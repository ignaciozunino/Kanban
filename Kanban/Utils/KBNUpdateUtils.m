//
//  KBNUpdateUtils.m
//  Kanban
//
//  Created by Guillermo Apoj on 8/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNUpdateUtils.h"

@implementation KBNUpdateUtils

+ (void)firebasePostToFirebaseRoot:(Firebase *)rootReference withObject:(NSString*)objectName withType:(NSString*)type projectID:(NSString*)projectID {
    NSString* path = [NSString stringWithFormat:@"%@/%@", projectID, objectName];
    id rootRef = [rootReference childByAppendingPath:path];
    NSDictionary * dataToPass = @{FIREBASE_TYPE_OF_CHANGE:type, @"User":[KBNUserUtils getUsername]};
    [rootRef setValue:dataToPass];
}

+ (void)firebasePostToFirebaseRootWithName:(Firebase *)rootReference withObject:(NSString*)objectName withName:(NSString*)name withDescription:(NSString*)description projectID:(NSString*)projectID {
    NSString* path = [NSString stringWithFormat:@"%@/%@", projectID, objectName];
    id rootRef = [rootReference childByAppendingPath:path];
    NSDictionary * dataToPass = @{FIREBASE_EDIT_NAME_CHANGE:name, FIREBASE_EDIT_DESC_CHANGE:description, @"User":[KBNUserUtils getUsername]};
    [rootRef setValue:dataToPass];
}

@end
