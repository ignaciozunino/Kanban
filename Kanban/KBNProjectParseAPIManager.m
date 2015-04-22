//
//  KBNProjectParseAPIManager.m
//  Kanban
//
//  Created by Guillermo Apoj on 20/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectParseAPIManager.h"



@implementation KBNProjectParseAPIManager
#pragma mark - project methods
+ (void)createTaskListWithIndex:(NSInteger)index projectID:(NSString *)projectID tasks:(NSArray *)tasks onError:(KBNParseErrorBlock)onError onCompletion:(KBNParseSuccesBlock)onCompletion manager:(AFHTTPRequestOperationManager *)manager {
    NSInteger nextIndex= index + 1;
    NSDictionary *taskdata = @{PARSE_TASKLIST_NAME_COLUMN: tasks[index], PARSE_TASKLIST_PROJECT_COLUMN: projectID,PARSE_TASKLIST_ORDER_COLUMN:[NSNumber numberWithInteger:index]};
    [manager POST:PARSE_TASKLISTS parameters:taskdata  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (nextIndex == tasks.count) {//if we are in the last task
            onCompletion();
        } else {
            NSInteger nextIndex= index +1;
            [self createTaskListWithIndex:nextIndex projectID:projectID tasks:tasks onError:onError onCompletion:onCompletion manager:manager];
        }
        
        
        ;}failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            onError(error);
        }];
}

+ (void)createTasksListForProject:(id)responseObject tasks:(NSArray *)tasks onError:(KBNParseErrorBlock)onError onCompletion:(KBNParseSuccesBlock)onCompletion manager:(AFHTTPRequestOperationManager *)manager {
    
    NSDictionary * item = responseObject;
    NSString *projectID=[item objectForKey:PARSE_OBJECTID];
    NSInteger initialIndex = 0;
    NSDictionary *taskdata = @{PARSE_TASKLIST_NAME_COLUMN: tasks[initialIndex], PARSE_TASKLIST_PROJECT_COLUMN: projectID,PARSE_TASKLIST_ORDER_COLUMN:[NSNumber numberWithInteger:initialIndex]};
    
    
    [manager POST:PARSE_TASKLISTS parameters:taskdata  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger nextIndex= initialIndex +1;
        [self createTaskListWithIndex:nextIndex projectID:projectID tasks:tasks onError:onError onCompletion:onCompletion manager:manager];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        onError(error);
    }];
}

+(void) createProject: (KBNProject *) project completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError{
    AFHTTPRequestOperationManager *manager = [self setupAFHTTPManager];
    NSDictionary *data = @{PARSE_PROJECT_NAME_COLUMN: project.name, PARSE_PROJECT_DESCRIPTION_COLUMN: project.projectDescription};
    [manager POST:PARSE_PROJECTS parameters: data
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"POST data JSON returned: %@", responseObject);
              NSArray * tasks = taskStates;
              
              [self createTasksListForProject:responseObject tasks:tasks onError:onError onCompletion:onCompletion manager:manager];
             
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              onError(error);
              NSLog(@"Error: %@", error);
          }
     ];
}

+(void) editProject: (NSString *)name newDescription:newDescription completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError{
    
}

+(void) removeProject: (NSString *)name completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError{
    
}

+(KBNProject*) getProjectWithName: (NSString*)name errorBlock:(KBNParseErrorBlock)onError{
    return nil;
}

+(NSArray*) getProjects:(KBNParseErrorBlock)onError{
    return nil;
}
@end
