//
//  KBNUpdateManager.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNUpdateManager.h"

@interface KBNUpdateManager ()
@property (nonatomic,unsafe_unretained) BOOL shouldUpdateTasks;
@property (nonatomic,unsafe_unretained) BOOL shouldUpdateProjects;
@property (nonatomic,strong) NSDate *lastProjectSyncDate;
@property (nonatomic,strong) NSDate *lastTasksSyncDate;
@property NSString * lastProjectsUpdate;
@property NSString * lastTasksUpdate;
@end

@implementation KBNUpdateManager


-(void)startUpdatingProjects{
    self.shouldUpdateProjects = YES;
    self.lastProjectsUpdate = [NSDate getUTCNowWithParseFormat];
    
    dispatch_after(KBNTimeBetweenUpdates, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self updateProjects];
    });
}

-(void)startUpdatingTasksForProject:(KBNProject*)project{
    self.projectForTasksUpdate =project;
    self.shouldUpdateTasks= YES;
    __weak KBNUpdateManager* weakself = self;
    [[KBNTaskService sharedInstance] getTasksForProject:project.projectId completionBlock:^(NSDictionary *records) {
        NSMutableArray *tasks = [[NSMutableArray alloc] init];
        
        for (NSDictionary* params in [records objectForKey:@"results"]) {
            NSString* taskListId = [params objectForKey:PARSE_TASK_TASK_LIST_COLUMN];
            KBNTaskList *taskList;
            BOOL isactive = ((NSNumber*)[params objectForKey:PARSE_TASK_ACTIVE_COLUMN]).boolValue;
            if (isactive){
                
                for (KBNTaskList* list in weakself.projectForTasksUpdate.taskLists) {
                    if ([list.taskListId isEqualToString:taskListId]) {
                        taskList = list;
                        [tasks addObject:[KBNTaskUtils taskForProject:weakself.projectForTasksUpdate taskList:taskList params:params]];
                        break;
                    }
                }
                
            }
        }
        
        weakself.updatedTasks = tasks;
        [self postNotification:KBNTasksUpdated];
     dispatch_after(KBNTimeBetweenUpdates, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            
            [self updateTasks];
        });
        
    } errorBlock:^(NSError *error) {
        
    }];
   
    
    
}

-(void)stopUpdatingProjects{
    self.shouldUpdateProjects = NO;
    
}

-(void)stopUpdatingTasks{
    
    self.shouldUpdateTasks= NO;
    
}

-(void)updateProjects{
    if (self.shouldUpdateProjects) {
        //query
        //completionblock
        //{
        //if (upated){
        [self postNotification:KBNProjectsUpdated];
        //}
        dispatch_after(KBNTimeBetweenUpdates, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self updateProjects];
        });
    }
}

-(void)updateTasks{
    if (self.shouldUpdateTasks) {
        self.lastTasksUpdate = [NSDate getUTCNowWithParseFormat];
        [[KBNTaskService sharedInstance] getUpdatedTasksForProject:self.projectForTasksUpdate.projectId withModifiedDate:self.lastTasksUpdate completionBlock:^(NSDictionary *records) {
            if(records.count > 0 ){
                [self updateExistingObjectsFromDictionary:[records objectForKey:@"results"]];
                [self postNotification:KBNTasksUpdated];
            }
            dispatch_after(KBNTimeBetweenUpdates, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [self updateTasks];
            });
        } errorBlock:^(NSError *error) {
            
        }];
        
    }
}

- (void)postNotification:(NSString *)notificationName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

- (void)dealloc
{
    // [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) updateExistingObjectsFromDictionary:(NSDictionary *) updatedTasks
{
    for (NSDictionary* params in updatedTasks) {
        NSString* taskListId = [params objectForKey:PARSE_TASK_TASK_LIST_COLUMN];
        KBNTaskList *taskList;
        BOOL isactive = ((NSNumber*)[params objectForKey:PARSE_TASK_ACTIVE_COLUMN]).boolValue;
        if (isactive){
            
            for (KBNTaskList* list in self.projectForTasksUpdate.taskLists) {
                if ([list.taskListId isEqualToString:taskListId]) {
                    taskList = list;
                    KBNTask *t = [KBNTaskUtils taskForProject:self.projectForTasksUpdate taskList:taskList params:params];
                    if ([self.updatedTasks containsObject:t]) {
                        [self.updatedTasks replaceObjectAtIndex:[self.updatedTasks indexOfObject:t] withObject:t];
                    }else{
                        [self.updatedTasks addObject:t];
                    }

                   
                    break;
                }
            }
            
        }
        
      
    }
}


@end

