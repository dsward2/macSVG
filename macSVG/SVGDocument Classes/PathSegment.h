//
//  PathSegment.h
//  macSVG
//
//  Created by Douglas Ward on 4/4/20.
//  Copyright © 2020 ArkPhone, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PathSegment : NSObject
{
    NSString * xStringPrivate;
    NSString * yStringPrivate;

    NSString * x1StringPrivate;
    NSString * y1StringPrivate;

    NSString * x2StringPrivate;
    NSString * y2StringPrivate;

    NSString * xAxisRotationStringPrivate;
    NSString * largeArcFlagStringPrivate;
    NSString * sweepFlagStringPrivate;

    NSString * rxStringPrivate;
    NSString * ryStringPrivate;
}

@property (assign) unichar pathCommand;
@property (assign) unichar originalPathCommand;

@property (assign) float absoluteStartXFloat;
@property (assign) float absoluteStartYFloat;

@property (assign) float absoluteXFloat;
@property (assign) float absoluteYFloat;

@property (assign) float absoluteX1Float;
@property (assign) float absoluteY1Float;

@property (assign) float absoluteX2Float;
@property (assign) float absoluteY2Float;

@property (assign) NSString * xString;
@property (assign) NSString * yString;

@property (assign) NSString * x1String;
@property (assign) NSString * y1String;

@property (assign) NSString * x2String;
@property (assign) NSString * y2String;

@property (assign) NSString * xAxisRotationString;
@property (assign) NSString * largeArcFlagString;
@property (assign) NSString * sweepFlagString;

@property (assign) NSString * rxString;
@property (assign) NSString * ryString;

+ (PathSegment *)newPathSegment;

- (void)copyValuesFromPathSegment:(PathSegment *)aPathSegment;
- (NSMutableString *)allocFloatString:(float)aFloat;
- (NSInteger)count;

- (float)xFloat;
- (float)yFloat;
- (float)x1Float;
- (float)y1Float;
- (float)x2Float;
- (float)y2Float;
- (float)xAxisRotationFloat;
- (BOOL)largeArcFlagBool;
- (BOOL)sweepFlagBool;
- (float)rxFloat;
- (float)ryFloat;

- (void)setXFloat:(float)newValue;
- (void)setYFloat:(float)newValue;
- (void)setX1Float:(float)newValue;
- (void)setY1Float:(float)newValue;
- (void)setX2Float:(float)newValue;
- (void)setY2Float:(float)newValue;
- (void)setXAxisRotationFloat:(float)newValue;
- (void)setLargeArcFlagBool:(BOOL)newValue;
- (void)setSweepFlagBool:(BOOL)newValue;
- (void)setRxFloat:(float)newValue;
- (void)setRyFloat:(float)newValue;

- (NSString *) pathCommandString;

- (NSString *) absoluteStartXString;
- (NSString *) absoluteStartYString;

- (NSString *) absoluteXString;
- (NSString *) absoluteYString;

- (NSString *) absoluteX1String;
- (NSString *) absoluteY1String;

- (NSString *) absoluteX2String;
- (NSString *) absoluteY2String;

- (void) setAbsoluteStartXString:(NSString *)newValue;
- (void) setAbsoluteStartYString:(NSString *)newValue;

- (void) setAbsoluteXString:(NSString *)newValue;
- (void) setAbsoluteYString:(NSString *)newValue;

- (void) setAbsoluteX1String:(NSString *)newValue;
- (void) setAbsoluteY1String:(NSString *)newValue;

- (void) setAbsoluteX2String:(NSString *)newValue;
- (void) setAbsoluteY2String:(NSString *)newValue;

- (void)resetValues;

@end

NS_ASSUME_NONNULL_END
