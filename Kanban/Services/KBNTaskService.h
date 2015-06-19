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
#import "KBNTaskListService.h"
#import "KBNUpdateUtils.h"
#import <Firebase/Firebase.h>

@interface KBNTaskService : NSObject

@property (strong, nonatomic) KBNTaskParseAPIManager* dataService;
@property (nonatomic, strong) Firebase *fireBaseRootReference;

+(KBNTaskService *) sharedInstance;

- (void)createTask:(KBNTask*)aTask inList:(KBNTaskList*)aTaskList completionBlock:(KBNSuccessTaskBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)getTasksForProject:(KBNProject*)project completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)removeTask:(KBNTask*)task completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)moveTask:(KBNTask *)task toList:(KBNTaskList*)destinationList inOrder:(NSNumber*)order completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)createTasks:(NSArray*)tasks completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

-(void)updateTask:(KBNTask*)task onSuccess:(KBNSuccessBlock)onSuccess failure:(KBNErrorBlock)onError;

@end