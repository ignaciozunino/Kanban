
//
//  KBNEmailUtils.h
//  Kanban
//
//  Created by Lucas on 5/8/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNConstants.h"
#import <AFNetworking/AFNetworking.h>

@interface KBNEmailUtils : NSObject

+(void)sendEmailTo:(NSString*)recipientEmailAddress from:(NSString*)emailSender subject:(NSString*)subject body:(NSString*)body onSuccess:(KBNConnectionSuccessBlock)successBlock onError:(KBNConnectionErrorBlock)errorBlock;

@end