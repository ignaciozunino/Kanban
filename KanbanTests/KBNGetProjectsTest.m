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
#import "KBNUserUtils.h"
#import "KBNInitialSetupTest.h"

@interface KBNGetProjectsTest : XCTestCase

@end

@implementation KBNGetProjectsTest

+ (void)setUp {
    [[KBNInitialSetupTest new] testCreateUser];
}

+ (void)tearDown {
    [[KBNInitialSetupTest new] testRemoveUser];
}

///test that we get all the projects
///we create a project and then we bring all the projects and we verify that the new created project is on the list
- (void)testGetProjects {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetProjects ok"];
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"ddMMYYHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    
    //we put the date in the name so we always have diferent projects
    NSString * name = [NSString stringWithFormat:@"test project:%@",dateString];
    //first we create a project to be sure we have at least one project to bring
    KBNProjectService * service = [[KBNProjectService alloc]init];
    service.dataService =[[KBNProjectParseAPIManager alloc]init];
    
    [service createProject:name
           withDescription:@"created with automatic test"
              withTemplate:nil
           completionBlock:^(KBNProject* aProject){
               ///on the complete block we get all the projects
               
               [service getProjectsOnSuccessBlock:^(NSArray *records) {
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
