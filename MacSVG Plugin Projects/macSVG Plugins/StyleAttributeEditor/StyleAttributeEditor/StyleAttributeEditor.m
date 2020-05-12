//
//  StyleAttributeEditor.m
//  StyleAttributeEditor
//
//  Created by Douglas Ward on 1/2/17.
//  Copyright © 2017 ArkPhone LLC. All rights reserved.
//

#import "StyleAttributeEditor.h"
#import <MacSVGPlugin/MacSVGPluginCallbacks.h>
#import "MacSVGDocumentWindowController.h"
#import "SVGWebKitController.h"

#define StyleTableViewDataType @"NSMutableDictionary"

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

    [stylePropertiesTableView registerForDraggedTypes:@[StyleTableViewDataType]];
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
        
        self.webColorsArray = [NSMutableArray array];
        [self buildWebColorsArray];
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
        
        NSString * propertyNameString = propertyNameComboBox.stringValue;
        if ([self isColorPropertyName:propertyNameString] == YES)
        {
            propertyValuesArray = self.webColorsArray;
        }
        
        self.styleValuesComboArray = propertyValuesArray;
    }
    else if (sender == propertyValueComboBox)
    {
    }
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
    
    if (sender == propertyNameComboBox)
    {
        NSInteger rowIndex = [stylePropertiesTableView selectedRow];
        if (rowIndex >= 0)
        {
            NSString * propertyString = propertyNameComboBox.stringValue;
            NSMutableDictionary * aStylePropertyDictionary = (self.stylePropertiesArray)[rowIndex];
            [aStylePropertyDictionary setObject:propertyString forKey:@"property"];

            [stylePropertiesTableView reloadData];
            
            NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:rowIndex];
            [stylePropertiesTableView selectRowIndexes:indexSet byExtendingSelection:NO];
        }
    }
    else if (sender == propertyValueComboBox)
    {
        NSInteger rowIndex = [stylePropertiesTableView selectedRow];
        if (rowIndex >= 0)
        {
            NSString * valueString = propertyValueComboBox.stringValue;
            NSMutableDictionary * aStylePropertyDictionary = (self.stylePropertiesArray)[rowIndex];
            [aStylePropertyDictionary setObject:valueString forKey:@"value"];

            [stylePropertiesTableView reloadData];
            
            NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:rowIndex];
            [stylePropertiesTableView selectRowIndexes:indexSet byExtendingSelection:NO];
        }
    }
    else
    {
        if ([sender isKindOfClass:[NSTextField class]] == YES)
        {
            NSTextField * aTextField = sender;
            
            NSView * parentView = aTextField.superview;
            
            if ([parentView isKindOfClass:[NSTableCellView class]] == YES)
            {
                NSTableCellView * aTableCellView = (NSTableCellView *)parentView;
                
                NSInteger columnIndex = [stylePropertiesTableView columnForView:aTableCellView];
                
                if (columnIndex >= 0)
                {
                    NSArray * tableColumnsArray = [stylePropertiesTableView tableColumns];
                    NSTableColumn * aTableColumn = [tableColumnsArray objectAtIndex:columnIndex];
                    NSString * tableColumnIdentifier = aTableColumn.identifier;
                    
                    NSInteger rowIndex = [stylePropertiesTableView rowForView:aTableCellView];
                    
                    if (rowIndex >= 0)
                    {
                        if ([tableColumnIdentifier isEqualToString:@"property"])
                        {
                            NSMutableDictionary * aStylePropertyDictionary = (self.stylePropertiesArray)[rowIndex];

                            NSString * propertyString = aTextField.stringValue;

                            [aStylePropertyDictionary setObject:propertyString forKey:@"property"];

                            propertyNameComboBox.stringValue = propertyString;
                        }
                        else if ([tableColumnIdentifier isEqualToString:@"value"])
                        {
                            NSMutableDictionary * aStylePropertyDictionary = (self.stylePropertiesArray)[rowIndex];

                            NSString * valueString = aTextField.stringValue;
                            
                            [aStylePropertyDictionary setObject:valueString forKey:@"value"];
                            
                            propertyValueComboBox.stringValue = valueString;
                        }
                    }
                }
            }
        }
    }
    
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
//    tableView:writeRowsWithIndexes:toPasteboard
//==================================================================================

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    
    // archivedDataWithRootObject:requiringSecureCoding:error:
    NSError * archivedDataError = NULL;
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes requiringSecureCoding:NO error:&archivedDataError];

    [pboard declareTypes:@[StyleTableViewDataType] owner:self];

    [pboard setData:data forType:StyleTableViewDataType];
    
    return YES;
}

//==================================================================================
//    tableView:acceptDrop:row:dropOperation
//==================================================================================

- (BOOL)tableView:(NSTableView*)tableView
        acceptDrop:(id <NSDraggingInfo>)info
        row:(NSInteger)row
        dropOperation:(NSTableViewDropOperation)operation
{
    //this is the code that handles dnd ordering - my table doesn't need to accept drops from outside! Hooray!
    NSPasteboard * pboard = [info draggingPasteboard];
    NSData * rowData = [pboard dataForType:StyleTableViewDataType];

    //NSIndexSet * rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    
    // unarchivedObjectOfClass:fromData:error:
    NSError * archiveDataError = NULL;
    NSIndexSet * rowIndexes = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSIndexSet class] fromData:rowData error:&archiveDataError];

    NSInteger from = rowIndexes.firstIndex;

    NSMutableDictionary * traveller = (self.stylePropertiesArray)[from];
    
    NSInteger length = (self.stylePropertiesArray).count;
    //NSMutableArray * replacement = [NSMutableArray new];

    NSInteger i;
    for (i = 0; i <= length; i++)
    {
        if (i == row)
        {
            if (from > row)
            {
                [self.stylePropertiesArray insertObject:traveller atIndex:row];
                [self.stylePropertiesArray removeObjectAtIndex:(from + 1)];
            }
            else
            {
                [self.stylePropertiesArray insertObject:traveller atIndex:row];
                [self.stylePropertiesArray removeObjectAtIndex:from];
            }
        }
    }
    
    [stylePropertiesTableView reloadData];
        
    return YES;
}


//==================================================================================
//    tableView:validateDrop:proposedRow:proposedDropOperation:
//==================================================================================

- (NSDragOperation)tableView:(NSTableView*)tableView
        validateDrop:(id <NSDraggingInfo>)info
        proposedRow:(NSInteger)row
        proposedDropOperation:(NSTableViewDropOperation)operation
{
    return NSDragOperationEvery;
}


//==================================================================================
//	tableView:viewForTableColumn:row:
//==================================================================================

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    //NSTableCellView * resultView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    NSTableCellView * resultView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:NULL];

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
        
        if ([self isColorPropertyName:propertyNameString] == YES)
        {
            propertyValuesArray = self.webColorsArray;
        }
        
        self.styleValuesComboArray = propertyValuesArray;
    }
    else
    {
        propertyNameComboBox.stringValue = @"";
        propertyValueComboBox.stringValue = @"";
    }
}

//==================================================================================
//	isColorPropertyName:
//==================================================================================

- (BOOL)isColorPropertyName:(NSString *)propertyName
{
    BOOL result = NO;
    
    if ([propertyName isEqualToString:@"stroke"] == YES)
    {
        result = YES;
    }
    else if ([propertyName isEqualToString:@"fill"] == YES)
    {
        result = YES;
    }
    else if ([propertyName isEqualToString:@"color"] == YES)
    {
        result = YES;
    }
    else if ([propertyName hasSuffix:@"-color"] == YES)
    {
        result = YES;
    }
    
    return result;
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
    [self configureStylePropertiesTableView];
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
        if (selectedRow < self.stylePropertiesArray.count)
        {
            newStylePropertyDictionary = (self.stylePropertiesArray)[selectedRow];
            
            NSString * newPropertyName = propertyNameComboBox.stringValue;
            NSString * newPropertyValue = propertyValueComboBox.stringValue;
            
            [newStylePropertyDictionary setObject:newPropertyName forKey:@"property"];
            [newStylePropertyDictionary setObject:newPropertyValue forKey:@"value"];
        }
    }
    
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

    NSString * newPropertyName = propertyNameComboBox.stringValue;
    NSString * newPropertyValue = propertyValueComboBox.stringValue;
    
    if (newPropertyName.length == 0)
    {
        newPropertyName = @"new-css-style";
    }

    if (newPropertyValue.length == 0)
    {
        newPropertyValue = @"new-value";
    }

    newStylePropertyDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            newPropertyName, @"property",
            newPropertyValue, @"value",
            NULL];
    
    [self.stylePropertiesArray insertObject:newStylePropertyDictionary atIndex:insertIndex];
    
    [stylePropertiesTableView reloadData];
    
    //[self applyChangesButtonAction:sender];
    
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

        //[self applyChangesButtonAction:sender];
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

//==================================================================================
//    addWebColorName:hex:rgb:
//==================================================================================

- (void)addWebColorName:(NSString *)colorName hex:(NSString *)hex rgb:(NSString *)rgb
{
    //NSDictionary * colorDictionary = @{@"name": colorName, @"hex": hex, @"rgb": rgb};
    //[self.webColorsArray addObject:colorDictionary];
    
    [self.webColorsArray addObject:colorName];
}

//==================================================================================
//    buildWebColorsArray
//==================================================================================

- (void)buildWebColorsArray
{
    self.webColorsArray = [[NSMutableArray alloc] init];

    [self addWebColorName:@"inherited" hex:@"#ffffff" rgb:@"255,255,255"];
    [self addWebColorName:@"aliceblue" hex:@"#f0f8ff" rgb:@"240,248,255"];
    [self addWebColorName:@"antiquewhite" hex:@"#faebd7" rgb:@"250,235,215"];
    [self addWebColorName:@"aqua" hex:@"#00ffff" rgb:@"0,255,255"];
    [self addWebColorName:@"aquamarine" hex:@"#7fffd4" rgb:@"127,255,212"];
    [self addWebColorName:@"azure" hex:@"#f0ffff" rgb:@"240,255,255"];
    [self addWebColorName:@"beige" hex:@"#f5f5dc" rgb:@"245,245,220"];
    [self addWebColorName:@"bisque" hex:@"#ffe4c4" rgb:@"255,228,196"];
    [self addWebColorName:@"black" hex:@"#000000" rgb:@"0,0,0"];
    [self addWebColorName:@"blanchedalmond" hex:@"#ffebcd" rgb:@"255,235,205"];
    [self addWebColorName:@"blue" hex:@"#0000ff" rgb:@"0,0,255"];
    [self addWebColorName:@"blueviolet" hex:@"#8a2be2" rgb:@"138,43,226"];
    [self addWebColorName:@"brown" hex:@"#a52a2a" rgb:@"165,42,42"];
    [self addWebColorName:@"burlywood" hex:@"#deb887" rgb:@"222,184,135"];
    [self addWebColorName:@"cadetblue" hex:@"#5f9ea0" rgb:@"95,158,160"];
    [self addWebColorName:@"chartreuse" hex:@"#7fff00" rgb:@"127,255,0"];
    [self addWebColorName:@"chocolate" hex:@"#d2691e" rgb:@"210,105,30"];
    [self addWebColorName:@"coral" hex:@"#ff7f50" rgb:@"255,127,80"];
    [self addWebColorName:@"cornflowerblue" hex:@"#6495ed" rgb:@"100,149,237"];
    [self addWebColorName:@"cornsilk" hex:@"#fff8dc" rgb:@"255,248,220"];
    [self addWebColorName:@"crimson" hex:@"#dc143c" rgb:@"220,20,60"];
    [self addWebColorName:@"cyan" hex:@"#00ffff" rgb:@"0,255,255"];
    [self addWebColorName:@"darkblue" hex:@"#00008b" rgb:@"0,0,139"];
    [self addWebColorName:@"darkcyan" hex:@"#008b8b" rgb:@"0,139,139"];
    [self addWebColorName:@"darkgoldenrod" hex:@"#b8860b" rgb:@"184,134,11"];
    [self addWebColorName:@"darkgray" hex:@"#a9a9a9" rgb:@"169,169,169"];
    [self addWebColorName:@"darkgreen" hex:@"#006400" rgb:@"0,100,0"];
    [self addWebColorName:@"darkgrey" hex:@"#a9a9a9" rgb:@"169,169,169"];
    [self addWebColorName:@"darkkhaki" hex:@"#bdb76b" rgb:@"189,183,107"];
    [self addWebColorName:@"darkmagenta" hex:@"#8b008b" rgb:@"139,0,139"];
    [self addWebColorName:@"darkolivegreen" hex:@"#556b2f" rgb:@"85,107,47"];
    [self addWebColorName:@"darkorange" hex:@"#ff8c00" rgb:@"255,140,0"];
    [self addWebColorName:@"darkorchid" hex:@"#9932cc" rgb:@"153,50,204"];
    [self addWebColorName:@"darkred" hex:@"#8b0000" rgb:@"139,0,0"];
    [self addWebColorName:@"darksalmon" hex:@"#e9967a" rgb:@"233,150,122"];
    [self addWebColorName:@"darkseagreen" hex:@"#8fbc8f" rgb:@"143,188,143"];
    [self addWebColorName:@"darkslateblue" hex:@"#483d8b" rgb:@"72,61,139"];
    [self addWebColorName:@"darkslategray" hex:@"#2f4f4f" rgb:@"47,79,79"];
    [self addWebColorName:@"darkslategrey" hex:@"#2f4f4f" rgb:@"47,79,79"];
    [self addWebColorName:@"darkturquoise" hex:@"#00ced1" rgb:@"0,206,209"];
    [self addWebColorName:@"darkviolet" hex:@"#9400d3" rgb:@"148,0,211"];
    [self addWebColorName:@"deeppink" hex:@"#ff1493" rgb:@"255,20,147"];
    [self addWebColorName:@"deepskyblue" hex:@"#00bfff" rgb:@"0,191,255"];
    [self addWebColorName:@"dimgray" hex:@"#696969" rgb:@"105,105,105"];
    [self addWebColorName:@"dimgrey" hex:@"#696969" rgb:@"105,105,105"];
    [self addWebColorName:@"dodgerblue" hex:@"#1e90ff" rgb:@"30,144,255"];
    [self addWebColorName:@"firebrick" hex:@"#b22222" rgb:@"178,34,34"];
    [self addWebColorName:@"floralwhite" hex:@"#fffaf0" rgb:@"255,250,240"];
    [self addWebColorName:@"forestgreen" hex:@"#228b22" rgb:@"34,139,34"];
    [self addWebColorName:@"fuchsia" hex:@"#ff00ff" rgb:@"255,0,255"];
    [self addWebColorName:@"gainsboro" hex:@"#dcdcdc" rgb:@"220,220,220"];
    [self addWebColorName:@"ghostwhite" hex:@"#f8f8ff" rgb:@"248,248,255"];
    [self addWebColorName:@"gold" hex:@"#ffd700" rgb:@"255,215,0"];
    [self addWebColorName:@"goldenrod" hex:@"#daa520" rgb:@"218,165,32"];
    [self addWebColorName:@"gray" hex:@"#808080" rgb:@"128,128,128"];
    [self addWebColorName:@"green" hex:@"#008000" rgb:@"0,128,0"];
    [self addWebColorName:@"greenyellow" hex:@"#adff2f" rgb:@"173,255,47"];
    [self addWebColorName:@"grey" hex:@"#808080" rgb:@"128,128,128"];
    [self addWebColorName:@"honeydew" hex:@"#f0fff0" rgb:@"240,255,240"];
    [self addWebColorName:@"hotpink" hex:@"#ff69b4" rgb:@"255,105,180"];
    [self addWebColorName:@"indianred" hex:@"#cd5c5c" rgb:@"205,92,92"];
    [self addWebColorName:@"indigo" hex:@"#4b0082" rgb:@"75,0,130"];
    [self addWebColorName:@"ivory" hex:@"#fffff0" rgb:@"255,255,240"];
    [self addWebColorName:@"khaki" hex:@"#f0e68c" rgb:@"240,230,140"];
    [self addWebColorName:@"lavender" hex:@"#e6e6fa" rgb:@"230,230,250"];
    [self addWebColorName:@"lavenderblush" hex:@"#fff0f5" rgb:@"255,240,245"];
    [self addWebColorName:@"lawngreen" hex:@"#7cfc00" rgb:@"124,252,0"];
    [self addWebColorName:@"lemonchiffon" hex:@"#fffacd" rgb:@"255,250,205"];
    [self addWebColorName:@"lightblue" hex:@"#add8e6" rgb:@"173,216,230"];
    [self addWebColorName:@"lightcoral" hex:@"#f08080" rgb:@"240,128,128"];
    [self addWebColorName:@"lightcyan" hex:@"#e0ffff" rgb:@"224,255,255"];
    [self addWebColorName:@"lightgoldenrodyellow" hex:@"#fafad2" rgb:@"250,250,210"];
    [self addWebColorName:@"lightgray" hex:@"#d3d3d3" rgb:@"211,211,211"];
    [self addWebColorName:@"lightgreen" hex:@"#90ee90" rgb:@"144,238,144"];
    [self addWebColorName:@"lightgrey" hex:@"#d3d3d3" rgb:@"211,211,211"];
    [self addWebColorName:@"lightpink" hex:@"#ffb6c1" rgb:@"255,182,193"];
    [self addWebColorName:@"lightsalmon" hex:@"#ffa07a" rgb:@"255,160,122"];
    [self addWebColorName:@"lightseagreen" hex:@"#20b2aa" rgb:@"32,178,170"];
    [self addWebColorName:@"lightskyblue" hex:@"#87cefa" rgb:@"135,206,250"];
    [self addWebColorName:@"lightslategray" hex:@"#778899" rgb:@"119,136,153"];
    [self addWebColorName:@"lightslategrey" hex:@"#778899" rgb:@"119,136,153"];
    [self addWebColorName:@"lightsteelblue" hex:@"#b0c4de" rgb:@"176,196,222"];
    [self addWebColorName:@"lightyellow" hex:@"#ffffe0" rgb:@"255,255,224"];
    [self addWebColorName:@"lime" hex:@"#00ff00" rgb:@"0,255,0"];
    [self addWebColorName:@"limegreen" hex:@"#32cd32" rgb:@"50,205,50"];
    [self addWebColorName:@"linen" hex:@"#faf0e6" rgb:@"250,240,230"];
    [self addWebColorName:@"magenta" hex:@"#ff00ff" rgb:@"255,0,255"];
    [self addWebColorName:@"maroon" hex:@"#800000" rgb:@"128,0,0"];
    [self addWebColorName:@"mediumaquamarine" hex:@"#66cdaa" rgb:@"102,205,170"];
    [self addWebColorName:@"mediumblue" hex:@"#0000cd" rgb:@"0,0,205"];
    [self addWebColorName:@"mediumorchid" hex:@"#ba55d3" rgb:@"186,85,211"];
    [self addWebColorName:@"mediumpurple" hex:@"#9370db" rgb:@"147,112,219"];
    [self addWebColorName:@"mediumseagreen" hex:@"#3cb371" rgb:@"60,179,113"];
    [self addWebColorName:@"mediumslateblue" hex:@"#7b68ee" rgb:@"123,104,238"];
    [self addWebColorName:@"mediumspringgreen" hex:@"#00fa9a" rgb:@"0,250,154"];
    [self addWebColorName:@"mediumturquoise" hex:@"#48d1cc" rgb:@"72,209,204"];
    [self addWebColorName:@"mediumvioletred" hex:@"#c71585" rgb:@"199,21,133"];
    [self addWebColorName:@"midnightblue" hex:@"#191970" rgb:@"25,25,112"];
    [self addWebColorName:@"mintcream" hex:@"#f5fffa" rgb:@"245,255,250"];
    [self addWebColorName:@"mistyrose" hex:@"#ffe4e1" rgb:@"255,228,225"];
    [self addWebColorName:@"moccasin" hex:@"#ffe4b5" rgb:@"255,228,181"];
    [self addWebColorName:@"navajowhite" hex:@"#ffdead" rgb:@"255,222,173"];
    [self addWebColorName:@"navy" hex:@"#000080" rgb:@"0,0,128"];
    [self addWebColorName:@"oldlace" hex:@"#fdf5e6" rgb:@"253,245,230"];
    [self addWebColorName:@"olive" hex:@"#808000" rgb:@"128,128,0"];
    [self addWebColorName:@"olivedrab" hex:@"#6b8e23" rgb:@"107,142,35"];
    [self addWebColorName:@"orange" hex:@"#ffa500" rgb:@"255,165,0"];
    [self addWebColorName:@"orangered" hex:@"#ff4500" rgb:@"255,69,0"];
    [self addWebColorName:@"orchid" hex:@"#da70d6" rgb:@"218,112,214"];
    [self addWebColorName:@"palegoldenrod" hex:@"#eee8aa" rgb:@"238,232,170"];
    [self addWebColorName:@"palegreen" hex:@"#98fb98" rgb:@"152,251,152"];
    [self addWebColorName:@"paleturquoise" hex:@"#afeeee" rgb:@"175,238,238"];
    [self addWebColorName:@"palevioletred" hex:@"#db7093" rgb:@"219,112,147"];
    [self addWebColorName:@"papayawhip" hex:@"#ffefd5" rgb:@"255,239,213"];
    [self addWebColorName:@"peachpuff" hex:@"#ffdab9" rgb:@"255,218,185"];
    [self addWebColorName:@"peru" hex:@"#cd853f" rgb:@"205,133,63"];
    [self addWebColorName:@"pink" hex:@"#ffc0cb" rgb:@"255,192,203"];
    [self addWebColorName:@"plum" hex:@"#dda0dd" rgb:@"221,160,221"];
    [self addWebColorName:@"powderblue" hex:@"#b0e0e6" rgb:@"176,224,230"];
    [self addWebColorName:@"purple" hex:@"#800080" rgb:@"128,0,128"];
    [self addWebColorName:@"red" hex:@"#ff0000" rgb:@"255,0,0"];
    [self addWebColorName:@"rosybrown" hex:@"#bc8f8f" rgb:@"188,143,143"];
    [self addWebColorName:@"royalblue" hex:@"#4169e1" rgb:@"65,105,225"];
    [self addWebColorName:@"saddlebrown" hex:@"#8b4513" rgb:@"139,69,19"];
    [self addWebColorName:@"salmon" hex:@"#fa8072" rgb:@"250,128,114"];
    [self addWebColorName:@"sandybrown" hex:@"#f4a460" rgb:@"244,164,96"];
    [self addWebColorName:@"seagreen" hex:@"#2e8b57" rgb:@"46,139,87"];
    [self addWebColorName:@"seashell" hex:@"#fff5ee" rgb:@"255,245,238"];
    [self addWebColorName:@"sienna" hex:@"#a0522d" rgb:@"160,82,45"];
    [self addWebColorName:@"silver" hex:@"#c0c0c0" rgb:@"192,192,192"];
    [self addWebColorName:@"skyblue" hex:@"#87ceeb" rgb:@"135,206,235"];
    [self addWebColorName:@"slateblue" hex:@"#6a5acd" rgb:@"106,90,205"];
    [self addWebColorName:@"slategray" hex:@"#708090" rgb:@"112,128,144"];
    [self addWebColorName:@"slategrey" hex:@"#708090" rgb:@"112,128,144"];
    [self addWebColorName:@"snow" hex:@"#fffafa" rgb:@"255,250,250"];
    [self addWebColorName:@"springgreen" hex:@"#00ff7f" rgb:@"0,255,127"];
    [self addWebColorName:@"steelblue" hex:@"#4682b4" rgb:@"70,130,180"];
    [self addWebColorName:@"tan" hex:@"#d2b48c" rgb:@"210,180,140"];
    [self addWebColorName:@"teal" hex:@"#008080" rgb:@"0,128,128"];
    [self addWebColorName:@"thistle" hex:@"#d8bfd8" rgb:@"216,191,216"];
    [self addWebColorName:@"tomato" hex:@"#ff6347" rgb:@"255,99,71"];
    [self addWebColorName:@"turquoise" hex:@"#40e0d0" rgb:@"64,224,208"];
    [self addWebColorName:@"violet" hex:@"#ee82ee" rgb:@"238,130,238"];
    [self addWebColorName:@"wheat" hex:@"#f5deb3" rgb:@"245,222,179"];
    [self addWebColorName:@"white" hex:@"#ffffff" rgb:@"255,255,255"];
    [self addWebColorName:@"whitesmoke" hex:@"#f5f5f5" rgb:@"245,245,245"];
    [self addWebColorName:@"yellow" hex:@"#ffff00" rgb:@"255,255,0"];
    [self addWebColorName:@"yellowgreen" hex:@"#9acd32" rgb:@"154,205,50"];
}



@end
