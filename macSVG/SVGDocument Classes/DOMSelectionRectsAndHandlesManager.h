//
//  DOMSelectionRectsAndHandlesManager.h
//  macSVG
//
//  Created by Douglas Ward on 9/9/13.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

// Supports selection rects for multiple elements, but only one element should have handles

@class DOMElement;
@class SVGWebView;
@class SVGXMLDOMSelectionManager;
@class SVGWebKitController;
@class ToolSettingsPopoverViewController;
@class MacSVGDocumentWindowController;

@interface DOMSelectionRectsAndHandlesManager : NSObject
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

@property(assign) CGFloat segmentStrokeWidth;
@property(strong) NSString * segmentStrokeHexColor;
//@property(assign) NSInteger pathSegmentIndex;
//@property(assign) NSInteger polylinePointIndex;

- (void) makeDOMSelectionRects;

- (void) makeDOMSelectionHandles:(DOMElement *)aDomElement;

- (void) updateDOMSelectionRectsAndHandles;

- (void) removeDOMSelectionRectsAndHandles;

- (NSXMLElement *) keyXMLElement;

-(void) removeDOMPathSegmentHighlight;
-(void) removeDOMPolylinePointHighlight;
-(void) removeDOMLinePointHighlight;

- (IBAction)highlightPathSegment;
- (IBAction)highlightPolylinePoint;
- (IBAction)highlightLinePoint;

- (DOMElement *)macsvgTopGroupElement;
- (DOMElement *)getMacsvgTopGroupChildByID:(NSString *)idString createIfNew:(BOOL)createIfNew;
- (void)setMacsvgTopGroupChild:(DOMElement *)childElement;
- (void)removeMacsvgTopGroupChildByID:(NSString *)idString;

@end
