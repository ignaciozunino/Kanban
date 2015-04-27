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

@property KBNTaskParseAPIManager* dataService;

+(KBNTaskService *) sharedInstance;
- (void)createTask:(NSString*)name withDescription:(NSString*)taskDescription withTaskList:(KBNTaskList*)taskList withProject:(KBNProject*)project success:(KBNConnectionSuccesBlock)success failure:(KBNConnectionErrorBlock)failure;
- (void)createTask:(KBNTask*)task success:(KBNConnectionSuccesBlock)success failure:(KBNConnectionErrorBlock)failure;
- (void)moveTask:(KBNTask*)task toList:(KBNTaskList*)list success:(KBNConnectionSuccesBlock)success failure:(KBNConnectionErrorBlock)failure;
- (void)getTasksOnSuccess:(KBNConnectionSuccesBlock)success failure:(KBNConnectionErrorBlock)failure;
- (void)getTasksForProject:(KBNProject*)project success:(KBNConnectionSuccesBlock)success failure:(KBNConnectionErrorBlock)failure;
@end
