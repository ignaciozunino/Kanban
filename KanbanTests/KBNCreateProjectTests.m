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
#import <OCMock/OCMock.h>
#import "KBNConstants.h"


@interface KBNCreateProjectTests : XCTestCase

@end

@implementation KBNCreateProjectTests

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


-(void) testCreateProjectWithoutName{
    KBNProjectService * serviceOrig = [[KBNProjectService alloc]init];
    id projectAPIManager = [OCMockObject mockForClass:[KBNProjectParseAPIManager class]];
    serviceOrig.dataService = projectAPIManager;
    [serviceOrig createProject:@"" withDescription:OCMOCK_ANY
               completionBlock:^(NSError *error)
     {
         XCTAssertFalse(true);
     }
                    errorBlock:^(NSError *error)
     {
         NSString *errorMessage = [[error userInfo] objectForKey:@"NSLocalizedDescriptionKey"];
         XCTAssertEqualObjects(errorMessage, CREATING_PROJECT_WITHOUTNAME_ERROR);
    }];
    [[projectAPIManager reject] createProject:OCMOCK_ANY completionBlock:OCMOCK_ANY errorBlock:OCMOCK_ANY];
}

-(void) testCreateProjectOK{
    KBNProjectService * serviceOrig = [KBNProjectService sharedInstance];
    id projectAPIManager = [OCMockObject mockForClass:[KBNProjectParseAPIManager class]];
    [[projectAPIManager stub] createProject:OCMOCK_ANY completionBlock:OCMOCK_ANY errorBlock:OCMOCK_ANY];
    serviceOrig.dataService = projectAPIManager;
    [serviceOrig createProject:@"test" withDescription:@"desc"
               completionBlock:^(NSError *error)
     {
         XCTAssertTrue(true); 
     }
                    errorBlock:^(NSError *error)
     {
         XCTAssertTrue(false);
     }];

    [projectAPIManager verify];
}

@end
