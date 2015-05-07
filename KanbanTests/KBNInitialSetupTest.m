//
//  KBNInitialSetupTest.m
//  Kanban
//
//  Created by Maxi Casal on 5/7/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNInitialSetupTest.h"

@implementation KBNInitialSetupTest
- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testCreateUser{
    KBNUser *user = [KBNUser new];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    // NSTimeInterval is defined as double
    NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    NSString * username = [NSString stringWithFormat:@"user%@_@test.com",timeStampObj];
    user.username = username;
    user.password =@"password1234";
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"..."];
    
    KBNUserParseAPIManager* api = [[KBNUserParseAPIManager alloc]init];
    [api createUser:user completionBlock:^{
        [KBNUserUtils saveUsername:username];
        [expectation fulfill];
    } errorBlock:^(NSError *error) {
        XCTAssertFalse(true);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
    }];
}

-(void) testRemoveUser{
//    XCTestExpectation *expectation = [self expectationWithDescription:@"..."];
//    
//    KBNUserParseAPIManager* api = [[KBNUserParseAPIManager alloc]init];
//    [api deleteUser:@"user@test.com" completionBlock:^{
//        [expectation fulfill];
//    } errorBlock:^(NSError *error) {
//        [expectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:40.0 handler:^(NSError *error) {
//    }];    
}
@end
