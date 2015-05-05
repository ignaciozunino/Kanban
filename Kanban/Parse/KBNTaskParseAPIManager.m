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
        _afManager = [[KBNParseRequestOperationManager alloc] init];
    }
    return self;
}

-(void)createTaskWithName:(NSString *)name taskDescription:(NSString *)taskDescription order:(NSNumber *)order projectId:(NSString *)projectId taskListId:(NSString *)taskListId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
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

-(void)moveTask:(NSString *)taskId toList:(NSString *)taskListId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:taskListId forKey:PARSE_TASK_TASK_LIST_COLUMN];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@/%@", PARSE_TASKS, taskId];
    
    [self.afManager PUT:stringURL
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    onCompletion(responseObject);
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    onError(error);
                }
     ];
}

-(void)getTasksForProject:(NSString *)projectId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
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

- (void)getTasksFromDateForProject:(NSString*)projectId withDate:(NSString*)lastModifiedDate completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
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

- (void)incrementOrderToTaskIds:(NSArray*)taskIds by:(NSNumber*)amount completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    NSMutableDictionary *operation = [NSMutableDictionary dictionaryWithCapacity:1];
    [operation setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Increment", @"__op", amount, @"amount", nil]
                  forKey:PARSE_TASK_ORDER_COLUMN];
    
    NSMutableArray *requests = [[NSMutableArray alloc] init];
    NSMutableDictionary *record;
    
    for (NSString *taskId in taskIds) {
        record = [NSMutableDictionary dictionaryWithCapacity:3];
        [record setObject:@"PUT" forKey:@"method"];
        [record setObject:[NSString stringWithFormat:@"/1/classes/Task/%@", taskId] forKey:@"path"];
        [record setObject:operation forKey:@"body"];
        
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



-(void)removeTask:(NSString*)taskId onSuccess:(KBNConnectionSuccessBlock)onSuccess failure:(KBNConnectionErrorBlock)onError{
    NSDictionary *params = @{PARSE_TASK_ACTIVE_COLUMN: @NO};
    NSString * url =[NSString stringWithFormat:@"%@/%@",PARSE_TASKS,taskId];
    [self.afManager PUT:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        onSuccess();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        onError(error);
    }];
    
}

@end
