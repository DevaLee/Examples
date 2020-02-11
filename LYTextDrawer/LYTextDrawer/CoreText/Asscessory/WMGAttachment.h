//
//  LYAttachment.h
//  LYTextDraw
//
//  Created by 李玉臣 on 2020/2/8.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "WMGFontMetrics.h"

typedef NS_ENUM(NSInteger, WMGAttachmentType)
{
    WMGAttachmentTypeText         = 0,
    WMGAttachmentTypeStaticImage  = 1,
    WMGAttachmentTypePlaceholder  = 2,

    WMGAttachmentTypeApplicationReserved = 0xF000,
};

@protocol WMGAttachment <NSObject>

// 定义组件类型，一般文本中插入的图片被标记为WMGAttachmentTypeStaticImage
@property (nonatomic) WMGAttachmentType type;

// 指定组件以size大小展示
@property (nonatomic) CGSize size;

// 组件和四周的edgeInsets
@property (nonatomic) UIEdgeInsets edgeInsets;

// 组件展示相关的数据 一般为 NSString*、UIImage、WMGImage
// 分别对应图片名称（或者是一组文本）、本地图片、网络下载图片
@property (nonatomic, strong, nullable) id contents;

@optional
// 指定组件在AttributedString中的位置和长度，对于图片组件而言，由于是用\ufffc表达，所以长度为1。
@property (nonatomic, assign) NSUInteger position;
@property (nonatomic, assign) NSUInteger length;

@required
// 组件的fontMetrics，系统判定一个系统组件的占位通过一下属性、方法实现
@property (nonatomic) WMGFontMetrics baselineFontMetrics;
- (CGSize)placeholderSize;

@end





