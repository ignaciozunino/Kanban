//
//  KBNTaskListUtils.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/28/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskListUtils.h"
#import "KBNAppDelegate.h"
#import "KBNConstants.h"

@interface KBNTaskListUtils()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation KBNTaskListUtils

+ (KBNTaskList*)taskListForProject:(KBNProject *)project params:(NSDictionary *)params {

    KBNTaskList *taskList = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TASK_LIST inManagedObjectContext:[self managedObjectContext]];
    
    [taskList setValue:[params objectForKey:PARSE_OBJECTID] forKey:@"taskListId"];
    [taskList setValue:[params objectForKey:PARSE_TASKLIST_NAME_COLUMN] forKey:@"name"];
    [taskList setValue:[params objectForKey:PARSE_TASKLIST_ORDER_COLUMN] forKey:@"order"];
    taskList.project = project;
    
    return taskList;
}

+ (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

@end
