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
@property (nonatomic,unsafe_unretained) BOOL listeningToFirebase;
@property NSString * lastTasksUpdate;

@end

@implementation KBNUpdateManager

+ (KBNUpdateManager *)sharedInstance{
    static  KBNUpdateManager *inst = nil;
    
    @synchronized(self){
        if (!inst) {
            inst = [[KBNUpdateManager alloc] init];
            inst.projectService = [KBNProjectService sharedInstance];
            inst.tasksService = [KBNTaskService sharedInstance];
            inst.fireBaseRootReference =[[Firebase alloc] initWithUrl:FIREBASE_BASE_URL];
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
    [self.projectService getProjectsForUser:[KBNUserUtils getUsername]
                             onSuccessBlock:^(NSArray *records) {
                                 self.lastProjectsUpdate =[NSDate getUTCNowWithParseFormat];
                                 [self postNotification:KBNProjectsInitialUpdate withObject:records];
                                 self.shouldUpdateProjects = YES;
                                 [self startListeningProjects:records];
                             }
                                 errorBlock:^(NSError *error) {
                                     
                                 }];
}

-(void)startUpdatingTasksForProject:(KBNProject*)project{
    self.projectForTasksUpdate =project;
    
    [self.tasksService getTasksForProject:project.projectId
                          completionBlock:^(NSDictionary *records) {
                              
                              [self postNotification:KBNTasksInitialUpdate withObject:[records objectForKey:@"results"]];
                              self.lastTasksUpdate = [NSDate getUTCNowWithParseFormat];
                              self.shouldUpdateTasks = YES;
                              ///we supouse to be listening but we try just in case
                              [self startListeningTasks:[records objectForKey:@"results"]];
                          }
                               errorBlock:^(NSError *error) {
                                   
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
                                             self.lastTasksUpdate = [NSDate getUTCNowWithParseFormat];
                                         }
                                     }
                                          errorBlock:^(NSError *error) {
                                              
                                          }];
    }
}

- (void)postNotification:(NSString *)notificationName withObject:(id)object {
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:object];
}

- (void) startListeningProjects: (NSArray*) projects {
    for (KBNProject* project in projects) {
        self.fireBaseRootReference =[[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@", FIREBASE_BASE_URL, project.projectId]];
        [self.fireBaseRootReference observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {

            NSString * projectChange = [[((NSDictionary *) snapshot.value) objectForKey:FIREBASE_PROJECT] objectForKey:FIREBASE_TYPE_OF_CHANGE];
            NSString * projectEdit = [[((NSDictionary *) snapshot.value) objectForKey:FIREBASE_PROJECT] objectForKey:FIREBASE_EDIT_NAME_CHANGE];
            if ([self isProjectChangeValid:projectChange]) {
                [self updateProjects];
            }
            if (projectEdit) {
                project.name = projectEdit;
                [self postNotification:KBNProjectUpdate withObject:project];
            }
        }];
    }
}

- (void) startListeningTasks: (NSArray*) tasks {
    for (NSMutableDictionary* task in tasks) {
        self.fireBaseRootReference =[[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@", FIREBASE_BASE_URL,[task objectForKey:PARSE_TASK_PROJECT_COLUMN]]];
        [self.fireBaseRootReference observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            
            NSString * taskChange = [[((NSDictionary *) snapshot.value) objectForKey:FIREBASE_TASK] objectForKey:FIREBASE_TYPE_OF_CHANGE];
            NSString * taskEdit = [[((NSDictionary *) snapshot.value) objectForKey:FIREBASE_TASK] objectForKey:FIREBASE_EDIT_NAME_CHANGE];
            if ([self isTaskChangeValid:taskChange]) {
                [self updateTasks];
            }
            if (taskEdit) {
                [task setValue:taskEdit forKey:PARSE_TASK_NAME_COLUMN];
                [self postNotification:KBNTasksUpdated withObject:task];
            }
        }];
    }
}

-(BOOL) isTaskChangeValid: (NSString*) typeOfChange{
    return [typeOfChange isEqualToString:FIREBASE_TASK_ADD] || [typeOfChange isEqualToString:FIREBASE_TASK_CHANGE] || [typeOfChange isEqualToString:FIREBASE_TASK_REMOVE];
}

-(BOOL) isProjectChangeValid: (NSString*) typeOfChange{
    return [typeOfChange isEqualToString:FIREBASE_PROJECT_ADD] || [typeOfChange isEqualToString:FIREBASE_PROJECT_CHANGE] || [typeOfChange isEqualToString:FIREBASE_PROJECT_REMOVE];
}

- (void)dealloc
{
    
}

@end