//
//  KBNCoreDataManagerTest.m
//  Kanban
//
//  Created by Miguel Becerril on 05/08/15.
//  Copyright © 2015 Globant. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KBNTaskService.h"
#import "KBNProjectUtils.h"

#define TASKS_CREATED_EXPECTATION @"tasks created"
#define TIMEOUT 40.0

@interface KBNCoreDataManagerTest : XCTestCase

@end

@implementation KBNCoreDataManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTaskForProject {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ddMMYYHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];

    XCTestExpectation *tasksCreatedExpectation = [self expectationWithDescription:TASKS_CREATED_EXPECTATION];
    KBNProject *project = [KBNProjectUtils projectWithParams:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"test_project_%@",dateString] forKey:PARSE_OBJECTID]];
    __block KBNTaskList* backlog = [KBNTaskListUtils taskListForProject:project params:[NSDictionary dictionaryWithObjectsAndKeys:@"backlog", PARSE_OBJECTID, @"backlog", PARSE_TASKLIST_NAME_COLUMN, @0,
                                                                                                                                  PARSE_TASKLIST_ORDER_COLUMN, nil]];

    KBNTaskService * service = [[KBNTaskService alloc]init];
    service.dataService =[[KBNTaskParseAPIManager alloc]init];

    // Create the tasks and retrieve tasks of the test project
    NSArray *tasks = [KBNTaskUtils mockTasksForProject:project taskList:backlog quantity:4];

    [service createTasks:tasks completionBlock:^(NSArray *records) {

        // We brought no records => error creating the tasks
        if (!records.count) {
            XCTFail(@"Task Service could not create any task");
        }

        XCTAssertEqual([records count], 4, @"There must be four tasks");

        for (KBNTask *task in records) {
            XCTAssertEqual([task.taskList.tasks count], 4, @"There must be four tasks");
        }

        [service getTasksForProject:project completionBlock:^(NSArray *retrievedTasks) {

            // We brought no records => error creating the tasks
            if (!retrievedTasks.count) {
                XCTFail(@"Task Service could not retrieve any task");
            }

            XCTAssertEqual([retrievedTasks count], 4, @"There must be four tasks");

            for (KBNTask *retrievedTask in retrievedTasks) {
                XCTAssertEqual([retrievedTask.taskList.tasks count], 4, @"There must be four tasks");
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
}

@end
