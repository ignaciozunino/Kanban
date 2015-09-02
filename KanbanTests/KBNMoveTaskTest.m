//
//  KBNMoveTaskTest.m
//  Kanban
//
//  Created by Lucas on 4/30/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KBNProjectUtils.h"
#import "KBNTaskUtils.h"
#import "KBNTaskListUtils.h"
#import "KBNTaskService.h"

//Local constants
#define TASKS_CREATED_EXPECTATION @"tasks created"
#define TASK_MOVED_EXPECTATION @"task moved"
#define TASKS_REORDERED_EXPECTATION @"tasks reordered"
#define TASK_MOVED_BACK_EXPECTATION @"task moved back"
#define TASK_REORDER_EXPECTATION @"task reordered"

#define TIMEOUT 40.0

@interface KBNMoveTaskTest : XCTestCase

@end

@implementation KBNMoveTaskTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSManagedObjectContext*) managedObjectContext {
    return [[KBNCoreDataManager sharedInstance] managedObjectContext];
}

// Test description
// ----------------
// 1. Create 4 tasks, tasks 0, 1, 2 and 3 in backlog (orders 0, 1, 2 and 3 respectively).
//
// 2. Move task 1 to requirements and verify that it was moved and has order 0 in requirements list.
//    Verify that task 2 and 3's orders were changed to 1 and 2 respectively and task 0's order remains unchanged.
//
// 3. Move back task 1 to backlog. It should be put at the end of the list.
//    Verify that task 1 has order 3.
//
// 4. Move task 1 to order 1 within backlog.
//    Verify that all tasks have their original order.

- (void)testMoveTask {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ddMMYYHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    // 1. Create 4 tasks, tasks 0, 1, 2 and 3 in backlog (orders 0, 1, 2 and 3 respectively).
    
    XCTestExpectation *tasksCreatedExpectation = [self expectationWithDescription:TASKS_CREATED_EXPECTATION];
    
    KBNProject *project = [KBNProjectUtils projectWithParams:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"test_project_%@",dateString] forKey:PARSE_OBJECTID]];
    
    __block KBNTaskList* backlog = [KBNTaskListUtils taskListForProject:project params:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                        @"backlog", PARSE_OBJECTID,
                                                                                        @"backlog", PARSE_TASKLIST_NAME_COLUMN,
                                                                                        @0, PARSE_TASKLIST_ORDER_COLUMN, nil]];
    
    __block KBNTaskList* requirements = [KBNTaskListUtils taskListForProject:project params:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                        @"requirements", PARSE_OBJECTID,
                                                                                        @"requirements", PARSE_TASKLIST_NAME_COLUMN,
                                                                                        @1, PARSE_TASKLIST_ORDER_COLUMN, nil]];
    
    KBNTaskService * service = [[KBNTaskService alloc]init];
    service.dataService =[[KBNTaskParseAPIManager alloc]init];
    
    // Create the tasks and retrieve tasks of the test project
    NSArray *tasks = [KBNTaskUtils mockTasksForProject:project taskList:backlog quantity:4];

    [service createTasks:tasks completionBlock:^(NSArray *records) {
        [service getTasksForProject:project completionBlock:^(NSArray *retrievedTasks) {
            if (!retrievedTasks.count) { // We brought no records => error creating the tasks
                     XCTFail(@"Task Service could not retrieve any task");
                 }
                 [tasksCreatedExpectation fulfill];
                 
             } errorBlock:^(NSError *error) {
                 XCTFail(@"Task Service could not retrieve tasks");
                 [tasksCreatedExpectation fulfill];
             }];
             
         } errorBlock:^(NSError *error) {
             XCTFail(@"Task Service could not create the tasks");
             [tasksCreatedExpectation fulfill];
         }];
    
    [self waitForExpectationsWithTimeout:TIMEOUT handler:^(NSError *error) {
    }];

    
    

    // 2. Move task 1 to requirements and verify that it was moved and has order 0 in requirements list.
    //    Verify that task 2 and 3's orders were changed to 1 and 2 respectively and task 0's order remains unchanged.
  
    XCTestExpectation *taskMovedExpectation = [self expectationWithDescription:TASK_MOVED_EXPECTATION];
    
    [service moveTask:tasks[1] toList:requirements inOrder:@0 completionBlock:^{
        [service getTasksForProject:project completionBlock:^(NSArray *retrievedTasks) {
            
            for (KBNTask *task in retrievedTasks) {
                for (KBNTaskList *taskList in task.project.taskLists) {
                    if ([taskList.taskListId isEqualToString:@"requirements"]) {
                        for (KBNTask *taskMove in taskList.tasks) {
                            if ([taskMove.taskId isEqualToString:@"Task1"]) {
                                XCTAssertTrue([taskMove.order isEqual:@(0)], @"Order should be zero");
                            }
                        }
                    } else if ([taskList.taskListId isEqualToString:@"backlog"]) {
                        for (KBNTask *taskOriginal in taskList.tasks) {
                            if ([taskOriginal.taskId isEqualToString:@"Task0"]) {
                                XCTAssertTrue([taskOriginal.order isEqual:@(0)], @"Order should be zero");
                            } else if ([taskOriginal.taskId isEqualToString:@"Task2"]) {
                                XCTAssertTrue([taskOriginal.order isEqual:@(1)], @"Order should be one");
                            } else if ([taskOriginal.taskId isEqualToString:@"Task3"]) {
                                XCTAssertTrue([taskOriginal.order isEqual:@(2)], @"Order should be two");
                            }
                        }
                    }
                }
            }
            
            [taskMovedExpectation fulfill];
            
        } errorBlock:^(NSError *error) {
            XCTAssertTrue(false);
            [taskMovedExpectation fulfill];
        }];
    } errorBlock:^(NSError *error) {
        XCTAssertTrue(false);
        [taskMovedExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:TIMEOUT handler:^(NSError *error) {
    }];

    // 3. Move back task 1 to backlog. It should be put at the end of the list.
    //    Verify that task 1 has order 3.

    XCTestExpectation *taskMovedBackExpectation = [self expectationWithDescription:TASK_MOVED_BACK_EXPECTATION];

    [service moveTask:tasks[1] toList:backlog inOrder:@3 completionBlock:^{
        [service getTasksForProject:project completionBlock:^(NSArray *retrievedTasks) {
            for (KBNTask *task in retrievedTasks) {
                for (KBNTaskList *taskList in task.project.taskLists) {
                    if ([taskList.taskListId isEqualToString:@"backlog"]) {
                        for (KBNTask *taskOriginal in taskList.tasks) {
                            if ([taskOriginal.taskId isEqualToString:@"Task0"]) {
                                XCTAssertTrue([taskOriginal.order isEqual:@(0)], @"Order should be zero");
                            } else if ([taskOriginal.taskId isEqualToString:@"Task2"]) {
                                XCTAssertTrue([taskOriginal.order isEqual:@(1)], @"Order should be one");
                            } else if ([taskOriginal.taskId isEqualToString:@"Task3"]) {
                                XCTAssertTrue([taskOriginal.order isEqual:@(2)], @"Order should be two");
                            } else if ([taskOriginal.taskId isEqualToString:@"Task1"]) {
                                XCTAssertTrue([taskOriginal.order isEqual:@(3)], @"Order should be three");
                            }
                        }
                    }
                }
            }

            [taskMovedBackExpectation fulfill];

        } errorBlock:^(NSError *error) {
            XCTAssertTrue(false);
            [taskMovedBackExpectation fulfill];
        }];
    } errorBlock:^(NSError *error) {
        XCTAssertTrue(false);
        [taskMovedBackExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:TIMEOUT handler:^(NSError *error) {
    }];

    // 4. Move task 1 to order 1 within backlog.
    //    Verify that all tasks have their original order.

    XCTestExpectation *taskReorderExpectation = [self expectationWithDescription:TASK_REORDER_EXPECTATION];

    [service moveTask:tasks[1] toList:backlog inOrder:@1 completionBlock:^{
        [service getTasksForProject:project completionBlock:^(NSArray *retrievedTasks) {
            for (KBNTask *task in retrievedTasks) {
                for (KBNTaskList *taskList in task.project.taskLists) {
                    if ([taskList.taskListId isEqualToString:@"backlog"]) {
                        for (KBNTask *taskOriginal in taskList.tasks) {
                            if ([taskOriginal.taskId isEqualToString:@"Task0"]) {
                                XCTAssertTrue([taskOriginal.order isEqual:@(0)], @"Order should be zero");
                            } else if ([taskOriginal.taskId isEqualToString:@"Task1"]) {
                                XCTAssertTrue([taskOriginal.order isEqual:@(1)], @"Order should be one");
                            } else if ([taskOriginal.taskId isEqualToString:@"Task2"]) {
                                XCTAssertTrue([taskOriginal.order isEqual:@(2)], @"Order should be two");
                            } else if ([taskOriginal.taskId isEqualToString:@"Task3"]) {
                                XCTAssertTrue([taskOriginal.order isEqual:@(3)], @"Order should be three");
                            }
                        }
                    }
                }
            }

            [taskReorderExpectation fulfill];

        } errorBlock:^(NSError *error) {
            XCTAssertTrue(false);
            [taskReorderExpectation fulfill];
        }];
    } errorBlock:^(NSError *error) {
        XCTAssertTrue(false);
        [taskReorderExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:TIMEOUT handler:^(NSError *error) {
    }];
}

@end