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
    self.afManager = [[KBNParseRequestOperationManager alloc]init];
   
    return self;
}

#pragma mark - user methods
-(void) createUser: (KBNUser *) user completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    
    NSDictionary *data = @{@"username": user.username, @"password": user.password};
    [self.afManager POST:PARSE_USERS parameters: data
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
              onCompletion();
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              onError(error);
                       }
     ];
}
@end
