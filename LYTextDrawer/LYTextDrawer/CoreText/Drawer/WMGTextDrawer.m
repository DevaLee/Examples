//
//  WMGTextDrawer.m
//  LYTextDrawer
//
//  Created by 李玉臣 on 2020/2/9.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//

#import "WMGTextDrawer.h"
#import "WMGTextLayout.h"
#import "WMGTextLayoutFrame.h"
#import "WMGTextLayoutLine.h"
#import "WMGTextLayout+Coordinate.h"
#import "WMGTextDrawer+Event.h"
#import "WMGTextDrawer+Debug.h"
#import "WMGTextDrawer+Coordinate.h"
#import "WMGContextAssisant.h"
#import "WMGraverMacroDefine.h"
#import "WMGAttachment.h"
#import "WMGActiveRange.h"
#import "WMGTextLayoutRun.h"

extern NSString * const WMGTextAttachmentAttributeName;

@interface WMGTextDrawer ()
{
    CGPoint _drawOrigin;
    BOOL drawing;
}
@property (nonatomic, assign) CGPoint drawOrigin;
@property (nonatomic, strong, readwrite) WMGTextLayout *textLayout;
@end

@implementation WMGTextDrawer


-(void)setFrame:(CGRect)frame {
    if (drawing && !CGSizeEqualToSize(frame.size, self.textLayout.size)) {
        WMGLog(@"draw_error");
    }
    _drawOrigin = frame.origin;

    if (self.textLayout.heightSensitiveLayout) {
        self.textLayout.size = frame.size;
    }else {
        CGFloat height = ceil((frame.size.height * 1.1) / 100000) * 100000;
        self.textLayout.size = CGSizeMake(frame.size.width, height);
    }
}

-(CGRect)frame {

    return CGRectMake(_drawOrigin.x, _drawOrigin.y, self.textLayout.size.width, self.textLayout.size.height);
}

-(WMGTextLayout *)textLayout {
    if (!_textLayout) {
        _textLayout = [[WMGTextLayout alloc] init];
        _textLayout.heightSensitiveLayout = YES;
    }
    return _textLayout;
}

#pragma mark - WMGTextDrawerDelegate
-(void)setDelegate:(id<WMGTextDrawerDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;

        // 是否替换attachment
        _delegateHas.placeAttachment = [delegate respondsToSelector:@selector(textDrawer:replaceAttachment:frame:context:)];
    }
}


#pragma mark - WMGTextDrawerEventDelegate
-(void)setEventDelegate:(id<WMGTextDrawerEventDelegate>)eventDelegate {

    if ([eventDelegate conformsToProtocol:@protocol(WMGTextDrawerEventDelegate)] ) {
        _eventDelegate = eventDelegate;

        _eventDelegateHas.contextView = [eventDelegate respondsToSelector:@selector(contextViewForTextDrawer:)];

        _eventDelegateHas.activeRanges = [eventDelegate respondsToSelector:@selector(activeRangesForTextDrawer:)];
        _eventDelegateHas.didPressActiveRange = [eventDelegate respondsToSelector:@selector(textDrawer:didPressActiveRange:)];
        _eventDelegateHas.shouldInteractWithActiveRange = [eventDelegate respondsToSelector:@selector(textDrawer:shouldInteractWithActiveRange:)];
        _eventDelegateHas.didHighlightedActiveRange = [eventDelegate respondsToSelector:@selector(textDrawer:didHighlightedActiveRange:rect:)];
    }
}
#pragma mark - drawing
- (void)draw {
    [self drawInContext:UIGraphicsGetCurrentContext()];
}

-(void)drawInContext:(CGContextRef)ctx {
    [self drawInContext:ctx shouldInterruptBlock:nil];
}


-(void)drawInContext:(CGContextRef)ctx shouldInterruptBlock:(WMGTextDrawerShouldInterruptBlock)block {
    [self drawInContext:ctx visibleRect:CGRectNull replaceAttachments:YES shouldInterruptBlock:block];
}
-(void)drawInContext:(CGContextRef)ctx visibleRect:(CGRect)visibleRect replaceAttachments:(BOOL)replaceAttachments shouldInterruptBlock:(WMGTextDrawerShouldInterruptBlock)block {
    if (!ctx) {
        return;
    }
    drawing = YES;

    WMGTextLayout *textLayout = [self textLayout];
    CGPoint drawingOrigin = _drawOrigin;
    CGSize drawingSize = textLayout.size;
#define should_interrupt (block && block())
#define interrupt_if_needed if(should_interrupt) {drawing = NO; return;}
    const BOOL partialDrawing = !CGRectIsNull(visibleRect);

    interrupt_if_needed;

    WMGTextLayoutFrame *layoutFrame = [textLayout.layoutFrame copy];

    if (!layoutFrame) {
        return;
    }
    interrupt_if_needed;

    // debugMode，添加绿色背景色
    if ([self.class debugModeEnabled]) {
        [self debugModeDrawLineFramesWithLayoutFrame:layoutFrame context:ctx];
    }
    interrupt_if_needed;


    // debugMode,点击区域添加蓝色背景,在点击的时候触发
    if (self.pressingActiveRange) {
        CGContextSaveGState(ctx);

        [layoutFrame enumerateEnclosingRectsForCharacterRange:self.pressingActiveRange.range usingBlock:^(CGRect rect, NSRange characterRange, BOOL * _Nonnull stop) {
            rect = [self convertRectFromLayout:rect offsetPoint:drawingOrigin];


            [self _drawHighlightedBackgroundForActiveRange:self.pressingActiveRange rect:rect context:ctx];

        }];
        CGContextRestoreGState(ctx);
    }

    interrupt_if_needed;

    // 坐标系转换 CoreText -> UIKit
    CGContextSaveGState(ctx);
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextTranslateCTM(ctx, 0, -textLayout.size.height);

    if (should_interrupt) {
        CGContextRestoreGState(ctx);
        drawing = NO;
        return;
    }

    int i = 0;
    for (WMGTextLayoutLine *line in layoutFrame.arrayLines) {

        if (textLayout.maximumNumberOfLines != 0 && i >= textLayout.maximumNumberOfLines) {
            continue;
        }

        CGRect fragmentRect = line.lineRect;

        // 调整origin
        fragmentRect = [self convertRectFromLayout:fragmentRect offsetPoint:drawingOrigin];
        if (partialDrawing && !CGRectIntersectsRect(fragmentRect, visibleRect)) {
            continue;
        }


        /**
         aaaaaaaaaa
         bbbbbbbbb
         cccccccccc
         */
        CTLineRef lineRef = line.lineRef;
        CGPoint lineOrigin = line.baselineOrigin;
        // height -  baselineOrigin.y = leading + descent
        lineOrigin.y = drawingSize.height - lineOrigin.y;
        lineOrigin.y -= drawingOrigin.y;
        lineOrigin.x += drawingOrigin.x;
        // 设置CTLine的绘制点
        CGContextSetTextPosition(ctx, lineOrigin.x, lineOrigin.y);
        CTLineDraw(lineRef, ctx);

        UIColor *strikeColor = [UIColor colorWithRed : ((CGFloat)((0x999999 & 0xFF0000) >> 16)) / 255.0 green : ((CGFloat)((0x999999 & 0xFF00) >> 8)) / 255.0 blue : ((CGFloat)(0x999999 & 0xFF)) / 255.0 alpha : 1.0];
        for (NSValue *rectValue in line.strikeThroughFrames) {
            CGRect strikeFrame = [rectValue CGRectValue];
            strikeFrame.origin.y = drawingSize.height - strikeFrame.origin.y;
            strikeFrame.origin.y -= drawingOrigin.y;
            strikeFrame.origin.x += drawingOrigin.x;

            CGContextSaveGState(ctx);
            CGContextSetTextPosition(ctx, strikeFrame.origin.x, strikeFrame.origin.y);
            CGContextMoveToPoint(ctx, strikeFrame.origin.x, strikeFrame.origin.y);
            CGContextAddLineToPoint(ctx, strikeFrame.origin.x + strikeFrame.size.width, strikeFrame.origin.y);

            CGContextSetStrokeColorWithColor(ctx, strikeColor.CGColor);
            CGContextStrokePath(ctx);
            CGContextRestoreGState(ctx);
        }
        if (should_interrupt) {
            CGContextRestoreGState(ctx);
            drawing = NO;
            return;
        }
        i += 1;
    }

    CGContextRestoreGState(ctx);

    // 需要替换文本组件
    if (replaceAttachments) {
        [self _drawAttachmentsInContext:ctx shouldInterrupt:block];
    }
    drawing = NO;

#undef interrupt_if_needed
#undef should_interrupt

}

-(void)_drawAttachmentsInContext:(CGContextRef)ctx shouldInterrupt:(WMGTextDrawerShouldInterruptBlock) shouldInterrupt {
#define should_interrupt (shouldInterrupt && shouldInterrupt())
#define interrupt_if_needed if(should_interrupt) {*stop = YES;}

    CGFloat scale = [UIScreen mainScreen].scale;
    CGPoint offset = _drawOrigin;

    [self.textLayout.layoutFrame.arrayLines enumerateObjectsUsingBlock:^(WMGTextLayoutLine * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        [line enumerateRunsUsingBlock:^(NSUInteger idx, NSDictionary * _Nonnull attributes, CTRunRef run, NSRange characterRange, BOOL * _Nonnull stop) {

            id <WMGAttachment> attchment = [attributes objectForKey:WMGTextAttachmentAttributeName];
            if (![attchment conformsToProtocol:@protocol(WMGAttachment)]) {
                return ;
            }


//            CGRect runBounds;
//            CGFloat ascent;
//            CGFloat descent;
//
//            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
//            runBounds.size.height = ascent + descent;
            // 文本组件的起始坐标
            CGPoint charaterOrign = [line baselineOriginForCharacterAtIndex:characterRange.location];

//            CTRunDelegateRef delegate = [WMGTextLayoutRun textLayoutRunWithAttachment:attchment];
            CGRect frame;

            WMGFontMetrics metrics = attchment.baselineFontMetrics;
            UIEdgeInsets edgeInsets = attchment.edgeInsets;

               frame = CGRectMake(charaterOrign.x + edgeInsets.left, charaterOrign.y + metrics.descent + metrics.leading - edgeInsets.bottom - attchment.size.height, attchment.size.width, attchment.size.height);
//            }

            frame.origin.x += offset.x;
            frame.origin.y += offset.y;

            frame.origin.x = round(frame.origin.x * scale) / scale;
            frame.origin.y = round(frame.origin.y * scale) / scale;

            // 如果有代理
            if (self -> _delegateHas.placeAttachment) {

                [self.delegate textDrawer:self replaceAttachment:attchment frame:frame context:ctx];
            }
            // 如果没代理
            else if (attchment.type == WMGAttachmentTypeStaticImage) {
                // 图片名称
                if ([attchment.contents isKindOfClass:[NSString class]]) {
                    UIGraphicsPushContext(ctx);
                    UIImage *image = [UIImage imageNamed:(NSString *)attchment.contents];
                    
                    [image drawInRect:frame];
                    UIGraphicsPopContext();
                }
                // 本地图片
                else if ([attchment.contents isKindOfClass:[UIImage class]]) {
                    UIGraphicsPushContext(ctx);
                    [(UIImage *)attchment.contents drawInRect:frame];
                    UIGraphicsPopContext();
                }
                //网络图片 - WMGImage

            }
        }];
    }];

#undef interrupt_if_needed
#undef should_interrupt
}

-(void)_drawHighlightedBackgroundForActiveRange:(id<WMGActiveRange>)activeRange rect:(CGRect)rect context:(CGContextRef)context {
    // debug 模式下，添加蓝色背景色
    if ([self.class debugModeEnabled]) {
        rect = CGRectIntegral(rect);
        UIColor *color = [UIColor blueColor];
        [color set];
        CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 8, color.CGColor);
        wmg_context_fill_round_rect(context, rect, 10);
    }

    // 相应点击的高亮区域
    if (_eventDelegateHas.didHighlightedActiveRange) {

        [_eventDelegate textDrawer:self didHighlightedActiveRange:activeRange rect:rect];
    }
}

#pragma mark - Event Handle
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIView *contextView = [self eventDelegateContextView];
    if (!contextView) {
        return;
    }

    // 相对于contextView的位置
    const CGPoint location = [[touches anyObject] locationInView:contextView];
    // 将坐标点从 TextDrawer 的绘制区域转换到文字布局中
    const CGPoint layoutLocation = [self convertPointToLayout:location offsetPoint:_drawOrigin];
    // 所有可以相应事件的点
    NSArray *rangeArray = [self eventDelegateActiveRanges];

    // 包含当前点击点的 activeRange
    id<WMGActiveRange> activeRange = [self rangeInRanges:rangeArray forLayoutLocation:layoutLocation];

    if (activeRange) {
        // pressingActiveRange 赋值
        [self setPressingActiveRange:activeRange];
        [contextView setNeedsDisplay];
    }

    _touchesBeginPoint = location;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIView *contextView = [self eventDelegateContextView];
    const CGFloat respondingRadius = 50;

    CGPoint location = [[touches anyObject] locationInView:contextView];

    CGFloat movedDistance = sqrt(pow((location.x - _touchesBeginPoint.x), 2.0) + pow((location.y - _touchesBeginPoint.y), 2.0));

    BOOL responds = movedDistance <= respondingRadius;
    // 大于50且有响应range
    if (!responds && self.pressingActiveRange) {
        self.savedPressingActiveRange = self.pressingActiveRange;
        self.pressingActiveRange = nil;

        [contextView setNeedsDisplay];
    }

    else if (responds && self.savedPressingActiveRange) {
        self.pressingActiveRange = self.savedPressingActiveRange;
        self.savedPressingActiveRange = nil;

        [contextView setNeedsDisplay];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_lastTouchEndedTimeStamp != event.timestamp) {
        self.savedPressingActiveRange = nil;
        _lastTouchEndedTimeStamp = event.timestamp;
        if (self.pressingActiveRange) {
            id<WMGActiveRange> activeRange = self.pressingActiveRange;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 委托代理
                [self eventDelegateDidPressActiveRange:activeRange];
            });

            _touchesBeginPoint = CGPointZero;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 若用户点击速度过快，hitRange高亮状态还未绘制又取消高亮会导致没有高亮效果
                // 故延迟执行
                // 取消高亮状态
                [self setPressingActiveRange:nil];
                [[self eventDelegateContextView] setNeedsDisplay];
            });
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.savedPressingActiveRange = nil;
    if (self.pressingActiveRange) {
        // 取消高亮状态
        self.pressingActiveRange = nil;
        [[self eventDelegateContextView] setNeedsDisplay];
    }
}
#pragma mark - Hit Testing

- (id<WMGActiveRange>)rangeInRanges:(NSArray *)ranges forLayoutLocation:(CGPoint)location {

    for (id<WMGActiveRange> activeRange in ranges) {
        BOOL __block hit = NO;
        // 找到location所处的Range
        [self.textLayout.layoutFrame enumerateEnclosingRectsForCharacterRange:activeRange.range usingBlock:^(CGRect rect, NSRange characterRange, BOOL * _Nonnull stop) {
            if (CGRectContainsPoint(rect, location)) {
                hit = YES;
                *stop = YES;
            }
        }];

        // 代理控制是否可以响应
        if (hit && _eventDelegateHas.shouldInteractWithActiveRange) {
            hit = [_eventDelegate textDrawer:self shouldInteractWithActiveRange:activeRange];
        }

        if (hit) {
            return activeRange;
        }

    }
    return nil;
}

#pragma mark - Event Delegate

- (UIView *)eventDelegateContextView {
    if (_eventDelegateHas.contextView) {
        return [_eventDelegate contextViewForTextDrawer:self];
    }
    return nil;
}

-(NSArray *)eventDelegateActiveRanges {
    if (_eventDelegateHas.activeRanges) {
        return [_eventDelegate activeRangesForTextDrawer:self];
    }
    return nil;
}

- (void)eventDelegateDidPressActiveRange:(id<WMGActiveRange>)activeRange {
    if (_eventDelegateHas.didPressActiveRange) {
        [_eventDelegate textDrawer:self didPressActiveRange:activeRange];
    }
}
@end
