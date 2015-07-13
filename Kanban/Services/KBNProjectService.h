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
#import "KBNTaskListUtils.h"
#import "KBNAppDelegate.h"
#import "KBNProjectTemplate.h"
#import <Firebase/Firebase.h>
#import "KBNUpdateUtils.h"

@interface KBNProjectService : NSObject

@property KBNProjectParseAPIManager* dataService;
@property Firebase* fireBaseRootReference;

+ (KBNProjectService *)sharedInstance;

-(void)syncProjectsOnParse;

- (void)createProject:(NSString*)name withDescription:(NSString*)projectDescription withTemplate:(KBNProjectTemplate*)projectTemplate completionBlock:(KBNSuccessProjectBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)editProject: (KBNProject*)project withNewName:(NSString*)newName withDescription:(NSString*)newDescription completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)addUser:(NSString*)emailAddress toProject:(KBNProject*)aProject completionBlock:(KBNSuccessBlock)onSuccess errorBlock:(KBNErrorBlock)onError;

- (void)removeProject:(KBNProject*)project completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)getProjectsOnSuccessBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

- (void)getProjectsUpdate;

@end
