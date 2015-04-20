//
//  KBNParseAPIManager.h
//  Kanban
//
//  Created by Guillermo Apoj on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNUser.h"
#import <AFNetworking.h>
#import "KBNConstants.h"
#import "KBNProject.h"

typedef void (^KBNParseErrorBlock) (NSError *error);
typedef void(^KBNParseSuccesBlock)() ;


@interface KBNParseAPIManager : NSObject

+ (AFHTTPRequestOperationManager *)setupAFHTTPManager;

@end
