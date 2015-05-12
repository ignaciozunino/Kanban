//
//  KBNUpdateUtils.h
//  Kanban
//
//  Created by Guillermo Apoj on 8/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNProject.h"
#import "KBNTask.h"
#import "KBNTaskList.h"
#import "KBNTaskUtils.h"
#import "KBNConstants.h"

@interface KBNUpdateUtils : NSObject

+(NSInteger) indexOfProject:(NSString*)projectid inArray:(NSArray *)array;
+(void) updateExistingProjectsFromArray:(NSArray *) updatedProjects inArray:(NSArray *)array;
+(void) updateExistingTasksFromDictionary:(NSDictionary *) updatedTasks inArray:(NSMutableArray *)array forProject:(KBNProject*)project;
+(NSInteger) indexOfTask:(NSString*)taskid inArray:(NSArray *)array;

@end
