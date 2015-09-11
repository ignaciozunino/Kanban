//
//  KBNProjectTemplateParseAPIManager.m
//  Kanban
//
//  Created by Marcelo Dessal on 5/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectTemplateParseAPIManager.h"
#import "KBNProjectTemplate.h"

@implementation KBNProjectTemplateParseAPIManager

-(instancetype) init{
    
    self = [super init];
    if (self) {
        _afManager = [[KBNParseRequestOperationManager alloc] init];
    }
    return self;
}

- (void)getTemplatesCompletionBlock:(KBNSuccessArrayBlock)onCompletion onLanguage: (NSString *) language errorBlock:(KBNErrorBlock)onError {
    
    NSMutableDictionary *where = [NSMutableDictionary dictionaryWithCapacity:1];
    [where setObject:language forKey:PARSE_PROJECT_TEMPLATE_LANGUAGE];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:where forKey:@"where"];
    
    [self.afManager GET:PARSE_PROJECT_TEMPLATES
             parameters:params
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSArray *templates = [responseObject objectForKey:@"results"];
                    onCompletion(templates);
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    onError(error);
                }];
}

@end
