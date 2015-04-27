//
//  KBNTaskListParseAPIManager.m
//  Kanban
//
//  Created by Lucas on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskListParseAPIManager.h"

@implementation KBNTaskListParseAPIManager

-(instancetype) init{
    
    self = [super init];
    
    if (self) {
        _afManager = [[KBNParseRequestOperationManager alloc] init];
    }
    return self;
}

- (void) createTaskList:(KBNTaskList *)taskList completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    [params setObject:taskList.name forKey:PARSE_TASKLIST_NAME_COLUMN];
    [params setObject:taskList.taskListId forKey:PARSE_OBJECTID];
    [params setObject:taskList.order forKey:PARSE_TASKLIST_ORDER_COLUMN];
    [params setObject:taskList.project forKey:PARSE_TASKLIST_PROJECT_COLUMN];
    
    
    [self.afManager POST:PARSE_TASKLISTS parameters: params
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

- (void)getTaskListOnSuccess:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure
{
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

-(void)getTaskListsForProject:(KBNProject*)project success:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure
{
    NSMutableDictionary *where = [NSMutableDictionary dictionaryWithCapacity:1];
    [where setObject:project.projectId forKey:PARSE_TASKLIST_PROJECT_COLUMN];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:where, @"where", nil];
    
    [self.afManager GET:PARSE_TASKLISTS
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    success(responseObject);
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    failure(error);
                    NSLog(@"Error: %@", error);
                }];
}


@end
