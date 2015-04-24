//
//  KBNProxy.h
//  Kanban
//
//  Created by Guillermo Apoj on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNUserParseAPIManager.h"
#import "KBNUser.h"
#import "KBNUserUtils.h"
#import "KBNAlertUtils.h"
#import "KBNConstants.h"

@interface KBNUserService : NSObject

+(KBNUserService *) sharedInstance;

-(void)createUser:(NSString*)username withPasword:(NSString*)password completionBlock:(KBNConnectionSuccesBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

@property KBNUserParseAPIManager* dataService;

@end
