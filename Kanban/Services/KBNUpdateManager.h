//
//  KBNUpdateManager.h
//  Kanban
//
//  Created by Guillermo Apoj on 4/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNProjectService.h"
#import "KBNTaskService.h"
#import "KBNTaskUtils.h"
#import "KBNUserUtils.h"
#import "KBNUpdateUtils.h"
#import <Firebase/Firebase.h>

@interface KBNUpdateManager : NSObject

@property KBNProject * projectForTasksUpdate;
@property (nonatomic, strong) Firebase *fireBaseRootReference;

+ (KBNUpdateManager *)sharedInstance;

- (void)listenToProjects:(NSArray*)projects;

@end
