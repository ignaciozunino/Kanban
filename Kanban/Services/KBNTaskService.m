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

-(void)moveTask:(NSString *)taskId toList:(NSString *)taskListId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    [self.dataService moveTask:taskId toList:taskListId completionBlock:onCompletion errorBlock:onError];
}

-(void)getTasksForProject:(NSString *)projectId completionBlock:(KBNConnectionSuccessDictionaryBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    [self.dataService getTasksForProject:projectId completionBlock:onCompletion errorBlock:onError];
}

@end