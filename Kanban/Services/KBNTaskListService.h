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


@interface KBNTaskListService : NSObject

@property KBNTaskListParseAPIManager* dataService;

+(KBNTaskListService *) sharedInstance;
- (void)createTaskList:(NSString*)name withDescription:(NSString*)taskDescription withTaskList:(KBNTaskList*)taskList withProject:(KBNProject*)project success:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure;
- (void)createTaskList:(KBNTask*)task success:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure;
- (void)moveTaskList:(KBNTask*)task toList:(KBNTaskList*)list success:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure;
- (void)getTaskListsOnSuccess:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure;
- (void)getTaskListsForProject:(KBNProject*)project success:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure;
@end
