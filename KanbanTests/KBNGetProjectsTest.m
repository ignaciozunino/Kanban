//
//  KBNGetProjectsTest.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KBNProjectService.h"

@interface KBNGetProjectsTest : XCTestCase

@end

@implementation KBNGetProjectsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testGetProjects {
    XCTestExpectation *expectation = [self expectationWithDescription:@"..."];
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"ddMMYYHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    
    //we put the date in the name so we always have diferent projects
    NSString * name = [NSString stringWithFormat:@"test project:%@",dateString];
    //first we create a project to be sure we have at least one project to bring
    [[KBNProjectService sharedInstance] createProject:name
     
                                      withDescription:@"created with automatic test"
                                      completionBlock:^{
                                          ///on the complete block we get all the projects
                                          [[KBNProjectService sharedInstance]getProjectsOnSucces:^(NSArray *records) {
                                              NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
                                              NSArray *filteredArray = [records filteredArrayUsingPredicate:predicate];
                                              
                                              //we have the resently created  project or we fail
                                              if (filteredArray.count>0) {
                                                  XCTAssertTrue(true);
                                              }else{
                                                  XCTAssertTrue(false);
                                              }
                                              [expectation fulfill];
                                          } errorBlock:^(NSError *error) {
                                              
                                              XCTAssertTrue(false);
                                              [expectation fulfill];
                                              
                                          }];
                                      } errorBlock:^(NSError *error) {
                                          XCTAssertTrue(false);
                                          [expectation fulfill];
                                      }];
    
    
    
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
}
@end
