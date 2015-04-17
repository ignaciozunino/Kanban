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

+(void) saveUsername:(NSString *) username;
+ (BOOL)hasUserBeenCreated;
+(BOOL) isValidUsername:(NSString*) username;
+(BOOL) isValidPassword:(NSString*) password;
@end
