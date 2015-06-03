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

- (void)createTaskListWithName:(NSString*)name order:(NSNumber*)order projectId:(NSString*)projectId
               completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

-(void)getTaskListsForProject:(NSString*)projectId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

- (void)updateTaskLists:(NSArray*)taskLists completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

@end
