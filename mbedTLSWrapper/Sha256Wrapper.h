//
// Created by Raimundas Sakalauskas on 21/08/2018.
// Copyright (c) 2018 Particle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Sha256Wrapper : NSObject

- (nullable instancetype)init;

- (int)updateWithData:(nonnull NSData *)data;
- (int)updateWithString:(nonnull NSString *)string;
- (nullable NSData *)finish;

@end