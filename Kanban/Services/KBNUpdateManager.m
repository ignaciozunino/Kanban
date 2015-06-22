//
//  KBNUpdateManager.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNUpdateManager.h"

@interface KBNUpdateManager ()

@end

@implementation KBNUpdateManager

+ (KBNUpdateManager *)sharedInstance {
    static  KBNUpdateManager *inst = nil;
    
    @synchronized(self){
        if (!inst) {
            inst = [[KBNUpdateManager alloc] init];
            inst.fireBaseRootReference = [[Firebase alloc] initWithUrl:FIREBASE_BASE_URL];
        }
    }
    return inst;
}

- (void)listenToProjects:(NSArray*)projects {
    
    for (KBNProject* project in projects) {
        
        NSString* stringURL = [NSString stringWithFormat:@"%@/%@", FIREBASE_BASE_URL, project.projectId];
        self.fireBaseRootReference = [[Firebase alloc] initWithUrl:stringURL];
        
        [self.fireBaseRootReference observeEventType:FEventTypeValue
                                           withBlock:^(FDataSnapshot *snapshot) {
                                               if ([snapshot.value respondsToSelector:@selector(objectForKey:)]) {
                                                   NSString* user = [snapshot.value objectForKey:FIREBASE_USER];
                                                   KBNChangeType changeType = [[snapshot.value objectForKey:FIREBASE_CHANGE_TYPE] integerValue];
                                                   id records = [snapshot.value objectForKey:FIREBASE_DATA];
                                                   
                                                   if ([user isEqualToString:[KBNUserUtils getUsername]]) {
                                                       // Delete node from firebase after receiving notification
                                                       // [snapshot.ref setValue:nil];
                                                   } else {
                                                       switch (changeType) {
                                                           case KBNChangeTypeProjectUpdate:
                                                               [self updateProject:records];
                                                               break;
                                                           case KBNChangeTypeTaskListsUpdate:
                                                               [self updateTaskLists:records];
                                                               break;
                                                           case KBNChangeTypeTaskAdded:
                                                               [self addTask:records];
                                                               break;
                                                           case KBNChangeTypeTaskUpdate:
                                                               [self updateTask:records];
                                                               break;
                                                           case KBNChangeTypeTasksUpdate:
                                                               [self updateTasks:records];
                                                               break;
                                                       }
                                                    }
                                               }
                                           }];
    }
}

- (void)updateProject:(NSDictionary*)records {
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_PROJECT
                                                        object:[KBNProjectUtils projectsFromDictionary:records key:@"results"]];
}

- (void)updateTaskLists:(NSDictionary*)records {
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TASKLISTS
                                                        object:[KBNTaskListUtils taskListsFromDictionary:records key:@"results" forProject:nil]];
}

- (void)addTask:(NSDictionary*)records {
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_TASK object:[KBNTaskUtils tasksFromDictionary:records key:@"results" forProject:nil]];
}

- (void)updateTask:(NSDictionary*)records {
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TASK object:[KBNTaskUtils tasksFromDictionary:records key:@"results" forProject:nil]];
}

- (void)updateTasks:(NSDictionary*)records {
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TASKS object:[KBNTaskUtils tasksFromDictionary:records key:@"results" forProject:nil]];
}
@end