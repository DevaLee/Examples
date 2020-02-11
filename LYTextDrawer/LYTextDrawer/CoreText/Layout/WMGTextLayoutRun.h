//
//  LYTextLayoutRun.h
//  LYTextDraw
//
//  Created by 李玉臣 on 2020/2/8.
//  Copyright © 2020 LYfinacial.com. All rights reserved./Users/ritamashin/Desktop/liyuchen/LYTextDraw/LYTextDraw/LYAttachment
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@protocol WMGAttachment;

NS_ASSUME_NONNULL_BEGIN

@interface WMGTextLayoutRun : NSObject

/**
* 根据文本组件创建一个CTRunDelegateRef，即CoreText可以识别的一个占位
*
* @param att WMGAttachment
*
*/
+ (CTRunDelegateRef)textLayoutRunWithAttachment:(id <WMGAttachment>)att;

@end

NS_ASSUME_NONNULL_END
