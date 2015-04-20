//
//  KBNUserParseAPIManager.m
//  Kanban
//
//  Created by Guillermo Apoj on 20/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNUserParseAPIManager.h"

@implementation KBNUserParseAPIManager
#pragma mark - user methods
+(void) createUser: (KBNUser *) user completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError{
    
    AFHTTPRequestOperationManager *manager = [self setupAFHTTPManager];
    NSDictionary *data = @{@"username": user.username, @"password": user.password};
    [manager POST:PARSE_USERS parameters: data
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"POST data JSON returned: %@", responseObject);
              onCompletion();
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              onError(error);
              NSLog(@"Error: %@", error);
          }
     ];
}
@end
