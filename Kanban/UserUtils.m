//
//  UserUtils.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "UserUtils.h"

@implementation UserUtils

+(void) saveUsername:(NSString *)username{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:USERNAME_KEY];
    [defaults synchronize];
}

+ (BOOL)hasUserBeenCreated {
    //verifying if we allready signed in before
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:USERNAME_KEY];
    if (username) {
        return YES;
    }
    return NO;
}

//Validate the email has a correct format
+(BOOL) isValidUsername:(NSString*) username{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:username];
}

//Validate the password has at least 6 characters, one letter and one numbercp
+(BOOL) isValidPassword:(NSString*) password{
    if ([password length]<6 || [password length]>32) return NO;  // too long or too short
    NSRange rang;
    rang = [password rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
    if ( !rang.length ) return NO;  // no letter
    rang = [password rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
    if ( !rang.length )  return NO;  // no number;
    return YES;
}

@end
