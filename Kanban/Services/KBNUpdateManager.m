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
@property NSString * lastProjectsUpdate;
@property NSString * lastTasksUpdate;
@property NSTimer * projectTimer;
@property NSTimer * taskTimer;
@end

@implementation KBNUpdateManager

+ (KBNUpdateManager *)sharedInstance{
    static  KBNUpdateManager *inst = nil;
    
    @synchronized(self){
        if (!inst) {
            inst = [[KBNUpdateManager alloc] init];
        }
    }
    return inst;
}

- (id)init {
    self = [super init];
    if (self) {
        self.updatedTasks = [[NSMutableArray alloc]init];
        self.updatedProjects = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)startUpdatingProjects{
    if (!self.projectTimer) {
        [[KBNProjectService sharedInstance] getProjectsForUser:[KBNUserUtils getUsername]
                                                onSuccessBlock:^(NSArray *records) {
                                                    
                                                    [self updateExistingProjectsFromArray:records];
                                                    self.lastProjectsUpdate =[NSDate getUTCNowWithParseFormat];
                                                    [self postNotification:KBNProjectsUpdated];
                                                    self.shouldUpdateProjects = YES;
                                                    self.projectTimer = [NSTimer scheduledTimerWithTimeInterval:KBNTimeBetweenUpdates
                                                                                                         target:self
                                                                                                       selector:@selector(updateProjects)
                                                                                                       userInfo:nil
                                                                                                        repeats:YES];
                                                }
                                                    errorBlock:^(NSError *error) {
                                                        
                                                    }];
    }
}

-(void)startUpdatingTasksForProject:(KBNProject*)project{
    self.projectForTasksUpdate =project;
    
    [[KBNTaskService sharedInstance] getTasksForProject:project.projectId
                                        completionBlock:^(NSDictionary *records) {
                                            
                                            [self updateExistingTasksFromDictionary:[records objectForKey:@"results"]];
                                            
                                            [self postNotification:KBNTasksUpdated];
                                            self.lastTasksUpdate = [NSDate getUTCNowWithParseFormat];
                                            self.shouldUpdateTasks = YES;
                                            self.taskTimer =  [NSTimer scheduledTimerWithTimeInterval:KBNTimeBetweenUpdates
                                                                                               target:self
                                                                                             selector:@selector(updateTasks)
                                                                                             userInfo:nil
                                                                                              repeats:YES];
                                        }
                                             errorBlock:^(NSError *error) {
                                                 
                                             }];
}

-(void)stopUpdatingProjects{
    self.shouldUpdateProjects = NO;
    [self.projectTimer invalidate];
}

-(void)stopUpdatingTasks{
    self.shouldUpdateTasks= NO;
    [self.taskTimer invalidate];
}

-(void)updateProjects{
    
    if (self.shouldUpdateProjects) {
        [[KBNProjectService sharedInstance]getProjectsForUser:[KBNUserUtils getUsername]
                                                 updatedAfter:self.lastProjectsUpdate
                                               onSuccessBlock:^(NSArray *records) {
                                                   if (records.count>0) {
                                                       [self updateExistingProjectsFromArray:records];
                                                       [self postNotification:KBNProjectsUpdated];
                                                   }
                                                   self.lastTasksUpdate = [NSDate getUTCNowWithParseFormat];
                                               }
                                                   errorBlock:^(NSError *error) {
                                                       
                                                   }];
    }
}

-(void)updateTasks{
    if (self.shouldUpdateTasks) {
        
        [[KBNTaskService sharedInstance] getUpdatedTasksForProject:self.projectForTasksUpdate.projectId
                                                  withModifiedDate:self.lastTasksUpdate
                                                   completionBlock:^(NSDictionary *records) {
                                                       NSDictionary * results=[records objectForKey:@"results"];
                                                       if(results.count > 0 ){
                                                           [self updateExistingTasksFromDictionary:results];
                                                           [self postNotification:KBNTasksUpdated];
                                                       }
                                                       self.lastTasksUpdate = [NSDate getUTCNowWithParseFormat];
                                                   }
                                                        errorBlock:^(NSError *error) {
                                                            
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
                    NSInteger index = [self indexOfTask:[params objectForKey:PARSE_OBJECTID]];
                    if (index!= -1) {
                        [self.updatedTasks replaceObjectAtIndex:index withObject:t];
                    }else{
                        [self.updatedTasks addObject:t];
                    }
                    break;
                }
            }
            
        }else{///if it is not active we look if it was removed
            //here we only care about the task id to compare
            NSInteger index = [self indexOfTask:[params objectForKey:PARSE_OBJECTID]];
            if (index != -1) {
                [self.updatedTasks removeObjectAtIndex:index];
            }
        }
    }
}

//returns the index of the task in the updatedTask array or -1 if is not in the array
-(NSInteger) indexOfTask:(NSString*)taskid{
    for (int i = 0; i<self.updatedTasks.count; i++) {
        if([taskid isEqualToString:((KBNTask*)[self.updatedTasks objectAtIndex:i]).taskId ]){
            return i;
        }
    }
    return -1;
}
//update the projects retrieved in the dictionary or if is not previusly exists add the new task
-(void) updateExistingProjectsFromArray:(NSArray *) updatedProjects
{
    for (KBNProject *project in updatedProjects) {
        NSInteger index = [self indexOfProject:project.projectId];
        if (index!= -1) {
            [self.updatedProjects replaceObjectAtIndex:index withObject:project];
            //if we update the current project we notify
            if ([project.projectId isEqualToString:self.projectForTasksUpdate.projectId]) {
                self.projectForTasksUpdate= project;
                [self postNotification:KBNCurrentProjectUpdated];
            }
            
        }else{
            [self.updatedProjects addObject:project];
        }
    }
}

//returns the index of the projrct in the updatedTask array or -1 if is not in the array
-(NSInteger) indexOfProject:(NSString*)projectid{
    for (int i = 0; i<self.updatedProjects.count; i++) {
        if([projectid isEqualToString:((KBNProject*)[self.updatedProjects objectAtIndex:i]).projectId ]){
            return i;
        }
    }
    return -1;
}
@end
