//
//  SelectedElementsManager.h
//  macSVG
//
//  Created by Douglas Ward on 7/3/13.
//
//

#import <Foundation/Foundation.h>

@class NSXMLElement;
@class DOMElement;
@class DOMSVGSVGElement;

@interface SelectedElementsManager : NSObject
{
}

- (NSMutableArray *)selectedElementsArray;
- (NSArray *)selectedXMLElementIDs;
- (NSUInteger)selectedElementsCount;

- (NSDictionary *)elementDictionaryAtIndex:(NSUInteger)elementIndex;
- (NSXMLElement *)xmlElementAtIndex:(NSUInteger)elementIndex;
- (DOMElement *)domElementAtIndex:(NSUInteger)elementIndex;

- (NSXMLElement *)firstXmlElement;
- (DOMElement *)firstDomElement;

- (void)addElementDictionaryWithXMLElement:(NSXMLElement *)xmlElement
        domElement:(DOMElement *)domElement;

- (void)removeElementDictionary:(NSDictionary *)aDictionary;
- (void)removeAllElements;

- (void)replaceDOMElement:(DOMElement *)oldElement newElement:(DOMElement *)newElement;

@end
