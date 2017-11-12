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
        
        self.comboBoxValuesArray = [NSMutableArray array];
        self.iriReferencesArray = [NSMutableArray array];
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
                    if (valueChar != '.')
                    {
                        allNumericValue = NO;
                        break;
                    }
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
//	unitForAttributeString:
//==================================================================================

- (NSString *)unitForAttributeString:(NSString *)attributeString
{
    //NSString * attributeString = attributeNode.stringValue;

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
//	setValueButtonAction:
//==================================================================================

- (IBAction)setValueButtonAction:(id)sender
{
    NSString * attributeValueString = attributeValueComboBox.stringValue;

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
//	setComboBoxAndUnit:
//==================================================================================

- (void)setComboBoxAndUnit:(NSString *)stringValue attributeName:(NSString *)attributeName
{
    NSMutableString * textFieldValue = [stringValue mutableCopy];

    if (stringValue.length > 0)
    {
        NSString * valueUnit = [self unitForAttributeString:stringValue];
        [attributeUnitPopUpButton selectItemWithTitle:valueUnit];
        
        if ([valueUnit isEqualToString:@""] == NO)
        {
            NSRange lastCharactersRange = NSMakeRange(NSNotFound, NSNotFound);
            NSInteger attributeStringLength = stringValue.length;
            if (attributeStringLength >= 2)
            {
                NSInteger valueUnitLength = valueUnit.length;
                lastCharactersRange = NSMakeRange(attributeStringLength - valueUnitLength, valueUnitLength);
                [textFieldValue deleteCharactersInRange:lastCharactersRange];
            }
        }
        
        float existingValueFloat = textFieldValue.floatValue;
        
        [self setStepperFloatValue:existingValueFloat attributeName:attributeName];
    }
    else
    {
        [attributeUnitPopUpButton selectItemAtIndex:0];
    }

    attributeValueComboBox.stringValue = textFieldValue;
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
    if (opacityRange.location == 0)
    {
        minStepperValue = 0.0f;
        maxStepperValue = 1.0f;
        stepperIncrement = 0.01f;
    }
    
    NSRange widthRange = [attributeName rangeOfString:@"width"];
    if (widthRange.location == 0)
    {
        minStepperValue = 0.0f;
        maxStepperValue = 1000000.0f;
        stepperIncrement = 0.5f;
    }
    
    NSRange heightRange = [attributeName rangeOfString:@"height"];
    if (heightRange.location == 0)
    {
        minStepperValue = 0.0f;
        maxStepperValue = 1000000.0f;
        stepperIncrement = 0.5f;
    }
    
    NSRange strokeWidthRange = [attributeName rangeOfString:@"stroke-width"];
    if (strokeWidthRange.location == 0)
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

    self.comboBoxValuesArray = [NSMutableArray array];
    self.iriReferencesArray = [NSMutableArray array];

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
    
    //NSMutableString * textFieldValue = [NSMutableString stringWithString:existingValue];
    
    //NSXMLNode * editAttributeNode = [newPluginTargetXMLElement attributeForName:newAttributeName];
    
    //attributeValueComboBox.stringValue = textFieldValue;
    
    //[self setComboBoxAndUnit:textFieldValue];
    
    [self.comboBoxValuesArray removeAllObjects];
    
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
                            NSInteger existingComboBoxIndex = [self indexOfComboBoxItem:aDefaultValue];

                            NSString * enableMenuItem = @"1";

                            if (existingComboBoxIndex < 0)
                            {
                                unichar firstChar = [aDefaultValue characterAtIndex:0];
                                if (firstChar == '#')
                                {
                                    enableMenuItem = @"0";
                                }
                                
                                if ([aDefaultValue isEqualToString:@"ID"] == YES)
                                {
                                    enableMenuItem = @"0";
                                }
                            }
                            
                            [self addComboBoxItem:aDefaultValue enable:enableMenuItem];
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
                                NSInteger existingComboBoxIndex = [self indexOfComboBoxItem:valueString];

                                NSString * enableMenuItem = @"1";

                                if (existingComboBoxIndex < 0)
                                {
                                    definedItemsFound = YES;

                                    unichar firstChar = [valueString characterAtIndex:0];
                                    if (firstChar == '#')
                                    {
                                        if ([valueString isEqualToString:@"#000000"] == NO)
                                        {
                                            enableMenuItem = @"0";
                                        }
                                    }
                                    
                                    if ([valueString isEqualToString:@"CDATA"] == YES)
                                    {
                                        enableMenuItem = @"0";
                                    }
                                }
                                
                                [self addComboBoxItem:valueString enable:enableMenuItem];
                            }
                        }
                    }
                }
            }
        }
    }

    [self buildIRIReferencesArrayForXMLElement:newPluginTargetXMLElement domElement:newPluginTargetDOMElement
            attributeName:newAttributeName existingValue:existingValue];
    
    BOOL dividerWasAdded = NO;
    
    for (NSXMLElement * aXMLElement in self.iriReferencesArray)
    {
        //NSLog(@"aXMLElement=%@", aXMLElement);
        NSXMLNode * idAttributeNode = [aXMLElement attributeForName:@"id"];
        
        if (idAttributeNode != NULL)
        {
            NSString * idAttributeString = idAttributeNode.stringValue;
            if (idAttributeString.length > 0)
            {
                if (dividerWasAdded == NO)
                {
                    //[self addComboBoxItem:@"-" enable:@"0"];
                    
                    dividerWasAdded = YES;
                }
            
                NSString * valueString = [NSString stringWithFormat:@"url(#%@)", idAttributeString];

                [self addComboBoxItem:valueString enable:@"1"];
            }
        }
    }
    
    if (definedItemsFound == YES)
    {
        //attributeValueComboBox.stringValue = existingValue;
        
        [self setComboBoxAndUnit:existingValue attributeName:newAttributeName];
    }
    else
    {
        //[self addComboBoxItem:@"(No values defined)" enable:@"0"];
        //attributeValueComboBox.stringValue = @"";

        [self setComboBoxAndUnit:@"" attributeName:@""];
    }
    
    [self itemTextFieldUpdated:self];
    
    return result;
}

//==================================================================================
//	indexOfComboBoxItem:
//==================================================================================

- (NSInteger)indexOfComboBoxItem:(NSString *)valueString
{
    NSInteger result = -1;
    
    for (NSDictionary * itemDictionary in self.comboBoxValuesArray)
    {
        NSString * aValueString = [itemDictionary objectForKey:@"value"];
        
        if ([valueString isEqualToString:aValueString] == YES)
        {
            result = [self.comboBoxValuesArray indexOfObject:itemDictionary];
            break;
        }
    }

    return result;
}

//==================================================================================
//	addComboBoxItem:enable:
//==================================================================================

- (void) addComboBoxItem:(NSString *)aDefaultValue enable:(NSString *)enableMenuItem
{
    if ([enableMenuItem isEqualToString:@"1"] == YES)
    {
        NSMutableDictionary * itemDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                aDefaultValue, @"value",
                enableMenuItem, @"enable",
                NULL];
        
        [self.comboBoxValuesArray addObject:itemDictionary];
    }
}

//==================================================================================
//	attributeStepperAction:
//==================================================================================

- (IBAction)attributeStepperAction:(id)sender
{
    NSString * attributeValueString = attributeValueComboBox.stringValue;
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber * aNumber = [numberFormatter numberFromString:attributeValueString];
    
    if (aNumber != NULL)
    {
        attributeValueComboBox.stringValue = attributeStepper.stringValue;

        [self setValueButtonAction:self];
    }
}

//==================================================================================
//	buildIRIReferencesArrayForXMLElement:domElement:attributeName:existingValue:
//==================================================================================

- (void)buildIRIReferencesArrayForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetDOMElement
        attributeName:(NSString *)newAttributeName
        existingValue:(NSString *)existingValue
{
    NSString * xpathQuery = @"*";

    NSString * elementName = newPluginTargetXMLElement.name;

    // check elements first
    if ([elementName isEqualToString:@"a"] == YES)
    {
        xpathQuery = @"*";
    }
    else if ([elementName isEqualToString:@"altGlyph"] == YES)
    {
        xpathQuery = @".//altGlyphDef|.//glyph";
    }
    else if ([elementName isEqualToString:@"animate"] == YES)
    {
        xpathQuery = @"*";
    }
    else if ([elementName isEqualToString:@"animateColor"] == YES)
    {
        xpathQuery = @"*";
    }
    else if ([elementName isEqualToString:@"animateMotion"] == YES)
    {
        xpathQuery = @"*";
    }
    else if ([elementName isEqualToString:@"animateTransform"] == YES)
    {
        xpathQuery = @"*";
    }
    else if ([elementName isEqualToString:@"color-profile"] == YES)
    {
        xpathQuery = @"*";      // TODO: FIXME:
    }
    else if ([elementName isEqualToString:@"cursor"] == YES)
    {
        xpathQuery = @".//cursor";
    }
    else if ([elementName isEqualToString:@"feImage"] == YES)
    {
        xpathQuery = @"*";
    }
    else if ([elementName isEqualToString:@"filter"] == YES)
    {
        xpathQuery = @".//filter";
    }
    else if ([elementName isEqualToString:@"image"] == YES)
    {
        xpathQuery = @"*";
    }
    else if ([elementName isEqualToString:@"linearGradient"] == YES)
    {
        xpathQuery = @".//linearGradient|.//radialGradient";
    }
    else if ([elementName isEqualToString:@"marker"] == YES)
    {
        xpathQuery = @".//marker";
    }
    else if ([elementName isEqualToString:@"pattern"] == YES)
    {
        xpathQuery = @".//pattern";
    }
    else if ([elementName isEqualToString:@"radialGradient"] == YES)
    {
        xpathQuery = @".//linearGradient|.//radialGradient";
    }
    else if ([elementName isEqualToString:@"script"] == YES)
    {
        xpathQuery = @"";   // TODO: FIXME:
    }
    else if ([elementName isEqualToString:@"textPath"] == YES)
    {
        xpathQuery = @".//path";
    }
    else if ([elementName isEqualToString:@"tref"] == YES)
    {
        xpathQuery = @"*";
    }
    else if ([elementName isEqualToString:@"set"] == YES)
    {
        xpathQuery = @"*";
    }
    else if ([elementName isEqualToString:@"use"] == YES)
    {
        xpathQuery = @"*";
    }
    
    // check attributes next
    if ([newAttributeName isEqualToString:@"clip-path"] == YES)
    {
        xpathQuery = @".//clipPath";
    }
    else if ([newAttributeName isEqualToString:@"color-profile"] == YES)
    {
        xpathQuery = @".//color-profile";
    }
    else if ([newAttributeName isEqualToString:@"cursor"] == YES)
    {
        xpathQuery = @"*";
    }
    else if ([newAttributeName isEqualToString:@"fill"] == YES)
    {
        xpathQuery = @".//linearGradient|.//radialGradient|.//pattern";
    }
    else if ([newAttributeName isEqualToString:@"filter"] == YES)
    {
        xpathQuery = @".//filter";
    }
    else if ([newAttributeName isEqualToString:@"marker-start"] == YES)
    {
        xpathQuery = @".//marker";
    }
    else if ([newAttributeName isEqualToString:@"marker-mid"] == YES)
    {
        xpathQuery = @".//marker";
    }
    else if ([newAttributeName isEqualToString:@"marker-end"] == YES)
    {
        xpathQuery = @".//marker";
    }
    else if ([newAttributeName isEqualToString:@"mask"] == YES)
    {
        xpathQuery = @".//mask";
    }
    else if ([newAttributeName isEqualToString:@"stroke"] == YES)
    {
        xpathQuery = @".//linearGradient|.//radialGradient|.//pattern";
    }
    
    NSXMLElement * rootElement = [self.svgXmlDocument rootElement];
    
    NSError * error = NULL;

    NSArray * xpathResultsArray = [rootElement nodesForXPath:xpathQuery error:&error];
    
    [self.iriReferencesArray removeAllObjects];
    
    for (NSXMLElement * aXMLElement in xpathResultsArray)
    {
        NSXMLNode * idAttributeNode = [aXMLElement attributeForName:@"id"];
        
        if (idAttributeNode != NULL)
        {
            NSString * idAttributeString = idAttributeNode.stringValue;
            
            if (idAttributeString.length > 0)
            {
                [self.iriReferencesArray addObject:aXMLElement];
            }
        }
    }
}

//==================================================================================
//	numberOfItemsInComboBox
//==================================================================================

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    NSInteger result = self.comboBoxValuesArray.count;
    
    return result;
}

//==================================================================================
//	comboBox:objectValueForItemAtIndex:
//==================================================================================

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    NSMutableDictionary * itemDictionary = (self.comboBoxValuesArray)[index];
    
    NSString * result = [itemDictionary objectForKey:@"value"];
    
    return result;
}

//==================================================================================
//	selectIRIReferenceElementButtonAction:
//==================================================================================

- (IBAction)selectIRIReferenceElementButtonAction:(id)sender
{
    NSString * valueString = attributeValueComboBox.stringValue;
    
    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    valueString = [valueString stringByTrimmingCharactersInSet:whitespaceSet];
    
    NSRange urlRange = [valueString rangeOfString:@"url(#"];
    
    if (urlRange.location == 0)
    {
        NSRange parenthesisRange = [valueString rangeOfString:@")"];
        
        if (parenthesisRange.location == (valueString.length - 1))
        {
            // valid IRI reference found
            
            NSRange elementNameRange = NSMakeRange(5, valueString.length - 6);
            
            NSString * elementName = [valueString substringWithRange:elementNameRange];
            
            elementName = [elementName stringByTrimmingCharactersInSet:whitespaceSet];
            
            NSXMLElement * rootElement = [self.svgXmlDocument rootElement];
            
            NSString * xpathQuery = [NSString stringWithFormat:@"//*[@id='%@']", elementName];
            
            NSError * error = NULL;
            
            NSArray * resultArray = [rootElement nodesForXPath:xpathQuery error:&error];
            
            if (resultArray.count > 0)
            {
                NSXMLElement * iriElement = [resultArray objectAtIndex:0];
            
                [self.macSVGPluginCallbacks selectXMLElement:iriElement];
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
    else
    {
        NSBeep();
    }
}

//==================================================================================
//	itemTextFieldUpdated:
//==================================================================================

- (IBAction)itemTextFieldUpdated:(id)sender
{
    selectIRIReferenceElementButton.enabled = NO;
    
    NSString * valueString = attributeValueComboBox.stringValue;
    
    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    valueString = [valueString stringByTrimmingCharactersInSet:whitespaceSet];
    
    NSRange urlRange = [valueString rangeOfString:@"url(#"];
    
    if (urlRange.location == 0)
    {
        NSRange parenthesisRange = [valueString rangeOfString:@")"];
        
        if (parenthesisRange.location == (valueString.length - 1))
        {
            selectIRIReferenceElementButton.enabled = YES;
        }
    }
}

//==================================================================================
//	textDidChange:
//==================================================================================


- (void)controlTextDidChange:(NSNotification *)aNotification
{
    [self itemTextFieldUpdated:self];
}


@end
