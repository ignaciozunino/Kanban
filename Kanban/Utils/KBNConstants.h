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
#define ADD_PROJECT_LOADING NSLocalizedString(@"ADD_PROJECT_LOADING", nil)
#define ADD_TASK_LOADING NSLocalizedString(@"ADD_TASK_LOADING", nil)
#define EDIT_PROJECT_LOADING NSLocalizedString(@"EDIT_PROJECT_LOADING", nil)
#define EDIT_TASK_LOADING NSLocalizedString(@"EDIT_TASK_LOADING", nil)
#define EDIT_PROJECT_INVITING NSLocalizedString(@"EDIT_PROJECT_INVITING", nil)


//Succes messages
#define PROJECT_CREATION_SUCCESS NSLocalizedString(@"PROJECT_CREATION_SUCCESS", nil)
#define PROJECT_EDIT_SUCCESS NSLocalizedString(@"PROJECT_EDIT_SUCCESS", nil)
#define TASK_CREATION_SUCCESS NSLocalizedString(@"TASK_CREATION_SUCCESS", nil)
#define TASK_EDIT_SUCCESS NSLocalizedString(@"TASK_EDIT_SUCCESS", nil)


//Error messages
#define ERROR_DOMAIN NSLocalizedString(@"ERROR_DOMAIN", nil)
#define SIGNIN_ERROR NSLocalizedString(@"SIGNIN_ERROR", nil)
#define CREATING_PROJECT_WITHOUTNAME_ERROR NSLocalizedString(@"CREATING_PROJECT_WITHOUTNAME_ERROR", nil)
#define CREATING_PROJECT_OFFLINE_ERROR NSLocalizedString(@"CREATING_PROJECT_OFFLINE_ERROR", nil)
#define CREATING_TASK_WITHOUT_NAME_ERROR NSLocalizedString(@"CREATING_TASK_WITHOUT_NAME_ERROR", nil)
#define CREATING_TASKLIST_WITHOUT_NAME_ERROR NSLocalizedString(@"CREATING_TASKLIST_WITHOUT_NAME_ERROR", nil)
#define CREATING_TASK_OFFLINE_ERROR NSLocalizedString(@"CREATING_TASK_OFFLINE_ERROR", nil)
#define CREATING_TASK_TASKLIST_FULL NSLocalizedString(@"CREATING_TASK_TASKLIST_FULL", nil)
#define EDIT_PROJECT_WITHOUTNAME_ERROR NSLocalizedString(@"EDIT_PROJECT_WITHOUTNAME_ERROR", nil)
#define USER_EXISTS_ERROR NSLocalizedString(@"USER_EXISTS_ERROR", nil)
#define EDIT_TASK_WITHOUTNAME_ERROR NSLocalizedString(@"EDIT_TASK_WITHOUTNAME_ERROR", nil)
#define INVITE_USERS_USER_EXISTS_ERROR NSLocalizedString(@"INVITE_USERS_USER_EXISTS_ERROR", nil)
#define OFFLINE_WARNING NSLocalizedString(@"OFFLINE_WARNING", nil)

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
#define PARSE_CREATED_COLUMN @"createdAt"
#define PARSE_UPDATED_COLUMN @"updatedAt"

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
#define PARSE_TASK_PRIORITY_COLUMN @"priority"

#define PARSE_PROJECT_TEMPLATE_NAME @"name"
#define PARSE_PROJECT_TEMPLATE_LISTS @"lists"
#define PARSE_PROJECT_TEMPLATE_LANGUAGE @"language"

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
#define EMAIL_INVITE_SUBJECT NSLocalizedString(@"EMAIL_INVITE_SUBJECT", nil)
#define EMAIL_INVITE_BODY NSLocalizedString(@"EMAIL_INVITE_BODY", nil)

//Base URL of the web site - make sure to include the trailing slash:
#define WEBSITE_BASE_URL @"https://www.simplekanban.com/"


//alert titles
#define ERROR_ALERT NSLocalizedString(@"ERROR_ALERT", nil)
#define WARNING_ALERT NSLocalizedString(@"WARNING_ALERT", nil)
#define SUCCESS_ALERT NSLocalizedString(@"SUCCESS_ALERT", nil)
#define OK_TITLE NSLocalizedString(@"OK_TITLE", nil)
#define CANCEL_TITLE NSLocalizedString(@"CANCEL_TITLE", nil)
#define DELETE_TITLE NSLocalizedString(@"DELETE_TITLE", nil)
#define BEFORE_TITLE NSLocalizedString(@"BEFORE_TITLE", nil)
#define AFTER_TITLE NSLocalizedString(@"AFTER_TITLE", nil)
#define ADD_LIST_TITLE NSLocalizedString(@"ADD_LIST_TITLE", nil)
#define DONE_TITLE NSLocalizedString(@"DONE_TITLE", nil)

//Tutorial titles
#define CREATE_PROJECTS_TITLE NSLocalizedString(@"CREATE_PROJECTS_TITLE", nil)
#define CREATE_AND_MOVE_TASK_TITLE NSLocalizedString(@"CREATE_AND_MOVE_TASK_TITLE", nil)
#define INVITE_USERS_TITLE NSLocalizedString(@"INVITE_USERS_TITLE", nil)

//FIREBASE KEYS
#define FIREBASE_CHANGE_TYPE @"ChangeType"
#define FIREBASE_USER @"User"
#define FIREBASE_DATA @"Data"

#define FIREBASE_PROJECT @"Project"
#define FIREBASE_TASK_LIST @"TaskList"
#define FIREBASE_TASK @"Task"

//Notifications
#define UPDATE_PROJECT @"updateProject"
#define UPDATE_PROJECTS @"updateProjects"
#define UPDATE_TASKLIST @"updateTaskList"
#define UPDATE_TASKLISTS @"updateTaskLists"
#define UPDATE_TASK @"updateTask"
#define UPDATE_TASKS @"updateTasks"
#define ADD_TASK @"addTask"
#define MOVE_TASK @"moveTask"
#define REMOVE_TASK @"removeTask"

//TaskLists Templates
#define DEFAULT_TASK_LISTS   @[@"Backlog",@"Requirements",@"Implemented",@"Tested",@"Production"]

//Priority Data
#define PRIORITY_HIGH NSLocalizedString(@"PRIORITY_HIGH", nil)
#define PRIORITY_MEDIUM NSLocalizedString(@"PRIORITY_MEDIUM", nil)
#define PRIORITY_LOW NSLocalizedString(@"PRIORITY_LOW", nil)
#define LOW_COLOR [UIColor colorWithRed:204.0/255.0 green:255.0/255.0 blue:102.0/255.0 alpha:1]
#define MEDIUM_COLOR [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1]
#define HIGH_COLOR [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1]

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
