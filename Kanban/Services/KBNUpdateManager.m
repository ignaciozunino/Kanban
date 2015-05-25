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
            NSString * urlString = [[NSString alloc] initWithFormat:@"%@/%@", FIREBASE_BASE_URL,[KBNUserUtils getUsernameForURL]];
            inst.fireBaseRootReference =[[Firebase alloc] initWithUrl:urlString];
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
                                 [self startListening];
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
                              [self startListening];
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

- (void)postNotification:(NSString *)notificationName withObject:(id)object
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:object];
}

- (void) startListening
{
    if (! self.listeningToFirebase) {//if we are not listening start listen
        self.listeningToFirebase = YES;
        [self.fireBaseRootReference observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSDictionary * projectChanges = [((NSDictionary *) snapshot.value) objectForKey:FIREBASE_PROJECT];
            NSDictionary * taskChanges = [((NSDictionary *) snapshot.value) objectForKey:FIREBASE_TASK];
            NSString *projectType =[projectChanges objectForKey:FIREBASE_TYPE_OF_CHANGE];
            NSString *taskType =[taskChanges objectForKey:FIREBASE_TYPE_OF_CHANGE];
            if ([projectType isEqualToString:FIREBASE_PROJECT_CHANGE]) {
                [self updateProjects];
            }
            if ([taskType isEqualToString:FIREBASE_TASK_CHANGE]){
                [self updateTasks];
            }
        }];
    }
}

- (void)dealloc
{
    
}

@end