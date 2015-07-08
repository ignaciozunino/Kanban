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

@implementation KBNTaskListUtils

+ (KBNTaskList *)taskListForProject:(KBNProject *)project params:(NSDictionary *)params {
    return [[KBNCoreDataManager sharedInstance] taskListForProject:project params:params];
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

@end
