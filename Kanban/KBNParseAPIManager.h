//
//  KBNParseAPIManager.h
//  Kanban
//
//  Created by Guillermo Apoj on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNUser.h"
#import <AFNetworking.h>
#import "KBNConstants.h"
#import "KBNProject.h"

typedef void (^KBNParseErrorBlock) (NSError *error);
typedef void(^KBNParseSuccesBlock)() ;


@interface KBNParseAPIManager : NSObject

//User functions
+(void) createUser: (KBNUser *) user completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError;

//Projects Functions
+(void) createProject: (KBNProject *) project completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError;
+(void) editProject: (NSString *)name newDescription:newDescription completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError;
+(void) removeProject: (NSString *)name completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError;
+(KBNProject*) getProjectWithName: (NSString*)name errorBlock:(KBNParseErrorBlock)onError;
+(NSArray*) getProjects:(KBNParseErrorBlock)onError;

@end
