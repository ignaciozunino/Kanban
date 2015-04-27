//
//  KBNTaskParseAPIManager.h
//  Kanban
//
//  Created by Lucas on 4/24/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "AFHTTPRequestOperationManager+KBNParseAPIManager.h"
#import "KBNTask.h"
#import "KBNProject.h"
#import "KBNTaskList.h"

@interface KBNTaskParseAPIManager : NSObject

@property AFHTTPRequestOperationManager* afManager;

- (void) createTask:(KBNTask *)task completionBlock:(KBNConnectionSuccesBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;
- (void)moveTask:(KBNTask*)task toList:(KBNTaskList*)list success:(KBNConnectionSuccesBlock)success failure:(KBNConnectionErrorBlock)failure;
- (void)getTasksOnSuccess:(KBNConnectionSuccesBlock)success failure:(KBNConnectionErrorBlock)failure;
-(void)getTasksForProject:(KBNProject*)project success:(KBNConnectionSuccesBlock)success failure:(KBNConnectionErrorBlock)failure;
@end
