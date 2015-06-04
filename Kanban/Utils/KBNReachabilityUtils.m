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
#import "AFNetworkReachabilityManager.h"

@implementation KBNReachabilityUtils

bool online;

+ (BOOL)isOnline {
    return online;
}

+ (BOOL)isOffline {
    return ![self isOnline];
}

+ (void)reachabilitySetup {
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            online = NO;
        } else {
            online = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:ONLINE object:nil];
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

@end
