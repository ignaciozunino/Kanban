//
//  KBNProxy.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNUserService.h"

@implementation KBNUserService

//This method is because KBNProxy is a Sigleton
+(KBNUserService *) sharedInstance{
    
    static  KBNUserService *inst = nil;
    
    @synchronized(self){
        if (!inst) {
            inst = [[self alloc] init];
            inst.dataService = [[KBNUserParseAPIManager alloc]init];
        }
    }
    return inst;
}

-(void)createUser:(NSString*)username withPasword:(NSString*)password completionBlock:(KBNConnectionSuccesBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    
    if ([KBNUserUtils isValidUsername:username] && [KBNUserUtils isValidPassword:password]) {
        
        [KBNUserUtils saveUsername:username];
        
        KBNUser *user = [KBNUser new];
        user.username = username;
        user.password = password;
        [self.dataService createUser:user completionBlock:onCompletion errorBlock:onError ] ;
    
    }else{
        NSString *domain = ERROR_DOMAIN;
        NSError *errorPtr = [NSError errorWithDomain:domain code:-101
                                    userInfo:nil];
        onError(errorPtr);
    }
    

}

@end
