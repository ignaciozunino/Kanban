//
//  KBNTaskUtils.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/28/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskUtils.h"
#import "KBNAppDelegate.h"

@implementation KBNTaskUtils

+ (KBNTask *)taskForProject:(KBNProject *)project taskList:(KBNTaskList *)taskList params:(NSDictionary *)params {
    return [[KBNCoreDataManager sharedInstance] taskForProject:project taskList:taskList params:params];
}

+ (NSArray *)mockTasksForProject:(KBNProject *)project taskList:(KBNTaskList *)taskList quantity:(NSUInteger)quantity {
    return [[KBNCoreDataManager sharedInstance] mockTasksForProject:project taskList:taskList quantity:quantity];
}

+ (NSDictionary*)taskJson:(KBNTask *)task {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            task.taskId, PARSE_OBJECTID,
            task.name, PARSE_TASK_NAME_COLUMN,
            task.taskDescription, PARSE_TASK_DESCRIPTION_COLUMN,
            task.order, PARSE_TASK_ORDER_COLUMN,
            task.active, PARSE_TASK_ACTIVE_COLUMN,
            task.taskList.taskListId, PARSE_TASK_TASK_LIST_COLUMN,
            task.priority, PARSE_TASK_PRIORITY_COLUMN, nil];
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

@end
