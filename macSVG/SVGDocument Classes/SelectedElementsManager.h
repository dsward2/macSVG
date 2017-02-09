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
@class MacSVGDocumentWindowController;

@interface SelectedElementsManager : NSObject
{
}

@property (readonly, copy) NSMutableArray *selectedElementsArray;
@property (readonly, copy) NSArray *selectedXMLElementIDs;
@property (readonly) NSUInteger selectedElementsCount;
@property (readonly) NSInteger drawableSelectedElementsCount;
@property (strong) MacSVGDocumentWindowController * macSVGDocumentWindowController;

- (NSDictionary *)elementDictionaryAtIndex:(NSUInteger)elementIndex;
- (NSXMLElement *)xmlElementAtIndex:(NSUInteger)elementIndex;
- (DOMElement *)domElementAtIndex:(NSUInteger)elementIndex;

@property (readonly, copy) NSXMLElement *firstXmlElement;
@property (readonly, copy) DOMElement *firstDomElement;
//@property (readonly, strong) DOMElement *firstDomElement;

- (void)addElementDictionaryWithXMLElement:(NSXMLElement *)xmlElement
        domElement:(DOMElement *)domElement;

- (void)removeElementDictionary:(NSDictionary *)aDictionary;
- (void)removeAllElements;

- (void)replaceDOMElement:(DOMElement *)oldElement newElement:(DOMElement *)newElement;

@end
