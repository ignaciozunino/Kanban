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

//Feature tested: Create Project
//Description: In this test we will verify that you cant create a project without a name
-(void) testCreateProjectWithoutName{
    KBNProjectService * serviceOrig = [[KBNProjectService alloc]init];
    id projectAPIManager = [OCMockObject mockForClass:[KBNProjectParseAPIManager class]];
    serviceOrig.dataService = projectAPIManager;
    [serviceOrig createProject:@"" withDescription:OCMOCK_ANY
               completionBlock:^{
         XCTAssertFalse(true);
     }
                    errorBlock:^(NSError *error)
     {
         NSString *errorMessage = [[error userInfo] objectForKey:@"NSLocalizedDescriptionKey"];
         XCTAssertEqualObjects(errorMessage, CREATING_PROJECT_WITHOUTNAME_ERROR);
     }];
    [[projectAPIManager reject] createProject:OCMOCK_ANY completionBlock:OCMOCK_ANY errorBlock:OCMOCK_ANY];
}

//Feature tested: Create Project
//Description: In this test we will verify that you create a project with name and description and everything is OK
-(void) testCreateProjectOK{
    KBNProjectService * serviceOrig = [KBNProjectService sharedInstance];
    id projectAPIManager = [OCMockObject mockForClass:[KBNProjectParseAPIManager class]];
    [[projectAPIManager stub] createProject:OCMOCK_ANY completionBlock:OCMOCK_ANY errorBlock:OCMOCK_ANY];
    serviceOrig.dataService = projectAPIManager;
    [serviceOrig createProject:@"test" withDescription:@"desc"
               completionBlock:^{
         XCTAssertTrue(true);
     }
                    errorBlock:^(NSError *error)
     {
         XCTAssertTrue(false);
     }];
    
    [projectAPIManager verify];
}

//Feature tested: Create Project
//Description: In this test we will verify that in case you create a project offline
//the project is't created correctly
-(void)testOfflineCreateProject
{
    KBNProjectService * serviceOrig = [KBNProjectService sharedInstance];
    id projectAPIManager = [OCMockObject mockForClass:[KBNProjectParseAPIManager class]];
    
    //This is to redefine the createProject method from the ParseAPIManager class
    OCMStub([projectAPIManager createProject:OCMOCK_ANY
                             completionBlock:OCMOCK_ANY
                                  errorBlock:OCMOCK_ANY]).
    andDo(^(NSInvocation *invocation)
          {
              //Block definition
              void(^stubBlock)(NSError *error);
              
              //Get the instance from the error block (position 4)
              [invocation getArgument:&stubBlock atIndex:4];
              
              //Error creation
              NSString *domain = ERROR_DOMAIN;
              NSDictionary * info = @{@"NSLocalizedDescriptionKey": CREATING_PROJECT_OFFLINE_ERROR};
              NSError *errorConnection = [NSError errorWithDomain:domain code:-102 userInfo:info];
              
              //Call the block with the error created
              stubBlock(errorConnection);
              
          });
    XCTestExpectation *expectation = [self expectationWithDescription:@"..."];
    serviceOrig.dataService = projectAPIManager;
    [serviceOrig createProject:@"test" withDescription:@"desc"
               completionBlock:^ {
         XCTAssertTrue(false);
         [expectation fulfill];
     }
                    errorBlock:^(NSError *error)
     {
         if (error) {
             NSString *errorMessage = [[error userInfo] objectForKey:@"NSLocalizedDescriptionKey"];
             XCTAssertEqualObjects(errorMessage, CREATING_PROJECT_OFFLINE_ERROR);
             [expectation fulfill];
         }
     }];
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
}

@end