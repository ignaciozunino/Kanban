//
//  KBNProjectService.h
//  Kanban
//
//  Created by Maximiliano Casal on 4/20/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNProjectParseAPIManager.h"
#import "KBNProjectUtils.h"
#import "KBNAppDelegate.h"

@interface KBNProjectService : NSObject
+(KBNProjectService *) sharedInstance;

-(void)createProject:(NSString*)name withDescription:(NSString*)projectDescription completionBlock:(KBNConnectionSuccesBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

-(void)editProject:(NSString*)name withDescription:(NSString*)newDescription completionBlock:(KBNConnectionSuccesBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

-(void)removeProject:(NSString*)name completionBlock:(KBNConnectionSuccesBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

-(KBNProject*) getProjectWithName: (NSString*)name errorBlock:(KBNConnectionErrorBlock)onError;

-(void)getProjectsOnSuccess:(KBNConnectionSuccesArrayBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

@property KBNProjectParseAPIManager* dataService;

@end
