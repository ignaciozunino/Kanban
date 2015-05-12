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
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
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
    
    __block NSArray* retrievedTasks;
    
    // Create the tasks and retrieve tasks of the test project
    // NOTE: mock tasks will have fictious taskIds that should be replaced by those returned by createTasks
    NSArray *tasks = [KBNTaskUtils mockTasksForProject:project taskList:backlog quantity:4];
    
    KBNTask *task0 = tasks[0];
    KBNTask *task1 = tasks[1];
    KBNTask *task2 = tasks[2];
    KBNTask *task3 = tasks[3];
    
    [service createTasks:tasks
         completionBlock:^(NSDictionary *records) {
             [service getTasksForProject:project.projectId completionBlock:^(NSDictionary *records) {
                 retrievedTasks = [records objectForKey:@"results"];
                 if (!retrievedTasks.count) { // We brought no records => error creating the tasks
                     XCTAssertTrue(false);
                 } else {
                     //update ids in tasks. NOTE: Tasks are retrieved ordered by task order.
                     NSUInteger i = 0;
                     for (NSDictionary *dict in retrievedTasks) {
                         KBNTask *task = tasks[i];
                          task.taskId = [dict objectForKey:PARSE_OBJECTID];
                         i++;
                     }
                 }
                 [tasksCreatedExpectation fulfill];
                 
             } errorBlock:^(NSError *error) {
                 XCTAssertTrue(false);
                 [tasksCreatedExpectation fulfill];
             }];
             
         } errorBlock:^(NSError *error) {
             XCTAssertTrue(false);
             [tasksCreatedExpectation fulfill];
         }];
    
    [self waitForExpectationsWithTimeout:TIMEOUT handler:^(NSError *error) {
    }];

    
    

    // 2. Move task 1 to requirements and verify that it was moved and has order 0 in requirements list.
    //    Verify that task 2 and 3's orders were changed to 1 and 2 respectively and task 0's order remains unchanged.
  
    XCTestExpectation *taskMovedExpectation = [self expectationWithDescription:TASK_MOVED_EXPECTATION];
    
    [service moveTask:task1 toList:requirements inOrder:nil completionBlock:^{
        [service getTasksForProject:project.projectId completionBlock:^(NSDictionary *records) {
            retrievedTasks = [records objectForKey:@"results"];
            
            for (NSDictionary *dict in retrievedTasks) {

                NSString *name = [dict objectForKey:PARSE_TASK_NAME_COLUMN];
                NSString *taskListId = [dict objectForKey:PARSE_TASK_TASK_LIST_COLUMN];
                NSNumber *order = [dict objectForKey:PARSE_TASK_ORDER_COLUMN];
                
                if ([name isEqualToString:task0.name]) {
                    if (!([taskListId isEqualToString:backlog.taskListId] && [order integerValue] == 0)) {
                        XCTAssertTrue(false);
                    }
                } else if ([name isEqualToString:task1.name]) {
                    if (!([taskListId isEqualToString:requirements.taskListId] && [order integerValue] == 0)) {
                        XCTAssertTrue(false);
                    }
                } else if ([name isEqualToString:task2.name]) {
                    if (!([taskListId isEqualToString:backlog.taskListId] && [order integerValue] == 1)) {
                        XCTAssertTrue(false);
                    }
                } else if ([name isEqualToString:task3.name]) {
                    if (!([taskListId isEqualToString:backlog.taskListId] && [order integerValue] == 2)) {
                        XCTAssertTrue(false);
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

    [service moveTask:task1 toList:backlog inOrder:nil completionBlock:^{
        [service getTasksForProject:project.projectId completionBlock:^(NSDictionary *records) {
            retrievedTasks = [records objectForKey:@"results"];
            
            for (NSDictionary *dict in retrievedTasks) {
                
                NSString *name = [dict objectForKey:PARSE_TASK_NAME_COLUMN];
                NSString *taskListId = [dict objectForKey:PARSE_TASK_TASK_LIST_COLUMN];
                NSNumber *order = [dict objectForKey:PARSE_TASK_ORDER_COLUMN];
                
                if ([name isEqualToString:task0.name]) {
                    if (!([taskListId isEqualToString:backlog.taskListId] && [order integerValue] == 0)) {
                        XCTAssertTrue(false);
                    }
                } else if ([name isEqualToString:task1.name]) {
                    if (!([taskListId isEqualToString:backlog.taskListId] && [order integerValue] == 3)) {
                        XCTAssertTrue(false);
                    }
                } else if ([name isEqualToString:task2.name]) {
                    if (!([taskListId isEqualToString:backlog.taskListId] && [order integerValue] == 1)) {
                        XCTAssertTrue(false);
                    }
                } else if ([name isEqualToString:task3.name]) {
                    if (!([taskListId isEqualToString:backlog.taskListId] && [order integerValue] == 2)) {
                        XCTAssertTrue(false);
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
    
    [service moveTask:task1 toList:backlog inOrder:@1 completionBlock:^{
        [service getTasksForProject:project.projectId completionBlock:^(NSDictionary *records) {
            retrievedTasks = [records objectForKey:@"results"];
            
            for (NSDictionary *dict in retrievedTasks) {
                
                NSString *name = [dict objectForKey:PARSE_TASK_NAME_COLUMN];
                NSString *taskListId = [dict objectForKey:PARSE_TASK_TASK_LIST_COLUMN];
                NSNumber *order = [dict objectForKey:PARSE_TASK_ORDER_COLUMN];
                
                if ([name isEqualToString:task0.name]) {
                    if (!([taskListId isEqualToString:backlog.taskListId] && [order integerValue] == 0)) {
                        XCTAssertTrue(false);
                    }
                } else if ([name isEqualToString:task1.name]) {
                    if (!([taskListId isEqualToString:backlog.taskListId] && [order integerValue] == 1)) {
                        XCTAssertTrue(false);
                    }
                } else if ([name isEqualToString:task2.name]) {
                    if (!([taskListId isEqualToString:backlog.taskListId] && [order integerValue] == 2)) {
                        XCTAssertTrue(false);
                    }
                } else if ([name isEqualToString:task3.name]) {
                    if (!([taskListId isEqualToString:backlog.taskListId] && [order integerValue] == 3)) {
                        XCTAssertTrue(false);
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
