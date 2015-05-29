//
//  UserUtils.h
//  Kanban
//
//  Created by Maximiliano Casal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNConstants.h"

@interface KBNUserUtils : NSObject

+(void) saveUsername:(NSString *) username;
+ (BOOL)hasUserBeenCreated;
+(BOOL) isValidUsername:(NSString*) username;
+(BOOL) isValidPassword:(NSString*) password;
+ (NSString*)getUsername;
+ (NSString*)getUsernameForURL;
+ (NSString*)getUsernameForURLFromParse: (NSString*) username;

@end
