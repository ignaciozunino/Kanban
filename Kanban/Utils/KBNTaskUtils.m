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
            task.taskId, NSStringFromSelector(@selector(taskId)),
            task.name, NSStringFromSelector(@selector(name)),
            task.taskDescription, NSStringFromSelector(@selector(taskDescription)),
            task.order, NSStringFromSelector(@selector(order)),
            task.active, NSStringFromSelector(@selector(active)), nil];
}

+ (NSDictionary *)tasksJson:(NSArray *)tasks {
    
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *keys = [NSMutableArray array];
    
    for (KBNTask *task in tasks) {
        [objects addObject:[self taskJson:task]];
        [keys addObject:task.taskId];
    }
    
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys];

}

@end
