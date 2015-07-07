//
//  KBNTaskListService.h
//  Kanban
//
//  Created by Lucas on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNAppDelegate.h"
#import "KBNTaskListParseAPIManager.h"
#import "KBNTaskListUtils.h"
#import "KBNUpdateUtils.h"

@interface KBNTaskListService : NSObject

@property (strong, nonatomic) KBNTaskListParseAPIManager* dataService;
@property Firebase* fireBaseRootReference;

+(KBNTaskListService *) sharedInstance;

- (BOOL)hasCountLimitBeenReached:(KBNTaskList*)taskList;

- (void)moveTaskList:(KBNTaskList*)taskList toOrder:(NSNumber*)order completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)createTaskList:(KBNTaskList*)taskList forProject:(KBNProject*)project inOrder:(NSNumber *)order completionBlock:(KBNSuccessTaskListBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)getTaskListsForProject:(KBNProject*)project completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

@end
