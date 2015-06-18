//
//  KBNProjectTemplateService.h
//  Kanban
//
//  Created by Marcelo Dessal on 5/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNProjectTemplateParseAPIManager.h"

@interface KBNProjectTemplateService : NSObject

@property (strong, nonatomic) KBNProjectTemplateParseAPIManager* dataService;

+ (KBNProjectTemplateService*) sharedInstance;

- (void)getTemplatesCompletionBlock:(KBNSuccessArrayBlock)onCompletion errorBlock:(KBNErrorBlock)onError;

@end
