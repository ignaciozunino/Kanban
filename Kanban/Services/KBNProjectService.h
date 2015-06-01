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
#import "KBNProjectTemplate.h"
#import <Firebase/Firebase.h>
#import "KBNUpdateUtils.h"

@interface KBNProjectService : NSObject
+(KBNProjectService *) sharedInstance;

-(void)createProject:(NSString*)name withDescription:(NSString*)projectDescription forUser:(NSString*) username completionBlock:(KBNConnectionSuccessProjectBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

-(void)createProject:(NSString*)name withDescription:(NSString*)projectDescription forUser:(NSString*) username withTemplate:(KBNProjectTemplate*)projectTemplate completionBlock:(KBNConnectionSuccessProjectBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

-(void)editProject: (KBNProject*)project withNewName:(NSString*)newName withDescription:(NSString*)newDescription completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

-(void)addUser:(NSString*)emailAddress
     toProject:(KBNProject*)aProject
completionBlock:(KBNConnectionSuccessBlock)onSuccess
    errorBlock:(KBNConnectionErrorBlock)onError;

-(void)removeProject:(KBNProject*)project completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

-(KBNProject*) getProjectWithName: (NSString*)name errorBlock:(KBNConnectionErrorBlock)onError;

-(void)getProjectsForUser: (NSString*) username onSuccessBlock:(KBNConnectionSuccessArrayBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

-(void)getProjectsForUser: (NSString*) username updatedAfter:(NSString*) lastUpdate  onSuccessBlock:(KBNConnectionSuccessArrayBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

@property KBNProjectParseAPIManager* dataService;
@property Firebase* fireBaseRootReference;
@end
