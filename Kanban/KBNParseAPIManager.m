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
+ (AFHTTPRequestOperationManager *)setupAFHTTPManager {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:PARSE_APP_ID forHTTPHeaderField:@"X-Parse-Application-Id"];
    [manager.requestSerializer setValue:PARSE_REST_API_KEY forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return manager;
}

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

#pragma mark - project methods
+(void) createProject: (KBNProject *) project completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError{

}

+(void) editProject: (NSString *)name newDescription:newDescription completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError{

}

+(void) removeProject: (NSString *)name completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError{

}

+(KBNProject*) getProjectWithName: (NSString*)name errorBlock:(KBNParseErrorBlock)onError{
    return nil;
}

+(NSArray*) getProjects:(KBNParseErrorBlock)onError{
    return nil;
}

@end
