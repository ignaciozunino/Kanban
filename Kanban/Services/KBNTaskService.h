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

@interface KBNTaskService : NSObject

@property (strong, nonatomic) KBNTaskParseAPIManager* dataService;

+(KBNTaskService *) sharedInstance;

- (void)createTask:(KBNTask*)aTask inList:(KBNTaskList*)aTaskList completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

- (void)getTasksForProject:(NSString*)projectId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

- (void)removeTask:(KBNTask*)task completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

- (void) moveTask:(KBNTask *)task toList:(KBNTaskList*)destinationList inOrder:(NSNumber*)order completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;


@end
