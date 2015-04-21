//
//  KanbanTests.m
//  KanbanTests
//
//  Created by Nicolas Alejandro Porpiglia on 4/15/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KBNProjectService.h"

@interface KanbanTests : XCTestCase

@end

@implementation KanbanTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
- (void)testCreateProject {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm"];
    
    NSDate *now = [[NSDate alloc] init];
   
    NSString *dateString = [format stringFromDate:now];
    
    NSString * projectName = [NSString stringWithFormat:@"test created %@",dateString];
    [[KBNProjectService sharedInstance]createProject:projectName withDescription:@"project createdby automatic tests" completionBlock:^{
        XCTAssert(YES, @"Pass");
    } errorBlock:^(NSError *error) {
        NSString *message = [NSString stringWithFormat:@"ERROR Creating project : %@", [error localizedDescription] ];
        XCTFail(@"%@",message);
    }];
}
@end
