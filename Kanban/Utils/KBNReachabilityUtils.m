//
//  KBNReachabilityUtils.m
//  Kanban
//
//  Created by Marcelo Dessal on 6/3/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNReachabilityUtils.h"
#import "AFNetworkReachabilityManager.h"

@implementation KBNReachabilityUtils

+ (BOOL)isOffline {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return networkStatus == NotReachable;
}

+ (BOOL)isOnline {
    return ![self isOffline];
}

+ (void)startMonitoring {
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status != AFNetworkReachabilityStatusNotReachable) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CONNECTION_ONLINE object:nil];
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (void)stopMonitoring {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

@end
