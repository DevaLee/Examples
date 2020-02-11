//
//  UIDevice+Graver.h
//  LYTextDrawer
//
//  Created by 李玉臣 on 2020/2/8.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WMGScreenType)
{
    WMGScreenTypeUndefined   = 0,
    WMGScreenTypeIpadClassic = 1,//iPad 1,2,mini
    WMGScreenTypeIpadRetina  = 2,//iPad 3以上,mini2以上
    WMGScreenTypeIpadPro     = 3,//iPad Pro
    WMGScreenTypeClassic     = 4,//3gs及以下
    WMGScreenTypeRetina      = 5,//4&4s
    WMGScreenTypeRetina4Inch = 6,//5&5s&5c
    WMGScreenTypeIphone6     = 7,//6或者6+放大模式
    WMGScreenTypeIphone6Plus = 8,//6+
    WMGScreenTypeIphoneX     = 9,//iphone X
    WMGScreenTypeIphoneXR    = 10,//iphone XR
};

@interface UIDevice (Graver)
/**
 * 判断当前屏幕是否为4英寸Retina屏
 *
 * @return BOOL类型YES or NO.
 */
- (BOOL)wmg_isRetina4Inch;

/**
 * 判断当前屏幕是否为iphone6尺寸屏
 *
 * @return BOOL类型YES or NO.
 */
- (BOOL)wmg_isIPhone6;

/**
 * 判断当前屏幕是否为iphone6Plus尺寸屏
 *
 * @return BOOL类型YES or NO.
 */
- (BOOL)wmg_isIPhone6Plus;

/**
 * 判断当前屏幕是否为 iphoneX 尺寸屏
 *
 * @return BOOL类型YES or NO.
 */
- (BOOL)wmg_isIPhoneX;

/**
 * 判断当前屏幕是否为 iphoneXR 尺寸屏
 *
 * @return BOOL类型YES or NO.
 */
- (BOOL)wmg_isIPhoneXR;
@end

