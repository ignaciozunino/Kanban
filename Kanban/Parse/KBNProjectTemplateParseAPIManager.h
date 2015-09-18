//
//  KBNProjectTemplateParseAPIManager.h
//  Kanban
//
//  Created by Marcelo Dessal on 5/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNParseRequestOperationManager.h"
#import "KBNConstants.h"

@interface KBNProjectTemplateParseAPIManager : NSObject

@property KBNParseRequestOperationManager* afManager;

- (void)getTemplatesCompletionBlock:(KBNSuccessArrayBlock)onCompletion language: (NSString *) language errorBlock:(KBNErrorBlock)onError;

@end
