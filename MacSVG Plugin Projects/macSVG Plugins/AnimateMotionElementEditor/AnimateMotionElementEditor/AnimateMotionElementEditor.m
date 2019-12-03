//
//  AnimateMotionElementEditor.m
//  AnimateMotionElementEditor
//
//  Created by Douglas Ward on 8/26/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "AnimateMotionElementEditor.h"
#import <MacSVGPlugin/KeyValuesPopoverViewController.h>

@implementation AnimateMotionElementEditor

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
    
    if (isAwake == NO)
    {
        isAwake = YES;
        
        self.keyValuesPopoverViewController.macSVGPlugin = self;
    }
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // Initialization code here.
    }
    
    return self;
}

//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    return @"AnimateMotion Element Editor";
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element tag name
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    NSString * result = NULL;

    if ([elementName isEqualToString:@"animateMotion"] == YES)
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

    if ([elementName isEqualToString:@"animateMotion"] == YES)
    {
        if ([attributeName isEqualToString:@"values"] == YES)
        {
            result = self.pluginName;
        }
        else if ([attributeName isEqualToString:@"from"] == YES)
        {
            result = self.pluginName;
        }
        else if ([attributeName isEqualToString:@"to"] == YES)
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

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
//	beginEditForXMLElement:domElement:existingValue:
//==================================================================================

- (BOOL)beginEditForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetElement
{
    BOOL result = [super beginEditForXMLElement:newPluginTargetXMLElement
            domElement:newPluginTargetElement];

    self.animationValuesArray = [NSMutableArray array];
    
    [valuesTableView reloadData];

    [self loadAnimateMotionSettings];
    
    return result;
}

#pragma clang diagnostic pop

//==================================================================================
//	numericStringWithFloat
//==================================================================================

- (NSString *)numericStringWithFloat:(float)floatValue
{
    NSString * numericString = [NSString stringWithFormat:@"%f", floatValue];
    
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
    NSString * numericString = [NSString stringWithFormat:@"%f", attributeFloat];
    
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
//	setAttribute:element:popUpButton
//==================================================================================

- (void)setAttribute:(NSString *)attributeName element:(NSXMLElement *)aElement popUpButton:(NSPopUpButton *)aPopUpButton
{
    NSString * attributeValue = @"";
    
    NSXMLNode * aAttributeNode = [aElement attributeForName:attributeName];
    if (aAttributeNode != NULL)
    {
        attributeValue = aAttributeNode.stringValue;
    }
    
    id popUpButtonItem = [aPopUpButton itemWithTitle:attributeValue];
    if (popUpButtonItem == NULL)
    {
        attributeValue = @"";   // value was not valid for attribute choices in popUpButton
    }
    
    [aPopUpButton selectItemWithTitle:attributeValue];
}

//==================================================================================
//	setAttribute:element:comboBox
//==================================================================================

- (void)setAttribute:(NSString *)attributeName element:(NSXMLElement *)aElement comboBox:(NSComboBox *)aComboBox
{
    NSString * attributeValue = @"";
    
    NSXMLNode * aAttributeNode = [aElement attributeForName:attributeName];
    if (aAttributeNode != NULL)
    {
        attributeValue = aAttributeNode.stringValue;
    }
    
    aComboBox.stringValue = attributeValue;
}

//==================================================================================
//	setAttribute:element:textField
//==================================================================================

- (void)setAttribute:(NSString *)attributeName element:(NSXMLElement *)aElement textField:(NSTextField *)aTextField
{
    NSString * attributeValue = @"";
    
    NSXMLNode * aAttributeNode = [aElement attributeForName:attributeName];
    if (aAttributeNode != NULL)
    {
        attributeValue = aAttributeNode.stringValue;
    }
    
    aTextField.stringValue = attributeValue;
}

//==================================================================================
//	loadAnimateMotionSettings
//==================================================================================

- (void)loadAnimateMotionSettings
{
    NSXMLElement * animateMotionElement = self.pluginTargetXMLElement;
    
    [self setAttribute:@"calcMode" element:animateMotionElement popUpButton:calcModePopUpButton];
    
    [self setAttribute:@"begin" element:animateMotionElement textField:beginTextField];
    [self setAttribute:@"dur" element:animateMotionElement textField:durTextField];
    
    [self setAttribute:@"repeatCount" element:animateMotionElement comboBox:repeatCountComboBox];

    [self setAttribute:@"begin" element:animateMotionElement textField:beginTextField];

    fromTextField.stringValue = @"";
    NSXMLNode * fromAttributeNode = [animateMotionElement attributeForName:@"from"];
    if (fromAttributeNode != NULL)
    {
        NSString * fromAttributeValue = fromAttributeNode.stringValue;
        fromTextField.stringValue = fromAttributeValue;
        [animateMotionTabView selectTabViewItemAtIndex:0];
    }

    toTextField.stringValue = @"";
    NSXMLNode * toAttributeNode = [animateMotionElement attributeForName:@"to"];
    if (toAttributeNode != NULL)
    {
        NSString * toAttributeValue = toAttributeNode.stringValue;
        toTextField.stringValue = toAttributeValue;
        [animateMotionTabView selectTabViewItemAtIndex:0];
    }

    NSXMLNode * valuesAttributeNode = [animateMotionElement attributeForName:@"values"];
    if (valuesAttributeNode != NULL)
    {
        [self configureAnimationKeyValuesWithUseKeyPoints:YES];
        [valuesTableView reloadData];

        [animateMotionTabView selectTabViewItemAtIndex:1];
    }

    pathTextField.stringValue = @"";
    NSXMLNode * pathAttributeNode = [animateMotionElement attributeForName:@"path"];
    if (pathAttributeNode != NULL)
    {
        NSString * pathAttributeValue = pathAttributeNode.stringValue;
        pathTextField.stringValue = pathAttributeValue;
        
        [animateMotionTabView selectTabViewItemAtIndex:2];
    }

    pathRotateComboBox.stringValue = @"";
    mpathRotateComboBox.stringValue = @"";
    NSXMLNode * rotateAttributeNode = [animateMotionElement attributeForName:@"rotate"];
    if (rotateAttributeNode != NULL)
    {
        NSString * rotateAttributeValue = rotateAttributeNode.stringValue;
        pathRotateComboBox.stringValue = rotateAttributeValue;
        mpathRotateComboBox.stringValue = rotateAttributeValue;
    }

    [self loadMpathOptions];
    [mpathPopUpButton selectItemWithTitle:@""];
    NSArray * mpathElementsArray = [animateMotionElement elementsForName:@"mpath"];
    if (mpathElementsArray.count == 1)
    {
        NSXMLElement * mpathElement = mpathElementsArray[0];
        NSXMLNode * mpathXlinkHrefAttributeNode = [mpathElement attributeForName:@"xlink:href"];
        if (mpathXlinkHrefAttributeNode != NULL)
        {
            NSString * mpathXlinkHrefAttributeValue = mpathXlinkHrefAttributeNode.stringValue;
            
            NSMutableString * xlinkHrefString = [NSMutableString stringWithString:mpathXlinkHrefAttributeValue];
            NSInteger xlinkHrefStringLength = xlinkHrefString.length;
            
            NSRange startURLRange = [xlinkHrefString rangeOfString:@"url("];
            if (startURLRange.location == 0)
            {
                
                unichar lastCharacter = [xlinkHrefString characterAtIndex:(xlinkHrefStringLength - 1)];
                if (lastCharacter == ')')
                {
                    NSRange deleteUrlRange = NSMakeRange((xlinkHrefStringLength - 1), 1);
                    [xlinkHrefString deleteCharactersInRange:deleteUrlRange];
                    deleteUrlRange = NSMakeRange(0, 4);
                    [xlinkHrefString deleteCharactersInRange:deleteUrlRange];
                }
            }
            
            xlinkHrefStringLength = xlinkHrefString.length;
            if (xlinkHrefStringLength > 1)
            {
                unichar firstCharacter = [xlinkHrefString characterAtIndex:0];
            
                if (firstCharacter == '#')
                {
                    NSRange firstCharacterRange = NSMakeRange(0, 1);
                    [xlinkHrefString deleteCharactersInRange:firstCharacterRange];
                    
                    id pathItem = [mpathPopUpButton itemWithTitle:xlinkHrefString];
                    if (pathItem != NULL)
                    {
                        [mpathPopUpButton selectItemWithTitle:xlinkHrefString];
                        
                        [animateMotionTabView selectTabViewItemAtIndex:3];
                    }
                }
            }
        }
    }
}


//==================================================================================
//	configureValuesTableView
//==================================================================================

/*
- (void)configureValuesTableView
{
    self.valuesArray = [NSMutableArray array];

    NSXMLElement * animateMotionElement = self.pluginTargetXMLElement;

    NSXMLNode * valuesAttributeNode = [animateMotionElement attributeForName:@"values"];

    if (valuesAttributeNode != NULL)
    {
        NSString * valuesAttributeString = valuesAttributeNode.stringValue;
        
        NSArray * valueRowsArray = [valuesAttributeString componentsSeparatedByString:@";"];
        
        for (NSString * aValuesString in valueRowsArray)
        {
            NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSString * trimmedValuesString = [aValuesString stringByTrimmingCharactersInSet:whitespaceSet];

            NSInteger aValuesStringLength = trimmedValuesString.length;
        
            if (aValuesStringLength > 0)
            {
                NSMutableString * filteredValuesString = [NSMutableString string];
                
                unichar prevChar = ' ';
                
                for (NSInteger i = 0; i < aValuesStringLength; i++)
                {
                    unichar aChar = [trimmedValuesString characterAtIndex:i];
                    NSString * aCharString = [NSString stringWithFormat:@"%C", aChar];
                    
                    if (aChar == ' ')
                    {
                        if (prevChar != ' ')
                        {
                            [filteredValuesString appendString:aCharString];
                        }
                    }
                    else
                    {
                        [filteredValuesString appendString:aCharString];
                    }
                    
                    prevChar = aChar;
                }
            
                NSArray * valueItemsArray = [filteredValuesString componentsSeparatedByString:@" "];
                
                [self.valuesArray addObject:valueItemsArray];
            }
        }
    }
    
    [valuesTableView reloadData];
    
    //valuesTableView.rowHeight = 14.0f;
    
    [self.keyValuesPopoverViewController useKeyPoints:YES];
}
*/

//==================================================================================
//	numberOfRowsInTableView:
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return (self.animationValuesArray).count;
}

//==================================================================================
//	itemTextFieldUpdated:
//==================================================================================

- (IBAction)itemTextFieldUpdated:(id)sender
{
    NSInteger rowIndex = [valuesTableView rowForView:sender];
    
    if (rowIndex >= 0)
    {
        NSInteger columnIndex = [valuesTableView columnForView:sender];
        
        NSString * stringValue = [sender stringValue];
        
        stringValue = [stringValue copy];
        
        if (rowIndex <= ((self.animationValuesArray).count - 1))
        {
            NSMutableArray * rowArray = (self.animationValuesArray)[rowIndex];
            
            rowArray[(columnIndex - 1)] = stringValue;
            
            NSTextField * textField = sender;
            textField.backgroundColor = [NSColor clearColor];
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
//	controlTextDidEndEditing:
//==================================================================================

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
    id sender = aNotification.object;
    
    [self itemTextFieldUpdated:sender];
}

//==================================================================================
//	controlTextDidBeginEditing:
//==================================================================================

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
    id sender = aNotification.object;
    
    NSTextField * textField = sender;
    textField.backgroundColor = [NSColor whiteColor];
}

//==================================================================================
//	control:textShouldBeginEditing:
//==================================================================================

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    return YES;
}

//==================================================================================
//	control:textShouldEndEditing:
//==================================================================================

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    return YES;
}

//==================================================================================
//	tableView:viewForTableColumn:row:
//==================================================================================

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString * tableColumnIdentifier = tableColumn.identifier;

    //NSTextField * resultView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    NSString * cellViewIndentifier = [tableColumnIdentifier stringByAppendingString:@"CellView"];
    
    NSTextField * resultView = [tableView makeViewWithIdentifier:cellViewIndentifier owner:self];

    NSArray * subviews = resultView.subviews;
    NSTextField * textField = subviews.firstObject;

    NSString * resultString = @"";
    
    if ([tableColumnIdentifier isEqualToString:@"#"] == YES)
    {
        resultString = [NSString stringWithFormat:@"%ld", (row + 1)];
        textField.editable = NO;
    }
    else
    {
        textField.editable = YES;
        textField.delegate = self;
        
        NSArray * rowArray = (self.animationValuesArray)[row];
        NSInteger rowArrayCount = rowArray.count;

        if ([tableColumnIdentifier isEqualToString:@"x"] == YES)
        {
            if (rowArrayCount > 0)
            {
                resultString = rowArray[0];
            }
        }
        else if ([tableColumnIdentifier isEqualToString:@"y"] == YES)
        {
            if (rowArrayCount > 1)
            {
                resultString = rowArray[1];
            }
        }
    }

    textField.stringValue = resultString;
    
    return resultView;
}

//==================================================================================
//	loadMpathOptions
//==================================================================================

- (void)loadMpathOptions
{
    [mpathPopUpButton removeAllItems];
    
    [mpathPopUpButton addItemWithTitle:@""];

    NSArray * pathElementsArray = [self findAllPathElements];
    for (NSXMLElement * aPathElement in pathElementsArray)
    {
        NSXMLNode * pathIDAttributeNode = [aPathElement attributeForName:@"id"];
        if (pathIDAttributeNode != NULL)
        {
            NSString * pathIDString = pathIDAttributeNode.stringValue;
            if (pathIDString.length > 0)
            {
                [mpathPopUpButton addItemWithTitle:pathIDString];
            }
        }
    }
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
//	numberOfItemsInComboBox
//==================================================================================

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    NSInteger result = 0;
    
    if (aComboBox == repeatCountComboBox) result = 3;
    if (aComboBox == pathRotateComboBox) result = 4;
    if (aComboBox == mpathRotateComboBox) result = 4;

    return result;
}

//==================================================================================
//	objectValueForItemAtIndex
//==================================================================================

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    NSString * result = @"Missing Item";
    
    if (aComboBox == repeatCountComboBox)
    {
        result = [self repeatCountComboBoxObjectValueAtIndex:index];
    }
    else if (aComboBox == pathRotateComboBox)
    {
        result = [self pathRotateComboBoxObjectValueAtIndex:index];
    }
    else if (aComboBox == mpathRotateComboBox)
    {
        result = [self mpathRotateComboBoxObjectValueAtIndex:index];
    }
    
    return result;
}

//==================================================================================
//	repeatCountComboBoxObjectValueAtIndex
//==================================================================================

- (NSString *)repeatCountComboBoxObjectValueAtIndex:(NSInteger)index
{
    NSString * result = @"Missing Item";
    
    switch (index)
    {
        case 0:
            result = @"";
            break;
        case 1:
            result = @"0";
            break;
        case 2:
            result = @"indefinite";
            break;
        default:
            break;
    }
    
    return result;
}

//==================================================================================
//	pathRotateComboBoxObjectValueAtIndex
//==================================================================================

- (NSString *)pathRotateComboBoxObjectValueAtIndex:(NSInteger)index
{
    NSString * result = @"Missing Item";
    
    switch (index)
    {
        case 0:
            result = @"";
            break;
        case 1:
            result = @"auto";
            break;
        case 2:
            result = @"auto-reverse";
            break;
        case 3:
            result = @"0";
            break;
        default:
            break;
    }
    
    return result;
}

//==================================================================================
//	mpathRotateComboBoxObjectValueAtIndex
//==================================================================================

- (NSString *)mpathRotateComboBoxObjectValueAtIndex:(NSInteger)index
{
    NSString * result = @"Missing Item";
    
    switch (index)
    {
        case 0:
            result = @"";
            break;
        case 1:
            result = @"auto";
            break;
        case 2:
            result = @"auto-reverse";
            break;
        case 3:
            result = @"0";
            break;
        default:
            break;
    }
    
    return result;
}

//==================================================================================
//	cancelButtonAction
//==================================================================================

- (IBAction)cancelButtonAction:(id)sender
{
}

//==================================================================================
//	setAttributeName:value:element:
//==================================================================================

- (void)setAttributeName:(NSString *)attributeName value:(NSString *)attributeValue element:(NSXMLElement *)aElement
{
    NSXMLNode * attributeNode = [aElement attributeForName:attributeName];
    if (attributeValue.length == 0)
    {
        if (attributeNode != NULL)
        {
            [aElement removeAttributeForName:attributeName];
        }
    }
    else
    {
        if (attributeNode == NULL)
        {
            attributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            attributeNode.name = attributeName;
            attributeNode.stringValue = @"";
            [aElement addAttribute:attributeNode];
        }
        attributeNode.stringValue = attributeValue;
    }
}

//==================================================================================
//	applyChangesButtonAction:
//==================================================================================

- (IBAction)applyChangesButtonAction:(id)sender
{
    NSXMLElement * animateMotionElement = self.pluginTargetXMLElement;
    
    NSString * calcModeString = calcModePopUpButton.titleOfSelectedItem;
    NSString * beginString = beginTextField.stringValue;
    NSString * durString = durTextField.stringValue;
    NSString * repeatCountString = repeatCountComboBox.stringValue;
    
    NSTabViewItem * animateMotionTabViewItem = animateMotionTabView.selectedTabViewItem;
    NSInteger animateMotionTabIndex = [animateMotionTabView indexOfTabViewItem:animateMotionTabViewItem];
    
    NSString * fromString = fromTextField.stringValue;
    NSString * toString = toTextField.stringValue;
    
    NSMutableString * valuesString = [NSMutableString string];
    for (NSArray * rowArray in self.animationValuesArray)
    {
        if (valuesString.length > 0)
        {
            [valuesString appendString:@";"];
        }
    
        NSInteger itemIndex = 0;
        for (NSString * columnString in rowArray)
        {
            if (itemIndex > 0)
            {
                [valuesString appendString:@" "];
            }

            [valuesString appendString:columnString];
            itemIndex++;
        }
    }

    NSString * pathString = pathTextField.stringValue;
    NSString * pathRotateString = pathRotateComboBox.stringValue;
    NSString * mpathString = mpathPopUpButton.titleOfSelectedItem;
    NSString * mpathRotateString = mpathRotateComboBox.stringValue;
    
    [self setAttributeName:@"calcMode" value:calcModeString element:self.pluginTargetXMLElement];
    [self setAttributeName:@"begin" value:beginString element:self.pluginTargetXMLElement];
    [self setAttributeName:@"dur" value:durString element:self.pluginTargetXMLElement];
    [self setAttributeName:@"repeatCount" value:repeatCountString element:self.pluginTargetXMLElement];
    
    switch (animateMotionTabIndex)
    {
        case 0:
        {
            [self setAttributeName:@"from" value:fromString element:self.pluginTargetXMLElement];
            [self setAttributeName:@"to" value:toString element:self.pluginTargetXMLElement];
            [self.pluginTargetXMLElement removeAttributeForName:@"values"];
            [self.pluginTargetXMLElement removeAttributeForName:@"path"];
            [self setAttributeName:@"rotate" value:@"" element:self.pluginTargetXMLElement];
            NSArray * mpathElementsArray = [animateMotionElement elementsForName:@"mpath"];
            for (NSXMLElement * aMpathElement in mpathElementsArray)
            {
                [animateMotionElement removeChildAtIndex:aMpathElement.index];
            }
            break;
        }
        case 1:
        {
            [self.pluginTargetXMLElement removeAttributeForName:@"from"];
            [self.pluginTargetXMLElement removeAttributeForName:@"to"];
            [self setAttributeName:@"values" value:valuesString element:self.pluginTargetXMLElement];
            [self.pluginTargetXMLElement removeAttributeForName:@"path"];
            [self setAttributeName:@"rotate" value:@"" element:self.pluginTargetXMLElement];
            NSArray * mpathElementsArray = [animateMotionElement elementsForName:@"mpath"];
            for (NSXMLElement * aMpathElement in mpathElementsArray)
            {
                [animateMotionElement removeChildAtIndex:aMpathElement.index];
            }
            break;
        }
        case 2:
        {
            [self.pluginTargetXMLElement removeAttributeForName:@"from"];
            [self.pluginTargetXMLElement removeAttributeForName:@"to"];
            [self.pluginTargetXMLElement removeAttributeForName:@"values"];
            [self setAttributeName:@"path" value:pathString element:self.pluginTargetXMLElement];
            [self setAttributeName:@"rotate" value:pathRotateString element:self.pluginTargetXMLElement];
            NSArray * mpathElementsArray = [animateMotionElement elementsForName:@"mpath"];
            for (NSXMLElement * aMpathElement in mpathElementsArray)
            {
                [animateMotionElement removeChildAtIndex:aMpathElement.index];
            }
            break;
        }
        case 3:
        {
            [self.pluginTargetXMLElement removeAttributeForName:@"from"];
            [self.pluginTargetXMLElement removeAttributeForName:@"to"];
            [self.pluginTargetXMLElement removeAttributeForName:@"values"];
            [self.pluginTargetXMLElement removeAttributeForName:@"path"];
            NSArray * mpathElementsArray = [animateMotionElement elementsForName:@"mpath"];
            for (NSXMLElement * aMpathElement in mpathElementsArray)
            {
                [animateMotionElement removeChildAtIndex:aMpathElement.index];
            }
            NSXMLElement * newMpathElement = [[NSXMLElement alloc] init];
            newMpathElement.name = @"mpath";
            [self assignMacsvgidsForNode:newMpathElement];
            NSXMLNode * newXlinkHrefAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            newXlinkHrefAttribute.name = @"xlink:href";
            NSString * mpathXlinkHrefString = [NSString stringWithFormat:@"#%@", mpathString];
            newXlinkHrefAttribute.stringValue = mpathXlinkHrefString;
            [newMpathElement addAttribute:newXlinkHrefAttribute];
            [animateMotionElement addChild:newMpathElement];
            [self setAttributeName:@"rotate" value:mpathRotateString element:self.pluginTargetXMLElement];
            break;
        }
        default:
            break;
    }
    
    NSMutableString * keyTimesAttributeString = [NSMutableString string];
    NSMutableString * keySplinesAttributeString = [NSMutableString string];
    NSMutableString * keyPointsAttributeString = [NSMutableString string];
    
    NSArray * keyValuesArray = self.keyValuesPopoverViewController.keyValuesArray;
    
    for (NSDictionary * keyValuesDictionary in keyValuesArray)
    {
        NSString * keyTimesString = keyValuesDictionary[@"keyTimes"];
        NSString * keySplinesString = keyValuesDictionary[@"keySplines"];
        NSString * keyPointsString = keyValuesDictionary[@"keyPoints"];
        
        if (keyTimesString.length > 0)
        {
            if (keyTimesAttributeString.length > 0)
            {
                [keyTimesAttributeString appendString:@";"];
            }
            [keyTimesAttributeString appendString:keyTimesString];
        }
        
        if (keySplinesString.length > 0)
        {
            // apparent Chrome bug (formerly in WebKit) - don't end last spline with semicolon
            if (keySplinesAttributeString.length > 0)
            {
                [keySplinesAttributeString appendString:@";"];
            }
            [keySplinesAttributeString appendString:keySplinesString];
        }
        
        if (keyPointsString.length > 0)
        {
            if (keyPointsAttributeString.length > 0)
            {
                [keyPointsAttributeString appendString:@";"];
            }
            [keyPointsAttributeString appendString:keyPointsString];
        }
    }
    
    [self setAttributeName:@"keyTimes" value:keyTimesAttributeString element:self.pluginTargetXMLElement];
    [self setAttributeName:@"keySplines" value:keySplinesAttributeString element:self.pluginTargetXMLElement];
    [self setAttributeName:@"keyPoints" value:keyPointsAttributeString element:self.pluginTargetXMLElement];
    
    [self updateDocumentViews];
}


// -------------------------------------------------------------------------------
//  editKeyValuesButtonAction:
// -------------------------------------------------------------------------------

- (IBAction)editKeyValuesButtonAction:(id)sender
{
    NSButton *targetButton = (NSButton *)sender;
    
    NSInteger validRowsCount = [self.keyValuesPopoverViewController validRowsCount:self.animationValuesArray];
    [self.keyValuesPopoverViewController loadKeyValuesDataForValidRowsCount:validRowsCount];

    // configure the preferred position of the popover
    [self.keyValuesPopover showRelativeToRect:targetButton.bounds ofView:sender preferredEdge:NSMaxYEdge];
}

//==================================================================================
//	addValuesRow:
//==================================================================================

- (IBAction)addValuesRow:(id)sender
{
    NSInteger selectedRow = valuesTableView.selectedRow;

    if (selectedRow == -1)
    {
        if (self.animationValuesArray.count > 0)
        {
            selectedRow = self.animationValuesArray.count - 1;
        }
    }

    NSMutableArray * selectedRowArray = NULL;
    
    if (selectedRow >= 0)
    {
        selectedRowArray = (self.animationValuesArray)[selectedRow];
    }
    else
    {
        selectedRowArray = [NSMutableArray arrayWithObjects:@"0", @"0", NULL];
    }
    
    NSMutableArray * newRowArray = [NSMutableArray array];
    
    for (NSString * columnString in selectedRowArray)
    {
        NSString * newColumnString = [NSString stringWithString:columnString];
        
        [newRowArray addObject:newColumnString];
    }
    
    [self.animationValuesArray insertObject:newRowArray atIndex:(selectedRow + 1)];
    
    [valuesTableView reloadData];
    
    NSIndexSet * rowIndexSet = [NSIndexSet indexSetWithIndex:(selectedRow + 1)];
    [valuesTableView selectRowIndexes:rowIndexSet byExtendingSelection:NO];
}

//==================================================================================
//	deleteValuesRow:
//==================================================================================

- (IBAction)deleteValuesRow:(id)sender
{
    NSInteger selectedRow = valuesTableView.selectedRow;

    if (selectedRow >= 0)
    {
        [self.animationValuesArray removeObjectAtIndex:selectedRow];
        
        [valuesTableView reloadData];
    }
    
    if (selectedRow > self.animationValuesArray.count - 1)
    {
        selectedRow = self.animationValuesArray.count - 1;
    }

    NSIndexSet * rowIndexSet = [NSIndexSet indexSetWithIndex:selectedRow];
    [valuesTableView selectRowIndexes:rowIndexSet byExtendingSelection:NO];
}

@end
