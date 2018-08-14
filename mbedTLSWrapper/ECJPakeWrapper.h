//
// Created by Raimundas Sakalauskas on 14/08/2018.
// Copyright (c) 2018 Particle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ECJPakeWrapperRoleType : NSUInteger {
    ECJPakeWrapperRoleClient,
    ECJPakeWrapperRoleServer
} ECJPakeWrapperRoleType;

@interface ECJPakeWrapper : NSObject

@property (assign) BOOL debug;

- (instancetype)initWithRole:(ECJPakeWrapperRoleType)role lowEntropySharedPassword:(nonnull NSString *)lowEntropySharedPassword;

- (void)setup;
- (void)readRoundOne:(nonnull NSData *)inputData;
- (void)readRoundTwo:(nonnull NSData *)inputData;

- (nonnull NSData *)writeRoundOne;
- (nonnull NSData *)writeRoundTwo;

- (nonnull NSData *)deriveSharedSecret;

@end