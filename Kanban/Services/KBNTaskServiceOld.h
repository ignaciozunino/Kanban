//
//  KBNTaskService.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/22/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "AFNetworking.h"
#import "KBNTask.h"
#import "KBNProject.h"
#import "KBNTaskList.h"

typedef void(^Success)(AFHTTPRequestOperation *operation, id responseObject);
typedef void(^Failure)(AFHTTPRequestOperation *operation, NSError *error);

@interface KBNTaskServiceOld : AFHTTPRequestOperationManager

+ (instancetype)sharedInstance;

- (void)createTask:(KBNTask*)task success:(Success)success failure:(Failure)failure;
- (void)moveTask:(KBNTask*)task toList:(KBNTaskList*)list success:(Success)success failure:(Failure)failure;
- (void)getTasksOnSuccess:(Success)success failure:(Failure)failure;
- (void)getTasksForProject:(KBNProject*)project success:(Success)success failure:(Failure)failure;
- (void)getProjectsOnSuccess:(Success)success failure:(Failure)failure;
- (void)getTaskListsOnSuccess:(Success)success failure:(Failure)failure;

@end
