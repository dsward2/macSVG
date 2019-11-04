//
//  SVGXMLDOMSelectionManager.h
//  macSVG
//
//  Created by Douglas Ward on 3/25/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DOMElement;
@class MacSVGDocumentWindowController;
@class SVGWebView;
@class SVGWebKitController;
@class SelectedElementsManager;
@class DOMSelectionControlsManager;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


// Selection management notes -
// XMLOutlineView is the primary selection manager, containing the "source of truth" master copy of SVG XML data.
// SelectedElementsManager manages selectedElementsArray for multiple XML/DOM elements
// SVGXMLDOMSelectionManager manages activeElement for creation and live editing, usually during mouse-down
// DOMSelectionControlsManager manages keyElement with handles, and selection rects
// MacSVGPlugin manages pluginTargetXMLElement and pluginTargetDOMElement
// XMLAttributesTableController manages xmlElementForAttributesTable

@interface SVGXMLDOMSelectionManager : NSObject
{
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;
    IBOutlet SVGWebView * svgWebView;
    IBOutlet SVGWebKitController * svgWebKitController;
}

@property (strong) SelectedElementsManager * selectedElementsManager;
@property (strong) IBOutlet DOMSelectionControlsManager * domSelectionControlsManager;
@property (strong) NSXMLElement * activeXMLElement;
@property (strong) NSMutableArray * pathSegmentsArray;      // array of path segment dictionaries

@property (readonly, copy) DOMElement *activeDOMElement;    // result corresponds to activeXMLElement
- (DOMElement *)createTemporaryDOMElementForXMLElement:(NSXMLElement *)aXmlElement;
- (void) selectXMLElement:(NSXMLElement *)aElement;
-(void) selectXMLElementAndChildNodes:(NSXMLElement *)aXMLElement;
- (void) setSelectedXMLElements:(NSArray *)selectedXMLElements;
- (void) syncSelectedDOMElementsToXMLDocument;
- (void) recursiveBuildDOMElementsDictionary:(NSMutableDictionary *)domElementsDictionary
        parent:(DOMElement *)parent depth:(unsigned int)depth;
- (void) resyncDOMElementsInSelectedElementsArray;

@end

#pragma clang diagnostic pop
