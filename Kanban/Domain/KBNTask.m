//
//  KBNTask.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTask.h"
#import "KBNProject.h"
#import "KBNTaskList.h"


@implementation KBNTask

@dynamic name;
@dynamic taskDescription;
@dynamic taskId;
@dynamic order;
@dynamic active;
@dynamic project;
@dynamic taskList;
@dynamic synchronized;
@dynamic updatedAt;
@dynamic priority;

- (BOOL)isActive {
    return self.active.boolValue;
}

- (BOOL)isSynchronized {
    return self.synchronized.boolValue;
}

@end
