//
//  KBNCreateProjectFromTemplateTest.m
//  Kanban
//
//  Created by Marcelo Dessal on 5/28/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KBNProjectService.h"
#import "KBNTaskListService.h"
#import "KBNUserUtils.h"
#import "KBNInitialSetupTest.h"
#import "KBNProjectTemplateUtils.h"

#define PROJECT_CREATED_EXPECTATION @"project created"

@interface KBNCreateProjectFromTemplateTest : XCTestCase

@end

@implementation KBNCreateProjectFromTemplateTest

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

- (void)testCreateProjectFromTemplate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ddMMYYHHmmssSSS"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    XCTestExpectation *projectCreatedExpectation = [self expectationWithDescription:PROJECT_CREATED_EXPECTATION];
    
    NSString *name = [NSString stringWithFormat:@"test_project_%@",dateString];
    NSString *projectDescription = @"Project created from template";
    
    __block KBNProject *testProject = [KBNProjectUtils projectWithParams:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                          name, PARSE_PROJECT_NAME_COLUMN,
                                                                          projectDescription, PARSE_PROJECT_DESCRIPTION_COLUMN, nil]];
    NSString *templateName = @"test_template";
    __block NSArray *templateLists = @[@"List1", @"List2", @"List3"];
    
    KBNProjectTemplate *template = [KBNProjectTemplateUtils projectTemplateWithParams:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                       templateName, PARSE_PROJECT_TEMPLATE_NAME,
                                                                                       templateLists, PARSE_PROJECT_TEMPLATE_LISTS, nil]];
    
    KBNProjectService *projectService = [[KBNProjectService alloc] init];
    projectService.dataService =[[KBNProjectParseAPIManager alloc] init];
    
    KBNTaskListService *tasklistService = [[KBNTaskListService alloc] init];
    tasklistService.dataService = [[KBNTaskListParseAPIManager alloc] init];
    
    [projectService createProject:testProject.name
                  withDescription:testProject.projectDescription
                     withTemplate:template
                  completionBlock:^(KBNProject *project) {
                      [tasklistService getTaskListsForProject:project completionBlock:^(NSArray *lists) {
                          if (lists.count != 3) {
                              XCTFail(@"Three lists should have been created");
                          } else {
                              for (int i = 0; i < lists.count; i++) {
                                  // Verify if the created list name is the same as the one in the template
                                  NSString *name = [lists[i] objectForKey:PARSE_PROJECT_TEMPLATE_NAME];
                                  if (![name isEqualToString:templateLists[i]]) {
                                      XCTFail(@"Template list was not created");
                                      break;
                                  }
                              }
                          }
                          [projectCreatedExpectation fulfill];
                          
                      } errorBlock:^(NSError *error) {
                          XCTFail(@"TaskList Service could not retrieve lists");
                          [projectCreatedExpectation fulfill];
                      }];
                  } errorBlock:^(NSError *error) {
                      XCTFail(@"Project Service could not create the project");
                      [projectCreatedExpectation fulfill];
                  }];
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
}

@end
