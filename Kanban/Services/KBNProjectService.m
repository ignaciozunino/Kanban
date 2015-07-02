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
            inst.fireBaseRootReference = [[Firebase alloc] initWithUrl:FIREBASE_BASE_URL];
        }
    }
    return inst;
}

- (void)createProject:(NSString *)name withDescription:(NSString *)projectDescription withTemplate:(KBNProjectTemplate *)projectTemplate completionBlock:(KBNSuccessProjectBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    if ([name isEqualToString:@""] || !name) {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{NSLocalizedDescriptionKey: CREATING_PROJECT_WITHOUTNAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-102
                                            userInfo:info];
        onError(errorPtr);
    }else{
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
        [params setObject:name forKey:PARSE_PROJECT_NAME_COLUMN];
        [params setObject:projectDescription forKey:PARSE_PROJECT_DESCRIPTION_COLUMN];
        [params setObject:[NSNumber numberWithBool:YES] forKey:PARSE_PROJECT_ACTIVE_COLUMN];
        [params setObject:[NSArray arrayWithObject:[KBNUserUtils getUsername]] forKey:PARSE_PROJECT_USERSLIST_COLUMN];
        
        KBNProject *project = [KBNProjectUtils projectWithParams:params];
        
        NSArray *lists = (NSArray*)projectTemplate.lists;
        NSMutableArray *taskLists = [NSMutableArray array];
        
        for (int i = 0; i < lists.count; i++) {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
            [params setObject:[projectTemplate.lists objectAtIndex:i] forKey:PARSE_TASKLIST_NAME_COLUMN];
            [params setObject:[NSNumber numberWithInt:i] forKey:PARSE_TASKLIST_ORDER_COLUMN];
            
            KBNTaskList *list = [KBNTaskListUtils taskListForProject:project params:params];
            [taskLists addObject:list];
        }
        
        project.taskLists = [NSOrderedSet orderedSetWithArray:taskLists];
        // Project object creation completed. Save context.
        [[KBNCoreDataManager sharedInstance] saveContext];
        
        [self.dataService createProject:project withLists:lists completionBlock:^(NSDictionary *records) {
            NSDictionary *projectParams = [records objectForKey:@"project"];
            project.projectId = [projectParams objectForKey:@"projectId"];
            project.updatedAt = [projectParams objectForKey:@"updatedAt"];
            project.synchronized = [NSNumber numberWithBool:YES];
            
            NSArray *listsParams = [records objectForKey:@"taskLists"];
            KBNTaskList *taskList = nil;
            NSUInteger index = 0;
            for (NSDictionary *params in listsParams) {
                taskList = [project.taskLists objectAtIndex:index];
                taskList.taskListId = [params objectForKey:@"taskListId"];
                taskList.updatedAt = [params objectForKey:@"updatedAt"];
                taskList.synchronized = [NSNumber numberWithBool:YES];
                index++;
             }
             
            [[KBNCoreDataManager sharedInstance] saveContext];
            onCompletion(project);
        } errorBlock:onError];
    }
}

- (void)editProject:(KBNProject*)project withNewName:(NSString*)newName withDescription:(NSString*)newDescription completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    if ([project.projectId isEqualToString:@""] || [newName isEqualToString:@""] ) {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{NSLocalizedDescriptionKey: EDIT_PROJECT_WITHOUTNAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-102
                                            userInfo:info];
        onError(errorPtr);
    }else{
        project.name = newName;
        project.projectDescription = newDescription;
        [[KBNCoreDataManager sharedInstance] saveContext];
        
        __weak typeof(self) weakself = self;
        [self.dataService editProject:project.projectId withNewName:newName withNewDesc:newDescription completionBlock:^{
            project.name = newName;
            project.projectDescription = newDescription;
            // If the project has more than one user, notify change
            if ([project isShared]) {
                [KBNUpdateUtils postToFirebase:weakself.fireBaseRootReference changeType:KBNChangeTypeProjectUpdate projectId:project.projectId data:[KBNProjectUtils projectsJson:@[project]]];
            }
            onCompletion();
        } errorBlock:onError];
    }
}


//Adds a email address to the participants list of a given project.
- (void)addUser:(NSString*)emailAddress toProject:(KBNProject*)aProject completionBlock:(KBNSuccessBlock)onSuccess errorBlock:(KBNErrorBlock)onError {
    
    if ([aProject.projectId isEqualToString:@""])
    {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{NSLocalizedDescriptionKey: EDIT_PROJECT_WITHOUTNAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-102
                                            userInfo:info];
        onError(errorPtr);
    }
    else
    {
        if (![self project:aProject hasUser:emailAddress])
        {
            __weak typeof(self) weakself = self;
            //Add the user email at the top
            NSMutableArray* usersMutableArray = [[NSMutableArray alloc]init];
            [usersMutableArray addObject:emailAddress];
            [usersMutableArray addObjectsFromArray:aProject.users];
            
            NSArray* newUsersArray = [NSArray arrayWithArray:usersMutableArray];
            [self.dataService setUsersList:newUsersArray toProjectId:aProject.projectId completionBlock:^(){
                aProject.users = newUsersArray;
                // As we are adding a new user, project is shared
                [KBNUpdateUtils postToFirebase:weakself.fireBaseRootReference changeType:KBNChangeTypeProjectUpdate projectId:aProject.projectId data:[KBNProjectUtils projectsJson:@[aProject]]];
                
                onSuccess();
            } errorBlock:onError];
        }
        else
        {
            NSDictionary * info = @{NSLocalizedDescriptionKey: INVITE_USERS_USER_EXISTS_ERROR};
            NSString* domain = ERROR_DOMAIN;
            NSError *errorPtr = [NSError errorWithDomain:domain code:-108 userInfo:info];
            onError(errorPtr);
            
        }
    }
}

-(BOOL)project:(KBNProject*)project hasUser:(NSString*)emailAddress{
    BOOL result = NO;
    NSArray* projectUsers = (NSArray*)project.users;
    for (NSString* emailAddressInArray in projectUsers) {
        if ([emailAddressInArray isEqualToString:emailAddress]){
            result = YES;
            break;
        }
    }
    return result;
}

- (void)removeProject:(KBNProject*)project completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError{
    project.active = @NO;
    __weak typeof(self) weakself = self;
    [self.dataService updateProjects:@[project] completionBlock:^{
        // If the project has more than one user, notify change
        if ([project isShared]) {
            [KBNUpdateUtils postToFirebase:weakself.fireBaseRootReference changeType:KBNChangeTypeProjectUpdate projectId:project.projectId data:[KBNProjectUtils projectsJson:@[project]]];
        }
        onCompletion();
    } errorBlock:onError];
}

- (void)getProjectsOnSuccessBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    [[KBNCoreDataManager sharedInstance] getProjectsOnSuccess:^(NSArray *records) {
        onCompletion(records);
    } errorBlock:onError];
    
    [self.dataService getProjectsFromUsername:[KBNUserUtils getUsername] onSuccessBlock:^(NSDictionary *records) {
        // Get the projects array from the response dictionary and pass it around
        NSArray *results = [KBNProjectUtils projectsFromDictionary:records key:@"results"];
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_PROJECTS object:results];
        
        // Any change in projects has already been changed in context.
        // Mark projects as synchronized and update context.
        for (KBNProject *project in results) {
            if (!project.isSynchronized) {
                project.synchronized = [NSNumber numberWithBool:YES];
            }
        }
        [[KBNCoreDataManager sharedInstance] saveContext];
    } errorBlock:^(NSError *error) {
    }];

}

@end
