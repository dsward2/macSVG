//
//  SVGPathEditor.m
//  macSVG
//
//  Created by Douglas Ward on 11/14/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "SVGPathEditor.h"
#import "SVGWebKitController.h"
#import "SVGWebView.h"
#import "MacSVGDocumentWindowController.h"
#import "DOMMouseEventsController.h"
#import "SVGXMLDOMSelectionManager.h"
#import "WebKitInterface.h"
#import "MacSVGAppDelegate.h"
#import "SelectedElementsManager.h"
#import "ToolSettingsPopoverViewController.h"
#import "EditorUIFrameController.h"
#import "ElementEditorPluginController.h"
#import "MacSVGPlugin/MacSVGPlugin.h"
#import "MacSVGDocument.h"
#import "DOMSelectionRectsAndHandlesManager.h"

//@class PathElementEditor;

/* 
    Printing description of self->pathSegmentsArray:
    <NSCFArray 0x100523410>(
    {
        command = M;
        x = 200;
        y = 193;
    },
    {
        command = C;
        x = 381;
        x1 = 292;
        x2 = 434;
        y = 356;
        y1 = 194;
        y2 = 206;
    },
    {
        command = C;
        x = 406;
        x1 = 328;
        x2 = 210;
        y = 665;
        y1 = 506;
        y2 = 639;
    },
    {
        command = C;
        x = 23;
        x1 = 602;
        x2 = 23;
        y = 234;
        y1 = 691;
        y2 = 234;
    }
    )
*/

@implementation SVGPathEditor

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.pathSegmentsArray = NULL;
    self.selectedPathElement = NULL;
    self.pathEditingKey = NULL;

    self.largeArcFlagString = NULL;
    self.sweepFlagString = NULL;
    self.xAxisRotationString = NULL;
    self.pathRadiusXString = NULL;
    self.pathRadiusYString = NULL;
    self.parametersMoveto = NULL;
    self.parametersLineto = NULL;
    self.parametersHorizontalLineto = NULL;
    self.parametersVerticalLineto = NULL;
    self.parametersCubicCurveto = NULL;
    self.parametersCubicCurvetoSmooth = NULL;
    self.parametersQuadraticCurveto = NULL;
    self.parametersQuadraticCurvetoSmooth = NULL;
    self.parametersEllipticalArc = NULL;
    self.parametersClosepath = NULL;
}

//==================================================================================
//	init
//==================================================================================

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
        self.selectedPathElement = NULL;
        
        self.pathSegmentIndex = -1;
        self.pathEditingKey = @"";
        
        editingMode = kPathEditingModeNotActive;

        self.useRelativePathCoordinates = NO;
        self.closePathAutomatically = NO;
        self.curveSegmentContinuity = YES;
        
        self.largeArcFlagString = [[NSMutableString alloc] initWithString:@"0"];
        self.sweepFlagString = [[NSMutableString alloc] initWithString:@"0"];
        self.xAxisRotationString = [[NSMutableString alloc] initWithString:@"0"];
        self.pathRadiusXString = [[NSMutableString alloc] initWithString:@"20"];
        self.pathRadiusYString = [[NSMutableString alloc] initWithString:@"20"];
        
        self.pathSegmentsArray = [[NSMutableArray alloc] init];

        self.parametersMoveto = [[NSArray alloc] initWithObjects:@"x", @"y", NULL];
        self.parametersLineto = [[NSArray alloc] initWithObjects:@"x", @"y", NULL];
        self.parametersHorizontalLineto = [[NSArray alloc] initWithObjects:@"x", NULL];
        self.parametersVerticalLineto = [[NSArray alloc] initWithObjects:@"y", NULL];
        self.parametersCubicCurveto = [[NSArray alloc] initWithObjects:@"x1", @"y1", @"x2", @"y2", @"x", @"y", NULL];
        self.parametersCubicCurvetoSmooth = [[NSArray alloc] initWithObjects:@"x2", @"y2", @"x", @"y", NULL];
        self.parametersQuadraticCurveto = [[NSArray alloc] initWithObjects:@"x1", @"y1", @"x", @"y", NULL];
        self.parametersQuadraticCurvetoSmooth = [[NSArray alloc] initWithObjects:@"x", @"y", NULL];
        self.parametersEllipticalArc = [[NSArray alloc] initWithObjects:@"rx", @"ry", @"x-axis-rotation", @"large-arc-flag", @"sweep-flag", @"x", @"y", NULL];
        self.parametersClosepath = [[NSArray alloc] init];
    }
    
    return self;
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
        NSUInteger stringLength = [aString length];
        
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
//	allocPxString:
//==================================================================================

- (NSMutableString *)allocPxString:(float)aFloat
{
    NSMutableString * aString = [[NSMutableString alloc] initWithFormat:@"%f", aFloat];

    BOOL continueTrim = YES;
    while (continueTrim == YES)
    {
        NSUInteger stringLength = [aString length];
        
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
    
    [aString appendString:@"px"];
    
    return aString;
}

//==================================================================================
//	absoluteXYPointAtPathSegmentIndex:
//==================================================================================

- (NSPoint)absoluteXYPointAtPathSegmentIndex:(NSInteger)segmentIndex
{
    NSPoint resultPoint = NSZeroPoint;

    if (segmentIndex >= 0)
    {
        if (segmentIndex < [self.pathSegmentsArray count])
        {
            NSMutableDictionary * currentSegmentDictionary = [self.pathSegmentsArray objectAtIndex:segmentIndex];
            NSNumber * absoluteXNumber = [currentSegmentDictionary objectForKey:@"absoluteX"];
            NSNumber * absoluteYNumber = [currentSegmentDictionary objectForKey:@"absoluteY"];
            
            float absoluteX = [absoluteXNumber floatValue];
            float absoluteY = [absoluteYNumber floatValue];
            
            resultPoint = NSMakePoint(absoluteX, absoluteY);
        }
    }
    
    return resultPoint;
}


//==================================================================================
//	buildPathSegmentsArrayWithPathString:
//==================================================================================

#define kSeparatorMode 0
#define kCommandMode 1
#define kValueMode 2


- (NSMutableArray *)buildPathSegmentsArrayWithPathString:(NSString *)aPathString
{
    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSString * pathString = [aPathString stringByTrimmingCharactersInSet:whitespaceSet];

    NSMutableArray * newPathSegmentsArray = [[NSMutableArray alloc] init];
    
    NSUInteger pathStringLength = [pathString length];
    
    int previousMode = kSeparatorMode;
    int newMode = kSeparatorMode;
    unichar newCommand = '?';
            
    NSArray * currentParameterNames = NULL;
    
    NSMutableDictionary * currentSegmentDictionary = [[NSMutableDictionary alloc] init];
    
    NSMutableString * valueString = [[NSMutableString alloc] init];
    
    for (int i = 0; i <= pathStringLength; i++) // intentionally one character past end of string length
    {
        unichar aChar = ' ';    // a space character for padding at end of pathString
        
        if (i < pathStringLength)
        {
            aChar = [pathString characterAtIndex:i];
        }
        
        switch (aChar) 
        {
            case ' ':
            case ',':
            case 0x09:
            case 0x0d:
            case 0x0a:
                newMode = kSeparatorMode;
                break;

            case '+':
            case '-':
            case '.':
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
            case 'e':
                newMode = kValueMode;  // value mode
                break;

            case 'M':     // moveto
            case 'm':     // moveto
            case 'L':     // lineto
            case 'l':     // lineto
            case 'H':     // horizontal lineto
            case 'h':     // horizontal lineto
            case 'V':     // vertical lineto
            case 'v':     // vertical lineto
            case 'C':     // curveto
            case 'c':     // curveto
            case 'S':     // smooth curveto
            case 's':     // smooth curveto
            case 'Q':     // quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
            case 'T':     // smooth quadratic Bezier curve
            case 't':     // smooth quadratic Bezier curve
            case 'A':     // elliptical arc
            case 'a':     // elliptical arc
            case 'Z':     // closepath
            case 'z':     // closepath
                newMode = kCommandMode;  // command mode
                newCommand = aChar;
                break;

            default:
                newMode = kSeparatorMode;  // separator mode
                break;
        }
        
        BOOL endOfParameterFound = NO;
        BOOL endOfSegment = NO;

        if (newMode == kValueMode)
        {
            // character is for a value
            if (aChar == '-') 
            {
                if ([valueString length] > 0)
                {
                    unichar previousChar = ' ';
                    if (i > 0)
                    {
                        previousChar = [pathString characterAtIndex:(i - 1)];
                    }
                    
                    if (previousChar != 'e')
                    {
                        // minus sign allowed only at the beginning of a value
                        endOfParameterFound = YES;
                    }
                }
            }
            
            if (aChar == '.') 
            {
                NSRange decimalRange = [valueString rangeOfString:@"."];
                if (decimalRange.location != NSNotFound)
                {
                    // only one decimal allowed in a value
                    endOfParameterFound = YES;
                }
            }
        }

        if ((newMode == kCommandMode) || (newMode == kSeparatorMode))
        {
            if (previousMode == kValueMode)
            {
                endOfParameterFound = YES;
            }
        }
        
        if (endOfParameterFound == YES)
        {
            NSUInteger parameterNamesCount = [currentParameterNames count];
            NSUInteger currentSegmentDictionaryCount = [currentSegmentDictionary count];
            NSInteger parametersCount = currentSegmentDictionaryCount - 1;
            
            if ((newCommand != 'z') && (newCommand != 'Z'))
            {
                if (parametersCount < 0)
                {
                    // a new segment is started, apparently a repeat of the previous command, omitting the command character, as Inkscape does
                    NSInteger segmentsCount = [newPathSegmentsArray count];
                    if (segmentsCount > 0)
                    {
                        NSDictionary * previousSegmentDictionary = [newPathSegmentsArray objectAtIndex:segmentsCount - 1];
                        NSString * previousSegmentCommand = [previousSegmentDictionary objectForKey:@"command"];
                        [currentSegmentDictionary setObject:previousSegmentCommand forKey:@"command"];
                        parametersCount = 0;
                    }
                }

                NSString * newParameter = [[NSString alloc] initWithString:valueString];
                
                NSString * keyForParameter = [currentParameterNames objectAtIndex:parametersCount];
                
                [currentSegmentDictionary setObject:newParameter forKey:keyForParameter];
                parametersCount++;
            }
            else
            {
                NSString * newParameter = [[NSString alloc] initWithString:valueString];
                
                NSString * keyForParameter = [currentParameterNames objectAtIndex:parametersCount];
                
                [currentSegmentDictionary setObject:newParameter forKey:keyForParameter];
                parametersCount++;
            }
            
            if (parametersCount >= parameterNamesCount)
            {
                endOfSegment = YES;
            }
            
            if (newMode == kCommandMode) 
            {
                endOfSegment = YES;
            }
        }

        if ((newCommand == 'Z') || (newCommand == 'z'))
        {
            endOfSegment = YES;
        }
        
        if (endOfSegment == YES)
        {
            // all parameters collected for current command
            if ([currentSegmentDictionary count] > 0)
            {
                NSMutableDictionary * newSegmentDictionary = [[NSMutableDictionary alloc] initWithDictionary:currentSegmentDictionary];

                [newPathSegmentsArray addObject:newSegmentDictionary];
                
                [currentSegmentDictionary removeAllObjects];
            }
            else
            {
                // currentSegmentDictionary was empty
            }
        }
            
        if (endOfParameterFound == YES)
        {
            [valueString setString:@""];
        }
        
        if (newMode == kCommandMode)
        {
            // start new command
            switch (aChar) 
            {
                case 'M':     // moveto
                case 'm':     // moveto
                    currentParameterNames = self.parametersMoveto;
                    break;

                case 'L':     // lineto
                case 'l':     // lineto
                    currentParameterNames = self.parametersLineto;
                    break;

                case 'H':     // horizontal lineto
                case 'h':     // horizontal lineto
                    currentParameterNames = self.parametersHorizontalLineto;
                    break;

                case 'V':     // vertical lineto
                case 'v':     // vertical lineto
                    currentParameterNames = self.parametersVerticalLineto;
                    break;

                case 'C':     // curveto
                case 'c':     // curveto
                    currentParameterNames = self.parametersCubicCurveto;
                    break;

                case 'S':     // smooth curveto
                case 's':     // smooth curveto
                    currentParameterNames = self.parametersCubicCurvetoSmooth;
                    break;

                case 'Q':     // quadratic Bezier curve
                case 'q':     // quadratic Bezier curve
                    currentParameterNames = self.parametersQuadraticCurveto;
                    break;

                case 'T':     // smooth quadratic Bezier curve
                case 't':     // smooth quadratic Bezier curve
                    currentParameterNames = self.parametersQuadraticCurvetoSmooth;
                    break;

                case 'A':     // elliptical arc
                case 'a':     // elliptical arc
                    currentParameterNames = self.parametersEllipticalArc;
                    break;

                case 'Z':     // closepath
                case 'z':     // closepath
                    currentParameterNames = self.parametersClosepath;
                    break;
            }
            
            //NSMutableDictionary * segmentDictionary = [[NSMutableDictionary alloc] init];
            [currentSegmentDictionary removeAllObjects];
            
            NSString * newModeString = [[NSString alloc] initWithFormat:@"%C", aChar];
            
            [currentSegmentDictionary setObject:newModeString forKey:@"command"];
            
            [valueString setString:@""];
        }
        
        if (newMode == kValueMode)
        {
            // character is for a value
            [valueString appendFormat:@"%C", aChar];
        }
        
        previousMode = newMode;
    }
    
    [self updatePathSegmentsAbsoluteValues:newPathSegmentsArray];
    
    return newPathSegmentsArray;
}

//==================================================================================
//	updatePathSegmentsAbsoluteValues
//==================================================================================

- (void)updatePathSegmentsAbsoluteValues:(NSMutableArray *)aPathSegmentsArray
{
    // If a "closepath" is followed immediately by a "moveto",
    // then the "moveto" identifies the start point of the next subpath.
    // If a "closepath" is followed immediately by any other command,
    // then the next subpath starts at the same initial point as the current subpath.

    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat segmentAbsoluteX = 0;
    CGFloat segmentAbsoluteY = 0;
    CGFloat segmentAbsoluteX1 = 0;
    CGFloat segmentAbsoluteY1 = 0;
    CGFloat segmentAbsoluteX2 = 0;
    CGFloat segmentAbsoluteY2 = 0;
    CGFloat segmentAbsoluteStartX = 0;
    CGFloat segmentAbsoluteStartY = 0;
    CGFloat subpathAbsoluteStartX = NSNotFound;
    CGFloat subpathAbsoluteStartY = NSNotFound;
    
    unichar previousCommandChar = 'Z';
    
    NSInteger pathSegmentsArrayCount = [aPathSegmentsArray count];

    
    for (NSInteger currentSegmentIndex = 0; currentSegmentIndex < pathSegmentsArrayCount;
            currentSegmentIndex++)
    {

        NSMutableDictionary * currentSegmentDictionary =
                [aPathSegmentsArray objectAtIndex:currentSegmentIndex];
        
        NSString * commandString = [currentSegmentDictionary objectForKey:@"command"];
        unichar commandChar = [commandString characterAtIndex:0];
        
        BOOL isRelative = NO;
        if ((commandChar >= 'a') && (commandChar <= 'z'))
        {
            if (currentSegmentIndex > 0)
            {
                isRelative = YES;
            }
        }
        
        // 20160807 - fix absoluteStartX/Y for first segment
        if (currentSegmentIndex == 0)
        {
            if (isRelative == NO)
            {
                NSString * xString = [currentSegmentDictionary objectForKey:@"x"];
                NSString * yString = [currentSegmentDictionary objectForKey:@"y"];
        
                segmentAbsoluteStartX = [xString floatValue];
                segmentAbsoluteStartY = [yString floatValue];
            }
        }

        NSNumber * absoluteStartXNumber = [NSNumber numberWithFloat:segmentAbsoluteStartX];
        NSNumber * absoluteStartYNumber = [NSNumber numberWithFloat:segmentAbsoluteStartY];
        
        [currentSegmentDictionary setObject:absoluteStartXNumber forKey:@"absoluteStartX"];
        [currentSegmentDictionary setObject:absoluteStartYNumber forKey:@"absoluteStartY"];
        

        switch (commandChar)
        {
            case 'M':     // moveto absolute
            case 'm':     // moveto relative
            {
                NSString * xString = [currentSegmentDictionary objectForKey:@"x"];
                NSString * yString = [currentSegmentDictionary objectForKey:@"y"];
                
                x = [xString floatValue];
                y = [yString floatValue];

                if (isRelative == YES)
                {
                    segmentAbsoluteX = segmentAbsoluteStartX + x;
                    segmentAbsoluteY = segmentAbsoluteStartY + y;
                }
                else
                {
                    segmentAbsoluteX = x;
                    segmentAbsoluteY = y;
                }
                
                NSNumber * absoluteXNumber = [NSNumber numberWithFloat:segmentAbsoluteX];
                NSNumber * absoluteYNumber = [NSNumber numberWithFloat:segmentAbsoluteY];
                
                [currentSegmentDictionary setObject:absoluteXNumber forKey:@"absoluteX"];
                [currentSegmentDictionary setObject:absoluteYNumber forKey:@"absoluteY"];
                
                if ((previousCommandChar == 'Z') || (previousCommandChar == 'z'))
                {
                    subpathAbsoluteStartX = segmentAbsoluteStartX;
                    subpathAbsoluteStartY = segmentAbsoluteStartY;
                }
                
                break;
            }

            case 'L':     // lineto absolute
            case 'l':     // lineto relative
            {
                NSString * xString = [currentSegmentDictionary objectForKey:@"x"];
                NSString * yString = [currentSegmentDictionary objectForKey:@"y"];
                
                x = [xString floatValue];
                y = [yString floatValue];

                if (isRelative == YES)
                {
                    segmentAbsoluteX = segmentAbsoluteStartX + x;
                    segmentAbsoluteY = segmentAbsoluteStartY + y;
                }
                else
                {
                    segmentAbsoluteX = x;
                    segmentAbsoluteY = y;
                }
                
                NSNumber * absoluteXNumber = [NSNumber numberWithFloat:segmentAbsoluteX];
                NSNumber * absoluteYNumber = [NSNumber numberWithFloat:segmentAbsoluteY];
                
                [currentSegmentDictionary setObject:absoluteXNumber forKey:@"absoluteX"];
                [currentSegmentDictionary setObject:absoluteYNumber forKey:@"absoluteY"];
                
                break;
            }

            case 'H':     // horizontal lineto absolute
            case 'h':     // horizontal lineto relative
            {
                NSString * xString = [currentSegmentDictionary objectForKey:@"x"];
                
                x = [xString floatValue];
                
                if (isRelative == YES)
                {
                    segmentAbsoluteX = segmentAbsoluteStartX + x;
                }
                else
                {
                    segmentAbsoluteX = x;
                }
                
                NSNumber * absoluteXNumber = [NSNumber numberWithFloat:segmentAbsoluteX];
                NSNumber * absoluteYNumber = [NSNumber numberWithFloat:segmentAbsoluteY];
                
                [currentSegmentDictionary setObject:absoluteXNumber forKey:@"absoluteX"];
                [currentSegmentDictionary setObject:absoluteYNumber forKey:@"absoluteY"];
                
                break;
            }

            case 'V':     // vertical lineto absolute
            case 'v':     // vertical lineto relative
            {
                NSString * yString = [currentSegmentDictionary objectForKey:@"y"];
                
                y = [yString floatValue];
                
                if (isRelative == YES)
                {
                    segmentAbsoluteY = segmentAbsoluteStartY + y;
                }
                else
                {
                    segmentAbsoluteY = y;
                }
                
                NSNumber * absoluteXNumber = [NSNumber numberWithFloat:segmentAbsoluteX];
                NSNumber * absoluteYNumber = [NSNumber numberWithFloat:segmentAbsoluteY];
                
                [currentSegmentDictionary setObject:absoluteXNumber forKey:@"absoluteX"];
                [currentSegmentDictionary setObject:absoluteYNumber forKey:@"absoluteY"];
                
                break;
            }

            case 'C':     // curveto absolute
            case 'c':     // curveto relative
            {
                NSString * xString = [currentSegmentDictionary objectForKey:@"x"];
                NSString * yString = [currentSegmentDictionary objectForKey:@"y"];
                NSString * x1String = [currentSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [currentSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [currentSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [currentSegmentDictionary objectForKey:@"y2"];
                
                x = [xString floatValue];
                y = [yString floatValue];
                CGFloat x1 = [x1String floatValue];
                CGFloat y1 = [y1String floatValue];
                CGFloat x2 = [x2String floatValue];
                CGFloat y2 = [y2String floatValue];
                
                if (isRelative == YES)
                {
                    segmentAbsoluteX = segmentAbsoluteStartX + x;
                    segmentAbsoluteY = segmentAbsoluteStartY + y;
                    segmentAbsoluteX1 = segmentAbsoluteStartX + x1;
                    segmentAbsoluteY1 = segmentAbsoluteStartY + y1;
                    segmentAbsoluteX2 = segmentAbsoluteStartX + x2;
                    segmentAbsoluteY2 = segmentAbsoluteStartY + y2;
                }
                else
                {
                    segmentAbsoluteX = x;
                    segmentAbsoluteY = y;
                    segmentAbsoluteX1 = x1;
                    segmentAbsoluteY1 = y1;
                    segmentAbsoluteX2 = x2;
                    segmentAbsoluteY2 = y2;
                }
                
                NSNumber * absoluteXNumber = [NSNumber numberWithFloat:segmentAbsoluteX];
                NSNumber * absoluteYNumber = [NSNumber numberWithFloat:segmentAbsoluteY];
                NSNumber * absoluteX1Number = [NSNumber numberWithFloat:segmentAbsoluteX1];
                NSNumber * absoluteY1Number = [NSNumber numberWithFloat:segmentAbsoluteY1];
                NSNumber * absoluteX2Number = [NSNumber numberWithFloat:segmentAbsoluteX2];
                NSNumber * absoluteY2Number = [NSNumber numberWithFloat:segmentAbsoluteY2];
                
                [currentSegmentDictionary setObject:absoluteXNumber forKey:@"absoluteX"];
                [currentSegmentDictionary setObject:absoluteYNumber forKey:@"absoluteY"];
                [currentSegmentDictionary setObject:absoluteX1Number forKey:@"absoluteX1"];
                [currentSegmentDictionary setObject:absoluteY1Number forKey:@"absoluteY1"];
                [currentSegmentDictionary setObject:absoluteX2Number forKey:@"absoluteX2"];
                [currentSegmentDictionary setObject:absoluteY2Number forKey:@"absoluteY2"];
                
                break;
            }

            case 'S':     // smooth curveto absolute
            case 's':     // smooth curveto relative
            {
                NSString * xString = [currentSegmentDictionary objectForKey:@"x"];
                NSString * yString = [currentSegmentDictionary objectForKey:@"y"];
                NSString * x2String = [currentSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [currentSegmentDictionary objectForKey:@"y2"];

                x = [xString floatValue];
                y = [yString floatValue];
                CGFloat x2 = [x2String floatValue];
                CGFloat y2 = [y2String floatValue];
                
                if (isRelative == YES)
                {
                    segmentAbsoluteX = segmentAbsoluteStartX + x;
                    segmentAbsoluteY = segmentAbsoluteStartY + y;
                    segmentAbsoluteX2 = segmentAbsoluteStartX + x2;
                    segmentAbsoluteY2 = segmentAbsoluteStartY + y2;
                }
                else
                {
                    segmentAbsoluteX = x;
                    segmentAbsoluteY = y;
                    segmentAbsoluteX2 = x2;
                    segmentAbsoluteY2 = y2;
                }
                
                NSNumber * absoluteXNumber = [NSNumber numberWithFloat:segmentAbsoluteX];
                NSNumber * absoluteYNumber = [NSNumber numberWithFloat:segmentAbsoluteY];
                NSNumber * absoluteX2Number = [NSNumber numberWithFloat:segmentAbsoluteX2];
                NSNumber * absoluteY2Number = [NSNumber numberWithFloat:segmentAbsoluteY2];
                
                [currentSegmentDictionary setObject:absoluteXNumber forKey:@"absoluteX"];
                [currentSegmentDictionary setObject:absoluteYNumber forKey:@"absoluteY"];
                [currentSegmentDictionary setObject:absoluteX2Number forKey:@"absoluteX2"];
                [currentSegmentDictionary setObject:absoluteY2Number forKey:@"absoluteY2"];

                break;
            }

            case 'Q':     // quadratic Bezier curve absolute
            case 'q':     // quadratic Bezier curve relative
            {
                NSString * xString = [currentSegmentDictionary objectForKey:@"x"];
                NSString * yString = [currentSegmentDictionary objectForKey:@"y"];
                NSString * x1String = [currentSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [currentSegmentDictionary objectForKey:@"y1"];
                
                x = [xString floatValue];
                y = [yString floatValue];
                CGFloat x1 = [x1String floatValue];
                CGFloat y1 = [y1String floatValue];
                
                if (isRelative == YES)
                {
                    segmentAbsoluteX = segmentAbsoluteStartX + x;
                    segmentAbsoluteY = segmentAbsoluteStartY + y;
                    segmentAbsoluteX1 = segmentAbsoluteStartX + x1;
                    segmentAbsoluteY1 = segmentAbsoluteStartY + y1;
                }
                else
                {
                    segmentAbsoluteX = x;
                    segmentAbsoluteY = y;
                    segmentAbsoluteX1 = x1;
                    segmentAbsoluteY1 = y1;
                }
                
                NSNumber * absoluteXNumber = [NSNumber numberWithFloat:segmentAbsoluteX];
                NSNumber * absoluteYNumber = [NSNumber numberWithFloat:segmentAbsoluteY];
                NSNumber * absoluteX1Number = [NSNumber numberWithFloat:segmentAbsoluteX1];
                NSNumber * absoluteY1Number = [NSNumber numberWithFloat:segmentAbsoluteY1];
                
                [currentSegmentDictionary setObject:absoluteXNumber forKey:@"absoluteX"];
                [currentSegmentDictionary setObject:absoluteYNumber forKey:@"absoluteY"];
                [currentSegmentDictionary setObject:absoluteX1Number forKey:@"absoluteX1"];
                [currentSegmentDictionary setObject:absoluteY1Number forKey:@"absoluteY1"];

                break;
            }

            case 'T':     // smooth quadratic Bezier curve absolute
            case 't':     // smooth quadratic Bezier curve relative
            {
                NSString * xString = [currentSegmentDictionary objectForKey:@"x"];
                NSString * yString = [currentSegmentDictionary objectForKey:@"y"];
                
                x = [xString floatValue];
                y = [yString floatValue];
                
                if (isRelative == YES)
                {
                    segmentAbsoluteX = segmentAbsoluteStartX + x;
                    segmentAbsoluteY = segmentAbsoluteStartY + y;
                }
                else
                {
                    segmentAbsoluteX = x;
                    segmentAbsoluteY = y;
                }
                
                NSNumber * absoluteXNumber = [NSNumber numberWithFloat:segmentAbsoluteX];
                NSNumber * absoluteYNumber = [NSNumber numberWithFloat:segmentAbsoluteY];
                
                [currentSegmentDictionary setObject:absoluteXNumber forKey:@"absoluteX"];
                [currentSegmentDictionary setObject:absoluteYNumber forKey:@"absoluteY"];
                
                break;
            }

            case 'A':     // elliptical arc absolute
            case 'a':     // elliptical arc relative
            {
                NSString * xString = [currentSegmentDictionary objectForKey:@"x"];
                NSString * yString = [currentSegmentDictionary objectForKey:@"y"];
                
                x = [xString floatValue];
                y = [yString floatValue];
                
                if (isRelative == YES)
                {
                    segmentAbsoluteX = segmentAbsoluteStartX + x;
                    segmentAbsoluteY = segmentAbsoluteStartY + y;
                }
                else
                {
                    segmentAbsoluteX = x;
                    segmentAbsoluteY = y;
                }
                
                NSNumber * absoluteXNumber = [NSNumber numberWithFloat:segmentAbsoluteX];
                NSNumber * absoluteYNumber = [NSNumber numberWithFloat:segmentAbsoluteY];
                
                [currentSegmentDictionary setObject:absoluteXNumber forKey:@"absoluteX"];
                [currentSegmentDictionary setObject:absoluteYNumber forKey:@"absoluteY"];
                
                break;
            }

            case 'Z':     // closepath absolute
            case 'z':     // closepath relative
            {
                if (subpathAbsoluteStartX == NSNotFound)
                {
                    subpathAbsoluteStartX = segmentAbsoluteStartX;
                    subpathAbsoluteStartY = segmentAbsoluteStartY;
                }

                segmentAbsoluteStartX = subpathAbsoluteStartX;
                segmentAbsoluteStartY = subpathAbsoluteStartY;
                
                NSNumber * absoluteXNumber = [NSNumber numberWithFloat:segmentAbsoluteStartX];
                NSNumber * absoluteYNumber = [NSNumber numberWithFloat:segmentAbsoluteStartY];
                
                [currentSegmentDictionary setObject:absoluteXNumber forKey:@"absoluteX"];
                [currentSegmentDictionary setObject:absoluteYNumber forKey:@"absoluteY"];
                break;
            }
        }
        
        previousCommandChar = commandChar;
        
        if (subpathAbsoluteStartX == NSNotFound)
        {
            subpathAbsoluteStartX = segmentAbsoluteStartX;
            subpathAbsoluteStartX = segmentAbsoluteStartY;
        }
        
        segmentAbsoluteStartX = segmentAbsoluteX;
        segmentAbsoluteStartY = segmentAbsoluteY;
    }
}

//==================================================================================
//	buildPathSegmentsArray
//==================================================================================

- (void)buildPathSegmentsArray:(NSXMLElement *)pathElement
{
    NSXMLNode * pathAttribute = [pathElement attributeForName:@"d"];
    NSString * pathString = [pathAttribute stringValue];
    
    NSMutableArray * activePathSegmentsArray = [self buildPathSegmentsArrayWithPathString:pathString];
    
    [self resetPathSegmentsArray];

    [self.pathSegmentsArray setArray:activePathSegmentsArray];
    
    self.selectedPathElement = pathElement;
}

//==================================================================================
//	endPointForSegmentIndex:pathSegmentDictionary:
//==================================================================================

- (NSPoint)endPointForSegmentIndex:(NSInteger)segmentIndex
        pathSegmentsArray:(NSArray *)aPathSegmentsArray
{
    NSPoint resultPoint = NSZeroPoint;
    
    NSDictionary * pathSegmentDictionary = [aPathSegmentsArray objectAtIndex:segmentIndex];

    NSNumber * absoluteStartXNumber = [pathSegmentDictionary objectForKey:@"absoluteStartX"];
    NSNumber * absoluteStartYNumber = [pathSegmentDictionary objectForKey:@"absoluteStartY"];
    
    float absoluteStartXFloat = [absoluteStartXNumber floatValue];
    float absoluteStartYFloat = [absoluteStartYNumber floatValue];

    NSString * commandString = [pathSegmentDictionary objectForKey:@"command"];
    
    unichar commandCharacter = [commandString characterAtIndex:0];

    switch (commandCharacter)
    {
        case 'M':     // moveto
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];

            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];
            
            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'm':     // moveto
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];
            xFloat += absoluteStartXFloat;

            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];
            yFloat += absoluteStartYFloat;
            
            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }
        
        case 'L':     // lineto
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];

            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }
        
        case 'l':     // lineto
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];
            xFloat += absoluteStartXFloat;

            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];
            yFloat += absoluteStartYFloat;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'H':     // horizontal lineto
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];

            resultPoint = NSMakePoint(xFloat, absoluteStartYFloat);
            break;
        }
        
        case 'h':     // horizontal lineto
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];
            xFloat += absoluteStartXFloat;

            resultPoint = NSMakePoint(xFloat, absoluteStartYFloat);
            break;
        }

        case 'V':     // vertical lineto
        {
            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];

            resultPoint = NSMakePoint(absoluteStartXFloat, yFloat);
            break;
        }

        case 'v':     // vertical lineto
        {
            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];
            yFloat += absoluteStartYFloat;

            resultPoint = NSMakePoint(absoluteStartXFloat, yFloat);
            break;
        }

        case 'C':     // curveto
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];

            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'c':     // curveto
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];
            xFloat += absoluteStartXFloat;

            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];
            yFloat += absoluteStartYFloat;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'S':     // smooth curveto
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];

            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 's':     // smooth curveto
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];
            xFloat += absoluteStartXFloat;

            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];
            yFloat += absoluteStartYFloat;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'Q':     // quadratic Bezier curve
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];

            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'q':     // quadratic Bezier curve
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];
            xFloat += absoluteStartXFloat;

            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];
            yFloat += absoluteStartYFloat;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'T':     // smooth quadratic Bezier curve
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];

            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 't':     // smooth quadratic Bezier curve
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];
            xFloat += absoluteStartXFloat;

            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];
            yFloat += absoluteStartYFloat;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'A':     // elliptical arc
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];

            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'a':     // elliptical arc
        {
            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
            float xFloat = [xString floatValue];
            xFloat += absoluteStartXFloat;

            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
            float yFloat = [yString floatValue];
            yFloat += absoluteStartYFloat;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'Z':     // closepath
        case 'z':     // closepath
        {
            NSDictionary * firstPathSegmentDictionary = [aPathSegmentsArray objectAtIndex:segmentIndex];

            NSNumber * firstAbsoluteStartXNumber = [firstPathSegmentDictionary objectForKey:@"absoluteStartX"];
            NSNumber * firstAbsoluteStartYNumber = [firstPathSegmentDictionary objectForKey:@"absoluteStartY"];
            
            float firstAbsoluteStartXFloat = [firstAbsoluteStartXNumber floatValue];
            float firstAbsoluteStartYFloat = [firstAbsoluteStartYNumber floatValue];

            resultPoint = NSMakePoint(firstAbsoluteStartXFloat, firstAbsoluteStartYFloat);

            break;
        }
    }
    
    return resultPoint;
}

//==================================================================================
//	makeHandleLineDOMElementWithX1:y1:x2:y2:
//==================================================================================

- (DOMElement *)makeHandleLineDOMElementWithX1:(NSString *)x1String y1:(NSString *)y1String
        x2:(NSString *)x2String y2:(NSString *)y2String strokeWidth:(NSString *)strokeWidthString
{
    DOMDocument * domDocument = [[svgWebKitController.svgWebView mainFrame] DOMDocument];

    DOMElement * handleLineElement = [domDocument createElementNS:svgNamespace
            qualifiedName:@"line" ];
    [handleLineElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_path_handle_line"];
    [handleLineElement setAttributeNS:NULL qualifiedName:@"pointer-events" value:@"none"]; // disallow selection
    [handleLineElement setAttributeNS:NULL qualifiedName:@"x1" value:x1String];
    [handleLineElement setAttributeNS:NULL qualifiedName:@"y1" value:y1String];
    [handleLineElement setAttributeNS:NULL qualifiedName:@"x2" value:x2String];
    [handleLineElement setAttributeNS:NULL qualifiedName:@"y2" value:y2String];
    [handleLineElement setAttributeNS:NULL qualifiedName:@"fill" value:@"none"];
    [handleLineElement setAttributeNS:NULL qualifiedName:@"stroke"
            value:toolSettingsPopoverViewController.pathLineStrokeColor];
    [handleLineElement setAttributeNS:NULL qualifiedName:@"stroke-linecap" value:@"butt"];
    [handleLineElement setAttributeNS:NULL qualifiedName:@"stroke-linejoin" value:@"miter"];

    [handleLineElement setAttributeNS:NULL qualifiedName:@"stroke-width"
            value:strokeWidthString];
    
    return handleLineElement;
}

//==================================================================================
//	makeHandleCircleDOMElementWithX1:y1:x2:y2:
//==================================================================================

- (DOMElement *)makeHandleCircleDOMElementWithCx:(NSString *)cxString cy:(NSString *)cyString
        strokeWidth:(NSString *)strokeWidthString radius:(NSString *)radiusString
        masterID:(NSString *)masterID segmentIndex:(NSString *)segmentIndexString
        handlePoint:(NSString *)handlePointString

{
    DOMDocument * domDocument = [[svgWebKitController.svgWebView mainFrame] DOMDocument];

    DOMElement * handleCircleElement = [domDocument createElementNS:svgNamespace
            qualifiedName:@"circle" ];
    
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_path_handle"];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"pointer-events" value:@"all"]; // allow selection
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"cx" value:cxString];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"cy" value:cyString];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"fill"
            value:toolSettingsPopoverViewController.pathCurvePointFillColor];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"stroke"
            value:toolSettingsPopoverViewController.pathCurvePointStrokeColor];
    
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"stroke-width"
            value:strokeWidthString];
    
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"r"
            value:radiusString];
    
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"_macsvg_master_Macsvgid" value:masterID];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"_macsvg_path_handle_segment" value:segmentIndexString];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"_macsvg_path_handle_point" value:handlePointString];
    
    return handleCircleElement;
}

//==================================================================================
//	addHandleForMoveto:segmentIndex:pathHandlesGroup
//==================================================================================

-(void) addHandleForMoveto:(NSDictionary *)pathSegmentDictionary  
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
{
    // path commands M,m
    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
    
    NSString * xPxString = [xString stringByAppendingString:@"px"];
    NSString * yPxString = [yString stringByAppendingString:@"px"];

    NSUInteger pathSegmentsCount = [self.pathSegmentsArray count];

    NSString * selectedPathMode = [macSVGDocumentWindowController selectedPathMode];

    CGFloat reciprocalZoomFactor = 1.0f / svgWebKitController.svgWebView.zoomFactor;
    
    NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
    CGFloat pathEndpointStrokeWidthFloat = [pathEndpointStrokeWidthString floatValue];
    pathEndpointStrokeWidthFloat *= reciprocalZoomFactor;
    pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

    NSString * pathLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
    CGFloat pathLineStrokeWidthFloat = [pathLineStrokeWidthString floatValue];
    pathLineStrokeWidthFloat *= reciprocalZoomFactor;
    pathLineStrokeWidthString = [self allocPxString:pathLineStrokeWidthFloat];

    NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
    CGFloat pathEndpointRadiusFloat = [pathEndpointRadiusString floatValue];
    pathEndpointRadiusFloat *= reciprocalZoomFactor;
    pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

    NSString * pathCurvePointStrokeWidthString = toolSettingsPopoverViewController.pathCurvePointStrokeWidth;
    CGFloat pathCurvePointStrokeWidthFloat = [pathCurvePointStrokeWidthString floatValue];
    pathCurvePointStrokeWidthFloat *= reciprocalZoomFactor;
    pathCurvePointStrokeWidthString = [self allocPxString:pathCurvePointStrokeWidthFloat];

    NSString * pathCurvePointRadiusString = toolSettingsPopoverViewController.pathCurvePointRadius;
    CGFloat pathCurvePointRadiusFloat = [pathCurvePointRadiusString floatValue];
    pathCurvePointRadiusFloat *= reciprocalZoomFactor;
    pathCurvePointRadiusString = [self allocPxString:pathCurvePointRadiusFloat];

    NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
    NSString * selectedElementMacsvgid = [selectedElementMacsvgidNode stringValue];
    
    NSString * segmentIndexString = [NSString stringWithFormat:@"%ld", segmentIndex];

    if ([selectedPathMode isEqualToString:@"Cubic Curve"] == YES)
    {
        // we are currently drawing the first segment of a cubic curve
        if ((pathSegmentsCount == 1) && (segmentIndex == 0))
        {
            // reflect a control point for the first segment
            NSString * x1PxString = [self allocPxString:domMouseEventsController.clickPoint.x];
            NSString * y1PxString = [self allocPxString:domMouseEventsController.clickPoint.y];
            NSString * x2PxString = [self allocPxString:domMouseEventsController.currentMousePoint.x];
            NSString * y2PxString = [self allocPxString:domMouseEventsController.currentMousePoint.y];

            float deltaX = domMouseEventsController.currentMousePoint.x - domMouseEventsController.clickPoint.x;
            float deltaY = domMouseEventsController.currentMousePoint.y - domMouseEventsController.clickPoint.y;

            float reflectX2 = domMouseEventsController.clickPoint.x - deltaX;
            float reflectY2 = domMouseEventsController.clickPoint.y - deltaY;

            NSString * reflectX2PxString = [self allocPxString:reflectX2];
            NSString * reflectY2PxString = [self allocPxString:reflectY2];
            
            // Line 1
            
            DOMElement * handleLine1Element = [self makeHandleLineDOMElementWithX1:x1PxString y1:y1PxString
                    x2:reflectX2PxString y2:reflectY2PxString strokeWidth:pathLineStrokeWidthString];

            [pathHandlesGroup appendChild:handleLine1Element];
            
            // Line 2

            DOMElement * handleLine2Element = [self makeHandleLineDOMElementWithX1:x1PxString y1:y1PxString
                    x2:x2PxString y2:y2PxString strokeWidth:pathLineStrokeWidthString];
            
            [pathHandlesGroup appendChild:handleLine2Element];

            // Circle handle x1,y1
            
            DOMElement * handleX1Y1CircleElement =
                    [self makeHandleCircleDOMElementWithCx:reflectX2PxString cy:reflectY2PxString
                    strokeWidth:pathCurvePointStrokeWidthString radius:pathCurvePointRadiusString
                    masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                    handlePoint:@"x1y1"];

            [pathHandlesGroup appendChild:handleX1Y1CircleElement];
            
            // Circle handle x2,y2

            DOMElement * handleX2Y2CircleElement =
                    [self makeHandleCircleDOMElementWithCx:x2PxString cy:y2PxString
                    strokeWidth:pathCurvePointStrokeWidthString radius:pathCurvePointRadiusString
                    masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                    handlePoint:@"x1y1"];

            [pathHandlesGroup appendChild:handleX2Y2CircleElement];
        }
    }

    DOMElement * handleXYCircleElement =
            [self makeHandleCircleDOMElementWithCx:xPxString cy:yPxString
            strokeWidth:pathCurvePointStrokeWidthString radius:pathCurvePointRadiusString
            masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
            handlePoint:@"xy"];
    
    [pathHandlesGroup appendChild:handleXYCircleElement];
}

//==================================================================================
//	addHandleForLineto:segmentIndex:pathHandlesGroup
//==================================================================================

-(void) addHandleForLineto:(NSDictionary *)pathSegmentDictionary  
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
{
    // path commands L,l

    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
    
    NSString * xPxString = [xString stringByAppendingString:@"px"];
    NSString * yPxString = [yString stringByAppendingString:@"px"];

    NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
    NSString * selectedElementMacsvgid = [selectedElementMacsvgidNode stringValue];
    
    NSString * segmentIndexString = [NSString stringWithFormat:@"%ld", segmentIndex];

    CGFloat reciprocalZoomFactor = 1.0f / svgWebKitController.svgWebView.zoomFactor;
    
    NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
    CGFloat pathEndpointStrokeWidthFloat = [pathEndpointStrokeWidthString floatValue];
    pathEndpointStrokeWidthFloat *= reciprocalZoomFactor;
    pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

    NSString * pathLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
    CGFloat pathLineStrokeWidthFloat = [pathLineStrokeWidthString floatValue];
    pathLineStrokeWidthFloat *= reciprocalZoomFactor;
    pathLineStrokeWidthString = [self allocPxString:pathLineStrokeWidthFloat];

    NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
    CGFloat pathEndpointRadiusFloat = [pathEndpointRadiusString floatValue];
    pathEndpointRadiusFloat *= reciprocalZoomFactor;
    pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

    DOMElement * handleXYCircleElement =
            [self makeHandleCircleDOMElementWithCx:xPxString cy:yPxString
            strokeWidth:pathEndpointStrokeWidthString radius:pathEndpointRadiusString
            masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
            handlePoint:@"xy"];

    [pathHandlesGroup appendChild:handleXYCircleElement];
}

//==================================================================================
//	addHandleForHorizontalLineto:segmentIndex:pathHandlesGroup
//==================================================================================

-(void) addHandleForHorizontalLineto:(NSDictionary *)pathSegmentDictionary  
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
{
    // path commands H,h
    NSPoint currentPoint = NSZeroPoint;
    if (segmentIndex > 0)
    {
        currentPoint = [self absoluteXYPointAtPathSegmentIndex:(segmentIndex - 1)];
    }

    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
    NSString * xPxString = [xString stringByAppendingString:@"px"];

    NSString * yPxString = [self allocPxString:currentPoint.y];

    CGFloat reciprocalZoomFactor = 1.0f / svgWebKitController.svgWebView.zoomFactor;
    
    NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
    CGFloat pathEndpointStrokeWidthFloat = [pathEndpointStrokeWidthString floatValue];
    pathEndpointStrokeWidthFloat *= reciprocalZoomFactor;
    pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

    NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
    CGFloat pathEndpointRadiusFloat = [pathEndpointRadiusString floatValue];
    pathEndpointRadiusFloat *= reciprocalZoomFactor;
    pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

    NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
    NSString * selectedElementMacsvgid = [selectedElementMacsvgidNode stringValue];
    
    NSString * segmentIndexString = [NSString stringWithFormat:@"%ld", segmentIndex];

    DOMElement * handleXYCircleElement =
            [self makeHandleCircleDOMElementWithCx:xPxString cy:yPxString
            strokeWidth:pathEndpointStrokeWidthString radius:pathEndpointRadiusString
            masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
            handlePoint:@"x"];

    [pathHandlesGroup appendChild:handleXYCircleElement];
}

//==================================================================================
//	addHandleForVerticalLineto:segmentIndex:pathHandlesGroup
//==================================================================================

-(void) addHandleForVerticalLineto:(NSDictionary *)pathSegmentDictionary  
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
{
    // path commands V,v
    NSPoint currentPoint = NSZeroPoint;
    if (segmentIndex > 0)
    {
        currentPoint = [self absoluteXYPointAtPathSegmentIndex:(segmentIndex - 1)];
    }

    NSString * xPxString = [self allocPxString:currentPoint.x];
    
    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
    NSString * yPxString = [yString stringByAppendingString:@"px"];


    CGFloat reciprocalZoomFactor = 1.0f / svgWebKitController.svgWebView.zoomFactor;
    
    NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
    CGFloat pathEndpointStrokeWidthFloat = [pathEndpointStrokeWidthString floatValue];
    pathEndpointStrokeWidthFloat *= reciprocalZoomFactor;
    pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

    NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
    CGFloat pathEndpointRadiusFloat = [pathEndpointRadiusString floatValue];
    pathEndpointRadiusFloat *= reciprocalZoomFactor;
    pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

    NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
    NSString * selectedElementMacsvgid = [selectedElementMacsvgidNode stringValue];
    
    NSString * segmentIndexString = [NSString stringWithFormat:@"%ld", segmentIndex];

    DOMElement * handleXYCircleElement =
            [self makeHandleCircleDOMElementWithCx:xPxString cy:yPxString
            strokeWidth:pathEndpointStrokeWidthString radius:pathEndpointRadiusString
            masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
            handlePoint:@"y"];

    [pathHandlesGroup appendChild:handleXYCircleElement];
}

//==================================================================================
//	addHandleForCubicCurveto:segmentIndex:pathHandlesGroup
//==================================================================================

-(void) addHandleForCubicCurveto:(NSDictionary *)pathSegmentDictionary  
        segmentIndex:(NSUInteger)segmentIndex 
        reflectX1Y1:(BOOL)reflectX1Y1
        reflectX2Y2:(BOOL)reflectX2Y2
        pathHandlesGroup:(DOMElement *)pathHandlesGroup
{
    // path commands C,c
    
    if (pathSegmentDictionary != NULL)
    {
        CGFloat reciprocalZoomFactor = 1.0f / svgWebKitController.svgWebView.zoomFactor;

        NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
        CGFloat pathEndpointStrokeWidthFloat = [pathEndpointStrokeWidthString floatValue];
        pathEndpointStrokeWidthFloat *= reciprocalZoomFactor;
        pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

        NSString * pathLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
        CGFloat pathLineStrokeWidthFloat = [pathLineStrokeWidthString floatValue];
        pathLineStrokeWidthFloat *= reciprocalZoomFactor;
        pathLineStrokeWidthString = [self allocPxString:pathLineStrokeWidthFloat];

        NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
        CGFloat pathEndpointRadiusFloat = [pathEndpointRadiusString floatValue];
        pathEndpointRadiusFloat *= reciprocalZoomFactor;
        pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

        NSString * pathCurvePointStrokeWidthString = toolSettingsPopoverViewController.pathCurvePointStrokeWidth;
        CGFloat pathCurvePointStrokeWidthFloat = [pathCurvePointStrokeWidthString floatValue];
        pathCurvePointStrokeWidthFloat *= reciprocalZoomFactor;
        pathCurvePointStrokeWidthString = [self allocPxString:pathCurvePointStrokeWidthFloat];

        NSString * pathCurvePointRadiusString = toolSettingsPopoverViewController.pathCurvePointRadius;
        CGFloat pathCurvePointRadiusFloat = [pathCurvePointRadiusString floatValue];
        pathCurvePointRadiusFloat *= reciprocalZoomFactor;
        pathCurvePointRadiusString = [self allocPxString:pathCurvePointRadiusFloat];

        NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
        NSString * selectedElementMacsvgid = [selectedElementMacsvgidNode stringValue];
        
        NSString * segmentIndexString = [NSString stringWithFormat:@"%ld", segmentIndex];
        
        if ([self.pathSegmentsArray count] > 1)
        {
            NSNumber * xNumber = [pathSegmentDictionary objectForKey:@"absoluteX"];
            NSNumber * yNumber = [pathSegmentDictionary objectForKey:@"absoluteY"];
            NSNumber * x1Number = [pathSegmentDictionary objectForKey:@"absoluteX1"];
            NSNumber * y1Number = [pathSegmentDictionary objectForKey:@"absoluteY1"];
            NSNumber * x2Number = [pathSegmentDictionary objectForKey:@"absoluteX2"];
            NSNumber * y2Number = [pathSegmentDictionary objectForKey:@"absoluteY2"];
            
            float x = [xNumber floatValue];     // endpoint
            float y = [yNumber floatValue];
            float x1 = [x1Number floatValue];   // first curve control point
            float y1 = [y1Number floatValue];
            float x2 = [x2Number floatValue];   // second curve control point
            float y2 = [y2Number floatValue];

            NSString * xPxString = [self allocPxString:x];
            NSString * yPxString = [self allocPxString:y];
            NSString * x1PxString = [self allocPxString:x1];
            NSString * y1PxString = [self allocPxString:y1];
            NSString * x2PxString = [self allocPxString:x2];
            NSString * y2PxString = [self allocPxString:y2];
                    
            NSPoint currentPoint = NSMakePoint(x, y);
            if (segmentIndex > 0)
            {
                currentPoint = [self absoluteXYPointAtPathSegmentIndex:(segmentIndex - 1)];
            }

            NSString * currentXPxString = [self allocPxString:currentPoint.x];
            NSString * currentYPxString = [self allocPxString:currentPoint.y];

            NSString * reflectX1PxString = xPxString;
            NSString * reflectY1PxString = yPxString;

            // draw line from first endpoint x1,y1 control point
            
            DOMElement * handleLine1Element =
                    [self makeHandleLineDOMElementWithX1:currentXPxString y1:currentYPxString
                    x2:x1PxString y2:y1PxString strokeWidth:pathLineStrokeWidthString];

            [pathHandlesGroup appendChild:handleLine1Element];

            // draw line between second endpoint and x2,y2 control point

            DOMElement * handleLine2Element =
                    [self makeHandleLineDOMElementWithX1:xPxString y1:yPxString
                    x2:x2PxString y2:y2PxString strokeWidth:pathLineStrokeWidthString];

            [pathHandlesGroup appendChild:handleLine2Element];

            NSString * reflectX2PxString = x2PxString;
            NSString * reflectY2PxString = y2PxString;

            // make handle for endpoint x,y

            DOMElement * handleCircleElement1 =
                    [self makeHandleCircleDOMElementWithCx:xPxString cy:yPxString
                    strokeWidth:pathCurvePointStrokeWidthString radius:pathCurvePointRadiusString
                    masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                    handlePoint:@"xy"];

            [pathHandlesGroup appendChild:handleCircleElement1];

            // make handle for x1, y1

            DOMElement * handleCircleElement2 =
                    [self makeHandleCircleDOMElementWithCx:x1PxString cy:y1PxString
                    strokeWidth:pathCurvePointStrokeWidthString radius:pathCurvePointRadiusString
                    masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                    handlePoint:@"x1y1"];

            [pathHandlesGroup appendChild:handleCircleElement2];

            // make handle for x2, y2

            DOMElement * handleCircleElement3 =
                    [self makeHandleCircleDOMElementWithCx:x2PxString cy:y2PxString
                    strokeWidth:pathCurvePointStrokeWidthString radius:pathCurvePointRadiusString
                    masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                    handlePoint:@"x2y2"];

            [pathHandlesGroup appendChild:handleCircleElement3];

            if (reflectX1Y1 == YES)
            {
                // draw line to reflected control point for x1, y1
                float deltaX = x1 - currentPoint.x;
                float deltaY = y1 - currentPoint.y;
                
                float reflectX1 = currentPoint.x - deltaX;
                float reflectY1 = currentPoint.y - deltaY;
                
                reflectX1PxString = [self allocPxString:reflectX1];
                reflectY1PxString = [self allocPxString:reflectY1];

                DOMElement * handleLine0Element =
                        [self makeHandleLineDOMElementWithX1:currentXPxString y1:currentYPxString
                        x2:reflectX1PxString y2:reflectY1PxString strokeWidth:pathLineStrokeWidthString];

                [pathHandlesGroup appendChild:handleLine0Element];

                // reflect handle for x1, y1

                DOMElement * handleCircleElement4 =
                        [self makeHandleCircleDOMElementWithCx:reflectX1PxString cy:reflectY1PxString
                        strokeWidth:pathCurvePointStrokeWidthString radius:pathCurvePointRadiusString
                        masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                        handlePoint:@"x0y0"];  // reflect x1,y1 handle

                [pathHandlesGroup appendChild:handleCircleElement4];
            }

            if (reflectX2Y2 == YES)
            {
                // draw a line to reflected control point for x2,y2
                float deltaX = x - x2;
                float deltaY = y - y2;
                
                float reflectX2 = x + deltaX;
                float reflectY2 = y + deltaY;

                reflectX2PxString = [self allocPxString:reflectX2];
                reflectY2PxString = [self allocPxString:reflectY2];

                DOMElement * handleLine3Element =
                        [self makeHandleLineDOMElementWithX1:xPxString y1:yPxString
                        x2:reflectX2PxString y2:reflectY2PxString strokeWidth:pathLineStrokeWidthString];

                [pathHandlesGroup appendChild:handleLine3Element];

                // reflect handle for x2,y2
                
                DOMElement * handleCircleElement5 =
                        [self makeHandleCircleDOMElementWithCx:reflectX2PxString cy:reflectY2PxString
                        strokeWidth:pathCurvePointStrokeWidthString radius:pathCurvePointRadiusString
                        masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                        handlePoint:@"x3y3"];  // reflect x2,y2 handle

                [pathHandlesGroup appendChild:handleCircleElement5];
            }
        }
    }
}

//==================================================================================
//	addHandleForSmoothCubicCurveto:segmentIndex:pathHandlesGroup
//==================================================================================

-(void) addHandleForSmoothCubicCurveto:(NSDictionary *)pathSegmentDictionary  
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
{
    // path commands S,s

    if ([self.pathSegmentsArray count] > 1)
    {
        NSString * x2String = [pathSegmentDictionary objectForKey:@"absoluteX2"];
        NSString * y2String = [pathSegmentDictionary objectForKey:@"absoluteY2"];
        NSString * xString = [pathSegmentDictionary objectForKey:@"absoluteX"];
        NSString * yString = [pathSegmentDictionary objectForKey:@"absoluteY"];

        float x2 = [x2String floatValue];
        float y2 = [y2String floatValue];
        float x = [xString floatValue];
        float y = [yString floatValue];

        NSString * xPxString = [self allocPxString:x];
        NSString * yPxString = [self allocPxString:y];
        NSString * x2PxString = [self allocPxString:x2];
        NSString * y2PxString = [self allocPxString:y2];
                
        NSPoint currentPoint = NSMakePoint(x, y);
        if (segmentIndex > 0)
        {
            currentPoint = [self absoluteXYPointAtPathSegmentIndex:(segmentIndex - 1)];
        }

        CGFloat reciprocalZoomFactor = 1.0f / svgWebKitController.svgWebView.zoomFactor;
        
        NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
        CGFloat pathEndpointStrokeWidthFloat = [pathEndpointStrokeWidthString floatValue];
        pathEndpointStrokeWidthFloat *= reciprocalZoomFactor;
        pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

        NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
        CGFloat pathEndpointRadiusFloat = [pathEndpointRadiusString floatValue];
        pathEndpointRadiusFloat *= reciprocalZoomFactor;
        pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

        NSString * pathLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
        CGFloat pathLineStrokeWidthFloat = [pathLineStrokeWidthString floatValue];
        pathLineStrokeWidthFloat *= reciprocalZoomFactor;
        pathLineStrokeWidthString = [self allocPxString:pathLineStrokeWidthFloat];

        NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
        NSString * selectedElementMacsvgid = [selectedElementMacsvgidNode stringValue];
        
        NSString * segmentIndexString = [NSString stringWithFormat:@"%ld", segmentIndex];

        // draw line between second endpoint and control point
        
        DOMElement * handleLine2Element = [self makeHandleLineDOMElementWithX1:xPxString y1:yPxString
                x2:x2PxString y2:y2PxString strokeWidth:pathLineStrokeWidthString];
        
        [pathHandlesGroup appendChild:handleLine2Element];

        // draw circle at endpoint

        DOMElement * handleCircleElement1 =
                [self makeHandleCircleDOMElementWithCx:xPxString cy:yPxString
                strokeWidth:pathEndpointStrokeWidthString radius:pathEndpointRadiusString
                masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                handlePoint:@"xy"];

        [pathHandlesGroup appendChild:handleCircleElement1];

        // draw circle at x2, y2

        DOMElement * handleCircleElement3 =
                [self makeHandleCircleDOMElementWithCx:x2PxString cy:y2PxString
                strokeWidth:pathEndpointStrokeWidthString radius:pathEndpointRadiusString
                masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                handlePoint:@"x2y2"];

        [pathHandlesGroup appendChild:handleCircleElement3];
    }
}

//==================================================================================
//	addHandleForQuadraticCurveto:segmentIndex:pathHandlesGroup
//==================================================================================

-(void) addHandleForQuadraticCurveto:(NSDictionary *)pathSegmentDictionary  
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
{
    // path commands Q,q

    if ([self.pathSegmentsArray count] > 1)
    {
        NSString * x1String = [pathSegmentDictionary objectForKey:@"absoluteX1"];
        NSString * y1String = [pathSegmentDictionary objectForKey:@"absoluteY1"];
        NSString * xString = [pathSegmentDictionary objectForKey:@"absoluteX"];
        NSString * yString = [pathSegmentDictionary objectForKey:@"absoluteY"];

        float x1 = [x1String floatValue];
        float y1 = [y1String floatValue];
        float x = [xString floatValue];
        float y = [yString floatValue];

        NSString * xPxString = [self allocPxString:x];
        NSString * yPxString = [self allocPxString:y];
        NSString * x1PxString = [self allocPxString:x1];
        NSString * y1PxString = [self allocPxString:y1];
                
        NSPoint currentPoint = NSMakePoint(x, y);
        if (segmentIndex > 0)
        {
            currentPoint = [self absoluteXYPointAtPathSegmentIndex:(segmentIndex - 1)];
        }

        NSString * currentXPxString = [self allocPxString:currentPoint.x];
        NSString * currentYPxString = [self allocPxString:currentPoint.y];


        CGFloat reciprocalZoomFactor = 1.0f / svgWebKitController.svgWebView.zoomFactor;
        
        NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
        CGFloat pathEndpointStrokeWidthFloat = [pathEndpointStrokeWidthString floatValue];
        pathEndpointStrokeWidthFloat *= reciprocalZoomFactor;
        pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

        NSString * pathLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
        CGFloat pathLineStrokeWidthFloat = [pathLineStrokeWidthString floatValue];
        pathLineStrokeWidthFloat *= reciprocalZoomFactor;
        pathLineStrokeWidthString = [self allocPxString:pathLineStrokeWidthFloat];

        NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
        CGFloat pathEndpointRadiusFloat = [pathEndpointRadiusString floatValue];
        pathEndpointRadiusFloat *= reciprocalZoomFactor;
        pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

        NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
        NSString * selectedElementMacsvgid = [selectedElementMacsvgidNode stringValue];
        
        NSString * segmentIndexString = [NSString stringWithFormat:@"%ld", segmentIndex];
        
        // draw line between first endpoint and control point
        
        DOMElement * handleLine1Element = [self makeHandleLineDOMElementWithX1:currentXPxString y1:currentYPxString
                x2:x1PxString y2:y1PxString strokeWidth:pathLineStrokeWidthString];
        
        [pathHandlesGroup appendChild:handleLine1Element];

        // draw circles at endpoint and control points

        DOMElement * handleCircleElement1 =
                [self makeHandleCircleDOMElementWithCx:xPxString cy:yPxString
                strokeWidth:pathEndpointStrokeWidthString radius:pathEndpointRadiusString
                masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                handlePoint:@"xy"];

        [pathHandlesGroup appendChild:handleCircleElement1];

        DOMElement * handleCircleElement2 =
                [self makeHandleCircleDOMElementWithCx:x1PxString cy:y1PxString
                strokeWidth:pathEndpointStrokeWidthString radius:pathEndpointRadiusString
                masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                handlePoint:@"x1y1"];

        [pathHandlesGroup appendChild:handleCircleElement2];
    }
}

//==================================================================================
//	addHandleForSmoothQuadraticCurveto:segmentIndex:pathHandlesGroup
//==================================================================================

-(void) addHandleForSmoothQuadraticCurveto:(NSDictionary *)pathSegmentDictionary  
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
{
    // path commands T,t

    if ([self.pathSegmentsArray count] > 1)
    {
        NSString * xString = [pathSegmentDictionary objectForKey:@"absoluteX"];
        NSString * yString = [pathSegmentDictionary objectForKey:@"absoluteY"];

        float x = [xString floatValue];
        float y = [yString floatValue];

        NSString * xPxString = [self allocPxString:x];
        NSString * yPxString = [self allocPxString:y];
        
        NSPoint currentPoint = NSMakePoint(x, y);
        if (segmentIndex > 0)
        {
            currentPoint = [self absoluteXYPointAtPathSegmentIndex:(segmentIndex - 1)];
        }

        CGFloat reciprocalZoomFactor = 1.0f / svgWebKitController.svgWebView.zoomFactor;
        
        NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
        CGFloat pathEndpointStrokeWidthFloat = [pathEndpointStrokeWidthString floatValue];
        pathEndpointStrokeWidthFloat *= reciprocalZoomFactor;
        pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

        NSString * pathLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
        CGFloat pathLineStrokeWidthFloat = [pathLineStrokeWidthString floatValue];
        pathLineStrokeWidthFloat *= reciprocalZoomFactor;
        pathLineStrokeWidthString = [self allocPxString:pathLineStrokeWidthFloat];

        NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
        CGFloat pathEndpointRadiusFloat = [pathEndpointRadiusString floatValue];
        pathEndpointRadiusFloat *= reciprocalZoomFactor;
        pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

        NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
        NSString * selectedElementMacsvgid = [selectedElementMacsvgidNode stringValue];
        
        NSString * segmentIndexString = [NSString stringWithFormat:@"%ld", segmentIndex];

        // draw circles at endpoint and control points
        
        DOMElement * handleCircleElement =
                [self makeHandleCircleDOMElementWithCx:xPxString cy:yPxString
                strokeWidth:pathEndpointStrokeWidthString radius:pathEndpointRadiusString
                masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                handlePoint:@"xy"];

        [pathHandlesGroup appendChild:handleCircleElement];
    }
}

//==================================================================================
//	addHandleForEllipicalArc:segmentIndex:pathHandlesGroup
//==================================================================================

-(void) addHandleForEllipicalArc:(NSDictionary *)pathSegmentDictionary  
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
{
    // path commands A,a

    if ([self.pathSegmentsArray count] > 1)
    {
        NSString * xString = [pathSegmentDictionary objectForKey:@"absoluteX"];
        NSString * yString = [pathSegmentDictionary objectForKey:@"absoluteY"];

        float x = [xString floatValue];
        float y = [yString floatValue];

        NSString * xPxString = [self allocPxString:x];
        NSString * yPxString = [self allocPxString:y];
        
        NSPoint currentPoint = NSMakePoint(x, y);
        if (segmentIndex > 0)
        {
            currentPoint = [self absoluteXYPointAtPathSegmentIndex:(segmentIndex - 1)];
        }

        CGFloat reciprocalZoomFactor = 1.0f / svgWebKitController.svgWebView.zoomFactor;
        
        NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
        CGFloat pathEndpointStrokeWidthFloat = [pathEndpointStrokeWidthString floatValue];
        pathEndpointStrokeWidthFloat *= reciprocalZoomFactor;
        pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

        NSString * pathLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
        CGFloat pathLineStrokeWidthFloat = [pathLineStrokeWidthString floatValue];
        pathLineStrokeWidthFloat *= reciprocalZoomFactor;
        pathLineStrokeWidthString = [self allocPxString:pathLineStrokeWidthFloat];

        NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
        CGFloat pathEndpointRadiusFloat = [pathEndpointRadiusString floatValue];
        pathEndpointRadiusFloat *= reciprocalZoomFactor;
        pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

        NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
        NSString * selectedElementMacsvgid = [selectedElementMacsvgidNode stringValue];
        
        NSString * segmentIndexString = [NSString stringWithFormat:@"%ld", segmentIndex];

        // draw circles at endpoint and control points

        DOMElement * handleCircleElement =
                [self makeHandleCircleDOMElementWithCx:xPxString cy:yPxString
                strokeWidth:pathEndpointStrokeWidthString radius:pathEndpointRadiusString
                masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                handlePoint:@"xy"];

        [pathHandlesGroup appendChild:handleCircleElement];
    }
}

//==================================================================================
//	addHandleForClosePath:segmentIndex:pathHandlesGroup
//==================================================================================

-(void) addHandleForClosePath:(NSDictionary *)pathSegmentDictionary 
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
{
    // path commands Z,z
}

//==================================================================================
//	makePathHandles
//==================================================================================

-(void) makePathHandles
{
    DOMDocument * domDocument = [[svgWebKitController.svgWebView mainFrame] DOMDocument];

    DOMSelectionRectsAndHandlesManager * domSelectionRectsAndHandlesManager =
            svgXMLDOMSelectionManager.domSelectionRectsAndHandlesManager;
    
    DOMElement * newPathHandlesGroup = [domDocument createElementNS:svgNamespace 
            qualifiedName:@"g"];
    [newPathHandlesGroup setAttributeNS:NULL qualifiedName:@"id" value:@"_macsvg_pathHandlesGroup"];
    [newPathHandlesGroup setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_pathHandlesGroup"];
    
    NSUInteger pathSegmentsCount = [self.pathSegmentsArray count];
            
    for (NSUInteger segmentIdx = 0; segmentIdx < pathSegmentsCount; segmentIdx++)
    {
        NSDictionary * pathSegmentDictionary = [self.pathSegmentsArray objectAtIndex:segmentIdx];

        NSString * pathCommand = [pathSegmentDictionary objectForKey:@"command"];
        
        unichar commandChar = [pathCommand characterAtIndex:0];

        switch (commandChar) 
        {
            case 'M':     // moveto
            case 'm':     // moveto
                [self addHandleForMoveto:pathSegmentDictionary segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup];
                break;

            case 'L':     // lineto
            case 'l':     // lineto
                [self addHandleForLineto:pathSegmentDictionary segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup];
                break;

            case 'H':     // horizontal lineto
            case 'h':     // horizontal lineto
                [self addHandleForHorizontalLineto:pathSegmentDictionary segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup];
                break;

            case 'V':     // vertical lineto
            case 'v':     // vertical lineto
                [self addHandleForVerticalLineto:pathSegmentDictionary segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup];
                break;

            case 'C':     // cubic Bezier curveto
            case 'c':     // cubic Bezier curveto
            {
                BOOL reflectX1Y1 = NO;
                if (segmentIdx == 1) reflectX1Y1 = YES;
                BOOL reflectX2Y2 = NO;
                if (segmentIdx >= (pathSegmentsCount - 1)) reflectX2Y2 = YES;

                [self addHandleForCubicCurveto:pathSegmentDictionary segmentIndex:segmentIdx 
                        reflectX1Y1:reflectX1Y1
                        reflectX2Y2:reflectX2Y2
                        pathHandlesGroup:newPathHandlesGroup];
                break;
            }
            case 'S':     // smooth cubic Bezier curveto
            case 's':     // smooth cubic Bezier curveto
                [self addHandleForSmoothCubicCurveto:pathSegmentDictionary segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup];
                break;

            case 'Q':     // quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
                [self addHandleForQuadraticCurveto:pathSegmentDictionary segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup];
                break;

            case 'T':     // smooth quadratic Bezier curve
            case 't':     // smooth quadratic Bezier curve
                [self addHandleForSmoothQuadraticCurveto:pathSegmentDictionary segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup];
                break;

            case 'A':     // elliptical arc
            case 'a':     // elliptical arc
                [self addHandleForEllipicalArc:pathSegmentDictionary segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup];
                break;

            case 'Z':     // closepath
            case 'z':     // closepath
                [self addHandleForClosePath:pathSegmentDictionary segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup];
                break;
        }
    }
    
    [domSelectionRectsAndHandlesManager setMacsvgTopGroupChild:newPathHandlesGroup];

    if (self.highlightSelectedSegment == YES)
    {
        [domSelectionRectsAndHandlesManager highlightPathSegment];
    }
    else
    {
        [domSelectionRectsAndHandlesManager removeDOMPathSegmentHighlight];
    }
}

//==================================================================================
//	buildPathStringWithPathSegmentsArray:
//==================================================================================

- (NSString *)buildPathStringWithPathSegmentsArray:(NSArray *)aPathSegmentsArray
{
    // convert path segments data to DOM
    NSUInteger pathSegmentsCount = [aPathSegmentsArray count];

    NSMutableString * newPathString = [[NSMutableString alloc] init];
    
    for (NSInteger i = 0; i < pathSegmentsCount; i++)
    {
        NSMutableDictionary * pathSegmentDictionary = [aPathSegmentsArray objectAtIndex:i];
        
        NSString * pathCommandString = [pathSegmentDictionary objectForKey:@"command"];
        unichar commandChar = [pathCommandString characterAtIndex:0];
        
        switch (commandChar) 
        {
            case 'M':     // moveto
            case 'm':     // moveto
            {
                if (i == 0)
                {
                    [newPathString appendString:@"M"];
                }
                else
                {
                    [newPathString appendString:pathCommandString];
                }
                
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                
                [newPathString appendString:@","];
                
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                
                [newPathString appendString:@" "];
                
                break;
            }
            case 'L':     // lineto
            {
                [newPathString appendString:@"L"];
                
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'l':     // lineto
            {
                [newPathString appendString:@"l"];
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'H':     // horizontal lineto
            {
                [newPathString appendString:@"H"];
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@" "];
                break;
            }
            case 'h':     // horizontal lineto
            {
                [newPathString appendString:@"h"];
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@" "];
                break;
            }
            case 'V':     // vertical lineto
            {
                [newPathString appendString:@"V"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'v':     // vertical lineto
            {
                [newPathString appendString:@"v"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'C':     // curveto
            {
                [newPathString appendString:@"C"];
                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                [newPathString appendString:x1String];
                [newPathString appendString:@","];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                [newPathString appendString:y1String];
                [newPathString appendString:@" "];

                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                [newPathString appendString:x2String];
                [newPathString appendString:@","];
                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                [newPathString appendString:y2String];
                [newPathString appendString:@" "];

                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'c':     // curveto
            {
                [newPathString appendString:@"c"];
                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                [newPathString appendString:x1String];
                [newPathString appendString:@","];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                [newPathString appendString:y1String];
                [newPathString appendString:@" "];

                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                [newPathString appendString:x2String];
                [newPathString appendString:@","];
                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                [newPathString appendString:y2String];
                [newPathString appendString:@" "];

                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'S':     // smooth curveto
            {
                [newPathString appendString:@"S"];

                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                [newPathString appendString:x2String];
                [newPathString appendString:@","];
                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                [newPathString appendString:y2String];
                [newPathString appendString:@" "];

                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 's':     // smooth curveto
            {
                [newPathString appendString:@"s"];

                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                [newPathString appendString:x2String];
                [newPathString appendString:@","];
                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                [newPathString appendString:y2String];
                [newPathString appendString:@" "];

                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'Q':     // quadratic Bezier curve
            {
                [newPathString appendString:@"Q"];
                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                [newPathString appendString:x1String];
                [newPathString appendString:@","];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                [newPathString appendString:y1String];
                [newPathString appendString:@" "];

                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'q':     // quadratic Bezier curve
            {
                [newPathString appendString:@"q"];
                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                [newPathString appendString:x1String];
                [newPathString appendString:@","];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                [newPathString appendString:y1String];
                [newPathString appendString:@" "];

                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'T':     // smooth quadratic Bezier curve
            {
                [newPathString appendString:@"T"];
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 't':     // smooth quadratic Bezier curve
            {
                [newPathString appendString:@"t"];
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'A':     // elliptical arc
            {
                [newPathString appendString:@"A"];
                
                NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                [newPathString appendString:rxString];
                [newPathString appendString:@","];
                NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                [newPathString appendString:ryString];
                [newPathString appendString:@" "];
                
                NSString * dataXAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                [newPathString appendString:dataXAxisRotationString];
                [newPathString appendString:@" "];
                
                NSString * dataLargeArcString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                [newPathString appendString:dataLargeArcString];
                [newPathString appendString:@" "];
                
                NSString * sweepString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
                [newPathString appendString:sweepString];
                [newPathString appendString:@" "];
                
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'a':     // elliptical arc
            {
                [newPathString appendString:@"a"];
                
                NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                [newPathString appendString:rxString];
                [newPathString appendString:@","];
                NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                [newPathString appendString:ryString];
                [newPathString appendString:@" "];
                
                NSString * aXAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                [newPathString appendString:aXAxisRotationString];
                [newPathString appendString:@" "];
                
                NSString * largeArcString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                [newPathString appendString:largeArcString];
                [newPathString appendString:@" "];
                
                NSString * sweepString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
                [newPathString appendString:sweepString];
                [newPathString appendString:@" "];
                
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'Z':     // closepath
            {
                [newPathString appendString:@" Z "];
                break;
            }
            case 'z':     // closepath
            {
                [newPathString appendString:@" z "];
                break;
            }
        }
    }
    
    return newPathString;
}

//==================================================================================
//	updatePathInDOMForElement:pathSegmentsArray:
//==================================================================================

- (void)updatePathInDOMForElement:(DOMElement *)pathElement pathSegmentsArray:(NSArray *)aPathSegmentsArray
{
    NSString * newPathString = [self buildPathStringWithPathSegmentsArray:aPathSegmentsArray];

    [pathElement setAttribute:@"d" value:newPathString];
    
    id currentPlugin = macSVGDocumentWindowController.editorUIFrameController.elementEditorPlugInController.currentPlugin;
    
    NSString * pluginName = [currentPlugin pluginName];
    
    if ([pluginName isEqualToString:@"Path Element Editor"] == YES)
    {
        NSString * macsvgid = [pathElement getAttribute:@"macsvgid"];
        
        if (macsvgid != NULL)
        {
            MacSVGDocument * macSVGDocument = [macSVGDocumentWindowController document];
            
            NSXMLElement * pathXMLElement = [macSVGDocument xmlElementForMacsvgid:macsvgid];
            
            [currentPlugin updateEditForXMLElement:pathXMLElement domElement:pathElement info:aPathSegmentsArray];
        }
    }
}

//==================================================================================
//	updateActivePathInDOM
//==================================================================================

- (void)updateActivePathInDOM
{
    NSUInteger currentToolMode = macSVGDocumentWindowController.currentToolMode;

    if ((currentToolMode == toolModePath) || (currentToolMode == toolModeCrosshairCursor))
    {
        DOMElement * activeDOMElement = [svgXMLDOMSelectionManager activeDOMElement];
        if (activeDOMElement != NULL)
        {
            [self updatePathInDOMForElement:activeDOMElement
                    pathSegmentsArray:self.pathSegmentsArray];
        }
        
        [svgXMLDOMSelectionManager syncSelectedDOMElementsToXMLDocument];
        
        [macSVGDocumentWindowController reloadAttributesTableData];
        
        [self makePathHandles];
    }
}

//==================================================================================
//	updateSelectedPathInDOM
//==================================================================================

- (void)updateSelectedPathInDOM
{
    if (self.selectedPathElement != NULL)
    {
        NSXMLNode * MacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
        NSString * macsvgid = [MacsvgidNode stringValue];
        
        DOMElement * selectedDOMPathElement = [svgWebKitController domElementForMacsvgid:macsvgid];
    
        [self updatePathInDOMForElement:selectedDOMPathElement
                pathSegmentsArray:self.pathSegmentsArray];
    }
    
    [svgXMLDOMSelectionManager syncSelectedDOMElementsToXMLDocument];
    
    [macSVGDocumentWindowController reloadAttributesTableData];
}

//==================================================================================
//	removePathHandles
//==================================================================================

- (void)removePathHandles
{
    // remove existing pathHandlesGroup from DOM
    
    [svgXMLDOMSelectionManager.domSelectionRectsAndHandlesManager
            removeMacsvgTopGroupChildByID:@"_macsvg_pathHandlesGroup"];
}

//==================================================================================
//	resetPathSegmentsArray
//==================================================================================

- (void)resetPathSegmentsArray
{
    self.selectedPathElement = NULL;
    [self.pathSegmentsArray removeAllObjects];
    self.pathSegmentIndex = -1;
    self.pathEditingKey = @"";
    editingMode = kPathEditingModeNotActive;

    [self removePathHandles];
}

//==================================================================================
//	startPath
//==================================================================================

- (void)startPath
{
    // we start paths with an absolute moveto
    //NSLog(@"startPath");
    
    [self resetPathSegmentsArray];

    NSString * clickXString = [self allocFloatString:domMouseEventsController.clickPoint.x];
    NSString * clickYString = [self allocFloatString:domMouseEventsController.clickPoint.y];
    
    NSNumber * clickAbsoluteXNumber = [NSNumber numberWithFloat:domMouseEventsController.clickPoint.x];
    NSNumber * clickAbsoluteYNumber = [NSNumber numberWithFloat:domMouseEventsController.clickPoint.y];

    NSMutableDictionary * movetoSegmentDictionary = [[NSMutableDictionary alloc] init];
    
    // start all paths with moveto
    [movetoSegmentDictionary setObject:@"M" forKey:@"command"];
    [movetoSegmentDictionary setObject:clickXString forKey:@"x"];
    [movetoSegmentDictionary setObject:clickYString forKey:@"y"];

    [movetoSegmentDictionary setObject:clickAbsoluteXNumber forKey:@"absoluteX"];
    [movetoSegmentDictionary setObject:clickAbsoluteYNumber forKey:@"absoluteY"];
    
    [self.pathSegmentsArray addObject:movetoSegmentDictionary];
    
    [self updateActivePathInDOM];
}

//==================================================================================
//	extendFreestylePath
//==================================================================================

NSPoint midPoint(NSPoint p1, NSPoint p2)
{
  return NSMakePoint((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

NSPoint bezierMidPoint(NSPoint p0, NSPoint p1, NSPoint p2)
{
    // p0 is the start point, p1 is the control point, and p2 is the end point. t is the parameter, which goes from 0 to 1.

    float t = 0.5; // find midpoint
    float x = (1 - t) * (1 - t) * p0.x + 2 * (1 - t) * t * p1.x + t * t * p2.x;
    float y = (1 - t) * (1 - t) * p0.y + 2 * (1 - t) * t * p1.y + t * t * p2.y;
    
    NSPoint resultPoint = NSMakePoint(x, y);
    return resultPoint;
}


- (void)extendFreestylePath
{
    // Changed to Quadratic Beziers
    // based on https://github.com/levinunnink/Smooth-Line-View/blob/master/Smooth%20Line%20View/SmoothLineView.m

    NSString * newXString = [self allocFloatString:domMouseEventsController.currentMousePoint.x];
    NSString * newYString = [self allocFloatString:domMouseEventsController.currentMousePoint.y];

    float newX = [newXString floatValue];
    float newY = [newYString floatValue];



    
    NSMutableDictionary * pathSegmentDictionary = [self.pathSegmentsArray objectAtIndex:self.pathSegmentIndex];

    NSString * previousXString = [pathSegmentDictionary objectForKey:@"x"];     // endpoint x
    NSString * previousYString = [pathSegmentDictionary objectForKey:@"y"];     // endpoint y
    
    NSString * previousX1String = newXString;
    NSString * previousY1String = newYString;

    NSString * tempPreviousX1String = [pathSegmentDictionary objectForKey:@"x1"];     // endpoint x
    NSString * tempPreviousY1String = [pathSegmentDictionary objectForKey:@"y1"];     // endpoint y
    
    if (tempPreviousX1String != NULL) previousX1String = tempPreviousX1String;
    if (tempPreviousY1String != NULL) previousY1String = tempPreviousY1String;



    
    float previousX = [previousXString floatValue];
    float previousY = [previousYString floatValue];
    float previousX1 = [previousX1String floatValue];
    float previousY1 = [previousY1String floatValue];
    
    NSString * previousPreviousXString = previousXString;
    NSString * previousPreviousYString = previousYString;
    
    if (self.pathSegmentIndex > 1)
    {
        NSMutableDictionary * pathSegmentDictionary2 = [self.pathSegmentsArray objectAtIndex:(self.pathSegmentIndex - 1)];
        
        NSString * tempPreviousPreviousXString = [pathSegmentDictionary2 objectForKey:@"x"];     // endpoint x
        NSString * tempPreviousPreviousYString = [pathSegmentDictionary2 objectForKey:@"y"];     // endpoint y

        if (tempPreviousPreviousXString != NULL) previousPreviousXString = tempPreviousPreviousXString;
        if (tempPreviousPreviousYString != NULL) previousPreviousYString = tempPreviousPreviousYString;
    }
    
    float previousPreviousX = [previousPreviousXString floatValue];
    float previousPreviousY = [previousPreviousYString floatValue];
    
    

    float deltaX = previousX - newX;
    float deltaY = previousY - newY;
    
    const float kPointMinDistance = 30.0f;
    const float kPointMinDistanceSquared = kPointMinDistance * kPointMinDistance;


    if (((deltaX * deltaX) + (deltaY * deltaY)) >= kPointMinDistanceSquared)
    {
        NSMutableDictionary * newPathSegmentDictionary = [[NSMutableDictionary alloc] init];

        if (self.useRelativePathCoordinates == YES)
        {
            NSPoint previousPoint = NSMakePoint(previousX, previousY);
            NSPoint previousPreviousPoint = NSMakePoint(previousPreviousX, previousPreviousY);
            
            NSPoint previousControlPoint = NSMakePoint(previousX1, previousY1);
            NSPoint previousMidPoint = bezierMidPoint(previousPreviousPoint, previousControlPoint, previousPoint);
        
            float newX1 = (previousX + (previousX - previousMidPoint.x));
            float newY1 = (previousY + (previousY - previousMidPoint.y));
            
            NSString * newX1String = [self allocFloatString:newX1];
            NSString * newY1String = [self allocFloatString:newY1];

            [newPathSegmentDictionary setObject:@"q" forKey:@"command"];
            
            [newPathSegmentDictionary setObject:newXString forKey:@"x"];
            [newPathSegmentDictionary setObject:newYString forKey:@"y"];
            
            [newPathSegmentDictionary setObject:newX1String forKey:@"x1"];
            [newPathSegmentDictionary setObject:newY1String forKey:@"y1"];
        }
        else
        {
            NSPoint previousPoint = NSMakePoint(previousX, previousY);
            NSPoint previousPreviousPoint = NSMakePoint(previousPreviousX, previousPreviousY);
            
            NSPoint previousControlPoint = NSMakePoint(previousX1, previousY1);
            NSPoint previousMidPoint = bezierMidPoint(previousPreviousPoint, previousControlPoint, previousPoint);
        
            float newX1 = (previousX + (previousX - previousMidPoint.x));
            float newY1 = (previousY + (previousY - previousMidPoint.y));
            
            NSString * newX1String = [self allocFloatString:newX1];
            NSString * newY1String = [self allocFloatString:newY1];

            [newPathSegmentDictionary setObject:@"Q" forKey:@"command"];
            
            [newPathSegmentDictionary setObject:newXString forKey:@"x"];
            [newPathSegmentDictionary setObject:newYString forKey:@"y"];
            
            [newPathSegmentDictionary setObject:newX1String forKey:@"x1"];
            [newPathSegmentDictionary setObject:newY1String forKey:@"y1"];
        }

        [self.pathSegmentsArray addObject:newPathSegmentDictionary];
        self.pathSegmentIndex = [self.pathSegmentsArray count] - 1;
        
        //NSLog(@"pathSegmentsArray - %@", pathSegmentsArray);
        
        [self updatePathSegmentsAbsoluteValues:self.pathSegmentsArray];

        [self updateActivePathInDOM];
    }
}

//==================================================================================
//	offsetPathElement:attribute:by:pathSegmentDictionary:
//==================================================================================

- (void)offsetPathElement:(DOMElement *)pathElement attribute:(NSString *)attribute 
        by:(float)byValue pathSegmentDictionary:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * currentValueString = [pathSegmentDictionary objectForKey:attribute];
    
    float currentValue = [currentValueString floatValue];
    
    float newValue = currentValue + byValue;
    
    NSString * newValueString = [self allocFloatString:newValue];
    
    [pathSegmentDictionary setObject:newValueString forKey:attribute];
}

//==================================================================================
//	offsetPath:deltaX:deltaY:
//==================================================================================

- (void)offsetPath:(DOMElement *)pathElement deltaX:(float)deltaX deltaY:(float)deltaY
{
    // for dragging the whole path
    NSString * pathString = [pathElement getAttribute:@"d"];

    NSMutableArray * aPathsArray = [self buildPathSegmentsArrayWithPathString:pathString];

    NSUInteger pathSegmentsCount = [aPathsArray count];
            
    for (NSUInteger segmentIdx = 0; segmentIdx < pathSegmentsCount; segmentIdx++)
    {
        NSMutableDictionary * pathSegmentDictionary = [aPathsArray objectAtIndex:segmentIdx];

        NSString * pathCommand = [pathSegmentDictionary objectForKey:@"command"];
        
        unichar commandChar = [pathCommand characterAtIndex:0];

        switch (commandChar) 
        {
            case 'M':     // moveto
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegmentDictionary:pathSegmentDictionary];
                break;
            case 'm':     // moveto
                // no recalculation required for relative path
                break;

            case 'L':     // lineto
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegmentDictionary:pathSegmentDictionary];
                break;
            case 'l':     // lineto
                // no recalculation required for relative path
                break;

            case 'H':     // horizontal lineto
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegmentDictionary:pathSegmentDictionary];
                break;
            case 'h':     // horizontal lineto
                // no recalculation required for relative path
                break;

            case 'V':     // vertical lineto
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegmentDictionary:pathSegmentDictionary];
                break;
            case 'v':     // vertical lineto
                // no recalculation required for relative path
                break;

            case 'C':     // cubic Bezier curveto
                [self offsetPathElement:pathElement attribute:@"x1" by:deltaX pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"y1" by:deltaY pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"x2" by:deltaX pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"y2" by:deltaY pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegmentDictionary:pathSegmentDictionary];
                break;
            case 'c':     // cubic Bezier curveto
                // no recalculation required for relative path
                break;
                
            case 'S':     // smooth cubic Bezier curveto
                [self offsetPathElement:pathElement attribute:@"x2" by:deltaX pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"y2" by:deltaY pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegmentDictionary:pathSegmentDictionary];
                break;
            case 's':     // smooth cubic Bezier curveto
                // no recalculation required for relative path
                break;

            case 'Q':     // quadratic Bezier curve
                [self offsetPathElement:pathElement attribute:@"x1" by:deltaX pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"y1" by:deltaY pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegmentDictionary:pathSegmentDictionary];
                break;
            case 'q':     // quadratic Bezier curve
                // no recalculation required for relative path
                break;

            case 'T':     // smooth quadratic Bezier curve
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegmentDictionary:pathSegmentDictionary];
                break;
            case 't':     // smooth quadratic Bezier curve
                // no recalculation required for relative path
                break;

            case 'A':     // elliptical arc
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegmentDictionary:pathSegmentDictionary];
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegmentDictionary:pathSegmentDictionary];
                break;
            case 'a':     // elliptical arc
                // no recalculation required for relative path
                break;

            case 'Z':     // closepath
                break;
            case 'z':     // closepath
                break;
        }
    } 

    [self updatePathSegmentsAbsoluteValues:self.pathSegmentsArray];
    
    [self updatePathInDOMForElement:pathElement pathSegmentsArray:aPathsArray];

    // update selection rect for path element
    //[svgXMLDOMSelectionManager offsetSelectionRectForDOMElement:pathElement
    //        deltaX:deltaX deltaY:deltaY];
    
    // work-around webkit bug to fix bounding rect, replace existing DOM path element
    DOMDocument * domDocument = [[svgWebKitController.svgWebView mainFrame] DOMDocument];
    MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)[NSApp delegate];
    WebKitInterface * webKitInterface = [macSVGAppDelegate webKitInterface];
    DOMElement * newPathElement = [webKitInterface replaceDOMElement:pathElement domDocument:domDocument];

    // replace domElement in selectedElementsArray
    SelectedElementsManager * selectedElementsManager = svgXMLDOMSelectionManager.selectedElementsManager;
    [selectedElementsManager replaceDOMElement:pathElement newElement:newPathElement];
}

//==================================================================================
//	modifyPath
//==================================================================================

- (void)modifyPath
{
    //NSLog(@"modifyPath");       // mousedown move event, i.e., dragging
    
    NSString * selectedPathMode = [macSVGDocumentWindowController selectedPathMode];

    if ([selectedPathMode isEqualToString:@"Freestyle Path"] == YES)
    {
        [self extendFreestylePath];
    }
    else
    {
        if (self.pathSegmentIndex < 0)
        {
            if ([self.pathSegmentsArray count] > 0)
            {
                self.pathSegmentIndex = [self.pathSegmentsArray count] - 1;
            }
        }
    
        if (self.pathSegmentIndex > 0) 
        {
            NSMutableDictionary * pathSegmentDictionary = [self.pathSegmentsArray objectAtIndex:self.pathSegmentIndex];
            NSString * pathCommandString = [pathSegmentDictionary objectForKey:@"command"];
            unichar pathCommand = [pathCommandString characterAtIndex:0];

            switch (pathCommand)
            {
                case 'M':     // moveto absolute
                {
                    // No action required
                    break;
                }
                case 'm':     // moveto relative
                {
                    // No action required
                    break;
                }
                case 'L':     // lineto absolute
                {
                    // No action required
                    break;
                }
                case 'l':     // lineto relative
                {
                    // No action required
                    break;
                }
                case 'H':     // horizontal lineto absolute
                {
                    // No action required
                    break;
                }
                case 'h':     // horizontal lineto relative
                {
                    // No action required
                    break;
                }
                case 'V':     // vertical lineto absolute
                {
                    // No action required
                    break;
                }
                case 'v':     // vertical lineto relative
                {
                    // No action required
                    break;
                }
                case 'C':     // cubic curveto absolute
                {
                    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                    
                    float x = [xString floatValue];
                    float y = [yString floatValue];
                    
                    float deltaX = domMouseEventsController.currentMousePoint.x - x;
                    float deltaY = domMouseEventsController.currentMousePoint.y - y;
                    
                    float newX2 = x - deltaX;
                    float newY2 = y - deltaY;
                    
                    NSString * newX2String = [self allocFloatString:newX2];
                    NSString * newY2String = [self allocFloatString:newY2];

                    [pathSegmentDictionary setObject:newX2String forKey:@"x2"];    // control point x2
                    [pathSegmentDictionary setObject:newY2String forKey:@"y2"];    // control point y2

                    break;
                }
                case 'c':     // cubic curveto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];

                    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];

                    float x = [xString floatValue];
                    float y = [yString floatValue];
                    
                    float mouseRelX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                    float mouseRelY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                    
                    float deltaX = x - mouseRelX;
                    float deltaY = y - mouseRelY;
                   
                    float newX2 = x + deltaX;
                    float newY2 = y + deltaY;

                    NSString * newX2String = [self allocFloatString:newX2];
                    NSString * newY2String = [self allocFloatString:newY2];

                    [pathSegmentDictionary setObject:newX2String forKey:@"x2"];
                    [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
                    
                    break;
                }
                case 'S':     // smooth cubic curveto absolute
                {
                    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                    
                    float x = [xString floatValue];
                    float y = [yString floatValue];
                    
                    float deltaX = domMouseEventsController.currentMousePoint.x - x;
                    float deltaY = domMouseEventsController.currentMousePoint.y - y;
                    
                    float newX2 = x - deltaX;
                    float newY2 = y - deltaY;
                                    
                    NSString * newX2String = [self allocFloatString:newX2];
                    NSString * newY2String = [self allocFloatString:newY2];

                    [pathSegmentDictionary setObject:newX2String forKey:@"x2"];    // control point 2 x
                    [pathSegmentDictionary setObject:newY2String forKey:@"y2"];    // control point 2 y

                    break;
                }
                case 's':     // smooth cubic curveto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];

                    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];

                    float x = [xString floatValue];
                    float y = [yString floatValue];
                    
                    float mouseRelX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                    float mouseRelY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                    
                    float deltaX = x - mouseRelX;
                    float deltaY = y - mouseRelY;
                   
                    float newX2 = x + deltaX;
                    float newY2 = y + deltaY;
                    
                    NSString * newX2String = [self allocFloatString:newX2];
                    NSString * newY2String = [self allocFloatString:newY2];

                    [pathSegmentDictionary setObject:newX2String forKey:@"x2"];
                    [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
                    
                    break;
                }
                case 'Q':     // quadratic curveto absolute
                {
                    NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                    NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                    
                    float x1 = [x1String floatValue];
                    float y1 = [y1String floatValue];
                    
                    float deltaX = domMouseEventsController.currentMousePoint.x - domMouseEventsController.previousMousePoint.x;
                    float deltaY = domMouseEventsController.currentMousePoint.y - domMouseEventsController.previousMousePoint.y;
                    
                    float newX1 = x1 - deltaX;
                    float newY1 = y1 - deltaY;
                                    
                    NSString * newX1String = [self allocFloatString:newX1];
                    NSString * newY1String = [self allocFloatString:newY1];

                    [pathSegmentDictionary setObject:newX1String forKey:@"x1"];
                    [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

                    break;
                }
                case 'q':     // quadratic curveto relative
                {
                    NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                    NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                    
                    float x1 = [x1String floatValue];
                    float y1 = [y1String floatValue];
                    
                    float deltaX = domMouseEventsController.currentMousePoint.x - domMouseEventsController.previousMousePoint.x;
                    float deltaY = domMouseEventsController.currentMousePoint.y - domMouseEventsController.previousMousePoint.y;
                    
                    float newX1 = x1 - deltaX;
                    float newY1 = y1 - deltaY;
                                    
                    NSString * newX1String = [self allocFloatString:newX1];
                    NSString * newY1String = [self allocFloatString:newY1];

                    [pathSegmentDictionary setObject:newX1String forKey:@"x1"];
                    [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

                    break;
                }
                case 'T':     // smooth quadratic curveto absolute
                {
                    NSString * newXString = [self allocFloatString:domMouseEventsController.currentMousePoint.x];
                    NSString * newYString = [self allocFloatString:domMouseEventsController.currentMousePoint.y];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 't':     // smooth quadratic curveto relative
                {
                    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                    
                    float x = [xString floatValue];
                    float y = [yString floatValue];
                    
                    float deltaX = domMouseEventsController.currentMousePoint.x - domMouseEventsController.previousMousePoint.x;
                    float deltaY = domMouseEventsController.currentMousePoint.y - domMouseEventsController.previousMousePoint.y;
                    
                    float newX = x - deltaX;
                    float newY = y - deltaY;
                                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 'A':     // elliptical arc absolute
                {
                    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                    
                    float x = [xString floatValue];
                    float y = [yString floatValue];
                    
                    float deltaX = domMouseEventsController.currentMousePoint.x - x;
                    float deltaY = domMouseEventsController.currentMousePoint.y - y;
                    
                    float newX = x - deltaX;
                    float newY = y - deltaY;
                                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 'a':     // elliptical arc relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];

                    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];

                    float x = [xString floatValue];
                    float y = [yString floatValue];
                    
                    float mouseRelX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                    float mouseRelY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                    
                    float deltaX = x - mouseRelX ;
                    float deltaY = y - mouseRelY;
                   
                    float newX = x + deltaX;
                    float newY = y + deltaY;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 'Z':     // closepath absolute
                {
                    // No action required
                    break;
                }
                case 'z':     // closepath
                {
                    // No action required
                    break;
                }
            }
        }
    }

    [self updatePathSegmentsAbsoluteValues:self.pathSegmentsArray];

    [self updateActivePathInDOM];
}


//==================================================================================
//	restartLastPathSegment
//==================================================================================

- (void)restartLastPathSegment
{
    NSInteger pathSegmentsArrayCount = [self.pathSegmentsArray count];
    if (pathSegmentsArrayCount > 0)
    {
        [self deleteLastSegmentInPath];
        
        pathSegmentsArrayCount = [self.pathSegmentsArray count];
        NSPoint lastSegmentPoint = [self absoluteXYPointAtPathSegmentIndex:(pathSegmentsArrayCount - 1)];
        
        if (lastSegmentPoint.x != NSNotFound)
        {
            domMouseEventsController.currentMousePoint = lastSegmentPoint;
        }

        if (self.pathSegmentIndex > 0)
        {
            self.pathSegmentIndex = pathSegmentsArrayCount - 1;
        }
        
        [self extendPath];
    }
}

//==================================================================================
//	extendPath
//==================================================================================

- (void)extendPath
{
    // called on mouseup event, assumes a previous path command exists in pathSegmentsArray, e.g. 'M'
    
    BOOL extendPathSuccess = YES;
    NSMutableDictionary * newPathSegmentDictionary = NULL;

    NSString * selectedPathMode = [macSVGDocumentWindowController selectedPathMode];

    if ([selectedPathMode isEqualToString:@"Freestyle Path"] == YES)
    {
    }
    else
    {
        if (self.selectedPathElement != NULL)
        {
            if ([self.pathSegmentsArray count] == 0)
            {
                [self buildPathSegmentsArray:self.selectedPathElement];
                NSInteger pathSegmentsArrayCount = [self.pathSegmentsArray count];
                if (pathSegmentsArrayCount > 0)
                {
                    self.pathSegmentIndex = [self.pathSegmentsArray count] - 1;
                }
                else
                {
                    self.pathSegmentIndex = 0;
                }
            }
            if (self.pathSegmentIndex < 0)
            {
                self.pathSegmentIndex = 0;
            }
        }
        else
        {
            if ([self.pathSegmentsArray count] == 1)
            {
                self.pathSegmentIndex = 0;
                
                if (svgXMLDOMSelectionManager.activeXMLElement != NULL)
                {
                    self.selectedPathElement = svgXMLDOMSelectionManager.activeXMLElement;
                }
                else
                {
                    self.pathSegmentIndex = -1;
                }
            }
            else
            {
                self.pathSegmentIndex = -1;
            }
        }
    
        if (self.pathSegmentIndex >= 0)
        {
            if (self.pathSegmentIndex < [self.pathSegmentsArray count])
            {
                NSMutableDictionary * pathSegmentDictionary = [self.pathSegmentsArray objectAtIndex:self.pathSegmentIndex];
                NSString * previousPathCommandString = [pathSegmentDictionary objectForKey:@"command"];
                unichar previousPathCommand = [previousPathCommandString characterAtIndex:0];
                
                BOOL pathWasRelative = NO;
                if (previousPathCommand >= 'a')
                {
                    if (previousPathCommand <= 'z')
                    {
                        pathWasRelative = YES;
                    }
                }
                
                NSString * previousXString = [pathSegmentDictionary objectForKey:@"x"];     // endpoint x
                NSString * previousYString = [pathSegmentDictionary objectForKey:@"y"];     // endpoint y

                NSString * newXString = [self allocFloatString:domMouseEventsController.currentMousePoint.x];
                NSString * newYString = [self allocFloatString:domMouseEventsController.currentMousePoint.y];

                newPathSegmentDictionary = [[NSMutableDictionary alloc] init];
                
                NSPoint startPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                NSNumber * absoluteStartX = [NSNumber numberWithFloat:startPathPoint.x];
                NSNumber * absoluteStartY = [NSNumber numberWithFloat:startPathPoint.y];
                [newPathSegmentDictionary setObject:absoluteStartX forKey:@"absoluteStartX"];
                [newPathSegmentDictionary setObject:absoluteStartY forKey:@"absoluteStartY"];
                
                NSString * selectedPathMode = [macSVGDocumentWindowController selectedPathMode];
                
                if ([selectedPathMode isEqualToString:@"Move To"] == YES)
                {
                    if (self.useRelativePathCoordinates == YES)
                    {
                        NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                        
                        float newRelX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                        float newRelY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                        
                        NSString * newRelXString = [self allocFloatString:newRelX];
                        NSString * newRelYString = [self allocFloatString:newRelY];
                    
                        [newPathSegmentDictionary setObject:@"m" forKey:@"command"];
                        
                        [newPathSegmentDictionary setObject:newRelXString forKey:@"x"];
                        [newPathSegmentDictionary setObject:newRelYString forKey:@"y"];
                    }
                    else
                    {
                        [newPathSegmentDictionary setObject:@"M" forKey:@"command"];
                        
                        [newPathSegmentDictionary setObject:newXString forKey:@"x"];
                        [newPathSegmentDictionary setObject:newYString forKey:@"y"];
                    }
                }
                else if ([selectedPathMode isEqualToString:@"Line To"] == YES)
                {
                    if (self.useRelativePathCoordinates == YES)
                    {
                        NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                        float newRelX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                        float newRelY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                        
                        NSString * newRelXString = [self allocFloatString:newRelX];
                        NSString * newRelYString = [self allocFloatString:newRelY];
                    
                        [newPathSegmentDictionary setObject:@"l" forKey:@"command"];
                        
                        [newPathSegmentDictionary setObject:newRelXString forKey:@"x"];
                        [newPathSegmentDictionary setObject:newRelYString forKey:@"y"];
                    }
                    else
                    {
                        [newPathSegmentDictionary setObject:@"L" forKey:@"command"];
                        
                        [newPathSegmentDictionary setObject:newXString forKey:@"x"];
                        [newPathSegmentDictionary setObject:newYString forKey:@"y"];
                    }
                }
                else if ([selectedPathMode isEqualToString:@"Horizontal Line"] == YES)
                {
                    if (self.useRelativePathCoordinates == YES)
                    {
                        NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                        float newRelX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                        
                        NSString * newRelXString = [self allocFloatString:newRelX];
                    
                        [newPathSegmentDictionary setObject:@"h" forKey:@"command"];
                        
                        [newPathSegmentDictionary setObject:newRelXString forKey:@"x"];
                    }
                    else
                    {
                        [newPathSegmentDictionary setObject:@"H" forKey:@"command"];
                        
                        [newPathSegmentDictionary setObject:newXString forKey:@"x"];
                    }
                }
                else if ([selectedPathMode isEqualToString:@"Vertical Line"] == YES)
                {
                    if (self.useRelativePathCoordinates == YES)
                    {
                        NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                        float newRelY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                        
                        NSString * newRelYString = [self allocFloatString:newRelY];
                    
                        [newPathSegmentDictionary setObject:@"v" forKey:@"command"];
                        
                        [newPathSegmentDictionary setObject:newRelYString forKey:@"y"];
                    }
                    else
                    {
                        [newPathSegmentDictionary setObject:@"V" forKey:@"command"];
                        
                        [newPathSegmentDictionary setObject:newYString forKey:@"y"];
                    }
                }
                else if ([selectedPathMode isEqualToString:@"Cubic Curve"] == YES)
                {
                    if (previousPathCommand == 'C')
                    {
                        NSString * previousX2String = [pathSegmentDictionary objectForKey:@"x2"];     // control point 2 x
                        NSString * previousY2String = [pathSegmentDictionary objectForKey:@"y2"];     // control point 2 y

                        float previousX2 = [previousX2String floatValue];
                        float previousY2 = [previousY2String floatValue];

                        float previousX = [previousXString floatValue];
                        float previousY = [previousYString floatValue];

                        float deltaX = previousX - previousX2;
                        float deltaY = previousY - previousY2;
                        
                        float newX1 = previousX + deltaX;
                        float newY1 = previousY + deltaY;
                        
                        if (self.curveSegmentContinuity == NO)
                        {
                            newX1 = previousX;
                            newY1 = previousY;
                        }
                        
                        if (self.useRelativePathCoordinates == YES)
                        {
                            NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                            float relX = newX1 - currentPathPoint.x;
                            float relY = newY1 - currentPathPoint.y;
                        
                            NSString * relX1String = [self allocFloatString:relX];
                            NSString * relY1String = [self allocFloatString:relY];
                        
                            [newPathSegmentDictionary setObject:@"c" forKey:@"command"];
                            
                            [newPathSegmentDictionary setObject:relX1String forKey:@"x1"];
                            [newPathSegmentDictionary setObject:relY1String forKey:@"y1"];
                            
                            [newPathSegmentDictionary setObject:relX1String forKey:@"x2"];
                            [newPathSegmentDictionary setObject:relY1String forKey:@"y2"];
                            
                            [newPathSegmentDictionary setObject:relX1String forKey:@"x"];
                            [newPathSegmentDictionary setObject:relY1String forKey:@"y"];
                        }
                        else
                        {
                            NSString * newX1String = [self allocFloatString:newX1];
                            NSString * newY1String = [self allocFloatString:newY1];
                        
                            [newPathSegmentDictionary setObject:@"C" forKey:@"command"];
                            
                            [newPathSegmentDictionary setObject:newXString forKey:@"x"];
                            [newPathSegmentDictionary setObject:newYString forKey:@"y"];
                            
                            [newPathSegmentDictionary setObject:newX1String forKey:@"x1"];
                            [newPathSegmentDictionary setObject:newY1String forKey:@"y1"];
                            
                            [newPathSegmentDictionary setObject:newXString forKey:@"x2"];
                            [newPathSegmentDictionary setObject:newYString forKey:@"y2"];
                        }
                    }
                    else if (previousPathCommand == 'c')
                    {
                        if (self.useRelativePathCoordinates == YES)
                        {
                            NSString * previousXString = [pathSegmentDictionary objectForKey:@"x"];
                            NSString * previousYString = [pathSegmentDictionary objectForKey:@"y"];
                            NSString * previousX2String = [pathSegmentDictionary objectForKey:@"x2"];
                            NSString * previousY2String = [pathSegmentDictionary objectForKey:@"y2"];
                        
                            float previousX = [previousXString floatValue];
                            float previousY = [previousYString floatValue];
                            float previousX2 = [previousX2String floatValue];
                            float previousY2 = [previousY2String floatValue];
                            
                            float deltaX = previousX - previousX2;
                            float deltaY = previousY - previousY2;
                            
                            NSString * newX1String = [self allocFloatString:deltaX];
                            NSString * newY1String = [self allocFloatString:deltaY];

                            [newPathSegmentDictionary setObject:@"c" forKey:@"command"];
                            
                            [newPathSegmentDictionary setObject:newX1String forKey:@"x1"];
                            [newPathSegmentDictionary setObject:newY1String forKey:@"y1"];
                            
                            [newPathSegmentDictionary setObject:@"0" forKey:@"x2"];
                            [newPathSegmentDictionary setObject:@"0" forKey:@"y2"];
                            
                            [newPathSegmentDictionary setObject:@"0" forKey:@"x"];
                            [newPathSegmentDictionary setObject:@"0" forKey:@"y"];
                        }
                        else
                        {
                            NSString * previousX2String = [pathSegmentDictionary objectForKey:@"x2"];     // control point 2 x
                            NSString * previousY2String = [pathSegmentDictionary objectForKey:@"y2"];     // control point 2 y

                            float previousX2 = [previousX2String floatValue];
                            float previousY2 = [previousY2String floatValue];

                            float previousX = [previousXString floatValue];
                            float previousY = [previousYString floatValue];

                            float deltaX = previousX - previousX2;
                            float deltaY = previousY - previousY2;
                            
                            float newX1 = previousX + deltaX;
                            float newY1 = previousY + deltaY;

                            NSString * newX1String = [self allocFloatString:newX1];
                            NSString * newY1String = [self allocFloatString:newY1];
                        
                            [newPathSegmentDictionary setObject:@"C" forKey:@"command"];
                            
                            [newPathSegmentDictionary setObject:newXString forKey:@"x"];
                            [newPathSegmentDictionary setObject:newYString forKey:@"y"];
                            
                            [newPathSegmentDictionary setObject:newX1String forKey:@"x1"];
                            [newPathSegmentDictionary setObject:newY1String forKey:@"y1"];
                            
                            [newPathSegmentDictionary setObject:newXString forKey:@"x2"];
                            [newPathSegmentDictionary setObject:newYString forKey:@"y2"];
                        }
                    }
                    else
                    {
                        // set starting point for first cubic path segment
                        if (self.useRelativePathCoordinates == YES)
                        {
                            NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                            float newRelX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                            float newRelY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                            
                            NSString * newRelXString = [self allocFloatString:newRelX];
                            NSString * newRelYString = [self allocFloatString:newRelY];
                        
                            [newPathSegmentDictionary setObject:@"c" forKey:@"command"];
                            
                            [newPathSegmentDictionary setObject:newRelXString forKey:@"x1"];
                            [newPathSegmentDictionary setObject:newRelYString forKey:@"y1"];
                            
                            [newPathSegmentDictionary setObject:newRelXString forKey:@"x2"];
                            [newPathSegmentDictionary setObject:newRelYString forKey:@"y2"];
                            
                            [newPathSegmentDictionary setObject:newRelXString forKey:@"x"];
                            [newPathSegmentDictionary setObject:newRelYString forKey:@"y"];
                        }
                        else
                        {
                            [newPathSegmentDictionary setObject:@"C" forKey:@"command"];
                            
                            [newPathSegmentDictionary setObject:newXString forKey:@"x1"];
                            [newPathSegmentDictionary setObject:newYString forKey:@"y1"];
                            
                            [newPathSegmentDictionary setObject:newXString forKey:@"x2"];
                            [newPathSegmentDictionary setObject:newYString forKey:@"y2"];
                            
                            [newPathSegmentDictionary setObject:newXString forKey:@"x"];
                            [newPathSegmentDictionary setObject:newYString forKey:@"y"];
                        }
                    }
                }
                else if ([selectedPathMode isEqualToString:@"Smooth Cubic Curve"] == YES)
                {
                    if (self.useRelativePathCoordinates == YES)
                    {
                        NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                        float newRelX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                        float newRelY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                        
                        NSString * newRelXString = [self allocFloatString:newRelX];
                        NSString * newRelYString = [self allocFloatString:newRelY];
                    
                        [newPathSegmentDictionary setObject:@"s" forKey:@"command"];
                        
                        [newPathSegmentDictionary setObject:newRelXString forKey:@"x2"];
                        [newPathSegmentDictionary setObject:newRelYString forKey:@"y2"];
                                        
                        [newPathSegmentDictionary setObject:newRelXString forKey:@"x"];
                        [newPathSegmentDictionary setObject:newRelYString forKey:@"y"];
                    }
                    else
                    {
                        [newPathSegmentDictionary setObject:@"S" forKey:@"command"];
                        
                        [newPathSegmentDictionary setObject:newXString forKey:@"x2"];
                        [newPathSegmentDictionary setObject:newYString forKey:@"y2"];
                        
                        [newPathSegmentDictionary setObject:newXString forKey:@"x"];
                        [newPathSegmentDictionary setObject:newYString forKey:@"y"];
                    }
                }
                else if ([selectedPathMode isEqualToString:@"Quadratic Curve"] == YES)
                {
                    if (self.useRelativePathCoordinates == YES)
                    {
                        NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                        float newRelX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                        float newRelY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                        
                        NSString * newRelXString = [self allocFloatString:newRelX];
                        NSString * newRelYString = [self allocFloatString:newRelY];
                    
                        [newPathSegmentDictionary setObject:@"q" forKey:@"command"];
                        
                        [newPathSegmentDictionary setObject:newRelXString forKey:@"x1"];
                        [newPathSegmentDictionary setObject:newRelYString forKey:@"y1"];
                                        
                        [newPathSegmentDictionary setObject:newRelXString forKey:@"x"];
                        [newPathSegmentDictionary setObject:newRelYString forKey:@"y"];
                    }
                    else
                    {
                        [newPathSegmentDictionary setObject:@"Q" forKey:@"command"];
                        
                        [newPathSegmentDictionary setObject:newXString forKey:@"x1"];
                        [newPathSegmentDictionary setObject:newYString forKey:@"y1"];
                        
                        [newPathSegmentDictionary setObject:newXString forKey:@"x"];
                        [newPathSegmentDictionary setObject:newYString forKey:@"y"];
                    }
                }
                else if ([selectedPathMode isEqualToString:@"Smooth Quadratic Curve"] == YES)
                {
                    if (self.useRelativePathCoordinates == YES)
                    {
                        NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                        float newRelX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                        float newRelY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                        
                        NSString * newRelXString = [self allocFloatString:newRelX];
                        NSString * newRelYString = [self allocFloatString:newRelY];
                    
                        [newPathSegmentDictionary setObject:@"t" forKey:@"command"];
                        
                        [newPathSegmentDictionary setObject:newRelXString forKey:@"x"];
                        [newPathSegmentDictionary setObject:newRelYString forKey:@"y"];
                    }
                    else
                    {
                        [newPathSegmentDictionary setObject:@"T" forKey:@"command"];
                        
                        [newPathSegmentDictionary setObject:newXString forKey:@"x"];
                        [newPathSegmentDictionary setObject:newYString forKey:@"y"];
                    }
                }
                else if ([selectedPathMode isEqualToString:@"Elliptical Arc"] == YES)
                {
                    if (previousPathCommand == 'A')
                    {
                        if (self.useRelativePathCoordinates == YES)
                        {
                            NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                            float newRelX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                            float newRelY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                            
                            NSString * newRelXString = [self allocFloatString:newRelX];
                            NSString * newRelYString = [self allocFloatString:newRelY];
                            
                            [newPathSegmentDictionary setObject:@"a" forKey:@"command"];
                            
                            [newPathSegmentDictionary setObject:newRelXString forKey:@"x"];
                            [newPathSegmentDictionary setObject:newRelYString forKey:@"y"];
                            [newPathSegmentDictionary setObject:self.xAxisRotationString forKey:@"x-axis-rotation"];
                            [newPathSegmentDictionary setObject:self.largeArcFlagString forKey:@"large-arc-flag"];
                            [newPathSegmentDictionary setObject:self.sweepFlagString forKey:@"sweep-flag"];
                            [newPathSegmentDictionary setObject:self.pathRadiusXString forKey:@"rx"];
                            [newPathSegmentDictionary setObject:self.pathRadiusYString forKey:@"ry"];
                        }
                        else
                        {
                            [newPathSegmentDictionary setObject:@"A" forKey:@"command"];
                            
                            [newPathSegmentDictionary setObject:newXString forKey:@"x"];
                            [newPathSegmentDictionary setObject:newYString forKey:@"y"];
                            [newPathSegmentDictionary setObject:self.xAxisRotationString forKey:@"x-axis-rotation"];
                            [newPathSegmentDictionary setObject:self.largeArcFlagString forKey:@"large-arc-flag"];
                            [newPathSegmentDictionary setObject:self.sweepFlagString forKey:@"sweep-flag"];
                            [newPathSegmentDictionary setObject:self.pathRadiusXString forKey:@"rx"];
                            [newPathSegmentDictionary setObject:self.pathRadiusYString forKey:@"ry"];
                        }
                    }
                    else if (previousPathCommand == 'a')
                    {
                        if (self.useRelativePathCoordinates == YES)
                        {
                            float newRelX = 0;
                            float newRelY = 0;
                            
                            NSString * newRelXString = [self allocFloatString:newRelX];
                            NSString * newRelYString = [self allocFloatString:newRelY];
                            
                            [newPathSegmentDictionary setObject:@"a" forKey:@"command"];
                            
                            [newPathSegmentDictionary setObject:newRelXString forKey:@"x"];
                            [newPathSegmentDictionary setObject:newRelYString forKey:@"y"];
                            [newPathSegmentDictionary setObject:self.xAxisRotationString forKey:@"x-axis-rotation"];
                            [newPathSegmentDictionary setObject:self.largeArcFlagString forKey:@"large-arc-flag"];
                            [newPathSegmentDictionary setObject:self.sweepFlagString forKey:@"sweep-flag"];
                            [newPathSegmentDictionary setObject:self.pathRadiusXString forKey:@"rx"];
                            [newPathSegmentDictionary setObject:self.pathRadiusYString forKey:@"ry"];
                        }
                        else
                        {
                            [newPathSegmentDictionary setObject:@"A" forKey:@"command"];
                            
                            [newPathSegmentDictionary setObject:newXString forKey:@"x"];
                            [newPathSegmentDictionary setObject:newYString forKey:@"y"];
                            [newPathSegmentDictionary setObject:self.xAxisRotationString forKey:@"x-axis-rotation"];
                            [newPathSegmentDictionary setObject:self.largeArcFlagString forKey:@"large-arc-flag"];
                            [newPathSegmentDictionary setObject:self.sweepFlagString forKey:@"sweep-flag"];
                            [newPathSegmentDictionary setObject:self.pathRadiusXString forKey:@"rx"];
                            [newPathSegmentDictionary setObject:self.pathRadiusYString forKey:@"ry"];
                        }
                    }
                    else
                    {
                        // setting first point for elliptical arc
                        if (self.useRelativePathCoordinates == YES)
                        {
                            NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                            float newRelX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                            float newRelY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                            
                            NSString * newRelXString = [self allocFloatString:newRelX];
                            NSString * newRelYString = [self allocFloatString:newRelY];
                            
                            [newPathSegmentDictionary setObject:@"a" forKey:@"command"];
                            
                            [newPathSegmentDictionary setObject:newRelXString forKey:@"x"];
                            [newPathSegmentDictionary setObject:newRelYString forKey:@"y"];
                            [newPathSegmentDictionary setObject:self.xAxisRotationString forKey:@"x-axis-rotation"];
                            [newPathSegmentDictionary setObject:self.largeArcFlagString forKey:@"large-arc-flag"];
                            [newPathSegmentDictionary setObject:self.sweepFlagString forKey:@"sweep-flag"];
                            [newPathSegmentDictionary setObject:self.pathRadiusXString forKey:@"rx"];
                            [newPathSegmentDictionary setObject:self.pathRadiusYString forKey:@"ry"];
                        }
                        else
                        {
                            [newPathSegmentDictionary setObject:@"A" forKey:@"command"];
                            
                            [newPathSegmentDictionary setObject:newXString forKey:@"x"];
                            [newPathSegmentDictionary setObject:newYString forKey:@"y"];
                            [newPathSegmentDictionary setObject:self.xAxisRotationString forKey:@"x-axis-rotation"];
                            [newPathSegmentDictionary setObject:self.largeArcFlagString forKey:@"large-arc-flag"];
                            [newPathSegmentDictionary setObject:self.sweepFlagString forKey:@"sweep-flag"];
                            [newPathSegmentDictionary setObject:self.pathRadiusXString forKey:@"rx"];
                            [newPathSegmentDictionary setObject:self.pathRadiusYString forKey:@"ry"];
                        }
                    }
                }
            }
            else
            {
                extendPathSuccess = NO;
            }
        }
        else
        {
            extendPathSuccess = NO;
        }
    
        if (extendPathSuccess == YES)
        {
            [self.pathSegmentsArray addObject:newPathSegmentDictionary];
            
            self.pathSegmentIndex = [self.pathSegmentsArray count] - 1;

            [self updatePathSegmentsAbsoluteValues:self.pathSegmentsArray];
            
            //NSLog(@"extendPath - pathSegmentsArray - %@", self.pathSegmentsArray);

            [self updateActivePathInDOM];
        }
        else
        {
            [macSVGDocumentWindowController setToolMode:toolModeArrowCursor];
            
            NSBeep();
        }
    }
}

//==================================================================================
//	editPathSegmentMoveto:
//==================================================================================

-(void) editPathSegmentMoveto:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * previousXString = [pathSegmentDictionary objectForKey:@"x"];     // endpoint x
    NSString * previousYString = [pathSegmentDictionary objectForKey:@"y"];     // endpoint y

    float previousX = [previousXString floatValue];
    float previousY = [previousYString floatValue];

    NSPoint  currentMousePoint = domMouseEventsController.currentMousePoint;
    
    if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
    {
        float deltaX = currentMousePoint.x - previousX;
        float deltaY = currentMousePoint.y - previousY;
        
        float newX = previousX + deltaX;
        float newY = previousY + deltaY;

        NSString * newXString = [self allocFloatString:newX];
        NSString * newYString = [self allocFloatString:newY];

        [pathSegmentDictionary setObject:newXString forKey:@"x"];
        [pathSegmentDictionary setObject:newYString forKey:@"y"];

        NSUInteger pathSegmentCount = [self.pathSegmentsArray count];
        if (self.pathSegmentIndex < (pathSegmentCount - 1))
        {
            NSMutableDictionary * nextPathSegmentDictionary =
                    [self.pathSegmentsArray objectAtIndex:(self.pathSegmentIndex + 1)];

            NSString * nextPathCommandString = [nextPathSegmentDictionary objectForKey:@"command"];
            unichar nextPathCommand = [nextPathCommandString characterAtIndex:0];
        
            if ((nextPathCommand == 'C') || (nextPathCommand == 'c'))
            {
                // modify control point in next segment for curve continuity
                NSString * previousX1String = [nextPathSegmentDictionary objectForKey:@"x1"];     // next control point x
                NSString * previousY1String = [nextPathSegmentDictionary objectForKey:@"y1"];     // next control point y
                
                float previousX1 = [previousX1String floatValue];
                float previousY1 = [previousY1String floatValue];

                float newX1 = previousX1 + deltaX;
                float newY1 = previousY1 + deltaY;

                NSString * newX1String = [self allocFloatString:newX1];
                NSString * newY1String = [self allocFloatString:newY1];

                [nextPathSegmentDictionary setObject:newX1String forKey:@"x1"];
                [nextPathSegmentDictionary setObject:newY1String forKey:@"y1"];
            }
        }
    }
}

//==================================================================================
//	editPathSegmentLineto:
//==================================================================================

-(void) editPathSegmentLineto:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * previousXString = [pathSegmentDictionary objectForKey:@"x"];     // endpoint x
    NSString * previousYString = [pathSegmentDictionary objectForKey:@"y"];     // endpoint y

    float previousX = [previousXString floatValue];
    float previousY = [previousYString floatValue];

    NSPoint  currentMousePoint = domMouseEventsController.currentMousePoint;
    
    if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
    {
        float deltaX = currentMousePoint.x - previousX;
        float deltaY = currentMousePoint.y - previousY;
        
        float newX = previousX + deltaX;
        float newY = previousY + deltaY;

        NSString * newXString = [self allocFloatString:newX];
        NSString * newYString = [self allocFloatString:newY];

        [pathSegmentDictionary setObject:newXString forKey:@"x"];
        [pathSegmentDictionary setObject:newYString forKey:@"y"];
    }
}

//==================================================================================
//	editPathSegmentHorizontal:
//==================================================================================

-(void) editPathSegmentHorizontal:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * previousXString = [pathSegmentDictionary objectForKey:@"x"];     // endpoint x

    float previousX = [previousXString floatValue];

    NSPoint  currentMousePoint = domMouseEventsController.currentMousePoint;
    
    if ([self.pathEditingKey isEqualToString:@"x"] == YES)
    {
        float deltaX = currentMousePoint.x - previousX;
        
        float newX = previousX + deltaX;

        NSString * newXString = [self allocFloatString:newX];

        [pathSegmentDictionary setObject:newXString forKey:@"x"];
    }
}


//==================================================================================
//	editPathSegmentVertical:
//==================================================================================

-(void) editPathSegmentVertical:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * previousYString = [pathSegmentDictionary objectForKey:@"y"];     // endpoint y

    float previousY = [previousYString floatValue];

    NSPoint  currentMousePoint = domMouseEventsController.currentMousePoint;
    
    if ([self.pathEditingKey isEqualToString:@"y"] == YES)
    {
        float deltaY = currentMousePoint.y - previousY;
        
        float newY = previousY + deltaY;

        NSString * newYString = [self allocFloatString:newY];

        [pathSegmentDictionary setObject:newYString forKey:@"y"];
    }
}

//==================================================================================
//	editPathSegmentCubicCurve:
//==================================================================================

-(void) editPathSegmentCubicCurve:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * commandString = [pathSegmentDictionary objectForKey:@"command"];

    NSString * previousXString = [pathSegmentDictionary objectForKey:@"x"];     // endpoint x
    NSString * previousYString = [pathSegmentDictionary objectForKey:@"y"];     // endpoint y
    NSString * previousX2String = [pathSegmentDictionary objectForKey:@"x2"];     // control point 2 x
    NSString * previousY2String = [pathSegmentDictionary objectForKey:@"y2"];     // control point 2 y

    float previousX = [previousXString floatValue];
    float previousY = [previousYString floatValue];
    float previousX2 = [previousX2String floatValue];
    float previousY2 = [previousY2String floatValue];
    
    NSPoint  currentMousePoint = domMouseEventsController.currentMousePoint;

    NSUInteger pathSegmentCount = [self.pathSegmentsArray count];
    
    if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
    {
        float deltaX = currentMousePoint.x - previousX;
        float deltaY = currentMousePoint.y - previousY;
        
        float newX = previousX + deltaX;
        float newY = previousY + deltaY;
        float newX2 = previousX2 + deltaX;
        float newY2 = previousY2 + deltaY;

        NSString * newXString = [self allocFloatString:newX];
        NSString * newYString = [self allocFloatString:newY];
        NSString * newX2String = [self allocFloatString:newX2];
        NSString * newY2String = [self allocFloatString:newY2];

        [pathSegmentDictionary setObject:newXString forKey:@"x"];
        [pathSegmentDictionary setObject:newYString forKey:@"y"];
                        
        [pathSegmentDictionary setObject:newX2String forKey:@"x2"];
        [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
        
        if (self.curveSegmentContinuity == YES)
        {
            // reflect control point in next segment for curve continuity
            if (self.pathSegmentIndex < (pathSegmentCount - 1))
            {
                NSMutableDictionary * nextPathSegmentDictionary =
                        [self.pathSegmentsArray objectAtIndex:(self.pathSegmentIndex + 1)];

                NSString * nextPathCommandString = [pathSegmentDictionary objectForKey:@"command"];
                unichar nextPathCommand = [nextPathCommandString characterAtIndex:0];
            
                if ((nextPathCommand == 'C') || (nextPathCommand == 'c'))
                {
                    float handleDeltaX = newX - newX2;
                    float handleDeltaY = newY - newY2;
                
                    float newX1 = newX + handleDeltaX;
                    float newY1 = newY + handleDeltaY;

                    NSString * newX1String = [self allocFloatString:newX1];
                    NSString * newY1String = [self allocFloatString:newY1];

                    [nextPathSegmentDictionary setObject:newX1String forKey:@"x1"];
                    [nextPathSegmentDictionary setObject:newY1String forKey:@"y1"];
                }
            }
        }
    }
    else if ([self.pathEditingKey isEqualToString:@"x1y1"] == YES)
    {
        float newX1 = currentMousePoint.x;
        float newY1 = currentMousePoint.y;
        
        if ([commandString isEqualToString:@"c"] == YES)
        {
            newX1 = 0;  // relative coordinates
            newY1 = 0;
        }
        
        float newAbsoluteX1 = currentMousePoint.x;
        float newAbsoluteY1 = currentMousePoint.y;
        
        if (editingMode == kPathEditingModePreviousSegment)
        {
            NSPoint previousSegmentPoint = NSMakePoint(0, 0);
            if (self.pathSegmentIndex > 0)
            {
                previousSegmentPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
            }
        
            float prevDeltaX = previousSegmentPoint.x - currentMousePoint.x;
            float prevDeltaY = previousSegmentPoint.y - currentMousePoint.y;
            
            newX1 = previousSegmentPoint.x + prevDeltaX;
            newY1 = previousSegmentPoint.y + prevDeltaY;
            
            newAbsoluteX1 = previousSegmentPoint.x + prevDeltaX;
            newAbsoluteY1 = previousSegmentPoint.y + prevDeltaY;
        }
    
        NSString * newX1String = [self allocFloatString:newX1];
        NSString * newY1String = [self allocFloatString:newY1];

        [pathSegmentDictionary setObject:newX1String forKey:@"x1"];
        [pathSegmentDictionary setObject:newY1String forKey:@"y1"];

        if (self.curveSegmentContinuity == YES)
        {
            // reflect control point in previous segment for curve continuity
            if (self.pathSegmentIndex > 0)
            {
                NSMutableDictionary * previousPathSegmentDictionary =
                        [self.pathSegmentsArray objectAtIndex:(self.pathSegmentIndex - 1)];

                NSString * previousPathCommandString = [pathSegmentDictionary objectForKey:@"command"];
                unichar previousPathCommand = [previousPathCommandString characterAtIndex:0];
            
                if ((previousPathCommand == 'C') || (previousPathCommand == 'c'))
                {
                    NSString * previousSegmentXString = [previousPathSegmentDictionary objectForKey:@"x"];     // endpoint x
                    NSString * previousSegmentYString = [previousPathSegmentDictionary objectForKey:@"y"];     // endpoint y
                    
                    float previousSegmentX = [previousSegmentXString floatValue];
                    float previousSegmentY = [previousSegmentYString floatValue];

                    float handleDeltaX = newX1 - previousSegmentX;
                    float handleDeltaY = newY1 - previousSegmentY;
                
                    float newX2 = previousSegmentX - handleDeltaX;
                    float newY2 = previousSegmentY - handleDeltaY;

                    NSString * newX2String = [self allocFloatString:newX2];
                    NSString * newY2String = [self allocFloatString:newY2];

                    [previousPathSegmentDictionary setObject:newX2String forKey:@"x2"];
                    [previousPathSegmentDictionary setObject:newY2String forKey:@"y2"];
                }
            }
        }
    }
    else if ([self.pathEditingKey isEqualToString:@"x2y2"] == YES)
    {
        float newX2 = currentMousePoint.x;
        float newY2 = currentMousePoint.y;

        if ([commandString isEqualToString:@"c"] == YES)
        {
            newX2 = 0;  // relative coordinates
            newY2 = 0;
        }

        if (editingMode == kPathEditingModeNextSegment)
        {
            float prevDeltaX = currentMousePoint.x - previousX;
            float prevDeltaY = currentMousePoint.y - previousY;
            newX2 = previousX - prevDeltaX;
            newY2 = previousY - prevDeltaY;
        }
    
        NSString * newX2String = [self allocFloatString:newX2];
        NSString * newY2String = [self allocFloatString:newY2];

        [pathSegmentDictionary setObject:newX2String forKey:@"x2"];
        [pathSegmentDictionary setObject:newY2String forKey:@"y2"];

        // reflect control point in next segment for curve continuity
        if (self.curveSegmentContinuity == YES)
        {
            if (self.pathSegmentIndex < (pathSegmentCount - 1))
            {
                NSMutableDictionary * nextPathSegmentDictionary =
                        [self.pathSegmentsArray objectAtIndex:(self.pathSegmentIndex + 1)];

                NSString * nextPathCommandString = [pathSegmentDictionary objectForKey:@"command"];
                unichar nextPathCommand = [nextPathCommandString characterAtIndex:0];
            
                if (nextPathCommand == 'C')
                {
                    float handleDeltaX = previousX - newX2;
                    float handleDeltaY = previousY - newY2;
                
                    float newX1 = previousX + handleDeltaX;
                    float newY1 = previousY + handleDeltaY;

                    NSString * newX1String = [self allocFloatString:newX1];
                    NSString * newY1String = [self allocFloatString:newY1];

                    [nextPathSegmentDictionary setObject:newX1String forKey:@"x1"];
                    [nextPathSegmentDictionary setObject:newY1String forKey:@"y1"];
                }

                if (nextPathCommand == 'c')
                {
                    float handleDeltaX = previousX - newX2;
                    float handleDeltaY = previousY - newY2;
                
                    float newX1 = previousX + handleDeltaX;
                    float newY1 = previousY + handleDeltaY;

                    NSString * newX1String = [self allocFloatString:newX1];
                    NSString * newY1String = [self allocFloatString:newY1];

                    [nextPathSegmentDictionary setObject:newX1String forKey:@"x1"];
                    [nextPathSegmentDictionary setObject:newY1String forKey:@"y1"];
                }
            }
        }
    }
    else if ([self.pathEditingKey isEqualToString:@"x0y0"] == YES)
    {
        // clicked on reflected handle of x1, y1
        float newX1 = currentMousePoint.x;
        float newY1 = currentMousePoint.y;
        
        if ([commandString isEqualToString:@"c"] == YES)
        {
            newX1 = 0;  // relative coordinates
            newY1 = 0;
        }
        
        float newAbsoluteX1 = currentMousePoint.x;
        float newAbsoluteY1 = currentMousePoint.y;
        
        NSPoint previousSegmentPoint = NSMakePoint(0, 0);
        if (self.pathSegmentIndex > 0)
        {
            previousSegmentPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
        }
    
        float prevDeltaX = previousSegmentPoint.x - currentMousePoint.x;
        float prevDeltaY = previousSegmentPoint.y - currentMousePoint.y;
        
        newX1 = previousSegmentPoint.x + prevDeltaX;
        newY1 = previousSegmentPoint.y + prevDeltaY;
        
        newAbsoluteX1 = previousSegmentPoint.x + prevDeltaX;
        newAbsoluteY1 = previousSegmentPoint.y + prevDeltaY;
    
        NSString * newX1String = [self allocFloatString:newX1];
        NSString * newY1String = [self allocFloatString:newY1];

        [pathSegmentDictionary setObject:newX1String forKey:@"x1"];
        [pathSegmentDictionary setObject:newY1String forKey:@"y1"];
    }
    else if ([self.pathEditingKey isEqualToString:@"x3y3"] == YES)
{
        // clicked on reflected handle of x2, y2

        float newX2 = currentMousePoint.x;
        float newY2 = currentMousePoint.y;

        if ([commandString isEqualToString:@"c"] == YES)
        {
            newX2 = 0;  // relative coordinates
            newY2 = 0;
        }

        float prevDeltaX = currentMousePoint.x - previousX;
        float prevDeltaY = currentMousePoint.y - previousY;
        
        newX2 = previousX - prevDeltaX;
        newY2 = previousY - prevDeltaY;
    
        NSString * newX2String = [self allocFloatString:newX2];
        NSString * newY2String = [self allocFloatString:newY2];

        [pathSegmentDictionary setObject:newX2String forKey:@"x2"];
        [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
    }
}

//==================================================================================
//	editPathSegmentSmoothCubicCurve:
//==================================================================================

-(void) editPathSegmentSmoothCubicCurve:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * previousXString = [pathSegmentDictionary objectForKey:@"x"];     // endpoint x
    NSString * previousYString = [pathSegmentDictionary objectForKey:@"y"];     // endpoint y
    NSString * previousX2String = [pathSegmentDictionary objectForKey:@"x2"];     // control point 2 x
    NSString * previousY2String = [pathSegmentDictionary objectForKey:@"y2"];     // control point 2 y

    float previousX = [previousXString floatValue];
    float previousY = [previousYString floatValue];
    float previousX2 = [previousX2String floatValue];
    float previousY2 = [previousY2String floatValue];

    NSPoint  currentMousePoint = domMouseEventsController.currentMousePoint;
    
    if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
    {
        float deltaX = currentMousePoint.x - previousX;
        float deltaY = currentMousePoint.y - previousY;
        
        float newX = previousX + deltaX;
        float newY = previousY + deltaY;
        float newX2 = previousX2 + deltaX;
        float newY2 = previousY2 + deltaY;

        NSString * newXString = [self allocFloatString:newX];
        NSString * newYString = [self allocFloatString:newY];
        NSString * newX2String = [self allocFloatString:newX2];
        NSString * newY2String = [self allocFloatString:newY2];

        [pathSegmentDictionary setObject:newXString forKey:@"x"];
        [pathSegmentDictionary setObject:newYString forKey:@"y"];
                        
        [pathSegmentDictionary setObject:newX2String forKey:@"x2"];
        [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
    }
    else if ([self.pathEditingKey isEqualToString:@"x2y2"] == YES)
    {
        float deltaX = currentMousePoint.x - previousX2;
        float deltaY = currentMousePoint.y - previousY2;

        float newX2 = previousX2 + deltaX;
        float newY2 = previousY2 + deltaY;
    
        NSString * newX2String = [self allocFloatString:newX2];
        NSString * newY2String = [self allocFloatString:newY2];

        [pathSegmentDictionary setObject:newX2String forKey:@"x2"];
        [pathSegmentDictionary setObject:newY2String forKey:@"y2"];
    }
}

//==================================================================================
//	editPathSegmentQuadraticCurve:
//==================================================================================

-(void) editPathSegmentQuadraticCurve:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * previousXString = [pathSegmentDictionary objectForKey:@"x"];     // endpoint x
    NSString * previousYString = [pathSegmentDictionary objectForKey:@"y"];     // endpoint y
    NSString * previousX1String = [pathSegmentDictionary objectForKey:@"x1"];     // control point 1 x
    NSString * previousY1String = [pathSegmentDictionary objectForKey:@"y1"];     // control point 1 y

    float previousX = [previousXString floatValue];
    float previousY = [previousYString floatValue];
    float previousX1 = [previousX1String floatValue];
    float previousY1 = [previousY1String floatValue];

    NSPoint  currentMousePoint = domMouseEventsController.currentMousePoint;

    //NSUInteger pathSegmentCount = [pathSegmentsArray count];
    
    if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
    {
        float deltaX = currentMousePoint.x - previousX;
        float deltaY = currentMousePoint.y - previousY;
        
        float newX = previousX + deltaX;
        float newY = previousY + deltaY;
        float newX1 = previousX1 + deltaX;
        float newY1 = previousY1 + deltaY;

        NSString * newXString = [self allocFloatString:newX];
        NSString * newYString = [self allocFloatString:newY];
        NSString * newX1String = [self allocFloatString:newX1];
        NSString * newY1String = [self allocFloatString:newY1];

        [pathSegmentDictionary setObject:newXString forKey:@"x"];
        [pathSegmentDictionary setObject:newYString forKey:@"y"];
                        
        [pathSegmentDictionary setObject:newX1String forKey:@"x1"];
        [pathSegmentDictionary setObject:newY1String forKey:@"y1"];
    }
    else if ([self.pathEditingKey isEqualToString:@"x1y1"] == YES)
    {
        float deltaX = currentMousePoint.x - previousX1;
        float deltaY = currentMousePoint.y - previousY1;

        float newX1 = previousX1 + deltaX;
        float newY1 = previousY1 + deltaY;
    
        NSString * newX1String = [self allocFloatString:newX1];
        NSString * newY1String = [self allocFloatString:newY1];

        [pathSegmentDictionary setObject:newX1String forKey:@"x1"];
        [pathSegmentDictionary setObject:newY1String forKey:@"y1"];
    }
}

//==================================================================================
//	editPathSegmentSmoothQuadraticCurve:
//==================================================================================

-(void) editPathSegmentSmoothQuadraticCurve:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * previousXString = [pathSegmentDictionary objectForKey:@"x"];     // endpoint x
    NSString * previousYString = [pathSegmentDictionary objectForKey:@"y"];     // endpoint y

    float previousX = [previousXString floatValue];
    float previousY = [previousYString floatValue];

    NSPoint  currentMousePoint = domMouseEventsController.currentMousePoint;

    //NSUInteger pathSegmentCount = [pathSegmentsArray count];
    
    if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
    {
        float deltaX = currentMousePoint.x - previousX;
        float deltaY = currentMousePoint.y - previousY;
        
        float newX = previousX + deltaX;
        float newY = previousY + deltaY;

        NSString * newXString = [self allocFloatString:newX];
        NSString * newYString = [self allocFloatString:newY];

        [pathSegmentDictionary setObject:newXString forKey:@"x"];
        [pathSegmentDictionary setObject:newYString forKey:@"y"];
    }
}

//==================================================================================
//	editPathSegmentEllipticalArc:
//==================================================================================

-(void) editPathSegmentEllipticalArc:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * previousXString = [pathSegmentDictionary objectForKey:@"x"];     // endpoint x
    NSString * previousYString = [pathSegmentDictionary objectForKey:@"y"];     // endpoint y

    float previousX = [previousXString floatValue];
    float previousY = [previousYString floatValue];

    NSPoint  currentMousePoint = domMouseEventsController.currentMousePoint;

    //NSUInteger pathSegmentCount = [pathSegmentsArray count];
    
    if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
    {
        float deltaX = currentMousePoint.x - previousX;
        float deltaY = currentMousePoint.y - previousY;
        
        float newX = previousX + deltaX;
        float newY = previousY + deltaY;

        NSString * newXString = [self allocFloatString:newX];
        NSString * newYString = [self allocFloatString:newY];

        [pathSegmentDictionary setObject:newXString forKey:@"x"];
        [pathSegmentDictionary setObject:newYString forKey:@"y"];
    }
}


//==================================================================================
//	editPath
//==================================================================================

- (void)editPath
{
    //NSLog(@"editPath");       // mousedown move event, i.e., dragging an endpoint or control point

    NSInteger pathSegmentCount = [self.pathSegmentsArray count];
    
    if (self.pathSegmentIndex >= 0)
    {
        if (self.pathSegmentIndex < pathSegmentCount)
        {
            NSMutableDictionary * pathSegmentDictionary = [self.pathSegmentsArray objectAtIndex:self.pathSegmentIndex];
            NSString * pathCommandString = [pathSegmentDictionary objectForKey:@"command"];
            unichar pathCommand = [pathCommandString characterAtIndex:0];

            switch (pathCommand)
            {
                case 'M':     // moveto absolute
                {
                    [self editPathSegmentMoveto:pathSegmentDictionary];
                    break;
                }
                case 'm':     // moveto relative
                {
                    [self editPathSegmentMoveto:pathSegmentDictionary];
                    break;
                }
                case 'L':     // lineto absolute
                {
                    [self editPathSegmentLineto:pathSegmentDictionary];
                    break;
                }
                case 'l':     // lineto relative
                {
                    [self editPathSegmentLineto:pathSegmentDictionary];
                    break;
                }
                case 'H':     // horizontal lineto absolute
                {
                    [self editPathSegmentHorizontal:pathSegmentDictionary];
                    break;
                }
                case 'h':     // horizontal lineto relative
                {
                    [self editPathSegmentHorizontal:pathSegmentDictionary];
                    break;
                }
                case 'V':     // vertical lineto absolute
                {
                    [self editPathSegmentVertical:pathSegmentDictionary];
                    break;
                }
                case 'v':     // vertical lineto relative
                {
                    [self editPathSegmentVertical:pathSegmentDictionary];
                    break;
                }
                case 'C':     // cubic curveto absolute
                {
                    [self editPathSegmentCubicCurve:pathSegmentDictionary];
                    break;
                }
                case 'c':     // cubic curveto relative
                {
                    [self editPathSegmentCubicCurve:pathSegmentDictionary];
                    break;
                }
                case 'S':     // smooth cubic curveto absolute
                {
                    [self editPathSegmentSmoothCubicCurve:pathSegmentDictionary];
                    break;
                }
                case 's':     // smooth cubic curveto relative
                {
                    [self editPathSegmentSmoothCubicCurve:pathSegmentDictionary];
                    break;
                }
                case 'Q':     // quadratic curveto absolute
                {
                    [self editPathSegmentQuadraticCurve:pathSegmentDictionary];
                    break;
                }
                case 'q':     // quadratic curveto relative
                {
                    [self editPathSegmentQuadraticCurve:pathSegmentDictionary];
                    break;
                }
                case 'T':     // smooth quadratic curveto absolute
                {
                    [self editPathSegmentSmoothQuadraticCurve:pathSegmentDictionary];
                    break;
                }
                case 't':     // smooth quadratic curveto relative
                {
                    [self editPathSegmentSmoothQuadraticCurve:pathSegmentDictionary];
                    break;
                }
                case 'A':     // elliptical arc absolute
                {
                    [self editPathSegmentEllipticalArc:pathSegmentDictionary];
                    break;
                }
                case 'a':     // elliptical arc relative
                {
                    [self editPathSegmentEllipticalArc:pathSegmentDictionary];
                    break;
                }
                case 'Z':     // closepath absolute
                {
                    break;
                }
                case 'z':     // closepath
                {
                    break;
                }
            }

            [self updatePathSegmentsAbsoluteValues:self.pathSegmentsArray];
            
            svgXMLDOMSelectionManager.activeXMLElement = self.selectedPathElement;
            
            [self updateActivePathInDOM];
        }
        else
        {
            NSLog(@"SVGPathEditor editPath-a invalid pathSegmentIndex=%lu pathSegmentCount=%lu",
                    self.pathSegmentIndex, pathSegmentCount);
        }
    }
    else
    {
        //NSLog(@"SVGPathEditor editPath-b invalid pathSegmentIndex=%lu pathSegmentCount=%lu",
        //        self.pathSegmentIndex, pathSegmentCount);
    }
}

//==================================================================================
//	handleMouseHoverEventForPath:
//==================================================================================

-(void) handleMouseHoverEventForPath:(DOMEvent *)event
{
    //NSLog(@"handleMouseHoverEventForPath");       // mouse hovering event

    NSString * selectedPathMode = [macSVGDocumentWindowController selectedPathMode];

    if ([selectedPathMode isEqualToString:@"Freestyle Path"] == YES)
    {
        // nothing to do
    }
    else
    {
        if (self.pathSegmentIndex > 0) 
        {
            NSMutableDictionary * pathSegmentDictionary = [self.pathSegmentsArray objectAtIndex:self.pathSegmentIndex];
            NSString * pathCommandString = [pathSegmentDictionary objectForKey:@"command"];
            unichar pathCommand = [pathCommandString characterAtIndex:0];

            switch (pathCommand) 
            {
                case 'M':     // moveto absolute
                {
                    float newX = domMouseEventsController.currentMousePoint.x;
                    float newY = domMouseEventsController.currentMousePoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 'm':     // moveto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                    float newY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 'L':     // lineto absolute
                {
                    float newX = domMouseEventsController.currentMousePoint.x;
                    float newY = domMouseEventsController.currentMousePoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 'l':     // lineto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                    float newY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 'H':     // horizontal lineto absolute
                {
                    float newX = domMouseEventsController.currentMousePoint.x;
                    
                    NSString * newXString = [self allocFloatString:newX];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];

                    break;
                }
                case 'h':     // horizontal lineto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                    
                    NSString * newXString = [self allocFloatString:newX];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];

                    break;
                }
                case 'V':     // vertical lineto absolute
                {
                    float newY = domMouseEventsController.currentMousePoint.y;
                    
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 'v':     // vertical lineto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 'C':     // curveto absolute
                {
                    float newX = domMouseEventsController.currentMousePoint.x;
                    float newY = domMouseEventsController.currentMousePoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x2"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y2"];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];
                    
                    break;
                }
                case 'c':     // curveto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                    float newY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x2"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y2"];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];
                    
                    break;
                }
                case 'S':     // smooth curveto absolute
                {
                    float newX = domMouseEventsController.currentMousePoint.x;
                    float newY = domMouseEventsController.currentMousePoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x2"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y2"];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 's':     // smooth curveto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                    float newY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x2"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y2"];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];
                    
                    break;
                }
                case 'Q':     // quadratic Bezier curve absolute
                {
                    float newX = domMouseEventsController.currentMousePoint.x;
                    float newY = domMouseEventsController.currentMousePoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 'q':     // quadratic Bezier curve relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                    float newY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x1"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y1"];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];
                    
                    break;
                }
                case 'T':     // smooth quadratic Bezier curve absolute
                {
                    float newX = domMouseEventsController.currentMousePoint.x;
                    float newY = domMouseEventsController.currentMousePoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 't':     // smooth quadratic Bezier curve relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                    float newY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 'A':     // elliptical arc absolute
                {
                    float newX = domMouseEventsController.currentMousePoint.x;
                    float newY = domMouseEventsController.currentMousePoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 'a':     // elliptical arc relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = domMouseEventsController.currentMousePoint.x - currentPathPoint.x;
                    float newY = domMouseEventsController.currentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    [pathSegmentDictionary setObject:newXString forKey:@"x"];
                    [pathSegmentDictionary setObject:newYString forKey:@"y"];

                    break;
                }
                case 'Z':     // closepath absolute
                {
                    break;
                }
                case 'z':     // closepath
                {
                    break;
                }
            }
        }
    }

    [self updatePathSegmentsAbsoluteValues:self.pathSegmentsArray];

    [self updateActivePathInDOM];
}

//==================================================================================
//	updatePathMode:
//==================================================================================

-(void) updatePathMode:(NSString *)newPathMode
{
    // mouse is in hover mode, replace the existing segment with a new segment for the new path mode
    NSUInteger pathSegmentsCount = [self.pathSegmentsArray count];
    
    if (pathSegmentsCount > 1)
    {
        if (self.pathSegmentIndex > 1)
        {
            [self.pathSegmentsArray removeLastObject];
            self.pathSegmentIndex--;
            [self updateActivePathInDOM];
        }
    }
    
    [self extendPath];
}

//==================================================================================
//	deleteLastSegmentInPath
//==================================================================================

-(void) deleteLastSegmentInPath
{
    NSUInteger pathSegmentsCount = [self.pathSegmentsArray count];
    
    if (pathSegmentsCount > 1)
    {
        if (self.pathSegmentIndex > 1)
        {
            [self.pathSegmentsArray removeLastObject];
            self.pathSegmentIndex--;
            [self updateActivePathInDOM];
        }
    }
}

//==================================================================================
//	didBeginPathEditing
//==================================================================================

- (NSInteger)didBeginPathEditingWithTargetXMLElement:(NSXMLElement *)targetXmlElement
        handleDOMElement:(DOMElement *)handleDOMElement
{
    NSInteger result = kPathEditingModeNotActive;
    
    self.pathEditingKey = @"";
    editingMode = kPathEditingModeNotActive;
    
    if (self.selectedPathElement != NULL)
    {
        if ([self.pathSegmentsArray count] > 0)
        {
            //result = [self findClickedPathSegmentHandle];

            result = [self setActiveDOMHandle:handleDOMElement];
        }
        else
        {
            NSLog(@"didBeginPathEditing - selectedPathElement not consistent with pathSegmentsArray");
        }
    }
    
    return result;
}

//==================================================================================
//	setActiveDOMHandle:
//==================================================================================

- (NSInteger)setActiveDOMHandle:(DOMElement *)handleDOMElement
{
    NSInteger newEditingMode = kPathEditingModeNotActive;

    self.pathEditingKey = @"";
    self.pathSegmentIndex = -1;
    
    self.activeHandleDOMElement = handleDOMElement;
    
    if (self.activeHandleDOMElement != NULL)
    {
        if ([self.activeHandleDOMElement hasAttribute:@"class"] == YES)
        {
            NSString * domElementClass = [self.activeHandleDOMElement getAttribute:@"class"];
            if ([domElementClass isEqualToString:@"_macsvg_path_handle"] == YES)
            {
                if ([self.activeHandleDOMElement hasAttribute:@"_macsvg_path_handle_segment"] == YES)
                {
                    NSString * newPathEditingKey = [self.activeHandleDOMElement getAttribute:@"_macsvg_path_handle_point"];
                    
                    NSString * handleSegmentString = [self.activeHandleDOMElement getAttribute:@"_macsvg_path_handle_segment"];
                    NSInteger newPathSegmentIndex = [handleSegmentString integerValue];
                    
                    editingMode = kPathEditingModeCurrentSegment;
                    newEditingMode = kPathEditingModeCurrentSegment;
                    
                    self.pathEditingKey = newPathEditingKey;
                    self.pathSegmentIndex = newPathSegmentIndex;
                }
            }
        }
    }

    return newEditingMode;
}


@end
