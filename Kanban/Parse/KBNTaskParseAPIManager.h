//
//  KBNTaskParseAPIManager.h
//  Kanban
//
//  Created by Lucas on 4/24/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNParseRequestOperationManager.h"
#import "KBNConstants.h"

@interface KBNTaskParseAPIManager : NSObject

@property KBNParseRequestOperationManager* afManager;

- (void)createTaskWithName:(NSString*)name taskDescription:(NSString*)taskDescription order:(NSNumber*)order projectId:(NSString*)projectId taskListId:(NSString*)taskListId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

- (void)moveTask:(NSString*)taskId toList:(NSString*)taskListId order:(NSNumber*)order completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

- (void)getTasksForProject:(NSString*)projectId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

- (void)incrementOrderToTaskIds:(NSArray*)taskIds by:(NSNumber*)amount completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

@end
