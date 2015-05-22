//
//  KBNTaskListService.m
//  Kanban
//
//  Created by Lucas on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskListService.h"

@implementation KBNTaskListService

+(KBNTaskListService *) sharedInstance{
    
    static  KBNTaskListService *inst = nil;
    
    @synchronized(self){
        if (!inst) {
            inst = [[self alloc] init];
            inst.dataService = [[KBNTaskListParseAPIManager alloc]init];
        }
    }
    return inst;
}

-(void)createTaskListWithName:(NSString *)name order:(NSNumber *)order projectId:(NSString *)projectId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {

    if (!name || [name isEqualToString:@""]) {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": CREATING_TASKLIST_WITHOUT_NAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-103 userInfo:info];
        onError(errorPtr);
    } else {
        [self.dataService createTaskListWithName:name order:order projectId:projectId completionBlock:onCompletion errorBlock:onError];
        
    }
}

-(void)getTaskListsForProject:(NSString *)projectId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    [self.dataService getTaskListsForProject:projectId completionBlock:onCompletion errorBlock:onError];
    
}

- (BOOL)hasCountLimitBeenReached:(KBNTaskList*)taskList {
    return ([taskList.tasks count] > LIMIT_TASKLIST_ITEMS);
}

- (void)moveTaskList:(KBNTaskList *)taskList toOrder:(NSNumber*)order completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    
    
}

- (void)createTaskList:(KBNTaskList*)taskList forProject:(KBNProject*)project inOrder:(NSNumber *)order completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    taskList.project = project;
    taskList.order = order;
    
    [project insertObject:taskList inTaskListsAtIndex:[order integerValue]];
    [self updateTaskListOrdersInSet:project.taskLists];
    
    [self.dataService updateTaskLists:project.taskLists.array completionBlock:onCompletion errorBlock:onError];
}

- (void)updateTaskListOrdersInSet:(NSOrderedSet*)set {
    
    for (NSUInteger index = 0; index < set.count; index++) {
        KBNTaskList *taskListToReorder = [set objectAtIndex:index];
        taskListToReorder.order = [NSNumber numberWithInteger:index];
    }
}

@end
