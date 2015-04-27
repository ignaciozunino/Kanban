//
//  KBNTaskService.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/22/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskServiceOld.h"
#import "KBNConstants.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation KBNTaskServiceOld

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&onceToken, ^{
        if (!_sharedObject) {
            _sharedObject = [[self alloc] init];
            [_sharedObject setup];
        }
    });
    
    return _sharedObject;
}

- (void)setup {
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:PARSE_APP_ID forHTTPHeaderField:@"X-Parse-Application-Id"];
    [self.requestSerializer setValue:PARSE_REST_API_KEY forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
}

- (void)createTask:(KBNTask*)task success:(Success)success failure:(Failure)failure {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    [params setObject:task.name forKey:PARSE_TASK_NAME_COLUMN];
    [params setObject:task.taskDescription forKey:PARSE_TASK_DESCRIPTION_COLUMN];
    [params setObject:task.project.projectId forKey:PARSE_TASK_PROJECT_COLUMN];
    [params setObject:task.taskList.taskListId forKey:PARSE_TASK_TASK_LIST_COLUMN];
    
    [self POST:PARSE_TASKS parameters:params success:success failure:failure];
    
}

- (void)moveTask:(KBNTask*)task toList:(KBNTaskList*)list success:(Success)success failure:(Failure)failure {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:list.taskListId forKey:PARSE_TASK_TASK_LIST_COLUMN];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@/%@", PARSE_TASKS, task.taskId];
    
    [self PUT:stringURL parameters:params success:success failure:failure];

}

- (void)getTasksOnSuccess:(Success)success failure:(Failure)failure {
    
    [self GET:PARSE_TASKS parameters:nil success:success failure:failure];
    
}

- (void)getTasksForProject:(KBNProject*)project success:(Success)success failure:(Failure)failure {
    
    NSMutableDictionary *where = [NSMutableDictionary dictionaryWithCapacity:1];
    [where setObject:project.projectId forKey:PARSE_TASK_PROJECT_COLUMN];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:where, @"where", nil];
    
    [self GET:PARSE_TASKS parameters:params success:success failure:failure];
    
}

- (void)getProjectsOnSuccess:(Success)success failure:(Failure)failure {
    
    [self GET:PARSE_PROJECTS parameters:nil success:success failure:failure];
    
}

- (void)getTaskListsOnSuccess:(Success)success failure:(Failure)failure {
    
    [self GET:PARSE_TASKLISTS parameters:nil success:success failure:failure];
    
}

@end