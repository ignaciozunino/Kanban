//
//  KBNProxy.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNDataService.h"

@implementation KBNDataService

//This method is because KBNProxy is a Sigleton
+(KBNDataService *) sharedInstance{
    
    static  KBNDataService *inst = nil;
    
    @synchronized(self){
        if (!inst) {
            inst = [[self alloc] init];
        }
    }
    return inst;
}

-(void)createUser:(NSString*)username withPasword:(NSString*)password completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError {
    
    if ([UserUtils isValidUsername:username] && [UserUtils isValidPassword:password]) {
        
        [UserUtils saveUsername:username];
        
        KBNUser *user = [KBNUser new];
        user.username = username;
        user.password = password;
        [KBNParseAPIManager createUser:user completionBlock:onCompletion errorBlock:onError ] ;
    
    }else{
        NSString *domain = ERROR_DOMAIN;
       
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": SIGNIN_ERROR};
                                  
        NSError *errorPtr = [NSError errorWithDomain:domain code:-101
                                    userInfo:info];
        onError(errorPtr);
    }
    

}

@end
