//
//  ECJPakeWrapperTests.m
//  ECJPakeWrapperTests
//
//  Created by Raimundas Sakalauskas on 14/08/2018.
//  Copyright © 2018 Particle Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ECJPakeWrapper.h"

@interface ECJPakeWrapperTests : XCTestCase

@end

@implementation ECJPakeWrapperTests {
    ECJPakeWrapper *_server;
    ECJPakeWrapper *_client;
}

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSamePasswordProducesSameSecret {
    _server = [[ECJPakeWrapper alloc] initWithRole:ECJPakeWrapperRoleServer lowEntropySharedPassword:@"password1"];
    [_server setup];
    
    _client = [[ECJPakeWrapper alloc] initWithRole:ECJPakeWrapperRoleClient lowEntropySharedPassword:@"password1"];
    [_client setup];
    
    NSData *c1 = [_client writeRoundOne];
    [_server readRoundOne:c1];
    
    NSData *s1 = [_server writeRoundOne];
    [_client readRoundOne:s1];
    
    NSData *c2 = [_client writeRoundTwo];
    [_server readRoundTwo:c2];
    
    NSData *s2 = [_server writeRoundTwo];
    [_client readRoundTwo:s2];
    
    NSData *clientResult = [_client deriveSharedSecret];
    NSData *serverResult = [_server deriveSharedSecret];
    
    XCTAssertTrue([clientResult isEqualToData:serverResult]);
}

- (void)testDifferentPasswordProducesDifferentSecret {
    _server = [[ECJPakeWrapper alloc] initWithRole:ECJPakeWrapperRoleServer lowEntropySharedPassword:@"password1"];
    [_server setup];
    
    _client = [[ECJPakeWrapper alloc] initWithRole:ECJPakeWrapperRoleClient lowEntropySharedPassword:@"not the same?"];
    [_client setup];
    
    NSData *c1 = [_client writeRoundOne];
    [_server readRoundOne:c1];
    
    NSData *s1 = [_server writeRoundOne];
    [_client readRoundOne:s1];
    
    NSData *c2 = [_client writeRoundTwo];
    [_server readRoundTwo:c2];
    
    NSData *s2 = [_server writeRoundTwo];
    [_client readRoundTwo:s2];
    
    NSData *clientResult = [_client deriveSharedSecret];
    NSData *serverResult = [_server deriveSharedSecret];
    
    _server = nil;
    _client = nil;
    
    XCTAssertFalse([clientResult isEqualToData:serverResult]);
}


@end
