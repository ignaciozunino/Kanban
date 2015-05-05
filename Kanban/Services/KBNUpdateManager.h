//
//  KBNUpdateManager.h
//  Kanban
//
//  Created by Guillermo Apoj on 4/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KBNProjectsUpdated                 @"KBNProjectsUpdated"
#define KBNTasksUpdated                  @"KBNTasksUpdated"
#define KBNTimeBetweenUpdates           5.0

@interface KBNUpdateManager : NSObject

@property NSArray * updatedProjects;
@property NSArray * updatedTasks;

// + (KBNUpdateManager *)sharedInstance;
-(void)startUpdatingProjects;
-(void)startUpdatingTasks;
-(void)stopUpdatingProjects;
-(void)stopUpdatingTasks;

@end
