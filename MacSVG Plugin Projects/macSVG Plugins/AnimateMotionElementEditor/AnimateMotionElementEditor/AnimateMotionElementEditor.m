//
//  AnimateMotionElementEditor.m
//  AnimateMotionElementEditor
//
//  Created by Douglas Ward on 8/26/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "AnimateMotionElementEditor.h"
#import "AnimateMotionKeyValuesPopoverViewController.h"
#import "AnimateMotionTableRowView.h"

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

    self.valuesArray = [NSMutableArray array];
    
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
        [self configureValuesTableView];
        
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

- (void)configureValuesTableView
{
    self.valuesArray = [NSMutableArray array];

    valuesTableView.columnAutoresizingStyle = NSTableViewUniformColumnAutoresizingStyle;

    while(valuesTableView.tableColumns.count > 0)
    {
        [valuesTableView removeTableColumn:valuesTableView.tableColumns.lastObject];
    }
    
    valuesTableView.columnAutoresizingStyle = NSTableViewUniformColumnAutoresizingStyle;
    
    NSTableColumn * indexTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"#"];
    indexTableColumn.title = @"#";
    indexTableColumn.width = 30.0f;
    indexTableColumn.minWidth = 30.0f;
    indexTableColumn.maxWidth = 100.0f;
    [valuesTableView addTableColumn:indexTableColumn];
    
    CGFloat tableWidth = valuesTableView.bounds.size.width - 30.0f;

    CGFloat columnWidth = tableWidth / 2.0f;

    NSTableColumn * xTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"x"];
    xTableColumn.title = @"x";
    xTableColumn.width = columnWidth;
    xTableColumn.minWidth = 60.0f;
    xTableColumn.maxWidth = 100.0f;
    [valuesTableView addTableColumn:xTableColumn];

    NSTableColumn * yTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"y"];
    yTableColumn.title = @"y";
    yTableColumn.width = columnWidth;
    yTableColumn.minWidth = 60.0f;
    yTableColumn.maxWidth = 100.0f;
    [valuesTableView addTableColumn:yTableColumn];

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
    
    valuesTableView.rowHeight = 14.0f;
}

//==================================================================================
//	numberOfRowsInTableView:
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return (self.valuesArray).count;
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
        
        if (rowIndex <= ((self.valuesArray).count - 1))
        {
            NSMutableArray * rowArray = (self.valuesArray)[rowIndex];
            
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
//	tableView:rowViewForRow:
//==================================================================================

- (NSTableRowView *)tableView:(NSTableView *)tableView
                rowViewForRow:(NSInteger)row
{
    // from http://stackoverflow.com/questions/10910779/coloring-rows-in-view-based-nstableview
    static NSString* const kRowIdentifier = @"AnimateMotionTableRowView";
    
    //AnimateMotionTableRowView * rowView = [tableView makeViewWithIdentifier:kRowIdentifier owner:self];
    AnimateMotionTableRowView * rowView = [tableView makeViewWithIdentifier:kRowIdentifier owner:NULL];

    if (rowView == NULL)
    {
        // Size doesn't matter, the table will set it
        rowView = [[AnimateMotionTableRowView alloc] initWithFrame:NSZeroRect];

        // This seemingly magical line enables your view to be found
        // next time "makeViewWithIdentifier" is called.
        rowView.identifier = kRowIdentifier; 
    }

    // Can customize properties here. Note that customizing
    // 'backgroundColor' isn't going to work at this point since the table
    // will reset it later. Use 'didAddRow' to customize if desired.

    return rowView;
}

//==================================================================================
//	tableView:viewForTableColumn:row:
//==================================================================================

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    //NSTextField * resultView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    NSTextField * resultView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:NULL];

    if (resultView == nil)
    {
        resultView = [[NSTextField alloc] initWithFrame:tableView.frame];
        resultView.identifier = tableColumn.identifier;
        resultView.font = [NSFont systemFontOfSize:10];
        resultView.bordered = NO;
        resultView.backgroundColor = [NSColor clearColor];
    }

    NSString * resultString = @"";

    NSString * tableColumnIdentifier = tableColumn.identifier;
    
    if ([tableColumnIdentifier isEqualToString:@"#"] == YES)
    {
        resultString = [NSString stringWithFormat:@"%ld", (row + 1)];
        resultView.editable = NO;
    }
    else
    {
        resultView.editable = YES;
        resultView.delegate = self;
        
        NSArray * rowArray = (self.valuesArray)[row];
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

    resultView.stringValue = resultString;
    
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
    for (NSArray * rowArray in self.valuesArray)
    {
        NSInteger rowArrayCount = rowArray.count;
        NSInteger indexOfObject = 0;
        for (NSString * columnString in rowArray)
        {
            [valuesString appendString:columnString];
            
            if (indexOfObject >= (rowArrayCount - 1))
            {
                [valuesString appendString:@";"];
            }
            else
            {
                [valuesString appendString:@" "];
            }
            
            indexOfObject++;
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
    
    NSArray * keyValuesArray = animateMotionKeyValuesPopoverViewController.keyValuesArray;
    
    for (NSDictionary * keyValuesDictionary in keyValuesArray)
    {
        NSString * keyTimesString = keyValuesDictionary[@"keyTimes"];
        NSString * keySplinesString = keyValuesDictionary[@"keySplines"];
        NSString * keyPointsString = keyValuesDictionary[@"keyPoints"];
        
        if (keyTimesString.length > 0)
        {
            [keyTimesAttributeString appendFormat:@"%@;", keyTimesString];
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
            [keyPointsAttributeString appendFormat:@"%@;", keyPointsString];
        }
    }
    
    [self setAttributeName:@"keyTimes" value:keyTimesAttributeString element:self.pluginTargetXMLElement];
    [self setAttributeName:@"keySplines" value:keySplinesAttributeString element:self.pluginTargetXMLElement];
    [self setAttributeName:@"keyPoints" value:keyPointsAttributeString element:self.pluginTargetXMLElement];
    
    [self updateDocumentViews];
}


// -------------------------------------------------------------------------------
//  keyValuesButtonAction:
// -------------------------------------------------------------------------------

- (IBAction)keyValuesButtonAction:(id)sender
{
    NSButton *targetButton = (NSButton *)sender;
    
    [animateMotionKeyValuesPopoverViewController loadKeyValuesData];
    
    // configure the preferred position of the popover
    [animateMotionKeyValuesPopover showRelativeToRect:targetButton.bounds ofView:sender preferredEdge:NSMaxYEdge];
}

//==================================================================================
//	addValuesRow:
//==================================================================================

- (IBAction)addValuesRow:(id)sender
{
    NSInteger selectedRow = valuesTableView.selectedRow;
    
    NSMutableArray * selectedRowArray = NULL;
    
    if (selectedRow >= 0)
    {
        selectedRowArray = (self.valuesArray)[selectedRow];
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
    
    [self.valuesArray insertObject:newRowArray atIndex:(selectedRow + 1)];
    
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
        [self.valuesArray removeObjectAtIndex:selectedRow];
        
        [valuesTableView reloadData];
    }
}

@end
