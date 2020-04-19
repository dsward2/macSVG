//
//  PathSegment.m
//  macSVG
//
//  Created by Douglas Ward on 4/4/20.
//  Copyright © 2020 ArkPhone, LLC. All rights reserved.
//

#import "PathSegment.h"
#import "math.h"


@implementation PathSegment


+ (PathSegment *)newPathSegment
{
    PathSegment * newPathSegment = [[PathSegment alloc] init];
    return newPathSegment;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self resetValues];
    }
    return self;
}


- (void)resetValues
{
    _pathCommand = '?';
    _originalPathCommand = '?';

    _absoluteStartXFloat = NAN;
    _absoluteStartYFloat = NAN;

    _absoluteXFloat = NAN;
    _absoluteYFloat = NAN;

    _absoluteX1Float = NAN;
    _absoluteY1Float = NAN;

    _absoluteX2Float = NAN;
    _absoluteY2Float = NAN;

    xStringPrivate = @"NAN";
    yStringPrivate = @"NAN";

    x1StringPrivate = @"NAN";
    y1StringPrivate = @"NAN";

    x2StringPrivate = @"NAN";
    y2StringPrivate = @"NAN";
    
    xAxisRotationStringPrivate = @"NAN";
    largeArcFlagStringPrivate = @"NAN";
    sweepFlagStringPrivate = @"NAN";
    rxStringPrivate = @"NAN";
    ryStringPrivate = @"NAN";
}

- (NSString *)description
{
    NSMutableString * description = [NSMutableString string];
    [description appendFormat:@"pathCommand=%C", _pathCommand];
    
    if (_originalPathCommand != '?')
    {
        [description appendFormat:@", originalPathCommand=%C", _originalPathCommand];
    }
    
    if (isnan(_absoluteStartXFloat) == false)
    {
        [description appendFormat:@", absoluteStartX=%@", self.absoluteStartXString];
    }
    if (isnan(_absoluteStartYFloat) == false)
    {
        [description appendFormat:@", absoluteStartY=%@", self.absoluteStartYString];
    }
    
    if (isnan(_absoluteXFloat) == false)
    {
        [description appendFormat:@", absoluteX=%@", self.absoluteXString];
    }
    if (isnan(_absoluteYFloat) == false)
    {
        [description appendFormat:@", absoluteY=%@", self.absoluteYString];
    }
    
    if (isnan(_absoluteX1Float) == false)
    {
        [description appendFormat:@", absoluteX1=%@", self.absoluteX1String];
    }
    if (isnan(_absoluteY1Float) == false)
    {
        [description appendFormat:@", absoluteY1=%@", self.absoluteY1String];
    }
    
    if (isnan(_absoluteX2Float) == false)
    {
        [description appendFormat:@", absoluteX2=%@", self.absoluteX2String];
    }
    if (isnan(_absoluteY2Float) == false)
    {
        [description appendFormat:@", absoluteY2=%@", self.absoluteY2String];
    }

    if ([xStringPrivate isEqualToString:@"NAN"] == NO)
    {
        [description appendFormat:@", x=%@", xStringPrivate];
    }
    if ([yStringPrivate isEqualToString:@"NAN"] == NO)
    {
        [description appendFormat:@", y=%@", yStringPrivate];
    }
    
    if ([x1StringPrivate isEqualToString:@"NAN"] == NO)
    {
        [description appendFormat:@", x1=%@", x1StringPrivate];
    }
    if ([y1StringPrivate isEqualToString:@"NAN"] == NO)
    {
        [description appendFormat:@", y1=%@", y1StringPrivate];
    }
    
    if ([x2StringPrivate isEqualToString:@"NAN"] == NO)
    {
        [description appendFormat:@", x2=%@", x2StringPrivate];
    }
    if ([y2StringPrivate isEqualToString:@"NAN"] == NO)
    {
        [description appendFormat:@", y2=%@", y2StringPrivate];
    }

    if ([xAxisRotationStringPrivate isEqualToString:@"NAN"] == NO)
    {
        [description appendFormat:@", x-axis-rotation=%@", xAxisRotationStringPrivate];
    }
    if ([largeArcFlagStringPrivate isEqualToString:@"NAN"] == NO)
    {
        [description appendFormat:@", large-arc-flag=%@", largeArcFlagStringPrivate];
    }
    if ([sweepFlagStringPrivate isEqualToString:@"NAN"] == NO)
    {
        [description appendFormat:@", sweep-flag=%@", sweepFlagStringPrivate];
    }

    if ([rxStringPrivate isEqualToString:@"NAN"] == NO)
    {
        [description appendFormat:@", rx=%@", rxStringPrivate];
    }
    if ([ryStringPrivate isEqualToString:@"NAN"] == NO)
    {
        [description appendFormat:@", ry=%@", ryStringPrivate];
    }

    return description;
}


- (NSInteger)count
{
    NSInteger result = 0;

    if ([xStringPrivate isEqualToString:@"NAN"] == NO) result++;
    if ([yStringPrivate isEqualToString:@"NAN"] == NO) result++;

    if ([x1StringPrivate isEqualToString:@"NAN"] == NO) result++;
    if ([y1StringPrivate isEqualToString:@"NAN"] == NO) result++;

    if ([x2StringPrivate isEqualToString:@"NAN"] == NO) result++;
    if ([y2StringPrivate isEqualToString:@"NAN"] == NO) result++;

    if ([xAxisRotationStringPrivate isEqualToString:@"NAN"] == NO) result++;
    if ([largeArcFlagStringPrivate isEqualToString:@"NAN"] == NO) result++;
    if ([sweepFlagStringPrivate isEqualToString:@"NAN"] == NO) result++;
    if ([rxStringPrivate isEqualToString:@"NAN"] == NO) result++;
    if ([ryStringPrivate isEqualToString:@"NAN"] == NO) result++;

    return result;
}


- (void)copyValuesFromPathSegment:(PathSegment *)aPathSegment
{
    _pathCommand = aPathSegment.pathCommand;

    _absoluteStartXFloat = aPathSegment.absoluteStartXFloat;
    _absoluteStartYFloat = aPathSegment.absoluteStartYFloat;

    _absoluteXFloat = aPathSegment.absoluteXFloat;
    _absoluteYFloat = aPathSegment.absoluteYFloat;

    _absoluteX1Float = aPathSegment.absoluteX1Float;
    _absoluteY1Float = aPathSegment.absoluteY1Float;

    _absoluteX2Float = aPathSegment.absoluteX2Float;
    _absoluteY2Float = aPathSegment.absoluteY2Float;

    xStringPrivate = aPathSegment.xString;
    yStringPrivate = aPathSegment.yString;

    x1StringPrivate = aPathSegment.x1String;
    y1StringPrivate = aPathSegment.y1String;

    x2StringPrivate = aPathSegment.x2String;
    y2StringPrivate = aPathSegment.y2String;
    
    xAxisRotationStringPrivate = aPathSegment.xAxisRotationString;
    largeArcFlagStringPrivate = aPathSegment.largeArcFlagString;
    sweepFlagStringPrivate = aPathSegment.sweepFlagString;
    rxStringPrivate = aPathSegment.rxString;
    ryStringPrivate = aPathSegment.ryString;
}



- (NSString *)xString
{
    return xStringPrivate;
}

- (void)setXString:(NSString *)newValue
{
    xStringPrivate = [newValue copy];
}

- (NSString *)yString
{
    return yStringPrivate;
}

- (void)setYString:(NSString *)newValue
{
    yStringPrivate = [newValue copy];
}


- (NSString *)x1String
{
    return x1StringPrivate;
}

- (void)setX1String:(NSString *)newValue
{
    x1StringPrivate = [newValue copy];
}

- (NSString *)y1String
{
    return y1StringPrivate;
}

- (void)setY1String:(NSString *)newValue
{
    y1StringPrivate = [newValue copy];
}



- (NSString *)x2String
{
    return x2StringPrivate;
}

- (void)setX2String:(NSString *)newValue
{
    x2StringPrivate = [newValue copy];
}

- (NSString *)y2String
{
    return y2StringPrivate;
}

- (void)setY2String:(NSString *)newValue
{
    y2StringPrivate = [newValue copy];
}



- (NSString *)xAxisRotationString
{
    return xAxisRotationStringPrivate;
}

- (void)setXAxisRotationString:(NSString *)newValue
{
    xAxisRotationStringPrivate = [newValue copy];
}


- (NSString *)largeArcFlagString
{
    return largeArcFlagStringPrivate;
}

- (void)setLargeArcFlagString:(NSString *)newValue
{
    largeArcFlagStringPrivate = [newValue copy];
}


- (NSString *)sweepFlagString
{
    return sweepFlagStringPrivate;
}

- (void)setSweepFlagString:(NSString *)newValue
{
    sweepFlagStringPrivate = [newValue copy];
}


- (NSString *)rxString
{
    return rxStringPrivate;
}

- (void)setRxString:(NSString *)newValue
{
    rxStringPrivate = [newValue copy];
}

- (NSString *)ryString
{
    return ryStringPrivate;
}

- (void)setRyString:(NSString *)newValue
{
    ryStringPrivate = [newValue copy];
}





- (float)xFloat
{
    return xStringPrivate.floatValue;
}


- (float)yFloat
{
    return yStringPrivate.floatValue;
}


- (float)x1Float
{
    return x1StringPrivate.floatValue;
}


- (float)y1Float
{
    return y1StringPrivate.floatValue;
}


- (float)x2Float
{
    return x2StringPrivate.floatValue;
}


- (float)y2Float
{
    return y2StringPrivate.floatValue;
}


- (float)xAxisRotationFloat
{
    return xAxisRotationStringPrivate.floatValue;
}


- (BOOL)largeArcFlagBool
{
    BOOL result = NO;
    if ([largeArcFlagStringPrivate isEqualToString:@"1"] == YES)
    {
        result = YES;
    }
    return result;
}


- (BOOL)sweepFlagBool
{
    BOOL result = NO;
    if ([sweepFlagStringPrivate isEqualToString:@"@"] == YES)
    {
        result = YES;
    }
    return result;
}


- (float)rxFloat
{
    return rxStringPrivate.floatValue;
}


- (float)ryFloat
{
    return ryStringPrivate.floatValue;
}




- (void)setXFloat:(float)newValue
{
    xStringPrivate = [self allocFloatString:newValue];
}

- (void)setYFloat:(float)newValue
{
    yStringPrivate = [self allocFloatString:newValue];
}

- (void)setX1Float:(float)newValue
{
    x1StringPrivate = [self allocFloatString:newValue];
}

- (void)setY1Float:(float)newValue
{
    y1StringPrivate = [self allocFloatString:newValue];
}

- (void)setX2Float:(float)newValue
{
    x2StringPrivate = [self allocFloatString:newValue];
}

- (void)setY2Float:(float)newValue
{
    y2StringPrivate = [self allocFloatString:newValue];
}

- (void)setXAxisRotationFloat:(float)newValue
{
    xAxisRotationStringPrivate = [self allocFloatString:newValue];
}

- (void)setLargeArcFlagBool:(BOOL)newValue
{
    if (newValue == YES)
    {
        largeArcFlagStringPrivate = @"1";
    }
    else
    {
        largeArcFlagStringPrivate = @"0";
    }
}

- (void)setSweepFlagBool:(BOOL)newValue
{
    if (newValue == YES)
    {
        sweepFlagStringPrivate = @"1";
    }
    else
    {
        sweepFlagStringPrivate = @"0";
    }
}

- (void)setRxFloat:(float)newValue
{
    rxStringPrivate = [self allocFloatString:newValue];
}

- (void)setRyFloat:(float)newValue
{
    ryStringPrivate = [self allocFloatString:newValue];
}




- (NSString *) pathCommandString
{
    NSString * resultString = [NSString stringWithFormat:@"%C", _pathCommand];
    return resultString;
}

- (NSString *) absoluteStartXString
{
    NSString * resultString = [self allocFloatString:_absoluteStartXFloat];
    return resultString;
}

- (NSString *) absoluteStartYString
{
    NSString * resultString = [self allocFloatString:_absoluteStartYFloat];
    return resultString;
}

- (NSString *) absoluteXString
{
    NSString * resultString = [self allocFloatString:_absoluteXFloat];
    return resultString;
}

- (NSString *) absoluteYString
{
    NSString * resultString = [self allocFloatString:_absoluteYFloat];
    return resultString;
}

- (NSString *) absoluteX1String
{
    NSString * resultString = [self allocFloatString:_absoluteX1Float];
    return resultString;
}

- (NSString *) absoluteY1String
{
    NSString * resultString = [self allocFloatString:_absoluteY1Float];
    return resultString;
}

- (NSString *) absoluteX2String
{
    NSString * resultString = [self allocFloatString:_absoluteX2Float];
    return resultString;
}

- (NSString *) absoluteY2String
{
    NSString * resultString = [self allocFloatString:_absoluteY2Float];
    return resultString;
}

- (void) setAbsoluteStartXString:(NSString *)newValue
{
    _absoluteStartXFloat = newValue.floatValue;
}

- (void) setAbsoluteStartYString:(NSString *)newValue
{
    _absoluteStartYFloat = newValue.floatValue;
}

- (void) setAbsoluteXString:(NSString *)newValue
{
    _absoluteXFloat = newValue.floatValue;
}

- (void) setAbsoluteYString:(NSString *)newValue
{
    _absoluteYFloat = newValue.floatValue;
}

- (void) setAbsoluteX1String:(NSString *)newValue
{
    _absoluteX1Float = newValue.floatValue;
}

- (void) setAbsoluteY1String:(NSString *)newValue
{
    _absoluteY1Float = newValue.floatValue;
}

- (void) setAbsoluteX2String:(NSString *)newValue
{
    _absoluteX2Float = newValue.floatValue;
}

- (void) setAbsoluteY2String:(NSString *)newValue
{
    _absoluteY2Float = newValue.floatValue;
}

//==================================================================================
//	allocFloatString:
//==================================================================================

- (NSMutableString *)allocFloatString:(float)aFloat
{
    NSMutableString * aString = [[NSMutableString alloc] initWithFormat:@"%f", aFloat];

    BOOL continueTrim = YES;
    while (continueTrim == YES)
    {
        NSUInteger stringLength = aString.length;
        
        if (stringLength <= 1)
        {
            continueTrim = NO;
        }
        else
        {
            unichar lastChar = [aString characterAtIndex:(stringLength - 1)];
            
            if (lastChar == '0')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
            }
            else if (lastChar == '.')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
                continueTrim = NO;
            }
            else
            {
                continueTrim = NO;
            }
        }
    }
    return aString;
}

@end
