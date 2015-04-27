//
//  KBNProjectService.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/20/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectService.h"

@implementation KBNProjectService

//This method is because KBNProxy is a Singleton
+(KBNProjectService *) sharedInstance{
    
    static  KBNProjectService *inst = nil;
    
    @synchronized(self){
        if (!inst) {
            inst = [[self alloc] init];
            inst.dataService = [[KBNProjectParseAPIManager alloc]init];
        }
    }
    return inst;
}

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}


-(void)createProject:(NSString *)name withDescription:(NSString *)projectDescription completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError {
    if ([name isEqualToString:@""] || !name) {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": CREATING_PROJECT_WITHOUTNAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-102
                                            userInfo:info];
        onError(errorPtr);
    }else{
        KBNProject *project = [[KBNProject alloc]initWithEntity:[NSEntityDescription entityForName:ENTITY_PROJECT inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        project.name = name;
        project.projectDescription = projectDescription;
        [self.dataService createProject:project completionBlock:onCompletion errorBlock:onError ] ;
    }
}

-(void)editProject:(NSString*)name withDescription:(NSString*)newDescription completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    
    
}

-(void)removeProject:(NSString*)name completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    
    
}

-(KBNProject*) getProjectWithName: (NSString*)name errorBlock:(KBNConnectionErrorBlock)onError{
    return nil;
}

-(NSArray*) getProjects:(KBNConnectionErrorBlock)onError{
    return nil;
}

@end
