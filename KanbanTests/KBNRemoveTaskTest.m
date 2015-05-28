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
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
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

    KBNTaskService * service = [[KBNTaskService alloc]init];
    service.dataService =[[KBNTaskParseAPIManager alloc]init];
    __block NSString* taskId;
    
    //first we create the task
    KBNTask* addTask = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TASK inManagedObjectContext:[self managedObjectContext]];
    addTask.name = taskName;
    addTask.taskDescription = taskDesc;

    [service createTask:addTask inList:taskListObj completionBlock:^(NSDictionary *records) {
        //we bring the tasks to know the task id, sincethe project id is unique and fake we know that is the only task
        [service getTasksForProject:project completionBlock:^(NSDictionary *records) {
            NSArray* tasksforid=[records objectForKey:@"results"];
            if (tasksforid.count==0) {//we bring no recors error creating the task
                XCTAssertTrue(false);
                
                
            }
            NSDictionary * taskdictforid = tasksforid[0];
            taskId = [taskdictforid objectForKey:PARSE_OBJECTID];
            [expectation fulfill];
            
        } errorBlock:^(NSError *error) {
            XCTAssertTrue(false);
            [expectation fulfill];
        }];
    } errorBlock:^(NSError *error) {
        XCTAssertTrue(false);
        [expectation fulfill];
    }];
    
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
    
    ////************************the test itself**********************************************
    XCTestExpectation *finalexpectation = [self expectationWithDescription:@"testRemoveTask completed"];
    
    // Create a task object to pass to the remove method
    KBNProject *testProject = projectObj;
    KBNTaskList *testTaskList = taskListObj;
    
    KBNTask *task = [KBNTaskUtils taskForProject:testProject
                                        taskList:testTaskList
                                          params:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  taskId, PARSE_OBJECTID,
                                                  taskName, PARSE_TASK_NAME_COLUMN,
                                                  taskDesc, PARSE_TASK_DESCRIPTION_COLUMN,
                                                  @0, PARSE_TASKLIST_ORDER_COLUMN,
                                                  [NSNumber numberWithBool:@YES], PARSE_TASK_ACTIVE_COLUMN, nil]];
    
    //we actually remove the task
    [service removeTask:task completionBlock:^{
        [service getTasksForProject:project completionBlock:^(NSDictionary *records) {
            if (records.count==0) {//we bring no recors error geting the task
                XCTAssertTrue(false);
                [finalexpectation fulfill];
                
            }
            NSArray* tasksforverif=[records objectForKey:@"results"];
            
            if (tasksforverif.count) {
                NSDictionary * taskdictfoverif = tasksforverif[0];
                
                if (!((NSNumber*)[taskdictfoverif objectForKey:PARSE_TASK_ACTIVE_COLUMN]).boolValue ) {
                    [finalexpectation fulfill];
                } else {
                    XCTAssertTrue(false);
                    [finalexpectation fulfill];
                }
            } else { // If the array is empty, the task was removed successfully
                [finalexpectation fulfill];
            }
        } errorBlock:^(NSError *error) {
            XCTAssertTrue(false);
            [finalexpectation fulfill];
            
        }];
        
    } errorBlock:^(NSError *error) {
        XCTAssertTrue(false);
        [finalexpectation fulfill];
        
    }];
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
}
@end
