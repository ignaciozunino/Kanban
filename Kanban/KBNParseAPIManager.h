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
#import "Constants.h"

@interface KBNParseAPIManager : NSObject

+(void) createUser: (KBNUser *) user;

@end
