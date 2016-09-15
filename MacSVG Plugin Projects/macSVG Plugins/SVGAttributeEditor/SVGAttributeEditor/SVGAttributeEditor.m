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
    
    result = [self pluginName];
    
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
//	unitForAttribute:
//==================================================================================

- (NSString *)unitForAttributeNode:(NSXMLNode *)attributeNode
{
    NSString * attributeString = [attributeNode stringValue];

    NSString * resultUnit = NULL;
    NSInteger attributeStringLength = [attributeString length];

    NSRange unitRange = NSMakeRange(NSNotFound, NSNotFound);
    
    NSRange lastCharactersRange = NSMakeRange(NSNotFound, NSNotFound);
    if (attributeStringLength >= 2)
    {
        lastCharactersRange = NSMakeRange(attributeStringLength - 2, 2);
    }
    if (attributeStringLength >= 3)
    {
        lastCharactersRange = NSMakeRange(attributeStringLength - 3, 3);
    }
    
    if (lastCharactersRange.location != NSNotFound)
    {
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
        unitRange = [attributeString rangeOfString:@"h"];
        if (unitRange.location != NSNotFound)
        {
            resultUnit = @"h";
        }
        unitRange = [attributeString rangeOfString:@"min"];
        if (unitRange.location != NSNotFound)
        {
            resultUnit = @"min";
        }
        unitRange = [attributeString rangeOfString:@"s"];
        if (unitRange.location != NSNotFound)
        {
            resultUnit = @"s";
        }
        unitRange = [attributeString rangeOfString:@"ms"];
        if (unitRange.location != NSNotFound)
        {
            resultUnit = @"ms";
        }
    }
    
    if (resultUnit == NULL)
    {
        if (attributeStringLength >= 2)
        {
            unichar lastCharacter = [attributeString characterAtIndex:(attributeStringLength - 1)];
            if (lastCharacter == '%')
            {
                resultUnit = @"%";
            }
        }
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
    NSString * attributeValueString = [attributeValueTextField stringValue];

    NSXMLNode * attributeNode = [self.pluginTargetXMLElement attributeForName:self.activeAttributeName];
    if (attributeNode != NULL)
    {
        NSString * attributeUnitString = [attributeUnitPopUpButton titleOfSelectedItem];
        
        if (attributeUnitString == NULL) attributeUnitString = @"";
        
        NSString * valueAndUnitString = [NSString stringWithFormat:@"%@%@",
                attributeValueString, attributeUnitString];
        [attributeNode setStringValue:valueAndUnitString];
    }
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber * aNumber = [numberFormatter numberFromString:attributeValueString];
    
    if (aNumber != NULL)
    {
        float attributeValueFloat = [attributeValueString floatValue];
        [attributeStepper setFloatValue:attributeValueFloat];
    }

    [self updateDocumentViews];
}

//==================================================================================
//	setDefinedValueButtonAction:
//==================================================================================

- (IBAction)setDefinedValueButtonAction:(id)sender
{
    NSString * definedValueString = [definedValuePopUpButton titleOfSelectedItem];
    
    [attributeValueTextField setStringValue:definedValueString];

    NSXMLNode * attributeNode = [self.pluginTargetXMLElement attributeForName:self.activeAttributeName];
    if (attributeNode != NULL)
    {
        [attributeNode setStringValue:definedValueString];
    }

    [self updateDocumentViews];
}

//==================================================================================
//	definedValuePopUpButtonAction:
//==================================================================================

- (IBAction)definedValuePopUpButtonAction:(id)sender
{
    NSMenuItem * selectedItem = [definedValuePopUpButton selectedItem];
    BOOL selectedItemIsEnabled = [selectedItem isEnabled];
    [setDefinedValueButton setEnabled:selectedItemIsEnabled];
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
    
    [attributeStepper setMinValue:minStepperValue];
    [attributeStepper setMaxValue:maxStepperValue];
    [attributeStepper setIncrement:stepperIncrement];
    
    [attributeStepper setFloatValue:stepperFloatValue];
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

    NSString * tagName = [newPluginTargetXMLElement name];
    
    NSString * elementName = NULL;
    
    NSString * idAttributeString = NULL;
    NSXMLNode * idAttributeNode = [newPluginTargetXMLElement attributeForName:@"id"];
    if (idAttributeNode != NULL)
    {
        idAttributeString = [idAttributeNode stringValue];
    }
    
    if (idAttributeString != NULL)
    {
        elementName = [NSString stringWithFormat:@"%@ (%@)", tagName, idAttributeString];
    }
    else
    {
        elementName = tagName;
    }

    [elementNameTextField setStringValue:elementName];

    [attributeNameTextField setStringValue:newAttributeName];
    
    NSMutableString * textFieldValue = [NSMutableString stringWithString:existingValue];
    
    NSXMLNode * editAttributeNode = [newPluginTargetXMLElement attributeForName:newAttributeName];
    if (editAttributeNode != NULL)
    {
        NSString * valueUnit = [self unitForAttributeNode:editAttributeNode];
        [attributeUnitPopUpButton selectItemWithTitle:valueUnit];
        
        if ([valueUnit isEqualToString:@""] == NO)
        {
            NSRange lastCharactersRange = NSMakeRange(NSNotFound, NSNotFound);
            NSInteger attributeStringLength = [textFieldValue length];
            if (attributeStringLength >= 2)
            {
                NSInteger valueUnitLength = [valueUnit length];
                lastCharactersRange = NSMakeRange(attributeStringLength - valueUnitLength, valueUnitLength);
                [textFieldValue deleteCharactersInRange:lastCharactersRange];
            }
        }
        
        float existingValueFloat = [textFieldValue floatValue];
        [self setStepperFloatValue:existingValueFloat attributeName:newAttributeName];
    }
    else
    {
        [attributeUnitPopUpButton selectItemAtIndex:0];
        //NSLog(@"beginEditForXMLElement:domElement:attributeName:existingValue: - missing attribute node");
    }
    
    [attributeValueTextField setStringValue:textFieldValue];
    
    [definedValuePopUpButton removeAllItems];
    
    BOOL definedItemsFound = NO;
    
    NSDictionary * aElementDictionary = [self.elementsDictionary objectForKey:tagName];
    if (aElementDictionary != NULL)
    {
        NSDictionary * elementAttributesDictionary = [aElementDictionary objectForKey:@"attributes"];
        
        if (elementAttributesDictionary != NULL)
        {
            NSDictionary * aAttributeDictionary = [elementAttributesDictionary objectForKey:newAttributeName];
            
            if (aAttributeDictionary != NULL)
            {
                NSArray * defaultValuesArray = [aAttributeDictionary objectForKey:@"default_value"];
                
                if (defaultValuesArray != NULL)
                {
                    for (NSString * aDefaultValue in defaultValuesArray)
                    {
                        if ([aDefaultValue length] > 0)
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

                NSArray * definedValuesArray = [aAttributeDictionary objectForKey:@"attribute_type"];
                if (definedValuesArray != NULL)
                {
                    NSInteger definedValuesArrayCount = [definedValuesArray count];
                    
                    if (definedValuesArrayCount > 0)
                    {
                        for (NSString * valueString in definedValuesArray)
                        {
                            if ([valueString length] > 0)
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
    
    NSMenuItem * selectedItem = [definedValuePopUpButton selectedItem];
    BOOL selectedItemIsEnabled = [selectedItem isEnabled];
    [setDefinedValueButton setEnabled:selectedItemIsEnabled];

    return result;
}

//==================================================================================
//	attributeStepperAction:
//==================================================================================

- (IBAction)attributeStepperAction:(id)sender
{
    NSString * attributeValueString = [attributeValueTextField stringValue];
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber * aNumber = [numberFormatter numberFromString:attributeValueString];
    
    if (aNumber != NULL)
    {
        [attributeValueTextField setStringValue:[attributeStepper stringValue]];

        [self setValueButtonAction:self];
    }
}

@end
