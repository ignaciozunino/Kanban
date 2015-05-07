//
//  KBNTaskService.m
//  Kanban
//
//  Created by Lucas on 4/24/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskService.h"

@implementation KBNTaskService

+(KBNTaskService *) sharedInstance{
    
    static  KBNTaskService *inst = nil;
    
    @synchronized(self){
        if (!inst) {
            inst = [[self alloc] init];
            inst.dataService = [[KBNTaskParseAPIManager alloc]init];
        }
    }
    return inst;
}
/*
-(void)createTaskWithName:(NSString *)name taskDescription:(NSString *)taskDescription order:(NSNumber *)order projectId:(NSString *)projectId taskListId:(NSString *)taskListId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    if ([name isEqualToString:@""] || !name) {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": CREATING_TASK_WITHOUT_NAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-104 userInfo:info];
        onError(errorPtr);
    } else {
        
        [self.dataService createTaskWithName:name taskDescription:taskDescription order:order projectId:projectId taskListId:taskListId completionBlock:onCompletion errorBlock:onError];
    }
}
*/

-(void)createTask:(KBNTask*)aTask
           inList:(KBNTaskList*)aTaskList
  completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion
       errorBlock:(KBNConnectionErrorBlock)onError
{
    if ([aTask.name isEqualToString:@""] || !aTask.name) {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": CREATING_TASK_WITHOUT_NAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-104 userInfo:info];
        onError(errorPtr);
    } else {
        if ([[KBNTaskListService sharedInstance] hasCountLimitBeenReached:aTaskList]){
            NSString *domain = ERROR_DOMAIN;
            NSDictionary * info = @{@"NSLocalizedDescriptionKey": CREATING_TASK_TASKLIST_FULL};
            NSError *errorPtr = [NSError errorWithDomain:domain code:-105 userInfo:info];
            onError(errorPtr);
        } else {
            [self.dataService createTaskWithName:aTask.name taskDescription:aTask.taskDescription order:aTask.order projectId:aTaskList.project.projectId taskListId:aTaskList.taskListId completionBlock:onCompletion errorBlock:onError];
        }
    }
}

-(void)getTasksForProject:(NSString *)projectId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    [self.dataService getTasksForProject:projectId completionBlock:onCompletion errorBlock:onError];
    
}

-(void)removeTask:(KBNTask *)task from:(NSArray *)tasksArray completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    NSMutableArray *tasksToUpdate = [[NSMutableArray alloc] init];
    
    task.active = @NO;
    [tasksToUpdate addObject:task];
    
    // As the task has been removed from the array, the first task to reorder will be the deleted task order
    
    for (NSUInteger index = [task.order integerValue]; index < tasksArray.count; index++) {
        KBNTask *taskToReorder = [tasksArray objectAtIndex:index];
        taskToReorder.order = [NSNumber numberWithInteger:index];
        [tasksToUpdate addObject:taskToReorder];
    }
    
    [self.dataService updateTasks:tasksToUpdate completionBlock:onCompletion errorBlock:onError];
    
}

-(void)reorderTasks:(NSArray *)tasksArray completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    NSMutableArray *tasksToUpdate = [[NSMutableArray alloc] init];
    
    // As the task has been moved to the desired position in the received array, just assign the index to each task order
    
    for (NSUInteger index = 0; index < tasksArray.count; index++) {
        KBNTask *taskToReorder = [tasksArray objectAtIndex:index];
        taskToReorder.order = [NSNumber numberWithInteger:index];
        [tasksToUpdate addObject:taskToReorder];
    }
    
    [self.dataService updateTasks:tasksToUpdate completionBlock:onCompletion errorBlock:onError];

}

-(void)moveTask:(KBNTask *)task from:(NSArray *)tasksArray completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    NSMutableArray *tasksToUpdate = [[NSMutableArray alloc] init];
    
    [tasksToUpdate addObject:task];
    
    // As the task has been removed from the array, just assign the index to each task order
    
    for (NSUInteger index = 0; index < tasksArray.count; index++) {
        KBNTask *taskToReorder = [tasksArray objectAtIndex:index];
        taskToReorder.order = [NSNumber numberWithInteger:index];
        [tasksToUpdate addObject:taskToReorder];
    }
    
    [self.dataService updateTasks:tasksToUpdate completionBlock:onCompletion errorBlock:onError];
    
}

@end
