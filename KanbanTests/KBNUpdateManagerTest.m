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
@property XCTestExpectation *expectation;
@property  KBNUpdateManager* um ;
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
    self.expectation = [self expectationWithDescription:@"testRealTime ok"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProjectsUpdate:) name:KBNProjectsUpdated object:nil];
    self.um= [[KBNUpdateManager alloc]init];
    
    
    KBNProjectService * serviceOrig = [[KBNProjectService alloc]init];
    serviceOrig.dataService = [[KBNProjectParseAPIManager alloc]init];
    self.um.projectService = serviceOrig;
    [serviceOrig createProject:ProjectTest withDescription:@"desc" forUser: [KBNUserUtils getUsername]
               completionBlock:^{
               }
                    errorBlock:^(NSError *error) {
                        XCTFail();
                        [self.expectation fulfill];
                    }];
    [self.um startUpdatingProjects];
    
    [self waitForExpectationsWithTimeout:100.0 handler:^(NSError *error) {
        [self.um stopUpdatingProjects];
    }];
}

-(void)onProjectsUpdate:(NSNotification *)noti{
    NSArray *projects = (NSArray*)noti.object;
    
    for (KBNProject *project in projects) {
        if ([project.name isEqualToString:ProjectTest]){
            
            [self.expectation fulfill];
            
            break;
        }
    }
   
    XCTFail();
    
    [self.expectation fulfill];
    
}

@end
