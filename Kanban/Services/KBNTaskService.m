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
   completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion
        errorBlock:(KBNConnectionErrorBlock)onError {
    
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
                [KBNUpdateUtils firebasePostToFirebaseRoot:self.fireBaseRootReference withObject:FIREBASE_TASK withType:FIREBASE_TASK_ADD projectID:aTask.project.projectId];
                onCompletion(records);
            } errorBlock:onError];
        }
    }
}

- (void)getTasksForProject:(NSString *)projectId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    [self.dataService getTasksForProject:projectId completionBlock:^(NSDictionary *records) {
        onCompletion([self activeRecordsFromDictionary:records]);
    } errorBlock:onError];
}

- (NSDictionary*)activeRecordsFromDictionary:(NSDictionary*)records {
    
    NSArray *results = [records objectForKey:@"results"];
    NSMutableArray *activeTasks = [[NSMutableArray alloc] init];
    
    for (NSDictionary *params in results) {
        if ([[params objectForKey:PARSE_TASK_ACTIVE_COLUMN] boolValue]) {
            [activeTasks addObject:params];
        };
    }
    
    return [NSDictionary dictionaryWithObject:activeTasks forKey:@"results"];

}

- (void)removeTask:(KBNTask*)task completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    NSMutableArray *tasksToUpdate = [[NSMutableArray alloc] init];
    KBNTaskList *list = task.taskList;
    
    //Delete logically the task updating its active value to NO
    task.active = @NO;
    [tasksToUpdate addObject:task];
    
    //Remove the task from the list
    [list.tasks removeObject:task];
    [self updateTaskOrdersInSet:list.tasks];
    [tasksToUpdate addObjectsFromArray:list.tasks.array];
    
    //Send updates to the data service
    [self.dataService updateTasks:tasksToUpdate completionBlock:^{
        [KBNUpdateUtils firebasePostToFirebaseRoot:self.fireBaseRootReference withObject:FIREBASE_TASK withType:FIREBASE_TASK_REMOVE projectID:task.project.projectId];
        onCompletion();
    } errorBlock:onError];
}

- (void) moveTask:(KBNTask *)task toList:(KBNTaskList*)destinationList inOrder:(NSNumber*)order
  completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    NSMutableArray *tasksToUpdate = [[NSMutableArray alloc] init];
    
    KBNTaskList *currentList = task.taskList;
    
    //Update task to the new values and add it to the tasks to update array
    task.taskList = destinationList;
    
    //If an order has not been passed, put the task at the end of the destination list
    if (order) {
        task.order = order;
    } else {
        task.order = [NSNumber numberWithUnsignedLong:destinationList.tasks.count];
    }
    
    [tasksToUpdate addObject:task];
    
    [currentList.tasks removeObject:task];
    [destinationList.tasks insertObject:task atIndex:[order integerValue]];
    
    [self updateTaskOrdersInSet:currentList.tasks];
    [tasksToUpdate addObjectsFromArray:currentList.tasks.array];
    
    [self updateTaskOrdersInSet:destinationList.tasks];
    [tasksToUpdate addObjectsFromArray:destinationList.tasks.array];
    
    //Send updates to the data service
    [self.dataService updateTasks:tasksToUpdate
                  completionBlock:^{
                      [KBNUpdateUtils firebasePostToFirebaseRoot:self.fireBaseRootReference withObject:FIREBASE_TASK
                                                        withType:FIREBASE_TASK_CHANGE
                                                projectID:task.project.projectId];
                      onCompletion();
                  }
                       errorBlock:onError];
}

- (void)updateTaskOrdersInSet:(NSMutableOrderedSet*)set {
    for (NSUInteger index = 0; index < set.count; index++) {
        KBNTask *taskToReorder = [set objectAtIndex:index];
        taskToReorder.order = [NSNumber numberWithInteger:index];
    }
}

- (void)createTasks:(NSArray*)tasks
    completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    [self.dataService createTasks:tasks completionBlock:^(NSDictionary *records) {
        if (tasks.count >0) {
            [KBNUpdateUtils firebasePostToFirebaseRoot:self.fireBaseRootReference withObject:FIREBASE_TASK withType:FIREBASE_TASK_ADD projectID:((KBNTask *)tasks[0]).project.projectId];
        }
        onCompletion(records);
    } errorBlock:onError ];
}

- (void)getUpdatedTasksForProject:(NSString*)projectId withModifiedDate: (NSString*)lastDate completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    [self.dataService getTasksUpdatedForProject:projectId fromDate:lastDate completionBlock:^(NSDictionary *records) {
        onCompletion([self activeRecordsFromDictionary:records]);
    } errorBlock:onError];
}

-(void)updateTask:(KBNTask*)task onSuccess:(KBNConnectionSuccessBlock)onSuccess failure:(KBNConnectionErrorBlock)onError{
    
    if (task.name.length) {
        [self.dataService updateTasks:@[task]
                      completionBlock:^{
                          [KBNUpdateUtils firebasePostToFirebaseRootWithName:self.fireBaseRootReference withObject:FIREBASE_TASK
                                                            withName:task.name
                                                             withDescription:task.taskDescription
                                                    projectID:task.project.projectId];
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
