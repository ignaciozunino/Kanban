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
                                                   NSString *projectId = snapshot.key;
                                                   
//                                                   if ([user isEqualToString:[KBNUserUtils getUsername]]) {
                                                       // If we made the changes, they are already reflected in the corresponding view.
                                                       // Delete reference in firebase a determined time after receiving notification
                                                   [self performSelector:@selector(deleteReference:) withObject:snapshot.ref afterDelay:600.0];
//                                                   } else {
                                                       switch (changeType) {
                                                           case KBNChangeTypeProjectUpdate:
                                                               [self updateProject:records];
                                                               break;
                                                           case KBNChangeTypeTaskListsUpdate:
                                                               [self updateTaskLists:records inProject:projectId];
                                                               break;
                                                           case KBNChangeTypeTaskAdded:
                                                               [self addTask:records inProject:projectId];
                                                               break;
                                                           case KBNChangeTypeTaskUpdate:
                                                               [self updateTask:records inProject:projectId];
                                                               break;
                                                           case KBNChangeTypeTasksUpdate:
                                                               [self updateTasks:records inProject:projectId];
                                                               break;
                                                       }
//                                                   }
                                               }
                                           }];
    }
}

- (void)deleteReference:(Firebase*)ref {
    [ref setValue:nil];
}

- (void)updateProject:(NSDictionary*)records {
    // Get the only project from the records array and post the notification
    KBNProject* project = [[KBNProjectUtils projectsFromDictionary:records key:@"results"] firstObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_PROJECT object:project];
}

- (void)updateTaskLists:(NSDictionary*)records inProject:(NSString*)projectId {
    // We get here when a task list is added. The order of the other lists may change, so we notify an array of updated task lists.
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TASKLISTS
                                                        object:[KBNTaskListUtils taskListsFromDictionary:records key:@"results" forProject:[KBNProjectUtils projectFromId:projectId]]];
}

- (void)addTask:(NSDictionary*)records inProject:(NSString*)projectId{
    // Get the task from the records array and post the notification
    // As the task is added at the end of the list, there will be only one. No other task is modified when a new task is added.
    KBNTask *task = [[KBNTaskUtils tasksFromDictionary:records key:@"results" forProject:[KBNProjectUtils projectFromId:projectId]] firstObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_TASK object:task];
}

- (void)updateTask:(NSDictionary*)records inProject:(NSString*)projectId{
    // We get here when the task name or description is changed. Get the task from the records array and post the notification.
    KBNTask *task = [[KBNTaskUtils tasksFromDictionary:records key:@"results" forProject:[KBNProjectUtils projectFromId:projectId]] firstObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TASK object:task];
}

- (void)updateTasks:(NSDictionary*)records inProject:(NSString*)projectId{
    // We get here when a task is moved (in the same list or to another list) or a task is deleted. 
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TASKS object:[KBNTaskUtils tasksFromDictionary:records key:@"results" forProject:[KBNProjectUtils projectFromId:projectId]]];
}
@end