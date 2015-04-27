//
//  KBNTaskParseAPIManager.m
//  Kanban
//
//  Created by Lucas on 4/24/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskParseAPIManager.h"

@implementation KBNTaskParseAPIManager

-(instancetype) init{
    
    self = [super init];
    
    if (self) {
        _afManager = [AFHTTPRequestOperationManager createAFManager];
    }
    return self;
}


- (void) createTask:(KBNTask *)task completionBlock:(KBNConnectionSuccesBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    [params setObject:task.name forKey:PARSE_TASK_NAME_COLUMN];
    [params setObject:task.taskDescription forKey:PARSE_TASK_DESCRIPTION_COLUMN];
    [params setObject:task.project.projectId forKey:PARSE_TASK_PROJECT_COLUMN];
    [params setObject:task.taskList.taskListId forKey:PARSE_TASK_TASK_LIST_COLUMN];
    
    [self.afManager POST:PARSE_PROJECTS parameters: params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSLog(@"POST data JSON returned: %@", responseObject);
                     onCompletion(responseObject);
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     onError(error);
                     NSLog(@"Error: %@", error);
                 }
     ];
}

- (void)moveTask:(KBNTask*)task toList:(KBNTaskList*)list success:(KBNConnectionSuccesBlock)success failure:(KBNConnectionErrorBlock)failure{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:list.taskListId forKey:PARSE_TASK_TASK_LIST_COLUMN];
    NSString *stringURL = [NSString stringWithFormat:@"%@/%@", PARSE_TASKS, task.taskId];
    [self.afManager PUT:stringURL
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                        success(responseObject);
                        }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        failure(error);
                        NSLog(@"Error: %@", error);
                        }
     ];
}


- (void)getTasksOnSuccess:(KBNConnectionSuccesBlock)success failure:(KBNConnectionErrorBlock)failure {
    
    [self.afManager GET:PARSE_TASKS
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                            success(responseObject);
                            }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            failure(error);
                            NSLog(@"Error: %@", error);
                            }];
}

-(void)getTasksForProject:(KBNProject*)project success:(KBNConnectionSuccesBlock)success failure:(KBNConnectionErrorBlock)failure
{
    NSMutableDictionary *where = [NSMutableDictionary dictionaryWithCapacity:1];
    [where setObject:project.projectId forKey:PARSE_TASK_PROJECT_COLUMN];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:where, @"where", nil];
    
    [self.afManager GET:PARSE_TASKS
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                        success(responseObject);
                        }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        failure(error);
                        NSLog(@"Error: %@", error);
                        }];
}


#pragma mark - Deprecated

//This method should be deprecated after refactoring any depending viewcontroller
- (void)getProjectsOnSuccess:(KBNConnectionSuccesBlock)success failure:(KBNConnectionErrorBlock)failure {
    
    [self.afManager GET:PARSE_PROJECTS
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                        success(responseObject);
                        }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        failure(error);
                        NSLog(@"Error: %@", error);
                        }];
    
}

//This method should be deprecated after refactoring any depending viewcontroller
- (void)getTaskListsOnSuccess:(KBNConnectionSuccesBlock)success failure:(KBNConnectionErrorBlock)failure {
    
    [self.afManager GET:PARSE_TASKLISTS
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    success(responseObject);
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    failure(error);
                    NSLog(@"Error: %@", error);
                }];
}

@end
