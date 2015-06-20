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
                                                   NSString* user = [[((NSDictionary *)snapshot.value) objectForKey:FIREBASE_PROJECT] objectForKey:@"User"];
                                                   
                                                   if (![user isEqualToString:[KBNUserUtils getUsername]]) {
                                                       NSString *projectChange = [[((NSDictionary *) snapshot.value) objectForKey:FIREBASE_PROJECT] objectForKey:FIREBASE_TYPE_OF_CHANGE];
                                                       if ([self isProjectChangeValid:projectChange]) {
                                                           [self updateProject];
                                                       }
                                                   } else {
                                                       // Delete node from firebase after receiving notification
                                                       [snapshot.ref setValue:nil];
                                                   }
                                               }
                                           }];
    }
}

- (void)updateProject {
    
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

- (BOOL)isProjectChangeValid:(NSString*)typeOfChange {
    return [typeOfChange isEqualToString:FIREBASE_PROJECT_CHANGE];
}

@end