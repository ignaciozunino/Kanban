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

//View controllers identifiers
#define PROJECT_DETAIL_VC @"KBNProjectDetailViewController"
#define PAGE_VC @"KBNPageViewController"


//Succes messages
#define PROJECT_CREATION_SUCCES @"Project created succesfully!"

//Error messages
#define ERROR_DOMAIN @"globant.kanban.Kanban.ErrorDomain";
#define SIGNIN_ERROR @"Please verify the username is a valid email and the password has at least 6 characters, one letter and one number."

//URL
#define PARSE_USERS @"https://api.parse.com/1/users"
#define PARSE_PROJECTS @"https://api.parse.com/1/classes/Project"

//alert titles
#define ERROR_ALERT @"ERROR"
#define WARNING_ALERT @"WARNING"
#define SUCCES_ALERT @"SUCCES"

#define taskStates          @[@"Backlog",@"Requirements",@"Implemented",@"Tested",@"Production"]




@interface KBNConstants : NSObject

@end
