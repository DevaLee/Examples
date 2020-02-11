//
//  WMGTextLayout.m
//  LYTextDrawer
//
//  Created by 李玉臣 on 2020/2/8.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//

#import "WMGTextLayout.h"
#import "WMGTextLayoutFrame.h"
@interface WMGTextLayout()
{
    struct {
        unsigned int needsLayout: 1;
    } _flags;
}
@property (nonatomic, strong) WMGTextLayoutFrame *layoutFrame;
@end


@implementation WMGTextLayout

-(instancetype)init {
    if (self = [super init]) {
        _flags.needsLayout = YES;
        _heightSensitiveLayout = YES;
        _baselineFontMetrics = WMGFontMetricsNull;
    }
    return self;
}

-(void)setAttributedString:(NSAttributedString *)attributedString {
    if (_attributedString != attributedString) {
        @synchronized (self) {
            _attributedString = attributedString;
        }
        [self setNeedsLayout];
    }
}

-(void)setSize:(CGSize)size {
    if (!CGSizeEqualToSize(_size, size)) {
        _size = size;
        _flags.needsLayout = YES;
    }
}

-(void)setMaximumNumberOfLines:(NSUInteger)maximumNumberOfLines {
    if (_maximumNumberOfLines != maximumNumberOfLines) {
        _maximumNumberOfLines = maximumNumberOfLines;
        [self setNeedsLayout];
    }
}

- (void)setBaselineFontMetrics:(WMGFontMetrics)baselineFontMetrics {
    if (!WMGFontMetricsEqual(_baselineFontMetrics, baselineFontMetrics)) {
        _baselineFontMetrics = baselineFontMetrics;
        [self setNeedsLayout];
    }
}
-(void)setNeedsLayout {
    _flags.needsLayout = YES;
}

#pragma mark - Layout Result

- (WMGTextLayoutFrame *)layoutFrame
{
    if (! _layoutFrame || _flags.needsLayout) {
        @synchronized(self) {
            _layoutFrame = [self _createLayoutFrame];
        }
        _flags.needsLayout = NO;
    }
    return _layoutFrame;
}

- (WMGTextLayoutFrame *)_createLayoutFrame
{
    const NSAttributedString *attributedString = _attributedString;

    if (!attributedString) {
        return nil;
    }

    CTFrameRef ctFrame = NULL;

    {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(( __bridge CFAttributedStringRef)attributedString);
        

        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, _size.width, _size.height));

        ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFRelease(path);
        CFRelease(framesetter);
    }

    if (!ctFrame) {
        return nil;
    }

    WMGTextLayoutFrame *layoutFrame = [[WMGTextLayoutFrame alloc] initWithCTFrame:ctFrame textLayout:self];

    CFRelease(ctFrame);

    return layoutFrame;
}

- (BOOL)layoutUpToDate
{
    return !_flags.needsLayout || !_layoutFrame;
}

@end



CGFloat const WMGTextLayoutMaximumWidth  = 2000;
CGFloat const WMGTextLayoutMaximumHeight = 10000000;
