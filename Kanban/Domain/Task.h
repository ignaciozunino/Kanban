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
    TaskStateBacklog,TaskStateRequirements,TaskStateImplemented,TaskStateTested,TaskStateProduction
} TaskState;

@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * taskDescription;
@property (nonatomic, retain) NSManagedObject * project;
@property (nonatomic, retain) NSNumber * state;

@end
