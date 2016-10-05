//
//  XMLAttributesTableController.m
//  macSVG
//
//  Created by Douglas Ward on 9/20/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "XMLAttributesTableController.h"
#import "MacSVGDocumentWindowController.h"
#import "MacSVGDocument.h"
#import "SVGWebKitController.h"
#import "SVGPathEditor.h"
#import "SVGPolylineEditor.h"
#import "SVGLineEditor.h"
#import "DOMMouseEventsController.h"
#import "ValidAttributesController.h"
#import "EditorUIFrameController.h"
#import "ValidAttributesController.h"
#import "XMLAttributesTableView.h"

@interface XMLAttributesTableController()
@property (strong) NSXMLElement * currentXmlElementForAttributesTable;
@end

@implementation XMLAttributesTableController


//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.currentXmlElementForAttributesTable = NULL;
    self.xmlAttributesArray = NULL;
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
        self.currentXmlElementForAttributesTable = NULL;
        self.xmlAttributesArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

//==================================================================================
//	nameSort()
//==================================================================================

NSComparisonResult nameSort(id attribute1, id attribute2, void *context)
{
    NSString * name1 = attribute1[@"name"];
    NSString * name2 = attribute2[@"name"];

    return [name1 compare:name2];
}

//==================================================================================
//	abortEditing
//==================================================================================

- (void)abortEditing
{
    [self.xmlAttributesTableView abortEditing];
}

//==================================================================================
//	buildAttributesTableForElement
//==================================================================================

- (void)buildAttributesTableForElement
{
    //NSXMLNode * nodeObject = xmlElementForAttributes;
    //NSXMLNodeKind nodeKind = [nodeObject kind];
    [self abortEditing];
    
    if (self.currentXmlElementForAttributesTable == NULL)
    {
        NSIndexSet * emptyIndexSet = [NSIndexSet indexSet];
        [self.xmlAttributesTableView selectRowIndexes:emptyIndexSet byExtendingSelection:NO];

        [macSVGDocumentWindowController.editorUIFrameController.attributeEditorController reloadData];
        [macSVGDocumentWindowController.editorUIFrameController.textEditorController reloadData];
    }
    
    NSMutableArray * buildArray = [[NSMutableArray alloc] init];
    
    if (self.currentXmlElementForAttributesTable != NULL)
    {
        if ((self.currentXmlElementForAttributesTable).kind == NSXMLElementKind)
        {
            NSXMLElement * selectedXmlElement = self.currentXmlElementForAttributesTable;
            
            //this loop misses the 'xmlns' attributes in svg element
            NSArray * attributesArray = selectedXmlElement.attributes;
            
            for (NSXMLNode * attributeItem in attributesArray) 
            {
                NSString * attributeName =  attributeItem.name;
                NSString * attributeLocalName =  attributeItem.localName;
                NSString * attributeValue = attributeItem.stringValue;
                NSString * attributeURI = attributeItem.URI;
                
                if (attributeURI == NULL)
                {
                    attributeURI = @"";
                }
                
                NSXMLNodeKind nodeKind = attributeItem.kind;
                
                BOOL omitAttribute = NO;
                
                if (nodeKind != NSXMLAttributeKind)
                {
                    NSLog(@"buildAttributesTableForElement - nodeKind (%ld) != NSXMLAttributeKind", nodeKind);
                    omitAttribute = YES;
                }
                
                NSRange xmlnsRange = [attributeName rangeOfString:@"xmlns"];
                if (xmlnsRange.location != NSNotFound)
                {
                    NSLog(@"buildAttributesTableForElement - found xmlns namespace in attributes");
                    omitAttribute = YES;
                }
                
                if ([attributeName isEqualToString:@"macsvgid"] == YES)
                {
                    omitAttribute = YES;
                }
                else if ([attributeName isEqualToString:@"undoRedoParent"] == YES)
                {
                    omitAttribute = YES;
                }
                else if ([attributeName isEqualToString:@"undoRedoChildIndex"] == YES)
                {
                    omitAttribute = YES;
                }
                
                if (omitAttribute == NO)
                {
                    NSDictionary * attributeRecordDictionary = @{@"kind": @"NSXMLAttributeKind",
                            @"name": attributeName,
                            @"localName": attributeLocalName,
                            @"value": attributeValue,
                            @"uri": attributeURI};
                    
                    [buildArray addObject:attributeRecordDictionary];
                }
            }
            
/*
            NSArray * namespacesArray = [selectedXmlElement namespaces];
            
            for (NSXMLNode * namespaceItem in namespacesArray)
            {
                NSString * namespaceName =  [namespaceItem name];
                NSString * namespacePrefix =  [namespaceItem prefix];
                if ([namespacePrefix length] == 0)
                {
                    namespacePrefix = @"xmlns";
                    namespaceName = [NSString stringWithFormat:@"xmlns:%@", namespaceName];
                }
                NSString * namespaceLocalName =  [namespaceItem localName];
                NSString * namespaceValue = [namespaceItem stringValue];
                NSString * namespaceURI = [namespaceItem URI];
                
                NSDictionary * namespaceRecordDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"NSXMLNamespaceKind", @"kind",
                        namespaceName, @"name",
                        namespacePrefix, @"prefix",
                        namespaceLocalName, @"localName",
                        namespaceValue, @"value",
                        namespaceURI, @"uri",
                        nil];
                
                [buildArray addObject:namespaceRecordDictionary];
            }
*/
        }
    }
    
    NSArray * sortedArray = [buildArray sortedArrayUsingFunction:nameSort context:NULL];

    [self.xmlAttributesArray setArray:sortedArray];
        
    [macSVGDocumentWindowController.editorUIFrameController.validAttributesController
            setValidAttributesForElement:self.currentXmlElementForAttributesTable];
    
    [self reloadData];    
}


//==================================================================================
//	reloadData
//==================================================================================

- (void)reloadData 
{
    [self abortEditing];

    [self.xmlAttributesTableView reloadData];

    EditorUIFrameController * editorUIFrameController =
            macSVGDocumentWindowController.editorUIFrameController;
    [editorUIFrameController reloadData];
}

//==================================================================================
//	reloadView
//==================================================================================

- (void)reloadView
{
    [self abortEditing];

    [self buildAttributesTableForElement];
    [self reloadData];
}

//==================================================================================
//	xmlElementForAttributesTable
//==================================================================================

- (NSXMLElement *)xmlElementForAttributesTable
{
    return self.currentXmlElementForAttributesTable;
}

//==================================================================================
//	setXmlElementForAttributesTable
//==================================================================================

- (void)setXmlElementForAttributesTable:(NSXMLElement *)selectedElement
{
    [self abortEditing];

    //NSLog(@"setXmlElementForAttributesTable - %@", selectedElement);

    if (selectedElement == NULL)
    {
        NSLog(@"setXmlElementForAttributesTable NULL - use unsetXmlElementForAttributesTable instead");
    }
    else
    {
        if (selectedElement.kind != NSXMLElementKind)
        {
            NSLog(@"setXmlElementForAttributesTable selectedElement != NSXMLElementKind");
        }
    }
    
    self.currentXmlElementForAttributesTable = selectedElement;

    NSIndexSet * emptyIndexSet = [NSIndexSet indexSet];
    [self.xmlAttributesTableView selectRowIndexes:emptyIndexSet byExtendingSelection:NO];
    
    [self buildAttributesTableForElement];
    
    [macSVGDocumentWindowController.editorUIFrameController.attributeEditorController reloadData];
    [macSVGDocumentWindowController.editorUIFrameController.textEditorController reloadData];
}

//==================================================================================
//	unsetXmlElementForAttributesTable
//==================================================================================

- (void)unsetXmlElementForAttributesTable
{
    [self abortEditing];

    self.currentXmlElementForAttributesTable = NULL;
    
    [macSVGDocumentWindowController.svgWebKitController.domMouseEventsController.svgPathEditor resetPathSegmentsArray];
    [macSVGDocumentWindowController.svgWebKitController.domMouseEventsController.svgPolylineEditor resetPolylinePointsArray];
    [macSVGDocumentWindowController.svgWebKitController.domMouseEventsController.svgLineEditor resetLinePoints];

    NSIndexSet * emptyIndexSet = [NSIndexSet indexSet];
    [self.xmlAttributesTableView selectRowIndexes:emptyIndexSet byExtendingSelection:NO];
    
    [self buildAttributesTableForElement];
}

//==================================================================================
//	numberOfRowsInTableView
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return (self.xmlAttributesArray).count;
}

//==================================================================================
//	tableView:objectValueForTableColumn:rowIndex
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    id objectValue = NULL;
    NSDictionary * attributeRecordDictionary = (self.xmlAttributesArray)[rowIndex];
    
    if (attributeRecordDictionary != NULL)
    {
        if ([aTableColumn.identifier isEqualToString:@"AttributeColumn"] == YES)
        {
            objectValue = attributeRecordDictionary[@"name"];
        } 
        else if ([aTableColumn.identifier isEqualToString:@"ValueColumn"] == YES)
        {
            objectValue = attributeRecordDictionary[@"value"];
        } 
    } 
    
    return objectValue;
}

//==================================================================================
//	setObjectValue:forTableColumn:row
//==================================================================================

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSDictionary * oldAttributeRecordDictionary = (self.xmlAttributesArray)[rowIndex];
    
    NSString * newName = oldAttributeRecordDictionary[@"name"];
    NSString * newValue = oldAttributeRecordDictionary[@"value"];

    if ([aTableColumn.identifier isEqualToString:@"AttributeColumn"] == YES)
    {
        newName = anObject;
    } 
    else if ([aTableColumn.identifier isEqualToString:@"ValueColumn"] == YES)
    {
        newValue = anObject;
    } 
    
    NSMutableDictionary * newAttributeRecordDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            newName, @"name",
            newValue, @"value",
            nil];

    (self.xmlAttributesArray)[rowIndex] = newAttributeRecordDictionary;

    [macSVGDocumentWindowController userChangedElement:self.currentXmlElementForAttributesTable attributes:self.xmlAttributesArray];
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    //NSLog(@"XMLAttributesTableController tableViewSelectionDidChange");
    
	id aTableView = aNotification.object;
	if (aTableView == self.xmlAttributesTableView)
	{
		[self buildAttributesTableForElement];

        EditorUIFrameController * editorUIFrameController =
                macSVGDocumentWindowController.editorUIFrameController;
                
        NSString * elementName = @"";
        NSString * attributeName = @"";
        
        if (self.currentXmlElementForAttributesTable != NULL)
        {
            elementName = (self.currentXmlElementForAttributesTable).name;
        
            NSInteger rowIndex = (self.xmlAttributesTableView).selectedRow;
        
            if (rowIndex != -1)
            {
                NSMutableDictionary * attributeRecordDictionary =
                        (self.xmlAttributesArray)[rowIndex];
                
                attributeName = attributeRecordDictionary[@"name"];
            }
        }
        
        if (macSVGDocumentWindowController.creatingNewElement == NO)
        {
            [editorUIFrameController
                    setValidEditorsForXMLNode:self.currentXmlElementForAttributesTable
                    elementName:elementName
                    attributeName:attributeName context:@"attribute"];
        }
	}
}

//==================================================================================
//	addAttributeAction:
//==================================================================================

- (IBAction)addAttributeAction:(id)sender
{
    [self abortEditing];

    int index = 1;
    NSString * newAttributeName = NULL;
    NSString * defaultValue = @"0";

    MacSVGDocument * macSVGDocument = macSVGDocumentWindowController.document;
    NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;
    NSXMLElement * rootElement = [svgXmlDocument rootElement];
    #pragma unused(rootElement)
    
    BOOL continueSearch = YES;

    EditorUIFrameController * editorUIFrameController =
            macSVGDocumentWindowController.editorUIFrameController;
            
    ValidAttributesController * validAttributesController = 
            editorUIFrameController.validAttributesController;
            
    NSTableView * validAttributesTableView = validAttributesController.validAttributesTableView;
    
    if (validAttributesTableView.superview != NULL)
    {
        // Valid Attributes list is visible, check for a selection there
        NSInteger selectedRow = validAttributesTableView.selectedRow;

        if (selectedRow != -1)
        {
            NSArray * attributeKeysArray = validAttributesController.attributeKeysArray;
            NSMutableDictionary * attributesDictionary = validAttributesController.attributesDictionary;
            
            NSString * aAttributeName = attributeKeysArray[selectedRow];
            NSMutableDictionary * aAttributeDictionary = attributesDictionary[aAttributeName];
            
            if (aAttributeName != NULL)
            {
                // match was found for attribute name
                newAttributeName = aAttributeName;

                MacSVGDocument * macSVGDocument = macSVGDocumentWindowController.document;
                                
                NSArray * aDefaultValueArray = aAttributeDictionary[@"default_value"];
                if (aDefaultValueArray != NULL)
                {
                    if (aDefaultValueArray.count > 0)
                    {
                        NSString * aDefaultValue = aDefaultValueArray[0];
                                                
                        if ([aDefaultValue isEqualToString:@"#IMPLIED"] == YES)
                        {
                            NSArray * valuesArray = aAttributeDictionary[@"attribute_type"];
                            
                            if (valuesArray.count > 0)
                            {
                                // first item from list of valid values
                                defaultValue = valuesArray[0];
                                
                                if ([defaultValue isEqualToString:@"ID"] == YES)
                                {
                                    NSString * elementName = (self.currentXmlElementForAttributesTable).name;
                                    defaultValue = [macSVGDocument uniqueIDForElementTagName:elementName pendingIDs:NULL];
                                }
                            }
                        }
                        else
                        {
                            defaultValue = aDefaultValue;
                        }
                    }
                }

                if ([defaultValue isEqualToString:@"CDATA"] == YES)
                {
                    defaultValue = @"";
                }
                
                continueSearch = NO;
            }
        }
    }
    
    // add a generic attribute name
    while (continueSearch == YES)
    {
        newAttributeName = [[NSString alloc] 
                initWithFormat:@"new_attribute_%d", index];
        
        BOOL matchFound = NO;
        
        for (NSDictionary * aAttributeDictionary in self.xmlAttributesArray)
        {
            NSString * aAttributeName= aAttributeDictionary[@"name"];
        
            if ([newAttributeName isEqualToString:aAttributeName] == YES)
            {
                matchFound = YES;
            }
        }
        
        if (matchFound == NO)
        {
            continueSearch = NO;
        }
        else
        {
            index++;
        }
    }

    NSMutableDictionary * newAttributeRecordDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            newAttributeName, @"name",
            defaultValue, @"value",
            nil];
            
    [self.xmlAttributesArray addObject:newAttributeRecordDictionary];
        
    [macSVGDocumentWindowController userChangedElement:self.currentXmlElementForAttributesTable attributes:self.xmlAttributesArray];
    
    [self.xmlAttributesTableView reloadData];

    NSArray * sortedArray = [self.xmlAttributesArray sortedArrayUsingFunction:nameSort context:NULL];

    [self.xmlAttributesArray setArray:sortedArray];
    
    NSUInteger newRowIndex = (self.xmlAttributesArray).count - 1;
    
    NSUInteger attributesArrayCount = (self.xmlAttributesArray).count;
    for (int i = 0; i < attributesArrayCount; i++)
    {
        NSMutableDictionary * attributeDictionary = (self.xmlAttributesArray)[i];
        NSString * aAttributeName = attributeDictionary[@"name"];
        if ([aAttributeName isEqualToString:newAttributeName] == YES)
        {
            newRowIndex = i;
        }
    }
    
    NSIndexSet * rowIndex = [NSIndexSet indexSetWithIndex:newRowIndex];
    [self.xmlAttributesTableView selectRowIndexes:rowIndex byExtendingSelection:NO];
}

//==================================================================================
//	deleteAttributeAction:
//==================================================================================

- (IBAction)deleteAttributeAction:(id)sender
{
    [self abortEditing];
    
    NSMutableArray * deletedAttributes = [[NSMutableArray alloc] init];
    
    NSIndexSet * selectedRows = (self.xmlAttributesTableView).selectedRowIndexes;
    //NSUInteger indexCount = [selectedRows count];

    if (selectedRows != nil) 
    {
        for (NSInteger row = selectedRows.firstIndex; row != NSNotFound; row = [selectedRows indexGreaterThanIndex:row]) 
        {
            NSDictionary * attributeRecordDictionary = (self.xmlAttributesArray)[row];
            NSString * attributeName = attributeRecordDictionary[@"name"];
            [deletedAttributes addObject:attributeName];
        }
    }
    
    for (NSString * deletedAttributeName in deletedAttributes)
    {
        NSUInteger attributesCount = (self.xmlAttributesArray).count;
         
        for (int i = (int)attributesCount - 1; i >= 0; i--)
        {
            NSDictionary * aAttributeRecordDictionary = (self.xmlAttributesArray)[i];
            NSString * aAttributeName = aAttributeRecordDictionary[@"name"];
            if ([deletedAttributeName isEqualToString:aAttributeName] == YES)
            {
                [self.xmlAttributesArray removeObjectAtIndex:i];
            }
        }
    }
    
    [macSVGDocumentWindowController userChangedElement:self.currentXmlElementForAttributesTable
            attributes:self.xmlAttributesArray];

    NSIndexSet * emptyIndexSet = [NSIndexSet indexSet];
    [self.xmlAttributesTableView selectRowIndexes:emptyIndexSet byExtendingSelection:NO];
    
    [macSVGDocumentWindowController updateSelections];

    [macSVGDocumentWindowController reloadAllViews];
}




@end
