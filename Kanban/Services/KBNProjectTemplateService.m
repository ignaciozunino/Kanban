//
//  KBNProjectTemplateService.m
//  Kanban
//
//  Created by Marcelo Dessal on 5/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectTemplateService.h"
#import "KBNProjectTemplateUtils.h"

@implementation KBNProjectTemplateService

+ (KBNProjectTemplateService *)sharedInstance {
    
    static  KBNProjectTemplateService *inst = nil;
    
    @synchronized(self){
        if (!inst) {
            inst = [[self alloc] init];
            inst.dataService = [[KBNProjectTemplateParseAPIManager alloc] init];
        }
    }
    return inst;
}

- (void)getTemplatesCompletionBlock:(KBNSuccessArrayBlock)onCompletion onLanguage: (NSString *) language errorBlock:(KBNErrorBlock)onError {
    
    [self.dataService getTemplatesCompletionBlock:^(NSArray *records){
        
        NSMutableArray *templatesArray = [[NSMutableArray alloc] init];
                                          
        for (NSDictionary *params in records) {
            KBNProjectTemplate *template = [KBNProjectTemplateUtils projectTemplateWithParams:params];
            [templatesArray addObject:template];
        }
        onCompletion(templatesArray);
        
    } onLanguage:language errorBlock:onError];
}

@end
