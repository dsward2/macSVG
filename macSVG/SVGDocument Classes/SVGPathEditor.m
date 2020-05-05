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
#import "MacSVGAppDelegate.h"
#import "SelectedElementsManager.h"
#import "ToolSettingsPopoverViewController.h"
#import "EditorUIFrameController.h"
#import "ElementEditorPlugInController.h"
#import <MacSVGPlugin/MacSVGPlugin.h>
#import "MacSVGDocument.h"
#import "DOMSelectionControlsManager.h"
#import "PathSegment.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


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

- (instancetype)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
        self.selectedPathElement = NULL;
        
        self.pathSegmentIndex = -1;
        self.pathEditingKey = @"";
        
        self.editingMode = kPathEditingModeNotActive;

        self.useRelativePathCoordinates = NO;
        self.closePathAutomatically = NO;
        self.curveSegmentContinuity = YES;
        
        self.largeArcFlagString = [[NSMutableString alloc] initWithString:@"0"];
        self.sweepFlagString = [[NSMutableString alloc] initWithString:@"0"];
        self.xAxisRotationString = [[NSMutableString alloc] initWithString:@"0"];
        self.pathRadiusXString = [[NSMutableString alloc] initWithString:@"20"];
        self.pathRadiusYString = [[NSMutableString alloc] initWithString:@"20"];
        
        self.pathSegmentsArray = [[NSMutableArray alloc] init];

        self.parametersMoveto = @[@"x", @"y"];
        self.parametersLineto = @[@"x", @"y"];
        self.parametersHorizontalLineto = @[@"x"];
        self.parametersVerticalLineto = @[@"y"];
        self.parametersCubicCurveto = @[@"x1", @"y1", @"x2", @"y2", @"x", @"y"];
        self.parametersCubicCurvetoSmooth = @[@"x2", @"y2", @"x", @"y"];
        self.parametersQuadraticCurveto = @[@"x1", @"y1", @"x", @"y"];
        self.parametersQuadraticCurvetoSmooth = @[@"x", @"y"];
        self.parametersEllipticalArc = @[@"rx", @"ry", @"x-axis-rotation", @"large-arc-flag", @"sweep-flag", @"x", @"y"];
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
//	allocPxString:
//==================================================================================

- (NSMutableString *)allocPxString:(float)aFloat
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
        if (segmentIndex < (self.pathSegmentsArray).count)
        {
            PathSegment * currentPathSegment = (self.pathSegmentsArray)[segmentIndex];
            
            float absoluteX = currentPathSegment.absoluteXFloat;
            float absoluteY = currentPathSegment.absoluteYFloat;
            
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
    // two-pass path data parser, building an array of PathSegment objects
    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSString * pathString = [aPathString stringByTrimmingCharactersInSet:whitespaceSet];

    NSMutableArray * newPathSegmentsArray = [[NSMutableArray alloc] init];
    
    NSUInteger pathStringLength = pathString.length;
    
    // First pass
    int previousMode = kSeparatorMode;
    int newMode = kSeparatorMode;
    unichar newCommand = '?';
    
    NSArray * currentParameterNames = NULL;     // the list of parameter names for the current command
    
    PathSegment * currentPathSegment = [[PathSegment alloc] init];
    
    NSMutableString * valueString = [[NSMutableString alloc] init];
    
    for (NSInteger i = 0; i <= pathStringLength; i++) // intentionally one character past end of string length
    {
        unichar aChar = ' ';    // a space character for padding at end of pathString
        unichar originalCommand = ' ';
        
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
                originalCommand = aChar;
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
                if (valueString.length > 0)
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
            NSInteger parametersCount = 0;
            for (NSString * aParameterName in currentParameterNames)
            {
                if ([aParameterName isEqualToString:@"x"] == YES)
                {
                    if ([currentPathSegment.xString isEqualToString:@"NAN"] == YES)
                    {
                        break;
                    }
                }
                else if ([aParameterName isEqualToString:@"y"] == YES)
                {
                    if ([currentPathSegment.yString isEqualToString:@"NAN"] == YES)
                    {
                        break;
                    }
                }
                else if ([aParameterName isEqualToString:@"x1"] == YES)
                {
                    if ([currentPathSegment.x1String isEqualToString:@"NAN"] == YES)
                    {
                        break;
                    }
                }
                else if ([aParameterName isEqualToString:@"y1"] == YES)
                {
                    if ([currentPathSegment.y1String isEqualToString:@"NAN"] == YES)
                    {
                        break;
                    }
                }
                else if ([aParameterName isEqualToString:@"x2"] == YES)
                {
                    if ([currentPathSegment.x2String isEqualToString:@"NAN"] == YES)
                    {
                        break;
                    }
                }
                else if ([aParameterName isEqualToString:@"y2"] == YES)
                {
                    if ([currentPathSegment.y2String isEqualToString:@"NAN"] == YES)
                    {
                        break;
                    }
                }
                else if ([aParameterName isEqualToString:@"x-axis-rotation"] == YES)
                {
                    if ([currentPathSegment.xAxisRotationString isEqualToString:@"NAN"] == YES)
                    {
                        break;
                    }
                }
                else if ([aParameterName isEqualToString:@"large-arc-flag"] == YES)
                {
                    if ([currentPathSegment.largeArcFlagString isEqualToString:@"NAN"] == YES)
                    {
                        break;
                    }
                }
                else if ([aParameterName isEqualToString:@"sweep-flag"] == YES)
                {
                    if ([currentPathSegment.sweepFlagString isEqualToString:@"NAN"] == YES)
                    {
                        break;
                    }
                }
                else if ([aParameterName isEqualToString:@"rx"] == YES)
                {
                    if ([currentPathSegment.rxString isEqualToString:@"NAN"] == YES)
                    {
                        break;
                    }
                }
                else if ([aParameterName isEqualToString:@"ry"] == YES)
                {
                    if ([currentPathSegment.ryString isEqualToString:@"NAN"] == YES)
                    {
                        break;
                    }
                }
                parametersCount++;
            }

            NSString * newParameter = [[NSString alloc] initWithString:valueString];

            NSString * keyForParameter = currentParameterNames[parametersCount];
            
            if ([keyForParameter isEqualToString:@"x"] == YES)
            {
                currentPathSegment.xString = newParameter;
            }
            else if ([keyForParameter isEqualToString:@"y"] == YES)
            {
                currentPathSegment.yString = newParameter;
            }
            else if ([keyForParameter isEqualToString:@"x1"] == YES)
            {
                currentPathSegment.x1String = newParameter;
            }
            else if ([keyForParameter isEqualToString:@"y1"] == YES)
            {
                currentPathSegment.y1String = newParameter;
            }
            else if ([keyForParameter isEqualToString:@"x2"] == YES)
            {
                currentPathSegment.x2String = newParameter;
            }
            else if ([keyForParameter isEqualToString:@"y2"] == YES)
            {
                currentPathSegment.y2String = newParameter;
            }
            else if ([keyForParameter isEqualToString:@"x-axis-rotation"] == YES)
            {
                currentPathSegment.xAxisRotationString = newParameter;
            }
            else if ([keyForParameter isEqualToString:@"large-arc-flag"] == YES)
            {
                currentPathSegment.largeArcFlagString = newParameter;
            }
            else if ([keyForParameter isEqualToString:@"sweep-flag"] == YES)
            {
                currentPathSegment.sweepFlagString = newParameter;
            }
            else if ([keyForParameter isEqualToString:@"rx"] == YES)
            {
                currentPathSegment.rxString = newParameter;
            }
            else if ([keyForParameter isEqualToString:@"ry"] == YES)
            {
                currentPathSegment.ryString = newParameter;
            }
            
            parametersCount++;
            
            NSUInteger parameterNamesCount = currentParameterNames.count;
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
            if (currentPathSegment.count > 0)
            {
                PathSegment * newPathSegment = [[PathSegment alloc] init];
                [newPathSegment copyValuesFromPathSegment:currentPathSegment];

                [newPathSegmentsArray addObject:newPathSegment];
                
                unichar currentPathCommand = newPathSegment.pathCommand;
                [currentPathSegment resetValues];
                currentPathSegment.pathCommand = currentPathCommand;
                currentPathSegment.originalPathCommand = currentPathCommand;
            }
            else
            {
                // currentSegment was empty
            }
        }
            
        if (endOfParameterFound == YES)
        {
            [valueString setString:@""];
        }
        
        if (newMode == kCommandMode)
        {
            switch (newCommand)
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
                default:
                    //NSLog(@"Invalid SVG path command '%C' at position %ld in \"%@\"", newCommand, i, pathString);
                    break;
            }
            
            [currentPathSegment resetValues];
            
            currentPathSegment.pathCommand = newCommand;
            
            currentPathSegment.originalPathCommand = originalCommand;
            
            [valueString setString:@""];
        }
        
        if (newMode == kValueMode)
        {
            // character is for a value
            [valueString appendFormat:@"%C", aChar];
        }
        
        previousMode = newMode;
    }
    
    // Second pass
    // Although not in the official SVG standard, some clipart and browsers interpret
    // consecutive Moveto commands as Lineto commands.  Change those segments to Lineto commands.
    unichar previousPathCommand = '?';
    for (PathSegment * aPathSegment in newPathSegmentsArray)
    {
        NSInteger currentSegmentIndex = [newPathSegmentsArray indexOfObject:aPathSegment];
        
        unichar currentPathCommand = aPathSegment.pathCommand;
        unichar originalPathCommand = aPathSegment.originalPathCommand;
        
        switch (currentPathCommand)
        {
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
                break;
            default:
                currentPathCommand = previousPathCommand;
        }

        if (currentSegmentIndex == 0)
        {
            if (originalPathCommand == 'm')
            {
                currentPathCommand = 'M';
            }
        }
        else
        {
            if (currentPathCommand == 'M')
            {
                if ((previousPathCommand == 'M') || (previousPathCommand == 'm'))
                {
                    currentPathCommand = 'L';
                }
            }
            else if (currentPathCommand == 'm')
            {
                if ((previousPathCommand == 'M') || (previousPathCommand == 'm'))
                {
                    currentPathCommand = 'l';
                }
            }
        }

        aPathSegment.pathCommand = currentPathCommand;
        
        previousPathCommand = originalPathCommand;
    }

    // cleanup segments
    for (PathSegment * aPathSegment in newPathSegmentsArray)
    {
        aPathSegment.originalPathCommand = '?';
        
        unichar currentCommand = aPathSegment.pathCommand;
        if (currentCommand != '?')
        {
            NSArray * currentParameterNames = NULL;
            switch (currentCommand)
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
                    
                default:
                    currentParameterNames = NULL;
                    break;
            }

            if (currentParameterNames != NULL)
            {
                for (NSString * aParameterName in currentParameterNames)
                {
                    if ([aParameterName isEqualToString:@"x"] == YES)
                    {
                        if ([aPathSegment.xString isEqualToString:@"NAN"] == YES)
                        {
                            aPathSegment.xString = @"0";
                        }
                    }
                    else if ([aParameterName isEqualToString:@"y"] == YES)
                    {
                        if ([aPathSegment.yString isEqualToString:@"NAN"] == YES)
                        {
                            aPathSegment.yString = @"0";
                        }
                    }
                    else if ([aParameterName isEqualToString:@"x1"] == YES)
                    {
                        if ([aPathSegment.x1String isEqualToString:@"NAN"] == YES)
                        {
                            aPathSegment.x1String = @"0";
                        }
                    }
                    else if ([aParameterName isEqualToString:@"y1"] == YES)
                    {
                        if ([aPathSegment.y1String isEqualToString:@"NAN"] == YES)
                        {
                            aPathSegment.y1String = @"0";
                        }
                    }
                    else if ([aParameterName isEqualToString:@"x2"] == YES)
                    {
                        if ([aPathSegment.x2String isEqualToString:@"NAN"] == YES)
                        {
                            aPathSegment.x2String = @"0";
                        }
                    }
                    else if ([aParameterName isEqualToString:@"y2"] == YES)
                    {
                        if ([aPathSegment.y2String isEqualToString:@"NAN"] == YES)
                        {
                            aPathSegment.y2String = @"0";
                        }
                    }
                    else if ([aParameterName isEqualToString:@"x-axis-rotation"] == YES)
                    {
                        if ([aPathSegment.xAxisRotationString isEqualToString:@"NAN"] == YES)
                        {
                            aPathSegment.xAxisRotationString = @"0";
                        }
                    }
                    else if ([aParameterName isEqualToString:@"large-arc-flag"] == YES)
                    {
                        if ([aPathSegment.largeArcFlagString isEqualToString:@"NAN"] == YES)
                        {
                            aPathSegment.largeArcFlagString = @"0";
                        }
                    }
                    else if ([aParameterName isEqualToString:@"sweep-flag"] == YES)
                    {
                        if ([aPathSegment.sweepFlagString isEqualToString:@"NAN"] == YES)
                        {
                            aPathSegment.sweepFlagString = @"0";
                        }
                    }
                    else if ([aParameterName isEqualToString:@"rx"] == YES)
                    {
                        if ([aPathSegment.rxString isEqualToString:@"NAN"] == YES)
                        {
                            aPathSegment.rxString = @"0";
                        }
                    }
                    else if ([aParameterName isEqualToString:@"ry"] == YES)
                    {
                        if ([aPathSegment.ryString isEqualToString:@"NAN"] == YES)
                        {
                            aPathSegment.ryString = @"0";
                        }
                    }
                }
            }
        }
    }

    [self updatePathSegmentsAbsoluteValues:newPathSegmentsArray];
    
    if (newPathSegmentsArray.count == 0)
    {
        if (pathStringLength > 0)
        {
            NSLog(@"buildPathSegmentsArrayWithPathString - empty newPathSegmentsArray result");
        }
    }
    
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
    
    float x = 0;
    float y = 0;
    float segmentAbsoluteX = 0;
    float segmentAbsoluteY = 0;
    float segmentAbsoluteX1 = 0;
    float segmentAbsoluteY1 = 0;
    float segmentAbsoluteX2 = 0;
    float segmentAbsoluteY2 = 0;
    float segmentAbsoluteStartX = 0;
    float segmentAbsoluteStartY = 0;
    float subpathAbsoluteStartX = NAN;
    float subpathAbsoluteStartY = NAN;
    
    unichar previousCommandChar = 'Z';
    
    NSInteger pathSegmentsArrayCount = aPathSegmentsArray.count;

    
    for (NSInteger currentSegmentIndex = 0; currentSegmentIndex < pathSegmentsArrayCount;
            currentSegmentIndex++)
    {

        PathSegment * currentPathSegment = aPathSegmentsArray[currentSegmentIndex];
        
        unichar commandChar = currentPathSegment.pathCommand;
        
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
                NSString * xString = currentPathSegment.xString;
                NSString * yString = currentPathSegment.yString;
        
                segmentAbsoluteStartX = xString.floatValue;
                segmentAbsoluteStartY = yString.floatValue;
            }
        }

        //NSNumber * absoluteStartXNumber = [NSNumber numberWithFloat:segmentAbsoluteStartX];
        //NSNumber * absoluteStartYNumber = [NSNumber numberWithFloat:segmentAbsoluteStartY];
        
        currentPathSegment.absoluteStartXFloat = segmentAbsoluteStartX;
        currentPathSegment.absoluteStartYFloat = segmentAbsoluteStartY;
        

        switch (commandChar)
        {
            case 'M':     // moveto absolute
            case 'm':     // moveto relative
            {
                NSString * xString = currentPathSegment.xString;
                NSString * yString = currentPathSegment.yString;
                
                x = xString.floatValue;
                y = yString.floatValue;

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
                
                //NSNumber * absoluteXNumber = [NSNumber numberWithFloat:segmentAbsoluteX];
                //NSNumber * absoluteYNumber = [NSNumber numberWithFloat:segmentAbsoluteY];
                
                currentPathSegment.absoluteXFloat = segmentAbsoluteX;
                currentPathSegment.absoluteYFloat = segmentAbsoluteY;
                
                currentPathSegment.absoluteStartXFloat = segmentAbsoluteX;
                currentPathSegment.absoluteStartYFloat = segmentAbsoluteY;
                
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
                NSString * xString = currentPathSegment.xString;
                NSString * yString = currentPathSegment.yString;
                
                x = xString.floatValue;
                y = yString.floatValue;

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
                
                currentPathSegment.absoluteXFloat = segmentAbsoluteX;
                currentPathSegment.absoluteYFloat = segmentAbsoluteY;
                
                break;
            }

            case 'H':     // horizontal lineto absolute
            case 'h':     // horizontal lineto relative
            {
                NSString * xString = currentPathSegment.xString;
                
                x = xString.floatValue;
                
                if (isRelative == YES)
                {
                    segmentAbsoluteX = segmentAbsoluteStartX + x;
                }
                else
                {
                    segmentAbsoluteX = x;
                }
                
                currentPathSegment.absoluteXFloat = segmentAbsoluteX;
                currentPathSegment.absoluteYFloat = segmentAbsoluteY;
                
                break;
            }

            case 'V':     // vertical lineto absolute
            case 'v':     // vertical lineto relative
            {
                NSString * yString = currentPathSegment.yString;
                
                y = yString.floatValue;
                
                if (isRelative == YES)
                {
                    segmentAbsoluteY = segmentAbsoluteStartY + y;
                }
                else
                {
                    segmentAbsoluteY = y;
                }
                
                currentPathSegment.absoluteXFloat = segmentAbsoluteX;
                currentPathSegment.absoluteYFloat = segmentAbsoluteY;
                
                break;
            }

            case 'C':     // curveto absolute
            case 'c':     // curveto relative
            {
                NSString * xString = currentPathSegment.xString;
                NSString * yString = currentPathSegment.yString;
                NSString * x1String = currentPathSegment.x1String;
                NSString * y1String = currentPathSegment.y1String;
                NSString * x2String = currentPathSegment.x2String;
                NSString * y2String = currentPathSegment.y2String;
                
                x = xString.floatValue;
                y = yString.floatValue;
                float x1 = x1String.floatValue;
                float y1 = y1String.floatValue;
                float x2 = x2String.floatValue;
                float y2 = y2String.floatValue;
                
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
                
                currentPathSegment.absoluteXFloat = segmentAbsoluteX;
                currentPathSegment.absoluteYFloat = segmentAbsoluteY;
                currentPathSegment.absoluteX1Float = segmentAbsoluteX1;
                currentPathSegment.absoluteY1Float = segmentAbsoluteY1;
                currentPathSegment.absoluteX2Float = segmentAbsoluteX2;
                currentPathSegment.absoluteY2Float = segmentAbsoluteY2;
                
                break;
            }

            case 'S':     // smooth curveto absolute
            case 's':     // smooth curveto relative
            {
                NSString * xString = currentPathSegment.xString;
                NSString * yString = currentPathSegment.yString;
                NSString * x2String = currentPathSegment.x2String;
                NSString * y2String = currentPathSegment.y2String;

                x = xString.floatValue;
                y = yString.floatValue;
                float x2 = x2String.floatValue;
                float y2 = y2String.floatValue;
                
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
                
                currentPathSegment.absoluteXFloat = segmentAbsoluteX;
                currentPathSegment.absoluteYFloat = segmentAbsoluteY;
                currentPathSegment.absoluteX2Float = segmentAbsoluteX2;
                currentPathSegment.absoluteY2Float = segmentAbsoluteY2;

                break;
            }

            case 'Q':     // quadratic Bezier curve absolute
            case 'q':     // quadratic Bezier curve relative
            {
                NSString * xString = currentPathSegment.xString;
                NSString * yString = currentPathSegment.yString;
                NSString * x1String = currentPathSegment.x1String;
                NSString * y1String = currentPathSegment.y1String;
                
                x = xString.floatValue;
                y = yString.floatValue;
                float x1 = x1String.floatValue;
                float y1 = y1String.floatValue;
                
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
                
                currentPathSegment.absoluteXFloat = segmentAbsoluteX;
                currentPathSegment.absoluteYFloat = segmentAbsoluteY;
                currentPathSegment.absoluteX1Float = segmentAbsoluteX1;
                currentPathSegment.absoluteY1Float = segmentAbsoluteY1;

                break;
            }

            case 'T':     // smooth quadratic Bezier curve absolute
            case 't':     // smooth quadratic Bezier curve relative
            {
                NSString * xString = currentPathSegment.xString;
                NSString * yString = currentPathSegment.yString;
                
                x = xString.floatValue;
                y = yString.floatValue;
                
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
                
                currentPathSegment.absoluteXFloat = segmentAbsoluteX;
                currentPathSegment.absoluteYFloat = segmentAbsoluteY;
                
                break;
            }

            case 'A':     // elliptical arc absolute
            case 'a':     // elliptical arc relative
            {
                NSString * xString = currentPathSegment.xString;
                NSString * yString = currentPathSegment.yString;
                
                x = xString.floatValue;
                y = yString.floatValue;
                
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
                
                currentPathSegment.absoluteXFloat = segmentAbsoluteX;
                currentPathSegment.absoluteYFloat = segmentAbsoluteY;
                
                break;
            }

            case 'Z':     // closepath absolute
            case 'z':     // closepath relative
            {
                if (isnan(subpathAbsoluteStartX) == true)
                {
                    subpathAbsoluteStartX = segmentAbsoluteStartX;
                    subpathAbsoluteStartY = segmentAbsoluteStartY;
                }

                segmentAbsoluteStartX = subpathAbsoluteStartX;
                segmentAbsoluteStartY = subpathAbsoluteStartY;
                
                currentPathSegment.absoluteXFloat = segmentAbsoluteStartX;
                currentPathSegment.absoluteYFloat = segmentAbsoluteStartY;
                break;
            }
        }
        
        previousCommandChar = commandChar;
        
        if (isnan(subpathAbsoluteStartX) == true)
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
    NSString * pathString = pathAttribute.stringValue;
    
    NSMutableArray * activePathSegmentsArray = [self buildPathSegmentsArrayWithPathString:pathString];
    
    [self resetPathSegmentsArray];

    [self.pathSegmentsArray setArray:activePathSegmentsArray];
    
    self.selectedPathElement = pathElement;
}

//==================================================================================
//	endPointForSegmentIndex:pathSegmentsArray:
//==================================================================================

- (NSPoint)endPointForSegmentIndex:(NSInteger)segmentIndex
        pathSegmentsArray:(NSArray *)aPathSegmentsArray
{
    NSPoint resultPoint = NSZeroPoint;
    
    PathSegment * pathSegment = aPathSegmentsArray[segmentIndex];

    float absoluteStartXFloat = pathSegment.absoluteStartXFloat;
    float absoluteStartYFloat = pathSegment.absoluteStartYFloat;
    
    unichar commandCharacter = pathSegment.pathCommand;

    switch (commandCharacter)
    {
        case 'M':     // moveto
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;

            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;
            
            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'm':     // moveto
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;
            xFloat += absoluteStartXFloat;

            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;
            yFloat += absoluteStartYFloat;
            
            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }
        
        case 'L':     // lineto
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;

            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }
        
        case 'l':     // lineto
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;
            xFloat += absoluteStartXFloat;

            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;
            yFloat += absoluteStartYFloat;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'H':     // horizontal lineto
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;

            resultPoint = NSMakePoint(xFloat, absoluteStartYFloat);
            break;
        }
        
        case 'h':     // horizontal lineto
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;
            xFloat += absoluteStartXFloat;

            resultPoint = NSMakePoint(xFloat, absoluteStartYFloat);
            break;
        }

        case 'V':     // vertical lineto
        {
            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;

            resultPoint = NSMakePoint(absoluteStartXFloat, yFloat);
            break;
        }

        case 'v':     // vertical lineto
        {
            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;
            yFloat += absoluteStartYFloat;

            resultPoint = NSMakePoint(absoluteStartXFloat, yFloat);
            break;
        }

        case 'C':     // curveto
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;

            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'c':     // curveto
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;
            xFloat += absoluteStartXFloat;

            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;
            yFloat += absoluteStartYFloat;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'S':     // smooth curveto
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;

            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 's':     // smooth curveto
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;
            xFloat += absoluteStartXFloat;

            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;
            yFloat += absoluteStartYFloat;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'Q':     // quadratic Bezier curve
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;

            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'q':     // quadratic Bezier curve
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;
            xFloat += absoluteStartXFloat;

            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;
            yFloat += absoluteStartYFloat;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'T':     // smooth quadratic Bezier curve
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;

            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 't':     // smooth quadratic Bezier curve
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;
            xFloat += absoluteStartXFloat;

            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;
            yFloat += absoluteStartYFloat;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'A':     // elliptical arc
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;

            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'a':     // elliptical arc
        {
            NSString * xString = pathSegment.xString;
            float xFloat = xString.floatValue;
            xFloat += absoluteStartXFloat;

            NSString * yString = pathSegment.yString;
            float yFloat = yString.floatValue;
            yFloat += absoluteStartYFloat;

            resultPoint = NSMakePoint(xFloat, yFloat);
            break;
        }

        case 'Z':     // closepath
        case 'z':     // closepath
        {
            PathSegment * firstPathSegment = aPathSegmentsArray[segmentIndex];

            float firstAbsoluteStartXFloat = firstPathSegment.absoluteStartXFloat;
            float firstAbsoluteStartYFloat = firstPathSegment.absoluteStartYFloat;
            
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
    DOMDocument * domDocument = (svgWebKitController.svgWebView).mainFrame.DOMDocument;

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
    DOMDocument * domDocument = (svgWebKitController.svgWebView).mainFrame.DOMDocument;

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
//	addHandleForMoveto:segmentIndex:pathHandlesGroup:pathXMLElement:
//==================================================================================

-(void) addHandleForMoveto:(PathSegment *)pathSegment
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
        pathXMLElement:(NSXMLElement *)pathXMLElement
{
    // path commands M,m
    NSString * xString = pathSegment.absoluteXString;
    NSString * yString = pathSegment.absoluteYString;
    
    NSString * xPxString = [xString stringByAppendingString:@"px"];
    NSString * yPxString = [yString stringByAppendingString:@"px"];

    NSUInteger pathSegmentsCount = (self.pathSegmentsArray).count;

    NSString * selectedPathMode = macSVGDocumentWindowController.selectedPathMode;

    float scaleForDOMElementHandles = [svgWebKitController maxScaleForDOMElementHandles:pathHandlesGroup];
    
    NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
    float pathEndpointStrokeWidthFloat = pathEndpointStrokeWidthString.floatValue;
    pathEndpointStrokeWidthFloat *= scaleForDOMElementHandles;
    pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

    NSString * pathLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
    float pathLineStrokeWidthFloat = pathLineStrokeWidthString.floatValue;
    pathLineStrokeWidthFloat *= scaleForDOMElementHandles;
    pathLineStrokeWidthString = [self allocPxString:pathLineStrokeWidthFloat];

    NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
    float pathEndpointRadiusFloat = pathEndpointRadiusString.floatValue;
    pathEndpointRadiusFloat *= scaleForDOMElementHandles;
    pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

    NSString * pathCurvePointStrokeWidthString = toolSettingsPopoverViewController.pathCurvePointStrokeWidth;
    float pathCurvePointStrokeWidthFloat = pathCurvePointStrokeWidthString.floatValue;
    pathCurvePointStrokeWidthFloat *= scaleForDOMElementHandles;
    pathCurvePointStrokeWidthString = [self allocPxString:pathCurvePointStrokeWidthFloat];

    NSString * pathCurvePointRadiusString = toolSettingsPopoverViewController.pathCurvePointRadius;
    float pathCurvePointRadiusFloat = pathCurvePointRadiusString.floatValue;
    pathCurvePointRadiusFloat *= scaleForDOMElementHandles;
    pathCurvePointRadiusString = [self allocPxString:pathCurvePointRadiusFloat];

    NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
    NSString * selectedElementMacsvgid = selectedElementMacsvgidNode.stringValue;
    
    NSString * segmentIndexString = [NSString stringWithFormat:@"%ld", segmentIndex];

    if ([selectedPathMode isEqualToString:@"Cubic Curve"] == YES)
    {
        // check for now drawing the first segment of a cubic curve, possibly a subpath
        
        BOOL isMovetoForCubic = NO;
        
        if ((pathSegmentsCount == 1) && (segmentIndex == 0))
        {
            isMovetoForCubic = YES;
        }
        else
        {
            if (domMouseEventsController.mouseMode == MOUSE_DRAGGING)
            {
                if (pathSegmentsCount > 0)
                {
                    if (segmentIndex == pathSegmentsCount - 1)
                    {
                        // starting a new cubic subpath, use the moveto point to draw handles for next segment x1,y1
                        PathSegment * previousPathSegment = [self.pathSegmentsArray objectAtIndex:segmentIndex];
                        unichar previousSegmentCommand = previousPathSegment.pathCommand;
                        if ((previousSegmentCommand == 'M') || (previousSegmentCommand == 'm'))
                        {
                            isMovetoForCubic = YES;
                        }
                    }
                }
            }
        }
        
        if (isMovetoForCubic == YES)
        {
            // reflect a control point for the first cubic curveto path segment
            
            NSPoint transformedClickPoint = domMouseEventsController.transformedClickMousePagePoint;
            NSPoint transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;
            
            NSString * transformedClickPointXString = [self allocPxString:transformedClickPoint.x];
            NSString * transformedClickPointYString = [self allocPxString:transformedClickPoint.y];

            NSString * x1PxString = [self allocPxString:transformedCurrentMousePoint.x];
            NSString * y1PxString = [self allocPxString:transformedCurrentMousePoint.y];
            
            float deltaX = transformedClickPoint.x - transformedCurrentMousePoint.x;
            float deltaY = transformedClickPoint.y - transformedCurrentMousePoint.y;

            float reflectX2 = transformedClickPoint.x + deltaX;
            float reflectY2 = transformedClickPoint.y + deltaY;

            NSString * reflectX2PxString = [self allocPxString:reflectX2];
            NSString * reflectY2PxString = [self allocPxString:reflectY2];
            
            // Line 1
            
            DOMElement * handleLine1Element = [self makeHandleLineDOMElementWithX1:transformedClickPointXString y1:transformedClickPointYString x2:x1PxString y2:y1PxString strokeWidth:pathLineStrokeWidthString];

            [pathHandlesGroup appendChild:handleLine1Element];
            
            // Line 2, reflected from line 1

            DOMElement * handleLine2Element = [self makeHandleLineDOMElementWithX1:transformedClickPointXString y1:transformedClickPointYString x2:reflectX2PxString y2:reflectY2PxString strokeWidth:pathLineStrokeWidthString];
            
            [pathHandlesGroup appendChild:handleLine2Element];

            // Circle handle x1,y1
            
            DOMElement * handleX1Y1CircleElement =
                    [self makeHandleCircleDOMElementWithCx:transformedClickPointXString cy:transformedClickPointYString
                    strokeWidth:pathCurvePointStrokeWidthString radius:pathCurvePointRadiusString
                    masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                    handlePoint:@"x1y1"];

            [pathHandlesGroup appendChild:handleX1Y1CircleElement];
            
            // Circle handle x2,y2, reflected from x1, y1

            DOMElement * handleX2Y2CircleElement =
                    [self makeHandleCircleDOMElementWithCx:reflectX2PxString cy:reflectY2PxString
                    strokeWidth:pathCurvePointStrokeWidthString radius:pathCurvePointRadiusString
                    masterID:selectedElementMacsvgid segmentIndex:segmentIndexString
                    handlePoint:@"x2y2"];

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

-(void) addHandleForLineto:(PathSegment *)pathSegment
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
        pathXMLElement:(NSXMLElement *)pathXMLElement
{
    // path commands L,l

    NSString * xString = pathSegment.absoluteXString;
    NSString * yString = pathSegment.absoluteYString;

    NSString * xPxString = [xString stringByAppendingString:@"px"];
    NSString * yPxString = [yString stringByAppendingString:@"px"];

    NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
    NSString * selectedElementMacsvgid = selectedElementMacsvgidNode.stringValue;
    
    NSString * segmentIndexString = [NSString stringWithFormat:@"%ld", segmentIndex];

    float scaleForDOMElementHandles = [svgWebKitController maxScaleForDOMElementHandles:pathHandlesGroup];
    
    NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
    float pathEndpointStrokeWidthFloat = pathEndpointStrokeWidthString.floatValue;
    pathEndpointStrokeWidthFloat *= scaleForDOMElementHandles;
    pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

    NSString * pathLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
    float pathLineStrokeWidthFloat = pathLineStrokeWidthString.floatValue;
    pathLineStrokeWidthFloat *= scaleForDOMElementHandles;
    pathLineStrokeWidthString = [self allocPxString:pathLineStrokeWidthFloat];

    NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
    float pathEndpointRadiusFloat = pathEndpointRadiusString.floatValue;
    pathEndpointRadiusFloat *= scaleForDOMElementHandles;
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

-(void) addHandleForHorizontalLineto:(PathSegment *)pathSegment
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
        pathXMLElement:(NSXMLElement *)pathXMLElement
{
    // path commands H,h
    NSPoint currentPoint = NSZeroPoint;
    if (segmentIndex > 0)
    {
        currentPoint = [self absoluteXYPointAtPathSegmentIndex:(segmentIndex - 1)];
    }

    NSString * xString = pathSegment.absoluteXString;
    NSString * xPxString = [xString stringByAppendingString:@"px"];

    NSString * yPxString = [self allocPxString:currentPoint.y];

    float scaleForDOMElementHandles = [svgWebKitController maxScaleForDOMElementHandles:pathHandlesGroup];

    NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
    float pathEndpointStrokeWidthFloat = pathEndpointStrokeWidthString.floatValue;
    pathEndpointStrokeWidthFloat *= scaleForDOMElementHandles;
    pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

    NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
    float pathEndpointRadiusFloat = pathEndpointRadiusString.floatValue;
    pathEndpointRadiusFloat *= scaleForDOMElementHandles;
    pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

    NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
    NSString * selectedElementMacsvgid = selectedElementMacsvgidNode.stringValue;
    
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

-(void) addHandleForVerticalLineto:(PathSegment *)pathSegment
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
        pathXMLElement:(NSXMLElement *)pathXMLElement
{
    // path commands V,v
    NSPoint currentPoint = NSZeroPoint;
    if (segmentIndex > 0)
    {
        currentPoint = [self absoluteXYPointAtPathSegmentIndex:(segmentIndex - 1)];
    }

    NSString * xPxString = [self allocPxString:currentPoint.x];
    
    NSString * yString = pathSegment.absoluteYString;
    NSString * yPxString = [yString stringByAppendingString:@"px"];

    float scaleForDOMElementHandles = [svgWebKitController maxScaleForDOMElementHandles:pathHandlesGroup];
    
    NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
    float pathEndpointStrokeWidthFloat = pathEndpointStrokeWidthString.floatValue;
    pathEndpointStrokeWidthFloat *= scaleForDOMElementHandles;
    pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

    NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
    float pathEndpointRadiusFloat = pathEndpointRadiusString.floatValue;
    pathEndpointRadiusFloat *= scaleForDOMElementHandles;
    pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

    NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
    NSString * selectedElementMacsvgid = selectedElementMacsvgidNode.stringValue;
    
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

-(void) addHandleForCubicCurveto:(PathSegment *)pathSegment
        segmentIndex:(NSUInteger)segmentIndex 
        reflectX1Y1:(BOOL)reflectX1Y1
        reflectX2Y2:(BOOL)reflectX2Y2
        pathHandlesGroup:(DOMElement *)pathHandlesGroup
        pathXMLElement:(NSXMLElement *)pathXMLElement
{
    // path commands C,c
    
    if (pathSegment != NULL)
    {
        float scaleForDOMElementHandles = [svgWebKitController maxScaleForDOMElementHandles:pathHandlesGroup];

        NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
        float pathEndpointStrokeWidthFloat = pathEndpointStrokeWidthString.floatValue;
        pathEndpointStrokeWidthFloat *= scaleForDOMElementHandles;
        pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

        NSString * pathLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
        float pathLineStrokeWidthFloat = pathLineStrokeWidthString.floatValue;
        pathLineStrokeWidthFloat *= scaleForDOMElementHandles;
        pathLineStrokeWidthString = [self allocPxString:pathLineStrokeWidthFloat];

        NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
        float pathEndpointRadiusFloat = pathEndpointRadiusString.floatValue;
        pathEndpointRadiusFloat *= scaleForDOMElementHandles;
        pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

        NSString * pathCurvePointStrokeWidthString = toolSettingsPopoverViewController.pathCurvePointStrokeWidth;
        float pathCurvePointStrokeWidthFloat = pathCurvePointStrokeWidthString.floatValue;
        pathCurvePointStrokeWidthFloat *= scaleForDOMElementHandles;
        pathCurvePointStrokeWidthString = [self allocPxString:pathCurvePointStrokeWidthFloat];

        NSString * pathCurvePointRadiusString = toolSettingsPopoverViewController.pathCurvePointRadius;
        float pathCurvePointRadiusFloat = pathCurvePointRadiusString.floatValue;
        pathCurvePointRadiusFloat *= scaleForDOMElementHandles;
        pathCurvePointRadiusString = [self allocPxString:pathCurvePointRadiusFloat];

        NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
        NSString * selectedElementMacsvgid = selectedElementMacsvgidNode.stringValue;
        
        NSString * segmentIndexString = [NSString stringWithFormat:@"%ld", segmentIndex];
        
        if ((self.pathSegmentsArray).count > 1)
        {
            float x = pathSegment.absoluteXFloat;     // endpoint
            float y = pathSegment.absoluteYFloat;
            float x1 = pathSegment.absoluteX1Float;   // first curve control point
            float y1 = pathSegment.absoluteY1Float;
            float x2 = pathSegment.absoluteX2Float;   // second curve control point
            float y2 = pathSegment.absoluteY2Float;
                                    
            NSPoint xyPoint = NSMakePoint(x, y);
            NSPoint x1y1Point = NSMakePoint(x1, y1);
            NSPoint x2y2Point = NSMakePoint(x2, y2);
            
            x = xyPoint.x;
            y = xyPoint.y;
            x1 = x1y1Point.x;
            y1 = x1y1Point.y;
            x2 = x2y2Point.x;
            y2 = x2y2Point.y;

            NSString * xPxString = [self allocPxString:x];
            NSString * yPxString = [self allocPxString:y];
            NSString * x1PxString = [self allocPxString:x1];
            NSString * y1PxString = [self allocPxString:y1];
            NSString * x2PxString = [self allocPxString:x2];
            NSString * y2PxString = [self allocPxString:y2];
                    
            NSPoint startPoint = NSMakePoint(x, y);
            if (segmentIndex > 0)
            {
                startPoint = [self absoluteXYPointAtPathSegmentIndex:(segmentIndex - 1)];
            }
            
            NSString * currentXPxString = [self allocPxString:startPoint.x];
            NSString * currentYPxString = [self allocPxString:startPoint.y];
            
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
                float deltaX = x1 - startPoint.x;
                float deltaY = y1 - startPoint.y;
                
                float reflectX1 = startPoint.x - deltaX;
                float reflectY1 = startPoint.y - deltaY;
                
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

-(void) addHandleForSmoothCubicCurveto:(PathSegment *)pathSegment
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
        pathXMLElement:(NSXMLElement *)pathXMLElement
{
    // path commands S,s

    if ((self.pathSegmentsArray).count > 1)
    {
        float x2 = pathSegment.absoluteX2Float;
        float y2 = pathSegment.absoluteY2Float;
        float x = pathSegment.absoluteXFloat;
        float y = pathSegment.absoluteYFloat;

        NSString * xPxString = [self allocPxString:x];
        NSString * yPxString = [self allocPxString:y];
        NSString * x2PxString = [self allocPxString:x2];
        NSString * y2PxString = [self allocPxString:y2];
                
        NSPoint currentPoint = NSMakePoint(x, y);
        if (segmentIndex > 0)
        {
            currentPoint = [self absoluteXYPointAtPathSegmentIndex:(segmentIndex - 1)];
        }

        float scaleForDOMElementHandles = [svgWebKitController maxScaleForDOMElementHandles:pathHandlesGroup];
        
        NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
        float pathEndpointStrokeWidthFloat = pathEndpointStrokeWidthString.floatValue;
        pathEndpointStrokeWidthFloat *= scaleForDOMElementHandles;
        pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

        NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
        float pathEndpointRadiusFloat = pathEndpointRadiusString.floatValue;
        pathEndpointRadiusFloat *= scaleForDOMElementHandles;
        pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

        NSString * pathLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
        float pathLineStrokeWidthFloat = pathLineStrokeWidthString.floatValue;
        pathLineStrokeWidthFloat *= scaleForDOMElementHandles;
        pathLineStrokeWidthString = [self allocPxString:pathLineStrokeWidthFloat];

        NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
        NSString * selectedElementMacsvgid = selectedElementMacsvgidNode.stringValue;
        
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

-(void) addHandleForQuadraticCurveto:(PathSegment *)pathSegment
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
        pathXMLElement:(NSXMLElement *)pathXMLElement
{
    // path commands Q,q

    if ((self.pathSegmentsArray).count > 1)
    {
        float x1 = pathSegment.absoluteX1Float;
        float y1 = pathSegment.absoluteY1Float;
        float x = pathSegment.absoluteXFloat;
        float y = pathSegment.absoluteYFloat;

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


        float scaleForDOMElementHandles = [svgWebKitController maxScaleForDOMElementHandles:pathHandlesGroup];
        
        NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
        float pathEndpointStrokeWidthFloat = pathEndpointStrokeWidthString.floatValue;
        pathEndpointStrokeWidthFloat *= scaleForDOMElementHandles;
        pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

        NSString * pathLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
        float pathLineStrokeWidthFloat = pathLineStrokeWidthString.floatValue;
        pathLineStrokeWidthFloat *= scaleForDOMElementHandles;
        pathLineStrokeWidthString = [self allocPxString:pathLineStrokeWidthFloat];

        NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
        float pathEndpointRadiusFloat = pathEndpointRadiusString.floatValue;
        pathEndpointRadiusFloat *= scaleForDOMElementHandles;
        pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

        NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
        NSString * selectedElementMacsvgid = selectedElementMacsvgidNode.stringValue;
        
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

-(void) addHandleForSmoothQuadraticCurveto:(PathSegment *)pathSegment
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
        pathXMLElement:(NSXMLElement *)pathXMLElement
{
    // path commands T,t

    if ((self.pathSegmentsArray).count > 1)
    {
        float x = pathSegment.absoluteXFloat;
        float y = pathSegment.absoluteYFloat;

        NSString * xPxString = [self allocPxString:x];
        NSString * yPxString = [self allocPxString:y];
        
        NSPoint currentPoint = NSMakePoint(x, y);
        if (segmentIndex > 0)
        {
            currentPoint = [self absoluteXYPointAtPathSegmentIndex:(segmentIndex - 1)];
        }

        float scaleForDOMElementHandles = [svgWebKitController maxScaleForDOMElementHandles:pathHandlesGroup];
        
        NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
        float pathEndpointStrokeWidthFloat = pathEndpointStrokeWidthString.floatValue;
        pathEndpointStrokeWidthFloat *= scaleForDOMElementHandles;
        pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

        NSString * pathLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
        float pathLineStrokeWidthFloat = pathLineStrokeWidthString.floatValue;
        pathLineStrokeWidthFloat *= scaleForDOMElementHandles;
        pathLineStrokeWidthString = [self allocPxString:pathLineStrokeWidthFloat];

        NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
        float pathEndpointRadiusFloat = pathEndpointRadiusString.floatValue;
        pathEndpointRadiusFloat *= scaleForDOMElementHandles;
        pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

        NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
        NSString * selectedElementMacsvgid = selectedElementMacsvgidNode.stringValue;
        
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

-(void) addHandleForEllipicalArc:(PathSegment *)pathSegment
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
        pathXMLElement:(NSXMLElement *)pathXMLElement
{
    // path commands A,a

    if ((self.pathSegmentsArray).count > 1)
    {
        float x = pathSegment.absoluteXFloat;
        float y = pathSegment.absoluteYFloat;

        NSString * xPxString = [self allocPxString:x];
        NSString * yPxString = [self allocPxString:y];
        
        NSPoint currentPoint = NSMakePoint(x, y);
        if (segmentIndex > 0)
        {
            currentPoint = [self absoluteXYPointAtPathSegmentIndex:(segmentIndex - 1)];
        }

        float scaleForDOMElementHandles = [svgWebKitController maxScaleForDOMElementHandles:pathHandlesGroup];
        
        NSString * pathEndpointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
        float pathEndpointStrokeWidthFloat = pathEndpointStrokeWidthString.floatValue;
        pathEndpointStrokeWidthFloat *= scaleForDOMElementHandles;
        pathEndpointStrokeWidthString = [self allocPxString:pathEndpointStrokeWidthFloat];

        NSString * pathLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
        float pathLineStrokeWidthFloat = pathLineStrokeWidthString.floatValue;
        pathLineStrokeWidthFloat *= scaleForDOMElementHandles;
        pathLineStrokeWidthString = [self allocPxString:pathLineStrokeWidthFloat];

        NSString * pathEndpointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
        float pathEndpointRadiusFloat = pathEndpointRadiusString.floatValue;
        pathEndpointRadiusFloat *= scaleForDOMElementHandles;
        pathEndpointRadiusString = [self allocPxString:pathEndpointRadiusFloat];

        NSXMLNode * selectedElementMacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
        NSString * selectedElementMacsvgid = selectedElementMacsvgidNode.stringValue;
        
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

-(void) addHandleForClosePath:(PathSegment *)pathSegment
        segmentIndex:(NSUInteger)segmentIndex pathHandlesGroup:(DOMElement *)pathHandlesGroup
        pathXMLElement:(NSXMLElement *)pathXMLElement
{
    // path commands Z,z
}

//==================================================================================
//	makePathHandlesForXMLElement:
//==================================================================================

-(void) makePathHandlesForXMLElement:(NSXMLElement *)pathXMLElement
{
    // called to create or update path handles
    // pathSegmentArray should already be populated with data from pathXMLElement
    
    DOMDocument * domDocument = (svgWebKitController.svgWebView).mainFrame.DOMDocument;

    DOMSelectionControlsManager * domSelectionControlsManager =
            svgXMLDOMSelectionManager.domSelectionControlsManager;
    
    DOMElement * newPathHandlesGroup = [domDocument createElementNS:svgNamespace 
            qualifiedName:@"g"];
    [newPathHandlesGroup setAttributeNS:NULL qualifiedName:@"id" value:@"_macsvg_pathHandlesGroup"];
    [newPathHandlesGroup setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_pathHandlesGroup"];
    
    NSXMLNode * transformAttributeNode = [pathXMLElement attributeForName:@"transform"];
    if (transformAttributeNode != NULL)
    {
        NSString * transformAttribureString = transformAttributeNode.stringValue;
        [newPathHandlesGroup setAttributeNS:NULL qualifiedName:@"transform" value:transformAttribureString];
    }





    // create parent group elements to match transforms for selected element, working back from current element to document root
    DOMElement * topGroupChild = newPathHandlesGroup;

    NSXMLElement * pathParentElement = (NSXMLElement *)pathXMLElement.parent;
    NSInteger groupIndex = 0;
    while (pathParentElement != NULL)
    {
        if (pathParentElement.kind == NSXMLElementKind)
        {
            NSXMLNode * transformAttributeNode = [pathParentElement attributeForName:@"transform"];
            if (transformAttributeNode != NULL)
            {
                NSString * transformValueString = transformAttributeNode.stringValue;
                if (transformValueString.length > 0)
                {
                    DOMElement * transformGroupElement = [domDocument createElementNS:svgNamespace qualifiedName:@"g"];
                    NSString * groupIDString = [NSString stringWithFormat:@"_macsvg_path_transform_group-%ld", groupIndex + 1];
                    [transformGroupElement setAttributeNS:NULL qualifiedName:@"id" value:groupIDString];
                    [transformGroupElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_path_transform_group"];
                    
                    [transformGroupElement setAttributeNS:NULL qualifiedName:@"transform" value:transformValueString];
                    
                    [transformGroupElement appendChild:topGroupChild];
                    topGroupChild = transformGroupElement;
                    
                    groupIndex++;
                }
            }
        }
        pathParentElement = (NSXMLElement *)pathParentElement.parent;
    }





    
    NSUInteger pathSegmentsCount = (self.pathSegmentsArray).count;
    
    unichar previousPathCommand = ' ';
            
    for (NSUInteger segmentIdx = 0; segmentIdx < pathSegmentsCount; segmentIdx++)
    {
        PathSegment * pathSegment = (self.pathSegmentsArray)[segmentIdx];

        unichar commandChar = pathSegment.pathCommand;

        switch (commandChar) 
        {
            case 'M':     // moveto
            case 'm':     // moveto
                [self addHandleForMoveto:pathSegment segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup pathXMLElement:pathXMLElement];
                break;

            case 'L':     // lineto
            case 'l':     // lineto
                [self addHandleForLineto:pathSegment segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup pathXMLElement:pathXMLElement];
                break;

            case 'H':     // horizontal lineto
            case 'h':     // horizontal lineto
                [self addHandleForHorizontalLineto:pathSegment segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup pathXMLElement:pathXMLElement];
                break;

            case 'V':     // vertical lineto
            case 'v':     // vertical lineto
                [self addHandleForVerticalLineto:pathSegment segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup pathXMLElement:pathXMLElement];
                break;

            case 'C':     // cubic Bezier curveto
            case 'c':     // cubic Bezier curveto
            {
                BOOL reflectX1Y1 = NO;
                BOOL reflectX2Y2 = NO;
                
                //if (segmentIdx == 1) reflectX1Y1 = YES;
                
                if (segmentIdx >= (pathSegmentsCount - 1))
                {
                    reflectX2Y2 = YES;
                }
                
                if ((previousPathCommand == 'M') || (previousPathCommand == 'm'))
                {
                    reflectX1Y1 = YES;
                }

                [self addHandleForCubicCurveto:pathSegment segmentIndex:segmentIdx
                        reflectX1Y1:reflectX1Y1
                        reflectX2Y2:reflectX2Y2
                        pathHandlesGroup:newPathHandlesGroup pathXMLElement:pathXMLElement];
                break;
            }
            case 'S':     // smooth cubic Bezier curveto
            case 's':     // smooth cubic Bezier curveto
                [self addHandleForSmoothCubicCurveto:pathSegment segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup pathXMLElement:pathXMLElement];
                break;

            case 'Q':     // quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
                [self addHandleForQuadraticCurveto:pathSegment segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup pathXMLElement:pathXMLElement];
                break;

            case 'T':     // smooth quadratic Bezier curve
            case 't':     // smooth quadratic Bezier curve
                [self addHandleForSmoothQuadraticCurveto:pathSegment segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup pathXMLElement:pathXMLElement];
                break;

            case 'A':     // elliptical arc
            case 'a':     // elliptical arc
                [self addHandleForEllipicalArc:pathSegment segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup pathXMLElement:pathXMLElement];
                break;

            case 'Z':     // closepath
            case 'z':     // closepath
                [self addHandleForClosePath:pathSegment segmentIndex:segmentIdx pathHandlesGroup:newPathHandlesGroup pathXMLElement:pathXMLElement];
                break;
        }
        
        previousPathCommand = commandChar;
    }
    
    [domSelectionControlsManager setMacsvgTopGroupChild:topGroupChild];

    if (self.highlightSelectedSegment == YES)
    {
        [domSelectionControlsManager highlightPathSegment];
    }
    else
    {
        [domSelectionControlsManager removeDOMPathSegmentHighlight];
    }
}

//==================================================================================
//	buildPathStringWithPathSegmentsArray:
//==================================================================================

- (NSString *)buildPathStringWithPathSegmentsArray:(NSArray *)aPathSegmentsArray
{
    // convert path segments data to DOM
    NSUInteger pathSegmentsCount = aPathSegmentsArray.count;

    NSMutableString * newPathString = [[NSMutableString alloc] init];
    
    for (NSInteger i = 0; i < pathSegmentsCount; i++)
    {
        PathSegment * pathSegment = aPathSegmentsArray[i];
        
        unichar commandChar = pathSegment.pathCommand;
        
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
                    NSString * pathCommandString = [NSString stringWithFormat:@"%C", commandChar];
                    [newPathString appendString:pathCommandString];
                }
                
                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                
                [newPathString appendString:@","];
                
                NSString * yString = pathSegment.yString;
                [newPathString appendString:yString];
                
                [newPathString appendString:@" "];
                
                break;
            }
            case 'L':     // lineto
            {
                [newPathString appendString:@"L"];
                
                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = pathSegment.yString;
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'l':     // lineto
            {
                [newPathString appendString:@"l"];
                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = pathSegment.yString;
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'H':     // horizontal lineto
            {
                [newPathString appendString:@"H"];
                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                [newPathString appendString:@" "];
                break;
            }
            case 'h':     // horizontal lineto
            {
                [newPathString appendString:@"h"];
                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                [newPathString appendString:@" "];
                break;
            }
            case 'V':     // vertical lineto
            {
                [newPathString appendString:@"V"];
                NSString * yString = pathSegment.yString;
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'v':     // vertical lineto
            {
                [newPathString appendString:@"v"];
                NSString * yString = pathSegment.yString;
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'C':     // curveto
            {
                [newPathString appendString:@"C"];
                NSString * x1String = pathSegment.x1String;
                [newPathString appendString:x1String];
                [newPathString appendString:@","];
                NSString * y1String = pathSegment.y1String;
                [newPathString appendString:y1String];
                [newPathString appendString:@" "];

                NSString * x2String = pathSegment.x2String;
                [newPathString appendString:x2String];
                [newPathString appendString:@","];
                NSString * y2String = pathSegment.y2String;
                [newPathString appendString:y2String];
                [newPathString appendString:@" "];

                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = pathSegment.yString;
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'c':     // curveto
            {
                [newPathString appendString:@"c"];
                NSString * x1String = pathSegment.x1String;
                [newPathString appendString:x1String];
                [newPathString appendString:@","];
                NSString * y1String = pathSegment.y1String;
                [newPathString appendString:y1String];
                [newPathString appendString:@" "];

                NSString * x2String = pathSegment.x2String;
                [newPathString appendString:x2String];
                [newPathString appendString:@","];
                NSString * y2String = pathSegment.y2String;
                [newPathString appendString:y2String];
                [newPathString appendString:@" "];

                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = pathSegment.yString;
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'S':     // smooth curveto
            {
                [newPathString appendString:@"S"];

                NSString * x2String = pathSegment.x2String;
                [newPathString appendString:x2String];
                [newPathString appendString:@","];
                NSString * y2String = pathSegment.y2String;
                [newPathString appendString:y2String];
                [newPathString appendString:@" "];

                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = pathSegment.yString;
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 's':     // smooth curveto
            {
                [newPathString appendString:@"s"];

                NSString * x2String = pathSegment.x2String;
                [newPathString appendString:x2String];
                [newPathString appendString:@","];
                NSString * y2String = pathSegment.y2String;
                [newPathString appendString:y2String];
                [newPathString appendString:@" "];

                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = pathSegment.yString;
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'Q':     // quadratic Bezier curve
            {
                [newPathString appendString:@"Q"];
                NSString * x1String = pathSegment.x1String;
                [newPathString appendString:x1String];
                [newPathString appendString:@","];
                NSString * y1String = pathSegment.y1String;
                [newPathString appendString:y1String];
                [newPathString appendString:@" "];

                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = pathSegment.yString;
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'q':     // quadratic Bezier curve
            {
                [newPathString appendString:@"q"];
                NSString * x1String = pathSegment.x1String;
                [newPathString appendString:x1String];
                [newPathString appendString:@","];
                NSString * y1String = pathSegment.y1String;
                [newPathString appendString:y1String];
                [newPathString appendString:@" "];

                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = pathSegment.yString;
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'T':     // smooth quadratic Bezier curve
            {
                [newPathString appendString:@"T"];
                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = pathSegment.yString;
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 't':     // smooth quadratic Bezier curve
            {
                [newPathString appendString:@"t"];
                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = pathSegment.yString;
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'A':     // elliptical arc
            {
                [newPathString appendString:@"A"];
                
                NSString * rxString = pathSegment.rxString;
                [newPathString appendString:rxString];
                [newPathString appendString:@","];
                NSString * ryString = pathSegment.ryString;
                [newPathString appendString:ryString];
                [newPathString appendString:@" "];
                
                NSString * dataXAxisRotationString = pathSegment.xAxisRotationString;
                [newPathString appendString:dataXAxisRotationString];
                [newPathString appendString:@" "];
                
                NSString * dataLargeArcString = pathSegment.largeArcFlagString;
                [newPathString appendString:dataLargeArcString];
                [newPathString appendString:@" "];
                
                NSString * sweepString = pathSegment.sweepFlagString;
                [newPathString appendString:sweepString];
                [newPathString appendString:@" "];
                
                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = pathSegment.yString;
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                break;
            }
            case 'a':     // elliptical arc
            {
                [newPathString appendString:@"a"];
                
                NSString * rxString = pathSegment.rxString;
                [newPathString appendString:rxString];
                [newPathString appendString:@","];
                NSString * ryString = pathSegment.ryString;
                [newPathString appendString:ryString];
                [newPathString appendString:@" "];
                
                NSString * aXAxisRotationString = pathSegment.xAxisRotationString;
                [newPathString appendString:aXAxisRotationString];
                [newPathString appendString:@" "];
                
                NSString * largeArcString = pathSegment.largeArcFlagString;
                [newPathString appendString:largeArcString];
                [newPathString appendString:@" "];
                
                NSString * sweepString = pathSegment.sweepFlagString;
                [newPathString appendString:sweepString];
                [newPathString appendString:@" "];
                
                NSString * xString = pathSegment.xString;
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = pathSegment.yString;
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
//	updatePathInDOMForElement:pathSegmentsArray:updatePathLength:
//==================================================================================

- (void)updatePathInDOMForElement:(DOMElement *)pathElement pathSegmentsArray:(NSArray *)aPathSegmentsArray updatePathLength:(BOOL)updatePathLength
{
    NSString * newPathString = [self buildPathStringWithPathSegmentsArray:aPathSegmentsArray];

    [pathElement setAttribute:@"d" value:newPathString];
    
    MacSVGPlugin * currentPlugin = macSVGDocumentWindowController.editorUIFrameController.elementEditorPlugInController.currentPlugin;
    
    NSString * pluginName = [currentPlugin pluginName];
    
    if ([pluginName isEqualToString:@"Path Element Editor"] == YES)
    {
        NSString * macsvgid = [pathElement getAttribute:@"macsvgid"];
        
        if (macsvgid != NULL)
        {
            MacSVGDocument * macSVGDocument = macSVGDocumentWindowController.document;
            
            NSXMLElement * pathXMLElement = [macSVGDocument xmlElementForMacsvgid:macsvgid];
            
            [currentPlugin updateEditForXMLElement:pathXMLElement domElement:pathElement info:aPathSegmentsArray updatePathLength:updatePathLength];
        }
    }
}

//==================================================================================
//	updateActivePathInDOM:
//==================================================================================

- (void)updateActivePathInDOM:(BOOL)updatePathLength
{
    NSUInteger currentToolMode = macSVGDocumentWindowController.currentToolMode;

    if ((currentToolMode == toolModePath) || (currentToolMode == toolModeCrosshairCursor))
    {
        DOMElement * activeDOMElement = [svgXMLDOMSelectionManager activeDOMElement];
        if (activeDOMElement != NULL)
        {
            NSString * activeDOMElementName = activeDOMElement.tagName;
            if ([activeDOMElementName isEqualToString:@"path"] == YES)
            {
                [self updatePathInDOMForElement:activeDOMElement
                        pathSegmentsArray:self.pathSegmentsArray updatePathLength:updatePathLength];
            }
        }
        
        [svgXMLDOMSelectionManager syncSelectedDOMElementsToXMLDocument];
        
        [macSVGDocumentWindowController reloadAttributesTableData];
        
        NSXMLElement * activeXMLElement = [svgXMLDOMSelectionManager activeXMLElement];
        if (activeXMLElement != NULL)
        {
            NSString * activeXMLElementName = activeXMLElement.name;
            if ([activeXMLElementName isEqualToString:@"path"] == YES)
            {
                [self makePathHandlesForXMLElement:activeXMLElement];
            }
        }
    }
}

//==================================================================================
//	updateSelectedPathInDOM:
//==================================================================================

- (void)updateSelectedPathInDOM:(BOOL)updatePathLength
{
    if (self.selectedPathElement != NULL)
    {
        NSXMLNode * MacsvgidNode = [self.selectedPathElement attributeForName:@"macsvgid"];
        NSString * macsvgid = MacsvgidNode.stringValue;
        
        DOMElement * selectedDOMPathElement = [svgWebKitController domElementForMacsvgid:macsvgid];
    
        [self updatePathInDOMForElement:selectedDOMPathElement
                pathSegmentsArray:self.pathSegmentsArray updatePathLength:updatePathLength];
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
    
    [svgXMLDOMSelectionManager.domSelectionControlsManager
            removeMacsvgTopGroupChildByID:@"_macsvg_pathHandlesGroup"];

    [svgXMLDOMSelectionManager.domSelectionControlsManager
            removeMacsvgTopGroupChildByClass:@"_macsvg_path_transform_group"];
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
    self.editingMode = kPathEditingModeNotActive;

    [self removePathHandles];
}

//==================================================================================
//	startPathWithParentDOMElement:
//==================================================================================

- (void)startPathWithParentDOMElement:(DOMElement *)parentDOMElement
{
    // we start paths with an absolute moveto
    //NSLog(@"startPath");
    
    [self resetPathSegmentsArray];
    
    NSPoint mouseEventClickPoint = domMouseEventsController.transformedClickMousePagePoint;
    
    NSString * clickXString = [self allocFloatString:mouseEventClickPoint.x];
    NSString * clickYString = [self allocFloatString:mouseEventClickPoint.y];
    
    PathSegment * movetoPathSegment = [[PathSegment alloc] init];
    
    // start all paths with absolute moveto
    movetoPathSegment.pathCommand = 'M';
    movetoPathSegment.xString = clickXString;
    movetoPathSegment.yString = clickYString;

    movetoPathSegment.absoluteXFloat = mouseEventClickPoint.x;
    movetoPathSegment.absoluteYFloat = mouseEventClickPoint.y;
    
    [self.pathSegmentsArray addObject:movetoPathSegment];
    
    [self updateActivePathInDOM:YES];
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

    NSString * newXString = [self allocFloatString:domMouseEventsController.transformedCurrentMousePagePoint.x];
    NSString * newYString = [self allocFloatString:domMouseEventsController.transformedCurrentMousePagePoint.y];

    float newX = newXString.floatValue;
    float newY = newYString.floatValue;



    
    PathSegment * pathSegment = (self.pathSegmentsArray)[self.pathSegmentIndex];

    NSString * existingXString = pathSegment.xString;     // endpoint x
    NSString * existingYString = pathSegment.yString;     // endpoint y
    
    NSString * existingX1String = newXString;
    NSString * existingY1String = newYString;

    NSString * tempExistingX1String = pathSegment.x1String;     // endpoint x
    NSString * tempExistingY1String = pathSegment.y1String;     // endpoint y
    
    if (tempExistingX1String != NULL) existingX1String = tempExistingX1String;
    if (tempExistingY1String != NULL) existingY1String = tempExistingY1String;



    
    float existingX = existingXString.floatValue;
    float existingY = existingYString.floatValue;
    float existingX1 = existingX1String.floatValue;
    float existingY1 = existingY1String.floatValue;
    
    NSString * previousExistingXString = existingXString;
    NSString * previousExistingYString = existingYString;
    
    if (self.pathSegmentIndex > 1)
    {
        PathSegment * pathSegment2 = (self.pathSegmentsArray)[(self.pathSegmentIndex - 1)];
        
        NSString * tempPreviousExistingXString = pathSegment2.xString;     // endpoint x
        NSString * tempPreviousExistingYString = pathSegment2.yString;     // endpoint y

        if (tempPreviousExistingXString != NULL) previousExistingXString = tempPreviousExistingXString;
        if (tempPreviousExistingYString != NULL) previousExistingYString = tempPreviousExistingYString;
    }
    
    float previousExistingX = previousExistingXString.floatValue;
    float previousExistingY = previousExistingYString.floatValue;
    
    

    float deltaX = existingX - newX;
    float deltaY = existingY - newY;
    
    const float kPointMinDistance = 30.0f;
    const float kPointMinDistanceSquared = kPointMinDistance * kPointMinDistance;


    if (((deltaX * deltaX) + (deltaY * deltaY)) >= kPointMinDistanceSquared)
    {
        PathSegment * newPathSegment = [[PathSegment alloc] init];

        if (self.useRelativePathCoordinates == YES)
        {
            NSPoint existingPoint = NSMakePoint(existingX, existingY);
            NSPoint previousExistingPoint = NSMakePoint(previousExistingX, previousExistingY);
            
            NSPoint existingControlPoint = NSMakePoint(existingX1, existingY1);
            NSPoint existingMidPoint = bezierMidPoint(previousExistingPoint, existingControlPoint, existingPoint);
        
            float newX1 = (existingX + (existingX - existingMidPoint.x));
            float newY1 = (existingY + (existingY - existingMidPoint.y));
            
            NSString * newX1String = [self allocFloatString:newX1];
            NSString * newY1String = [self allocFloatString:newY1];

            newPathSegment.pathCommand = 'q';
            
            newPathSegment.xString = newXString;
            newPathSegment.yString = newYString;
            
            newPathSegment.x1String = newX1String;
            newPathSegment.y1String = newY1String;
        }
        else
        {
            NSPoint existingPoint = NSMakePoint(existingX, existingY);
            NSPoint previousExistingPoint = NSMakePoint(previousExistingX, previousExistingY);
            
            NSPoint existingControlPoint = NSMakePoint(existingX1, existingY1);
            NSPoint existingMidPoint = bezierMidPoint(previousExistingPoint, existingControlPoint, existingPoint);
        
            float newX1 = (existingX + (existingX - existingMidPoint.x));
            float newY1 = (existingY + (existingY - existingMidPoint.y));
            
            NSString * newX1String = [self allocFloatString:newX1];
            NSString * newY1String = [self allocFloatString:newY1];

            newPathSegment.pathCommand = 'Q';
            
            newPathSegment.xString = newXString;
            newPathSegment.yString = newYString;
            
            newPathSegment.x1String = newX1String;
            newPathSegment.y1String = newY1String;
        }

        [self.pathSegmentsArray addObject:newPathSegment];
        self.pathSegmentIndex = (self.pathSegmentsArray).count - 1;
        
        //NSLog(@"pathSegmentsArray - %@", pathSegmentsArray);
        
        [self updatePathSegmentsAbsoluteValues:self.pathSegmentsArray];

        [self updateActivePathInDOM:YES];
    }
}

//==================================================================================
//	offsetPathElement:attribute:by:pathSegment:
//==================================================================================

- (void)offsetPathElement:(DOMElement *)pathElement attribute:(NSString *)attribute 
        by:(float)byValue pathSegment:(PathSegment *)pathSegment
{
    float currentValue = 0;
    
    if ([attribute isEqualToString:@"x"] == YES)
    {
        currentValue = pathSegment.xFloat;
        float newValue = currentValue + byValue;
        pathSegment.xFloat = newValue;
    }
    else if ([attribute isEqualToString:@"y"] == YES)
    {
        currentValue = pathSegment.yFloat;
        float newValue = currentValue + byValue;
        pathSegment.yFloat = newValue;
    }
    else if ([attribute isEqualToString:@"x1"] == YES)
    {
        currentValue = pathSegment.x1Float;
        float newValue = currentValue + byValue;
        pathSegment.x1Float = newValue;
    }
    else if ([attribute isEqualToString:@"y1"] == YES)
    {
        currentValue = pathSegment.y1Float;
        float newValue = currentValue + byValue;
        pathSegment.y1Float = newValue;
    }
    else if ([attribute isEqualToString:@"x2"] == YES)
    {
        currentValue = pathSegment.x2Float;
        float newValue = currentValue + byValue;
        pathSegment.x2Float = newValue;
    }
    else if ([attribute isEqualToString:@"y2"] == YES)
    {
        currentValue = pathSegment.y2Float;
        float newValue = currentValue + byValue;
        pathSegment.y2Float = newValue;
    }
    else
    {
        NSLog(@"SVGPathEditor - Error offsetPathElement:attribute:by:pathSegment invalid attribute %@", attribute);
    }
}

//==================================================================================
//	offsetPath:deltaX:deltaY:
//==================================================================================

- (void)offsetPath:(DOMElement *)pathElement deltaX:(float)deltaX deltaY:(float)deltaY
{
    // for dragging the whole path
    NSString * pathString = [pathElement getAttribute:@"d"];

    NSMutableArray * aPathsArray = [self buildPathSegmentsArrayWithPathString:pathString];
    
    self.pathSegmentsArray = aPathsArray;

    NSUInteger pathSegmentsCount = aPathsArray.count;
            
    for (NSUInteger segmentIdx = 0; segmentIdx < pathSegmentsCount; segmentIdx++)
    {
        PathSegment * pathSegment = aPathsArray[segmentIdx];

        unichar commandChar = pathSegment.pathCommand;

        switch (commandChar) 
        {
            case 'M':     // moveto
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegment:pathSegment];
                break;
            case 'm':     // moveto
                // no recalculation required for relative path
                break;

            case 'L':     // lineto
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegment:pathSegment];
                break;
            case 'l':     // lineto
                // no recalculation required for relative path
                break;

            case 'H':     // horizontal lineto
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegment:pathSegment];
                break;
            case 'h':     // horizontal lineto
                // no recalculation required for relative path
                break;

            case 'V':     // vertical lineto
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegment:pathSegment];
                break;
            case 'v':     // vertical lineto
                // no recalculation required for relative path
                break;

            case 'C':     // cubic Bezier curveto
                [self offsetPathElement:pathElement attribute:@"x1" by:deltaX pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"y1" by:deltaY pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"x2" by:deltaX pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"y2" by:deltaY pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegment:pathSegment];
                break;
            case 'c':     // cubic Bezier curveto
                // no recalculation required for relative path
                break;
                
            case 'S':     // smooth cubic Bezier curveto
                [self offsetPathElement:pathElement attribute:@"x2" by:deltaX pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"y2" by:deltaY pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegment:pathSegment];
                break;
            case 's':     // smooth cubic Bezier curveto
                // no recalculation required for relative path
                break;

            case 'Q':     // quadratic Bezier curve
                [self offsetPathElement:pathElement attribute:@"x1" by:deltaX pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"y1" by:deltaY pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegment:pathSegment];
                break;
            case 'q':     // quadratic Bezier curve
                // no recalculation required for relative path
                break;

            case 'T':     // smooth quadratic Bezier curve
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegment:pathSegment];
                break;
            case 't':     // smooth quadratic Bezier curve
                // no recalculation required for relative path
                break;

            case 'A':     // elliptical arc
                [self offsetPathElement:pathElement attribute:@"x" by:deltaX pathSegment:pathSegment];
                [self offsetPathElement:pathElement attribute:@"y" by:deltaY pathSegment:pathSegment];
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
    
    [self updatePathInDOMForElement:pathElement pathSegmentsArray:aPathsArray updatePathLength:YES];

    // update selection rect for path element
    //[svgXMLDOMSelectionManager offsetSelectionRectForDOMElement:pathElement
    //        deltaX:deltaX deltaY:deltaY];
    
    // work-around webkit bug to fix bounding rect, replace existing DOM path element
    DOMDocument * domDocument = (svgWebKitController.svgWebView).mainFrame.DOMDocument;
    MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)NSApp.delegate;
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
    
    NSString * selectedPathMode = macSVGDocumentWindowController.selectedPathMode;

    if ([selectedPathMode isEqualToString:@"Freestyle Path"] == YES)
    {
        [self extendFreestylePath];
    }
    else
    {
        if (self.pathSegmentIndex < 0)
        {
            if ((self.pathSegmentsArray).count > 0)
            {
                self.pathSegmentIndex = (self.pathSegmentsArray).count - 1;
            }
        }
    
        if (self.pathSegmentIndex > 0) 
        {
            PathSegment * pathSegment = (self.pathSegmentsArray)[self.pathSegmentIndex];
            unichar pathCommand = pathSegment.pathCommand;

            NSPoint transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;
            NSPoint transformedExistingMousePoint = domMouseEventsController.previousTransformedMousePagePoint;

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
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    
                    float x = xString.floatValue;
                    float y = yString.floatValue;
                    
                    float deltaX = transformedCurrentMousePoint.x - x;
                    float deltaY = transformedCurrentMousePoint.y - y;
                    
                    float newX2 = x - deltaX;
                    float newY2 = y - deltaY;
                    
                    NSString * newX2String = [self allocFloatString:newX2];
                    NSString * newY2String = [self allocFloatString:newY2];

                    pathSegment.x2String = newX2String;    // control point x2
                    pathSegment.y2String = newY2String;    // control point y2

                    break;
                }
                case 'c':     // cubic curveto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];

                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;

                    float x = xString.floatValue;
                    float y = yString.floatValue;
                    
                    float mouseRelX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    float mouseRelY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    float deltaX = x - mouseRelX;
                    float deltaY = y - mouseRelY;
                   
                    float newX2 = x + deltaX;
                    float newY2 = y + deltaY;

                    NSString * newX2String = [self allocFloatString:newX2];
                    NSString * newY2String = [self allocFloatString:newY2];

                    pathSegment.x2String = newX2String;
                    pathSegment.y2String = newY2String;
                    
                    break;
                }
                case 'S':     // smooth cubic curveto absolute
                {
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    
                    float x = xString.floatValue;
                    float y = yString.floatValue;
                    
                    float deltaX = transformedCurrentMousePoint.x - x;
                    float deltaY = transformedCurrentMousePoint.y - y;
                    
                    float newX2 = x - deltaX;
                    float newY2 = y - deltaY;
                                    
                    NSString * newX2String = [self allocFloatString:newX2];
                    NSString * newY2String = [self allocFloatString:newY2];

                    pathSegment.x2String = newX2String;    // control point 2 x
                    pathSegment.y2String = newY2String;    // control point 2 y

                    break;
                }
                case 's':     // smooth cubic curveto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];

                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;

                    float x = xString.floatValue;
                    float y = yString.floatValue;
                    
                    float mouseRelX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    float mouseRelY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    float deltaX = x - mouseRelX;
                    float deltaY = y - mouseRelY;
                   
                    float newX2 = x + deltaX;
                    float newY2 = y + deltaY;
                    
                    NSString * newX2String = [self allocFloatString:newX2];
                    NSString * newY2String = [self allocFloatString:newY2];

                    pathSegment.x2String = newX2String;
                    pathSegment.y2String = newY2String;
                    
                    break;
                }
                case 'Q':     // quadratic curveto absolute
                {
                    NSString * x1String = pathSegment.x1String;
                    NSString * y1String = pathSegment.y1String;
                    
                    float x1 = x1String.floatValue;
                    float y1 = y1String.floatValue;
                    
                    float deltaX = transformedCurrentMousePoint.x - transformedExistingMousePoint.x;
                    float deltaY = transformedCurrentMousePoint.y - transformedExistingMousePoint.y;
                    
                    float newX1 = x1 - deltaX;
                    float newY1 = y1 - deltaY;
                                    
                    NSString * newX1String = [self allocFloatString:newX1];
                    NSString * newY1String = [self allocFloatString:newY1];

                    pathSegment.x1String = newX1String;
                    pathSegment.y1String = newY1String;

                    break;
                }
                case 'q':     // quadratic curveto relative
                {
                    NSString * x1String = pathSegment.x1String;
                    NSString * y1String = pathSegment.y1String;
                    
                    float x1 = x1String.floatValue;
                    float y1 = y1String.floatValue;
                    
                    float deltaX = transformedCurrentMousePoint.x - transformedExistingMousePoint.x;
                    float deltaY = transformedCurrentMousePoint.y - transformedExistingMousePoint.y;
                    
                    float newX1 = x1 - deltaX;
                    float newY1 = y1 - deltaY;
                                    
                    NSString * newX1String = [self allocFloatString:newX1];
                    NSString * newY1String = [self allocFloatString:newY1];

                    pathSegment.x1String = newX1String;
                    pathSegment.y1String = newY1String;

                    break;
                }
                case 'T':     // smooth quadratic curveto absolute
                {
                    NSString * newXString = [self allocFloatString:transformedCurrentMousePoint.x];
                    NSString * newYString = [self allocFloatString:transformedCurrentMousePoint.y];

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;

                    break;
                }
                case 't':     // smooth quadratic curveto relative
                {
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    
                    float x = xString.floatValue;
                    float y = yString.floatValue;
                    
                    float deltaX = transformedCurrentMousePoint.x - transformedExistingMousePoint.x;
                    float deltaY = transformedCurrentMousePoint.y - transformedExistingMousePoint.y;
                    
                    float newX = x - deltaX;
                    float newY = y - deltaY;
                                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;

                    break;
                }
                case 'A':     // elliptical arc absolute
                {
                    // vary the arc x and y radius with mouse dragging
                    
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    
                    float x = xString.floatValue;
                    float y = yString.floatValue;
                    
                    float absoluteStartXFloat = pathSegment.absoluteStartXFloat;
                    float absoluteStartYFloat = pathSegment.absoluteStartYFloat;

                    float midX = (x + absoluteStartXFloat) / 2.0f;
                    float midY = (y + absoluteStartYFloat) / 2.0f;

                    float distance = sqrtf(((transformedCurrentMousePoint.x - midX) * (transformedCurrentMousePoint.x - midX)) + ((transformedCurrentMousePoint.y - midY) * (transformedCurrentMousePoint.y - midY)));
                    float radiusX = fabs(distance);
                    float radiusY = fabs(distance);

                    NSString * radiusXString = [self allocFloatString:radiusX];
                    NSString * radiusYString = [self allocFloatString:radiusY];
                    
                    pathSegment.rxString = radiusXString;    // radius x
                    pathSegment.ryString = radiusYString;    // radius y
                    
                    break;
                }
                case 'a':     // elliptical arc relative
                {
                    // vary the arc x and y radius with mouse dragging
                    //NSString * xString = pathSegment.absoluteX;
                    //NSString * yString = pathSegment.absoluteY;
                    
                    //float x = xString.floatValue;
                    //float y = yString.floatValue;
                    
                    float x = pathSegment.absoluteXFloat;
                    float y = pathSegment.absoluteYFloat;
                    
                    float absoluteStartXFloat = pathSegment.absoluteStartXFloat;
                    float absoluteStartYFloat = pathSegment.absoluteStartYFloat;

                    float midX = (x + absoluteStartXFloat) / 2.0f;
                    float midY = (y + absoluteStartYFloat) / 2.0f;

                    float distance = sqrtf(((transformedCurrentMousePoint.x - midX) * (transformedCurrentMousePoint.x - midX)) + ((transformedCurrentMousePoint.y - midY) * (transformedCurrentMousePoint.y - midY)));
                    float radiusX = fabs(distance);
                    float radiusY = fabs(distance);

                    NSString * radiusXString = [self allocFloatString:radiusX];
                    NSString * radiusYString = [self allocFloatString:radiusY];
                    
                    pathSegment.rxString = radiusXString;    // radius x
                    pathSegment.ryString = radiusYString;    // radius y

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

    [self updateActivePathInDOM:YES];
}


//==================================================================================
//	restartLastPathSegment
//==================================================================================

- (void)restartLastPathSegment
{
    NSInteger pathSegmentsArrayCount = (self.pathSegmentsArray).count;
    if (pathSegmentsArrayCount > 0)
    {
        [self deleteLastSegmentInPath];
        
        pathSegmentsArrayCount = (self.pathSegmentsArray).count;
        NSPoint lastSegmentPoint = [self absoluteXYPointAtPathSegmentIndex:(pathSegmentsArrayCount - 1)];
        
        if (lastSegmentPoint.x != NSNotFound)
        {
            // TODO: if problems here, try calling setCurrentMousePointsWithDOMMouseEvent:transformTargetElement:
            domMouseEventsController.currentMousePagePoint = lastSegmentPoint;
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
    PathSegment * newPathSegment = NULL;

    NSString * selectedPathMode = macSVGDocumentWindowController.selectedPathMode;

    if ([selectedPathMode isEqualToString:@"Freestyle Path"] == YES)
    {
    }
    else
    {
        // find the last path close command, if one exists
        NSInteger lastClosePathIndex = -1;
        for (PathSegment * aPathSegment in self.pathSegmentsArray)
        {
            NSInteger aPathSegmentIndex = [self.pathSegmentsArray indexOfObject:aPathSegment];
            unichar aPathCommand = aPathSegment.pathCommand;
            
            switch (aPathCommand)
            {
                case 'Z':
                case 'z':
                {
                    lastClosePathIndex = aPathSegmentIndex;
                    break;
                }
            }
        }
    
        if (self.selectedPathElement != NULL)
        {
            if ((self.pathSegmentsArray).count == 0)
            {
                [self buildPathSegmentsArray:self.selectedPathElement];
                NSInteger pathSegmentsArrayCount = self.pathSegmentsArray.count;
                if (pathSegmentsArrayCount > 0)
                {
                    self.pathSegmentIndex = (self.pathSegmentsArray).count - 1;
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
            if ((self.pathSegmentsArray).count == 1)
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
        
        BOOL indexRangeIsValid = NO;
    
        if (self.pathSegmentIndex >= 0)
        {
            if (self.pathSegmentIndex < (self.pathSegmentsArray).count)
            {
                indexRangeIsValid = YES;
            }
        }
        
        if (indexRangeIsValid == YES)
        {
            PathSegment * pathSegment = (self.pathSegmentsArray)[self.pathSegmentIndex];
            unichar previousPathCommand = pathSegment.pathCommand;
            
            //NSLog(@"extendPath %ld %@", (self.pathSegmentsArray).count, previousPathCommandString);
            
            if (self.pathSegmentIndex > 2)
            {
                if (previousPathCommand == 'M')
                {
                    PathSegment * secondPreviousPathSegment = (self.pathSegmentsArray)[self.pathSegmentIndex - 1];
                    unichar secondPreviousPathCommand = secondPreviousPathSegment.pathCommand;
                    
                    if (secondPreviousPathCommand == 'Z')
                    {
                    
                    }
                }
            }
            
            BOOL pathWasRelative = NO;
            if (previousPathCommand >= 'a')
            {
                if (previousPathCommand <= 'z')
                {
                    pathWasRelative = YES;
                }
            }
            
            NSString * previousXString = pathSegment.xString;     // endpoint x
            NSString * previousYString = pathSegment.yString;     // endpoint y

            //DOMElement * activeDOMElement = [svgWebKitController.svgXMLDOMSelectionManager activeDOMElement]; // the path element

            NSPoint transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;

            NSString * newXString = [self allocFloatString:transformedCurrentMousePoint.x];
            NSString * newYString = [self allocFloatString:transformedCurrentMousePoint.y];

            newPathSegment = [[PathSegment alloc] init];
            
            NSPoint startPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
            float absoluteStartX = startPathPoint.x;
            float absoluteStartY = startPathPoint.y;
            newPathSegment.absoluteStartXFloat = absoluteStartX;
            newPathSegment.absoluteStartYFloat = absoluteStartY;
            
            //NSString * selectedPathMode = macSVGDocumentWindowController.selectedPathMode;
            
            if ([selectedPathMode isEqualToString:@"Move To"] == YES)
            {
                if (self.useRelativePathCoordinates == YES)
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                    
                    float newRelX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    float newRelY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newRelXString = [self allocFloatString:newRelX];
                    NSString * newRelYString = [self allocFloatString:newRelY];
                
                    newPathSegment.pathCommand = 'm';
                    
                    newPathSegment.xString = newRelXString;
                    newPathSegment.yString = newRelYString;
                }
                else
                {
                    newPathSegment.pathCommand = 'M';
                    
                    newPathSegment.xString = newXString;
                    newPathSegment.yString = newYString;
                }
            }
            else if ([selectedPathMode isEqualToString:@"Line To"] == YES)
            {
                if (self.useRelativePathCoordinates == YES)
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                    float newRelX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    float newRelY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newRelXString = [self allocFloatString:newRelX];
                    NSString * newRelYString = [self allocFloatString:newRelY];
                
                    newPathSegment.pathCommand = 'l';
                    
                    newPathSegment.xString = newRelXString;
                    newPathSegment.yString = newRelYString;
                }
                else
                {
                    newPathSegment.pathCommand= 'L';
                    
                    newPathSegment.xString = newXString;
                    newPathSegment.yString = newYString;
                }
            }
            else if ([selectedPathMode isEqualToString:@"Horizontal Line"] == YES)
            {
                if (self.useRelativePathCoordinates == YES)
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                    float newRelX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    
                    NSString * newRelXString = [self allocFloatString:newRelX];
                
                    newPathSegment.pathCommand = 'h';
                    
                    newPathSegment.xString = newRelXString;
                }
                else
                {
                    newPathSegment.pathCommand = 'H';
                    
                    newPathSegment.xString = newXString;
                }
            }
            else if ([selectedPathMode isEqualToString:@"Vertical Line"] == YES)
            {
                if (self.useRelativePathCoordinates == YES)
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                    float newRelY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newRelYString = [self allocFloatString:newRelY];
                
                    newPathSegment.pathCommand = 'v';
                    
                    newPathSegment.yString = newRelYString;
                }
                else
                {
                    newPathSegment.pathCommand = 'V';
                    
                    newPathSegment.yString = newYString;
                }
            }
            else if ([selectedPathMode isEqualToString:@"Cubic Curve"] == YES)
            {
                if (previousPathCommand == 'C')
                {
                    NSString * previousX2String = pathSegment.x2String;     // control point 2 x
                    NSString * previousY2String = pathSegment.y2String;     // control point 2 y

                    float previousX2 = previousX2String.floatValue;
                    float previousY2 = previousY2String.floatValue;

                    float previousX = previousXString.floatValue;
                    float previousY = previousYString.floatValue;

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
                    
                        newPathSegment.pathCommand = 'c';
                        
                        newPathSegment.x1String = relX1String;
                        newPathSegment.y1String = relY1String;
                        
                        newPathSegment.x2String = relX1String;
                        newPathSegment.y2String = relY1String;
                        
                        newPathSegment.xString = relX1String;
                        newPathSegment.yString = relY1String;
                    }
                    else
                    {
                        NSString * newX1String = [self allocFloatString:newX1];
                        NSString * newY1String = [self allocFloatString:newY1];
                    
                        newPathSegment.pathCommand = 'C';
                        
                        newPathSegment.xString = newXString;
                        newPathSegment.yString = newYString;
                        
                        newPathSegment.x1String = newX1String;
                        newPathSegment.y1String = newY1String;
                        
                        newPathSegment.x2String = newXString;
                        newPathSegment.y2String = newYString;
                    }
                }
                else if (previousPathCommand == 'c')
                {
                    if (self.useRelativePathCoordinates == YES)
                    {
                        NSString * previousXString = pathSegment.xString;
                        NSString * previousYString = pathSegment.yString;
                        NSString * previousX2String = pathSegment.x2String;
                        NSString * previousY2String = pathSegment.y2String;
                    
                        float previousX = previousXString.floatValue;
                        float previousY = previousYString.floatValue;
                        float previousX2 = previousX2String.floatValue;
                        float previousY2 = previousY2String.floatValue;
                        
                        float deltaX = previousX - previousX2;
                        float deltaY = previousY - previousY2;
                        
                        NSString * newX1String = [self allocFloatString:deltaX];
                        NSString * newY1String = [self allocFloatString:deltaY];

                        newPathSegment.pathCommand = 'c';
                        
                        newPathSegment.x1String = newX1String;
                        newPathSegment.y1String = newY1String;
                        
                        newPathSegment.x2String = @"0";
                        newPathSegment.y2String = @"0";
                        
                        newPathSegment.xString = @"0";
                        newPathSegment.yString = @"0";
                    }
                    else
                    {
                        NSString * previousX2String = pathSegment.x2String;     // control point 2 x
                        NSString * previousY2String = pathSegment.y2String;     // control point 2 y

                        float previousX2 = previousX2String.floatValue;
                        float previousY2 = previousY2String.floatValue;

                        float previousX = previousXString.floatValue;
                        float previousY = previousYString.floatValue;

                        float deltaX = previousX - previousX2;
                        float deltaY = previousY - previousY2;
                        
                        float newX1 = previousX + deltaX;
                        float newY1 = previousY + deltaY;

                        NSString * newX1String = [self allocFloatString:newX1];
                        NSString * newY1String = [self allocFloatString:newY1];
                    
                        newPathSegment.pathCommand = 'C';
                        
                        newPathSegment.xString = newXString;
                        newPathSegment.yString = newYString;
                        
                        newPathSegment.x1String = newX1String;
                        newPathSegment.y1String = newY1String;
                        
                        newPathSegment.x2String = newXString;
                        newPathSegment.y2String = newYString;
                    }
                }
                else
                {
                    // set starting point for first cubic path segment
                    if ((previousPathCommand == 'Z') || (previousPathCommand == 'z'))
                    {
                        if (self.useRelativePathCoordinates == YES)
                        {
                            NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                            float newRelX = transformedCurrentMousePoint.x - currentPathPoint.x;
                            float newRelY = transformedCurrentMousePoint.y - currentPathPoint.y;
                            
                            NSString * newRelXString = [self allocFloatString:newRelX];
                            NSString * newRelYString = [self allocFloatString:newRelY];
                        
                            newPathSegment.pathCommand = 'm';
                            
                            newPathSegment.xString = newRelXString;
                            newPathSegment.yString = newRelYString;
                        }
                        else
                        {
                            newPathSegment.pathCommand = 'M';
                            
                            newPathSegment.xString = newXString;
                            newPathSegment.yString = newYString;
                        }
                    }
                    else
                    {
                        if (self.useRelativePathCoordinates == YES)
                        {
                            NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                            float newRelX = transformedCurrentMousePoint.x - currentPathPoint.x;
                            float newRelY = transformedCurrentMousePoint.y - currentPathPoint.y;
                            
                            NSString * newRelXString = [self allocFloatString:newRelX];
                            NSString * newRelYString = [self allocFloatString:newRelY];
                        
                            newPathSegment.pathCommand = 'c';
                            
                            newPathSegment.x1String = newRelXString;
                            newPathSegment.y1String = newRelYString;
                            
                            newPathSegment.x2String = newRelXString;
                            newPathSegment.y2String = newRelYString;
                            
                            newPathSegment.xString = newRelXString;
                            newPathSegment.yString = newRelYString;
                        }
                        else
                        {
                            newPathSegment.pathCommand = 'C';
                            
                            newPathSegment.x1String = newXString;
                            newPathSegment.y1String = newYString;
                            
                            newPathSegment.x2String = newXString;
                            newPathSegment.y2String = newYString;
                            
                            newPathSegment.xString = newXString;
                            newPathSegment.yString = newYString;
                        }
                    }
                }
            }
            else if ([selectedPathMode isEqualToString:@"Smooth Cubic Curve"] == YES)
            {
                if (self.useRelativePathCoordinates == YES)
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                    float newRelX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    float newRelY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newRelXString = [self allocFloatString:newRelX];
                    NSString * newRelYString = [self allocFloatString:newRelY];
                
                    newPathSegment.pathCommand = 's';
                    
                    newPathSegment.x2String = newRelXString;
                    newPathSegment.y2String = newRelYString;
                                    
                    newPathSegment.xString = newRelXString;
                    newPathSegment.yString = newRelYString;
                }
                else
                {
                    newPathSegment.pathCommand = 'S';
                    
                    newPathSegment.x2String = newXString;
                    newPathSegment.y2String = newYString;
                    
                    newPathSegment.xString = newXString;
                    newPathSegment.yString = newYString;
                }
            }
            else if ([selectedPathMode isEqualToString:@"Quadratic Curve"] == YES)
            {
                if (self.useRelativePathCoordinates == YES)
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                    float newRelX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    float newRelY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newRelXString = [self allocFloatString:newRelX];
                    NSString * newRelYString = [self allocFloatString:newRelY];
                
                    newPathSegment.pathCommand = 'q';
                    
                    newPathSegment.x1String = newRelXString;
                    newPathSegment.y1String = newRelYString;
                                    
                    newPathSegment.xString = newRelXString;
                    newPathSegment.yString = newRelYString;
                }
                else
                {
                    newPathSegment.pathCommand = 'Q';
                    
                    newPathSegment.x1String = newXString;
                    newPathSegment.y1String = newYString;
                    
                    newPathSegment.xString = newXString;
                    newPathSegment.yString = newYString;
                }
            }
            else if ([selectedPathMode isEqualToString:@"Smooth Quadratic Curve"] == YES)
            {
                if (self.useRelativePathCoordinates == YES)
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                    float newRelX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    float newRelY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newRelXString = [self allocFloatString:newRelX];
                    NSString * newRelYString = [self allocFloatString:newRelY];
                
                    newPathSegment.pathCommand = 't';
                    
                    newPathSegment.xString = newRelXString;
                    newPathSegment.yString = newRelYString;
                }
                else
                {
                    newPathSegment.pathCommand = 'T';
                    
                    newPathSegment.xString = newXString;
                    newPathSegment.yString = newYString;
                }
            }
            else if ([selectedPathMode isEqualToString:@"Elliptical Arc"] == YES)
            {
                if (previousPathCommand == 'A')
                {
                    if (self.useRelativePathCoordinates == YES)
                    {
                        NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                        float newRelX = transformedCurrentMousePoint.x - currentPathPoint.x;
                        float newRelY = transformedCurrentMousePoint.y - currentPathPoint.y;
                        
                        NSString * newRelXString = [self allocFloatString:newRelX];
                        NSString * newRelYString = [self allocFloatString:newRelY];
                        
                        newPathSegment.pathCommand = 'a';
                        
                        newPathSegment.xString = newRelXString;
                        newPathSegment.yString = newRelYString;
                        newPathSegment.xAxisRotationString = self.xAxisRotationString;
                        newPathSegment.largeArcFlagString = self.largeArcFlagString;
                        newPathSegment.sweepFlagString = self.sweepFlagString;
                        newPathSegment.rxString = self.pathRadiusXString;
                        newPathSegment.ryString = self.pathRadiusYString;
                    }
                    else
                    {
                        newPathSegment.pathCommand = 'A';
                        
                        newPathSegment.xString = newXString;
                        newPathSegment.yString = newYString;
                        newPathSegment.xAxisRotationString = self.xAxisRotationString;
                        newPathSegment.largeArcFlagString = self.largeArcFlagString;
                        newPathSegment.sweepFlagString = self.sweepFlagString;
                        newPathSegment.rxString = self.pathRadiusXString;
                        newPathSegment.ryString = self.pathRadiusYString;
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
                        
                        newPathSegment.pathCommand = 'a';
                        
                        newPathSegment.xString = newRelXString;
                        newPathSegment.yString = newRelYString;
                        newPathSegment.xAxisRotationString = self.xAxisRotationString;
                        newPathSegment.largeArcFlagString = self.largeArcFlagString;
                        newPathSegment.sweepFlagString = self.sweepFlagString;
                        newPathSegment.rxString = self.pathRadiusXString;
                        newPathSegment.ryString = self.pathRadiusYString;
                    }
                    else
                    {
                        newPathSegment.pathCommand = 'A';
                        
                        newPathSegment.xString = newXString;
                        newPathSegment.yString = newYString;
                        newPathSegment.xAxisRotationString = self.xAxisRotationString;
                        newPathSegment.largeArcFlagString = self.largeArcFlagString;
                        newPathSegment.sweepFlagString = self.sweepFlagString;
                        newPathSegment.rxString = self.pathRadiusXString;
                        newPathSegment.ryString = self.pathRadiusYString;
                    }
                }
                else
                {
                    // setting first point for elliptical arc
                    if (self.useRelativePathCoordinates == YES)
                    {
                        NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:self.pathSegmentIndex];
                        float newRelX = transformedCurrentMousePoint.x - currentPathPoint.x;
                        float newRelY = transformedCurrentMousePoint.y - currentPathPoint.y;
                        
                        NSString * newRelXString = [self allocFloatString:newRelX];
                        NSString * newRelYString = [self allocFloatString:newRelY];
                        
                        newPathSegment.pathCommand = 'a';
                        
                        newPathSegment.xString = newRelXString;
                        newPathSegment.yString = newRelYString;
                        newPathSegment.xAxisRotationString = self.xAxisRotationString;
                        newPathSegment.largeArcFlagString = self.largeArcFlagString;
                        newPathSegment.sweepFlagString = self.sweepFlagString;
                        newPathSegment.rxString = self.pathRadiusXString;
                        newPathSegment.ryString = self.pathRadiusYString;
                    }
                    else
                    {
                        newPathSegment.pathCommand = 'A';
                        
                        newPathSegment.xString = newXString;
                        newPathSegment.yString = newYString;
                        newPathSegment.xAxisRotationString = self.xAxisRotationString;
                        newPathSegment.largeArcFlagString = self.largeArcFlagString;
                        newPathSegment.sweepFlagString = self.sweepFlagString;
                        newPathSegment.rxString = self.pathRadiusXString;
                        newPathSegment.ryString = self.pathRadiusYString;
                    }
                }
            }
        }
        else
        {
            extendPathSuccess = NO;
        }
    
        if (extendPathSuccess == YES)
        {
            self.editingMode = kPathEditingModeNextSegment;

            [self.pathSegmentsArray addObject:newPathSegment];
            
            self.pathSegmentIndex = (self.pathSegmentsArray).count - 1;

            [self updatePathSegmentsAbsoluteValues:self.pathSegmentsArray];
            
            //NSLog(@"extendPath - pathSegmentsArray - %@", self.pathSegmentsArray);

            [self updateActivePathInDOM:YES];
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

-(void) editPathSegmentMoveto:(PathSegment *)pathSegment
{
    NSString * existingXString = pathSegment.xString;     // endpoint x
    NSString * existingYString = pathSegment.yString;     // endpoint y

    float existingX = existingXString.floatValue;
    float existingY = existingYString.floatValue;

    //NSPoint  currentMousePoint = domMouseEventsController.currentMousePoint;
    NSPoint  transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;
    
    if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
    {
        float deltaX = transformedCurrentMousePoint.x - existingX;
        float deltaY = transformedCurrentMousePoint.y - existingY;
        
        float newX = existingX + deltaX;
        float newY = existingY + deltaY;

        NSString * newXString = [self allocFloatString:newX];
        NSString * newYString = [self allocFloatString:newY];

        pathSegment.xString = newXString;
        pathSegment.yString = newYString;
        
        if (pathSegment.pathCommand == 'M')
        {
            pathSegment.absoluteXFloat = newX;
            pathSegment.absoluteYFloat = newY;
        }
        else if (pathSegment.pathCommand == 'm')
        {
            pathSegment.absoluteXFloat = pathSegment.absoluteStartXFloat + newX;
            pathSegment.absoluteYFloat = pathSegment.absoluteStartYFloat + newX;
        }

        NSUInteger pathSegmentCount = (self.pathSegmentsArray).count;
        if (self.pathSegmentIndex < (pathSegmentCount - 1))
        {
            PathSegment * nextPathSegment =
                    (self.pathSegmentsArray)[(self.pathSegmentIndex + 1)];

            unichar nextPathCommand = nextPathSegment.pathCommand;
        
            //if ((nextPathCommand == 'C') || (nextPathCommand == 'c'))
            if (nextPathCommand == 'C')
            {
                // modify control point in next segment for curve continuity
                NSString * existingX1String = nextPathSegment.x1String;     // next control point x
                NSString * existingY1String = nextPathSegment.y1String;     // next control point y
                
                float existingX1 = existingX1String.floatValue;
                float existingY1 = existingY1String.floatValue;

                float newX1 = existingX1 + deltaX;
                float newY1 = existingY1 + deltaY;

                nextPathSegment.x1Float = newX1;
                nextPathSegment.y1Float = newY1;
            }
        }
    }
    
    //NSLog(@"pathSegment = %@", pathSegment);
}

//==================================================================================
//	editPathSegmentLineto:
//==================================================================================

-(void) editPathSegmentLineto:(PathSegment *)pathSegment
{
    unichar commandCharacter = pathSegment.pathCommand;

    float existingAbsoluteStartX = pathSegment.absoluteStartXFloat;
    float existingAbsoluteStartY = pathSegment.absoluteStartYFloat;
    float existingAbsoluteX = pathSegment.absoluteXFloat;
    float existingAbsoluteY = pathSegment.absoluteYFloat;
    
    NSPoint  transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;
    float deltaX = transformedCurrentMousePoint.x - existingAbsoluteX;
    float deltaY = transformedCurrentMousePoint.y - existingAbsoluteY;

    if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
    {
        float newAbsoluteX = existingAbsoluteX + deltaX;
        float newAbsoluteY = existingAbsoluteY + deltaY;

        pathSegment.absoluteXFloat = newAbsoluteX;
        pathSegment.absoluteYFloat = newAbsoluteY;
                        
        if (commandCharacter == 'L')
        {
            pathSegment.xFloat = newAbsoluteX;
            pathSegment.yFloat = newAbsoluteY;
        }
        else if (commandCharacter == 'l')
        {
            float newX = newAbsoluteX - existingAbsoluteStartX;
            float newY = newAbsoluteY - existingAbsoluteStartY;
            
            pathSegment.xFloat = newX;
            pathSegment.yFloat = newY;
        }
    }
}

//==================================================================================
//	editPathSegmentHorizontal:
//==================================================================================

-(void) editPathSegmentHorizontal:(PathSegment *)pathSegment
{
    unichar commandCharacter = pathSegment.pathCommand;

    float existingAbsoluteStartX = pathSegment.absoluteStartXFloat;
    float existingAbsoluteX = pathSegment.absoluteXFloat;
    
    NSPoint  transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;
    float deltaX = transformedCurrentMousePoint.x - existingAbsoluteX;

    if ([self.pathEditingKey isEqualToString:@"x"] == YES)
    {
        float newAbsoluteX = existingAbsoluteX + deltaX;

        pathSegment.absoluteXFloat = newAbsoluteX;
                        
        if (commandCharacter == 'H')
        {
            pathSegment.xFloat = newAbsoluteX;
        }
        else if (commandCharacter == 'h')
        {
            float newX = newAbsoluteX - existingAbsoluteStartX;
            
            pathSegment.xFloat = newX;
        }
    }
}

//==================================================================================
//	editPathSegmentVertical:
//==================================================================================

-(void) editPathSegmentVertical:(PathSegment *)pathSegment
{
    unichar commandCharacter = pathSegment.pathCommand;

    float existingAbsoluteStartY = pathSegment.absoluteStartYFloat;
    float existingAbsoluteY = pathSegment.absoluteYFloat;
    
    NSPoint  transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;
    float deltaY = transformedCurrentMousePoint.y - existingAbsoluteY;

    if ([self.pathEditingKey isEqualToString:@"y"] == YES)
    {
        float newAbsoluteY = existingAbsoluteY + deltaY;

        pathSegment.absoluteYFloat = newAbsoluteY;
                        
        if (commandCharacter == 'V')
        {
            pathSegment.yFloat = newAbsoluteY;
        }
        else if (commandCharacter == 'v')
        {
            float newY = newAbsoluteY - existingAbsoluteStartY;
            
            pathSegment.yFloat = newY;
        }
    }
}

//==================================================================================
//	editPathSegmentCubicCurve:
//==================================================================================

-(void) editPathSegmentCubicCurve:(PathSegment *)pathSegment
{
    unichar commandCharacter = pathSegment.pathCommand;

    float existingAbsoluteStartX = pathSegment.absoluteStartXFloat;
    float existingAbsoluteStartY = pathSegment.absoluteStartYFloat;
    float existingAbsoluteX = pathSegment.absoluteXFloat;
    float existingAbsoluteY = pathSegment.absoluteYFloat;
    float existingAbsoluteX2 = pathSegment.absoluteX2Float;
    float existingAbsoluteY2 = pathSegment.absoluteY2Float;
    
    NSPoint  transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;
    float deltaX = transformedCurrentMousePoint.x - existingAbsoluteX;
    float deltaY = transformedCurrentMousePoint.y - existingAbsoluteY;

    NSUInteger pathSegmentCount = self.pathSegmentsArray.count;
    
    if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
    {
        float newAbsoluteX = existingAbsoluteX + deltaX;
        float newAbsoluteY = existingAbsoluteY + deltaY;
        float newAbsoluteX2 = existingAbsoluteX2 + deltaX;
        float newAbsoluteY2 = existingAbsoluteY2 + deltaY;

        pathSegment.absoluteXFloat = newAbsoluteX;
        pathSegment.absoluteYFloat = newAbsoluteY;
                        
        pathSegment.absoluteX2Float = newAbsoluteX2;
        pathSegment.absoluteY2Float = newAbsoluteY2;
        
        if (commandCharacter == 'C')
        {
            pathSegment.xFloat = newAbsoluteX;
            pathSegment.yFloat = newAbsoluteY;

            pathSegment.x2Float = newAbsoluteX2;
            pathSegment.y2Float = newAbsoluteY2;
        }
        else if (commandCharacter == 'c')
        {
            float newX = newAbsoluteX - existingAbsoluteStartX;
            float newY = newAbsoluteY - existingAbsoluteStartY;
            
            pathSegment.xFloat = newX;
            pathSegment.yFloat = newY;
            
            float newX2 = newAbsoluteX2 - existingAbsoluteStartX;
            float newY2 = newAbsoluteY2 - existingAbsoluteStartY;
            
            pathSegment.x2Float = newX2;
            pathSegment.y2Float = newY2;
        }
    }
    else if ([self.pathEditingKey isEqualToString:@"x1y1"] == YES)
    {
        float newAbsoluteX1 = transformedCurrentMousePoint.x;
        float newAbsoluteY1 = transformedCurrentMousePoint.y;
        
        pathSegment.absoluteX1Float = newAbsoluteX1;
        pathSegment.absoluteY1Float = newAbsoluteY1;

        if (commandCharacter == 'C')
        {
            pathSegment.x1Float = newAbsoluteX1;
            pathSegment.y1Float = newAbsoluteY1;
        }
        else if (commandCharacter == 'c')
        {
            float newX1 = existingAbsoluteX - existingAbsoluteStartX + deltaX;
            float newY1 = existingAbsoluteY - existingAbsoluteStartY + deltaY;

            pathSegment.x1Float = newX1;
            pathSegment.y1Float = newY1;
        }
    }
    else if ([self.pathEditingKey isEqualToString:@"x2y2"] == YES)
    {
        float newAbsoluteX2 = transformedCurrentMousePoint.x;
        float newAbsoluteY2 = transformedCurrentMousePoint.y;

        if (self.editingMode == kPathEditingModeNextSegment)
        {
            float prevDeltaX = transformedCurrentMousePoint.x - existingAbsoluteX;
            float prevDeltaY = transformedCurrentMousePoint.y - existingAbsoluteY;
            newAbsoluteX2 = existingAbsoluteX - prevDeltaX;
            newAbsoluteY2 = existingAbsoluteY - prevDeltaY;
        }
    
        pathSegment.absoluteX2Float = newAbsoluteX2;
        pathSegment.absoluteY2Float = newAbsoluteY2;

        if (commandCharacter == 'C')
        {
            pathSegment.x2Float = newAbsoluteX2;
            pathSegment.y2Float = newAbsoluteY2;
        }
        else if (commandCharacter == 'c')
        {
            float newX2 = newAbsoluteX2 - existingAbsoluteStartX;
            float newY2 = newAbsoluteY2 - existingAbsoluteStartY;

            pathSegment.x2Float = newX2;
            pathSegment.y2Float = newY2;
        }

        // reflect control point in next segment for curve continuity
        if (self.curveSegmentContinuity == YES)
        {
            if (self.pathSegmentIndex < (pathSegmentCount - 1))
            {
                PathSegment * nextPathSegment =
                        (self.pathSegmentsArray)[(self.pathSegmentIndex + 1)];

                unichar nextPathCommand = nextPathSegment.pathCommand;

                float handleDeltaX = existingAbsoluteX - newAbsoluteX2;
                float handleDeltaY = existingAbsoluteY - newAbsoluteY2;
            
                float newAbsoluteX1 = existingAbsoluteX + handleDeltaX;
                float newAbsoluteY1 = existingAbsoluteY + handleDeltaY;

                nextPathSegment.absoluteX1Float = newAbsoluteX1;
                nextPathSegment.absoluteY1Float = newAbsoluteY1;

                if (nextPathCommand == 'C')
                {
                    nextPathSegment.x1Float = newAbsoluteX1;
                    nextPathSegment.y1Float = newAbsoluteY1;
                }
                else if (nextPathCommand == 'c')
                {
                    float newX1 = newAbsoluteX1 - existingAbsoluteX;
                    float newY1 = newAbsoluteY1 - existingAbsoluteY;
                    
                    nextPathSegment.x1Float = newX1;
                    nextPathSegment.y1Float = newY1;
                }
            }
        }
    }
    else if ([self.pathEditingKey isEqualToString:@"x0y0"] == YES)
    {
        // clicked on reflected handle of x1, y1
        float newAbsoluteX1 = transformedCurrentMousePoint.x;
        float newAbsoluteY1 = transformedCurrentMousePoint.y;
        
        NSPoint previousSegmentPoint = NSMakePoint(0, 0);
        if (self.pathSegmentIndex > 0)
        {
            previousSegmentPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
        }
    
        float prevDeltaX = previousSegmentPoint.x - transformedCurrentMousePoint.x;
        float prevDeltaY = previousSegmentPoint.y - transformedCurrentMousePoint.y;
        
        newAbsoluteX1 = previousSegmentPoint.x + prevDeltaX;
        newAbsoluteY1 = previousSegmentPoint.y + prevDeltaY;
        
        pathSegment.absoluteX1Float = newAbsoluteX1;
        pathSegment.absoluteY1Float = newAbsoluteY1;

        if (commandCharacter == 'C')
        {
            pathSegment.x1Float = newAbsoluteX1;
            pathSegment.y1Float = newAbsoluteY1;
        }
        else if (commandCharacter == 'c')
        {
            float newX1 = newAbsoluteX1 - existingAbsoluteStartX;
            float newY1 = newAbsoluteY1 - existingAbsoluteStartY;
            
            pathSegment.x1Float = newX1;
            pathSegment.y1Float = newY1;
        }

    }
    else if ([self.pathEditingKey isEqualToString:@"x3y3"] == YES)
    {
        // clicked on reflected handle of x2, y2 in next path segment

        float newAbsoluteX2 = transformedCurrentMousePoint.x;
        float newAbsoluteY2 = transformedCurrentMousePoint.y;

        float prevDeltaX = transformedCurrentMousePoint.x - existingAbsoluteX;
        float prevDeltaY = transformedCurrentMousePoint.y - existingAbsoluteY;
        
        newAbsoluteX2 = existingAbsoluteX - prevDeltaX;
        newAbsoluteY2 = existingAbsoluteY - prevDeltaY;
    
        pathSegment.absoluteX2Float = newAbsoluteX2;
        pathSegment.absoluteY2Float = newAbsoluteY2;

        if (commandCharacter == 'C')
        {
            pathSegment.x2Float = newAbsoluteX2;
            pathSegment.y2Float = newAbsoluteY2;
        }
        else if (commandCharacter == 'c')
        {
            pathSegment.x2Float = newAbsoluteX2 - existingAbsoluteStartX;
            pathSegment.y2Float = newAbsoluteY2 - existingAbsoluteStartY;
        }
    }
}

//==================================================================================
//	editPathSegmentSmoothCubicCurve:
//==================================================================================

-(void) editPathSegmentSmoothCubicCurve:(PathSegment *)pathSegment
{
    unichar commandCharacter = pathSegment.pathCommand;

    float existingAbsoluteStartX = pathSegment.absoluteStartXFloat;
    float existingAbsoluteStartY = pathSegment.absoluteStartYFloat;
    float existingAbsoluteX = pathSegment.absoluteXFloat;
    float existingAbsoluteY = pathSegment.absoluteYFloat;
    float existingAbsoluteX2 = pathSegment.absoluteX2Float;
    float existingAbsoluteY2 = pathSegment.absoluteY2Float;
    
    NSPoint  transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;
    float deltaX = transformedCurrentMousePoint.x - existingAbsoluteX;
    float deltaY = transformedCurrentMousePoint.y - existingAbsoluteY;

    NSUInteger pathSegmentCount = self.pathSegmentsArray.count;
    
    if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
    {
        float newAbsoluteX = existingAbsoluteX + deltaX;
        float newAbsoluteY = existingAbsoluteY + deltaY;
        float newAbsoluteX2 = existingAbsoluteX2 + deltaX;
        float newAbsoluteY2 = existingAbsoluteY2 + deltaY;

        pathSegment.absoluteXFloat = newAbsoluteX;
        pathSegment.absoluteYFloat = newAbsoluteY;
                        
        pathSegment.absoluteX2Float = newAbsoluteX2;
        pathSegment.absoluteY2Float = newAbsoluteY2;
        
        if (commandCharacter == 'S')
        {
            pathSegment.xFloat = newAbsoluteX;
            pathSegment.yFloat = newAbsoluteY;

            pathSegment.x2Float = newAbsoluteX2;
            pathSegment.y2Float = newAbsoluteY2;
        }
        else if (commandCharacter == 's')
        {
            float newX = newAbsoluteX - existingAbsoluteStartX;
            float newY = newAbsoluteY - existingAbsoluteStartY;
            
            pathSegment.xFloat = newX;
            pathSegment.yFloat = newY;
            
            float newX2 = newAbsoluteX2 - existingAbsoluteStartX;
            float newY2 = newAbsoluteY2 - existingAbsoluteStartY;
            
            pathSegment.x2Float = newX2;
            pathSegment.y2Float = newY2;
        }
    }
    else if ([self.pathEditingKey isEqualToString:@"x2y2"] == YES)
    {
        float newAbsoluteX2 = transformedCurrentMousePoint.x;
        float newAbsoluteY2 = transformedCurrentMousePoint.y;

        if (self.editingMode == kPathEditingModeNextSegment)
        {
            float prevDeltaX = transformedCurrentMousePoint.x - existingAbsoluteX;
            float prevDeltaY = transformedCurrentMousePoint.y - existingAbsoluteY;
            newAbsoluteX2 = existingAbsoluteX - prevDeltaX;
            newAbsoluteY2 = existingAbsoluteY - prevDeltaY;
        }
    
        pathSegment.absoluteX2Float = newAbsoluteX2;
        pathSegment.absoluteY2Float = newAbsoluteY2;

        if (commandCharacter == 'S')
        {
            pathSegment.x2Float = newAbsoluteX2;
            pathSegment.y2Float = newAbsoluteY2;
        }
        else if (commandCharacter == 's')
        {
            float newX2 = newAbsoluteX2 - existingAbsoluteStartX;
            float newY2 = newAbsoluteY2 - existingAbsoluteStartY;

            pathSegment.x2Float = newX2;
            pathSegment.y2Float = newY2;
        }

        // reflect control point in next segment for curve continuity
        if (self.curveSegmentContinuity == YES)
        {
            if (self.pathSegmentIndex < (pathSegmentCount - 1))
            {
                PathSegment * nextPathSegment =
                        (self.pathSegmentsArray)[(self.pathSegmentIndex + 1)];

                unichar nextPathCommand = nextPathSegment.pathCommand;

                float handleDeltaX = existingAbsoluteX - newAbsoluteX2;
                float handleDeltaY = existingAbsoluteY - newAbsoluteY2;
            
                float newAbsoluteX1 = existingAbsoluteX + handleDeltaX;
                float newAbsoluteY1 = existingAbsoluteY + handleDeltaY;

                nextPathSegment.absoluteX1Float = newAbsoluteX1;
                nextPathSegment.absoluteY1Float = newAbsoluteY1;

                if (nextPathCommand == 'S')
                {
                    nextPathSegment.x1Float = newAbsoluteX1;
                    nextPathSegment.y1Float = newAbsoluteY1;
                }
                else if (nextPathCommand == 's')
                {
                    float newX1 = newAbsoluteX1 - existingAbsoluteX;
                    float newY1 = newAbsoluteY1 - existingAbsoluteY;
                    
                    nextPathSegment.x1Float = newX1;
                    nextPathSegment.y1Float = newY1;
                }
            }
        }
    }
}

//==================================================================================
//	editPathSegmentQuadraticCurve:
//==================================================================================

-(void) editPathSegmentQuadraticCurve:(PathSegment *)pathSegment
{
    unichar commandCharacter = pathSegment.pathCommand;

    float existingAbsoluteStartX = pathSegment.absoluteStartXFloat;
    float existingAbsoluteStartY = pathSegment.absoluteStartYFloat;
    float existingAbsoluteX = pathSegment.absoluteXFloat;
    float existingAbsoluteY = pathSegment.absoluteYFloat;
    
    NSPoint  transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;
    float deltaX = transformedCurrentMousePoint.x - existingAbsoluteX;
    float deltaY = transformedCurrentMousePoint.y - existingAbsoluteY;

    if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
    {
        float newAbsoluteX = existingAbsoluteX + deltaX;
        float newAbsoluteY = existingAbsoluteY + deltaY;

        pathSegment.absoluteXFloat = newAbsoluteX;
        pathSegment.absoluteYFloat = newAbsoluteY;
                                
        if (commandCharacter == 'Q')
        {
            pathSegment.xFloat = newAbsoluteX;
            pathSegment.yFloat = newAbsoluteY;
        }
        else if (commandCharacter == 'q')
        {
            float newX = newAbsoluteX - existingAbsoluteStartX;
            float newY = newAbsoluteY - existingAbsoluteStartY;
            
            pathSegment.xFloat = newX;
            pathSegment.yFloat = newY;
        }
    }
    else if ([self.pathEditingKey isEqualToString:@"x1y1"] == YES)
    {
        float newAbsoluteX1 = transformedCurrentMousePoint.x;
        float newAbsoluteY1 = transformedCurrentMousePoint.y;
        
        pathSegment.absoluteX1Float = newAbsoluteX1;
        pathSegment.absoluteY1Float = newAbsoluteY1;

        if (commandCharacter == 'Q')
        {
            pathSegment.x1Float = newAbsoluteX1;
            pathSegment.y1Float = newAbsoluteY1;
        }
        else if (commandCharacter == 'q')
        {
            float newX1 = existingAbsoluteX - existingAbsoluteStartX + deltaX;
            float newY1 = existingAbsoluteY - existingAbsoluteStartY + deltaY;

            pathSegment.x1Float = newX1;
            pathSegment.y1Float = newY1;
        }
    }
}

//==================================================================================
//	editPathSegmentSmoothQuadraticCurve:
//==================================================================================

-(void) editPathSegmentSmoothQuadraticCurve:(PathSegment *)pathSegment
{
    unichar commandCharacter = pathSegment.pathCommand;

    float existingAbsoluteStartX = pathSegment.absoluteStartXFloat;
    float existingAbsoluteStartY = pathSegment.absoluteStartYFloat;
    float existingAbsoluteX = pathSegment.absoluteXFloat;
    float existingAbsoluteY = pathSegment.absoluteYFloat;
    
    NSPoint  transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;
    float deltaX = transformedCurrentMousePoint.x - existingAbsoluteX;
    float deltaY = transformedCurrentMousePoint.y - existingAbsoluteY;

    if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
    {
        float newAbsoluteX = existingAbsoluteX + deltaX;
        float newAbsoluteY = existingAbsoluteY + deltaY;

        pathSegment.absoluteXFloat = newAbsoluteX;
        pathSegment.absoluteYFloat = newAbsoluteY;
                                
        if (commandCharacter == 'T')
        {
            pathSegment.xFloat = newAbsoluteX;
            pathSegment.yFloat = newAbsoluteY;
        }
        else if (commandCharacter == 't')
        {
            float newX = newAbsoluteX - existingAbsoluteStartX;
            float newY = newAbsoluteY - existingAbsoluteStartY;
            
            pathSegment.xFloat = newX;
            pathSegment.yFloat = newY;
        }
    }
}

//==================================================================================
//	editPathSegmentEllipticalArc:
//==================================================================================

-(void) editPathSegmentEllipticalArc:(PathSegment *)pathSegment
{
    unichar commandCharacter = pathSegment.pathCommand;

    float existingAbsoluteStartX = pathSegment.absoluteStartXFloat;
    float existingAbsoluteStartY = pathSegment.absoluteStartYFloat;
    float existingAbsoluteX = pathSegment.absoluteXFloat;
    float existingAbsoluteY = pathSegment.absoluteYFloat;
    
    NSPoint  transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;
    float deltaX = transformedCurrentMousePoint.x - existingAbsoluteX;
    float deltaY = transformedCurrentMousePoint.y - existingAbsoluteY;

    if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
    {
        float newAbsoluteX = existingAbsoluteX + deltaX;
        float newAbsoluteY = existingAbsoluteY + deltaY;

        pathSegment.absoluteXFloat = newAbsoluteX;
        pathSegment.absoluteYFloat = newAbsoluteY;
                                
        if (commandCharacter == 'A')
        {
            pathSegment.xFloat = newAbsoluteX;
            pathSegment.yFloat = newAbsoluteY;
        }
        else if (commandCharacter == 'a')
        {
            float newX = newAbsoluteX - existingAbsoluteStartX;
            float newY = newAbsoluteY - existingAbsoluteStartY;
            
            pathSegment.xFloat = newX;
            pathSegment.yFloat = newY;
        }
    }

}


//==================================================================================
//	editPath
//==================================================================================

- (void)editPath
{
    //NSLog(@"editPath");       // mousedown move event, i.e., dragging an endpoint or control point

    NSInteger pathSegmentCount = (self.pathSegmentsArray).count;
    
    if (self.pathSegmentIndex >= 0)
    {
        if (self.pathSegmentIndex < pathSegmentCount)
        {
            PathSegment * pathSegment = (self.pathSegmentsArray)[self.pathSegmentIndex];
            
            PathSegment * originalPathSegment = [[PathSegment alloc] init];
            [originalPathSegment copyValuesFromPathSegment:pathSegment];
            
            unichar pathCommand = pathSegment.pathCommand;

            switch (pathCommand)
            {
                case 'M':     // moveto absolute
                {
                    [self editPathSegmentMoveto:pathSegment];
                    break;
                }
                case 'm':     // moveto relative
                {
                    [self editPathSegmentMoveto:pathSegment];
                    break;
                }
                case 'L':     // lineto absolute
                {
                    [self editPathSegmentLineto:pathSegment];
                    break;
                }
                case 'l':     // lineto relative
                {
                    [self editPathSegmentLineto:pathSegment];
                    break;
                }
                case 'H':     // horizontal lineto absolute
                {
                    [self editPathSegmentHorizontal:pathSegment];
                    break;
                }
                case 'h':     // horizontal lineto relative
                {
                    [self editPathSegmentHorizontal:pathSegment];
                    break;
                }
                case 'V':     // vertical lineto absolute
                {
                    [self editPathSegmentVertical:pathSegment];
                    break;
                }
                case 'v':     // vertical lineto relative
                {
                    [self editPathSegmentVertical:pathSegment];
                    break;
                }
                case 'C':     // cubic curveto absolute
                {
                    [self editPathSegmentCubicCurve:pathSegment];
                    break;
                }
                case 'c':     // cubic curveto relative
                {
                    [self editPathSegmentCubicCurve:pathSegment];
                    break;
                }
                case 'S':     // smooth cubic curveto absolute
                {
                    [self editPathSegmentSmoothCubicCurve:pathSegment];
                    break;
                }
                case 's':     // smooth cubic curveto relative
                {
                    [self editPathSegmentSmoothCubicCurve:pathSegment];
                    break;
                }
                case 'Q':     // quadratic curveto absolute
                {
                    [self editPathSegmentQuadraticCurve:pathSegment];
                    break;
                }
                case 'q':     // quadratic curveto relative
                {
                    [self editPathSegmentQuadraticCurve:pathSegment];
                    break;
                }
                case 'T':     // smooth quadratic curveto absolute
                {
                    [self editPathSegmentSmoothQuadraticCurve:pathSegment];
                    break;
                }
                case 't':     // smooth quadratic curveto relative
                {
                    [self editPathSegmentSmoothQuadraticCurve:pathSegment];
                    break;
                }
                case 'A':     // elliptical arc absolute
                {
                    [self editPathSegmentEllipticalArc:pathSegment];
                    break;
                }
                case 'a':     // elliptical arc relative
                {
                    [self editPathSegmentEllipticalArc:pathSegment];
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

            if (self.pathSegmentIndex > 0)
            {
                // a previous path segment might contain x2, y2 parameters reflecting the current cubic curve's x1, y1
                [self fixPreviousPathSegment:pathSegment];
            }

            if (self.pathSegmentIndex < (self.pathSegmentsArray.count - 1))
            {
                // a next path segment might contain x2, y2 parameters reflecting the current cubic curve's x1, y1,
                // or might be a relative path segment that needs, say x and y adjusted to maintain the current absolute position
                [self fixNextPathSegment:pathSegment originalSegment:originalPathSegment];
            }
            
            [self fixClosedPathSegments:pathSegment originalPathSegment:originalPathSegment];

            //NSLog(@"pathSegmentIndex=%ld, pathEditingKey=%@", self.pathSegmentIndex, self.pathEditingKey);

            [self updatePathSegmentsAbsoluteValues:self.pathSegmentsArray];
            
            svgXMLDOMSelectionManager.activeXMLElement = self.selectedPathElement;
            
            [self updateActivePathInDOM:YES];
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
//	fixPreviousPathSegment:
//==================================================================================

- (void)fixPreviousPathSegment:(PathSegment *)currentPathSegment
{
    // a previous path segment might contain x2, y2 parameters reflecting a current segment cubic curve's x1, y1

    if (self.pathSegmentIndex > 0)
    {
        unichar currentSegmentCommandCharacter = currentPathSegment.pathCommand;

        PathSegment * previousPathSegment =
                (self.pathSegmentsArray)[(self.pathSegmentIndex - 1)];

        unichar previousSegmentCommandCharacter = previousPathSegment.pathCommand;

        //NSLog(@"previousSegment = %@", previousSegment);

        if ((currentSegmentCommandCharacter == 'C') || (currentSegmentCommandCharacter == 'c'))
        {
            if (self.curveSegmentContinuity == YES)
            {
                if ([self.pathEditingKey isEqualToString:@"x1y1"] == YES)
                {
                    // reflect x2,y2 control point in previous segment for curve continuity
                    NSPoint  transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;

                    float previousSegmentAbsoluteX = previousPathSegment.absoluteXFloat;     // endpoint x
                    float previousSegmentAbsoluteY = previousPathSegment.absoluteYFloat;     // endpoint y

                    float newAbsoluteX1 = transformedCurrentMousePoint.x;
                    float newAbsoluteY1 = transformedCurrentMousePoint.y;

                    float handleDeltaX = newAbsoluteX1 - previousSegmentAbsoluteX;
                    float handleDeltaY = newAbsoluteY1 - previousSegmentAbsoluteY;

                    float newAbsoluteX2 = previousSegmentAbsoluteX - handleDeltaX;
                    float newAbsoluteY2 = previousSegmentAbsoluteY - handleDeltaY;

                    previousPathSegment.absoluteX2Float = newAbsoluteX2;
                    previousPathSegment.absoluteY2Float = newAbsoluteY2;

                    if (previousSegmentCommandCharacter == 'C')
                    {
                        previousPathSegment.x2Float = newAbsoluteX2;
                        previousPathSegment.y2Float = newAbsoluteY2;
                    }
                    else if (previousSegmentCommandCharacter == 'c')
                    {
                        previousPathSegment.x2Float = previousSegmentAbsoluteX - previousPathSegment.absoluteStartXFloat - handleDeltaX;
                        previousPathSegment.y2Float = previousSegmentAbsoluteY - previousPathSegment.absoluteStartYFloat - handleDeltaY;
                    }
                }
            }
        }
        else if ((previousSegmentCommandCharacter != 'C') && (previousSegmentCommandCharacter != 'c'))
        {
            // Neither current nor previous segment are cubic curve, so previous segment
            // should not contain x2,y2 values
            
            previousPathSegment.x2Float = NAN;
            previousPathSegment.y2Float = NAN;
            previousPathSegment.absoluteX2Float = NAN;
            previousPathSegment.absoluteY2Float = NAN;
        }
    }
}

//==================================================================================
//	fixNextPathSegment:
//==================================================================================

- (void)fixNextPathSegment:(PathSegment *)currentPathSegment originalSegment:(PathSegment *)originalPathSegment
{
    // a next path segment might be a relative path segment that needs adjustment to stay at the current absolute position
    // or might contain x2, y2 parameters reflecting the current cubic curve's x1, y1

    if (self.pathSegmentIndex < self.pathSegmentsArray.count - 1)
    {
        unichar currentSegmentCommandCharacter = currentPathSegment.pathCommand;

        float originalPathSegmentAbsoluteXFloat = originalPathSegment.absoluteXFloat;
        float originalPathSegmentAbsoluteYFloat = originalPathSegment.absoluteYFloat;

        PathSegment * nextPathSegment =
                (self.pathSegmentsArray)[(self.pathSegmentIndex + 1)];

        unichar nextPathSegmentCommandCharacter = nextPathSegment.pathCommand;

        float nextPathSegmentAbsoluteX = nextPathSegment.absoluteXFloat;
        float nextPathSegmentAbsoluteY = nextPathSegment.absoluteYFloat;

        float nextPathSegmentX = nextPathSegment.xFloat;
        float nextPathSegmentY = nextPathSegment.yFloat;

        NSPoint  transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;
        float deltaX = transformedCurrentMousePoint.x - originalPathSegmentAbsoluteXFloat;
        float deltaY = transformedCurrentMousePoint.y - originalPathSegmentAbsoluteYFloat;

        if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
        {
            if ((nextPathSegmentCommandCharacter >= 'a') && (nextPathSegmentCommandCharacter <= 'z'))
            {
                // next path segment is relative to current segment
                switch (nextPathSegmentCommandCharacter)
                {
                    case 'm':     // moveto
                    case 'l':     // lineto
                    case 's':     // smooth curveto
                    case 'q':     // quadratic Bezier curve
                    case 't':     // smooth quadratic Bezier curve
                    case 'a':     // elliptical arc
                    {
                        float newNextPathSegmentX = nextPathSegmentX - deltaX;
                        float newNextPathSegmentY = nextPathSegmentY - deltaY;

                        nextPathSegment.xFloat = newNextPathSegmentX;
                        nextPathSegment.yFloat = newNextPathSegmentY;

                        break;
                    }
                    case 'c':     // curveto
                    {
                        float nextPathSegmentX2 = nextPathSegment.x2Float;
                        float nextPathSegmentY2 = nextPathSegment.y2Float;

                        float newNextPathSegmentX2 = nextPathSegmentX2 - deltaX;
                        float newNextPathSegmentY2 = nextPathSegmentY2 - deltaY;

                        nextPathSegment.x2Float = newNextPathSegmentX2;
                        nextPathSegment.y2Float = newNextPathSegmentY2;

                        float newNextPathSegmentX = nextPathSegmentX - deltaX;
                        float newNextPathSegmentY = nextPathSegmentY - deltaY;
                        
                        nextPathSegment.xFloat = newNextPathSegmentX;
                        nextPathSegment.yFloat = newNextPathSegmentY;

                        //NSLog(@"nextPathSegment = %@", nextPathSegment);

                        break;
                    }
                    case 'h':     // horizontal lineto
                    {
                        float newNextPathSegmentX = nextPathSegmentX + deltaX;
                        nextPathSegment.xFloat = newNextPathSegmentX;

                        break;
                    }
                    case 'v':     // vertical lineto
                    {
                        float newNextPathSegmentY = nextPathSegmentY + deltaY;
                        nextPathSegment.yFloat = newNextPathSegmentY;

                        break;
                    }
                }
            }
        }
        
        if ((currentSegmentCommandCharacter == 'C') || (currentSegmentCommandCharacter == 'c'))
        {
            if (self.curveSegmentContinuity == YES)
            {
                // adjust reflected control point in next segment for curve continuity
                if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
                {
                    float currentPathSegmentAbsoluteX = currentPathSegment.absoluteXFloat;
                    float currentPathSegmentAbsoluteY = currentPathSegment.absoluteYFloat;
                    float currentPathSegmentAbsoluteX2 = currentPathSegment.absoluteX2Float;
                    float currentPathSegmentAbsoluteY2 = currentPathSegment.absoluteY2Float;
                    
                    float handleDeltaX = currentPathSegmentAbsoluteX - currentPathSegmentAbsoluteX2;
                    float handleDeltaY = currentPathSegmentAbsoluteY - currentPathSegmentAbsoluteY2;

                    if (nextPathSegmentCommandCharacter == 'C')
                    {
                        float newAbsoluteX1 = originalPathSegmentAbsoluteXFloat + handleDeltaX;
                        float newAbsoluteY1 = originalPathSegmentAbsoluteYFloat + handleDeltaY;
                        
                        nextPathSegment.absoluteX1Float = newAbsoluteX1;
                        nextPathSegment.absoluteY1Float = newAbsoluteY1;

                        nextPathSegment.x1Float = newAbsoluteX1;
                        nextPathSegment.y1Float = newAbsoluteY1;
                    }
                }
                else if ([self.pathEditingKey isEqualToString:@"x2y2"] == YES)
                {
                    float currentPathSegmentAbsoluteX = currentPathSegment.absoluteXFloat;
                    float currentPathSegmentAbsoluteY = currentPathSegment.absoluteYFloat;
                    float currentPathSegmentAbsoluteX2 = currentPathSegment.absoluteX2Float;
                    float currentPathSegmentAbsoluteY2 = currentPathSegment.absoluteY2Float;
                    
                    float handleDeltaX = currentPathSegmentAbsoluteX - currentPathSegmentAbsoluteX2;
                    float handleDeltaY = currentPathSegmentAbsoluteY - currentPathSegmentAbsoluteY2;

                    if (nextPathSegmentCommandCharacter == 'C')
                    {
                        float newAbsoluteX1 = originalPathSegmentAbsoluteXFloat + handleDeltaX;
                        float newAbsoluteY1 = originalPathSegmentAbsoluteYFloat + handleDeltaY;
                        
                        nextPathSegment.absoluteX1Float = newAbsoluteX1;
                        nextPathSegment.absoluteY1Float = newAbsoluteY1;

                        nextPathSegment.x1Float = newAbsoluteX1;
                        nextPathSegment.y1Float = newAbsoluteY1;
                    }
                    else if (nextPathSegmentCommandCharacter == 'c')
                    {
                        float nextPathSegmentAbsoluteX1 = nextPathSegment.absoluteX1Float;
                        float nextPathSegmentAbsoluteY1 = nextPathSegment.absoluteY1Float;

                        float newNextPathSegmentAbsoluteX1 = nextPathSegmentAbsoluteX1 + deltaX;
                        float newNextPathSegmentAbsoluteY1 = nextPathSegmentAbsoluteY1 + deltaY;

                        nextPathSegment.absoluteX1Float = newNextPathSegmentAbsoluteX1;
                        nextPathSegment.absoluteY1Float = newNextPathSegmentAbsoluteY1;
                    }
                    else
                    {
                    
                    }
                }
            }
        }
    }
}

//==================================================================================
//	fixClosedPathSegments:
//==================================================================================

- (void)fixClosedPathSegments:(PathSegment *)currentPathSegment originalPathSegment:(PathSegment *)originalPathSegment
{
    // For closed paths, modify joining segments
    CGEventRef event = CGEventCreate(NULL);
    CGEventFlags modifiers = CGEventGetFlags(event);
    CFRelease(event);
    //CGEventFlags flags = (kCGEventFlagMaskShift | kCGEventFlagMaskCommand);
    CGEventFlags flags = (kCGEventFlagMaskAlternate);   // check for option key
    if ((modifiers & flags) == 0)
    {
        // option key not pressed

        NSInteger pathSegmentCount = (self.pathSegmentsArray).count;

        // search for a matching segment point
        //NSNumber * originalAbsoluteXNumber = originalPathSegment.absoluteX;
        //NSNumber * originalAbsoluteYNumber = originalPathSegment.absoluteY;
        
        float originalAbsoluteX = originalPathSegment.absoluteXFloat;
        float originalAbsoluteY = originalPathSegment.absoluteYFloat;
        
        for (NSInteger i = 0; i < pathSegmentCount; i++)
        {
            if (i != self.pathSegmentIndex) // don't check current segment, only other segments
            {
                PathSegment * aPathSegment = (self.pathSegmentsArray)[i];
                
                unichar aPathCommand = aPathSegment.pathCommand;
                
                switch (aPathCommand)
                {
                    case 'M':     // moveto absolute
                    {
                        if ([self.pathEditingKey isEqualToString:@"xy"] == YES)
                        {
                            //NSNumber * absoluteXNumber = aPathSegment.absoluteX;
                            //NSNumber * absoluteYNumber = aPathSegment.absoluteY;

                            float absoluteX = aPathSegment.absoluteXFloat;
                            float absoluteY = aPathSegment.absoluteYFloat;

                            if ((originalAbsoluteX == absoluteX) &&
                                    (originalAbsoluteY == absoluteY))
                            {
                                // modify this Moveto found in a different segment within the path,
                                // this can preserve a smooth closed path, typically between the last cubic segment
                                // and the first segment, but this seems to work for subpath matches too.
                                NSInteger tempPathSegmentIndex = self.pathSegmentIndex;
                                self.pathSegmentIndex = i;
                                [self editPathSegmentMoveto:aPathSegment];
                                self.pathSegmentIndex = tempPathSegmentIndex;
     
                                [self updatePathSegmentsAbsoluteValues:self.pathSegmentsArray];
                            }
                        }

                        break;
                    }
                    case 'm':     // moveto relative
                    case 'L':     // lineto absolute
                    case 'l':     // lineto relative
                    case 'H':     // horizontal lineto absolute
                    case 'h':     // horizontal lineto relative
                    case 'V':     // vertical lineto absolute
                    case 'v':     // vertical lineto relative
                        break;
                    case 'C':     // cubic curveto absolute
                    {
                        if ([self.pathEditingKey isEqualToString:@"x1y1"] == YES)
                        {
                            if (i != self.pathSegmentIndex - 1) // don't check previous segment, it is already adjusted
                            {
                                //NSNumber * absoluteX2Number = aPathSegment.absoluteX2;
                                //NSNumber * absoluteY2Number = aPathSegment.absoluteY2;
                                //NSNumber * absoluteXNumber = aPathSegment.absoluteX;
                                //NSNumber * absoluteYNumber = aPathSegment.absoluteY;

                                float absoluteX2 = aPathSegment.absoluteX2Float;
                                float absoluteY2 = aPathSegment.absoluteY2Float;
                                float absoluteX = aPathSegment.absoluteXFloat;
                                float absoluteY = aPathSegment.absoluteYFloat;
                                
                                float reflectX2 = absoluteX - (absoluteX2 - absoluteX);
                                float reflectY2 = absoluteY - (absoluteY2 - absoluteY);

                                float originalAbsoluteX1 = originalPathSegment.absoluteX1Float;
                                float originalAbsoluteY1 = originalPathSegment.absoluteY1Float;
                                
                                if ((originalAbsoluteX1 == reflectX2) &&
                                        (originalAbsoluteY1 == reflectY2))
                                {
                                    // reflect x1y1 from current cubic curve found to x2y2 in previous segment.
                                    NSInteger tempPathSegmentIndex = self.pathSegmentIndex;
                                    NSString * tempPathEditingKey = self.pathEditingKey;
                                    self.pathEditingKey = @"x3y3";
                                    self.pathSegmentIndex = i;
                                    [self editPathSegmentCubicCurve:aPathSegment];
                                    self.pathEditingKey = tempPathEditingKey;
                                    self.pathSegmentIndex = tempPathSegmentIndex;
         
                                    [self updatePathSegmentsAbsoluteValues:self.pathSegmentsArray];
                                }
                            }
                        }
                        else if ([self.pathEditingKey isEqualToString:@"x2y2"] == YES)
                        {
                            if (i != self.pathSegmentIndex + 1) // don't check next segment, it is already adjusted
                            {
                                float absoluteX1 = aPathSegment.absoluteX1Float;
                                float absoluteY1 = aPathSegment.absoluteY1Float;
                                float absoluteStartX = aPathSegment.absoluteStartXFloat;
                                float absoluteStartY = aPathSegment.absoluteStartYFloat;

                                float reflectX1 = absoluteStartX - (absoluteX1 - absoluteStartX);
                                float reflectY1 = absoluteStartY - (absoluteY1 - absoluteStartY);

                                float originalAbsoluteX2 = originalPathSegment.absoluteX2Float;
                                float originalAbsoluteY2 = originalPathSegment.absoluteY2Float;
                                
                                if ((originalAbsoluteX2 == reflectX1) &&
                                        (originalAbsoluteY2 == reflectY1))
                                {
                                    // reflect x2y2 from current cubic curve found to x1y1 in a different segment.
                                    NSInteger tempPathSegmentIndex = self.pathSegmentIndex;
                                    NSString * tempPathEditingKey = self.pathEditingKey;
                                    self.pathEditingKey = @"x0y0";
                                    self.pathSegmentIndex = i;
                                    [self editPathSegmentCubicCurve:aPathSegment];
                                    self.pathEditingKey = tempPathEditingKey;
                                    self.pathSegmentIndex = tempPathSegmentIndex;
         
                                    [self updatePathSegmentsAbsoluteValues:self.pathSegmentsArray];
                                }
                            }
                        }

                        break;
                    }
                    case 'c':     // cubic curveto relative
                    case 'S':     // smooth cubic curveto absolute
                    case 's':     // smooth cubic curveto relative
                    case 'Q':     // quadratic curveto absolute
                    case 'q':     // quadratic curveto relative
                    case 'T':     // smooth quadratic curveto absolute
                    case 't':     // smooth quadratic curveto relative
                    case 'A':     // elliptical arc absolute
                    case 'a':     // elliptical arc relative
                    case 'Z':     // closepath absolute
                    case 'z':     // closepath
                        break;
                }
            }
        }
    }
}

//==================================================================================
//	handleMouseHoverEventForPath:
//==================================================================================

-(void) handleMouseHoverEventForPath:(DOMEvent *)event
{
    //NSLog(@"handleMouseHoverEventForPath");       // mouse hovering event

    NSString * selectedPathMode = macSVGDocumentWindowController.selectedPathMode;

    if ([selectedPathMode isEqualToString:@"Freestyle Path"] == YES)
    {
        // nothing to do
    }
    else
    {
        if (self.pathSegmentIndex > 0) 
        {
            PathSegment * pathSegment = (self.pathSegmentsArray)[self.pathSegmentIndex];
            unichar pathCommand = pathSegment.pathCommand;

            NSPoint  transformedCurrentMousePoint = domMouseEventsController.transformedCurrentMousePagePoint;

            switch (pathCommand) 
            {
                case 'M':     // moveto absolute
                {
                    float newX = transformedCurrentMousePoint.x;
                    float newY = transformedCurrentMousePoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;

                    break;
                }
                case 'm':     // moveto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    float newY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;
                    
                    break;
                }
                case 'L':     // lineto absolute
                {
                    float newX = transformedCurrentMousePoint.x;
                    float newY = transformedCurrentMousePoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;

                    break;
                }
                case 'l':     // lineto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    float newY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;

                    break;
                }
                case 'H':     // horizontal lineto absolute
                {
                    float newX = transformedCurrentMousePoint.x;
                    
                    NSString * newXString = [self allocFloatString:newX];

                    pathSegment.xString = newXString;

                    break;
                }
                case 'h':     // horizontal lineto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    
                    NSString * newXString = [self allocFloatString:newX];

                    pathSegment.xString = newXString;

                    break;
                }
                case 'V':     // vertical lineto absolute
                {
                    float newY = transformedCurrentMousePoint.y;
                    
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.yString = newYString;

                    break;
                }
                case 'v':     // vertical lineto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.yString = newYString;

                    break;
                }
                case 'C':     // curveto absolute
                {
                    float newX = transformedCurrentMousePoint.x;
                    float newY = transformedCurrentMousePoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.x2String = newXString;
                    pathSegment.y2String = newYString;

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;
                    
                    break;
                }
                case 'c':     // curveto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    float newY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.x2String = newXString;
                    pathSegment.y2String = newYString;

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;
                    
                    break;
                }
                case 'S':     // smooth curveto absolute
                {
                    float newX = transformedCurrentMousePoint.x;
                    float newY = transformedCurrentMousePoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.x2String = newXString;
                    pathSegment.y2String = newYString;

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;

                    break;
                }
                case 's':     // smooth curveto relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    float newY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.x2String = newXString;
                    pathSegment.y2String = newYString;

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;
                    
                    break;
                }
                case 'Q':     // quadratic Bezier curve absolute
                {
                    float newX = transformedCurrentMousePoint.x;
                    float newY = transformedCurrentMousePoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;

                    break;
                }
                case 'q':     // quadratic Bezier curve relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    float newY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.x1String = newXString;
                    pathSegment.y1String = newYString;

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;
                    
                    break;
                }
                case 'T':     // smooth quadratic Bezier curve absolute
                {
                    float newX = transformedCurrentMousePoint.x;
                    float newY = transformedCurrentMousePoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;

                    break;
                }
                case 't':     // smooth quadratic Bezier curve relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    float newY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;

                    break;
                }
                case 'A':     // elliptical arc absolute
                {
                    float newX = transformedCurrentMousePoint.x;
                    float newY = transformedCurrentMousePoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;

                    break;
                }
                case 'a':     // elliptical arc relative
                {
                    NSPoint currentPathPoint = [self absoluteXYPointAtPathSegmentIndex:(self.pathSegmentIndex - 1)];
                    
                    float newX = transformedCurrentMousePoint.x - currentPathPoint.x;
                    float newY = transformedCurrentMousePoint.y - currentPathPoint.y;
                    
                    NSString * newXString = [self allocFloatString:newX];
                    NSString * newYString = [self allocFloatString:newY];

                    pathSegment.xString = newXString;
                    pathSegment.yString = newYString;

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

    [self updateActivePathInDOM:YES];
    
    //NSLog(@"pathSegmentsArray - %@", self.pathSegmentsArray);
}

//==================================================================================
//	updatePathMode:
//==================================================================================

-(void) updatePathMode:(NSString *)newPathMode
{
    // mouse is in hover mode, replace the existing segment with a new segment for the new path mode
    NSUInteger pathSegmentsCount = (self.pathSegmentsArray).count;
    
    if (pathSegmentsCount > 1)
    {
        if (self.pathSegmentIndex > 1)
        {
            [self.pathSegmentsArray removeLastObject];
            self.pathSegmentIndex--;
            [self updateActivePathInDOM:YES];
        }
    }
    
    [self extendPath];
}

//==================================================================================
//	deleteLastSegmentInPath
//==================================================================================

-(void) deleteLastSegmentInPath
{
    NSUInteger pathSegmentsCount = (self.pathSegmentsArray).count;
    
    if (pathSegmentsCount > 1)
    {
        if (self.pathSegmentIndex > 1)
        {
            [self.pathSegmentsArray removeLastObject];
            self.pathSegmentIndex--;
            [self updateActivePathInDOM:YES];
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
    self.editingMode = kPathEditingModeNotActive;
    
    if (self.selectedPathElement != NULL)
    {
        if ((self.pathSegmentsArray).count > 0)
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
                    NSInteger newPathSegmentIndex = handleSegmentString.integerValue;
                    
                    self.editingMode = kPathEditingModeCurrentSegment;
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


#pragma clang diagnostic pop
