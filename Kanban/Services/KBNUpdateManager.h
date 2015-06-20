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
#import <Firebase/Firebase.h>

#define KBNProjectsUpdated @"KBNProjectsUpdated"
#define KBNProjectUpdated @"KBNProjectUpdated"
#define KBNTasksUpdated @"KBNTasksUpdated"
#define KBNTaskUpdated @"KBNTaskUpdated"
#define KBNCurrentProjectUpdated @"KBNCurrentProjectUpdated"

@interface KBNUpdateManager : NSObject

@property KBNProject * projectForTasksUpdate;
@property (nonatomic, strong) Firebase *fireBaseRootReference;

+ (KBNUpdateManager *)sharedInstance;
- (void)startUpdatingProjects;
- (void)startUpdatingTaskListsForProject:(KBNProject*)project;
- (void)startUpdatingTasksForProject:(KBNProject*)project;
- (void)stopUpdatingProjects;
- (void)stopUpdatingTaskLists;
- (void)stopUpdatingTasks;
- (void)startListeningProjects:(NSArray*)projects;
- (void)startListeningTaskLists:(NSArray*)taskLists;
- (void)startListeningTasks:(NSArray*)tasks;

@end
