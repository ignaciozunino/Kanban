//
//  KBNEditProjectTest.m
//  Kanban
//
//  Created by Maxi Casal on 4/29/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KBNProjectService.h"
#import <OCMock/OCMock.h>
#import "KBNConstants.h"

@interface KBNEditProjectTest : XCTestCase

@end

@implementation KBNEditProjectTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


//Feature tested: Edit Project
//Description: In this test we will verify that you can edit an existing project
-(void) testCreateProjectOK{
//    KBNProjectService * serviceOrig = [[KBNProjectService alloc]init];
//    serviceOrig.dataService = [[KBNProjectParseAPIManager alloc]init];
//    [serviceOrig editProject:@"x1p7UzZp5m"withNewName:@"TEST-OK" withDescription:@"TEST-Desc" completionBlock:^{
//        
//        [serviceOrig.dataService getProjectWithProjectID:@"" successBlock:^(NSArray *records) {
//            if (records) {
//                KBNProject *project =[records objectAtIndex:0];
//                XCTAssertEqualObjects(@"TEST-OK", project.name);
//            }
//        } errorBlock:^(NSError *error) {
//            XCTAssertTrue(false);
//        }];} errorBlock:^(NSError *error) {
//            XCTAssertTrue(false);
//        }];
}

//Feature tested: Edit Project
//Description: In this test we will verify that you cant edit an existing project without name or project id
-(void) testCreateProjectWithoutNameOrProjectID{
    KBNProjectService * serviceOrig = [KBNProjectService sharedInstance];
    id projectAPIManager = [OCMockObject mockForClass:[KBNProjectParseAPIManager class]];
    [[projectAPIManager stub] editProject:OCMOCK_ANY withNewName:OCMOCK_ANY withNewDesc:OCMOCK_ANY completionBlock:OCMOCK_ANY errorBlock:OCMOCK_ANY ];
    serviceOrig.dataService = projectAPIManager;
    KBNProject *project = [KBNProject new];
    [serviceOrig editProject:project withNewName:@"" withDescription:@"TEST-Desc" completionBlock:^{
        XCTAssertTrue(false);
    } errorBlock:^(NSError *error) {
        XCTAssertTrue(true);
    }];
    
    [projectAPIManager reject];
}

@end
