//
//  KBNUpdateManager.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNUpdateManager.h"
#import "KBNAlertUtils.h"

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
            inst.fireBaseRootReference =[[Firebase alloc] initWithUrl:FIREBASE_BASE_URL];
        }
    }
    return inst;
}

-(void)startUpdatingProjects{
    __weak typeof(self) weakself = self;
    [[KBNProjectService sharedInstance] getProjectsOnSuccessBlock:^(NSArray *records) {
        weakself.shouldUpdateProjects = YES;
        [weakself startListeningProjects:records];
    }
                                                       errorBlock:^(NSError *error) {
                                                       }];
}

-(void)startUpdatingTasksForProject:(KBNProject*)project{
    self.projectForTasksUpdate = project;
    __weak typeof(self) weakself = self;
    [[KBNTaskService sharedInstance] getTasksForProject:project
                                        completionBlock:^(NSArray *records) {
                                            weakself.shouldUpdateTasks = YES;
                                            //we suppose to be listening but we try just in case
                                            [weakself startListeningTasks:records];
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
        [[KBNProjectService sharedInstance] getProjectsOnSuccessBlock:^(NSArray *records) {
            if (records.count > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KBNProjectsUpdated object:records];
            }
            for (KBNProject *project in records) {
                //if we update the current project we notify
                if ([project.projectId isEqualToString:self.projectForTasksUpdate.projectId]) {
                    self.projectForTasksUpdate= project;
                    [[NSNotificationCenter defaultCenter] postNotificationName:KBNCurrentProjectUpdated object:project];
                }
            }
        }
                                                           errorBlock:^(NSError *error) {
                                                               
                                                           }];
    }
}

-(void)updateTasks{
    if (self.shouldUpdateTasks) {
        [[KBNTaskService sharedInstance] getTasksForProject:self.projectForTasksUpdate
                                            completionBlock:^(NSArray *records) {
                                                // TODO
                                                [[NSNotificationCenter defaultCenter] postNotificationName:KBNTasksUpdated object:records];
                                            }
                                                 errorBlock:^(NSError *error) {
                                                     
                                                 }];
    }
}

- (void) startListeningProjects: (NSArray*) projects {
    for (KBNProject* project in projects) {
        self.fireBaseRootReference =[[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@", FIREBASE_BASE_URL, project.projectId]];
        [self.fireBaseRootReference observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSString* user = [[((NSDictionary *) snapshot.value) objectForKey:FIREBASE_PROJECT] objectForKey:@"User"];
            if (![user isEqualToString:[KBNUserUtils getUsername]]) {
                NSString * projectChange = [[((NSDictionary *) snapshot.value) objectForKey:FIREBASE_PROJECT] objectForKey:FIREBASE_TYPE_OF_CHANGE];
                if ([self isProjectChangeValid:projectChange]) {
                    [self updateProjects];
                }
            }
            NSString * projectName = [[((NSDictionary *) snapshot.value) objectForKey:FIREBASE_PROJECT] objectForKey:FIREBASE_EDIT_NAME_CHANGE];
            NSString * projectDesc = [[((NSDictionary *) snapshot.value) objectForKey:FIREBASE_PROJECT] objectForKey:FIREBASE_EDIT_DESC_CHANGE];
            if (projectName) {
                project.name = projectName;
                project.projectDescription = projectDesc;
                [[NSNotificationCenter defaultCenter] postNotificationName:KBNProjectUpdate object:project];
            }
        }];
    }
}

- (void)startListeningTasks:(NSArray*)tasks {
    for (NSMutableDictionary* task in tasks) {
        self.fireBaseRootReference =[[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@", FIREBASE_BASE_URL,[task objectForKey:PARSE_TASK_PROJECT_COLUMN]]];
        [self.fireBaseRootReference observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSString* user = [[((NSDictionary *) snapshot.value) objectForKey:FIREBASE_TASK] objectForKey:@"User"];
            if (![user isEqualToString:[KBNUserUtils getUsername]]) {
                NSString * taskChange = [[((NSDictionary *) snapshot.value) objectForKey:FIREBASE_TASK] objectForKey:FIREBASE_TYPE_OF_CHANGE];
                if ([self isTaskChangeValid:taskChange]) {
                    [self updateTasks];
                }
            }
            NSString * taskEdit = [[((NSDictionary *) snapshot.value) objectForKey:FIREBASE_TASK] objectForKey:FIREBASE_EDIT_NAME_CHANGE];
            NSString * taskDesc = [[((NSDictionary *) snapshot.value) objectForKey:FIREBASE_TASK] objectForKey:FIREBASE_EDIT_DESC_CHANGE];
            if (taskEdit) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KBNTasksUpdated
                                                                    object:@{PARSE_TASK_NAME_COLUMN:taskEdit,
                                                                             PARSE_TASK_DESCRIPTION_COLUMN:taskDesc,
                                                                             PARSE_OBJECTID:[task objectForKey:PARSE_OBJECTID]}];
            }
        }];
    }
}

- (BOOL)isTaskChangeValid:(NSString*)typeOfChange {
    return [typeOfChange isEqualToString:FIREBASE_TASK_ADD] || [typeOfChange isEqualToString:FIREBASE_TASK_CHANGE] || [typeOfChange isEqualToString:FIREBASE_TASK_REMOVE];
}

- (BOOL)isProjectChangeValid:(NSString*)typeOfChange {
    return [typeOfChange isEqualToString:FIREBASE_PROJECT_ADD] || [typeOfChange isEqualToString:FIREBASE_PROJECT_CHANGE] || [typeOfChange isEqualToString:FIREBASE_PROJECT_REMOVE];
}

@end