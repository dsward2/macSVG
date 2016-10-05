//
//  SelectedElementsManager.m
//  macSVG
//
//  Created by Douglas Ward on 7/3/13.
//
//

#import "SelectedElementsManager.h"
#import <WebKit/WebKit.h>
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
        NSLog(@"ERROR - SelectedElementsManager domElement is NULL");
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
