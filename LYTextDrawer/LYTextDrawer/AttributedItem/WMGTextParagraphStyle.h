//
//  WMGTextParagraphStyle.h
//  LYTextDrawer
//
//  Created by 李玉臣 on 2020/2/8.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@class WMGTextParagraphStyle;

@protocol WMGTextParagraphStyleDelegate <NSObject>
- (void)paragraphStyleDidUpdated:(WMGTextParagraphStyle *)style;
@end

NS_ASSUME_NONNULL_BEGIN
/*
 段落风格设置类，该类是对系统CTParagraphStyle各个属性相关设置的封装
 */
@interface WMGTextParagraphStyle : NSObject

/**
 * 获取默认段落风格，每次调用都会创建一个实例返回。
 *
 * @return WMGTextParagraphStyle
 */
+ (instancetype)defaultParagraphStyle;

// 段落风格代理
@property (nonatomic, weak, nullable) id<WMGTextParagraphStyleDelegate> delegate;

// 获取默认段落风格，每次调用都会创建一个实例返回。
@property (nonatomic, assign) BOOL allowsDynamicLineSpacing;

// 行间距，默认值5
@property (nonatomic, assign) CGFloat lineSpacing;

// 最大行高
@property (nonatomic, assign) CGFloat maximumLineHeight;

// 换行模式，默认NSLineBreakByWordWrapping
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;

// 对齐风格，默认NSTextAlignmentLeft
@property (nonatomic, assign) NSTextAlignment alignment;

// 段落首行头部缩进
@property (nonatomic, assign) CGFloat firstLineHeadIndent;

// 段落前间距
@property (nonatomic, assign) CGFloat paragraphSpacingBefore;

// 段落后间距
@property (nonatomic, assign) CGFloat paragraphSpacingAfter;

/**
 * 根据指定字号获取NS类型的段落对象
 * @param fontSize 字号大小
 *
 * @return NSParagraphStyle
 */
- (NSParagraphStyle *)nsParagraphStyleWithFontSize:(NSInteger)fontSize;

/**
 * 根据指定字号获取CT类型的段落对象
 * @param fontSize 字号大小
 *
 * @return CTParagraphStyleRef
 */

- (CTParagraphStyleRef)ctParagraphStyleWithFontSize:(NSInteger)fontSize;

@end

NS_ASSUME_NONNULL_END

