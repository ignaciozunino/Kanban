//
//  KBNProjectParseAPIManager.m
//  Kanban
//
//  Created by Guillermo Apoj on 20/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectParseAPIManager.h"
#import "KBNTaskList.h"

@implementation KBNProjectParseAPIManager

-(instancetype) init{
    
    self = [super init];
    self.afManager = [[KBNParseRequestOperationManager alloc]init];
    
    return self;
}



#pragma mark - project methods


- (void)createTasksListForProject:(id)responseObject forProject:(KBNProject*) project lists:(NSArray*)lists onError:(KBNErrorBlock)onError onCompletion:(KBNSuccessProjectBlock)onCompletion manager:(AFHTTPRequestOperationManager *)manager {
    
    __block NSError *error = nil;
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    __block NSMutableArray *listIds = [NSMutableArray array];
    
    for (int i =0; i<lists.count; i++) {
        NSDictionary * item = responseObject;
        NSString *projectID=[item objectForKey:PARSE_OBJECTID];
        
        NSDictionary *listdata = @{PARSE_TASKLIST_NAME_COLUMN: lists[i], PARSE_TASKLIST_PROJECT_COLUMN: projectID,PARSE_TASKLIST_ORDER_COLUMN:[NSNumber numberWithInteger:i]};
        dispatch_group_enter(serviceGroup);

        [manager POST:PARSE_TASKLISTS parameters:listdata  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // As we don't know the order in which blocks are completed, we save the listId and the corresponding order too
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [responseObject objectForKey:PARSE_OBJECTID], @"listId",
                                  [NSNumber numberWithInt:i], @"order", nil];
            [listIds addObject:info];
            dispatch_group_leave(serviceGroup);
        } failure:^(AFHTTPRequestOperation *operation, NSError *errorParse) {
            error = errorParse;
            dispatch_group_leave(serviceGroup);
        }];
    }

    dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
        if (error) {
            onError(error);
        } else {
            KBNTaskList *taskList;
            for (NSDictionary *info in listIds) {
                NSUInteger index = [[info objectForKey:@"order"] integerValue];
                taskList = (KBNTaskList*)[project.taskLists objectAtIndex:index];
                taskList.taskListId = [info objectForKey:@"listId"];
            }
            onCompletion(project);
        }
    });
}

- (void) createProject: (KBNProject *) project completionBlock:(KBNSuccessProjectBlock)onCompletion errorBlock:(KBNErrorBlock)onError{
    
    NSArray *projectUsers = (NSArray*)project.users;
    NSString *username = [projectUsers firstObject];

    NSDictionary *data = @{PARSE_PROJECT_NAME_COLUMN: project.name, PARSE_PROJECT_DESCRIPTION_COLUMN: project.projectDescription, PARSE_PROJECT_USER_COLUMN: username, PARSE_PROJECT_ACTIVE_COLUMN: [NSNumber numberWithBool:YES],PARSE_PROJECT_USERSLIST_COLUMN:projectUsers};
    
    [self.afManager POST:PARSE_PROJECTS parameters: data
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     project.projectId = [responseObject objectForKey:PARSE_OBJECTID];
                     
                     NSArray *lists = DEFAULT_TASK_LISTS;
                     [self createTasksListForProject:responseObject forProject:project lists:lists onError:onError onCompletion:onCompletion manager:self.afManager];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     onError(error);
                     
                 }
     ];
}

- (void) createProject: (KBNProject *) project withLists:(NSArray*)lists completionBlock:(KBNSuccessProjectBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    NSArray *projectUsers = (NSArray*)project.users;
    NSString *username = [projectUsers firstObject];

    __block NSArray *listNames = lists;
    
    NSDictionary *data = @{PARSE_PROJECT_NAME_COLUMN: project.name, PARSE_PROJECT_DESCRIPTION_COLUMN: project.projectDescription, PARSE_PROJECT_USER_COLUMN: username, PARSE_PROJECT_ACTIVE_COLUMN: [NSNumber numberWithBool:YES],PARSE_PROJECT_USERSLIST_COLUMN:projectUsers};
    
    [self.afManager POST:PARSE_PROJECTS parameters: data
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     project.projectId = [responseObject objectForKey:PARSE_OBJECTID];
                     if (!lists) {
                         listNames = @[];
                     }
                     [self createTasksListForProject:responseObject forProject:project lists:listNames onError:onError onCompletion:onCompletion manager:self.afManager];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     onError(error);
                     
                 }
     ];
}

-(void)setUsersList:(NSArray*)emailAddresses
        toProjectId:(NSString*)aProjectId
    completionBlock:(KBNSuccessBlock)onSuccess
         errorBlock:(KBNErrorBlock)onError
{
    NSDictionary *data = @{PARSE_PROJECT_USERSLIST_COLUMN: emailAddresses};
    [self.afManager PUT:[NSString stringWithFormat:@"%@/%@", PARSE_PROJECTS, aProjectId]
             parameters:data
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    onSuccess();
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    onError(error);
                }];
}

- (void) editProject: (NSString*)projectID withNewName: (NSString*) newName withNewDesc: (NSString*) newDesc completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError{
    NSDictionary *data = @{PARSE_PROJECT_NAME_COLUMN: newName, PARSE_PROJECT_DESCRIPTION_COLUMN: newDesc};
    [self.afManager PUT:[NSString stringWithFormat:@"%@/%@", PARSE_PROJECTS, projectID]
             parameters:data
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    onCompletion();
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    onError(error);
                }];
}

-(void) getProjectWithProjectID: (NSString*)projectID successBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError{
    [self.afManager GET: [NSString stringWithFormat:@"%@/%@", PARSE_PROJECTS, projectID]
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSMutableArray *results = [NSMutableArray new];
                    [results addObject:responseObject];
                    onCompletion(results);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    onError(error);
                }];
}

- (void)getProjectsFromUsername:(NSString*) username onSuccessBlock:(KBNSuccessDictionaryBlock) onSuccess errorBlock:(KBNErrorBlock)onError{
    
    NSMutableDictionary *where = [NSMutableDictionary dictionaryWithCapacity:1];
    [where setObject:username forKey:PARSE_PROJECT_USERSLIST_COLUMN];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:@"-createdAt" forKey:@"order"];
    [params setObject:where forKey:@"where"];
    
    [self.afManager GET:PARSE_PROJECTS
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    onSuccess(responseObject);
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    onError(error);
                }];
}

- (void)getProjectsFromUsername:(NSString*) username updatedAfter:(NSString*) lastUpdate onSuccessBlock:(KBNSuccessDictionaryBlock) onSuccess errorBlock:(KBNErrorBlock)onError{
    
    NSMutableDictionary *where = [NSMutableDictionary dictionaryWithCapacity:2];
    NSMutableDictionary *whereGT = [NSMutableDictionary dictionaryWithCapacity:1];
    
    NSMutableDictionary *whereDate = [NSMutableDictionary dictionaryWithCapacity:2];
    [whereDate setObject:@"Date" forKey:@"__type"];
    [whereDate setObject:lastUpdate forKey:@"iso"];
    
    [whereGT setObject:whereDate forKey:@"$gt"];
    
    
    [where setObject:whereGT forKey:PARSE_TASK_UPDATED_COLUMN];
  
    [where setObject:username forKey:PARSE_PROJECT_USERSLIST_COLUMN];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:@"-createdAt" forKey:@"order"];
    [params setObject:where forKey:@"where"];
    
    [self.afManager GET:PARSE_PROJECTS
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSDictionary *projectList = [responseObject objectForKey:@"results"];
                    
                    onSuccess(projectList);
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    onError(error);
                }];


}

// This method will receive an array of projects to update
- (void)updateProjects:(NSArray *)projects completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    NSMutableArray *requests = [[NSMutableArray alloc] init];
    NSMutableDictionary *record;
    
    for (KBNProject *project in projects) {
        NSString *username = (NSString*)project.users;
        NSArray* projectUsers = [NSArray arrayWithObject:username];
        
        NSMutableDictionary *updates = [NSMutableDictionary dictionaryWithCapacity:5];
        [updates setObject:project.name forKey:PARSE_PROJECT_NAME_COLUMN];
        [updates setObject:project.projectDescription forKey:PARSE_PROJECT_DESCRIPTION_COLUMN];
        [updates setObject:[NSNumber numberWithBool:[project.active boolValue]] forKey:PARSE_PROJECT_ACTIVE_COLUMN];
        [updates setObject:username forKey:PARSE_PROJECT_USER_COLUMN];
        [updates setObject:projectUsers forKey:PARSE_PROJECT_USERSLIST_COLUMN];
        
        record = [NSMutableDictionary dictionaryWithCapacity:3];
        [record setObject:@"PUT" forKey:@"method"];
        [record setObject:[NSString stringWithFormat:@"/1/classes/Project/%@", project.projectId] forKey:@"path"];
        [record setObject:updates forKey:@"body"];
        
        [requests addObject:record];
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:requests, @"requests", nil];
    
    [self.afManager POST:PARSE_BATCH
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject){
                     onCompletion(responseObject);
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     onError(error);
                 }];
}

@end
