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
-(void) createUser: (KBNUser *) user completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError{
    
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

-(void) deleteUser: (NSString *) username completionBlock:(KBNSuccessBlock)onCompletion errorBlock:(KBNErrorBlock)onError{
    
    NSMutableDictionary *where = [NSMutableDictionary dictionaryWithCapacity:1];
    [where setObject:username forKey:PARSE_USER_NAME_COLUMN];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:where, @"where",nil];
    
    [self.afManager GET:PARSE_USERS
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    
                    NSArray *result = [responseObject objectForKey:@"results"];
                    NSString* userID = [[result objectAtIndex:0] objectForKey:@"objectId"];
                    [self.afManager DELETE:[NSString stringWithFormat:@"%@/%@", PARSE_USERS, userID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"OK");
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error");
                    }];
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    onError(error);
                }];
}

@end
