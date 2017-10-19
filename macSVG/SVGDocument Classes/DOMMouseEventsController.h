//
//  DOMMouseEventsController.h
//  macSVG
//
//  Created by Douglas Ward on 1/25/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DOMSelectionControlsManager;

// mouseMode values
enum {
    MOUSE_UNSPECIFIED = 0,
    MOUSE_DISENGAGED = 1,
    MOUSE_DRAGGING = 2,
    MOUSE_HOVERING = 3
};

@class MacSVGDocumentWindowController;
@class SVGWebKitController;
@class SVGXMLDOMSelectionManager;
@class SVGWebView;
@class SVGPathEditor;
@class SVGPolylineEditor;
@class SVGLineEditor;
@class DOMNode;
@class DOMElement;
@class DOMEvent;
@class DOMMouseEvent;

@interface DOMMouseEventsController : NSObject
{
    IBOutlet SVGWebView * svgWebView;
    IBOutlet SVGWebKitController * svgWebKitController;
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;
    IBOutlet DOMSelectionControlsManager * domSelectionControlsManager;

    //DOMNode * clickTarget;
    int mouseMoveCount;
    
    BOOL selectionHandleClicked;
    NSString * handle_orientation;  // static string, e.g. @"topLeft"
}

@property (strong) IBOutlet SVGXMLDOMSelectionManager * svgXMLDOMSelectionManager;

@property (assign) NSInteger mouseMode;

@property (strong) DOMNode * currentMouseTarget;
@property (strong) DOMNode * clickTarget;
@property (strong) DOMElement * targetParentDOMElement;

// previous mouse points

@property (assign) NSPoint previousMouseClientPoint;
@property (assign) NSPoint previousMousePagePoint;
@property (assign) NSPoint previousMouseScreenPoint;

@property (assign) NSPoint previousTransformedMouseClientPoint;
@property (assign) NSPoint previousTransformedMousePagePoint;
@property (assign) NSPoint previousTransformedMouseScreenPoint;

// current mouse points, after scaling with web view zoom factor

@property (assign) NSPoint currentMouseClientPoint;
@property (assign) NSPoint currentMousePagePoint;
@property (assign) NSPoint currentMouseScreenPoint;

@property (assign) NSPoint transformedCurrentMouseClientPoint;
@property (assign) NSPoint transformedCurrentMousePagePoint;
@property (assign) NSPoint transformedCurrentMouseScreenPoint;

// mouse click points

@property (assign) NSPoint clickMouseClientPoint;
@property (assign) NSPoint clickMousePagePoint;
@property (assign) NSPoint clickMouseScreenPoint;

@property (assign) NSPoint transformedClickMouseClientPoint;
@property (assign) NSPoint transformedClickMousePagePoint;
@property (assign) NSPoint transformedClickMouseScreenPoint;


@property (strong) NSDictionary * validElementsForTransformDictionary;

@property (weak) IBOutlet SVGPathEditor * svgPathEditor;
@property (weak) IBOutlet SVGPolylineEditor * svgPolylineEditor;
@property (weak) IBOutlet SVGLineEditor * svgLineEditor;

- (void) setMouseMode:(NSInteger)newMode;

- (void) setCurrentMousePointsWithDOMMouseEvent:(DOMMouseEvent *)mouseEvent transformTargetDOMElement:(DOMElement *)transformTargetDOMElement;
- (void) setPreviousMousePointsWithCurrentMousePoints;

- (void) updatePathMode:(NSString *)newPathMode;

- (void) handleMouseDownEvent:(DOMEvent *)event;
- (void) handleMouseMoveOrHoverEvent:(DOMEvent *)event;
- (void) handleMouseUpEvent:(DOMEvent *)event;
- (void) handleMouseDoubleClickEvent:(DOMEvent *)event;
- (void) handlePluginEvent:(DOMEvent *)event;

- (void) endPathDrawing;
- (void) endPolylineDrawing;
- (void) endLineDrawing;
- (void) endTextEditing;

-(void) handleCrosshairToolSelectionForPathXMLElement:(NSXMLElement *)pathXMLElement
        handleDOMElement:(DOMElement *)handleDOMElement;
-(void) handleCrosshairToolSelectionForPolylineXMLElement:(NSXMLElement *)polylineXMLElement
        handleDOMElement:(DOMElement *)handleDOMElement;
-(void) handleCrosshairToolSelectionForLineXMLElement:(NSXMLElement *)polylineXMLElement
        handleDOMElement:(DOMElement *)handleDOMElement;

-(NSPoint) transformPoint:(NSPoint)aMousePoint targetElement:(DOMElement *)targetElement;

@end
