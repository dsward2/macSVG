//
//  SVGPolylineEditor.h
//  macSVG
//
//  Created by Douglas Ward on 9/6/16.
//
//

// Used for both polyline and polygon elements

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class SVGWebKitController;
@class MacSVGDocumentWindowController;
@class DOMMouseEventsController;
@class SVGXMLDOMSelectionManager;
@class ToolSettingsPopoverViewController;

#define kPolylineEditingModeNotActive 0
#define kPolylineEditingModeNextActive 1

@interface SVGPolylineEditor : NSObject
{
    int editingMode;
    
    IBOutlet SVGWebKitController * svgWebKitController;
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;  
    IBOutlet SVGXMLDOMSelectionManager * svgXMLDOMSelectionManager;
    IBOutlet DOMMouseEventsController * domMouseEventsController;
    IBOutlet ToolSettingsPopoverViewController * toolSettingsPopoverViewController;
}

@property(strong) NSMutableArray * polylinePointsArray;     // array of dictionaries of x,y points
@property(strong) NSXMLElement * selectedPolylineElement;
@property(assign) NSInteger polylinePointIndex;
@property(assign) DOMElement * activeHandleDOMElement;
@property(assign) BOOL highlightSelectedPoint;

- (void)startPolyline;
- (void)editPolyline;

- (void)updateActivePolylineInDOM;
- (void)updateSelectedPolylineInDOM;

- (void) handleMouseHoverEventForPolyline:(DOMEvent *)event;

- (void)updatePolylineInDOMForElement:(DOMElement *)polylineElement polylinePointsArray:(NSArray *)aPolylinePointsArray;

- (void)buildPolylinePointsArray:(NSXMLElement *)polylineElement;

- (NSMutableArray *)buildPolylinePointsArrayWithPointsString:(NSString *)pointsString;
- (NSString *)buildStringWithPolylinePointsArray:(NSArray *)aPolylinePointsArray;

- (void) makePolylineHandles;
- (void)removePolylineHandles;

- (void)resetPolylinePointsArray;

- (NSInteger)setActiveDOMHandle:(DOMElement *)handleDOMElement;

- (NSInteger)didBeginPolylineEditingWithTargetXMLElement:(NSXMLElement *)targetXmlElement
        handleDOMElement:(DOMElement *)handleDOMElement;

-(void) deleteLastLineInPolyline;

@end
