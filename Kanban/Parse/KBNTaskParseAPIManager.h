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

- (void)createTaskWithName:(NSString*)name taskDescription:(NSString*)taskDescription order:(NSNumber*)order projectId:(NSString*)projectId taskListId:(NSString*)taskListId priority:(NSNumber *)priority completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)getTasksForProject:(NSString*)projectId completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)updateTasks:(NSArray*)tasks completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)getTasksUpdatedForProject:(NSString*)projectId fromDate:(NSString*)lastModifiedDate completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)createTasks:(NSArray*)tasks completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

@end
