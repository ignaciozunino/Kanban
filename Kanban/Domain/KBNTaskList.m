//
//  KBNTaskList.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskList.h"
#import "KBNProject.h"
#import "KBNTask.h"
#import "KBNConstants.h"

@implementation KBNTaskList

@dynamic name;
@dynamic order;
@dynamic taskListId;
@dynamic project;
@dynamic tasks;
@dynamic synchronized;

- (void)insertObject:(KBNTask *)value inTasksAtIndex:(NSUInteger)idx {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.tasks.array];
    [temp insertObject:value atIndex:idx];
    self.tasks = [NSOrderedSet orderedSetWithArray:temp];
}

- (void)removeTasksObject:(KBNTask *)value {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.tasks.array];
    [temp removeObject:value];
    self.tasks = [NSOrderedSet orderedSetWithArray:temp];
}

- (BOOL)isSynchronized {
    return self.synchronized.boolValue;
}

@end
