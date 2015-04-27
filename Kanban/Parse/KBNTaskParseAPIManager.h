//
//  KBNTaskParseAPIManager.h
//  Kanban
//
//  Created by Lucas on 4/24/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNParseRequestOperationManager.h"
#import "KBNTask.h"
#import "KBNProject.h"
#import "KBNTaskList.h"
#import "KBNConstants.h"

@interface KBNTaskParseAPIManager : NSObject

@property KBNParseRequestOperationManager* afManager;

- (void) createTask:(KBNTask *)task completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;
- (void)moveTask:(KBNTask*)task toList:(KBNTaskList*)list success:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure;
- (void)getTasksOnSuccess:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure;
-(void)getTasksForProject:(KBNProject*)project success:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure;
@end
