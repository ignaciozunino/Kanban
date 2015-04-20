//
//  KBNProjectService.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/20/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectService.h"

@implementation KBNProjectService

//This method is because KBNProxy is a Sigleton
+(KBNProjectService *) sharedInstance{
    
    static  KBNProjectService *inst = nil;
    
    @synchronized(self){
        if (!inst) {
            inst = [[self alloc] init];
        }
    }
    return inst;
}

-(void)createProject:(NSString *)name withDescription:(NSString *)projectDescription completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError {
    
    if (![KBNProjectUtils existProject:name]) {
        KBNProject *project = [KBNProject new];
        project.name = name;
        project.projectDescription = projectDescription;
        
        [KBNParseAPIManager createProject:project completionBlock:onCompletion errorBlock:onError ] ;
    }else{
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": SIGNIN_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-101
                                            userInfo:info];
        onError(errorPtr);
    }
}

-(void)editProject:(NSString*)name withDescription:(NSString*)newDescription completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError{
    
    if (![KBNProjectUtils existProject:name]) {
        [KBNParseAPIManager editProject:name newDescription:newDescription completionBlock:onCompletion errorBlock:onError ] ;
    }else{
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": SIGNIN_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-101
                                            userInfo:info];
        onError(errorPtr);
    }
}

-(void)removeProject:(NSString*)name completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError{
    
    if (![KBNProjectUtils existProject:name]) {
        [KBNParseAPIManager removeProject:name completionBlock:onCompletion errorBlock:onError ] ;
    }else{
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": SIGNIN_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-101
                                            userInfo:info];
        onError(errorPtr);
    }
}

-(KBNProject*) getProjectWithName: (NSString*)name errorBlock:(KBNParseErrorBlock)onError{
    return nil;
}

-(NSArray*) getProjects:(KBNParseErrorBlock)onError{
    return nil;
}

@end
