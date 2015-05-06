//
//  KBNTaskService.h
//  Kanban
//
//  Created by Lucas on 4/24/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNTaskParseAPIManager.h"
#import "KBNAppDelegate.h"
#import "KBNProject.h"
#import "KBNTask.h"
#import "KBNTaskList.h"

@interface KBNTaskService : NSObject

@property (strong, nonatomic) KBNTaskParseAPIManager* dataService;

+(KBNTaskService *) sharedInstance;

- (void)createTaskWithName:(NSString*)name taskDescription:(NSString*)taskDescription order:(NSNumber*)order projectId:(NSString*)projectId taskListId:(NSString*)taskListId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

- (void)getTasksForProject:(NSString*)projectId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

- (void)removeTask:(KBNTask*)task from:(NSArray*)tasksArray completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

- (void)reorderTask:(KBNTask*)task in:(NSArray*)tasksArrray completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

- (void)moveTask:(KBNTask*)task from:(NSArray*)tasksArray completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;


// To be deleted:

-(void)removeTask:(NSString*)taskId onSuccess:(KBNConnectionSuccessBlock)onSuccess failure:(KBNConnectionErrorBlock)onError;

- (void)moveTask:(NSString*)taskId toList:(NSString*)taskListId order:(NSNumber*)order completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

- (void)updateTask:(NSString *)taskId order:(NSNumber*)order completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

@end
