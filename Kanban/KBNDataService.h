//
//  KBNProxy.h
//  Kanban
//
//  Created by Guillermo Apoj on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNParseAPIManager.h"
#import "KBNUser.h"
#import "UserUtils.h"
#import "AlertUtils.h"
#import "constants.h"

@interface KBNDataService : NSObject

+(KBNDataService *) sharedInstance;

-(void)createUser:(NSString*)username withPasword:(NSString*)password completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError;
@end
