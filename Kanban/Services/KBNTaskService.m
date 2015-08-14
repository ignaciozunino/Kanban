//
//  KBNTaskService.m
//  Kanban
//
//  Created by Lucas on 4/24/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskService.h"
#import "KBNTaskUtils.h"
#import "KBNReachabilityUtils.h"
#import "NSDate+Utils.h"

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

-(instancetype)init {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncTasksOnParse) name:CONNECTION_ONLINE object:nil];
    return self;
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
            aTask.active = [NSNumber numberWithBool:YES];
            [[KBNCoreDataManager sharedInstance] saveContext];
            
            if ([KBNReachabilityUtils isOnline] &&
                aTask.project.projectId && aTask.taskList.taskListId) {
                
                __weak typeof(self) weakself = self;
                [self.dataService createTaskWithName:aTask.name taskDescription:aTask.taskDescription order:aTask.order projectId:aTaskList.project.projectId taskListId:aTaskList.taskListId priority:aTask.priority completionBlock:^(NSDictionary *params) {
                    aTask.taskId = [params objectForKey:@"taskId"];
                    aTask.updatedAt = [params objectForKey:@"updatedAt"];
                    aTask.synchronized = [NSNumber numberWithBool:YES];
                    
                    // Save context to save parse object id's in Core Data
                    [[KBNCoreDataManager sharedInstance] saveContext];
                    
                    if ([aTask.project isShared]) {
                        [KBNUpdateUtils postToFirebase:weakself.fireBaseRootReference changeType:KBNChangeTypeTaskAdd projectId:aTask.project.projectId data:[KBNTaskUtils tasksJson:@[aTask]]];
                    }
                    onCompletion(aTask);
                } errorBlock:onError];
            } else {
                onCompletion(aTask);
            }
        }
    }
}

- (void)getTasksForProject:(KBNProject*)project completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    // If the project was created offline, it will not hava a projectId, so return.
    if (!project.projectId) {
        return;
    }
    [self.dataService getTasksForProject:project.projectId completionBlock:^(NSDictionary *records) {
        NSArray *results = [KBNTaskUtils tasksFromDictionary:records key:@"results" forProject:project];
        
        // Any change in tasks has already been changed in context.
        // Mark tasks as synchronized and save context.
        for (KBNTask *task in results) {
            task.synchronized = [NSNumber numberWithBool:YES];
        }
        [[KBNCoreDataManager sharedInstance] saveContext];
        
        onCompletion(results);
        
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
    __weak typeof(self) weakself = self;
    [self.dataService updateTasks:tasksToUpdate completionBlock:^(NSDictionary *records) {
        
        
        if ([task.project isShared]) {
            [KBNUpdateUtils postToFirebase:weakself.fireBaseRootReference changeType:KBNChangeTypeTaskRemove projectId:task.project.projectId data:[KBNTaskUtils tasksJson:@[task]]];
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
    
    if ([currentList.taskListId isEqualToString:destinationList.taskListId]) {
        [currentList removeTasksObject:task];
        [destinationList insertObject:task inTasksAtIndex:[order integerValue]];
    }
    
    [self updateTaskOrdersInSet:currentList.tasks];
    [tasksToUpdate addObjectsFromArray:currentList.tasks.array];
    
    if (![currentList.taskListId isEqualToString:destinationList.taskListId]) {
        [self updateTaskOrdersInSet:destinationList.tasks];
        [tasksToUpdate addObjectsFromArray:destinationList.tasks.array];
    }
    
     //Send updates to the data service
    __weak typeof(self) weakself = self;
    [self.dataService updateTasks:tasksToUpdate
                  completionBlock:^(NSDictionary *records) {
                      if ([task.project isShared]) {
                          [KBNUpdateUtils postToFirebase:weakself.fireBaseRootReference changeType:KBNChangeTypeTaskMove projectId:task.project.projectId data:[KBNTaskUtils tasksJson:tasksToUpdate]];
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
    __weak typeof(self) weakself = self;
    [self.dataService createTasks:tasks completionBlock:^(NSDictionary *records) {
        KBNProject *project = [[tasks firstObject] project];
        if ([project isShared]) {
            [KBNUpdateUtils postToFirebase:weakself.fireBaseRootReference changeType:KBNChangeTypeTasksUpdate projectId:project.projectId data:[KBNTaskUtils tasksJson:tasks]];
        }
        if ([tasks count] == [records count]) {
            NSUInteger i = 0;
            for (NSDictionary *record in records) {
                NSDictionary *success = [record objectForKey:@"success"];
                KBNTask *task = [tasks objectAtIndex:i];
                task.taskId = [success objectForKey:PARSE_OBJECTID];
                NSDate *createdAt = [NSDate dateFromParseString:[success objectForKey:PARSE_CREATED_COLUMN]];
                task.updatedAt = createdAt;
                NSError *error = nil;
                [task.managedObjectContext save:&error];
                if (error != nil) {
                    onError(error);
                }
                i++;
            }
        }
        onCompletion(tasks);
    } errorBlock:onError ];
}

-(void)updateTask:(KBNTask*)task onSuccess:(KBNSuccessBlock)onSuccess failure:(KBNErrorBlock)onError{
    
    if (task.name.length) {
        __weak typeof(self) weakself = self;
        [self.dataService updateTasks:@[task]
                      completionBlock:^(NSDictionary *records) {
                          if ([task.project isShared]) {
                              [KBNUpdateUtils postToFirebase:weakself.fireBaseRootReference changeType:KBNChangeTypeTaskUpdate projectId:task.project.projectId data:[KBNTaskUtils tasksJson:@[task]]];
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

- (void)tasksForProject:(KBNProject *)project completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    [[KBNCoreDataManager sharedInstance] tasksForProjectId:project.projectId completionBlock:onCompletion errorBlock:onError];
}

-(void)syncTasksOnParse {
    [[KBNCoreDataManager sharedInstance] getUnUpdatedTasksOnSuccess:^(NSArray *records) {
        for (KBNTask *task in records) {
            if(task.isSynchronized) {
                __weak typeof(self) weakself = self;
                [self.dataService updateTasks:@[task]
                              completionBlock:^(NSDictionary *records) {
                                  if ([task.project isShared]) {
                                      [KBNUpdateUtils postToFirebase:weakself.fireBaseRootReference changeType:KBNChangeTypeTaskUpdate projectId:task.project.projectId data:[KBNTaskUtils tasksJson:@[task]]];
                                  }
                              }
                                   errorBlock:^(NSError *error) {
                                       NSLog(@"[KBNTaskService syncTasksOnParse] - Error: Could not update task",nil);
                                   }];
            }
            else {
                if (task.project.isSynchronized && task.taskList.isSynchronized) {
                    __weak typeof(self) weakself = self;
                    [self.dataService createTaskWithName:task.name taskDescription:task.taskDescription order:task.order projectId:task.project.projectId taskListId:task.taskList.taskListId priority:task.priority completionBlock:^(NSDictionary *params) {
                        task.taskId = [params objectForKey:@"taskId"];
                        task.updatedAt = [params objectForKey:@"updatedAt"];
                        task.synchronized = [NSNumber numberWithBool:YES];
                        
                       
                        NSError *error = nil;
                        [task.managedObjectContext save:&error];
                        if (error) {
                            NSLog(@"[KBNTaskService syncTasksOnParse] - Error: %@", error);
                        }
                        
                        if ([task.project isShared]) {
                            [KBNUpdateUtils postToFirebase:weakself.fireBaseRootReference changeType:KBNChangeTypeTaskAdd projectId:task.project.projectId data:[KBNTaskUtils tasksJson:@[task]]];
                        }
                    } errorBlock:^(NSError *error) {
                        NSLog(@"[KBNTaskService syncTasksOnParse] - Error: Could not create task");
                    }];
                }
            }
        }
    } errorBlock:^(NSError *error) {
        NSLog(@"Error Recovering Projects from coredata");
    }];
}

@end
