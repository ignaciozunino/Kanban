//
//  KBNParseAPIManager.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNParseRequestOperationManager.h"

@implementation KBNParseRequestOperationManager


- (void)setupParseConfig {
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:PARSE_APP_ID forHTTPHeaderField:@"X-Parse-Application-Id"];
    [self.requestSerializer setValue:PARSE_REST_API_KEY forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setupParseConfig];
    }
    return self;
}

@end
