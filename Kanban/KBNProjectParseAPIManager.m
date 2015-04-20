//
//  KBNProjectParseAPIManager.m
//  Kanban
//
//  Created by Guillermo Apoj on 20/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectParseAPIManager.h"

@implementation KBNProjectParseAPIManager
#pragma mark - project methods
+(void) createProject: (KBNProject *) project completionBlock:(KBNParseSuccesBlock)onCompletion errorBlock:(KBNParseErrorBlock)onError{
    AFHTTPRequestOperationManager *manager = [self setupAFHTTPManager];
    NSDictionary *data = @{@"name": project.name, @"project_description": project.description};
    [manager POST:PARSE_PROJECTS parameters: data
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
