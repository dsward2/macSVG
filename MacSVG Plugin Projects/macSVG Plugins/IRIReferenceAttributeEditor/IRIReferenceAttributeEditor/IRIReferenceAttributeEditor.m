//
//  IRIReferenceAttributeEditor.m
//  IRIReferenceAttributeEditor
//
//  Created by Douglas Ward on 9/3/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "IRIReferenceAttributeEditor.h"

@implementation IRIReferenceAttributeEditor

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
    if (self)
    {
        // Initialization code here.
        self.iriReferencesArray = [NSMutableArray array];
    }
    
    return self;
}

//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    return @"IRI Reference Editor";
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
    
    BOOL iriReferenceFound = NO;
    
    if ([attributeName isEqualToString:@"xlink:href"] == YES)
    {
        iriReferenceFound = YES;
    }
    else if ([attributeName isEqualToString:@"clip-path"] == YES)
    {
        iriReferenceFound = YES;
    }
    else if ([attributeName isEqualToString:@"colorProfile"] == YES)
    {
        iriReferenceFound = YES;
    }
    else if ([attributeName isEqualToString:@"cursor"] == YES)
    {
        iriReferenceFound = YES;
    }
    else if ([attributeName isEqualToString:@"fill"] == YES)
    {
        iriReferenceFound = YES;
    }
    else if ([attributeName isEqualToString:@"filter"] == YES)
    {
        iriReferenceFound = YES;
    }
    else if ([attributeName isEqualToString:@"mask"] == YES)
    {
        iriReferenceFound = YES;
    }
    else if ([attributeName isEqualToString:@"stroke"] == YES)
    {
        iriReferenceFound = YES;
    }
    else if ([attributeName isEqualToString:@"marker-start"] == YES)
    {
        iriReferenceFound = YES;
    }
    else if ([attributeName isEqualToString:@"marker-mid"] == YES)
    {
        iriReferenceFound = YES;
    }
    else if ([attributeName isEqualToString:@"marker-end"] == YES)
    {
        iriReferenceFound = YES;
    }
    
    if (iriReferenceFound == YES)
    {
        result = [self pluginName];
    }
    
    return result;
}

//==================================================================================
//	editorPriority:context:
//==================================================================================

- (NSInteger)editorPriority:(NSXMLElement *)targetElement context:(NSString *)context
{
    return 20;
}


- (void)awakeFromNib
{

}

//==================================================================================
//	setValueButtonAction:
//==================================================================================

- (IBAction)setValueButtonAction:(id)sender
{
    NSString * attributeValueString = [iriReferenceComboBox stringValue];

    NSXMLNode * attributeNode = [self.pluginTargetXMLElement attributeForName:self.activeAttributeName];
    if (attributeNode != NULL)
    {
        [attributeNode setStringValue:attributeValueString];
    }
    
    [self updateDocumentViews];
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
    
    [iriReferenceComboBox setStringValue:existingValue];
    
    [self buildIRIReferencesArrayForXMLElement:newPluginTargetXMLElement domElement:newPluginTargetDOMElement
            attributeName:newAttributeName existingValue:existingValue];

    return result;
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

    NSString * elementName = [newPluginTargetXMLElement name];

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
            NSString * idAttributeString = [idAttributeNode stringValue];
            
            if ([idAttributeString length] > 0)
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
    NSInteger result = [self.iriReferencesArray count];
    
    return result;
}

//==================================================================================
//	objectValueForItemAtIndex
//==================================================================================

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    NSXMLElement * validElement = [self.iriReferencesArray objectAtIndex:index];
    
    NSXMLNode * idAttributeNode = [validElement attributeForName:@"id"];
    NSString * idAttributeString = [idAttributeNode stringValue];
    
    NSString * result = [NSString stringWithFormat:@"url(#%@)", idAttributeString];
    
    return result;
}




@end
