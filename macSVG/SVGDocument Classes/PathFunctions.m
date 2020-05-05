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
#import "PathSegment.h"

@implementation PathFunctions

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

//==================================================================================
//	computeBoundsForPathSegmentsArray
//==================================================================================

- (NSRect)computeBoundsForPathSegmentsArray:(NSMutableArray *)pathSegmentsArray withControlPoints:(BOOL)withControlPoints
{
    NSRect resultRect = NSZeroRect;
    
    float xMin = FLT_MAX;
    float xMax = FLT_MIN;
    float yMin = FLT_MAX;
    float yMax = FLT_MIN;

    [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:pathSegmentsArray];
    
    for (PathSegment * pathSegment in pathSegmentsArray)
    {
        float absoluteStartXFloat = pathSegment.absoluteStartXFloat;
        float absoluteStartYFloat = pathSegment.absoluteStartYFloat;
        float absoluteXFloat = pathSegment.absoluteXFloat;
        float absoluteYFloat = pathSegment.absoluteYFloat;

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

        unichar commandCharacter = pathSegment.pathCommand;

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
                    float x1Float = pathSegment.absoluteX1Float;
                    float y1Float = pathSegment.absoluteY1Float;

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

                    float x2Float = pathSegment.absoluteX2Float;
                    float y2Float = pathSegment.absoluteY2Float;

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
                    float x2Float = pathSegment.absoluteX2Float;
                    float y2Float = pathSegment.absoluteY2Float;

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
                    float x1Float = pathSegment.absoluteX1Float;
                    float y1Float = pathSegment.absoluteY1Float;

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

    for (PathSegment * pathSegment in pathSegmentsArray)
    {
        float absoluteStartXFloat = pathSegment.absoluteStartXFloat;
        float absoluteStartYFloat = pathSegment.absoluteStartYFloat;

        unichar commandCharacter = pathSegment.pathCommand;

        switch (commandCharacter)
        {
            case 'M':     // moveto
                break;    // no changes required

            case 'm':     // moveto
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;
                
                pathSegment.pathCommand = 'M';
                break;
            }
            case 'L':     // lineto
            {
                break;    // no changes required
            }
            
            case 'l':     // lineto
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;
                
                pathSegment.pathCommand = 'L';
                break;
            }

            case 'H':     // horizontal lineto
                break;    // no changes required

            case 'h':     // horizontal lineto
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                pathSegment.pathCommand = 'H';
                break;
            }

            case 'V':     // vertical lineto
                break;    // no changes required

            case 'v':     // vertical lineto
            {
                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;
                
                pathSegment.pathCommand = 'V';
                break;
            }

            case 'C':     // curveto
                break;    // no changes required

            case 'c':     // curveto
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;

                NSString * x1String = pathSegment.x1String;
                float x1Float = x1String.floatValue;
                x1Float += absoluteStartXFloat;
                NSString * newX1String = [macSVGDocument allocFloatString:x1Float];
                pathSegment.x1String = newX1String;

                NSString * y1String = pathSegment.y1String;
                float y1Float = y1String.floatValue;
                y1Float += absoluteStartYFloat;
                NSString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegment.y1String = newY1String;

                NSString * x2String = pathSegment.x2String;
                float x2Float = x2String.floatValue;
                x2Float += absoluteStartXFloat;
                NSString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegment.x2String = newX2String;

                NSString * y2String = pathSegment.y2String;
                float y2Float = y2String.floatValue;
                y2Float += absoluteStartYFloat;
                NSString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegment.y2String = newY2String;
                
                pathSegment.pathCommand = 'C';
                break;
            }

            case 'S':     // smooth curveto
                break;    // no changes required

            case 's':     // smooth curveto
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;

                NSString * x2String = pathSegment.x2String;
                float x2Float = x2String.floatValue;
                x2Float += absoluteStartXFloat;
                NSString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegment.x2String = newX2String;

                NSString * y2String = pathSegment.y2String;
                float y2Float = y2String.floatValue;
                y2Float += absoluteStartYFloat;
                NSString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegment.y2String = newY2String;
                
                pathSegment.pathCommand = 'S';
                break;
            }

            case 'Q':     // quadratic Bezier curve
                break;    // no changes required

            case 'q':     // quadratic Bezier curve
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;

                NSString * x1String = pathSegment.x1String;
                float x1Float = x1String.floatValue;
                x1Float += absoluteStartXFloat;
                NSString * newX1String = [macSVGDocument allocFloatString:x1Float];
                pathSegment.x1String = newX1String;

                NSString * y1String = pathSegment.y1String;
                float y1Float = y1String.floatValue;
                y1Float += absoluteStartYFloat;
                NSString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegment.y1String = newY1String;

                pathSegment.pathCommand = 'Q';
                break;
            }

            case 'T':     // smooth quadratic Bezier curve
                break;    // no changes required

            case 't':     // smooth quadratic Bezier curve
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;

                pathSegment.pathCommand = 'T';
                break;
            }

            case 'A':     // elliptical arc
                break;    // no changes required

            case 'a':     // elliptical arc
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;

                pathSegment.pathCommand = 'A';
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
    PathSegment * previousSegment = NULL;
    NSInteger pathSegmentIndex = 0;
    CGPoint controlPoint = NSZeroPoint;

    for (PathSegment * pathSegment in pathSegmentsArray)
    {
        float absoluteStartXFloat = pathSegment.absoluteStartXFloat;
        float absoluteStartYFloat = pathSegment.absoluteStartYFloat;
        
        float absoluteXFloat = pathSegment.absoluteXFloat;
        float absoluteYFloat = pathSegment.absoluteYFloat;
        
        if (pathSegmentIndex == 0)
        {
            controlPoint = CGPointMake(absoluteStartXFloat, absoluteStartYFloat);
        }

        unichar commandCharacter = pathSegment.pathCommand;

        switch (commandCharacter)
        {
            case 'M':     // moveto
                break;    // no changes required

            case 'm':     // moveto
            {
                pathSegment.xFloat = pathSegment.absoluteXFloat;
                pathSegment.yFloat = pathSegment.absoluteYFloat;
                
                pathSegment.pathCommand = 'M';
                break;
            }
            case 'L':     // lineto
            {
                break;    // no changes required
            }
            
            case 'l':     // lineto
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;
                
                pathSegment.pathCommand = 'L';
                break;
            }

            case 'H':     // horizontal lineto
                break;    // no changes required

            case 'h':     // horizontal lineto
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                pathSegment.pathCommand = 'H';
                break;
            }

            case 'V':     // vertical lineto
                break;    // no changes required

            case 'v':     // vertical lineto
            {
                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;
                
                pathSegment.pathCommand = 'V';
                break;
            }

            case 'C':     // curveto
                break;    // no changes required

            case 'c':     // curveto
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;

                NSString * x1String = pathSegment.x1String;
                float x1Float = x1String.floatValue;
                x1Float += absoluteStartXFloat;
                NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                pathSegment.x1String = newX1String;

                NSString * y1String = pathSegment.y1String;
                float y1Float = y1String.floatValue;
                y1Float += absoluteStartYFloat;
                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegment.y1String = newY1String;

                NSString * x2String = pathSegment.x2String;
                float x2Float = x2String.floatValue;
                x2Float += absoluteStartXFloat;
                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegment.x2String = newX2String;

                NSString * y2String = pathSegment.y2String;
                float y2Float = y2String.floatValue;
                y2Float += absoluteStartYFloat;
                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegment.y2String = newY2String;
                
                pathSegment.pathCommand = 'C';
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
                        float previousAbsoluteX2Float = previousSegment.absoluteX2Float;
                        float previousAbsoluteY2Float = previousSegment.absoluteY2Float;
                        
                        float x1Float = absoluteStartXFloat + (absoluteStartXFloat - previousAbsoluteX2Float);
                        float y1Float = absoluteStartYFloat + (absoluteStartYFloat - previousAbsoluteY2Float);

                        //pathSegment.x1String = [self allocFloatString:x1Float];
                        //pathSegment.y1String = [self allocFloatString:y1Float];
                        
                        pathSegment.x1Float = x1Float;
                        pathSegment.y1Float = y1Float;
                        
                        pathSegment.absoluteX1Float = x1Float;
                        pathSegment.absoluteY1Float = y1Float;

                        break;
                    }
                    default:
                    {
                        NSMutableString * newX1String = [macSVGDocument allocFloatString:absoluteStartXFloat];
                        pathSegment.x1String = newX1String;

                        NSMutableString * newY1String = [macSVGDocument allocFloatString:absoluteStartYFloat];
                        pathSegment.y1String = newY1String;

                        pathSegment.absoluteX1Float = absoluteStartXFloat;
                        pathSegment.absoluteY1Float = absoluteStartYFloat;
                    }
                }

                float absoluteX2Float = pathSegment.absoluteX2Float;
                float absoluteY2Float = pathSegment.absoluteY2Float;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:absoluteX2Float];
                pathSegment.x2String = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:absoluteY2Float];
                pathSegment.y2String = newY2String;

                pathSegment.absoluteX1Float = absoluteX2Float;

                pathSegment.absoluteY1Float = absoluteY2Float;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                pathSegment.xString = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                pathSegment.yString = newYString;

                pathSegment.pathCommand = 'C';
                
                break;
            }


            case 'Q':     // quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
            {
                CGPoint currentPoint = CGPointMake(absoluteStartXFloat, absoluteStartYFloat);
                CGPoint targetPoint = CGPointMake(absoluteXFloat, absoluteYFloat);

                float oldAbsoluteX1Float = pathSegment.absoluteX1Float;    // quadratic x1,y1
                float oldAbsoluteY1Float = pathSegment.absoluteY1Float;

                controlPoint = CGPointMake(oldAbsoluteX1Float, oldAbsoluteY1Float);
                
                float x1Float = currentPoint.x - ((currentPoint.x - controlPoint.x) / 1.5f);
                float y1Float = currentPoint.y - ((currentPoint.y - controlPoint.y) / 1.5f);
                
                float x2Float = targetPoint.x - ((targetPoint.x - controlPoint.x) / 1.5f);
                float y2Float = targetPoint.y - ((targetPoint.y - controlPoint.y) / 1.5f);

                NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                pathSegment.x1String = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegment.y1String = newY1String;
                
                pathSegment.absoluteX1Float = x1Float;
                pathSegment.absoluteY1Float = y1Float;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegment.x2String = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegment.y2String = newY2String;
                
                pathSegment.absoluteX2Float = x2Float;
                pathSegment.absoluteY2Float = y2Float;

                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                pathSegment.xString = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                pathSegment.yString = newYString;

                pathSegment.pathCommand = 'C';
                
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

                float x1Float = point1.x;
                float y1Float = point1.y;
                
                float x2Float = point2.x;
                float y2Float = point2.y;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                pathSegment.x1String = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegment.y1String = newY1String;
                
                pathSegment.absoluteX1Float = x1Float;
                pathSegment.absoluteY1Float = y1Float;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegment.x2String = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegment.y2String = newY2String;
                
                pathSegment.absoluteX2Float = x2Float;
                pathSegment.absoluteY2Float = y2Float;

                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                pathSegment.xString = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                pathSegment.yString = newYString;

                pathSegment.pathCommand = 'C';
                
                break;
            }

            case 'A':     // elliptical arc
                break;    // no changes required

            case 'a':     // elliptical arc
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;

                pathSegment.pathCommand = 'A';
                break;
            }

            case 'Z':     // closepath
            case 'z':     // closepath
                break;
        }
        
        previousCommandCharacter = commandCharacter;
        previousSegment = pathSegment;
        
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
    PathSegment * previousSegment = NULL;
    NSInteger pathSegmentIndex = 0;
    CGPoint controlPoint = NSZeroPoint;

    for (PathSegment * pathSegment in pathSegmentsArray)
    {
        float absoluteStartXFloat = pathSegment.absoluteStartXFloat;
        float absoluteStartYFloat = pathSegment.absoluteStartYFloat;
        
        float absoluteXFloat = pathSegment.absoluteXFloat;
        float absoluteYFloat = pathSegment.absoluteYFloat;
        
        if (pathSegmentIndex == 0)
        {
            controlPoint = CGPointMake(absoluteStartXFloat, absoluteStartYFloat);
        }

        unichar commandCharacter = pathSegment.pathCommand;

        switch (commandCharacter)
        {
            case 'M':     // moveto
                break;    // no changes required

            case 'm':     // moveto
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;
                
                pathSegment.pathCommand = 'M';
                break;
            }
            case 'L':     // lineto
            {
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;

                pathSegment.x1String = xString;
                pathSegment.y1String = yString;
                pathSegment.x2String = xString;
                pathSegment.y2String = yString;
                
                pathSegment.pathCommand = 'C';

                break;
            }
            
            case 'l':     // lineto
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;

                pathSegment.x1String = newXString;
                pathSegment.y1String = newYString;
                pathSegment.x2String = newXString;
                pathSegment.y2String = newYString;
                
                pathSegment.pathCommand = 'C';
                break;
            }

            case 'H':     // horizontal lineto
            {
                NSString * xString = pathSegment.xString;
                NSString * yString = [macSVGDocument allocFloatString:absoluteStartYFloat];

                pathSegment.x1String = xString;
                pathSegment.y1String = yString;
                pathSegment.x2String = xString;
                pathSegment.y2String = yString;

                pathSegment.pathCommand = 'C';

                break;
            }

            case 'h':     // horizontal lineto
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = [macSVGDocument allocFloatString:absoluteStartYFloat];

                pathSegment.x1String = xString;
                pathSegment.y1String = yString;
                pathSegment.x2String = xString;
                pathSegment.y2String = yString;

                pathSegment.pathCommand = 'C';
                break;
            }

            case 'V':     // vertical lineto
            {
                NSString * xString = [macSVGDocument allocFloatString:absoluteStartXFloat];
                NSString * yString = pathSegment.yString;

                pathSegment.x1String = xString;
                pathSegment.y1String = yString;
                pathSegment.x2String = xString;
                pathSegment.y2String = yString;

                pathSegment.pathCommand = 'C';

                break;
            }

            case 'v':     // vertical lineto
            {
                NSString * xString = [macSVGDocument allocFloatString:absoluteStartXFloat];

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;
                
                pathSegment.x1String = xString;
                pathSegment.y1String = yString;
                pathSegment.x2String = xString;
                pathSegment.y2String = yString;

                pathSegment.pathCommand = 'C';

                break;
            }

            case 'C':     // curveto
                break;    // no changes required

            case 'c':     // curveto
            {
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;

                NSString * x1String = pathSegment.x1String;
                float x1Float = x1String.floatValue;
                x1Float += absoluteStartXFloat;
                NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                pathSegment.x1String = newX1String;

                NSString * y1String = pathSegment.y1String;
                float y1Float = y1String.floatValue;
                y1Float += absoluteStartYFloat;
                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegment.y1String = newY1String;

                NSString * x2String = pathSegment.x2String;
                float x2Float = x2String.floatValue;
                x2Float += absoluteStartXFloat;
                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegment.x2String = newX2String;

                NSString * y2String = pathSegment.y2String;
                float y2Float = y2String.floatValue;
                y2Float += absoluteStartYFloat;
                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegment.y2String = newY2String;
                
                pathSegment.pathCommand = 'C';
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
                        float previousAbsoluteX2Float = previousSegment.absoluteX2Float;
                        float previousAbsoluteY2Float = previousSegment.absoluteY2Float;
                        
                        float x1Float = absoluteStartXFloat + (absoluteStartXFloat - previousAbsoluteX2Float);
                        float y1Float = absoluteStartYFloat + (absoluteStartYFloat - previousAbsoluteY2Float);

                        NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                        pathSegment.x1String = newX1String;

                        NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                        pathSegment.y1String = newY1String;
                        
                        pathSegment.absoluteX1Float = x1Float;

                        pathSegment.absoluteY1Float = y1Float;

                        break;
                    }
                    default:
                    {
                        NSMutableString * newX1String = [macSVGDocument allocFloatString:absoluteStartXFloat];
                        pathSegment.x1String = newX1String;

                        NSMutableString * newY1String = [macSVGDocument allocFloatString:absoluteStartYFloat];
                        pathSegment.y1String = newY1String;

                        pathSegment.absoluteX1Float = absoluteStartXFloat;

                        pathSegment.absoluteY1Float = absoluteStartYFloat;
                    }
                }

                float absoluteX2Float = pathSegment.absoluteX2Float;
                float absoluteY2Float = pathSegment.absoluteY2Float;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:absoluteX2Float];
                pathSegment.x2String = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:absoluteY2Float];
                pathSegment.y2String = newY2String;

                pathSegment.absoluteX1Float = absoluteX2Float;

                pathSegment.absoluteY1Float = absoluteY2Float;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                pathSegment.xString = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                pathSegment.yString = newYString;

                pathSegment.pathCommand = 'C';
                
                break;
            }


            case 'Q':     // quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
            {
                CGPoint currentPoint = CGPointMake(absoluteStartXFloat, absoluteStartYFloat);
                CGPoint targetPoint = CGPointMake(absoluteXFloat, absoluteYFloat);

                float oldAbsoluteX1Float = pathSegment.absoluteX1Float;
                float oldAbsoluteY1Float = pathSegment.absoluteY1Float;

                controlPoint = CGPointMake(oldAbsoluteX1Float, oldAbsoluteY1Float);
                
                float x1Float = currentPoint.x - ((currentPoint.x - controlPoint.x) / 1.5f);
                float y1Float = currentPoint.y - ((currentPoint.y - controlPoint.y) / 1.5f);
                
                float x2Float = targetPoint.x - ((targetPoint.x - controlPoint.x) / 1.5f);
                float y2Float = targetPoint.y - ((targetPoint.y - controlPoint.y) / 1.5f);

                NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                pathSegment.x1String = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegment.y1String = newY1String;
                
                pathSegment.absoluteX1Float = x1Float;

                pathSegment.absoluteY1Float = y1Float;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegment.x2String = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegment.y2String = newY2String;
                
                pathSegment.absoluteX2Float = x2Float;

                pathSegment.absoluteY2Float = y2Float;

                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                pathSegment.xString = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                pathSegment.yString = newYString;

                pathSegment.pathCommand = 'C';
                
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

                float x1Float = point1.x;
                float y1Float = point1.y;
                
                float x2Float = point2.x;
                float y2Float = point2.y;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:x1Float];
                pathSegment.x1String = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:y1Float];
                pathSegment.y1String = newY1String;
                
                pathSegment.absoluteX1Float = x1Float;

                pathSegment.absoluteY1Float = y1Float;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:x2Float];
                pathSegment.x2String = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:y2Float];
                pathSegment.y2String = newY2String;
                
                pathSegment.absoluteX2Float = x2Float;

                pathSegment.absoluteY2Float = y2Float;

                NSMutableString * newXString = [macSVGDocument allocFloatString:absoluteXFloat];
                pathSegment.xString = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:absoluteYFloat];
                pathSegment.yString = newYString;

                pathSegment.pathCommand = 'C';
                
                break;
            }

            case 'A':     // elliptical arc
                // TODO: convert elliptical arc to cubic bezier?
                break;    // no changes required

            case 'a':     // elliptical arc
            {
                // TODO: convert elliptical arc to cubic bezier?
                NSString * xString = pathSegment.xString;
                float xFloat = xString.floatValue;
                xFloat += absoluteStartXFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                NSString * yString = pathSegment.yString;
                float yFloat = yString.floatValue;
                yFloat += absoluteStartYFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;

                pathSegment.pathCommand = 'A';
                break;
            }

            case 'Z':     // closepath
            case 'z':     // closepath
                break;
        }
        
        previousCommandCharacter = commandCharacter;
        previousSegment = pathSegment;
        
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

    for (PathSegment * pathSegment in pathSegmentsArray)
    {
        PathSegment * newPathSegment = [[PathSegment alloc] init];
        [newPathSegment copyValuesFromPathSegment:pathSegment];
        
        [resultArray addObject:newPathSegment];
    }
    
    return resultArray;
}

//==================================================================================
//	duplicatePathSegment
//==================================================================================

- (PathSegment *)duplicatePathSegment:(PathSegment *)pathSegment
{
    PathSegment * newPathSegment = [[PathSegment alloc] init];
    [newPathSegment copyValuesFromPathSegment:pathSegment];
    
    return newPathSegment;
}

//==================================================================================
//	reversePathWithPathSegmentsArray:
//==================================================================================

- (NSMutableArray *)reversePathWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:pathSegmentsArray];
    
    NSMutableArray * cubicPathSegmentsArray = [self copyPathSegmentsArray:pathSegmentsArray];
    cubicPathSegmentsArray = [self convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray:cubicPathSegmentsArray];
    NSMutableArray * reverseCubicsSegmentsArray = [NSMutableArray array];
    for (PathSegment * cubicPathSegment in cubicPathSegmentsArray)
    {
        PathSegment * newCubicPathSegment = [self duplicatePathSegment:cubicPathSegment];

        [reverseCubicsSegmentsArray insertObject:newCubicPathSegment atIndex:0];
    }

    // reverse sequence of input array
    NSMutableArray * reverseSegmentsArray = [NSMutableArray array];
    for (PathSegment * pathSegment in pathSegmentsArray)
    {
        PathSegment * newPathSegment = [self duplicatePathSegment:pathSegment];

        [reverseSegmentsArray insertObject:newPathSegment atIndex:0];
    }
    
    NSMutableArray * newPathSegmentsArray = [NSMutableArray array];

    NSInteger currentIndex = 0;
    
    unichar originalLastCommand = ' ';
    
    for (PathSegment * reversePathSegment in reverseSegmentsArray)
    {
        PathSegment * pathSegment = [[PathSegment alloc] init];
    
        float absoluteStartXFloat = reversePathSegment.absoluteStartXFloat;
        float absoluteStartYFloat = reversePathSegment.absoluteStartYFloat;
        float absoluteXFloat = reversePathSegment.absoluteXFloat;
        float absoluteYFloat = reversePathSegment.absoluteYFloat;
                
        float xFloat = pathSegment.xFloat;
        float yFloat = pathSegment.yFloat;

        pathSegment.pathCommand = reversePathSegment.pathCommand;;
        
        unichar commandCharacter = pathSegment.pathCommand;

        if (currentIndex == 0)
        {
            originalLastCommand = commandCharacter;

            NSPoint reverseOriginPoint = [self.macSVGDocumentWindowController.svgWebKitController
                    endPointForSegmentIndex:0 pathSegmentsArray:reverseSegmentsArray];
            
            PathSegment * movetoPathSegment = [[PathSegment alloc] init];
            
            movetoPathSegment.pathCommand = 'M';
            movetoPathSegment.xFloat = reverseOriginPoint.x;
            movetoPathSegment.yFloat = reverseOriginPoint.y;
                        
            [newPathSegmentsArray addObject:movetoPathSegment];
        }
        
        // some path segments must be changed to standard cubic curves for accurate reversal
        switch (commandCharacter)
        {
            case 'S':     // absolute smooth cubic curve
            {
                // change smooth cubic curve to cubic curve
                commandCharacter = 'C';
                pathSegment.pathCommand = commandCharacter;

                float absoluteX1Float = absoluteStartXFloat;
                float absoluteY1Float = absoluteStartYFloat;
                
                if (currentIndex < reverseSegmentsArray.count)
                {
                    PathSegment * nextReversePathSegment =
                            reverseSegmentsArray[(currentIndex + 1)];
                    
                    float nextAbsoluteX2Float = nextReversePathSegment.absoluteX2Float;
                    float nextAbsoluteY2Float = nextReversePathSegment.absoluteY2Float;
                    
                    float absoluteX1 = absoluteStartXFloat + (absoluteStartXFloat - nextAbsoluteX2Float);
                    float absoluteY1 = absoluteStartYFloat + (absoluteStartYFloat - nextAbsoluteY2Float);
                    
                    absoluteX1Float = absoluteX1;
                    absoluteY1Float = absoluteY1;
                }
                
                reversePathSegment.x1Float = absoluteX1Float;
                reversePathSegment.y1Float = absoluteY1Float;
                
                break;
            }
            case 's':     // relative smooth cubic curve
            {
                // change smooth cubic curve to cubic curve
                commandCharacter = 'C';
                pathSegment.pathCommand = commandCharacter;

                float absoluteX1Float = absoluteStartXFloat;
                float absoluteY1Float = absoluteStartYFloat;
                
                if (currentIndex < reverseSegmentsArray.count)
                {
                    PathSegment * nextReversePathSegment =
                            reverseSegmentsArray[(currentIndex + 1)];
                    
                    float nextAbsoluteX2Float = nextReversePathSegment.absoluteX2Float;
                    float nextAbsoluteY2Float = nextReversePathSegment.absoluteY2Float;
                
                    float absoluteX1 = absoluteStartXFloat + (absoluteStartXFloat - nextAbsoluteX2Float);
                    float absoluteY1 = absoluteStartYFloat + (absoluteStartYFloat - nextAbsoluteY2Float);
                    
                    absoluteX1Float = absoluteX1;
                    absoluteY1Float = absoluteY1;
                }
                
                reversePathSegment.x1Float = absoluteX1Float;
                reversePathSegment.y1Float = absoluteY1Float;

                reversePathSegment.xFloat = absoluteXFloat;
                reversePathSegment.yFloat = absoluteYFloat;

                float absoluteX2Float = reversePathSegment.absoluteX2Float;
                float absoluteY2Float = reversePathSegment.absoluteY2Float;
                                
                reversePathSegment.x2Float = absoluteX2Float;
                reversePathSegment.y2Float = absoluteY2Float;
                
                break;
            }
            case 'Q':     // absolute quadratic curve
            {
                // change quadratic curve to cubic curve
                commandCharacter = 'C';
                pathSegment.pathCommand = commandCharacter;

                float absoluteX1Float = reversePathSegment.absoluteX1Float;
                float absoluteY1Float = reversePathSegment.absoluteY1Float;
                
                float newAbsoluteX1Float = absoluteStartXFloat - ((absoluteStartXFloat - absoluteX1Float) / 1.5f);
                float newAbsoluteY1Float = absoluteStartYFloat - ((absoluteStartYFloat - absoluteY1Float) / 1.5f);
                float newAbsoluteX2Float = absoluteXFloat - ((absoluteXFloat - absoluteX1Float) / 1.5f);
                float newAbsoluteY2Float = absoluteYFloat - ((absoluteYFloat - absoluteY1Float) / 1.5f);
                                
                reversePathSegment.x1Float = newAbsoluteX1Float;
                reversePathSegment.y1Float = newAbsoluteY1Float;
                reversePathSegment.x2Float = newAbsoluteX2Float;
                reversePathSegment.y2Float = newAbsoluteY2Float;
                
                break;
            }
            case 'q':     // relative quadratic curve
            {
                // change quadratic curve to cubic curve
                commandCharacter = 'C';
                pathSegment.pathCommand = commandCharacter;

                float absoluteX1Float = reversePathSegment.absoluteX1Float;
                float absoluteY1Float = reversePathSegment.absoluteY1Float;
                
                float newAbsoluteX1Float = absoluteStartXFloat - ((absoluteStartXFloat - absoluteX1Float) / 1.5f);
                float newAbsoluteY1Float = absoluteStartYFloat - ((absoluteStartYFloat - absoluteY1Float) / 1.5f);
                float newAbsoluteX2Float = absoluteXFloat - ((absoluteXFloat - absoluteX1Float) / 1.5f);
                float newAbsoluteY2Float = absoluteYFloat - ((absoluteYFloat - absoluteY1Float) / 1.5f);
                
                reversePathSegment.x1Float = newAbsoluteX1Float;
                reversePathSegment.y1Float = newAbsoluteY1Float;
                reversePathSegment.x2Float = newAbsoluteX2Float;
                reversePathSegment.y2Float = newAbsoluteY2Float;
                
                break;
            }
            case 'T':     // absolute smooth quadratic curve
            {
                // change quadratic curve to cubic curve
                commandCharacter = 'C';
                pathSegment.pathCommand = commandCharacter;
                
                PathSegment * cubicPathSegment = reverseCubicsSegmentsArray[currentIndex];

                float cubicAbsoluteStartX = cubicPathSegment.absoluteStartXFloat;
                float cubicAbsoluteStartY = cubicPathSegment.absoluteStartYFloat;
                float cubicAbsoluteX = cubicPathSegment.absoluteXFloat;
                float cubicAbsoluteY = cubicPathSegment.absoluteYFloat;
                float cubicAbsoluteX1 = cubicPathSegment.absoluteX1Float;
                float cubicAbsoluteY1 = cubicPathSegment.absoluteY1Float;
                float cubicAbsoluteX2 = cubicPathSegment.absoluteX2Float;
                float cubicAbsoluteY2 = cubicPathSegment.absoluteY2Float;
                
                float cubicX1Float = cubicPathSegment.x1Float;
                float cubicY1Float = cubicPathSegment.y1Float;
                float cubicX2Float = cubicPathSegment.x2Float;
                float cubicY2Float = cubicPathSegment.y2Float;
                
                // reverse the endpoint of the cubic bezier for the new segment
                
                PathSegment * newPathSegment = [[PathSegment alloc] init];
                
                newPathSegment.absoluteStartXFloat = cubicAbsoluteX;
                newPathSegment.absoluteStartYFloat = cubicAbsoluteY;
                newPathSegment.absoluteXFloat = cubicAbsoluteStartX;
                newPathSegment.absoluteYFloat = cubicAbsoluteStartY;
                
                newPathSegment.absoluteX1Float = cubicAbsoluteX1;
                newPathSegment.absoluteY1Float = cubicAbsoluteY1;
                newPathSegment.absoluteX2Float = cubicAbsoluteX2;
                newPathSegment.absoluteY2Float = cubicAbsoluteY2;
                
                newPathSegment.xFloat = cubicAbsoluteStartX;
                newPathSegment.yFloat = cubicAbsoluteStartY;
                newPathSegment.x1Float = cubicX1Float;
                newPathSegment.y1Float = cubicY1Float;
                newPathSegment.x2Float = cubicX2Float;
                newPathSegment.y2Float = cubicY2Float;

                [reversePathSegment copyValuesFromPathSegment:newPathSegment];

                break;
            }
            case 't':     // absolute smooth quadratic curve
            {
                commandCharacter = 'C';
                pathSegment.pathCommand = commandCharacter;
                
                PathSegment * cubicPathSegment = reverseCubicsSegmentsArray[currentIndex];

                float cubicAbsoluteStartX = cubicPathSegment.absoluteStartXFloat;
                float cubicAbsoluteStartY = cubicPathSegment.absoluteStartYFloat;
                float cubicAbsoluteX = cubicPathSegment.absoluteXFloat;
                float cubicAbsoluteY = cubicPathSegment.absoluteYFloat;
                float cubicAbsoluteX1 = cubicPathSegment.absoluteX1Float;
                float cubicAbsoluteY1 = cubicPathSegment.absoluteY1Float;
                float cubicAbsoluteX2 = cubicPathSegment.absoluteX2Float;
                float cubicAbsoluteY2 = cubicPathSegment.absoluteY2Float;
                
                float cubicX1Float = cubicPathSegment.x1Float;
                float cubicY1Float = cubicPathSegment.y1Float;
                float cubicX2Float = cubicPathSegment.x2Float;
                float cubicY2Float = cubicPathSegment.y2Float;
                
                // reverse the endpoint of the cubic bezier for the new segment
                
                PathSegment * newPathSegment = [[PathSegment alloc] init];
                
                newPathSegment.absoluteStartXFloat = cubicAbsoluteX;
                newPathSegment.absoluteStartYFloat = cubicAbsoluteY;
                newPathSegment.absoluteXFloat = cubicAbsoluteStartX;
                newPathSegment.absoluteYFloat = cubicAbsoluteStartY;
                
                newPathSegment.absoluteX1Float = cubicAbsoluteX1;
                newPathSegment.absoluteY1Float = cubicAbsoluteY1;
                newPathSegment.absoluteX2Float = cubicAbsoluteX2;
                newPathSegment.absoluteY2Float = cubicAbsoluteY2;
                
                newPathSegment.xFloat = cubicAbsoluteStartX;
                newPathSegment.yFloat = cubicAbsoluteStartX;
                newPathSegment.x1Float = cubicX1Float;
                newPathSegment.y1Float = cubicY1Float;
                newPathSegment.x2Float = cubicX2Float;
                newPathSegment.y2Float = cubicY2Float;

                [reversePathSegment copyValuesFromPathSegment:newPathSegment];

                break;
            }
        }

        
        switch (commandCharacter)
        {
            case 'M':     // moveto
            {
                pathSegment.xFloat = absoluteStartXFloat;
                pathSegment.yFloat = absoluteStartYFloat;
                
                break;
            }

            case 'm':     // moveto
            {
                xFloat = -xFloat;
                pathSegment.xFloat = xFloat;

                yFloat = -yFloat;
                pathSegment.yFloat = yFloat;
                
                break;
            }
            case 'L':     // lineto
            {
                pathSegment.xFloat = absoluteStartXFloat;
                pathSegment.yFloat = absoluteStartYFloat;

                break;
            }
            
            case 'l':     // lineto
            {
                xFloat = -xFloat;
                pathSegment.xFloat = xFloat;

                yFloat = -yFloat;
                pathSegment.yFloat = yFloat;
                
                break;
            }

            case 'H':     // horizontal lineto
            {
                pathSegment.xFloat = absoluteStartXFloat;
                
                break;
            }

            case 'h':     // horizontal lineto
            {
                xFloat = -xFloat;
                pathSegment.xFloat = xFloat;
                
                break;
            }

            case 'V':     // vertical lineto
            {
                pathSegment.yFloat = absoluteStartYFloat;
                
                break;
            }
            
            case 'v':     // vertical lineto
            {
                yFloat = -yFloat;
                pathSegment.yFloat = yFloat;

                break;
            }

            case 'C':     // curveto
            {
                pathSegment.xFloat = absoluteStartXFloat;
                pathSegment.yFloat = absoluteStartYFloat;
                
                pathSegment.x1Float = reversePathSegment.x2Float;
                pathSegment.y1Float = reversePathSegment.y2Float;
                pathSegment.x2Float = reversePathSegment.x1Float;
                pathSegment.y2Float = reversePathSegment.y1Float;

                break;
            }

            case 'c':     // curveto
            {
                xFloat = -xFloat;
                pathSegment.xFloat = xFloat;

                yFloat = -yFloat;
                pathSegment.yFloat = yFloat;
                
                float x1Float = reversePathSegment.x1Float;
                float y1Float = reversePathSegment.y1Float;
                float x2Float = reversePathSegment.x2Float;
                float y2Float = reversePathSegment.y2Float;
                
                x1Float = -x1Float;
                y1Float = -y1Float;
                x2Float = -x2Float;
                y2Float = -y2Float;
                
                pathSegment.x1Float = x2Float;
                pathSegment.y1Float = y2Float;
                pathSegment.x2Float = x1Float;
                pathSegment.y2Float = y1Float;

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
                pathSegment.xFloat = absoluteStartXFloat;
                pathSegment.yFloat = absoluteStartYFloat;

                float rxFloat = reversePathSegment.rxFloat;
                float ryFloat = reversePathSegment.ryFloat;
                float xAxisRotationFloat = reversePathSegment.xAxisRotationFloat;
                BOOL largeArcFlagBool = reversePathSegment.largeArcFlagBool;
                BOOL sweepFlagBool = reversePathSegment.sweepFlagBool;
                
                sweepFlagBool = !sweepFlagBool;
                
                pathSegment.rxFloat = rxFloat;
                pathSegment.ryFloat = ryFloat;
                pathSegment.xAxisRotationFloat = xAxisRotationFloat;
                pathSegment.largeArcFlagBool = largeArcFlagBool;
                pathSegment.sweepFlagBool = sweepFlagBool;

                break;
            }
            case 'a':     // elliptical arc
            {
                xFloat = -xFloat;
                pathSegment.xFloat = xFloat;

                yFloat = -yFloat;
                pathSegment.yFloat = yFloat;

                float rxFloat = reversePathSegment.rxFloat;
                float ryFloat = reversePathSegment.ryFloat;
                float xAxisRotationFloat = reversePathSegment.xAxisRotationFloat;
                BOOL largeArcFlagBool = reversePathSegment.largeArcFlagBool;
                BOOL sweepFlagBool = reversePathSegment.sweepFlagBool;

                sweepFlagBool = !sweepFlagBool;
                
                pathSegment.rxFloat = rxFloat;
                pathSegment.ryFloat = ryFloat;
                pathSegment.xAxisRotationFloat = xAxisRotationFloat;
                pathSegment.largeArcFlagBool = largeArcFlagBool;
                pathSegment.sweepFlagBool = sweepFlagBool;

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
                [newPathSegmentsArray addObject:pathSegment];
            }
        }
        else if (currentIndex >= reverseSegmentsArray.count - 1)
        {
            if ((commandCharacter != 'M') && (commandCharacter != 'm'))
            {
                [newPathSegmentsArray addObject:pathSegment];
            }
        }
        else
        {
            [newPathSegmentsArray addObject:pathSegment];
        }
        
        currentIndex++;
    }
    
    if ((originalLastCommand == 'Z') || (originalLastCommand == 'z'))
    {
        PathSegment * closePathSegment = [[PathSegment alloc] init];
        
        closePathSegment.pathCommand = originalLastCommand;
        
        [newPathSegmentsArray addObject:closePathSegment];
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
    for (PathSegment * pathSegment in pathSegmentsArray)
    {
        PathSegment * newPathSegment = [self duplicatePathSegment:pathSegment];

        [reverseSegmentsArray insertObject:newPathSegment atIndex:0];
    }

    NSMutableArray * cubicPathSegmentsArray = [self copyPathSegmentsArray:pathSegmentsArray];
    cubicPathSegmentsArray = [self convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray:cubicPathSegmentsArray];
    NSMutableArray * reverseCubicsSegmentsArray = [NSMutableArray array];
    for (PathSegment * cubicPathSegment in cubicPathSegmentsArray)
    {
        PathSegment * newCubicPathSegment = [self duplicatePathSegment:cubicPathSegment];

        [reverseCubicsSegmentsArray insertObject:newCubicPathSegment atIndex:0];
    }

    NSInteger lastIndex = pathSegmentsArray.count - 1;
    
    NSPoint reverseOriginPoint = [self.macSVGDocumentWindowController.svgWebKitController
            endPointForSegmentIndex:lastIndex pathSegmentsArray:pathSegmentsArray];
    
    NSInteger currentIndex = 0;
    
    for (PathSegment * pathSegment in reverseSegmentsArray)
    {
        MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
        
        float absoluteStartXFloat = pathSegment.absoluteStartXFloat;
        float absoluteStartYFloat = pathSegment.absoluteStartYFloat;

        NSPoint originalCurrentPoint = [self.macSVGDocumentWindowController.svgWebKitController
                endPointForSegmentIndex:(lastIndex - currentIndex)
                pathSegmentsArray:pathSegmentsArray];
        
        float currentXDelta = originalCurrentPoint.x - reverseOriginPoint.x;
        
        NSPoint currentPoint = NSMakePoint(originalCurrentPoint.x - currentXDelta, originalCurrentPoint.y);
        
        unichar commandCharacter = pathSegment.pathCommand;
        
        switch (commandCharacter)
        {
            case 'M':     // moveto
            {
                float deltaX = currentPoint.x - absoluteStartXFloat;
                
                float newXFloat = currentPoint.x + deltaX;
                float newYFloat = absoluteStartYFloat;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegment.xString = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegment.yString = newYString;
                
                break;
            }

            case 'm':     // moveto
            {
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;

                float xFloat = xString.floatValue;
                float yFloat = yString.floatValue;

                xFloat = -xFloat;
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                yFloat = -yFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;
                
                break;
            }
            case 'L':     // lineto
            {
                float deltaX = currentPoint.x - absoluteStartXFloat;
                
                float newXFloat = currentPoint.x + deltaX;
                float newYFloat = absoluteStartYFloat;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegment.xString = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegment.yString = newYString;

                break;
            }
            
            case 'l':     // lineto
            {
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;
                
                float xFloat = xString.floatValue;
                float yFloat = yString.floatValue;

                float newXFloat = xFloat;
                float newYFloat = -yFloat;

                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegment.xString = newXString;

                yFloat = -yFloat;
                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegment.yString = newYString;
                
                break;
            }

            case 'H':     // horizontal lineto
            {
                float deltaX = currentPoint.x - absoluteStartXFloat;
                
                float newXFloat = currentPoint.x + deltaX;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegment.xString = newXString;

                
                break;
            }

            case 'h':     // horizontal lineto
            {
                NSString * xString = pathSegment.xString;
                
                float xFloat = xString.floatValue;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;
                
                break;
            }

            case 'V':     // vertical lineto
            {
                NSString * yString = pathSegment.yString;
                
                float yFloat = yString.floatValue;
                
                float yDelta = absoluteStartYFloat - yFloat;
                yFloat = currentPoint.y + yDelta;
                NSMutableString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;
                
                break;
            }
            
            case 'v':     // vertical lineto
            {
                NSString * yString = pathSegment.yString;
                
                float yFloat = yString.floatValue;
                
                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;

                break;
            }

            case 'C':     // curveto
            {
                NSString * x1String = pathSegment.x1String;
                NSString * y1String = pathSegment.y1String;
                NSString * x2String = pathSegment.x2String;
                NSString * y2String = pathSegment.y2String;
                
                float x1Float = x1String.floatValue;
                float y1Float = y1String.floatValue;
                float x2Float = x2String.floatValue;
                float y2Float = y2String.floatValue;
                
                float deltaX = currentPoint.x - absoluteStartXFloat;
                float deltaX1 = currentPoint.x - x2Float;
                float deltaX2 = currentPoint.x - x1Float;
                
                float newXFloat = currentPoint.x + deltaX;
                float newYFloat = absoluteStartYFloat;
                float newX1Float = currentPoint.x + deltaX1;
                float newY1Float = y2Float;
                float newX2Float = currentPoint.x + deltaX2;
                float newY2Float = y1Float;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegment.xString = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegment.yString = newYString;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegment.x1String = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegment.y1String = newY1String;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegment.x2String = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegment.y2String = newY2String;

                break;
            }

            case 'c':     // curveto
            {
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;
                NSString * x1String = pathSegment.x1String;
                NSString * y1String = pathSegment.y1String;
                NSString * x2String = pathSegment.x2String;
                NSString * y2String = pathSegment.y2String;
                
                float xFloat = xString.floatValue;
                float yFloat = yString.floatValue;
                float x1Float = x1String.floatValue;
                float y1Float = y1String.floatValue;
                float x2Float = x2String.floatValue;
                float y2Float = y2String.floatValue;
                
                //float deltaX = currentPoint.x - absoluteStartXFloat;
                float deltaX1 = currentPoint.x - x2Float;
                float deltaX2 = currentPoint.x - x1Float;
                
                float newXFloat = xFloat;
                float newYFloat = -yFloat;
                float newX1Float = currentPoint.x + deltaX1;
                float newY1Float = y2Float;
                float newX2Float = currentPoint.x + deltaX2;
                float newY2Float = y1Float;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegment.xString = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegment.yString = newYString;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegment.x1String = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegment.y1String = newY1String;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegment.x2String = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegment.y2String = newY2String;

                break;
            }

            case 'S':     // smooth curveto
            case 's':     // smooth curveto
            {
                // Convert this segment to an absolute cubic curve
                PathSegment * cubicPathSegment = reverseCubicsSegmentsArray[currentIndex];

                NSString * x1String = cubicPathSegment.x1String;
                NSString * y1String = cubicPathSegment.y1String;
                NSString * x2String = cubicPathSegment.x2String;
                NSString * y2String = cubicPathSegment.y2String;
                
                float x1Float = x1String.floatValue;
                float y1Float = y1String.floatValue;
                float x2Float = x2String.floatValue;
                float y2Float = y2String.floatValue;
                
                float deltaX = currentPoint.x - absoluteStartXFloat;
                float deltaX1 = currentPoint.x - x2Float;
                float deltaX2 = currentPoint.x - x1Float;
                
                float newXFloat = currentPoint.x + deltaX;
                float newYFloat = absoluteStartYFloat;
                float newX1Float = currentPoint.x + deltaX1;
                float newY1Float = y2Float;
                float newX2Float = currentPoint.x + deltaX2;
                float newY2Float = y1Float;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegment.xString = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegment.yString = newYString;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegment.x1String = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegment.y1String = newY1String;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegment.x2String = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegment.y2String = newY2String;
                
                pathSegment.pathCommand = 'C';

                break;
            }


            case 'Q':     // quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
            {
                // Convert this segment to an absolute cubic curve
                PathSegment * cubicPathSegment = reverseCubicsSegmentsArray[currentIndex];

                NSString * x1String = cubicPathSegment.x1String;
                NSString * y1String = cubicPathSegment.y1String;
                NSString * x2String = cubicPathSegment.x2String;
                NSString * y2String = cubicPathSegment.y2String;
                
                float x1Float = x1String.floatValue;
                float y1Float = y1String.floatValue;
                float x2Float = x2String.floatValue;
                float y2Float = y2String.floatValue;
                
                float deltaX = currentPoint.x - absoluteStartXFloat;
                float deltaX1 = currentPoint.x - x2Float;
                float deltaX2 = currentPoint.x - x1Float;
                
                float newXFloat = currentPoint.x + deltaX;
                float newYFloat = absoluteStartYFloat;
                float newX1Float = currentPoint.x + deltaX1;
                float newY1Float = y2Float;
                float newX2Float = currentPoint.x + deltaX2;
                float newY2Float = y1Float;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegment.xString = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegment.yString = newYString;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegment.x1String = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegment.y1String = newY1String;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegment.x2String = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegment.y2String = newY2String;
                
                pathSegment.pathCommand = 'C';

                break;
            }


            case 'T':     // smooth quadratic Bezier curve
            case 't':     // smooth quadratic Bezier curve
            {
                // Convert this segment to an absolute cubic curve
                PathSegment * cubicPathSegment = reverseCubicsSegmentsArray[currentIndex];

                NSString * x1String = cubicPathSegment.x1String;
                NSString * y1String = cubicPathSegment.y1String;
                NSString * x2String = cubicPathSegment.x2String;
                NSString * y2String = cubicPathSegment.y2String;
                
                float x1Float = x1String.floatValue;
                float y1Float = y1String.floatValue;
                float x2Float = x2String.floatValue;
                float y2Float = y2String.floatValue;
                
                float deltaX = currentPoint.x - absoluteStartXFloat;
                float deltaX1 = currentPoint.x - x2Float;
                float deltaX2 = currentPoint.x - x1Float;
                
                float newXFloat = currentPoint.x + deltaX;
                float newYFloat = absoluteStartYFloat;
                float newX1Float = currentPoint.x + deltaX1;
                float newY1Float = y2Float;
                float newX2Float = currentPoint.x + deltaX2;
                float newY2Float = y1Float;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegment.xString = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegment.yString = newYString;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegment.x1String = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegment.y1String = newY1String;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegment.x2String = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegment.y2String = newY2String;
                
                pathSegment.pathCommand = 'C';

                break;
            }



            case 'A':     // elliptical arc
            {
                float deltaX = currentPoint.x - absoluteStartXFloat;
                
                float newXFloat = currentPoint.x + deltaX;
                float newYFloat = absoluteStartYFloat;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegment.xString = newXString;

                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegment.yString = newYString;

                break;
            }
            case 'a':     // elliptical arc
            {
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;
                
                float xFloat = xString.floatValue;
                float yFloat = yString.floatValue;
                
                xFloat = -xFloat;
                NSString * newXString = [macSVGDocument allocFloatString:xFloat];
                pathSegment.xString = newXString;

                yFloat = -yFloat;
                NSString * newYString = [macSVGDocument allocFloatString:yFloat];
                pathSegment.yString = newYString;

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
    for (PathSegment * pathSegment in pathSegmentsArray)
    {
        PathSegment * newPathSegment = [self duplicatePathSegment:pathSegment];

        [reverseSegmentsArray insertObject:newPathSegment atIndex:0];
    }

    NSMutableArray * cubicPathSegmentsArray = [self copyPathSegmentsArray:pathSegmentsArray];
    cubicPathSegmentsArray = [self convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray:cubicPathSegmentsArray];
    NSMutableArray * reverseCubicsSegmentsArray = [NSMutableArray array];
    for (PathSegment * cubicPathSegment in cubicPathSegmentsArray)
    {
        PathSegment * newCubicSegment = [self duplicatePathSegment:cubicPathSegment];

        [reverseCubicsSegmentsArray insertObject:newCubicSegment atIndex:0];
    }

    NSInteger lastIndex = pathSegmentsArray.count - 1;
    
    NSPoint reverseOriginPoint = [self.macSVGDocumentWindowController.svgWebKitController
            endPointForSegmentIndex:lastIndex pathSegmentsArray:pathSegmentsArray];
    
    NSInteger currentIndex = 0;
    
    for (PathSegment * pathSegment in reverseSegmentsArray)
    {
        MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
        
        float absoluteStartXFloat = pathSegment.absoluteStartXFloat;
        float absoluteStartYFloat = pathSegment.absoluteStartYFloat;

        NSPoint originalCurrentPoint = [self.macSVGDocumentWindowController.svgWebKitController
                endPointForSegmentIndex:(lastIndex - currentIndex)
                pathSegmentsArray:pathSegmentsArray];
        
        float currentYDelta = originalCurrentPoint.y - reverseOriginPoint.y;
        
        NSPoint currentPoint = NSMakePoint(originalCurrentPoint.x, originalCurrentPoint.y - currentYDelta);
        
        unichar commandCharacter = pathSegment.pathCommand;
        
        switch (commandCharacter)
        {
            case 'M':     // moveto
            {
                float deltaY = currentPoint.y - absoluteStartYFloat;
                pathSegment.yFloat = currentPoint.y + deltaY;
                break;
            }

            case 'm':     // moveto
            {
                float xFloat = pathSegment.xFloat;
                pathSegment.xFloat = -xFloat;
                break;
            }
            case 'L':     // lineto
            {
                float deltaX = currentPoint.x - absoluteStartXFloat;
                float deltaY = currentPoint.y - absoluteStartYFloat;
                
                float newXFloat = currentPoint.x - deltaX;
                float newYFloat = currentPoint.y + deltaY;

                pathSegment.xFloat = newXFloat;
                pathSegment.yFloat = newYFloat;

                break;
            }
            
            case 'l':     // lineto
            {
                float xFloat = pathSegment.xFloat;
                pathSegment.xFloat = -xFloat;
                
                break;
            }

            case 'H':     // horizontal lineto
            {
                float deltaX = currentPoint.x - absoluteStartXFloat;
                float newXFloat = currentPoint.x - deltaX;
                pathSegment.xFloat = newXFloat;

                break;
            }

            case 'h':     // horizontal lineto
            {
                float xFloat = pathSegment.xFloat;
                pathSegment.xFloat = -xFloat;

                break;
            }

            case 'V':     // vertical lineto
            {
                //float yFloat = pathSegment.yFloat;
                //float yDelta = absoluteStartYFloat - yFloat;
                //yFloat = currentPoint.y + yDelta;
                //pathSegment.yFloat = yFloat;

                float deltaY = currentPoint.y - absoluteStartYFloat;
                float newYFloat = currentPoint.y + deltaY;
                pathSegment.yFloat = newYFloat;

                break;
            }
            
            case 'v':     // vertical lineto
            {
                break;
            }

            case 'C':     // curveto
            {
                float x1Float = pathSegment.x1Float;
                float y1Float = pathSegment.y1Float;
                float x2Float = pathSegment.x2Float;
                float y2Float = pathSegment.y2Float;
                
                float deltaY = currentPoint.y - absoluteStartYFloat;
                float deltaY1 = currentPoint.y - y2Float;
                float deltaY2 = currentPoint.y - y1Float;
                
                float newXFloat = absoluteStartXFloat;
                float newYFloat = currentPoint.y + deltaY;
                float newX1Float = x2Float;
                float newY1Float = currentPoint.y + deltaY1;
                float newX2Float = x1Float;
                float newY2Float = currentPoint.y + deltaY2;
                
                pathSegment.xFloat = newXFloat;
                pathSegment.yFloat = newYFloat;
                pathSegment.x1Float = newX1Float;
                pathSegment.y1Float = newY1Float;
                pathSegment.x2Float = newX2Float;
                pathSegment.y2Float = newY2Float;

                break;
            }

            case 'c':     // curveto
            {
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;
                NSString * x1String = pathSegment.x1String;
                NSString * y1String = pathSegment.y1String;
                NSString * x2String = pathSegment.x2String;
                NSString * y2String = pathSegment.y2String;
                
                float xFloat = xString.floatValue;
                float yFloat = yString.floatValue;
                float x1Float = x1String.floatValue;
                float y1Float = y1String.floatValue;
                float x2Float = x2String.floatValue;
                float y2Float = y2String.floatValue;
                
                float deltaX1 = currentPoint.x - x2Float;
                float deltaX2 = currentPoint.x - x1Float;
                
                float newXFloat = xFloat;
                float newYFloat = -yFloat;
                float newX1Float = currentPoint.x + deltaX1;
                float newY1Float = y2Float;
                float newX2Float = currentPoint.x + deltaX2;
                float newY2Float = y1Float;
                
                NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegment.xString = newXString;

                NSString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegment.yString = newYString;

                NSString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegment.x1String = newX1String;

                NSString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegment.y1String = newY1String;

                NSString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegment.x2String = newX2String;

                NSString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegment.y2String = newY2String;

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
                PathSegment * cubicPathSegment = reverseCubicsSegmentsArray[currentIndex];

                NSString * x1String = cubicPathSegment.x1String;
                NSString * y1String = cubicPathSegment.y1String;
                NSString * x2String = cubicPathSegment.x2String;
                NSString * y2String = cubicPathSegment.y2String;
                
                float x1Float = x1String.floatValue;
                float y1Float = y1String.floatValue;
                float x2Float = x2String.floatValue;
                float y2Float = y2String.floatValue;
                
                float deltaY = currentPoint.y - absoluteStartYFloat;
                float deltaY1 = currentPoint.y - y2Float;
                float deltaY2 = currentPoint.y - y1Float;
                
                float newXFloat = absoluteStartXFloat;
                float newYFloat = currentPoint.y + deltaY;
                float newX1Float = x2Float;
                float newY1Float = currentPoint.y + deltaY1;
                float newX2Float = x1Float;
                float newY2Float = currentPoint.y + deltaY2;
                
                NSMutableString * newXString = [macSVGDocument allocFloatString:newXFloat];
                pathSegment.xString = newXString;

                NSMutableString * newYString = [macSVGDocument allocFloatString:newYFloat];
                pathSegment.yString = newYString;

                NSMutableString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                pathSegment.x1String = newX1String;

                NSMutableString * newY1String = [macSVGDocument allocFloatString:newY1Float];
                pathSegment.y1String = newY1String;

                NSMutableString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                pathSegment.x2String = newX2String;

                NSMutableString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                pathSegment.y2String = newY2String;
                
                pathSegment.pathCommand = 'C';

                break;
            }
                
            case 'A':     // elliptical arc
            {
                float deltaY = currentPoint.y - absoluteStartYFloat;
                
                float newXFloat = absoluteStartXFloat;
                float newYFloat = currentPoint.y + deltaY;
                
                pathSegment.xFloat = newXFloat;
                pathSegment.yFloat = newYFloat;

                break;
            }
            case 'a':     // elliptical arc
            {
                float xFloat = pathSegment.xFloat;
                pathSegment.xFloat = -xFloat;

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
//	flipPathHorizontallyWithPathSegmentsArray:
//==================================================================================

- (NSMutableArray *)flipPathHorizontallyWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;

    NSMutableArray * newSegmentsArray = [NSMutableArray array];

    if (pathSegmentsArray.count > 0)
    {
        float pathOriginX = 0;
        float pathOriginY = 0;
        
        NSInteger currentIndex = 0;
        
        for (PathSegment * pathSegment in pathSegmentsArray)
        {
            float oldAbsoluteXFloat = pathSegment.absoluteXFloat;
            float oldXFloat = pathSegment.xFloat;
            float oldYFloat = pathSegment.yFloat;
            NSString * oldYString = pathSegment.yString;
        
            float oldAbsoluteX1Float = pathSegment.absoluteX1Float;
            float oldX1Float = pathSegment.x1Float;
            float oldY1Float = pathSegment.y1Float;
            NSString * oldY1String = pathSegment.y1String;
        
            float oldAbsoluteX2Float = pathSegment.absoluteX2Float;
            float oldX2Float = pathSegment.x2Float;
            float oldY2Float = pathSegment.y2Float;
            NSString * oldY2String = pathSegment.y2String;
                    
            if (currentIndex == 0)
            {
                oldAbsoluteXFloat = oldXFloat;
            
                pathOriginX = oldXFloat;
                pathOriginY = oldYFloat;
            }

            float newAbsoluteXFloat = pathOriginX + (pathOriginX - oldAbsoluteXFloat);
            NSString * newAbsoluteXString = [macSVGDocument allocFloatString:newAbsoluteXFloat];

            float newAbsoluteX1Float = pathOriginX + (pathOriginX - oldAbsoluteX1Float);
            NSString * newAbsoluteX1String = [macSVGDocument allocFloatString:newAbsoluteX1Float];

            float newAbsoluteX2Float = pathOriginX + (pathOriginX - oldAbsoluteX2Float);
            NSString * newAbsoluteX2String = [macSVGDocument allocFloatString:newAbsoluteX2Float];

            float newRelativeXFloat = -oldXFloat;
            NSString * newRelativeXString = [macSVGDocument allocFloatString:newRelativeXFloat];

            float newRelativeX1Float = -oldX1Float;
            NSString * newRelativeX1String = [macSVGDocument allocFloatString:newRelativeX1Float];

            float newRelativeX2Float = -oldX2Float;
            NSString * newRelativeX2String = [macSVGDocument allocFloatString:newRelativeX2Float];
            
            unichar commandCharacter = pathSegment.pathCommand;
            
            PathSegment * newPathSegment = [[PathSegment alloc] init];

            newPathSegment.pathCommand = commandCharacter;
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = oldYString;
                    break;
                }

                case 'm':     // moveto
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = oldYString;
                    break;
                }
                case 'L':     // lineto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = oldYString;
                    break;
                }
                
                case 'l':     // lineto
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = oldYString;
                    break;
                }

                case 'H':     // horizontal lineto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    break;
                }

                case 'h':     // horizontal lineto
                {
                    newPathSegment.xString = newRelativeXString;
                    break;
                }

                case 'V':     // vertical lineto
                {
                    newPathSegment.yString = oldYString;
                    break;
                }
                
                case 'v':     // vertical lineto
                {
                    newPathSegment.yString = oldYString;
                    break;
                }

                case 'C':     // absolute curveto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = oldYString;
                    newPathSegment.x1String = newAbsoluteX1String;
                    newPathSegment.y1String = oldY1String;
                    newPathSegment.x2String = newAbsoluteX2String;
                    newPathSegment.y2String = oldY2String;
                    break;
                }

                case 'c':     // relative curveto
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = oldYString;
                    newPathSegment.x1String = newRelativeX1String;
                    newPathSegment.y1String = oldY1String;
                    newPathSegment.x2String = newRelativeX2String;
                    newPathSegment.y2String = oldY2String;

                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = oldYString;
                    newPathSegment.x2String = newAbsoluteX2String;
                    newPathSegment.y2String = oldY2String;
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = oldYString;
                    newPathSegment.x2String = newRelativeX2String;
                    newPathSegment.y2String = oldY2String;
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = oldYString;
                    newPathSegment.x1String = newAbsoluteXString;
                    newPathSegment.y1String = oldY1String;
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = oldYString;
                    newPathSegment.x1String = newRelativeX1String;
                    newPathSegment.y1String = oldY1String;
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = oldYString;
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = oldYString;
                    break;
                }

                case 'A':     // elliptical arc
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = oldYString;

                    NSString * rxString = pathSegment.rxString;
                    NSString * ryString = pathSegment.ryString;
                    NSString * xAxisRotationString = pathSegment.xAxisRotationString;
                    NSString * largeArcFlagString = pathSegment.largeArcFlagString;
                    NSString * sweepFlagString = pathSegment.sweepFlagString;
                    
                    newPathSegment.rxString = rxString;
                    newPathSegment.ryString = ryString;
                    newPathSegment.xAxisRotationString = xAxisRotationString;
                    newPathSegment.largeArcFlagString = largeArcFlagString;
                    newPathSegment.sweepFlagString = sweepFlagString;

                    break;
                }
                case 'a':     // elliptical arc
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = oldYString;

                    NSString * rxString = pathSegment.rxString;
                    NSString * ryString = pathSegment.ryString;
                    NSString * xAxisRotationString = pathSegment.xAxisRotationString;
                    NSString * largeArcFlagString = pathSegment.largeArcFlagString;
                    NSString * sweepFlagString = pathSegment.sweepFlagString;
                    
                    newPathSegment.rxString = rxString;
                    newPathSegment.ryString = ryString;
                    newPathSegment.xAxisRotationString = xAxisRotationString;
                    newPathSegment.largeArcFlagString = largeArcFlagString;
                    newPathSegment.sweepFlagString = sweepFlagString;
                    break;
                }

                case 'Z':     // closepath
                case 'z':     // closepath
                    break;
            }
            
            [newSegmentsArray addObject:newPathSegment];
            
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
        
        for (PathSegment * pathSegment in pathSegmentsArray)
        {
            float oldAbsoluteYFloat = pathSegment.absoluteYFloat;
            float oldXFloat = pathSegment.xFloat;
            float oldYFloat = pathSegment.yFloat;
            NSString * oldXString = pathSegment.xString;
        
            float oldAbsoluteY1Float = pathSegment.absoluteY1Float;
            float oldX1Float = pathSegment.x1Float;
            float oldY1Float = pathSegment.y1Float;
            NSString * oldX1String = pathSegment.x1String;
        
            float oldAbsoluteY2Float = pathSegment.absoluteY2Float;
            float oldX2Float = pathSegment.x2Float;
            float oldY2Float = pathSegment.y2Float;
            NSString * oldX2String = pathSegment.x2String;
            
            float newAbsoluteYFloat = pathEndPoint.y - (oldAbsoluteYFloat - pathOriginPoint.y);
            NSString * newAbsoluteYString = [macSVGDocument allocFloatString:newAbsoluteYFloat];

            float newAbsoluteY1Float = pathEndPoint.y - (oldAbsoluteY1Float - pathOriginPoint.y);
            NSString * newAbsoluteY1String = [macSVGDocument allocFloatString:newAbsoluteY1Float];

            float newAbsoluteY2Float = pathEndPoint.y - (oldAbsoluteY2Float - pathOriginPoint.y);
            NSString * newAbsoluteY2String = [macSVGDocument allocFloatString:newAbsoluteY2Float];

            float newRelativeYFloat = -oldYFloat;
            NSString * newRelativeYString = [macSVGDocument allocFloatString:newRelativeYFloat];

            float newRelativeY1Float = -oldY1Float;
            NSString * newRelativeY1String = [macSVGDocument allocFloatString:newRelativeY1Float];

            float newRelativeY2Float = -oldY2Float;
            NSString * newRelativeY2String = [macSVGDocument allocFloatString:newRelativeY2Float];
            
            unichar commandCharacter = pathSegment.pathCommand;
            
            PathSegment * newPathSegment = [[PathSegment alloc] init];

            newPathSegment.pathCommand = commandCharacter;
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    newPathSegment.xString = oldXString;
                    newPathSegment.yString = newAbsoluteYString;
                    break;
                }

                case 'm':     // moveto
                {
                    newPathSegment.xString = oldXString;
                    newPathSegment.yString = newRelativeYString;
                    break;
                }
                case 'L':     // lineto
                {
                    newPathSegment.xString = oldXString;
                    newPathSegment.yString = newAbsoluteYString;
                    break;
                }
                
                case 'l':     // lineto
                {
                    newPathSegment.xString = oldXString;
                    newPathSegment.yString = newRelativeYString;
                    break;
                }

                case 'H':     // horizontal lineto
                {
                    newPathSegment.xString = oldXString;
                    break;
                }

                case 'h':     // horizontal lineto
                {
                    newPathSegment.xString = oldXString;
                    break;
                }

                case 'V':     // vertical lineto
                {
                    newPathSegment.yString = newAbsoluteYString;
                    break;
                }
                
                case 'v':     // vertical lineto
                {
                    newPathSegment.yString = newRelativeYString;
                    break;
                }

                case 'C':     // absolute curveto
                {
                    newPathSegment.xString = oldXString;
                    newPathSegment.yString = newAbsoluteYString;
                    newPathSegment.x1String = oldX1String;
                    newPathSegment.y1String = newAbsoluteY1String;
                    newPathSegment.x2String = oldX2String;
                    newPathSegment.y2String = newAbsoluteY2String;
                    break;
                }

                case 'c':     // relative curveto
                {
                    newPathSegment.xString = oldXString;
                    newPathSegment.yString = newRelativeYString;
                    newPathSegment.x1String = oldX1String;
                    newPathSegment.y1String = newRelativeY1String;
                    newPathSegment.x2String = oldX2String;
                    newPathSegment.y2String = newRelativeY2String;
                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    newPathSegment.xString = oldXString;
                    newPathSegment.yString = newAbsoluteYString;
                    newPathSegment.x2String = oldX2String;
                    newPathSegment.y2String = newAbsoluteY2String;
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    newPathSegment.xString = oldXString;
                    newPathSegment.yString = newRelativeYString;
                    newPathSegment.x2String = oldX2String;
                    newPathSegment.y2String = newRelativeY2String;
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    newPathSegment.xString = oldXString;
                    newPathSegment.yString = newAbsoluteYString;
                    newPathSegment.x1String = oldX1String;
                    newPathSegment.y1String = newAbsoluteY1String;
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    newPathSegment.xString = oldXString;
                    newPathSegment.yString = newRelativeYString;
                    newPathSegment.x1String = oldX1String;
                    newPathSegment.y1String = newRelativeY1String;
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    newPathSegment.xString = oldXString;
                    newPathSegment.yString = newAbsoluteYString;
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    newPathSegment.xString = oldXString;
                    newPathSegment.yString = newRelativeYString;
                    break;
                }

                case 'A':     // elliptical arc
                {
                    newPathSegment.xString = oldXString;
                    newPathSegment.yString = newAbsoluteYString;
                    
                    NSString * rxString = pathSegment.rxString;
                    NSString * ryString = pathSegment.ryString;
                    NSString * xAxisRotationString = pathSegment.xAxisRotationString;
                    NSString * largeArcFlagString = pathSegment.largeArcFlagString;
                    NSString * sweepFlagString = pathSegment.sweepFlagString;
                    
                    newPathSegment.rxString = rxString;
                    newPathSegment.ryString = ryString;
                    newPathSegment.xAxisRotationString = xAxisRotationString;
                    newPathSegment.largeArcFlagString = largeArcFlagString;
                    newPathSegment.sweepFlagString = sweepFlagString;

                    break;
                }
                case 'a':     // elliptical arc
                {
                    newPathSegment.xString = oldXString;
                    newPathSegment.yString = newRelativeYString;
                    
                    NSString * rxString = pathSegment.rxString;
                    NSString * ryString = pathSegment.ryString;
                    NSString * xAxisRotationString = pathSegment.xAxisRotationString;
                    NSString * largeArcFlagString = pathSegment.largeArcFlagString;
                    NSString * sweepFlagString = pathSegment.sweepFlagString;
                    
                    newPathSegment.rxString = rxString;
                    newPathSegment.ryString = ryString;
                    newPathSegment.xAxisRotationString = xAxisRotationString;
                    newPathSegment.largeArcFlagString = largeArcFlagString;
                    newPathSegment.sweepFlagString = sweepFlagString;

                    break;
                }

                case 'Z':     // closepath
                case 'z':     // closepath
                    break;
            }
            
            [newSegmentsArray addObject:newPathSegment];
            
            currentIndex++;
        }
        
        [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:newSegmentsArray];
    }
    
    return newSegmentsArray;
}


//==================================================================================
//	translatePathCoordinatesWithPathSegmentsArray:x:y:
//==================================================================================

- (NSMutableArray *)translatePathCoordinatesWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray x:(float)translateX y:(float)translateY
{
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;

    NSMutableArray * newSegmentsArray = [NSMutableArray array];

    if (pathSegmentsArray.count > 0)
    {
        NSPoint pathOriginPoint = [self.macSVGDocumentWindowController.svgWebKitController
                endPointForSegmentIndex:0 pathSegmentsArray:pathSegmentsArray];
        
        NSInteger currentIndex = 0;
        
        for (PathSegment * pathSegment in pathSegmentsArray)
        {
            float oldAbsoluteXFloat = pathSegment.absoluteXFloat;
            float oldAbsoluteYFloat = pathSegment.absoluteYFloat;
            float oldXFloat = pathSegment.xFloat;
            float oldYFloat = pathSegment.yFloat;
        
            float oldAbsoluteX1Float = pathSegment.absoluteX1Float;
            float oldAbsoluteY1Float = pathSegment.absoluteY1Float;
            float oldX1Float = pathSegment.x1Float;
            float oldY1Float = pathSegment.y1Float;
        
            float oldAbsoluteX2Float = pathSegment.absoluteX2Float;
            float oldAbsoluteY2Float = pathSegment.absoluteY2Float;
            float oldX2Float = pathSegment.x2Float;
            float oldY2Float = pathSegment.y2Float;
        
            float newAbsoluteXFloat = ((oldAbsoluteXFloat - pathOriginPoint.x) + translateX) + pathOriginPoint.x;
            NSString * newAbsoluteXString = [macSVGDocument allocFloatString:newAbsoluteXFloat];
            
            float newAbsoluteYFloat = ((oldAbsoluteYFloat - pathOriginPoint.y) + translateY) + pathOriginPoint.y;
            NSString * newAbsoluteYString = [macSVGDocument allocFloatString:newAbsoluteYFloat];

            float newAbsoluteX1Float = ((oldAbsoluteX1Float - pathOriginPoint.x) + translateX) + pathOriginPoint.x;
            NSString * newAbsoluteX1String = [macSVGDocument allocFloatString:newAbsoluteX1Float];

            float newAbsoluteY1Float = ((oldAbsoluteY1Float - pathOriginPoint.y) + translateY) + pathOriginPoint.y;
            NSString * newAbsoluteY1String = [macSVGDocument allocFloatString:newAbsoluteY1Float];

            float newAbsoluteX2Float = ((oldAbsoluteX2Float - pathOriginPoint.x) + translateX) + pathOriginPoint.x;
            NSString * newAbsoluteX2String = [macSVGDocument allocFloatString:newAbsoluteX2Float];

            float newAbsoluteY2Float = ((oldAbsoluteY2Float - pathOriginPoint.y) + translateY) + pathOriginPoint.y;
            NSString * newAbsoluteY2String = [macSVGDocument allocFloatString:newAbsoluteY2Float];

            float newRelativeXFloat = oldXFloat + translateX;
            NSString * newRelativeXString = [macSVGDocument allocFloatString:newRelativeXFloat];

            float newRelativeYFloat = oldYFloat + translateY;
            NSString * newRelativeYString = [macSVGDocument allocFloatString:newRelativeYFloat];

            float newRelativeX1Float = oldX1Float + translateX;
            NSString * newRelativeX1String = [macSVGDocument allocFloatString:newRelativeX1Float];

            float newRelativeY1Float = oldY1Float + translateY;
            NSString * newRelativeY1String = [macSVGDocument allocFloatString:newRelativeY1Float];

            float newRelativeX2Float = oldX2Float + translateX;
            NSString * newRelativeX2String = [macSVGDocument allocFloatString:newRelativeX2Float];
            
            float newRelativeY2Float = oldY2Float + translateY;
            NSString * newRelativeY2String = [macSVGDocument allocFloatString:newRelativeY2Float];
            
            unichar commandCharacter = pathSegment.pathCommand;
            
            PathSegment * newPathSegment = [[PathSegment alloc] init];

            newPathSegment.pathCommand = commandCharacter;
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    break;
                }

                case 'm':     // moveto
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = newRelativeYString;
                    break;
                }
                case 'L':     // lineto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    break;
                }
                
                case 'l':     // lineto
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = newRelativeYString;
                    break;
                }

                case 'H':     // horizontal lineto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    break;
                }

                case 'h':     // horizontal lineto
                {
                    newPathSegment.xString = newRelativeXString;
                    break;
                }

                case 'V':     // vertical lineto
                {
                    newPathSegment.yString = newAbsoluteYString;
                    break;
                }
                
                case 'v':     // vertical lineto
                {
                    newPathSegment.yString = newRelativeYString;
                    break;
                }

                case 'C':     // absolute curveto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    newPathSegment.x1String = newAbsoluteX1String;
                    newPathSegment.y1String = newAbsoluteY1String;
                    newPathSegment.x2String = newAbsoluteX2String;
                    newPathSegment.y2String = newAbsoluteY2String;
                    break;
                }

                case 'c':     // relative curveto
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = newRelativeYString;
                    newPathSegment.x1String = newRelativeX1String;
                    newPathSegment.y1String = newRelativeY1String;
                    newPathSegment.x2String = newRelativeX2String;
                    newPathSegment.y2String = newRelativeY2String;
                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    newPathSegment.x2String = newAbsoluteX2String;
                    newPathSegment.y2String = newAbsoluteY2String;
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = newRelativeYString;
                    newPathSegment.x2String = newRelativeX2String;
                    newPathSegment.y2String = newRelativeY2String;
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    newPathSegment.x1String = newAbsoluteX1String;
                    newPathSegment.y1String = newAbsoluteY1String;
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = newRelativeYString;
                    newPathSegment.x1String = newRelativeX1String;
                    newPathSegment.y1String = newRelativeY1String;
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = newRelativeYString;
                    break;
                }

                case 'A':     // elliptical arc
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    
                    NSString * rxString = pathSegment.rxString;
                    NSString * ryString = pathSegment.ryString;
                    NSString * xAxisRotationString = pathSegment.xAxisRotationString;
                    NSString * largeArcFlagString = pathSegment.largeArcFlagString;
                    NSString * sweepFlagString = pathSegment.sweepFlagString;
                    
                    float rxFloat = rxString.floatValue + translateX;
                    float ryFloat = ryString.floatValue + translateY;
                    rxString = [macSVGDocument allocFloatString:rxFloat];
                    ryString = [macSVGDocument allocFloatString:ryFloat];
                    
                    newPathSegment.rxString = rxString;
                    newPathSegment.ryString = ryString;
                    newPathSegment.xAxisRotationString = xAxisRotationString;
                    newPathSegment.largeArcFlagString = largeArcFlagString;
                    newPathSegment.sweepFlagString = sweepFlagString;

                    break;
                }
                case 'a':     // elliptical arc
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = newRelativeYString;
                    
                    NSString * rxString = pathSegment.rxString;
                    NSString * ryString = pathSegment.ryString;
                    NSString * xAxisRotationString = pathSegment.xAxisRotationString;
                    NSString * largeArcFlagString = pathSegment.largeArcFlagString;
                    NSString * sweepFlagString = pathSegment.sweepFlagString;

                    float rxFloat = rxString.floatValue + translateX;
                    float ryFloat = ryString.floatValue + translateY;
                    rxString = [macSVGDocument allocFloatString:rxFloat];
                    ryString = [macSVGDocument allocFloatString:ryFloat];
                    
                    newPathSegment.rxString = rxString;
                    newPathSegment.ryString = ryString;
                    newPathSegment.xAxisRotationString = xAxisRotationString;
                    newPathSegment.largeArcFlagString = largeArcFlagString;
                    newPathSegment.sweepFlagString = sweepFlagString;

                    break;
                }

                case 'Z':     // closepath
                case 'z':     // closepath
                    break;
            }
            
            [newSegmentsArray addObject:newPathSegment];
            
            currentIndex++;
        }
        
        [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:newSegmentsArray];
    }
    
    return newSegmentsArray;
}

//==================================================================================
//	scalePathCoordinatesWithPathSegmentsArray:scaleX:scaleY:
//==================================================================================

- (NSMutableArray *)scalePathCoordinatesWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray scaleX:(float)scaleX scaleY:(float)scaleY
{
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;

    NSMutableArray * newSegmentsArray = [NSMutableArray array];

    if (pathSegmentsArray.count > 0)
    {
        NSPoint pathOriginPoint = [self.macSVGDocumentWindowController.svgWebKitController
                endPointForSegmentIndex:0 pathSegmentsArray:pathSegmentsArray];
        
        NSInteger currentIndex = 0;
        
        for (PathSegment * pathSegment in pathSegmentsArray)
        {
            float oldAbsoluteXFloat = pathSegment.absoluteXFloat;
            float oldAbsoluteYFloat = pathSegment.absoluteYFloat;
            float oldXFloat = pathSegment.xFloat;
            float oldYFloat = pathSegment.yFloat;
        
            float oldAbsoluteX1Float = pathSegment.absoluteX1Float;
            float oldAbsoluteY1Float = pathSegment.absoluteY1Float;
            float oldX1Float = pathSegment.x1Float;
            float oldY1Float = pathSegment.y1Float;
        
            float oldAbsoluteX2Float = pathSegment.absoluteX2Float;
            float oldAbsoluteY2Float = pathSegment.absoluteY2Float;
            float oldX2Float = pathSegment.x2Float;
            float oldY2Float = pathSegment.y2Float;

            float newAbsoluteXFloat = ((oldAbsoluteXFloat - pathOriginPoint.x) * scaleX) + pathOriginPoint.x;
            NSString * newAbsoluteXString = [macSVGDocument allocFloatString:newAbsoluteXFloat];
            
            float newAbsoluteYFloat = ((oldAbsoluteYFloat - pathOriginPoint.y) * scaleY) + pathOriginPoint.y;
            NSString * newAbsoluteYString = [macSVGDocument allocFloatString:newAbsoluteYFloat];

            float newAbsoluteX1Float = ((oldAbsoluteX1Float - pathOriginPoint.x) * scaleX) + pathOriginPoint.x;
            NSString * newAbsoluteX1String = [macSVGDocument allocFloatString:newAbsoluteX1Float];

            float newAbsoluteY1Float = ((oldAbsoluteY1Float - pathOriginPoint.y) * scaleY) + pathOriginPoint.y;
            NSString * newAbsoluteY1String = [macSVGDocument allocFloatString:newAbsoluteY1Float];

            float newAbsoluteX2Float = ((oldAbsoluteX2Float - pathOriginPoint.x) * scaleX) + pathOriginPoint.x;
            NSString * newAbsoluteX2String = [macSVGDocument allocFloatString:newAbsoluteX2Float];

            float newAbsoluteY2Float = ((oldAbsoluteY2Float - pathOriginPoint.y) * scaleY) + pathOriginPoint.y;
            NSString * newAbsoluteY2String = [macSVGDocument allocFloatString:newAbsoluteY2Float];

            float newRelativeXFloat = oldXFloat * scaleX;
            NSString * newRelativeXString = [macSVGDocument allocFloatString:newRelativeXFloat];

            float newRelativeYFloat = oldYFloat * scaleY;
            NSString * newRelativeYString = [macSVGDocument allocFloatString:newRelativeYFloat];

            float newRelativeX1Float = oldX1Float * scaleX;
            NSString * newRelativeX1String = [macSVGDocument allocFloatString:newRelativeX1Float];

            float newRelativeY1Float = oldY1Float * scaleY;
            NSString * newRelativeY1String = [macSVGDocument allocFloatString:newRelativeY1Float];

            float newRelativeX2Float = oldX2Float * scaleX;
            NSString * newRelativeX2String = [macSVGDocument allocFloatString:newRelativeX2Float];
            
            float newRelativeY2Float = oldY2Float * scaleY;
            NSString * newRelativeY2String = [macSVGDocument allocFloatString:newRelativeY2Float];
            
            unichar commandCharacter = pathSegment.pathCommand;
            
            PathSegment * newPathSegment = [[PathSegment alloc] init];

            newPathSegment.pathCommand = commandCharacter;
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    break;
                }

                case 'm':     // moveto
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = newRelativeYString;
                    break;
                }
                case 'L':     // lineto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    break;
                }
                
                case 'l':     // lineto
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = newRelativeYString;
                    break;
                }

                case 'H':     // horizontal lineto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    break;
                }

                case 'h':     // horizontal lineto
                {
                    newPathSegment.xString = newRelativeXString;
                    break;
                }

                case 'V':     // vertical lineto
                {
                    newPathSegment.yString = newAbsoluteYString;
                    break;
                }
                
                case 'v':     // vertical lineto
                {
                    newPathSegment.yString = newRelativeYString;
                    break;
                }

                case 'C':     // absolute curveto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    newPathSegment.x1String = newAbsoluteX1String;
                    newPathSegment.y1String = newAbsoluteY1String;
                    newPathSegment.x2String = newAbsoluteX2String;
                    newPathSegment.y2String = newAbsoluteY2String;
                    break;
                }

                case 'c':     // relative curveto
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = newRelativeYString;
                    newPathSegment.x1String = newRelativeX1String;
                    newPathSegment.y1String = newRelativeY1String;
                    newPathSegment.x2String = newRelativeX2String;
                    newPathSegment.y2String = newRelativeY2String;
                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    newPathSegment.x2String = newAbsoluteX2String;
                    newPathSegment.y2String = newAbsoluteY2String;
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = newRelativeYString;
                    newPathSegment.x2String = newRelativeX2String;
                    newPathSegment.y2String = newRelativeY2String;
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    newPathSegment.x1String = newAbsoluteX1String;
                    newPathSegment.y1String = newAbsoluteY1String;
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = newRelativeYString;
                    newPathSegment.x1String = newRelativeX1String;
                    newPathSegment.y1String = newRelativeY1String;
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = newRelativeYString;
                    break;
                }

                case 'A':     // elliptical arc
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    
                    NSString * rxString = pathSegment.rxString;
                    NSString * ryString = pathSegment.ryString;
                    NSString * xAxisRotationString = pathSegment.xAxisRotationString;
                    NSString * largeArcFlagString = pathSegment.largeArcFlagString;
                    NSString * sweepFlagString = pathSegment.sweepFlagString;
                    
                    float rxFloat = rxString.floatValue * scaleX;
                    float ryFloat = ryString.floatValue * scaleY;
                    rxString = [macSVGDocument allocFloatString:rxFloat];
                    ryString = [macSVGDocument allocFloatString:ryFloat];
                    
                    newPathSegment.rxString = rxString;
                    newPathSegment.ryString = ryString;
                    newPathSegment.xAxisRotationString = xAxisRotationString;
                    newPathSegment.largeArcFlagString = largeArcFlagString;
                    newPathSegment.sweepFlagString = sweepFlagString;

                    break;
                }
                case 'a':     // elliptical arc
                {
                    newPathSegment.xString = newRelativeXString;
                    newPathSegment.yString = newRelativeYString;
                    
                    NSString * rxString = pathSegment.rxString;
                    NSString * ryString = pathSegment.ryString;
                    NSString * xAxisRotationString = pathSegment.xAxisRotationString;
                    NSString * largeArcFlagString = pathSegment.largeArcFlagString;
                    NSString * sweepFlagString = pathSegment.sweepFlagString;

                    float rxFloat = rxString.floatValue * scaleX;
                    float ryFloat = ryString.floatValue * scaleY;
                    rxString = [macSVGDocument allocFloatString:rxFloat];
                    ryString = [macSVGDocument allocFloatString:ryFloat];
                    
                    newPathSegment.rxString = rxString;
                    newPathSegment.ryString = ryString;
                    newPathSegment.xAxisRotationString = xAxisRotationString;
                    newPathSegment.largeArcFlagString = largeArcFlagString;
                    newPathSegment.sweepFlagString = sweepFlagString;

                    break;
                }

                case 'Z':     // closepath
                case 'z':     // closepath
                    break;
            }
            
            [newSegmentsArray addObject:newPathSegment];
            
            currentIndex++;
        }
        
        [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:newSegmentsArray];
    }
    
    return newSegmentsArray;
}

//==================================================================================
//	rotate_point()
//==================================================================================

- (CGPoint)rotatePoint:(CGPoint)aPoint centerPoint:(CGPoint)centerPoint degrees:(float)degrees
{
    double radians = degrees * (M_PI / 180.0f);

    float s = sinf(radians);
    float c = cosf(radians);

    CGPoint translatePoint = aPoint;
    translatePoint.x -= centerPoint.x;
    translatePoint.y -= centerPoint.y;
    
    float rotX = (translatePoint.x * c) - (translatePoint.y * s);
    float rotY = (translatePoint.x * s) + (translatePoint.y * c);
    
    CGPoint result = CGPointZero;
    result.x = rotX + centerPoint.x;
    result.y = rotY + centerPoint.y;
    
    return result;
}

//==================================================================================
//	rotatePathCoordinatesWithPathSegmentsArray:x:y:degree:
//==================================================================================

- (NSMutableArray *)rotatePathCoordinatesWithPathSegmentsArray:(NSMutableArray *)mixedPathSegmentsArray x:(float)rotateX y:(float)rotateY degrees:(float)degrees
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
        
        for (PathSegment * pathSegment in pathSegmentsArray)
        {
            float oldAbsoluteXFloat = pathSegment.absoluteXFloat;
            float oldAbsoluteYFloat = pathSegment.absoluteYFloat;
        
            float oldAbsoluteX1Float = pathSegment.absoluteX1Float;
            float oldAbsoluteY1Float = pathSegment.absoluteY1Float;
        
            float oldAbsoluteX2Float = pathSegment.absoluteX2Float;
            float oldAbsoluteY2Float = pathSegment.absoluteY2Float;
        
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
            
            unichar commandCharacter = pathSegment.pathCommand;

            if (commandCharacter == 'H')
            {
                commandCharacter = 'L';
            }
            if (commandCharacter == 'V')
            {
                commandCharacter = 'L';
            }
            
            PathSegment * newPathSegment = [[PathSegment alloc] init];

            newPathSegment.pathCommand = commandCharacter;
            
            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    break;
                }

                case 'm':     // moveto
                {
                    break;
                }
                case 'L':     // lineto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
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
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    newPathSegment.x1String = newAbsoluteX1String;
                    newPathSegment.y1String = newAbsoluteY1String;
                    newPathSegment.x2String = newAbsoluteX2String;
                    newPathSegment.y2String = newAbsoluteY2String;
                    break;
                }

                case 'c':     // relative curveto
                {
                    break;
                }

                case 'S':     // absolute smooth cubic curveto
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    newPathSegment.x2String = newAbsoluteX2String;
                    newPathSegment.y2String = newAbsoluteY2String;
                    break;
                }
                
                case 's':     // relative smooth cubic curveto
                {
                    break;
                }

                case 'Q':     // quadratic Bezier curve
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    newPathSegment.x1String = newAbsoluteX1String;
                    newPathSegment.y1String = newAbsoluteY1String;
                    break;
                }
                
                case 'q':     // quadratic Bezier curve
                {
                    break;
                }

                case 'T':     // smooth quadratic Bezier curve
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;
                    break;

                case 't':     // smooth quadratic Bezier curve
                {
                    break;
                }

                case 'A':     // elliptical arc
                {
                    newPathSegment.xString = newAbsoluteXString;
                    newPathSegment.yString = newAbsoluteYString;

                    NSString * rxString = pathSegment.rxString;
                    NSString * ryString = pathSegment.ryString;
                    NSString * xAxisRotationString = pathSegment.xAxisRotationString;
                    NSString * largeArcFlagString = pathSegment.largeArcFlagString;
                    NSString * sweepFlagString = pathSegment.sweepFlagString;
                    
                    newPathSegment.rxString = rxString;
                    newPathSegment.ryString = ryString;
                    newPathSegment.xAxisRotationString = xAxisRotationString;
                    newPathSegment.largeArcFlagString = largeArcFlagString;
                    newPathSegment.sweepFlagString = sweepFlagString;
                    
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
            
            [newSegmentsArray addObject:newPathSegment];
            
            currentIndex++;
        }
        
        [self.macSVGDocumentWindowController.svgWebKitController updatePathSegmentsAbsoluteValues:newSegmentsArray];
    }
    
    return newSegmentsArray;
}

//==================================================================================
//    joinPathSegmentsArray:secondPathSegmentsArray:
//==================================================================================

- (NSMutableArray *)joinPathSegmentsArray:(NSMutableArray *)pathSegmentsArray secondPathSegmentsArray:(NSMutableArray *)secondPathSegmentsArray
{
    NSMutableArray * resultArray = [NSMutableArray array];
    
    [resultArray addObjectsFromArray:pathSegmentsArray];
    
    [resultArray addObjectsFromArray:secondPathSegmentsArray];

    return resultArray;
}

//==================================================================================
//    splitPathSegmentsArray:splitIndex:
//==================================================================================

- (NSMutableArray *)splitPathSegmentsArray:(NSMutableArray *)pathSegmentsArray splitIndex:(NSInteger *)splitIndex
{
    /*
    NSMutableArray * resultArray = [NSMutableArray array];
    
    NSMutableArray * firstArray = [NSMutableArray array];
    NSMutableArray * secondArray = [NSMutableArray array];
    */
    
    NSBeep();
    
    NSMutableArray * resultArray = pathSegmentsArray;        // FIXME: return original array for now

    return resultArray;
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
        NSInteger firstSegmentIndex = 0;
        NSInteger secondSegmentIndex = 1;
        NSInteger lastSegmentIndex = pathSegmentsArrayCount - 1;
        
        for (PathSegment * aPathSegment in pathSegmentsArray)
        {
            unichar aPathSegmentCommand = aPathSegment.pathCommand;
            NSInteger aPathSegmentIndex = [pathSegmentsArray indexOfObject:aPathSegment];
            
            if (aPathSegmentIndex < lastSegmentIndex - 2)
            {
                switch (aPathSegmentCommand)
                {
                    case 'Z':
                    case 'z':
                    {
                        firstSegmentIndex = aPathSegmentIndex + 1;
                        secondSegmentIndex = aPathSegmentIndex + 2;
                        break;
                    }
                }
            }
        }
    
        
        PathSegment * firstPathSegment = [pathSegmentsArray objectAtIndex:firstSegmentIndex];
        unichar firstPathSegmentCommand = firstPathSegment.pathCommand;
        
        float firstXFloat = firstPathSegment.xFloat;
        float firstYFloat = firstPathSegment.yFloat;

        float firstAbsoluteXFloat = firstPathSegment.absoluteXFloat;
        float firstAbsoluteYFloat = firstPathSegment.absoluteYFloat;

        PathSegment * secondPathSegment = [pathSegmentsArray objectAtIndex:secondSegmentIndex];
        unichar secondPathSegmentCommand = secondPathSegment.pathCommand;
        
        float secondX1Float = secondPathSegment.x1Float;
        float secondY1Float = secondPathSegment.y1Float;

        float secondX2Float = secondPathSegment.x2Float;
        float secondY2Float = secondPathSegment.y2Float;

        float secondAbsoluteX1Float = secondPathSegment.absoluteX1Float;
        float secondAbsoluteY1Float = secondPathSegment.absoluteY1Float;

        PathSegment * lastPathSegment = [pathSegmentsArray objectAtIndex:lastSegmentIndex];
        unichar lastPathSegmentCommand = lastPathSegment.pathCommand;
        
        float lastAbsoluteStartXFloat = lastPathSegment.absoluteStartXFloat;
        float lastAbsoluteStartYFloat = lastPathSegment.absoluteStartYFloat;
        
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
                        NSString * newXString = [macSVGDocument allocFloatString:firstXFloat];
                        NSString * newYString = [macSVGDocument allocFloatString:firstYFloat];

                        lastPathSegment.xString = newXString;
                        lastPathSegment.yString = newYString;
                        lastPathSegment.pathCommand = 'L';

                        break;
                    }
                    
                    case 'l':     // lineto
                    {
                        float newXFloat = firstAbsoluteXFloat - lastAbsoluteStartXFloat;
                        float newYFloat = firstAbsoluteYFloat - lastAbsoluteStartYFloat;

                        NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                        NSString * newYString = [macSVGDocument allocFloatString:newYFloat];

                        lastPathSegment.xString = newXString;
                        lastPathSegment.yString = newYString;
                        lastPathSegment.pathCommand = 'l';

                        break;
                    }

                    case 'H':     // horizontal lineto
                    {
                        NSString * newXString = [macSVGDocument allocFloatString:firstXFloat];
                        NSString * newYString = [macSVGDocument allocFloatString:firstYFloat];

                        lastPathSegment.xString = newXString;
                        lastPathSegment.yString = newYString;
                        lastPathSegment.pathCommand = 'L';

                        break;
                    }

                    case 'h':     // horizontal lineto
                    {
                        float newXFloat = firstAbsoluteXFloat - lastAbsoluteStartXFloat;
                        float newYFloat = firstAbsoluteYFloat - lastAbsoluteStartYFloat;

                        NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                        NSString * newYString = [macSVGDocument allocFloatString:newYFloat];

                        lastPathSegment.xString = newXString;
                        lastPathSegment.yString = newYString;
                        lastPathSegment.pathCommand = 'l';

                        break;
                    }

                    case 'V':     // vertical lineto
                    {
                        NSString * newXString = [macSVGDocument allocFloatString:firstXFloat];
                        NSString * newYString = [macSVGDocument allocFloatString:firstYFloat];

                        lastPathSegment.xString = newXString;
                        lastPathSegment.yString = newYString;
                        lastPathSegment.pathCommand = 'L';

                        break;
                    }
                    
                    case 'v':     // vertical lineto
                    {
                        float newXFloat = firstAbsoluteXFloat - lastAbsoluteStartXFloat;
                        float newYFloat = firstAbsoluteYFloat - lastAbsoluteStartYFloat;

                        NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                        NSString * newYString = [macSVGDocument allocFloatString:newYFloat];

                        lastPathSegment.xString = newXString;
                        lastPathSegment.yString = newYString;
                        lastPathSegment.pathCommand = 'l';

                        break;
                    }

                    case 'C':     // absolute curveto
                    {
                        if (secondPathSegmentCommand == 'C')
                        {
                            NSString * newXString = [macSVGDocument allocFloatString:firstXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:firstYFloat];

                            float newX2Float = firstXFloat - (secondX1Float - firstXFloat);
                            float newY2Float = firstYFloat - (secondY1Float - firstYFloat);
                            
                            NSString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                            NSString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                            
                            lastPathSegment.xString = newXString;
                            lastPathSegment.yString = newYString;
                            lastPathSegment.x2String = newX2String;
                            lastPathSegment.y2String = newY2String;
                        }

                        break;
                    }

                    case 'c':     // relative curveto
                    {
                        if (secondPathSegmentCommand == 'c')
                        {
                            float newXFloat = firstAbsoluteXFloat - lastAbsoluteStartXFloat;
                            float newYFloat = firstAbsoluteYFloat - lastAbsoluteStartYFloat;
                        
                            NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:newYFloat];

                            float newX2Float = (firstAbsoluteXFloat - secondAbsoluteX1Float) + (firstAbsoluteXFloat - lastAbsoluteStartXFloat);
                            float newY2Float = (firstAbsoluteYFloat - secondAbsoluteY1Float) + (firstAbsoluteYFloat -lastAbsoluteStartYFloat);
                            
                            NSString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                            NSString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                            
                            lastPathSegment.xString = newXString;
                            lastPathSegment.yString = newYString;
                            lastPathSegment.x2String = newX2String;
                            lastPathSegment.y2String = newY2String;
                        }

                        break;
                    }

                    case 'S':     // absolute smooth cubic curveto
                    {
                        if (secondPathSegmentCommand == 'S')
                        {
                            NSString * newXString = [macSVGDocument allocFloatString:firstXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:firstYFloat];

                            float newX2Float = firstXFloat - (secondX2Float - firstXFloat);
                            float newY2Float = firstYFloat - (secondY2Float - firstYFloat);
                            
                            NSString * newX2String = [macSVGDocument allocFloatString:newX2Float];
                            NSString * newY2String = [macSVGDocument allocFloatString:newY2Float];
                            
                            lastPathSegment.xString = newXString;
                            lastPathSegment.yString = newYString;
                            lastPathSegment.x2String = newX2String;
                            lastPathSegment.y2String = newY2String;
                        }
                        break;
                    }
                    
                    case 's':     // relative smooth cubic curveto
                    {
                        if (secondPathSegmentCommand == 's')
                        {
                            float newXFloat = firstAbsoluteXFloat - lastAbsoluteStartXFloat;
                            float newYFloat = firstAbsoluteYFloat - lastAbsoluteStartYFloat;

                            NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:newYFloat];

                            NSString * newX2String = [macSVGDocument allocFloatString:newXFloat];
                            NSString * newY2String = [macSVGDocument allocFloatString:newYFloat];
                            
                            lastPathSegment.xString = newXString;
                            lastPathSegment.yString = newYString;
                            lastPathSegment.x2String = newX2String;
                            lastPathSegment.y2String = newY2String;
                        }
                        break;
                    }

                    case 'Q':     // quadratic Bezier curve
                    {
                        if (secondPathSegmentCommand == 'Q')
                        {
                            NSString * newXString = [macSVGDocument allocFloatString:firstXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:firstYFloat];

                            float newX1Float = firstXFloat - (secondX1Float - firstXFloat);
                            float newY1Float = firstYFloat - (secondY1Float - firstYFloat);
                            
                            NSString * newX1String = [macSVGDocument allocFloatString:newX1Float];
                            NSString * newY1String = [macSVGDocument allocFloatString:newY1Float];

                            lastPathSegment.xString = newXString;
                            lastPathSegment.yString = newYString;
                            lastPathSegment.x1String = newX1String;
                            lastPathSegment.y1String = newY1String;
                        }
                        break;
                    }
                    
                    case 'q':     // quadratic Bezier curve
                    {
                        if (secondPathSegmentCommand == 'q')
                        {
                            float newXFloat = firstAbsoluteXFloat - lastAbsoluteStartXFloat;
                            float newYFloat = firstAbsoluteYFloat - lastAbsoluteStartYFloat;

                            NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:newYFloat];

                            NSString * newX1String = [macSVGDocument allocFloatString:newXFloat];
                            NSString * newY1String = [macSVGDocument allocFloatString:newYFloat];

                            lastPathSegment.xString = newXString;
                            lastPathSegment.yString = newYString;
                            lastPathSegment.x1String = newX1String;
                            lastPathSegment.y1String = newY1String;
                        }

                        break;
                    }

                    case 'T':     // smooth quadratic Bezier curve
                        if (secondPathSegmentCommand == 'T')
                        {
                            NSString * newXString = [macSVGDocument allocFloatString:firstXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:firstYFloat];

                            lastPathSegment.xString = newXString;
                            lastPathSegment.yString = newYString;
                        }
                        break;

                    case 't':     // smooth quadratic Bezier curve
                    {
                        if (secondPathSegmentCommand == 't')
                        {
                            float newXFloat = firstAbsoluteXFloat - lastAbsoluteStartXFloat;
                            float newYFloat = firstAbsoluteYFloat - lastAbsoluteStartYFloat;

                            NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:newYFloat];

                            lastPathSegment.xString = newXString;
                            lastPathSegment.yString = newYString;
                        }

                        break;
                    }

                    case 'A':     // elliptical arc
                    {
                        if (secondPathSegmentCommand == 'A')
                        {
                            NSString * newXString = [macSVGDocument allocFloatString:firstXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:firstYFloat];

                            lastPathSegment.xString = newXString;
                            lastPathSegment.yString = newYString;
                        }
                        
                        break;
                    }
                    case 'a':     // elliptical arc
                    {
                        if (secondPathSegmentCommand == 'a')
                        {
                            float newXFloat = firstAbsoluteXFloat - lastAbsoluteStartXFloat;
                            float newYFloat = firstAbsoluteYFloat - lastAbsoluteStartYFloat;

                            NSString * newXString = [macSVGDocument allocFloatString:newXFloat];
                            NSString * newYString = [macSVGDocument allocFloatString:newYFloat];

                            lastPathSegment.xString = newXString;
                            lastPathSegment.yString = newYString;
                        }

                        break;
                    }

                    case 'Z':     // closepath
                    case 'z':     // closepath
                        break;
                }
            }

            PathSegment * closePathSegment = [[PathSegment alloc] init];
            
            if ((lastPathSegmentCommand >= 'a') && (lastPathSegmentCommand <= 'z'))
            {
                closePathSegment.pathCommand = 'z';
            }
            else
            {
                closePathSegment.pathCommand = 'Z';
            }
            
            [pathSegmentsArray addObject:closePathSegment];
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
        PathSegment * firstPathSegment = [pathSegmentsArray objectAtIndex:0];
        unichar firstSegmentCommand = firstPathSegment.pathCommand;
        
        if (firstSegmentCommand == 'M')
        {
            BOOL lastSegmentIsClosePath = NO;
            NSInteger lastSegmentIndex = pathSegmentsArrayCount - 1;

            PathSegment * lastPathSegment = [pathSegmentsArray objectAtIndex:lastSegmentIndex];
            unichar lastSegmentCommand = lastPathSegment.pathCommand;
            if ((lastSegmentCommand == 'Z') || (lastSegmentCommand == 'z'))
            {
                lastSegmentIsClosePath = YES;
                lastSegmentIndex--;
            }
        
            newSegmentsArray = [NSMutableArray array];

            if (offset < 0)
            {
                // left rotation

                PathSegment * startPathSegment = [pathSegmentsArray objectAtIndex:-offset];
                float startX = startPathSegment.absoluteXFloat;
                float startY = startPathSegment.absoluteYFloat;
                
                NSString * startXString = [self allocFloatString:startX];
                NSString * startYString = [self allocFloatString:startY];
                
                PathSegment * newFirstPathSegment = [[PathSegment alloc] init];
                newFirstPathSegment.pathCommand = 'M';
                newFirstPathSegment.absoluteXFloat = startX;
                newFirstPathSegment.absoluteYFloat = startY;
                newFirstPathSegment.absoluteStartXFloat = startX;
                newFirstPathSegment.absoluteStartYFloat = startY;
                newFirstPathSegment.xString = startXString;
                newFirstPathSegment.yString = startYString;
                                
                [newSegmentsArray addObject:newFirstPathSegment];
                
                for (NSInteger i = -offset + 1; i <= lastSegmentIndex; i++)
                {
                    PathSegment * pathSegment = [pathSegmentsArray objectAtIndex:i];
                    
                    PathSegment * newPathSegment = [[PathSegment alloc] init];
                    [newPathSegment copyValuesFromPathSegment:pathSegment];

                    [newSegmentsArray addObject:newPathSegment];
                }

                for (NSInteger i = 1; i <= -offset; i++)
                {
                    PathSegment * pathSegment = [pathSegmentsArray objectAtIndex:i];
                    
                    PathSegment * newPathSegment = [[PathSegment alloc] init];
                    [newPathSegment copyValuesFromPathSegment:pathSegment];

                    [newSegmentsArray addObject:newPathSegment];
                }
                
                if (lastSegmentIsClosePath == YES)
                {
                    PathSegment * closePathSegment = [[PathSegment alloc] init];
                    closePathSegment.pathCommand = 'Z';
                    
                    [newSegmentsArray addObject:closePathSegment];
                }

            }
            else if (offset > 0)
            {
                // right rotation
                
                NSInteger startSegmentIndex = lastSegmentIndex - offset;

                PathSegment * startPathSegment = [pathSegmentsArray objectAtIndex:startSegmentIndex];
                float startX = startPathSegment.absoluteXFloat;
                float startY = startPathSegment.absoluteYFloat;
                
                NSString * startXString = [self allocFloatString:startX];
                NSString * startYString = [self allocFloatString:startY];
                
                PathSegment * newFirstPathSegment = [[PathSegment alloc] init];
                newFirstPathSegment.pathCommand = 'M';
                newFirstPathSegment.absoluteXFloat = startX;
                newFirstPathSegment.absoluteYFloat = startY;
                newFirstPathSegment.absoluteStartXFloat = startX;
                newFirstPathSegment.absoluteStartYFloat = startY;
                newFirstPathSegment.xString = startXString;
                newFirstPathSegment.yString = startYString;
                
                [newSegmentsArray addObject:newFirstPathSegment];
                
                for (NSInteger i = startSegmentIndex + 1; i <= lastSegmentIndex; i++)
                {
                    PathSegment * pathSegment = [pathSegmentsArray objectAtIndex:i];

                    PathSegment * newPathSegment = [[PathSegment alloc] init];
                    [newPathSegment copyValuesFromPathSegment:pathSegment];

                    [newSegmentsArray addObject:newPathSegment];
                }

                for (NSInteger i = 1; i < lastSegmentIndex - offset + 1; i++)
                {
                    PathSegment * pathSegment = [pathSegmentsArray objectAtIndex:i];
                    
                    PathSegment * newPathSegment = [[PathSegment alloc] init];
                    [newPathSegment copyValuesFromPathSegment:pathSegment];

                    [newSegmentsArray addObject:newPathSegment];
                }
                
                if (lastSegmentIsClosePath == YES)
                {
                    PathSegment * closePathSegment = [[PathSegment alloc] init];
                    
                    [newSegmentsArray addObject:closePathSegment];
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

float degreesToRadians(float degree)
{
    return (degree * M_PI) / 180;
}

//==================================================================================
//	radiansToDegrees()
//==================================================================================

float radiansToDegrees(float radians)
{
    return (radians * 180) / (M_PI);
}

//==================================================================================
//	convertArcToEndPointWithRotation:angleStart:angleExtent:
//==================================================================================

/**
 * Conversion from center to endpoint parameterization
 * - following: http://www.w3.org/TR/SVG11/implnote.html#ArcConversionCenterToEndpoint
 * @param	a Arc
 * @return	Object containing parameters {start<Point>, end<Point>, rx<Number>, ry<Number>, rotation<Number>, isLarge<Boolean>, isClockwise<Boolean>}
 */
- (NSDictionary *) convertArcToEndPointWithRotation:(float)rotation angleStart:(float)angleStart angleExtent:(float)angleExtent
        cx:(float)cx cy:(float)cy rx:(float)rx ry:(float)ry
{
    // http://www.w3.org/TR/SVG11/implnote.html#ArcConversionCenterToEndpoint
    float radRotation = degreesToRadians(rotation);
    float radStart = degreesToRadians(angleStart);
    float radExtent = degreesToRadians(angleExtent);
    float sinRotation = sinf(radRotation);
    float cosRotation = cosf(radRotation);
    
    CGPoint start = CGPointZero;
    float rxcos = rx * cosf(radStart);
    float rysin = ry * sinf(radStart);
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
    * - Conversion from endpoint to center parameterization following: http://www.w3.org/TR/SVG11/implnote.html#ArcImplementationNotes
    * @param	start	Start Point
    * @param	end	End Point
    * @param	rx	X radii of the ellipse
    * @param	ry	Y radii of the ellipse
    * @param	rotation Rotation angle of the ellipse (in degrees)
    * @param	isLarge	Define if is a large arc (large-arc-flag)
    * @param	isCounterClockwise	Define if arc should be draw clockwise (sweep-flag)
    */
- (NSDictionary *) convertArcToCenterPointWithStart:(CGPoint)start end:(CGPoint)end rx:(float)rx ry:(float)ry
        rotation:(float)rotation isLarge:(BOOL)isLarge isCounterClockwise:(BOOL)isCounterClockwise
{
    // adapted from https://github.com/millermedeiros/SVGParser/blob/master/com/millermedeiros/geom/SVGArc.as
    // http://www.w3.org/TR/SVG11/implnote.html#ArcImplementationNotes

    //midpoint
    float midX = (start.x - end.x) / 2;
    float midY = (start.y - end.y) / 2;

    //rotation
    float radRotation = degreesToRadians(rotation);
    float sinRotation = sinf(radRotation);
    float cosRotation = cosf(radRotation);

    //(x1', y1')
    float x1 = cosRotation * midX + sinRotation * midY;
    float y1 = -sinRotation * midX + cosRotation * midY;

    // Correction of out-of-range radii
    if (rx == 0 || ry == 0)
    {
        // throw new Error("rx and rx can't be equal to zero !!"); // Ensure radii are non-zero
        return NULL;
    }

    float abs_rx = fabs(rx);
    float abs_ry = fabs(ry);
    
    float x1_2 = x1 * x1;
    float y1_2 = y1 * y1;
    float rx_2 = abs_rx * abs_rx;
    float ry_2 = abs_ry * abs_ry;
    
    float radiiFix = (x1_2 / rx_2) + (y1_2 / ry_2);
    
    if(radiiFix > 1)
    {
        abs_rx = sqrt(radiiFix) * abs_rx;
        abs_ry = sqrt(radiiFix) * abs_ry;
        rx_2 = abs_rx * abs_rx;
        ry_2 = abs_ry * abs_ry;
    }

    //(cx', cy')
    float cf = ((rx_2 * ry_2) - (rx_2 * y1_2) - (ry_2 * x1_2)) / ((rx_2 * y1_2) + (ry_2 * x1_2));
    cf = (cf > 0)? cf : 0;
    float sqr = sqrt(cf);
    sqr *= (isLarge != isCounterClockwise)? 1 : -1;
    float cx1 = sqr * ((abs_rx * y1) / abs_ry);
    float cy1 = sqr * -((abs_ry * x1) / abs_rx);

    //(cx, cy) from (cx', cy')
    float cx = (cosRotation * cx1 - sinRotation * cy1) + ((start.x + end.x) / 2);
    float cy = (sinRotation * cx1 + cosRotation * cy1) + ((start.y + end.y) / 2);

    // angleStart and angleExtent
    float ux = (x1 - cx1) / abs_rx;
    float uy = (y1 - cy1) / abs_ry;
    float vx = (-x1 - cx1) / abs_rx;
    float vy = (-y1 - cy1) / abs_ry;
    float uv = ux*vx + uy*vy; // u.v
    float u_norm = sqrt(ux*ux + uy*uy); // ||u||
    float uv_norm = sqrt((ux*ux + uy*uy) * (vx*vx + vy*vy)); // ||u||||v||
    
    NSInteger sign = (uy < 0)? -1 : 1; //((1,0),(vx, vy))
    
    float angleStart = radiansToDegrees( sign * acos(ux / u_norm));
    sign = ((ux * vy - uy * vx) < 0) ? -1 : 1; //((ux,uy),(vx, vy))
    float angleExtent = radiansToDegrees( sign * acos(uv / uv_norm));
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
// See also SVG implementation notes: http://www.w3.org/TR/SVG11/implnote.html#ArcConversionEndpointToCenter
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
    // http://www.w3.org/TR/SVG11/implnote.html#ArcCorrectionOutOfRangeRadii
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
