//
//  KBNReachabilityUtils.h
//  Kanban
//
//  Created by Marcelo Dessal on 6/3/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNReachabilityView.h"

@interface KBNReachabilityUtils : NSObject

+ (BOOL)isOnline;
+ (BOOL)isOffline;

@end
