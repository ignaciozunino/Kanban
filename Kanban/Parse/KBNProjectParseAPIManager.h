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
-(void) createProject: (KBNProject *) project completionBlock:(KBNConnectionSuccessArrayBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;
- (void) editProject: (NSString*)projectID withNewName: (NSString*) newName withNewDesc: (NSString*) newDesc completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;
-(void) getProjectWithProjectID: (NSString*)projectID successBlock:(KBNConnectionSuccessArrayBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

-(void) removeProject: (NSString *)name completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;
-(KBNProject*) getProjectWithName: (NSString*)name errorBlock:(KBNConnectionErrorBlock)onError;
- (void)getProjectsFromUsername:(NSString*) username onSuccessBlock:(KBNConnectionSuccessDictionaryBlock) onSuccess errorBlock:(KBNConnectionErrorBlock)onError;
- (void)getProjectsFromUsername:(NSString*) username updatedAfter:(NSString*) lastUpdate onSuccessBlock:(KBNConnectionSuccessDictionaryBlock) onSuccess errorBlock:(KBNConnectionErrorBlock)onError;

@property KBNParseRequestOperationManager * afManager;

@end





