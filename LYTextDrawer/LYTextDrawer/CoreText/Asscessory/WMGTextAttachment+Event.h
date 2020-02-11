//
//  WMGTextAttachment+Event.h
//  LYTextDrawer
//
//  Created by 李玉臣 on 2020/2/9.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//



#import "WMGTextAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMGTextAttachment()

// 文本组件触发事件的target
@property (nonatomic, weak, nullable) id target;

// 文本组件触发的事件回调
@property (nonatomic, assign) SEL selector;

// 文本组件是否响应事件，默认responseEvent = （target && selector && target respondSelector:selector）
@property (nonatomic, assign) BOOL responseEvent;

// 给 attachment 绑定的自定义信息
@property (nonatomic, strong) id userInfo;

// userInfo 绑定的优先级
@property (nonatomic, assign) NSInteger userInfoPriority;

// event 绑定的优先级
@property (nonatomic, assign) NSInteger eventPriority;

/**
 *  给一个文本组件添加事件
 *
 * @param target 事件执行者
 * @param action 事件行为
 * @param controlEvents 事件类型
 *
 */
- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

/**
 *  给一个文本组件添加点击回调
 *
 * @param callBack 点击事件执行回调
 *
 */
- (void)registerClickBlock:(void(^)(void))callBack;

/**
 *  处理事件，框架内部使用
 */
- (void)handleEvent:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
