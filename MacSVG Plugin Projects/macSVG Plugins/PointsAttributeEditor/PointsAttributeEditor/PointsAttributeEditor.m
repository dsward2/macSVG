//
//  PointsAttributeEditor.m
//  PointsAttributeEditor
//
//  Created by Douglas Ward on 9/10/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "PointsAttributeEditor.h"
#import "PointsTableRowView.h"
#import "MacSVGPlugin/MacSVGPluginCallbacks.h"
#import "MacSVGDocumentWindowController.h"
#import "SVGXMLDOMSelectionManager.h"
#import "DOMSelectionRectsAndHandlesManager.h"
#import "SVGWebKitController.h"
#import "SVGPolylineEditor.h"
#import "DOMMouseEventsController.h"

@implementation PointsAttributeEditor

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

- (id)init
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
    return @"Points Attribute Editor";
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element tag name
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    NSString * result = NULL;

    if ([elementName isEqualToString:@"polyline"] == YES)
    {
        result = [self pluginName];
    }
    else if ([elementName isEqualToString:@"polygon"] == YES)
    {
        result = [self pluginName];
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

    if ([elementName isEqualToString:@"polyline"] == YES)
    {
        if ([attributeName isEqualToString:@"points"] == YES)
        {
            result = [self pluginName];
        }
    }
    else if ([elementName isEqualToString:@"polygon"] == YES)
    {
        if ([attributeName isEqualToString:@"points"] == YES)
        {
            result = [self pluginName];
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

    self.pointsArray = [NSMutableArray array];

    [self loadPointsData];
    
    [pointsTableView reloadData];

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

    self.pointsArray = [NSMutableArray array];

    [self loadPointsData];
    
    [pointsTableView reloadData];
    
    return result;
}

//==================================================================================
//	loadPointsData
//==================================================================================

- (void)loadPointsData
{
    NSXMLNode * pointsAttributeNode = [self.pluginTargetXMLElement attributeForName:@"points"];
    if (pointsAttributeNode != NULL)
    {
        //NSString * valuesAttributeValue = [valuesAttributeNode stringValue];
        //[valuesTextView setString:valuesAttributeValue];
        
        [self configurePointsTableView];
    }
    else
    {
        [self.pointsArray removeAllObjects];
    }
}

//==================================================================================
//	configurePointsTableView
//==================================================================================

- (void)configurePointsTableView
{
    self.pointsArray = [NSMutableArray array];

    [pointsTableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];

    while([[pointsTableView tableColumns] count] > 0)
    {
        [pointsTableView removeTableColumn:[[pointsTableView tableColumns] lastObject]];
    }
    
    [pointsTableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    
    NSTableColumn * indexTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"#"];
    indexTableColumn.title = @"#";
    indexTableColumn.width = 30.0f;
    indexTableColumn.minWidth = 30.0f;
    indexTableColumn.maxWidth = 100.0f;
    [pointsTableView addTableColumn:indexTableColumn];
    
    CGFloat tableWidth = pointsTableView.bounds.size.width - 30.0f;

    CGFloat columnWidth = tableWidth / 2.0f;

    NSTableColumn * xTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"x"];
    xTableColumn.title = @"x";
    xTableColumn.width = columnWidth;
    xTableColumn.minWidth = 60.0f;
    xTableColumn.maxWidth = 100.0f;
    [pointsTableView addTableColumn:xTableColumn];

    NSTableColumn * yTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"y"];
    yTableColumn.title = @"y";
    yTableColumn.width = columnWidth;
    yTableColumn.minWidth = 60.0f;
    yTableColumn.maxWidth = 100.0f;
    [pointsTableView addTableColumn:yTableColumn];

    NSXMLElement * animateMotionElement = self.pluginTargetXMLElement;

    NSXMLNode * pointsAttributeNode = [animateMotionElement attributeForName:@"points"];
    if (pointsAttributeNode != NULL)
    {
        NSString * pointsAttributeString = [pointsAttributeNode stringValue];
        
        if ([pointsAttributeString length] > 0)
        {
            NSCharacterSet * whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            pointsAttributeString = [pointsAttributeString stringByTrimmingCharactersInSet:whitespaceCharacterSet];

            while ([pointsAttributeString rangeOfString:@"  "].location != NSNotFound)
            {
                pointsAttributeString = [pointsAttributeString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
            }
            
            NSCharacterSet * pointsDelimitersCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@", ;\n\r"];
            NSArray * pointsValuesArray = [pointsAttributeString componentsSeparatedByCharactersInSet:pointsDelimitersCharacterSet];

            NSInteger pointsValuesArrayCount = [pointsValuesArray count];
            
            for (NSInteger i = 0; i < pointsValuesArrayCount; i+=2)
            {
                NSString * xString = [pointsValuesArray objectAtIndex:i];
                NSString * yString = [pointsValuesArray objectAtIndex:i + 1];
                
                NSMutableDictionary * pointDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        xString, @"x",
                        yString, @"y",
                        NULL];

                [self.pointsArray addObject:pointDictionary];
            }
        }
    }
    
    [pointsTableView reloadData];
    
    pointsTableView.rowHeight = 14.0f;
}

//==================================================================================
//	numberOfRowsInTableView:
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [self.pointsArray count];
}

//==================================================================================
//	itemTextFieldUpdated:
//==================================================================================

- (IBAction)itemTextFieldUpdated:(id)sender
{
    NSInteger rowIndex = [pointsTableView rowForView:sender];
    NSInteger columnIndex = [pointsTableView columnForView:sender];
    
    NSString * stringValue = [sender stringValue];
    
    stringValue = [stringValue copy];
    
    if (rowIndex <= ([self.pointsArray count] - 1))
    {
        NSMutableDictionary * pointDictionary = [self.pointsArray objectAtIndex:rowIndex];
        
        if (columnIndex == 1)   // x column
        {
            [pointDictionary setObject:stringValue forKey:@"x"];
        }
        else if (columnIndex == 2)  // y column
        {
            [pointDictionary setObject:stringValue forKey:@"y"];
        }
        
        NSTextField * textField = sender;
        textField.backgroundColor = [NSColor clearColor];
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
    
    PointsTableRowView * rowView = [tableView makeViewWithIdentifier:kRowIdentifier owner:self];
    
    if (rowView == NULL)
    {
        // Size doesn't matter, the table will set it
        rowView = [[PointsTableRowView alloc] initWithFrame:NSZeroRect];

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
    NSTextField * resultView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];

    if (resultView == nil)
    {
        resultView = [[NSTextField alloc] initWithFrame:[tableView frame]];
        resultView.identifier = [tableColumn identifier];
        resultView.font = [NSFont systemFontOfSize:10];
        resultView.bordered = NO;
        [resultView setBackgroundColor:[NSColor clearColor]];
    }

    NSString * resultString = @"";

    if (row < [self.pointsArray count])
    {
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
        
            NSMutableDictionary * pointDictionary = [self.pointsArray objectAtIndex:row];

            if ([tableColumnIdentifier isEqualToString:@"x"] == YES)
            {
                resultString = [pointDictionary objectForKey:@"x"];
            }
            else if ([tableColumnIdentifier isEqualToString:@"y"] == YES)
            {
                resultString = [pointDictionary objectForKey:@"y"];
            }
        }
    }

    resultView.stringValue = resultString;
    
    return resultView;
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = [aNotification object];
	if (aTableView == pointsTableView)
	{
        [self refreshSelectedRow];
    }
}

//==================================================================================
//	refreshSelectedRow
//==================================================================================

- (void)refreshSelectedRow
{
    NSInteger rowIndex = [pointsTableView selectedRow];

    MacSVGDocumentWindowController * macSVGDocumentWindowController =
            [self.macSVGDocument macSVGDocumentWindowController];

    DOMSelectionRectsAndHandlesManager * domSelectionRectsAndHandlesManager =
            macSVGDocumentWindowController.svgXMLDOMSelectionManager.domSelectionRectsAndHandlesManager;
    
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    SVGPolylineEditor * svgPolylineEditor = [domMouseEventsController svgPolylineEditor];
    
    if (rowIndex >= 0)
    {
        if (highlightSelectedPointCheckbox.state == YES)
        {
            NSMutableDictionary * pointDictionary = [self.pointsArray objectAtIndex:rowIndex];
                
            svgPolylineEditor.polylinePointIndex = rowIndex;
            
            domSelectionRectsAndHandlesManager.segmentStrokeWidth =
                    [highlightStrokeWidthTextField.stringValue floatValue];
            domSelectionRectsAndHandlesManager.segmentStrokeHexColor =
                    [self hexColorFromColorWell:highlightColorWell];

            [self highlightPolylinePoint];
        }
        else
        {
            [self removeHighlightPolylinePoint];
        }
    }
    else
    {
        svgPolylineEditor.polylinePointIndex = -1;
        
        [self removeHighlightPolylinePoint];
    }
}

//==================================================================================
//	highlightPolylinePoint
//==================================================================================

- (void)highlightPolylinePoint
{
    if (highlightSelectedPointCheckbox.state == YES)
    {
        NSInteger selectedRow = [pointsTableView selectedRow];
        
        if (selectedRow != -1)
        {
            NSWindow * keyWindow = [NSApp keyWindow];
            id firstResponder = [keyWindow firstResponder];
            if (firstResponder != pointsTableView)
            {
                [keyWindow makeFirstResponder:pointsTableView];
            }

            MacSVGDocumentWindowController * macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
            
            DOMSelectionRectsAndHandlesManager * domSelectionRectsAndHandlesManager =
                    macSVGDocumentWindowController.svgXMLDOMSelectionManager.domSelectionRectsAndHandlesManager;
            
            domSelectionRectsAndHandlesManager.segmentStrokeWidth = 0;
            if (highlightUseCustomStrokeWidthCheckbox.state == YES)
            {
                domSelectionRectsAndHandlesManager.segmentStrokeWidth = [highlightStrokeWidthTextField.stringValue floatValue];
            }
    
            domSelectionRectsAndHandlesManager.segmentStrokeHexColor = [self hexColorFromColorWell:highlightColorWell];

            [domSelectionRectsAndHandlesManager highlightPolylinePoint];
        }
    }
}

//==================================================================================
//	removeHighlightPolylinePoint
//==================================================================================

- (void)removeHighlightPolylinePoint
{
    NSInteger selectedRow = [pointsTableView selectedRow];

    if (selectedRow != -1)
    {
        MacSVGDocumentWindowController * macSVGDocumentWindowController =
                [self.macSVGDocument macSVGDocumentWindowController];
        
        DOMSelectionRectsAndHandlesManager * domSelectionRectsAndHandlesManager =
                macSVGDocumentWindowController.svgXMLDOMSelectionManager.domSelectionRectsAndHandlesManager;
        
        [domSelectionRectsAndHandlesManager removeDOMPolylinePointHighlight];
    }
}

//==================================================================================
//	hexColorFromColorWell
//==================================================================================

- (NSString *)hexColorFromColorWell:(NSColorWell *)aColorWell
{
    NSColor * aColor = [aColorWell color];
    
    NSString * hexColor = [self hexadecimalValueOfAnNSColor:aColor];
    
    return hexColor;
}

//==================================================================================
//	updateEditForXMLElement:domElement:info:
//==================================================================================

- (void)updateEditForXMLElement:(NSXMLElement *)xmlElement domElement:(DOMElement *)domElement info:(id)infoData
{
    // subclasses can override as needed
    
    NSArray * aPointsArray = infoData;
    #pragma unused(aPointsArray)
    
    [self loadPointsData];
    
    [pointsTableView reloadData];
}

//==================================================================================
//	hexadecimalValueOfAnNSColor
//==================================================================================

-(NSString *)hexadecimalValueOfAnNSColor:(NSColor *)aColor
{
    CGFloat redFloatValue, greenFloatValue, blueFloatValue;
    int redIntValue, greenIntValue, blueIntValue;
    NSString *redHexValue, *greenHexValue, *blueHexValue;

    // Convert the NSColor to the RGB color space before we can access its components
    NSColor * convertedColor = [aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

    if(convertedColor)
    {
        // Get the red, green, and blue components of the color
        [convertedColor getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];

        // Convert the components to numbers (unsigned decimal integer) between 0 and 255
        redIntValue = redFloatValue * 255.99999f;
        greenIntValue = greenFloatValue * 255.99999f;
        blueIntValue = blueFloatValue * 255.99999f;

        // Convert the numbers to hex strings
        redHexValue=[NSString stringWithFormat:@"%02x", redIntValue]; 
        greenHexValue=[NSString stringWithFormat:@"%02x", greenIntValue];
        blueHexValue=[NSString stringWithFormat:@"%02x", blueIntValue];

        // Concatenate the red, green, and blue components' hex strings together with a "#"
        return [NSString stringWithFormat:@"#%@%@%@", redHexValue, greenHexValue, blueHexValue];
    }
    return nil;
}

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

    NSMutableString * pointsString = [NSMutableString string];
    NSInteger indexOfObject = 0;
    for (NSMutableDictionary * pointDictionary in self.pointsArray)
    {
        NSString * xString = [pointDictionary objectForKey:@"x"];
        NSString * yString = [pointDictionary objectForKey:@"y"];

        if (indexOfObject > 0)
        {
            [pointsString appendString:@" "];
        }

        [pointsString appendString:xString];
        [pointsString appendString:@","];
        [pointsString appendString:yString];
        
        indexOfObject++;
    }

    [self setAttributeName:@"points" value:pointsString element:self.pluginTargetXMLElement];
    
    [self updateDocumentViews];
}

//==================================================================================
//	setAttributeName:value:element:
//==================================================================================

- (void)setAttributeName:(NSString *)attributeName value:(NSString *)attributeValue element:(NSXMLElement *)aElement
{
    NSXMLNode * attributeNode = [aElement attributeForName:attributeName];
    if ([attributeValue length] == 0)
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
            [attributeNode setName:attributeName];
            [attributeNode setStringValue:@""];
            [aElement addAttribute:attributeNode];
        }
        [attributeNode setStringValue:attributeValue];
    }
}

//==================================================================================
//	addPointsRow:
//==================================================================================

- (IBAction)addPointsRow:(id)sender
{
    NSInteger selectedRow = [pointsTableView selectedRow];
    
    NSMutableDictionary * newPointDictionary = NULL;
    
    if (selectedRow >= 0)
    {
        newPointDictionary = [self.pointsArray objectAtIndex:selectedRow];
    }
    else
    {
        newPointDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                @"0", @"x",
                @"0", @"y",
                NULL];
    }
    
    [self.pointsArray insertObject:newPointDictionary atIndex:(selectedRow + 1)];
    
    [pointsTableView reloadData];
    
    NSIndexSet * rowIndexSet = [NSIndexSet indexSetWithIndex:(selectedRow + 1)];
    [pointsTableView selectRowIndexes:rowIndexSet byExtendingSelection:NO];
}

//==================================================================================
//	deletePointsRow:
//==================================================================================

- (IBAction)deletePointsRow:(id)sender
{
    NSInteger selectedRow = [pointsTableView selectedRow];

    if (selectedRow >= 0)
    {
        [self.pointsArray removeObjectAtIndex:selectedRow];
        
        [pointsTableView reloadData];
    }
}

//==================================================================================
//	highlightSelectedPointCheckboxAction:
//==================================================================================

-(IBAction)highlightSelectedPointCheckboxAction:(id)sender
{
    MacSVGDocumentWindowController * macSVGDocumentWindowController =
            [self.macSVGDocument macSVGDocumentWindowController];

    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    SVGPolylineEditor * svgPolylineEditor = [domMouseEventsController svgPolylineEditor];
    
    svgPolylineEditor.highlightSelectedPoint = highlightSelectedPointCheckbox.state;
    
    [self refreshSelectedRow];
}





@end
