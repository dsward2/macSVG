//
//  TextElementEditor.m
//  TextElementEditor
//
//  Created by Douglas Ward on 7/29/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "TextElementEditor.h"
#import "TextStylesPopoverViewController.h"
#import "TextPathPopoverViewController.h"
#import "TspanPopoverViewController.h"
#import "MacSVGPlugin/MacSVGPluginCallbacks.h"


@implementation TextElementEditor

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
}

//==================================================================================
//	awakeFromNib
//==================================================================================

- (void)awakeFromNib
{
    [super awakeFromNib];

    creatingNewTspan = NO;
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        creatingNewTspan = NO;
    }
    
    return self;
}

//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    return @"Text Element Editor";
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

    if ([elementName isEqualToString:@"text"] == YES)
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

    if ([elementName isEqualToString:@"text"] == YES)
    {
        if ([attributeName isEqualToString:@"font-family"] == YES)
        {
            result = self.pluginName;
        }
        else if ([attributeName isEqualToString:@"font-size"] == YES)
        {
            result = self.pluginName;
        }
        else if ([attributeName isEqualToString:@"text-anchor"] == YES)
        {
            result = self.pluginName;
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
//	svgXmlDocument
//==================================================================================

/*
- (NSXMLDocument *) svgXmlDocument;
{
    return svgXmlDocument;
}
*/

//==================================================================================
//	macSVGPluginCallbacks
//==================================================================================

/*
- (MacSVGPluginCallbacks *) macSVGPluginCallbacks;
{
    return macSVGPluginCallbacks;
}
*/

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

    return result;
}

//==================================================================================
//	activeXMLTextElement
//==================================================================================


- (NSXMLElement *)activeXMLTextElement
{
    return self.pluginTargetXMLElement;
}


//==================================================================================
//	activeXMLDocument
//==================================================================================


- (NSXMLDocument *)activeXMLDocument
{
    return self.svgXmlDocument;
}


//==================================================================================
//	numericStringWithFloat
//==================================================================================

- (NSString *)numericStringWithFloat:(float)floatValue
{
    NSString * numericString = @"0";

    numericString = [NSString stringWithFormat:@"%f", floatValue];
    
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
//	numericStringWithAttributeString
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
//	textElementContent:
//==================================================================================

- (NSString *)textElementContent
{
    return textContentTextView.string;
}

//==================================================================================
//	browseFontsButton:
//==================================================================================

- (NSButton *)browseFontsButton
{
    return browseFontsButton;
}

//==================================================================================
//	setFontName:
//==================================================================================

- (void)setFontName:(NSString *)fontName
{
    if (fontName != NULL)
    {
        fontFamilyTextField.stringValue = fontName;
        
        [self updateTextElementAction:self];
    }
    else
    {
        NSBeep();
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
//	findAllTspanElements
//==================================================================================

 -(NSArray *)findAllTspanElements
 {       
    NSArray * resultArray = NULL;
    
    NSString * xpathQuery = @".//tspan";
    
    NSError * error = NULL;
    resultArray = [self.pluginTargetXMLElement nodesForXPath:xpathQuery error:&error];
    
    return resultArray;
}

//==================================================================================
//	tspanPopUpButtonAction:
//==================================================================================

- (IBAction)tspanPopUpButtonAction:(id)sender
{
    NSArray * tspanElementsArray = [self findAllTspanElements];

    if (tspanElementsArray.count == 0)
    {
        [tspanPopUpButton removeAllItems];
        NSString * itemTitle = @"No tspan elements defined";
        [tspanPopUpButton addItemWithTitle:itemTitle];
        [tspanPopUpButton setEnabled:NO];
        
        NSString * textContentString = (self.pluginTargetXMLElement).stringValue;
        textContentTextView.string = textContentString;
    }
    else
    {
        NSInteger tspanIndex = tspanPopUpButton.indexOfSelectedItem;
        
        NSXMLElement * firstTspanElement = tspanElementsArray[tspanIndex];
        NSString * textContentString = firstTspanElement.stringValue;
        textContentTextView.string = textContentString;
    }
}

//==================================================================================
//	newTspanButtonAction:
//==================================================================================

- (IBAction)newTspanButtonAction:(id)sender
{
    NSString * idString = [self.macSVGPluginCallbacks uniqueIDForElementTagName:@"tspan" pendingIDs:NULL];

    NSXMLElement * newTspanElement = [[NSXMLElement alloc] init];
    newTspanElement.name = @"tspan";
    
    NSXMLNode * idAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    idAttributeNode.name = @"id";
    idAttributeNode.stringValue = idString;
    [newTspanElement addAttribute:idAttributeNode];
    
    [self assignMacsvgidsForNode:newTspanElement];
    
    NSXMLNode * dxAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    dxAttributeNode.name = @"dx";
    dxAttributeNode.stringValue = @"0";
    [newTspanElement addAttribute:dxAttributeNode];
    
    NSXMLNode * dyAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    dyAttributeNode.name = @"dy";
    dyAttributeNode.stringValue = @"0";
    [newTspanElement addAttribute:dyAttributeNode];
    
    NSXMLNode * rotateAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    rotateAttributeNode.name = @"rotate";
    rotateAttributeNode.stringValue = @"0";
    [newTspanElement addAttribute:rotateAttributeNode];
    
    NSXMLNode * newTextContentNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind];
    NSString * newTextContentString = [NSString stringWithFormat:@"%@ tspan text", idString];
    [self.pluginTargetXMLElement normalizeAdjacentTextNodesPreservingCDATA:YES];
    NSArray * textElementChildArray = (self.pluginTargetXMLElement).children;
    for (NSXMLNode * aChildNode in textElementChildArray)
    {
        if (aChildNode.kind == NSXMLTextKind)
        {
            newTextContentString = aChildNode.stringValue;
            //[aChildNode detach];
            NSInteger textContentIndex = aChildNode.index;
            [self.pluginTargetXMLElement removeChildAtIndex:textContentIndex];
        }
    }
    newTextContentNode.stringValue = newTextContentString;
    [newTspanElement addChild:newTextContentNode];
    
    [self.pluginTargetXMLElement addChild:newTspanElement];

    NSArray * tspanElementsArray = [self findAllTspanElements];
    
    NSMutableArray * tspanTitlesArray = [NSMutableArray array];
    
    for (NSXMLElement * aTspanElement in tspanElementsArray)
    {
        NSXMLNode * tspanIDNode = [aTspanElement attributeForName:@"id"];
        NSString * tspanIDString = @"tspan ID Missing";
        if (tspanIDNode != NULL)
        {
            tspanIDString = tspanIDNode.stringValue;
        }
        
        [tspanTitlesArray addObject:tspanIDString];
    }

    [tspanPopUpButton removeAllItems];
    [tspanPopUpButton addItemsWithTitles:tspanTitlesArray];
    [tspanPopUpButton setEnabled:YES];
    NSInteger newTspanIndex = tspanTitlesArray.count - 1;
    [tspanPopUpButton selectItemAtIndex:newTspanIndex];

    [editTspanButton setEnabled:YES];
    
    NSString * textContentString = newTspanElement.stringValue;
    textContentTextView.string = textContentString;
    
    creatingNewTspan = YES;
    
    [self updateDocumentViews];

    creatingNewTspan = NO;
}

//==================================================================================
//	editTSpanButtonAction:
//==================================================================================

- (IBAction)editTspanButtonAction:(id)sender
{
    NSButton *targetButton = (NSButton *)sender;
    
    NSInteger tspanIndex = tspanPopUpButton.indexOfSelectedItem;

    NSArray * tspanElementsArray = [self findAllTspanElements];
    NSXMLElement * tspanElement = tspanElementsArray[tspanIndex];
    
    [tspanPopoverViewController loadSettingsForTspan:tspanElement textElement:self.pluginTargetXMLElement];
    
    // configure the preferred position of the popover
    [tspanPopover showRelativeToRect:targetButton.bounds
            ofView:sender preferredEdge:NSMaxYEdge];
}

//==================================================================================
//	findAllPathElements
//==================================================================================

 -(NSArray *)findAllPathElements
 {       
    NSArray * resultArray = NULL;
    
    NSXMLElement * rootElement = [self.svgXmlDocument rootElement];
    
    NSString * xpathQuery = @".//path";
    
    NSError * error = NULL;
    resultArray = [rootElement nodesForXPath:xpathQuery error:&error];
    
    return resultArray;
}

//==================================================================================
//	beginEditForXMLElement:domElement:existingValue:
//==================================================================================

- (BOOL)beginEditForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetDOMElement
{
    BOOL result = [super beginEditForXMLElement:newPluginTargetXMLElement
            domElement:newPluginTargetDOMElement];
    
    NSArray * textPathElementsArray = [newPluginTargetXMLElement elementsForName:@"textPath"];
    if (textPathElementsArray.count > 0)
    {
        editTextpathButton.title = @"Edit textPath";
    }
    else
    {
        editTextpathButton.title = @"New textPath";
    }
    
    NSArray * pathElementsArray = [self findAllPathElements];
    if (pathElementsArray.count > 0)
    {
        [editTextpathButton setEnabled:YES];
    }
    else
    {
        [editTextpathButton setEnabled:NO];
    }
    
    if (creatingNewTspan == NO)
    {
        NSArray * tspanElementsArray = [self findAllTspanElements];

        if (tspanElementsArray.count == 0)
        {
            [tspanPopUpButton removeAllItems];
            NSString * itemTitle = @"No tspan elements defined";
            [tspanPopUpButton addItemWithTitle:itemTitle];
            [tspanPopUpButton setEnabled:NO];
            
            [editTspanButton setEnabled:NO];
            
            NSString * textContentString = @"";
            if (newPluginTargetXMLElement != NULL)
            {
                textContentString = newPluginTargetXMLElement.stringValue;
            }
            textContentTextView.string = textContentString;
        }
        else
        {
            NSMutableArray * tspanTitlesArray = [NSMutableArray array];
            
            for (NSXMLElement * aTspanElement in tspanElementsArray)
            {
                NSXMLNode * tspanIDNode = [aTspanElement attributeForName:@"id"];
                NSString * tspanIDString = @"tspan ID Missing";
                if (tspanIDNode != NULL)
                {
                    tspanIDString = tspanIDNode.stringValue;
                }
                
                [tspanTitlesArray addObject:tspanIDString];
            }
        
            [tspanPopUpButton removeAllItems];
            [tspanPopUpButton addItemsWithTitles:tspanTitlesArray];
            [tspanPopUpButton setEnabled:YES];
            [tspanPopUpButton selectItemAtIndex:0];

            [editTspanButton setEnabled:YES];
            
            NSXMLElement * firstTspanElement = tspanElementsArray[0];
            NSString * textContentString = firstTspanElement.stringValue;
            textContentTextView.string = textContentString;
        }
        
        NSXMLNode * fontFamilyAttributeNode = [newPluginTargetXMLElement attributeForName:@"font-family"];
        if (fontFamilyAttributeNode != NULL)
        {
            NSString * fontFamilyAttributeString = fontFamilyAttributeNode.stringValue;
            fontFamilyTextField.stringValue = fontFamilyAttributeString;
        }
        
        NSXMLNode * fontSizeAttributeNode = [newPluginTargetXMLElement attributeForName:@"font-size"];
        if (fontSizeAttributeNode != NULL)
        {
            NSString * fontSizeAttributeString = [self numericStringWithAttributeNode:fontSizeAttributeNode];
            
            NSString * fontSizeUnitString = [self unitForAttributeNode:fontSizeAttributeNode];
            
            fontSizeTextField.stringValue = fontSizeAttributeString;
            [fontSizeUnitsPopUpButton selectItemWithTitle:fontSizeUnitString];
            
            float fontSizeFloat = fontSizeAttributeString.floatValue;
            fontSizeStepper.floatValue = fontSizeFloat;
        }

        NSXMLNode * textAnchorAttributeNode = [newPluginTargetXMLElement attributeForName:@"text-anchor"];
        if (textAnchorAttributeNode != NULL)
        {
            NSString * textAnchorAttributeString = textAnchorAttributeNode.stringValue;
            textAnchorPopUpButton.stringValue = textAnchorAttributeString;
        }
        else
        {
            textAnchorPopUpButton.stringValue = @"";
        }
    }
    
    return result;
}

// -------------------------------------------------------------------------------
//  browseFontsButtonAction:
// -------------------------------------------------------------------------------
- (IBAction)browseFontsButtonAction:(id)sender
{
    NSButton *targetButton = (NSButton *)sender;
    
    // configure the preferred position of the popover
    [fontPopover showRelativeToRect:targetButton.bounds ofView:sender preferredEdge:NSMaxYEdge];
}

// -------------------------------------------------------------------------------
//  fontSizeStepperAction:
// -------------------------------------------------------------------------------

- (IBAction)fontSizeStepperAction:(id)sender
{
    float fontSizeFloat = fontSizeStepper.floatValue;

    NSString * fontSizeAttributeString = [self numericStringWithFloat:fontSizeFloat];
    
    fontSizeTextField.stringValue = fontSizeAttributeString;

    [self updateTextElementAction:self];
}

// -------------------------------------------------------------------------------
//  textStylesButtonAction:
// -------------------------------------------------------------------------------

- (IBAction)textStylesButtonAction:(id)sender
{
    NSButton *targetButton = (NSButton *)sender;
    
    [textStylesPopoverViewController loadTextStyles];
    
    // configure the preferred position of the popover
    [textStylesPopover showRelativeToRect:targetButton.bounds ofView:sender preferredEdge:NSMaxYEdge];
}

// -------------------------------------------------------------------------------
//  editTextPathButtonAction:
// -------------------------------------------------------------------------------

- (IBAction)editTextPathButtonAction:(id)sender
{
    NSButton *targetButton = (NSButton *)sender;
    
    [textPathPopoverViewController loadSettingsForTextElement:self.pluginTargetXMLElement];
    
    // configure the preferred position of the popover
    [textPathPopover showRelativeToRect:targetButton.bounds ofView:sender preferredEdge:NSMaxYEdge];
}

// -------------------------------------------------------------------------------
//  updateTextElementAction:
// -------------------------------------------------------------------------------

- (IBAction)updateTextElementAction:(id)sender
{
    NSString * fontFamilyAttributeString = fontFamilyTextField.stringValue;
    if (fontFamilyAttributeString.length > 0)
    {
        NSXMLNode * fontFamilyAttributeNode = [self.pluginTargetXMLElement attributeForName:@"font-family"];
        
        if (fontFamilyAttributeNode == NULL)
        {
            fontFamilyAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            fontFamilyAttributeNode.name = @"font-family";
            [self.pluginTargetXMLElement addAttribute:fontFamilyAttributeNode];
        }

        fontFamilyAttributeNode.stringValue = fontFamilyAttributeString;
    }

    NSString * fontNumericSizeAttributeString = fontSizeTextField.stringValue;
    NSString * fontSizeUnitsString = fontSizeUnitsPopUpButton.titleOfSelectedItem;
    NSString * fontSizeString = [NSString stringWithFormat:@"%@%@",
            fontNumericSizeAttributeString, fontSizeUnitsString];
    if (fontFamilyAttributeString.length > 0)
    {
        NSXMLNode * fontSizeAttributeNode = [self.pluginTargetXMLElement attributeForName:@"font-size"];
        
        if (fontSizeAttributeNode == NULL)
        {
            fontSizeAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            fontSizeAttributeNode.name = @"font-size";
            [self.pluginTargetXMLElement addAttribute:fontSizeAttributeNode];
        }

        fontSizeAttributeNode.stringValue = fontSizeString;
        
        float fontSizeFloat = fontNumericSizeAttributeString.floatValue;
        fontSizeStepper.floatValue = fontSizeFloat;
    }
    
    NSString * textAnchorString = textAnchorPopUpButton.titleOfSelectedItem;
    textAnchorString = textAnchorString.lowercaseString;
    NSXMLNode * textAnchorAttributeNode = [self.pluginTargetXMLElement attributeForName:@"text-anchor"];
    if (textAnchorString.length > 0)
    {
        if (textAnchorAttributeNode == NULL)
        {
            textAnchorAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            textAnchorAttributeNode.name = @"text-anchor";
            [self.pluginTargetXMLElement addAttribute:textAnchorAttributeNode];
        }

        textAnchorAttributeNode.stringValue = textAnchorString;
    }
    else
    {
        if (textAnchorAttributeNode != NULL)
        {
            NSXMLElement * parentElement = (NSXMLElement *)textAnchorAttributeNode.parent;
            [parentElement removeAttributeForName:@"text-anchor"];
        }
    }
    
    // update the main text, in text or textPath or tSpan
    NSXMLElement * textContainerElement = [self textContainerElement:self.pluginTargetXMLElement];
    
    if (tspanPopUpButton.enabled == YES)
    {
        // override previous element search result
        NSInteger tspanIndex = tspanPopUpButton.indexOfSelectedItem;
        
        NSArray * tspanArray = [self findAllTspanElements];
        textContainerElement = tspanArray[tspanIndex];
    }
    
    NSString * textContentString = textContentTextView.string;
    
    NSXMLNode * textNode = NULL;
    NSArray * textContainerChildArray = textContainerElement.children;
    for (NSXMLNode * aChildNode in textContainerChildArray)
    {
        if (aChildNode.kind == NSXMLTextKind)
        {
            textNode = aChildNode;
            break;
        }
    }
    if (textNode == NULL)
    {
        textNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind];
        [textContainerElement addChild:textNode];
    }
    
    textNode.stringValue = textContentString;
    
    [textContainerElement normalizeAdjacentTextNodesPreservingCDATA:YES];

    [self updateDocumentViews];
    
    NSWindow * keyWindow = NSApp.keyWindow;
    id firstResponder = keyWindow.firstResponder;
    if (firstResponder != textContentTextView)
    {
        [keyWindow makeFirstResponder:textContentTextView];
    }
}

// -------------------------------------------------------------------------------
//  textContainerElement:
// -------------------------------------------------------------------------------

- (NSXMLElement *)textContainerElement:(NSXMLElement *)withinElement
{
    NSXMLElement * resultElement = withinElement;
    BOOL textContainerFound = NO;
    
    NSArray * childNodesArray = withinElement.children;
    for (NSXMLNode * aChildNode in childNodesArray)
    {
        NSXMLNodeKind nodeKind = aChildNode.kind;
        if (nodeKind == NSXMLTextKind)
        {
            // an existing text node is found, resuse it
            resultElement = withinElement;
            textContainerFound = YES;
            break;
        }
    }
    
    if (textContainerFound == NO)
    {
        // check again, recursively
        for (NSXMLNode * aChildNode in childNodesArray)
        {
            NSXMLNodeKind nodeKind = aChildNode.kind;
            if (nodeKind == NSXMLElementKind)
            {
                // an existing text node is found, resuse it
                NSXMLElement * childElement = (NSXMLElement *)aChildNode;
                NSXMLElement * recursiveResultElement = [self textContainerElement:childElement];
                if (recursiveResultElement != resultElement)
                {
                    resultElement = recursiveResultElement;
                    break;
                }
            }
        }
    }
    
    return resultElement;
}


// -------------------------------------------------------------------------------
//  controlTextDidEndEditing:
// -------------------------------------------------------------------------------

- (void)controlTextDidEndEditing:(NSNotification *)obj;
{
    [self updateTextElementAction:self];
}

// -------------------------------------------------------------------------------
//  textDidChange:
// -------------------------------------------------------------------------------

- (void)textDidChange:(NSNotification *)aNotification
{
    [self updateTextElementAction:self];
}





@end
