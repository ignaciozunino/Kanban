//
//  KBNTaskListParseAPIManager.m
//  Kanban
//
//  Created by Lucas on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskListParseAPIManager.h"
#import "KBNTaskListUtils.h"
#import "NSDate+Utils.h"

@implementation KBNTaskListParseAPIManager

-(instancetype) init{
    
    self = [super init];
    if (self) {
        _afManager = [[KBNParseRequestOperationManager alloc] init];
    }
    return self;
}

- (void)createTaskLists:(NSArray*)listNames forProject:(NSString*)projectId onCompletion:(KBNSuccessArrayBlock)onCompletion onError:(KBNErrorBlock)onError {
    
    __block NSError *error = nil;
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    __block NSMutableArray *listsInfo = [NSMutableArray array];
    
    for (int i = 0; i < listNames.count; i++) {
        
        NSDictionary *listdata = @{PARSE_TASKLIST_NAME_COLUMN: listNames[i], PARSE_TASKLIST_PROJECT_COLUMN: projectId, PARSE_TASKLIST_ORDER_COLUMN:[NSNumber numberWithInteger:i]};
        dispatch_group_enter(serviceGroup);

        [self.afManager POST:PARSE_TASKLISTS parameters:listdata  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // As we don't know the order in which blocks are completed, we save the listId and the corresponding order too
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [responseObject objectForKey:PARSE_OBJECTID], @"taskListId",
                                  [NSDate dateFromParseString:[responseObject objectForKey:PARSE_CREATED_COLUMN]], @"updatedAt",
                                  [NSNumber numberWithInt:i], @"order", nil];
            [listsInfo addObject:info];
            dispatch_group_leave(serviceGroup);
        } failure:^(AFHTTPRequestOperation *operation, NSError *errorParse) {
            error = errorParse;
            dispatch_group_leave(serviceGroup);
        }];
    }
    
    dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
        if (error) {
            onError(error);
        } else {
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
            [listsInfo sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            onCompletion(listsInfo);
        }
    });
}

- (void)getTaskListsForProject:(NSString*)projectId completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
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

- (void)updateTaskLists:(NSArray*)taskLists completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    NSMutableArray *requests = [[NSMutableArray alloc] init];
    NSMutableDictionary *record;
    
    for (KBNTaskList *taskList in taskLists) {
        
        NSMutableDictionary *updates = [NSMutableDictionary dictionaryWithCapacity:3];
        [updates setObject:taskList.name forKey:PARSE_TASKLIST_NAME_COLUMN];
        [updates setObject:taskList.project.projectId forKey:PARSE_TASKLIST_PROJECT_COLUMN];
        [updates setObject:taskList.order forKey:PARSE_TASKLIST_ORDER_COLUMN];
        
        record = [NSMutableDictionary dictionaryWithCapacity:3];
        
        // TaskList to add does not have taskListId.
        // Update taskLists with taskListId and post taskList with no taskListId to be created.
        if (taskList.taskListId) {
            [record setObject:@"PUT" forKey:@"method"];
            [record setObject:[NSString stringWithFormat:@"/1/classes/TaskList/%@", taskList.taskListId] forKey:@"path"];
        }
        else {
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
                     // Parse response to get the item with the id of the taskList created and return it.
                     for (NSDictionary *record in responseObject) {
                         NSDictionary *result = [record objectForKey:@"success"];
                         if ([result objectForKey:PARSE_OBJECTID]) {
                             onCompletion(result);
                         }
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     onError(error);
                 }];
}

@end
