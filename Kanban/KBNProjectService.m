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
- (NSManagedObjectContext*) managedObjectContext {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}


-(void)createProject:(NSString *)name withDescription:(NSString *)projectDescription completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError {
    
   
        KBNProject *project = [[KBNProject alloc]initWithEntity:[NSEntityDescription entityForName:ENTITY_PROJECT inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        project.name = name;
        project.projectDescription = projectDescription;
        
        [KBNProjectParseAPIManager createProject:project completionBlock:onCompletion errorBlock:onError ] ;

}

-(void)editProject:(NSString*)name withDescription:(NSString*)newDescription completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError{
    

}

-(void)removeProject:(NSString*)name completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError{
    
 
}

-(KBNProject*) getProjectWithName: (NSString*)name errorBlock:(KBNParseErrorBlock)onError{
    return nil;
}

-(NSArray*) getProjects:(KBNParseErrorBlock)onError{
    return nil;
}

@end
