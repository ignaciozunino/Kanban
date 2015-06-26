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
#define ENTITY_PROJECT_TEMPLATE @"KBNProjectTemplate"

//View controllers identifiers
#define PROJECT_DETAIL_VC @"KBNProjectDetailViewController"
#define PAGE_VC @"KBNPageViewController"

//Loading messages
#define ADD_PROJECT_LOADING @"Creating the project"
#define ADD_TASK_LOADING @"Creating the task"
#define EDIT_PROJECT_LOADING @"Editing the project"
#define EDIT_TASK_LOADING @"Editing the task"
#define EDIT_PROJECT_INVITING @"Inviting to the project"


//Succes messages
#define PROJECT_CREATION_SUCCESS @"Project created successfully!"
#define PROJECT_EDIT_SUCCESS @"Project modified successfully!"
#define TASK_CREATION_SUCCESS @"Task created successfully!"
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
#define INVITE_USERS_USER_EXISTS_ERROR @"There is already a user created with that username, please try other username."
#define OFFLINE_WARNING @"Connection appears to be offline."

//URL
#define PARSE_USERS @"https://api.parse.com/1/users"
#define PARSE_PROJECTS @"https://api.parse.com/1/classes/Project"
#define PARSE_TASKLISTS @"https://api.parse.com/1/classes/TaskList"
#define PARSE_TASKS @"https://api.parse.com/1/classes/Task"
#define PARSE_PROJECT_TEMPLATES @"https://api.parse.com/1/classes/ProjectTemplate"
#define PARSE_BATCH @"https://api.parse.com/1/batch"

#define FIREBASE_BASE_URL @"https://kanbanglb.firebaseio.com/"

//PARSE TABLE COLUMNS
#define PARSE_OBJECTID @"objectId"

#define PARSE_TASKLIST_NAME_COLUMN @"name"
#define PARSE_TASKLIST_PROJECT_COLUMN @"project"
#define PARSE_TASKLIST_ORDER_COLUMN @"order"

#define PARSE_PROJECT_NAME_COLUMN @"name"
#define PARSE_PROJECT_DESCRIPTION_COLUMN @"projectDescription"
#define PARSE_PROJECT_USER_COLUMN @"userName"
#define PARSE_PROJECT_USERSLIST_COLUMN @"users"
#define PARSE_PROJECT_ACTIVE_COLUMN @"active"

#define PARSE_TASK_NAME_COLUMN @"name"
#define PARSE_TASK_DESCRIPTION_COLUMN @"taskDescription"
#define PARSE_TASK_PROJECT_COLUMN @"project"
#define PARSE_TASK_TASK_LIST_COLUMN @"taskList"
#define PARSE_TASK_ORDER_COLUMN @"order"
#define PARSE_TASK_ACTIVE_COLUMN @"active"
#define PARSE_TASK_UPDATED_COLUMN @"updatedAt"

#define PARSE_PROJECT_TEMPLATE_NAME @"name"
#define PARSE_PROJECT_TEMPLATE_LISTS @"lists"

#define PARSE_USER_NAME_COLUMN @"username"


//Mailgun constants
#define MAILGUN_URL_SANDBOX @"https://api.mailgun.net/v3/sandbox92aeacae0c604dfe9bdf32b0d17e3cf4.mailgun.org/messages"
#define MAILGUN_API_KEY_USER @"api"
#define MAILGUN_API_KEY_PASSWORD @"key-aa16f88cfd7050161fbd5f43ed8a071e"
#define MAILGUN_FIELD_TO @"to"
#define MAILGUN_FIELD_FROM @"from"
#define MAILGUN_FIELD_SUBJECT @"subject"
#define MAILGUN_FIELD_BODY @"text"

//Email communications
#define EMAIL_INVITE_SUBJECT @"Invitation to my project"
#define EMAIL_INVITE_BODY @"I've just invited you to my Simple Kanban project. Sign in to the Kanban App with your email address and check it out!"

//Base URL of the web site - make sure to include the trailing slash:
#define WEBSITE_BASE_URL @"https://www.simplekanban.com/"


//alert titles
#define ERROR_ALERT @"ERROR"
#define WARNING_ALERT @"WARNING"
#define SUCCESS_ALERT @"SUCCESS"
#define OK_TITLE @"Ok"
#define CANCEL_TITLE @"Cancel"
#define DELETE_TITLE @"Delete"
#define BEFORE_TITLE @"Before"
#define AFTER_TITLE @"After"
#define ADD_LIST_TITLE @"Add list"


//FIREBASE KEYS
#define FIREBASE_CHANGE_TYPE @"ChangeType"
#define FIREBASE_USER @"User"
#define FIREBASE_DATA @"Data"

#define FIREBASE_PROJECT @"Project"
#define FIREBASE_TASK_LIST @"TaskList"
#define FIREBASE_TASK @"Task"

//Notifications
#define UPDATE_PROJECT @"updateProject"
#define UPDATE_TASKLIST @"updateTaskList"
#define UPDATE_TASK @"updateTask"
#define UPDATE_TASKS @"updateTasks"
#define ADD_TASK @"addTask"
#define MOVE_TASK @"moveTask"

//TaskLists Templates
#define DEFAULT_TASK_LISTS   @[@"Backlog",@"Requirements",@"Implemented",@"Tested",@"Production"]


//Blocks 
typedef void (^KBNErrorBlock) (NSError *error);
typedef void (^KBNSuccessBlock)() ;
typedef void (^KBNSuccessArrayBlock) (NSArray *records);
typedef void (^KBNSuccessProjectBlock) (KBNProject *project);
typedef void (^KBNSuccessTaskListBlock) (KBNTaskList *taskList);
typedef void (^KBNSuccessTaskBlock) (KBNTask *task);
typedef void (^KBNSuccessDictionaryBlock) (NSDictionary *records);
typedef void (^KBNSuccessIdBlock) (NSString *objectId);

//Colors
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define GREEN_GLOBANT 0xb6cf48
#define LIGHT_GRAY 0xefeff0
#define LIGHT_RED 0xff6060
#define LIGHT_BLUE 0x2f9dc4
#define DARK_BLUE 0x125066
#define DEFAULT_BLUE 0x007aff
#define BORDER_GRAY 0xc7c7c7
#define DISABLE_GRAY 0x8f8f90

@interface KBNConstants : NSObject

@end
