//
//  ExampleView.m
//  LYTextDrawer
//
//  Created by 李玉臣 on 2020/2/9.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//

#import "ExampleView.h"
#import "WMGTextDrawer.h"
#import "WMGTextDrawer.h"
#import "WMGTextAttachment.h"
#import "WMGTextLayout.h"
#import "WMGTextLayoutFrame.h"
#import <CoreText/CoreText.h>
#import "WMGTextDrawer+Debug.h"
#import "WMGTextLayoutRun.h"
#import "WMGTextAttachment+Event.h"
#import "WMGTextActiveRange.h"
@interface ExampleView()<WMGTextDrawerEventDelegate>
@property (nonatomic, strong) NSMutableAttributedString *attrStr;
@property (nonatomic, strong) WMGTextDrawer *textDrawer;

@property (nonatomic, strong) WMGTextAttachment *textAttachment;

@end


@implementation ExampleView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;

        _attrStr = [[NSMutableAttributedString alloc] initWithString:@"这些喜欢矫"];

        // 新建图片组件信息
        WMGTextAttachment *attachment = [[WMGTextAttachment alloc] init];
        attachment.type = WMGAttachmentTypeStaticImage;
        attachment.contents = [UIImage imageNamed:@"aiqing"];
        attachment.size = CGSizeMake(40, 40);
        attachment.position = 5;// 在字符串中的index
        attachment.length = 1;// 所占字符长度
        attachment.userInfo = @{@"content": attachment.contents};
        self.textAttachment = attachment;

        // 设置占位符的高度
        WMGFontMetrics fontMetric = WMGFontMetricsMake(attachment.size.height, 0, 0);
        attachment.baselineFontMetrics = fontMetric;

        // 给图片添加点击事件
        [attachment addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];

        NSAttributedString *str1 = [NSAttributedString wmg_attributedStringWithTextAttachment:attachment];

        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:@"枉过正的中国近代知识分子，他们不否定读书人群体存在的必要性，但主张自己要和工人打成一片"];
        [_attrStr appendAttributedString:str1];
        [_attrStr appendAttributedString:str2];
        [_attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, _attrStr.string.length)];

        NSMutableAttributedString *strdd = [[NSMutableAttributedString alloc] initWithString:_attrStr.string];
        // 拼接文本组件信息
        [strdd addAttribute:WMGTextAttachmentAttributeName value:attachment range:NSMakeRange(5, 1)];
        CTRunDelegateRef delegate = [WMGTextLayoutRun textLayoutRunWithAttachment:attachment];
        [strdd addAttribute:(NSString * )kCTRunDelegateAttributeName value:(__bridge id )delegate range:NSMakeRange(5, 1)];

        // 添加蓝色字体
        [strdd addAttribute:(NSString *)kCTForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(8, 5)];

        [strdd addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, strdd.string.length)];


        _textDrawer = [[WMGTextDrawer alloc] init];
        // frame 必须设置
        _textDrawer.frame = self.bounds;
        // 设置最大行数
        _textDrawer.textLayout.maximumNumberOfLines = 2;
        _textDrawer.textLayout.attributedString = strdd;
        // 设置点击事件代理
        _textDrawer.eventDelegate = self;

    }
    return self;
}


-(void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    // CoreText绘制
    [self exampleDrawRect:context];

    // WMGTextDrawer绘制
//    [self textDrawDrawInContext:context];

}

#pragma mark - action

- (void)clickAction:(NSDictionary *)userInfo {

    UIImage *clickImage = userInfo[@"content"];


    NSLog(@"点击图片 %@",clickImage);
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textDrawer touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textDrawer touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textDrawer touchesEnded:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textDrawer touchesCancelled:touches withEvent:event];
}


#pragma mark - draw

-(void)textDrawDrawInContext:(CGContextRef) context {


    // 开始绘制
    [_textDrawer drawInContext:context visibleRect:CGRectNull replaceAttachments:YES shouldInterruptBlock:nil];
}

#pragma mark -- TextDrawerEventDelegate

/**
 *  返回 textDrawer 处理事件时所基于的 view，用于确定坐标系等，必须
 *
 *  @param textDrawer 查询的 textDrawer
 *
 *  @return 处理事件时基于的 view
 */
- (UIView *)contextViewForTextDrawer:(WMGTextDrawer *)textDrawer {

    return self;
}

/**
 *  返回定义 textDrawer 可点击区域的数组
 *
 *  @param textDrawer 查询的 textDrawer
 *
 *  @return 由 (id<WMGTextActiveRange>) 对象组成的数组
 */
- (NSArray *)activeRangesForTextDrawer:(WMGTextDrawer *)textDrawer{

    WMGTextAttachment *att = self.textAttachment;
    WMGTextActiveRange *range = [WMGTextActiveRange activeRange:NSMakeRange(att.position, att.length) type:WMGActiveRangeTypeAttachment text:@""];
    range.bindingData = att;



    NSString *text = [textDrawer.textLayout.attributedString.string substringWithRange:NSMakeRange(8, 5)];
    WMGTextActiveRange *rangeText = [WMGTextActiveRange activeRange:NSMakeRange(8, 5) type:WMGActiveRangeTypeText text:text];

    return @[range, rangeText];
}

/**
 *  响应对一个 activeRange 的点击事件
 *
 *  @param textDrawer 响应事件的 textDrawer
 *  @param activeRange  响应的 activeRange
 */
- (void)textDrawer:(WMGTextDrawer *)textDrawer didPressActiveRange:(id<WMGActiveRange>)activeRange {

    if (activeRange.type == WMGActiveRangeTypeAttachment) {
        WMGTextAttachment *att = (WMGTextAttachment *)activeRange.bindingData;

        [att handleEvent:att.userInfo];
    }else if (activeRange.type == WMGActiveRangeTypeText) {
        NSLog(@"点击了文字：%@",activeRange.text);
    }
}


- (BOOL)textDrawer:(WMGTextDrawer *)textDrawer shouldInteractWithActiveRange:(id<WMGActiveRange>)activeRange {

    return YES;
}


- (void)textDrawer:(WMGTextDrawer *)textDrawer didHighlightedActiveRange:(id<WMGActiveRange>)activeRange rect:(CGRect)rect {

}


#pragma mark - CoreContext Draw

- (void)exampleDrawRect:(CGContextRef) context {

     CGContextTranslateCTM(context, 0, self.bounds.size.height);
     CGContextScaleCTM(context, 1.0, -1.0);
     CGContextSetTextMatrix(context, CGAffineTransformIdentity);

     CTRunDelegateRef delegate = [ExampleView textLayoutRunWithAttachment];
 
     NSMutableAttributedString *strShou = [[NSMutableAttributedString alloc] initWithString:@"sdfsdfsd见风使舵积分开始的； SDK积分卡时间段；开发就开始了大家快速健康管理记录福建烤老鼠；的；放假快乐；； 接口螺丝刀荆防颗粒时代峻峰克鲁赛德降费率；可视对讲建设大街付款收到了；就开始威尔额外近日为今日我玩儿翁"];


     // 使用0xFFFC作为空白的占位符,
        unichar objectReplacementChar = 0xFFFC;
        NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];

     NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content attributes:@{}];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);

     CFRelease(delegate);

     NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"积分热ITUI偶尔up我哦呜日哦乌尔破我围殴温柔四大皆空"];
     [strShou appendAttributedString:space];
     [strShou appendAttributedString:str];

     CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)strShou);

     CGMutablePathRef path = CGPathCreateMutable();
     CGPathAddRect(path, NULL, self.bounds);
     CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
     CFRelease(path);

     CTFrameDraw(ctFrame, context);

     NSArray *lines = (NSArray *)CTFrameGetLines(ctFrame);
     NSUInteger lineCount = [lines count];
     CGPoint lineOrigins[lineCount];
     CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);

     for (int i = 0 ; i < lineCount; i++) {
         CTLineRef line = (__bridge CTLineRef)lines[i];

         NSArray *runObjArray = (NSArray *)CTLineGetGlyphRuns(line);

         for (id runObj in runObjArray) {
             CTRunRef run = (__bridge CTRunRef)runObj;
             NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);

             CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];

             if (delegate == nil) {
                 continue;
             }

             NSDictionary *metaDic = CTRunDelegateGetRefCon(delegate);

             if (![metaDic isKindOfClass:[NSDictionary class]]) {
                 continue;
             }
             // 获取占位符的frame，将占位符替换为图片
             CGRect runBounds;
             CGFloat ascent;
             CGFloat descent;

             runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
             runBounds.size.height = ascent + descent;


             CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
             runBounds.origin.x = lineOrigins[i].x + xOffset;
             runBounds.origin.y = lineOrigins[i].y;
             runBounds.origin.y -= descent;

             CGPathRef pathRef = CTFrameGetPath(ctFrame);
             CGRect colRect = CGPathGetBoundingBox(pathRef);

             CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
             CGContextDrawImage(context, delegateBounds, [UIImage imageNamed:@"aiqing"].CGImage);
         }
     }
}

#pragma mark - CTRunDelegateRef

+ (CTRunDelegateRef) textLayoutRunWithAttachment {

    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateCurrentVersion;
    callbacks.dealloc = ly_embeddedObjectDeallocCallback;
    callbacks.getAscent = ly_embeddedObjectGetAscentCallback;
    callbacks.getDescent = ly_embeddedObjectGetDescentCallback;
    callbacks.getWidth = ly_embeddedObjectGetWidthCallback;

    return CTRunDelegateCreate(&callbacks, (__bridge void *)@{});
}




void ly_embeddedObjectDeallocCallback(void* context)
{
    CFBridgingRelease(context);
}

CGFloat ly_embeddedObjectGetAscentCallback(void* context)
{


    return 160;
}

CGFloat ly_embeddedObjectGetDescentCallback(void* context)
{

    return 0;
}

CGFloat ly_embeddedObjectGetWidthCallback(void* context)
{

    return 120;
}

@end
