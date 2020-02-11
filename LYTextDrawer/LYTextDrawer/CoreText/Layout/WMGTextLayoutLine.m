//
//  WMGTextLayoutLine.m
//  LYTextDrawer
//
//  Created by 李玉臣 on 2020/2/8.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//

#import "WMGTextLayoutLine.h"
#import "WMGTextLayout.h"
#import "NSMutableAttributedString+GTextProperty.h"
#import "WMGTextLayout+Coordinate.h"
#import "WMGTextLayoutRun.h"

extern NSString * const WMGTextStrikethroughStyleAttributeName;
@interface WMGTextLayoutLine ()
{
    CTLineRef _lineRef;
    CGFloat _lineWidth;
}
// 中划线的在CTFrame中的frame（由CTLine的originPoint和NSRange确定）
@property (nonatomic, strong, readwrite) NSArray *strikeThroughFrames;
@end


@implementation WMGTextLayoutLine
-(void)dealloc {
    if (_lineRef) {
        CFRelease(_lineRef);
        _lineRef = NULL;
    }
}



- (id) initWithCTLine:(CTLineRef)lineRef baselineOrigin:(CGPoint)baselineOrigin textLayout:(WMGTextLayout *)textLayout {
    return [self initWithCTLine:lineRef truncatedLine:NULL baselineOrigin:baselineOrigin textLayout:textLayout];
}

- (id)initWithCTLine:(CTLineRef)lineRef truncatedLine:(CTLineRef)truncatedLineRef baselineOrigin:(CGPoint)baselineOrigin textLayout:(WMGTextLayout *)textLayout {
    if (self = [self init]) {
        if (lineRef) {
            _truncated = (truncatedLineRef != NULL);
            _lineRef = CFRetain(truncatedLineRef ? : lineRef);

            CGFloat a, d, l;
            _lineWidth = CTLineGetTypographicBounds(_lineRef, &a, &d, &l);

            // 获取CTLine在原始字符串中的Range
            CFRange range = CTLineGetStringRange(_lineRef);
            _originStringRange = NSMakeRange(range.location, range.length);

            CFRange truncatedRange = CTLineGetStringRange(lineRef);
            _truncatedStringRange = NSMakeRange(truncatedRange.location, truncatedRange.length);

            if (truncatedLineRef) {
                _originStringRange.length = truncatedRange.length;
            }

            _originalFontMetrics = WMGFontMetricsMake(ABS(a), ABS(d), ABS(l));
            _fontMetrics = WMGFontMetricsMake(ABS(a), ABS(d), ABS(l));

            // 基线调整

           double baselineOriginY = baselineOrigin.y;
           if (textLayout.baselineFontMetrics.descent != NSNotFound) {
               baselineOriginY -= (_fontMetrics.descent - textLayout.baselineFontMetrics.descent);
           }

           if (textLayout.baselineFontMetrics.leading != NSNotFound &&
               textLayout.baselineFontMetrics.leading) {
               baselineOriginY -= (_fontMetrics.leading - textLayout.baselineFontMetrics.leading);
           }

           //12.3
           double lineHeight = _fontMetrics.ascent + _fontMetrics.descent + _fontMetrics.leading;
           // 13
           double ceilResult = ceil(lineHeight) - lineHeight;
           // 14
           ceilResult += 1;

           baselineOriginY -= ceilResult;

           _baselineOrigin = CGPointMake(baselineOrigin.x, floor(baselineOriginY));

           // CoreText Coordinate Convert to UI Coordinate
           _originalBaselineOrigin = [textLayout wmg_UIPointFromCTPoint:_originalBaselineOrigin];
           _baselineOrigin = [textLayout wmg_UIPointFromCTPoint:_baselineOrigin];

           if (textLayout.baselineFontMetrics.ascent == NSNotFound && textLayout.retriveFontMetricsAutomatically) {
               textLayout.baselineFontMetrics = _fontMetrics;
           }
            // 删除线
            NSMutableArray *array = [NSMutableArray array];
            [textLayout.attributedString enumerateAttribute:WMGTextStrikethroughStyleAttributeName inRange:_originStringRange options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {

                if (value) {
                    WMGTextStrikeThroughStyle style = [value unsignedIntValue];
                    CGFloat start = [self offsetXForCharacterAtIndex:range.location];
                    CGFloat end = [self offsetXForCharacterAtIndex:NSMaxRange(range)];

                    [array addObject:[NSValue valueWithCGRect:CGRectMake(start, self.baselineOrigin.y - 3, end - start, (style == WMGTextStrikeThroughStyleSingle) ? 1 : 2)]];
                }
            }];
            self.strikeThroughFrames = array;
        }
    }
    return self;
}



-(CGRect)originalLineRect {

    return CGRectIntegral(CGRectMake(_originalBaselineOrigin.x, _originalBaselineOrigin.y - _originalFontMetrics.ascent, _lineWidth, WMGFontMetricsGetLineHeight(_originalFontMetrics)));
}


-(CGRect)lineRect {

    return CGRectIntegral(CGRectMake(_baselineOrigin.x, _baselineOrigin.y - _fontMetrics.ascent, _lineWidth, WMGFontMetricsGetLineHeight(_fontMetrics)));
}

-(CTLineRef)lineRef {

    return _lineRef;
}

- (NSInteger)_rangeLocOffset {
    if (!_lineRef) {
        return 0;
    }

    return MAX(_originStringRange.location - _truncatedStringRange.location, 0);
}
//  计算指定索引位置字符相对于行基线原点的偏移量
- (CGFloat)offsetXForCharacterAtIndex:(NSUInteger)characterIndex
{
    if (!_lineRef) {
        return 0;
    }
    NSInteger locOffset = [self _rangeLocOffset];
    characterIndex -= MIN(characterIndex, locOffset);

    CGFloat offset = CTLineGetOffsetForStringIndex(_lineRef, characterIndex, NULL);
    return offset;
}

// 计算指定索引位置字符相对于行基线原点的偏移坐标Point
- (CGPoint)baselineOriginForCharacterAtIndex:(NSUInteger)characterIndex {
    CGPoint origin = _baselineOrigin;
    if (!_lineRef) {
        return origin;
    }

    NSInteger locOffset = [self _rangeLocOffset];
    characterIndex -= MIN(characterIndex, locOffset);

    CGFloat offset = CTLineGetOffsetForStringIndex(_lineRef, characterIndex, NULL);
    origin.x += offset;

    return origin;
}

// 通过点击位置，得到对应字符的索引值


- (NSUInteger)characterIndexForBoundingPosition:(CGPoint)position {
    NSUInteger index = _originStringRange.location;
    if (_lineRef) {
        // position :The location of the mouse click relative to the line's origin
        // result: The string index for the position. Relative to the line's string
        // range
        index = CTLineGetStringIndexForPosition(_lineRef, position);
        index += [self _rangeLocOffset];
    }

    return index;
}


- (void)enumerateRunsUsingBlock:(void (^)(NSUInteger idx,  NSDictionary * attributes,CTRunRef run, NSRange characterRange, BOOL *stop))block {
    if (!_lineRef || !block) {
        return;
    }

    NSInteger locOffset = [self _rangeLocOffset];

    NSArray *runs = (NSArray *)CTLineGetGlyphRuns(_lineRef);
    [runs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CTRunRef run = (__bridge CTRunRef)obj;
        NSDictionary *attribute = (NSDictionary *)CTRunGetAttributes(run);
        CFRange range = CTRunGetStringRange(run);
        NSRange nsRange = NSMakeRange(range.location, range.length);
        nsRange.location += locOffset;

        block(idx, attribute, run, nsRange, stop);
    }];
}



- (id)copyWithZone:(NSZone *)zone
{
    WMGTextLayoutLine *line = [[[self class] allocWithZone:zone] init];
    line->_lineRef = _lineRef;
    line->_truncated = _truncated;
    line->_lineWidth = _lineWidth;

    line->_originalBaselineOrigin = _originalBaselineOrigin;
    line->_baselineOrigin = _baselineOrigin;

    line->_originStringRange = _originStringRange;
    line->_truncatedStringRange = _truncatedStringRange;

    line->_originalFontMetrics = _originalFontMetrics;
    line->_fontMetrics = _fontMetrics;

    return line;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    WMGTextLayoutLine *line = [[self class] allocWithZone:zone];
    return line;
}

@end
