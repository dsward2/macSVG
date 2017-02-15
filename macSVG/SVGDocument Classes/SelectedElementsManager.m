//
//  SelectedElementsManager.m
//  macSVG
//
//  Created by Douglas Ward on 7/3/13.
//
//

#import "SelectedElementsManager.h"
#import <WebKit/WebKit.h>
#import "MacSVGDocumentWindowController.h"
#import "SVGWebView.h"
#import "SVGWebKitController.h"

@interface SelectedElementsManager()
{
    @private
    NSMutableArray * selectedElementsDictionariesArray;  // dictionaries of paired NSXMLElement and DOMElement
}
@end


@implementation SelectedElementsManager


//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    [selectedElementsDictionariesArray removeAllObjects];
    
    selectedElementsDictionariesArray = NULL;       // old note, not sure if still an issue: "does selectedElementsArray leak?"
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
        selectedElementsDictionariesArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

//==================================================================================
//	selectedElementsArray
//==================================================================================

- (NSMutableArray *)selectedElementsArray
{
    return selectedElementsDictionariesArray;
}

//==================================================================================
//	elementDictionaryAtIndex
//==================================================================================

- (NSDictionary *)elementDictionaryAtIndex:(NSUInteger)elementIndex
{
    return selectedElementsDictionariesArray[elementIndex];
}

//==================================================================================
//	removeElementDictionary
//==================================================================================

- (void)removeElementDictionary:(NSDictionary *)aDictionary
{
    [selectedElementsDictionariesArray removeObject:aDictionary];
}

//==================================================================================
//	removeAllElements
//==================================================================================

- (void)removeAllElements
{
    [selectedElementsDictionariesArray removeAllObjects];
}

//==================================================================================
//	selectedElementsCount
//==================================================================================

- (NSUInteger)selectedElementsCount
{
    return selectedElementsDictionariesArray.count;
}

//==================================================================================
//	drawableSelectedElementsCount
//==================================================================================

- (NSInteger)drawableSelectedElementsCount
{
    NSInteger result = 0;
    
    NSDictionary * drawableObjectsDictionary = @{@"rect": @"rect",
                                                 @"circle": @"circle",
                                                 @"ellipse": @"ellipse",
                                                 @"text": @"text",
                                                 @"image": @"image",
                                                 @"line": @"line",
                                                 @"polyline": @"polyline",
                                                 @"polygon": @"polygon",
                                                 @"path": @"path",
                                                 @"use": @"use",
                                                 @"g": @"g",
                                                 @"foreignObject": @"foreignObject"};
    
    for (NSDictionary * selectedElementDictionary in selectedElementsDictionariesArray)
    {
        NSXMLElement * aXMLElement = [selectedElementDictionary objectForKey:@"xmlElement"];
        
        NSString * elementName = [aXMLElement name];
        
        if ([drawableObjectsDictionary objectForKey:elementName] != NULL)
        {
            result++;
        }
    }

    return result;
}

//==================================================================================
//	xmlElementAtIndex
//==================================================================================

- (NSXMLElement *)xmlElementAtIndex:(NSUInteger)elementIndex
{
    NSMutableDictionary * elementDictionary = selectedElementsDictionariesArray[elementIndex];
    NSXMLElement * xmlElement = elementDictionary[@"xmlElement"];
    
    if (xmlElement == NULL)
    {
        NSLog(@"SelectedElementsManager xmlElement is NULL");
    }
    
    return xmlElement;
}

//==================================================================================
//	firstXmlElement
//==================================================================================

- (NSXMLElement *)firstXmlElement
{   NSXMLElement * xmlElement = NULL;

    if (selectedElementsDictionariesArray.count > 0)
    {
        NSMutableDictionary * elementDictionary = selectedElementsDictionariesArray[0];
        xmlElement = elementDictionary[@"xmlElement"];
    }
    
    return xmlElement;
}


//==================================================================================
//	domElementAtIndex
//==================================================================================

- (DOMElement *)domElementAtIndex:(NSUInteger)elementIndex
{
    NSMutableDictionary * elementDictionary = selectedElementsDictionariesArray[elementIndex];
    DOMElement * domElement = elementDictionary[@"domElement"];
    
    if (domElement == NULL)
    {
        NSLog(@"SelectedElementsManager domElement is NULL");
    }
    
    return domElement;
}

//==================================================================================
//	firstDomElement
//==================================================================================

- (DOMElement *)firstDomElement
{
    DOMElement * domElement = NULL;

    if (selectedElementsDictionariesArray.count > 0)
    {
        NSMutableDictionary * elementDictionary = selectedElementsDictionariesArray[0];
        domElement = elementDictionary[@"domElement"];
    }
    
    return domElement;
}

//==================================================================================
//	addElementDictionaryWithXMLElement:domElement:
//==================================================================================

- (void)addElementDictionaryWithXMLElement:(NSXMLElement *)xmlElement
        domElement:(DOMElement *)domElement
{
    if (xmlElement == NULL)
    {
        NSLog(@"ERROR - SelectedElementsManager xmlElement is NULL");
    }
    else
    {
        if ([xmlElement isKindOfClass:[NSXMLElement class]] == NO)
        {
            NSLog(@"ERROR - SelectedElementsManager xmlElement is wrong class %@", [NSXMLElement class]);
        }
    }

    if (domElement == NULL)
    {
        BOOL isFilteredAnimationElement = NO;
        
        NSInteger animationEnabled = self.macSVGDocumentWindowController.enableAnimationCheckbox.state;
        if (animationEnabled == NO)
        {
            NSString * xmlElementName = [xmlElement name];
            
            if ([xmlElementName isEqualToString:@"animate"] == YES)
            {
                isFilteredAnimationElement = YES;
            }
            else if ([xmlElementName isEqualToString:@"animateColor"] == YES)
            {
                isFilteredAnimationElement = YES;
            }
            else if ([xmlElementName isEqualToString:@"animateMotion"] == YES)
            {
                isFilteredAnimationElement = YES;
            }
            else if ([xmlElementName isEqualToString:@"animateTransform"] == YES)
            {
                isFilteredAnimationElement = YES;
            }
            else if ([xmlElementName isEqualToString:@"set"] == YES)
            {
                isFilteredAnimationElement = YES;
            }
        }
        
        if (isFilteredAnimationElement == YES)
        {
            // the corresponding dom element was not found in webview because animation mode is disabled,
            // so make a standalone dummy dom element for the xml element
            
            domElement = [self createTemporaryDOMElementForXMLElement:xmlElement];
        }
        else
        {
            NSLog(@"ERROR - SelectedElementsManager domElement is NULL");
        }
    }
    else
    {
        if ([domElement isKindOfClass:[DOMElement class]] == NO)
        {
            NSLog(@"ERROR - SelectedElementsManager domElement is wrong class %@", [domElement class]);
        }
    }

    NSMutableDictionary * elementDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            xmlElement, @"xmlElement",
            domElement, @"domElement",
            nil];
    [selectedElementsDictionariesArray addObject:elementDictionary];
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
        
        DOMDocument * domDocument = (self.macSVGDocumentWindowController.svgWebKitController.svgWebView).mainFrame.DOMDocument;
        
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
                    
                    parentDOMElement = [self.macSVGDocumentWindowController.svgWebKitController domElementForMacsvgid:parentMacsvgid];
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
//	selectedXMLElementIDs
//==================================================================================

- (NSArray *)selectedXMLElementIDs
{
    NSMutableArray * resultArray = [NSMutableArray array];
    
    for (NSDictionary * selectedItemDictionary in selectedElementsDictionariesArray)
    {
        NSXMLElement * aElement = selectedItemDictionary[@"xmlElement"];
        
        if (aElement != NULL)
        {
            NSXMLNode * MacsvgidNode = [aElement attributeForName:@"macsvgid"];
            NSString * macsvgid = MacsvgidNode.stringValue;

            if (macsvgid != NULL)
            {
                [resultArray addObject:macsvgid];
            }
        }
    }
    
    return resultArray;
}

//==================================================================================
//	replaceDOMElement:newElement:
//==================================================================================

- (void)replaceDOMElement:(DOMElement *)oldElement newElement:(DOMElement *)newElement
{
    for (NSMutableDictionary * selectedItemDictionary in selectedElementsDictionariesArray)
    {
        DOMElement * aElement = selectedItemDictionary[@"domElement"];
        
        if (aElement == oldElement)
        {
            selectedItemDictionary[@"domElement"] = newElement;
            break;
        }
    }
}




@end
