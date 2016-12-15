//
//  SVGAttributeEditor.m
//  SVGAttributeEditor
//
//  Created by Douglas Ward on 7/29/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "SVGAttributeEditor.h"

@implementation SVGAttributeEditor

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
    return @"SVG Attribute Editor";
}


//==================================================================================
//	loadPluginViewInScrollView:
//==================================================================================

- (BOOL)loadPluginViewInScrollView:(NSScrollView *)scrollView
{
    BOOL result = [super loadPluginViewInScrollView:scrollView];
        
    return result;
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
    
    result = self.pluginName;
    
    return result;
}

//==================================================================================
//	editorPriority:context:
//==================================================================================

- (NSInteger)editorPriority:(NSXMLElement *)targetElement context:(NSString *)context
{
    return 20;
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
//	unitForAttribute:
//==================================================================================

- (NSString *)unitForAttributeNode:(NSXMLNode *)attributeNode
{
    NSString * attributeString = attributeNode.stringValue;

    NSString * resultUnit = NULL;
    NSInteger attributeStringLength = attributeString.length;

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
//	setValueButtonAction:
//==================================================================================

- (IBAction)setValueButtonAction:(id)sender
{
    NSString * attributeValueString = attributeValueTextField.stringValue;

    NSXMLNode * attributeNode = [self.pluginTargetXMLElement attributeForName:self.activeAttributeName];
    if (attributeNode != NULL)
    {
        NSString * attributeUnitString = attributeUnitPopUpButton.titleOfSelectedItem;
        
        if (attributeUnitString == NULL) attributeUnitString = @"";
        
        NSString * valueAndUnitString = [NSString stringWithFormat:@"%@%@",
                attributeValueString, attributeUnitString];
        attributeNode.stringValue = valueAndUnitString;
    }
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber * aNumber = [numberFormatter numberFromString:attributeValueString];
    
    if (aNumber != NULL)
    {
        float attributeValueFloat = attributeValueString.floatValue;
        attributeStepper.floatValue = attributeValueFloat;
    }

    [self updateDocumentViews];
}

//==================================================================================
//	setDefinedValueButtonAction:
//==================================================================================

- (IBAction)setDefinedValueButtonAction:(id)sender
{
    NSString * definedValueString = definedValuePopUpButton.titleOfSelectedItem;
    
    attributeValueTextField.stringValue = definedValueString;

    NSXMLNode * attributeNode = [self.pluginTargetXMLElement attributeForName:self.activeAttributeName];
    if (attributeNode != NULL)
    {
        attributeNode.stringValue = definedValueString;
    }

    [self updateDocumentViews];
}

//==================================================================================
//	definedValuePopUpButtonAction:
//==================================================================================

- (IBAction)definedValuePopUpButtonAction:(id)sender
{
    NSMenuItem * selectedItem = definedValuePopUpButton.selectedItem;
    BOOL selectedItemIsEnabled = selectedItem.enabled;
    setDefinedValueButton.enabled = selectedItemIsEnabled;
}

//==================================================================================
//	setStepperFloat:tagName:
//==================================================================================

- (void)setStepperFloatValue:(float)stepperFloatValue attributeName:(NSString *)attributeName
{
    float minStepperValue = -1000000.0f;
    float maxStepperValue = 1000000.0f;
    float stepperIncrement = 1.0f;
    
    NSRange opacityRange = [attributeName rangeOfString:@"opacity"];
    if (opacityRange.location != NSNotFound)
    {
        minStepperValue = 0.0f;
        maxStepperValue = 1.0f;
        stepperIncrement = 0.01f;
    }
    
    NSRange widthRange = [attributeName rangeOfString:@"width"];
    if (widthRange.location != NSNotFound)
    {
        minStepperValue = 0.0f;
        maxStepperValue = 1000000.0f;
        stepperIncrement = 0.5f;
    }
    
    attributeStepper.minValue = minStepperValue;
    attributeStepper.maxValue = maxStepperValue;
    attributeStepper.increment = stepperIncrement;
    
    attributeStepper.floatValue = stepperFloatValue;
}

//==================================================================================
//	beginEditForXMLElement:domElement:attributeName:existingValue:
//==================================================================================

- (BOOL)beginEditForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetDOMElement
        attributeName:(NSString *)newAttributeName
        existingValue:(NSString *)existingValue
{
    BOOL result = [super beginEditForXMLElement:newPluginTargetXMLElement
            domElement:newPluginTargetDOMElement attributeName:newAttributeName
            existingValue:existingValue];

    [definedValuePopUpButton setAutoenablesItems:NO];

    NSString * tagName = newPluginTargetXMLElement.name;
    
    NSString * elementName = NULL;
    
    NSString * idAttributeString = NULL;
    NSXMLNode * idAttributeNode = [newPluginTargetXMLElement attributeForName:@"id"];
    if (idAttributeNode != NULL)
    {
        idAttributeString = idAttributeNode.stringValue;
    }
    
    if (idAttributeString != NULL)
    {
        elementName = [NSString stringWithFormat:@"%@ (%@)", tagName, idAttributeString];
    }
    else
    {
        elementName = tagName;
    }

    elementNameTextField.stringValue = elementName;

    attributeNameTextField.stringValue = newAttributeName;
    
    NSMutableString * textFieldValue = [NSMutableString stringWithString:existingValue];
    
    NSXMLNode * editAttributeNode = [newPluginTargetXMLElement attributeForName:newAttributeName];
    if (editAttributeNode != NULL)
    {
        NSString * valueUnit = [self unitForAttributeNode:editAttributeNode];
        [attributeUnitPopUpButton selectItemWithTitle:valueUnit];
        
        if ([valueUnit isEqualToString:@""] == NO)
        {
            NSRange lastCharactersRange = NSMakeRange(NSNotFound, NSNotFound);
            NSInteger attributeStringLength = textFieldValue.length;
            if (attributeStringLength >= 2)
            {
                NSInteger valueUnitLength = valueUnit.length;
                lastCharactersRange = NSMakeRange(attributeStringLength - valueUnitLength, valueUnitLength);
                [textFieldValue deleteCharactersInRange:lastCharactersRange];
            }
        }
        
        float existingValueFloat = textFieldValue.floatValue;
        [self setStepperFloatValue:existingValueFloat attributeName:newAttributeName];
    }
    else
    {
        [attributeUnitPopUpButton selectItemAtIndex:0];
        //NSLog(@"beginEditForXMLElement:domElement:attributeName:existingValue: - missing attribute node");
    }
    
    attributeValueTextField.stringValue = textFieldValue;
    
    [definedValuePopUpButton removeAllItems];
    
    BOOL definedItemsFound = NO;
    
    NSDictionary * aElementDictionary = (self.elementsDictionary)[tagName];
    if (aElementDictionary != NULL)
    {
        NSDictionary * elementAttributesDictionary = aElementDictionary[@"attributes"];
        
        if (elementAttributesDictionary != NULL)
        {
            NSDictionary * aAttributeDictionary = elementAttributesDictionary[newAttributeName];
            
            if (aAttributeDictionary != NULL)
            {
                NSArray * defaultValuesArray = aAttributeDictionary[@"default_value"];
                
                if (defaultValuesArray != NULL)
                {
                    for (NSString * aDefaultValue in defaultValuesArray)
                    {
                        if (aDefaultValue.length > 0)
                        {
                            NSMenuItem * existingMenuItem = [definedValuePopUpButton itemWithTitle:aDefaultValue];
                            
                            if (existingMenuItem == NULL)
                            {
                                [definedValuePopUpButton addItemWithTitle:aDefaultValue];
                                
                                BOOL disableMenuItem = NO;
                                
                                unichar firstChar = [aDefaultValue characterAtIndex:0];
                                if (firstChar == '#')
                                {
                                    disableMenuItem = YES;
                                }
                                
                                if ([aDefaultValue isEqualToString:@"ID"] == YES)
                                {
                                    disableMenuItem = YES;
                                }
                                
                                if (disableMenuItem == YES)
                                {
                                    NSMenuItem * aMenuItem = [definedValuePopUpButton itemWithTitle:aDefaultValue];
                                    [aMenuItem setEnabled:NO];
                                }
                                else
                                {
                                    definedItemsFound = YES;
                                }
                            }
                        }
                    }
                }

                NSArray * definedValuesArray = aAttributeDictionary[@"attribute_type"];
                if (definedValuesArray != NULL)
                {
                    NSInteger definedValuesArrayCount = definedValuesArray.count;
                    
                    if (definedValuesArrayCount > 0)
                    {
                        for (NSString * valueString in definedValuesArray)
                        {
                            if (valueString.length > 0)
                            {
                                NSMenuItem * aMenuItem = [definedValuePopUpButton itemWithTitle:valueString];
                                
                                if (aMenuItem == NULL)
                                {
                                    definedItemsFound = YES;
                                    
                                    [definedValuePopUpButton addItemWithTitle:valueString];
                                    
                                    BOOL disableMenuItem = NO;
                                    
                                    unichar firstChar = [valueString characterAtIndex:0];
                                    if (firstChar == '#')
                                    {
                                        if ([valueString isEqualToString:@"#000000"] == NO)
                                        {
                                            disableMenuItem = YES;
                                        }
                                    }
                                    
                                    if ([valueString isEqualToString:@"CDATA"])
                                    {
                                        disableMenuItem = YES;
                                    }

                                    if (disableMenuItem == YES)
                                    {
                                        NSMenuItem * aMenuItem = [definedValuePopUpButton itemWithTitle:valueString];
                                        [aMenuItem setEnabled:NO];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    if (definedItemsFound == YES)
    {
        NSMenuItem * aMenuItem = [definedValuePopUpButton itemWithTitle:existingValue];
        if (aMenuItem != NULL)
        {
            [definedValuePopUpButton selectItem:aMenuItem];
        }
    }
    else
    {
        NSString * noValuesString = @"(No values defined)";
        [definedValuePopUpButton addItemWithTitle:noValuesString];
        NSMenuItem * aMenuItem = [definedValuePopUpButton itemWithTitle:noValuesString];
        [aMenuItem setEnabled:NO];
    }
    
    NSMenuItem * selectedItem = definedValuePopUpButton.selectedItem;
    BOOL selectedItemIsEnabled = selectedItem.enabled;
    setDefinedValueButton.enabled = selectedItemIsEnabled;

    return result;
}

//==================================================================================
//	attributeStepperAction:
//==================================================================================

- (IBAction)attributeStepperAction:(id)sender
{
    NSString * attributeValueString = attributeValueTextField.stringValue;
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber * aNumber = [numberFormatter numberFromString:attributeValueString];
    
    if (aNumber != NULL)
    {
        attributeValueTextField.stringValue = attributeStepper.stringValue;

        [self setValueButtonAction:self];
    }
}

@end
