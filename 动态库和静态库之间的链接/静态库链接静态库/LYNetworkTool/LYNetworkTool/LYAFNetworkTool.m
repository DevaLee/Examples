//
//  LYAFNetworkTool.m
//  LYNetworkTool
//
//  Created by bel on 2021/7/5.
//  Copyright © 2021 bel. All rights reserved.
//

#import "LYAFNetworkTool.h"
#import <AFNetworking.h>
#import "LYAppObject.h"


@implementation LYAFNetworkTool
+(instancetype)shared {
    NSLog(@"-----AFNetworkMangager----%@",[AFNetworkReachabilityManager manager]);
    
    LYAppObject *obj = [[LYAppObject alloc] init];
    [obj sayAppHello];
    NSLog(@"------ LYAppObject ------ %@", obj);
    
    return  [[LYAFNetworkTool alloc] init];
}
@end
