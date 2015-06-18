//
//  KBNTaskParseAPIManager.m
//  Kanban
//
//  Created by Lucas on 4/24/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskParseAPIManager.h"
#import "KBNTask.h"
#import "KBNTaskList.h"
#import "KBNProject.h"

@implementation KBNTaskParseAPIManager

-(instancetype) init{
    
    self = [super init];
    
    if (self) {
        _afManager = [[KBNParseRequestOperationManager alloc] init];
    }
    return self;
}

-(void)createTaskWithName:(NSString *)name taskDescription:(NSString *)taskDescription order:(NSNumber *)order projectId:(NSString *)projectId taskListId:(NSString *)taskListId completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
    [params setObject:name forKey:PARSE_TASK_NAME_COLUMN];
    [params setObject:taskDescription forKey:PARSE_TASK_DESCRIPTION_COLUMN];
    [params setObject:order forKey:PARSE_TASK_ORDER_COLUMN];
    [params setObject:projectId forKey:PARSE_TASK_PROJECT_COLUMN];
    [params setObject:taskListId forKey:PARSE_TASK_TASK_LIST_COLUMN];
    [params setObject:[NSNumber numberWithBool:YES] forKey:PARSE_TASK_ACTIVE_COLUMN];
    
    
    [self.afManager POST:PARSE_TASKS parameters: params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     onCompletion(responseObject);
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     onError(error);
                 }
     ];
}

-(void)getTasksForProject:(NSString *)projectId completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    NSMutableDictionary *where = [NSMutableDictionary dictionaryWithCapacity:1];
    [where setObject:projectId forKey:PARSE_TASK_PROJECT_COLUMN];
    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:where, @"where", PARSE_TASK_ORDER_COLUMN, @"order",nil];
    
    [self.afManager GET:PARSE_TASKS
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    onCompletion(responseObject);
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    onError(error);
                }];
}

- (void)getTasksUpdatedForProject:(NSString*)projectId fromDate:(NSString*)lastModifiedDate completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError{
    NSMutableDictionary *where = [NSMutableDictionary dictionaryWithCapacity:2];
    NSMutableDictionary *whereGT = [NSMutableDictionary dictionaryWithCapacity:1];
 
    NSMutableDictionary *whereDate = [NSMutableDictionary dictionaryWithCapacity:2];
    [whereDate setObject:@"Date" forKey:@"__type"];
    [whereDate setObject:lastModifiedDate forKey:@"iso"];
    
    [whereGT setObject:whereDate forKey:@"$gt"];
    
    [where setObject:projectId forKey:PARSE_TASK_PROJECT_COLUMN];
    [where setObject:whereGT forKey:PARSE_TASK_UPDATED_COLUMN];

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:where, @"where", PARSE_TASK_ORDER_COLUMN, @"order",nil];
    
    [self.afManager GET:PARSE_TASKS
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    onCompletion(responseObject);
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    onError(error);
                }];
}

// This method will receive an array of tasks to update
- (void)updateTasks:(NSArray*)tasks completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    NSMutableArray *requests = [[NSMutableArray alloc] init];
    NSMutableDictionary *record;
    
    for (KBNTask *task in tasks) {
        
        NSMutableDictionary *updates = [NSMutableDictionary dictionaryWithCapacity:6];
        [updates setObject:task.name forKey:PARSE_TASK_NAME_COLUMN];
        [updates setObject:task.taskDescription forKey:PARSE_TASK_DESCRIPTION_COLUMN];
        [updates setObject:task.taskList.taskListId forKey:PARSE_TASK_TASK_LIST_COLUMN];
        [updates setObject:task.project.projectId forKey:PARSE_TASK_PROJECT_COLUMN];
        [updates setObject:task.order forKey:PARSE_TASK_ORDER_COLUMN];
        [updates setObject:[NSNumber numberWithBool:[task.active boolValue]] forKey:PARSE_TASK_ACTIVE_COLUMN];

        record = [NSMutableDictionary dictionaryWithCapacity:3];
        [record setObject:@"PUT" forKey:@"method"];
        [record setObject:[NSString stringWithFormat:@"/1/classes/Task/%@", task.taskId] forKey:@"path"];
        [record setObject:updates forKey:@"body"];
        
        [requests addObject:record];
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:requests, @"requests", nil];
    
    [self.afManager POST:PARSE_BATCH
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject){
                     onCompletion(responseObject);
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     onError(error);
                 }];
}

// This method will receive an array of tasks to create
- (void)createTasks:(NSArray*)tasks
    completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    NSMutableArray *requests = [[NSMutableArray alloc] init];
    NSMutableDictionary *record;
    
    for (KBNTask *task in tasks) {
        
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:6];
        [data setObject:task.name forKey:PARSE_TASK_NAME_COLUMN];
        [data setObject:task.taskDescription forKey:PARSE_TASK_DESCRIPTION_COLUMN];
        [data setObject:task.taskList.taskListId forKey:PARSE_TASK_TASK_LIST_COLUMN];
        [data setObject:task.project.projectId forKey:PARSE_TASK_PROJECT_COLUMN];
        [data setObject:task.order forKey:PARSE_TASK_ORDER_COLUMN];
        [data setObject:@YES forKey:PARSE_TASK_ACTIVE_COLUMN];
        
        record = [NSMutableDictionary dictionaryWithCapacity:3];
        [record setObject:@"POST" forKey:@"method"];
        [record setObject:@"/1/classes/Task" forKey:@"path"];
        [record setObject:data forKey:@"body"];
        
        [requests addObject:record];
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:requests, @"requests", nil];
    
    [self.afManager POST:PARSE_BATCH
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject){
                     onCompletion(responseObject);
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     onError(error);
                 }];
}

@end
