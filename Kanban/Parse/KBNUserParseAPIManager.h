//
//  KBNUserParseAPIManager.h
//  Kanban
//
//  Created by Guillermo Apoj on 20/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "AFHTTPRequestOperationManager+KBNParseAPIManager.h"
#import "KBNUser.h"
#import "KBNParseAPIManager.h"

@interface KBNUserParseAPIManager :KBNParseAPIManager
//User functions
-(void) createUser:(KBNUser *) user completionBlock:(KBNConnectionSuccesBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError;



@end
