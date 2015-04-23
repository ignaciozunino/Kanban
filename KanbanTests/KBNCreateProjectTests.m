//
//  KanbanTests.m
//  KanbanTests
//
//  Created by Nicolas Alejandro Porpiglia on 4/15/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KBNProjectService.h"
#import <OCMock/OCMock.h>
#import "KBNConstants.h"


@interface KBNCreateProjectTests : XCTestCase

@end

@implementation KBNCreateProjectTests

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
//     EJEMPLO MOCKS
  
  /*
@interface ExampleLC : NSObject
  - (void)loginWithUserPass:userPassD withSuccess:(void (^)(NSString *authToken))successBlock failure:(void (^)(NSString *errorMessage))failureBlock;
  @end
  @implementation ExampleLC
  - (void)loginWithUserPass:userPassD withSuccess:(void (^)(NSString *authToken))successBlock failure:(void (^)(NSString *errorMessage))failureBlock
  {
  }
  @end
  @interface Example : NSObject {
  @public
  ExampleLC *_loginCntrl;
  }
  - (void)saveToken:(NSString *)authToken;
  - (void)loginWithUser:(NSString *)userName andPass:(NSString *)pass;
  @end
  @implementation Example
  - (void)saveToken:(NSString *)authToken
  {
  }
  - (void)loginWithUser:(NSString *)userName andPass:(NSString *)pass {
  
  NSDictionary *userPassD = @{@"user":userName,
  @"pass":pass};
  [_loginCntrl loginWithUserPass:userPassD withSuccess:^(NSString *authToken){
  // save authToken to credential store
  [self saveToken:authToken];
  } failure:^(NSString *errorMessage) {
  // alert user pass was wrong
  }];
  }
  @end
  
  
  @interface loginTest : SenTestCase
  
  @end
  
  @implementation loginTest
  
  - (void)testExample
  {
  Example *exampleOrig = [[Example alloc] init];
  id loginCntrl = [OCMockObject mockForClass:[ExampleLC class]];
  [[[loginCntrl expect] andDo:^(NSInvocation *invocation) {
  void (^successBlock)(NSString *authToken) = [invocation getArgumentAtIndexAsObject:3];
  successBlock(@"Dummy");
  }] loginWithUserPass:OCMOCK_ANY withSuccess:OCMOCK_ANY failure:OCMOCK_ANY];
  exampleOrig->_loginCntrl = loginCntrl;
  id example = [OCMockObject partialMockForObject:exampleOrig];
  [[example expect] saveToken:@"Dummy"];
  [example loginWithUser:@"ABC" andPass:@"DEF"];
  [loginCntrl verify];
  [example verify];
  }
  @end
  */
  
 /*
- (void)testCreateProject {
    
   KBNProjectService * service = [[KBNProjectService alloc]init];
    id projectparseapimanager = [OCMockObject mockForClass:[KBNProjectParseAPIManager class]];
    [[projectparseapimanager expect] andDo:^(NSInvocation *invocation) {
        void (KBNParseSuccesBlock)() = [invocation getArgumentAtIndexAsObject:3];
        KBNParseSuccesBlock();
    }
     ];
    /*NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm"];
    
    NSDate *now = [[NSDate alloc] init];
   
    NSString *dateString = [format stringFromDate:now];
    
    NSString * projectName = [NSString stringWithFormat:@"test created %@",dateString];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Project created"];
    [[KBNProjectService sharedInstance]createProject:projectName withDescription:@"project createdby automatic tests" completionBlock:^{
       [expectation fulfill];
    } errorBlock:^(NSError *error) {
        NSString *message = [NSString stringWithFormat:@"ERROR Creating project : %@", [error localizedDescription] ];
        XCTFail(@"%@",message);
    }];
    
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
        NSString *message = [NSString stringWithFormat:@"ERROR Creating project : %@", [error localizedDescription] ];
        XCTFail(@"%@",message);
    }];
}

*/

-(void) testCreateProjectWithoutName{
    KBNProjectService * serviceOrig = [[KBNProjectService alloc]init];
    id projectAPIManager = [OCMockObject mockForClass:[KBNProjectParseAPIManager class]];
    serviceOrig.dataService = projectAPIManager;
    [serviceOrig createProject:@"" withDescription:OCMOCK_ANY completionBlock:OCMOCK_ANY errorBlock:^(NSError *error) {}];
    [[projectAPIManager reject] createProject:OCMOCK_ANY completionBlock:OCMOCK_ANY errorBlock:OCMOCK_ANY];
}

@end
