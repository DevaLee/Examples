//
//  ViewController.m
//  FishHookDemo
//
//  Created by 李玉臣 on 2020/11/21.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//

#import "ViewController.h"
#import "fishhook.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    char * c = getenv("HOME");
     NSString *str = [NSString stringWithUTF8String:c];

     NSLog(@"%@",str);

    struct rebinding getEnvb; // 1
    getEnvb.name = "getenv"; //2
    getEnvb.replacement = my_getenv; //3
    getEnvb.replaced = (void *)&sys_getenv; //4


    struct rebinding rebs[1] = {getEnvb};
    rebind_symbols(rebs, 1); // 5

    char * cOne = getenv("HOME");
    NSString *strOne = [NSString stringWithUTF8String:cOne];

    NSLog(@"%@",strOne);

    char * cTwo = getenv("PATH");
    NSString *strTwo = [NSString stringWithUTF8String:cTwo];

    NSLog(@"%@",strTwo);


}

static char *(* sys_getenv)(const char * str);  // 6

char  *my_getenv(const char * str){  // 7


    if (strcmp(str, "HOME") == 0 ) {
        return  "YAY";
    }else {
        return sys_getenv(str);
    }

}

@end
