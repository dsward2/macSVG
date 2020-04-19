//
//  PathSegmentEditorPopoverViewController.m
//  PathElementEditor
//
//  Created by Douglas Ward on 7/13/16.
//
//

#import "PathSegmentEditorPopoverViewController.h"
#import "PathElementEditor.h"
#import "PathSegment.h"

#import <WebKit/WebKit.h>

@interface PathSegmentEditorPopoverViewController ()

@end

@implementation PathSegmentEditorPopoverViewController

- (void)dealloc
{
    self.applyButton = NULL;
    self.cancelButton = NULL;
}

//==================================================================================
//	segmentTypePopUpButtonAction:
//==================================================================================

- (IBAction)segmentTypePopUpButtonAction:(id)sender
{
    NSInteger selectedRow = (self.pathElementEditor.pathTableView).selectedRow;

    if (selectedRow >= 0)
    {
        PathSegment * pathSegment = (self.pathElementEditor.pathSegmentsArray)[selectedRow];
        
        PathSegment * newPathSegment = [[PathSegment alloc] init];
        [newPathSegment copyValuesFromPathSegment:pathSegment];
        
        NSInteger selectedSegmentTypeIndex = segmentTypePopUpButton.indexOfSelectedItem;
        
        unichar newCommand = pathSegment.pathCommand;
        
        BOOL useRelativeCoordinates = relativeCoordinatesCheckboxButton.state;
        
        switch (selectedSegmentTypeIndex)
        {
            case 0:
            {
                // Moveto
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'M';
                }
                else
                {
                    newCommand = 'm';
                }
                NSArray * validAttributes = @[@"x", @"y"];
                [self validateAttributes:validAttributes inPathSegment:newPathSegment];
                break;
            }
            case 1:
            {
                // Lineto
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'L';
                }
                else
                {
                    newCommand = 'l';
                }
                NSArray * validAttributes = @[@"x", @"y"];
                [self validateAttributes:validAttributes inPathSegment:newPathSegment];
                break;
            }
            case 2:
            {
                // Horizontal Lineto
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'H';
                }
                else
                {
                    newCommand = 'h';
                }
                NSArray * validAttributes = @[@"x"];
                [self validateAttributes:validAttributes inPathSegment:newPathSegment];
                break;
            }
            case 3:
            {
                // Vertical Lineto
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'V';
                }
                else
                {
                    newCommand = 'v';
                }
                NSArray * validAttributes = @[@"y"];
                [self validateAttributes:validAttributes inPathSegment:newPathSegment];
                break;
            }
            case 4:
            {
                // Cubic Curveto
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'C';
                }
                else
                {
                    newCommand = 'c';
                }
                NSArray * validAttributes = @[@"x", @"y", @"x1", @"y1", @"x2", @"y2"];
                [self validateAttributes:validAttributes inPathSegment:newPathSegment];
                break;
            }
            case 5:
            {
                // Cubic Curveto Smooth
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'S';
                }
                else
                {
                    newCommand = 's';
                }
                NSArray * validAttributes = @[@"x", @"y", @"x2", @"y2"];
                [self validateAttributes:validAttributes inPathSegment:newPathSegment];
                break;
            }
            case 6:
            {
                // Quadratic Curveto
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'Q';
                }
                else
                {
                    newCommand = 'q';
                }
                NSArray * validAttributes = @[@"x", @"y", @"x1", @"y1"];
                [self validateAttributes:validAttributes inPathSegment:newPathSegment];
                break;
            }
            case 7:
            {
                // Quadratic Curveto Smooth
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'T';
                }
                else
                {
                    newCommand = 't';
                }
                NSArray * validAttributes = @[@"x", @"y"];
                [self validateAttributes:validAttributes inPathSegment:newPathSegment];
                break;
            }
            case 8:
            {
                // Elliptical Arc
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'A';
                }
                else
                {
                    newCommand = 'a';
                }
                NSArray * validAttributes = @[@"x", @"y", @"rx", @"ry", @"x-axis-rotation", @"large-arc-flag", @"sweep-flag"];
                

                [self validateAttributes:validAttributes inPathSegment:newPathSegment];
                break;
            }
            case 9:
            {
                // Close Path
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'Z';
                }
                else
                {
                    newCommand = 'z';
                }
                break;
            }
        }
        
        newPathSegment.pathCommand = newCommand;
        
        [self loadPathSegmentData:newPathSegment];
    }
}

//==================================================================================
//	validateAttributes:inPathSegment:
//==================================================================================

- (void)validateAttributes:(NSArray *)validAttributesArray inPathSegment:(PathSegment *)pathSegment
{
    NSLog(@"FIXME:PathSegmentEditorPopoverViewController validAttributesArray:inPathSegment");

/*
    NSArray * allKeys = pathSegment.allKeys;
    
    for (NSString * aKey in allKeys)
    {
        //NSInteger attributeIndex = [validAttributesArray indexOfObjectIdenticalTo:aKey];
        
        BOOL commonKeyFound = NO;
        
        if ([aKey isEqualToString:@"absoluteStartX"] == YES)
        {
            commonKeyFound = YES;
        }
        else if ([aKey isEqualToString:@"absoluteStartY"] == YES)
        {
            commonKeyFound = YES;
        }
        else if ([aKey isEqualToString:@"absoluteX"] == YES)
        {
            commonKeyFound = YES;
        }
        else if ([aKey isEqualToString:@"absoluteX"] == YES)
        {
            commonKeyFound = YES;
        }
        else
        {
            for (NSString * aValidAttribute in validAttributesArray)
            {
                if ([aKey isEqualToString:aValidAttribute] == YES)
                {
                    commonKeyFound = YES;
                    break;
                }
            }
        }
        
        if (commonKeyFound == NO)
        {
            [pathSegment removeObjectForKey:aKey];
        }
    }
    
    for (NSString * aValidAttribute in validAttributesArray)
    {
        id existingAttribute = pathSegment[aValidAttribute];
        
        if (existingAttribute == NULL)
        {
            NSString * newAttributeValue = @"0";
            
            unichar firstAttributeCharacter = [aValidAttribute characterAtIndex:0];
            if (firstAttributeCharacter == 'x')
            {
                NSString * xString = pathSegment[@"x"];
                
                if (xString != NULL)
                {
                    newAttributeValue = xString;
                }
            }
            else if (firstAttributeCharacter == 'y')
            {
                NSString * yString = pathSegment[@"y"];
                
                if (yString != NULL)
                {
                    newAttributeValue = yString;
                }
            }
            
            pathSegment[aValidAttribute] = newAttributeValue;
        }
    }
    */
}

//==================================================================================
//	applyButtonAction
//==================================================================================

- (IBAction)applyButtonAction:(id)sender
{
    NSInteger selectedRow = (self.pathElementEditor.pathTableView).selectedRow;

    if (selectedRow >= 0)
    {
        PathSegment * pathSegment = (self.pathElementEditor.pathSegmentsArray)[selectedRow];
        
        PathSegment * newPathSegment = [[PathSegment alloc] init];
        
        NSInteger selectedSegmentTypeIndex = segmentTypePopUpButton.indexOfSelectedItem;
        
        unichar newCommand = pathSegment.pathCommand;
        
        BOOL useRelativeCoordinates = relativeCoordinatesCheckboxButton.state;
        
        switch (selectedSegmentTypeIndex)
        {
            case 0:
            {
                // Moveto
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'M';
                }
                else
                {
                    newCommand = 'm';
                }
                
                NSString * xString = textfield1.stringValue;
                NSString * yString = textfield2.stringValue;
                
                newPathSegment.pathCommand = newCommand;
                newPathSegment.xString = xString;
                newPathSegment.yString = yString;
                
                break;
            }
            case 1:
            {
                // Lineto
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'L';
                }
                else
                {
                    newCommand = 'l';
                }
                
                NSString * xString = textfield1.stringValue;
                NSString * yString = textfield2.stringValue;
                
                newPathSegment.pathCommand = newCommand;
                newPathSegment.xString = xString;
                newPathSegment.yString = yString;
                
                break;
            }
            case 2:
            {
                // Horizontal Lineto
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'H';
                }
                else
                {
                    newCommand = 'h';
                }
                
                NSString * xString = textfield1.stringValue;
                
                newPathSegment.pathCommand = newCommand;
                newPathSegment.xString = xString;
                
                break;
            }
            case 3:
            {
                // Vertical Lineto
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'V';
                }
                else
                {
                    newCommand = 'v';
                }
                
                NSString * yString = textfield2.stringValue;
                
                newPathSegment.pathCommand = newCommand;
                newPathSegment.yString = yString;
                
                break;
            }
            case 4:
            {
                // Cubic Curveto
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'C';
                }
                else
                {
                    newCommand = 'c';
                }
                
                NSString * x1String = textfield1.stringValue;
                NSString * y1String = textfield2.stringValue;
                NSString * x2String = textfield3.stringValue;
                NSString * y2String = textfield4.stringValue;
                NSString * xString = textfield5.stringValue;
                NSString * yString = textfield6.stringValue;
                
                newPathSegment.pathCommand = newCommand;
                newPathSegment.x1String = x1String;
                newPathSegment.y1String = y1String;
                newPathSegment.x2String = x2String;
                newPathSegment.y2String = y2String;
                newPathSegment.xString = xString;
                newPathSegment.yString = yString;
                
                break;
            }
            case 5:
            {
                // Cubic Curveto Smooth
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'S';
                }
                else
                {
                    newCommand = 's';
                }
                
                NSString * x2String = textfield1.stringValue;
                NSString * y2String = textfield2.stringValue;
                NSString * xString = textfield3.stringValue;
                NSString * yString = textfield4.stringValue;
                
                newPathSegment.pathCommand = newCommand;
                newPathSegment.x2String = x2String;
                newPathSegment.y2String = y2String;
                newPathSegment.xString = xString;
                newPathSegment.yString = yString;

                break;
            }
            case 6:
            {
                // Quadratic Curveto
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'Q';
                }
                else
                {
                    newCommand = 'q';
                }
                
                NSString * x1String = textfield1.stringValue;
                NSString * y1String = textfield2.stringValue;
                NSString * xString = textfield3.stringValue;
                NSString * yString = textfield4.stringValue;
                
                newPathSegment.pathCommand = newCommand;
                newPathSegment.x1String = x1String;
                newPathSegment.y1String = y1String;
                newPathSegment.xString = xString;
                newPathSegment.yString = yString;
                
                break;
            }
            case 7:
            {
                // Quadratic Curveto Smooth
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'T';
                }
                else
                {
                    newCommand = 't';
                }
                
                NSString * xString = textfield1.stringValue;
                NSString * yString = textfield2.stringValue;
                
                newPathSegment.pathCommand = newCommand;
                newPathSegment.xString = xString;
                newPathSegment.yString = yString;
                
                break;
            }
            case 8:
            {
                // Elliptical Arc
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'A';
                }
                else
                {
                    newCommand = 'a';
                }

                NSString * rxString = textfield1.stringValue;
                NSString * ryString = textfield2.stringValue;
                NSString * xAxisRotationString = textfield3.stringValue;
                NSString * largeArcFlagString = textfield4.stringValue;
                NSString * sweepFlagString = textfield5.stringValue;
                NSString * xString = textfield6.stringValue;
                NSString * yString = textfield7.stringValue;
                
                newPathSegment.pathCommand = newCommand;
                newPathSegment.rxString = rxString;
                newPathSegment.ryString = ryString;
                newPathSegment.xAxisRotationString = xAxisRotationString;
                newPathSegment.largeArcFlagString = largeArcFlagString;
                newPathSegment.sweepFlagString = sweepFlagString;
                newPathSegment.xString = xString;
                newPathSegment.yString = yString;
                
                break;
            }
            case 9:
            {
                // Close Path
                if (useRelativeCoordinates == NO)
                {
                    newCommand = 'Z';
                }
                else
                {
                    newCommand = 'z';
                }

                newPathSegment.pathCommand = newCommand;

                break;
            }
        }
        
        [self.pathElementEditor.macSVGPluginCallbacks pushUndoRedoDocumentChanges];
        
        if (self.pathElementEditor.pathSegmentEditorMode == kEditPathSegment)
        {
            (self.pathElementEditor.pathSegmentsArray)[selectedRow] = newPathSegment;
        }
        if (self.pathElementEditor.pathSegmentEditorMode == kAddPathSegment)
        {
            [self.pathElementEditor.pathSegmentsArray insertObject:newPathSegment atIndex:(selectedRow + 1)];
        }
        
        [self.pathElementEditor.macSVGPluginCallbacks updatePathSegmentsAbsoluteValues:self.pathElementEditor.pathSegmentsArray];
        
        [self.pathElementEditor updateWithPathSegmentsArray:self.pathElementEditor.pathSegmentsArray updatePathLength:YES];
    }
    else
    {
        NSBeep();
    }

    [pathSegmentEditorPopover performClose:self];
}

//==================================================================================
//	cancelButtonAction
//==================================================================================

- (IBAction)cancelButtonAction:(id)sender
{
    [pathSegmentEditorPopover performClose:self];
}

//==================================================================================
//	hideAllFields
//==================================================================================

- (void)hideAllFields
{
    [label1 setHidden:YES];
    [textfield1 setHidden:YES];

    [label2 setHidden:YES];
    [textfield2 setHidden:YES];

    [label3 setHidden:YES];
    [textfield3 setHidden:YES];

    [label4 setHidden:YES];
    [textfield4 setHidden:YES];

    [label5 setHidden:YES];
    [textfield5 setHidden:YES];

    [label6 setHidden:YES];
    [textfield6 setHidden:YES];

    [label7 setHidden:YES];
    [textfield7 setHidden:YES];
}

//==================================================================================
//	showTextFieldIndex:value:
//==================================================================================

- (void)showTextFieldIndex:(NSInteger)textFieldIndex label:(NSString *)label value:(NSString *)value
{
    NSString * copyValue = value;
    if (copyValue == NULL)
    {
        copyValue = @"0";
    }

    switch (textFieldIndex) 
    {
      case 1:
        [label1 setHidden:NO];
        label1.stringValue = label;
        
        [textfield1 setHidden:NO];
        textfield1.stringValue = copyValue;
        break;

      case 2:
        [label2 setHidden:NO];
        label2.stringValue = label;
        
        [textfield2 setHidden:NO];
        textfield2.stringValue = copyValue;
        break;

      case 3:
        [label3 setHidden:NO];
        label3.stringValue = label;
        
        [textfield3 setHidden:NO];
        textfield3.stringValue = copyValue;
        break;

      case 4:
        [label4 setHidden:NO];
        label4.stringValue = label;
        
        [textfield4 setHidden:NO];
        textfield4.stringValue = copyValue;
        break;

      case 5:
        [label5 setHidden:NO];
        label5.stringValue = label;
        
        [textfield5 setHidden:NO];
        textfield5.stringValue = copyValue;
        break;

      case 6:
        [label6 setHidden:NO];
        label6.stringValue = label;
        
        [textfield6 setHidden:NO];
        textfield6.stringValue = copyValue;
        break;

      case 7:
        [label7 setHidden:NO];
        label7.stringValue = label;
        
        [textfield7 setHidden:NO];
        textfield7.stringValue = copyValue;
        break;

      default:
        break;
    }
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
//	setPathSegmentData:
//==================================================================================

- (void)setPathSegmentData:(PathSegment *)pathSegment
{
    [self.pathElementEditor.macSVGPluginCallbacks updatePathSegmentsAbsoluteValues:self.pathElementEditor.pathSegmentsArray];

    unichar commandChar = pathSegment.pathCommand;
    
    if ((commandChar >= 'a') && (commandChar <= 'z'))
    {
        [relativeCoordinatesCheckboxButton setState:YES];
    }
    else
    {
        [relativeCoordinatesCheckboxButton setState:NO];
    }
    
    float absoluteStartX = pathSegment.absoluteStartXFloat;
    float absoluteStartY = pathSegment.absoluteStartYFloat;
    float absoluteX = pathSegment.absoluteXFloat;
    float absoluteY = pathSegment.absoluteYFloat;
    
    absoluteStartXTextField.stringValue = [self allocFloatString:absoluteStartX];
    absoluteStartYTextField.stringValue = [self allocFloatString:absoluteStartY];
    absoluteXTextField.stringValue = [self allocFloatString:absoluteX];
    absoluteYTextField.stringValue = [self allocFloatString:absoluteY];
    
    switch (commandChar)
    {
        case 'M':
        case 'm':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Moveto"];
            [self setXYFieldData:pathSegment];
            break;
        }
        case 'L':
        case 'l':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Lineto"];
            [self setXYFieldData:pathSegment];
            break;
        }
        case 'H':
        case 'h':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Horizontal Lineto"];
            [self setXFieldData:pathSegment];
            break;
        }
        case 'V':
        case 'v':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Vertical Lineto"];
            [self setYFieldData:pathSegment];
            break;
        }
        case 'C':
        case 'c':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Cubic Curveto"];
            [self setCubicCurveFieldData:pathSegment];
            break;
        }
        case 'S':
        case 's':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Cubic Curveto Smooth"];
            [self setSmoothCubicCurveFieldData:pathSegment];
            break;
        }
        case 'Q':
        case 'q':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Quadratic Curveto"];
            [self setQuadraticCurveFieldData:pathSegment];
            break;
        }
        case 'T':
        case 't':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Quadratic Curveto Smooth"];
            [self setSmoothQuadraticCurveFieldData:pathSegment];
            break;
        }
        case 'A':
        case 'a':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Elliptical Arc"];
        [self setEllipticalArcFieldData:pathSegment];
            break;
        }
        case 'Z':
        case 'z':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Close Path"];
            [self setClosePathFieldData:pathSegment];
            break;
        }
    }
}

//==================================================================================
//	setXYFieldData:
//==================================================================================

- (void)setXYFieldData:(PathSegment *)pathSegment
{
    NSString * xString = pathSegment.xString;
    NSString * yString = pathSegment.yString;
    
    [self showTextFieldIndex:1 label:@"x" value:xString];
    [self showTextFieldIndex:2 label:@"y" value:yString];
}

//==================================================================================
//	setXFieldData:
//==================================================================================

- (void)setXFieldData:(PathSegment *)pathSegment
{
    NSString * xString = pathSegment.xString;
    
    [self showTextFieldIndex:1 label:@"x" value:xString];
}

//==================================================================================
//	setYFieldData:
//==================================================================================

- (void)setYFieldData:(PathSegment *)pathSegment
{
    NSString * yString = pathSegment.yString;
    
    [self showTextFieldIndex:1 label:@"y" value:yString];
}

//==================================================================================
//	setCubicCurveFieldData:
//==================================================================================

- (void)setCubicCurveFieldData:(PathSegment *)pathSegment
{
    NSString * x1String = pathSegment.x1String;
    NSString * y1String = pathSegment.y1String;
    
    NSString * x2String = pathSegment.x2String;
    NSString * y2String = pathSegment.y2String;
    
    NSString * xString = pathSegment.xString;
    NSString * yString = pathSegment.yString;
    
    [self showTextFieldIndex:1 label:@"x1" value:x1String];
    [self showTextFieldIndex:2 label:@"y1" value:y1String];
    
    [self showTextFieldIndex:3 label:@"x2" value:x2String];
    [self showTextFieldIndex:4 label:@"y2" value:y2String];
    
    [self showTextFieldIndex:5 label:@"x" value:xString];
    [self showTextFieldIndex:6 label:@"y" value:yString];
}

//==================================================================================
//	setSmoothCubicCurveFieldData:
//==================================================================================

- (void)setSmoothCubicCurveFieldData:(PathSegment *)pathSegment
{
    NSString * x2String = pathSegment.x2String;
    NSString * y2String = pathSegment.y2String;
    
    NSString * xString = pathSegment.xString;
    NSString * yString = pathSegment.yString;
    
    [self showTextFieldIndex:1 label:@"x2" value:x2String];
    [self showTextFieldIndex:2 label:@"y2" value:y2String];
    
    [self showTextFieldIndex:3 label:@"x" value:xString];
    [self showTextFieldIndex:4 label:@"y" value:yString];
}

//==================================================================================
//	setQuadraticCurveFieldData:
//==================================================================================

- (void)setQuadraticCurveFieldData:(PathSegment *)pathSegment
{
    NSString * x1String = pathSegment.x1String;
    NSString * y1String = pathSegment.y1String;
    
    NSString * xString = pathSegment.xString;
    NSString * yString = pathSegment.yString;
    
    [self showTextFieldIndex:1 label:@"x1" value:x1String];
    [self showTextFieldIndex:2 label:@"y1" value:y1String];
    
    [self showTextFieldIndex:3 label:@"x" value:xString];
    [self showTextFieldIndex:4 label:@"y" value:yString];
}

//==================================================================================
//	setSmoothQuadraticCurveFieldData:
//==================================================================================

- (void)setSmoothQuadraticCurveFieldData:(PathSegment *)pathSegment
{
    NSString * xString = pathSegment.xString;
    NSString * yString = pathSegment.yString;
    
    [self showTextFieldIndex:1 label:@"x" value:xString];
    [self showTextFieldIndex:2 label:@"y" value:yString];
}

//==================================================================================
//	setEllipticalArcFieldData:
//==================================================================================

- (void)setEllipticalArcFieldData:(PathSegment *)pathSegment
{
    NSString * rxString = pathSegment.rxString;
    NSString * ryString = pathSegment.ryString;
    NSString * xAxisRotationString = pathSegment.xAxisRotationString;
    NSString * largeArcFlagString = pathSegment.largeArcFlagString;
    NSString * sweepFlagString = pathSegment.sweepFlagString;
    NSString * xString = pathSegment.xString;
    NSString * yString = pathSegment.yString;
    
    [self showTextFieldIndex:1 label:@"rx" value:rxString];
    [self showTextFieldIndex:2 label:@"ry" value:ryString];
    [self showTextFieldIndex:3 label:@"x-axis-rotation" value:xAxisRotationString];
    [self showTextFieldIndex:4 label:@"large-arc-flag" value:largeArcFlagString];
    [self showTextFieldIndex:5 label:@"sweep-flag" value:sweepFlagString];
    [self showTextFieldIndex:6 label:@"x" value:xString];
    [self showTextFieldIndex:7 label:@"y" value:yString];
}

//==================================================================================
//	setClosePathFieldData:
//==================================================================================

- (void)setClosePathFieldData:(PathSegment *)pathSegment
{
}

//==================================================================================
//	textFieldAction
//==================================================================================

- (IBAction)textFieldAction:(id)sender;
{
    NSInteger selectedRow = (self.pathElementEditor.pathTableView).selectedRow;

    if (selectedRow != -1)
    {
        NSMutableArray * pathSegmentsArray = [self.pathElementEditor pathSegmentsArray];

        PathSegment * pathSegment = pathSegmentsArray[selectedRow];

        [self copyTextFieldValuesToTransformDictionary:pathSegment];
    }    
}

//==================================================================================
//	copyTextFieldValuesToTransformDictionary:
//==================================================================================

- (void)copyTextFieldValuesToTransformDictionary:(PathSegment *)pathSegment
{
    NSLog(@"FIXME: PathPluginEditor - copyTextFieldValuesToTransformDictionary method needed here");
}

//==================================================================================
//	loadPathSegmentData:
//==================================================================================

-(void)loadPathSegmentData:(PathSegment *)pathSegment
{
    [self hideAllFields];
    
    [self setPathSegmentData:pathSegment];
    
    [textfield1 becomeFirstResponder];
}


@end
