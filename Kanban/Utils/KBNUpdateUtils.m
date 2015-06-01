//
//  KBNUpdateUtils.m
//  Kanban
//
//  Created by Guillermo Apoj on 8/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNUpdateUtils.h"

@implementation KBNUpdateUtils


//update the tasks retrieved in the dictionary or if is not previusly exists add the new task
+(void) updateExistingTasksFromDictionary:(NSDictionary *) updatedTasks inArray:(NSMutableArray *)array forProject:(KBNProject*)project
{
    for (NSDictionary* params in updatedTasks) {
        NSString* taskListId = [params objectForKey:PARSE_TASK_TASK_LIST_COLUMN];
        KBNTaskList *taskList;
        BOOL isactive = ((NSNumber*)[params objectForKey:PARSE_TASK_ACTIVE_COLUMN]).boolValue;
        if (isactive){
            
            for (KBNTaskList* list in project.taskLists) {
                if ([list.taskListId isEqualToString:taskListId]) {
                    taskList = list;
                    KBNTask *t = [KBNTaskUtils taskForProject:project taskList:taskList params:params];
                    NSInteger index = [self indexOfTask:[params objectForKey:PARSE_OBJECTID]inArray:array];
                    if (index!= -1) {
                        [array replaceObjectAtIndex:index withObject:t];
                    }else{
                        [array addObject:t];
                    }
                    break;
                }
            }
            
        }else{///if it is not active we look if it was removed
            //here we only care about the task id to compare
            NSInteger index = [self indexOfTask:[params objectForKey:PARSE_OBJECTID]inArray:array];
            if (index != -1) {
                [array removeObjectAtIndex:index];
            }
        }
    }
}

//returns the index of the task in the updatedTask array or -1 if is not in the array
+(NSInteger) indexOfTask:(NSString*)taskid inArray:(NSArray *)array{
    for (int i = 0; i<array.count; i++) {
        if([taskid isEqualToString:((KBNTask*)[array objectAtIndex:i]).taskId ]){
            return i;
        }
    }
    return -1;
}
//update the projects retrieved in the dictionary or if not previously exists add the new task
+(void) updateExistingProjectsFromArray:(NSArray *) updatedProjects inArray:(NSMutableArray *)array
{
    for (KBNProject *project in updatedProjects) {
        NSInteger index = [self indexOfProject:project.projectId inArray:array];
        if (index!= -1) {
            [array replaceObjectAtIndex:index withObject:project];
            
        }else{
            [array addObject:project];
        }
    }
}

//returns the index of the projrct in the updatedTask array or -1 if is not in the array
+(NSInteger) indexOfProject:(NSString*)projectid inArray:(NSArray *)array{
    for (int i = 0; i<array.count; i++) {
        if([projectid isEqualToString:((KBNProject*)[array objectAtIndex:i]).projectId ]){
            return i;
        }
    }
    return -1;
}

+(void) firebasePostToFirebaseRoot:(Firebase *)rootReference withObject:(NSString*) objectName withType:(NSString*) type projectID:(NSString*)projectID{
    NSString* path = [NSString stringWithFormat:@"%@/%@", projectID, objectName];
    id rootRef = [rootReference childByAppendingPath:path];
    NSDictionary * dataToPass = @{FIREBASE_TYPE_OF_CHANGE:type, @"User":[KBNUserUtils getUsername]};
    [rootRef setValue:dataToPass];
}

+(void) firebasePostToFirebaseRootWithName:(Firebase *)rootReference withObject:(NSString*) objectName withName:(NSString*) name projectID:(NSString*)projectID{
    NSString* path = [NSString stringWithFormat:@"%@/%@", projectID, objectName];
    id rootRef = [rootReference childByAppendingPath:path];
    NSDictionary * dataToPass = @{FIREBASE_EDIT_NAME_CHANGE:name, @"User":[KBNUserUtils getUsername]};
    [rootRef setValue:dataToPass];
}
@end
