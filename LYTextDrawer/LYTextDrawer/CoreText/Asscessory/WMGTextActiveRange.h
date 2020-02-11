//
//  WMGTextActiveRange.h
//  LYTextDrawer
//
//  Created by 李玉臣 on 2020/2/9.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMGActiveRange.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMGTextActiveRange : NSObject<WMGActiveRange>

/**
 * 创建一个激活区，框架内部使用
 *
 * @param range 激活区对应的range
 * @param type 激活区类型
 * @param text 如果是非WMGActiveRangeTypeAttachment类型的指定才有意义
 *
 * @return 激活区
 */
+ (instancetype)activeRange:(NSRange)range type:(WMGActiveRangeType)type text:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
