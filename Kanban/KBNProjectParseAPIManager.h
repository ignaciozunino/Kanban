//
//  KBNProjectParseAPIManager.h
//  Kanban
//
//  Created by Guillermo Apoj on 20/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNParseAPIManager.h"

@interface KBNProjectParseAPIManager : KBNParseAPIManager
//Projects Functions
+(void) createProject: (KBNProject *) project completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError;
+(void) editProject: (NSString *)name newDescription:newDescription completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError;
+(void) removeProject: (NSString *)name completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError;
+(KBNProject*) getProjectWithName: (NSString*)name errorBlock:(KBNParseErrorBlock)onError;
+(NSArray*) getProjects:(KBNParseErrorBlock)onError;


@end
