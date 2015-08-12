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
#import "KBNUserUtils.h"
#import "KBNInitialSetupTest.h"
#import "KBNProjectTemplateUtils.h"
#import "KBNReachabilityUtils.h"

@interface KBNCreateProjectTests : XCTestCase

@end

@implementation KBNCreateProjectTests

+ (void)setUp {
    [[KBNInitialSetupTest new] testCreateUser];
}

+ (void)tearDown {
    [[KBNInitialSetupTest new] testRemoveUser];
}

//Feature tested: Create Project
//Description: In this test we will verify that you can't create a project without a name
-(void) testCreateProjectWithoutName{
    KBNProjectService * serviceOrig = [[KBNProjectService alloc]init];
    id projectAPIManager = [OCMockObject mockForClass:[KBNProjectParseAPIManager class]];
    serviceOrig.dataService = projectAPIManager;
    [serviceOrig createProject:@"" withDescription:OCMOCK_ANY withTemplate:OCMOCK_ANY completionBlock:^(KBNProject* aProject){
        XCTFail(@"Project was created with no name");
    }
                    errorBlock:^(NSError *error)
     {
         NSString *errorMessage = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
         XCTAssertEqualObjects(errorMessage, CREATING_PROJECT_WITHOUTNAME_ERROR);
     }];
    [[projectAPIManager reject] createProject:OCMOCK_ANY withLists:OCMOCK_ANY completionBlock:OCMOCK_ANY errorBlock:OCMOCK_ANY];
}

//Feature tested: Create Project
//Description: In this test we will verify that you create a project with name and description and everything is OK
-(void) testCreateProjectOK{
    KBNProjectService * serviceOrig = [KBNProjectService sharedInstance];
    id projectAPIManager = [OCMockObject mockForClass:[KBNProjectParseAPIManager class]];
    [[projectAPIManager stub] createProject:OCMOCK_ANY withLists:OCMOCK_ANY completionBlock:OCMOCK_ANY errorBlock:OCMOCK_ANY];
    serviceOrig.dataService = projectAPIManager;
    
    [serviceOrig createProject:@"test" withDescription:@"desc" withTemplate:[KBNProjectTemplateUtils defaultTemplate] completionBlock:^(KBNProject* aProject){
    }
                    errorBlock:^(NSError *error)
     {
         XCTFail(@"The project could not be created");
     }];
    
    [projectAPIManager verify];
}

//Feature tested: Create Project
//Description: In this test we will verify that in case you create a project offline
//the project isn't created correctly in Parse
-(void)testOfflineCreateProject
{
    KBNProjectService * serviceOrig = [KBNProjectService sharedInstance];
    id projectAPIManager = [OCMockObject mockForClass:[KBNProjectParseAPIManager class]];
    serviceOrig.dataService = projectAPIManager;

    id reachability = [OCMockObject mockForClass:[KBNReachabilityUtils class]];
    [[[reachability stub] andReturnValue:@NO] isOnline];

    XCTestExpectation *expectation = [self expectationWithDescription:@"testOfflineCreateProject"];

    [serviceOrig createProject:@"test" withDescription:@"desc" withTemplate:[KBNProjectTemplateUtils defaultTemplate] completionBlock:^(KBNProject* aProject){
        if (aProject.projectId) {
            XCTFail(@"Project was created on server");
        }
        [expectation fulfill];
    }
                    errorBlock:^(NSError *error){
         if (error) {
             NSString *errorMessage = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
             XCTAssertEqualObjects(errorMessage, CREATING_PROJECT_OFFLINE_ERROR);
             [expectation fulfill];
         }
     }];

    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
}

@end
