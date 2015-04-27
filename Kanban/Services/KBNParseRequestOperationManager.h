//
//  KBNParseAPIManager.h
//  Kanban
//
//  Created by Guillermo Apoj on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "KBNConstants.h"



@interface KBNParseRequestOperationManager : AFHTTPRequestOperationManager 

- (void)setupParseConfig;



@end
