//
//  KBNTaskListParseAPIManager.m
//  Kanban
//
//  Created by Lucas on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskListParseAPIManager.h"
#import "KBNTaskListUtils.h"

@implementation KBNTaskListParseAPIManager

-(instancetype) init{
    
    self = [super init];
    if (self) {
        _afManager = [[KBNParseRequestOperationManager alloc] init];
    }
    return self;
}

- (void)createTaskListWithName:(NSString*)name
                         order:(NSNumber*)order
                     projectId:(NSString*)projectId
               completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:name forKey:PARSE_TASKLIST_NAME_COLUMN];
    [params setObject:order forKey:PARSE_TASKLIST_ORDER_COLUMN];
    [params setObject:projectId forKey:PARSE_TASKLIST_PROJECT_COLUMN];
    
    [self.afManager POST:PARSE_TASKLISTS parameters: params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     onCompletion(responseObject);
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     onError(error);
                 }
     ];
}

-(void)getTaskListsForProject:(NSString*)projectId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    NSMutableDictionary *where = [NSMutableDictionary dictionaryWithCapacity:1];
    [where setObject:projectId forKey:PARSE_TASKLIST_PROJECT_COLUMN];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:where, @"where", PARSE_TASKLIST_ORDER_COLUMN, @"order", nil];
    
    [self.afManager GET:PARSE_TASKLISTS
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    onCompletion(responseObject);
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    onError(error);
                }];
}

- (void)updateTaskLists:(NSArray*)taskLists completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    NSMutableArray *requests = [[NSMutableArray alloc] init];
    NSMutableDictionary *record;
    
    for (KBNTaskList *taskList in taskLists) {
        
        NSMutableDictionary *updates = [NSMutableDictionary dictionaryWithCapacity:3];
        [updates setObject:taskList.name forKey:PARSE_TASKLIST_NAME_COLUMN];
        [updates setObject:taskList.project.projectId forKey:PARSE_TASKLIST_PROJECT_COLUMN];
        [updates setObject:taskList.order forKey:PARSE_TASKLIST_ORDER_COLUMN];
        
        record = [NSMutableDictionary dictionaryWithCapacity:3];
        
        if (taskList.taskListId) {
            [record setObject:@"PUT" forKey:@"method"];
            [record setObject:[NSString stringWithFormat:@"/1/classes/TaskList/%@", taskList.taskListId] forKey:@"path"];
        }
        else { //Task to add does not have taskId
            [record setObject:@"POST" forKey:@"method"];
            [record setObject:@"/1/classes/TaskList" forKey:@"path"];
        }
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

@end
