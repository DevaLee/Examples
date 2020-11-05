//
//  ViewController.m
//  GCD
//
//  Created by 李玉臣 on 2020/11/5.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self mainSyncTest];
//    [self test1];
//    [self test2];
    [self test3];
}

- (void)mainSyncTest{

    NSLog(@"0");
    // 等
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"1");
    });
    NSLog(@"2");
}

- (void)test1{
    dispatch_queue_t queue = dispatch_queue_create("LY", NULL);
    NSLog(@"1");
    // 异步函数
    dispatch_async(queue, ^{
        NSLog(@"2");
        // 同步
        dispatch_sync(queue, ^{
            NSLog(@"3");
        });
         NSLog(@"4");
    });
    NSLog(@"5");
}

- (void)test2 {
    dispatch_queue_t queue1 = dispatch_queue_create("LY", NULL); // 串行队列
    dispatch_queue_t queue2 = dispatch_queue_create("Nice", NULL); // 串行队列
       NSLog(@"1");
       // 异步函数
       dispatch_async(queue1, ^{
           NSLog(@"2");
           // 同步
           dispatch_sync(queue2, ^{
               NSLog(@"3");
           });
            NSLog(@"4");
       });
       NSLog(@"5");
}

-(void) test3 {
    dispatch_queue_t queue = dispatch_queue_create("LY", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"1");
    dispatch_async(queue, ^{
        NSLog(@"2");
        dispatch_sync(queue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}
@end
