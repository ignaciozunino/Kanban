//
//  KBNTaskListService.m
//  Kanban
//
//  Created by Lucas on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskListService.h"
#import "KBNReachabilityUtils.h"

@implementation KBNTaskListService

+(KBNTaskListService *) sharedInstance{
    
    static  KBNTaskListService *inst = nil;
    
    @synchronized(self){
        if (!inst) {
            inst = [[self alloc] init];
            inst.dataService = [[KBNTaskListParseAPIManager alloc]init];
            inst.fireBaseRootReference = [[Firebase alloc] initWithUrl:FIREBASE_BASE_URL];
        }
    }
    return inst;
}

-(void)getTaskListsForProject:(KBNProject*)project completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    // If the project was created offline, it will not hava a projectId, so return.
    if (!project.projectId) {
        return;
    }
    
    [self.dataService getTaskListsForProject:project.projectId completionBlock:^(NSDictionary *records) {
        NSArray *results = [KBNTaskListUtils taskListsFromDictionary:records key:@"results" forProject:project];
        
        // TaskLists have already been inserted in context.
        // Mark them as synchronized and update context.
        for (KBNTaskList *taskList in results) {
            if (!taskList.isSynchronized) {
                taskList.synchronized = [NSNumber numberWithBool:YES];
            }
        }
        [[KBNCoreDataManager sharedInstance] saveContext];
        
        onCompletion(results);
        
    } errorBlock:onError];
}

- (BOOL)hasCountLimitBeenReached:(KBNTaskList*)taskList {
    return ([taskList.tasks count] > LIMIT_TASKLIST_ITEMS);
}

- (void)moveTaskList:(KBNTaskList *)taskList toOrder:(NSNumber*)order completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    KBNProject *project = taskList.project;
    
    [project removeTaskListsObject:taskList];
    [project insertObject:taskList inTaskListsAtIndex:[order integerValue]];
    
    [self updateTaskListOrdersInSet:project.taskLists];
    
    [self.dataService updateTaskLists:project.taskLists.array completionBlock:onCompletion errorBlock:onError];
}

- (void)createTaskList:(KBNTaskList*)taskList forProject:(KBNProject*)project inOrder:(NSNumber *)order completionBlock:(KBNSuccessTaskListBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    
    taskList.project = project;
    taskList.order = order;
    
    [project insertObject:taskList inTaskListsAtIndex:[order integerValue]];
    [self updateTaskListOrdersInSet:project.taskLists];
    
    // TaskList object creation completed offline. Save context.
    [[KBNCoreDataManager sharedInstance] saveContext];

    if ([KBNReachabilityUtils isOnline] && project.projectId) {
        __weak typeof(self) weakself = self;
        [self.dataService updateTaskLists:project.taskLists.array completionBlock:^(NSDictionary *records) {
            taskList.taskListId = [records objectForKey:PARSE_OBJECTID];
            if ([project isShared]) {
                NSArray *array = [NSArray arrayWithObject:taskList];
                NSDictionary *data = [KBNTaskListUtils taskListsJson:array];
                [KBNUpdateUtils postToFirebase:weakself.fireBaseRootReference changeType:KBNChangeTypeTaskListUpdate projectId:project.projectId data:data];
            }
            onCompletion(taskList);
        } errorBlock:^(NSError *error){
            [project removeTaskListsObject:taskList];
            [self updateTaskListOrdersInSet:project.taskLists];
            onError(error);
        }];
    } else {
        onCompletion(taskList);
    }
}

- (void)updateTaskListOrdersInSet:(NSOrderedSet*)set {
    
    for (NSUInteger index = 0; index < set.count; index++) {
        KBNTaskList *taskListToReorder = [set objectAtIndex:index];
        taskListToReorder.order = [NSNumber numberWithInteger:index];
    }
}

@end
