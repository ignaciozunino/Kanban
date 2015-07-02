//
//  KBNProjectParseAPIManager.h
//  Kanban
//
//  Created by Guillermo Apoj on 20/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//


#import "KBNProject.h"
#import "KBNParseRequestOperationManager.h"

@interface KBNProjectParseAPIManager : NSObject

//Projects Functions
- (void)createProject:(KBNProject*)project withLists:(NSArray*)lists completionBlock:(KBNSuccessDictionaryBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)setUsersList:(NSArray*)emailAddresses
        toProjectId:(NSString*)aProjectId
    completionBlock:(KBNSuccessBlock)onSuccess
         errorBlock:(KBNErrorBlock)onError;

- (void) editProject: (NSString*)projectID withNewName: (NSString*) newName withNewDesc: (NSString*) newDesc completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void) getProjectWithProjectID: (NSString*)projectID successBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)getProjectsFromUsername:(NSString*) username onSuccessBlock:(KBNSuccessDictionaryBlock) onSuccess errorBlock:(KBNErrorBlock)onError;

- (void)getProjectsFromUsername:(NSString*) username updatedAfter:(NSString*) lastUpdate onSuccessBlock:(KBNSuccessDictionaryBlock) onSuccess errorBlock:(KBNErrorBlock)onError;

- (void)updateProjects:(NSArray*)projects completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError;


@property KBNParseRequestOperationManager * afManager;

@end





