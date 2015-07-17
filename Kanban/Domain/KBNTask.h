//
//  KBNTask.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KBNProject, KBNTaskList;

@interface KBNTask : NSManagedObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * taskDescription;
@property (nonatomic, strong) NSString * taskId;
@property (nonatomic, strong) NSNumber * order;
@property (nonatomic, strong) NSNumber *active;
@property (nonatomic, strong) KBNProject *project;
@property (nonatomic, strong) KBNTaskList *taskList;
@property (nonatomic, strong) NSNumber *synchronized;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSNumber *priority;


- (BOOL)isActive;
- (BOOL)isSynchronized;

@end
