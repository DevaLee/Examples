//
//  ViewController.m
//  LYTextDrawer
//
//  Created by 李玉臣 on 2020/2/8.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//

#import "ViewController.h"
#import "NSMutableAttributedString+GTextProperty.h"

#import "ExampleView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    ExampleView *exampleView = [[ExampleView alloc] initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, 500)];
    exampleView.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.1];
    [self.view addSubview:exampleView];

}




@end
