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

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}


- (void)createTask:(NSString*)name withDescription:(NSString*)taskDescription withTaskList:(KBNTaskList*)taskList withProject:(KBNProject*)project success:(KBNConnectionSuccessBlock)success failure:(KBNConnectionErrorBlock)failure {
    
    if ([name isEqualToString:@""] || !name) {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": CREATING_TASK_WITHOUT_NAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-102
                                            userInfo:info];
        failure(errorPtr);
    }else{
        
        KBNTask *task = [[KBNTask alloc]initWithEntity:[NSEntityDescription entityForName:ENTITY_TASK inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        task.name = name;
        task.taskDescription = taskDescription;
        [self.dataService createTask:task completionBlock:success errorBlock:failure];
        
    }
    
}




- (void)createTask:(KBNTask*)task success:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure {
    
        [self.dataService createTask:task completionBlock:success errorBlock:failure];
    
}

- (void)moveTask:(KBNTask*)task toList:(KBNTaskList*)list success:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure {
    
    [self.dataService moveTask:task toList:list success:success failure:failure];
}

- (void)getTasksOnSuccess:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure {
    
    [self.dataService getTasksOnSuccess:success failure:failure];
}

- (void)getTasksForProject:(KBNProject*)project success:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure {
    [self.dataService getTasksForProject:(KBNProject*)project success:success failure:failure];
}


@end
