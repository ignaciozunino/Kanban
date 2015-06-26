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
#import "KBNTaskUtils.h"
#import "KBNTaskListUtils.h"
#import "KBNProjectUtils.h"

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

- (NSManagedObjectContext*) managedObjectContext {
    return [[KBNCoreDataManager sharedInstance] managedObjectContext];
}

///test that we can logical remove tasks
///we create a task, we remove it and then we prove that is actually removed
- (void)testRemoveTask {
  
    XCTestExpectation *expectation = [self expectationWithDescription:@"settings for testRemoveTask "];
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"ddMMYYHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    
    //we put the date in the name so we always have different project, tasklist and service
    NSString * project = [NSString stringWithFormat:@"test_project_%@",dateString];
    NSString * tasklist = [NSString stringWithFormat:@"test_task_List%@",dateString];
    NSString * taskDesc = [NSString stringWithFormat:@"testing remove on:%@",dateString];
    NSString * taskName = [NSString stringWithFormat:@"Task%@",dateString];
    
    //*************************Preparation to the test ***************************
    //first we create a project to be sure we have at least one project to bring
    KBNProject* projectObj = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_PROJECT inManagedObjectContext:[self managedObjectContext]];
    projectObj.projectId = project;
    
    KBNTaskList* taskListObj = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TASK_LIST inManagedObjectContext:[self managedObjectContext]];
    taskListObj.taskListId = tasklist;
    taskListObj.name = @"";
    taskListObj.project = projectObj;

    KBNTaskService * service = [KBNTaskService sharedInstance];
    service.dataService =[[KBNTaskParseAPIManager alloc] init];
    
    // First we create the task
                                
    KBNTask* task = [KBNTaskUtils taskForProject:projectObj taskList:taskListObj params:nil];
    task.name = taskName;
    task.taskDescription = taskDesc;
    
    [service createTask:task inList:taskListObj completionBlock:^(KBNTask *task) {
        //we bring the tasks to know the task id, since the project id is unique and fake we know that is the only task
        [service getTasksForProject:projectObj completionBlock:^(NSArray *records) {
            if (!records.count) {//we bring no records error creating the task
                XCTFail(@"Task Service could not retrieve any task");
            }
            [expectation fulfill];
            
        } errorBlock:^(NSError *error) {
            XCTFail(@"Task Service could not retrieved the tasks");
            [expectation fulfill];
        }];
    } errorBlock:^(NSError *error) {
        XCTFail(@"Task Service could not create the task");
        [expectation fulfill];
    }];
    
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
    
    ////************************the test itself**********************************************
    XCTestExpectation *finalexpectation = [self expectationWithDescription:@"testRemoveTask completed"];
    
    // We actually remove the task
    [service removeTask:task completionBlock:^{
        [service getTasksForProject:projectObj completionBlock:^(NSArray *records) {
            if (records.count) {
                KBNTask *removedTask = [records firstObject];
                if (removedTask.isActive) {
                    XCTFail(@"The task to remove is still active");
                    [finalexpectation fulfill];
                } else {
                    [finalexpectation fulfill];
                }
            } else { // If the array is empty, the task was removed successfully
                [finalexpectation fulfill];
            }
        } errorBlock:^(NSError *error) {
            XCTFail(@"Task Service could not retrieved the tasks");
            [finalexpectation fulfill];
            
        }];
        
    } errorBlock:^(NSError *error) {
        XCTFail(@"Task Service could not remove the task");
        [finalexpectation fulfill];
        
    }];
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
}
@end
