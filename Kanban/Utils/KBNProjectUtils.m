//
//  ProjectUtils.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/20/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectUtils.h"
#import "KBNAppDelegate.h"
#import "KBNConstants.h"

@interface KBNProjectUtils()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end


@implementation KBNProjectUtils

+ (BOOL)existProject:(NSString*)name {
    return NO;
}

+ (KBNProject*)projectWithParams:(NSDictionary *)params {
    
    KBNProject *project = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_PROJECT inManagedObjectContext:[self managedObjectContext]];
    
    [project setValue:[params objectForKey:PARSE_OBJECTID] forKey:@"projectId"];
    [project setValue:[params objectForKey:PARSE_PROJECT_NAME_COLUMN] forKey:@"name"];
    [project setValue:[params objectForKey:PARSE_PROJECT_DESCRIPTION_COLUMN] forKey:@"projectDescription"];
    
    return project;
}

+ (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

@end
