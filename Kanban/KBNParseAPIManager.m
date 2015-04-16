//
//  KBNParseAPIManager.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNParseAPIManager.h"

@implementation KBNParseAPIManager

+(void) createUser: (KBNUser *) user{
    
    AFHTTPRequestOperationManager *manager = [self setupAFHTTPManager];
    NSDictionary *data = @{@"username": user.username, @"password": user.password};
    [manager POST:@"https://api.parse.com/1/classes/KBNUser" parameters: data
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"POST data JSON returned: %@", responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }
     ];
}

//This method is to create the AFHTTP Manager and setup Parse App ID and Parse REST API Keys
+ (AFHTTPRequestOperationManager *)setupAFHTTPManager {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:PARSE_APP_ID forHTTPHeaderField:@"X-Parse-Application-Id"];
    [manager.requestSerializer setValue:PARSE_REST_API_KEY forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return manager;
}

@end
