//
//  KBNProjectService.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/20/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectService.h"

@implementation KBNProjectService

//This method is because KBNProxy is a Singleton
+(KBNProjectService *) sharedInstance{
    
    static  KBNProjectService *inst = nil;
    
    @synchronized(self){
        if (!inst) {
            inst = [[self alloc] init];
            inst.dataService = [[KBNProjectParseAPIManager alloc]init];
        }
    }
    return inst;
}

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}


-(void)createProject:(NSString*)name withDescription:(NSString*)projectDescription forUser:(NSString*) username completionBlock:(KBNConnectionSuccessProjectBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    if ([name isEqualToString:@""] || !name) {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": CREATING_PROJECT_WITHOUTNAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-102
                                            userInfo:info];
        onError(errorPtr);
    }else{
        KBNProject *project = [[KBNProject alloc]initWithEntity:[NSEntityDescription entityForName:ENTITY_PROJECT inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        project.name = name;
        project.projectDescription = projectDescription;
        project.users = [NSMutableArray new];
        [project.users addObject:username];
        
        [self.dataService createProject:project completionBlock:^(KBNProject *newProject) {
            onCompletion(newProject);
        } errorBlock:onError];
    }
}

-(void)editProject: (NSString*)projectID withNewName:(NSString*)newName withDescription:(NSString*)newDescription completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    if ([projectID isEqualToString:@""] || [newName isEqualToString:@""] ) {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": EDIT_PROJECT_WITHOUTNAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-102
                                            userInfo:info];
        onError(errorPtr);
    }else{
        [self.dataService editProject:projectID withNewName:newName withNewDesc:newDescription completionBlock:onCompletion errorBlock:onError];
    }
}


-(void)removeProject:(KBNProject*)project completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    
    project.active = @NO;
    [self.dataService updateProjects:@[project] completionBlock:onCompletion errorBlock:onError];
    
}

-(KBNProject*) getProjectWithName: (NSString*)name errorBlock:(KBNConnectionErrorBlock)onError{
    return nil;
}

-(void)getProjectsForUser: (NSString*) username onSuccessBlock:(KBNConnectionSuccessArrayBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    
    __weak typeof(self) weakself = self;
    
    [self.dataService getProjectsFromUsername:username onSuccessBlock:^(NSDictionary *records) {
        NSMutableArray *projectsArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary* item in records) {
            KBNProject *newProject = [[KBNProject alloc] initWithEntity:[NSEntityDescription entityForName:ENTITY_PROJECT
                                                                                    inManagedObjectContext:weakself.managedObjectContext]
                                         insertIntoManagedObjectContext:weakself.managedObjectContext];
            
            newProject.projectId = [item objectForKey:PARSE_OBJECTID];
            newProject.name = [item objectForKey:PARSE_PROJECT_NAME_COLUMN];
            newProject.projectDescription = [item objectForKey:PARSE_PROJECT_DESCRIPTION_COLUMN];
            newProject.projectId = [item objectForKey:PARSE_OBJECTID];
            newProject.active = [item objectForKey:PARSE_TASK_ACTIVE_COLUMN];
            newProject.users = [NSMutableArray new];
            [newProject.users addObject:[item objectForKey:PARSE_PROJECT_USER_COLUMN]];
            
            if ([newProject isActive]) {
                [projectsArray addObject:newProject];
            }
        }
        onCompletion(projectsArray);
    } errorBlock:onError];
}

-(void)getProjectsForUser: (NSString*) username updatedAfter:(NSString*) lastUpdate  onSuccessBlock:(KBNConnectionSuccessArrayBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    
    __weak typeof(self) weakself = self;
    
    [self.dataService getProjectsFromUsername:username updatedAfter:lastUpdate onSuccessBlock:^(NSDictionary *records) {
        NSMutableArray *projectsArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary* item in records) {
            KBNProject *newProject = [[KBNProject alloc] initWithEntity:[NSEntityDescription entityForName:ENTITY_PROJECT
                                                                                    inManagedObjectContext:weakself.managedObjectContext]
                                         insertIntoManagedObjectContext:weakself.managedObjectContext];
            
            newProject.projectId = [item objectForKey:PARSE_OBJECTID];
            newProject.name = [item objectForKey:PARSE_PROJECT_NAME_COLUMN];
            newProject.projectDescription = [item objectForKey:PARSE_PROJECT_DESCRIPTION_COLUMN];
            newProject.projectId = [item objectForKey:PARSE_OBJECTID];
            newProject.active = [item objectForKey:PARSE_TASK_ACTIVE_COLUMN];
            newProject.users = [NSMutableArray new];
            [newProject.users addObject:[item objectForKey:PARSE_PROJECT_USER_COLUMN]];
            
            if ([newProject isActive]) {
                [projectsArray addObject:newProject];
            }
        }
        onCompletion(projectsArray);
    } errorBlock:onError];
    
    
}

@end
