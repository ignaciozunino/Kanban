//
//  KBNUserParseAPIManager.m
//  Kanban
//
//  Created by Guillermo Apoj on 20/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNUserParseAPIManager.h"

@implementation KBNUserParseAPIManager

-(instancetype) init{
    
    self = [super init];
    
    if (self) {
        _afManager = [AFHTTPRequestOperationManager createAFManager];
    }
    return self;
}

#pragma mark - user methods
-(void) createUser: (KBNUser *) user completionBlock:(KBNConnectionSuccesBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    
    NSDictionary *data = @{@"username": user.username, @"password": user.password};
    [self.afManager POST:PARSE_USERS parameters: data
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
