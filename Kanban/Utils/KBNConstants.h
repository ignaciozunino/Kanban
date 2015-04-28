//
//  Constants.h
//  Kanban
//
//  Created by Nicolas Alejandro Porpiglia on 4/15/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>

//Parse constants
#define PARSE_APP_ID        @"2LDJ8L7aB9iO9QTGyG4UxGjUSFxxTCUFxM05nOJx"
#define PARSE_CLIENT_ID     @"3ChxbtSTeoblQgtu5bNZCw1v6L158u2eGsiYuvrs"
#define PARSE_REST_API_KEY @"oiD6BSxTMx8xKjyZFgP6S4IHmHsybxLF1DKGtuTm"

//Project constants
#define USERNAME_KEY @"username"
#define MAIN_STORYBOARD @"Main"
#define SIGNIN_STORYBOARD @"Signin"
#define RESOURCE_NAME_PROJECTS @"projects"

//Entities
#define ENTITY_TASK @"KBNTask"
#define ENTITY_PROJECT @"KBNProject"
#define ENTITY_TASK_LIST @"KBNTaskList"

//View controllers identifiers
#define PROJECT_DETAIL_VC @"KBNProjectDetailViewController"
#define PAGE_VC @"KBNPageViewController"


//Succes messages
#define PROJECT_CREATION_SUCCESS @"Project created successfully!"

//Error messages
#define ERROR_DOMAIN @"globant.kanban.Kanban.ErrorDomain";
#define SIGNIN_ERROR @"Please verify the username is a valid email and the password has at least 6 characters, one letter and one number."
#define CREATING_PROJECT_WITHOUTNAME_ERROR @"Project must have a name"
#define CREATING_PROJECT_OFFLINE_ERROR @"The service is offline."
#define CREATING_TASK_WITHOUT_NAME_ERROR @"Task must have a name"
#define CREATING_TASKLIST_WITHOUT_NAME_ERROR @"Task List must have a name"

//URL
#define PARSE_USERS @"https://api.parse.com/1/users"
#define PARSE_PROJECTS @"https://api.parse.com/1/classes/Project"
#define PARSE_TASKLISTS @"https://api.parse.com/1/classes/TaskList"
#define PARSE_TASKS @"https://api.parse.com/1/classes/Task"

//PARSE TABLE COLUMNS
#define PARSE_OBJECTID @"objectId"

#define PARSE_TASKLIST_NAME_COLUMN @"name"
#define PARSE_TASKLIST_PROJECT_COLUMN @"project"
#define PARSE_TASKLIST_ORDER_COLUMN @"order"

#define PARSE_PROJECT_NAME_COLUMN @"name"
#define PARSE_PROJECT_DESCRIPTION_COLUMN @"project_description"

#define PARSE_TASK_NAME_COLUMN @"name"
#define PARSE_TASK_DESCRIPTION_COLUMN @"taskDescription"
#define PARSE_TASK_PROJECT_COLUMN @"project"
#define PARSE_TASK_TASK_LIST_COLUMN @"taskList"
#define PARSE_TASK_ORDER_COLUMN @"order"
#define PARSE_TASK_ACTIVE_COLUMN @"active"

//alert titles
#define ERROR_ALERT @"ERROR"
#define WARNING_ALERT @"WARNING"
#define SUCCESS_ALERT @"SUCCESS"

#define DEFAULT_TASK_LISTS   @[@"Backlog",@"Requirements",@"Implemented",@"Tested",@"Production"]

//Blocks 
typedef void (^KBNConnectionErrorBlock) (NSError *error);
typedef void (^KBNConnectionSuccessBlock)() ;
typedef void (^KBNConnectionSuccessDictionaryBlock)(NSDictionary* response);
@interface KBNConstants : NSObject

@end
