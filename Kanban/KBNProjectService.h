//
//  KBNProjectService.h
//  Kanban
//
//  Created by Maximiliano Casal on 4/20/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNParseAPIManager.h"
#import "KBNProjectUtils.h"

@interface KBNProjectService : NSObject
+(KBNProjectService *) sharedInstance;

-(void)createProject:(NSString*)name withDescription:(NSString*)projectDescription completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError;

-(void)editProject:(NSString*)name withDescription:(NSString*)newDescription completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError;

-(void)removeProject:(NSString*)name completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError;

-(KBNProject*) getProjectWithName: (NSString*)name errorBlock:(KBNParseErrorBlock)onError;

-(NSArray*) getProjects:(KBNParseErrorBlock)onError;

@end
