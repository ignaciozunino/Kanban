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
                                                   
                                                   if ([user isEqualToString:[KBNUserUtils getUsername]]) {
                                                       // If we made the changes, they are already reflected in the corresponding view.
                                                       // Delete reference in firebase a determined time after receiving notification
                                                       [self performSelector:@selector(deleteReference:) withObject:snapshot.ref afterDelay:60.0];
                                                   } else {
                                                       switch (changeType) {
                                                           case KBNChangeTypeProjectUpdate:
                                                               [self updateProject:records];
                                                               break;
                                                           case KBNChangeTypeTaskListUpdate:
                                                               [self updateTaskList:records inProject:projectId];
                                                               break;
                                                           case KBNChangeTypeTaskUpdate:
                                                               [self updateTask:records inProject:projectId];
                                                               break;
                                                           case KBNChangeTypeTasksUpdate:
                                                               [self updateTasks:records inProject:projectId];
                                                               break;
                                                           case KBNChangeTypeTaskAdd:
                                                               [self addTask:records inProject:projectId];
                                                               break;
                                                       }
                                                   }
                                               }
                                           }];
    }
}

- (void)deleteReference:(Firebase*)ref {
    [ref setValue:nil];
}

- (void)updateProject:(NSDictionary*)records {
    // Get the only project from the records array and post the notification
    KBNProject *project = [[KBNProjectUtils projectsFromDictionary:records key:@"results"] firstObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_PROJECT object:project];
}

- (void)updateTaskList:(NSDictionary*)records inProject:(NSString*)projectId {
    // We get here when a task list is added.
    KBNTaskList *taskList = [[KBNTaskListUtils taskListsFromDictionary:records key:@"results" forProject:[KBNProjectUtils projectFromId:projectId]] firstObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TASKLIST object:taskList];
}

- (void)updateTask:(NSDictionary*)records inProject:(NSString*)projectId{
    // We get here when a task is deleted or moved in the same list or to another list.
    KBNTask *task = [[KBNTaskUtils tasksFromDictionary:records key:@"results" forProject:[KBNProjectUtils projectFromId:projectId]] firstObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TASK object:task];
}

- (void)addTask:(NSDictionary*)records inProject:(NSString*)projectId{
    // We get here when a task is added.
    KBNTask *task = [[KBNTaskUtils tasksFromDictionary:records key:@"results" forProject:[KBNProjectUtils projectFromId:projectId]] firstObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_TASK object:task];
}

- (void)updateTasks:(NSDictionary*)records inProject:(NSString*)projectId{
    // We get here when several tasks are created. It's only used in a test.
    NSArray *tasks = [KBNTaskUtils tasksFromDictionary:records key:@"results" forProject:[KBNProjectUtils projectFromId:projectId]];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TASK object:tasks];
}

@end