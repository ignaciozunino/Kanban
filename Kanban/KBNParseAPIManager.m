//
//  KBNParseAPIManager.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNParseAPIManager.h"

@implementation KBNParseAPIManager

#pragma mark - configuration methods
//This method is to create the AFHTTP Manager and setup Parse App ID and Parse REST API Keys
+ (AFHTTPRequestOperationManager *)setupManager {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:PARSE_APP_ID forHTTPHeaderField:@"X-Parse-Application-Id"];
    [manager.requestSerializer setValue:PARSE_REST_API_KEY forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return manager;
}

@end
