//
//  SVGXMLDOMSelectionManager.m
//  macSVG
//
//  Created by Douglas Ward on 3/25/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "SVGXMLDOMSelectionManager.h"
#import <WebKit/WebKit.h>
#import "MacSVGDocument.h"
#import "MacSVGDocumentWindowController.h"
#import "SVGWebKitController.h"
#import "SVGWebView.h"
#import "SelectedElementsManager.h"
#import "WebKitInterface.h"
#import "SVGWebKitController.h"
#import "SelectedElementsManager.h"
#import "DOMSelectionControlsManager.h"
#import "DOMMouseEventsController.h"
#import "SVGPathEditor.h"
#import "SVGPolylineEditor.h"
#import "SVGLineEditor.h"

@implementation SVGXMLDOMSelectionManager

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.activeXMLElement = NULL;
    self.selectedElementsManager = NULL;
    self.pathSegmentsArray = NULL;
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
        self.selectedElementsManager = [[SelectedElementsManager alloc] init];
        self.selectedElementsManager.macSVGDocumentWindowController = macSVGDocumentWindowController;
        self.activeXMLElement = NULL;
    }
    
    return self;
}

//==================================================================================
//	syncSelectedDOMElementsToXMLDocument:
//==================================================================================

-(void) syncSelectedDOMElementsToXMLDocument
{
    // copy attributes of selected elements from DOM to XML document
    MacSVGDocument * macSVGDocument = macSVGDocumentWindowController.document;

    NSArray * selectedElementsArray = self.selectedElementsManager.selectedElementsArray;
    
    NSUInteger selectedItemsCount = selectedElementsArray.count;
    for (int i = 0; i < selectedItemsCount; i++)
    {
        NSMutableDictionary * selectedItemDictionary = selectedElementsArray[i];

        // update the selected elements
        DOMElement * aSvgElement = selectedItemDictionary[@"domElement"];
        NSXMLElement * aXmlElement = selectedItemDictionary[@"xmlElement"];
        
        //NSLog(@"syncSelectedElementsToXMLDocument - %@", aSvgElement);
        
        NSMutableDictionary * attributesDictionary = [[NSMutableDictionary alloc] init];
        
        DOMNamedNodeMap * attributesNodeMap = aSvgElement.attributes;
        
        int attributeCount = attributesNodeMap.length;
        
        for (int j = 0; j < attributeCount; j++)
        {
            DOMNode * attributeNode = [attributesNodeMap item:j];
            
            NSString * attributeName = attributeNode.nodeName;
            NSString * attributeValue = attributeNode.nodeValue;
            
            if (attributeName.length > 0)
            {
                BOOL omitAttribute = NO;
            
                NSRange colonRange = [attributeName rangeOfString:@"xmlns:"];
                if (colonRange.location != NSNotFound)
                {
                    // found a namespace
                    omitAttribute = YES;
                }
            
                unichar firstChar = [attributeName characterAtIndex:0];
                if (firstChar == '_')   // omit attribute if name begins with underscore character
                {
                    omitAttribute = YES;
                }

                if (omitAttribute == NO)
                {
                    attributesDictionary[attributeName] = attributeValue;
                }
            }
        }
        
        //[macSVGDocument setAttributesForXMLElement:attributesDictionary];
        
        if (attributesDictionary.count == 0)
        {
            NSLog(@"syncSelectedDOMElementsToXMLDocument - attributesDictionary count is zero");
        }

        [macSVGDocument setAttributes:attributesDictionary forElement:aXmlElement];
    }
}

//==================================================================================
//	activeDOMElement
//==================================================================================

- (DOMElement *) activeDOMElement
{
    // find DOMElement corresponding to activeDOMElement
   DOMElement * activeDOMElement = NULL;

    if (self.activeXMLElement != NULL)
    {
        NSXMLNode * xmlMacsvgidNode = [self.activeXMLElement attributeForName:@"macsvgid"];
        NSString * xmlMacsvgid = xmlMacsvgidNode.stringValue;
        
        if (xmlMacsvgid != NULL)
        {
            activeDOMElement = [svgWebKitController domElementForMacsvgid:xmlMacsvgid];
        }
    }
    
    return activeDOMElement;
}

//==================================================================================
//	xmlElementIsSelected:selectedElements:
//==================================================================================

- (BOOL)xmlElementIsSelected:(NSXMLElement *)aElement selectedElements:(NSArray *)selectedElements
{
    BOOL result = NO;
    
    BOOL continueSearch = NO;
    
    NSUInteger selectedElementsCount = selectedElements.count;
    
    if (selectedElementsCount > 0)
    {
        continueSearch = YES;
    }
    
    int searchIdx = 0;
    
    while (continueSearch == YES)
    {
        NSXMLElement * aComparisionElement = selectedElements[searchIdx];
        
        if (aElement == aComparisionElement)
        {
            result = YES;
            continueSearch = NO;
        }
        
        searchIdx++;
        if (searchIdx >= selectedElementsCount)
        {
            continueSearch = NO;
        }
    }
    
    return result;
}

//==================================================================================
//	createTemporaryDOMElementForXMLElement
//==================================================================================

-(DOMElement *)createTemporaryDOMElementForXMLElement:(NSXMLElement *)aXmlElement
{
    DOMElement * aDomElement = NULL;

    if (aXmlElement != NULL)
    {
        // also recursively creates temporary parents
        NSString * tagName = aXmlElement.name;

        DOMDocument * domDocument = (macSVGDocumentWindowController.svgWebKitController.svgWebView).mainFrame.DOMDocument;
        
        aDomElement = [domDocument createElementNS:svgNamespace
                qualifiedName:tagName];

        NSArray * xmlAttributeNodes = aXmlElement.attributes;
        
        for (NSXMLNode * aXMLAttributeNode in xmlAttributeNodes)
        {
            NSString * attributeName = aXMLAttributeNode.name;
            NSString * attributeValue = aXMLAttributeNode.stringValue;
            
            [aDomElement setAttribute:attributeName value:attributeValue];
        }
        
        NSString * stringValue = aXmlElement.stringValue;
        
        NSString * copyStringValue = [[NSString alloc] initWithString:stringValue];
        
        aDomElement.textContent = copyStringValue;
        
        // try to find matching parent element
        BOOL endParentSearch = NO;
        if ([tagName isEqualToString:@"svg"] == NO) endParentSearch = YES;
        if ([tagName isEqualToString:@"html"] == NO) endParentSearch = YES;
        if (aXmlElement.parent == NULL) endParentSearch = YES;
        
        if (endParentSearch == NO)
        {
            NSXMLElement * parentXmlElement = (NSXMLElement *)aXmlElement.parent;
            if (parentXmlElement != NULL)
            {
                DOMElement * parentDOMElement = NULL;
                
                NSXMLNode * parentMacsvgidNode = [aXmlElement attributeForName:@"macsvgid"];
                if (parentMacsvgidNode != NULL)
                {
                    NSString * parentMacsvgid = parentMacsvgidNode.stringValue;

                    parentDOMElement = [svgWebKitController domElementForMacsvgid:parentMacsvgid];
                }
                
                if (parentDOMElement == NULL)
                {
                    parentDOMElement = [self createTemporaryDOMElementForXMLElement:parentXmlElement];
                }
                
                if (parentDOMElement != NULL)
                {
                    [parentDOMElement appendChild:aDomElement];
                }
            }
        }
    }
    
    return aDomElement;
}

//==================================================================================
//	recursiveBuildXMLElementsDictionary:parent:depth:
//==================================================================================

- (void)recursiveBuildXMLElementsDictionary:(NSMutableDictionary *)xmlElementsDictionary
        parent:(NSXMLNode *)parent depth:(unsigned int)depth
{
	NSArray * children = NULL;
	NSUInteger childCount = 0;

    if (parent == NULL)
    {
        // if parent is NULL, use the xml root element as parent
        MacSVGDocument * macSVGDocument = macSVGDocumentWindowController.document;
        NSXMLElement * xmlRootElement = [macSVGDocument.svgXmlDocument rootElement];
        NSXMLNode * MacsvgidNode = [xmlRootElement attributeForName:@"macsvgid"];
        NSString * macsvgid = MacsvgidNode.stringValue;

        xmlElementsDictionary[macsvgid] = xmlRootElement;
        
        children = xmlRootElement.children;
        childCount = children.count;
    }
    else
    {
        children = parent.children;
        childCount = children.count;
    }
    
	for (unsigned int i = 0; i < childCount; i++)
    {
		NSXMLNode * aNode = children[i];
        
		if (aNode.kind == NSXMLElementKind)
        {
            NSXMLElement * aXmlElement = (NSXMLElement *)aNode;
            NSXMLNode * MacsvgidNode = [aXmlElement attributeForName:@"macsvgid"];
            NSString * macsvgid = MacsvgidNode.stringValue;
            
            xmlElementsDictionary[macsvgid] = aXmlElement;

            NSUInteger grandchildCount = aXmlElement.childCount;
            if (grandchildCount > 0)
            {
                [self recursiveBuildXMLElementsDictionary:xmlElementsDictionary
                        parent:aNode depth:(depth + 1)];   // recursive call
            }
        }
	}
}

//==================================================================================
//	recursiveBuildDOMElementsDictionary:parent:depth:
//==================================================================================

- (void)recursiveBuildDOMElementsDictionary:(NSMutableDictionary *)domElementsDictionary
        parent:(DOMElement *)parent depth:(unsigned int)depth
{
	DOMNodeList * childNodes = NULL;
	int childCount = 0;

    if (parent == NULL)
    {
        // if parent is NULL, use the dom root element as parent
        DOMDocument * domDocument = (svgWebKitController.svgWebView).mainFrame.DOMDocument;
        DOMNodeList * svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
        
        if (svgElementsList.length > 0)
        {
            DOMElement * domRootElement = (DOMElement *)[svgElementsList item:0];
            
            NSString * macsvgid = [domRootElement getAttribute:@"macsvgid"];

            domElementsDictionary[macsvgid] = domRootElement;

            childNodes = domRootElement.childNodes;
            childCount = childNodes.length;
        }
    }
    else
    {
        childNodes = parent.childNodes;
        childCount = childNodes.length;
    }
    
	for (unsigned int i = 0; i < childCount; i++)
    {
		DOMNode * aNode = [childNodes item:i];
        
		if (aNode.nodeType == DOM_ELEMENT_NODE)
        {
            DOMElement * aDomElement = (DOMElement *)aNode;
            NSString * macsvgid = [aDomElement getAttribute:@"macsvgid"];
            
            domElementsDictionary[macsvgid] = aDomElement;

            NSUInteger grandchildCount = aDomElement.childElementCount;
            if (grandchildCount > 0)
            {
                [self recursiveBuildDOMElementsDictionary:domElementsDictionary
                        parent:aDomElement depth:(depth + 1)];   // recursive call
            }
        }
	}
}


//==================================================================================
//	recursiveXMLSelect:selectedXMLElements:depth
//==================================================================================

- (void)recursiveXMLSelect:(NSXMLNode *)parent selectedXMLElements:(NSArray *)selectedElements
        depth:(unsigned int)depth
{
	NSArray * children = NULL;
	NSUInteger childCount = 0;

    if (parent == NULL)
    {
        // if parent is NULL, use the xml root element as parent
        MacSVGDocument * macSVGDocument = macSVGDocumentWindowController.document;
        NSXMLElement * xmlRootElement = [macSVGDocument.svgXmlDocument rootElement];
        if ([self xmlElementIsSelected:xmlRootElement selectedElements:selectedElements] == YES)
        {
            NSXMLNode * MacsvgidNode = [xmlRootElement attributeForName:@"macsvgid"];
            NSString * macsvgid = MacsvgidNode.stringValue;
            DOMElement * aDomElement = [svgWebKitController domElementForMacsvgid:macsvgid];
            
            if (aDomElement == NULL)
            {
                // should not happen
                aDomElement = [self createTemporaryDOMElementForXMLElement:xmlRootElement];
            }
            
            [self.selectedElementsManager addElementDictionaryWithXMLElement:xmlRootElement domElement:aDomElement];
        }
        children = xmlRootElement.children;
        childCount = children.count;
    }
    else
    {
        children = parent.children;
        childCount = children.count;
    }
    
	for (unsigned int i = 0; i < childCount; i++)
    {
		NSXMLNode * aNode = children[i];
        
		if (aNode.kind == NSXMLElementKind)
        {
            NSXMLElement * aXmlElement = (NSXMLElement *)aNode;
            //NSString * macsvgid = [aXmlElement getAttribute:@"macsvgid"];
            
            if ([self xmlElementIsSelected:aXmlElement selectedElements:selectedElements] == YES)
            {
                NSXMLNode * MacsvgidNode = [aXmlElement attributeForName:@"macsvgid"];
                NSString * macsvgid = MacsvgidNode.stringValue;
                DOMElement * aDomElement = [svgWebKitController domElementForMacsvgid:macsvgid];
                
                if (aDomElement == NULL)
                {
                    // this is probably an animation element, not found because animation is disabled and filtered out
                    // create a temporary DOMElement translated from the XML element before insertion to selection array
                    aDomElement = [self createTemporaryDOMElementForXMLElement:aXmlElement];
                }
                
                [self.selectedElementsManager addElementDictionaryWithXMLElement:aXmlElement domElement:aDomElement];
            }
        
            [self recursiveXMLSelect:aNode selectedXMLElements:selectedElements depth:(depth + 1)];   // recursive call
        }
	}
}

//==================================================================================
//	setSelectedXMLElements:domElementsDictionary:
//==================================================================================

- (void)setSelectedXMLElements:(NSArray *)selectedXMLElements
        domElementsDictionary:(NSMutableDictionary *)domElementsDictionary
{
    for (NSXMLNode * aXmlNode in selectedXMLElements)
    {
        if (aXmlNode.kind == NSXMLElementKind)
        {
            NSXMLElement * aXmlElement = (NSXMLElement *)aXmlNode;
            
            NSXMLNode * MacsvgidNode = [aXmlElement attributeForName:@"macsvgid"];
            NSString * macsvgid = MacsvgidNode.stringValue;
        
            DOMElement * aDomElement = domElementsDictionary[macsvgid];
            
            if (aDomElement == NULL)
            {
                // TODO this is probably an animation element, not found because animation is disabled and filtered out
                // create a temporary DOMElement translated from the XML element before insertion to selection array
                aDomElement = [self createTemporaryDOMElementForXMLElement:aXmlElement];
            }
            
            [self.selectedElementsManager addElementDictionaryWithXMLElement:aXmlElement domElement:aDomElement];
        }
    }
}

//==================================================================================
//	setSelectedXMLElements
//==================================================================================

- (void)setSelectedXMLElements:(NSArray *)selectedXMLElements
{
    [self.selectedElementsManager removeAllElements];
    [self.domSelectionControlsManager removeDOMSelectionRectsAndHandles];

    if (selectedXMLElements.count <= 1)
    {
        [self recursiveXMLSelect:NULL
                selectedXMLElements:selectedXMLElements depth:0];
    }
    else
    {
        NSMutableDictionary * domElementsDictionary =
                [NSMutableDictionary dictionaryWithCapacity:512];

        [self recursiveBuildDOMElementsDictionary:domElementsDictionary parent:NULL depth:0];
        
        [self setSelectedXMLElements:selectedXMLElements
                domElementsDictionary:domElementsDictionary];
    }
    
    if (macSVGDocumentWindowController.currentToolMode == toolModeArrowCursor)
    {
        [self.domSelectionControlsManager makeDOMSelectionRects];
        
        DOMElement * firstDOMElement = [self.selectedElementsManager firstDomElement];
        [self.domSelectionControlsManager makeDOMSelectionHandles:firstDOMElement];
    }
    
    NSXMLElement * selectedXMLElement = [self.selectedElementsManager firstXmlElement];
    
    if (selectedXMLElement != NULL)
    {
        [macSVGDocumentWindowController setAttributesForXMLNode:selectedXMLElement];
    }
    else
    {
        [macSVGDocumentWindowController setAttributesForXMLNode:NULL];
    }
}


//==================================================================================
//	setSelectionsForChildNodes:selectionState:
//==================================================================================

-(void) setSelectionsForChildNodes:(NSXMLElement *)aXMLElement selectionState:(BOOL)selectionState
{
    NSArray * childNodesArray = aXMLElement.children;
    for (NSXMLNode * aChildNode in childNodesArray)
    {
        BOOL itemIsSelected = NO;
        NSXMLNodeKind nodeKind = aChildNode.kind;
        
        if (nodeKind == NSXMLElementKind)
        {
            NSXMLElement * aChildXMLElement = (NSXMLElement *)aChildNode;
            
            NSDictionary * targetDictionary = NULL;

            NSArray * selectedElementsArray = [self.selectedElementsManager
                    selectedElementsArray];
            
            for (NSMutableDictionary * selectedElementDictionary in selectedElementsArray)
            {
                NSXMLElement * aSelectedXMLElement = selectedElementDictionary[@"xmlElement"];
                if (aChildXMLElement == aSelectedXMLElement)
                {
                    targetDictionary = selectedElementDictionary;
                    itemIsSelected = YES;
                    break;
                }
            }
            
            if (itemIsSelected == YES)
            {
                if (selectionState == NO)
                {
                    // remove from selection
                    [self.selectedElementsManager removeElementDictionary:targetDictionary];
                }
            }
            else
            {
                if (selectionState == YES)
                {
                    // add to selection
                    NSXMLNode * MacsvgidNode = [aChildXMLElement attributeForName:@"macsvgid"];
                    if (MacsvgidNode != NULL)
                    {
                        NSString * aMacsvgid = MacsvgidNode.stringValue;
                        DOMElement * aChildDomElement = [svgWebKitController domElementForMacsvgid:aMacsvgid];
                        [self.selectedElementsManager
                                addElementDictionaryWithXMLElement:aChildXMLElement domElement:aChildDomElement];
                    }
                }
            }
            
            [self setSelectionsForChildNodes:aChildXMLElement selectionState:selectionState]; // recursive call
        }
    }
}

//==================================================================================
//	selectXMLElementAndChildNodes:
//==================================================================================

-(void) selectXMLElementAndChildNodes:(NSXMLElement *)aXMLElement
{
    [self selectXMLElement:aXMLElement];
    
    NSArray * selectedElementsArray = [self.selectedElementsManager selectedElementsArray];
    
    BOOL itemIsSelected = NO;
    for (NSMutableDictionary * selectedElementDictionary in selectedElementsArray)
    {
        NSXMLElement * aSelectedXMLElement = selectedElementDictionary[@"xmlElement"];
        if (aXMLElement == aSelectedXMLElement)
        {
            itemIsSelected = YES;
            break;
        }
    }
    
    [macSVGDocumentWindowController revealElementInXMLOutline:aXMLElement];
    
    [self setSelectionsForChildNodes:aXMLElement selectionState:itemIsSelected];

    [macSVGDocumentWindowController updateXMLOutlineViewSelections];
}

//==================================================================================
//	selectXMLElement:
//==================================================================================

-(void) selectXMLElement:(NSXMLElement *)aXMLElement
{
    BOOL omitFromSelection = NO;
    NSString * tagName = @"";

    NSXMLNode * MacsvgidNode = [aXMLElement attributeForName:@"macsvgid"];
    NSString * macsvgid = MacsvgidNode.stringValue;

    DOMElement * aDOMElement = [svgWebKitController domElementForMacsvgid:macsvgid];

    NSUInteger selectedItemsCount = [self.selectedElementsManager selectedElementsCount];
    NSUInteger selectedItemsIndex = NSNotFound;
    NSMutableDictionary * selectedItemDictionary = NULL;
    
    // manage click for existing selection, if any
    if (selectedItemsCount > 0)
    {
        BOOL continueSearch = YES;
        NSUInteger dictionaryIdx = 0;
        while (continueSearch == YES)
        {
            if (dictionaryIdx >= selectedItemsCount)
            {
                continueSearch = NO;
            }
            else
            {
                NSXMLElement * selectedItemElement = [self.selectedElementsManager xmlElementAtIndex:dictionaryIdx];
                if (selectedItemElement == aXMLElement)
                {
                    selectedItemsIndex = dictionaryIdx;
                    continueSearch = NO;
                }
            }
            dictionaryIdx++;
        }
        CGEventRef event = CGEventCreate(NULL);
        CGEventFlags modifiers = CGEventGetFlags(event);
        CFRelease(event);
        CGEventFlags flags = (kCGEventFlagMaskShift | kCGEventFlagMaskCommand);
        if ((modifiers & flags) != 0)
        {
            // shift key or command key were pressed
            if (selectedItemsIndex != NSNotFound)
            {
                [self.selectedElementsManager removeElementDictionary:selectedItemDictionary];  // remove the selected element
                omitFromSelection = YES;
            }
        }
        else
        {
            // no keys pressed
            if (selectedItemsIndex == NSNotFound)
            {
                [self.selectedElementsManager removeAllElements];  // remove all selected elements
                [self.domSelectionControlsManager removeDOMSelectionRectsAndHandles];
                [svgWebKitController.domMouseEventsController.svgLineEditor removeLineHandles];
                [svgWebKitController.domMouseEventsController.svgPolylineEditor removePolylineHandles];
                [svgWebKitController.domMouseEventsController.svgPathEditor removePathHandles];
            }
        }
    }
    
    selectedItemsCount = [self.selectedElementsManager selectedElementsCount];    // refresh count
    
    // manage click where adding, not omitting, from an existing selection
    if (omitFromSelection == NO)
    {
        int searchItemIdx = 0;
        int foundItemIdx = 0;
        BOOL continueSearch = NO;
        BOOL selectedItemFound = NO;
        
        tagName = aXMLElement.name;
        
        if (selectedItemsCount > 0)
        {
            continueSearch = YES;
        }
        
        while (continueSearch == YES)
        {
            NSXMLElement * aSelectedXMLElement = [self.selectedElementsManager xmlElementAtIndex:searchItemIdx];
            
            if (aXMLElement == aSelectedXMLElement)
            {
                // crosshair can only select path, polyline or polygon
                //selectedItemFound = YES;
                //foundItemIdx = searchItemIdx;
                //continueSearch = NO;
                
                if (macSVGDocumentWindowController.currentToolMode != toolModeCrosshairCursor)
                {
                    selectedItemFound = YES;
                    foundItemIdx = searchItemIdx;
                    continueSearch = NO;
                }
                else
                {
                    NSString * elementTag = aSelectedXMLElement.name;
                    if ([elementTag isEqualToString:@"path"])
                    {
                        selectedItemFound = YES;
                        foundItemIdx = searchItemIdx;
                        continueSearch = NO;
                    }
                    else if ([elementTag isEqualToString:@"polyline"])
                    {
                        selectedItemFound = YES;
                        foundItemIdx = searchItemIdx;
                        continueSearch = NO;
                    }
                    else if ([elementTag isEqualToString:@"polygon"])
                    {
                        selectedItemFound = YES;
                        foundItemIdx = searchItemIdx;
                        continueSearch = NO;
                    }
                    else if ([elementTag isEqualToString:@"line"])
                    {
                        selectedItemFound = YES;
                        foundItemIdx = searchItemIdx;
                        continueSearch = NO;
                    }
                }
            }
            
            searchItemIdx++;
            if (searchItemIdx >= selectedItemsCount)
            {
                continueSearch = NO;
            }
        }
            
        if (selectedItemFound == NO)
        {
            if (aDOMElement == NULL)
            {
                if (aXMLElement != NULL)
                {
                    aDOMElement = [self createTemporaryDOMElementForXMLElement:aXMLElement];

                    if (aDOMElement == NULL)
                    {
                        NSLog(@"SVGXMLDOMSelectionManager selectXMLElement aDOMElement is NULL");
                    }
                }
            }
        
            if (aDOMElement != NULL)
            {
                [self.selectedElementsManager addElementDictionaryWithXMLElement:aXMLElement domElement:aDOMElement];
            }
        }
    }  

    if (macSVGDocumentWindowController.creatingNewElement == NO)
    {
        if (macSVGDocumentWindowController.currentToolMode != toolModeCrosshairCursor)
        {
            [self.domSelectionControlsManager makeDOMSelectionRects];   // test 20130709
            
            //[self.domSelectionControlsManager makeDOMSelectionHandles:[self activeDOMElement]];
            [self.domSelectionControlsManager makeDOMSelectionHandles:aDOMElement];  // test 20160907
        }
        else
        {
            if ([tagName isEqualToString:@"path"] == YES)
            {
                [svgWebKitController.domMouseEventsController.svgPathEditor makePathHandles];
            }
            else if ([tagName isEqualToString:@"polyline"] == YES)
            {
                [svgWebKitController.domMouseEventsController.svgPolylineEditor makePolylineHandles];
            }
            else if ([tagName isEqualToString:@"polygon"] == YES)
            {
                [svgWebKitController.domMouseEventsController.svgPolylineEditor makePolylineHandles];
            }
            else if ([tagName isEqualToString:@"line"] == YES)
            {
                [svgWebKitController.domMouseEventsController.svgLineEditor makeLineHandles];
            }
        }
    }
    
    if ([tagName isEqualToString:@"text"] == YES)
    {
        [aDOMElement focus];
    }

    // Select the corresponding element in the SVGOutlineView

    [macSVGDocumentWindowController revealElementInXMLOutline:aXMLElement];

    [macSVGDocumentWindowController updateXMLOutlineViewSelections];

    //NSLog(@"selectXMLElement - test call to setAttributesForXMLNode");

    NSXMLElement * selectedXMLElement = [self.selectedElementsManager firstXmlElement];

    if (selectedXMLElement != NULL)
    {
        [macSVGDocumentWindowController setAttributesForXMLNode:selectedXMLElement];
    }
    else
    {
        [macSVGDocumentWindowController setAttributesForXMLNode:NULL];
    }
}

//==================================================================================
//	resyncDOMElementsInSelectedElementsArray
//==================================================================================

- (void) resyncDOMElementsInSelectedElementsArray
{
    // resync the DOM elements to XML elements in the selectedElementsArray
    // this needs to be called after svgWebView is reloaded with updated XML data
    NSArray * selectedElementsDictionariesArray = [self.selectedElementsManager selectedElementsArray];

    NSMutableDictionary * domElementsDictionary =
            [NSMutableDictionary dictionaryWithCapacity:512];

    [self recursiveBuildDOMElementsDictionary:domElementsDictionary parent:NULL depth:0];

    NSUInteger selectedItemsCount = selectedElementsDictionariesArray.count;
    for (int i = 0; i < selectedItemsCount; i++) 
    {
        NSMutableDictionary * selectedElementDictionary = selectedElementsDictionariesArray[i];
        
        NSXMLElement * aSelectedXmlElement = selectedElementDictionary[@"xmlElement"];
        
        NSXMLNode * MacsvgidNode = [aSelectedXmlElement attributeForName:@"macsvgid"];
        NSString * macsvgid = MacsvgidNode.stringValue;
        
        DOMElement * aSelectedDomElement = domElementsDictionary[macsvgid];
    
        if (aSelectedDomElement != NULL)
        {
            selectedElementDictionary[@"domElement"] = aSelectedDomElement;
        }
        else
        {
            // could happen with animation elements, when animation is disabled
            aSelectedDomElement = [self createTemporaryDOMElementForXMLElement:aSelectedXmlElement];
            
            selectedElementDictionary[@"domElement"] = aSelectedDomElement;
        }
    }
}

@end
