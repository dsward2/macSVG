//
//  PathSegmentEditorPopoverViewController.m
//  PathElementEditor
//
//  Created by Douglas Ward on 7/13/16.
//
//

/* pathSegmentDictionary
{
    absoluteStartX = 486;
    absoluteStartY = 320;
    absoluteX = 366;
    absoluteX1 = 487;
    absoluteX2 = 461;
    absoluteY = 529;
    absoluteY1 = 394;
    absoluteY2 = 507;
    command = C;
    x = 366;
    x1 = 487;
    x2 = 461;
    y = 529;
    y1 = 394;
    y2 = 507;
}
*/

#import "PathSegmentEditorPopoverViewController.h"
#import "PathElementEditor.h"

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
        NSMutableDictionary * pathSegmentDictionary = (self.pathElementEditor.pathSegmentsArray)[selectedRow];
        
        NSMutableDictionary *newPathSegmentDictionary =
                (__bridge NSMutableDictionary *)(CFPropertyListCreateDeepCopy(kCFAllocatorDefault,
                (__bridge CFPropertyListRef)(pathSegmentDictionary),
                kCFPropertyListMutableContainersAndLeaves));
        
        NSInteger selectedSegmentTypeIndex = segmentTypePopUpButton.indexOfSelectedItem;
        
        NSString * currentCommand = pathSegmentDictionary[@"command"];
        unichar newCommand = [currentCommand characterAtIndex:0];
        
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
                [self validateAttributes:validAttributes inPathSegmentDictionary:newPathSegmentDictionary];
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
                [self validateAttributes:validAttributes inPathSegmentDictionary:newPathSegmentDictionary];
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
                [self validateAttributes:validAttributes inPathSegmentDictionary:newPathSegmentDictionary];
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
                [self validateAttributes:validAttributes inPathSegmentDictionary:newPathSegmentDictionary];
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
                [self validateAttributes:validAttributes inPathSegmentDictionary:newPathSegmentDictionary];
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
                [self validateAttributes:validAttributes inPathSegmentDictionary:newPathSegmentDictionary];
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
                [self validateAttributes:validAttributes inPathSegmentDictionary:newPathSegmentDictionary];
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
                [self validateAttributes:validAttributes inPathSegmentDictionary:newPathSegmentDictionary];
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
                

                [self validateAttributes:validAttributes inPathSegmentDictionary:newPathSegmentDictionary];
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
        
        NSString * newCommandString = [NSString stringWithFormat:@"%C", newCommand];
        newPathSegmentDictionary[@"command"] = newCommandString;
        [self loadPathSegmentData:newPathSegmentDictionary];
    }
}

//==================================================================================
//	validateAttributes:inPathSegmentDictionary:
//==================================================================================

- (void)validateAttributes:(NSArray *)validAttributesArray inPathSegmentDictionary:(NSMutableDictionary *)pathSegmentDictionary
{
    NSArray * allKeys = pathSegmentDictionary.allKeys;
    
    for (NSString * aKey in allKeys)
    {
        NSInteger attributeIndex = [validAttributesArray indexOfObjectIdenticalTo:aKey];
        
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
            [pathSegmentDictionary removeObjectForKey:aKey];
        }
    }
    
    for (NSString * aValidAttribute in validAttributesArray)
    {
        id existingAttribute = pathSegmentDictionary[aValidAttribute];
        
        if (existingAttribute == NULL)
        {
            NSString * newAttributeValue = @"0";
            
            unichar firstAttributeCharacter = [aValidAttribute characterAtIndex:0];
            if (firstAttributeCharacter == 'x')
            {
                NSString * xString = pathSegmentDictionary[@"x"];
                
                if (xString != NULL)
                {
                    newAttributeValue = xString;
                }
            }
            else if (firstAttributeCharacter == 'y')
            {
                NSString * yString = pathSegmentDictionary[@"y"];
                
                if (yString != NULL)
                {
                    newAttributeValue = yString;
                }
            }
            
            pathSegmentDictionary[aValidAttribute] = newAttributeValue;
        }
    }
}

//==================================================================================
//	applyButtonAction
//==================================================================================

- (IBAction)applyButtonAction:(id)sender
{
    NSInteger selectedRow = (self.pathElementEditor.pathTableView).selectedRow;

    if (selectedRow >= 0)
    {
        NSMutableDictionary * pathSegmentDictionary = (self.pathElementEditor.pathSegmentsArray)[selectedRow];
        
        NSMutableDictionary * newPathSegmentDictionary = [NSMutableDictionary dictionary];
        
        NSInteger selectedSegmentTypeIndex = segmentTypePopUpButton.indexOfSelectedItem;
        
        NSString * currentCommand = pathSegmentDictionary[@"command"];
        unichar newCommand = [currentCommand characterAtIndex:0];
        
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
                
                NSString * commandString = [NSString stringWithFormat:@"%C", newCommand];
                NSString * xString = textfield1.stringValue;
                NSString * yString = textfield2.stringValue;
                
                newPathSegmentDictionary[@"command"] = commandString;
                newPathSegmentDictionary[@"x"] = xString;
                newPathSegmentDictionary[@"y"] = yString;
                
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
                
                NSString * commandString = [NSString stringWithFormat:@"%C", newCommand];
                NSString * xString = textfield1.stringValue;
                NSString * yString = textfield2.stringValue;
                
                newPathSegmentDictionary[@"command"] = commandString;
                newPathSegmentDictionary[@"x"] = xString;
                newPathSegmentDictionary[@"y"] = yString;
                
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
                
                NSString * commandString = [NSString stringWithFormat:@"%C", newCommand];
                NSString * xString = textfield1.stringValue;
                
                newPathSegmentDictionary[@"command"] = commandString;
                newPathSegmentDictionary[@"x"] = xString;
                
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
                
                NSString * commandString = [NSString stringWithFormat:@"%C", newCommand];
                NSString * yString = textfield2.stringValue;
                
                newPathSegmentDictionary[@"command"] = commandString;
                newPathSegmentDictionary[@"y"] = yString;
                
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
                
                NSString * commandString = [NSString stringWithFormat:@"%C", newCommand];
                NSString * x1String = textfield1.stringValue;
                NSString * y1String = textfield2.stringValue;
                NSString * x2String = textfield3.stringValue;
                NSString * y2String = textfield4.stringValue;
                NSString * xString = textfield5.stringValue;
                NSString * yString = textfield6.stringValue;
                
                newPathSegmentDictionary[@"command"] = commandString;
                newPathSegmentDictionary[@"x1"] = x1String;
                newPathSegmentDictionary[@"y1"] = y1String;
                newPathSegmentDictionary[@"x2"] = x2String;
                newPathSegmentDictionary[@"y2"] = y2String;
                newPathSegmentDictionary[@"x"] = xString;
                newPathSegmentDictionary[@"y"] = yString;
                
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
                
                NSString * commandString = [NSString stringWithFormat:@"%C", newCommand];
                NSString * x2String = textfield1.stringValue;
                NSString * y2String = textfield2.stringValue;
                NSString * xString = textfield3.stringValue;
                NSString * yString = textfield4.stringValue;
                
                newPathSegmentDictionary[@"command"] = commandString;
                newPathSegmentDictionary[@"x2"] = x2String;
                newPathSegmentDictionary[@"y2"] = y2String;
                newPathSegmentDictionary[@"x"] = xString;
                newPathSegmentDictionary[@"y"] = yString;

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
                
                NSString * commandString = [NSString stringWithFormat:@"%C", newCommand];
                NSString * x1String = textfield1.stringValue;
                NSString * y1String = textfield2.stringValue;
                NSString * xString = textfield3.stringValue;
                NSString * yString = textfield4.stringValue;
                
                newPathSegmentDictionary[@"command"] = commandString;
                newPathSegmentDictionary[@"x1"] = x1String;
                newPathSegmentDictionary[@"y1"] = y1String;
                newPathSegmentDictionary[@"x"] = xString;
                newPathSegmentDictionary[@"y"] = yString;
                
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
                
                NSString * commandString = [NSString stringWithFormat:@"%C", newCommand];
                NSString * xString = textfield1.stringValue;
                NSString * yString = textfield2.stringValue;
                
                newPathSegmentDictionary[@"command"] = commandString;
                newPathSegmentDictionary[@"x"] = xString;
                newPathSegmentDictionary[@"y"] = yString;
                
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

                NSString * commandString = [NSString stringWithFormat:@"%C", newCommand];
                NSString * rxString = textfield1.stringValue;
                NSString * ryString = textfield2.stringValue;
                NSString * xAxisRotationString = textfield3.stringValue;
                NSString * largeArcFlagString = textfield4.stringValue;
                NSString * sweepFlagString = textfield5.stringValue;
                NSString * xString = textfield6.stringValue;
                NSString * yString = textfield7.stringValue;
                
                newPathSegmentDictionary[@"command"] = commandString;
                newPathSegmentDictionary[@"rx"] = rxString;
                newPathSegmentDictionary[@"ry"] = ryString;
                newPathSegmentDictionary[@"x-axis-rotation"] = xAxisRotationString;
                newPathSegmentDictionary[@"large-arc-flag"] = largeArcFlagString;
                newPathSegmentDictionary[@"sweep-flag"] = sweepFlagString;
                newPathSegmentDictionary[@"x"] = xString;
                newPathSegmentDictionary[@"y"] = yString;
                
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

                NSString * commandString = [NSString stringWithFormat:@"%C", newCommand];

                newPathSegmentDictionary[@"command"] = commandString;

                break;
            }
        }
        
        [self.pathElementEditor.macSVGPluginCallbacks pushUndoRedoDocumentChanges];
        
        if (self.pathElementEditor.pathSegmentEditorMode == kEditPathSegment)
        {
            (self.pathElementEditor.pathSegmentsArray)[selectedRow] = newPathSegmentDictionary;
        }
        if (self.pathElementEditor.pathSegmentEditorMode == kAddPathSegment)
        {
            [self.pathElementEditor.pathSegmentsArray insertObject:newPathSegmentDictionary atIndex:(selectedRow + 1)];
        }
        
        [self.pathElementEditor.macSVGPluginCallbacks updatePathSegmentsAbsoluteValues:self.pathElementEditor.pathSegmentsArray];
        
        [self.pathElementEditor updateWithPathSegmentsArray:self.pathElementEditor.pathSegmentsArray];
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
//	setPathSegmentData:
//==================================================================================

- (void)setPathSegmentData:(NSMutableDictionary *)pathSegmentDictionary
{
    [self.pathElementEditor.macSVGPluginCallbacks updatePathSegmentsAbsoluteValues:self.pathElementEditor.pathSegmentsArray];

    NSString * segmentCommand = segmentCommand = pathSegmentDictionary[@"command"];
    
    unichar commandChar = [segmentCommand characterAtIndex:0];
    
    if ((commandChar >= 'a') && (commandChar <= 'z'))
    {
        [relativeCoordinatesCheckboxButton setState:YES];
    }
    else
    {
        [relativeCoordinatesCheckboxButton setState:NO];
    }
    
    NSNumber * absoluteStartXNumber = pathSegmentDictionary[@"absoluteStartX"];
    NSNumber * absoluteStartYNumber = pathSegmentDictionary[@"absoluteStartY"];
    NSNumber * absoluteXNumber = pathSegmentDictionary[@"absoluteX"];
    NSNumber * absoluteYNumber = pathSegmentDictionary[@"absoluteY"];
    
    if (absoluteStartXNumber == NULL)
    {
        absoluteStartXNumber = @0.0f;
    }
    if (absoluteStartYNumber == NULL)
    {
        absoluteStartYNumber = @0.0f;
    }
    if (absoluteXNumber == NULL)
    {
        absoluteXNumber = @0.0f;
    }
    if (absoluteYNumber == NULL)
    {
        absoluteYNumber = @0.0f;
    }

    absoluteStartXTextField.stringValue = absoluteStartXNumber.stringValue;
    absoluteStartYTextField.stringValue = absoluteStartYNumber.stringValue;
    absoluteXTextField.stringValue = absoluteXNumber.stringValue;
    absoluteYTextField.stringValue = absoluteYNumber.stringValue;
    
    switch (commandChar)
    {
        case 'M':
        case 'm':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Moveto"];
            [self setXYFieldData:pathSegmentDictionary];
            break;
        }
        case 'L':
        case 'l':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Lineto"];
            [self setXYFieldData:pathSegmentDictionary];
            break;
        }
        case 'H':
        case 'h':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Horizontal Lineto"];
            [self setXFieldData:pathSegmentDictionary];
            break;
        }
        case 'V':
        case 'v':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Vertical Lineto"];
            [self setYFieldData:pathSegmentDictionary];
            break;
        }
        case 'C':
        case 'c':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Cubic Curveto"];
            [self setCubicCurveFieldData:pathSegmentDictionary];
            break;
        }
        case 'S':
        case 's':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Cubic Curveto Smooth"];
            [self setSmoothCubicCurveFieldData:pathSegmentDictionary];
            break;
        }
        case 'Q':
        case 'q':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Quadratic Curveto"];
            [self setQuadraticCurveFieldData:pathSegmentDictionary];
            break;
        }
        case 'T':
        case 't':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Quadratic Curveto Smooth"];
            [self setSmoothQuadraticCurveFieldData:pathSegmentDictionary];
            break;
        }
        case 'A':
        case 'a':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Elliptical Arc"];
        [self setEllipticalArcFieldData:pathSegmentDictionary];
            break;
        }
        case 'Z':
        case 'z':
        {
            [segmentTypePopUpButton selectItemWithTitle:@"Close Path"];
            [self setClosePathFieldData:pathSegmentDictionary];
            break;
        }
    }
}

//==================================================================================
//	setXYFieldData:
//==================================================================================

- (void)setXYFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * xString = pathSegmentDictionary[@"x"];
    NSString * yString = pathSegmentDictionary[@"y"];
    
    [self showTextFieldIndex:1 label:@"x" value:xString];
    [self showTextFieldIndex:2 label:@"y" value:yString];
}

//==================================================================================
//	setXFieldData:
//==================================================================================

- (void)setXFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * xString = pathSegmentDictionary[@"x"];
    
    [self showTextFieldIndex:1 label:@"x" value:xString];
}

//==================================================================================
//	setYFieldData:
//==================================================================================

- (void)setYFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * yString = pathSegmentDictionary[@"y"];
    
    [self showTextFieldIndex:1 label:@"y" value:yString];
}

//==================================================================================
//	setCubicCurveFieldData:
//==================================================================================

- (void)setCubicCurveFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * x1String = pathSegmentDictionary[@"x1"];
    NSString * y1String = pathSegmentDictionary[@"y1"];
    
    NSString * x2String = pathSegmentDictionary[@"x2"];
    NSString * y2String = pathSegmentDictionary[@"y2"];
    
    NSString * xString = pathSegmentDictionary[@"x"];
    NSString * yString = pathSegmentDictionary[@"y"];
    
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

- (void)setSmoothCubicCurveFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * x2String = pathSegmentDictionary[@"x2"];
    NSString * y2String = pathSegmentDictionary[@"y2"];
    
    NSString * xString = pathSegmentDictionary[@"x"];
    NSString * yString = pathSegmentDictionary[@"y"];
    
    [self showTextFieldIndex:1 label:@"x2" value:x2String];
    [self showTextFieldIndex:2 label:@"y2" value:y2String];
    
    [self showTextFieldIndex:3 label:@"x" value:xString];
    [self showTextFieldIndex:4 label:@"y" value:yString];
}

//==================================================================================
//	setQuadraticCurveFieldData:
//==================================================================================

- (void)setQuadraticCurveFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * x1String = pathSegmentDictionary[@"x1"];
    NSString * y1String = pathSegmentDictionary[@"y1"];
    
    NSString * xString = pathSegmentDictionary[@"x"];
    NSString * yString = pathSegmentDictionary[@"y"];
    
    [self showTextFieldIndex:1 label:@"x1" value:x1String];
    [self showTextFieldIndex:2 label:@"y1" value:y1String];
    
    [self showTextFieldIndex:3 label:@"x" value:xString];
    [self showTextFieldIndex:4 label:@"y" value:yString];
}

//==================================================================================
//	setSmoothQuadraticCurveFieldData:
//==================================================================================

- (void)setSmoothQuadraticCurveFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * xString = pathSegmentDictionary[@"x"];
    NSString * yString = pathSegmentDictionary[@"y"];
    
    [self showTextFieldIndex:1 label:@"x" value:xString];
    [self showTextFieldIndex:2 label:@"y" value:yString];
}

//==================================================================================
//	setEllipticalArcFieldData:
//==================================================================================

- (void)setEllipticalArcFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * rxString = pathSegmentDictionary[@"rx"];
    NSString * ryString = pathSegmentDictionary[@"ry"];
    NSString * xAxisRotationString = pathSegmentDictionary[@"x-axis-rotation"];
    NSString * largeArcFlagString = pathSegmentDictionary[@"large-arc-flag"];
    NSString * sweepFlagString = pathSegmentDictionary[@"sweep-flag"];
    NSString * xString = pathSegmentDictionary[@"x"];
    NSString * yString = pathSegmentDictionary[@"y"];
    
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

- (void)setClosePathFieldData:(NSMutableDictionary *)pathSegmentDictionary
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

        NSMutableDictionary * pathSegmentDictionary = pathSegmentsArray[selectedRow];

        [self copyTextFieldValuesToTransformDictionary:pathSegmentDictionary];
    }    
}

//==================================================================================
//	copyTextFieldValuesToTransformDictionary:
//==================================================================================

- (void)copyTextFieldValuesToTransformDictionary:(NSMutableDictionary *)transformDictionary
{
    NSLog(@"PathPluginEditor - copyTextFieldValuesToTransformDictionary method needed here");
}

//==================================================================================
//	loadPathSegmentData:
//==================================================================================

-(void)loadPathSegmentData:(NSMutableDictionary *)pathSegmentDictionary
{
    [self hideAllFields];
    
    [self setPathSegmentData:pathSegmentDictionary];
    
    [textfield1 becomeFirstResponder];
}


@end
