//
//  KBNTaskListParseAPIManager.h
//  Kanban
//
//  Created by Lucas on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNParseRequestOperationManager.h"
#import "KBNTask.h"
#import "KBNProject.h"
#import "KBNTaskList.h"
#import "KBNConstants.h"

@interface KBNTaskListParseAPIManager : NSObject

@property AFHTTPRequestOperationManager* afManager;

- (void) createTaskList:(KBNTaskList *)task completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;
- (void)getTaskListOnSuccess:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure;
-(void)getTaskListsForProject:(KBNProject*)project success:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure;

@end
