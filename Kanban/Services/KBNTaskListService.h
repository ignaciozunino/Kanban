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

@interface KBNTaskListService : NSObject

@property (strong, nonatomic) KBNTaskListParseAPIManager* dataService;           

+(KBNTaskListService *) sharedInstance;

- (void)createTaskListWithName:(NSString*)name order:(NSNumber*)order projectId:(NSString*)projectId
               completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

-(void)getTaskListsForProject:(NSString*)projectId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

-(BOOL)hasCountLimitBeenReached:(KBNTaskList*)taskList;

- (void)moveTaskList:(KBNTaskList *)taskList toOrder:(NSNumber*)order completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

- (void)createTaskList:(KBNTaskList*)taskList forProject:(KBNProject*)project inOrder:(NSNumber *)order completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

@end
