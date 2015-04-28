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

//-(void)decrementOrderOnTaskList:(NSString*)taskListId from:(NSNumber*)order completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
//    
//    NSDictionary *operation = NSDictionary dictionaryWithObjectsAndKeys:<#(id), ...#>, nil
//    
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
//    [params setObject:taskListId forKey:PARSE_TASK_TASK_LIST_COLUMN];
//    
//    [self.afManager PUT:PARSE_TASKS
//             parameters:params
//                success:^(AFHTTPRequestOperation *operation, id responseObject){
//                    onCompletion(responseObject);
//                }
//                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                    onError(error);
//                }
//     ];
//}

-(void)getTasksForTaskList:(NSString*)taskListId withOrderGreaterThan:(NSNumber*) order completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError
{
    NSMutableDictionary *greaterThanOrder = [NSMutableDictionary dictionaryWithCapacity:1];
    [greaterThanOrder setObject:order forKey:@"$gt"];//@{@"$gt":order};
    
    NSDictionary *column = [NSDictionary dictionaryWithObjectsAndKeys:greaterThanOrder, PARSE_TASK_ORDER_COLUMN, nil];
    
    NSMutableDictionary *where = [NSMutableDictionary dictionaryWithCapacity:2];
    [where setObject:taskListId forKey:PARSE_TASK_PROJECT_COLUMN];

    //[where setObject:orderDict forKey:PARSE_TASK_ORDER_COLUMN];
    [where setObject:greaterthan forKey:PARSE_TASK_ORDER_COLUMN];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:where, @"where", nil];
    
    [self.afManager GET:PARSE_TASKS
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    NSDictionary *projectList = [responseObject objectForKey:@"results"];
                }
                failure:^(AFHTTPRequestOperation operation, NSError error) {
                    onError(error);
                    NSLog(@"Error: %@", error);
                }];
}

@end
