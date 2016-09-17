//
//  MacSVGDocumentWindowController.h
//  macSVG
//
//  Created by Douglas Ward on 7/29/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SVGXMLDOMSelectionManager;
@class XMLOutlineController;
@class XMLAttributesTableController;
@class SVGWebKitController;
@class HorizontalRulerView;
@class VerticalRulerView;
@class SVGElementsTableController;
@class AnimationTimelineView;
@class EditorUIFrameController;
@class EmbeddedFontEncoder;
@class DOMEvent;
@class ToolSettingsPopoverViewController;
@class SVGHelpManager;
@class DOMElement;
@class SVGtoCoreGraphicsConverter;
@class PathFunctions;

@interface MacSVGDocumentWindowController : NSWindowController <NSSplitViewDelegate, NSMenuDelegate>
{
    IBOutlet NSView * infoView;
    IBOutlet NSTextField * selectedElementID;
    IBOutlet NSTextField * selectedElementBounds;

    @private

    IBOutlet NSTextView * detailTextView;
    IBOutlet NSFormCell * selectionOutput;
	IBOutlet NSTextView * infoTextView;
    IBOutlet NSTextView * xmlElementTextView;
    
    IBOutlet NSButton * svgElementsButton;
    IBOutlet NSButton * svgToolsButton;
    
    IBOutlet NSView * toolsAndElementsView;
    IBOutlet NSView * svgElementsPanel;
    IBOutlet NSView * svgToolsPanel;
    
    IBOutlet NSButton * arrowToolButton;
    IBOutlet NSButton * crosshairToolButton;
    IBOutlet NSButton * rectToolButton;
    IBOutlet NSButton * circleToolButton;
    IBOutlet NSButton * ellipseToolButton;
    IBOutlet NSButton * textToolButton;
    IBOutlet NSButton * imageToolButton;
    IBOutlet NSButton * lineToolButton;
    IBOutlet NSButton * polylineToolButton;
    IBOutlet NSButton * polygonToolButton;
    IBOutlet NSButton * pathToolButton;
    IBOutlet NSButton * pluginToolButton;
    
    IBOutlet NSSplitView * fullWindowTopBottomSplitView;    // full window top/bottom
    IBOutlet NSSplitView * leftMiddleRightSplitView;        // elements(left)/webview(middle)/attributes(right)
    IBOutlet NSSplitView * elementsTopBottomSplitView;      // top/bottom
    IBOutlet NSSplitView * attributesTopBottomSplitView;    // top/bottom
    IBOutlet NSSplitView * timelineLeftRightSplitView;      // left/right
    
    IBOutlet NSButton * webBrowserPreviewButton;
    IBOutlet NSSearchField * svgSearchField;
    
    IBOutlet SVGtoCoreGraphicsConverter * svgToCoreGraphicsConverter;
        
    NSArray * toolButtonsArray;
    
    NSXMLNode * selectedNode;
        
	float rulerScale;
    IBOutlet HorizontalRulerView * horizontalRulerView;
    IBOutlet VerticalRulerView * verticalRulerView;
}

@property(assign) NSUInteger currentToolMode;
@property(assign) BOOL creatingNewElement;

@property(strong) NSMutableArray * pluginsArray;
@property(strong) NSString * selectedPathMode;
@property(strong) NSString * currentTimeString;
@property(weak) IBOutlet PathFunctions * pathFunctions;

@property(weak) IBOutlet NSWindow * generateHTML5VideoSheet;
@property(weak) IBOutlet NSTextField * videoWidthTextField;
@property(weak) IBOutlet NSTextField * videoHeightTextField;
@property(weak) IBOutlet NSTextField * videoStartTimeTextField;
@property(weak) IBOutlet NSTextField * videoEndTimeTextField;
@property(weak) IBOutlet NSTextField * videoFramesPerSecondTextField;
@property(weak) IBOutlet NSButton * videoOKButton;
@property(weak) IBOutlet NSButton * videoCancelButton;

@property(weak) IBOutlet NSWindow * generatingHTML5VideoSheet;
@property(weak) IBOutlet NSTextField * generatingVideoPathTextField;
@property(weak) IBOutlet NSTextField * generatingVideoWidthTextField;
@property(weak) IBOutlet NSTextField * generatingVideoHeightTextField;
@property(weak) IBOutlet NSTextField * generatingVideoStartTimeTextField;
@property(weak) IBOutlet NSTextField * generatingVideoEndTimeTextField;
@property(weak) IBOutlet NSTextField * generatingVideoCurrentTimeTextField;
@property(weak) IBOutlet NSTextField * generatingVideoFramesPerSecondTextField;
@property(weak) IBOutlet NSButton * generatingVideoCancelButton;


@property(strong) NSMutableDictionary * imageDictionary; // see ImageElementEditor plugin for description

@property(weak) IBOutlet SVGXMLDOMSelectionManager * svgXMLDOMSelectionManager;

@property(weak) IBOutlet AnimationTimelineView * animationTimelineView;
@property(weak) IBOutlet XMLOutlineController * xmlOutlineController;
@property(weak) IBOutlet SVGElementsTableController * svgElementsTableController;
@property(weak) IBOutlet EditorUIFrameController * editorUIFrameController;
@property(weak) IBOutlet XMLAttributesTableController * xmlAttributesTableController;
@property(weak) IBOutlet SVGWebKitController * svgWebKitController;
@property(weak) IBOutlet EmbeddedFontEncoder * embeddedFontEncoder;
@property(weak) IBOutlet NSTextField * liveCoordinatesTextField;
//@property(weak) IBOutlet NSTextField * liveInfoTextField;
@property(weak) IBOutlet NSButton * enableAnimationCheckbox;
@property(weak) IBOutlet NSButton * pausePlayAnimationButton;

@property(weak) IBOutlet NSButton * showElementHelpButton;
@property(weak) IBOutlet NSButton * showAttributeHelpButton;

@property(weak) IBOutlet NSPopover * toolSettingsPopover;
@property(weak) IBOutlet ToolSettingsPopoverViewController * toolSettingsPopoverViewController;

@property(weak) IBOutlet SVGHelpManager * svgHelpManager;

@property(weak) NSView * currentToolSettingsView;

@property(weak) IBOutlet NSButton * strokeCheckboxButton;
@property(weak) IBOutlet NSButton * fillCheckboxButton;

@property(weak) IBOutlet NSColorWell * strokeColorWell;
@property(weak) IBOutlet NSColorWell * fillColorWell;
    
@property(weak) IBOutlet NSTextField * strokeWidthTextField;
@property(weak) IBOutlet NSPopUpButton * strokeWidthUnitPopUpButton;
@property(weak) IBOutlet NSStepper * strokeWidthStepper;

@property(assign) BOOL rectStrokeEnabled;
@property(assign) BOOL rectFillEnabled;
@property(assign) float rectStrokeWidth;
@property(assign) NSString * rectUnit;
@property(strong) NSColor * rectStrokeColor;
@property(strong) NSColor * rectFillColor;

@property(assign) BOOL circleStrokeEnabled;
@property(assign) BOOL circleFillEnabled;
@property(assign) float circleStrokeWidth;
@property(assign) NSString * circleUnit;
@property(strong) NSColor * circleStrokeColor;
@property(strong) NSColor * circleFillColor;

@property(assign) BOOL ellipseStrokeEnabled;
@property(assign) BOOL ellipseFillEnabled;
@property(assign) float ellipseStrokeWidth;
@property(assign) NSString * ellipseUnit;
@property(strong) NSColor * ellipseStrokeColor;
@property(strong) NSColor * ellipseFillColor;

@property(assign) BOOL polylineStrokeEnabled;
@property(assign) BOOL polylineFillEnabled;
@property(assign) float polylineStrokeWidth;
@property(assign) NSString * polylineUnit;
@property(strong) NSColor * polylineStrokeColor;
@property(strong) NSColor * polylineFillColor;

@property(assign) BOOL polygonStrokeEnabled;
@property(assign) BOOL polygonFillEnabled;
@property(assign) float polygonStrokeWidth;
@property(assign) NSString * polygonUnit;
@property(strong) NSColor * polygonStrokeColor;
@property(strong) NSColor * polygonFillColor;

@property(assign) BOOL lineStrokeEnabled;
@property(assign) BOOL lineFillEnabled;
@property(assign) float lineStrokeWidth;
@property(assign) NSString * lineUnit;
@property(strong) NSColor * lineStrokeColor;
@property(strong) NSColor * lineFillColor;

@property(assign) BOOL textStrokeEnabled;
@property(assign) BOOL textFillEnabled;
@property(assign) float textStrokeWidth;
@property(assign) NSString * textUnit;
@property(strong) NSColor * textStrokeColor;
@property(strong) NSColor * textFillColor;

@property(assign) BOOL imageStrokeEnabled;
@property(assign) BOOL imageFillEnabled;
@property(assign) float imageStrokeWidth;
@property(assign) NSString * imageUnit;
@property(strong) NSColor * imageStrokeColor;
@property(strong) NSColor * imageFillColor;

@property(assign) BOOL pathStrokeEnabled;
@property(assign) BOOL pathFillEnabled;
@property(assign) float pathStrokeWidth;
@property(assign) NSString * pathUnit;
@property(strong) NSColor * pathStrokeColor;
@property(strong) NSColor * pathFillColor;

@property (weak) IBOutlet NSButton * toolSettingsButton;

@property(strong) NSMutableArray * menuPlugInsArray;

@property(strong) id svgLoadFinishedObserver;

- (void) reloadAllViews;
- (void) reloadWebView;
- (void) reloadData;
- (void) reloadAttributesTableData;
- (void) setAttributesForXMLNode:(NSXMLNode *)newSelectedNode;
- (void) expandElementInOutline:(NSXMLElement *)aElement;
- (NSMutableArray *)selectedElementsArray;

- (NSArray *)selectedItemsInOutlineView;

- (void) updateXMLOutlineViewSelections;
- (void) updateXMLTextContent:(NSString *)textContent macsvgid:(NSString *)macsvgid;

//- (void) setAnimationCurrentTime:(NSString *)currentTime;

- (void) userChangedElement:(NSXMLElement *)aElement attributes:(NSMutableArray *)xmlAttributesArray;
- (void) addDOMElementForXMLElement:(NSXMLElement *)aElement;

- (void)setToolMode:(NSUInteger)newToolMode;
- (IBAction)toolButtonAction:(id)sender;
- (IBAction)svgElementsButtonClicked:(id)sender;
- (IBAction)svgToolsButtonClicked:(id)sender;

- (IBAction)launchWebBrowserPreview:(id)sender;
- (IBAction)showPopoverAction:(id)sender;

//- (IBAction)launchWebBrowserDocument:(id)sender;

- (IBAction)strokeCheckboxButtonAction:(id)sender;
- (IBAction)fillCheckboxButtonAction:(id)sender;
- (IBAction)strokeColorWellAction:(id)sender;
- (IBAction)fillColorWellAction:(id)sender;
- (IBAction)strokeWidthStepperAction:(id)sender;
- (IBAction)strokeWidthTextFieldAction:(id)sender;
- (IBAction)strokeWidthUnitPopUpButtonAction:(id)sender;

- (IBAction)svgSearchFieldAction:(id)sender;

- (IBAction)generateCoreGraphicsCode:(id)sender;
- (IBAction)generateHTML5Video:(id)sender;

- (NSString *)strokeColorString;
- (NSString *)fillColorString;
- (NSString *)strokeWidthString;

- (void)selectXMLElement:(NSXMLElement *)selectedElement;

//- (IBAction)pathModePopUpButtonAction:(id)sender;

//- (NSString *)strokeColorString;
//- (NSString *)fillColorString;

//- (NSString *) selectedPathMode;

- (void) endPathDrawing;
- (void) endPolylineDrawing;

- (void) setDOMVisibility:(NSString *)visibility forMacsvgid:(NSString *)macsvgid;

- (void)beginArrowToolMode;

- (void)beginPluginEditorToolMode;  // called from MacSVGDocument when a plugin needs mouse control
- (void) handlePluginEvent:(DOMEvent *)event;

- (void)updateSelections;

- (void)enableEditMenuItems;

- (void) assignElementIDIfUnassigned:(NSXMLNode *)aNode;
- (NSString *)newMacsvgid;

- (void) revealElementInXMLOutline:(NSXMLElement *)aElement;

- (IBAction)showElementDocumentation:(id)sender;
- (IBAction)showAttributeDocumentation:(id)sender;

- (NSString *)addCSSStyleName:(NSString *)styleName styleValue:(NSString *)styleValue toXMLElement:(NSXMLElement *)targetElement;
- (NSString *)addCSSStyleName:(NSString *)styleName styleValue:(NSString *)styleValue toDOMElement:(DOMElement *)targetElement;

- (void)setWebViewCursor;

@end

// values of defines should correspond to toolButtonsArray in implementation
#define toolModeNone 0
#define toolModeArrowCursor 1
#define toolModeRect 2
#define toolModeCircle 3
#define toolModeEllipse 4
#define toolModeCrosshairCursor 5
#define toolModePolyline 6
#define toolModePolygon 7
#define toolModeLine 8
#define toolModePlugin 9
#define toolModeText 10
#define toolModeImage 11
#define toolModePath 12
