//
//  KBNTaskUtils.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/28/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNTask.h"
#import "KBNTaskList.h"

@interface KBNTaskUtils : NSObject

+ (KBNTask*)taskForProject:(KBNProject*)project taskList:(KBNTaskList*)taskList params:(NSDictionary*)params;

+ (NSArray*)mockTasksForProject:(KBNProject*)project taskList:(KBNTaskList*)taskList quantity:(NSUInteger)quantity;

+ (NSDictionary *)taskJson:(KBNTask *)task;

+ (NSDictionary *)tasksJson:(NSArray *)tasks;

+ (NSArray*)tasksFromDictionary:(NSDictionary*)records key:(NSString*)key forProject:(KBNProject*)project;

@end
