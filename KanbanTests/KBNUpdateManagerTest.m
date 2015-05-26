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
@property  KBNUpdateManager* updateManager ;
@end

@implementation KBNUpdateManagerTest

+ (void)setUp {
    [[KBNInitialSetupTest new] testCreateUser];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProjectsUpdate:) name:KBNProjectsUpdated object:nil];
}

+ (void)tearDown {
    [[KBNInitialSetupTest new] testRemoveUser];
}

//Feature tested: Update manager
//Description: In this test we will verify that the app is updating in real time
-(void) testCreateProjectAndReloaded{
//    self.expectation = [self expectationWithDescription:@"testRealTime ok"];
//    
//    self.updateManager= [KBNUpdateManager new];
//    
//    KBNProjectService * serviceOrig = [[KBNProjectService alloc]init];
//    serviceOrig.dataService = [[KBNProjectParseAPIManager alloc]init];
//    self.updateManager.projectService = serviceOrig;
//    [serviceOrig createProject:ProjectTest withDescription:@"desc" forUser:[KBNUserUtils getUsername] completionBlock:^(KBNProject *project) {
//        
//    } errorBlock:^(NSError *error) {
//        XCTFail();
//        [self.expectation fulfill];
//    }];
//    [self.updateManager startUpdatingProjects];
//    
//    [self waitForExpectationsWithTimeout:100.0 handler:^(NSError *error) {
//        [self.updateManager stopUpdatingProjects];
//    }];
}

-(void)onProjectsUpdate:(NSNotification *)noti{
    NSArray *projects = (NSArray*)noti.object;
    for (KBNProject *project in projects) {
        if ([project.name isEqualToString:ProjectTest]){
            [self.expectation fulfill];
            return;
        }
    }
    XCTFail();
    [self.expectation fulfill];
}

@end
