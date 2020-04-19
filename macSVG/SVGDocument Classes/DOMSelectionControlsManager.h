//
//  DOMSelectionControlsManager.h
//  macSVG
//
//  Created by Douglas Ward on 9/9/13.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


// Supports selection rects for multiple elements, but note: only one element should have handles

@class DOMElement;
@class SVGWebView;
@class SVGXMLDOMSelectionManager;
@class SVGWebKitController;
@class ToolSettingsPopoverViewController;
@class MacSVGDocumentWindowController;

@interface DOMSelectionControlsManager : NSObject
{
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;
    IBOutlet SVGWebView * svgWebView;
    IBOutlet SVGWebKitController * svgWebKitController;
    IBOutlet SVGXMLDOMSelectionManager * svgXMLDOMSelectionManager;
    IBOutlet ToolSettingsPopoverViewController * toolSettingsPopoverViewController;
}
@property (strong) NSDictionary * validElementsForTransformDictionary;
@property (strong) DOMElement * domElementForHandles;
@property (assign) time_t domElementForHandlesCreationTime;

@property(assign) float segmentStrokeWidth;
@property(strong) NSString * segmentStrokeHexColor;

- (void) makeDOMSelectionRects;

- (void) makeDOMSelectionHandles:(DOMElement *)aDomElement;

- (void) updateDOMSelectionRectsAndHandles;

- (void) removeDOMSelectionRectsAndHandles;

@property (readonly, copy) NSXMLElement *keyXMLElement;

-(void) removeDOMPathSegmentHighlight;
-(void) removeDOMPolylinePointHighlight;
-(void) removeDOMLinePointHighlight;

- (IBAction)highlightPathSegment;
- (IBAction)highlightPolylinePoint;
- (IBAction)highlightLinePoint;

@property (readonly, copy) DOMElement *macsvgTopGroupElement;
- (DOMElement *)getMacsvgTopGroupChildByID:(NSString *)idString createIfNew:(BOOL)createIfNew;
- (void)setMacsvgTopGroupChild:(DOMElement *)childElement;
- (void)removeMacsvgTopGroupChildByID:(NSString *)idString;
- (void)removeMacsvgTopGroupChildByClass:(NSString *)classString;

- (void)addPluginSelectionHandleWithDOMElement:(DOMElement *)aDomElement
        handlesGroup:(DOMElement *)newSelectionHandlesGroup
        x:(float)x y:(float)y handleName:(NSString *)handleName
        pluginName:(NSString *)pluginName;

@end


#pragma clang diagnostic pop
