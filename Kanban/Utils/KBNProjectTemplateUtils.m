//
//  KBNProjectTemplateUtils.m
//  Kanban
//
//  Created by Marcelo Dessal on 5/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectTemplateUtils.h"
#import "KBNAppDelegate.h"
#import "KBNConstants.h"

@interface KBNProjectTemplateUtils()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation KBNProjectTemplateUtils

+ (KBNProjectTemplate*)projectTemplateWithParams:(NSDictionary *)params {
    
    KBNProjectTemplate *template = nil;
    NSString *templateId = [params objectForKey:PARSE_OBJECTID];
    
    if (templateId) {
        template = [self projectTemplateFromId:templateId];
    }
    if (!template) {
        template = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_PROJECT_TEMPLATE inManagedObjectContext:[self managedObjectContext]];
    }

    [template setValue:[params objectForKey:PARSE_OBJECTID] forKey:@"projectTemplateId"];
    [template setValue:[params objectForKey:PARSE_PROJECT_TEMPLATE_NAME] forKey:@"name"];
    [template setValue:[params objectForKey:PARSE_PROJECT_TEMPLATE_LISTS] forKey:@"lists"];
    
    return template;
}

+ (NSManagedObjectContext*) managedObjectContext {
    return [[KBNCoreDataManager sharedInstance] managedObjectContext];
}

+ (KBNProjectTemplate *)defaultTemplate {
 
    return [self projectTemplateWithParams:[NSDictionary dictionaryWithObjectsAndKeys:@"Default", @"name", DEFAULT_TASK_LISTS, @"lists", @"xxxxxxxxxx", PARSE_OBJECTID, nil]];
}

+ (KBNProjectTemplate *)projectTemplateFromId:(NSString *)templateId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_PROJECT_TEMPLATE inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectTemplateId LIKE %@", templateId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    return [fetchedObjects firstObject];
}

@end
