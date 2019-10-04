//
//  SVGLineEditor.h
//  macSVG
//
//  Created by Douglas Ward on 9/13/16.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#define kLineEditingModeNotActive 0
#define kLineEditingModeActive 1

@class SVGWebKitController;
@class MacSVGDocumentWindowController;
@class DOMMouseEventsController;
@class SVGXMLDOMSelectionManager;
@class ToolSettingsPopoverViewController;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


@interface SVGLineEditor : NSObject
{
    int editingMode;
    
    IBOutlet SVGWebKitController * svgWebKitController;
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;  
    IBOutlet SVGXMLDOMSelectionManager * svgXMLDOMSelectionManager;
    IBOutlet DOMMouseEventsController * domMouseEventsController;
    IBOutlet ToolSettingsPopoverViewController * toolSettingsPopoverViewController;
}

@property(strong) NSXMLElement * selectedLineElement;
@property(assign) NSInteger linePointIndex;
@property(strong) DOMElement * activeHandleDOMElement;

- (void)startLineWithParentDOMElement:(DOMElement *)parentDOMElement;
- (void)editLine;

- (void)updateActiveLineInDOM;
- (void)updateSelectedLineInDOM;

- (void) handleMouseHoverEventForLine:(DOMEvent *)event;

- (void)updateLineInDOMForElement:(DOMElement *)lineDOMElement xmlElement:(NSXMLElement *)lineXMLElement;

//- (void) makeLineHandles;
- (void) makeLineHandlesForXMLElement:(NSXMLElement *)lineXMLElement;

- (void)removeLineHandles;

- (void)resetLinePoints;

- (NSInteger)setActiveDOMHandle:(DOMElement *)handleDOMElement;

- (NSInteger)didBeginLineEditingWithTargetXMLElement:(NSXMLElement *)targetXmlElement
        handleDOMElement:(DOMElement *)handleDOMElement;

@end


#pragma clang diagnostic pop
