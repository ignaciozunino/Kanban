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
        }
    }
    return inst;
}

-(void)createUser:(NSString*)username withPasword:(NSString*)password completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError {
    
    if ([KBNUserUtils isValidUsername:username] && [KBNUserUtils isValidPassword:password]) {
        
        [KBNUserUtils saveUsername:username];
        
        KBNUser *user = [KBNUser new];
        user.username = username;
        user.password = password;
        [KBNUserParseAPIManager createUser:user completionBlock:onCompletion errorBlock:onError ] ;
    
    }else{
        NSString *domain = ERROR_DOMAIN;
       
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": SIGNIN_ERROR};
                                  
        NSError *errorPtr = [NSError errorWithDomain:domain code:-101
                                    userInfo:info];
        onError(errorPtr);
    }
    

}

@end
