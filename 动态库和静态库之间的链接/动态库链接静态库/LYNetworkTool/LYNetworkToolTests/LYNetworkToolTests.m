//
//  LYNetworkToolTests.m
//  LYNetworkToolTests
//
//  Created by bel on 2021/7/5.
//  Copyright © 2021 bel. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LYAFNetworkTool.h"

@interface LYNetworkToolTests : XCTestCase

@end

@implementation LYNetworkToolTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    NSLog(@"---- shared ------ %@", [LYAFNetworkTool shared]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
