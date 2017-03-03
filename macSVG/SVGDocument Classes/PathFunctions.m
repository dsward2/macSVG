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
        NSNumber * absoluteStartXNumber = pathSegmentDictionary[@"absoluteStartX"];
        NSNumber * absoluteStartYNumber = pathSegmentDictionary[@"absoluteStartY"];
        NSNumber * absoluteXNumber = pathSegmentDictionary[@"absoluteX"];
        NSNumber * absoluteYNumber = pathSegmentDictionary[@"absoluteY"];
        
        CGFloat absoluteStartXFloat = absoluteStartXNumber.floatValue;
        CGFloat absoluteStartYFloat = absoluteStartYNumber.floatValue;
        CGFloat absoluteXFloat = absoluteXNumber.floatValue;
        CGFloat absoluteYFloat = absoluteYNumber.floatValue;

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

        NSString * commandString = pathSegmentDictionary[@"command"];
        
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
                    NSNumber * x1Number = pathSegmentDictionary[@"absoluteX1"];
                    CGFloat x1Float = x1Number.floatValue;

                    NSNumber * y1Number = pathSegmentDictionary[@"absoluteY1"];
                    CGFloat y1Float = y1Number.floatValue;

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

                    NSNumber * x2Number = pathSegmentDictionary[@"absoluteX2"];
                    CGFloat x2Float = x2Number.floatValue;

                    NSNumber * y2Number = pathSegmentDictionary[@"absoluteY2"];
                    CGFloat y2Float = y2Number.floatValue;

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
                    NSNumber * x2Number = pathSegmentDictionary[@"absoluteX2"];
                    CGFloat x2Float = x2Number.floatValue;

                    NSNumber * y2Number = pathSegmentDictionary[@"absoluteY2"];
                    CGFloat y2Float = y2Number.floatValue;

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
                    NSNumber * x1Number = pathSegmentDictionary[@"absoluteX1"];
                    CGFloat x1Float = x1Number.floatValue;

                    NSNumber * y1Number = pathSegmentDictionary[@"absoluteY1"];
                    CGFloat y1Float = y1Number.floatValue;

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
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [self.macSVGDocumentWindowController.svgWebKitController
            buildPathSegmentsArrayWithPathString:pathAttributeString];

    return [self convertToAbsoluteCoordinatesWithPathSegmentsArray:pathSegmentsArray];
}

//==================================================================================
//	convertToAbsoluteCoordinates
//==================================================================================

- (NSMutableArray *)convertToAbsoluteCoordinatesWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;

    for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
    {
        NSNumber * absoluteStartXNumber = pathSegmentDictionary[@"absoluteStartX"];
        NSNumber * absoluteStartYNumber = pathSegmentDictionary[@"absoluteStartY"];
        
        CGFloat absoluteStartXFloat = absoluteStartXNumber.floatValue;
        CGFloat absoluteStartYFloat = absoluteStartYNumber.floatValue;

        NSString * commandString = pathSegmentDictionary[@"command"];
        
        unichar commandCharacter = [commandString characterAtIndex:0];

        switch (commandCharacter)
        {
            case 'M':     // moveto
                break;    // no changes required

            case 'm':     // moveto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                pathSegmentDictionary[@"command"] = @"M";
                break;
            }
            case 'L':     // lineto
            {
                break;    // no changes required
            }
            
            case 'l':     // lineto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                pathSegmentDictionary[@"command"] = @"L";
                break;
            }

            case 'H':     // horizontal lineto
                break;    // no changes required

            case 'h':     // horizontal lineto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                pathSegmentDictionary[@"command"] = @"H";
                break;
            }

            case 'V':     // vertical lineto
                break;    // no changes required

            case 'v':     // vertical lineto
            {
                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                pathSegmentDictionary[@"command"] = @"V";
                break;
            }

            case 'C':     // curveto
                break;    // no changes required

            case 'c':     // curveto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSString * x1String = pathSegmentDictionary[@"x1"];
                CGFloat x1Float = x1String.floatValue;
                x1Float += absoluteStartXFloat;
                NSString * newX1String = [macSVGDocument allocFloatString:x1Float];
                pathSegmentDictionary[@"x1"] = newX1String;

                NSString * y1String = pathSegmentDictionary[@"y1"];
                CGFloat y1Float = y1String.floatValue;
                y1Float += absoluteStartYFloat;
                NSString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegmentDictionary[@"y1"] = newY1String;

                NSString * x2String = pathSegmentDictionary[@"x2"];
                CGFloat x2Float = x2String.floatValue;
                x2Float += absoluteStartXFloat;
                NSString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSString * y2String = pathSegmentDictionary[@"y2"];
                CGFloat y2Float = y2String.floatValue;
                y2Float += absoluteStartYFloat;
                NSString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegmentDictionary[@"y2"] = newY2String;
                
                pathSegmentDictionary[@"command"] = @"C";
                break;
            }

            case 'S':     // smooth curveto
                break;    // no changes required

            case 's':     // smooth curveto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSString * x2String = pathSegmentDictionary[@"x2"];
                CGFloat x2Float = x2String.floatValue;
                x2Float += absoluteStartXFloat;
                NSString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSString * y2String = pathSegmentDictionary[@"y2"];
                CGFloat y2Float = y2String.floatValue;
                y2Float += absoluteStartYFloat;
                NSString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegmentDictionary[@"y2"] = newY2String;
                
                pathSegmentDictionary[@"command"] = @"S";
                break;
            }

            case 'Q':     // quadratic Bezier curve
                break;    // no changes required

            case 'q':     // quadratic Bezier curve
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSString * x1String = pathSegmentDictionary[@"x1"];
                CGFloat x1Float = x1String.floatValue;
                x1Float += absoluteStartXFloat;
                NSString * newX1String = [macSVGDocument allocFloatString:x1Float];
                pathSegmentDictionary[@"x1"] = newX1String;

                NSString * y1String = pathSegmentDictionary[@"y1"];
                CGFloat y1Float = y1String.floatValue;
                y1Float += absoluteStartYFloat;
                NSString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegmentDictionary[@"y1"] = newY1String;

                pathSegmentDictionary[@"command"] = @"Q";
                break;
            }

            case 'T':     // smooth quadratic Bezier curve
                break;    // no changes required

            case 't':     // smooth quadratic Bezier curve
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                pathSegmentDictionary[@"command"] = @"T";
                break;
            }

            case 'A':     // elliptical arc
                break;    // no changes required

            case 'a':     // elliptical arc
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                pathSegmentDictionary[@"command"] = @"A";
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
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [self.macSVGDocumentWindowController.svgWebKitController
            buildPathSegmentsArrayWithPathString:pathAttributeString];

    return [self convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray:pathSegmentsArray];
}

//==================================================================================
//	convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray
//==================================================================================

- (NSMutableArray *)convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;

    [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:pathSegmentsArray];

    unichar previousCommandCharacter = ' ';
    NSDictionary * previousSegmentDictionary = NULL;
    NSInteger pathSegmentIndex = 0;
    CGPoint controlPoint = NSZeroPoint;

    for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
    {
        NSNumber * absoluteStartXNumber = pathSegmentDictionary[@"absoluteStartX"];
        NSNumber * absoluteStartYNumber = pathSegmentDictionary[@"absoluteStartY"];
        
        NSNumber * absoluteXNumber = pathSegmentDictionary[@"absoluteX"];
        NSNumber * absoluteYNumber = pathSegmentDictionary[@"absoluteY"];
        
        //NSNumber * xNumber = [pathSegmentDictionary objectForKey:@"x"];
        //NSNumber * yNumber = [pathSegmentDictionary objectForKey:@"y"];
        
        CGFloat absoluteStartXFloat = absoluteStartXNumber.floatValue;
        CGFloat absoluteStartYFloat = absoluteStartYNumber.floatValue;
        
        CGFloat absoluteXFloat = absoluteXNumber.floatValue;
        CGFloat absoluteYFloat = absoluteYNumber.floatValue;
        
        //CGFloat xFloat = [xNumber floatValue];
        //CGFloat yFloat = [yNumber floatValue];

        if (pathSegmentIndex == 0)
        {
            controlPoint = CGPointMake(absoluteStartXFloat, absoluteStartYFloat);
        }

        NSString * commandString = pathSegmentDictionary[@"command"];
        unichar commandCharacter = [commandString characterAtIndex:0];

        switch (commandCharacter)
        {
            case 'M':     // moveto
                break;    // no changes required

            case 'm':     // moveto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                pathSegmentDictionary[@"command"] = @"M";
                break;
            }
            case 'L':     // lineto
            {
                break;    // no changes required
            }
            
            case 'l':     // lineto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                pathSegmentDictionary[@"command"] = @"L";
                break;
            }

            case 'H':     // horizontal lineto
                break;    // no changes required

            case 'h':     // horizontal lineto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                pathSegmentDictionary[@"command"] = @"H";
                break;
            }

            case 'V':     // vertical lineto
                break;    // no changes required

            case 'v':     // vertical lineto
            {
                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                pathSegmentDictionary[@"command"] = @"V";
                break;
            }

            case 'C':     // curveto
                break;    // no changes required

            case 'c':     // curveto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSString * x1String = pathSegmentDictionary[@"x1"];
                CGFloat x1Float = x1String.floatValue;
                x1Float += absoluteStartXFloat;
                NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                pathSegmentDictionary[@"x1"] = newX1String;

                NSString * y1String = pathSegmentDictionary[@"y1"];
                CGFloat y1Float = y1String.floatValue;
                y1Float += absoluteStartYFloat;
                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegmentDictionary[@"y1"] = newY1String;

                NSString * x2String = pathSegmentDictionary[@"x2"];
                CGFloat x2Float = x2String.floatValue;
                x2Float += absoluteStartXFloat;
                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSString * y2String = pathSegmentDictionary[@"y2"];
                CGFloat y2Float = y2String.floatValue;
                y2Float += absoluteStartYFloat;
                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegmentDictionary[@"y2"] = newY2String;
                
                pathSegmentDictionary[@"command"] = @"C";
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
                        NSNumber * previousAbsoluteX2Number = previousSegmentDictionary[@"absoluteX2"];
                        NSNumber * previousAbsoluteY2Number = previousSegmentDictionary[@"absoluteY2"];
                        
                        CGFloat previousAbsoluteX2Float = previousAbsoluteX2Number.floatValue;
                        CGFloat previousAbsoluteY2Float = previousAbsoluteY2Number.floatValue;
                        
                        CGFloat x1Float = absoluteStartXFloat + (absoluteStartXFloat - previousAbsoluteX2Float);
                        CGFloat y1Float = absoluteStartYFloat + (absoluteStartYFloat - previousAbsoluteY2Float);

                        NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                        pathSegmentDictionary[@"x1"] = newX1String;

                        NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                        pathSegmentDictionary[@"y1"] = newY1String;
                        
                        NSNumber * newAbsoluteX1Number = [NSNumber numberWithFloat:x1Float];
                        pathSegmentDictionary[@"absoluteX1"] = newAbsoluteX1Number;

                        NSNumber * newAbsoluteY1Number = [NSNumber numberWithFloat:y1Float];
                        pathSegmentDictionary[@"absoluteY1"] = newAbsoluteY1Number;

                        break;
                    }
                    default:
                    {
                        NSMutableString * newX1String = [macSVGDocument allocFloatString:absoluteStartXFloat];
                        pathSegmentDictionary[@"x1"] = newX1String;

                        NSMutableString * newY1String = [macSVGDocument allocFloatString:absoluteStartYFloat];
                        pathSegmentDictionary[@"y1"] = newY1String;

                        NSNumber * newAbsoluteX1Number = [NSNumber numberWithFloat:absoluteStartXFloat];
                        pathSegmentDictionary[@"absoluteX1"] = newAbsoluteX1Number;

                        NSNumber * newAbsoluteY1Number = [NSNumber numberWithFloat:absoluteStartYFloat];
                        pathSegmentDictionary[@"absoluteY1"] = newAbsoluteY1Number;
                    }
                }

                NSNumber * absoluteX2Number = pathSegmentDictionary[@"absoluteX2"];
                NSNumber * absoluteY2Number = pathSegmentDictionary[@"absoluteY2"];
                
                CGFloat absoluteX2Float = absoluteX2Number.floatValue;
                CGFloat absoluteY2Float = absoluteY2Number.floatValue;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:absoluteX2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:absoluteY2Float];
                pathSegmentDictionary[@"y2"] = newY2String;

                NSNumber * newAbsoluteX2Number = [NSNumber numberWithFloat:absoluteX2Float];
                pathSegmentDictionary[@"absoluteX1"] = newAbsoluteX2Number;

                NSNumber * newAbsoluteY2Number = [NSNumber numberWithFloat:absoluteY2Float];
                pathSegmentDictionary[@"absoluteY1"] = newAbsoluteY2Number;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                pathSegmentDictionary[@"command"] = @"C";
                
                break;
            }


            case 'Q':     // quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
            {
                CGPoint currentPoint = CGPointMake(absoluteStartXFloat, absoluteStartYFloat);
                CGPoint targetPoint = CGPointMake(absoluteXFloat, absoluteYFloat);

                NSNumber * oldAbsoluteX1Number = pathSegmentDictionary[@"absoluteX1"];    // quadratic x1,y1
                NSNumber * oldAbsoluteY1Number = pathSegmentDictionary[@"absoluteY1"];
                
                CGFloat oldAbsoluteX1Float = oldAbsoluteX1Number.floatValue;
                CGFloat oldAbsoluteY1Float = oldAbsoluteY1Number.floatValue;

                controlPoint = CGPointMake(oldAbsoluteX1Float, oldAbsoluteY1Float);
                
                CGFloat x1Float = currentPoint.x - ((currentPoint.x - controlPoint.x) / 1.5f);
                CGFloat y1Float = currentPoint.y - ((currentPoint.y - controlPoint.y) / 1.5f);
                
                CGFloat x2Float = targetPoint.x - ((targetPoint.x - controlPoint.x) / 1.5f);
                CGFloat y2Float = targetPoint.y - ((targetPoint.y - controlPoint.y) / 1.5f);

                NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                pathSegmentDictionary[@"x1"] = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegmentDictionary[@"y1"] = newY1String;
                
                NSNumber * newAbsoluteX1Number = [NSNumber numberWithFloat:x1Float];
                pathSegmentDictionary[@"absoluteX1"] = newAbsoluteX1Number;

                NSNumber * newAbsoluteY1Number = [NSNumber numberWithFloat:y1Float];
                pathSegmentDictionary[@"absoluteY1"] = newAbsoluteY1Number;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegmentDictionary[@"y2"] = newY2String;
                
                NSNumber * newAbsoluteX2Number = [NSNumber numberWithFloat:x2Float];
                pathSegmentDictionary[@"absoluteX2"] = newAbsoluteX2Number;

                NSNumber * newAbsoluteY2Number = [NSNumber numberWithFloat:y2Float];
                pathSegmentDictionary[@"absoluteY2"] = newAbsoluteY2Number;

                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                pathSegmentDictionary[@"command"] = @"C";
                
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
                pathSegmentDictionary[@"x1"] = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegmentDictionary[@"y1"] = newY1String;
                
                NSNumber * newAbsoluteX1Number = [NSNumber numberWithFloat:x1Float];
                pathSegmentDictionary[@"absoluteX1"] = newAbsoluteX1Number;

                NSNumber * newAbsoluteY1Number = [NSNumber numberWithFloat:y1Float];
                pathSegmentDictionary[@"absoluteY1"] = newAbsoluteY1Number;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegmentDictionary[@"y2"] = newY2String;
                
                NSNumber * newAbsoluteX2Number = [NSNumber numberWithFloat:x2Float];
                pathSegmentDictionary[@"absoluteX2"] = newAbsoluteX2Number;

                NSNumber * newAbsoluteY2Number = [NSNumber numberWithFloat:y2Float];
                pathSegmentDictionary[@"absoluteY2"] = newAbsoluteY2Number;

                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                pathSegmentDictionary[@"command"] = @"C";
                
                break;
            }

            case 'A':     // elliptical arc
                break;    // no changes required

            case 'a':     // elliptical arc
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                pathSegmentDictionary[@"command"] = @"A";
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
//	convertPathToAbsoluteCubicBezier
//==================================================================================

- (NSMutableArray *)convertPathToAbsoluteCubicBezier:(NSXMLElement *)pathElement
{
    NSXMLNode * pathAttributeNode = [pathElement attributeForName:@"d"];
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [self.macSVGDocumentWindowController.svgWebKitController
            buildPathSegmentsArrayWithPathString:pathAttributeString];

    return [self convertPathToAbsoluteCubicBezierWithPathSegmentsArray:pathSegmentsArray];
}

//==================================================================================
//	convertPathToAbsoluteCubicBezierWithPathSegmentsArray
//==================================================================================

- (NSMutableArray *)convertPathToAbsoluteCubicBezierWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;

    [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:pathSegmentsArray];

    unichar previousCommandCharacter = ' ';
    NSDictionary * previousSegmentDictionary = NULL;
    NSInteger pathSegmentIndex = 0;
    CGPoint controlPoint = NSZeroPoint;

    for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
    {
        NSNumber * absoluteStartXNumber = pathSegmentDictionary[@"absoluteStartX"];
        NSNumber * absoluteStartYNumber = pathSegmentDictionary[@"absoluteStartY"];
        
        NSNumber * absoluteXNumber = pathSegmentDictionary[@"absoluteX"];
        NSNumber * absoluteYNumber = pathSegmentDictionary[@"absoluteY"];
        
        //NSNumber * xNumber = [pathSegmentDictionary objectForKey:@"x"];
        //NSNumber * yNumber = [pathSegmentDictionary objectForKey:@"y"];
        
        CGFloat absoluteStartXFloat = absoluteStartXNumber.floatValue;
        CGFloat absoluteStartYFloat = absoluteStartYNumber.floatValue;
        
        CGFloat absoluteXFloat = absoluteXNumber.floatValue;
        CGFloat absoluteYFloat = absoluteYNumber.floatValue;
        
        //CGFloat xFloat = [xNumber floatValue];
        //CGFloat yFloat = [yNumber floatValue];

        if (pathSegmentIndex == 0)
        {
            controlPoint = CGPointMake(absoluteStartXFloat, absoluteStartYFloat);
        }

        NSString * commandString = pathSegmentDictionary[@"command"];
        unichar commandCharacter = [commandString characterAtIndex:0];

        switch (commandCharacter)
        {
            case 'M':     // moveto
                break;    // no changes required

            case 'm':     // moveto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                pathSegmentDictionary[@"command"] = @"M";
                break;
            }
            case 'L':     // lineto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                NSString * yString = pathSegmentDictionary[@"y"];

                pathSegmentDictionary[@"x1"] = xString;
                pathSegmentDictionary[@"y1"] = yString;
                pathSegmentDictionary[@"x2"] = xString;
                pathSegmentDictionary[@"y2"] = yString;
                
                pathSegmentDictionary[@"command"] = @"C";

                break;
            }
            
            case 'l':     // lineto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                pathSegmentDictionary[@"x1"] = newXString;
                pathSegmentDictionary[@"y1"] = newYString;
                pathSegmentDictionary[@"x2"] = newXString;
                pathSegmentDictionary[@"y2"] = newYString;
                
                pathSegmentDictionary[@"command"] = @"C";
                break;
            }

            case 'H':     // horizontal lineto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                NSString * yString = [macSVGDocument allocFloatString:absoluteStartYFloat];

                pathSegmentDictionary[@"x1"] = xString;
                pathSegmentDictionary[@"y1"] = yString;
                pathSegmentDictionary[@"x2"] = xString;
                pathSegmentDictionary[@"y2"] = yString;

                pathSegmentDictionary[@"command"] = @"C";

                break;
            }

            case 'h':     // horizontal lineto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = [macSVGDocument allocFloatString:absoluteStartYFloat];

                pathSegmentDictionary[@"x1"] = xString;
                pathSegmentDictionary[@"y1"] = yString;
                pathSegmentDictionary[@"x2"] = xString;
                pathSegmentDictionary[@"y2"] = yString;

                pathSegmentDictionary[@"command"] = @"C";
                break;
            }

            case 'V':     // vertical lineto
            {
                NSString * xString = [macSVGDocument allocFloatString:absoluteStartXFloat];
                NSString * yString = pathSegmentDictionary[@"y"];

                pathSegmentDictionary[@"x1"] = xString;
                pathSegmentDictionary[@"y1"] = yString;
                pathSegmentDictionary[@"x2"] = xString;
                pathSegmentDictionary[@"y2"] = yString;

                pathSegmentDictionary[@"command"] = @"C";

                break;
            }

            case 'v':     // vertical lineto
            {
                NSString * xString = [macSVGDocument allocFloatString:absoluteStartXFloat];

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                pathSegmentDictionary[@"x1"] = xString;
                pathSegmentDictionary[@"y1"] = yString;
                pathSegmentDictionary[@"x2"] = xString;
                pathSegmentDictionary[@"y2"] = yString;

                pathSegmentDictionary[@"command"] = @"C";

                break;
            }

            case 'C':     // curveto
                break;    // no changes required

            case 'c':     // curveto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSString * x1String = pathSegmentDictionary[@"x1"];
                CGFloat x1Float = x1String.floatValue;
                x1Float += absoluteStartXFloat;
                NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                pathSegmentDictionary[@"x1"] = newX1String;

                NSString * y1String = pathSegmentDictionary[@"y1"];
                CGFloat y1Float = y1String.floatValue;
                y1Float += absoluteStartYFloat;
                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegmentDictionary[@"y1"] = newY1String;

                NSString * x2String = pathSegmentDictionary[@"x2"];
                CGFloat x2Float = x2String.floatValue;
                x2Float += absoluteStartXFloat;
                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSString * y2String = pathSegmentDictionary[@"y2"];
                CGFloat y2Float = y2String.floatValue;
                y2Float += absoluteStartYFloat;
                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegmentDictionary[@"y2"] = newY2String;
                
                pathSegmentDictionary[@"command"] = @"C";
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
                        NSNumber * previousAbsoluteX2Number = previousSegmentDictionary[@"absoluteX2"];
                        NSNumber * previousAbsoluteY2Number = previousSegmentDictionary[@"absoluteY2"];
                        
                        CGFloat previousAbsoluteX2Float = previousAbsoluteX2Number.floatValue;
                        CGFloat previousAbsoluteY2Float = previousAbsoluteY2Number.floatValue;
                        
                        CGFloat x1Float = absoluteStartXFloat + (absoluteStartXFloat - previousAbsoluteX2Float);
                        CGFloat y1Float = absoluteStartYFloat + (absoluteStartYFloat - previousAbsoluteY2Float);

                        NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                        pathSegmentDictionary[@"x1"] = newX1String;

                        NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                        pathSegmentDictionary[@"y1"] = newY1String;
                        
                        NSNumber * newAbsoluteX1Number = [NSNumber numberWithFloat:x1Float];
                        pathSegmentDictionary[@"absoluteX1"] = newAbsoluteX1Number;

                        NSNumber * newAbsoluteY1Number = [NSNumber numberWithFloat:y1Float];
                        pathSegmentDictionary[@"absoluteY1"] = newAbsoluteY1Number;

                        break;
                    }
                    default:
                    {
                        NSMutableString * newX1String = [macSVGDocument allocFloatString:absoluteStartXFloat];
                        pathSegmentDictionary[@"x1"] = newX1String;

                        NSMutableString * newY1String = [macSVGDocument allocFloatString:absoluteStartYFloat];
                        pathSegmentDictionary[@"y1"] = newY1String;

                        NSNumber * newAbsoluteX1Number = [NSNumber numberWithFloat:absoluteStartXFloat];
                        pathSegmentDictionary[@"absoluteX1"] = newAbsoluteX1Number;

                        NSNumber * newAbsoluteY1Number = [NSNumber numberWithFloat:absoluteStartYFloat];
                        pathSegmentDictionary[@"absoluteY1"] = newAbsoluteY1Number;
                    }
                }

                NSNumber * absoluteX2Number = pathSegmentDictionary[@"absoluteX2"];
                NSNumber * absoluteY2Number = pathSegmentDictionary[@"absoluteY2"];
                
                CGFloat absoluteX2Float = absoluteX2Number.floatValue;
                CGFloat absoluteY2Float = absoluteY2Number.floatValue;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:absoluteX2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:absoluteY2Float];
                pathSegmentDictionary[@"y2"] = newY2String;

                NSNumber * newAbsoluteX2Number = [NSNumber numberWithFloat:absoluteX2Float];
                pathSegmentDictionary[@"absoluteX1"] = newAbsoluteX2Number;

                NSNumber * newAbsoluteY2Number = [NSNumber numberWithFloat:absoluteY2Float];
                pathSegmentDictionary[@"absoluteY1"] = newAbsoluteY2Number;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                pathSegmentDictionary[@"command"] = @"C";
                
                break;
            }


            case 'Q':     // quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
            {
                CGPoint currentPoint = CGPointMake(absoluteStartXFloat, absoluteStartYFloat);
                CGPoint targetPoint = CGPointMake(absoluteXFloat, absoluteYFloat);

                NSNumber * oldAbsoluteX1Number = pathSegmentDictionary[@"absoluteX1"];    // quadratic x1,y1
                NSNumber * oldAbsoluteY1Number = pathSegmentDictionary[@"absoluteY1"];
                
                CGFloat oldAbsoluteX1Float = oldAbsoluteX1Number.floatValue;
                CGFloat oldAbsoluteY1Float = oldAbsoluteY1Number.floatValue;

                controlPoint = CGPointMake(oldAbsoluteX1Float, oldAbsoluteY1Float);
                
                CGFloat x1Float = currentPoint.x - ((currentPoint.x - controlPoint.x) / 1.5f);
                CGFloat y1Float = currentPoint.y - ((currentPoint.y - controlPoint.y) / 1.5f);
                
                CGFloat x2Float = targetPoint.x - ((targetPoint.x - controlPoint.x) / 1.5f);
                CGFloat y2Float = targetPoint.y - ((targetPoint.y - controlPoint.y) / 1.5f);

                NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                pathSegmentDictionary[@"x1"] = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegmentDictionary[@"y1"] = newY1String;
                
                NSNumber * newAbsoluteX1Number = [NSNumber numberWithFloat:x1Float];
                pathSegmentDictionary[@"absoluteX1"] = newAbsoluteX1Number;

                NSNumber * newAbsoluteY1Number = [NSNumber numberWithFloat:y1Float];
                pathSegmentDictionary[@"absoluteY1"] = newAbsoluteY1Number;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegmentDictionary[@"y2"] = newY2String;
                
                NSNumber * newAbsoluteX2Number = [NSNumber numberWithFloat:x2Float];
                pathSegmentDictionary[@"absoluteX2"] = newAbsoluteX2Number;

                NSNumber * newAbsoluteY2Number = [NSNumber numberWithFloat:y2Float];
                pathSegmentDictionary[@"absoluteY2"] = newAbsoluteY2Number;

                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                pathSegmentDictionary[@"command"] = @"C";
                
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
                pathSegmentDictionary[@"x1"] = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegmentDictionary[@"y1"] = newY1String;
                
                NSNumber * newAbsoluteX1Number = [NSNumber numberWithFloat:x1Float];
                pathSegmentDictionary[@"absoluteX1"] = newAbsoluteX1Number;

                NSNumber * newAbsoluteY1Number = [NSNumber numberWithFloat:y1Float];
                pathSegmentDictionary[@"absoluteY1"] = newAbsoluteY1Number;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegmentDictionary[@"y2"] = newY2String;
                
                NSNumber * newAbsoluteX2Number = [NSNumber numberWithFloat:x2Float];
                pathSegmentDictionary[@"absoluteX2"] = newAbsoluteX2Number;

                NSNumber * newAbsoluteY2Number = [NSNumber numberWithFloat:y2Float];
                pathSegmentDictionary[@"absoluteY2"] = newAbsoluteY2Number;

                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                pathSegmentDictionary[@"command"] = @"C";
                
                break;
            }

            case 'A':     // elliptical arc
                // TODO: convert elliptical arc to cubic bezier?
                break;    // no changes required

            case 'a':     // elliptical arc
            {
                // TODO: convert elliptical arc to cubic bezier?
                NSString * xString = pathSegmentDictionary[@"x"];
                CGFloat xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * yString = pathSegmentDictionary[@"y"];
                CGFloat yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                pathSegmentDictionary[@"command"] = @"A";
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
    
        NSArray * allKeys = pathSegmentDictionary.allKeys;
        
        for (NSString * aKey in allKeys)
        {
            id aValue = pathSegmentDictionary[aKey];
            
            NSString * newKey = [aKey copy];
            id newValue = [aValue copy];
            
            newDictionary[newKey] = newValue;
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
    
    NSArray * originalKeys = pathSegmentDictionary.allKeys;
    
    for (NSString * aKey in originalKeys)
    {
        id originalObject = pathSegmentDictionary[aKey];
        
        if ([originalObject isKindOfClass:[NSString class]] == YES)
        {
            NSString * aString = originalObject;
            NSMutableString * newString = [NSMutableString stringWithString:aString];
            newSegmentDictionary[aKey] = newString;
        }
        else if ([originalObject isKindOfClass:[NSNumber class]] == YES)
        {
            NSNumber * aNumber = originalObject;
            NSNumber * newNumber = @(aNumber.floatValue);
            newSegmentDictionary[aKey] = newNumber;
        }
    }
    
    return newSegmentDictionary;
}

//==================================================================================
//	reversePathWithPathSegmentsArray:
//==================================================================================

- (NSMutableArray *)reversePathWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
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
    
        NSNumber * absoluteStartXNumber = reversePathSegmentDictionary[@"absoluteStartX"];    // reversed, this will be the new endpoint
        NSNumber * absoluteStartYNumber = reversePathSegmentDictionary[@"absoluteStartY"];
        NSNumber * absoluteXNumber = reversePathSegmentDictionary[@"absoluteX"];              // reversed, this will be the new startpoint
        NSNumber * absoluteYNumber = reversePathSegmentDictionary[@"absoluteY"];
        
        CGFloat absoluteStartXFloat = absoluteStartXNumber.floatValue;
        CGFloat absoluteStartYFloat = absoluteStartYNumber.floatValue;
        CGFloat absoluteXFloat = absoluteXNumber.floatValue;
        CGFloat absoluteYFloat = absoluteYNumber.floatValue;
        
        NSString * absoluteStartXString = [macSVGDocument allocFloatString:absoluteStartXFloat];
        NSString * absoluteStartYString = [macSVGDocument allocFloatString:absoluteStartYFloat];
        NSString * absoluteXString = [macSVGDocument allocFloatString:absoluteXFloat];
        NSString * absoluteYString = [macSVGDocument allocFloatString:absoluteYFloat];
        
        NSString * xString = pathSegmentDictionary[@"x"];
        NSNumber * yString = pathSegmentDictionary[@"y"];

        CGFloat xFloat = xString.floatValue;
        CGFloat yFloat = yString.floatValue;
        
        NSString * commandString = reversePathSegmentDictionary[@"command"];
        
        pathSegmentDictionary[@"command"] = commandString;
        
        unichar commandCharacter = [commandString characterAtIndex:0];

        if (currentIndex == 0)
        {
            originalLastCommand = commandCharacter;

            NSPoint reverseOriginPoint = [self.macSVGDocumentWindowController.svgWebKitController
                    endPointForSegmentIndex:0 pathSegmentsArray:reverseSegmentsArray];
            
            NSMutableDictionary * movetoPathDictionary = [NSMutableDictionary dictionary];
            
            movetoPathDictionary[@"command"] = @"M";
            
            NSString * movetoXString = [macSVGDocument allocFloatString:reverseOriginPoint.x];
            NSString * movetoYString = [macSVGDocument allocFloatString:reverseOriginPoint.y];
            
            movetoPathDictionary[@"x"] = movetoXString;
            movetoPathDictionary[@"y"] = movetoYString;
            
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
                pathSegmentDictionary[@"command"] = commandString;

                NSString * absoluteX1String = [macSVGDocument allocFloatString:absoluteStartXFloat];
                NSString * absoluteY1String = [macSVGDocument allocFloatString:absoluteStartYFloat];
                
                if (currentIndex < reverseSegmentsArray.count)
                {
                    NSMutableDictionary * nextReversePathSegmentsDictionary =
                            reverseSegmentsArray[(currentIndex + 1)];
                    
                    NSNumber * nextAbsoluteX2Number = nextReversePathSegmentsDictionary[@"absoluteX2"];
                    NSNumber * nextAbsoluteY2Number = nextReversePathSegmentsDictionary[@"absoluteY2"];

                    if ((nextAbsoluteX2Number != NULL) && (nextAbsoluteY2Number != NULL))
                    {
                        CGFloat nextAbsoluteX2Float = nextAbsoluteX2Number.floatValue;
                        CGFloat nextAbsoluteY2Float = nextAbsoluteY2Number.floatValue;
                    
                        CGFloat absoluteX1 = absoluteStartXFloat + (absoluteStartXFloat - nextAbsoluteX2Float);
                        CGFloat absoluteY1 = absoluteStartYFloat + (absoluteStartYFloat - nextAbsoluteY2Float);
                        
                        absoluteX1String = [macSVGDocument allocFloatString:absoluteX1];
                        absoluteY1String = [macSVGDocument allocFloatString:absoluteY1];
                    }
                }
                
                reversePathSegmentDictionary[@"x1"] = absoluteX1String;
                reversePathSegmentDictionary[@"y1"] = absoluteY1String;
                
                break;
            }
            case 's':     // relative smooth cubic curve
            {
                // change smooth cubic curve to cubic curve
                commandCharacter = 'C';
                commandString = @"C";
                pathSegmentDictionary[@"command"] = commandString;

                NSString * absoluteX1String = [macSVGDocument allocFloatString:absoluteStartXFloat];
                NSString * absoluteY1String = [macSVGDocument allocFloatString:absoluteStartYFloat];
                
                if (currentIndex < reverseSegmentsArray.count)
                {
                    NSMutableDictionary * nextReversePathSegmentsDictionary =
                            reverseSegmentsArray[(currentIndex + 1)];
                    
                    NSNumber * nextAbsoluteX2Number = nextReversePathSegmentsDictionary[@"absoluteX2"];
                    NSNumber * nextAbsoluteY2Number = nextReversePathSegmentsDictionary[@"absoluteY2"];

                    if ((nextAbsoluteX2Number != NULL) && (nextAbsoluteY2Number != NULL))
                    {
                        CGFloat nextAbsoluteX2Float = nextAbsoluteX2Number.floatValue;
                        CGFloat nextAbsoluteY2Float = nextAbsoluteY2Number.floatValue;
                    
                        CGFloat absoluteX1 = absoluteStartXFloat + (absoluteStartXFloat - nextAbsoluteX2Float);
                        CGFloat absoluteY1 = absoluteStartYFloat + (absoluteStartYFloat - nextAbsoluteY2Float);
                        
                        absoluteX1String = [macSVGDocument allocFloatString:absoluteX1];
                        absoluteY1String = [macSVGDocument allocFloatString:absoluteY1];
                    }
                }
                
                reversePathSegmentDictionary[@"x1"] = absoluteX1String;
                reversePathSegmentDictionary[@"y1"] = absoluteY1String;

                reversePathSegmentDictionary[@"x"] = absoluteXString;
                reversePathSegmentDictionary[@"y"] = absoluteYString;

                NSNumber * absoluteX2Number = reversePathSegmentDictionary[@"absoluteX2"];
                NSNumber * absoluteY2Number = reversePathSegmentDictionary[@"absoluteY2"];

                CGFloat absoluteX2 = absoluteX2Number.floatValue;
                CGFloat absoluteY2 = absoluteY2Number.floatValue;
                
                NSString * absoluteX2String = [macSVGDocument allocFloatString:absoluteX2];
                NSString * absoluteY2String = [macSVGDocument allocFloatString:absoluteY2];
                
                reversePathSegmentDictionary[@"x2"] = absoluteX2String;
                reversePathSegmentDictionary[@"y2"] = absoluteY2String;
                
                break;
            }
            case 'Q':     // absolute quadratic curve
            {
                // change quadratic curve to cubic curve
                commandCharacter = 'C';
                commandString = @"C";
                pathSegmentDictionary[@"command"] = commandString;

                NSNumber * absoluteX1Number = reversePathSegmentDictionary[@"absoluteX1"];
                NSNumber * absoluteY1Number = reversePathSegmentDictionary[@"absoluteY1"];
                
                CGFloat absoluteX1Float = absoluteX1Number.floatValue;
                CGFloat absoluteY1Float = absoluteY1Number.floatValue;
                
                CGFloat newAbsoluteX1Float = absoluteStartXFloat - ((absoluteStartXFloat - absoluteX1Float) / 1.5f);
                CGFloat newAbsoluteY1Float = absoluteStartYFloat - ((absoluteStartYFloat - absoluteY1Float) / 1.5f);
                CGFloat newAbsoluteX2Float = absoluteXFloat - ((absoluteXFloat - absoluteX1Float) / 1.5f);
                CGFloat newAbsoluteY2Float = absoluteYFloat - ((absoluteYFloat - absoluteY1Float) / 1.5f);
                
                NSString * absoluteX1String = [macSVGDocument allocFloatString:newAbsoluteX1Float];
                NSString * absoluteY1String = [macSVGDocument allocFloatString:newAbsoluteY1Float];
                NSString * absoluteX2String = [macSVGDocument allocFloatString:newAbsoluteX2Float];
                NSString * absoluteY2String = [macSVGDocument allocFloatString:newAbsoluteY2Float];
                
                reversePathSegmentDictionary[@"x1"] = absoluteX1String;
                reversePathSegmentDictionary[@"y1"] = absoluteY1String;
                reversePathSegmentDictionary[@"x2"] = absoluteX2String;
                reversePathSegmentDictionary[@"y2"] = absoluteY2String;
                
                break;
            }
            case 'q':     // relative quadratic curve
            {
                // change quadratic curve to cubic curve
                commandCharacter = 'C';
                commandString = @"C";
                pathSegmentDictionary[@"command"] = commandString;

                NSNumber * absoluteX1Number = reversePathSegmentDictionary[@"absoluteX1"];
                NSNumber * absoluteY1Number = reversePathSegmentDictionary[@"absoluteY1"];
                
                CGFloat absoluteX1Float = absoluteX1Number.floatValue;
                CGFloat absoluteY1Float = absoluteY1Number.floatValue;
                
                CGFloat newAbsoluteX1Float = absoluteStartXFloat - ((absoluteStartXFloat - absoluteX1Float) / 1.5f);
                CGFloat newAbsoluteY1Float = absoluteStartYFloat - ((absoluteStartYFloat - absoluteY1Float) / 1.5f);
                CGFloat newAbsoluteX2Float = absoluteXFloat - ((absoluteXFloat - absoluteX1Float) / 1.5f);
                CGFloat newAbsoluteY2Float = absoluteYFloat - ((absoluteYFloat - absoluteY1Float) / 1.5f);
                
                NSString * absoluteX1String = [macSVGDocument allocFloatString:newAbsoluteX1Float];
                NSString * absoluteY1String = [macSVGDocument allocFloatString:newAbsoluteY1Float];
                NSString * absoluteX2String = [macSVGDocument allocFloatString:newAbsoluteX2Float];
                NSString * absoluteY2String = [macSVGDocument allocFloatString:newAbsoluteY2Float];
                
                reversePathSegmentDictionary[@"x1"] = absoluteX1String;
                reversePathSegmentDictionary[@"y1"] = absoluteY1String;
                reversePathSegmentDictionary[@"x2"] = absoluteX2String;
                reversePathSegmentDictionary[@"y2"] = absoluteY2String;
                
                break;
            }
            case 'T':     // absolute smooth quadratic curve
            {
                // change quadratic curve to cubic curve
                commandCharacter = 'C';
                commandString = @"C";
                pathSegmentDictionary[@"command"] = commandString;
                
                NSMutableDictionary * cubicSegmentDictionary = reverseCubicsSegmentsArray[currentIndex];

                NSNumber * cubicAbsoluteStartXNumber = cubicSegmentDictionary[@"absoluteStartX"];
                NSNumber * cubicAbsoluteStartYNumber = cubicSegmentDictionary[@"absoluteStartY"];
                NSNumber * cubicAbsoluteXNumber = cubicSegmentDictionary[@"absoluteX"];
                NSNumber * cubicAbsoluteYNumber = cubicSegmentDictionary[@"absoluteY"];
                NSNumber * cubicAbsoluteX1Number = cubicSegmentDictionary[@"absoluteX1"];
                NSNumber * cubicAbsoluteY1Number = cubicSegmentDictionary[@"absoluteY1"];
                NSNumber * cubicAbsoluteX2Number = cubicSegmentDictionary[@"absoluteX2"];
                NSNumber * cubicAbsoluteY2Number = cubicSegmentDictionary[@"absoluteY2"];
                
                NSString * cubicX1String = cubicSegmentDictionary[@"x1"];
                NSString * cubicY1String = cubicSegmentDictionary[@"y1"];
                NSString * cubicX2String = cubicSegmentDictionary[@"x2"];
                NSString * cubicY2String = cubicSegmentDictionary[@"y2"];
                
                // reverse the endpoint of the cubic bezier for the new segment
                
                NSMutableDictionary * newPathSegmentDictionary = [NSMutableDictionary dictionary];
                
                newPathSegmentDictionary[@"absoluteStartX"] = cubicAbsoluteXNumber;
                newPathSegmentDictionary[@"absoluteStartY"] = cubicAbsoluteYNumber;
                newPathSegmentDictionary[@"absoluteX"] = cubicAbsoluteStartXNumber;
                newPathSegmentDictionary[@"absoluteY"] = cubicAbsoluteStartYNumber;
                
                newPathSegmentDictionary[@"absoluteX1"] = cubicAbsoluteX1Number;
                newPathSegmentDictionary[@"absoluteY1"] = cubicAbsoluteY1Number;
                newPathSegmentDictionary[@"absoluteX2"] = cubicAbsoluteX2Number;
                newPathSegmentDictionary[@"absoluteY2"] = cubicAbsoluteY2Number;
                
                NSString * newXString = cubicAbsoluteStartXNumber.stringValue;
                NSString * newYString = cubicAbsoluteStartXNumber.stringValue;

                newPathSegmentDictionary[@"x"] = newXString;
                newPathSegmentDictionary[@"y"] = newYString;
                newPathSegmentDictionary[@"x1"] = cubicX1String;
                newPathSegmentDictionary[@"y1"] = cubicY1String;
                newPathSegmentDictionary[@"x2"] = cubicX2String;
                newPathSegmentDictionary[@"y2"] = cubicY2String;

                [reversePathSegmentDictionary setDictionary:newPathSegmentDictionary];

                break;
            }
            case 't':     // absolute smooth quadratic curve
            {
                commandCharacter = 'C';
                commandString = @"C";
                pathSegmentDictionary[@"command"] = commandString;
                
                NSMutableDictionary * cubicSegmentDictionary = reverseCubicsSegmentsArray[currentIndex];

                NSNumber * cubicAbsoluteStartXNumber = cubicSegmentDictionary[@"absoluteStartX"];
                NSNumber * cubicAbsoluteStartYNumber = cubicSegmentDictionary[@"absoluteStartY"];
                NSNumber * cubicAbsoluteXNumber = cubicSegmentDictionary[@"absoluteX"];
                NSNumber * cubicAbsoluteYNumber = cubicSegmentDictionary[@"absoluteY"];
                NSNumber * cubicAbsoluteX1Number = cubicSegmentDictionary[@"absoluteX1"];
                NSNumber * cubicAbsoluteY1Number = cubicSegmentDictionary[@"absoluteY1"];
                NSNumber * cubicAbsoluteX2Number = cubicSegmentDictionary[@"absoluteX2"];
                NSNumber * cubicAbsoluteY2Number = cubicSegmentDictionary[@"absoluteY2"];
                
                NSString * cubicX1String = cubicSegmentDictionary[@"x1"];
                NSString * cubicY1String = cubicSegmentDictionary[@"y1"];
                NSString * cubicX2String = cubicSegmentDictionary[@"x2"];
                NSString * cubicY2String = cubicSegmentDictionary[@"y2"];
                
                // reverse the endpoint of the cubic bezier for the new segment
                
                NSMutableDictionary * newPathSegmentDictionary = [NSMutableDictionary dictionary];
                
                newPathSegmentDictionary[@"absoluteStartX"] = cubicAbsoluteXNumber;
                newPathSegmentDictionary[@"absoluteStartY"] = cubicAbsoluteYNumber;
                newPathSegmentDictionary[@"absoluteX"] = cubicAbsoluteStartXNumber;
                newPathSegmentDictionary[@"absoluteY"] = cubicAbsoluteStartYNumber;
                
                newPathSegmentDictionary[@"absoluteX1"] = cubicAbsoluteX1Number;
                newPathSegmentDictionary[@"absoluteY1"] = cubicAbsoluteY1Number;
                newPathSegmentDictionary[@"absoluteX2"] = cubicAbsoluteX2Number;
                newPathSegmentDictionary[@"absoluteY2"] = cubicAbsoluteY2Number;
                
                NSString * newXString = cubicAbsoluteStartXNumber.stringValue;
                NSString * newYString = cubicAbsoluteStartXNumber.stringValue;

                newPathSegmentDictionary[@"x"] = newXString;
                newPathSegmentDictionary[@"y"] = newYString;
                newPathSegmentDictionary[@"x1"] = cubicX1String;
                newPathSegmentDictionary[@"y1"] = cubicY1String;
                newPathSegmentDictionary[@"x2"] = cubicX2String;
                newPathSegmentDictionary[@"y2"] = cubicY2String;

                [reversePathSegmentDictionary setDictionary:newPathSegmentDictionary];

                break;
            }
        }

        
        switch (commandCharacter)
        {
            case 'M':     // moveto
            {
                pathSegmentDictionary[@"x"] = absoluteStartXString;
                pathSegmentDictionary[@"y"] = absoluteStartYString;
                
                break;
            }

            case 'm':     // moveto
            {
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                break;
            }
            case 'L':     // lineto
            {
                pathSegmentDictionary[@"x"] = absoluteStartXString;
                pathSegmentDictionary[@"y"] = absoluteStartYString;

                break;
            }
            
            case 'l':     // lineto
            {
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                break;
            }

            case 'H':     // horizontal lineto
            {
                pathSegmentDictionary[@"x"] = absoluteStartXString;
                
                break;
            }

            case 'h':     // horizontal lineto
            {
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;
                
                break;
            }

            case 'V':     // vertical lineto
            {
                pathSegmentDictionary[@"y"] = absoluteStartYString;
                
                break;
            }
            
            case 'v':     // vertical lineto
            {
                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                break;
            }

            case 'C':     // curveto
            {
                pathSegmentDictionary[@"x"] = absoluteStartXString;
                pathSegmentDictionary[@"y"] = absoluteStartYString;

                NSString * x1String = reversePathSegmentDictionary[@"x1"];
                NSString * y1String = reversePathSegmentDictionary[@"y1"];
                NSString * x2String = reversePathSegmentDictionary[@"x2"];
                NSString * y2String = reversePathSegmentDictionary[@"y2"];
                
                
                pathSegmentDictionary[@"x1"] = x2String;
                pathSegmentDictionary[@"y1"] = y2String;
                pathSegmentDictionary[@"x2"] = x1String;
                pathSegmentDictionary[@"y2"] = y1String;

                break;
            }

            case 'c':     // curveto
            {
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSString * x1String = reversePathSegmentDictionary[@"x1"];
                NSString * y1String = reversePathSegmentDictionary[@"y1"];
                NSString * x2String = reversePathSegmentDictionary[@"x2"];
                NSString * y2String = reversePathSegmentDictionary[@"y2"];
                
                CGFloat x1Float = x1String.floatValue;
                CGFloat y1Float = y1String.floatValue;
                CGFloat x2Float = x2String.floatValue;
                CGFloat y2Float = y2String.floatValue;
                
                x1Float = -x1Float;
                y1Float = -y1Float;
                x2Float = -x2Float;
                y2Float = -y2Float;
                
                x1String = [macSVGDocument allocFloatString:x1Float];
                y1String = [macSVGDocument allocFloatString:y1Float];
                x2String = [macSVGDocument allocFloatString:x2Float];
                y2String = [macSVGDocument allocFloatString:y2Float];
                
                pathSegmentDictionary[@"x1"] = x2String;
                pathSegmentDictionary[@"y1"] = y2String;
                pathSegmentDictionary[@"x2"] = x1String;
                pathSegmentDictionary[@"y2"] = y1String;

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
                pathSegmentDictionary[@"x"] = absoluteStartXString;
                pathSegmentDictionary[@"y"] = absoluteStartYString;

                NSString * rxString = reversePathSegmentDictionary[@"rx"];
                NSString * ryString = reversePathSegmentDictionary[@"ry"];
                NSString * xAxisRotationString = reversePathSegmentDictionary[@"x-axis-rotation"];
                NSString * largeArcFlagString = reversePathSegmentDictionary[@"large-arc-flag"];
                NSString * sweepFlagString = reversePathSegmentDictionary[@"sweep-flag"];
                
                NSInteger sweepFlag = sweepFlagString.integerValue;
                sweepFlag = !sweepFlag;
                sweepFlagString = [NSString stringWithFormat:@"%ld", sweepFlag];
                
                pathSegmentDictionary[@"rx"] = rxString;
                pathSegmentDictionary[@"ry"] = ryString;
                pathSegmentDictionary[@"x-axis-rotation"] = xAxisRotationString;
                pathSegmentDictionary[@"large-arc-flag"] = largeArcFlagString;
                pathSegmentDictionary[@"sweep-flag"] = sweepFlagString;

                break;
            }
            case 'a':     // elliptical arc
            {
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSString * rxString = reversePathSegmentDictionary[@"rx"];
                NSString * ryString = reversePathSegmentDictionary[@"ry"];
                NSString * xAxisRotationString = reversePathSegmentDictionary[@"x-axis-rotation"];
                NSString * largeArcFlagString = reversePathSegmentDictionary[@"large-arc-flag"];
                NSString * sweepFlagString = reversePathSegmentDictionary[@"sweep-flag"];

                NSInteger sweepFlag = sweepFlagString.integerValue;
                sweepFlag = !sweepFlag;
                sweepFlagString = [NSString stringWithFormat:@"%ld", sweepFlag];
                
                pathSegmentDictionary[@"rx"] = rxString;
                pathSegmentDictionary[@"ry"] = ryString;
                pathSegmentDictionary[@"x-axis-rotation"] = xAxisRotationString;
                pathSegmentDictionary[@"large-arc-flag"] = largeArcFlagString;
                pathSegmentDictionary[@"sweep-flag"] = sweepFlagString;

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
        else if (currentIndex >= reverseSegmentsArray.count - 1)
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
        closePathDictionary[@"command"] = newLastCommand;
        
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

    NSInteger lastIndex = pathSegmentsArray.count - 1;
    
    NSPoint reverseOriginPoint = [self.macSVGDocumentWindowController.svgWebKitController
            endPointForSegmentIndex:lastIndex pathSegmentsArray:pathSegmentsArray];
    
    NSInteger currentIndex = 0;
    
    for (NSMutableDictionary * pathSegmentDictionary in reverseSegmentsArray)
    {
        MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
        
        NSNumber * absoluteStartXNumber = pathSegmentDictionary[@"absoluteStartX"];
        NSNumber * absoluteStartYNumber = pathSegmentDictionary[@"absoluteStartY"];
        
        CGFloat absoluteStartXFloat = absoluteStartXNumber.floatValue;
        CGFloat absoluteStartYFloat = absoluteStartYNumber.floatValue;

        NSPoint originalCurrentPoint = [self.macSVGDocumentWindowController.svgWebKitController
                endPointForSegmentIndex:(lastIndex - currentIndex)
                pathSegmentsArray:pathSegmentsArray];
        
        CGFloat currentXDelta = originalCurrentPoint.x - reverseOriginPoint.x;
        
        NSPoint currentPoint = NSMakePoint(originalCurrentPoint.x - currentXDelta, originalCurrentPoint.y);
        
        NSString * commandString = pathSegmentDictionary[@"command"];
        
        unichar commandCharacter = [commandString characterAtIndex:0];
        
        switch (commandCharacter)
        {
            case 'M':     // moveto
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                break;
            }

            case 'm':     // moveto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                NSString * yString = pathSegmentDictionary[@"y"];

                CGFloat xFloat = xString.floatValue;
                CGFloat yFloat = yString.floatValue;

                xFloat = -xFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                yFloat = -yFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                break;
            }
            case 'L':     // lineto
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                break;
            }
            
            case 'l':     // lineto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                NSString * yString = pathSegmentDictionary[@"y"];
                
                CGFloat xFloat = xString.floatValue;
                CGFloat yFloat = yString.floatValue;

                CGFloat newXFloat = xFloat;
                CGFloat newYFloat = -yFloat;

                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                yFloat = -yFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                break;
            }

            case 'H':     // horizontal lineto
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                
                break;
            }

            case 'h':     // horizontal lineto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                
                CGFloat xFloat = xString.floatValue;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;
                
                break;
            }

            case 'V':     // vertical lineto
            {
                NSString * yString = pathSegmentDictionary[@"y"];
                
                CGFloat yFloat = yString.floatValue;
                
                CGFloat yDelta = absoluteStartYFloat - yFloat;
                yFloat = currentPoint.y + yDelta;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                break;
            }
            
            case 'v':     // vertical lineto
            {
                NSString * yString = pathSegmentDictionary[@"y"];
                
                CGFloat yFloat = yString.floatValue;
                
                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                break;
            }

            case 'C':     // curveto
            {
                NSString * x1String = pathSegmentDictionary[@"x1"];
                NSString * y1String = pathSegmentDictionary[@"y1"];
                NSString * x2String = pathSegmentDictionary[@"x2"];
                NSString * y2String = pathSegmentDictionary[@"y2"];
                
                CGFloat x1Float = x1String.floatValue;
                CGFloat y1Float = y1String.floatValue;
                CGFloat x2Float = x2String.floatValue;
                CGFloat y2Float = y2String.floatValue;
                
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
                pathSegmentDictionary[@"x"] = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegmentDictionary[@"x1"] = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegmentDictionary[@"y1"] = newY1String;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegmentDictionary[@"y2"] = newY2String;

                break;
            }

            case 'c':     // curveto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                NSString * yString = pathSegmentDictionary[@"y"];
                NSString * x1String = pathSegmentDictionary[@"x1"];
                NSString * y1String = pathSegmentDictionary[@"y1"];
                NSString * x2String = pathSegmentDictionary[@"x2"];
                NSString * y2String = pathSegmentDictionary[@"y2"];
                
                CGFloat xFloat = xString.floatValue;
                CGFloat yFloat = yString.floatValue;
                CGFloat x1Float = x1String.floatValue;
                CGFloat y1Float = y1String.floatValue;
                CGFloat x2Float = x2String.floatValue;
                CGFloat y2Float = y2String.floatValue;
                
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
                pathSegmentDictionary[@"x"] = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegmentDictionary[@"x1"] = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegmentDictionary[@"y1"] = newY1String;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegmentDictionary[@"y2"] = newY2String;

                break;
            }

            case 'S':     // smooth curveto
            case 's':     // smooth curveto
            {
                // Convert this segment to an absolute cubic curve
                NSMutableDictionary * cubicSegmentDictionary = reverseCubicsSegmentsArray[currentIndex];

                NSString * x1String = cubicSegmentDictionary[@"x1"];
                NSString * y1String = cubicSegmentDictionary[@"y1"];
                NSString * x2String = cubicSegmentDictionary[@"x2"];
                NSString * y2String = cubicSegmentDictionary[@"y2"];
                
                //NSString * cubicXString = [cubicSegmentDictionary objectForKey:@"x"];
                //NSString * cubicYString = [cubicSegmentDictionary objectForKey:@"y"];

                CGFloat x1Float = x1String.floatValue;
                CGFloat y1Float = y1String.floatValue;
                CGFloat x2Float = x2String.floatValue;
                CGFloat y2Float = y2String.floatValue;
                
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
                pathSegmentDictionary[@"x"] = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegmentDictionary[@"x1"] = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegmentDictionary[@"y1"] = newY1String;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegmentDictionary[@"y2"] = newY2String;
                
                pathSegmentDictionary[@"command"] = @"C";

                break;
            }


            case 'Q':     // quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
            {
                // Convert this segment to an absolute cubic curve
                NSMutableDictionary * cubicSegmentDictionary = reverseCubicsSegmentsArray[currentIndex];

                NSString * x1String = cubicSegmentDictionary[@"x1"];
                NSString * y1String = cubicSegmentDictionary[@"y1"];
                NSString * x2String = cubicSegmentDictionary[@"x2"];
                NSString * y2String = cubicSegmentDictionary[@"y2"];
                
                //NSString * cubicXString = [cubicSegmentDictionary objectForKey:@"x"];
                //NSString * cubicYString = [cubicSegmentDictionary objectForKey:@"y"];

                CGFloat x1Float = x1String.floatValue;
                CGFloat y1Float = y1String.floatValue;
                CGFloat x2Float = x2String.floatValue;
                CGFloat y2Float = y2String.floatValue;
                
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
                pathSegmentDictionary[@"x"] = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegmentDictionary[@"x1"] = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegmentDictionary[@"y1"] = newY1String;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegmentDictionary[@"y2"] = newY2String;
                
                pathSegmentDictionary[@"command"] = @"C";

                break;
            }


            case 'T':     // smooth quadratic Bezier curve
            case 't':     // smooth quadratic Bezier curve
            {
                // Convert this segment to an absolute cubic curve
                NSMutableDictionary * cubicSegmentDictionary = reverseCubicsSegmentsArray[currentIndex];

                NSString * x1String = cubicSegmentDictionary[@"x1"];
                NSString * y1String = cubicSegmentDictionary[@"y1"];
                NSString * x2String = cubicSegmentDictionary[@"x2"];
                NSString * y2String = cubicSegmentDictionary[@"y2"];
                
                //NSString * cubicXString = [cubicSegmentDictionary objectForKey:@"x"];
                //NSString * cubicYString = [cubicSegmentDictionary objectForKey:@"y"];

                CGFloat x1Float = x1String.floatValue;
                CGFloat y1Float = y1String.floatValue;
                CGFloat x2Float = x2String.floatValue;
                CGFloat y2Float = y2String.floatValue;
                
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
                pathSegmentDictionary[@"x"] = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegmentDictionary[@"x1"] = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegmentDictionary[@"y1"] = newY1String;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegmentDictionary[@"y2"] = newY2String;
                
                pathSegmentDictionary[@"command"] = @"C";

                break;
            }



            case 'A':     // elliptical arc
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                break;
            }
            case 'a':     // elliptical arc
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                NSString * yString = pathSegmentDictionary[@"y"];
                
                CGFloat xFloat = xString.floatValue;
                CGFloat yFloat = yString.floatValue;
                
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

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



    NSInteger lastIndex = pathSegmentsArray.count - 1;
    
    NSPoint reverseOriginPoint = [self.macSVGDocumentWindowController.svgWebKitController
            endPointForSegmentIndex:lastIndex pathSegmentsArray:pathSegmentsArray];
    
    NSInteger currentIndex = 0;
    
    for (NSMutableDictionary * pathSegmentDictionary in reverseSegmentsArray)
    {
        MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
        
        NSNumber * absoluteStartXNumber = pathSegmentDictionary[@"absoluteStartX"];
        NSNumber * absoluteStartYNumber = pathSegmentDictionary[@"absoluteStartY"];
        
        CGFloat absoluteStartXFloat = absoluteStartXNumber.floatValue;
        CGFloat absoluteStartYFloat = absoluteStartYNumber.floatValue;

        NSPoint originalCurrentPoint = [self.macSVGDocumentWindowController.svgWebKitController
                endPointForSegmentIndex:(lastIndex - currentIndex)
                pathSegmentsArray:pathSegmentsArray];
        
        CGFloat currentYDelta = originalCurrentPoint.y - reverseOriginPoint.y;
        
        NSPoint currentPoint = NSMakePoint(originalCurrentPoint.x, originalCurrentPoint.y - currentYDelta);
        
        NSString * commandString = pathSegmentDictionary[@"command"];
        
        unichar commandCharacter = [commandString characterAtIndex:0];
        
        switch (commandCharacter)
        {
            case 'M':     // moveto
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                break;
            }

            case 'm':     // moveto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                NSString * yString = pathSegmentDictionary[@"y"];

                CGFloat xFloat = xString.floatValue;
                CGFloat yFloat = yString.floatValue;

                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                break;
            }
            case 'L':     // lineto
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                break;
            }
            
            case 'l':     // lineto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                NSString * yString = pathSegmentDictionary[@"y"];
                
                CGFloat xFloat = xString.floatValue;
                CGFloat yFloat = yString.floatValue;

                CGFloat newXFloat = xFloat;
                CGFloat newYFloat = -yFloat;

                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                break;
            }

            case 'H':     // horizontal lineto
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                
                break;
            }

            case 'h':     // horizontal lineto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                
                CGFloat xFloat = xString.floatValue;
                
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;
                
                break;
            }

            case 'V':     // vertical lineto
            {
                NSString * yString = pathSegmentDictionary[@"y"];
                
                CGFloat yFloat = yString.floatValue;
                
                CGFloat yDelta = absoluteStartYFloat - yFloat;
                yFloat = currentPoint.y + yDelta;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;
                
                break;
            }
            
            case 'v':     // vertical lineto
            {
                NSString * yString = pathSegmentDictionary[@"y"];
                
                CGFloat yFloat = yString.floatValue;
                
                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

                break;
            }

            case 'C':     // curveto
            {
                NSString * x1String = pathSegmentDictionary[@"x1"];
                NSString * y1String = pathSegmentDictionary[@"y1"];
                NSString * x2String = pathSegmentDictionary[@"x2"];
                NSString * y2String = pathSegmentDictionary[@"y2"];
                
                CGFloat x1Float = x1String.floatValue;
                CGFloat y1Float = y1String.floatValue;
                CGFloat x2Float = x2String.floatValue;
                CGFloat y2Float = y2String.floatValue;
                
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
                pathSegmentDictionary[@"x"] = newXString;

                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegmentDictionary[@"x1"] = newX1String;

                NSString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegmentDictionary[@"y1"] = newY1String;

                NSString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegmentDictionary[@"y2"] = newY2String;

                break;
            }

            case 'c':     // curveto
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                NSString * yString = pathSegmentDictionary[@"y"];
                NSString * x1String = pathSegmentDictionary[@"x1"];
                NSString * y1String = pathSegmentDictionary[@"y1"];
                NSString * x2String = pathSegmentDictionary[@"x2"];
                NSString * y2String = pathSegmentDictionary[@"y2"];
                
                CGFloat xFloat = xString.floatValue;
                CGFloat yFloat = yString.floatValue;
                CGFloat x1Float = x1String.floatValue;
                CGFloat y1Float = y1String.floatValue;
                CGFloat x2Float = x2String.floatValue;
                CGFloat y2Float = y2String.floatValue;
                
                CGFloat deltaX1 = currentPoint.x - x2Float;
                CGFloat deltaX2 = currentPoint.x - x1Float;
                
                CGFloat newXFloat = xFloat;
                CGFloat newYFloat = -yFloat;
                CGFloat newX1Float = currentPoint.x + deltaX1;
                CGFloat newY1Float = y2Float;
                CGFloat newX2Float = currentPoint.x + deltaX2;
                CGFloat newY2Float = y1Float;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegmentDictionary[@"x1"] = newX1String;

                NSString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegmentDictionary[@"y1"] = newY1String;

                NSString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegmentDictionary[@"y2"] = newY2String;

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
                NSMutableDictionary * cubicSegmentDictionary = reverseCubicsSegmentsArray[currentIndex];

                NSString * x1String = cubicSegmentDictionary[@"x1"];
                NSString * y1String = cubicSegmentDictionary[@"y1"];
                NSString * x2String = cubicSegmentDictionary[@"x2"];
                NSString * y2String = cubicSegmentDictionary[@"y2"];
                
                CGFloat x1Float = x1String.floatValue;
                CGFloat y1Float = y1String.floatValue;
                CGFloat x2Float = x2String.floatValue;
                CGFloat y2Float = y2String.floatValue;
                
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
                pathSegmentDictionary[@"x"] = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegmentDictionary[@"x1"] = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegmentDictionary[@"y1"] = newY1String;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegmentDictionary[@"x2"] = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegmentDictionary[@"y2"] = newY2String;
                
                pathSegmentDictionary[@"command"] = @"C";

                break;
            }
                
            case 'A':     // elliptical arc
            {
                CGFloat deltaX = currentPoint.x - absoluteStartXFloat;
                
                CGFloat newXFloat = currentPoint.x + deltaX;
                CGFloat newYFloat = absoluteStartYFloat;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegmentDictionary[@"x"] = newXString;

                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegmentDictionary[@"y"] = newYString;

                break;
            }
            case 'a':     // elliptical arc
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                NSString * yString = pathSegmentDictionary[@"y"];
                
                CGFloat xFloat = xString.floatValue;
                CGFloat yFloat = yString.floatValue;
                
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegmentDictionary[@"x"] = newXString;

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegmentDictionary[@"y"] = newYString;

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
    NSString * valueString = pathSegmentDictionary[attributeName];
    if (valueString != NULL)
    {
        result = valueString.floatValue;
    }
    return result;
}

//==================================================================================
//	flipPathHorizontallyWithPathSegmentsArray:
//==================================================================================

- (NSMutableArray *)flipPathHorizontallyWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;

    NSMutableArray * newSegmentsArray = [NSMutableArray array];

    if (pathSegmentsArray.count > 0)
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
            
            NSString * commandString = pathSegmentDictionary[@"command"];
            
            unichar commandCharacter = [commandString characterAtIndex:0];
            
            NSMutableDictionary * newSegmentDictionary = [NSMutableDictionary dictionary];

            newSegmentDictionary[@"command"] = commandString;
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = oldYString;
                    break;
                }

                case 'm':     // moveto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = oldYString;
                    break;
                }
                case 'L':     // lineto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = oldYString;
                    break;
                }
                
                case 'l':     // lineto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = oldYString;
                    break;
                }

                case 'H':     // horizontal lineto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    break;
                }

                case 'h':     // horizontal lineto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    break;
                }

                case 'V':     // vertical lineto
                {
                    newSegmentDictionary[@"y"] = oldYString;
                    break;
                }
                
                case 'v':     // vertical lineto
                {
                    newSegmentDictionary[@"y"] = oldYString;
                    break;
                }

                case 'C':     // absolute curveto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = oldYString;
                    newSegmentDictionary[@"x1"] = newAbsoluteX1String;
                    newSegmentDictionary[@"y1"] = oldY1String;
                    newSegmentDictionary[@"x2"] = newAbsoluteX2String;
                    newSegmentDictionary[@"y2"] = oldY2String;
                    break;
                }

                case 'c':     // relative curveto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = oldYString;
                    newSegmentDictionary[@"x1"] = newRelativeX1String;
                    newSegmentDictionary[@"y1"] = oldY1String;
                    newSegmentDictionary[@"x2"] = newRelativeX2String;
                    newSegmentDictionary[@"y2"] = oldY2String;

                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = oldYString;
                    newSegmentDictionary[@"x2"] = newAbsoluteX2String;
                    newSegmentDictionary[@"y2"] = oldY2String;
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = oldYString;
                    newSegmentDictionary[@"x2"] = newRelativeX2String;
                    newSegmentDictionary[@"y2"] = oldY2String;
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = oldYString;
                    newSegmentDictionary[@"x1"] = newAbsoluteX1String;
                    newSegmentDictionary[@"y1"] = oldY1String;
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = oldYString;
                    newSegmentDictionary[@"x1"] = newRelativeX1String;
                    newSegmentDictionary[@"y1"] = oldY1String;
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = oldYString;
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = oldYString;
                    break;
                }

                case 'A':     // elliptical arc
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = oldYString;

                    NSString * rxString = pathSegmentDictionary[@"rx"];
                    NSString * ryString = pathSegmentDictionary[@"ry"];
                    NSString * xAxisRotationString = pathSegmentDictionary[@"x-axis-rotation"];
                    NSString * largeArcFlagString = pathSegmentDictionary[@"large-arc-flag"];
                    NSString * sweepFlagString = pathSegmentDictionary[@"sweep-flag"];
                    
                    newSegmentDictionary[@"rx"] = rxString;
                    newSegmentDictionary[@"ry"] = ryString;
                    newSegmentDictionary[@"x-axis-rotation"] = xAxisRotationString;
                    newSegmentDictionary[@"large-arc-flag"] = largeArcFlagString;
                    newSegmentDictionary[@"sweep-flag"] = sweepFlagString;

                    break;
                }
                case 'a':     // elliptical arc
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = oldYString;

                    NSString * rxString = pathSegmentDictionary[@"rx"];
                    NSString * ryString = pathSegmentDictionary[@"ry"];
                    NSString * xAxisRotationString = pathSegmentDictionary[@"x-axis-rotation"];
                    NSString * largeArcFlagString = pathSegmentDictionary[@"large-arc-flag"];
                    NSString * sweepFlagString = pathSegmentDictionary[@"sweep-flag"];
                    
                    newSegmentDictionary[@"rx"] = rxString;
                    newSegmentDictionary[@"ry"] = ryString;
                    newSegmentDictionary[@"x-axis-rotation"] = xAxisRotationString;
                    newSegmentDictionary[@"large-arc-flag"] = largeArcFlagString;
                    newSegmentDictionary[@"sweep-flag"] = sweepFlagString;
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
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;

    NSMutableArray * newSegmentsArray = [NSMutableArray array];

    if (pathSegmentsArray.count > 0)
    {
        NSInteger lastIndex = pathSegmentsArray.count - 1;
        
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
            
            NSString * commandString = pathSegmentDictionary[@"command"];
            
            unichar commandCharacter = [commandString characterAtIndex:0];
            
            NSMutableDictionary * newSegmentDictionary = [NSMutableDictionary dictionary];

            newSegmentDictionary[@"command"] = commandString;
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    break;
                }

                case 'm':     // moveto
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    break;
                }
                case 'L':     // lineto
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    break;
                }
                
                case 'l':     // lineto
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    break;
                }

                case 'H':     // horizontal lineto
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    break;
                }

                case 'h':     // horizontal lineto
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    break;
                }

                case 'V':     // vertical lineto
                {
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    break;
                }
                
                case 'v':     // vertical lineto
                {
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    break;
                }

                case 'C':     // absolute curveto
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    newSegmentDictionary[@"x1"] = oldX1String;
                    newSegmentDictionary[@"y1"] = newAbsoluteY1String;
                    newSegmentDictionary[@"x2"] = oldX2String;
                    newSegmentDictionary[@"y2"] = newAbsoluteY2String;
                    break;
                }

                case 'c':     // relative curveto
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    newSegmentDictionary[@"x1"] = oldX1String;
                    newSegmentDictionary[@"y1"] = newRelativeY1String;
                    newSegmentDictionary[@"x2"] = oldX2String;
                    newSegmentDictionary[@"y2"] = newRelativeY2String;
                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    newSegmentDictionary[@"x2"] = oldX2String;
                    newSegmentDictionary[@"y2"] = newAbsoluteY2String;
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    newSegmentDictionary[@"x2"] = oldX2String;
                    newSegmentDictionary[@"y2"] = newRelativeY2String;
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    newSegmentDictionary[@"x1"] = oldX1String;
                    newSegmentDictionary[@"y1"] = newAbsoluteY1String;
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    newSegmentDictionary[@"x1"] = oldX1String;
                    newSegmentDictionary[@"y1"] = newRelativeY1String;
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    newSegmentDictionary[@"x"] = oldXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    break;
                }

                case 'A':     // elliptical arc
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    
                    NSString * rxString = pathSegmentDictionary[@"rx"];
                    NSString * ryString = pathSegmentDictionary[@"ry"];
                    NSString * xAxisRotationString = pathSegmentDictionary[@"x-axis-rotation"];
                    NSString * largeArcFlagString = pathSegmentDictionary[@"large-arc-flag"];
                    NSString * sweepFlagString = pathSegmentDictionary[@"sweep-flag"];
                    
                    newSegmentDictionary[@"rx"] = rxString;
                    newSegmentDictionary[@"ry"] = ryString;
                    newSegmentDictionary[@"x-axis-rotation"] = xAxisRotationString;
                    newSegmentDictionary[@"large-arc-flag"] = largeArcFlagString;
                    newSegmentDictionary[@"sweep-flag"] = sweepFlagString;

                    break;
                }
                case 'a':     // elliptical arc
                {
                    newSegmentDictionary[@"x"] = oldXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    
                    NSString * rxString = pathSegmentDictionary[@"rx"];
                    NSString * ryString = pathSegmentDictionary[@"ry"];
                    NSString * xAxisRotationString = pathSegmentDictionary[@"x-axis-rotation"];
                    NSString * largeArcFlagString = pathSegmentDictionary[@"large-arc-flag"];
                    NSString * sweepFlagString = pathSegmentDictionary[@"sweep-flag"];
                    
                    newSegmentDictionary[@"rx"] = rxString;
                    newSegmentDictionary[@"ry"] = ryString;
                    newSegmentDictionary[@"x-axis-rotation"] = xAxisRotationString;
                    newSegmentDictionary[@"large-arc-flag"] = largeArcFlagString;
                    newSegmentDictionary[@"sweep-flag"] = sweepFlagString;

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
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;

    NSMutableArray * newSegmentsArray = [NSMutableArray array];

    if (pathSegmentsArray.count > 0)
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
            
            NSString * commandString = pathSegmentDictionary[@"command"];
            
            unichar commandCharacter = [commandString characterAtIndex:0];
            
            NSMutableDictionary * newSegmentDictionary = [NSMutableDictionary dictionary];

            newSegmentDictionary[@"command"] = commandString;
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    break;
                }

                case 'm':     // moveto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    break;
                }
                case 'L':     // lineto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    break;
                }
                
                case 'l':     // lineto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    break;
                }

                case 'H':     // horizontal lineto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    break;
                }

                case 'h':     // horizontal lineto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    break;
                }

                case 'V':     // vertical lineto
                {
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    break;
                }
                
                case 'v':     // vertical lineto
                {
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    break;
                }

                case 'C':     // absolute curveto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    newSegmentDictionary[@"x1"] = newAbsoluteX1String;
                    newSegmentDictionary[@"y1"] = newAbsoluteY1String;
                    newSegmentDictionary[@"x2"] = newAbsoluteX2String;
                    newSegmentDictionary[@"y2"] = newAbsoluteY2String;
                    break;
                }

                case 'c':     // relative curveto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    newSegmentDictionary[@"x1"] = newRelativeX1String;
                    newSegmentDictionary[@"y1"] = newRelativeY1String;
                    newSegmentDictionary[@"x2"] = newRelativeX2String;
                    newSegmentDictionary[@"y2"] = newRelativeY2String;
                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    newSegmentDictionary[@"x2"] = newAbsoluteX2String;
                    newSegmentDictionary[@"y2"] = newAbsoluteY2String;
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    newSegmentDictionary[@"x2"] = newRelativeX2String;
                    newSegmentDictionary[@"y2"] = newRelativeY2String;
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    newSegmentDictionary[@"x1"] = newAbsoluteX1String;
                    newSegmentDictionary[@"y1"] = newAbsoluteY1String;
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    newSegmentDictionary[@"x1"] = newRelativeX1String;
                    newSegmentDictionary[@"y1"] = newRelativeY1String;
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    break;
                }

                case 'A':     // elliptical arc
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    
                    NSString * rxString = pathSegmentDictionary[@"rx"];
                    NSString * ryString = pathSegmentDictionary[@"ry"];
                    NSString * xAxisRotationString = pathSegmentDictionary[@"x-axis-rotation"];
                    NSString * largeArcFlagString = pathSegmentDictionary[@"large-arc-flag"];
                    NSString * sweepFlagString = pathSegmentDictionary[@"sweep-flag"];
                    
                    CGFloat rxFloat = rxString.floatValue + translateX;
                    CGFloat ryFloat = ryString.floatValue + translateY;
                    rxString = [macSVGDocument allocFloatString:rxFloat];
                    ryString = [macSVGDocument allocFloatString:ryFloat];
                    
                    newSegmentDictionary[@"rx"] = rxString;
                    newSegmentDictionary[@"ry"] = ryString;
                    newSegmentDictionary[@"x-axis-rotation"] = xAxisRotationString;
                    newSegmentDictionary[@"large-arc-flag"] = largeArcFlagString;
                    newSegmentDictionary[@"sweep-flag"] = sweepFlagString;

                    break;
                }
                case 'a':     // elliptical arc
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    
                    NSString * rxString = pathSegmentDictionary[@"rx"];
                    NSString * ryString = pathSegmentDictionary[@"ry"];
                    NSString * xAxisRotationString = pathSegmentDictionary[@"x-axis-rotation"];
                    NSString * largeArcFlagString = pathSegmentDictionary[@"large-arc-flag"];
                    NSString * sweepFlagString = pathSegmentDictionary[@"sweep-flag"];

                    CGFloat rxFloat = rxString.floatValue + translateX;
                    CGFloat ryFloat = ryString.floatValue + translateY;
                    rxString = [macSVGDocument allocFloatString:rxFloat];
                    ryString = [macSVGDocument allocFloatString:ryFloat];
                    
                    newSegmentDictionary[@"rx"] = rxString;
                    newSegmentDictionary[@"ry"] = ryString;
                    newSegmentDictionary[@"x-axis-rotation"] = xAxisRotationString;
                    newSegmentDictionary[@"large-arc-flag"] = largeArcFlagString;
                    newSegmentDictionary[@"sweep-flag"] = sweepFlagString;

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
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;

    NSMutableArray * newSegmentsArray = [NSMutableArray array];

    if (pathSegmentsArray.count > 0)
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
            
            NSString * commandString = pathSegmentDictionary[@"command"];
            
            unichar commandCharacter = [commandString characterAtIndex:0];
            
            NSMutableDictionary * newSegmentDictionary = [NSMutableDictionary dictionary];

            newSegmentDictionary[@"command"] = commandString;
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    break;
                }

                case 'm':     // moveto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    break;
                }
                case 'L':     // lineto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    break;
                }
                
                case 'l':     // lineto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    break;
                }

                case 'H':     // horizontal lineto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    break;
                }

                case 'h':     // horizontal lineto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    break;
                }

                case 'V':     // vertical lineto
                {
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    break;
                }
                
                case 'v':     // vertical lineto
                {
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    break;
                }

                case 'C':     // absolute curveto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    newSegmentDictionary[@"x1"] = newAbsoluteX1String;
                    newSegmentDictionary[@"y1"] = newAbsoluteY1String;
                    newSegmentDictionary[@"x2"] = newAbsoluteX2String;
                    newSegmentDictionary[@"y2"] = newAbsoluteY2String;
                    break;
                }

                case 'c':     // relative curveto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    newSegmentDictionary[@"x1"] = newRelativeX1String;
                    newSegmentDictionary[@"y1"] = newRelativeY1String;
                    newSegmentDictionary[@"x2"] = newRelativeX2String;
                    newSegmentDictionary[@"y2"] = newRelativeY2String;
                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    newSegmentDictionary[@"x2"] = newAbsoluteX2String;
                    newSegmentDictionary[@"y2"] = newAbsoluteY2String;
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    newSegmentDictionary[@"x2"] = newRelativeX2String;
                    newSegmentDictionary[@"y2"] = newRelativeY2String;
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    newSegmentDictionary[@"x1"] = newAbsoluteX1String;
                    newSegmentDictionary[@"y1"] = newAbsoluteY1String;
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    newSegmentDictionary[@"x1"] = newRelativeX1String;
                    newSegmentDictionary[@"y1"] = newRelativeY1String;
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    break;
                }

                case 'A':     // elliptical arc
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    
                    NSString * rxString = pathSegmentDictionary[@"rx"];
                    NSString * ryString = pathSegmentDictionary[@"ry"];
                    NSString * xAxisRotationString = pathSegmentDictionary[@"x-axis-rotation"];
                    NSString * largeArcFlagString = pathSegmentDictionary[@"large-arc-flag"];
                    NSString * sweepFlagString = pathSegmentDictionary[@"sweep-flag"];
                    
                    CGFloat rxFloat = rxString.floatValue * scaleX;
                    CGFloat ryFloat = ryString.floatValue * scaleY;
                    rxString = [macSVGDocument allocFloatString:rxFloat];
                    ryString = [macSVGDocument allocFloatString:ryFloat];
                    
                    newSegmentDictionary[@"rx"] = rxString;
                    newSegmentDictionary[@"ry"] = ryString;
                    newSegmentDictionary[@"x-axis-rotation"] = xAxisRotationString;
                    newSegmentDictionary[@"large-arc-flag"] = largeArcFlagString;
                    newSegmentDictionary[@"sweep-flag"] = sweepFlagString;

                    break;
                }
                case 'a':     // elliptical arc
                {
                    newSegmentDictionary[@"x"] = newRelativeXString;
                    newSegmentDictionary[@"y"] = newRelativeYString;
                    
                    NSString * rxString = pathSegmentDictionary[@"rx"];
                    NSString * ryString = pathSegmentDictionary[@"ry"];
                    NSString * xAxisRotationString = pathSegmentDictionary[@"x-axis-rotation"];
                    NSString * largeArcFlagString = pathSegmentDictionary[@"large-arc-flag"];
                    NSString * sweepFlagString = pathSegmentDictionary[@"sweep-flag"];

                    CGFloat rxFloat = rxString.floatValue * scaleX;
                    CGFloat ryFloat = ryString.floatValue * scaleY;
                    rxString = [macSVGDocument allocFloatString:rxFloat];
                    ryString = [macSVGDocument allocFloatString:ryFloat];
                    
                    newSegmentDictionary[@"rx"] = rxString;
                    newSegmentDictionary[@"ry"] = ryString;
                    newSegmentDictionary[@"x-axis-rotation"] = xAxisRotationString;
                    newSegmentDictionary[@"large-arc-flag"] = largeArcFlagString;
                    newSegmentDictionary[@"sweep-flag"] = sweepFlagString;

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

    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
    
    NSMutableArray * newSegmentsArray = [NSMutableArray array];

    if (pathSegmentsArray.count > 0)
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
            
            NSString * commandString = pathSegmentDictionary[@"command"];
            
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

            newSegmentDictionary[@"command"] = commandString;
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    break;
                }

                case 'm':     // moveto
                {
                    break;
                }
                case 'L':     // lineto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
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
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    newSegmentDictionary[@"x1"] = newAbsoluteX1String;
                    newSegmentDictionary[@"y1"] = newAbsoluteY1String;
                    newSegmentDictionary[@"x2"] = newAbsoluteX2String;
                    newSegmentDictionary[@"y2"] = newAbsoluteY2String;
                    break;
                }

                case 'c':     // relative curveto
                {
                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    newSegmentDictionary[@"x2"] = newAbsoluteX2String;
                    newSegmentDictionary[@"y2"] = newAbsoluteY2String;
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    newSegmentDictionary[@"x1"] = newAbsoluteX1String;
                    newSegmentDictionary[@"y1"] = newAbsoluteY1String;
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    break;
                }

                case 'A':     // elliptical arc
                {
                    newSegmentDictionary[@"x"] = newAbsoluteXString;
                    newSegmentDictionary[@"y"] = newAbsoluteYString;

                    NSString * rxString = pathSegmentDictionary[@"rx"];
                    NSString * ryString = pathSegmentDictionary[@"ry"];
                    NSString * xAxisRotationString = pathSegmentDictionary[@"x-axis-rotation"];
                    NSString * largeArcFlagString = pathSegmentDictionary[@"large-arc-flag"];
                    NSString * sweepFlagString = pathSegmentDictionary[@"sweep-flag"];
                    
                    newSegmentDictionary[@"rx"] = rxString;
                    newSegmentDictionary[@"ry"] = ryString;
                    newSegmentDictionary[@"x-axis-rotation"] = xAxisRotationString;
                    newSegmentDictionary[@"large-arc-flag"] = largeArcFlagString;
                    newSegmentDictionary[@"sweep-flag"] = sweepFlagString;
                    
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

//==================================================================================
//	closePathWithPathSegmentsArray:
//==================================================================================

- (NSMutableArray *)closePathWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    // returns the original array
    // if last command is not 'Z' or 'z', can modify existing attribute values of last command
    // also adds a 'Z' or 'z' command if none exists

    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;

    NSInteger pathSegmentsArrayCount = pathSegmentsArray.count;
    if (pathSegmentsArrayCount > 2)
    {
        NSInteger lastSegmentIndex = pathSegmentsArrayCount - 1;
        
        NSMutableDictionary * firstPathSegmentDictionary = [pathSegmentsArray objectAtIndex:0];
        NSString * firstPathSegmentCommandString = [firstPathSegmentDictionary objectForKey:@"command"];
        unichar firstPathSegmentCommand = [firstPathSegmentCommandString characterAtIndex:0];

        CGFloat firstXFloat = [self floatForAttribute:@"x" pathSegment:firstPathSegmentDictionary];
        CGFloat firstYFloat = [self floatForAttribute:@"y" pathSegment:firstPathSegmentDictionary];

        CGFloat firstAbsoluteXFloat = [self floatForAttribute:@"absoluteX" pathSegment:firstPathSegmentDictionary];
        CGFloat firstAbsoluteYFloat = [self floatForAttribute:@"absoluteY" pathSegment:firstPathSegmentDictionary];

        NSMutableDictionary * secondPathSegmentDictionary = [pathSegmentsArray objectAtIndex:1];
        NSString * secondPathSegmentCommandString = [secondPathSegmentDictionary objectForKey:@"command"];
        unichar secondPathSegmentCommand = [secondPathSegmentCommandString characterAtIndex:0];

        CGFloat secondX1Float = [self floatForAttribute:@"x1" pathSegment:secondPathSegmentDictionary];
        CGFloat secondY1Float = [self floatForAttribute:@"y1" pathSegment:secondPathSegmentDictionary];

        CGFloat secondX2Float = [self floatForAttribute:@"x2" pathSegment:secondPathSegmentDictionary];
        CGFloat secondY2Float = [self floatForAttribute:@"y2" pathSegment:secondPathSegmentDictionary];

        CGFloat secondAbsoluteX1Float = [self floatForAttribute:@"absoluteX1" pathSegment:secondPathSegmentDictionary];
        CGFloat secondAbsoluteY1Float = [self floatForAttribute:@"absoluteY1" pathSegment:secondPathSegmentDictionary];

        NSMutableDictionary * lastPathSegmentDictionary = [pathSegmentsArray objectAtIndex:lastSegmentIndex];
        NSString * lastPathSegmentCommandString = [lastPathSegmentDictionary objectForKey:@"command"];
        unichar lastPathSegmentCommand = [lastPathSegmentCommandString characterAtIndex:0];

        CGFloat lastAbsoluteStartXFloat = [self floatForAttribute:@"absoluteStartX" pathSegment:lastPathSegmentDictionary];
        CGFloat lastAbsoluteStartYFloat = [self floatForAttribute:@"absoluteStartY" pathSegment:lastPathSegmentDictionary];

        
        if ((lastPathSegmentCommand != 'Z') && (lastPathSegmentCommand != 'z'))
        {
            if (firstPathSegmentCommand == 'M')
            {
                switch (lastPathSegmentCommand)
                {
                    case 'M':     // moveto
                    {
                        break;
                    }

                    case 'm':     // moveto
                    {
                        break;
                    }
                    case 'L':     // lineto
                    {
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
                        if (secondPathSegmentCommand == 'C')
                        {
                            NSString * newXString = [macSVGDocument allocFloatString:firstXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:firstYFloat];

                            CGFloat newX2Float = firstXFloat - (secondX1Float - firstXFloat);
                            CGFloat newY2Float = firstYFloat - (secondY1Float - firstYFloat);
                            
                            NSString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                            NSString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                            
                            lastPathSegmentDictionary[@"x"] = newXString;
                            lastPathSegmentDictionary[@"y"] = newYString;
                            lastPathSegmentDictionary[@"x2"] = newX2String;
                            lastPathSegmentDictionary[@"y2"] = newY2String;
                        }

                        break;
                    }

                    case 'c':     // relative curveto
                    {
                        if (secondPathSegmentCommand == 'c')
                        {
                            CGFloat newXFloat = firstAbsoluteXFloat - lastAbsoluteStartXFloat;
                            CGFloat newYFloat = firstAbsoluteYFloat - lastAbsoluteStartYFloat;
                        
                            NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:newYFloat];

                            CGFloat newX2Float = (firstAbsoluteXFloat - secondAbsoluteX1Float) + (firstAbsoluteXFloat - lastAbsoluteStartXFloat);
                            CGFloat newY2Float = (firstAbsoluteYFloat - secondAbsoluteY1Float) + (firstAbsoluteYFloat -lastAbsoluteStartYFloat);
                            
                            NSString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                            NSString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                            
                            lastPathSegmentDictionary[@"x"] = newXString;
                            lastPathSegmentDictionary[@"y"] = newYString;
                            lastPathSegmentDictionary[@"x2"] = newX2String;
                            lastPathSegmentDictionary[@"y2"] = newY2String;
                        }

                        break;
                    }

                    case 'S':     // absolute smooth cubic curveto
                    {
                        if (secondPathSegmentCommand == 'S')
                        {
                            NSString * newXString = [macSVGDocument allocFloatString:firstXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:firstYFloat];

                            CGFloat newX2Float = firstXFloat - (secondX2Float - firstXFloat);
                            CGFloat newY2Float = firstYFloat - (secondY2Float - firstYFloat);
                            
                            NSString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                            NSString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                            
                            lastPathSegmentDictionary[@"x"] = newXString;
                            lastPathSegmentDictionary[@"y"] = newYString;
                            lastPathSegmentDictionary[@"x2"] = newX2String;
                            lastPathSegmentDictionary[@"y2"] = newY2String;
                        }
                        break;
                    }
                    
                    case 's':     // relative smooth cubic curveto
                    {
                        if (secondPathSegmentCommand == 's')
                        {
                            CGFloat newXFloat = firstAbsoluteXFloat - lastAbsoluteStartXFloat;
                            CGFloat newYFloat = firstAbsoluteYFloat - lastAbsoluteStartYFloat;

                            NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:newYFloat];

                            NSString * newX2String = [macSVGDocument allocFloatString:newXFloat];
                            NSString * newY2String = [macSVGDocument allocFloatString:newYFloat];
                            
                            lastPathSegmentDictionary[@"x"] = newXString;
                            lastPathSegmentDictionary[@"y"] = newYString;
                            lastPathSegmentDictionary[@"x2"] = newX2String;
                            lastPathSegmentDictionary[@"y2"] = newY2String;
                        }
                        break;
                    }

                    case 'Q':     // quadratic Bezier curve
                    {
                        if (secondPathSegmentCommand == 'Q')
                        {
                            NSString * newXString = [macSVGDocument allocFloatString:firstXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:firstYFloat];

                            CGFloat newX1Float = firstXFloat - (secondX1Float - firstXFloat);
                            CGFloat newY1Float = firstYFloat - (secondY1Float - firstYFloat);
                            
                            NSString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                            NSString * newY1String = [macSVGDocument allocFloatString:newY1Float];

                            lastPathSegmentDictionary[@"x"] = newXString;
                            lastPathSegmentDictionary[@"y"] = newYString;
                            lastPathSegmentDictionary[@"x1"] = newX1String;
                            lastPathSegmentDictionary[@"y1"] = newY1String;
                        }
                        break;
                    }
                    
                    case 'q':     // quadratic Bezier curve
                    {
                        if (secondPathSegmentCommand == 'q')
                        {
                            CGFloat newXFloat = firstAbsoluteXFloat - lastAbsoluteStartXFloat;
                            CGFloat newYFloat = firstAbsoluteYFloat - lastAbsoluteStartYFloat;

                            NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:newYFloat];

                            NSString * newX1String = [macSVGDocument allocFloatString:newXFloat];
                            NSString * newY1String = [macSVGDocument allocFloatString:newYFloat];

                            lastPathSegmentDictionary[@"x"] = newXString;
                            lastPathSegmentDictionary[@"y"] = newYString;
                            lastPathSegmentDictionary[@"x1"] = newX1String;
                            lastPathSegmentDictionary[@"y1"] = newY1String;
                        }

                        break;
                    }

                    case 'T':     // smooth quadratic Bezier curve
                        if (secondPathSegmentCommand == 'T')
                        {
                            NSString * newXString = [macSVGDocument allocFloatString:firstXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:firstYFloat];

                            lastPathSegmentDictionary[@"x"] = newXString;
                            lastPathSegmentDictionary[@"y"] = newYString;
                        }
                        break;

                    case 't':     // smooth quadratic Bezier curve
                    {
                        if (secondPathSegmentCommand == 't')
                        {
                            CGFloat newXFloat = firstAbsoluteXFloat - lastAbsoluteStartXFloat;
                            CGFloat newYFloat = firstAbsoluteYFloat - lastAbsoluteStartYFloat;

                            NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:newYFloat];

                            lastPathSegmentDictionary[@"x"] = newXString;
                            lastPathSegmentDictionary[@"y"] = newYString;
                        }

                        break;
                    }

                    case 'A':     // elliptical arc
                    {
                        if (secondPathSegmentCommand == 'A')
                        {
                            NSString * newXString = [macSVGDocument allocFloatString:firstXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:firstYFloat];

                            lastPathSegmentDictionary[@"x"] = newXString;
                            lastPathSegmentDictionary[@"y"] = newYString;
                        }
                        
                        break;
                    }
                    case 'a':     // elliptical arc
                    {
                        if (secondPathSegmentCommand == 'a')
                        {
                            CGFloat newXFloat = firstAbsoluteXFloat - lastAbsoluteStartXFloat;
                            CGFloat newYFloat = firstAbsoluteYFloat - lastAbsoluteStartYFloat;

                            NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:newYFloat];

                            lastPathSegmentDictionary[@"x"] = newXString;
                            lastPathSegmentDictionary[@"y"] = newYString;
                        }

                        break;
                    }

                    case 'Z':     // closepath
                    case 'z':     // closepath
                        break;
                }
            }

            NSMutableDictionary * closePathSegmentDictionary = [NSMutableDictionary dictionary];
            
            if ((lastPathSegmentCommand >= 'a') && (lastPathSegmentCommand <= 'z'))
            {
                [closePathSegmentDictionary setObject:@"z" forKey:@"command"];
            }
            else
            {
                [closePathSegmentDictionary setObject:@"Z" forKey:@"command"];
            }
            
            [pathSegmentsArray addObject:closePathSegmentDictionary];
        }
    }
    
    return pathSegmentsArray;
}

//==================================================================================
//	rotateSegmentsWithPathSegmentsArray:offset:
//==================================================================================

- (NSMutableArray *)rotateSegmentsWithPathSegmentsArray:(NSMutableArray *)mixedPathSegmentsArray offset:(NSInteger)offset
{
    // this method will convert the path segments to use absolute coordinates before segment rotation.
    // Typical offset values: 1 = rotate segments to right one position, -1 = rotate segments to left one position
    
    NSMutableArray * pathSegmentsArray = [self convertToAbsoluteCoordinatesWithPathSegmentsArray:mixedPathSegmentsArray];
    
    NSInteger pathSegmentsArrayCount = pathSegmentsArray.count;
    
    NSMutableArray * newSegmentsArray = NULL;
    
    if ((pathSegmentsArrayCount > 3) && (offset < pathSegmentsArrayCount))
    {
        NSMutableDictionary * firstSegmentDictionary = [pathSegmentsArray objectAtIndex:0];
        NSString * firstSegmentCommand = [firstSegmentDictionary objectForKey:@"command"];
        
        if ([firstSegmentCommand isEqualToString:@"M"] == YES)
        {
            BOOL closePathFound = NO;
            NSInteger lastSegmentIndex = pathSegmentsArrayCount - 1;

            NSMutableDictionary * lastSegmentDictionary = [pathSegmentsArray objectAtIndex:lastSegmentIndex];
            NSString * lastSegmentCommand = [lastSegmentDictionary objectForKey:@"command"];
            if ([lastSegmentCommand isEqualToString:@"Z"] == YES)
            {
                closePathFound = YES;
                lastSegmentIndex--;
            }
        
            newSegmentsArray = [NSMutableArray array];

            if (offset < 0)
            {
                // left rotation

                NSMutableDictionary * startSegmentDictionary = [pathSegmentsArray objectAtIndex:-offset];
                NSNumber * startXNumber = [startSegmentDictionary objectForKey:@"absoluteX"];
                NSNumber * startYNumber = [startSegmentDictionary objectForKey:@"absoluteY"];
                
                NSString * startX = [startXNumber stringValue];
                NSString * startY = [startYNumber stringValue];
                
                NSMutableDictionary * newFirstSegmentDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"M", @"command",
                        [startXNumber copy], @"absoluteX",
                        [startYNumber copy], @"absoluteY",
                        [startXNumber copy], @"absoluteStartX",
                        [startYNumber copy], @"absoluteStartY",
                        startX, @"x",
                        startY, @"y",
                        NULL];
                
                [newSegmentsArray addObject:newFirstSegmentDictionary];
                
                for (NSInteger i = -offset + 1; i <= lastSegmentIndex; i++)
                {
                    NSMutableDictionary * pathSegmentDictionary = [pathSegmentsArray objectAtIndex:i];
                    
                    NSMutableDictionary * newSegmentDictionary = [pathSegmentDictionary mutableCopy];

                    [newSegmentsArray addObject:newSegmentDictionary];
                }

                for (NSInteger i = 1; i <= -offset; i++)
                {
                    NSMutableDictionary * pathSegmentDictionary = [pathSegmentsArray objectAtIndex:i];
                    
                    NSMutableDictionary * newSegmentDictionary = [pathSegmentDictionary mutableCopy];

                    [newSegmentsArray addObject:newSegmentDictionary];
                }
                
                if (closePathFound == YES)
                {
                    NSMutableDictionary * closePathSegmentDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"Z", @"command",
                            NULL];
                    
                    [newSegmentsArray addObject:closePathSegmentDictionary];
                }

            }
            else if (offset > 0)
            {
                // right rotation
                
                NSInteger startSegmentIndex = lastSegmentIndex - offset;

                NSMutableDictionary * startSegmentDictionary = [pathSegmentsArray objectAtIndex:startSegmentIndex];
                NSNumber * startXNumber = [startSegmentDictionary objectForKey:@"absoluteX"];
                NSNumber * startYNumber = [startSegmentDictionary objectForKey:@"absoluteY"];
                
                NSString * startX = [startXNumber stringValue];
                NSString * startY = [startYNumber stringValue];
                
                NSMutableDictionary * newFirstSegmentDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"M", @"command",
                        [startXNumber copy], @"absoluteX",
                        [startYNumber copy], @"absoluteY",
                        [startXNumber copy], @"absoluteStartX",
                        [startYNumber copy], @"absoluteStartY",
                        startX, @"x",
                        startY, @"y",
                        NULL];
                
                [newSegmentsArray addObject:newFirstSegmentDictionary];
                
                for (NSInteger i = startSegmentIndex + 1; i <= lastSegmentIndex; i++)
                {
                    NSMutableDictionary * pathSegmentDictionary = [pathSegmentsArray objectAtIndex:i];

                    NSMutableDictionary * newSegmentDictionary = [pathSegmentDictionary mutableCopy];

                    [newSegmentsArray addObject:newSegmentDictionary];
                }

                for (NSInteger i = 1; i < lastSegmentIndex - offset + 1; i++)
                {
                    NSMutableDictionary * pathSegmentDictionary = [pathSegmentsArray objectAtIndex:i];
                    
                    NSMutableDictionary * newSegmentDictionary = [pathSegmentDictionary mutableCopy];

                    [newSegmentsArray addObject:newSegmentDictionary];
                }
                
                if (closePathFound == YES)
                {
                    NSMutableDictionary * closePathSegmentDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"Z", @"command",
                            NULL];
                    
                    [newSegmentsArray addObject:closePathSegmentDictionary];
                }
            }
            
            [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:newSegmentsArray];
        }
    }
    
    if (newSegmentsArray == NULL)
    {
        newSegmentsArray = pathSegmentsArray;   // rotation failed, but return the absolute path instead of original
    }
    
    return newSegmentsArray;
}


//==================================================================================
//	degreesToRadians()
//==================================================================================

CGFloat degreesToRadians(CGFloat degree)
{
    return (degree * M_PI) / 180;
}

//==================================================================================
//	radiansToDegrees()
//==================================================================================

CGFloat radiansToDegrees(CGFloat radians)
{
    return (radians * 180) / (M_PI);
}

//==================================================================================
//	convertArcToEndPointWithRotation:angleStart:angleExtent:
//==================================================================================

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
    NSNumber * isLargeNumber = @(isLarge);
    NSNumber * isCounterClockwiseNumber = @(isCounterClockwise);
    
    NSDictionary * resultDictionary = @{@"startX": startXNumber,
            @"startY": startYNumber,
            @"endX": endXNumber,
            @"endY": endYNumber,
            @"isLarge": isLargeNumber,
            @"isCounterClockwise": isCounterClockwiseNumber};
    
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

    NSDictionary * resultDictionary = @{@"angleStart": angleStartNumber,
            @"angleExtent": angleExtentNumber,
            @"cx": cxNumber,
            @"cy": cyNumber};
    
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
