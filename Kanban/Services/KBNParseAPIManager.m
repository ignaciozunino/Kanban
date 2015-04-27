//
//  KBNParseAPIManager.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNParseAPIManager.h"

@implementation KBNParseAPIManager

-(AFHTTPRequestOperationManager *) createAFManager{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if (manager) {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:PARSE_APP_ID forHTTPHeaderField:@"X-Parse-Application-Id"];
        [manager.requestSerializer setValue:PARSE_REST_API_KEY forHTTPHeaderField:@"X-Parse-REST-API-Key"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    return manager;
}
- (id)init {
    self = [super init];
    if (self) {
        self.afManager = [self createAFManager];
    }
    return self;
}

@end
