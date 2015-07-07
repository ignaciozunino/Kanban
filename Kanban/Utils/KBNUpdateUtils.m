//
//  KBNUpdateUtils.m
//  Kanban
//
//  Created by Guillermo Apoj on 8/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNUpdateUtils.h"

@implementation KBNUpdateUtils

+ (void)postToFirebase:(Firebase *)rootReference changeType:(KBNChangeType)changeType projectId:(NSString *)projectId data:(id)data {
    
    NSString* path = [NSString stringWithFormat:@"%@", projectId];
    id rootRef = [rootReference childByAppendingPath:path];
    
    NSDictionary *dataToPass = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [KBNUserUtils getUsername], FIREBASE_USER,
                                [NSNumber numberWithInt:changeType], FIREBASE_CHANGE_TYPE,
                                data, FIREBASE_DATA, nil];
    
    [rootRef setValue:dataToPass];
}

@end
