//
//  KBNUserParseAPIManager.h
//  Kanban
//
//  Created by Guillermo Apoj on 20/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNParseAPIManager.h"

@interface KBNUserParseAPIManager : KBNParseAPIManager
//User functions
-(void) createUser: (KBNUser *) user completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError;

@property AFHTTPRequestOperationManager* afManager;

@end
