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
    
    KBNProjectTemplate *template = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_PROJECT_TEMPLATE inManagedObjectContext:[self managedObjectContext]];
    
    [template setValue:[params objectForKey:PARSE_OBJECTID] forKey:@"projectTemplateId"];
    [template setValue:[params objectForKey:PARSE_PROJECT_TEMPLATE_NAME] forKey:@"name"];
    [template setValue:[params objectForKey:PARSE_PROJECT_TEMPLATE_LISTS] forKey:@"lists"];
    
    return template;
}

+ (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

+ (KBNProjectTemplate *)defaultTemplate {
 
    return [self projectTemplateWithParams:[NSDictionary dictionaryWithObjectsAndKeys:@"Default", @"name", DEFAULT_TASK_LISTS, @"lists", nil]];
}

@end
