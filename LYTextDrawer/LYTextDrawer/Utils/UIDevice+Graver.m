//
//  UIDevice+Graver.m
//  LYTextDrawer
//
//  Created by 李玉臣 on 2020/2/8.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//

#import "UIDevice+Graver.h"

@implementation UIDevice (Graver)

- (WMGScreenType)screenType
{
    static WMGScreenType screenType = WMGScreenTypeUndefined;
    if (screenType == WMGScreenTypeUndefined)
    {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        int height = MAX(screenBounds.size.width, screenBounds.size.height);
        int width = MIN(screenBounds.size.width, screenBounds.size.height);

        int scale = [[UIScreen mainScreen] scale];

        if (height == 480 && width == 320)
        {
            if (scale == 1) {
                screenType = WMGScreenTypeClassic;
            } else if (scale == 2){
                screenType = WMGScreenTypeRetina;
            }
        }
        else if (height == 568 && width == 320)
        {
            screenType = WMGScreenTypeRetina4Inch;
        }
        else if (height == 667 && width == 375)
        {
            screenType = WMGScreenTypeIphone6;
        }
        else if (height == 736 && width == 414)
        {
            screenType = WMGScreenTypeIphone6Plus;
        }
        else if (height == 1024 && width == 768)
        {
            if (scale == 1){
                screenType = WMGScreenTypeIpadClassic;
            } else if (scale == 2) {
                screenType = WMGScreenTypeIpadRetina;
            }
        }
        else if (height == 1112 && width == 834)
        {
            screenType = WMGScreenTypeIpadPro;
        }
        else if (height == 1366 && width == 1024)
        {
            screenType = WMGScreenTypeIpadPro;
        }
        else if (height == 812 && width == 375)
        {
            screenType = WMGScreenTypeIphoneX;
        }else if (height == 896 && width == 414)
        {
            screenType = WMGScreenTypeIphoneXR;
        }
    }
    return screenType;
}

- (BOOL)wmg_isIPhone6
{
    return [self screenType] == WMGScreenTypeIphone6;
}

- (BOOL)wmg_isIPhone6Plus
{
    return [self screenType] == WMGScreenTypeIphone6Plus;
}

- (BOOL)wmg_isRetina4Inch
{
    return [self screenType] == WMGScreenTypeRetina4Inch;
}

- (BOOL)wmg_isIPhoneX
{
    return [self screenType] == WMGScreenTypeIphoneX;
}

- (BOOL)wmg_isIPhoneXR
{
    return [self screenType] == WMGScreenTypeIphoneXR;
}
@end

