//
//  KBNTaskUtils.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/28/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskUtils.h"
#import "KBNAppDelegate.h"
#import "KBNConstants.h"

@interface KBNTaskUtils()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation KBNTaskUtils

+ (KBNTask*)taskForProject:(KBNProject *)project taskList:(KBNTaskList *)taskList params:(NSDictionary *)params {
    
    KBNTask *task = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TASK inManagedObjectContext:[self managedObjectContext]];
    
    [task setValue:[params objectForKey:PARSE_OBJECTID] forKey:@"taskId"];
    [task setValue:[params objectForKey:PARSE_TASK_NAME_COLUMN] forKey:@"name"];
    [task setValue:[params objectForKey:PARSE_TASK_DESCRIPTION_COLUMN] forKey:@"taskDescription"];
    [task setValue:[params objectForKey:PARSE_TASK_ORDER_COLUMN] forKey:@"order"];
    [task setValue:[params objectForKey:PARSE_TASK_ACTIVE_COLUMN] forKey:@"active"];
    task.project = project;
    task.taskList = taskList;
    
    return task;
}

+ (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

@end
