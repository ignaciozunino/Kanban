//
//  KBNUpdateManagerTest.m
//  Kanban
//
//  Created by Maxi Casal on 5/8/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KBNProjectService.h"
#import "KBNUpdateManager.h"
#import "KBNInitialSetupTest.h"

#define ProjectTest @"TestProject"
@interface KBNUpdateManagerTest : XCTestCase

@end

@implementation KBNUpdateManagerTest

+ (void)setUp {
    [[KBNInitialSetupTest new] testCreateUser];
}

+ (void)tearDown {
    [[KBNInitialSetupTest new] testRemoveUser];
}

//Feature tested: Update manager
//Description: In this test we will verify that the app is updating in real time
-(void) testCreateProjectAndReloaded{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testRealTime ok"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProjectsUpdate:) name:KBNProjectsUpdated object:nil];
    [[KBNUpdateManager sharedInstance] startUpdatingProjects];
    
    KBNProjectService * serviceOrig = [KBNProjectService sharedInstance];
    [serviceOrig createProject:ProjectTest withDescription:@"desc" forUser: [KBNUserUtils getUsername]
               completionBlock:^{
                   XCTAssertTrue(true);
                   [expectation fulfill];
               }
                    errorBlock:^(NSError *error) {
                        XCTAssertTrue(false);
                        [expectation fulfill];
                        
                    }];
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
}

-(void)onProjectsUpdate:(NSNotification *)noti{
    NSArray *projects = (NSArray*)noti.object;
    BOOL projectFound = NO;
    for (KBNProject *project in projects) {
        if ([project.name isEqualToString:ProjectTest]){
            projectFound = YES;
            break;
        }
    }
    if (projectFound) {
        XCTAssertTrue(true);

    }else{
        XCTAssertTrue(false);
    }
    [[KBNUpdateManager sharedInstance] stopUpdatingProjects];
}

@end
