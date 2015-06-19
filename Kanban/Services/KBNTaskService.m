//
//  KBNTaskService.m
//  Kanban
//
//  Created by Lucas on 4/24/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskService.h"
#import "KBNTaskUtils.h"

@implementation KBNTaskService

+(KBNTaskService *) sharedInstance{
    
    static  KBNTaskService *inst = nil;
    
    @synchronized(self){
        if (!inst) {
            inst = [[self alloc] init];
            inst.dataService = [[KBNTaskParseAPIManager alloc]init];
            inst.fireBaseRootReference = [[Firebase alloc] initWithUrl:FIREBASE_BASE_URL];
        }
    }
    return inst;
}

- (void)createTask:(KBNTask*)aTask
            inList:(KBNTaskList*)aTaskList
   completionBlock:(KBNSuccessTaskBlock)onCompletion
        errorBlock:(KBNErrorBlock)onError {
    
    if ([aTask.name isEqualToString:@""] || !aTask.name) {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{NSLocalizedDescriptionKey: CREATING_TASK_WITHOUT_NAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-104 userInfo:info];
        onError(errorPtr);
    } else {
        if ([[KBNTaskListService sharedInstance] hasCountLimitBeenReached:aTaskList]){
            NSString *domain = ERROR_DOMAIN;
            NSDictionary * info = @{NSLocalizedDescriptionKey: CREATING_TASK_TASKLIST_FULL};
            NSError *errorPtr = [NSError errorWithDomain:domain code:-105 userInfo:info];
            onError(errorPtr);
        } else {
            aTask.order = [NSNumber numberWithUnsignedLong:[aTaskList.tasks indexOfObject:aTask]];
            [self.dataService createTaskWithName:aTask.name taskDescription:aTask.taskDescription order:aTask.order projectId:aTaskList.project.projectId taskListId:aTaskList.taskListId completionBlock:^(NSDictionary *records) {
                aTask.taskId = [records objectForKey:PARSE_OBJECTID];
                aTask.active = [NSNumber numberWithBool:YES];
                if ([aTask.project isShared]) {
                    [KBNUpdateUtils firebasePostToFirebaseRoot:self.fireBaseRootReference withObject:FIREBASE_TASK withType:FIREBASE_TASK_ADD projectID:aTask.project.projectId];
                }
                onCompletion(aTask);
            } errorBlock:onError];
        }
    }
}

- (void)getTasksForProject:(KBNProject*)project completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    [self.dataService getTasksForProject:project.projectId completionBlock:^(NSDictionary *records) {
        NSArray *results = [records objectForKey:@"results"];
        NSMutableArray *activeTasks = [[NSMutableArray alloc] init];
        
        for (NSDictionary *params in results) {
            NSString *taskListId = [params objectForKey:PARSE_TASK_TASK_LIST_COLUMN];
            KBNTask *task = [KBNTaskUtils taskForProject:project taskList:[project taskListForId:taskListId] params:params];
            if ([task isActive]) {
                [activeTasks addObject:task];
            };
        }
        
        onCompletion(activeTasks);
    } errorBlock:onError];
}

- (void)removeTask:(KBNTask*)task completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    NSMutableArray *tasksToUpdate = [[NSMutableArray alloc] init];
    KBNTaskList *list = task.taskList;
    
    //Delete logically the task updating its active value to NO
    task.active = @NO;
    [tasksToUpdate addObject:task];
    
    //Update orders
    [self updateTaskOrdersInSet:list.tasks];
    [tasksToUpdate addObjectsFromArray:list.tasks.array];
    
    //Send updates to the data service
    [self.dataService updateTasks:tasksToUpdate completionBlock:^{
        if ([task.project isShared]) {
            [KBNUpdateUtils firebasePostToFirebaseRoot:self.fireBaseRootReference withObject:FIREBASE_TASK withType:FIREBASE_TASK_REMOVE projectID:task.project.projectId];
        }
        onCompletion();
    } errorBlock:onError];
}

- (void) moveTask:(KBNTask *)task toList:(KBNTaskList*)destinationList inOrder:(NSNumber*)order
  completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    NSMutableArray *tasksToUpdate = [[NSMutableArray alloc] init];
    
    KBNTaskList *currentList = task.taskList;
    
    //Update task to the new values
    //If an order has not been passed, put the task at the end of the destination list
    if (order) {
        task.order = order;
    } else {
        task.order = [NSNumber numberWithUnsignedLong:destinationList.tasks.count];
    }
    
    task.taskList = destinationList;
    
    [currentList removeTasksObject:task];
    [destinationList insertObject:task inTasksAtIndex:[order integerValue]];
    
    [self updateTaskOrdersInSet:currentList.tasks];
    [tasksToUpdate addObjectsFromArray:currentList.tasks.array];
    
    [self updateTaskOrdersInSet:destinationList.tasks];
    [tasksToUpdate addObjectsFromArray:destinationList.tasks.array];
    
    //Send updates to the data service
    [self.dataService updateTasks:tasksToUpdate
                  completionBlock:^{
                      if ([task.project isShared]) {
                          [KBNUpdateUtils firebasePostToFirebaseRoot:self.fireBaseRootReference withObject:FIREBASE_TASK
                                                            withType:FIREBASE_TASK_CHANGE
                                                           projectID:task.project.projectId];
                      }
                      onCompletion();
                  }
                       errorBlock:onError];
}

- (void)updateTaskOrdersInSet:(NSOrderedSet*)set {
    NSUInteger index = 0;
    for (KBNTask *taskToReorder in set) {
        if ([taskToReorder isActive]) {
            taskToReorder.order = [NSNumber numberWithInteger:index];
            index++;
        }
    }
}

- (void)createTasks:(NSArray*)tasks completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    [self.dataService createTasks:tasks completionBlock:^(NSDictionary *records) {
        
        if ([[[tasks firstObject] project] isShared]) {
            [KBNUpdateUtils firebasePostToFirebaseRoot:self.fireBaseRootReference withObject:FIREBASE_TASK withType:FIREBASE_TASK_ADD projectID:((KBNTask*)tasks[0]).project.projectId];
        }
        onCompletion(tasks);
    } errorBlock:onError ];
}

-(void)updateTask:(KBNTask*)task onSuccess:(KBNSuccessBlock)onSuccess failure:(KBNErrorBlock)onError{
    
    if (task.name.length) {
        [self.dataService updateTasks:@[task]
                      completionBlock:^{
                          if ([task.project isShared]) {
                              [KBNUpdateUtils firebasePostToFirebaseRootWithName:self.fireBaseRootReference withObject:FIREBASE_TASK
                                                                        withName:task.name
                                                                 withDescription:task.taskDescription
                                                                       projectID:task.project.projectId];
                          }
                          onSuccess();
                      }
                           errorBlock:onError];
    } else {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{NSLocalizedDescriptionKey: EDIT_TASK_WITHOUTNAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-106 userInfo:info];
        onError(errorPtr);
    }
}
@end
