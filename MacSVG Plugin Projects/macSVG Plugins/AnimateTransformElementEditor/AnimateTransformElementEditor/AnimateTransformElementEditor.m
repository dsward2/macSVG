//
//  AnimateTransformElementEditor.m
//  AnimateTransformElementEditor
//
//  Created by Douglas Ward on 9/1/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "AnimateTransformElementEditor.h"
#import "AnimateTransformKeyValuesPopoverViewController.h"
#import "AnimateTransformTableRowView.h"

@implementation AnimateTransformElementEditor

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
    if (self) {
        // Initialization code here.
        self.valuesArray = [NSMutableArray array];
    }
    
    return self;
}

//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    return @"AnimateTransform Element Editor";
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element tag name
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    NSString * result = NULL;

    if ([elementName isEqualToString:@"animateTransform"] == YES)
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

    if ([elementName isEqualToString:@"animateTransform"] == YES)
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

    [self loadAnimateTransformSettings];
    
    return result;
}

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
//	loadAnimateTransformSettings
//==================================================================================

- (void)loadAnimateTransformSettings
{
    NSXMLElement * animateTransformElement = self.pluginTargetXMLElement;
    
    [self setAttribute:@"calcMode" element:animateTransformElement popUpButton:calcModePopUpButton];
    
    [self setAttribute:@"begin" element:animateTransformElement textField:beginTextField];
    [self setAttribute:@"dur" element:animateTransformElement textField:durTextField];
    
    [self setAttribute:@"repeatCount" element:animateTransformElement comboBox:repeatCountComboBox];

    [self setAttribute:@"begin" element:animateTransformElement textField:beginTextField];

    fromXTextField.stringValue = @"";
    fromYTextField.stringValue = @"";
    NSXMLNode * fromAttributeNode = [animateTransformElement attributeForName:@"from"];
    if (fromAttributeNode != NULL)
    {
        NSString * fromAttributeValue = fromAttributeNode.stringValue;
        NSArray * fromAttributeArray = [fromAttributeValue componentsSeparatedByString:@" "];
        if (fromAttributeArray.count > 1)
        {
            NSString * fromXAttributeValue = fromAttributeArray[0];
            NSString * fromYAttributeValue = fromAttributeArray[1];
            fromXTextField.stringValue = fromXAttributeValue;
            fromYTextField.stringValue = fromYAttributeValue;
        }
    }

    toXTextField.stringValue = @"";
    toYTextField.stringValue = @"";
    NSXMLNode * toAttributeNode = [animateTransformElement attributeForName:@"to"];
    if (toAttributeNode != NULL)
    {
        NSString * toAttributeValue = toAttributeNode.stringValue;
        NSArray * toAttributeArray = [toAttributeValue componentsSeparatedByString:@" "];
        if (toAttributeArray.count > 1)
        {
            [animateTransformTabView selectTabViewItemAtIndex:0];

            NSString * toXAttributeValue = toAttributeArray[0];
            NSString * toYAttributeValue = toAttributeArray[1];
            toXTextField.stringValue = toXAttributeValue;
            toYTextField.stringValue = toYAttributeValue;
        }
    }

    NSXMLNode * valuesAttributeNode = [animateTransformElement attributeForName:@"values"];
    if (valuesAttributeNode != NULL)
    {
        [animateTransformTabView selectTabViewItemAtIndex:1];
        
        [self configureValuesTableView];
    }
}

//==================================================================================
//	configureValuesTableView
//==================================================================================

- (void)configureValuesTableView
{
    self.valuesArray = [NSMutableArray array];

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
    
    NSXMLElement * animateTransformElement = self.pluginTargetXMLElement;

    NSString * typeAttributeString = @"translate";
    
    NSXMLNode * typeAttributeNode = [animateTransformElement attributeForName:@"type"];
    if (typeAttributeNode != NULL)
    {
        typeAttributeString = typeAttributeNode.stringValue;
    }
    
    if ([typeAttributeString isEqualToString:@"translate"] == YES)
    {
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
    }
    else if ([typeAttributeString isEqualToString:@"scale"] == YES)
    {
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
    }
    else if ([typeAttributeString isEqualToString:@"rotate"] == YES)
    {
        CGFloat columnWidth = tableWidth / 3.0f;

        NSTableColumn * degreesTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"degrees"];
        degreesTableColumn.title = @"degrees";
        degreesTableColumn.width = columnWidth;
        degreesTableColumn.minWidth = 60.0f;
        degreesTableColumn.maxWidth = 100.0f;
        [valuesTableView addTableColumn:degreesTableColumn];
        
        NSTableColumn * xTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"center x"];
        xTableColumn.title = @"center x";
        xTableColumn.width = columnWidth;
        xTableColumn.minWidth = 60.0f;
        xTableColumn.maxWidth = 100.0f;
        [valuesTableView addTableColumn:xTableColumn];
    
        NSTableColumn * yTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"center y"];
        yTableColumn.title = @"center y";
        yTableColumn.width = columnWidth;
        yTableColumn.minWidth = 60.0f;
        yTableColumn.maxWidth = 100.0f;
        [valuesTableView addTableColumn:yTableColumn];
    }
    else if ([typeAttributeString isEqualToString:@"skewX"] == YES)
    {
        CGFloat columnWidth = tableWidth;

        NSTableColumn * xTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"x"];
        xTableColumn.title = @"x";
        xTableColumn.width = columnWidth;
        xTableColumn.minWidth = 60.0f;
        xTableColumn.maxWidth = 100.0f;
        [valuesTableView addTableColumn:xTableColumn];
    }
    else if ([typeAttributeString isEqualToString:@"skewY"] == YES)
    {
        CGFloat columnWidth = tableWidth;

        NSTableColumn * yTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"y"];
        yTableColumn.title = @"y";
        yTableColumn.width = columnWidth;
        yTableColumn.minWidth = 60.0f;
        yTableColumn.maxWidth = 100.0f;
        [valuesTableView addTableColumn:yTableColumn];
    }

    NSXMLNode * valuesAttributeNode = [animateTransformElement attributeForName:@"values"];
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
                
                valueItemsArray = [valueItemsArray mutableCopy];
                
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
    NSInteger columnIndex = [valuesTableView columnForView:sender];
    
    NSString * stringValue = [sender stringValue];
    
    stringValue = [stringValue copy];
    
    NSMutableArray * rowArray = (self.valuesArray)[rowIndex];
    
    if (columnIndex >= rowArray.count)
    {
        [rowArray addObject:stringValue];
    }
    else
    {
        rowArray[(columnIndex - 1)] = stringValue;
    }
    
    NSTextField * textField = sender;
    textField.backgroundColor = [NSColor clearColor];
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
    
    AnimateTransformTableRowView * rowView = [tableView makeViewWithIdentifier:kRowIdentifier owner:self];
    
    if (rowView == NULL)
    {
        rowView = [[AnimateTransformTableRowView alloc] initWithFrame:NSZeroRect];
        rowView.identifier = kRowIdentifier;
    }

    return rowView;
}

//==================================================================================
//	tableView:viewForTableColumn:row:
//==================================================================================

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTextField * resultView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];

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
        
        resultView.target = self;
        resultView.action = @selector(itemTextFieldUpdated:);
    
        NSXMLElement * animateTransformElement = self.pluginTargetXMLElement;
        
        NSArray * rowArray = (self.valuesArray)[row];
        NSInteger rowArrayCount = rowArray.count;

        NSString * typeAttributeString = @"translate";
        
        NSXMLNode * typeAttributeNode = [animateTransformElement attributeForName:@"type"];
        if (typeAttributeNode != NULL)
        {
            typeAttributeString = typeAttributeNode.stringValue;
        }
        
        if ([typeAttributeString isEqualToString:@"translate"] == YES)
        {
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
        else if ([typeAttributeString isEqualToString:@"scale"] == YES)
        {
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
        else if ([typeAttributeString isEqualToString:@"rotate"] == YES)
        {
            if ([tableColumnIdentifier isEqualToString:@"degrees"] == YES)
            {
                if (rowArrayCount > 0)
                {
                    resultString = rowArray[0];
                }
            }
            if ([tableColumnIdentifier isEqualToString:@"center x"] == YES)
            {
                if (rowArrayCount > 1)
                {
                    resultString = rowArray[1];
                }
            }
            else if ([tableColumnIdentifier isEqualToString:@"center y"] == YES)
            {
                if (rowArrayCount > 2)
                {
                    resultString = rowArray[2];
                }
            }
        }
        else if ([typeAttributeString isEqualToString:@"skewX"] == YES)
        {
            if ([tableColumnIdentifier isEqualToString:@"x"] == YES)
            {
                if (rowArrayCount > 0)
                {
                    resultString = rowArray[0];
                }
            }
        }
        else if ([typeAttributeString isEqualToString:@"skewY"] == YES)
        {
            if ([tableColumnIdentifier isEqualToString:@"y"] == YES)
            {
                if (rowArrayCount > 0)
                {
                    resultString = rowArray[0];
                }
            }
        }
    }

    resultView.stringValue = resultString;
    
    return resultView;
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
    NSXMLElement * animateTransformElement = self.pluginTargetXMLElement;
    
    NSString * calcModeString = calcModePopUpButton.titleOfSelectedItem;
    NSString * beginString = beginTextField.stringValue;
    NSString * durString = durTextField.stringValue;
    NSString * repeatCountString = repeatCountComboBox.stringValue;
    
    NSTabViewItem * animateTransformTabViewItem = animateTransformTabView.selectedTabViewItem;
    NSInteger animateTransformTabIndex = [animateTransformTabView indexOfTabViewItem:animateTransformTabViewItem];
    
    NSString * fromXString = fromXTextField.stringValue;
    NSString * fromYString = fromYTextField.stringValue;
    NSString * toXString = toXTextField.stringValue;
    NSString * toYString = toYTextField.stringValue;


    NSString * typeAttributeString = @"translate";
    NSInteger rowArrayCount = 2;

    NSXMLNode * typeAttributeNode = [animateTransformElement attributeForName:@"type"];
    if (typeAttributeNode != NULL)
    {
        typeAttributeString = typeAttributeNode.stringValue;
    }

    if ([typeAttributeString isEqualToString:@"translate"] == YES)
    {
        rowArrayCount = 2;
    }
    else if ([typeAttributeString isEqualToString:@"scale"] == YES)
    {
        rowArrayCount = 2;
    }
    else if ([typeAttributeString isEqualToString:@"rotate"] == YES)
    {
        rowArrayCount = 3;
    }
    else if ([typeAttributeString isEqualToString:@"skewX"] == YES)
    {
        rowArrayCount = 1;
    }
    else if ([typeAttributeString isEqualToString:@"skewY"] == YES)
    {
        rowArrayCount = 1;
    }
    
    NSMutableString * valuesString = [NSMutableString string];
    for (NSArray * rowArray in self.valuesArray)
    {
        NSInteger actualRowArrayCount = rowArray.count;
        
        if (rowArrayCount <= actualRowArrayCount)
        {
            NSInteger indexOfObject = 0;
            //for (NSString * columnString in rowArray)
            for (NSInteger i = 0; i < rowArrayCount; i++)
            {
                NSString * columnString = [rowArray objectAtIndex:i];
            
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
    }
    
    [self setAttributeName:@"calcMode" value:calcModeString element:self.pluginTargetXMLElement];
    [self setAttributeName:@"begin" value:beginString element:self.pluginTargetXMLElement];
    [self setAttributeName:@"dur" value:durString element:self.pluginTargetXMLElement];
    [self setAttributeName:@"repeatCount" value:repeatCountString element:self.pluginTargetXMLElement];
    
    switch (animateTransformTabIndex)
    {
        case 0:
        {
            NSString * fromString = [NSString stringWithFormat:@"%@ %@", fromXString, fromYString];
            NSString * toString = [NSString stringWithFormat:@"%@ %@", toXString, toYString];
            [self setAttributeName:@"from" value:fromString element:self.pluginTargetXMLElement];
            [self setAttributeName:@"to" value:toString element:self.pluginTargetXMLElement];
            [self setAttributeName:@"values" value:@"" element:self.pluginTargetXMLElement];
            break;
        }
        case 1:
        {
            [self setAttributeName:@"from" value:@"" element:self.pluginTargetXMLElement];
            [self setAttributeName:@"to" value:@"" element:self.pluginTargetXMLElement];
            [self setAttributeName:@"values" value:valuesString element:self.pluginTargetXMLElement];
            break;
        }
        default:
            break;
    }
    
    NSMutableString * keyTimesAttributeString = [NSMutableString string];
    NSMutableString * keySplinesAttributeString = [NSMutableString string];
    NSMutableString * keyPointsAttributeString = [NSMutableString string];
    
    NSArray * keyValuesArray = keyValuesPopoverViewController.keyValuesArray;
    
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
            // apparent webkit bug - don't end last spline with semicolon
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
    
    [keyValuesPopoverViewController loadKeyValuesData];
    
    // configure the preferred position of the popover
    [keyValuesPopover showRelativeToRect:targetButton.bounds ofView:sender preferredEdge:NSMaxYEdge];
}

//==================================================================================
//	addValuesRow:
//==================================================================================

- (IBAction)addValuesRow:(id)sender
{
    NSInteger selectedRow = valuesTableView.selectedRow;
    
    NSMutableArray * selectedRowArray = [NSMutableArray array];
    
    if (selectedRow > 0)
    {
        selectedRowArray = (self.valuesArray)[selectedRow];
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
