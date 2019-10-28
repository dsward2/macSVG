//
//  StyleAttributeEditor.m
//  StyleAttributeEditor
//
//  Created by Douglas Ward on 1/2/17.
//  Copyright © 2017 ArkPhone LLC. All rights reserved.
//

#import "StyleAttributeEditor.h"
#import "StylePropertiesTableRowView.h"
#import <MacSVGPlugin/MacSVGPluginCallbacks.h>
#import "MacSVGDocumentWindowController.h"
#import "SVGWebKitController.h"
#import "StylePropertiesTableRowView.h"

@implementation StyleAttributeEditor


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
        
       NSBundle * thisBundle = [NSBundle bundleForClass:[self class]];

       NSURL * cssProperiesURL = [thisBundle URLForResource:@"CSSProperties" withExtension:@"json"];
        
        NSData * cssPropertiesData = [NSData dataWithContentsOfURL:cssProperiesURL];
        
        NSError * jsonError = NULL;
        NSJSONReadingOptions jsonOptions = 0;
        self.cssPropertiesDictionary = [NSJSONSerialization JSONObjectWithData:cssPropertiesData
                options:jsonOptions error:&jsonError];
        
        NSDictionary * propertiesDictionary = [self.cssPropertiesDictionary objectForKey:@"properties"];
        NSArray * propertiesAllKeysArray = [propertiesDictionary allKeys];

        propertiesAllKeysArray = [propertiesAllKeysArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

        self.styleNamesComboArray = propertiesAllKeysArray;
        self.styleValuesComboArray = [NSArray array];
    }
    
    return self;
}

//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    return @"Style Attribute Editor";
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element tag name
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    NSString * result = NULL;
    
    // currently, the element name is not a factor for this plugin

    return result;
}

//==================================================================================
//	isEditorForElement:elementName:attribute:
//==================================================================================

// return label if this editor can edit specified element and attribute
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName attribute:(NSString *)attributeName
{   
    NSString * result = NULL;

    if ([attributeName isEqualToString:@"style"] == YES)
    {
        result = self.pluginName;
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

    self.stylePropertiesArray = [NSMutableArray array];

    [self loadStylePropertiesData];
    
    [stylePropertiesTableView reloadData];

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

    self.stylePropertiesArray = [NSMutableArray array];

    [self loadStylePropertiesData];
    
    [stylePropertiesTableView reloadData];
    
    return result;
}

#pragma clang diagnostic pop

//==================================================================================
//	loadStylePropertiesData
//==================================================================================

- (void)loadStylePropertiesData
{
    NSXMLNode * styleAttributeNode = [self.pluginTargetXMLElement attributeForName:@"style"];
    if (styleAttributeNode != NULL)
    {
        //NSString * valuesAttributeValue = [valuesAttributeNode stringValue];
        //[valuesTextView setString:valuesAttributeValue];
        
        [self configureStylePropertiesTableView];
    }
    else
    {
        [self.stylePropertiesArray removeAllObjects];
    }
}

//==================================================================================
//	configureStylePropertiesTableView
//==================================================================================

- (void)configureStylePropertiesTableView
{
    self.stylePropertiesArray = [NSMutableArray array];

    /*
    stylePropertiesTableView.columnAutoresizingStyle = NSTableViewUniformColumnAutoresizingStyle;

    while(stylePropertiesTableView.tableColumns.count > 0)
    {
        [stylePropertiesTableView removeTableColumn:stylePropertiesTableView.tableColumns.lastObject];
    }
    
    stylePropertiesTableView.columnAutoresizingStyle = NSTableViewUniformColumnAutoresizingStyle;
    
    NSTableColumn * indexTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"#"];
    indexTableColumn.title = @"#";
    indexTableColumn.width = 30.0f;
    indexTableColumn.minWidth = 30.0f;
    indexTableColumn.maxWidth = 100.0f;
    [stylePropertiesTableView addTableColumn:indexTableColumn];
    
    CGFloat tableWidth = stylePropertiesTableView.bounds.size.width - 30.0f;

    CGFloat columnWidth = tableWidth / 2.0f;

    NSTableColumn * xTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"property"];
    xTableColumn.title = @"property";
    xTableColumn.width = columnWidth;
    xTableColumn.minWidth = 60.0f;
    xTableColumn.maxWidth = 100.0f;
    [stylePropertiesTableView addTableColumn:xTableColumn];

    NSTableColumn * yTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"value"];
    yTableColumn.title = @"value";
    yTableColumn.width = columnWidth;
    yTableColumn.minWidth = 60.0f;
    yTableColumn.maxWidth = 100.0f;
    [stylePropertiesTableView addTableColumn:yTableColumn];
    */

    NSXMLElement * animateMotionElement = self.pluginTargetXMLElement;

    NSXMLNode * styleAttributeNode = [animateMotionElement attributeForName:@"style"];
    if (styleAttributeNode != NULL)
    {
        NSString * styleAttributeString = styleAttributeNode.stringValue;
        
        if (styleAttributeString.length > 0)
        {
            NSCharacterSet * whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            styleAttributeString = [styleAttributeString stringByTrimmingCharactersInSet:whitespaceCharacterSet];

            while ([styleAttributeString rangeOfString:@"  "].location != NSNotFound)
            {
                styleAttributeString = [styleAttributeString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
            }
            
            NSArray * newStylePropertiesArray = [styleAttributeString componentsSeparatedByString:@";"];

            NSInteger newStylePropertiesArrayCount = newStylePropertiesArray.count;
            
            for (NSInteger i = 0; i < newStylePropertiesArrayCount; i++)
            {
                NSString * aPropertyString = newStylePropertiesArray[i];
                
                aPropertyString = [aPropertyString stringByTrimmingCharactersInSet:whitespaceCharacterSet];

                if ([aPropertyString length] > 0)
                {
                    NSArray * aPropertyArray = [aPropertyString componentsSeparatedByString:@":"];
                    
                    NSInteger aPropertyArrayCount = [aPropertyArray count];
                    
                    if (aPropertyArrayCount > 0)
                    {
                        NSString * propertyNameString = [aPropertyArray objectAtIndex:0];
                        NSString * propertyValueString = @"";
                        
                        if (aPropertyArrayCount == 2)
                        {
                            propertyValueString = [aPropertyArray objectAtIndex:1];
                        }
                        
                        NSMutableDictionary * propertyDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                propertyNameString, @"property",
                                propertyValueString, @"value",
                                NULL];

                        [self.stylePropertiesArray addObject:propertyDictionary];
                    }
                }
            }
        }
    }
    
    [stylePropertiesTableView reloadData];
    
    //stylePropertiesTableView.rowHeight = 14.0f;
}

//==================================================================================
//	numberOfRowsInTableView:
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return (self.stylePropertiesArray).count;
}

//==================================================================================
//	itemTextFieldUpdated:
//==================================================================================

- (IBAction)itemTextFieldUpdated:(id)sender
{
    //NSInteger rowIndex = [stylePropertiesTableView rowForView:sender];
    //NSInteger columnIndex = [stylePropertiesTableView columnForView:sender];

    NSInteger rowIndex = [stylePropertiesTableView selectedRow];
    NSInteger columnIndex = [stylePropertiesTableView selectedColumn];
    
    NSString * stringValue = [sender stringValue];
    
    stringValue = [stringValue copy];
    
    NSView * senderSuperview = NULL;
    if ([sender isKindOfClass:[NSView class]] == YES)
    {
        NSView * senderView = sender;
        senderSuperview = senderView.superview;
    }
    
    NSMutableDictionary * aStylePropertyDictionary = NULL;
    
    if (sender == propertyNameComboBox)
    {
        NSDictionary * propertiesDictionary = [self.cssPropertiesDictionary objectForKey:@"properties"];
        
        NSDictionary * propertyDictionary = [propertiesDictionary objectForKey:stringValue];
        
        NSArray * propertyValuesArray = [propertyDictionary objectForKey:@"values"];
        
        self.styleValuesComboArray = propertyValuesArray;
    }
    else if (sender == propertyValueComboBox)
    {
    }
    //else if ([senderSuperview isKindOfClass:[StylePropertiesTableRowView class]] == YES)
    else if ([sender isKindOfClass:[NSTextField class]] == YES)
    {
        // sender was a text cell inside the table view
        if (rowIndex < (self.stylePropertiesArray).count)
        {
            NSTextField * tableCellTextField = sender;
            NSString * tableCellString = tableCellTextField.stringValue;
        
            aStylePropertyDictionary = (self.stylePropertiesArray)[rowIndex];
            
            if (columnIndex == 1)
            {
                [aStylePropertyDictionary setValue:tableCellString forKey:@"property"];
            }
            else if (columnIndex == 2)
            {
                [aStylePropertyDictionary setValue:tableCellString forKey:@"value"];
            }

            NSString * propertyString = aStylePropertyDictionary[@"property"];
            if (propertyString != NULL)
            {
                NSString * valueString = aStylePropertyDictionary[@"value"];
                
                if (valueString == NULL)
                {
                    valueString = @"";
                }
                
                propertyNameComboBox.stringValue = propertyString;
                propertyValueComboBox.stringValue = valueString;
            }
        }
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
    
    //StylePropertiesTableRowView * rowView = [tableView makeViewWithIdentifier:kRowIdentifier owner:self];
    StylePropertiesTableRowView * rowView = [tableView makeViewWithIdentifier:kRowIdentifier owner:NULL];

    if (rowView == NULL)
    {
        // Size doesn't matter, the table will set it
        rowView = [[StylePropertiesTableRowView alloc] initWithFrame:NSZeroRect];

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
    //NSTableCellView * resultView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    NSTableCellView * resultView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:NULL];

    /*
    if (resultView == nil)
    {
        resultView = [[NSTextField alloc] initWithFrame:tableView.frame];
        resultView.identifier = tableColumn.identifier;
        resultView.font = [NSFont systemFontOfSize:10];
        resultView.bordered = NO;
        resultView.backgroundColor = [NSColor clearColor];
    }
    */

    NSString * resultString = @"";

    if (row < (self.stylePropertiesArray).count)
    {
        NSString * tableColumnIdentifier = tableColumn.identifier;
        
        if ([tableColumnIdentifier isEqualToString:@"#"] == YES)
        {
            resultString = [NSString stringWithFormat:@"%ld", (row + 1)];
            resultView.textField.editable = NO;
        }
        else
        {
            resultView.textField.editable = YES;
            resultView.textField.delegate = (id)self;
        
            NSMutableDictionary * aStylePropertyDictionary = (self.stylePropertiesArray)[row];

            if ([tableColumnIdentifier isEqualToString:@"property"] == YES)
            {
                resultString = aStylePropertyDictionary[@"property"];
            }
            else if ([tableColumnIdentifier isEqualToString:@"value"] == YES)
            {
                resultString = aStylePropertyDictionary[@"value"];
            }
        }
    }

    if (resultString == NULL)
    {
        resultString = @"";
    }

    resultView.textField.stringValue = resultString;
    
    return resultView;
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = aNotification.object;
	if (aTableView == stylePropertiesTableView)
	{
        [self refreshSelectedRow];
    }
}

//==================================================================================
//	refreshSelectedRow
//==================================================================================

- (void)refreshSelectedRow
{
    NSInteger rowIndex = stylePropertiesTableView.selectedRow;

    if (rowIndex >= 0)
    {
        NSDictionary * stylePropertyDictionary = [self.stylePropertiesArray objectAtIndex:rowIndex];
        
        NSString * propertyNameString = [stylePropertyDictionary objectForKey:@"property"];
        NSString * propertyValueString = [stylePropertyDictionary objectForKey:@"value"];
        
        if (propertyNameString == NULL)
        {
            propertyNameString = @"";
        }
        
        if (propertyValueString == NULL)
        {
            propertyValueString = @"";
        }
        
        propertyNameComboBox.stringValue = propertyNameString;
        propertyValueComboBox.stringValue = propertyValueString;
        
        NSDictionary * propertiesDictionary = [self.cssPropertiesDictionary objectForKey:@"properties"];
        
        NSDictionary * propertyDictionary = [propertiesDictionary objectForKey:propertyNameString];
        
        NSArray * propertyValuesArray = [propertyDictionary objectForKey:@"values"];
        
        self.styleValuesComboArray = propertyValuesArray;
    }
    else
    {
        propertyNameComboBox.stringValue = @"";
        propertyValueComboBox.stringValue = @"";
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

//==================================================================================
//	updateEditForXMLElement:domElement:info:updatePathLength:
//==================================================================================

- (void)updateEditForXMLElement:(NSXMLElement *)xmlElement domElement:(DOMElement *)domElement info:(id)infoData updatePathLength:(BOOL)updatePathLength
{
    // subclasses can override as needed
    
    NSArray * aStylePropertiesArray = infoData;
    #pragma unused(aStylePropertiesArray)
    
    [self loadStylePropertiesData];
    
    [stylePropertiesTableView reloadData];
}

#pragma clang diagnostic pop

//==================================================================================
//	cancelButtonAction
//==================================================================================

- (IBAction)cancelButtonAction:(id)sender
{
}

//==================================================================================
//	applyChangesButtonAction:
//==================================================================================

- (IBAction)applyChangesButtonAction:(id)sender
{
    [self.macSVGPluginCallbacks pushUndoRedoDocumentChanges];
    
    NSInteger selectedRow = stylePropertiesTableView.selectedRow;
    NSIndexSet * selectedRowIndexSet = stylePropertiesTableView.selectedRowIndexes;
    
    NSMutableDictionary * newStylePropertyDictionary = NULL;
    
    if (selectedRow >= 0)
    {
        newStylePropertyDictionary = (self.stylePropertiesArray)[selectedRow];
        
        NSString * newPropertyName = propertyNameComboBox.stringValue;
        NSString * newPropertyValue = propertyValueComboBox.stringValue;
        
        [newStylePropertyDictionary setObject:newPropertyName forKey:@"property"];
        [newStylePropertyDictionary setObject:newPropertyValue forKey:@"value"];

        NSMutableString * styleString = [NSMutableString string];
        NSInteger indexOfObject = 0;
        for (NSMutableDictionary * stylePropertyDictionary in self.stylePropertiesArray)
        {
            NSString * aStylePropertyString = stylePropertyDictionary[@"property"];
            NSString * aStyleValueString = stylePropertyDictionary[@"value"];

            [styleString appendString:aStylePropertyString];
            
            if ([aStyleValueString length] > 0)
            {
                [styleString appendString:@":"];
                [styleString appendString:aStyleValueString];
            }
            
            [styleString appendString:@"; "];
            
            indexOfObject++;
        }

        [self setAttributeName:@"style" value:styleString element:self.pluginTargetXMLElement];
        
        [stylePropertiesTableView reloadData];
        
        [stylePropertiesTableView selectRowIndexes:selectedRowIndexSet byExtendingSelection:NO];
        
        [self updateDocumentViews];
    }
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
//	addStylePropertyRow:
//==================================================================================

- (IBAction)addStylePropertyRow:(id)sender
{
    NSInteger selectedRow = stylePropertiesTableView.selectedRow;
    
    NSMutableDictionary * newStylePropertyDictionary = NULL;
    
    NSInteger insertIndex = selectedRow + 1;
    
    newStylePropertyDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            @"new-css-style", @"property",
            @"new-value", @"value",
            NULL];
    
    [self.stylePropertiesArray insertObject:newStylePropertyDictionary atIndex:insertIndex];
    
    [stylePropertiesTableView reloadData];
    
    NSIndexSet * rowIndexSet = [NSIndexSet indexSetWithIndex:insertIndex];
    [stylePropertiesTableView selectRowIndexes:rowIndexSet byExtendingSelection:NO];
}

//==================================================================================
//	deleteStylePropertyRow:
//==================================================================================

- (IBAction)deleteStylePropertyRow:(id)sender
{
    NSInteger selectedRow = stylePropertiesTableView.selectedRow;

    if (selectedRow >= 0)
    {
        [self.stylePropertiesArray removeObjectAtIndex:selectedRow];
        
        [stylePropertiesTableView reloadData];
    }
}

//==================================================================================
//	numberOfItemsInComboBox
//==================================================================================

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    NSInteger result = 0;
    
    if (aComboBox == propertyNameComboBox)
    {
        result = self.styleNamesComboArray.count;
    }
    else if (aComboBox == propertyValueComboBox)
    {
        result = self.styleValuesComboArray.count;
    }
    
    return result;
}

//==================================================================================
//	objectValueForItemAtIndex
//==================================================================================

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    id result = @"";

    if (aComboBox == propertyNameComboBox)
    {
        if (index < self.styleNamesComboArray.count)
        {
            result = [self.styleNamesComboArray objectAtIndex:index];
        }
    }
    else if (aComboBox == propertyValueComboBox)
    {
        if (index < self.styleValuesComboArray.count)
        {
            result = [self.styleValuesComboArray objectAtIndex:index];
        }
    }
    
    return result;
}




@end
