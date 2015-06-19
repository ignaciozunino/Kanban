//
//  KBNRemoveProjectTest.m
//  Kanban
//
//  Created by Marcelo Dessal on 5/19/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KBNProjectService.h"
#import "KBNUserUtils.h"
#import "KBNInitialSetupTest.h"

#define PROJECT_CREATED_EXPECTATION @"project created"
#define PROJECT_REMOVED_EXPECTATION @"project removed"

@interface KBNRemoveProjectTest : XCTestCase

@end

@implementation KBNRemoveProjectTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [[KBNInitialSetupTest new] testCreateUser];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}


- (void)testRemoveProject {
    
    // Setup for the test. Creates a project to be removed
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ddMMYYHHmmssSSS"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    XCTestExpectation *projectCreatedExpectation = [self expectationWithDescription:PROJECT_CREATED_EXPECTATION];
    
    NSString *name = [NSString stringWithFormat:@"test_project_%@",dateString];
    NSString *projectDescription = @"To remove";
    
    __block KBNProject *testProject = [KBNProjectUtils projectWithParams:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                      name, PARSE_PROJECT_NAME_COLUMN,
                                                                      projectDescription, PARSE_PROJECT_DESCRIPTION_COLUMN, nil]];
    
    KBNProjectService * service = [[KBNProjectService alloc] init];
    service.dataService =[[KBNProjectParseAPIManager alloc] init];
    
    [service createProject:testProject.name
           withDescription:testProject.projectDescription
              withTemplate:nil
           completionBlock:^(KBNProject *project) {
               testProject = project;
               [projectCreatedExpectation fulfill];
           } errorBlock:^(NSError *error) {
               XCTFail(@"Project Service could not create the project");
               [projectCreatedExpectation fulfill];
           }];
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
    
    
    // Here comes the actual test.
    
    XCTestExpectation *projectRemovedExpectation = [self expectationWithDescription:PROJECT_REMOVED_EXPECTATION];
    
    [service removeProject:testProject
           completionBlock:^{
               [service getProjectsOnSuccessBlock:^(NSArray *records) {
                                
                                for (KBNProject *record in records) {
                                    NSString *projectId = record.projectId;
                                    NSNumber *active = record.active;
                                    
                                    if ([projectId isEqualToString:testProject.projectId] && active.boolValue) {
                                        XCTFail(@"Project has not been removed");
                                        break;
                                    }
                                }
                                
                                [projectRemovedExpectation fulfill];
                            }
                                errorBlock:^(NSError *error) {
                                    XCTFail(@"Project Service could not retrieve projects for this user");
                                    [projectRemovedExpectation fulfill];
                                }];
               
           } errorBlock:^(NSError *error) {
               XCTFail(@"Project Service could not remove the project");
               [projectRemovedExpectation fulfill];
           }];
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
}

@end
