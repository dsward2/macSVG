//
//  SVGElementEditor.m
//  SVGElementEditor
//
//  Created by Douglas Ward on 7/17/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "SVGElementEditor.h"
#import "MacSVGPlugin/MacSVGPlugin.h"
#import "MacSVGPlugin/MacSVGPluginCallbacks.h"

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

- (instancetype)init
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
        result = self.pluginName;
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
    NSString * attributeString = attributeNode.stringValue;
    float attributeFloat = attributeString.floatValue;
    NSString * numericString = @"0";

    numericString = [NSString stringWithFormat:@"%f", attributeFloat];
    
    NSRange decimalPointRange = [numericString rangeOfString:@"."];
    if (decimalPointRange.location != NSNotFound)
    {
        NSInteger index = numericString.length - 1;
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
    
    if ((viewBoxWidthString.length > 0) && (viewBoxHeightString.length > 0))
    {
        float viewBoxWidth = viewBoxWidthString.floatValue;
        float viewBoxHeight = viewBoxHeightString.floatValue;
        
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
    NSString * scaleSetting = scalePopUpButton.titleOfSelectedItem;
    
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
        NSString * viewBoxValueString = viewBoxAttributeNode.stringValue;
    
        NSArray * viewBoxValuesArray = [viewBoxValueString componentsSeparatedByString:@" "];
        
        if (viewBoxValuesArray.count == 4)
        {
            NSString * viewBoxMinX = viewBoxValuesArray[0];
            NSString * viewBoxMinY = viewBoxValuesArray[1];
            NSString * viewBoxWidth = viewBoxValuesArray[2];
            NSString * viewBoxHeight = viewBoxValuesArray[3];
            
            viewBoxMinXTextField.stringValue = viewBoxMinX;
            viewBoxMinYTextField.stringValue = viewBoxMinY;
            viewBoxWidthTextField.stringValue = viewBoxWidth;
            viewBoxHeightTextField.stringValue = viewBoxHeight;
            
            viewBoxValuesSet = YES;
        }
    }
    
    if (viewBoxValuesSet == NO)
    {
        viewBoxMinXTextField.stringValue = @"";
        viewBoxMinYTextField.stringValue = @"";
        viewBoxWidthTextField.stringValue = @"";
        viewBoxHeightTextField.stringValue = @"";
    }

    NSXMLNode * widthAttributeNode = [self.pluginTargetXMLElement attributeForName:@"width"];
    if (widthAttributeNode != NULL)
    {
        NSString * widthValueString = [self numericStringWithAttributeNode:widthAttributeNode];
        
        if (widthValueString.length > 0)
        {
            widthAttributeTextField.stringValue = widthValueString;
            
            NSString * widthUnitString = [self unitForAttributeNode:widthAttributeNode];
            [widthUnitPopUpButton selectItemWithTitle:widthUnitString];
        }
    }
    else
    {
        widthAttributeTextField.stringValue = @"";
        [widthUnitPopUpButton selectItemWithTitle:@""];
    }

    NSXMLNode * heightAttributeNode = [self.pluginTargetXMLElement attributeForName:@"height"];
    if (heightAttributeNode != NULL)
    {
        NSString * heightValueString = [self numericStringWithAttributeNode:heightAttributeNode];
        
        if (heightValueString.length > 0)
        {
            heightAttributeTextField.stringValue = heightValueString;
            
            NSString * heightUnitString = [self unitForAttributeNode:heightAttributeNode];
            [heightUnitPopUpButton selectItemWithTitle:heightUnitString];
        }
    }
    else
    {
        heightAttributeTextField.stringValue = @"";
        [heightUnitPopUpButton selectItemWithTitle:@""];
    }
}

//==================================================================================
//	attributeString:endsWithSuffix:
//==================================================================================

- (BOOL)attributeString:(NSString *)attributeString endsWithSuffix:(NSString *)suffix
{
    BOOL result = NO;

    NSInteger attributeStringLength = attributeString.length;
    NSInteger suffixLength = suffix.length;
    
    if (attributeStringLength > suffixLength)
    {
        NSRange unitRange = [attributeString rangeOfString:suffix];
        
        if (unitRange.location == (attributeStringLength - suffixLength))
        {
            BOOL allNumericValue = YES;
            
            for (NSInteger i = 0; i < unitRange.location; i++)
            {
                unichar valueChar = [attributeString characterAtIndex:i];
                
                if ((valueChar < '0') || (valueChar > '9'))
                {
                    allNumericValue = NO;
                    break;
                }
            }
            
            if (allNumericValue == YES)
            {
                result = YES;
            }
        }
    }
    
    return result;
}

//==================================================================================
//	unitForAttributeNode:
//==================================================================================

- (NSString *)unitForAttributeNode:(NSXMLNode *)attributeNode
{
    NSString * attributeString = attributeNode.stringValue;

    NSString * resultUnit = NULL;

    if ([self attributeString:attributeString endsWithSuffix:@"em"] == YES)
    {
        resultUnit = @"em";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"ex"] == YES)
    {
        resultUnit = @"ex";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"px"] == YES)
    {
        resultUnit = @"px";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"pt"] == YES)
    {
        resultUnit = @"pt";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"pc"] == YES)
    {
        resultUnit = @"pc";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"cm"] == YES)
    {
        resultUnit = @"cm";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"mm"] == YES)
    {
        resultUnit = @"mm";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"in"] == YES)
    {
        resultUnit = @"in";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"h"] == YES)
    {
        resultUnit = @"h";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"min"] == YES)
    {
        resultUnit = @"min";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"s"] == YES)
    {
        resultUnit = @"s";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"%"] == YES)
    {
        resultUnit = @"%";
    }

    if (resultUnit == NULL)
    {
        resultUnit = @"";
    }
    
    return resultUnit;
}


//==================================================================================
//	updateAttributeValue
//==================================================================================

- (void)updateAttributeValue
{
    [self.macSVGPluginCallbacks pushUndoRedoDocumentChanges];

    NSXMLNode * viewBoxAttributeNode = [self.pluginTargetXMLElement attributeForName:@"viewBox"];
    
    if (viewBoxAttributeNode != NULL)
    {
        NSString * viewBoxMinX = viewBoxMinXTextField.stringValue;
        NSString * viewBoxMinY = viewBoxMinYTextField.stringValue;
        NSString * viewBoxWidth = viewBoxWidthTextField.stringValue;
        NSString * viewBoxHeight = viewBoxHeightTextField.stringValue;
        
        if ((viewBoxMinX.length > 0) && (viewBoxMinX.length > 0) &&
                (viewBoxMinX.length > 0) && (viewBoxMinX.length > 0))
        {
            NSString * viewBoxString = [NSString stringWithFormat:@"%@ %@ %@ %@",
                    viewBoxMinX, viewBoxMinY, viewBoxWidth, viewBoxHeight];
            
            viewBoxAttributeNode.stringValue = viewBoxString;
        }
    }

    NSString * widthString = widthAttributeTextField.stringValue;
    NSString * widthUnitString = widthUnitPopUpButton.titleOfSelectedItem;
    if (widthString.length > 0)
    {
        NSString * widthValue = [NSString stringWithFormat:@"%@%@", widthString, widthUnitString];
        NSXMLNode * widthAttributeNode = [self.pluginTargetXMLElement attributeForName:@"width"];
        if (widthAttributeNode == NULL)
        {
            widthAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            widthAttributeNode.name = @"width";
            widthAttributeNode.stringValue = @"";
            [self.pluginTargetXMLElement addAttribute:widthAttributeNode];
        }
        widthAttributeNode.stringValue = widthValue;
    }
    else
    {
        [self.pluginTargetXMLElement removeAttributeForName:@"width"];
    }

    NSString * heightString = heightAttributeTextField.stringValue;
    NSString * heightUnitString = heightUnitPopUpButton.titleOfSelectedItem;
    if (heightString.length > 0)
    {
        NSString * heightValue = [NSString stringWithFormat:@"%@%@", heightString, heightUnitString];
        NSXMLNode * heightAttributeNode = [self.pluginTargetXMLElement attributeForName:@"height"];
        if (heightAttributeNode == NULL)
        {
            heightAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            heightAttributeNode.name = @"height";
            heightAttributeNode.stringValue = @"";
            [self.pluginTargetXMLElement addAttribute:heightAttributeNode];
        }
        heightAttributeNode.stringValue = heightValue;
    }
    else
    {
        [self.pluginTargetXMLElement removeAttributeForName:@"height"];
    }
    
    [self updateDocumentViews];
}



@end
