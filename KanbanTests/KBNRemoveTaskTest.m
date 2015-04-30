//
//  KBNRemoveTaskTest.m
//  Kanban
//
//  Created by Guillermo Apoj on 30/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//


#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "KBNTaskService.h"
@interface KBNRemoveTaskTest : XCTestCase

@end

@implementation KBNRemoveTaskTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

///test that we can logical remove tasks
///we create a task, we remove it and then we prove that is actually removed
- (void)testRemoveTask {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testRemoveTask ok"];
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"ddMMYYHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    
    //we put the date in the name so we always have diferent project,tasklist and service
    NSString * project = [NSString stringWithFormat:@"test_project_%@",dateString];
    NSString * tasklist = [NSString stringWithFormat:@"test_task_List%@",dateString];
    NSString * taskDesc = [NSString stringWithFormat:@"testing remove on:%@",dateString];
    NSString * taskName = [NSString stringWithFormat:@"Task%@",dateString];
    NSNumber * order = [NSNumber numberWithInt:51];
    
    //first we create a project to be sure we have at least one project to bring
    KBNTaskService * service = [[KBNTaskService alloc]init];
    service.dataService =[[KBNTaskParseAPIManager alloc]init];
    __block NSString* taskId;
    //first we creaTE THE TASK
    [service createTaskWithName:taskName taskDescription:taskDesc order:order projectId:project taskListId:tasklist completionBlock:^(NSDictionary *records) {
        //we bring the tasks to know the task id, sincethe project id is unique and fake we know that is the only task
        [service getTasksForProject:project completionBlock:^(NSDictionary *records) {
            NSArray* tasksforid=[records objectForKey:@"results"];
            if (tasksforid.count==0) {//we bring no recors error creating the task
                XCTAssertTrue(false);
                [expectation fulfill];

            }
            NSDictionary * taskdictforid = tasksforid[0];
           taskId = [taskdictforid objectForKey:PARSE_OBJECTID];
            //we actually remove the task
            [service removeTask:taskId onSuccess:^{
                //we verify that was removed
                [service getTasksForProject:project completionBlock:^(NSDictionary *records) {
                    if (tasksforid.count==0) {//we bring no recors error geting the task
                        XCTAssertTrue(false);
                        [expectation fulfill];
                        
                    }
                    NSArray* tasksforverif=[records objectForKey:@"results"];
                    NSDictionary * taskdictfoverif = tasksforverif[0];
                   
                    if (((NSNumber*)[taskdictfoverif objectForKey:PARSE_TASK_ACTIVE_COLUMN  ]).boolValue ) {
                        XCTAssertTrue(true);
                        [expectation fulfill];
                    } else {
                        XCTAssertTrue(false);
                        [expectation fulfill];
                    }
                } errorBlock:^(NSError *error) {
                    XCTAssertTrue(false);
                    [expectation fulfill];

                }];
            } failure:^(NSError *error) {
                XCTAssertTrue(false);
                [expectation fulfill];
            }];
            
        } errorBlock:^(NSError *error) {
            XCTAssertTrue(false);
            [expectation fulfill];
        }];
    } errorBlock:^(NSError *error) {
        XCTAssertTrue(false);
        [expectation fulfill];
    }];

    
    [self waitForExpectationsWithTimeout:1000.0 handler:^(NSError *error) {
    }];
}

@end
