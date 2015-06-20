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

+ (KBNProject*)projectWithParams:(NSDictionary *)params {
    
    KBNProject *project = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_PROJECT inManagedObjectContext:[self managedObjectContext]];
    
    [project setValue:[params objectForKey:PARSE_OBJECTID] forKey:@"projectId"];
    [project setValue:[params objectForKey:PARSE_PROJECT_NAME_COLUMN] forKey:@"name"];
    [project setValue:[params objectForKey:PARSE_PROJECT_DESCRIPTION_COLUMN] forKey:@"projectDescription"];
    [project setValue:[params objectForKey:PARSE_PROJECT_ACTIVE_COLUMN] forKey:@"active"];
    [project setValue:[params objectForKey:PARSE_PROJECT_USERSLIST_COLUMN] forKey:@"users"];
    
    return project;
}

+ (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

+ (NSDictionary *)projectJson:(KBNProject *)project {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            project.projectId, NSStringFromSelector(@selector(projectId)),
            project.name, NSStringFromSelector(@selector(name)),
            project.projectDescription, NSStringFromSelector(@selector(projectDescription)),
            project.users, NSStringFromSelector(@selector(users)),
            project.active, NSStringFromSelector(@selector(active)), nil];
}

@end
