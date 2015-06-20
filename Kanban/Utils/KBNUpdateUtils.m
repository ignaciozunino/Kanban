//
//  KBNUpdateUtils.m
//  Kanban
//
//  Created by Guillermo Apoj on 8/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNUpdateUtils.h"

@implementation KBNUpdateUtils

+ (void)firebasePostToFirebaseRoot:(Firebase *)rootReference withObject:(NSString*)objectName projectId:(NSString*)projectId data:(NSDictionary*)data {
    NSString* path = [NSString stringWithFormat:@"%@/%@", projectId, objectName];
    id rootRef = [rootReference childByAppendingPath:path];
    NSDictionary *dataToPass = @{@"User":[KBNUserUtils getUsername], @"data":data};
    [rootRef setValue:dataToPass];
}

@end
