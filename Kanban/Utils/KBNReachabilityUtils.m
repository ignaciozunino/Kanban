//
//  KBNReachabilityUtils.m
//  Kanban
//
//  Created by Marcelo Dessal on 6/3/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNReachabilityUtils.h"
#import "KBNAppDelegate.h"
#import "KBNConstants.h"

@implementation KBNReachabilityUtils

+ (BOOL)isOnline {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] networkAvailable];
}

+ (BOOL)isOffline {
    return ![self isOnline];
}

@end
