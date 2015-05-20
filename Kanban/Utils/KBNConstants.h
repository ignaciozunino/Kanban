//
//  Constants.h
//  Kanban
//
//  Created by Nicolas Alejandro Porpiglia on 4/15/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNProject.h"
//Parse constants





#ifdef DEBUG
  //Development environment values
  #define PARSE_APP_ID        @"2LDJ8L7aB9iO9QTGyG4UxGjUSFxxTCUFxM05nOJx"
  #define PARSE_CLIENT_ID     @"3ChxbtSTeoblQgtu5bNZCw1v6L158u2eGsiYuvrs"
  #define PARSE_REST_API_KEY @"oiD6BSxTMx8xKjyZFgP6S4IHmHsybxLF1DKGtuTm"
#else
  //Production environment values
  #define PARSE_APP_ID        @"64CkJJ6FLtZ3Tnl8VE7cSUDiazsBxgPHNKNCHopP"
  #define PARSE_CLIENT_ID     @"ByBaCQtSmmeVh4s1bCUywJ8qTcSGUlkly4TBZnJg"
  #define PARSE_REST_API_KEY  @"HeXimJkf3NQAfbehujVPcvNiBP40HtKMyPiVp4Bf"
#endif

//Project constants
#define USERNAME_KEY @"username"
#define MAIN_STORYBOARD @"Main"
#define SIGNIN_STORYBOARD @"Signin"
#define RESOURCE_NAME_PROJECTS @"projects"

//Limits and thresholds
#define LIMIT_TASKLIST_ITEMS 50

//Entities
#define ENTITY_TASK @"KBNTask"
#define ENTITY_PROJECT @"KBNProject"
#define ENTITY_TASK_LIST @"KBNTaskList"

//View controllers identifiers
#define PROJECT_DETAIL_VC @"KBNProjectDetailViewController"
#define PAGE_VC @"KBNPageViewController"


//Succes messages
#define PROJECT_CREATION_SUCCESS @"Project created successfully!"
#define PROJECT_EDIT_SUCCESS @"Project modified successfully!"
#define TASK_EDIT_SUCCESS @"Task modified successfully!"
//Error messages
#define ERROR_DOMAIN @"globant.kanban.Kanban.ErrorDomain";
#define SIGNIN_ERROR @"Please verify the username is a valid email and the password has at least 6 characters, one letter and one number."
#define CREATING_PROJECT_WITHOUTNAME_ERROR @"Project must have a name"
#define CREATING_PROJECT_OFFLINE_ERROR @"The service is offline."
#define CREATING_TASK_WITHOUT_NAME_ERROR @"Task must have a name"
#define CREATING_TASKLIST_WITHOUT_NAME_ERROR @"Task List must have a name"
#define CREATING_TASK_OFFLINE_ERROR @"The connection to the server has timed out"
#define CREATING_TASK_TASKLIST_FULL @"The task list cannot hold any more items"
#define EDIT_PROJECT_WITHOUTNAME_ERROR @"Project must have a name"
#define USER_EXISTS_ERROR @"There is already a user created with that username, please try other username."
#define EDIT_TASK_WITHOUTNAME_ERROR @"Task must have a name"
//URL
#define PARSE_USERS @"https://api.parse.com/1/users"
#define PARSE_PROJECTS @"https://api.parse.com/1/classes/Project"
#define PARSE_TASKLISTS @"https://api.parse.com/1/classes/TaskList"
#define PARSE_TASKS @"https://api.parse.com/1/classes/Task"
#define PARSE_BATCH @"https://api.parse.com/1/batch"

//PARSE TABLE COLUMNS
#define PARSE_OBJECTID @"objectId"

#define PARSE_TASKLIST_NAME_COLUMN @"name"
#define PARSE_TASKLIST_PROJECT_COLUMN @"project"
#define PARSE_TASKLIST_ORDER_COLUMN @"order"

#define PARSE_PROJECT_NAME_COLUMN @"name"
#define PARSE_PROJECT_DESCRIPTION_COLUMN @"project_description"
#define PARSE_PROJECT_USER_COLUMN @"userName"
#define PARSE_PROJECT_USERSLIST_COLUMN @"usersList"
#define PARSE_PROJECT_ACTIVE_COLUMN @"active"

#define PARSE_TASK_NAME_COLUMN @"name"
#define PARSE_TASK_DESCRIPTION_COLUMN @"taskDescription"
#define PARSE_TASK_PROJECT_COLUMN @"project"
#define PARSE_TASK_TASK_LIST_COLUMN @"taskList"
#define PARSE_TASK_ORDER_COLUMN @"order"
#define PARSE_TASK_ACTIVE_COLUMN @"active"
#define PARSE_TASK_UPDATED_COLUMN @"updatedAt"


#define PARSE_USER_NAME_COLUMN @"username"


//alert titles
#define ERROR_ALERT @"ERROR"
#define WARNING_ALERT @"WARNING"
#define SUCCESS_ALERT @"SUCCESS"
#define CANCEL_TITLE @"Cancel"
#define DELETE_TITLE @"Delete"


#define DEFAULT_TASK_LISTS   @[@"Backlog",@"Requirements",@"Implemented",@"Tested",@"Production"]

//Blocks 
typedef void (^KBNConnectionErrorBlock) (NSError *error);
typedef void (^KBNConnectionSuccessBlock)() ;
typedef void (^KBNConnectionSuccessArrayBlock) (NSArray *records);
typedef void (^KBNConnectionSuccessProjectBlock) (KBNProject * project);
typedef void (^KBNConnectionSuccessDictionaryBlock) (NSDictionary *records);

//Colors
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define GREEN_GLOBANT 0xb6cf48
#define LIGHT_GRAY 0xefeff0
#define LIGHT_RED 0xff6060
#define LIGHT_BLUE 0x2f9dc4
#define DARK_BLUE 0x125066
#define DEFAULT_BLUE 0x007aff
#define BORDER_GRAY 0xc7c7c7

@interface KBNConstants : NSObject

@end
