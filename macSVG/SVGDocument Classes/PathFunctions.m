//
//  PathFunctions.m
//  macSVG
//
//  Created by Douglas Ward on 8/9/16.
//
//

#import "PathFunctions.h"
#import "MacSVGDocumentWindowController.h"
#import "MacSVGDocument.h"
#import "SVGWebKitController.h"

@implementation PathFunctions

//==================================================================================
//	computeBoundsForPathSegmentsArray
//==================================================================================

- (NSRect)computeBoundsForPathSegmentsArray:(NSMutableArray *)pathSegmentsArray withControlPoints:(BOOL)withControlPoints
{
    NSRect resultRect = NSZeroRect;
    
    CGFloat xMin = FLT_MAX;
    CGFloat xMax = FLT_MIN;
    CGFloat yMin = FLT_MAX;
    CGFloat yMax = FLT_MIN;

    [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:pathSegmentsArray];
    
    for (NSDictionary * pathSegmentDictionary in pathSegmentsArray)
    {
        NSNumber * absoluteStartXNumber = [pathSegmentDictionary objectForKey:@"absoluteStartX"];
        NSNumber * absoluteStartYNumber = [pathSegmentDictionary objectForKey:@"absoluteStartY"];
        NSNumber * absoluteXNumber = [pathSegmentDictionary objectForKey:@"absoluteX"];
        NSNumber * absoluteYNumber = [pathSegmentDictionary objectForKey:@"absoluteY"];
        
        CGFloat absoluteStartXFloat = [absoluteStartXNumber floatValue];
        CGFloat absoluteStartYFloat = [absoluteStartYNumber floatValue];
        CGFloat absoluteXFloat = [absoluteXNumber floatValue];
        CGFloat absoluteYFloat = [absoluteYNumber floatValue];

        if (xMin > absoluteStartXFloat)
        {
            xMin = absoluteStartXFloat;
        }
        
        if (xMax < absoluteStartXFloat)
        {
            xMax = absoluteStartXFloat;
        }
        
        if (yMin > absoluteStartYFloat)
        {
            yMin = absoluteStartYFloat;
        }
        
        if (yMax < absoluteStartYFloat)
        {
            yMax = absoluteStartYFloat;
        }

        if (xMin > absoluteXFloat)
        {
            xMin = absoluteXFloat;
        }
        
        if (xMax < absoluteXFloat)
        {
            xMax = absoluteXFloat;
        }
        
        if (yMin > absoluteYFloat)
        {
            yMin = absoluteYFloat;
        }
        
        if (yMax < absoluteYFloat)
        {
            yMax = absoluteYFloat;
        }

        NSString * commandString = [pathSegmentDictionary objectForKey:@"command"];
        
        unichar commandCharacter = [commandString characterAtIndex:0];

        switch (commandCharacter)
        {
            case 'M':     // moveto
            case 'm':     // moveto
            {
                break;
            }
            case 'L':     // lineto
            case 'l':     // lineto
            {
                break;
            }

            case 'H':     // horizontal lineto
            case 'h':     // horizontal lineto
            {
                break;
            }

            case 'V':     // vertical lineto
            case 'v':     // vertical lineto
            {
                break;
            }

            case 'C':     // curveto
            case 'c':     // curveto
            {
                if (withControlPoints == YES)
                {
                    NSNumber * x1Number = [pathSegmentDictionary objectForKey:@"absoluteX1"];
                    CGFloat x1Float = [x1Number floatValue];

                    NSNumber * y1Number = [pathSegmentDictionary objectForKey:@"absoluteY1"];
                    CGFloat y1Float = [y1Number floatValue];

                    if (xMin > x1Float)
                    {
                        xMin = x1Float;
                    }
                    else if (xMax < x1Float)
                    {
                        xMax = x1Float;
                    }
                    
                    if (yMin > y1Float)
                    {
                        yMin = y1Float;
                    }
                    else if (yMax < y1Float)
                    {
                        yMax = y1Float;
                    }

                    NSNumber * x2Number = [pathSegmentDictionary objectForKey:@"absoluteX2"];
                    CGFloat x2Float = [x2Number floatValue];

                    NSNumber * y2Number = [pathSegmentDictionary objectForKey:@"absoluteY2"];
                    CGFloat y2Float = [y2Number floatValue];

                    if (xMin > x2Float)
                    {
                        xMin = x2Float;
                    }
                    else if (xMax < x2Float)
                    {
                        xMax = x2Float;
                    }
                    
                    if (yMin > y2Float)
                    {
                        yMin = y2Float;
                    }
                    else if (yMax < y2Float)
                    {
                        yMax = y2Float;
                    }
                }

                break;
            }

            case 'S':     // smooth curveto
            case 's':     // smooth curveto
            {
                if (withControlPoints == YES)
                {
                    NSNumber * x2Number = [pathSegmentDictionary objectForKey:@"absoluteX2"];
                    CGFloat x2Float = [x2Number floatValue];

                    NSNumber * y2Number = [pathSegmentDictionary objectForKey:@"absoluteY2"];
                    CGFloat y2Float = [y2Number floatValue];

                    if (xMin > x2Float)
                    {
                        xMin = x2Float;
                    }
                    else if (xMax < x2Float)
                    {
                        xMax = x2Float;
                    }
                    
                    if (yMin > y2Float)
                    {
                        yMin = y2Float;
                    }
                    else if (yMax < y2Float)
                    {
                        yMax = y2Float;
                    }
                }

                break;
            }

            case 'Q':     // quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
            {
                if (withControlPoints == YES)
                {
                    NSNumber * x1Number = [pathSegmentDictionary objectForKey:@"absoluteX1"];
                    CGFloat x1Float = [x1Number floatValue];

                    NSNumber * y1Number = [pathSegmentDictionary objectForKey:@"absoluteY1"];
                    CGFloat y1Float = [y1Number floatValue];

                    if (xMin > x1Float)
                    {
                        xMin = x1Float;
                    }
                    else if (xMax < x1Float)
                    {
                        xMax = x1Float;
                    }
                    
                    if (yMin > y1Float)
                    {
                        yMin = y1Float;
                    }
                    else if (yMax < y1Float)
                    {
                        yMax = y1Float;
                    }
                }

                break;
            }

            case 'T':     // smooth quadratic Bezier curve
            case 't':     // smooth quadratic Bezier curve
            {
                break;
            }

            case 'A':     // elliptical arc
            case 'a':     // elliptical arc
            {
                break;
            }

            case 'Z':     // closepath
            case 'z':     // closepath
                break;
        }
        
        resultRect = NSMakeRect(xMin, yMin, (xMax - xMin), (yMax - yMin));
    }
    
    return resultRect;
}

//==================================================================================
//	convertToAbsoluteCoordinates
//==================================================================================

- (NSMutableArray *)convertToAbsoluteCoordinates:(NSXMLElement *)pathElement
{
    NSXMLNode * pathAttributeNode = [pathElement attributeForName:@"d"];
    NSString * pathAttributeString = [pathAttributeNode stringValue];
    
    NSMutableArray * pathSegmentsArray = [self.macSVGDocumentWindowController.svgWebKitController
            buildPathSegmentsArrayWithPathString:pathAttributeString];

    return [self convertToAbsoluteCoordinatesWithPathSegmentsArray:pathSegmentsArray];
}

//==================================================================================
//	convertToAbsoluteCoordinates
//==================================================================================

- (NSMutableArray *)convertToAbsoluteCoordinatesWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    MacSVGDocument * macSVGDocument = [self.macSVGDocumentWindowController document];

    for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
    {
        NSNumber * absoluteStartXNumber = [pathSegmentDictionary objectForKey:@"absoluteStartX"];
        NSNumber * absoluteStartYNumber = [pathSegmentDictionary objectForKey:@"absoluteStartY"];
        
        CGFloat absoluteStartXFloat = [absoluteStartXNumber floatValue];
        CGFloat absoluteStartYFloat = [absoluteStartYNumber floatValue];

        NSString * commandString = [pathSegmentDictionary objectForKey:@"command"];
        
        unichar commandCharacter = [commandString characterAtIndex:0];

        switch (commandCharacter)
        {
            case 'M':     // moveto
                break;    // no changes required

            case 'm':     // moveto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                CGFloat xFloat = [xString floatValue];
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                CGFloat yFloat = [yString floatValue];
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                [pathSegmentDictionary setObject:@"M" forKey:@"command"];
                break;
            }
            case 'L':     // lineto
            {
                break;    // no changes required
            }
            
            case 'l':     // lineto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                CGFloat xFloat = [xString floatValue];
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                CGFloat yFloat = [yString floatValue];
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                [pathSegmentDictionary setObject:@"L" forKey:@"command"];
                break;
            }

            case 'H':     // horizontal lineto
                break;    // no changes required

            case 'h':     // horizontal lineto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                CGFloat xFloat = [xString floatValue];
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                [pathSegmentDictionary setObject:@"H" forKey:@"command"];
                break;
            }

            case 'V':     // vertical lineto
                break;    // no changes required

            case 'v':     // vertical lineto
            {
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                CGFloat yFloat = [yString floatValue];
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                [pathSegmentDictionary setObject:@"V" forKey:@"command"];
                break;
            }

            case 'C':     // curveto
                break;    // no changes required

            case 'c':     // curveto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                CGFloat xFloat = [xString floatValue];
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                CGFloat yFloat = [yString floatValue];
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                CGFloat x1Float = [x1String floatValue];
                x1Float += absoluteStartXFloat;
                NSString * newX1String = [macSVGDocument allocFloatString:x1Float];
                [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                CGFloat y1Float = [y1String floatValue];
                y1Float += absoluteStartYFloat;
                NSString * newY1String = [macSVGDocument allocFloatString:y1Float];
                [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                CGFloat x2Float = [x2String floatValue];
                x2Float += absoluteStartXFloat;
                NSString * newX2String = [macSVGDocument allocFloatString:x2Float];
                [pathSegmentDictionary setObject:newX2String forKey:@"x2"];

                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                CGFloat y2Float = [y2String floatValue];
                y2Float += absoluteStartYFloat;
                NSString * newY2String = [macSVGDocument allocFloatString:y2Float];
                [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
                
                [pathSegmentDictionary setObject:@"C" forKey:@"command"];
                break;
            }

            case 'S':     // smooth curveto
                break;    // no changes required

            case 's':     // smooth curveto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                CGFloat xFloat = [xString floatValue];
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                CGFloat yFloat = [yString floatValue];
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                CGFloat x2Float = [x2String floatValue];
                x2Float += absoluteStartXFloat;
                NSString * newX2String = [macSVGDocument allocFloatString:x2Float];
                [pathSegmentDictionary setObject:newX2String forKey:@"x2"];

                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                CGFloat y2Float = [y2String floatValue];
                y2Float += absoluteStartYFloat;
                NSString * newY2String = [macSVGDocument allocFloatString:y2Float];
                [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
                
                [pathSegmentDictionary setObject:@"S" forKey:@"command"];
                break;
            }

            case 'Q':     // quadratic Bezier curve
                break;    // no changes required

            case 'q':     // quadratic Bezier curve
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                CGFloat xFloat = [xString floatValue];
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                CGFloat yFloat = [yString floatValue];
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                CGFloat x1Float = [x1String floatValue];
                x1Float += absoluteStartXFloat;
                NSString * newX1String = [macSVGDocument allocFloatString:x1Float];
                [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                CGFloat y1Float = [y1String floatValue];
                y1Float += absoluteStartYFloat;
                NSString * newY1String = [macSVGDocument allocFloatString:y1Float];
                [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

                [pathSegmentDictionary setObject:@"Q" forKey:@"command"];
                break;
            }

            case 'T':     // smooth quadratic Bezier curve
                break;    // no changes required

            case 't':     // smooth quadratic Bezier curve
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                CGFloat xFloat = [xString floatValue];
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                CGFloat yFloat = [yString floatValue];
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                [pathSegmentDictionary setObject:@"T" forKey:@"command"];
                break;
            }

            case 'A':     // elliptical arc
                break;    // no changes required

            case 'a':     // elliptical arc
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                CGFloat xFloat = [xString floatValue];
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                CGFloat yFloat = [yString floatValue];
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                [pathSegmentDictionary setObject:@"A" forKey:@"command"];
                break;
            }

            case 'Z':     // closepath
            case 'z':     // closepath
                break;
        }
    }
        
    return pathSegmentsArray;
}




//==================================================================================
//	convertCurvesToAbsoluteCubicBezier
//==================================================================================

- (NSMutableArray *)convertCurvesToAbsoluteCubicBezier:(NSXMLElement *)pathElement
{
    NSXMLNode * pathAttributeNode = [pathElement attributeForName:@"d"];
    NSString * pathAttributeString = [pathAttributeNode stringValue];
    
    NSMutableArray * pathSegmentsArray = [self.macSVGDocumentWindowController.svgWebKitController
            buildPathSegmentsArrayWithPathString:pathAttributeString];

    return [self convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray:pathSegmentsArray];
}

//==================================================================================
//	convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray
//==================================================================================

- (NSMutableArray *)convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    MacSVGDocument * macSVGDocument = [self.macSVGDocumentWindowController document];

    [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:pathSegmentsArray];

    unichar previousCommandCharacter = ' ';
    NSDictionary * previousSegmentDictionary = NULL;
    NSInteger pathSegmentIndex = 0;
    CGPoint controlPoint = NSZeroPoint;

    for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
    {
        NSNumber * absoluteStartXNumber = [pathSegmentDictionary objectForKey:@"absoluteStartX"];
        NSNumber * absoluteStartYNumber = [pathSegmentDictionary objectForKey:@"absoluteStartY"];
        
        NSNumber * absoluteXNumber = [pathSegmentDictionary objectForKey:@"absoluteX"];
        NSNumber * absoluteYNumber = [pathSegmentDictionary objectForKey:@"absoluteY"];
        
        //NSNumber * xNumber = [pathSegmentDictionary objectForKey:@"x"];
        //NSNumber * yNumber = [pathSegmentDictionary objectForKey:@"y"];
        
        CGFloat absoluteStartXFloat = [absoluteStartXNumber floatValue];
        CGFloat absoluteStartYFloat = [absoluteStartYNumber floatValue];
        
        CGFloat absoluteXFloat = [absoluteXNumber floatValue];
        CGFloat absoluteYFloat = [absoluteYNumber floatValue];
        
        //CGFloat xFloat = [xNumber floatValue];
        //CGFloat yFloat = [yNumber floatValue];

        if (pathSegmentIndex == 0)
        {
            controlPoint = CGPointMake(absoluteStartXFloat, absoluteStartYFloat);
        }

        NSString * commandString = [pathSegmentDictionary objectForKey:@"command"];
        unichar commandCharacter = [commandString characterAtIndex:0];

        switch (commandCharacter)
        {
            case 'M':     // moveto
                break;    // no changes required

            case 'm':     // moveto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                CGFloat xFloat = [xString floatValue];
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                CGFloat yFloat = [yString floatValue];
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                [pathSegmentDictionary setObject:@"M" forKey:@"command"];
                break;
            }
            case 'L':     // lineto
            {
                break;    // no changes required
            }
            
            case 'l':     // lineto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                CGFloat xFloat = [xString floatValue];
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                CGFloat yFloat = [yString floatValue];
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                [pathSegmentDictionary setObject:@"L" forKey:@"command"];
                break;
            }

            case 'H':     // horizontal lineto
                break;    // no changes required

            case 'h':     // horizontal lineto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                CGFloat xFloat = [xString floatValue];
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                [pathSegmentDictionary setObject:@"H" forKey:@"command"];
                break;
            }

            case 'V':     // vertical lineto
                break;    // no changes required

            case 'v':     // vertical lineto
            {
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                CGFloat yFloat = [yString floatValue];
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                [pathSegmentDictionary setObject:@"V" forKey:@"command"];
                break;
            }

            case 'C':     // curveto
                break;    // no changes required

            case 'c':     // curveto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                CGFloat xFloat = [xString floatValue];
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                CGFloat yFloat = [yString floatValue];
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                CGFloat x1Float = [x1String floatValue];
                x1Float += absoluteStartXFloat;
                NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                CGFloat y1Float = [y1String floatValue];
                y1Float += absoluteStartYFloat;
                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                CGFloat x2Float = [x2String floatValue];
                x2Float += absoluteStartXFloat;
                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                [pathSegmentDictionary setObject:newX2String forKey:@"x2"];

                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                CGFloat y2Float = [y2String floatValue];
                y2Float += absoluteStartYFloat;
                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
                
                [pathSegmentDictionary setObject:@"C" forKey:@"command"];
                break;
            }

            case 'S':     // smooth curveto
            case 's':     // smooth curveto
            {
                // The first control point is assumed to be the reflection of the second control point on the previous command relative to the current point. (If there is no previous command or if the previous command was not an C, c, S or s, assume the first control point is coincident with the current point.)
                
                switch (previousCommandCharacter)
                {
                    case 'C':
                    case 'c':
                    case 'S':
                    case 's':
                    {
                        NSNumber * previousAbsoluteX2Number = [previousSegmentDictionary objectForKey:@"absoluteX2"];
                        NSNumber * previousAbsoluteY2Number = [previousSegmentDictionary objectForKey:@"absoluteY2"];
                        
                        CGFloat previousAbsoluteX2Float = [previousAbsoluteX2Number floatValue];
                        CGFloat previousAbsoluteY2Float = [previousAbsoluteY2Number floatValue];
                        
                        CGFloat x1Float = absoluteStartXFloat + (absoluteStartXFloat - previousAbsoluteX2Float);
                        CGFloat y1Float = absoluteStartYFloat + (absoluteStartYFloat - previousAbsoluteY2Float);

                        NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                        [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                        NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                        [pathSegmentDictionary setObject:newY1String forKey:@"y1"];
                        
                        NSNumber * newAbsoluteX1Number = [NSNumber numberWithFloat:x1Float];
                        [pathSegmentDictionary setObject:newAbsoluteX1Number forKey:@"absoluteX1"];

                        NSNumber * newAbsoluteY1Number = [NSNumber numberWithFloat:y1Float];
                        [pathSegmentDictionary setObject:newAbsoluteY1Number forKey:@"absoluteY1"];

                        break;
                    }
                    default:
                    {
                        NSMutableString * newX1String = [macSVGDocument allocFloatString:absoluteStartXFloat];
                        [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                        NSMutableString * newY1String = [macSVGDocument allocFloatString:absoluteStartYFloat];
                        [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

                        NSNumber * newAbsoluteX1Number = [NSNumber numberWithFloat:absoluteStartXFloat];
                        [pathSegmentDictionary setObject:newAbsoluteX1Number forKey:@"absoluteX1"];

                        NSNumber * newAbsoluteY1Number = [NSNumber numberWithFloat:absoluteStartYFloat];
                        [pathSegmentDictionary setObject:newAbsoluteY1Number forKey:@"absoluteY1"];
                    }
                }

                NSNumber * absoluteX2Number = [pathSegmentDictionary objectForKey:@"absoluteX2"];
                NSNumber * absoluteY2Number = [pathSegmentDictionary objectForKey:@"absoluteY2"];
                
                CGFloat absoluteX2Float = [absoluteX2Number floatValue];
                CGFloat absoluteY2Float = [absoluteY2Number floatValue];

                NSMutableString * newX2String = [macSVGDocument allocFloatString:absoluteX2Float];
                [pathSegmentDictionary setObject:newX2String forKey:@"x2"];

                NSMutableString * newY2String = [macSVGDocument allocFloatString:absoluteY2Float];
                [pathSegmentDictionary setObject:newY2String forKey:@"y2"];

                NSNumber * newAbsoluteX2Number = [NSNumber numberWithFloat:absoluteX2Float];
                [pathSegmentDictionary setObject:newAbsoluteX2Number forKey:@"absoluteX1"];

                NSNumber * newAbsoluteY2Number = [NSNumber numberWithFloat:absoluteY2Float];
                [pathSegmentDictionary setObject:newAbsoluteY2Number forKey:@"absoluteY1"];
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                [pathSegmentDictionary setObject:@"C" forKey:@"command"];
                
                break;
            }


            case 'Q':     // quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
            {
                CGPoint currentPoint = CGPointMake(absoluteStartXFloat, absoluteStartYFloat);
                CGPoint targetPoint = CGPointMake(absoluteXFloat, absoluteYFloat);

                NSNumber * oldAbsoluteX1Number = [pathSegmentDictionary objectForKey:@"absoluteX1"];    // quadratic x1,y1
                NSNumber * oldAbsoluteY1Number = [pathSegmentDictionary objectForKey:@"absoluteY1"];
                
                CGFloat oldAbsoluteX1Float = [oldAbsoluteX1Number floatValue];
                CGFloat oldAbsoluteY1Float = [oldAbsoluteY1Number floatValue];

                controlPoint = CGPointMake(oldAbsoluteX1Float, oldAbsoluteY1Float);
                
                CGFloat x1Float = currentPoint.x - ((currentPoint.x - controlPoint.x) / 1.5f);
                CGFloat y1Float = currentPoint.y - ((currentPoint.y - controlPoint.y) / 1.5f);
                
                CGFloat x2Float = targetPoint.x - ((targetPoint.x - controlPoint.x) / 1.5f);
                CGFloat y2Float = targetPoint.y - ((targetPoint.y - controlPoint.y) / 1.5f);

                NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                [pathSegmentDictionary setObject:newY1String forKey:@"y1"];
                
                NSNumber * newAbsoluteX1Number = [NSNumber numberWithFloat:x1Float];
                [pathSegmentDictionary setObject:newAbsoluteX1Number forKey:@"absoluteX1"];

                NSNumber * newAbsoluteY1Number = [NSNumber numberWithFloat:y1Float];
                [pathSegmentDictionary setObject:newAbsoluteY1Number forKey:@"absoluteY1"];

                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                [pathSegmentDictionary setObject:newX2String forKey:@"x2"];

                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
                
                NSNumber * newAbsoluteX2Number = [NSNumber numberWithFloat:x2Float];
                [pathSegmentDictionary setObject:newAbsoluteX2Number forKey:@"absoluteX2"];

                NSNumber * newAbsoluteY2Number = [NSNumber numberWithFloat:y2Float];
                [pathSegmentDictionary setObject:newAbsoluteY2Number forKey:@"absoluteY2"];

                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                [pathSegmentDictionary setObject:@"C" forKey:@"command"];
                
                break;
            }

            case 'T':     // smooth quadratic Bezier curve
            case 't':     // smooth quadratic Bezier curve
            {
                // Based on WebKitSVGPathParser::parseCurveToQuadraticSmoothSegment()
                // to get cubic x1,x2 and quadratic control point for a quadratic smooth segment
                // from https://github.com/WebKit/webkit/blob/master/Source/WebCore/svg/SVGPathParser.cpp

                CGPoint currentPoint = CGPointMake(absoluteStartXFloat, absoluteStartYFloat);
                CGPoint targetPoint = CGPointMake(absoluteXFloat, absoluteYFloat);
                
                CGPoint point1 = currentPoint;
                CGPoint point2 = targetPoint;

                if (pathSegmentIndex > 0)
                {
                    switch (previousCommandCharacter)
                    {
                        case 'Q':
                        case 'q':
                        case 'T':
                        case 't':
                        {
                            break;
                        }
                        default:
                        {
                            controlPoint = currentPoint;
                        }
                    }
                    
                    CGPoint cubicPoint = currentPoint;
                    cubicPoint.x *= 2.0f;
                    cubicPoint.y *= 2.0f;
                    cubicPoint.x -= controlPoint.x;
                    cubicPoint.y -= controlPoint.y;
                    
                    point1 = CGPointMake((currentPoint.x + (2.0f * cubicPoint.x)), (currentPoint.y + (2.0f * cubicPoint.y)));
                    point2 = CGPointMake((targetPoint.x + (2.0f * cubicPoint.x)), (targetPoint.y + (2.0f * cubicPoint.y)));
                    
                    point1.x /= 3.0f;   // x1 for cubic curve
                    point1.y /= 3.0f;   // y1 for cubic curve
                    point2.x /= 3.0f;   // x2 for cubic curve
                    point2.y /= 3.0f;   // y2 for cubic curve
                    
                    controlPoint = cubicPoint;
                }

                CGFloat x1Float = point1.x;
                CGFloat y1Float = point1.y;
                
                CGFloat x2Float = point2.x;
                CGFloat y2Float = point2.y;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                [pathSegmentDictionary setObject:newY1String forKey:@"y1"];
                
                NSNumber * newAbsoluteX1Number = [NSNumber numberWithFloat:x1Float];
                [pathSegmentDictionary setObject:newAbsoluteX1Number forKey:@"absoluteX1"];

                NSNumber * newAbsoluteY1Number = [NSNumber numberWithFloat:y1Float];
                [pathSegmentDictionary setObject:newAbsoluteY1Number forKey:@"absoluteY1"];

                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                [pathSegmentDictionary setObject:newX2String forKey:@"x2"];

                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
                
                NSNumber * newAbsoluteX2Number = [NSNumber numberWithFloat:x2Float];
                [pathSegmentDictionary setObject:newAbsoluteX2Number forKey:@"absoluteX2"];

                NSNumber * newAbsoluteY2Number = [NSNumber numberWithFloat:y2Float];
                [pathSegmentDictionary setObject:newAbsoluteY2Number forKey:@"absoluteY2"];

                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                [pathSegmentDictionary setObject:@"C" forKey:@"command"];
                
                break;
            }

            case 'A':     // elliptical arc
                break;    // no changes required

            case 'a':     // elliptical arc
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                CGFloat xFloat = [xString floatValue];
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                CGFloat yFloat = [yString floatValue];
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                [pathSegmentDictionary setObject:@"A" forKey:@"command"];
                break;
            }

            case 'Z':     // closepath
            case 'z':     // closepath
                break;
        }
        
        previousCommandCharacter = commandCharacter;
        previousSegmentDictionary = pathSegmentDictionary;
        
        pathSegmentIndex++;
    }

    [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:pathSegmentsArray];
    
    return pathSegmentsArray;
}

//==================================================================================
//	copyPathSegmentsArray:
//==================================================================================

- (NSMutableArray *)copyPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    NSMutableArray * resultArray = [NSMutableArray array];

    for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
    {
        NSMutableDictionary * newDictionary = [NSMutableDictionary dictionary];
    
        NSArray * allKeys = [pathSegmentDictionary allKeys];
        
        for (NSString * aKey in allKeys)
        {
            id aValue = [pathSegmentDictionary objectForKey:aKey];
            
            NSString * newKey = [aKey copy];
            id newValue = [aValue copy];
            
            [newDictionary setObject:newValue forKey:newKey];
        }
        
        [resultArray addObject:newDictionary];
    }
    
    return resultArray;
}

//==================================================================================
//	duplicateSegmentDictionary
//==================================================================================

- (NSMutableDictionary *)duplicateSegmentDictionary:(NSMutableDictionary *)pathSegmentDictionary
{
    NSMutableDictionary * newSegmentDictionary = [NSMutableDictionary dictionary];
    
    NSArray * originalKeys = [pathSegmentDictionary allKeys];
    
    for (NSString * aKey in originalKeys)
    {
        id originalObject = [pathSegmentDictionary objectForKey:aKey];
        
        if ([originalObject isKindOfClass:[NSString class]] == YES)
        {
            NSString * aString = originalObject;
            NSMutableString * newString = [NSMutableString stringWithString:aString];
            [newSegmentDictionary setObject:newString forKey:aKey];
        }
        else if ([originalObject isKindOfClass:[NSNumber class]] == YES)
        {
            NSNumber * aNumber = originalObject;
            NSNumber * newNumber = [NSNumber numberWithFloat:[aNumber floatValue]];
            [newSegmentDictionary setObject:newNumber forKey:aKey];
        }
    }
    
    return newSegmentDictionary;
}

//==================================================================================
//	reversePathWithPathSegmentsArray:
//==================================================================================

- (NSMutableArray *)reversePathWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    MacSVGDocument * macSVGDocument = [self.macSVGDocumentWindowController document];
    [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:pathSegmentsArray];
    
    NSMutableArray * cubicPathSegmentsArray = [self copyPathSegmentsArray:pathSegmentsArray];
    cubicPathSegmentsArray = [self convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray:cubicPathSegmentsArray];
    NSMutableArray * reverseCubicsSegmentsArray = [NSMutableArray array];
    for (NSMutableDictionary * cubicSegmentDictionary in cubicPathSegmentsArray)
    {
        NSMutableDictionary * newCubicSegmentDictionary = [self duplicateSegmentDictionary:cubicSegmentDictionary];

        [reverseCubicsSegmentsArray insertObject:newCubicSegmentDictionary atIndex:0];
    }

    // reverse sequence of input array
    NSMutableArray * reverseSegmentsArray = [NSMutableArray array];
    for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
    {
        NSMutableDictionary * newSegmentDictionary = [self duplicateSegmentDictionary:pathSegmentDictionary];

        [reverseSegmentsArray insertObject:newSegmentDictionary atIndex:0];
    }
    
    NSMutableArray * newPathSegmentsArray = [NSMutableArray array];

    NSInteger currentIndex = 0;
    
    unichar originalLastCommand = ' ';
    
    for (NSMutableDictionary * reversePathSegmentDictionary in reverseSegmentsArray)
    {
        NSMutableDictionary * pathSegmentDictionary = [NSMutableDictionary dictionary];
    
        NSNumber * absoluteStartXNumber = [reversePathSegmentDictionary objectForKey:@"absoluteStartX"];    // reversed, this will be the new endpoint
        NSNumber * absoluteStartYNumber = [reversePathSegmentDictionary objectForKey:@"absoluteStartY"];
        NSNumber * absoluteXNumber = [reversePathSegmentDictionary objectForKey:@"absoluteX"];              // reversed, this will be the new startpoint
        NSNumber * absoluteYNumber = [reversePathSegmentDictionary objectForKey:@"absoluteY"];
        
        CGFloat absoluteStartXFloat = [absoluteStartXNumber floatValue];
        CGFloat absoluteStartYFloat = [absoluteStartYNumber floatValue];
        CGFloat absoluteXFloat = [absoluteXNumber floatValue];
        CGFloat absoluteYFloat = [absoluteYNumber floatValue];
        
        NSString * absoluteStartXString = [macSVGDocument allocFloatString:absoluteStartXFloat];
        NSString * absoluteStartYString = [macSVGDocument allocFloatString:absoluteStartYFloat];
        NSString * absoluteXString = [macSVGDocument allocFloatString:absoluteXFloat];
        NSString * absoluteYString = [macSVGDocument allocFloatString:absoluteYFloat];
        
        NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
        NSNumber * yString = [pathSegmentDictionary objectForKey:@"y"];

        CGFloat xFloat = [xString floatValue];
        CGFloat yFloat = [yString floatValue];
        
        NSString * commandString = [reversePathSegmentDictionary objectForKey:@"command"];
        
        [pathSegmentDictionary setObject:commandString forKey:@"command"];
        
        unichar commandCharacter = [commandString characterAtIndex:0];

        if (currentIndex == 0)
        {
            originalLastCommand = commandCharacter;

            NSPoint reverseOriginPoint = [self.macSVGDocumentWindowController.svgWebKitController
                    endPointForSegmentIndex:0 pathSegmentsArray:reverseSegmentsArray];
            
            NSMutableDictionary * movetoPathDictionary = [NSMutableDictionary dictionary];
            
            [movetoPathDictionary setObject:@"M" forKey:@"command"];
            
            NSString * movetoXString = [macSVGDocument allocFloatString:reverseOriginPoint.x];
            NSString * movetoYString = [macSVGDocument allocFloatString:reverseOriginPoint.y];
            
            [movetoPathDictionary setObject:movetoXString forKey:@"x"];
            [movetoPathDictionary setObject:movetoYString forKey:@"y"];
            
            [newPathSegmentsArray addObject:movetoPathDictionary];
        }
        
        // some path segments must be changed to standard cubic curves for accurate reversal
        switch (commandCharacter)
        {
            case 'S':     // absolute smooth cubic curve
            {
                // change smooth cubic curve to cubic curve
                commandCharacter = 'C';
                commandString = @"C";
                [pathSegmentDictionary setObject:commandString forKey:@"command"];

                NSString * absoluteX1String = [macSVGDocument allocFloatString:absoluteStartXFloat];
                NSString * absoluteY1String = [macSVGDocument allocFloatString:absoluteStartYFloat];
                
                if (currentIndex < [reverseSegmentsArray count])
                {
                    NSMutableDictionary * nextReversePathSegmentsDictionary =
                            [reverseSegmentsArray objectAtIndex:(currentIndex + 1)];
                    
                    NSNumber * nextAbsoluteX2Number = [nextReversePathSegmentsDictionary objectForKey:@"absoluteX2"];
                    NSNumber * nextAbsoluteY2Number = [nextReversePathSegmentsDictionary objectForKey:@"absoluteY2"];

                    if ((nextAbsoluteX2Number != NULL) && (nextAbsoluteY2Number != NULL))
                    {
                        CGFloat nextAbsoluteX2Float = [nextAbsoluteX2Number floatValue];
                        CGFloat nextAbsoluteY2Float = [nextAbsoluteY2Number floatValue];
                    
                        CGFloat absoluteX1 = absoluteStartXFloat + (absoluteStartXFloat - nextAbsoluteX2Float);
                        CGFloat absoluteY1 = absoluteStartYFloat + (absoluteStartYFloat - nextAbsoluteY2Float);
                        
                        absoluteX1String = [macSVGDocument allocFloatString:absoluteX1];
                        absoluteY1String = [macSVGDocument allocFloatString:absoluteY1];
                    }
                }
                
                [reversePathSegmentDictionary setObject:absoluteX1String forKey:@"x1"];
                [reversePathSegmentDictionary setObject:absoluteY1String forKey:@"y1"];
                
                break;
            }
            case 's':     // relative smooth cubic curve
            {
                // change smooth cubic curve to cubic curve
                commandCharacter = 'C';
                commandString = @"C";
                [pathSegmentDictionary setObject:commandString forKey:@"command"];

                NSString * absoluteX1String = [macSVGDocument allocFloatString:absoluteStartXFloat];
                NSString * absoluteY1String = [macSVGDocument allocFloatString:absoluteStartYFloat];
                
                if (currentIndex < [reverseSegmentsArray count])
                {
                    NSMutableDictionary * nextReversePathSegmentsDictionary =
                            [reverseSegmentsArray objectAtIndex:(currentIndex + 1)];
                    
                    NSNumber * nextAbsoluteX2Number = [nextReversePathSegmentsDictionary objectForKey:@"absoluteX2"];
                    NSNumber * nextAbsoluteY2Number = [nextReversePathSegmentsDictionary objectForKey:@"absoluteY2"];

                    if ((nextAbsoluteX2Number != NULL) && (nextAbsoluteY2Number != NULL))
                    {
                        CGFloat nextAbsoluteX2Float = [nextAbsoluteX2Number floatValue];
                        CGFloat nextAbsoluteY2Float = [nextAbsoluteY2Number floatValue];
                    
                        CGFloat absoluteX1 = absoluteStartXFloat + (absoluteStartXFloat - nextAbsoluteX2Float);
                        CGFloat absoluteY1 = absoluteStartYFloat + (absoluteStartYFloat - nextAbsoluteY2Float);
                        
                        absoluteX1String = [macSVGDocument allocFloatString:absoluteX1];
                        absoluteY1String = [macSVGDocument allocFloatString:absoluteY1];
                    }
                }
                
                [reversePathSegmentDictionary setObject:absoluteX1String forKey:@"x1"];
                [reversePathSegmentDictionary setObject:absoluteY1String forKey:@"y1"];

                [reversePathSegmentDictionary setObject:absoluteXString forKey:@"x"];
                [reversePathSegmentDictionary setObject:absoluteYString forKey:@"y"];

                NSNumber * absoluteX2Number = [reversePathSegmentDictionary objectForKey:@"absoluteX2"];
                NSNumber * absoluteY2Number = [reversePathSegmentDictionary objectForKey:@"absoluteY2"];

                CGFloat absoluteX2 = [absoluteX2Number floatValue];
                CGFloat absoluteY2 = [absoluteY2Number floatValue];
                
                NSString * absoluteX2String = [macSVGDocument allocFloatString:absoluteX2];
                NSString * absoluteY2String = [macSVGDocument allocFloatString:absoluteY2];
                
                [reversePathSegmentDictionary setObject:absoluteX2String forKey:@"x2"];
                [reversePathSegmentDictionary setObject:absoluteY2String forKey:@"y2"];
                
                break;
            }
            case 'Q':     // absolute quadratic curve
            {
                // change quadratic curve to cubic curve
                commandCharacter = 'C';
                commandString = @"C";
                [pathSegmentDictionary setObject:commandString forKey:@"command"];

                NSNumber * absoluteX1Number = [reversePathSegmentDictionary objectForKey:@"absoluteX1"];
                NSNumber * absoluteY1Number = [reversePathSegmentDictionary objectForKey:@"absoluteY1"];
                
                CGFloat absoluteX1Float = [absoluteX1Number floatValue];
                CGFloat absoluteY1Float = [absoluteY1Number floatValue];
                
                CGFloat newAbsoluteX1Float = absoluteStartXFloat - ((absoluteStartXFloat - absoluteX1Float) / 1.5f);
                CGFloat newAbsoluteY1Float = absoluteStartYFloat - ((absoluteStartYFloat - absoluteY1Float) / 1.5f);
                CGFloat newAbsoluteX2Float = absoluteXFloat - ((absoluteXFloat - absoluteX1Float) / 1.5f);
                CGFloat newAbsoluteY2Float = absoluteYFloat - ((absoluteYFloat - absoluteY1Float) / 1.5f);
                
                NSString * absoluteX1String = [macSVGDocument allocFloatString:newAbsoluteX1Float];
                NSString * absoluteY1String = [macSVGDocument allocFloatString:newAbsoluteY1Float];
                NSString * absoluteX2String = [macSVGDocument allocFloatString:newAbsoluteX2Float];
                NSString * absoluteY2String = [macSVGDocument allocFloatString:newAbsoluteY2Float];
                
                [reversePathSegmentDictionary setObject:absoluteX1String forKey:@"x1"];
                [reversePathSegmentDictionary setObject:absoluteY1String forKey:@"y1"];
                [reversePathSegmentDictionary setObject:absoluteX2String forKey:@"x2"];
                [reversePathSegmentDictionary setObject:absoluteY2String forKey:@"y2"];
                
                break;
            }
            case 'q':     // relative quadratic curve
            {
                // change quadratic curve to cubic curve
                commandCharacter = 'C';
                commandString = @"C";
                [pathSegmentDictionary setObject:commandString forKey:@"command"];

                NSNumber * absoluteX1Number = [reversePathSegmentDictionary objectForKey:@"absoluteX1"];
                NSNumber * absoluteY1Number = [reversePathSegmentDictionary objectForKey:@"absoluteY1"];
                
                CGFloat absoluteX1Float = [absoluteX1Number floatValue];
                CGFloat absoluteY1Float = [absoluteY1Number floatValue];
                
                CGFloat newAbsoluteX1Float = absoluteStartXFloat - ((absoluteStartXFloat - absoluteX1Float) / 1.5f);
                CGFloat newAbsoluteY1Float = absoluteStartYFloat - ((absoluteStartYFloat - absoluteY1Float) / 1.5f);
                CGFloat newAbsoluteX2Float = absoluteXFloat - ((absoluteXFloat - absoluteX1Float) / 1.5f);
                CGFloat newAbsoluteY2Float = absoluteYFloat - ((absoluteYFloat - absoluteY1Float) / 1.5f);
                
                NSString * absoluteX1String = [macSVGDocument allocFloatString:newAbsoluteX1Float];
                NSString * absoluteY1String = [macSVGDocument allocFloatString:newAbsoluteY1Float];
                NSString * absoluteX2String = [macSVGDocument allocFloatString:newAbsoluteX2Float];
                NSString * absoluteY2String = [macSVGDocument allocFloatString:newAbsoluteY2Float];
                
                [reversePathSegmentDictionary setObject:absoluteX1String forKey:@"x1"];
                [reversePathSegmentDictionary setObject:absoluteY1String forKey:@"y1"];
                [reversePathSegmentDictionary setObject:absoluteX2String forKey:@"x2"];
                [reversePathSegmentDictionary setObject:absoluteY2String forKey:@"y2"];
                
                break;
            }
            case 'T':     // absolute smooth quadratic curve
            {
                // change quadratic curve to cubic curve
                commandCharacter = 'C';
                commandString = @"C";
                [pathSegmentDictionary setObject:commandString forKey:@"command"];
                
                NSMutableDictionary * cubicSegmentDictionary = [reverseCubicsSegmentsArray objectAtIndex:currentIndex];

                NSNumber * cubicAbsoluteStartXNumber = [cubicSegmentDictionary objectForKey:@"absoluteStartX"];
                NSNumber * cubicAbsoluteStartYNumber = [cubicSegmentDictionary objectForKey:@"absoluteStartY"];
                NSNumber * cubicAbsoluteXNumber = [cubicSegmentDictionary objectForKey:@"absoluteX"];
                NSNumber * cubicAbsoluteYNumber = [cubicSegmentDictionary objectForKey:@"absoluteY"];
                NSNumber * cubicAbsoluteX1Number = [cubicSegmentDictionary objectForKey:@"absoluteX1"];
                NSNumber * cubicAbsoluteY1Number = [cubicSegmentDictionary objectForKey:@"absoluteY1"];
                NSNumber * cubicAbsoluteX2Number = [cubicSegmentDictionary objectForKey:@"absoluteX2"];
                NSNumber * cubicAbsoluteY2Number = [cubicSegmentDictionary objectForKey:@"absoluteY2"];
                
                NSString * cubicX1String = [cubicSegmentDictionary objectForKey:@"x1"];
                NSString * cubicY1String = [cubicSegmentDictionary objectForKey:@"y1"];
                NSString * cubicX2String = [cubicSegmentDictionary objectForKey:@"x2"];
                NSString * cubicY2String = [cubicSegmentDictionary objectForKey:@"y2"];
                
                // reverse the endpoint of the cubic bezier for the new segment
                
                NSMutableDictionary * newPathSegmentDictionary = [NSMutableDictionary dictionary];
                
                [newPathSegmentDictionary setObject:cubicAbsoluteXNumber forKey:@"absoluteStartX"];
                [newPathSegmentDictionary setObject:cubicAbsoluteYNumber forKey:@"absoluteStartY"];
                [newPathSegmentDictionary setObject:cubicAbsoluteStartXNumber forKey:@"absoluteX"];
                [newPathSegmentDictionary setObject:cubicAbsoluteStartYNumber forKey:@"absoluteY"];
                
                [newPathSegmentDictionary setObject:cubicAbsoluteX1Number forKey:@"absoluteX1"];
                [newPathSegmentDictionary setObject:cubicAbsoluteY1Number forKey:@"absoluteY1"];
                [newPathSegmentDictionary setObject:cubicAbsoluteX2Number forKey:@"absoluteX2"];
                [newPathSegmentDictionary setObject:cubicAbsoluteY2Number forKey:@"absoluteY2"];
                
                NSString * newXString = [cubicAbsoluteStartXNumber stringValue];
                NSString * newYString = [cubicAbsoluteStartXNumber stringValue];

                [newPathSegmentDictionary setObject:newXString forKey:@"x"];
                [newPathSegmentDictionary setObject:newYString forKey:@"y"];
                [newPathSegmentDictionary setObject:cubicX1String forKey:@"x1"];
                [newPathSegmentDictionary setObject:cubicY1String forKey:@"y1"];
                [newPathSegmentDictionary setObject:cubicX2String forKey:@"x2"];
                [newPathSegmentDictionary setObject:cubicY2String forKey:@"y2"];

                [reversePathSegmentDictionary setDictionary:newPathSegmentDictionary];

                break;
            }
            case 't':     // absolute smooth quadratic curve
            {
                commandCharacter = 'C';
                commandString = @"C";
                [pathSegmentDictionary setObject:commandString forKey:@"command"];
                
                NSMutableDictionary * cubicSegmentDictionary = [reverseCubicsSegmentsArray objectAtIndex:currentIndex];

                NSNumber * cubicAbsoluteStartXNumber = [cubicSegmentDictionary objectForKey:@"absoluteStartX"];
                NSNumber * cubicAbsoluteStartYNumber = [cubicSegmentDictionary objectForKey:@"absoluteStartY"];
                NSNumber * cubicAbsoluteXNumber = [cubicSegmentDictionary objectForKey:@"absoluteX"];
                NSNumber * cubicAbsoluteYNumber = [cubicSegmentDictionary objectForKey:@"absoluteY"];
                NSNumber * cubicAbsoluteX1Number = [cubicSegmentDictionary objectForKey:@"absoluteX1"];
                NSNumber * cubicAbsoluteY1Number = [cubicSegmentDictionary objectForKey:@"absoluteY1"];
                NSNumber * cubicAbsoluteX2Number = [cubicSegmentDictionary objectForKey:@"absoluteX2"];
                NSNumber * cubicAbsoluteY2Number = [cubicSegmentDictionary objectForKey:@"absoluteY2"];
                
                NSString * cubicX1String = [cubicSegmentDictionary objectForKey:@"x1"];
                NSString * cubicY1String = [cubicSegmentDictionary objectForKey:@"y1"];
                NSString * cubicX2String = [cubicSegmentDictionary objectForKey:@"x2"];
                NSString * cubicY2String = [cubicSegmentDictionary objectForKey:@"y2"];
                
                // reverse the endpoint of the cubic bezier for the new segment
                
                NSMutableDictionary * newPathSegmentDictionary = [NSMutableDictionary dictionary];
                
                [newPathSegmentDictionary setObject:cubicAbsoluteXNumber forKey:@"absoluteStartX"];
                [newPathSegmentDictionary setObject:cubicAbsoluteYNumber forKey:@"absoluteStartY"];
                [newPathSegmentDictionary setObject:cubicAbsoluteStartXNumber forKey:@"absoluteX"];
                [newPathSegmentDictionary setObject:cubicAbsoluteStartYNumber forKey:@"absoluteY"];
                
                [newPathSegmentDictionary setObject:cubicAbsoluteX1Number forKey:@"absoluteX1"];
                [newPathSegmentDictionary setObject:cubicAbsoluteY1Number forKey:@"absoluteY1"];
                [newPathSegmentDictionary setObject:cubicAbsoluteX2Number forKey:@"absoluteX2"];
                [newPathSegmentDictionary setObject:cubicAbsoluteY2Number forKey:@"absoluteY2"];
                
                NSString * newXString = [cubicAbsoluteStartXNumber stringValue];
                NSString * newYString = [cubicAbsoluteStartXNumber stringValue];

                [newPathSegmentDictionary setObject:newXString forKey:@"x"];
                [newPathSegmentDictionary setObject:newYString forKey:@"y"];
                [newPathSegmentDictionary setObject:cubicX1String forKey:@"x1"];
                [newPathSegmentDictionary setObject:cubicY1String forKey:@"y1"];
                [newPathSegmentDictionary setObject:cubicX2String forKey:@"x2"];
                [newPathSegmentDictionary setObject:cubicY2String forKey:@"y2"];

                [reversePathSegmentDictionary setDictionary:newPathSegmentDictionary];

                break;
            }
        }

        
        switch (commandCharacter)
        {
            case 'M':     // moveto
            {
                [pathSegmentDictionary setObject:absoluteStartXString forKey:@"x"];
                [pathSegmentDictionary setObject:absoluteStartYString forKey:@"y"];
                
                break;
            }

            case 'm':     // moveto
            {
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                break;
            }
            case 'L':     // lineto
            {
                [pathSegmentDictionary setObject:absoluteStartXString forKey:@"x"];
                [pathSegmentDictionary setObject:absoluteStartYString forKey:@"y"];

                break;
            }
            
            case 'l':     // lineto
            {
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                break;
            }

            case 'H':     // horizontal lineto
            {
                [pathSegmentDictionary setObject:absoluteStartXString forKey:@"x"];
                
                break;
            }

            case 'h':     // horizontal lineto
            {
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];
                
                break;
            }

            case 'V':     // vertical lineto
            {
                [pathSegmentDictionary setObject:absoluteStartYString forKey:@"y"];
                
                break;
            }
            
            case 'v':     // vertical lineto
            {
                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                break;
            }

            case 'C':     // curveto
            {
                [pathSegmentDictionary setObject:absoluteStartXString forKey:@"x"];
                [pathSegmentDictionary setObject:absoluteStartYString forKey:@"y"];

                NSString * x1String = [reversePathSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [reversePathSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [reversePathSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [reversePathSegmentDictionary objectForKey:@"y2"];
                
                
                [pathSegmentDictionary setObject:x2String forKey:@"x1"];
                [pathSegmentDictionary setObject:y2String forKey:@"y1"];
                [pathSegmentDictionary setObject:x1String forKey:@"x2"];
                [pathSegmentDictionary setObject:y1String forKey:@"y2"];

                break;
            }

            case 'c':     // curveto
            {
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                NSString * x1String = [reversePathSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [reversePathSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [reversePathSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [reversePathSegmentDictionary objectForKey:@"y2"];
                
                CGFloat x1Float = [x1String floatValue];
                CGFloat y1Float = [y1String floatValue];
                CGFloat x2Float = [x2String floatValue];
                CGFloat y2Float = [y2String floatValue];
                
                x1Float = -x1Float;
                y1Float = -y1Float;
                x2Float = -x2Float;
                y2Float = -y2Float;
                
                x1String = [macSVGDocument allocFloatString:x1Float];
                y1String = [macSVGDocument allocFloatString:y1Float];
                x2String = [macSVGDocument allocFloatString:x2Float];
                y2String = [macSVGDocument allocFloatString:y2Float];
                
                [pathSegmentDictionary setObject:x2String forKey:@"x1"];
                [pathSegmentDictionary setObject:y2String forKey:@"y1"];
                [pathSegmentDictionary setObject:x1String forKey:@"x2"];
                [pathSegmentDictionary setObject:y1String forKey:@"y2"];

                break;
            }

            case 'S':     // smooth curveto
            {
                // Not converted directly - smooth cubic curveto is convert to cubic curveto instead

                break;
            }

            case 's':     // smooth curveto
            {
                // Not converted directly - smooth cubic curveto is convert to cubic curveto instead
                
                break;
            }

            case 'Q':     // quadratic Bezier curve
            {
                // Not converted directly - quadratic curveto is convert to cubic curveto instead

                break;
            }

            case 'q':     // quadratic Bezier curve
            {
                // Not converted directly - quadratic curveto is convert to cubic curveto instead

                break;
            }

            case 'T':     // smooth absolute quadratic Bezier curve
            {
                // Not converted directly - quadratic curveto is convert to cubic curveto instead
                
                break;
            }

            case 't':     // smooth relative quadratic Bezier curve
            {
                // Not converted directly - quadratic curveto is convert to cubic curveto instead
                
                break;
            }

            case 'A':     // elliptical arc
            {
                [pathSegmentDictionary setObject:absoluteStartXString forKey:@"x"];
                [pathSegmentDictionary setObject:absoluteStartYString forKey:@"y"];

                NSString * rxString = [reversePathSegmentDictionary objectForKey:@"rx"];
                NSString * ryString = [reversePathSegmentDictionary objectForKey:@"ry"];
                NSString * xAxisRotationString = [reversePathSegmentDictionary objectForKey:@"x-axis-rotation"];
                NSString * largeArcFlagString = [reversePathSegmentDictionary objectForKey:@"large-arc-flag"];
                NSString * sweepFlagString = [reversePathSegmentDictionary objectForKey:@"sweep-flag"];
                
                NSInteger sweepFlag = [sweepFlagString integerValue];
                sweepFlag = !sweepFlag;
                sweepFlagString = [NSString stringWithFormat:@"%ld", sweepFlag];
                
                [pathSegmentDictionary setObject:rxString forKey:@"rx"];
                [pathSegmentDictionary setObject:ryString forKey:@"ry"];
                [pathSegmentDictionary setObject:xAxisRotationString forKey:@"x-axis-rotation"];
                [pathSegmentDictionary setObject:largeArcFlagString forKey:@"large-arc-flag"];
                [pathSegmentDictionary setObject:sweepFlagString forKey:@"sweep-flag"];

                break;
            }
            case 'a':     // elliptical arc
            {
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                NSString * rxString = [reversePathSegmentDictionary objectForKey:@"rx"];
                NSString * ryString = [reversePathSegmentDictionary objectForKey:@"ry"];
                NSString * xAxisRotationString = [reversePathSegmentDictionary objectForKey:@"x-axis-rotation"];
                NSString * largeArcFlagString = [reversePathSegmentDictionary objectForKey:@"large-arc-flag"];
                NSString * sweepFlagString = [reversePathSegmentDictionary objectForKey:@"sweep-flag"];

                NSInteger sweepFlag = [sweepFlagString integerValue];
                sweepFlag = !sweepFlag;
                sweepFlagString = [NSString stringWithFormat:@"%ld", sweepFlag];
                
                [pathSegmentDictionary setObject:rxString forKey:@"rx"];
                [pathSegmentDictionary setObject:ryString forKey:@"ry"];
                [pathSegmentDictionary setObject:xAxisRotationString forKey:@"x-axis-rotation"];
                [pathSegmentDictionary setObject:largeArcFlagString forKey:@"large-arc-flag"];
                [pathSegmentDictionary setObject:sweepFlagString forKey:@"sweep-flag"];

                break;
            }

            case 'Z':     // closepath
            case 'z':     // closepath
                break;
        }
        
        if (currentIndex == 0)
        {
            if ((commandCharacter != 'Z') && (commandCharacter != 'z'))
            {
                [newPathSegmentsArray addObject:pathSegmentDictionary];
            }
        }
        else if (currentIndex >= [reverseSegmentsArray count] - 1)
        {
            if ((commandCharacter != 'M') && (commandCharacter != 'm'))
            {
                [newPathSegmentsArray addObject:pathSegmentDictionary];
            }
        }
        else
        {
            [newPathSegmentsArray addObject:pathSegmentDictionary];
        }
        
        currentIndex++;
    }
    
    if ((originalLastCommand == 'Z') || (originalLastCommand == 'z'))
    {
        NSMutableDictionary * closePathDictionary = [NSMutableDictionary dictionary];
        
        NSString * newLastCommand = [NSString stringWithFormat:@"%C", originalLastCommand];
        [closePathDictionary setObject:newLastCommand forKey:@"command"];
        
        [newPathSegmentsArray addObject:closePathDictionary];
    }

    [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:newPathSegmentsArray];
    
    return newPathSegmentsArray;
}

//==================================================================================
//	mirrorPathHorizontallyWithPathSegmentsArray:
//==================================================================================

- (NSMutableArray *)mirrorPathHorizontallyWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    // reverse sequence of input array
    NSMutableArray * reverseSegmentsArray = [NSMutableArray array];
    for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
    {
        NSMutableDictionary * newSegmentDictionary = [self duplicateSegmentDictionary:pathSegmentDictionary];

        [reverseSegmentsArray insertObject:newSegmentDictionary atIndex:0];
    }

    NSMutableArray * cubicPathSegmentsArray = [self copyPathSegmentsArray:pathSegmentsArray];
    cubicPathSegmentsArray = [self convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray:cubicPathSegmentsArray];
    NSMutableArray * reverseCubicsSegmentsArray = [NSMutableArray array];
    for (NSMutableDictionary * cubicSegmentDictionary in cubicPathSegmentsArray)
    {
        NSMutableDictionary * newCubicSegmentDictionary = [self duplicateSegmentDictionary:cubicSegmentDictionary];

        [reverseCubicsSegmentsArray insertObject:newCubicSegmentDictionary atIndex:0];
    }

    NSInteger lastIndex = [pathSegmentsArray count] - 1;
    
    NSPoint reverseOriginPoint = [self.macSVGDocumentWindowController.svgWebKitController
            endPointForSegmentIndex:lastIndex pathSegmentsArray:pathSegmentsArray];
    
    NSInteger currentIndex = 0;
    
    for (NSMutableDictionary * pathSegmentDictionary in reverseSegmentsArray)
    {
        MacSVGDocument * macSVGDocument = [self.macSVGDocumentWindowController document];
        
        NSNumber * absoluteStartXNumber = [pathSegmentDictionary objectForKey:@"absoluteStartX"];
        NSNumber * absoluteStartYNumber = [pathSegmentDictionary objectForKey:@"absoluteStartY"];
        
        CGFloat absoluteStartXFloat = [absoluteStartXNumber floatValue];
        CGFloat absoluteStartYFloat = [absoluteStartYNumber floatValue];

        NSPoint originalCurrentPoint = [self.macSVGDocumentWindowController.svgWebKitController
                endPointForSegmentIndex:(lastIndex - currentIndex)
                pathSegmentsArray:pathSegmentsArray];
        
        CGFloat currentXDelta = originalCurrentPoint.x - reverseOriginPoint.x;
        
        NSPoint currentPoint = NSMakePoint(originalCurrentPoint.x - currentXDelta, originalCurrentPoint.y);
        
        NSString * commandString = [pathSegmentDictionary objectForKey:@"command"];
        
        unichar commandCharacter = [commandString characterAtIndex:0];
        
        switch (commandCharacter)
        {
            case 'M':     // moveto
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                break;
            }

            case 'm':     // moveto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];

                CGFloat xFloat = [xString floatValue];
                CGFloat yFloat = [yString floatValue];

                xFloat = -xFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                yFloat = -yFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                break;
            }
            case 'L':     // lineto
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                break;
            }
            
            case 'l':     // lineto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                
                CGFloat xFloat = [xString floatValue];
                CGFloat yFloat = [yString floatValue];

                CGFloat newXFloat = xFloat;
                CGFloat newYFloat = -yFloat;

                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                yFloat = -yFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                break;
            }

            case 'H':     // horizontal lineto
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                
                break;
            }

            case 'h':     // horizontal lineto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                
                CGFloat xFloat = [xString floatValue];
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];
                
                break;
            }

            case 'V':     // vertical lineto
            {
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                
                CGFloat yFloat = [yString floatValue];
                
                CGFloat yDelta = absoluteStartYFloat - yFloat;
                yFloat = currentPoint.y + yDelta;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                break;
            }
            
            case 'v':     // vertical lineto
            {
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                
                CGFloat yFloat = [yString floatValue];
                
                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                break;
            }

            case 'C':     // curveto
            {
                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                
                CGFloat x1Float = [x1String floatValue];
                CGFloat y1Float = [y1String floatValue];
                CGFloat x2Float = [x2String floatValue];
                CGFloat y2Float = [y2String floatValue];
                
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                CGFloat deltaX1 = currentPoint.x - x2Float;
                CGFloat deltaX2 = currentPoint.x - x1Float;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                CGFloat newX1Float = currentPoint.x + deltaX1;
                CGFloat newY1Float = y2Float;
                CGFloat newX2Float = currentPoint.x + deltaX2;
                CGFloat newY2Float = y1Float;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                [pathSegmentDictionary setObject:newX2String forKey:@"x2"];

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                [pathSegmentDictionary setObject:newY2String forKey:@"y2"];

                break;
            }

            case 'c':     // curveto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                
                CGFloat xFloat = [xString floatValue];
                CGFloat yFloat = [yString floatValue];
                CGFloat x1Float = [x1String floatValue];
                CGFloat y1Float = [y1String floatValue];
                CGFloat x2Float = [x2String floatValue];
                CGFloat y2Float = [y2String floatValue];
                
                //float deltaX = currentPoint.x - absoluteStartXFloat;
                CGFloat deltaX1 = currentPoint.x - x2Float;
                CGFloat deltaX2 = currentPoint.x - x1Float;
                
                CGFloat newXFloat = xFloat;
                CGFloat newYFloat = -yFloat;
                CGFloat newX1Float = currentPoint.x + deltaX1;
                CGFloat newY1Float = y2Float;
                CGFloat newX2Float = currentPoint.x + deltaX2;
                CGFloat newY2Float = y1Float;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                [pathSegmentDictionary setObject:newX2String forKey:@"x2"];

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                [pathSegmentDictionary setObject:newY2String forKey:@"y2"];

                break;
            }

            case 'S':     // smooth curveto
            case 's':     // smooth curveto
            {
                // Convert this segment to an absolute cubic curve
                NSMutableDictionary * cubicSegmentDictionary = [reverseCubicsSegmentsArray objectAtIndex:currentIndex];

                NSString * x1String = [cubicSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [cubicSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [cubicSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [cubicSegmentDictionary objectForKey:@"y2"];
                
                //NSString * cubicXString = [cubicSegmentDictionary objectForKey:@"x"];
                //NSString * cubicYString = [cubicSegmentDictionary objectForKey:@"y"];

                CGFloat x1Float = [x1String floatValue];
                CGFloat y1Float = [y1String floatValue];
                CGFloat x2Float = [x2String floatValue];
                CGFloat y2Float = [y2String floatValue];
                
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                CGFloat deltaX1 = currentPoint.x - x2Float;
                CGFloat deltaX2 = currentPoint.x - x1Float;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                CGFloat newX1Float = currentPoint.x + deltaX1;
                CGFloat newY1Float = y2Float;
                CGFloat newX2Float = currentPoint.x + deltaX2;
                CGFloat newY2Float = y1Float;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                [pathSegmentDictionary setObject:newX2String forKey:@"x2"];

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
                
                [pathSegmentDictionary setObject:@"C" forKey:@"command"];

                break;
            }


            case 'Q':     // quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
            {
                // Convert this segment to an absolute cubic curve
                NSMutableDictionary * cubicSegmentDictionary = [reverseCubicsSegmentsArray objectAtIndex:currentIndex];

                NSString * x1String = [cubicSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [cubicSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [cubicSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [cubicSegmentDictionary objectForKey:@"y2"];
                
                //NSString * cubicXString = [cubicSegmentDictionary objectForKey:@"x"];
                //NSString * cubicYString = [cubicSegmentDictionary objectForKey:@"y"];

                CGFloat x1Float = [x1String floatValue];
                CGFloat y1Float = [y1String floatValue];
                CGFloat x2Float = [x2String floatValue];
                CGFloat y2Float = [y2String floatValue];
                
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                CGFloat deltaX1 = currentPoint.x - x2Float;
                CGFloat deltaX2 = currentPoint.x - x1Float;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                CGFloat newX1Float = currentPoint.x + deltaX1;
                CGFloat newY1Float = y2Float;
                CGFloat newX2Float = currentPoint.x + deltaX2;
                CGFloat newY2Float = y1Float;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                [pathSegmentDictionary setObject:newX2String forKey:@"x2"];

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
                
                [pathSegmentDictionary setObject:@"C" forKey:@"command"];

                break;
            }


            case 'T':     // smooth quadratic Bezier curve
            case 't':     // smooth quadratic Bezier curve
            {
                // Convert this segment to an absolute cubic curve
                NSMutableDictionary * cubicSegmentDictionary = [reverseCubicsSegmentsArray objectAtIndex:currentIndex];

                NSString * x1String = [cubicSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [cubicSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [cubicSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [cubicSegmentDictionary objectForKey:@"y2"];
                
                //NSString * cubicXString = [cubicSegmentDictionary objectForKey:@"x"];
                //NSString * cubicYString = [cubicSegmentDictionary objectForKey:@"y"];

                CGFloat x1Float = [x1String floatValue];
                CGFloat y1Float = [y1String floatValue];
                CGFloat x2Float = [x2String floatValue];
                CGFloat y2Float = [y2String floatValue];
                
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                CGFloat deltaX1 = currentPoint.x - x2Float;
                CGFloat deltaX2 = currentPoint.x - x1Float;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                CGFloat newX1Float = currentPoint.x + deltaX1;
                CGFloat newY1Float = y2Float;
                CGFloat newX2Float = currentPoint.x + deltaX2;
                CGFloat newY2Float = y1Float;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                [pathSegmentDictionary setObject:newX2String forKey:@"x2"];

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
                
                [pathSegmentDictionary setObject:@"C" forKey:@"command"];

                break;
            }



            case 'A':     // elliptical arc
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                break;
            }
            case 'a':     // elliptical arc
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                
                CGFloat xFloat = [xString floatValue];
                CGFloat yFloat = [yString floatValue];
                
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                break;
            }

            case 'Z':     // closepath
            case 'z':     // closepath
                break;
        }
        
        currentIndex++;
    }

    [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:reverseSegmentsArray];
    
    return reverseSegmentsArray;
}

//==================================================================================
//	mirrorPathVerticallyWithPathSegmentsArray:
//==================================================================================

- (NSMutableArray *)mirrorPathVerticallyWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    // reverse sequence of input array
    NSMutableArray * reverseSegmentsArray = [NSMutableArray array];
    for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
    {
        NSMutableDictionary * newSegmentDictionary = [self duplicateSegmentDictionary:pathSegmentDictionary];

        [reverseSegmentsArray insertObject:newSegmentDictionary atIndex:0];
    }


    NSMutableArray * cubicPathSegmentsArray = [self copyPathSegmentsArray:pathSegmentsArray];
    cubicPathSegmentsArray = [self convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray:cubicPathSegmentsArray];
    NSMutableArray * reverseCubicsSegmentsArray = [NSMutableArray array];
    for (NSMutableDictionary * cubicSegmentDictionary in cubicPathSegmentsArray)
    {
        NSMutableDictionary * newCubicSegmentDictionary = [self duplicateSegmentDictionary:cubicSegmentDictionary];

        [reverseCubicsSegmentsArray insertObject:newCubicSegmentDictionary atIndex:0];
    }



    NSInteger lastIndex = [pathSegmentsArray count] - 1;
    
    NSPoint reverseOriginPoint = [self.macSVGDocumentWindowController.svgWebKitController
            endPointForSegmentIndex:lastIndex pathSegmentsArray:pathSegmentsArray];
    
    NSInteger currentIndex = 0;
    
    for (NSMutableDictionary * pathSegmentDictionary in reverseSegmentsArray)
    {
        MacSVGDocument * macSVGDocument = [self.macSVGDocumentWindowController document];
        
        NSNumber * absoluteStartXNumber = [pathSegmentDictionary objectForKey:@"absoluteStartX"];
        NSNumber * absoluteStartYNumber = [pathSegmentDictionary objectForKey:@"absoluteStartY"];
        
        CGFloat absoluteStartXFloat = [absoluteStartXNumber floatValue];
        CGFloat absoluteStartYFloat = [absoluteStartYNumber floatValue];

        NSPoint originalCurrentPoint = [self.macSVGDocumentWindowController.svgWebKitController
                endPointForSegmentIndex:(lastIndex - currentIndex)
                pathSegmentsArray:pathSegmentsArray];
        
        CGFloat currentYDelta = originalCurrentPoint.y - reverseOriginPoint.y;
        
        NSPoint currentPoint = NSMakePoint(originalCurrentPoint.x, originalCurrentPoint.y - currentYDelta);
        
        NSString * commandString = [pathSegmentDictionary objectForKey:@"command"];
        
        unichar commandCharacter = [commandString characterAtIndex:0];
        
        switch (commandCharacter)
        {
            case 'M':     // moveto
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                break;
            }

            case 'm':     // moveto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];

                CGFloat xFloat = [xString floatValue];
                CGFloat yFloat = [yString floatValue];

                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                break;
            }
            case 'L':     // lineto
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                break;
            }
            
            case 'l':     // lineto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                
                CGFloat xFloat = [xString floatValue];
                CGFloat yFloat = [yString floatValue];

                CGFloat newXFloat = xFloat;
                CGFloat newYFloat = -yFloat;

                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                break;
            }

            case 'H':     // horizontal lineto
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                
                break;
            }

            case 'h':     // horizontal lineto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                
                CGFloat xFloat = [xString floatValue];
                
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];
                
                break;
            }

            case 'V':     // vertical lineto
            {
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                
                CGFloat yFloat = [yString floatValue];
                
                CGFloat yDelta = absoluteStartYFloat - yFloat;
                yFloat = currentPoint.y + yDelta;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];
                
                break;
            }
            
            case 'v':     // vertical lineto
            {
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                
                CGFloat yFloat = [yString floatValue];
                
                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                break;
            }

            case 'C':     // curveto
            {
                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                
                CGFloat x1Float = [x1String floatValue];
                CGFloat y1Float = [y1String floatValue];
                CGFloat x2Float = [x2String floatValue];
                CGFloat y2Float = [y2String floatValue];
                
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                CGFloat deltaX1 = currentPoint.x - x2Float;
                CGFloat deltaX2 = currentPoint.x - x1Float;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                CGFloat newX1Float = currentPoint.x + deltaX1;
                CGFloat newY1Float = y2Float;
                CGFloat newX2Float = currentPoint.x + deltaX2;
                CGFloat newY2Float = y1Float;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                NSString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                NSString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

                NSString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                [pathSegmentDictionary setObject:newX2String forKey:@"x2"];

                NSString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                [pathSegmentDictionary setObject:newY2String forKey:@"y2"];

                break;
            }

            case 'c':     // curveto
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                
                CGFloat xFloat = [xString floatValue];
                CGFloat yFloat = [yString floatValue];
                CGFloat x1Float = [x1String floatValue];
                CGFloat y1Float = [y1String floatValue];
                CGFloat x2Float = [x2String floatValue];
                CGFloat y2Float = [y2String floatValue];
                
                CGFloat deltaX1 = currentPoint.x - x2Float;
                CGFloat deltaX2 = currentPoint.x - x1Float;
                
                CGFloat newXFloat = xFloat;
                CGFloat newYFloat = -yFloat;
                CGFloat newX1Float = currentPoint.x + deltaX1;
                CGFloat newY1Float = y2Float;
                CGFloat newX2Float = currentPoint.x + deltaX2;
                CGFloat newY2Float = y1Float;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                NSString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                NSString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

                NSString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                [pathSegmentDictionary setObject:newX2String forKey:@"x2"];

                NSString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                [pathSegmentDictionary setObject:newY2String forKey:@"y2"];

                break;
            }


            case 'S':     // smooth curveto
            case 's':     // smooth curveto
            case 'Q':     // quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
            case 'T':     // smooth quadratic Bezier curve
            case 't':     // smooth quadratic Bezier curve
            {
                // Convert this segment to an absolute cubic curve
                NSMutableDictionary * cubicSegmentDictionary = [reverseCubicsSegmentsArray objectAtIndex:currentIndex];

                NSString * x1String = [cubicSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [cubicSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [cubicSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [cubicSegmentDictionary objectForKey:@"y2"];
                
                CGFloat x1Float = [x1String floatValue];
                CGFloat y1Float = [y1String floatValue];
                CGFloat x2Float = [x2String floatValue];
                CGFloat y2Float = [y2String floatValue];
                
                CGFloat deltaY = currentPoint.y - absoluteStartYFloat;
                CGFloat deltaY1 = currentPoint.y - y2Float;
                CGFloat deltaY2 = currentPoint.y - y1Float;
                
                CGFloat newXFloat = absoluteStartXFloat;
                CGFloat newYFloat = currentPoint.y + deltaY;
                CGFloat newX1Float = x2Float;
                CGFloat newY1Float = currentPoint.y + deltaY1;
                CGFloat newX2Float = x1Float;
                CGFloat newY2Float = currentPoint.y + deltaY2;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                [pathSegmentDictionary setObject:newX1String forKey:@"x1"];

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                [pathSegmentDictionary setObject:newX2String forKey:@"x2"];

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
                
                [pathSegmentDictionary setObject:@"C" forKey:@"command"];

                break;
            }
                
            case 'A':     // elliptical arc
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                break;
            }
            case 'a':     // elliptical arc
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                
                CGFloat xFloat = [xString floatValue];
                CGFloat yFloat = [yString floatValue];
                
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                [pathSegmentDictionary setObject:newXString forKey:@"x"];

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                [pathSegmentDictionary setObject:newYString forKey:@"y"];

                break;
            }

            case 'Z':     // closepath
            case 'z':     // closepath
                break;
        }
        
        currentIndex++;
    }

    [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:reverseSegmentsArray];
    
    return reverseSegmentsArray;
}

//==================================================================================
//	floatForAttribute:pathSegment:
//==================================================================================

- (CGFloat) floatForAttribute:(NSString *)attributeName pathSegment:(NSDictionary *)pathSegmentDictionary
{
    CGFloat result = 0;
    NSString * valueString = [pathSegmentDictionary objectForKey:attributeName];
    if (valueString != NULL)
    {
        result = [valueString floatValue];
    }
    return result;
}

//==================================================================================
//	flipPathHorizontallyWithPathSegmentsArray:
//==================================================================================

- (NSMutableArray *)flipPathHorizontallyWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    MacSVGDocument * macSVGDocument = [self.macSVGDocumentWindowController document];

    NSMutableArray * newSegmentsArray = [NSMutableArray array];

    if ([pathSegmentsArray count] > 0)
    {
        CGFloat pathOriginX = 0;
        CGFloat pathOriginY = 0;
        
        NSInteger currentIndex = 0;
        
        for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
        {
            CGFloat oldAbsoluteXFloat = [self floatForAttribute:@"absoluteX" pathSegment:pathSegmentDictionary];
            CGFloat oldXFloat = [self floatForAttribute:@"x" pathSegment:pathSegmentDictionary];
            CGFloat oldYFloat = [self floatForAttribute:@"y" pathSegment:pathSegmentDictionary];
            NSString * oldYString = [macSVGDocument allocFloatString:oldYFloat];

            CGFloat oldAbsoluteX1Float = [self floatForAttribute:@"absoluteX1" pathSegment:pathSegmentDictionary];
            CGFloat oldX1Float = [self floatForAttribute:@"x1" pathSegment:pathSegmentDictionary];
            CGFloat oldY1Float = [self floatForAttribute:@"y1" pathSegment:pathSegmentDictionary];
            NSString * oldY1String = [macSVGDocument allocFloatString:oldY1Float];

            CGFloat oldAbsoluteX2Float = [self floatForAttribute:@"absoluteX2" pathSegment:pathSegmentDictionary];
            CGFloat oldX2Float = [self floatForAttribute:@"x2" pathSegment:pathSegmentDictionary];
            CGFloat oldY2Float = [self floatForAttribute:@"y2" pathSegment:pathSegmentDictionary];
            NSString * oldY2String = [macSVGDocument allocFloatString:oldY2Float];
            
            if (currentIndex == 0)
            {
                oldAbsoluteXFloat = oldXFloat;
            
                pathOriginX = oldXFloat;
                pathOriginY = oldYFloat;
            }

            CGFloat newAbsoluteXFloat = pathOriginX + (pathOriginX - oldAbsoluteXFloat);
            NSString * newAbsoluteXString = [macSVGDocument allocFloatString:newAbsoluteXFloat];

            CGFloat newAbsoluteX1Float = pathOriginX + (pathOriginX - oldAbsoluteX1Float);
            NSString * newAbsoluteX1String = [macSVGDocument allocFloatString:newAbsoluteX1Float];

            CGFloat newAbsoluteX2Float = pathOriginX + (pathOriginX - oldAbsoluteX2Float);
            NSString * newAbsoluteX2String = [macSVGDocument allocFloatString:newAbsoluteX2Float];

            CGFloat newRelativeXFloat = -oldXFloat;
            NSString * newRelativeXString = [macSVGDocument allocFloatString:newRelativeXFloat];

            CGFloat newRelativeX1Float = -oldX1Float;
            NSString * newRelativeX1String = [macSVGDocument allocFloatString:newRelativeX1Float];

            CGFloat newRelativeX2Float = -oldX2Float;
            NSString * newRelativeX2String = [macSVGDocument allocFloatString:newRelativeX2Float];
            
            NSString * commandString = [pathSegmentDictionary objectForKey:@"command"];
            
            unichar commandCharacter = [commandString characterAtIndex:0];
            
            NSMutableDictionary * newSegmentDictionary = [NSMutableDictionary dictionary];

            [newSegmentDictionary setObject:commandString forKey:@"command"];
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];
                    break;
                }

                case 'm':     // moveto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];
                    break;
                }
                case 'L':     // lineto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];
                    break;
                }
                
                case 'l':     // lineto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];
                    break;
                }

                case 'H':     // horizontal lineto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    break;
                }

                case 'h':     // horizontal lineto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    break;
                }

                case 'V':     // vertical lineto
                {
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];
                    break;
                }
                
                case 'v':     // vertical lineto
                {
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];
                    break;
                }

                case 'C':     // absolute curveto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];
                    [newSegmentDictionary setObject:newAbsoluteX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:oldY1String forKey:@"y1"];
                    [newSegmentDictionary setObject:newAbsoluteX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:oldY2String forKey:@"y2"];
                    break;
                }

                case 'c':     // relative curveto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];
                    [newSegmentDictionary setObject:newRelativeX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:oldY1String forKey:@"y1"];
                    [newSegmentDictionary setObject:newRelativeX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:oldY2String forKey:@"y2"];

                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];
                    [newSegmentDictionary setObject:newAbsoluteX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:oldY2String forKey:@"y2"];
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];
                    [newSegmentDictionary setObject:newRelativeX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:oldY2String forKey:@"y2"];
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];
                    [newSegmentDictionary setObject:newAbsoluteX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:oldY1String forKey:@"y1"];
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];
                    [newSegmentDictionary setObject:newRelativeX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:oldY1String forKey:@"y1"];
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];
                    break;
                }

                case 'A':     // elliptical arc
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];

                    NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                    NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                    NSString * xAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                    NSString * largeArcFlagString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                    NSString * sweepFlagString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
                    
                    [newSegmentDictionary setObject:rxString forKey:@"rx"];
                    [newSegmentDictionary setObject:ryString forKey:@"ry"];
                    [newSegmentDictionary setObject:xAxisRotationString forKey:@"x-axis-rotation"];
                    [newSegmentDictionary setObject:largeArcFlagString forKey:@"large-arc-flag"];
                    [newSegmentDictionary setObject:sweepFlagString forKey:@"sweep-flag"];

                    break;
                }
                case 'a':     // elliptical arc
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:oldYString forKey:@"y"];

                    NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                    NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                    NSString * xAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                    NSString * largeArcFlagString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                    NSString * sweepFlagString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
                    
                    [newSegmentDictionary setObject:rxString forKey:@"rx"];
                    [newSegmentDictionary setObject:ryString forKey:@"ry"];
                    [newSegmentDictionary setObject:xAxisRotationString forKey:@"x-axis-rotation"];
                    [newSegmentDictionary setObject:largeArcFlagString forKey:@"large-arc-flag"];
                    [newSegmentDictionary setObject:sweepFlagString forKey:@"sweep-flag"];
                    break;
                }

                case 'Z':     // closepath
                case 'z':     // closepath
                    break;
            }
            
            [newSegmentsArray addObject:newSegmentDictionary];
            
            currentIndex++;
        }
        
        [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:newSegmentsArray];
    }
    
    return newSegmentsArray;
}

//==================================================================================
//	flipPathVerticallyWithPathSegmentsArray:
//==================================================================================

- (NSMutableArray *)flipPathVerticallyWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    MacSVGDocument * macSVGDocument = [self.macSVGDocumentWindowController document];

    NSMutableArray * newSegmentsArray = [NSMutableArray array];

    if ([pathSegmentsArray count] > 0)
    {
        NSInteger lastIndex = [pathSegmentsArray count] - 1;
        
        NSPoint pathOriginPoint = [self.macSVGDocumentWindowController.svgWebKitController
                endPointForSegmentIndex:0 pathSegmentsArray:pathSegmentsArray];
        
        NSPoint pathEndPoint = [self.macSVGDocumentWindowController.svgWebKitController
                endPointForSegmentIndex:lastIndex pathSegmentsArray:pathSegmentsArray];

        NSInteger currentIndex = 0;
        
        for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
        {
            CGFloat oldAbsoluteYFloat = [self floatForAttribute:@"absoluteY" pathSegment:pathSegmentDictionary];
            CGFloat oldXFloat = [self floatForAttribute:@"x" pathSegment:pathSegmentDictionary];
            CGFloat oldYFloat = [self floatForAttribute:@"y" pathSegment:pathSegmentDictionary];
            NSString * oldXString = [macSVGDocument allocFloatString:oldXFloat];

            CGFloat oldAbsoluteY1Float = [self floatForAttribute:@"absoluteY1" pathSegment:pathSegmentDictionary];
            CGFloat oldX1Float = [self floatForAttribute:@"x1" pathSegment:pathSegmentDictionary];
            CGFloat oldY1Float = [self floatForAttribute:@"y1" pathSegment:pathSegmentDictionary];
            NSString * oldX1String = [macSVGDocument allocFloatString:oldX1Float];

            CGFloat oldAbsoluteY2Float = [self floatForAttribute:@"absoluteY2" pathSegment:pathSegmentDictionary];
            CGFloat oldX2Float = [self floatForAttribute:@"x2" pathSegment:pathSegmentDictionary];
            CGFloat oldY2Float = [self floatForAttribute:@"y2" pathSegment:pathSegmentDictionary];
            NSString * oldX2String = [macSVGDocument allocFloatString:oldX2Float];
            
            CGFloat newAbsoluteYFloat = pathEndPoint.y - (oldAbsoluteYFloat - pathOriginPoint.y);
            NSString * newAbsoluteYString = [macSVGDocument allocFloatString:newAbsoluteYFloat];

            CGFloat newAbsoluteY1Float = pathEndPoint.y - (oldAbsoluteY1Float - pathOriginPoint.y);
            NSString * newAbsoluteY1String = [macSVGDocument allocFloatString:newAbsoluteY1Float];

            CGFloat newAbsoluteY2Float = pathEndPoint.y - (oldAbsoluteY2Float - pathOriginPoint.y);
            NSString * newAbsoluteY2String = [macSVGDocument allocFloatString:newAbsoluteY2Float];

            CGFloat newRelativeYFloat = -oldYFloat;
            NSString * newRelativeYString = [macSVGDocument allocFloatString:newRelativeYFloat];

            CGFloat newRelativeY1Float = -oldY1Float;
            NSString * newRelativeY1String = [macSVGDocument allocFloatString:newRelativeY1Float];

            CGFloat newRelativeY2Float = -oldY2Float;
            NSString * newRelativeY2String = [macSVGDocument allocFloatString:newRelativeY2Float];
            
            NSString * commandString = [pathSegmentDictionary objectForKey:@"command"];
            
            unichar commandCharacter = [commandString characterAtIndex:0];
            
            NSMutableDictionary * newSegmentDictionary = [NSMutableDictionary dictionary];

            [newSegmentDictionary setObject:commandString forKey:@"command"];
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;
                }

                case 'm':     // moveto
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    break;
                }
                case 'L':     // lineto
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;
                }
                
                case 'l':     // lineto
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    break;
                }

                case 'H':     // horizontal lineto
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    break;
                }

                case 'h':     // horizontal lineto
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    break;
                }

                case 'V':     // vertical lineto
                {
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;
                }
                
                case 'v':     // vertical lineto
                {
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    break;
                }

                case 'C':     // absolute curveto
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    [newSegmentDictionary setObject:oldX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:newAbsoluteY1String forKey:@"y1"];
                    [newSegmentDictionary setObject:oldX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:newAbsoluteY2String forKey:@"y2"];
                    break;
                }

                case 'c':     // relative curveto
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    [newSegmentDictionary setObject:oldX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:newRelativeY1String forKey:@"y1"];
                    [newSegmentDictionary setObject:oldX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:newRelativeY2String forKey:@"y2"];
                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    [newSegmentDictionary setObject:oldX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:newAbsoluteY2String forKey:@"y2"];
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    [newSegmentDictionary setObject:oldX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:newRelativeY2String forKey:@"y2"];
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    [newSegmentDictionary setObject:oldX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:newAbsoluteY1String forKey:@"y1"];
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    [newSegmentDictionary setObject:oldX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:newRelativeY1String forKey:@"y1"];
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    break;
                }

                case 'A':     // elliptical arc
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    
                    NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                    NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                    NSString * xAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                    NSString * largeArcFlagString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                    NSString * sweepFlagString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
                    
                    [newSegmentDictionary setObject:rxString forKey:@"rx"];
                    [newSegmentDictionary setObject:ryString forKey:@"ry"];
                    [newSegmentDictionary setObject:xAxisRotationString forKey:@"x-axis-rotation"];
                    [newSegmentDictionary setObject:largeArcFlagString forKey:@"large-arc-flag"];
                    [newSegmentDictionary setObject:sweepFlagString forKey:@"sweep-flag"];

                    break;
                }
                case 'a':     // elliptical arc
                {
                    [newSegmentDictionary setObject:oldXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    
                    NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                    NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                    NSString * xAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                    NSString * largeArcFlagString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                    NSString * sweepFlagString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
                    
                    [newSegmentDictionary setObject:rxString forKey:@"rx"];
                    [newSegmentDictionary setObject:ryString forKey:@"ry"];
                    [newSegmentDictionary setObject:xAxisRotationString forKey:@"x-axis-rotation"];
                    [newSegmentDictionary setObject:largeArcFlagString forKey:@"large-arc-flag"];
                    [newSegmentDictionary setObject:sweepFlagString forKey:@"sweep-flag"];

                    break;
                }

                case 'Z':     // closepath
                case 'z':     // closepath
                    break;
            }
            
            [newSegmentsArray addObject:newSegmentDictionary];
            
            currentIndex++;
        }
        
        [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:newSegmentsArray];
    }
    
    return newSegmentsArray;
}


//==================================================================================
//	translatePathCoordinatesWithPathSegmentsArray:x:y:
//==================================================================================

- (NSMutableArray *)translatePathCoordinatesWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray x:(CGFloat)translateX y:(CGFloat)translateY
{
    MacSVGDocument * macSVGDocument = [self.macSVGDocumentWindowController document];

    NSMutableArray * newSegmentsArray = [NSMutableArray array];

    if ([pathSegmentsArray count] > 0)
    {
        NSPoint pathOriginPoint = [self.macSVGDocumentWindowController.svgWebKitController
                endPointForSegmentIndex:0 pathSegmentsArray:pathSegmentsArray];
        
        NSInteger currentIndex = 0;
        
        for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
        {
            CGFloat oldAbsoluteXFloat = [self floatForAttribute:@"absoluteX" pathSegment:pathSegmentDictionary];
            CGFloat oldAbsoluteYFloat = [self floatForAttribute:@"absoluteY" pathSegment:pathSegmentDictionary];
            CGFloat oldXFloat = [self floatForAttribute:@"x" pathSegment:pathSegmentDictionary];
            CGFloat oldYFloat = [self floatForAttribute:@"y" pathSegment:pathSegmentDictionary];

            CGFloat oldAbsoluteX1Float = [self floatForAttribute:@"absoluteX1" pathSegment:pathSegmentDictionary];
            CGFloat oldAbsoluteY1Float = [self floatForAttribute:@"absoluteY1" pathSegment:pathSegmentDictionary];
            CGFloat oldX1Float = [self floatForAttribute:@"x1" pathSegment:pathSegmentDictionary];
            CGFloat oldY1Float = [self floatForAttribute:@"y1" pathSegment:pathSegmentDictionary];

            CGFloat oldAbsoluteX2Float = [self floatForAttribute:@"absoluteX2" pathSegment:pathSegmentDictionary];
            CGFloat oldAbsoluteY2Float = [self floatForAttribute:@"absoluteY2" pathSegment:pathSegmentDictionary];
            CGFloat oldX2Float = [self floatForAttribute:@"x2" pathSegment:pathSegmentDictionary];
            CGFloat oldY2Float = [self floatForAttribute:@"y2" pathSegment:pathSegmentDictionary];

            CGFloat newAbsoluteXFloat = ((oldAbsoluteXFloat - pathOriginPoint.x) + translateX) + pathOriginPoint.x;
            NSString * newAbsoluteXString = [macSVGDocument allocFloatString:newAbsoluteXFloat];
            
            CGFloat newAbsoluteYFloat = ((oldAbsoluteYFloat - pathOriginPoint.y) + translateY) + pathOriginPoint.y;
            NSString * newAbsoluteYString = [macSVGDocument allocFloatString:newAbsoluteYFloat];

            CGFloat newAbsoluteX1Float = ((oldAbsoluteX1Float - pathOriginPoint.x) + translateX) + pathOriginPoint.x;
            NSString * newAbsoluteX1String = [macSVGDocument allocFloatString:newAbsoluteX1Float];

            CGFloat newAbsoluteY1Float = ((oldAbsoluteY1Float - pathOriginPoint.y) + translateY) + pathOriginPoint.y;
            NSString * newAbsoluteY1String = [macSVGDocument allocFloatString:newAbsoluteY1Float];

            CGFloat newAbsoluteX2Float = ((oldAbsoluteX2Float - pathOriginPoint.x) + translateX) + pathOriginPoint.x;
            NSString * newAbsoluteX2String = [macSVGDocument allocFloatString:newAbsoluteX2Float];

            CGFloat newAbsoluteY2Float = ((oldAbsoluteY2Float - pathOriginPoint.y) + translateY) + pathOriginPoint.y;
            NSString * newAbsoluteY2String = [macSVGDocument allocFloatString:newAbsoluteY2Float];

            CGFloat newRelativeXFloat = oldXFloat + translateX;
            NSString * newRelativeXString = [macSVGDocument allocFloatString:newRelativeXFloat];

            CGFloat newRelativeYFloat = oldYFloat + translateY;
            NSString * newRelativeYString = [macSVGDocument allocFloatString:newRelativeYFloat];

            CGFloat newRelativeX1Float = oldX1Float + translateX;
            NSString * newRelativeX1String = [macSVGDocument allocFloatString:newRelativeX1Float];

            CGFloat newRelativeY1Float = oldY1Float + translateY;
            NSString * newRelativeY1String = [macSVGDocument allocFloatString:newRelativeY1Float];

            CGFloat newRelativeX2Float = oldX2Float + translateX;
            NSString * newRelativeX2String = [macSVGDocument allocFloatString:newRelativeX2Float];
            
            CGFloat newRelativeY2Float = oldY2Float + translateY;
            NSString * newRelativeY2String = [macSVGDocument allocFloatString:newRelativeY2Float];
            
            NSString * commandString = [pathSegmentDictionary objectForKey:@"command"];
            
            unichar commandCharacter = [commandString characterAtIndex:0];
            
            NSMutableDictionary * newSegmentDictionary = [NSMutableDictionary dictionary];

            [newSegmentDictionary setObject:commandString forKey:@"command"];
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;
                }

                case 'm':     // moveto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    break;
                }
                case 'L':     // lineto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;
                }
                
                case 'l':     // lineto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    break;
                }

                case 'H':     // horizontal lineto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    break;
                }

                case 'h':     // horizontal lineto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    break;
                }

                case 'V':     // vertical lineto
                {
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;
                }
                
                case 'v':     // vertical lineto
                {
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    break;
                }

                case 'C':     // absolute curveto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    [newSegmentDictionary setObject:newAbsoluteX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:newAbsoluteY1String forKey:@"y1"];
                    [newSegmentDictionary setObject:newAbsoluteX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:newAbsoluteY2String forKey:@"y2"];
                    break;
                }

                case 'c':     // relative curveto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    [newSegmentDictionary setObject:newRelativeX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:newRelativeY1String forKey:@"y1"];
                    [newSegmentDictionary setObject:newRelativeX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:newRelativeY2String forKey:@"y2"];
                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    [newSegmentDictionary setObject:newAbsoluteX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:newAbsoluteY2String forKey:@"y2"];
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    [newSegmentDictionary setObject:newRelativeX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:newRelativeY2String forKey:@"y2"];
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    [newSegmentDictionary setObject:newAbsoluteX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:newAbsoluteY1String forKey:@"y1"];
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    [newSegmentDictionary setObject:newRelativeX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:newRelativeY1String forKey:@"y1"];
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    break;
                }

                case 'A':     // elliptical arc
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    
                    NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                    NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                    NSString * xAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                    NSString * largeArcFlagString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                    NSString * sweepFlagString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
                    
                    CGFloat rxFloat = [rxString floatValue] + translateX;
                    CGFloat ryFloat = [ryString floatValue] + translateY;
                    rxString = [macSVGDocument allocFloatString:rxFloat];
                    ryString = [macSVGDocument allocFloatString:ryFloat];
                    
                    [newSegmentDictionary setObject:rxString forKey:@"rx"];
                    [newSegmentDictionary setObject:ryString forKey:@"ry"];
                    [newSegmentDictionary setObject:xAxisRotationString forKey:@"x-axis-rotation"];
                    [newSegmentDictionary setObject:largeArcFlagString forKey:@"large-arc-flag"];
                    [newSegmentDictionary setObject:sweepFlagString forKey:@"sweep-flag"];

                    break;
                }
                case 'a':     // elliptical arc
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    
                    NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                    NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                    NSString * xAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                    NSString * largeArcFlagString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                    NSString * sweepFlagString = [pathSegmentDictionary objectForKey:@"sweep-flag"];

                    CGFloat rxFloat = [rxString floatValue] + translateX;
                    CGFloat ryFloat = [ryString floatValue] + translateY;
                    rxString = [macSVGDocument allocFloatString:rxFloat];
                    ryString = [macSVGDocument allocFloatString:ryFloat];
                    
                    [newSegmentDictionary setObject:rxString forKey:@"rx"];
                    [newSegmentDictionary setObject:ryString forKey:@"ry"];
                    [newSegmentDictionary setObject:xAxisRotationString forKey:@"x-axis-rotation"];
                    [newSegmentDictionary setObject:largeArcFlagString forKey:@"large-arc-flag"];
                    [newSegmentDictionary setObject:sweepFlagString forKey:@"sweep-flag"];

                    break;
                }

                case 'Z':     // closepath
                case 'z':     // closepath
                    break;
            }
            
            [newSegmentsArray addObject:newSegmentDictionary];
            
            currentIndex++;
        }
        
        [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:newSegmentsArray];
    }
    
    return newSegmentsArray;
}

//==================================================================================
//	scalePathCoordinatesWithPathSegmentsArray:scaleX:scaleY:
//==================================================================================

- (NSMutableArray *)scalePathCoordinatesWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY
{
    MacSVGDocument * macSVGDocument = [self.macSVGDocumentWindowController document];

    NSMutableArray * newSegmentsArray = [NSMutableArray array];

    if ([pathSegmentsArray count] > 0)
    {
        NSPoint pathOriginPoint = [self.macSVGDocumentWindowController.svgWebKitController
                endPointForSegmentIndex:0 pathSegmentsArray:pathSegmentsArray];
        
        NSInteger currentIndex = 0;
        
        for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
        {
            CGFloat oldAbsoluteXFloat = [self floatForAttribute:@"absoluteX" pathSegment:pathSegmentDictionary];
            CGFloat oldAbsoluteYFloat = [self floatForAttribute:@"absoluteY" pathSegment:pathSegmentDictionary];
            CGFloat oldXFloat = [self floatForAttribute:@"x" pathSegment:pathSegmentDictionary];
            CGFloat oldYFloat = [self floatForAttribute:@"y" pathSegment:pathSegmentDictionary];

            CGFloat oldAbsoluteX1Float = [self floatForAttribute:@"absoluteX1" pathSegment:pathSegmentDictionary];
            CGFloat oldAbsoluteY1Float = [self floatForAttribute:@"absoluteY1" pathSegment:pathSegmentDictionary];
            CGFloat oldX1Float = [self floatForAttribute:@"x1" pathSegment:pathSegmentDictionary];
            CGFloat oldY1Float = [self floatForAttribute:@"y1" pathSegment:pathSegmentDictionary];

            CGFloat oldAbsoluteX2Float = [self floatForAttribute:@"absoluteX2" pathSegment:pathSegmentDictionary];
            CGFloat oldAbsoluteY2Float = [self floatForAttribute:@"absoluteY2" pathSegment:pathSegmentDictionary];
            CGFloat oldX2Float = [self floatForAttribute:@"x2" pathSegment:pathSegmentDictionary];
            CGFloat oldY2Float = [self floatForAttribute:@"y2" pathSegment:pathSegmentDictionary];

            CGFloat newAbsoluteXFloat = ((oldAbsoluteXFloat - pathOriginPoint.x) * scaleX) + pathOriginPoint.x;
            NSString * newAbsoluteXString = [macSVGDocument allocFloatString:newAbsoluteXFloat];
            
            CGFloat newAbsoluteYFloat = ((oldAbsoluteYFloat - pathOriginPoint.y) * scaleY) + pathOriginPoint.y;
            NSString * newAbsoluteYString = [macSVGDocument allocFloatString:newAbsoluteYFloat];

            CGFloat newAbsoluteX1Float = ((oldAbsoluteX1Float - pathOriginPoint.x) * scaleX) + pathOriginPoint.x;
            NSString * newAbsoluteX1String = [macSVGDocument allocFloatString:newAbsoluteX1Float];

            CGFloat newAbsoluteY1Float = ((oldAbsoluteY1Float - pathOriginPoint.y) * scaleY) + pathOriginPoint.y;
            NSString * newAbsoluteY1String = [macSVGDocument allocFloatString:newAbsoluteY1Float];

            CGFloat newAbsoluteX2Float = ((oldAbsoluteX2Float - pathOriginPoint.x) * scaleX) + pathOriginPoint.x;
            NSString * newAbsoluteX2String = [macSVGDocument allocFloatString:newAbsoluteX2Float];

            CGFloat newAbsoluteY2Float = ((oldAbsoluteY2Float - pathOriginPoint.y) * scaleY) + pathOriginPoint.y;
            NSString * newAbsoluteY2String = [macSVGDocument allocFloatString:newAbsoluteY2Float];

            CGFloat newRelativeXFloat = oldXFloat * scaleX;
            NSString * newRelativeXString = [macSVGDocument allocFloatString:newRelativeXFloat];

            CGFloat newRelativeYFloat = oldYFloat * scaleY;
            NSString * newRelativeYString = [macSVGDocument allocFloatString:newRelativeYFloat];

            CGFloat newRelativeX1Float = oldX1Float * scaleX;
            NSString * newRelativeX1String = [macSVGDocument allocFloatString:newRelativeX1Float];

            CGFloat newRelativeY1Float = oldY1Float * scaleY;
            NSString * newRelativeY1String = [macSVGDocument allocFloatString:newRelativeY1Float];

            CGFloat newRelativeX2Float = oldX2Float * scaleX;
            NSString * newRelativeX2String = [macSVGDocument allocFloatString:newRelativeX2Float];
            
            CGFloat newRelativeY2Float = oldY2Float * scaleY;
            NSString * newRelativeY2String = [macSVGDocument allocFloatString:newRelativeY2Float];
            
            NSString * commandString = [pathSegmentDictionary objectForKey:@"command"];
            
            unichar commandCharacter = [commandString characterAtIndex:0];
            
            NSMutableDictionary * newSegmentDictionary = [NSMutableDictionary dictionary];

            [newSegmentDictionary setObject:commandString forKey:@"command"];
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;
                }

                case 'm':     // moveto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    break;
                }
                case 'L':     // lineto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;
                }
                
                case 'l':     // lineto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    break;
                }

                case 'H':     // horizontal lineto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    break;
                }

                case 'h':     // horizontal lineto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    break;
                }

                case 'V':     // vertical lineto
                {
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;
                }
                
                case 'v':     // vertical lineto
                {
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    break;
                }

                case 'C':     // absolute curveto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    [newSegmentDictionary setObject:newAbsoluteX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:newAbsoluteY1String forKey:@"y1"];
                    [newSegmentDictionary setObject:newAbsoluteX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:newAbsoluteY2String forKey:@"y2"];
                    break;
                }

                case 'c':     // relative curveto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    [newSegmentDictionary setObject:newRelativeX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:newRelativeY1String forKey:@"y1"];
                    [newSegmentDictionary setObject:newRelativeX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:newRelativeY2String forKey:@"y2"];
                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    [newSegmentDictionary setObject:newAbsoluteX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:newAbsoluteY2String forKey:@"y2"];
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    [newSegmentDictionary setObject:newRelativeX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:newRelativeY2String forKey:@"y2"];
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    [newSegmentDictionary setObject:newAbsoluteX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:newAbsoluteY1String forKey:@"y1"];
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    [newSegmentDictionary setObject:newRelativeX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:newRelativeY1String forKey:@"y1"];
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    break;
                }

                case 'A':     // elliptical arc
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    
                    NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                    NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                    NSString * xAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                    NSString * largeArcFlagString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                    NSString * sweepFlagString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
                    
                    CGFloat rxFloat = [rxString floatValue] * scaleX;
                    CGFloat ryFloat = [ryString floatValue] * scaleY;
                    rxString = [macSVGDocument allocFloatString:rxFloat];
                    ryString = [macSVGDocument allocFloatString:ryFloat];
                    
                    [newSegmentDictionary setObject:rxString forKey:@"rx"];
                    [newSegmentDictionary setObject:ryString forKey:@"ry"];
                    [newSegmentDictionary setObject:xAxisRotationString forKey:@"x-axis-rotation"];
                    [newSegmentDictionary setObject:largeArcFlagString forKey:@"large-arc-flag"];
                    [newSegmentDictionary setObject:sweepFlagString forKey:@"sweep-flag"];

                    break;
                }
                case 'a':     // elliptical arc
                {
                    [newSegmentDictionary setObject:newRelativeXString forKey:@"x"];
                    [newSegmentDictionary setObject:newRelativeYString forKey:@"y"];
                    
                    NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                    NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                    NSString * xAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                    NSString * largeArcFlagString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                    NSString * sweepFlagString = [pathSegmentDictionary objectForKey:@"sweep-flag"];

                    CGFloat rxFloat = [rxString floatValue] * scaleX;
                    CGFloat ryFloat = [ryString floatValue] * scaleY;
                    rxString = [macSVGDocument allocFloatString:rxFloat];
                    ryString = [macSVGDocument allocFloatString:ryFloat];
                    
                    [newSegmentDictionary setObject:rxString forKey:@"rx"];
                    [newSegmentDictionary setObject:ryString forKey:@"ry"];
                    [newSegmentDictionary setObject:xAxisRotationString forKey:@"x-axis-rotation"];
                    [newSegmentDictionary setObject:largeArcFlagString forKey:@"large-arc-flag"];
                    [newSegmentDictionary setObject:sweepFlagString forKey:@"sweep-flag"];

                    break;
                }

                case 'Z':     // closepath
                case 'z':     // closepath
                    break;
            }
            
            [newSegmentsArray addObject:newSegmentDictionary];
            
            currentIndex++;
        }
        
        [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:newSegmentsArray];
    }
    
    return newSegmentsArray;
}

//==================================================================================
//	rotate_point()
//==================================================================================

- (CGPoint)rotatePoint:(CGPoint)aPoint centerPoint:(CGPoint)centerPoint degrees:(CGFloat)degrees
{
    double radians = degrees * (M_PI / 180.0f);

    CGFloat s = sinf(radians);
    CGFloat c = cosf(radians);

    CGPoint translatePoint = aPoint;
    translatePoint.x -= centerPoint.x;
    translatePoint.y -= centerPoint.y;
    
    CGFloat rotX = (translatePoint.x * c) - (translatePoint.y * s);
    CGFloat rotY = (translatePoint.x * s) + (translatePoint.y * c);
    
    CGPoint result = CGPointZero;
    result.x = rotX + centerPoint.x;
    result.y = rotY + centerPoint.y;
    
    return result;
}

//==================================================================================
//	rotatePathCoordinatesWithPathSegmentsArray:x:y:degree:
//==================================================================================

- (NSMutableArray *)rotatePathCoordinatesWithPathSegmentsArray:(NSMutableArray *)mixedPathSegmentsArray x:(CGFloat)rotateX y:(CGFloat)rotateY degrees:(CGFloat)degrees
{
    // this method will convert the path segments to use absolute coordinates
    // 'H' and 'V' drawing commands are replaced with 'L' command with both x and y coordinates.
    
    NSMutableArray *pathSegmentsArray = [self convertToAbsoluteCoordinatesWithPathSegmentsArray:mixedPathSegmentsArray];

    MacSVGDocument * macSVGDocument = [self.macSVGDocumentWindowController document];
    
    NSMutableArray * newSegmentsArray = [NSMutableArray array];

    if ([pathSegmentsArray count] > 0)
    {
        NSInteger currentIndex = 0;
        
        CGPoint centerPoint = CGPointMake(rotateX, rotateY);
        
        for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
        {
            CGFloat oldAbsoluteXFloat = [self floatForAttribute:@"absoluteX" pathSegment:pathSegmentDictionary];
            CGFloat oldAbsoluteYFloat = [self floatForAttribute:@"absoluteY" pathSegment:pathSegmentDictionary];

            CGFloat oldAbsoluteX1Float = [self floatForAttribute:@"absoluteX1" pathSegment:pathSegmentDictionary];
            CGFloat oldAbsoluteY1Float = [self floatForAttribute:@"absoluteY1" pathSegment:pathSegmentDictionary];

            CGFloat oldAbsoluteX2Float = [self floatForAttribute:@"absoluteX2" pathSegment:pathSegmentDictionary];
            CGFloat oldAbsoluteY2Float = [self floatForAttribute:@"absoluteY2" pathSegment:pathSegmentDictionary];

            CGPoint oldAbsoluteXYPoint = CGPointMake(oldAbsoluteXFloat, oldAbsoluteYFloat);
            CGPoint oldAbsoluteXY1Point = CGPointMake(oldAbsoluteX1Float, oldAbsoluteY1Float);
            CGPoint oldAbsoluteXY2Point = CGPointMake(oldAbsoluteX2Float, oldAbsoluteY2Float);
            
            CGPoint newAbsoluteXYPoint = [self rotatePoint:oldAbsoluteXYPoint centerPoint:centerPoint degrees:degrees];
            NSString * newAbsoluteXString = [macSVGDocument allocFloatString:newAbsoluteXYPoint.x];
            NSString * newAbsoluteYString = [macSVGDocument allocFloatString:newAbsoluteXYPoint.y];

            CGPoint newAbsoluteXY1Point = [self rotatePoint:oldAbsoluteXY1Point centerPoint:centerPoint degrees:degrees];
            NSString * newAbsoluteX1String = [macSVGDocument allocFloatString:newAbsoluteXY1Point.x];
            NSString * newAbsoluteY1String = [macSVGDocument allocFloatString:newAbsoluteXY1Point.y];

            CGPoint newAbsoluteXY2Point = [self rotatePoint:oldAbsoluteXY2Point centerPoint:centerPoint degrees:degrees];
            NSString * newAbsoluteX2String = [macSVGDocument allocFloatString:newAbsoluteXY2Point.x];
            NSString * newAbsoluteY2String = [macSVGDocument allocFloatString:newAbsoluteXY2Point.y];
            
            NSString * commandString = [pathSegmentDictionary objectForKey:@"command"];
            
            unichar commandCharacter = [commandString characterAtIndex:0];

            if (commandCharacter == 'H')
            {
                commandString = @"L";
                commandCharacter = 'L';
            }
            if (commandCharacter == 'V')
            {
                commandString = @"L";
                commandCharacter = 'L';
            }
            
            NSMutableDictionary * newSegmentDictionary = [NSMutableDictionary dictionary];

            [newSegmentDictionary setObject:commandString forKey:@"command"];
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;
                }

                case 'm':     // moveto
                {
                    break;
                }
                case 'L':     // lineto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;
                }
                
                case 'l':     // lineto
                {
                    break;
                }

                case 'H':     // horizontal lineto
                {
                    break;
                }

                case 'h':     // horizontal lineto
                {
                    break;
                }

                case 'V':     // vertical lineto
                {
                    break;
                }
                
                case 'v':     // vertical lineto
                {
                    break;
                }

                case 'C':     // absolute curveto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    [newSegmentDictionary setObject:newAbsoluteX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:newAbsoluteY1String forKey:@"y1"];
                    [newSegmentDictionary setObject:newAbsoluteX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:newAbsoluteY2String forKey:@"y2"];
                    break;
                }

                case 'c':     // relative curveto
                {
                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    [newSegmentDictionary setObject:newAbsoluteX2String forKey:@"x2"];
                    [newSegmentDictionary setObject:newAbsoluteY2String forKey:@"y2"];
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    [newSegmentDictionary setObject:newAbsoluteX1String forKey:@"x1"];
                    [newSegmentDictionary setObject:newAbsoluteY1String forKey:@"y1"];
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    break;
                }

                case 'A':     // elliptical arc
                {
                    [newSegmentDictionary setObject:newAbsoluteXString forKey:@"x"];
                    [newSegmentDictionary setObject:newAbsoluteYString forKey:@"y"];

                    NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                    NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                    NSString * xAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                    NSString * largeArcFlagString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                    NSString * sweepFlagString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
                    
                    [newSegmentDictionary setObject:rxString forKey:@"rx"];
                    [newSegmentDictionary setObject:ryString forKey:@"ry"];
                    [newSegmentDictionary setObject:xAxisRotationString forKey:@"x-axis-rotation"];
                    [newSegmentDictionary setObject:largeArcFlagString forKey:@"large-arc-flag"];
                    [newSegmentDictionary setObject:sweepFlagString forKey:@"sweep-flag"];
                    
                    break;
                }
                case 'a':     // elliptical arc
                {
                    break;
                }

                case 'Z':     // closepath
                case 'z':     // closepath
                    break;
            }
            
            [newSegmentsArray addObject:newSegmentDictionary];
            
            currentIndex++;
        }
        
        [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:newSegmentsArray];
    }
    
    return newSegmentsArray;
}


CGFloat degreesToRadians(CGFloat degree)
{
    return (degree * M_PI) / 180;
}

CGFloat radiansToDegrees(CGFloat radians)
{
    return (radians * 180) / (M_PI);
}

/**
 * Conversion from center to endpoint parameterization
 * - following: http://www.w3.org/TR/SVG/implnote.html#ArcConversionCenterToEndpoint
 * @param	a Arc
 * @return	Object containing parameters {start<Point>, end<Point>, rx<Number>, ry<Number>, rotation<Number>, isLarge<Boolean>, isClockwise<Boolean>}
 */
- (NSDictionary *) convertArcToEndPointWithRotation:(CGFloat)rotation angleStart:(CGFloat)angleStart angleExtent:(CGFloat)angleExtent
        cx:(CGFloat)cx cy:(CGFloat)cy rx:(CGFloat)rx ry:(CGFloat)ry
{
    // http://www.w3.org/TR/SVG/implnote.html#ArcConversionCenterToEndpoint
    CGFloat radRotation = degreesToRadians(rotation);
    CGFloat radStart = degreesToRadians(angleStart);
    CGFloat radExtent = degreesToRadians(angleExtent);
    CGFloat sinRotation = sinf(radRotation);
    CGFloat cosRotation = cosf(radRotation);
    
    CGPoint start = CGPointZero;
    CGFloat rxcos = rx * cosf(radStart);
    CGFloat rysin = ry * sinf(radStart);
    start.x = (cosRotation * rxcos) + (-sinRotation * rxcos) + cx;
    start.y = (sinRotation * rysin) + (cosRotation * rysin) + cy;
    
    CGPoint end = CGPointZero;
    rxcos = rx * cosf(radStart + radExtent);
    rysin = ry * sinf(radStart + radExtent);
    end.x = (cosRotation * rxcos) + (-sinRotation * rxcos) + cx;
    end.y = (sinRotation * rysin) + (cosRotation * rysin) + cy;
    
    BOOL isLarge = (fabs(angleExtent) > 180);
    BOOL isCounterClockwise = (angleExtent > 0);
    
    //return { start:start, end:end, rx:a._rx, ry:a._ry, rotation:a._rotation, isLarge:isLarge, isCounterClockwise:isCounterClockwise };
    
    NSNumber * startXNumber = [NSNumber numberWithFloat:start.x];
    NSNumber * startYNumber = [NSNumber numberWithFloat:start.y];
    NSNumber * endXNumber = [NSNumber numberWithFloat:end.x];
    NSNumber * endYNumber = [NSNumber numberWithFloat:end.y];
    NSNumber * isLargeNumber = [NSNumber numberWithBool:isLarge];
    NSNumber * isCounterClockwiseNumber = [NSNumber numberWithBool:isCounterClockwise];
    
    NSDictionary * resultDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
            startXNumber, @"startX",
            startYNumber, @"startY",
            endXNumber, @"endX",
            endYNumber, @"endY",
            isLargeNumber, @"isLarge",
            isCounterClockwiseNumber, @"isCounterClockwise",
            NULL];
    
    return resultDictionary;
}


/**
    * Create a new SVG Elliptical Arc object
    * - Conversion from endpoint to center parameterization following: http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes
    * @param	start	Start Point
    * @param	end	End Point
    * @param	rx	X radii of the ellipse
    * @param	ry	Y radii of the ellipse
    * @param	rotation Rotation angle of the ellipse (in degrees)
    * @param	isLarge	Define if is a large arc (large-arc-flag)
    * @param	isCounterClockwise	Define if arc should be draw clockwise (sweep-flag)
    */
- (NSDictionary *) convertArcToCenterPointWithStart:(CGPoint)start end:(CGPoint)end rx:(CGFloat)rx ry:(CGFloat)ry
        rotation:(CGFloat)rotation isLarge:(BOOL)isLarge isCounterClockwise:(BOOL)isCounterClockwise
{
    // adapted from https://github.com/millermedeiros/SVGParser/blob/master/com/millermedeiros/geom/SVGArc.as
    // http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes

    //midpoint
    CGFloat midX = (start.x - end.x) / 2;
    CGFloat midY = (start.y - end.y) / 2;

    //rotation
    CGFloat radRotation = degreesToRadians(rotation);
    CGFloat sinRotation = sinf(radRotation);
    CGFloat cosRotation = cosf(radRotation);

    //(x1', y1')
    CGFloat x1 = cosRotation * midX + sinRotation * midY;
    CGFloat y1 = -sinRotation * midX + cosRotation * midY;

    // Correction of out-of-range radii
    if (rx == 0 || ry == 0)
    {
        // throw new Error("rx and rx can't be equal to zero !!"); // Ensure radii are non-zero
        return NULL;
    }

    CGFloat abs_rx = fabs(rx);
    CGFloat abs_ry = fabs(ry);
    
    CGFloat x1_2 = x1 * x1;
    CGFloat y1_2 = y1 * y1;
    CGFloat rx_2 = abs_rx * abs_rx;
    CGFloat ry_2 = abs_ry * abs_ry;
    
    CGFloat radiiFix = (x1_2 / rx_2) + (y1_2 / ry_2);
    
    if(radiiFix > 1)
    {
        abs_rx = sqrt(radiiFix) * abs_rx;
        abs_ry = sqrt(radiiFix) * abs_ry;
        rx_2 = abs_rx * abs_rx;
        ry_2 = abs_ry * abs_ry;
    }

    //(cx', cy')
    CGFloat cf = ((rx_2 * ry_2) - (rx_2 * y1_2) - (ry_2 * x1_2)) / ((rx_2 * y1_2) + (ry_2 * x1_2));
    cf = (cf > 0)? cf : 0;
    CGFloat sqr = sqrt(cf);
    sqr *= (isLarge != isCounterClockwise)? 1 : -1;
    CGFloat cx1 = sqr * ((abs_rx * y1) / abs_ry);
    CGFloat cy1 = sqr * -((abs_ry * x1) / abs_rx);

    //(cx, cy) from (cx', cy')
    CGFloat cx = (cosRotation * cx1 - sinRotation * cy1) + ((start.x + end.x) / 2);
    CGFloat cy = (sinRotation * cx1 + cosRotation * cy1) + ((start.y + end.y) / 2);

    // angleStart and angleExtent
    CGFloat ux = (x1 - cx1) / abs_rx;
    CGFloat uy = (y1 - cy1) / abs_ry;
    CGFloat vx = (-x1 - cx1) / abs_rx;
    CGFloat vy = (-y1 - cy1) / abs_ry;
    CGFloat uv = ux*vx + uy*vy; // u.v
    CGFloat u_norm = sqrt(ux*ux + uy*uy); // ||u||
    CGFloat uv_norm = sqrt((ux*ux + uy*uy) * (vx*vx + vy*vy)); // ||u||||v||
    
    NSInteger sign = (uy < 0)? -1 : 1; //((1,0),(vx, vy))
    
    CGFloat angleStart = radiansToDegrees( sign * acos(ux / u_norm));
    sign = ((ux * vy - uy * vx) < 0) ? -1 : 1; //((ux,uy),(vx, vy))
    CGFloat angleExtent = radiansToDegrees( sign * acos(uv / uv_norm));
    if (!isCounterClockwise && angleExtent > 0) angleExtent -= 360;
    else if (isCounterClockwise && angleExtent < 0) angleExtent += 360;
    angleStart = fmod(angleStart, 360);
    angleExtent = fmod(angleExtent, 360);
    
    NSNumber * angleStartNumber = [NSNumber numberWithFloat:angleStart];
    NSNumber * angleExtentNumber = [NSNumber numberWithFloat:angleExtent];
    NSNumber * cxNumber = [NSNumber numberWithFloat:cx];
    NSNumber * cyNumber = [NSNumber numberWithFloat:cy];

    NSDictionary * resultDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
            angleStartNumber, @"angleStart",
            angleExtentNumber, @"angleExtent",
            cxNumber, @"cx",
            cyNumber, @"cy",
            NULL];
    
    return resultDictionary;
}


// from WebKit - https://github.com/WebKit/webkit/blob/master/Source/WebCore/svg/SVGPathParser.cpp
/*

// This works by converting the SVG arc to "simple" beziers.
// Partly adapted from Niko's code in kdelibs/kdecore/svgicons.
// See also SVG implementation notes: http://www.w3.org/TR/SVG/implnote.html#ArcConversionEndpointToCenter
bool SVGPathParser::decomposeArcToCubic(float angle, float rx, float ry, FloatPoint& point1, FloatPoint& point2, bool largeArcFlag, bool sweepFlag)
{
    FloatSize midPointDistance = point1 - point2;
    midPointDistance.scale(0.5f);

    AffineTransform pointTransform;
    pointTransform.rotate(-angle);

    FloatPoint transformedMidPoint = pointTransform.mapPoint(FloatPoint(midPointDistance.width(), midPointDistance.height()));
    float squareRx = rx * rx;
    float squareRy = ry * ry;
    float squareX = transformedMidPoint.x() * transformedMidPoint.x();
    float squareY = transformedMidPoint.y() * transformedMidPoint.y();

    // Check if the radii are big enough to draw the arc, scale radii if not.
    // http://www.w3.org/TR/SVG/implnote.html#ArcCorrectionOutOfRangeRadii
    float radiiScale = squareX / squareRx + squareY / squareRy;
    if (radiiScale > 1) {
        rx *= sqrtf(radiiScale);
        ry *= sqrtf(radiiScale);
    }

    pointTransform.makeIdentity();
    pointTransform.scale(1 / rx, 1 / ry);
    pointTransform.rotate(-angle);

    point1 = pointTransform.mapPoint(point1);
    point2 = pointTransform.mapPoint(point2);
    FloatSize delta = point2 - point1;

    float d = delta.width() * delta.width() + delta.height() * delta.height();
    float scaleFactorSquared = std::max(1 / d - 0.25f, 0.f);

    float scaleFactor = sqrtf(scaleFactorSquared);
    if (sweepFlag == largeArcFlag)
        scaleFactor = -scaleFactor;

    delta.scale(scaleFactor);
    FloatPoint centerPoint = point1 + point2;
    centerPoint.scale(0.5f, 0.5f);
    centerPoint.move(-delta.height(), delta.width());

    float theta1 = FloatPoint(point1 - centerPoint).slopeAngleRadians();
    float theta2 = FloatPoint(point2 - centerPoint).slopeAngleRadians();

    float thetaArc = theta2 - theta1;
    if (thetaArc < 0 && sweepFlag)
        thetaArc += 2 * piFloat;
    else if (thetaArc > 0 && !sweepFlag)
        thetaArc -= 2 * piFloat;

    pointTransform.makeIdentity();
    pointTransform.rotate(angle);
    pointTransform.scale(rx, ry);

    // Some results of atan2 on some platform implementations are not exact enough. So that we get more
    // cubic curves than expected here. Adding 0.001f reduces the count of sgements to the correct count.
    int segments = ceilf(fabsf(thetaArc / (piOverTwoFloat + 0.001f)));
    for (int i = 0; i < segments; ++i) {
        float startTheta = theta1 + i * thetaArc / segments;
        float endTheta = theta1 + (i + 1) * thetaArc / segments;

        float t = (8 / 6.f) * tanf(0.25f * (endTheta - startTheta));
        if (!std::isfinite(t))
            return false;
        float sinStartTheta = sinf(startTheta);
        float cosStartTheta = cosf(startTheta);
        float sinEndTheta = sinf(endTheta);
        float cosEndTheta = cosf(endTheta);

        point1 = FloatPoint(cosStartTheta - t * sinStartTheta, sinStartTheta + t * cosStartTheta);
        point1.move(centerPoint.x(), centerPoint.y());
        FloatPoint targetPoint = FloatPoint(cosEndTheta, sinEndTheta);
        targetPoint.move(centerPoint.x(), centerPoint.y());
        point2 = targetPoint;
        point2.move(t * sinEndTheta, -t * cosEndTheta);

        m_consumer.curveToCubic(pointTransform.mapPoint(point1), pointTransform.mapPoint(point2),
                                 pointTransform.mapPoint(targetPoint), AbsoluteCoordinates);
    }
    return true;
}
*/


@end
