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
    
    KBNTaskList *taskList = nil;
    NSString *taskListId = [params objectForKey:PARSE_OBJECTID];
    
    if (taskListId) {
        taskList = [self taskListFromId:taskListId];
    }
    if (!taskList) {
        taskList = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TASK_LIST inManagedObjectContext:[self managedObjectContext]];
    }
    
    [taskList setValue:[params objectForKey:PARSE_OBJECTID] forKey:@"taskListId"];
    [taskList setValue:[params objectForKey:PARSE_TASKLIST_NAME_COLUMN] forKey:@"name"];
    [taskList setValue:[params objectForKey:PARSE_TASKLIST_ORDER_COLUMN] forKey:@"order"];
    taskList.project = project;
    
    return taskList;
}

+ (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

+ (KBNTaskList*)taskListWithName:(NSString *)name {
    return [self taskListForProject:nil params:[NSDictionary dictionaryWithObjectsAndKeys:name, PARSE_TASKLIST_NAME_COLUMN, nil]];
}

+ (NSDictionary *)taskListJson:(KBNTaskList *)taskList {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            taskList.taskListId, PARSE_OBJECTID,
            taskList.name, PARSE_TASKLIST_NAME_COLUMN,
            taskList.order, PARSE_TASKLIST_ORDER_COLUMN, nil];
}

+ (NSDictionary *)taskListsJson:(NSArray *)taskLists {
    
    NSMutableArray *lists = [NSMutableArray array];
    
    for (KBNTaskList *taskList in taskLists) {
        [lists addObject:[self taskListJson:taskList]];
    }
    
    return [NSDictionary dictionaryWithObject:lists forKey:@"results"];
}

+ (NSArray *)taskListsFromDictionary:(NSDictionary *)records key:(NSString *)key forProject:(KBNProject*)project{
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary* params in (NSArray*)[records objectForKey:key]) {
        [array addObject:[self taskListForProject:project params:params]];
    }
    return array;
}

+ (KBNTaskList *)taskListFromId:(NSString *)taskListId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_TASK_LIST inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskListId LIKE %@", taskListId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    return [fetchedObjects firstObject];
}

@end
