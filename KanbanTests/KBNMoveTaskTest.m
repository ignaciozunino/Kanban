//
//  KBNMoveTaskTest.m
//  Kanban
//
//  Created by Lucas on 4/30/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KBNProjectDetailViewController.h"
#import "KBNProjectService.h"
#import "KBNTaskService.h"
#import "KBNTaskUtils.h"
#import "KBNTaskListService.h"
#import "KBNTaskListUtils.h"
#import "KBNUserUtils.h"

//Local constants
#define TEST_PROJECT_ID @"Z1OblTylc6"
#define TEST_TASKLIST_ID_BACKLOG @"q3fpXmrJuZ"
#define TEST_TASKLIST_ID_REQUIREMENTS @"aoDh6esO15"
#define PROJECTS_RETRIEVED_EXPECTATION @"projects retrieved"
#define TASKS_RETRIEVED_EXPECTATION @"tasks retrieved"
#define TASKLISTS_RETRIEVED_EXPECTATION @"task lists retrieved"
#define TASK_MOVED_EXPECTATION @"task moved"
#define TASK_MOVED_BACK_EXPECTATION @"task moved back"

@interface KBNMoveTaskTest : XCTestCase

@property (nonatomic,strong) NSMutableArray* tasks;
@property (nonatomic,strong) NSArray* projects;
@property (nonatomic,strong) KBNProject* testProject;
@property (nonatomic,strong) NSArray *projectLists;
@end

@implementation KBNMoveTaskTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self retrieveProjects];
    [self retrieveTaskLists];
    [self retrieveTasks];
    
}

- (void) retrieveProjects{
    XCTestExpectation *projectsRetrievedExpectation = [self expectationWithDescription:PROJECTS_RETRIEVED_EXPECTATION];
    __weak typeof(self) weakself = self;
    
    [[KBNProjectService sharedInstance] getProjectsForUser:[KBNUserUtils getUsername]
                                            onSuccessBlock:^(NSArray *records) {
                                                weakself.projects = records;
                                                XCTAssertTrue(true);
                                                
                                                //Look for the specific project used for this test
                                                for (KBNProject* project in weakself.projects) {
                                                    if ([project.projectId isEqualToString:TEST_PROJECT_ID])
                                                    {
                                                        self.testProject = project;
                                                        break;
                                                    }
                                                }
                                                [projectsRetrievedExpectation fulfill];
                                            }
                                                errorBlock:^(NSError *error) {
                                                    XCTAssertTrue(false);
                                                }];
    
    // The test will pause here, running the run loop, until the timeout is hit
    // or all expectations are fulfilled.
    [self waitForExpectationsWithTimeout:40 handler:^(NSError *error) {
        if (error){
            XCTAssertTrue(false);
        }
        else{
            XCTAssertTrue(true);
        }
        
    }];
    
}


-(void)retrieveTaskLists{
    __weak typeof(self) weakself = self;
    
    XCTestExpectation *taskListsRetrievedExpectation = [self expectationWithDescription:TASKLISTS_RETRIEVED_EXPECTATION];
    [[KBNTaskListService sharedInstance] getTaskListsForProject:self.testProject.projectId completionBlock:^(NSDictionary *response) {
        
        NSMutableArray *taskLists = [[NSMutableArray alloc] init];
        
        for (NSDictionary* params in [response objectForKey:@"results"]) {
            [taskLists addObject:[KBNTaskListUtils taskListForProject:self.testProject params:params]];
        }
        
        
        weakself.projectLists = taskLists;
        [taskListsRetrievedExpectation fulfill];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Error getting TaskLists: %@",error.localizedDescription);
    }];
    
    [self waitForExpectationsWithTimeout:40 handler:^(NSError *error) {
        if (error){
            XCTAssertTrue(false);
        }
        else{
            XCTAssertTrue(true);
        }
    }];
}

- (void)retrieveTasks{
    XCTestExpectation *tasksExpectation = [self expectationWithDescription:TASKS_RETRIEVED_EXPECTATION];
    __weak typeof(self) weakself = self;
    [[KBNTaskService sharedInstance] getTasksForProject:TEST_PROJECT_ID
                                        completionBlock:^(NSDictionary* response){
                                            NSMutableArray *tasks = [[NSMutableArray alloc] init];
                                            for (NSDictionary* params in [response objectForKey:@"results"]) {
                                                if ([[params objectForKey:PARSE_TASK_ACTIVE_COLUMN] boolValue]) {
                                                    NSString* taskListId = [params objectForKey:PARSE_TASK_TASK_LIST_COLUMN];
                                                    
                                                    KBNTaskList *taskList;
                                                    for (KBNTaskList* list in weakself.projectLists) {
                                                        if ([list.taskListId isEqualToString:taskListId]) {
                                                            taskList = list;
                                                            break;
                                                        }
                                                    }
                                                    
                                                    KBNTask* task = [KBNTaskUtils taskForProject:weakself.testProject taskList:taskList params:params];
                                                    [tasks addObject:task];
                                                }
                                                
                                            }
                                            
                                            weakself.tasks = tasks;
                                            XCTAssertTrue(true);
                                            [tasksExpectation fulfill];
                                        }
                                             errorBlock:^(NSError *error){
                                                 XCTAssertTrue(false);
                                             }];
    
    // The test will pause here, running the run loop, until the timeout is hit
    // or all expectations are fulfilled.
    [self waitForExpectationsWithTimeout:40 handler:^(NSError *error) {
        if (error){
            XCTAssertTrue(false);
        }
        else{
            XCTAssertTrue(true);
        }
    }];
    
}



- (KBNTask*) getFirstTaskFromListId:(NSString*)listId{
    //Returns the task belonging to the give taskListId with the lowest order
    KBNTask* result;
    int order = -1;
    for (KBNTask* task in self.tasks) {
        if ([task.taskList.taskListId isEqualToString:listId] && order < [task.order intValue]){
            result = task;
            order = [task.order intValue];
        }
    }
    return result;
}


- (KBNTask*) getLastTaskFromListId:(NSString*)listId{
    //Returns the task belonging to the give taskListId with the lowest order
    KBNTask* result;
    int order = 9999;
    for (KBNTask* task in self.tasks) {
        if ([task.taskList.taskListId isEqualToString:listId] && order > [task.order intValue]){
            result = task;
            order = [task.order intValue];
        }
    }
    return result;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testKBNMoveTask{
    XCTAssertTrue(true);
    //Get a predefined project with a list of tasks, and swap the order between the 1st and 2nd task.
    
    KBNTask* taskMovedFromBacklog = [self getFirstTaskFromListId:TEST_TASKLIST_ID_BACKLOG];
    
    NSNumber* orderOfTaskMovedFromBacklog = taskMovedFromBacklog.order;
    NSString* taskIdOfTaskMovedFromBacklog = taskMovedFromBacklog.taskId;
    
    
    
    //Move a task from the backlog list to the requirements list
    XCTestExpectation *taskMovedExpectation = [self expectationWithDescription:TASK_MOVED_EXPECTATION];
    
    [[KBNTaskService sharedInstance] moveTask:taskMovedFromBacklog.taskId
                                       toList:TEST_TASKLIST_ID_REQUIREMENTS
                                        order:[NSNumber numberWithInt:1]
                              completionBlock:^(NSDictionary* records){
                                  
                                  //XCTAssertTrue(true);
                                  [taskMovedExpectation fulfill];
                                  
                              } errorBlock:^(NSError* error){
                                  XCTAssertTrue(false);
                              }];
    
    
    // The test will pause here, running the run loop, until the timeout is hit
    // or all expectations are fulfilled.
    [self waitForExpectationsWithTimeout:40 handler:^(NSError *error) {
        if (error){
            XCTAssertTrue(false);
        }
        else{
            XCTAssertTrue(true);
        }
    }];
    
    
    //Make sure the changes were effective:
    //1.-Retrieve all tasks again
    [self retrieveTasks];
    
    //2.-Look for the task that was moved
    KBNTask* movedTask;
    for (KBNTask* task in self.tasks) {
        if ([task.taskId isEqualToString:taskIdOfTaskMovedFromBacklog])
        {
            movedTask = task;
            break;
        }
    }
    
    //3.-Verify that its' task list ID is correct.
    if ((movedTask != nil) && ([movedTask.taskList.taskListId isEqualToString:TEST_TASKLIST_ID_REQUIREMENTS])){
        XCTAssertTrue(true);
    }
    else{
        XCTAssertTrue(false);
    }
    
    
    //Roll back the changes made:
    XCTestExpectation *taskMovedBackExpectation = [self expectationWithDescription:TASK_MOVED_BACK_EXPECTATION];
    
    [[KBNTaskService sharedInstance] moveTask:taskIdOfTaskMovedFromBacklog
                                       toList:TEST_TASKLIST_ID_BACKLOG
                                        order:orderOfTaskMovedFromBacklog
                              completionBlock:^(NSDictionary* records){
                                  
                                  XCTAssertTrue(true);
                                  [taskMovedBackExpectation fulfill];
                                  
                              } errorBlock:^(NSError* error){
                                  XCTAssertTrue(false);
                              }];
    
    
    // The test will pause here, running the run loop, until the timeout is hit
    // or all expectations are fulfilled.
    [self waitForExpectationsWithTimeout:40 handler:^(NSError *error) {
        if (error){
            XCTAssertTrue(false);
        }
        else{
            XCTAssertTrue(true);
        }
    }];
    
}

@end
