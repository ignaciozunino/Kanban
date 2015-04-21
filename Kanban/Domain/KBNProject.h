//
//  Project.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/17/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KBNTask;

@interface KBNProject : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * projectDescription;
@property (nonatomic, retain) NSSet *tasks;
@end

@interface KBNProject (CoreDataGeneratedAccessors)

- (void)addTasksObject:(KBNTask *)value;
- (void)removeTasksObject:(KBNTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

@end
