//
//  PathAttributeEditor.m
//  PathAttributeEditor
//
//  Created by Douglas Ward on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PathAttributeEditor.h"
#import "MacSVGDocument.h"
#import "MacSVGDocumentWindowController.h"
#import "SVGWebKitController.h"
#import <WebKit/WebKit.h>
#import "SvgDomAppDelegate.h"
#import "DOMSelectionRectsAndHandlesManager.h"
#import "SVGXMLDOMSelectionManager.h"
#import "MacSVGPluginCallbacks.h"

#define PathTableViewDataType @"NSMutableDictionary"

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

@implementation PathAttributeEditor

//==================================================================================
//	dealloc
//==================================================================================


//==================================================================================
//	init
//==================================================================================

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    return @"Path Segments Editor";
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element tag name
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    NSString * result = NULL;

    return result;
}

//==================================================================================
//	isEditorForElement:elementName:attribute:
//==================================================================================

// return label if this editor can edit specified element and attribute
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName attribute:(NSString *)attributeName
{   
    NSString * result = NULL;
    
    if ([elementName isEqualToString:@"path"] == YES)
    {
        if ([attributeName isEqualToString:@"d"] == YES)
        {
            result = [self pluginName];
        }
    }

    return result;
}

//==================================================================================
//	editorPriority:context:
//==================================================================================

- (NSInteger)editorPriority:(NSXMLElement *)targetElement context:(NSString *)context
{
    return 30;
}

//==================================================================================
//	syncDOMElementToXMLDocument:
//==================================================================================

-(void) syncDOMElementToXMLDocument
{
    NSMutableDictionary * newAttributesDictionary = [[NSMutableDictionary alloc] init];

    DOMNamedNodeMap * domAttributes = [self.pluginTargetDOMElement attributes];
    NSInteger attCount = [domAttributes length];
    
    for (unsigned int a = 0; a < attCount; a++) 
    {
        DOMNode * attributes = [domAttributes item:a];
        NSString * attributeName = [attributes nodeName];
        NSString * attributeValue = [attributes nodeValue];

        NSRange xmlnsRange = [attributeName rangeOfString:@"xmlns"];
        if (xmlnsRange.location != NSNotFound)
        {
            NSLog(@"syncDOMElementToXMLDocument - xmlns namespace found as attribute");
        }
        
        if ([attributeName length] > 0)
        {
            unichar firstChar = [attributeName characterAtIndex:0];
            if (firstChar != '_')
            {
                [newAttributesDictionary setObject:attributeValue forKey:attributeName];
            }
        }
    }
    
    [self.pluginTargetXMLElement setAttributesWithDictionary:newAttributesDictionary];
    
}

//==================================================================================
//	setPathDataAttribute
//==================================================================================

-(void) setPathDataAttribute
{
    [self syncDOMElementToXMLDocument];

    [self.macSVGDocument updateSelections]; // update selection rectangles and handles
    
    NSInteger selectedRow = [pathTableView selectedRow];
    [pathTableView setNeedsDisplayInRect:[pathTableView 
            frameOfCellAtColumn:0 row:selectedRow]];
}

//==================================================================================
//	pathSegmentsArray
//==================================================================================

- (NSMutableArray * )pathSegmentsArray
{
    //id svgPathEditor = [svgWebView svgPathEditor];
    
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    
    NSMutableArray * pathSegmentsArray = [svgWebKitController pathSegmentsArray];
    
    return pathSegmentsArray;
}


//==================================================================================
//	numberOfRowsInTableView
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];
    return [pathSegmentsArray count];
}

//==================================================================================
//	tableView:objectValueForTableColumn:rowIndex
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString *  objectValue = NULL;
    
    NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];
    NSDictionary * pathSegmentDictionary = [pathSegmentsArray objectAtIndex:rowIndex];

    
    if ([[aTableColumn identifier] isEqualToString:@"segmentIndex"] == YES)
    {
        objectValue = [NSString stringWithFormat:@"%ld", (rowIndex + 1)];
    }
    else if ([[aTableColumn identifier] isEqualToString:@"segmentCommand"] == YES)
    {
        if (pathSegmentDictionary != NULL)
        {
            NSString * segmentCommand = segmentCommand = [pathSegmentDictionary objectForKey:@"command"];

           if ([segmentCommand isEqualToString:@"M"] == YES) 
            {
                objectValue = @"Moveto";
            }
            else if ([segmentCommand isEqualToString:@"m"] == YES) 
            {
                objectValue = @"Moveto Relative";
            }
            else if ([segmentCommand isEqualToString:@"L"] == YES) 
            {
                objectValue = @"Lineto";
            }
            else if ([segmentCommand isEqualToString:@"l"] == YES) 
            {
                objectValue = @"Lineto Relative";
            }
            else if ([segmentCommand isEqualToString:@"H"] == YES) 
            {
                objectValue = @"Horizontal Lineto";
            }
            else if ([segmentCommand isEqualToString:@"h"] == YES) 
            {
                objectValue = @"Horizontal Lineto Relative";
            }
            else if ([segmentCommand isEqualToString:@"V"] == YES) 
            {
                objectValue = @"Vertical Lineto";
            }
            else if ([segmentCommand isEqualToString:@"v"] == YES) 
            {
                objectValue = @"Vertical Lineto Relative";
            }
            else if ([segmentCommand isEqualToString:@"C"] == YES) 
            {
                objectValue = @"Cubic Curveto";
            }
            else if ([segmentCommand isEqualToString:@"c"] == YES) 
            {
                objectValue = @"Cubic Curveto Relative";
            }
            else if ([segmentCommand isEqualToString:@"S"] == YES) 
            {
                objectValue = @"Smooth Cubic Curveto";
            }
            else if ([segmentCommand isEqualToString:@"s"] == YES) 
            {
                objectValue = @"Smooth Cubic Curveto Relative";
            }
            else if ([segmentCommand isEqualToString:@"Q"] == YES) 
            {
                objectValue = @"Quadratic Curveto";
            }
            else if ([segmentCommand isEqualToString:@"q"] == YES) 
            {
                objectValue = @"Quadratic Curveto Relative";
            }
            else if ([segmentCommand isEqualToString:@"T"] == YES) 
            {
                objectValue = @"Smooth Quadratic Curveto";
            }
            else if ([segmentCommand isEqualToString:@"t"] == YES) 
            {
                objectValue = @"Smooth Quadratic Curveto Relative";
            }
            else if ([segmentCommand isEqualToString:@"A"] == YES) 
            {
                objectValue = @"Elliptical Arc";
            }
            else if ([segmentCommand isEqualToString:@"a"] == YES) 
            {
                objectValue = @"Elliptical Arc Relative";
            }
            else if ([segmentCommand isEqualToString:@"Z"] == YES) 
            {
                objectValue = @"Close Path";
            }
            else if ([segmentCommand isEqualToString:@"z"] == YES) 
            {
                objectValue = @"Close Path Relative";
            }
        }
    }
    else if ([[aTableColumn identifier] isEqualToString:@"segmentData"] == YES)
    {
        if (pathSegmentDictionary != NULL)
        {
            NSString * segmentCommand = segmentCommand = [pathSegmentDictionary objectForKey:@"command"];
            
            NSString * segmentValues = @"";
            
            if ([segmentCommand isEqualToString:@"M"] == YES) 
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                segmentValues = [NSString stringWithFormat:@"%@ %@",
                        xString, yString];
            }
            else if ([segmentCommand isEqualToString:@"m"] == YES) 
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                segmentValues = [NSString stringWithFormat:@"%@ %@",
                        xString, yString];
            }
            else if ([segmentCommand isEqualToString:@"L"] == YES) 
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                segmentValues = [NSString stringWithFormat:@"%@ %@",
                        xString, yString];
            }
            else if ([segmentCommand isEqualToString:@"l"] == YES) 
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                segmentValues = [NSString stringWithFormat:@"%@ %@",
                        xString, yString];
            }
            else if ([segmentCommand isEqualToString:@"H"] == YES) 
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                segmentValues = [NSString stringWithFormat:@"%@",
                        xString];
            }
            else if ([segmentCommand isEqualToString:@"h"] == YES) 
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                segmentValues = [NSString stringWithFormat:@"%@",
                        xString];
            }
            else if ([segmentCommand isEqualToString:@"V"] == YES) 
            {
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                segmentValues = [NSString stringWithFormat:@"%@",
                        yString];
            }
            else if ([segmentCommand isEqualToString:@"v"] == YES) 
            {
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                segmentValues = [NSString stringWithFormat:@"%@",
                        yString];
            }
            else if ([segmentCommand isEqualToString:@"C"] == YES) 
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",
                        x1String, y1String, x2String, y2String, xString, yString];
            }
            else if ([segmentCommand isEqualToString:@"c"] == YES) 
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",
                        x1String, y1String, x2String, y2String, xString, yString];
            }
            else if ([segmentCommand isEqualToString:@"S"] == YES) 
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@",
                        x2String, y2String, xString, yString];
            }
            else if ([segmentCommand isEqualToString:@"s"] == YES) 
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@",
                        x2String, y2String, xString, yString];
            }
            else if ([segmentCommand isEqualToString:@"Q"] == YES) 
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                NSString * x1String = [pathSegmentDictionary objectForKey:@"x2"];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y2"];
                segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@",
                        x1String, y1String, xString, yString];
            }
            else if ([segmentCommand isEqualToString:@"q"] == YES) 
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                NSString * x1String = [pathSegmentDictionary objectForKey:@"x2"];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y2"];
                segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@",
                        x1String, y1String, xString, yString];
            }
            else if ([segmentCommand isEqualToString:@"T"] == YES) 
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                segmentValues = [NSString stringWithFormat:@"%@ %@",
                        xString, yString];
            }
            else if ([segmentCommand isEqualToString:@"t"] == YES) 
            {
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                segmentValues = [NSString stringWithFormat:@"%@ %@",
                        xString, yString];
            }
            else if ([segmentCommand isEqualToString:@"A"] == YES) 
            {
                NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                NSString * xAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                NSString * largeArcFlagString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                NSString * sweepFlagString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@",
                        rxString, ryString, xAxisRotationString, largeArcFlagString, sweepFlagString, xString, yString];
            }
            else if ([segmentCommand isEqualToString:@"a"] == YES) 
            {
                NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                NSString * xAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                NSString * largeArcFlagString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                NSString * sweepFlagString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@",
                        rxString, ryString, xAxisRotationString, largeArcFlagString, sweepFlagString, xString, yString];
            }
            else if ([segmentCommand isEqualToString:@"Z"] == YES) 
            {
                segmentValues = @"";
            }
            else if ([segmentCommand isEqualToString:@"z"] == YES) 
            {
                segmentValues = @"";
            }
            
            objectValue = [NSString stringWithFormat:@"%@ %@", segmentCommand, segmentValues];
        } 
    }
    
    return objectValue;
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
    switch (textFieldIndex) 
    {
      case 1:
        [label1 setHidden:NO];
        [label1 setStringValue:label];
        
        [textfield1 setHidden:NO];
        [textfield1 setStringValue:value];
        break;

      case 2:
        [label2 setHidden:NO];
        [label2 setStringValue:label];
        
        [textfield2 setHidden:NO];
        [textfield2 setStringValue:value];
        break;

      case 3:
        [label3 setHidden:NO];
        [label3 setStringValue:label];
        
        [textfield3 setHidden:NO];
        [textfield3 setStringValue:value];
        break;

      case 4:
        [label4 setHidden:NO];
        [label4 setStringValue:label];
        
        [textfield4 setHidden:NO];
        [textfield4 setStringValue:value];
        break;

      case 5:
        [label5 setHidden:NO];
        [label5 setStringValue:label];
        
        [textfield5 setHidden:NO];
        [textfield5 setStringValue:value];
        break;

      case 6:
        [label6 setHidden:NO];
        [label6 setStringValue:label];
        
        [textfield6 setHidden:NO];
        [textfield6 setStringValue:value];
        break;

      case 7:
        [label7 setHidden:NO];
        [label7 setStringValue:label];
        
        [textfield7 setHidden:NO];
        [textfield7 setStringValue:value];
        break;

      default:
        break;
    }
}


//==================================================================================
//	setXYFieldData:
//==================================================================================

- (void)setXYFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
    
    [self showTextFieldIndex:1 label:@"x" value:xString];
    [self showTextFieldIndex:2 label:@"y" value:yString];
}

//==================================================================================
//	setXFieldData:
//==================================================================================

- (void)setXFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
    
    [self showTextFieldIndex:1 label:@"x" value:xString];
}

//==================================================================================
//	setYFieldData:
//==================================================================================

- (void)setYFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * yString = [pathSegmentDictionary objectForKey:@"x"];
    
    [self showTextFieldIndex:1 label:@"y" value:yString];
}

//==================================================================================
//	setCubicCurveFieldData:
//==================================================================================

- (void)setCubicCurveFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
    NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
    
    NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
    NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
    
    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
    
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
    NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
    NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
    
    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
    
    [self showTextFieldIndex:1 label:@"x2" value:x2String];
    [self showTextFieldIndex:2 label:@"y2" value:y2String];
    
    [self showTextFieldIndex:2 label:@"x" value:xString];
    [self showTextFieldIndex:3 label:@"y" value:yString];
}

//==================================================================================
//	setQuadraticCurveFieldData:
//==================================================================================

- (void)setQuadraticCurveFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
    NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
    
    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
    
    [self showTextFieldIndex:1 label:@"x1" value:x1String];
    [self showTextFieldIndex:2 label:@"y1" value:y1String];
    
    [self showTextFieldIndex:2 label:@"x" value:xString];
    [self showTextFieldIndex:3 label:@"y" value:yString];
}

//==================================================================================
//	setSmoothQuadraticCurveFieldData:
//==================================================================================

- (void)setSmoothQuadraticCurveFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
    
    [self showTextFieldIndex:1 label:@"x" value:xString];
    [self showTextFieldIndex:2 label:@"y" value:yString];
}

//==================================================================================
//	setEllipticalArcFieldData:
//==================================================================================

- (void)setEllipticalArcFieldData:(NSMutableDictionary *)pathSegmentDictionary
{
    NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
    NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
    NSString * xAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
    NSString * largeArcFlagString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
    NSString * sweepFlagString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
    NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
    NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
    
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
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = [aNotification object];
	if (aTableView == pathTableView)
	{
        NSInteger rowIndex = [pathTableView selectedRow];

        NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];

        NSMutableDictionary * pathSegmentDictionary = [pathSegmentsArray objectAtIndex:rowIndex];
            
        if (pathSegmentDictionary != NULL)
        {
            [self hideAllFields];

            NSString * segmentCommand = segmentCommand = [pathSegmentDictionary objectForKey:@"command"];

            if ([segmentCommand isEqualToString:@"M"] == YES) 
            {
                [self setXYFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"m"] == YES) 
            {
                [self setXYFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"L"] == YES) 
            {
                [self setXYFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"l"] == YES) 
            {
                [self setXYFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"H"] == YES) 
            {
                [self setXFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"h"] == YES) 
            {
                [self setXFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"V"] == YES) 
            {
                [self setYFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"v"] == YES) 
            {
                [self setYFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"C"] == YES) 
            {
                [self setCubicCurveFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"c"] == YES) 
            {
                [self setCubicCurveFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"S"] == YES) 
            {
                [self setSmoothCubicCurveFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"s"] == YES) 
            {
                [self setSmoothCubicCurveFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"Q"] == YES) 
            {
                [self setQuadraticCurveFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"q"] == YES) 
            {
                [self setQuadraticCurveFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"T"] == YES) 
            {
                [self setSmoothQuadraticCurveFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"t"] == YES) 
            {
                [self setSmoothQuadraticCurveFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"A"] == YES) 
            {
                [self setEllipticalArcFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"a"] == YES) 
            {
                [self setEllipticalArcFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"Z"] == YES) 
            {
                [self setClosePathFieldData:pathSegmentDictionary];
            }
            else if ([segmentCommand isEqualToString:@"z"] == YES) 
            {
                [self setClosePathFieldData:pathSegmentDictionary];
            }
        }
    }
}

//==================================================================================
//	awakeFromNib
//==================================================================================

- (void)awakeFromNib 
{
    [pathTableView registerForDraggedTypes:[NSArray arrayWithObject:PathTableViewDataType]];
}

//==================================================================================
//	tableView:writeRowsWithIndexes:toPasteboard
//==================================================================================

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];

    [pboard declareTypes:[NSArray arrayWithObject:PathTableViewDataType] owner:self];

    [pboard setData:data forType:PathTableViewDataType];
    
    return YES;
}

//==================================================================================
//	tableView:acceptDrop:row:dropOperation
//==================================================================================

- (BOOL)tableView:(NSTableView*)tableView 
        acceptDrop:(id <NSDraggingInfo>)info 
        row:(NSInteger)row
        dropOperation:(NSTableViewDropOperation)operation
{
    // handle drag-and-drop reordering
    
    NSPasteboard * pboard = [info draggingPasteboard];
    NSData * rowData = [pboard dataForType:PathTableViewDataType];

    NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];

    NSIndexSet * rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];

    NSInteger from = [rowIndexes firstIndex];

    NSMutableDictionary * traveller = [pathSegmentsArray objectAtIndex:from];
    
    NSInteger length = [pathSegmentsArray count];
    //NSMutableArray * replacement = [NSMutableArray new];

    NSInteger i;
    for (i = 0; i <= length; i++)
    {
        if (i == row)
        {
            if (from > row)
            {
                [pathSegmentsArray insertObject:traveller atIndex:row];
                [pathSegmentsArray removeObjectAtIndex:(from + 1)];
            }
            else
            {
                [pathSegmentsArray insertObject:traveller atIndex:row];
                [pathSegmentsArray removeObjectAtIndex:from];
            }
        }
    }
    
    [pathTableView reloadData];
    
    [self setPathDataAttribute];
    
    return YES;
}


//==================================================================================
//	tableView:validateDrop:proposedRow:proposedDropOperation:
//==================================================================================

- (NSDragOperation)tableView:(NSTableView*)tableView 
        validateDrop:(id <NSDraggingInfo>)info 
        proposedRow:(NSInteger)row
        proposedDropOperation:(NSTableViewDropOperation)operation
{
    return NSDragOperationEvery;
}


//==================================================================================
//	handlePluginEvent
//==================================================================================

-(void) handlePluginEvent:(DOMEvent *)event
{
    // Our callback from WebKit
    NSString * eventType = event.type;
    
    DOMNode * targetNode = self.pluginTargetDOMElement;
    
    DOMElement * targetElement = (DOMElement *)targetNode;
    NSString * tagName = [targetElement tagName];
    #pragma unused(tagName)

    if ([eventType isEqualToString:@"dblclick"] == YES)
    {
        //NSLog(@"handlePluginEvent dblclick");
    }
    else if ([eventType isEqualToString:@"mousedown"] == YES)
    {
        //NSLog(@"handlePluginEvent mousedown");
    }
    else if ([eventType isEqualToString:@"mousemove"] == YES)
    {
        //NSLog(@"handlePluginEvent mousemove");
    }
    else if ([eventType isEqualToString:@"mouseup"] == YES)
    {
        //NSLog(@"handlePluginEvent mouseup");
    }
    else if ([eventType isEqualToString:@"focus"] == YES)
    {
        //NSLog(@"handlePluginEvent focus");
    }
    else if ([eventType isEqualToString:@"blur"] == YES)
    {
        //NSLog(@"handlePluginEvent blur");
    }
    else if ([eventType isEqualToString:@"keydown"] == YES)
    {
        //NSLog(@"handlePluginEvent keydown");
    }
    else if ([eventType isEqualToString:@"keypress"] == YES)
    {
        //NSLog(@"handlePluginEvent keypress");
    }
    else if ([eventType isEqualToString:@"keyup"] == YES)
    {
        //NSLog(@"handlePluginEvent keyup");
    }

    //[macSVGDocument updatePluginLiveCoordinates:event];
}


//==================================================================================
//	copyTextFieldValuesToPathSegmentDictionary:
//==================================================================================

- (void)copyTextFieldValuesToPathSegmentDictionary:(NSMutableDictionary *)pathSegmentDictionary
{
    NSLog(@"PathPluginEditor - copyTextFieldValuesToPathSegmentDictionary method needed here");

/*
    NSString * value1String = [textfield1 stringValue];
    NSString * value2String = [textfield2 stringValue];
    NSString * value3String = [textfield3 stringValue];
    NSString * value4String = [textfield4 stringValue];
    NSString * value5String = [textfield5 stringValue];
    NSString * value6String = [textfield6 stringValue];
    NSString * value7String = [textfield7 stringValue];

    NSString * function = [transformDictionary objectForKey:@"function"];
    
    if ([function isEqualToString:@"translate"] == YES)
    {
        NSString * xString = [[NSString alloc] initWithString:value1String];
        [transformDictionary setObject:xString forKey:@"x"];
        [xString release];
        
        NSString * yString = [[NSString alloc] initWithString:value2String];
        [transformDictionary setObject:yString forKey:@"y"];
        [yString release];
    }
    else if ([function isEqualToString:@"scale"] == YES)
    {
        NSString * xString = [[NSString alloc] initWithString:value1String];
        [transformDictionary setObject:xString forKey:@"x"];
        [xString release];
        
        NSString * yString = [[NSString alloc] initWithString:value2String];
        [transformDictionary setObject:yString forKey:@"y"];
        [yString release];
    }
    else if ([function isEqualToString:@"rotate"] == YES)
    {
        NSString * degreesString = [[NSString alloc] initWithString:value1String];
        [transformDictionary setObject:degreesString forKey:@"degrees"];
        [degreesString release];
        
        NSString * xString = [[NSString alloc] initWithString:value2String];
        [transformDictionary setObject:xString forKey:@"x"];
        [xString release];
        
        NSString * yString = [[NSString alloc] initWithString:value3String];
        [transformDictionary setObject:yString forKey:@"y"];
        [yString release];
    }
    else if ([function isEqualToString:@"skewX"] == YES)
    {
        NSString * degreesString = [[NSString alloc] initWithString:value1String];
        [transformDictionary setObject:degreesString forKey:@"degrees"];
        [degreesString release];
    }
    else if ([function isEqualToString:@"skewY"] == YES)
    {
        NSString * degreesString = [[NSString alloc] initWithString:value1String];
        [transformDictionary setObject:degreesString forKey:@"degrees"];
        [degreesString release];
    }
*/

    [pathTableView reloadData];
    
    [self setTransformAttribute];
}

//==================================================================================
//	textFieldAction
//==================================================================================

- (IBAction)textFieldAction:(id)sender;
{
    NSInteger selectedRow = [pathTableView selectedRow];

    if (selectedRow != -1)
    {
        NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];

        NSMutableDictionary * pathSegmentDictionary = [pathSegmentsArray objectAtIndex:selectedRow];

        [self copyTextFieldValuesToTransformDictionary:pathSegmentDictionary];
    }    
}

//==================================================================================
//	setTransformAttribute
//==================================================================================

-(void) setTransformAttribute
{
    NSLog(@"PathPluginEditor - setTranformAttribute method needed here");
}

//==================================================================================
//	copyTextFieldValuesToTransformDictionary:
//==================================================================================

- (void)copyTextFieldValuesToTransformDictionary:(NSMutableDictionary *)transformDictionary
{
    NSLog(@"PathPluginEditor - copyTextFieldValuesToTransformDictionary method needed here");
}

//==================================================================================
//	highlightSegmentButtonAction:
//==================================================================================

- (IBAction)highlightSegmentButtonAction:(id)sender
{
    NSInteger selectedRow = [pathTableView selectedRow];

    NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];
    
    if (selectedRow != -1)
    {
        NSMutableString * newPathString = [NSMutableString string];
        
        NSMutableDictionary * pathSegmentDictionary = [pathSegmentsArray objectAtIndex:selectedRow];

        NSString * startXString = [pathSegmentDictionary objectForKey:@"x"];
        NSString * startYString = [pathSegmentDictionary objectForKey:@"y"];
        
        if (selectedRow > 0)
        {
            // get current starting point from previous segment
            
            NSMutableDictionary * previousPathSegmentDictionary = [pathSegmentsArray objectAtIndex:(selectedRow - 1)];

            startXString = [previousPathSegmentDictionary objectForKey:@"x"];
            startYString = [previousPathSegmentDictionary objectForKey:@"y"];
        }
        
        if ([startXString length] == 0)
        {
            startXString = @"0";
        }
        if ([startYString length] == 0)
        {
            startYString = @"0";
        }

        // move to initial position of segment
        [newPathString appendString:@"M"];

        [newPathString appendString:startXString];

        [newPathString appendString:@","];

        [newPathString appendString:startYString];
        
        [newPathString appendString:@" "];
        
        
        
        NSString * pathCommandString = [pathSegmentDictionary objectForKey:@"command"];
        unichar commandChar = [pathCommandString characterAtIndex:0];
        
        // draw the path segment
        switch (commandChar) 
        {
            case 'M':     // moveto
            case 'm':     // moveto
            {
                if (selectedRow == 0)
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
        
        MacSVGDocumentWindowController * macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
        
        [macSVGDocumentWindowController.svgXMLDOMSelectionManager.domSelectionRectsAndHandlesManager
                highlightPathSegmentInDOM:newPathString forDOMElement:self.pluginTargetDOMElement
                strokeWidth:0 strokeColor:@"#FF0000"];
    }
}

//==================================================================================
//	subdivideSegmentButtonAction:
//==================================================================================

- (IBAction)subdivideSegmentButtonAction:(id)sender
{
    // adapted from http://antigrain.com/research/adaptive_bezier/#toc0003
    // and http://www.ericeastwood.com/blog/25/curves-and-arcs-quadratic-cubic-elliptical-svg-implementations

    NSInteger selectedRow = [pathTableView selectedRow];

    NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];
    
    if (selectedRow != -1)
    {
        //NSMutableString * newPath1String = [NSMutableString string];
        //NSMutableString * newPath2String = [NSMutableString string];
        
        NSMutableDictionary * pathSegmentDictionary = [pathSegmentsArray objectAtIndex:selectedRow];

        NSMutableDictionary * newPathSegmentDictionary = [NSMutableDictionary dictionary];
        NSArray * allKeys = [pathSegmentDictionary allKeys];
        for (NSString * aKey in allKeys)
        {
            NSString * aValue = [pathSegmentDictionary objectForKey:aKey];
            NSString * copyValue = [aValue copy];
            [newPathSegmentDictionary setObject:copyValue forKey:aKey];
        }

        // get starting point of segment

        NSString * startXString = [pathSegmentDictionary objectForKey:@"x"];
        NSString * startYString = [pathSegmentDictionary objectForKey:@"y"];
        NSString * previousX1String = [pathSegmentDictionary objectForKey:@"x1"];
        NSString * previousY1String = [pathSegmentDictionary objectForKey:@"y1"];
        NSString * previousX2String = [pathSegmentDictionary objectForKey:@"x2"];
        NSString * previousY2String = [pathSegmentDictionary objectForKey:@"y2"];
        
        if (selectedRow > 0)
        {
            // get current starting point from previous segment
            
            NSMutableDictionary * previousPathSegmentDictionary = [pathSegmentsArray objectAtIndex:(selectedRow - 1)];

            startXString = [previousPathSegmentDictionary objectForKey:@"x"];
            startYString = [previousPathSegmentDictionary objectForKey:@"y"];
            previousX1String = [pathSegmentDictionary objectForKey:@"x1"];
            previousY1String = [pathSegmentDictionary objectForKey:@"y1"];
            previousX2String = [pathSegmentDictionary objectForKey:@"x2"];
            previousY2String = [pathSegmentDictionary objectForKey:@"y2"];
        }
        
        if ([startXString length] == 0)
        {
            startXString = @"0";
        }
        if ([startYString length] == 0)
        {
            startYString = @"0";
        }
        if ([previousX1String length] == 0)
        {
            previousX1String = @"0";
        }
        if ([previousY1String length] == 0)
        {
            previousY1String = @"0";
        }
        if ([previousX2String length] == 0)
        {
            previousX2String = @"0";
        }
        if ([previousY2String length] == 0)
        {
            previousY2String = @"0";
        }
        
        CGFloat startX = [startXString floatValue];
        CGFloat startY = [startYString floatValue];
        CGFloat previousX1 = [previousX1String floatValue];
        CGFloat previousY1 = [previousY1String floatValue];
        CGFloat previousX2 = [previousX2String floatValue];
        CGFloat previousY2 = [previousY2String floatValue];
        
        NSString * pathCommandString = [pathSegmentDictionary objectForKey:@"command"];
        unichar commandChar = [pathCommandString characterAtIndex:0];
        
        BOOL subdividablePathFound = NO;
        
        // define the path segment
        switch (commandChar) 
        {
            case 'M':     // absolute moveto
            case 'm':     // relative moveto
            {
                // we can't subdivide a move path segment
                
                subdividablePathFound = NO;
                
                break;
            }
            case 'L':     // absolute lineto
            case 'l':     // relative lineto
            {
                subdividablePathFound = YES;

                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                
                CGFloat x = [xString floatValue];
                CGFloat y = [yString floatValue];
                
                CGFloat midX = (x + startX) / 2.0f;
                CGFloat midY = (y + startY) / 2.0f;
                
                NSString * midXString = [self allocFloatString:midX];
                NSString * midYString = [self allocFloatString:midY];
                
                [pathSegmentDictionary setObject:midXString forKey:@"x"];
                [pathSegmentDictionary setObject:midYString forKey:@"y"];

                [newPathSegmentDictionary setObject:xString forKey:@"x"];
                [newPathSegmentDictionary setObject:yString forKey:@"y"];

                break;
            }
            case 'H':     // absolute horizontal lineto
            case 'h':     // absolute horizontal lineto
            {
                subdividablePathFound = YES;

                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                CGFloat x = [xString floatValue];

                CGFloat midX = (x + startX) / 2.0f;
                NSString * midXString = [self allocFloatString:midX];

                [pathSegmentDictionary setObject:midXString forKey:@"x"];
                [newPathSegmentDictionary setObject:xString forKey:@"x"];
                
                break;
            }
            case 'V':     // absolute vertical lineto
            case 'v':     // absolute vertical lineto
            {
                subdividablePathFound = YES;

                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                CGFloat y = [yString floatValue];

                CGFloat midY = (y + startY) / 2.0f;
                NSString * midYString = [self allocFloatString:midY];

                [pathSegmentDictionary setObject:midYString forKey:@"y"];
                [newPathSegmentDictionary setObject:yString forKey:@"y"];

                break;
            }
            case 'C':     // absolute cubic curveto
            case 'c':     // absolute cubic curveto
            {
                subdividablePathFound = YES;

                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                
                CGFloat x1 = [x1String floatValue];
                CGFloat y1 = [y1String floatValue];
                CGFloat x2 = [x2String floatValue];
                CGFloat y2 = [y2String floatValue];
                CGFloat x = [xString floatValue];
                CGFloat y = [yString floatValue];
                
                CGFloat x12 = (startX + x1) / 2.0f;
                CGFloat y12 = (startY + y1) / 2.0f;
                CGFloat x23 = (x1 + x2) / 2.0f;
                CGFloat y23 = (y1 + y2) / 2.0f;
                CGFloat x34 = (x2 + x) / 2.0f;
                CGFloat y34 = (y2 + y) / 2.0f;
                CGFloat x123  = (x12 + x23) / 2.0f;
                CGFloat y123  = (y12 + y23) / 2.0f;
                CGFloat x234  = (x23 + x34) / 2.0f;
                CGFloat y234  = (y23 + y34) / 2.0f;
                CGFloat x1234 = (x123 + x234) / 2.0f;
                CGFloat y1234 = (y123 + y234) / 2.0f;
                
                NSString * x12String = [self allocFloatString:x12];
                NSString * y12String = [self allocFloatString:y12];
                NSString * x23String = [self allocFloatString:x23];
                NSString * y23String = [self allocFloatString:y23];
                NSString * x34String = [self allocFloatString:x34];
                NSString * y34String = [self allocFloatString:y34];
                NSString * x123String = [self allocFloatString:x123];
                NSString * y123String = [self allocFloatString:y123];
                NSString * x234String = [self allocFloatString:x234];
                NSString * y234String = [self allocFloatString:y234];
                NSString * x1234String = [self allocFloatString:x1234];
                NSString * y1234String = [self allocFloatString:y1234];
                
                [pathSegmentDictionary setObject:x12String forKey:@"x1"];
                [pathSegmentDictionary setObject:y12String forKey:@"y1"];
                [pathSegmentDictionary setObject:x123String forKey:@"x2"];
                [pathSegmentDictionary setObject:y123String forKey:@"y2"];
                [pathSegmentDictionary setObject:x1234String forKey:@"x"];
                [pathSegmentDictionary setObject:y1234String forKey:@"y"];

                [newPathSegmentDictionary setObject:x234String forKey:@"x1"];
                [newPathSegmentDictionary setObject:y234String forKey:@"y1"];
                [newPathSegmentDictionary setObject:x34String forKey:@"x2"];
                [newPathSegmentDictionary setObject:y34String forKey:@"y2"];
                [newPathSegmentDictionary setObject:xString forKey:@"x"];
                [newPathSegmentDictionary setObject:yString forKey:@"y"];
                break;
            }
            case 'S':     // absolute smooth cubic curveto
            case 's':     // relative smooth cubic curveto
            {
                subdividablePathFound = YES;

                CGFloat x1 = startX - previousX1;
                CGFloat y1 = startY - previousY1;

                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                
                CGFloat x2 = [x2String floatValue];
                CGFloat y2 = [y2String floatValue];
                CGFloat x = [xString floatValue];
                CGFloat y = [yString floatValue];
                
                CGFloat x12 = (startX + x1) / 2.0f;
                CGFloat y12 = (startY + y1) / 2.0f;
                CGFloat x23 = (x1 + x2) / 2.0f;
                CGFloat y23 = (y1 + y2) / 2.0f;
                CGFloat x34 = (x2 + x) / 2.0f;
                CGFloat y34 = (y2 + y) / 2.0f;
                CGFloat x123  = (x12 + x23) / 2.0f;
                CGFloat y123  = (y12 + y23) / 2.0f;
                CGFloat x234  = (x23 + x34) / 2.0f;
                CGFloat y234  = (y23 + y34) / 2.0f;
                CGFloat x1234 = (x123 + x234) / 2.0f;
                CGFloat y1234 = (y123 + y234) / 2.0f;
                
                NSString * x12String = [self allocFloatString:x12];
                NSString * y12String = [self allocFloatString:y12];
                NSString * x23String = [self allocFloatString:x23];
                NSString * y23String = [self allocFloatString:y23];
                NSString * x34String = [self allocFloatString:x34];
                NSString * y34String = [self allocFloatString:y34];
                NSString * x123String = [self allocFloatString:x123];
                NSString * y123String = [self allocFloatString:y123];
                NSString * x234String = [self allocFloatString:x234];
                NSString * y234String = [self allocFloatString:y234];
                NSString * x1234String = [self allocFloatString:x1234];
                NSString * y1234String = [self allocFloatString:y1234];

                [pathSegmentDictionary setObject:x123String forKey:@"x2"];
                [pathSegmentDictionary setObject:y123String forKey:@"y2"];
                [pathSegmentDictionary setObject:x1234String forKey:@"x"];
                [pathSegmentDictionary setObject:y1234String forKey:@"y"];

                [newPathSegmentDictionary setObject:x34String forKey:@"x2"];
                [newPathSegmentDictionary setObject:y34String forKey:@"y2"];
                [newPathSegmentDictionary setObject:xString forKey:@"x"];
                [newPathSegmentDictionary setObject:yString forKey:@"y"];
                break;
            }
            case 'Q':     // absolute quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
            {
                subdividablePathFound = YES;

                NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];

                CGFloat x1 = [x1String floatValue];
                CGFloat y1 = [y1String floatValue];
                CGFloat x = [xString floatValue];
                CGFloat y = [yString floatValue];
                
                CGFloat control1MidpointX = (startX + x1) / 2.0f;
                CGFloat control1MidpointY = (startY + y1) / 2.0f;

                CGFloat control2MidpointX = (x1 + x) / 2.0f;
                CGFloat control2MidpointY = (x1 + x) / 2.0f;
                
                CGFloat midpointX = [self calculateQuadraticBezierParameterAtx0:startX x1:x1 x2:x t:0.5f];
                CGFloat midpointY = [self calculateQuadraticBezierParameterAtx0:startY x1:y1 x2:y t:0.5f];
                
                NSString * control1MidpointXString = [self allocFloatString:control1MidpointX];
                NSString * control1MidpointYString = [self allocFloatString:control1MidpointY];
                NSString * control2MidpointXString = [self allocFloatString:control2MidpointX];
                NSString * control2MidpointYString = [self allocFloatString:control2MidpointY];
                NSString * midpointXString = [self allocFloatString:midpointX];
                NSString * midpointYString = [self allocFloatString:midpointY];

                [pathSegmentDictionary setObject:control1MidpointXString forKey:@"x1"];
                [pathSegmentDictionary setObject:control1MidpointYString forKey:@"y1"];
                [pathSegmentDictionary setObject:midpointXString forKey:@"x"];
                [pathSegmentDictionary setObject:midpointYString forKey:@"y"];

                [newPathSegmentDictionary setObject:control2MidpointXString forKey:@"x1"];
                [newPathSegmentDictionary setObject:control2MidpointYString forKey:@"y1"];
                [newPathSegmentDictionary setObject:xString forKey:@"x"];
                [newPathSegmentDictionary setObject:yString forKey:@"y"];
                break;
            }
            case 'T':     // absolute smooth quadratic Bezier curve
            case 't':     // relative smooth quadratic Bezier curve
            {
                // this segment should probably be divided into three segments
            
                /*
                [newPathString appendString:@"t"];
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                [newPathString appendString:xString];
                [newPathString appendString:@","];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                [newPathString appendString:yString];
                [newPathString appendString:@" "];
                */
                break;
            }
            case 'A':     // absolute elliptical arc
            case 'a':     // relative elliptical arc
            {
                // TODO: this needs a midpoint x,y calculation

                subdividablePathFound = YES;
                
                NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                NSString * dataXAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                NSString * dataLargeArcString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                NSString * sweepString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
                NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                NSString * yString = [pathSegmentDictionary objectForKey:@"y"];

                CGFloat rx = [rxString floatValue];
                CGFloat ry = [ryString floatValue];
                CGFloat x = [xString floatValue];
                CGFloat y = [yString floatValue];
                CGFloat dataXAxisRotation = [dataXAxisRotationString floatValue];
                
                CGFloat halfDataXAxisRotation = dataXAxisRotation / 2.0f;
                
                NSString * halfDataXAxisRotationString = [NSString stringWithFormat:@"%f", halfDataXAxisRotation];

                /*
                [newPath1String appendString:@"a"];
                
                [newPath1String appendString:rxString];
                [newPath1String appendString:@","];
                [newPath1String appendString:ryString];
                [newPath1String appendString:@" "];
                
                [newPath1String appendString:halfDataXAxisRotationString];
                [newPath1String appendString:@" "];
                
                [newPath1String appendString:dataLargeArcString];
                [newPath1String appendString:@" "];
                
                [newPath1String appendString:sweepString];
                [newPath1String appendString:@" "];
                
                [newPath1String appendString:xString];
                [newPath1String appendString:@","];
                [newPath1String appendString:yString];
                [newPath1String appendString:@" "];


                [newPath2String appendString:@"a"];
                
                [newPath2String appendString:rxString];
                [newPath2String appendString:@","];
                [newPath2String appendString:ryString];
                [newPath2String appendString:@" "];
                
                [newPath2String appendString:halfDataXAxisRotationString];
                [newPath2String appendString:@" "];
                
                [newPath2String appendString:dataLargeArcString];
                [newPath2String appendString:@" "];
                
                [newPath2String appendString:sweepString];
                [newPath2String appendString:@" "];
                
                [newPath2String appendString:xString];
                [newPath2String appendString:@","];
                [newPath2String appendString:yString];
                [newPath2String appendString:@" "];
                */

                break;
            }
            case 'Z':     // absolute closepath
            case 'z':     // relative closepath
            {
                // we can't subdivide a close-path segment
                
                subdividablePathFound = NO;
                break;
            }
        }
        
        if (subdividablePathFound == YES)
        {
            /*
            [pathSegmentDictionary setObject:newPath1String forKey:@"d"];
            
            [newPathSegmentDictionary setObject:newPath2String forKey:@"d"];
            */

            [pathSegmentsArray insertObject:newPathSegmentDictionary atIndex:(selectedRow + 1)];
            
            [self.macSVGPluginCallbacks updatePathSegmentsAbsoluteValues:self.pathSegmentsArray];
            
            [self updateWithPathSegmentsArray:pathSegmentsArray];

            [pathTableView reloadData];
            
            [self updateDocumentViews];
        }
    }
}



//==================================================================================
//	updateWithPathSegmentsArray:
//==================================================================================

- (void)updateWithPathSegmentsArray:(NSMutableArray *)aPathSegmentsArray
{
    NSXMLElement * holdSelectedPathElement = [self.macSVGPluginCallbacks svgPathEditorSelectedPathElement];

    [self.macSVGPluginCallbacks svgPathEditorSetSelectedPathElement:self.pluginTargetXMLElement];
    
    [self.macSVGPluginCallbacks setPathSegmentsArray:aPathSegmentsArray];

    [self.macSVGPluginCallbacks updateSelectedPathInDOM];

    [self.macSVGPluginCallbacks svgPathEditorSetSelectedPathElement:holdSelectedPathElement];
}

//==================================================================================
//	calculateQuadraticBezierParameterAtx0:x1:x2:t:
//==================================================================================

- (CGFloat)calculateQuadraticBezierParameterAtx0:(CGFloat)x0 x1:(CGFloat)x1 x2:(CGFloat)x2 t:(CGFloat)t
{
    CGFloat result = pow(1-t, 2)*x0 + 2*t*(1-t)*x1 + pow(t, 2)*x2;
    
    return result;
}

/*
- (NSPoint)pointOnQuadraticBezierCurveAtp0:(NSPoint)p0 p1:(NSPoint)p1 p2:(NSPoint)p2 t:(CGFloat)t
{
    CGFloat x = [self calculateQuadraticBezierParameterAtx0:p0.x x1:p1.x x2:p2.x t:t];
    CGFloat y = [self calculateQuadraticBezierParameterAtx0:p0.y x1:p1.y x2:p2.y t:t];
    
    NSPoint resultPoint = NSMakePoint(x, y);
};
*/

@end