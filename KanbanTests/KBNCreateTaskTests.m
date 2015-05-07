//
//  KBNCreateTaskTests.m
//  Kanban
//
//  Created by Lucas on 4/28/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KBNTaskService.h"
#import <OCMock/OCMock.h>
#import "KBNConstants.h"


@interface KBNCreateTaskTests : XCTestCase

@end

@implementation KBNCreateTaskTests

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

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

//Feature tested: Create Task
//Description: In this test we will verify that you cant create a task without a name
-(void) testCreateTaskWithoutName{
    KBNTaskService * serviceOrig = [[KBNTaskService alloc]init];
    id taskAPIManager = [OCMockObject mockForClass:[KBNTaskParseAPIManager class]];
    serviceOrig.dataService = taskAPIManager;
    KBNTask* addTask = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TASK inManagedObjectContext:[self managedObjectContext]];
    addTask.name = @"";
    addTask.project = OCMOCK_ANY;
    addTask.taskList = OCMOCK_ANY;
    addTask.order = [NSNumber numberWithInt:0];
    [serviceOrig createTask:addTask inList:OCMOCK_ANY completionBlock:^(NSDictionary* response){
                        XCTAssertFalse(true);
    }
                         errorBlock:^(NSError* error){
                             NSString *errorMessage = [[error userInfo] objectForKey:@"NSLocalizedDescriptionKey"];
                             XCTAssertEqualObjects(errorMessage, CREATING_TASK_WITHOUT_NAME_ERROR);
                         }];
    
    [[taskAPIManager reject] createTaskWithName:OCMOCK_ANY taskDescription:OCMOCK_ANY order:OCMOCK_ANY projectId:OCMOCK_ANY taskListId:OCMOCK_ANY completionBlock:OCMOCK_ANY errorBlock:OCMOCK_ANY];
}

//Feature tested: Create Task
//Description: In this test we will verify that you create a task with name and description and everything is OK
-(void) testCreateTaskOK{
    KBNTaskService * serviceOrig = [KBNTaskService sharedInstance];
    id taskAPIManager = [OCMockObject mockForClass:[KBNTaskParseAPIManager class]];
    [[taskAPIManager stub] createTask:OCMOCK_ANY
                               inList:OCMOCK_ANY
                              completionBlock:OCMOCK_ANY
                                   errorBlock:OCMOCK_ANY];

    serviceOrig.dataService = taskAPIManager;
    serviceOrig.dataService = taskAPIManager;
    
    KBNTask* addTask = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TASK inManagedObjectContext:[self managedObjectContext]];
    addTask.name = @"Test create task OK";
    addTask.project = OCMOCK_ANY;
    addTask.taskList = OCMOCK_ANY;
    addTask.order = [NSNumber numberWithInt:0];
    
    [serviceOrig createTask:addTask inList:OCMOCK_ANY
                    completionBlock:^(NSDictionary* response){
                                        XCTAssertTrue(true);
                                    }
                         errorBlock:^(NSError* error){
                                        XCTAssertTrue(false);
                                    }];
    
    [taskAPIManager verify];
}




//Feature tested: Creation Timeout for CreateTask method
//Description: In this test we will verify that a task doesn't get created if the
//internet connection times out.
-(void)testTimeoutForCreateTask
{
    KBNTaskService * serviceOrig = [KBNTaskService sharedInstance];
    id taskAPIManager = [OCMockObject mockForClass:[KBNTaskParseAPIManager class]];
    
    //This is to redefine the createTask method from the ParseAPIManager class
    OCMStub([taskAPIManager createTask:OCMOCK_ANY
                                   inList:OCMOCK_ANY
                              completionBlock:OCMOCK_ANY
                                   errorBlock:OCMOCK_ANY]).
    andDo(^(NSInvocation *invocation){
        
        //Block definition
        void(^stubBlock)(NSError *error);
        
        //Get the instance from the error block (position 8)
        [invocation getArgument:&stubBlock atIndex:8];
        
        //Error creation
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": CREATING_TASK_OFFLINE_ERROR};
        NSError *errorConnection = [NSError errorWithDomain:domain code:-102 userInfo:info];
        
        //Call the block with the error created
        stubBlock(errorConnection);
    });
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"..."];
    serviceOrig.dataService = taskAPIManager;
    [serviceOrig createTask:OCMOCK_ANY
                         inList:OCMOCK_ANY
                    completionBlock:^(NSDictionary* response){
                        XCTAssertTrue(false);
                        [expectation fulfill];
                        }
                         errorBlock:^(NSError* error ){
                             if (error) {
                                 NSString *errorMessage = [[error userInfo] objectForKey:@"NSLocalizedDescriptionKey"];
                                 XCTAssertEqualObjects(errorMessage, CREATING_TASK_OFFLINE_ERROR);
                                 [expectation fulfill];
                                }
                         }
                        ];
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
}



@end
