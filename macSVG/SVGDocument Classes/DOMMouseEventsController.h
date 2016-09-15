//
//  DOMMouseEventsController.h
//  macSVG
//
//  Created by Douglas Ward on 1/25/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DOMSelectionRectsAndHandlesManager;

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

@interface DOMMouseEventsController : NSObject
{
    IBOutlet SVGWebView * svgWebView;
    IBOutlet SVGWebKitController * svgWebKitController;
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;
    IBOutlet DOMSelectionRectsAndHandlesManager * domSelectionRectsAndHandlesManager;

    //DOMNode * clickTarget;
    int mouseMoveCount;
    
    BOOL selectionHandleClicked;
    NSString * handle_orientation;  // static string, e.g. @"topLeft"
}

@property (strong) DOMNode * clickTarget;
@property (strong) IBOutlet SVGXMLDOMSelectionManager * svgXMLDOMSelectionManager;

@property (assign) int mouseMode;
@property (assign) NSPoint clickPoint;
@property (assign) NSPoint currentMousePoint;
@property (assign) NSPoint previousMousePoint;
@property (strong) NSDictionary * validElementsForTransformDictionary;

@property (weak) IBOutlet SVGPathEditor * svgPathEditor;
@property (weak) IBOutlet SVGPolylineEditor * svgPolylineEditor;
@property (weak) IBOutlet SVGLineEditor * svgLineEditor;

- (void) setMouseMode:(int)newMode;
- (void) updatePathMode:(NSString *)newPathMode;

- (void) handleMouseDownEvent:(DOMEvent *)event;
- (void) handleMouseMoveOrHoverEvent:(DOMEvent *)event;
- (void) handleMouseUpEvent:(DOMEvent *)event;
- (void) handleMouseDoubleClickEvent:(DOMEvent *)event;

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

@end
