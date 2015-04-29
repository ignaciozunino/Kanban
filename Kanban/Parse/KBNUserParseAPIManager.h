//
//  KBNUserParseAPIManager.h
//  Kanban
//
//  Created by Guillermo Apoj on 20/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//


#import "KBNUser.h"

#import "KBNParseRequestOperationManager.h"


@interface KBNUserParseAPIManager :NSObject
//User functions
-(void) createUser:(KBNUser *) user completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;

@property KBNParseRequestOperationManager * afManager;

@end
