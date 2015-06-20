//
//  KBNUpdateUtils.h
//  Kanban
//
//  Created by Guillermo Apoj on 8/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNProject.h"
#import "KBNTask.h"
#import "KBNTaskList.h"
#import "KBNTaskUtils.h"
#import "KBNConstants.h"
#import "KBNUserUtils.h"
#import <Firebase/Firebase.h>
#import "KBNUserUtils.h"

@interface KBNUpdateUtils : NSObject

+ (void)firebasePostToFirebaseRoot:(Firebase *)rootReference withObject:(NSString*)objectName withType:(NSString*)type projectID:(NSString*)projectID;
+ (void)firebasePostToFirebaseRootWithName:(Firebase *)rootReference withObject:(NSString*)objectName withName:(NSString*)name withDescription:(NSString*)description projectID:(NSString*)projectID;

@end
