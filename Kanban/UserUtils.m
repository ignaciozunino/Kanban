//
//  UserUtils.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "UserUtils.h"

@implementation UserUtils

+(void) saveUsernameInUserDefaults:(NSString *)username{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:USERNAME_KEY];
    [defaults synchronize];
}

+ (BOOL)hasUserLogged {
    //verifying if we allready signed in before
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:USERNAME_KEY];
    if (username) {
        return YES;
    }
    return NO;
}
@end
