//
//  SVGElementEditor.m
//  SVGElementEditor
//
//  Created by Douglas Ward on 7/17/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "SVGElementEditor.h"
#import "MacSVGPlugin/MacSVGPlugin.h"

@implementation SVGElementEditor

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
}

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
    return @"SVG Element Editor";
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element tag name
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    NSString * result = NULL;

    if ([elementName isEqualToString:@"svg"] == YES)
    {
        result = [self pluginName];
    }

    return result;
}

//==================================================================================
//	isEditorForElement:elementName:attribute:
//==================================================================================

// return label if this editor can edit specified element and attribute
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName attribute:(NSString *)attributeName
{   
    NSString * result = NULL;
    
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
//	numericStringWithAttributeNode
//==================================================================================

- (NSString *)numericStringWithAttributeNode:(NSXMLNode *)attributeNode
{
    NSString * attributeString = [attributeNode stringValue];
    float attributeFloat = [attributeString floatValue];
    NSString * numericString = @"0";

    numericString = [NSString stringWithFormat:@"%f", attributeFloat];
    
    NSRange decimalPointRange = [numericString rangeOfString:@"."];
    if (decimalPointRange.location != NSNotFound)
    {
        NSInteger index = [numericString length] - 1;
        BOOL continueTrim = YES;
        while (continueTrim == YES)
        {
            if ([numericString characterAtIndex:index] == '0')
            {
                index--;
            }
            else if ([numericString characterAtIndex:index] == '.')
            {
                index--;
                continueTrim = NO;
            }
            else
            {
                continueTrim = NO;
            }
            
            if (index < decimalPointRange.location)
            {
                continueTrim = NO;
            }
        }
        
        numericString = [numericString substringToIndex:index + 1];
    }
    

    return numericString;
}

//==================================================================================
//	scaleWidthHeightToViewBox:
//==================================================================================

- (void)scaleWidthHeightToViewBox:(float)scaleFactor
{
    NSString * viewBoxWidthString = viewBoxWidthTextField.stringValue;
    NSString * viewBoxHeightString = viewBoxHeightTextField.stringValue;
    
    if (([viewBoxWidthString length] > 0) && ([viewBoxHeightString length] > 0))
    {
        float viewBoxWidth = [viewBoxWidthString floatValue];
        float viewBoxHeight = [viewBoxHeightString floatValue];
        
        float widthAttributeFloat = viewBoxWidth * scaleFactor;
        float heightAttributeFloat = viewBoxHeight * scaleFactor;
        
        NSInteger widthAttribute = widthAttributeFloat;
        NSInteger heightAttribute = heightAttributeFloat;
        
        if ((widthAttribute > 0) && (heightAttribute > 0))
        {
            NSString * widthAttributeString = [NSString stringWithFormat:@"%ld", (long)widthAttribute];
            NSString * heightAttributeString = [NSString stringWithFormat:@"%ld", (long)heightAttribute];
            
            widthAttributeTextField.stringValue = widthAttributeString;
            heightAttributeTextField.stringValue = heightAttributeString;
            
            [self updateAttributeValue];
        }
        else
        {
            NSBeep();
        }
    }
    else
    {
        NSBeep();
    }
}

//==================================================================================
//	scalePopUpButtonAction:
//==================================================================================

- (IBAction)scalePopUpButtonAction:(id)sender
{
    NSString * scaleSetting = [scalePopUpButton titleOfSelectedItem];
    
    if ([scaleSetting isEqualToString:@"Original Scale"] == YES)
    {
        // no action required
    }
    else if ([scaleSetting isEqualToString:@"12.5%"] == YES)
    {
        [self scaleWidthHeightToViewBox:0.125f];
    }
    else if ([scaleSetting isEqualToString:@"25%"] == YES)
    {
        [self scaleWidthHeightToViewBox:0.25f];
    }
    else if ([scaleSetting isEqualToString:@"50%"] == YES)
    {
        [self scaleWidthHeightToViewBox:0.5f];
    }
    else if ([scaleSetting isEqualToString:@"100%"] == YES)
    {
        [self scaleWidthHeightToViewBox:1.0f];
    }
    else if ([scaleSetting isEqualToString:@"200%"] == YES)
    {
        [self scaleWidthHeightToViewBox:2.0f];
    }
    else if ([scaleSetting isEqualToString:@"400%"] == YES)
    {
        [self scaleWidthHeightToViewBox:4.0f];
    }
    else if ([scaleSetting isEqualToString:@"800%"] == YES)
    {
        [self scaleWidthHeightToViewBox:8.0f];
    }
    else if ([scaleSetting isEqualToString:@"1600%"] == YES)
    {
        [self scaleWidthHeightToViewBox:16.0f];
    }
}

//==================================================================================
//	saveChangesButtonAction:
//==================================================================================

- (IBAction)saveChangesButtonAction:(id)sender
{
    [self updateAttributeValue];
    //[self scalePopUpButtonAction:self];
}

//==================================================================================
//	revertButtonAction:
//==================================================================================

- (IBAction)revertButtonAction:(id)sender
{
    [self loadSettingsForElement];
}

//==================================================================================
//	beginEditForXMLElement:domElement:
//==================================================================================

- (BOOL)beginEditForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetDOMElement
{
    BOOL result = [super beginEditForXMLElement:newPluginTargetXMLElement
            domElement:newPluginTargetDOMElement];

    [self loadSettingsForElement];
            
    return result;
}

//==================================================================================
//	loadSettingsForElement
//==================================================================================

- (void) loadSettingsForElement
{
    [scalePopUpButton selectItemAtIndex:0];
    
    BOOL viewBoxValuesSet = NO;
    
    NSXMLNode * viewBoxAttributeNode = [self.pluginTargetXMLElement attributeForName:@"viewBox"];
    if (viewBoxAttributeNode != NULL)
    {
        NSString * viewBoxValueString = [viewBoxAttributeNode stringValue];
    
        NSArray * viewBoxValuesArray = [viewBoxValueString componentsSeparatedByString:@" "];
        
        if ([viewBoxValuesArray count] == 4)
        {
            NSString * viewBoxMinX = [viewBoxValuesArray objectAtIndex:0];
            NSString * viewBoxMinY = [viewBoxValuesArray objectAtIndex:1];
            NSString * viewBoxWidth = [viewBoxValuesArray objectAtIndex:2];
            NSString * viewBoxHeight = [viewBoxValuesArray objectAtIndex:3];
            
            [viewBoxMinXTextField setStringValue:viewBoxMinX];
            [viewBoxMinYTextField setStringValue:viewBoxMinY];
            [viewBoxWidthTextField setStringValue:viewBoxWidth];
            [viewBoxHeightTextField setStringValue:viewBoxHeight];
            
            viewBoxValuesSet = YES;
        }
    }
    
    if (viewBoxValuesSet == NO)
    {
        [viewBoxMinXTextField setStringValue:@""];
        [viewBoxMinYTextField setStringValue:@""];
        [viewBoxWidthTextField setStringValue:@""];
        [viewBoxHeightTextField setStringValue:@""];
    }

    NSXMLNode * widthAttributeNode = [self.pluginTargetXMLElement attributeForName:@"width"];
    if (widthAttributeNode != NULL)
    {
        NSString * widthValueString = [self numericStringWithAttributeNode:widthAttributeNode];
        
        if ([widthValueString length] > 0)
        {
            [widthAttributeTextField setStringValue:widthValueString];
            
            NSString * widthUnitString = [self unitForAttributeNode:widthAttributeNode];
            [widthUnitPopUpButton selectItemWithTitle:widthUnitString];
        }
    }
    else
    {
        [widthAttributeTextField setStringValue:@""];
        [widthUnitPopUpButton selectItemWithTitle:@""];
    }

    NSXMLNode * heightAttributeNode = [self.pluginTargetXMLElement attributeForName:@"height"];
    if (heightAttributeNode != NULL)
    {
        NSString * heightValueString = [self numericStringWithAttributeNode:heightAttributeNode];
        
        if ([heightValueString length] > 0)
        {
            [heightAttributeTextField setStringValue:heightValueString];
            
            NSString * heightUnitString = [self unitForAttributeNode:heightAttributeNode];
            [heightUnitPopUpButton selectItemWithTitle:heightUnitString];
        }
    }
    else
    {
        [heightAttributeTextField setStringValue:@""];
        [heightUnitPopUpButton selectItemWithTitle:@""];
    }
}

//==================================================================================
//	unitForAttribute:
//==================================================================================

- (NSString *)unitForAttributeNode:(NSXMLNode *)attributeNode
{
    NSString * attributeString = [attributeNode stringValue];

    NSString * resultUnit = @"";
    NSRange unitRange = NSMakeRange(NSNotFound, NSNotFound);
    
    unitRange = [attributeString rangeOfString:@"%"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"%";
    }
    unitRange = [attributeString rangeOfString:@"em"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"em";
    }
    unitRange = [attributeString rangeOfString:@"ex"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"ex";
    }
    unitRange = [attributeString rangeOfString:@"px"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"px";
    }
    unitRange = [attributeString rangeOfString:@"pt"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"pt";
    }
    unitRange = [attributeString rangeOfString:@"pc"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"pc";
    }
    unitRange = [attributeString rangeOfString:@"cm"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"cm";
    }
    unitRange = [attributeString rangeOfString:@"mm"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"mm";
    }
    unitRange = [attributeString rangeOfString:@"in"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"in";
    }
    
    return resultUnit;
}

//==================================================================================
//	updateAttributeValue
//==================================================================================

- (void)updateAttributeValue
{
    NSXMLNode * viewBoxAttributeNode = [self.pluginTargetXMLElement attributeForName:@"viewBox"];
    
    if (viewBoxAttributeNode != NULL)
    {
        NSString * viewBoxMinX = [viewBoxMinXTextField stringValue];
        NSString * viewBoxMinY = [viewBoxMinYTextField stringValue];
        NSString * viewBoxWidth = [viewBoxWidthTextField stringValue];
        NSString * viewBoxHeight = [viewBoxHeightTextField stringValue];
        
        if (([viewBoxMinX length] > 0) && ([viewBoxMinX length] > 0) &&
                ([viewBoxMinX length] > 0) && ([viewBoxMinX length] > 0))
        {
            NSString * viewBoxString = [NSString stringWithFormat:@"%@ %@ %@ %@",
                    viewBoxMinX, viewBoxMinY, viewBoxWidth, viewBoxHeight];
            
            [viewBoxAttributeNode setStringValue:viewBoxString];
        }
    }

    NSString * widthString = [widthAttributeTextField stringValue];
    NSString * widthUnitString = [widthUnitPopUpButton titleOfSelectedItem];
    if ([widthString length] > 0)
    {
        NSString * widthValue = [NSString stringWithFormat:@"%@%@", widthString, widthUnitString];
        NSXMLNode * widthAttributeNode = [self.pluginTargetXMLElement attributeForName:@"width"];
        if (widthAttributeNode == NULL)
        {
            widthAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            [widthAttributeNode setName:@"width"];
            [widthAttributeNode setStringValue:@""];
            [self.pluginTargetXMLElement addAttribute:widthAttributeNode];
        }
        [widthAttributeNode setStringValue:widthValue];
    }
    else
    {
        [self.pluginTargetXMLElement removeAttributeForName:@"width"];
    }

    NSString * heightString = [heightAttributeTextField stringValue];
    NSString * heightUnitString = [heightUnitPopUpButton titleOfSelectedItem];
    if ([heightString length] > 0)
    {
        NSString * heightValue = [NSString stringWithFormat:@"%@%@", heightString, heightUnitString];
        NSXMLNode * heightAttributeNode = [self.pluginTargetXMLElement attributeForName:@"height"];
        if (heightAttributeNode == NULL)
        {
            heightAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            [heightAttributeNode setName:@"height"];
            [heightAttributeNode setStringValue:@""];
            [self.pluginTargetXMLElement addAttribute:heightAttributeNode];
        }
        [heightAttributeNode setStringValue:heightValue];
    }
    else
    {
        [self.pluginTargetXMLElement removeAttributeForName:@"height"];
    }
    
    [self updateDocumentViews];
}



@end
