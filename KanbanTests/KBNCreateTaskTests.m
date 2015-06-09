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
#import "KBNProjectUtils.h"
#import "KBNTaskListUtils.h"
#import "KBNTaskUtils.h"

//Local constants
#define TASKS_CREATED_WITHOUT_NAME_EXPECTATION @"task created without name"
#define TASKS_CREATED_EXPECTATION @"task created ok"

#define TIMEOUT 40.0


@interface KBNCreateTaskTests : XCTestCase

@property (strong, nonatomic) KBNProject *project;
@property (strong, nonatomic) KBNTaskList *taskList;
@property (strong, nonatomic) KBNTaskService *service;

@end

@implementation KBNCreateTaskTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ddMMYYHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    self.project = [KBNProjectUtils projectWithParams:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"test_project_%@",dateString] forKey:PARSE_OBJECTID]];
    
    self.taskList = [KBNTaskListUtils taskListForProject:self.project params:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                              @"taskList", PARSE_OBJECTID,
                                                                              @"taskList", PARSE_TASKLIST_NAME_COLUMN,
                                                                              @0, PARSE_TASKLIST_ORDER_COLUMN, nil]];
    
    self.service = [[KBNTaskService alloc]init];
    self.service.dataService =[[KBNTaskParseAPIManager alloc]init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

//Feature tested: Create Task
//Description: In this test we will verify that you can't create a task without a name
-(void) testCreateTaskWithoutName{
    
    XCTestExpectation *taskCreatedWithoutNameExpectation = [self expectationWithDescription:TASKS_CREATED_WITHOUT_NAME_EXPECTATION];
    
    KBNTask *addTask = [[KBNTaskUtils mockTasksForProject:self.project taskList:self.taskList quantity:1] objectAtIndex:0];
    addTask.name = @"";
    
    [self.service createTask:addTask
                      inList:self.taskList
             completionBlock:^(NSDictionary* response){
                 
                 XCTAssertFalse(true);
                 
             }
                  errorBlock:^(NSError* error){
                      NSString *errorMessage = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
                      XCTAssertEqualObjects(errorMessage, CREATING_TASK_WITHOUT_NAME_ERROR);
                  }];
    
    [taskCreatedWithoutNameExpectation fulfill];
    
    [self waitForExpectationsWithTimeout:TIMEOUT handler:^(NSError *error) {
    }];
}

//Feature tested: Create Task
//Description: In this test we will verify that you create a task with name and description and everything is OK
-(void) testCreateTaskOK{
    
    XCTestExpectation *taskCreatedExpectation = [self expectationWithDescription:TASKS_CREATED_EXPECTATION];
    
    KBNTask *addTask = [[KBNTaskUtils mockTasksForProject:self.project taskList:self.taskList quantity:1] objectAtIndex:0];
    addTask.name = @"Test create task OK";
    
    [self.service createTask:addTask
                      inList:self.taskList
             completionBlock:^(NSDictionary* response){
                 XCTAssertTrue(true);
             }
                  errorBlock:^(NSError* error){
                      XCTAssertTrue(false);
                  }];
    
    [taskCreatedExpectation fulfill];
    
    [self waitForExpectationsWithTimeout:TIMEOUT handler:^(NSError *error) {
    }];
}

@end
