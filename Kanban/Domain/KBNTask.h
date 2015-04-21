//
//  Task.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/17/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
typedef enum {
                TaskStateBacklog,
                TaskStateRequirements,
                TaskStateImplemented,
                TaskStateTested,
                TaskStateProduction
            } TaskState;

@interface KBNTask : NSManagedObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * taskDescription;
@property (nonatomic, strong) NSManagedObject * project;
@property (nonatomic, strong) NSNumber * state;

@end
