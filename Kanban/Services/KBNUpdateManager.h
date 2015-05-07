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

#define KBNProjectsUpdated                 @"KBNProjectsUpdated"
#define KBNTasksUpdated                  @"KBNTasksUpdated"
#define KBNCurrentProjectUpdated                  @"KBNCurrentProjectUpdated"

#define KBNTimeBetweenUpdates           50000

@interface KBNUpdateManager : NSObject

@property NSMutableArray * updatedProjects;
@property NSMutableArray * updatedTasks;
@property KBNProject * projectForTasksUpdate;

 + (KBNUpdateManager *)sharedInstance;
-(void)startUpdatingProjects;
-(void)startUpdatingTasksForProject:(KBNProject*)project;
-(void)stopUpdatingProjects;
-(void)stopUpdatingTasks;

@end
