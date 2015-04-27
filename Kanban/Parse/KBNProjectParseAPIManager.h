//
//  KBNProjectParseAPIManager.h
//  Kanban
//
//  Created by Guillermo Apoj on 20/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "AFHTTPRequestOperationManager+KBNParseAPIManager.h"
#import "KBNProject.h"
#import "KBNParseAPIManager.h"

@interface KBNProjectParseAPIManager : KBNParseAPIManager
//Projects Functions
-(void) createProject: (KBNProject *) project completionBlock:(KBNConnectionSuccesBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;
-(void) editProject: (NSString *)name newDescription:newDescription completionBlock:(KBNConnectionSuccesBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;
-(void) removeProject: (NSString *)name completionBlock:(KBNConnectionSuccesBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;
-(KBNProject*) getProjectWithName: (NSString*)name errorBlock:(KBNConnectionErrorBlock)onError;
-(NSArray*) getProjects:(KBNConnectionErrorBlock)onError;


@end
