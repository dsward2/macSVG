//
//  AnimateElementEditor.m
//  AnimateElementEditor
//
//  Created by Douglas Ward on 9/4/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "AnimateElementEditor.h"
#import <MacSVGPlugin/KeyValuesPopoverViewController.h>
#import "MacSVGDocument.h"
#import "MacSVGDocumentWindowController.h"
#import "SVGHelpManager.h"


@implementation AnimateElementEditor

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
}

//==================================================================================
//    awakeFromNib
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
    if (self) {
        // Initialization code here.
        self.animationValuesArray = [NSMutableArray array];
    }
    
    return self;
}

//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    return @"Animate Element Editor";
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element tag name
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    NSString * result = NULL;

    if ([elementName isEqualToString:@"animate"] == YES)
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

    [self loadAnimateSettings];
    
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
//	loadAnimateSettings
//==================================================================================

- (void)loadAnimateSettings
{
    NSXMLElement * animateElement = self.pluginTargetXMLElement;
    NSTabViewItem * selectedTabViewItem = [animateElementTabView selectedTabViewItem];
    
    [self setAttribute:@"attributeName" element:animateElement comboBox:attributeNameComboBox];
    
    [self setAttribute:@"attributeType" element:animateElement popUpButton:attributeTypePopUpButton];
    
    [self setAttribute:@"calcMode" element:animateElement popUpButton:calcModePopUpButton];
    
    [self setAttribute:@"begin" element:animateElement textField:beginTextField];
    [self setAttribute:@"dur" element:animateElement textField:durTextField];
    
    [self setAttribute:@"repeatCount" element:animateElement comboBox:repeatCountComboBox];

    [self setAttribute:@"begin" element:animateElement textField:beginTextField];

    BOOL tabViewWasSelected = NO;

    fromTextField.stringValue = @"";
    NSXMLNode * fromAttributeNode = [animateElement attributeForName:@"from"];
    if (fromAttributeNode != NULL)
    {
        NSString * fromAttributeValue = fromAttributeNode.stringValue;
        fromTextField.stringValue = fromAttributeValue;
        
        if ([animateElementTabView indexOfTabViewItem:selectedTabViewItem] == 2)
        {
            [animateElementTabView selectTabViewItemAtIndex:1];
            tabViewWasSelected = YES;
        }
    }

    toTextField.stringValue = @"";
    NSXMLNode * toAttributeNode = [animateElement attributeForName:@"to"];
    if (toAttributeNode != NULL)
    {
        NSString * toAttributeValue = toAttributeNode.stringValue;
        toTextField.stringValue = toAttributeValue;
        
        if ([animateElementTabView indexOfTabViewItem:selectedTabViewItem] == 2)
        {
            [animateElementTabView selectTabViewItemAtIndex:1];
            tabViewWasSelected = YES;
        }
    }

    //[valuesTextView setString:@""];
    NSXMLNode * valuesAttributeNode = [animateElement attributeForName:@"values"];
    if (valuesAttributeNode != NULL)
    {
        
        if ([animateElementTabView indexOfTabViewItem:selectedTabViewItem] == 1)
        {
            [animateElementTabView selectTabViewItemAtIndex:2];
            tabViewWasSelected = YES;
        }
        
        [self configureAnimationKeyValuesWithUseKeyPoints:NO];
        [valuesTableView reloadData];
    }
    
    if (tabViewWasSelected == NO)
    {
        [animateElementTabView selectTabViewItemAtIndex:0];
    }
}

//==================================================================================
//	configureValuesTableView
//==================================================================================

/*
- (void)configureValuesTableView
{
    self.valuesArray = [NSMutableArray array];

    NSXMLElement * animateElement = self.pluginTargetXMLElement;

    NSXMLNode * valuesAttributeNode = [animateElement attributeForName:@"values"];
    
    if (valuesAttributeNode != NULL)
    {
        NSString * valuesAttributeString = valuesAttributeNode.stringValue;
        
        NSArray * valueRowsArray = [valuesAttributeString componentsSeparatedByString:@";"];

        NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        for (NSString * aValuesString in valueRowsArray)
        {
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
            
                [self.valuesArray addObject:filteredValuesString];
            }
        }
    }
    
    [valuesTableView reloadData];
    
    [self.keyValuesPopoverViewController useKeyPoints:NO];
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
/*
- (IBAction)itemTextFieldUpdated:(id)sender
{
    NSInteger rowIndex = [valuesTableView rowForView:sender];
    
    if (rowIndex >= 0)
    {
        NSString * stringValue = [sender stringValue];
        
        stringValue = [stringValue copy];
        
        if (rowIndex < self.animationValuesArray.count)
        {
            [self.animationValuesArray replaceObjectAtIndex:rowIndex withObject:stringValue];
        }
        else
        {
            [self.animationValuesArray addObject:stringValue];
        }
    }
}
*/

//==================================================================================
//    itemTextFieldUpdated:
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

    NSString * cellViewIndentifier = [tableColumnIdentifier stringByAppendingString:@"CellView"];

    NSTableCellView * tableCellView = [tableView makeViewWithIdentifier:cellViewIndentifier owner:NULL];
    
    NSTextField * textField = tableCellView.textField;
    
    NSString * resultString = @"";
    
    if ([tableColumnIdentifier isEqualToString:@"rowNumber"] == YES)
    {
        resultString = [NSString stringWithFormat:@"%ld", (row + 1)];
        textField.editable = NO;
    }
    else
    {
        textField.editable = YES;
        textField.delegate = self;
        
        textField.target = self;
        textField.action = @selector(itemTextFieldUpdated:);
        
        if (row < self.animationValuesArray.count)
        {
            NSMutableArray * rowArray = [self.animationValuesArray objectAtIndex:row];
            resultString = rowArray.firstObject;
        }
    }

    textField.stringValue = resultString;
    
    return tableCellView;
}

//==================================================================================
//	numberOfItemsInComboBox:
//==================================================================================

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox
{
    NSInteger result = 0;

    if (comboBox == repeatCountComboBox)
    {
        result = 3;
    }
    else if (comboBox == attributeNameComboBox)
    {
        NSArray * attributeNamesArray = [self filteredParentAttributeNames];
        
        result = [attributeNamesArray count];
    }
    
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
    else if (aComboBox == attributeNameComboBox)
    {
        result = [self attributeNameComboBoxObjectValueAtIndex:index];
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
//	attributeNameComboBoxObjectValueAtIndex
//==================================================================================

- (NSString *)attributeNameComboBoxObjectValueAtIndex:(NSInteger)index
{
    NSString * result = @"Missing Item";
    
    NSArray * filteredParentAttributeNames = [self filteredParentAttributeNames];
    
    if (filteredParentAttributeNames != NULL)
    {
        if (index < filteredParentAttributeNames.count)
        {
            result = [filteredParentAttributeNames objectAtIndex:index];
        }
    }
    
    return result;
}

//==================================================================================
//	filteredParentAttributeNames
//==================================================================================

- (NSArray *)filteredParentAttributeNames
{
    NSMutableArray * result = NULL;

    NSXMLElement * parentElement = (NSXMLElement *)self.pluginTargetXMLElement.parent;
    
    if (parentElement != NULL)
    {
        NSArray * parentAttributesArray = [parentElement attributes];
        
        for (NSXMLNode * attributeNode in parentAttributesArray)
        {
            if (attributeNode.kind == NSXMLAttributeKind)
            {
                NSString * attributeName = [attributeNode name];
                
                if (result == NULL)
                {
                    result = [NSMutableArray array];
                }
                
                BOOL addItem = YES;
                
                if ([attributeName isEqualToString:@"macsvgid"] == YES)
                {
                    addItem = NO;
                }
                else
                {
                    addItem = [self attributeIsAnimatable:attributeName];
                }
                
                if (addItem == YES)
                {
                    [result addObject:attributeName];
                }
            }
        }
        
        NSArray * sortedArray = [result sortedArrayUsingFunction:attributeNameSort context:NULL];
        
        result = [sortedArray mutableCopy];
    }
    
    return result;
}

//==================================================================================
//	directoryListingSort()
//==================================================================================

NSComparisonResult attributeNameSort(id name1, id name2, void *context)
{
    NSComparisonResult sortResult = NSOrderedSame;

    sortResult = [name1 compare:name2];

    return sortResult;
}

//==================================================================================
//	attributeIsAnimatable:
//==================================================================================

- (BOOL)attributeIsAnimatable:(NSString *)attributeName
{
    BOOL result = NO;

    MacSVGDocumentWindowController * macSVGDocumentWindowController =
            [self.macSVGDocument macSVGDocumentWindowController];

    for (NSDictionary * attributeHelpDictionary in macSVGDocumentWindowController.svgHelpManager.attributesHelpArray)
    {
        NSString * aAttributeName = attributeHelpDictionary[@"attributeName"];
        
        if ([attributeName isEqualToString:aAttributeName])
        {
            NSString * attributeAnimatableString = [attributeHelpDictionary objectForKey:@"attributeAnimatable"];
            
            if ([attributeAnimatableString isEqualToString:@"1"] == YES)
            {
                result = YES;
            }
            
            break;
        }
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
    //NSXMLElement * animateElement = self.pluginTargetXMLElement;
    
    NSString * attributeName = attributeNameComboBox.stringValue;
    NSString * attributeType = attributeTypePopUpButton.titleOfSelectedItem;
    NSString * calcModeString = calcModePopUpButton.titleOfSelectedItem;
    NSString * beginString = beginTextField.stringValue;
    NSString * durString = durTextField.stringValue;
    NSString * repeatCountString = repeatCountComboBox.stringValue;
    
    NSTabViewItem * animateElementTabViewItem = animateElementTabView.selectedTabViewItem;
    NSInteger animateElementTabIndex = [animateElementTabView indexOfTabViewItem:animateElementTabViewItem];
    
    NSString * fromString = fromTextField.stringValue;
    NSString * toString = toTextField.stringValue;
    
    //NSString * valuesString = [valuesTextView string];
    //valuesString = [valuesString stringByReplacingOccurrencesOfString:@";\n" withString:@";"];
    
    NSMutableString * valuesString = [NSMutableString string];
    for (NSArray * valueItemsArray in self.animationValuesArray)
    {
        NSString * aValueString = valueItemsArray.firstObject;
        if (valuesString.length > 0)
        {
            [valuesString appendString:@";"];
        }
        [valuesString appendString:aValueString];
    }
    
    [self setAttributeName:@"attributeName" value:attributeName element:self.pluginTargetXMLElement];
    [self setAttributeName:@"attributeType" value:attributeType element:self.pluginTargetXMLElement];
    [self setAttributeName:@"calcMode" value:calcModeString element:self.pluginTargetXMLElement];
    [self setAttributeName:@"begin" value:beginString element:self.pluginTargetXMLElement];
    [self setAttributeName:@"dur" value:durString element:self.pluginTargetXMLElement];
    [self setAttributeName:@"repeatCount" value:repeatCountString element:self.pluginTargetXMLElement];
    
    if (animateElementTabIndex == 0)
    {
        if (valuesString.length > 0)
        {
            animateElementTabIndex = 2;
        }
        else if (fromString.length > 0)
        {
            animateElementTabIndex = 1;
        }
        else if (toString.length > 0)
        {
            animateElementTabIndex = 1;
        }
        else
        {
            animateElementTabIndex = 2;
        }
    }
    
    switch (animateElementTabIndex)
    {
        case 1:
        {
            [self setAttributeName:@"from" value:fromString element:self.pluginTargetXMLElement];
            [self setAttributeName:@"to" value:toString element:self.pluginTargetXMLElement];
            //[self setAttributeName:@"values" value:@"" element:self.pluginTargetXMLElement];
            [self.pluginTargetXMLElement removeAttributeForName:@"values"];
            break;
        }
        case 2:
        {
            //[self setAttributeName:@"from" value:@"" element:self.pluginTargetXMLElement];
            //[self setAttributeName:@"to" value:@"" element:self.pluginTargetXMLElement];
            [self setAttributeName:@"values" value:valuesString element:self.pluginTargetXMLElement];
            [self.pluginTargetXMLElement removeAttributeForName:@"from"];
            [self.pluginTargetXMLElement removeAttributeForName:@"to"];

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
            if (keySplinesAttributeString.length > 0)
            {
                [keySplinesAttributeString appendString:@";"];
            }
            [keySplinesAttributeString appendString:keySplinesString];
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
    
    NSString * selectedRowString = @"0";

    if (selectedRow >= 0)
    {
        NSMutableArray * selectedRowArray = (self.animationValuesArray)[selectedRow];
        selectedRowString = selectedRowArray.firstObject;
    }
    else
    {
        if (self.animationValuesArray.count > 0)
        {
            NSMutableArray * selectedRowArray = self.animationValuesArray.lastObject;
            selectedRowString = selectedRowArray.firstObject;
        }
    }
        
    NSString * newRowString = [NSString stringWithString:selectedRowString];
    
    NSMutableArray * newRowArray = [NSMutableArray array];
    [newRowArray addObject:newRowString];

    NSInteger newRowIndex = selectedRow + 1;

    if (selectedRow > 0)
    {
        [self.animationValuesArray insertObject:newRowArray atIndex:(selectedRow + 1)];
    }
    else
    {
        [self.animationValuesArray addObject:newRowArray];
        newRowIndex = self.animationValuesArray.count - 1;
    }
    
    [valuesTableView reloadData];
    
    NSIndexSet * rowIndexSet = [NSIndexSet indexSetWithIndex:newRowIndex];
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
