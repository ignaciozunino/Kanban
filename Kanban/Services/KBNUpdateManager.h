//
//  KBNUpdateManager.h
//  Kanban
//
//  Created by Guillermo Apoj on 4/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+Utils.h"
#import "KBNTaskService.h"
#import "KBNTaskUtils.h"
#import "KBNTaskList.h"
#import "KBNUserUtils.h"
#import "KBNProjectService.h"
#import "KBNUpdateUtils.h"

#define KBNProjectsUpdated @"KBNProjectsUpdated"
#define KBNProjectsInitialUpdate @"KBNProjectsInitialUpdate"
#define KBNTasksInitialUpdate @"KBNTasksInitialUpdate"
#define KBNTasksUpdated @"KBNTasksUpdated"
#define KBNCurrentProjectUpdated @"KBNCurrentProjectUpdated"

#define KBNTimeBetweenUpdates 2.0

@interface KBNUpdateManager : NSObject

@property KBNProjectService* projectService;
@property KBNTaskService * tasksService;
@property KBNProject * projectForTasksUpdate;

+ (KBNUpdateManager *)sharedInstance;
-(void)startUpdatingProjects;
-(void)startUpdatingTasksForProject:(KBNProject*)project;
-(void)stopUpdatingProjects;
-(void)stopUpdatingTasks;

@end
