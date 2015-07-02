//
//  KBNProjectParseAPIManager.m
//  Kanban
//
//  Created by Guillermo Apoj on 20/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectParseAPIManager.h"
#import "KBNTaskListService.h"
#import "NSDate+Utils.h"

@implementation KBNProjectParseAPIManager

-(instancetype) init{
    
    self = [super init];
    self.afManager = [[KBNParseRequestOperationManager alloc]init];
    
    return self;
}

#pragma mark - Project Methods

- (void)createProject:(KBNProject*)project withLists:(NSArray*)lists completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    NSArray *projectUsers = (NSArray*)project.users;
    NSString *username = [projectUsers firstObject];
    
    __block NSArray *listNames = lists;
    __block NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSDictionary *data = @{PARSE_PROJECT_NAME_COLUMN: project.name, PARSE_PROJECT_DESCRIPTION_COLUMN: project.projectDescription, PARSE_PROJECT_USER_COLUMN: username, PARSE_PROJECT_ACTIVE_COLUMN: [NSNumber numberWithBool:YES],PARSE_PROJECT_USERSLIST_COLUMN:projectUsers};
    
    [self.afManager POST:PARSE_PROJECTS parameters: data
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSString *projectId = [responseObject objectForKey:PARSE_OBJECTID];
                     NSDate *updatedAt = [NSDate dateFromParseString:[responseObject objectForKey:PARSE_CREATED_COLUMN]];
                     NSDictionary *projectParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    projectId, @"projectId",
                                                    updatedAt, @"updatedAt", nil];
                     [info setObject:projectParams forKey:@"project"];
                     
                     if (!lists) {
                         listNames = @[];
                     }
                     
                     [[[KBNTaskListParseAPIManager alloc] init] createTaskLists:listNames forProject:projectId onCompletion:^(NSArray *records) {
                         [info setObject:records forKey:@"taskLists"];
                         onCompletion(info);
                         
                     } onError:onError];
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
