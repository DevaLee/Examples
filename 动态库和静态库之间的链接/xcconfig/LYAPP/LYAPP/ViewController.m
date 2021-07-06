//
//  ViewController.m
//  LYAPP
//
//  Created by bel on 2021/7/5.
//  Copyright © 2021 bel. All rights reserved.
//

#import "ViewController.h"
#import <SYTimer.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SYTimer *timer = [[SYTimer alloc] init];
    
    NSLog(@"%@",timer);
}

@end
