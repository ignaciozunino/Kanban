//
//  KBNInitialSetupTest.h
//  Kanban
//
//  Created by Maxi Casal on 5/7/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KBNConstants.h"
#import "KBNUserService.h"
#import "KBNUser.h"

@interface KBNInitialSetupTest : XCTestCase

-(void) testCreateUser;
-(void) testRemoveUser;

@end
