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
#import "NSDate+Utils.h"

@interface KBNProjectUtils()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end


@implementation KBNProjectUtils

+ (KBNProject*)projectWithParams:(NSDictionary *)params {
    
    KBNProject *project = nil;
    NSString *projectId = [params objectForKey:PARSE_OBJECTID];
    
    if (projectId) {
        project = [self projectFromId:projectId];
    }
    if (!project) {
        project = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_PROJECT inManagedObjectContext:[self managedObjectContext]];
    }

    [project setValue:[params objectForKey:PARSE_OBJECTID] forKey:@"projectId"];
    [project setValue:[params objectForKey:PARSE_PROJECT_NAME_COLUMN] forKey:@"name"];
    [project setValue:[params objectForKey:PARSE_PROJECT_DESCRIPTION_COLUMN] forKey:@"projectDescription"];
    [project setValue:[params objectForKey:PARSE_PROJECT_ACTIVE_COLUMN] forKey:@"active"];
    [project setValue:[params objectForKey:PARSE_PROJECT_USERSLIST_COLUMN] forKey:@"users"];
    [project setValue:[NSDate dateFromParseString:[params objectForKey:PARSE_UPDATED_COLUMN]] forKey:@"updatedAt"];
    
    return project;
}

+ (NSManagedObjectContext*) managedObjectContext {
    return [[KBNCoreDataManager sharedInstance] managedObjectContext];
}

+ (NSDictionary *)projectJson:(KBNProject *)project {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            project.projectId, PARSE_OBJECTID,
            project.name, PARSE_PROJECT_NAME_COLUMN,
            project.projectDescription, PARSE_PROJECT_DESCRIPTION_COLUMN,
            project.users, PARSE_PROJECT_USERSLIST_COLUMN   ,
            project.active, PARSE_PROJECT_ACTIVE_COLUMN, nil];
}

+ (NSDictionary *)projectsJson:(NSArray *)projects {
    
    NSMutableArray *objects = [NSMutableArray array];
    
    for (KBNProject *project in projects) {
        [objects addObject:[self projectJson:project]];
    }
    
    return [NSDictionary dictionaryWithObject:objects forKey:@"results"];
    
}

+ (NSArray *)projectsFromDictionary:(NSDictionary *)records key:(NSString *)key {

    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary* params in (NSArray*)[records objectForKey:key]) {
        KBNProject *project = [self projectWithParams:params];
        [array addObject:project];
    }
    return array;
}

+ (KBNProject *)projectFromId:(NSString *)projectId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_PROJECT inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectId LIKE %@", projectId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    return [fetchedObjects firstObject];
}

@end
