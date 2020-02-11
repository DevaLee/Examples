//
//  WMGTextLayoutFrame.m
//  LYTextDrawer
//
//  Created by 李玉臣 on 2020/2/8.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//

#import "WMGTextLayoutFrame.h"
#import "WMGTextLayout.h"
#import "WMGTextLayoutLine.h"

extern NSString * const WMGTextDefaultForegroundColorAttributeName;
// 省略号
static NSString *WMGEllipsisCharacter = @"\u2026";

@interface WMGTextLayoutFrame ()<NSCopying,NSMutableCopying>
@property (nonatomic, weak) WMGTextLayout *textLayout;
@property (nonatomic, strong, readwrite) NSMutableArray <WMGTextLayoutLine *> *arrayLines;
@property (nonatomic, assign, readwrite) CGSize layoutSize;

@end


@implementation WMGTextLayoutFrame

-(id)initWithCTFrame:(CTFrameRef)frameRef textLayout:(WMGTextLayout *)textLayout {
    if (self = [super init]) {
        _textLayout  = textLayout;
        if (frameRef) {
            [self setupWithCTFrame:frameRef];

        }
    }
    return self;
}


// 根据 CTFrameRef 确定 layoutSize ，创建 CTLine，根据TextLayout的AttributeString,确定CTLine的中划线的range，根据maximumNumberOfLines，确定CTLine是否需要截断，
-(void)setupWithCTFrame:(CTFrameRef)frameRef {

       _frameRef = frameRef;
    const NSUInteger maximumNumberOfLines = _textLayout.maximumNumberOfLines;
    // 获取所有的CTLine
    NSArray *lines = (NSArray *)CTFrameGetLines(frameRef);
    NSUInteger lineCount = lines.count;
    CGPoint lineOrigins[lineCount];
    // 获取每一行的基线原点
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, lineCount), lineOrigins);
    _arrayLines =[NSMutableArray array];

    for (NSInteger i = 0; i < lineCount; i++) {
        CTLineRef lineRef = (__bridge CTLineRef)lines[i];
        CTLineRef truncatedLineRef = NULL;

        if (maximumNumberOfLines) {
            if (i == maximumNumberOfLines - 1) {
                BOOL truncated = NO;

                // 判断是否需要截断
                truncatedLineRef = (__bridge CTLineRef)[self _textLayout:_textLayout truncateLine:lineRef atIndex:i truncated:&truncated];
                if (!truncated) {
                    truncatedLineRef = NULL;
                }
            }else if (i > maximumNumberOfLines ) {

                break;
            }
        }

       

        WMGTextLayoutLine *line = [[WMGTextLayoutLine alloc] initWithCTLine:lineRef truncatedLine:truncatedLineRef baselineOrigin:lineOrigins[i] textLayout:_textLayout];
        [_arrayLines addObject:line];
        
    }

    [self _updateLayoutSize];
}

- (void)_updateLayoutSize {

    CGFloat __block width = 0.0;
    CGFloat __block height = 0.0;
    NSUInteger lineCount = _arrayLines.count;

    [_arrayLines enumerateObjectsUsingBlock:^(WMGTextLayoutLine * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {

        CGRect fragmentRect = line.lineRect;
        if (idx == lineCount - 1) {
            height = CGRectGetMaxX(fragmentRect);
        }

        width = MAX(width, CGRectGetMaxX(fragmentRect));
    }];

    _layoutSize = CGSizeMake(ceil(width), ceil(height));
}

#pragma mark - Line Truncating

- (id)_textLayout:(WMGTextLayout *)textLayout truncateLine:(CTLineRef)lineRef atIndex:(NSUInteger)index truncated:(BOOL *)truncated
{
    if (!lineRef) {
        if (truncated) {
            *truncated = NO;
        }
        return nil;
    }

    const CFRange stringRange = CTLineGetStringRange(lineRef);

    if (stringRange.length == 0) {
        if (truncated) {
            *truncated = NO;
        }
        return (__bridge id)lineRef;
    }

    CGFloat truncateWidth = textLayout.size.width;

    const CGFloat delegateMaxWidth = [self textLayout:textLayout maximumWidthForTruncatedLine:lineRef atIndex:index];
    BOOL needsTruncate = NO;

    if (delegateMaxWidth < truncateWidth && delegateMaxWidth > 0) {
        CGFloat lineWidth = CTLineGetTypographicBounds(lineRef, NULL, NULL, NULL);
        if (lineWidth > delegateMaxWidth) {
            truncateWidth = delegateMaxWidth;
            needsTruncate = YES;
        }
    }

    if (!needsTruncate) {
        if (stringRange.location + stringRange.length < textLayout.attributedString.length) {
            needsTruncate = YES;
        }
    }

    if (!needsTruncate) {
        // 依旧不需要截断
        if (truncated) {
            *truncated = NO;
        }
        return (__bridge id)lineRef;
    }

    const NSAttributedString *attributedString = textLayout.attributedString;

    // Get correct truncationType and attribute position
    CTLineTruncationType truncationType = kCTLineTruncationEnd;
    NSUInteger truncationAttributePosition = stringRange.location + (stringRange.length - 1);

    // Get the attributes and use them to create the truncation token string
    NSDictionary *attrs = [attributedString attributesAtIndex:truncationAttributePosition effectiveRange:NULL];
    attrs = [attrs dictionaryWithValuesForKeys:@[(id)kCTFontAttributeName, (id)kCTParagraphStyleAttributeName, (id)kCTForegroundColorAttributeName, WMGTextDefaultForegroundColorAttributeName]];

    // Filter all NSNull values
    NSMutableDictionary *tokenAttributes = [NSMutableDictionary dictionary];
    [attrs enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSNull class]]) {
            [tokenAttributes setObject:obj forKey:key];
        }
    }];

    CGColorRef cgColor = (__bridge CGColorRef)[tokenAttributes objectForKey:WMGTextDefaultForegroundColorAttributeName];
    if (cgColor) {
        [tokenAttributes setValue:(__bridge id)cgColor forKey:(NSString *)kCTForegroundColorAttributeName];
    }

    // 如果设置了truncationString，则用自定义的
    NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:WMGEllipsisCharacter attributes:tokenAttributes];
    if (_textLayout.truncationString) {
        tokenString = _textLayout.truncationString;
    }
    CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)tokenString);

    // Append truncationToken to the string
    // because if string isn't too long, CT wont add the truncationToken on it's own
    // There is no change of a double truncationToken because CT only add the token if it removes characters (and the one we add will go first)
    NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange(stringRange.location, stringRange.length)] mutableCopy];
    if (stringRange.length > 0)
    {
        // Remove any newline at the end (we don't want newline space between the text and the truncation token). There can only be one, because the second would be on the next line.
        unichar lastCharacter = [[truncationString string] characterAtIndex:stringRange.length - 1];
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastCharacter])
        {
            [truncationString deleteCharactersInRange:NSMakeRange(stringRange.length - 1, 1)];
        }
    }

    [truncationString appendAttributedString:tokenString];
    CTLineRef truncationLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationString);

    // Truncate the line in case it is too long.
    CTLineRef truncatedLine;
    truncatedLine = CTLineCreateTruncatedLine(truncationLine, truncateWidth, truncationType, truncationToken);

    CFRelease(truncationLine);
    if (!truncatedLine)
    {
        // If the line is not as wide as the truncationToken, truncatedLine is NULL
        truncatedLine = CFRetain(truncationToken);
    }

    CFRelease(truncationToken);

    if (truncated) {
        *truncated = YES;
    }

    return CFBridgingRelease(truncatedLine);
}

- (CGFloat)textLayout:(WMGTextLayout *)textLayout maximumWidthForTruncatedLine:(CTLineRef)lineRef atIndex:(NSUInteger)index
{
    if ([textLayout.delegate respondsToSelector:@selector(textLayout:maximumWidthForTruncatedLine:atIndex:)]) {
        CGFloat width = [textLayout.delegate textLayout:textLayout maximumWidthForTruncatedLine:lineRef atIndex:index];
        return floor(width);
    }

    return textLayout.size.width;
}

#pragma mark - NSCopying & NSMutableCopying

- (id)copyWithZone:(NSZone *)zone
{
    WMGTextLayoutFrame *copy = [[[self class] allocWithZone:zone] init];
    copy.textLayout = self.textLayout;
    copy.arrayLines = [self.arrayLines copy];
    copy.layoutSize = CGSizeMake(_layoutSize.width, _layoutSize.height);
    return copy;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    WMGTextLayoutFrame *copy = [WMGTextLayoutFrame allocWithZone:zone];
    return copy;
}

#pragma mark - Result

- (void)enumerateLinesUsingBlock:(void (^)(NSUInteger, CGRect, NSRange, BOOL * _Nonnull))block {
    if (!block) {
        return;
    }

    [self.arrayLines enumerateObjectsUsingBlock:^(WMGTextLayoutLine * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        block(idx, line.lineRect, line.originStringRange,stop);
    }];
}
/**
 第一个选中区域的rect
 aaaaaaaaaaaabbb
 bbbbbbaaaaaaaa

 返回的是 bbb的rect
 */

- (CGRect)firstSelectionRectForCharacterRange:(NSRange)characterRange {
    CGRect __block selectionRect = CGRectNull;

    [self enumerateEnclosingRectsForCharacterRange:characterRange usingBlock:^(CGRect rect, NSRange characterRange, BOOL * _Nonnull stop) {
        selectionRect = rect;
        *stop = YES;
    }];
    return selectionRect;
}

- (CGRect)enumerateSelectionRectsForCharacterRange:(NSRange)characterRange usingBlock:(void (^)(CGRect, NSRange, BOOL * _Nonnull))block {

    CGSize containerSize = self.textLayout.size;
    CGRect __block boundingRect = CGRectNull;

    [self enumerateEnclosingRectsForCharacterRange:characterRange usingBlock:^(CGRect rect, NSRange lineRange, BOOL * _Nonnull stop) {
        // aaaaaaaabbbbbbbbbbaaaaaaaa
        if (NSMaxRange(lineRange) < NSMaxRange(characterRange)) {
            rect.size.width = containerSize.width - CGRectGetMinX(rect);
        }
        if (block) {
            if (!CGRectIsNull(boundingRect)) {
                CGFloat deltaHeight = rect.origin.y - CGRectGetMaxX(boundingRect);
                rect.origin.y -= deltaHeight;
                rect.size.height += deltaHeight;
            }
            block(rect, characterRange, stop);
        }
        boundingRect = CGRectUnion(boundingRect, rect);
    }];

    return boundingRect;
}


//选中区域的所有rect
-(void)enumerateEnclosingRectsForCharacterRange:(NSRange)characterRange usingBlock:(void (^)(CGRect, NSRange, BOOL * _Nonnull))block {
    if (!block) {
        return;
    }

    const NSUInteger lineCount = [self.arrayLines count];

    [self.arrayLines enumerateObjectsUsingBlock:^(WMGTextLayoutLine * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        const NSRange lineRange = line.originStringRange;//在原始字符串中的range
        const CGRect lineRect = line.lineRect;

        const NSUInteger lineStartIndex = lineRange.location;
        const NSUInteger lineEndIndex = NSMaxRange(lineRange);

        NSUInteger characterStartIndex = characterRange.location;
        NSUInteger characterEndIndex = NSMaxRange(characterRange);


        if (characterStartIndex > lineEndIndex) {
            // 不在该行，继续遍历下一行
            return ;
        }
        if (idx == lineCount - 1) {
            // 最后一行,防止越界
            characterEndIndex = MIN(lineEndIndex, characterEndIndex);
        }

        const BOOL containsStartIndex = WMRangeContainsIndex(lineRange, characterStartIndex);
        const BOOL containsEndIndex = WMRangeContainsIndex(lineRange, characterEndIndex);

        /**
         aaaaaaaaaaaaa
         aabbbbbbbaaa
         aaaaaaaaaaaaa
         aaaaaaaaaaaa
         */
        // 一共只有一行
        if (containsStartIndex && containsEndIndex) {
            if (characterStartIndex != characterEndIndex) {
                CGFloat startOffset = [line offsetXForCharacterAtIndex:characterStartIndex];
                CGFloat endOffset = [line offsetXForCharacterAtIndex:characterEndIndex];
                CGRect rect = lineRect;
                // 目标区域的rect
                rect.origin.x += startOffset;
                rect.size.width = endOffset - startOffset;

                block(rect, NSMakeRange(characterStartIndex, characterEndIndex - characterStartIndex), stop);

            }
            *stop = YES;
        }
        /**
         aaaaaaaaaaaaaaa
         aaaaaaabbbbbbb
         bbbbbbbbbbaaaa
         aaaaaaaaaaaaaaa
         */
        // 多行时的第一行
        else if (containsStartIndex) {

            if (characterStartIndex != NSMaxRange(lineRange)) {
                CGFloat startOffset = [line offsetXForCharacterAtIndex:characterStartIndex];

                CGRect rect = lineRect;
                rect.origin.x += startOffset;
                rect.size.width -= startOffset;

                block(rect, NSMakeRange(lineStartIndex, lineEndIndex - characterStartIndex), stop);
            }
        // 多行的最后一行
        }else if (containsEndIndex) {
            CGFloat endOffset = [line offsetXForCharacterAtIndex:characterEndIndex];
            CGRect rect = lineRect;
            rect.size.width = endOffset;

             *stop = YES;
            block(rect, NSMakeRange(lineStartIndex, characterEndIndex - lineStartIndex), stop);
        }
        // 多行时的中间行
        else if (WMRangeContainsIndex(characterRange, lineRange.location)) {
            block(lineRect, lineRange, stop);
        }

        if (containsEndIndex) {
            *stop = YES;
        }

    }];
}

#pragma mark - 第 charaterIndex 个字 ，在第几行
- (NSUInteger)lineIndexForCharacterAtIndex:(NSUInteger)characterIndex {

    NSUInteger __block lineIndex = NSNotFound;
    [self.arrayLines enumerateObjectsUsingBlock:^(WMGTextLayoutLine * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {

        if (WMRangeContainsIndex(line.originStringRange, characterIndex)
            && characterIndex != NSMaxRange(line.originStringRange)) {
            lineIndex = idx;
            *stop = YES;
        }
    }];

    return lineIndex;
}

#pragma mark  - 第 index 行 的 CGRect
-(CGRect)lineRectForLineAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)effectiveCharacterRange {
    if (index >= [self.arrayLines count]) {
        if (effectiveCharacterRange) {
            *effectiveCharacterRange = NSMakeRange(NSNotFound, 0);
        }
        return CGRectNull;
    }
    WMGTextLayoutLine *line = self.arrayLines[index];
    if (effectiveCharacterRange) {
        *effectiveCharacterRange = line.originStringRange;
    }

    return line.lineRect;
}
#pragma mark - 第 index 个字，所在行的CGRect
-(CGRect)lineRectForCharacterAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)effectiveCharacterRange {
    NSUInteger lineIndex = [self lineIndexForCharacterAtIndex:index];

    return [self lineRectForLineAtIndex:lineIndex effectiveRange:effectiveCharacterRange];
}

#pragma mark - 第characterIndex字，对应的CGPoint
- (CGPoint)locationForCharacterAtIndex:(NSUInteger)characterIndex {
    CGRect rect = [self boundingRectForCharacterRange:NSMakeRange(characterIndex, 1)];
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

- (CGRect)boundingRectForCharacterRange:(NSRange)characterRange {
    return [self enumerateSelectionRectsForCharacterRange:characterRange usingBlock:NULL];
}
#pragma mark - 第index行的 基点坐标
-(CGPoint)positionForLinesAtIndex:(NSUInteger)index {
    WMGTextLayoutLine *line = [self.arrayLines objectAtIndex:index];
    if (line) {
        return line.baselineOrigin;
    }

    return CGPointZero;
}

#pragma mark - 第index行的 CGRect
-(CGRect)rectForLinesAtIndex:(NSUInteger)index {
    WMGTextLayoutLine *line = [self.arrayLines objectAtIndex:index];
    if (line) {
        return line.lineRect;
    }

    return CGRectZero;
}

#pragma mark -- Private

BOOL WMRangeContainsIndex(NSRange range, NSUInteger index) {
    BOOL a = (index >= range.location);
    BOOL b = (index <= (range.location + range.length));

    return (a && b);
}


#pragma mark - Hit Test

#pragma mark - 获得点击Rect对应的字符串Range

-(NSRange)characterRangeForBoundingRect:(CGRect)bounds {
    CGPoint topLeftPoint = bounds.origin;
    CGPoint bottomRightPoint = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));

    // 将 bounds 限制在有效区域内
    topLeftPoint.y = MIN(2, topLeftPoint.y);
    bottomRightPoint.y = MAX(bottomRightPoint.y, self.layoutSize.height - 2);

    NSUInteger start = [self characterIndexForPoint:topLeftPoint];
    NSUInteger end = [self characterIndexForPoint:bottomRightPoint];

    return NSMakeRange(start, end - start);
}
#pragma mark -- 获取某一坐标上的文字对应的字符串 index
-(NSUInteger)characterIndexForPoint:(CGPoint)point {
    const NSString *string = self.textLayout.attributedString.string;
    const NSUInteger stringLength = string.length;
    const NSArray *lines = self.arrayLines;
    const NSUInteger lineCount = lines.count;

    CGFloat previousLineY = 0;

    for (NSInteger i = 0; i < lineCount; i++) {
        WMGTextLayoutLine *line = lines[i];
        CGRect fragmentRect = line.lineRect;

        // 在第一行之上
        if (i == 0 && point.y < CGRectGetMinY(fragmentRect)) {
            return 0;
        }
        // 在最后一行之下
        if (i == lineCount - 1 && point.y > CGRectGetMaxY(fragmentRect)) {
            return stringLength;
        }
        // 命中
        if (point.y > previousLineY && point.y <= CGRectGetMaxY(fragmentRect)) {
            // 坐标转化成在相对于基准点的坐标
            point.x -= line.baselineOrigin.x;
            point.y -= line.baselineOrigin.y;

            NSUInteger index = [line characterIndexForBoundingPosition:point];

            NSRange stringRange = line.originStringRange;
            if (index == NSMaxRange(stringRange) && index > 0) {
                if ([string characterAtIndex:index - 1] == '\n') {
                    index --;
                }
            }
            return index;

        }

        previousLineY = CGRectGetMaxY(fragmentRect);
    }
    return 0;
}

@end


