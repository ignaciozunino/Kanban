//
//  KBNTaskListUtils.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/28/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNTaskList.h"

@interface KBNTaskListUtils : NSObject

+ (KBNTaskList*)taskListForProject:(KBNProject*)project params:(NSDictionary*)params;

+ (KBNTaskList*)taskListWithName:(NSString*)name;

+ (NSDictionary *)taskListJson:(KBNTaskList *)taskList;

+ (NSDictionary *)taskListsJson:(NSArray *)taskLists;

+ (NSArray *)taskListsFromDictionary:(NSDictionary *)records key:(NSString *)key forProject:(KBNProject*)project;

@end
