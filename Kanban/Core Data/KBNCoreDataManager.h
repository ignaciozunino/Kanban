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

@interface KBNCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL*)applicationDocumentsDirectory;

+ (instancetype) sharedInstance;

- (void)getProjectsOnSuccess:(KBNSuccessArrayBlock)onSuccess errorBlock:(KBNErrorBlock)onError;

- (void)getTasksForProject:(NSString*)projectId completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)getTaskListsForProject:(NSString*)projectId completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError;


@end