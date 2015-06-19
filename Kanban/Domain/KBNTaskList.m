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

- (void)removeTasksObject:(KBNTask *)value {
    [self.tasks removeObject:value];
}

- (void)insertObject:(KBNTask *)value inTasksAtIndex:(NSUInteger)idx {
    [self.tasks insertObject:value atIndex:idx];
}
@end
