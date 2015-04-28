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

@end
