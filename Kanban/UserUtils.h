//
//  UserUtils.h
//  Kanban
//
//  Created by Maximiliano Casal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface UserUtils : NSObject

+(void) saveUsernameInUserDefaults:(NSString *) username;
+ (BOOL)hasUserLogged;

@end
