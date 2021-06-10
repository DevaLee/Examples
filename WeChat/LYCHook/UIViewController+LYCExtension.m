//
//  UIViewController+LYCExtension.m
//  LYCHook
//
//  Created by bel on 2021/6/10.
//

#import "UIViewController+LYCExtension.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation UIViewController (LYCExtension)

+(void)load {
    NSLog(@"\n\n\n\n\n\n注入成功\n\n\n\n\n\n");
    
   Method oldFirstViewLoginMethod =  class_getInstanceMethod(objc_getClass("WCAccountLoginControlLogic"), @selector(onFirstViewLogin));
    
    Method newFirstViewLoginMethod = class_getInstanceMethod(self, @selector(new_firstViewLogin));
    
    class_addMethod(objc_getClass("WCAccountLoginControlLogic"), @selector(new_firstViewLogin),     class_getMethodImplementation(objc_getClass("WCAccountLoginControlLogic"), @selector(onFirstViewLogin)), method_getTypeEncoding(oldFirstViewLoginMethod));
    
    method_exchangeImplementations(oldFirstViewLoginMethod, newFirstViewLoginMethod);
    
    
}


-(void) new_firstViewLogin{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"" message:@"点击了登录" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *oneAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ac dismissViewControllerAnimated:YES completion:^{
            [self new_firstViewLogin];
        }];
    }];
    
    [ac addAction:oneAction];
    
 
    [[UIViewController findCurrentShowingViewController] presentViewController:ac animated:true completion:nil];
}


+ (UIViewController *)findCurrentShowingViewController {
    //获得当前活动窗口的根视图
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentShowingVC = [self findCurrentShowingViewControllerFrom:vc];
    return currentShowingVC;
}

//注意考虑几种特殊情况：①A present B, B present C，参数vc为A时候的情况
/* 完整的描述请参见文件头部 */
+ (UIViewController *)findCurrentShowingViewControllerFrom:(UIViewController *)vc
{
    //方法1：递归方法 Recursive method
    UIViewController *currentShowingVC;
    if ([vc presentedViewController]) { //注要优先判断vc是否有弹出其他视图，如有则当前显示的视图肯定是在那上面
        // 当前视图是被presented出来的
        UIViewController *nextRootVC = [vc presentedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        UIViewController *nextRootVC = [(UITabBarController *)vc selectedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else if ([vc isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        UIViewController *nextRootVC = [(UINavigationController *)vc visibleViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else {
        // 根视图为非导航类
        currentShowingVC = vc;
    }
    
    return currentShowingVC;
    
}
@end
