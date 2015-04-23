//
//  AFHTTPRequestOperationManager+KBNParseAPIManager.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/23/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "AFHTTPRequestOperationManager+KBNParseAPIManager.h"

@implementation AFHTTPRequestOperationManager (KBNParseAPIManager)

+(instancetype) createAFManager{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if (manager) {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:PARSE_APP_ID forHTTPHeaderField:@"X-Parse-Application-Id"];
        [manager.requestSerializer setValue:PARSE_REST_API_KEY forHTTPHeaderField:@"X-Parse-REST-API-Key"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    return manager;
}
@end
