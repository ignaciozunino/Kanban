//
//  KBNProject.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KBNTask, KBNTaskList;

@interface KBNProject : NSManagedObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * projectDescription;
@property (nonatomic, strong) NSString * projectId;
@property (nonatomic, strong) NSOrderedSet *taskLists;
@property (nonatomic, strong) NSOrderedSet *tasks;
@end

@interface KBNProject (CoreDataGeneratedAccessors)

- (void)insertObject:(KBNTaskList *)value inTaskListsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTaskListsAtIndex:(NSUInteger)idx;
- (void)insertTaskLists:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTaskListsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTaskListsAtIndex:(NSUInteger)idx withObject:(KBNTaskList *)value;
- (void)replaceTaskListsAtIndexes:(NSIndexSet *)indexes withTaskLists:(NSArray *)values;
- (void)addTaskListsObject:(KBNTaskList *)value;
- (void)removeTaskListsObject:(KBNTaskList *)value;
- (void)addTaskLists:(NSOrderedSet *)values;
- (void)removeTaskLists:(NSOrderedSet *)values;
- (void)insertObject:(KBNTask *)value inTasksAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTasksAtIndex:(NSUInteger)idx;
- (void)insertTasks:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTasksAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTasksAtIndex:(NSUInteger)idx withObject:(KBNTask *)value;
- (void)replaceTasksAtIndexes:(NSIndexSet *)indexes withTasks:(NSArray *)values;
- (void)addTasksObject:(KBNTask *)value;
- (void)removeTasksObject:(KBNTask *)value;
- (void)addTasks:(NSOrderedSet *)values;
- (void)removeTasks:(NSOrderedSet *)values;
@end
