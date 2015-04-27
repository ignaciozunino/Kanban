//
//  KBNLoginTest.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KBNUserService.h"
#import <OCMock/OCMock.h>
#import "KBNConstants.h"

@interface KBNLoginTest : XCTestCase

@end

@implementation KBNLoginTest

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

- (void)testLogin {
    XCTestExpectation *expectation = [self expectationWithDescription:@"..."];
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"ddMMYYHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    
    //we put the date in the usernameso we always have diferent users
    NSString * user = [NSString stringWithFormat:@"user%@@test.com",dateString];
    
    [[KBNUserService sharedInstance]createUser:user withPasword:@"12345g" completionBlock:^{
         XCTAssertTrue(true);
        [expectation fulfill];
    } errorBlock:^(NSError *error) {
        XCTAssertTrue(false);
        [expectation fulfill];
    }];
    
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
}
@end
