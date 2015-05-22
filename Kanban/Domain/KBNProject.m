//
//  KBNProject.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProject.h"
#import "KBNTask.h"
#import "KBNTaskList.h"


@implementation KBNProject

@dynamic name;
@dynamic projectDescription;
@dynamic projectId;
@dynamic users;
@dynamic active;
@dynamic taskLists;
@dynamic tasks;


- (void)insertObject:(KBNTaskList *)value inTaskListsAtIndex:(NSUInteger)idx {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.taskLists.array];
    [temp insertObject:value atIndex:idx];
    self.taskLists = [NSOrderedSet orderedSetWithArray:temp];
}

- (void)removeTaskListsObject:(KBNTaskList *)value {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.taskLists.array];
    [temp removeObject:value];
    self.taskLists = [NSOrderedSet orderedSetWithArray:temp];
}

- (BOOL)isActive {
    return self.active.boolValue;
}

@end
