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
    
    KBNTask *task = nil;
    NSString *taskId = [params objectForKey:PARSE_OBJECTID];
    
    if (taskId) {
        task = [self taskFromId:taskId];
    }
    if (!task) {
        task = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TASK inManagedObjectContext:[self managedObjectContext]];
    }
    
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

+ (NSArray*)mockTasksForProject:(KBNProject*)project taskList:(KBNTaskList*)taskList quantity:(NSUInteger)quantity {
    
    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    KBNTask *task;
    
    for (NSUInteger i = 0; i < quantity; i++) {
        
        task = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TASK inManagedObjectContext:[self managedObjectContext]];

        [task setValue:[NSString stringWithFormat:@"Task%lu", (unsigned long)i] forKey:@"taskId"];
        [task setValue:[NSString stringWithFormat:@"Task%lu", (unsigned long)i] forKey:@"name"];
        [task setValue:@"Mock task for testing purposes" forKey:@"taskDescription"];
        [task setValue:[NSNumber numberWithUnsignedLong:i] forKey:@"order"];
        [task setValue:@YES forKey:@"active"];
        task.project = project;
        task.taskList = taskList;
        
        [tasks addObject:task];
    }
    
    return tasks;
    
}

+ (NSDictionary*)taskJson:(KBNTask *)task {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            task.taskId, PARSE_OBJECTID,
            task.name, PARSE_TASK_NAME_COLUMN,
            task.taskDescription, PARSE_TASK_DESCRIPTION_COLUMN,
            task.order, PARSE_TASK_ORDER_COLUMN,
            task.active, PARSE_TASK_ACTIVE_COLUMN,
            task.taskList.taskListId, PARSE_TASK_TASK_LIST_COLUMN, nil];
}

+ (NSDictionary *)tasksJson:(NSArray *)tasks {
    
    NSMutableArray *objects = [NSMutableArray array];
    
    for (KBNTask *task in tasks) {
        [objects addObject:[self taskJson:task]];
    }
    
    return [NSDictionary dictionaryWithObject:objects forKey:@"results"];

}

+ (NSArray *)tasksFromDictionary:(NSDictionary *)records key:(NSString *)key forProject:(KBNProject *)project {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *params in (NSArray*)[records objectForKey:key]) {
        NSString *taskListId = [params objectForKey:PARSE_TASK_TASK_LIST_COLUMN];
        KBNTask *task = [KBNTaskUtils taskForProject:project taskList:[project taskListForId:taskListId] params:params];
        if ([task isActive]) {
            [array addObject:task];
        }
    }
    return array;
}

+ (NSArray *)allTasksFromDictionary:(NSDictionary *)records key:(NSString *)key forProject:(KBNProject *)project {
    // Returns an array of all tasks, including deleted ones.
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *params in (NSArray*)[records objectForKey:key]) {
        NSString *taskListId = [params objectForKey:PARSE_TASK_TASK_LIST_COLUMN];
        KBNTask *task = [KBNTaskUtils taskForProject:project taskList:[project taskListForId:taskListId] params:params];
        [array addObject:task];
    }
    return array;
}

+ (KBNTask *)taskFromId:(NSString *)taskId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_TASK inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskId LIKE %@", taskId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    return [fetchedObjects firstObject];
}

+ (void)tasksForProjectId:(NSString*)projectId completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_TASK inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(project.projectId LIKE %@) AND (active == %@)", projectId, [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortByTaskListDescriptor = [[NSSortDescriptor alloc] initWithKey:@"taskList.order" ascending:YES];
    NSSortDescriptor *sortByOrderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortByTaskListDescriptor, sortByOrderDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        onError(error);
    } else {
        onCompletion(fetchedObjects);
    }
}

@end
