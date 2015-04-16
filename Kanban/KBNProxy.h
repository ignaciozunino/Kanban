//
//  KBNProxy.h
//  Kanban
//
//  Created by Guillermo Apoj on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNParseAPIManager.h"
#import "KBNUser.h"

@interface KBNProxy : NSObject

+(KBNProxy *) sharedInstance;

-(void)createUser:(KBNUser*)user ;

@end
