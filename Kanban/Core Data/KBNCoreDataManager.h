//
//  CoreDataManager.h
//  Kanban
//
//  Created by Lucas on 5/19/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "KBNConstants.h"
#import "KBNProject.h"
#import "KBNTask.h"
#import "KBNTaskList.h"
#import "KBNProjectTemplate.h"

@interface KBNCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL*)applicationDocumentsDirectory;

+ (instancetype) sharedInstance;

- (void)getProjectsOnSuccess:(KBNSuccessArrayBlock)onSuccess errorBlock:(KBNErrorBlock)onError;

-(void)getUnUpdatedProyectsOnSucess:(KBNSuccessArrayBlock)onSucess errorBlock:(KBNErrorBlock)onError;

- (KBNProject*)projectWithParams:(NSDictionary *)params;

- (KBNProject *)projectFromId:(NSString *)project;

- (void)getTasksForProject:(NSString*)projectId completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (KBNTask*)taskForProject:(KBNProject*)project taskList:(KBNTaskList*)taskList params:(NSDictionary*)params;

- (NSArray*)mockTasksForProject:(KBNProject*)project taskList:(KBNTaskList*)taskList quantity:(NSUInteger)quantity;

- (void)tasksForProjectId:(NSString*)projectId completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)getTaskListsForProject:(NSString*)projectId completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (KBNTaskList*)taskListForProject:(KBNProject *)project params:(NSDictionary *)params;

- (KBNProjectTemplate*)projectTemplateWithParams:(NSDictionary *)params;

@end