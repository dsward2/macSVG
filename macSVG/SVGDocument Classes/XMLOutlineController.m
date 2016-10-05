//
//  XMLOutlineController.m
//  macSVG
//
//  Created by Douglas Ward on 9/18/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "XMLOutlineController.h"
#import "MacSVGDocument.h"
#import "MacSVGDocumentWindowController.h"
#import "ImageAndTextCell.h"
#import "MacSVGAppDelegate.h"
#import "SVGDTDData.h"
#import "SVGElementsTableController.h"
#import "EditorUIFrameController.h"
#import "SelectedElementsManager.h"
#import "SVGXMLDOMSelectionManager.h"
#import "XMLOutlineRowView.h"
#import "DOMSelectionRectsAndHandlesManager.h"
#import "ToolSettingsPopoverViewController.h"
#import "SVGWebKitController.h"
#import "SVGWebView.h"
#import "SVGPathEditor.h"
#import "DOMMouseEventsController.h"
#import "MacSVGAppDelegate.h"
#import "WebKitInterface.h"
#import "SvgWebKitController.h"
#import "SVGIconTableHeaderCell.h"
#import "SVGIconCell.h"

#import "NSOutlineView_Extensions.h"


#define COLUMNID_IS_VISIBLE          @"IsVisibleColumn"
#define COLUMNID_IS_LOCKED           @"IsLockedColumn"
#define COLUMNID_ELEMENT_NAME        @"ElementNameColumn"
#define COLUMNID_ICON                @"IconColumn"

@interface XMLOutlineController(Private)
//- (void)addNewDataToSelection:(NSXMLNode *)newChildData;
@end


@implementation XMLOutlineController

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc 
{
    self.xmlTextEditView = NULL;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        draggingOutlineItems = NO;
        self.draggingActive = NO;
        acceptingDrop = NO;
        validatingDrop = NO;
        
        iconImagesDictionary = NULL;
        self.draggedNodes = NULL;
    }
    
    return self;
}

// ================================================================

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self.xmlOutlineView reloadData];

    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(outlineViewSelectionIsChanging:)
            name:NSOutlineViewSelectionIsChangingNotification object:nil];
}


// ================================================================

- (void)outlineViewSelectionIsChanging:(id)sender
{

}

// ================================================================

- (void)setColumnHeaders 
{ 
    NSTableColumn * visibleColumn = [self.xmlOutlineView tableColumnWithIdentifier:COLUMNID_IS_VISIBLE];
    NSTableColumn * lockColumn = [self.xmlOutlineView tableColumnWithIdentifier:COLUMNID_IS_LOCKED];
    
    //NSImage * visibleEyeImage = [NSImage imageNamed:@"visibleEye.png"];
    //[[visibleColumn headerCell] setImage:visibleEyeImage];
    SVGIconTableHeaderCell * visibleEyeCell = [[SVGIconTableHeaderCell alloc] init];
    visibleEyeCell.iconIndex = 0;
    visibleColumn.headerCell = visibleEyeCell;

    //NSImage * padlockImage = [NSImage imageNamed:@"padlock.png"];
    //[[lockColumn headerCell] setImage:padlockImage];
    SVGIconTableHeaderCell * padlockCell = [[SVGIconTableHeaderCell alloc] init];
    padlockCell.iconIndex = 1;
    lockColumn.headerCell = padlockCell;
}

// ================================================================

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem 
{
    //if ([menuItem action] == @selector(deleteSelections:))
    if (menuItem.action == @selector(deleteElementAction:))
    {
        // The delete selection item should be disabled if nothing is selected.
        if ([self selectedNodes].count > 0) 
        {
            return YES;
        } 
        else 
        {
            return NO;
        }
    }    
    return YES;
}

// ================================================================

- (void)registerDragTypes
{
    NSArray * draggedTypesArray = @[XML_OUTLINE_PBOARD_TYPE, 
            NSStringPboardType, 
            NSURLPboardType, 
            NSFilenamesPboardType, 
            NSTIFFPboardType];
    
    [self.xmlOutlineView registerForDraggedTypes:draggedTypesArray];
    
    [self.xmlOutlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    [self.xmlOutlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    [self.xmlOutlineView setAutoresizesOutlineColumn:NO];
    [self.xmlOutlineView setVerticalMotionCanBeginDrag:YES];

}

// ================================================================

- (void)reloadData 
{
    [self.xmlOutlineView reloadData];
}

//==================================================================================
//	reloadView
//==================================================================================

- (void)reloadView
{
    [self reloadData];
    
    //[xmlOutlineView expandItem:NULL expandChildren:YES];
    
    NSArray * selectedItems = [self.xmlOutlineView selectedItems];
    
    for (NSXMLNode * aXMLNode in selectedItems) 
    {
        [self.xmlOutlineView expandItem:aXMLNode expandChildren:YES];
    }
}

// ================================================================

- (NSArray *)selectedNodes 
{ 
    return [self.xmlOutlineView selectedItems]; 
}

//==================================================================================
//	addSelectionIndexesForChildNodes:selectionIndexes:
//==================================================================================

- (void)addSelectionIndexesForChildNodes:(NSXMLNode *)parentNode 
        selectionIndexes:(NSMutableIndexSet *)selectionIndexes
{
    // recursively select child elements
	NSArray * childNodesArray = parentNode.children;
    
    for (NSXMLNode * childNode in childNodesArray)
    {
        BOOL selectChildNode = NO;
    
        if (childNode.kind ==  NSXMLElementKind) 
        {
            selectChildNode = YES;
        }
    
        if (childNode.kind ==  NSXMLTextKind) 
        {
            selectChildNode = YES;
        }
        
        if (childNode.kind ==  NSXMLCommentKind)
        {
            selectChildNode = YES;
        }
        
        if (selectChildNode == YES)
        {
            NSInteger childRow = [self.xmlOutlineView rowForItem:childNode];

            if (childRow != -1)
            {
                [selectionIndexes addIndex:childRow];
                
                [self addSelectionIndexesForChildNodes:childNode selectionIndexes:selectionIndexes]; // recursive
            }
        }
    }
}

//==================================================================================
//	outlineView:selectionIndexesForProposedSelection:
//==================================================================================

- (NSIndexSet *)outlineView:(NSOutlineView *)outlineView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
{
    // select child nodes with parent node
    NSMutableIndexSet * modifiedSelectionIndexes = [NSMutableIndexSet indexSet];
    
    CGEventRef event = CGEventCreate(NULL);
    CGEventFlags modifiers = CGEventGetFlags(event);
    CFRelease(event);
    //CGEventFlags flags = (kCGEventFlagMaskShift | kCGEventFlagMaskCommand);
    CGEventFlags flags = (kCGEventFlagMaskAlternate);   // check for option key

    [proposedSelectionIndexes enumerateIndexesUsingBlock:^(NSUInteger indexRow, BOOL *stop) 
    {
        [modifiedSelectionIndexes addIndex:indexRow];
    
        NSXMLNode * aXMLNode = [self.xmlOutlineView itemAtRow:indexRow];

        if (aXMLNode.kind ==  NSXMLElementKind) 
        {
            [self addSelectionIndexesForChildNodes:aXMLNode selectionIndexes:modifiedSelectionIndexes];
        }
 
        if ((modifiers & flags) == 0)
        {
            // option key not pressed
            if (aXMLNode.kind ==  NSXMLTextKind)
            {
                NSXMLNode * parentElement = aXMLNode.parent;

                NSInteger parentRow = [self.xmlOutlineView rowForItem:parentElement];

                if (parentRow != -1)
                {
                    [modifiedSelectionIndexes addIndex:parentRow];
                }
            }
        }
    }];
    
    //NSLog(@"proposedSelectionIndexes:%@ modifiedSelectionIndexes:%@", proposedSelectionIndexes, modifiedSelectionIndexes);

    return modifiedSelectionIndexes;
}

//==================================================================================
//	selectElement
//==================================================================================

// select current element only
- (void)selectElement:(NSXMLElement *)aElement
{
    NSMutableIndexSet * rowIndexSet = [NSMutableIndexSet indexSet];    
    
    NSInteger rowIdx = [self.xmlOutlineView rowForItem:aElement];
    
    if (rowIdx != -1)
    {
        [rowIndexSet addIndex:rowIdx];
            
        [self.xmlOutlineView selectRowIndexes:rowIndexSet byExtendingSelection:NO];
    }
}

//==================================================================================
//	outlineViewAction
//==================================================================================

- (void)outlineViewAction:(id)sender 
{
    //NSLog(@"outlineViewAction sender=%@", sender);
}

//==================================================================================
//	selectedElementIDs
//==================================================================================

- (NSArray *)selectedElementIDs
{
    NSMutableArray * resultArray = [NSMutableArray array];
    
    NSArray * selectedItemsArray = [self.xmlOutlineView selectedItems];
    
    if (selectedItemsArray != NULL)
    {
        for (NSXMLElement * aElement in selectedItemsArray)
        {
            if (aElement.kind ==  NSXMLElementKind) 
            {
                NSXMLNode * MacsvgidNode = [aElement attributeForName:@"macsvgid"];
                
                if (MacsvgidNode == NULL)
                {
                    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
                    [macSVGDocument assignNewMacsvgidsForNode:aElement];
                    MacsvgidNode = [aElement attributeForName:@"macsvgid"];
                }
                
                NSString * macsvgid = MacsvgidNode.stringValue;
                [resultArray addObject:macsvgid];
            }
        }
    }
    
    return resultArray;
}

//==================================================================================
//	setSelectedXMLElements:
//==================================================================================

- (void)setSelectedXMLElements:(NSArray *)selectedXMLElements
{
    NSMutableIndexSet * rowIndexSet = [NSMutableIndexSet indexSet];
    
    for (NSXMLElement * aElement in selectedXMLElements)
    {
        NSInteger rowIdx = [self.xmlOutlineView rowForItem:aElement];
        
        if (rowIdx != -1)
        {
            [rowIndexSet addIndex:rowIdx];
        }
    }
    
    [self.xmlOutlineView selectRowIndexes:rowIndexSet byExtendingSelection:NO];
}

//==================================================================================
//	setSelectedXMLDOMElements:
//==================================================================================

- (void)setSelectedXMLDOMElements:(NSArray *)selectedXMLDOMElements
{
    NSMutableIndexSet * rowIndexSet = [NSMutableIndexSet indexSet];
    
    for (NSMutableDictionary * xmlDOMDictionary in selectedXMLDOMElements)
    {
        NSXMLElement * aXMLElement = xmlDOMDictionary[@"xmlElement"];
        
        NSInteger rowIdx = [self.xmlOutlineView rowForItem:aXMLElement];
        
        if (rowIdx != -1)
        {
            [rowIndexSet addIndex:rowIdx];
        }
        
        NSArray * childNodesArray = aXMLElement.children;
        {
            for (NSXMLNode * aChildNode in childNodesArray)
            {
                if (aChildNode.kind == NSXMLTextKind)
                {
                    NSInteger textRowIdx = [self.xmlOutlineView rowForItem:aChildNode];
                    
                    if (textRowIdx != -1)
                    {
                        [rowIndexSet addIndex:textRowIdx];
                    }
                }
            }
        }
    }
    
    [self.xmlOutlineView selectRowIndexes:rowIndexSet byExtendingSelection:NO];
}

//==================================================================================
//	prototypeElementFromSVGElementsTable
//==================================================================================

- (NSString *)prototypeElementFromSVGElementsTable
{
    //NSLog(@"newElementFromSVGElementsTable");
    
    NSMutableString * elementXML = (id)@"";
    
    SVGElementsTableController * svgElementsTableController = 
            self.macSVGDocumentWindowController.svgElementsTableController;
            
    NSInteger selectedRow = (svgElementsTableController.elementsTableView).selectedRow;
    
    if (selectedRow == -1)
    {
        // No element selected
        NSBeep();
    }
    else
    {
        NSString * elementTag = (svgElementsTableController.svgElementsArray)[selectedRow];
        
        NSDictionary * elementDictionary = (svgElementsTableController.svgElementsDictionary)[elementTag];

        NSString * prototypeElement = elementDictionary[@"prototype"];

        elementXML = [NSMutableString stringWithFormat:@"<%@ />", prototypeElement];
    }
    
    return elementXML;
}

//==================================================================================
//	addElementAction:
//==================================================================================

- (IBAction)addElementAction:(id)sender
{
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;

    //NSArray * selectedElementIDs = [macSVGDocumentWindowController.svgXMLDOMSelectionManager selectedElementIDs];
    NSArray * selectedElementIDs = [self selectedElementIDs];
    
    if (selectedElementIDs.count > 0) 
    {
        SVGElementsTableController * svgElementsTableController = 
                self.macSVGDocumentWindowController.svgElementsTableController;

        NSInteger selectedRow = (svgElementsTableController.elementsTableView).selectedRow;
        
        if (selectedRow != -1)
        {
            NSInteger selectedOutlineRow = (self.xmlOutlineView).selectedRow;
        
            NSXMLNode * itemNode = [self.xmlOutlineView itemAtRow:selectedOutlineRow];
            
            if (itemNode.kind != NSXMLElementKind)
            {
                itemNode = itemNode.parent;
            }
            
            if (itemNode.kind == NSXMLElementKind)
            {
                NSXMLElement * item = (NSXMLElement *)itemNode;
            
                NSString * xmlElementPrototypeString = [self prototypeElementFromSVGElementsTable];
                
                NSString * xmlElementString = [self customizeElementPrototype:xmlElementPrototypeString
                        forParentElement:item];
                
                BOOL result = [macSVGDocument insertElementToXmlDocument:xmlElementString
                        item:item childIndex:selectedRow];
                #pragma unused(result)
            }
        }
    }
    
    //[macSVGDocumentWindowController reloadAllViews]; // got called in insertElementToXmlDocument:item:childIndex
}

//==================================================================================
//	customizeElementPrototype:forParentElement:
//==================================================================================

- (NSString *)customizeElementPrototype:(NSString *)xmlElementPrototypeString forParentElement:(NSXMLElement *)parentElement
{
    NSString * resultString = xmlElementPrototypeString;

    NSError * error = NULL;
    NSXMLElement * prototypeElement = [[NSXMLElement alloc] initWithXMLString:xmlElementPrototypeString error:&error];
    
    NSString * prototypeElementName = prototypeElement.name;
    
    if ([prototypeElementName isEqualToString:@"animateTransform"])
    {
        resultString = [self customizeAnimateTransform:xmlElementPrototypeString forParentElement:parentElement];
    }
    else if ([prototypeElementName isEqualToString:@"animateMotion"])
    {
        resultString = [self customizeAnimateMotion:xmlElementPrototypeString forParentElement:parentElement];
    }
    else if ([prototypeElementName isEqualToString:@"script"])
    {
        NSXMLNode *cdataNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind  options:NSXMLNodeIsCDATA];
        cdataNode.stringValue = @"//JavaScript goes here";
        [prototypeElement addChild:cdataNode];
        resultString = [prototypeElement XMLStringWithOptions:NSXMLNodePreserveCDATA];
    }
    else if ([prototypeElementName isEqualToString:@"style"])
    {
        NSXMLNode *cdataNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind  options:NSXMLNodeIsCDATA];
        cdataNode.stringValue = @"/* CSS style goes here */";
        [prototypeElement addChild:cdataNode];
        resultString = [prototypeElement XMLStringWithOptions:NSXMLNodePreserveCDATA];
    }

    return resultString;
}

//==================================================================================
//	customizeAnimateTransform:forParentElement:
//==================================================================================

- (NSString *)customizeAnimateTransform:(NSString *)xmlElementPrototypeString forParentElement:(NSXMLElement *)parentElement
{
    NSString * resultString = xmlElementPrototypeString;

    NSError * error = NULL;
    NSXMLElement * prototypeElement = [[NSXMLElement alloc] initWithXMLString:xmlElementPrototypeString error:&error];
    
    NSString * prototypeElementName = prototypeElement.name;
    
    if ([prototypeElementName isEqualToString:@"animateTransform"] == YES)
    {
        MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)NSApp.delegate;
        
        WebKitInterface * webKitInterface = [macSVGAppDelegate webKitInterface];
        
        NSXMLNode * xmlParentMacsvgidNode = [parentElement attributeForName:@"macsvgid"];
        NSString * parentMacsvgid = xmlParentMacsvgidNode.stringValue;
        
        DOMElement * domParentElement = [self.macSVGDocumentWindowController.svgWebKitController
                domElementForMacsvgid:parentMacsvgid];
        
        NSRect boundingBox = [webKitInterface bBoxForDOMElement:domParentElement];
        
        if (NSIsEmptyRect(boundingBox) == NO)
        {
            CGFloat midX = NSMidX(boundingBox);
            CGFloat midY = NSMidY(boundingBox);
            
            NSString * midXString = [self allocFloatString:midX];
            NSString * midYString = [self allocFloatString:midY];
            
            NSString * rotateValuesString = [NSString stringWithFormat:@"0 %@ %@;360 %@ %@",
                    midXString, midYString, midXString, midYString];
            
            NSXMLNode * valuesNode = [prototypeElement attributeForName:@"values"];
            if (valuesNode != NULL)
            {
                valuesNode.stringValue = rotateValuesString;
                
                resultString = prototypeElement.XMLString;
            }
        }
    }
    
    return resultString;
}

//==================================================================================
//	customizeAnimateTransform:forParentElement:
//==================================================================================

- (NSString *)customizeAnimateMotion:(NSString *)xmlElementPrototypeString forParentElement:(NSXMLElement *)parentElement
{
    NSString * resultString = xmlElementPrototypeString;

    NSError * error = NULL;
    NSXMLElement * prototypeElement = [[NSXMLElement alloc] initWithXMLString:xmlElementPrototypeString error:&error];
    
    NSString * prototypeElementName = prototypeElement.name;
    
    if ([prototypeElementName isEqualToString:@"animateMotion"])
    {
        MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)NSApp.delegate;
        
        WebKitInterface * webKitInterface = [macSVGAppDelegate webKitInterface];
        
        NSXMLNode * xmlParentMacsvgidNode = [parentElement attributeForName:@"macsvgid"];
        NSString * parentMacsvgid = xmlParentMacsvgidNode.stringValue;
        
        DOMElement * domParentElement = [self.macSVGDocumentWindowController.svgWebKitController
                domElementForMacsvgid:parentMacsvgid];
        
        NSRect boundingBox = [webKitInterface bBoxForDOMElement:domParentElement];
        
        if (NSIsEmptyRect(boundingBox) == NO)
        {
            CGFloat x = boundingBox.origin.x;
            CGFloat y = boundingBox.origin.y;
            
            NSString * parentElementName = parentElement.name;
            if (([parentElementName isEqualToString:@"circle"] == YES) ||
                    ([parentElementName isEqualToString:@"ellipse"] == YES))
            {
                x = NSMidX(boundingBox);
                y = NSMidY(boundingBox);
            }
            
            NSString * motionValuesString = @"0 0;20 20;";
           
            NSXMLNode * valuesNode = [prototypeElement attributeForName:@"values"];
            if (valuesNode != NULL)
            {
                valuesNode.stringValue = motionValuesString;
                
                resultString = prototypeElement.XMLString;
            }
        }
    }
    
    return resultString;
}

//==================================================================================
//	addCSSStyleName:styleValue:toXMLElement:
//==================================================================================

- (NSString *)addCSSStyleName:(NSString *)styleName styleValue:(NSString *)styleValue toXMLElement:(NSXMLElement *)targetElement
{
    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSMutableArray * newAttributesArray = [NSMutableArray array];
    
    NSXMLNode * styleAttributeNode = [targetElement attributeForName:@"style"];
    
    if (styleAttributeNode != NULL)
    {
        NSString * styleAttributeString = styleAttributeNode.stringValue;

        BOOL itemWasFound = NO;

        if (styleAttributeString.length > 0)
        {
            NSArray * styleItemsArray = [styleAttributeString componentsSeparatedByString:@";"];
            
            for (NSString * styleExpression in styleItemsArray)
            {
                NSString * copyStyleExpression = styleExpression;
            
                NSArray * styleExpressionArray = [styleExpression componentsSeparatedByString:@":"];
                
                if (styleExpressionArray.count == 2)
                {
                    NSString * aStyleName = styleExpressionArray.firstObject;

                    aStyleName = [aStyleName stringByTrimmingCharactersInSet:whitespaceSet];
                    
                    if ([styleName isEqualToString:aStyleName] == YES)
                    {
                        copyStyleExpression = [NSString stringWithFormat:@"%@: %@", styleName, styleValue];
                        itemWasFound = YES;
                    }
                }
                
                if (copyStyleExpression.length > 0)
                {
                    [newAttributesArray addObject: copyStyleExpression];
                }
            }
        }
        
        if (itemWasFound == NO)
        {
            NSString * styleString = [NSString stringWithFormat:@"%@: %@", styleName, styleValue];
        
            [newAttributesArray addObject:styleString];
        }
    }
    else
    {
        NSString * styleExpressionString = [NSString stringWithFormat:@"%@: %@", styleName, styleValue];
    
        [newAttributesArray addObject:styleExpressionString];
    }

    NSString * newStyleAttributeString = [newAttributesArray componentsJoinedByString:@";"];
    
    if (newStyleAttributeString.length > 0)
    {
        newStyleAttributeString = [newStyleAttributeString stringByAppendingString:@";"];
    }
    
    return newStyleAttributeString;
}

//==================================================================================
//	addCSSStyleName:styleValue:toDOMElement:
//==================================================================================

- (NSString *)addCSSStyleName:(NSString *)styleName styleValue:(NSString *)styleValue toDOMElement:(DOMElement *)targetElement
{
    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSMutableArray * newAttributesArray = [NSMutableArray array];
    
    DOMNode * styleAttributeNode = [targetElement getAttributeNode:@"style"];
    
    if (styleAttributeNode != NULL)
    {
        NSString * styleAttributeString = styleAttributeNode.nodeValue;
        
        NSArray * styleItemsArray = [styleAttributeString componentsSeparatedByString:@";"];
        
        BOOL itemWasFound = NO;
        
        for (NSString * styleExpression in styleItemsArray)
        {
            NSString * copyStyleExpression = styleExpression;
        
            NSArray * styleExpressionArray = [styleExpression componentsSeparatedByString:@":"];
            
            if (styleExpressionArray.count == 2)
            {
                NSString * aStyleName = styleExpressionArray.firstObject;

                aStyleName = [aStyleName stringByTrimmingCharactersInSet:whitespaceSet];
                
                if ([styleName isEqualToString:aStyleName] == YES)
                {
                    copyStyleExpression = [NSString stringWithFormat:@"%@: %@", styleName, styleValue];
                    itemWasFound = YES;
                }
            }
            
            if (copyStyleExpression.length > 0)
            {
                [newAttributesArray addObject: copyStyleExpression];
            }
        }
        
        if (itemWasFound == NO)
        {
            NSString * styleString = [NSString stringWithFormat:@"%@: %@", styleName, styleValue];
        
            [newAttributesArray addObject:styleString];
        }
    }
    else
    {
        NSString * styleExpressionString = [NSString stringWithFormat:@"%@: %@", styleName, styleValue];
    
        [newAttributesArray addObject:styleExpressionString];
    }

    NSString * newStyleAttributeString = [newAttributesArray componentsJoinedByString:@";"];
    
    if (newStyleAttributeString.length > 0)
    {
        newStyleAttributeString = [newStyleAttributeString stringByAppendingString:@";"];
    }
    
    return newStyleAttributeString;
}

//==================================================================================
//	allocFloatString:
//==================================================================================

- (NSMutableString *)allocFloatString:(float)aFloat
{
    NSMutableString * aString = [[NSMutableString alloc] initWithFormat:@"%f", aFloat];

    BOOL continueTrim = YES;
    while (continueTrim == YES)
    {
        NSUInteger stringLength = aString.length;
        
        if (stringLength <= 1)
        {
            continueTrim = NO;
        }
        else
        {
            unichar lastChar = [aString characterAtIndex:(stringLength - 1)];
            
            if (lastChar == '0')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
            }
            else if (lastChar == '.')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
                continueTrim = NO;
            }
            else
            {
                continueTrim = NO;
            }
        }
    }
    return aString;
}

//==================================================================================
//	allocPxString:
//==================================================================================

- (NSMutableString *)allocPxString:(float)aFloat
{
    NSMutableString * aString = [[NSMutableString alloc] initWithFormat:@"%f", aFloat];

    BOOL continueTrim = YES;
    while (continueTrim == YES)
    {
        NSUInteger stringLength = aString.length;
        
        if (stringLength <= 1)
        {
            continueTrim = NO;
        }
        else
        {
            unichar lastChar = [aString characterAtIndex:(stringLength - 1)];
            
            if (lastChar == '0')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
            }
            else if (lastChar == '.')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
                continueTrim = NO;
            }
            else
            {
                continueTrim = NO;
            }
        }
    }
    
    [aString appendString:@"px"];
    
    return aString;
}


//==================================================================================
//	deleteElementAction:
//==================================================================================

- (IBAction)deleteElementAction:(id)sender
{
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
    
    NSMutableArray * deletedNodesArray = [NSMutableArray array];
    NSMutableArray * parentNodesArray = [NSMutableArray array];

    NSIndexSet * selectedIndexSet = (self.xmlOutlineView).selectedRowIndexes;

    // Save Undo/Redo information
    NSMutableArray * deletedElementsArray = [NSMutableArray array];
    [selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger indexRow, BOOL *stop)
    {
        // only nodes with an unselected parent need to be kept
        NSXMLNode * aXMLNode = [self.xmlOutlineView itemAtRow:indexRow];
        NSXMLNode * parentNode = aXMLNode.parent;
        NSInteger parentRow = [self.xmlOutlineView rowForItem:parentNode];
        if ([selectedIndexSet containsIndex:parentRow] == NO)
        {
            [deletedElementsArray addObject:aXMLNode];
        }
    }];
    
    //[macSVGDocument pushUndoRedoDeleteElements:deletedElementsArray];
    [macSVGDocument pushUndoRedoDocumentChanges];
    
    // delete text nodes first
    [selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger indexRow, BOOL *stop)
    {
        NSXMLNode * aXMLNode = [self.xmlOutlineView itemAtRow:indexRow];
        NSXMLNode * parentNode = aXMLNode.parent;
        
        [deletedNodesArray addObject:aXMLNode];
        [parentNodesArray addObject:parentNode];
 
        if (aXMLNode.kind ==  NSXMLTextKind) 
        {
            NSXMLElement * parentElement = (NSXMLElement *)parentNode;
            
            NSUInteger childCount = parentNode.childCount;
            
            for (NSUInteger i = 0; i < childCount; i++)
            {
                NSXMLNode * aNode = [parentNode childAtIndex:i];
                
                if (aNode == aXMLNode)
                {
                    [parentElement removeChildAtIndex:i];
                    break;
                }
            }        
        }
    }];

    // delete elements
    NSArray * selectedElementIDs = [self selectedElementIDs];
    
    for (NSString * macsvgid in selectedElementIDs)
    {
        [macSVGDocument deleteElementForMacsvgid:macsvgid];
    }
    
    [domSelectionRectsAndHandlesManager removeDOMSelectionRectsAndHandles];
    
    //[macSVGDocumentWindowController reloadAllViews];
    
    NSMutableArray * reloadedNodesArray = [NSMutableArray array];
    for (NSXMLNode * aParentNode in parentNodesArray)
    {
        if ([deletedNodesArray containsObject:aParentNode] == NO)
        {
            if ([reloadedNodesArray containsObject:aParentNode] == NO)
            {
                [self.xmlOutlineView reloadItem:aParentNode reloadChildren:YES];
            }
        }
    }
    
    [self.xmlOutlineView deselectAll:self];
    
    [self.macSVGDocumentWindowController reloadWebView];    // reload everything except outlineView
}

//==================================================================================
//	duplicateElementAction:
//==================================================================================

- (IBAction)duplicateElementAction:(id)sender
{
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;

    NSArray * selectedElementIDs = [self selectedElementIDs];
    
    if (selectedElementIDs.count > 0) 
    {
        [macSVGDocument pushUndoRedoDocumentChanges];

        //SVGElementsTableController * svgElementsTableController =
        //        macSVGDocumentWindowController.svgElementsTableController;

        //NSInteger selectedRow = [svgElementsTableController.elementsTableView selectedRow];
        
        //NSXMLElement * sourceXMLElement = [xmlOutlineView itemAtRow:selectedRow];
        
        NSString * macsvgid = selectedElementIDs[0];
        
        NSXMLElement * sourceXMLElement = [macSVGDocument xmlElementForMacsvgid:macsvgid];
        
        BOOL result = [macSVGDocument duplicateElement:sourceXMLElement];
        #pragma unused(result)
    }
}

//==================================================================================
//	expandAllNodes
//==================================================================================

- (void) expandAllNodes
{
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
    XMLOutlineView * xmlOutlineView = self.xmlOutlineView;
    NSXMLElement * rootElement = [macSVGDocument.svgXmlDocument rootElement];
    [xmlOutlineView expandItem:rootElement expandChildren:YES];
}

//==================================================================================
//	expandElementInOutline
//==================================================================================

- (void) expandElementInOutline:(NSXMLElement *)aElement
{
    NSXMLElement * parentElement = (id)aElement.parent;
    
    [self.xmlOutlineView expandItem:parentElement expandChildren:YES];    
    
    [self.xmlOutlineView expandItem:aElement expandChildren:YES];

    NSArray * selectedItems = @[aElement];

    [self.xmlOutlineView setSelectedItems:selectedItems];
}


// ================================================================

- (NSArray *)selectedItems
{
    NSArray * selectedItemsArray = [self.xmlOutlineView selectedItems];
    
    return selectedItemsArray;
}

// ================================================================

- (IBAction)addGroupElementAction:(id)sender
{
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
    
    NSXMLElement * rootElement = [macSVGDocument.svgXmlDocument rootElement];
    
    NSArray * selectedElementIDsArray = [self selectedElementIDs];
    
    if (selectedElementIDsArray.count > 0)
    {
        // enclose selected elements within new group element

        SVGElementsTableController * svgElementsTableController =
                self.macSVGDocumentWindowController.svgElementsTableController;

        NSDictionary * elementDictionary = (svgElementsTableController.svgElementsDictionary)[@"g"];

        NSString * prototypeElement = elementDictionary[@"prototype"];

        NSString * xmlElementString = [NSMutableString stringWithFormat:@"<%@ />", prototypeElement];
        
        //NSInteger selectedRow = [self.xmlOutlineView selectedRow];
        
        NSIndexSet * selectedIndexSet = (self.xmlOutlineView).selectedRowIndexes;

        NSUInteger selectedRow = selectedIndexSet.firstIndex;
        
        if (selectedRow != NSNotFound)
        {
            NSXMLNode * selectedNode = [self.xmlOutlineView itemAtRow:selectedRow];
            
            if (selectedNode.kind == NSXMLElementKind)
            {
                NSXMLElement * selectedElement = (NSXMLElement *)selectedNode;
                NSXMLElement * parentElement = (NSXMLElement *)selectedNode.parent;
                
                NSInteger insertElementIndex = selectedElement.index;
                
                NSXMLElement * groupElement = [self insertGroupElementToXmlDocument:xmlElementString
                        item:parentElement childIndex:insertElementIndex selectedElementIDsArray:selectedElementIDsArray];
                
                if (groupElement != NULL)
                {
                    //NSInteger rowIdx = [self.xmlOutlineView rowForItem:groupElement];
                    
                    [self.xmlOutlineView expandItem:parentElement];
                    [self.xmlOutlineView expandItem:groupElement];

                    NSMutableIndexSet * proposedSelectionIndexes = [NSMutableIndexSet indexSetWithIndex:selectedRow];

                    [self addSelectionIndexesForChildNodes:groupElement
                            selectionIndexes:proposedSelectionIndexes];

                    [self.xmlOutlineView selectRowIndexes:proposedSelectionIndexes byExtendingSelection:NO];
                }
            }
        }
    }
    else
    {
        // append new group element as last element

        NSInteger childCount = [self.xmlOutlineView numberOfChildrenOfItem:rootElement];

        SVGElementsTableController * svgElementsTableController =
                self.macSVGDocumentWindowController.svgElementsTableController;

        NSDictionary * elementDictionary = (svgElementsTableController.svgElementsDictionary)[@"g"];

        NSString * prototypeElement = elementDictionary[@"prototype"];

        NSString * xmlElementString = [NSMutableString stringWithFormat:@"<%@ />", prototypeElement];
        
        BOOL result = [macSVGDocument insertElementToXmlDocument:xmlElementString
                item:rootElement childIndex:childCount];
        #pragma unused(result)
        
        NSXMLElement * groupElement = [self.xmlOutlineView child:childCount ofItem:rootElement];
        
        [self selectElement:groupElement];
    }
}

//==================================================================================
//	insertGroupElementToXmlDocument:item:childIndex:selectedElementIDArray
//==================================================================================

- (NSXMLElement *)insertGroupElementToXmlDocument:(NSString *)xmlElementString
        item:(id)item childIndex:(NSInteger)childIndex selectedElementIDsArray:(NSArray *)selectedElementIDsArray
{
    CGEventRef event = CGEventCreate(NULL);
    CGEventFlags modifiers = CGEventGetFlags(event);
    CFRelease(event);
    //CGEventFlags flags = (kCGEventFlagMaskShift | kCGEventFlagMaskCommand);
    CGEventFlags flags = (kCGEventFlagMaskAlternate);   // check for option key

    if ((modifiers & flags) == 0)
    {
        // option key not pressed
    }

    NSString * xmlString = xmlElementString;
        
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
    NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;

    //NSArray * oldSelectedNodes = [self selectedNodes];
 
    NSXMLElement * rootElement = [svgXmlDocument rootElement];

    NSXMLNode * targetNode = item;
    
    // A target of "nil" means we are on the main root tree
    if (targetNode == nil) 
	{
        targetNode = rootElement;
    }
    
    // Determine the parent to insert into and the child index to insert at.
    if (targetNode.kind != NSXMLElementKind)
   {
        // If our target is a leaf, and we are dropping on it
        if (childIndex == NSOutlineViewDropOnItemIndex) 
        {
            // If we are dropping on a leaf, we will have to turn it into a container node
            childIndex = 0;
        } 
        else 
        {
            // We will be dropping on the item's parent at the target index of this child, plus one
            NSXMLNode * oldTargetNode = targetNode;
            targetNode = targetNode.parent;
            childIndex = [targetNode.children indexOfObject:oldTargetNode] + 1;
        }
    } 
    else 
    {            
        if (childIndex == NSOutlineViewDropOnItemIndex) 
        {
            // Insert it at the start, if we were dropping on it
            childIndex = 0;
        }
    }
    
    // Create a temporary XML document with the dragged object and namespace declarations
    NSError * docError = NULL;

    NSString * headerString = [macSVGDocument svgHeaderString];

    NSString * footerString = @"</svg>";
    
    NSString * xmlDocString = [[NSString alloc] initWithFormat:@"%@%@%@", headerString, xmlString, footerString];
    
    NSXMLDocument * tempDocument = [[NSXMLDocument alloc] initWithXMLString:xmlDocString options:0 error:&docError];
    
    NSXMLElement * tempRootElement = [tempDocument rootElement];
    
    // retrieve the new group
    NSXMLElement * newGroupElement = (id)[tempRootElement childAtIndex:0];

    [newGroupElement detach];
    
    [macSVGDocument assignNewMacsvgidsForNode:newGroupElement];
    
    [macSVGDocument assignElementIDIfUnassigned:newGroupElement];

    //[item insertChild:newGroupElement atIndex:childIndex];
    
    [self moveSelectedElementIDs:selectedElementIDsArray toGroupElement:newGroupElement];

    [item insertChild:newGroupElement atIndex:childIndex];

    [self.macSVGDocumentWindowController reloadAllViews];
    
    // Make sure the target is expanded
    //[self.xmlOutlineView expandItem:targetNode expandChildren:YES];
    [self.xmlOutlineView expandItem:newGroupElement expandChildren:YES];
    
    // Select new Group.
    NSArray * newSelectionArray = @[newGroupElement];
    [self.xmlOutlineView setSelectedItems:newSelectionArray];
    
    return newGroupElement;
}

//==================================================================================
//	moveSelectedElementIDs:toGroupElement:
//==================================================================================

- (void) moveSelectedElementIDs:(NSArray *)selectedElementIDsArray toGroupElement:groupElement
{
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;

    //NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;

    NSMutableDictionary * selectedElementsDictionary = [NSMutableDictionary dictionary];
    
    for (NSString * macsvgid in selectedElementIDsArray)
    {
        NSXMLElement * aSelectedElement = [macSVGDocument xmlElementForMacsvgid:macsvgid];
        
        selectedElementsDictionary[macsvgid] = aSelectedElement;
    }
    
    NSMutableArray * groupedElementsArray = [NSMutableArray array];

    for (NSString * macsvgid in selectedElementIDsArray)
    {
        NSXMLElement * aXMLElement = selectedElementsDictionary[macsvgid];
        
        NSXMLNode * parentXMLNode = aXMLElement.parent;
        
        if (parentXMLNode.kind == NSXMLElementKind)
        {
            NSXMLElement * parentXMLElement = (NSXMLElement *)parentXMLNode;
        
            NSXMLNode * parentMacsvgidAttribute = [parentXMLElement attributeForName:@"macsvgid"];
            
            NSString * parentMacsvgid = parentMacsvgidAttribute.stringValue;
                
            NSXMLElement * existingParentElement = selectedElementsDictionary[parentMacsvgid];
            
            if (existingParentElement == NULL)
            {
                [groupedElementsArray addObject:aXMLElement];
            }
        }
    }

    //[macSVGDocument pushUndoRedoGroupedElements:groupedElementsArray newGroupElement:groupElement];

    [macSVGDocument pushUndoRedoDocumentChanges];

    
    for (NSXMLElement * aXMLElement in groupedElementsArray)
    {
        NSXMLNode * parentXMLNode = aXMLElement.parent;
        
        if (parentXMLNode.kind == NSXMLElementKind)
        {
            NSXMLElement * parentXMLElement = (NSXMLElement *)parentXMLNode;
        
            NSXMLNode * parentMacsvgidAttribute = [parentXMLElement attributeForName:@"macsvgid"];
            
            NSString * parentMacsvgid = parentMacsvgidAttribute.stringValue;
                
            NSXMLElement * existingParentElement = selectedElementsDictionary[parentMacsvgid];
            
            if (existingParentElement == NULL)
            {
                // move the top level elements to new group element container
                
                [aXMLElement detach];
                
                [groupElement addChild:aXMLElement];
            }
        }
    }
}

//==================================================================================
//	editXMLTextAction:
//==================================================================================

- (IBAction)editXMLTextAction:(id)sender
{
    NSArray * selectedItems = [self.xmlOutlineView selectedItems];
    
    NSInteger selectedItemsCount = selectedItems.count;

    if (selectedItemsCount > 0)
    {
        NSMutableArray * editItemArray = [NSMutableArray array];
        
        for (NSXMLElement * aElement in selectedItems)
        {
            NSInteger elementIndex = [selectedItems indexOfObject:aElement];
            
            if (elementIndex == 0)
            {
                [editItemArray addObject:aElement];
            }
            else
            {
                NSXMLNode * parentNode = aElement;
                BOOL parentFound = NO;
                
                while (parentNode != NULL)
                {
                    parentNode = parentNode.parent;
                    
                    for (NSXMLElement * editItem in editItemArray)
                    {
                        if (parentNode == editItem)
                        {
                            parentFound = YES;
                            break;
                        }
                    }
                    
                    if (parentFound == YES)
                    {
                        break;
                    }
                }
                
                if (parentFound == NO)
                {
                    [editItemArray addObject:aElement];
                }
            }
        }
        
        if (editItemArray.count == 1)
        {
            NSFont * courierFont = [NSFont fontWithName:@"Courier New" size:14];

            [self.xmlTextEditView setRichText:NO];
            [self.xmlTextEditView setContinuousSpellCheckingEnabled:NO];
            [self.xmlTextEditView setGrammarCheckingEnabled:NO];
            
            [self.xmlTextEditView setSmartInsertDeleteEnabled:NO];
            [self.xmlTextEditView setAutomaticQuoteSubstitutionEnabled:NO];
            [self.xmlTextEditView setAutomaticLinkDetectionEnabled:NO];
            [self.xmlTextEditView setAutomaticDashSubstitutionEnabled:NO];
            [self.xmlTextEditView setAutomaticDataDetectionEnabled:NO];
            [self.xmlTextEditView setAutomaticSpellingCorrectionEnabled:NO];
            [self.xmlTextEditView setAutomaticTextReplacementEnabled:NO];
        
            (self.xmlTextEditView).font = courierFont;
        
            NSWindow * hostWindow = (self.macSVGDocumentWindowController).window;
            
            NSXMLElement * firstElement = editItemArray[0];
            
            NSXMLNode * MacsvgidNode = [firstElement attributeForName:@"macsvgid"];
            
            NSString * macsvgid = MacsvgidNode.stringValue;

            MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
            self.editElement = [macSVGDocument xmlElementForMacsvgid:macsvgid];
            
            NSUInteger xmlStringOptions = NSXMLNodePrettyPrint | NSXMLNodePreserveCDATA;
            
            NSString * xmlString = [self.editElement XMLStringWithOptions:xmlStringOptions];
            
            (self.xmlTextEditView).string = xmlString;
            
            [hostWindow beginSheet:self.xmlTextEditSheet  completionHandler:^(NSModalResponse returnCode)
            {
            
            
            }];            
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
//	applyEditXMLText:
//==================================================================================

- (IBAction) applyEditXMLText:(id)sender
{
    NSString * xmlString = (self.xmlTextEditView).string;
    
    NSError * xmlError = NULL;
    
    NSXMLDocument * xmlDocument = [[NSXMLDocument alloc] initWithXMLString:xmlString options:NSXMLNodePreserveCDATA error:&xmlError];
    NSXMLElement * xmlElement = [xmlDocument rootElement];
    [xmlElement detach];
    
    if (xmlError != NULL)
    {
        NSString * errorString = xmlError.localizedDescription;
        
        NSString * errorMessageString = [NSString stringWithFormat:@"Error: %@", errorString];
        
        (self.editErrorTextField).stringValue = errorMessageString;
        
        NSBeep();
    }
    else
    {
        MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
        NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;
            
        [macSVGDocument pushUndoRedoDocumentChanges];

        [macSVGDocument assignNewMacsvgidsForNode:xmlElement];

        NSXMLElement * parentElement = (NSXMLElement *)(self.editElement).parent;
        
        if (parentElement != NULL)
        {
            NSInteger childIndex = (self.editElement).index;
            
            [parentElement replaceChildAtIndex:childIndex withNode:xmlElement];
        }
        else
        {
            [svgXmlDocument setRootElement:xmlElement];
        }
    
        NSWindow * hostWindow = (self.macSVGDocumentWindowController).window;
        [hostWindow endSheet:self.xmlTextEditSheet returnCode:NSModalResponseContinue];

        [self.xmlTextEditSheet orderOut:sender];
        
        self.editElement = NULL;
        
        [self.macSVGDocumentWindowController reloadAllViews];
    }
}

//==================================================================================
//	cancelEditXMLText:
//==================================================================================

- (IBAction) cancelEditXMLText:(id)sender
{
    NSWindow * hostWindow = (self.macSVGDocumentWindowController).window;
    [hostWindow endSheet:self.xmlTextEditSheet returnCode:NSModalResponseCancel];

    [self.xmlTextEditSheet orderOut:sender];

    self.editElement = NULL;
}

//==================================================================================
//	selectedElementsInfoAction:
//==================================================================================

- (IBAction)selectedElementsInfoAction:(id)sender
{
    NSButton *targetButton = (NSButton *)sender;
    
    // configure the preferred position of the popover
    [self.selectedElementsInfoPopover showRelativeToRect:targetButton.bounds ofView:sender preferredEdge:NSMaxYEdge];
}

// ================================================================

- (IBAction)visibilityCheckboxAction:(id)sender
{
    NSInteger clickedCol = (self.xmlOutlineView).clickedColumn;
    NSInteger clickedRow = (self.xmlOutlineView).clickedRow;
    if ((clickedRow >= 0) && (clickedCol >= 0)) 
    {
        NSCell * cell = [self.xmlOutlineView preparedCellAtColumn:clickedCol row:clickedRow];
        if ([cell isKindOfClass:[NSButtonCell class]] && cell.enabled) 
        {
            NSButtonCell * buttonCell = (id)cell;
            NSInteger newState = buttonCell.state;
            #pragma unused(newState)

            NSTableColumn * aTableColumn = [self.xmlOutlineView tableColumnWithIdentifier:COLUMNID_IS_VISIBLE];
            #pragma unused(aTableColumn)
            
            id item = [self.xmlOutlineView itemAtRow:clickedRow];
            
            NSXMLNode * nodeData = item;
            NSXMLNodeKind nodeKind = nodeData.kind;
            
            if (nodeKind ==  NSXMLElementKind)
            {
                NSString * visibility = @"hidden";

                NSXMLElement * rowElement = (id)nodeData;
                NSXMLNode * visibilityAttributeNode = [rowElement attributeForName:@"visibility"];
                NSString * visibilityAttributeString = visibilityAttributeNode.stringValue;
                if (visibilityAttributeString != NULL)
                {
                    if ([visibilityAttributeString isEqualToString:@"hidden"])
                    {
                        visibility = @"visible";
                    }
                    visibilityAttributeNode.stringValue = visibility;
                }
                else
                {
                    visibilityAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                    visibilityAttributeNode.name = @"visibility";
                    visibilityAttributeNode.stringValue = visibility;
                    [rowElement addAttribute:visibilityAttributeNode];
                }
                
                NSXMLNode * MacsvgidNode = [rowElement attributeForName:@"macsvgid"];
                NSString * macsvgid = MacsvgidNode.stringValue;
                
                [self.macSVGDocumentWindowController setDOMVisibility:visibility forMacsvgid:macsvgid];
                
                if ([visibility isEqualToString:@"hidden"] == YES)
                {
                    //[self.xmlOutlineView deselectRow:clickedRow];
                    
                    [self deselectRowsForXMLNode:rowElement];
                }
            }
        }            
    }
}


- (void)deselectRowsForXMLNode:(NSXMLNode *)aXMLNode
{
    NSInteger rowForItem = [self.xmlOutlineView rowForItem:aXMLNode];
    
    if (rowForItem > -1)
    {
        [self.xmlOutlineView deselectRow:rowForItem];
    
        NSArray * childNodesArray = aXMLNode.children;
        
        for (NSXMLNode * childXMLNode in childNodesArray)
        {
            [self deselectRowsForXMLNode:childXMLNode];     // recursive call
        }
    }
}

//==================================================================================
//	nudgeSelectedItemsUp
//==================================================================================

- (void)nudgeSelectedItemsUp
{
    [self nudgeSelectedItemsWithDeltaX:0.0f deltaY:-1.0f];
}

//==================================================================================
//	nudgeSelectedItemsDown
//==================================================================================

- (void)nudgeSelectedItemsDown
{
    [self nudgeSelectedItemsWithDeltaX:0.0f deltaY:1.0f];
}

//==================================================================================
//	nudgeSelectedItemsLeft
//==================================================================================

- (void)nudgeSelectedItemsLeft
{
    [self nudgeSelectedItemsWithDeltaX:-1.0f deltaY:0.0f];
}

//==================================================================================
//	nudgeSelectedItemsRight
//==================================================================================

- (void)nudgeSelectedItemsRight
{
    [self nudgeSelectedItemsWithDeltaX:1.0f deltaY:0.0f];
}

//==================================================================================
//	nudgeSelectedItemsWithDeltaX:deltaY:
//==================================================================================

- (void)nudgeSelectedItemsWithDeltaX:(CGFloat)deltaX deltaY:(CGFloat)deltaY
{
    //NSArray * selectedItems = [self.xmlOutlineView selectedItems];

    NSArray * selectedElementsDictionariesArray =
            [self.macSVGDocumentWindowController.svgXMLDOMSelectionManager.selectedElementsManager selectedElementsArray];
    
    for (NSMutableDictionary * elementDictionary in selectedElementsDictionariesArray)
    {
        NSXMLElement * aXMLElement = elementDictionary[@"xmlElement"];
        DOMElement * aDOMElement = elementDictionary[@"domElement"];
    
        NSString * elementName = aXMLElement.name;
        
        BOOL nudgeXY = NO;
        BOOL nudgeX1Y1 = NO;
        BOOL nudgeX2Y2 = NO;
        BOOL nudgeCxCy = NO;
        BOOL nudgePoints = NO;
        BOOL nudgePath = NO;
        
        if ([elementName isEqualToString:@"rect"] == YES)
        {
            nudgeXY = YES;
        }
        if ([elementName isEqualToString:@"circle"] == YES)
        {
            nudgeCxCy = YES;
        }
        if ([elementName isEqualToString:@"ellipse"] == YES)
        {
            nudgeCxCy = YES;
        }
        if ([elementName isEqualToString:@"polyline"] == YES)
        {
            nudgePoints = YES;
        }
        if ([elementName isEqualToString:@"polygon"] == YES)
        {
            nudgePoints = YES;
        }
        if ([elementName isEqualToString:@"line"] == YES)
        {
            nudgeX1Y1 = YES;
            nudgeX2Y2 = YES;
        }
        if ([elementName isEqualToString:@"text"] == YES)
        {
            nudgeXY = YES;
        }
        if ([elementName isEqualToString:@"image"] == YES)
        {
            nudgeXY = YES;
        }
        if ([elementName isEqualToString:@"path"] == YES)
        {
            nudgePath = YES;
        }
        if ([elementName isEqualToString:@"foreignObject"] == YES)
        {
            nudgeXY = YES;
        }
        
        if (nudgeXY == YES)
        {
            NSXMLNode * xAttributeNode = [aXMLElement attributeForName:@"x"];
            NSString * xAttributeString = xAttributeNode.stringValue;
            CGFloat xAttributeFloat = xAttributeString.floatValue;
            xAttributeFloat += deltaX;
            xAttributeString = [self allocPxString:xAttributeFloat];
            xAttributeNode.stringValue = xAttributeString;
            
            NSXMLNode * yAttributeNode = [aXMLElement attributeForName:@"y"];
            NSString * yAttributeString = yAttributeNode.stringValue;
            CGFloat yAttributeFloat = yAttributeString.floatValue;
            yAttributeFloat += deltaY;
            yAttributeString = [self allocPxString:yAttributeFloat];
            yAttributeNode.stringValue = yAttributeString;
            
            [aDOMElement setAttribute:@"x" value:xAttributeString];
            [aDOMElement setAttribute:@"y" value:yAttributeString];
        }

        if (nudgeCxCy == YES)
        {
            NSXMLNode * cxAttributeNode = [aXMLElement attributeForName:@"cx"];
            NSString * cxAttributeString = cxAttributeNode.stringValue;
            CGFloat cxAttributeFloat = cxAttributeString.floatValue;
            cxAttributeFloat += deltaX;
            cxAttributeString = [self allocPxString:cxAttributeFloat];
            cxAttributeNode.stringValue = cxAttributeString;
            
            NSXMLNode * cyAttributeNode = [aXMLElement attributeForName:@"cy"];
            NSString * cyAttributeString = cyAttributeNode.stringValue;
            CGFloat cyAttributeFloat = cyAttributeString.floatValue;
            cyAttributeFloat += deltaY;
            cyAttributeString = [self allocPxString:cyAttributeFloat];
            cyAttributeNode.stringValue = cyAttributeString;
            
            [aDOMElement setAttribute:@"cx" value:cxAttributeString];
            [aDOMElement setAttribute:@"cy" value:cyAttributeString];
        }
        
        if (nudgeX1Y1 == YES)
        {
            NSXMLNode * x1AttributeNode = [aXMLElement attributeForName:@"x1"];
            NSString * x1AttributeString = x1AttributeNode.stringValue;
            CGFloat x1AttributeFloat = x1AttributeString.floatValue;
            x1AttributeFloat += deltaX;
            x1AttributeString = [self allocPxString:x1AttributeFloat];
            x1AttributeNode.stringValue = x1AttributeString;
            
            NSXMLNode * y1AttributeNode = [aXMLElement attributeForName:@"y1"];
            NSString * y1AttributeString = y1AttributeNode.stringValue;
            CGFloat y1AttributeFloat = y1AttributeString.floatValue;
            y1AttributeFloat += deltaY;
            y1AttributeString = [self allocPxString:y1AttributeFloat];
            y1AttributeNode.stringValue = y1AttributeString;
            
            [aDOMElement setAttribute:@"x1" value:x1AttributeString];
            [aDOMElement setAttribute:@"y1" value:y1AttributeString];
        }
        
        if (nudgeX2Y2 == YES)
        {
            NSXMLNode * x2AttributeNode = [aXMLElement attributeForName:@"x2"];
            NSString * x2AttributeString = x2AttributeNode.stringValue;
            CGFloat x2AttributeFloat = x2AttributeString.floatValue;
            x2AttributeFloat += deltaX;
            x2AttributeString = [self allocPxString:x2AttributeFloat];
            x2AttributeNode.stringValue = x2AttributeString;
            
            NSXMLNode * y2AttributeNode = [aXMLElement attributeForName:@"y2"];
            NSString * y2AttributeString = y2AttributeNode.stringValue;
            CGFloat y2AttributeFloat = y2AttributeString.floatValue;
            y2AttributeFloat += deltaY;
            y2AttributeString = [self allocPxString:y2AttributeFloat];
            y2AttributeNode.stringValue = y2AttributeString;
            
            [aDOMElement setAttribute:@"x2" value:x2AttributeString];
            [aDOMElement setAttribute:@"y2" value:y2AttributeString];
        }
        
        if (nudgePath == YES)
        {
            [self nudgePathElement:elementDictionary deltaX:deltaX deltaY:deltaY];
        }
    }
    
    [self.macSVGDocumentWindowController.svgXMLDOMSelectionManager.domSelectionRectsAndHandlesManager updateDOMSelectionRectsAndHandles];
    
    [self.macSVGDocumentWindowController reloadAttributesTableData];
}

//==================================================================================
//	nudgeSelectedItemsWithDeltaX:deltaY:
//==================================================================================

- (void)nudgePathElement:(NSMutableDictionary *)pathElementDictionary deltaX:(CGFloat)deltaX deltaY:(CGFloat)deltaY
{
        NSXMLElement * aXMLElement = pathElementDictionary[@"xmlElement"];
        DOMElement * aDOMElement = pathElementDictionary[@"domElement"];

        NSXMLNode * dAttributeNode = [aXMLElement attributeForName:@"d"];
        NSString * dAttributeString = dAttributeNode.stringValue;

        NSMutableArray * pathSegmentsArray = [self.macSVGDocumentWindowController.svgWebKitController
                buildPathSegmentsArrayWithPathString:dAttributeString];
    
        for (NSMutableDictionary * pathSegmentDictionary in pathSegmentsArray)
        {
            NSString * commandString = pathSegmentDictionary[@"command"];
            
            unichar commandCharacter = [commandString characterAtIndex:0];

            switch (commandCharacter)
            {
                case 'M':     // moveto
                {
                    NSString * xString = pathSegmentDictionary[@"x"];
                    CGFloat xFloat = xString.floatValue;
                    xFloat += deltaX;
                    NSString * newXString = [self allocFloatString:xFloat];
                    pathSegmentDictionary[@"x"] = newXString;

                    NSString * yString = pathSegmentDictionary[@"y"];
                    CGFloat yFloat = yString.floatValue;
                    yFloat += deltaY;
                    NSString * newYString = [self allocFloatString:yFloat];
                    pathSegmentDictionary[@"y"] = newYString;
                    break;    // no changes required
                }
                case 'm':     // moveto
                {
                    break;    // no changes required
                }
                
                case 'L':     // lineto
                {
                    NSString * xString = pathSegmentDictionary[@"x"];
                    CGFloat xFloat = xString.floatValue;
                    xFloat += deltaX;
                    NSString * newXString = [self allocFloatString:xFloat];
                    pathSegmentDictionary[@"x"] = newXString;

                    NSString * yString = pathSegmentDictionary[@"y"];
                    CGFloat yFloat = yString.floatValue;
                    yFloat += deltaY;
                    NSString * newYString = [self allocFloatString:yFloat];
                    pathSegmentDictionary[@"y"] = newYString;
                    break;
                }
                case 'l':     // lineto
                {
                    break;    // no changes required
                }

                case 'H':     // horizontal lineto
                {
                    NSString * xString = pathSegmentDictionary[@"x"];
                    CGFloat xFloat = xString.floatValue;
                    xFloat += deltaX;
                    NSString * newXString = [self allocFloatString:xFloat];
                    pathSegmentDictionary[@"x"] = newXString;
                    break;
                }
                case 'h':     // horizontal lineto
                {
                    break;    // no changes required
                }

                case 'V':     // vertical lineto
                {
                    NSString * yString = pathSegmentDictionary[@"y"];
                    CGFloat yFloat = yString.floatValue;
                    yFloat += deltaY;
                    NSString * newYString = [self allocFloatString:yFloat];
                    pathSegmentDictionary[@"y"] = newYString;
                    break;
                }
                case 'v':     // vertical lineto
                {
                    break;    // no changes required
                }

                case 'C':     // curveto
{
                    NSString * xString = pathSegmentDictionary[@"x"];
                    CGFloat xFloat = xString.floatValue;
                    xFloat += deltaX;
                    NSString * newXString = [self allocFloatString:xFloat];
                    pathSegmentDictionary[@"x"] = newXString;

                    NSString * yString = pathSegmentDictionary[@"y"];
                    CGFloat yFloat = yString.floatValue;
                    yFloat += deltaY;
                    NSString * newYString = [self allocFloatString:yFloat];
                    pathSegmentDictionary[@"y"] = newYString;

                    NSString * x1String = pathSegmentDictionary[@"x1"];
                    CGFloat x1Float = x1String.floatValue;
                    x1Float += deltaX;
                    NSString * newX1String = [self allocFloatString:x1Float];
                    pathSegmentDictionary[@"x1"] = newX1String;

                    NSString * y1String = pathSegmentDictionary[@"y1"];
                    CGFloat y1Float = y1String.floatValue;
                    y1Float += deltaY;
                    NSString * newY1String = [self allocFloatString:y1Float];
                    pathSegmentDictionary[@"y1"] = newY1String;

                    NSString * x2String = pathSegmentDictionary[@"x2"];
                    CGFloat x2Float = x2String.floatValue;
                    x2Float += deltaX;
                    NSString * newX2String = [self allocFloatString:x2Float];
                    pathSegmentDictionary[@"x2"] = newX2String;

                    NSString * y2String = pathSegmentDictionary[@"y2"];
                    CGFloat y2Float = y2String.floatValue;
                    y2Float += deltaY;
                    NSString * newY2String = [self allocFloatString:y2Float];
                    pathSegmentDictionary[@"y2"] = newY2String;
                    break;
                }
                case 'c':     // curveto
                {
                    break;    // no changes required
                }

                case 'S':     // smooth curveto
{
                    NSString * xString = pathSegmentDictionary[@"x"];
                    CGFloat xFloat = xString.floatValue;
                    xFloat += deltaX;
                    NSString * newXString = [self allocFloatString:xFloat];
                    pathSegmentDictionary[@"x"] = newXString;

                    NSString * yString = pathSegmentDictionary[@"y"];
                    CGFloat yFloat = yString.floatValue;
                    yFloat += deltaY;
                    NSString * newYString = [self allocFloatString:yFloat];
                    pathSegmentDictionary[@"y"] = newYString;

                    NSString * x2String = pathSegmentDictionary[@"x2"];
                    CGFloat x2Float = x2String.floatValue;
                    x2Float += deltaX;
                    NSString * newX2String = [self allocFloatString:x2Float];
                    pathSegmentDictionary[@"x2"] = newX2String;

                    NSString * y2String = pathSegmentDictionary[@"y2"];
                    CGFloat y2Float = y2String.floatValue;
                    y2Float += deltaY;
                    NSString * newY2String = [self allocFloatString:y2Float];
                    pathSegmentDictionary[@"y2"] = newY2String;
                    break;
                }
                case 's':     // smooth curveto
                {
                    break;    // no changes required
                }

                case 'Q':     // quadratic Bezier curve
                {
                    NSString * xString = pathSegmentDictionary[@"x"];
                    CGFloat xFloat = xString.floatValue;
                    xFloat += deltaX;
                    NSString * newXString = [self allocFloatString:xFloat];
                    pathSegmentDictionary[@"x"] = newXString;

                    NSString * yString = pathSegmentDictionary[@"y"];
                    CGFloat yFloat = yString.floatValue;
                    yFloat += deltaY;
                    NSString * newYString = [self allocFloatString:yFloat];
                    pathSegmentDictionary[@"y"] = newYString;

                    NSString * x1String = pathSegmentDictionary[@"x1"];
                    CGFloat x1Float = x1String.floatValue;
                    x1Float += deltaX;
                    NSString * newX1String = [self allocFloatString:x1Float];
                    pathSegmentDictionary[@"x1"] = newX1String;

                    NSString * y1String = pathSegmentDictionary[@"y1"];
                    CGFloat y1Float = y1String.floatValue;
                    y1Float += deltaY;
                    NSString * newY1String = [self allocFloatString:y1Float];
                    pathSegmentDictionary[@"y1"] = newY1String;
                    break;
                }
                case 'q':     // quadratic Bezier curve
                {
                    break;    // no changes required
                }

                case 'T':     // smooth quadratic Bezier curve
                {
                    NSString * xString = pathSegmentDictionary[@"x"];
                    CGFloat xFloat = xString.floatValue;
                    xFloat += deltaX;
                    NSString * newXString = [self allocFloatString:xFloat];
                    pathSegmentDictionary[@"x"] = newXString;

                    NSString * yString = pathSegmentDictionary[@"y"];
                    CGFloat yFloat = yString.floatValue;
                    yFloat += deltaY;
                    NSString * newYString = [self allocFloatString:yFloat];
                    pathSegmentDictionary[@"y"] = newYString;
                    break;
                }

                case 't':     // smooth quadratic Bezier curve
                {
                    break;    // no changes required
                }

                case 'A':     // elliptical arc
                {
                    NSString * xString = pathSegmentDictionary[@"x"];
                    CGFloat xFloat = xString.floatValue;
                    xFloat += deltaX;
                    NSString * newXString = [self allocFloatString:xFloat];
                    pathSegmentDictionary[@"x"] = newXString;

                    NSString * yString = pathSegmentDictionary[@"y"];
                    CGFloat yFloat = yString.floatValue;
                    yFloat += deltaY;
                    NSString * newYString = [self allocFloatString:yFloat];
                    pathSegmentDictionary[@"y"] = newYString;
                    break;
                }

                case 'a':     // elliptical arc
                {
                    break;    // no changes required
                }

                case 'Z':     // closepath
                case 'z':     // closepath
                    break;
            }
        }

    NSString * newDAttributeString =
            [self.macSVGDocumentWindowController.svgWebKitController.domMouseEventsController.svgPathEditor buildPathStringWithPathSegmentsArray:pathSegmentsArray];
    
    dAttributeNode.stringValue = newDAttributeString;
    
    [aDOMElement setAttribute:@"d" value:newDAttributeString];
}

@end

// ================================================================
// ================================================================
// ================================================================


@implementation XMLOutlineController(Private)

// ================================================================
//  NSOutlineView data source methods. (The required ones)
// ================================================================

// The NSOutlineView uses 'nil' to indicate the root item. We return our root tree node for that case.
- (NSArray *)childrenForItem:(id)item 
{
    id result = nil;
    if (item == nil) 
    {
		MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
        NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;
        NSXMLElement * rootElement = [svgXmlDocument rootElement];
        result = rootElement.children;
    } 
    else 
    {
        result = [item children];
    }
    return result;
}

// ================================================================

// Required methods. 
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item 
{
    // 'item' may potentially be nil for the root item.
    NSXMLNode * nodeItem = item;
    NSArray * children = NULL;
        
    if (item == NULL)
    {
        // NULL item represent outline root, return the root element from XML document
        MacSVGDocument * macSVGDocument = self.macSVGDocumentWindowController.document;
        NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;
        nodeItem = [svgXmlDocument rootElement];
        
        children = @[nodeItem];
    }
    else
    {
        children = [self childrenForItem:nodeItem];
    }    
    
    // return NSXMLNode 
    return children[index];
}

// ================================================================

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item 
{
    BOOL result = NO;
    
    /*
    unsigned long childCount = [item childCount];
    if (childCount > 0)
    {
        result = YES;
    }
    */
    
    //if ([item isKindOfClass:[NSXMLElement class]])
    
    NSXMLNode * nodeItem = item;
    if (nodeItem.kind == NSXMLElementKind)
    {
        result = YES;
    }
    
    return result;
}

// ================================================================

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item 
{
    // 'item' may potentially be nil for the root item.
    unsigned long childCount = 0;

    if (item == NULL) 
    {
        childCount = 1;
    }
    else
    {
        childCount = [item childCount];
    }

    return childCount;
}

//==================================================================================
//	outlineView:objectValueForTableColumn:byItem:
//==================================================================================

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item 
{
    id objectValue = nil;
    
    if (item == NULL)
    {
        // The return value from this method is used to configure the state of the items cell via setObjectValue:
        if ((tableColumn == nil) || [tableColumn.identifier isEqualToString:COLUMNID_ELEMENT_NAME]) 
        {
            objectValue = @"svg";
        } 
        else if ([tableColumn.identifier isEqualToString:COLUMNID_IS_VISIBLE]) 
        {
            // set the state of a check box.
            objectValue = @YES;
        } 
        else if ([tableColumn.identifier isEqualToString:COLUMNID_IS_LOCKED])
        {
            // set the state of the check box.
            objectValue = @NO;
        }
        else if ([tableColumn.identifier isEqualToString:COLUMNID_ICON]) 
        {
            //NSImage * iconImage = [NSImage imageNamed:@"folder.png"];
            
            //objectValue = iconImage;
            
            objectValue = @0;
        }
    }
    else
    {
        NSXMLNode * nodeData = item;
        NSXMLNodeKind nodeKind = nodeData.kind;
        
        // The return value from this method is used to configure the state of the items cell via setObjectValue:
        if ((tableColumn == nil) || [tableColumn.identifier isEqualToString:COLUMNID_ELEMENT_NAME]) 
        {
            if (nodeKind ==  NSXMLElementKind)
            {
                NSString * elementName = nodeData.localName;
                NSString * idString = @"";
                NSXMLElement * elementItem = item;
                NSXMLNode * idNode = [elementItem attributeForName:@"id"];
                if (idNode != NULL)
                {
                    NSString * idValue = idNode.stringValue;
                    idString = [NSString stringWithFormat:@"id=\"%@\"", idValue];
                }
                objectValue = [NSString stringWithFormat:@"%@ %@", elementName, idString];
            }
            else if (nodeKind ==  NSXMLTextKind)
            {
                NSString * stringValue = nodeData.stringValue;
                NSString * trimmedValue = [stringValue stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                objectValue = [NSString stringWithFormat:@"\"%@\"", trimmedValue];
            }
            else if (nodeKind ==  NSXMLCommentKind)
            {
                NSString * stringValue = nodeData.stringValue;
                NSString * trimmedValue = [stringValue stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                objectValue = [NSString stringWithFormat:@"\"%@\"", trimmedValue];
            }
        } 
        else if ([tableColumn.identifier isEqualToString:COLUMNID_IS_VISIBLE]) 
        {
            // Here, object value will be used to set the state of a check box.
            BOOL visibility = YES;

            if (nodeKind ==  NSXMLElementKind)
            {
                NSXMLElement * rowElement = (id)nodeData;
                NSXMLNode * visibilityAttributeNode = [rowElement attributeForName:@"visibility"];
                NSString * visibilityAttributeString = visibilityAttributeNode.stringValue;
                if (visibilityAttributeString != NULL)
                {
                    if ([visibilityAttributeString isEqualToString:@"hidden"])
                    {
                        visibility = NO;
                    }
                }
                
                if (draggingOutlineItems == NO)
                {
                    if (self.draggingActive == NO)
                    {
                        // Update the visibility checkboxes in child NSXMLNodes to match parent
                        // don't perform this part if dragging is active
                        // due to reloadItem: call will cancel dragging
                        NSArray * childNodes = rowElement.children;
                        for (NSXMLNode * aChildNode in childNodes)
                        {
                            NSXMLNodeKind childNodeKind = aChildNode.kind;
                            
                            if (childNodeKind != NSXMLElementKind)
                            {
                                NSInteger childRow = [self.xmlOutlineView rowForItem:aChildNode];
                                
                                if (childRow > -1)
                                {
                                    [self.xmlOutlineView reloadItem:aChildNode];
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                NSXMLNode * parentNode = nodeData.parent;
                NSXMLNodeKind parentNodeKind = parentNode.kind;
                if (parentNodeKind == NSXMLElementKind)
                {
                    NSXMLElement * parentElement = (NSXMLElement *)parentNode;
                    NSXMLNode * parentVisibilityAttributeNode = [parentElement attributeForName:@"visibility"];
                    NSString * parentVisibilityAttributeString = parentVisibilityAttributeNode.stringValue;
                    if (parentVisibilityAttributeString != NULL)
                    {
                        if ([parentVisibilityAttributeString isEqualToString:@"hidden"])
                        {
                            visibility = NO;
                        }
                    }
                }
            }

            objectValue = @(visibility);
        } 
        else if ([tableColumn.identifier isEqualToString:COLUMNID_IS_LOCKED])
        {
            // Again -- this object value will set the state of the check box.
            objectValue = @NO;
        }
        else if ([tableColumn.identifier isEqualToString:COLUMNID_ICON]) 
        {
            // Again -- this object value will set the state of the check box.
            NSXMLNode * nodeData = item;
            NSXMLNodeKind nodeKind = nodeData.kind;
            
            //NSImage * iconImage = NULL;
            
            if (nodeKind == NSXMLTextKind)
            {
                //iconImage = [NSImage imageNamed:@"texticon.png"];

                objectValue = @2;
            }
            else if (nodeKind == NSXMLCommentKind)
            {
                //iconImage = [NSImage imageNamed:@"texticon.png"];

                objectValue = @2;
            }
            else
            {
                NSArray * selectedItems = [self.xmlOutlineView selectedItems];
                if (selectedItems.count > 0)
                {
                    NSXMLNode * firstSelectedItem = selectedItems[0];
                    
                    if (firstSelectedItem == nodeData)
                    {
                        //iconImage = [NSImage imageNamed:@"target.png"];

                        objectValue = @1;
                    }
                    else
                    {
                        //iconImage = [NSImage imageNamed:@"folder.png"];

                        objectValue = @0;
                    }
                }
                else
                {
                    //iconImage = [NSImage imageNamed:@"folder.png"];

                    objectValue = @0;
                }
            }
            
            //objectValue = iconImage;
        }
    }
    
    return objectValue;
}

//==================================================================================
//	outlineView:willDisplayCell:forTableColumn:item:
//==================================================================================

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(NSCell *)cell 
        forTableColumn:(NSTableColumn *)tableColumn item:(id)item 
{ 
    // If ImageAnTextCell class used, set image here

    if ([tableColumn.identifier isEqualToString:COLUMNID_IS_VISIBLE])
    {
        BOOL checkboxVisibility = YES;
        
        NSXMLNode * xmlNode = item;
        
        NSXMLNodeKind nodeKind = xmlNode.kind;
        
        if (nodeKind == NSXMLTextKind)
        {
             checkboxVisibility = NO;
        }
        if (nodeKind == NSXMLCommentKind)
        {
             checkboxVisibility = NO;
        }

        cell.enabled = checkboxVisibility;
    }
}

//==================================================================================
//	outlineView:shouldSelectItem:
//==================================================================================

//- (BOOL)outlineView:(NSOutlineView *)ov shouldSelectItem:(id)item

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    NSLog(@"shouldSelectItem");
    
    // Control selection of a particular item. 
    BOOL result = YES;
    NSInteger clickedCol = (self.xmlOutlineView).clickedColumn;
    NSInteger clickedRow = (self.xmlOutlineView).clickedRow;
    if (clickedRow >= 0 && clickedCol >= 0) 
    {
        NSCell * cell = [self.xmlOutlineView preparedCellAtColumn:clickedCol row:clickedRow];
        if ([cell isKindOfClass:[NSButtonCell class]] && cell.enabled)
        {
            result = NO;
        }            
    }
    return result;
}

//==================================================================================
//	selectionShouldChangeInOutlineView:
//==================================================================================

- (BOOL)selectionShouldChangeInOutlineView:(NSOutlineView *)outlineView;
{
    return YES;
}

//==================================================================================
//	outlineView:shouldTrackCell:forTableColumn:item:
//==================================================================================

- (BOOL)outlineView:(NSOutlineView *)ov shouldTrackCell:(NSCell *)cell 
        forTableColumn:(NSTableColumn *)tableColumn item:(id)item 
{
    //NSLog(@"XMLOutlineController - shouldTrackCell");
    // We want to allow tracking for all the button cells, even if we don't allow selecting that particular row.
    BOOL result = YES;
    
    NSInteger rowIdx = [self.xmlOutlineView rowForItem:item];

    if (rowIdx != -1)
    {
        if ([cell isKindOfClass:[NSButtonCell class]]) 
        {
            // We can also take a peek and make sure that the part of the cell clicked is an area that is normally tracked. Otherwise, clicking outside of the checkbox may make it check the checkbox
            
            NSRect cellFrame = [self.xmlOutlineView frameOfCellAtColumn:[(self.xmlOutlineView).tableColumns 
                    indexOfObject:tableColumn] row:rowIdx];
            NSUInteger hitTestResult = [cell hitTestForEvent:NSApp.currentEvent inRect:cellFrame ofView:self.xmlOutlineView];
            if ((hitTestResult & NSCellHitTrackableArea) != 0) 
            {
                result = YES;
            } 
            else 
            {
                result = NO;
            }
        }
        else 
        {
            // Only allow tracking on selected rows. This is what NSTableView does by default.
            result = [self.xmlOutlineView isRowSelected:rowIdx];
        }
    }
    else
    {
        result = NO;
    }
    
    return result;
}

//==================================================================================
//	outlineView:didClickTableColumn:
//==================================================================================

- (void)outlineView:(NSOutlineView *)outlineView didClickTableColumn:(NSTableColumn *)tableColumn
{

}

//==================================================================================
//	GenerateUniqueFileNameAtPath()
//==================================================================================

static NSString * GenerateUniqueFileNameAtPath(NSString *path, NSString *basename, NSString *extension) 
{
    NSLog(@"XMLOutlineController - GenerateUniqueFileNameAtPath");
    NSString *filename = [NSString stringWithFormat:@"%@.%@", basename, extension];
    NSString *result = [path stringByAppendingPathComponent:filename];
    NSInteger i = 1;
    while ([[NSFileManager defaultManager] fileExistsAtPath:result]) 
    {
        filename = [NSString stringWithFormat:@"%@ %ld.%@", basename, (long)i, extension];
        result = [path stringByAppendingPathComponent:filename];
        i++;
    }    
    return result;
}

//==================================================================================
//	outlineView:namesOfPromisedFilesDroppedAtDestination:forDraggedItems:
//==================================================================================

// We promised the files, so now lets make good on that promise!
- (NSArray *)outlineView:(NSOutlineView *)outlineView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedItems:(NSArray *)items 
{
    NSLog(@"XMLOutlineController - namesOfPromisedFilesDroppedAtDestination");
    NSMutableArray *result = [NSMutableArray array];
    
    for (NSInteger i = 0; i < items.count; i++) 
    {
        NSString *filepath  = GenerateUniqueFileNameAtPath(dropDestination.path, @"PromiseTestFile", @"txt");
        // We write out the tree node's description
        NSXMLNode *xmlNode = items[i];
        
        NSString *itemString = [xmlNode XMLStringWithOptions:NSXMLNodePreserveCDATA];
        
        NSError *error = nil;
        if (![itemString writeToURL:[NSURL fileURLWithPath:filepath] atomically:NO encoding:NSUTF8StringEncoding error:&error]) 
        {
            [NSApp presentError:error];
        }
    }
    return result;
}

//==================================================================================
//	outlineView:writeItems:toPasteboard:
//==================================================================================

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard 
{
    self.draggedNodes = items;

    // Provide data for our custom type, and simple NSStrings.
    [pboard declareTypes:@[XML_OUTLINE_PBOARD_TYPE, NSStringPboardType, NSFilesPromisePboardType] owner:self];

    // the actual data doesn't matter since XML_OUTLINE_PBOARD_TYPE drags aren't recognized by anyone but us!.
    [pboard setData:[NSData data] forType:XML_OUTLINE_PBOARD_TYPE]; 
    
    NSMutableString * nodesString = [NSMutableString string];
    for (NSXMLNode * aNode in items)
    {
        NSString * nodeXml = [aNode XMLStringWithOptions:NSXMLNodePreserveCDATA];
        [nodesString appendString:nodeXml];
    }
    [pboard setString:nodesString forType:NSStringPboardType];
            
    // Put the promised type we handle on the pasteboard.
    [pboard setPropertyList:@[@"txt"] forType:NSFilesPromisePboardType];

    return YES;
}

//==================================================================================
//	xmlNode:isDescendantOfNode:
//==================================================================================

- (BOOL)xmlNode:(NSXMLNode *)xmlNode isDescendantOfNode:(NSXMLNode *)parentNode 
{
    NSXMLNode * currentNode = (NSXMLElement *)xmlNode;
    while (currentNode != nil) 
    {
        if (currentNode == parentNode) 
        {
            return YES;
        }
        currentNode = currentNode.parent;
    }
    return NO;
}



//==================================================================================
//	outlineView:validateDrop:proposedItem:proposedChildIndex:
//==================================================================================

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info
        proposedItem:(id)item proposedChildIndex:(NSInteger)childIndex
{
    // Returns NSDragOperationNone if proposed drop is not valid.
    
    validatingDrop = YES;
    
    NSXMLNode * targetNode = item;
    NSInteger targetChildIndex = childIndex;

    NSDragOperation result = NSDragOperationNone;
    
    NSPasteboard * draggingPasteboard = [info draggingPasteboard];
    
    NSMutableArray * pasteboardTypesArray = [NSMutableArray array];
    
    NSArray * pasteboardItems = draggingPasteboard.pasteboardItems;
    for (NSPasteboardItem * aPasteboardItem in pasteboardItems)
    {
        NSArray * pasteboardTypes = aPasteboardItem.types;
        #pragma unused(pasteboardTypes)
        
        [pasteboardTypesArray addObjectsFromArray:pasteboardTypes];
    }

    id draggingSource = [info draggingSource];
    
    /*
    NSWindow * draggingDestinationWindow = [info draggingDestinationWindow];
    NSDragOperation draggingSourceOperationMask = [info draggingSourceOperationMask];
    NSInteger numberOfValidItemsForDrop = [info numberOfValidItemsForDrop];
    if (draggingSource == self.xmlOutlineView) 
    {
        if (self.xmlOutlineView.window == draggingDestinationWindow)
        {
            NSLog(@"draggingDestinationWindow is self");
        }
        else
        {
            NSLog(@"draggingDestinationWindow is %@", draggingDestinationWindow);
        }
    }
    NSLog(@"draggingSourceOperationMask = %ld", draggingSourceOperationMask);
    NSLog(@"numberOfValidItemsForDrop = %ld", numberOfValidItemsForDrop);
    */

    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
    NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;
    NSXMLElement * rootElement = [svgXmlDocument rootElement];

    // Check to see what we are proposed to be dropping on
    
    // A target of "nil" means we are on the main root tree
    if (targetNode == nil) 
    {
        targetNode = rootElement;
    }
    
    //NSLog(@"enter validateDrop - proposedParentTagName = %@", proposedParentTagName);

    NSUInteger targetNodeKind = targetNode.kind;

    BOOL destinationIsBetweenItems = NO;
    if (targetNodeKind == NSXMLElementKind)
    {
        if (targetChildIndex != NSOutlineViewDropOnItemIndex)
        {
            // Allow drop between items
            destinationIsBetweenItems = YES;
        }
        else
        {
            NSXMLNode * targetParent = targetNode.parent;
            
            NSInteger newTargetChildIndex = targetNode.index + 1;
            
            targetNode = targetParent;
            targetChildIndex = newTargetChildIndex;

            destinationIsBetweenItems = YES;
        }
    }
    else
    {
        NSXMLNode * targetParent = targetNode.parent;
        NSXMLNode * targetGrandparent = targetParent.parent;
        
        NSInteger newTargetChildIndex = targetParent.index + 1;
    
        targetNode = targetGrandparent;
        targetChildIndex = newTargetChildIndex;

        destinationIsBetweenItems = YES;
    }

    
    // Refuse drops into a descendent item
    BOOL destinationIsDescendent = NO;
        
    if (draggingSource == self.xmlOutlineView) 
    {
        // Drag is originating from ourselves
        NSString * availableType = [draggingPasteboard
                availableTypeFromArray:@[XML_OUTLINE_PBOARD_TYPE]];
        
        if ((targetNode != rootElement) && (availableType != nil)) 
        {
            for (NSXMLNode * draggedNode in self.draggedNodes)
            {
                if ([self xmlNode:targetNode isDescendantOfNode:draggedNode]) 
                {
                    destinationIsDescendent = YES;   // cancel drag to descendent
                    break;
                }
            }
        }
    }

    NSArray * sourceNodes = nil;
    
    if ((destinationIsDescendent == NO) && (destinationIsBetweenItems == YES))
    {
        NSString * xmlString = NULL;
        NSString * pasteboardType = NULL;
        
        NSArray * pboardArray  = @[XML_OUTLINE_PBOARD_TYPE];
        NSString * availableType = [draggingPasteboard availableTypeFromArray:pboardArray];

        if ((draggingSource == self.xmlOutlineView) && (availableType != NULL))
        {
            sourceNodes = self.draggedNodes;     // Drag is originating from ourselves, nodes are ready to insert
            
            result = NSDragOperationMove;
        } 
        else 
        {
            // Check for several types of pasteboard data, convert to XML string, then create nodes for insertion
        
            // Try for an pasteboard string, possibly an XML string
            pboardArray  = @[NSStringPboardType];
            availableType = [draggingPasteboard availableTypeFromArray:pboardArray];
            NSString * pasteboardString = [draggingPasteboard stringForType:NSStringPboardType];

            if (availableType != NULL)
            {
                if (pasteboardString != NULL)
                {
                    NSRange tagRange = [pasteboardString rangeOfString:@"<"];
                    if (tagRange.location == 0)
                    {
                        if ([pasteboardString isEqualToString:@"<nil>"] == NO)
                        {
                            xmlString = pasteboardString;   // probably XML?
                            pasteboardType = NSStringPboardType;
                        }
                    }
                }
            }
            
            if (xmlString == NULL)
            {
                // Try for a URL reference to an image or TrueType font
                NSRange httpSchemeRange = [pasteboardString rangeOfString:@"http"];
                if (httpSchemeRange.location == 0)
                {
                    id urlPropertyList = [draggingPasteboard propertyListForType:NSURLPboardType];
                    
                    if ([urlPropertyList isKindOfClass:[NSArray class]] == YES)
                    {
                        NSArray * urlPropertyArray = (NSArray *)urlPropertyList;
                    
                        NSString * urlString = NULL;
                        
                        for (NSString * aURLString in urlPropertyArray)
                        {
                            // accept the first valid URL
                            NSURL * aURL = [NSURL URLWithString:aURLString];
                            if (aURL != NULL)
                            {
                                urlString = aURLString;
                                break;
                            }

                            aURL = [NSURL fileURLWithPath:aURLString];
                            if (aURL != NULL)
                            {
                                urlString = aURLString;
                                break;
                            }
                        }
                        
                        if (urlString != NULL)
                        {
                            NSString * filename  = urlString.lastPathComponent;
                            
                            if (filename != nil) 
                            {
                                NSUInteger filenameLength = filename.length;
                                
                                NSRange suffixRange = [filename rangeOfString:@".svg"];
                                if (suffixRange.location == filenameLength - 4)
                                {
                                    xmlString = @"<svg />";
                                    pasteboardType = NSURLPboardType;
                                }
                                
                                if (xmlString == NULL)
                                {
                                    suffixRange = [filename rangeOfString:@".jpg"];
                                    if (suffixRange.location == filenameLength - 4)
                                    {
                                        xmlString = @"<image />";
                                        pasteboardType = NSURLPboardType;
                                    }
                                }
                                
                                if (xmlString == NULL)
                                {
                                    suffixRange = [filename rangeOfString:@".jpeg"];
                                    if (suffixRange.location == filenameLength - 5)
                                    {
                                        xmlString = @"<image />";
                                        pasteboardType = NSURLPboardType;
                                    }
                                }
                                
                                if (xmlString == NULL)
                                {
                                    suffixRange = [filename rangeOfString:@".png"];
                                    if (suffixRange.location == filenameLength - 4)
                                    {
                                        xmlString = @"<image />";
                                        pasteboardType = NSURLPboardType;
                                    }
                                }
                                
                                if (xmlString == NULL)
                                {
                                    suffixRange = [filename rangeOfString:@".ttf"];
                                    if (suffixRange.location == filenameLength - 4)
                                    {
                                        xmlString = @"<font-face />";
                                        pasteboardType = NSURLPboardType;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if (xmlString == nil) 
            {
                // Try for an array of URL references to images or TrueType fonts
                NSArray * pboardArray  = @[NSURLPboardType];
                NSString * availableType = [draggingPasteboard availableTypeFromArray:pboardArray];

                if (availableType != NULL)
                {
                    NSString * filepath = [[draggingPasteboard propertyListForType:NSURLPboardType] lastObject];
                    NSString * filename = filepath.lastPathComponent;
                        
                    if (filename != nil) 
                    {
                        NSUInteger filenameLength = filename.length;
                        
                        NSRange suffixRange = [filename rangeOfString:@".svg"];
                        if (suffixRange.location == filenameLength - 4)
                        {
                            xmlString = @"<svg />";
                            pasteboardType = NSURLPboardType;
                        }
                        
                        if (xmlString == NULL)
                        {
                            suffixRange = [filename rangeOfString:@".jpg"];
                            if (suffixRange.location == filenameLength - 4)
                            {
                                xmlString = @"<image />";
                                pasteboardType = NSURLPboardType;
                            }
                        }
                        
                        if (xmlString == NULL)
                        {
                            suffixRange = [filename rangeOfString:@".jpeg"];
                            if (suffixRange.location == filenameLength - 5)
                            {
                                xmlString = @"<image />";
                                pasteboardType = NSURLPboardType;
                            }
                        }
                        
                        if (xmlString == NULL)
                        {
                            suffixRange = [filename rangeOfString:@".png"];
                            if (suffixRange.location == filenameLength - 4)
                            {
                                xmlString = @"<image />";
                                pasteboardType = NSURLPboardType;
                            }
                        }
                        
                        if (xmlString == NULL)
                        {
                            suffixRange = [filename rangeOfString:@".ttf"];
                            if (suffixRange.location == filenameLength - 4)
                            {
                                xmlString = @"<font-face />";
                                pasteboardType = NSURLPboardType;
                            }
                        }
                    }
                }
            }
            
            if (xmlString == nil) 
            {
                // Try for an array of filenames, perhaps dragged from finder, so we just grab one.
                pboardArray  = @[NSFilenamesPboardType];
                availableType = [draggingPasteboard availableTypeFromArray:pboardArray];

                if (availableType != NULL)
                {
                    NSString * filepath = [[draggingPasteboard propertyListForType:NSFilenamesPboardType] lastObject];
                    NSString * filename = filepath.lastPathComponent;
                        
                    if (filename != nil) 
                    {
                        NSUInteger filenameLength = filename.length;
                        
                        NSRange suffixRange = [filename rangeOfString:@".svg"];
                        if (suffixRange.location == filenameLength - 4)
                        {
                            xmlString = @"<svg />";
                            pasteboardType = NSURLPboardType;
                        }
                        
                        if (xmlString == NULL)
                        {
                            suffixRange = [filename rangeOfString:@".jpg"];
                            if (suffixRange.location == filenameLength - 4)
                            {
                                xmlString = @"<image />";
                                pasteboardType = NSURLPboardType;
                            }
                        }
                        
                        if (xmlString == NULL)
                        {
                            suffixRange = [filename rangeOfString:@".jpeg"];
                            if (suffixRange.location == filenameLength - 5)
                            {
                                xmlString = @"<image />";
                                pasteboardType = NSURLPboardType;
                            }
                        }
                        
                        if (xmlString == NULL)
                        {
                            suffixRange = [filename rangeOfString:@".png"];
                            if (suffixRange.location == filenameLength - 4)
                            {
                                xmlString = @"<image />";
                                pasteboardType = NSURLPboardType;
                            }
                        }
                        
                        if (xmlString == NULL)
                        {
                            suffixRange = [filename rangeOfString:@".ttf"];
                            if (suffixRange.location == filenameLength - 4)
                            {
                                xmlString = @"<font-face />";
                                pasteboardType = NSURLPboardType;
                            }
                        }
                    }
                }
            }
                
            if (xmlString == nil) 
            {
                // Try for a TIFF image on the pasteboard, typically dragged from another app like a web browser window
                pboardArray  = @[NSTIFFPboardType];
                availableType = [draggingPasteboard availableTypeFromArray:pboardArray];

                if (availableType != NULL)
                {
                    pasteboardType = NSTIFFPboardType;
                    xmlString = @"<image />";
                }              
            }
            
            if (xmlString == nil) 
            {
                pasteboardType = NULL;
            }

            // checks for all pasteboard types done, now convert XML string to nodes ready for insertion 
            if (xmlString != NULL)
            {
                // Create a temporary XML document with the dragged object and namespace declarations

                NSError * docError = NULL;

                NSString * headerString = [macSVGDocument svgHeaderString];

                NSString * footerString = @"</svg>";
                
                NSString * xmlDocString = [[NSString alloc] initWithFormat:@"%@%@%@", headerString, xmlString, footerString];
                
                NSXMLDocument * tempDocument = [[NSXMLDocument alloc] initWithXMLString:xmlDocString options:0 error:&docError];
                
                NSXMLElement * rootElement = [tempDocument rootElement];
                
                // retrieve the dragged nodes
                NSXMLElement * newNode = (id)[rootElement childAtIndex:0];

                [newNode detach];
                
                /*
                NSError * xmlError = NULL;
                NSXMLElement * newNode = [[NSXMLElement alloc] initWithXMLString:xmlString error:&xmlError];
                */
                
                [macSVGDocument assignNewMacsvgidsForNode:newNode];
                        
                // Finally, add it to the array of dragged items to insert
                sourceNodes = @[newNode];
            }
        }
    }
    
    
    //BOOL checkDTDRules = YES;
    BOOL checkDTDRules = toolSettingsPopoverViewController.validateElementPlacement;

    CGEventRef event = CGEventCreate(NULL);
    CGEventFlags modifiers = CGEventGetFlags(event);
    CFRelease(event);
    CGEventFlags flags = (kCGEventFlagMaskAlternate);
    
    if ((modifiers & flags) != 0)
    {
        checkDTDRules = NO;
    }
   
    if (sourceNodes != NULL)
    {
        result = NSDragOperationGeneric;
        
        if (checkDTDRules == YES)
        {
            MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)NSApp.delegate;
            SVGDTDData * svgDtdData = macSVGAppDelegate.svgDtdData;
            NSDictionary * elementContentsDictionary = svgDtdData.elementContentsDictionary;

            NSString * proposedParentTagName = targetNode.name;
            
            for (NSXMLNode * aNode in sourceNodes) 
            {
                NSString * sourceTagName = aNode.name;
                
                NSDictionary * allowedChildrenDictionary = elementContentsDictionary[proposedParentTagName];
                NSDictionary * childTagDictionary = allowedChildrenDictionary[sourceTagName];
                
                if (childTagDictionary == NULL)
                {
                    // matching tag not found in allowedChildrenDictionary, disallow the drop
                    result = NSDragOperationNone;
                    break;
                }
            }
        }
    }
    
    [self.xmlOutlineView setDropItem:targetNode dropChildIndex:targetChildIndex];
    
    if (result != NSDragOperationNone)
    {
        //NSLog(@"validateDrop result NSDragOperation %ld", result);
    }

    /*
    if ([targetNode kind] == NSXMLElementKind)
    {
        NSString * targetTagName = [(NSXMLElement *)targetNode name];
        NSXMLNode * idAttributeNode = [(NSXMLElement *)targetNode attributeForName:@"id"];
        NSString * idString = [idAttributeNode stringValue];
        NSLog(@"NSDragOperation:%ld - element:%@ %@ - childIndex:%ld", result, targetTagName, idString, targetChildIndex);
    }
    else
    {
        NSLog(@"NSDragOperation:%ld - node:%@ - childIndex:%ld", result, targetNode , targetChildIndex);
    }
    */
    
    validatingDrop = NO;
    
    return result;
}

//==================================================================================
//	outlineView:draggingSession:willBeginAtPoint:forItems:
//==================================================================================

- (void)outlineView:(NSOutlineView *)outlineView
    draggingSession:(NSDraggingSession *)session
   willBeginAtPoint:(NSPoint)screenPoint
           forItems:(NSArray *)draggedItems
{
    draggingOutlineItems = YES;
}

//==================================================================================
//	outlineView:draggingSession:endedAtPoint:operation:
//==================================================================================

- (void)outlineView:(NSOutlineView *)outlineView
    draggingSession:(NSDraggingSession *)session
       endedAtPoint:(NSPoint)screenPoint
          operation:(NSDragOperation)operation
{
    draggingOutlineItems = NO;
}

//==================================================================================
//	outlineView:heightOfRowByItem:
//==================================================================================

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    return 15;
}

//==================================================================================
//	outlineView:acceptDrop:item:childIndex:
//==================================================================================

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info
        item:(id)item childIndex:(NSInteger)index
{
    acceptingDrop = YES;
    
    MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
    
    [macSVGDocument pushUndoRedoDocumentChanges];

    id draggingSource = [info draggingSource];
    NSPasteboard * draggingPasteboard = [info draggingPasteboard];
    //NSArray * pasteboardItems = [draggingPasteboard pasteboardItems];
    
    if (draggingSource == self.macSVGDocumentWindowController.svgElementsTableController.elementsTableView)
    {
        NSString * pasteboardString = [draggingPasteboard stringForType:NSStringPboardType];
        
        NSString * elementString = [self customizeElementPrototype:pasteboardString forParentElement:item];
        
        [draggingPasteboard setString:elementString forType:NSStringPboardType];
    }
    
    //NSArray * pboardArray  = [NSArray arrayWithObject:XML_OUTLINE_PBOARD_TYPE];
    //NSString * availableType = [draggingPasteboard availableTypeFromArray:pboardArray];
    
    BOOL result = [macSVGDocument dropElementsToXmlDocument:info
            item:item childIndex:index];
    
    acceptingDrop = NO;
    
    NSMutableIndexSet * reselectIndexSet = [NSMutableIndexSet indexSet];
    for (NSXMLNode * aXMLNode in macSVGDocument.insertedXMLNodes)
    {
        //NSInteger itemIndex = [self.macSVGDocumentWindowController.xmlOutlineController.xmlOutlineView
        //        rowForItem:aXMLNode];
        //[reselectIndexSet addIndex:itemIndex];
        
        [self recursiveAddIndex:reselectIndexSet forXMLNode:aXMLNode];
    }
    [self.macSVGDocumentWindowController.xmlOutlineController.xmlOutlineView
            selectRowIndexes:reselectIndexSet byExtendingSelection:NO];
    
    macSVGDocument.insertedXMLNodes = NULL;
    
    return result;
}

//==================================================================================
//	recursiveAddIndex:forXMLNode:
//==================================================================================

- (void)recursiveAddIndex:(NSMutableIndexSet *)indexSet forXMLNode:(NSXMLNode *)aXMLNode
{
    NSInteger itemIndex = [self.macSVGDocumentWindowController.xmlOutlineController.xmlOutlineView
            rowForItem:aXMLNode];
    [indexSet addIndex:itemIndex];

    NSArray * childNodesArray = aXMLNode.children;
    for (NSXMLNode * aChildNode in childNodesArray)
    {
        [self recursiveAddIndex:indexSet forXMLNode:aChildNode];
    }
}

//==================================================================================
//	outlineViewItemDidCollapse:
//==================================================================================

- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
    //NSLog(@"outlineViewItemDidCollapse");
}

//==================================================================================
//	outlineViewItemDidExpand:
//==================================================================================

- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
    //NSLog(@"outlineViewItemDidExpand");
}

//==================================================================================
//	outlineViewItemWillCollapse:
//==================================================================================

- (void)outlineViewItemWillCollapse:(NSNotification *)notification
{
    //NSLog(@"outlineViewItemWillCollapse");
}

//==================================================================================
//	outlineViewItemWillExpand:
//==================================================================================

- (void)outlineViewItemWillExpand:(NSNotification *)notification
{
    //NSLog(@"outlineViewItemWillExpand");
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)outlineViewSelectionDidChange:(NSNotification *)aNotification
{
	id aOutlineView = aNotification.object;
	if (aOutlineView == self.xmlOutlineView)
	{
        if (self.macSVGDocumentWindowController.creatingNewElement == NO)
        {
            [self.macSVGDocumentWindowController endPolylineDrawing];
            [self.macSVGDocumentWindowController endPathDrawing];
            //[self.macSVGDocumentWindowController endLineDrawing];
        }
        
        // moved from outlineViewAction
        // Usually a click to select an element or node
        NSArray * selectedNodes = [self selectedNodes];
        unsigned long selectedNodesCount = selectedNodes.count;

        if (selectedNodesCount > 1) 
        {
            // select first element
            [self.macSVGDocumentWindowController.svgXMLDOMSelectionManager
                    setSelectedXMLElements:selectedNodes];

            // update attributes table view
            //id selectedNode = [selectedNodes objectAtIndex:0];
            NSXMLNode * selectedNode = selectedNodes[0];
            
            NSString * context = @"element";
            NSXMLNodeKind selectedNodeKind = selectedNode.kind;
            if (selectedNodeKind == NSXMLTextKind)
            {
                selectedNode = selectedNode.parent;
                context = @"text";
            }
            [self.macSVGDocumentWindowController setAttributesForXMLNode:selectedNode];
            
            NSString * elementName = selectedNode.name;

            //[self selectElement:selectedNode];

            [self.macSVGDocumentWindowController.editorUIFrameController
                    setValidEditorsForXMLNode:selectedNode
                    elementName:elementName
                    attributeName:NULL context:context];

        }
        else if (selectedNodesCount == 1) 
        {
            // select one element
            [self.macSVGDocumentWindowController.svgXMLDOMSelectionManager
                    setSelectedXMLElements:selectedNodes];

            // update attributes table view
            NSXMLNode * selectedNode = selectedNodes[0];

            NSString * context = @"element";
            NSXMLNodeKind selectedNodeKind = selectedNode.kind;
            if (selectedNodeKind == NSXMLTextKind)
            {
                selectedNode = selectedNode.parent;
                context = @"text";
            }
            
            [self.macSVGDocumentWindowController setAttributesForXMLNode:selectedNode];

            NSString * elementName = selectedNode.name;

            //[self selectElement:selectedNode];

            [self.macSVGDocumentWindowController.editorUIFrameController
                    setValidEditorsForXMLNode:selectedNode
                    elementName:elementName
                    attributeName:NULL context:context];
            
            if (self.macSVGDocumentWindowController.currentToolMode == toolModeCrosshairCursor)
            {
                if ([elementName isEqualToString:@"path"] == YES)
                {
                    [self.macSVGDocumentWindowController.svgWebKitController.domMouseEventsController
                            handleCrosshairToolSelectionForPathXMLElement:(NSXMLElement *)selectedNode
                            handleDOMElement:NULL];
                }
                else if ([elementName isEqualToString:@"polyline"] == YES)
                {
                    [self.macSVGDocumentWindowController.svgWebKitController.domMouseEventsController
                            handleCrosshairToolSelectionForPolylineXMLElement:(NSXMLElement *)selectedNode
                            handleDOMElement:NULL];
                }
                else if ([elementName isEqualToString:@"polygon"] == YES)
                {
                    [self.macSVGDocumentWindowController.svgWebKitController.domMouseEventsController
                            handleCrosshairToolSelectionForPolylineXMLElement:(NSXMLElement *)selectedNode
                            handleDOMElement:NULL];
                }
                else if ([elementName isEqualToString:@"line"] == YES)
                {
                    [self.macSVGDocumentWindowController.svgWebKitController.domMouseEventsController
                            handleCrosshairToolSelectionForLineXMLElement:(NSXMLElement *)selectedNode
                            handleDOMElement:NULL];
                }
            }
        }
        else 
        {
            // nothing selected
            [self.macSVGDocumentWindowController.svgXMLDOMSelectionManager
                    setSelectedXMLElements:selectedNodes];

            [self.macSVGDocumentWindowController setAttributesForXMLNode:NULL];

            [self.macSVGDocumentWindowController.editorUIFrameController
                    setValidEditorsForXMLNode:NULL
                    elementName:@""
                    attributeName:NULL context:@"disable"];
        }
	}
}


//==================================================================================
//	shouldCollapseAutoExpandedItemsForDeposited:
//==================================================================================

- (BOOL)shouldCollapseAutoExpandedItemsForDeposited:(BOOL)deposited
{
    return NO;
}

//==================================================================================
//	outlineView:shouldCollapseItem:
//==================================================================================

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
    BOOL result = YES;
    
    if ([outlineView rowForItem:item] != 0)
    {
        //result = NO;
    }

    if (draggingOutlineItems == YES)
    {
        result = NO;
    }

    if (validatingDrop == YES)
    {
        result = NO;
    }
    
    if (acceptingDrop == YES)
    {
        result = NO;
    }
    
    if (result == YES)
    {
        //NSLog(@"shouldCollapseItem YES");
    }
        
    return result;
}

//==================================================================================
//	outlineView:shouldExpandItem:
//==================================================================================

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item
{
    BOOL result = YES;
    
    if (draggingOutlineItems == YES)
    {
        result = [outlineView isItemExpanded:item];
    }
    
    if (validatingDrop == YES)
    {
        result = [outlineView isItemExpanded:item];
    }
    
    if (acceptingDrop == YES)
    {
        //result = [outlineView isItemExpanded:item];
        
        result = NO;
        
        MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
        NSMutableArray * insertedXMLNodes = macSVGDocument.insertedXMLNodes;
        for (NSXMLNode * aXMLNode in insertedXMLNodes)
        {
            NSXMLNode * parentNode = aXMLNode;
            while (parentNode != NULL)
            {
                if (item == parentNode)
                {
                    result = YES;
                    break;
                }
                
                parentNode = parentNode.parent;
            }
            
            if (result == YES)
            {
                break;
            }
        }
    }

    if (result == NO)
    {
        //NSLog(@"shouldExpandItem NO");
    }
    
    return result;
}

//==================================================================================
//	tableView:rowViewForRow:
//==================================================================================

// TODO: this is not working because the table view is still cell-based
// FIXME: this is not working because the table view is still cell-based
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    // Make the row view keep track of our main model object
    
    XMLOutlineRowView *result = [[XMLOutlineRowView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    
    return result;
}


@end
