//
//  KBNReachabilityUtils.h
//  Kanban
//
//  Created by Marcelo Dessal on 6/3/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

#define CONNECTION_ONLINE @"online"

@interface KBNReachabilityUtils : NSObject

+ (BOOL)isOffline;
+ (void)startMonitoring;
+ (void)stopMonitoring;

@end
