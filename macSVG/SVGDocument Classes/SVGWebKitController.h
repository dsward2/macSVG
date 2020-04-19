//
//  SVGWebKitController.h
//  macSVG
//
//  Created by Douglas Ward on 9/18/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class MacSVGDocumentWindowController;
@class SVGWebView;
@class DOMMouseEventsController;
@class DOMNode;
@class DOMElement;
@class DOMDocument;
@class SVGXMLDOMSelectionManager;
@class DOMSelectionControlsManager;

#define svgNamespace @"http://www.w3.org/2000/svg"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface SVGWebKitController : NSObject
{
}

@property (weak) IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;
@property (weak) IBOutlet DOMSelectionControlsManager * domSelectionControlsManager;
@property (weak) IBOutlet SVGXMLDOMSelectionManager * svgXMLDOMSelectionManager;
@property (weak) IBOutlet NSTextField * currentTimeTextField;
@property (weak) DOMDocument * previousDomDocument;  // used to detect domDocument changed

@property (strong) NSTimer * periodicTimer;

@property (weak) IBOutlet SVGWebView * svgWebView;
@property (weak) IBOutlet DOMMouseEventsController * domMouseEventsController;
@property (assign) BOOL mainFrameIsLoading;
@property (assign) time_t lastLoadFinishedTime;

@property (assign) BOOL webKitInspectorIsOpen;
@property (assign) BOOL webKitInspectorIsAttached;
@property (assign) BOOL javaScriptIsDisabled;

@property (assign) NSPoint mainFrameScrollToPoint;
@property (assign) BOOL scrollToPointAfterMainFrameLoad;

@property (assign) DOMTimeStamp lastMouseUpDOMTimeStamp;

- (NSPoint) scaleForDOMElementHandles:(DOMElement *)domElement;
- (float) maxScaleForDOMElementHandles:(DOMElement *)domElement;

- (IBAction)showWebKitInspectorAction:(id)sender;
- (IBAction)detachWebKitInspectorAction:(id)sender;
- (IBAction)disableJavaScriptAction:(id)sender;
- (IBAction)enableJavaScriptProfilingAction:(id)sender;
- (IBAction)enableTimelineProfilingAction:(id)sender;
- (IBAction)startDebuggingJavaScriptAction:(id)sender;
- (IBAction)startProfilingJavaScriptAction:(id)sender;

- (void)enableJavaScript;
- (void)disableJavaScript;

- (void)configureWebKitMenu;

- (void)reloadView;
- (void)willCloseSVGWebView;

- (IBAction)restartAnimationButtonClicked:(id)sender;
- (IBAction)pausePlayAnimationButtonClicked:(id)sender;

- (DOMElement *)domElementForMacsvgid:(NSString *)macsvgid;
- (void) addDOMElementForXMLElement:(NSXMLElement *)aElement;

- (void)stopPeriodicTimer;

- (void) updateElementAttributes:(NSXMLElement *)aElement;

- (void) setDOMVisibility:(NSString *)visibility forMacsvgid:(NSString *)macsvgid;

- (void)updateSelections;
- (void) updateLiveCoordinates;

- (void)reloadRulerViews;

@property (copy) NSMutableArray *pathSegmentsArray;
- (NSMutableArray *)buildPathSegmentsArrayWithPathString:(NSString *)pathString;
- (void)updatePathSegmentsAbsoluteValues:(NSMutableArray *)pathSegmentsArray;
- (void)updateActivePathInDOM:(BOOL)updatePathLength;
- (void)updateSelectedPathInDOM:(BOOL)updatePathLength;
//- (void)updatePathInDOMForElement:(DOMElement *)pathElement pathSegmentsArray:(NSArray *)aPathSegmentsArray;
- (void)updatePathInDOMForElement:(DOMElement *)pathElement pathSegmentsArray:(NSArray *)aPathSegmentsArray  updatePathLength:(BOOL)updatePathLength;

- (NSPoint)endPointForSegmentIndex:(NSInteger)segmentIndex
        pathSegmentsArray:(NSArray *)aPathSegmentsArray;

@property (readonly, strong) id svgPathEditorSelectedPathElement;   // returns NSXMLElement
- (void)buildPathSegmentsArray:(NSXMLElement *)pathElement;
- (void)svgPathEditorSetSelectedPathElement:(NSXMLElement *)aSelectedPathElement;

- (void)walkDOMNodeTree:(DOMNode *)parent level:(unsigned int)level;

- (void)setScrollToPoint:(NSPoint)scrollToPoint;

@end

#pragma clang diagnostic pop
