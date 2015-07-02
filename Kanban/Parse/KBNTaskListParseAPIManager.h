//
//  KBNTaskListParseAPIManager.h
//  Kanban
//
//  Created by Lucas on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNParseRequestOperationManager.h"
#import "KBNConstants.h"

@interface KBNTaskListParseAPIManager : NSObject

@property KBNParseRequestOperationManager* afManager;

- (void)createTaskLists:(NSArray*)listNames forProject:(NSString*)projectId onCompletion:(KBNSuccessArrayBlock)onCompletion onError:(KBNErrorBlock)onError;

- (void)getTaskListsForProject:(NSString*)projectId completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)updateTaskLists:(NSArray*)taskLists completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

@end
