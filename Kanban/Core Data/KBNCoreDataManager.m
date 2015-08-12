//
//  CoreDataManager.m
//  Kanban
//
//  Created by Lucas on 5/19/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNCoreDataManager.h"
#import "KBNUserUtils.h"
#import "NSDate+Utils.h"

@implementation KBNCoreDataManager

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype) sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.globant.SimpleKanban" in the application's documents directory.
    NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject]);
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Kanban" withExtension:@"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Kanban.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"CoreDataHelper.Error.CouldNotGetPersistentCoordinator" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Fetch Entity from Context
-(void)fetchEntitiesForClass:(Class)aClass withPredicate:(NSPredicate*)predicate inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext onSuccess:(KBNSuccessArrayBlock)onSuccess onError:(KBNErrorBlock)onError {
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:NSStringFromClass(aClass) inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray* fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"[ERROR][CoreDataHelper-fetchEntitiesForClass]%@",[error localizedDescription]);
        onError(error);
    } else {
        NSLog(@"No error fetching entities. All OK");
        onSuccess(fetchedObjects);
    }
}

#pragma mark - Project methods

- (void)getProjectsOnSuccess:(KBNSuccessArrayBlock)onSuccess errorBlock:(KBNErrorBlock)onError {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_PROJECT inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil) {
        onError(error);
    } else {
        // We filter records here because users is transformable
        NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"users contains[c] %@", [KBNUserUtils getUsername]];
        onSuccess([fetchedObjects filteredArrayUsingPredicate:aPredicate]);
    }
}

- (KBNProject*)projectWithParams:(NSDictionary *)params {
    
    KBNProject *project = nil;
    NSString *projectId = [params objectForKey:PARSE_OBJECTID];
    
    if (projectId) {
        project = [self projectFromId:projectId];
    }
    if (!project) {
        project = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_PROJECT inManagedObjectContext:[self managedObjectContext]];
    }
    
    [project setValue:[params objectForKey:PARSE_OBJECTID] forKey:@"projectId"];
    [project setValue:[params objectForKey:PARSE_PROJECT_NAME_COLUMN] forKey:@"name"];
    [project setValue:[params objectForKey:PARSE_PROJECT_DESCRIPTION_COLUMN] forKey:@"projectDescription"];
    [project setValue:[params objectForKey:PARSE_PROJECT_ACTIVE_COLUMN] forKey:@"active"];
    [project setValue:[params objectForKey:PARSE_PROJECT_USERSLIST_COLUMN] forKey:@"users"];
    [project setValue:[NSDate dateFromParseString:[params objectForKey:PARSE_UPDATED_COLUMN]] forKey:@"updatedAt"];
    
    return project;
}

- (KBNProject *)projectFromId:(NSString *)projectId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_PROJECT inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectId LIKE %@", projectId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    return [fetchedObjects firstObject];
}

#pragma mark - Task methods

- (void)getTasksForProject:(NSString*)projectId completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"project.projectId == %@", projectId];
    [self fetchEntitiesForClass:[KBNTask class] withPredicate:predicate inManagedObjectContext:[self managedObjectContext] onSuccess:onCompletion onError:onError];
}

- (KBNTask*)taskForProject:(KBNProject *)project taskList:(KBNTaskList *)taskList params:(NSDictionary *)params {
    
    KBNTask *task = nil;
    NSString *taskId = [params objectForKey:PARSE_OBJECTID];
    
    if (taskId) {
        task = [self taskFromId:taskId];
    }
    if (!task) {
        task = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TASK inManagedObjectContext:[self managedObjectContext]];
    }
    
    [task setValue:[params objectForKey:PARSE_OBJECTID] forKey:@"taskId"];
    [task setValue:[params objectForKey:PARSE_TASK_NAME_COLUMN] forKey:@"name"];
    [task setValue:[params objectForKey:PARSE_TASK_DESCRIPTION_COLUMN] forKey:@"taskDescription"];
    [task setValue:[params objectForKey:PARSE_TASK_ORDER_COLUMN] forKey:@"order"];
    [task setValue:[params objectForKey:PARSE_TASK_ACTIVE_COLUMN] forKey:@"active"];
    [task setValue:[NSDate dateFromParseString:[params objectForKey:PARSE_UPDATED_COLUMN]] forKey:@"updatedAt"];
    [task setValue:[params objectForKey:PARSE_TASK_PRIORITY_COLUMN] forKey:@"priority"];
    task.project = project;
    task.taskList = taskList;
    return task;
}

- (NSArray*)mockTasksForProject:(KBNProject*)project taskList:(KBNTaskList*)taskList quantity:(NSUInteger)quantity {
    
    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    KBNTask *task;
    
    for (NSUInteger i = 0; i < quantity; i++) {
        
        task = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TASK inManagedObjectContext:[self managedObjectContext]];
        
        [task setValue:[NSString stringWithFormat:@"Task%lu", (unsigned long)i] forKey:@"taskId"];
        [task setValue:[NSString stringWithFormat:@"Task%lu", (unsigned long)i] forKey:@"name"];
        [task setValue:@"Mock task for testing purposes" forKey:@"taskDescription"];
        [task setValue:[NSNumber numberWithUnsignedLong:i] forKey:@"order"];
        [task setValue:@YES forKey:@"active"];
        [task setValue:[NSNumber numberWithInteger:0] forKey:@"priority"];
        task.project = project;
        task.taskList = taskList;
        [tasks addObject:task];
    }
    
    return tasks;
}

- (KBNTask *)taskFromId:(NSString *)taskId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_TASK inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskId LIKE %@", taskId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    return [fetchedObjects firstObject];
}

- (void)tasksForProjectId:(NSString*)projectId completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_TASK inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(project.projectId LIKE %@) AND (active == %@)", projectId, [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortByTaskListDescriptor = [[NSSortDescriptor alloc] initWithKey:@"taskList.order" ascending:YES];
    NSSortDescriptor *sortByOrderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortByTaskListDescriptor, sortByOrderDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        onError(error);
    } else {
        onCompletion(fetchedObjects);
    }
}

#pragma mark - TaskList methods

- (void)getTaskListsForProject:(NSString*)projectId completionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"project.projectId == %@", projectId];
    [self fetchEntitiesForClass:[KBNTaskList class] withPredicate:predicate inManagedObjectContext:[self managedObjectContext] onSuccess:onCompletion onError:onError];
}

- (KBNTaskList*)taskListForProject:(KBNProject *)project params:(NSDictionary *)params {
    
    KBNTaskList *taskList = nil;
    NSString *taskListId = [params objectForKey:PARSE_OBJECTID];
    
    if (taskListId) {
        taskList = [self taskListFromId:taskListId];
    }
    if (!taskList) {
        taskList = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TASK_LIST inManagedObjectContext:[self managedObjectContext]];
    }
    
    [taskList setValue:[params objectForKey:PARSE_OBJECTID] forKey:@"taskListId"];
    [taskList setValue:[params objectForKey:PARSE_TASKLIST_NAME_COLUMN] forKey:@"name"];
    [taskList setValue:[params objectForKey:PARSE_TASKLIST_ORDER_COLUMN] forKey:@"order"];
    [taskList setValue:[NSDate dateFromParseString:[params objectForKey:PARSE_UPDATED_COLUMN]] forKey:@"updatedAt"];
    taskList.project = project;
    
    return taskList;
}

- (KBNTaskList *)taskListFromId:(NSString *)taskListId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_TASK_LIST inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskListId LIKE %@", taskListId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    return [fetchedObjects firstObject];
}

#pragma mark - Project Template methods

- (KBNProjectTemplate*)projectTemplateWithParams:(NSDictionary *)params {
    
    KBNProjectTemplate *template = nil;
    NSString *templateId = [params objectForKey:PARSE_OBJECTID];
    
    if (templateId) {
        template = [self projectTemplateFromId:templateId];
    }
    if (!template) {
        template = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_PROJECT_TEMPLATE inManagedObjectContext:[self managedObjectContext]];
    }
    
    [template setValue:[params objectForKey:PARSE_OBJECTID] forKey:@"projectTemplateId"];
    [template setValue:[params objectForKey:PARSE_PROJECT_TEMPLATE_NAME] forKey:@"name"];
    [template setValue:[params objectForKey:PARSE_PROJECT_TEMPLATE_LISTS] forKey:@"lists"];
    
    return template;
}

- (KBNProjectTemplate *)projectTemplateFromId:(NSString *)templateId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_PROJECT_TEMPLATE inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectTemplateId LIKE %@", templateId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    return [fetchedObjects firstObject];
}

@end