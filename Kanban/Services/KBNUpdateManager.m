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
    self.updatedTasks = [NSMutableArray new];
    self.shouldUpdateTasks= YES;
    __weak KBNUpdateManager* weakself = self;
    [[KBNTaskService sharedInstance] getTasksForProject:project.projectId completionBlock:^(NSDictionary *records) {
        NSMutableArray *tasks = [[NSMutableArray alloc] init];
        
       [self updateExistingTasksFromDictionary:[records objectForKey:@"results"]];
        
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
                [self updateExistingTasksFromDictionary:[records objectForKey:@"results"]];
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

//update the tasks retrieved in the dictionary or if is not previusly exists add the new task
-(void) updateExistingTasksFromDictionary:(NSDictionary *) updatedTasks
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
                    NSInteger index = [self indexOfTask:t];
                    if (index!= -1) {
                        [self.updatedTasks replaceObjectAtIndex:index withObject:t];
                    }else{
                        [self.updatedTasks addObject:t];
                    }

                   
                    break;
                }
            }
            
        }else{///if it is not active we look if it was removed
            KBNTask *t = [KBNTask new ];
            //here we only care about the task id to compare
            [t setValue:[params objectForKey:PARSE_OBJECTID] forKey:@"taskId"];
                 NSInteger index = [self indexOfTask:t];
            if (index == -1) {
                [self.updatedTasks removeObjectAtIndex:index];
            }
        }
        
      
    }
}

//returns the index of the task in the updatedTask array or -1 if is not in the array
-(NSInteger) indexOfTask:(KBNTask*)task{
    for (int i = 0; i<self.updatedTasks.count; i++) {
        if([task.taskId isEqualToString:((KBNTask *)[self.updatedTasks objectAtIndex:i]).taskId ]){
            return i;
        }
    }
    return -1;
}

@end

