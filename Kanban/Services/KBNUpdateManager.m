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
            inst.projectService = [KBNProjectService sharedInstance];
            inst.tasksService = [KBNTaskService sharedInstance];
        }
    }
    return inst;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)startUpdatingProjects{
    if (!self.projectTimer) {
        [self.projectService getProjectsForUser:[KBNUserUtils getUsername]
                                                onSuccessBlock:^(NSArray *records) {
                                                    
                                                    self.lastProjectsUpdate =[NSDate getUTCNowWithParseFormat];
                                                    [self postNotification:KBNProjectsInitialUpdate withObject:records];
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
    
    [self.tasksService getTasksForProject:project.projectId
                                        completionBlock:^(NSDictionary *records) {
                                            
                                            [self postNotification:KBNTasksInitialUpdate withObject:[records objectForKey:@"results"]];
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
    [self.taskTimer invalidate];
    
}

-(void)stopUpdatingTasks{
    self.shouldUpdateTasks= NO;
    [self.taskTimer invalidate];
    
}

-(void)updateProjects{
    
    if (self.shouldUpdateProjects) {
        [self.projectService getProjectsForUser:[KBNUserUtils getUsername]
                                                 updatedAfter:self.lastProjectsUpdate
                                               onSuccessBlock:^(NSArray *records) {
                                                   if (records.count>0) {
                                                       
                                                       [self postNotification:KBNProjectsUpdated withObject:records];
                                                   }
                                                   for (KBNProject *project in records) {
                                                       
                                                       //if we update the current project we notify
                                                       if ([project.projectId isEqualToString:self.projectForTasksUpdate.projectId]) {
                                                           self.projectForTasksUpdate= project;
                                                           [self postNotification:KBNCurrentProjectUpdated withObject:project];
                                                       }
                                                       
                                                       
                                                   }
                                                   self.lastTasksUpdate = [NSDate getUTCNowWithParseFormat];
                                               }
                                                   errorBlock:^(NSError *error) {
                                                       
                                                   }];
    }
}

-(void)updateTasks{
    if (self.shouldUpdateTasks) {
        
        [self.tasksService getUpdatedTasksForProject:self.projectForTasksUpdate.projectId
                                                  withModifiedDate:self.lastTasksUpdate
                                                   completionBlock:^(NSDictionary *records) {
                                                       NSDictionary * results=[records objectForKey:@"results"];
                                                       if(results.count > 0 ){
                                                           
                                                           [self postNotification:KBNTasksUpdated withObject:results];
                                                       }
                                                       self.lastTasksUpdate = [NSDate getUTCNowWithParseFormat];
                                                       
                                                   }
                                                        errorBlock:^(NSError *error) {
                                                            
                                                        }];
    }
}

- (void)postNotification:(NSString *)notificationName withObject:(id)object
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:object];
}

- (void)dealloc
{
    
}
@end
