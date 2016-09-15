//
//  SZJsonParser.h
//  JSON Parser
//
//  Created by numata on 09/09/04.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//
//  modified for macSVG by dsward

#import <Foundation/Foundation.h>


@interface SZJsonParser : NSObject
{
    NSUInteger  mLength;
    NSUInteger  mPos;
}

@property(strong) NSString * mSource;

- (id)parseObject;

- (id)initWithSource:(NSString *)source;

- (id)parse;

@end

