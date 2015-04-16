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

-(void)createUser:(KBNUser*)user completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError {
    [KBNParseAPIManager createUser:user completionBlock:onCompletion errorBlock:onError ] ;

}

@end
