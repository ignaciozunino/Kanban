//
//  KBNEmailUtils.m
//  Kanban
//
//  Created by Lucas on 5/8/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNEmailUtils.h"


@implementation KBNEmailUtils


+(void)sendEmailTo:(NSString*)recipientEmailAddress from:(NSString*)emailSender subject:(NSString*)subject body:(NSString*)body onSuccess:(KBNConnectionSuccessBlock)successBlock onError:(KBNConnectionErrorBlock)errorBlock{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:MAILGUN_API_KEY_USER password:MAILGUN_API_KEY_PASSWORD];
    
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:emailSender forKey:MAILGUN_FIELD_FROM];
    [parameters setObject:recipientEmailAddress forKey:MAILGUN_FIELD_TO];
    [parameters setObject:subject forKey:MAILGUN_FIELD_SUBJECT];
    [parameters setObject:body forKey:MAILGUN_FIELD_BODY];
    [manager POST:MAILGUN_URL_SANDBOX parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
    
    
}
@end