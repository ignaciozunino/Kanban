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

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

-(void)createTaskList:(NSString *)name withProject:(KBNProject *)project success:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure
{
    if ([name isEqualToString:@""] || !name) {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": CREATING_TASKLIST_WITHOUT_NAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-102
                                            userInfo:info];
        failure(errorPtr);
    }else{
        
        KBNTaskList *taskList = [[KBNTaskList alloc]initWithEntity:[NSEntityDescription entityForName:ENTITY_TASK_LIST inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        taskList.name = name;
        [self.dataService createTaskList:taskList completionBlock:success errorBlock:failure];
        
    }
}

-(void)getTaskListsOnSuccess:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure
{
    [self.dataService getTaskListOnSuccess:success failure:failure];
}

-(void)getTaskListsForProject:(KBNProject *)project success:(KBNConnectionSuccessDictionaryBlock)success failure:(KBNConnectionErrorBlock)failure
{
}


@end
