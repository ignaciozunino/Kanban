//
//  KBNCreateTaskListTest.m
//  Kanban
//
//  Created by Marcelo Dessal on 5/23/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KBNTaskListService.h"
#import "KBNProjectService.h"
#import "KBNProjectTemplateUtils.h"
#import "KBNUserUtils.h"
#import "KBNInitialSetupTest.h"

#define PROJECT_CREATED_EXPECTATION @"project created"
#define GET_TASKLISTS_EXPECTATION @"get tasklists"
#define TASKLIST_CREATED_EXPECTATION @"tasklist created"
#define TASKLIST_ORDER_CHECKED_EXPECTATION @"tasklist order checked"

@interface KBNCreateTaskListTest : XCTestCase

@end

@implementation KBNCreateTaskListTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[KBNInitialSetupTest new] testCreateUser];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testCreateTaskList {
    
    // Setup for the test. Create a project
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ddMMYYHHmmssSSS"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    XCTestExpectation *projectCreatedExpectation = [self expectationWithDescription:PROJECT_CREATED_EXPECTATION];
    
    NSString *name = [NSString stringWithFormat:@"test_project_%@",dateString];
    NSString *projectDescription = @"Create task list test";
    
    __block KBNProject *testProject = [KBNProjectUtils projectWithParams:
                                       [NSDictionary dictionaryWithObjectsAndKeys:
                                        name, PARSE_PROJECT_NAME_COLUMN,
                                        projectDescription, PARSE_PROJECT_DESCRIPTION_COLUMN, nil]];
    
    KBNProjectService *projectService = [[KBNProjectService alloc] init];
    projectService.dataService =[[KBNProjectParseAPIManager alloc] init];
    
    [projectService createProject:testProject.name
                  withDescription:testProject.projectDescription
                     withTemplate:[KBNProjectTemplateUtils defaultTemplate]
                  completionBlock:^(KBNProject *project) {
                      testProject = project;
                      [projectCreatedExpectation fulfill];
                  } errorBlock:^(NSError *error) {
                      XCTFail(@"Project Service could not create the project");
                      [projectCreatedExpectation fulfill];
                  }];
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
    
    // Get the default taskLists for the created project
    
    XCTestExpectation *getTaskListsExpectation = [self expectationWithDescription:GET_TASKLISTS_EXPECTATION];
    
    KBNTaskListService *taskListService = [KBNTaskListService sharedInstance];
    taskListService.dataService = [[KBNTaskListParseAPIManager alloc] init];
    
    [taskListService getTaskListsForProject:testProject
                            completionBlock:^(NSArray *records) {
                                testProject.taskLists = [NSOrderedSet orderedSetWithArray:records];
                                [getTaskListsExpectation fulfill];
                            } errorBlock:^(NSError *error) {
                                XCTFail(@"TaskList Service could not get project´s tasklists");
                                [getTaskListsExpectation fulfill];
                            }];
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
    
    // Here comes the actual test.
    
    XCTestExpectation *taskListCreatedExpectation = [self expectationWithDescription:TASKLIST_CREATED_EXPECTATION];
    
    KBNTaskList *taskList = [KBNTaskListUtils taskListWithName:@"AfterBacklog"];
    
    [taskListService createTaskList:taskList
                         forProject:testProject
                            inOrder:@1
                    completionBlock:^(KBNTaskList *taskList) {
                        // Get task lists and check their orders to be correct
                        [taskListService getTaskListsForProject:testProject
                                                completionBlock:^(NSArray *records) {
                                                    for (KBNTaskList* retrievedTaskList in records) {
                                                        if ([retrievedTaskList.name isEqualToString: @"Backlog"] && [retrievedTaskList.order integerValue] != 0) {
                                                            XCTFail(@"Backlog order is not correct");
                                                        } else if ([retrievedTaskList.name isEqualToString: @"AfterBacklog"] && [retrievedTaskList.order integerValue] != 1) {
                                                            XCTFail(@"AfterBacklog order is not correct");
                                                        } else if ([retrievedTaskList.name isEqualToString: @"Requirements"] && [retrievedTaskList.order integerValue] != 2) {
                                                            XCTFail(@"Requirements order is not correct");
                                                        } else if ([retrievedTaskList.name isEqualToString: @"Implemented"] && [retrievedTaskList.order integerValue] != 3) {
                                                            XCTFail(@"Implemented order is not correct");
                                                        } else if ([retrievedTaskList.name isEqualToString: @"Tested"] && [retrievedTaskList.order integerValue] != 4) {
                                                            XCTFail(@"Tested order is not correct");
                                                        } else if ([retrievedTaskList.name isEqualToString: @"Production"] && [retrievedTaskList.order integerValue] != 5) {
                                                            XCTFail(@"Production order is not correct");
                                                        }
                                                    }
                                                    [taskListCreatedExpectation fulfill];
                                                } errorBlock:^(NSError *error) {
                                                    XCTFail(@"TaskList Service could not get project´s tasklists");
                                                    [taskListCreatedExpectation fulfill];
                                                }];
                        
                    } errorBlock:^(NSError *error) {
                        XCTFail(@"TaskList Service could not create the list");
                        [taskListCreatedExpectation fulfill];
                    }];
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
}

@end
