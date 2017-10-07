//
//  SVGPathEditor.h
//  macSVG
//
//  Created by Douglas Ward on 11/14/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class SVGWebKitController;
@class MacSVGDocumentWindowController;
@class DOMMouseEventsController;
@class SVGXMLDOMSelectionManager;
@class ToolSettingsPopoverViewController;

#define kPathEditingModeNotActive 0
#define kPathEditingModeCurrentSegment 1
#define kPathEditingModePreviousSegment 2
#define kPathEditingModeNextSegment 2

@interface SVGPathEditor : NSObject
{
    int editingMode;
    
    IBOutlet SVGWebKitController * svgWebKitController;
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;  
    IBOutlet SVGXMLDOMSelectionManager * svgXMLDOMSelectionManager;
    IBOutlet DOMMouseEventsController * domMouseEventsController;
    IBOutlet ToolSettingsPopoverViewController * toolSettingsPopoverViewController;
}

@property(assign) BOOL useRelativePathCoordinates;
@property(assign) BOOL closePathAutomatically;
@property(assign) BOOL curveSegmentContinuity;
@property(assign) BOOL highlightSelectedSegment;

@property(strong) NSMutableArray * pathSegmentsArray;     // array of path segment dictionaries
@property(strong) NSXMLElement * selectedPathElement;
@property(assign) NSInteger pathSegmentIndex;
@property(strong) NSString * pathEditingKey;

@property(strong) NSString * largeArcFlagString;
@property(strong) NSString * sweepFlagString;
@property(strong) NSString * xAxisRotationString;
@property(strong) NSString * pathRadiusXString;
@property(strong) NSString * pathRadiusYString;

@property(strong) NSArray * parametersMoveto;
@property(strong) NSArray * parametersLineto;
@property(strong) NSArray * parametersHorizontalLineto;
@property(strong) NSArray * parametersVerticalLineto;
@property(strong) NSArray * parametersCubicCurveto;
@property(strong) NSArray * parametersCubicCurvetoSmooth;
@property(strong) NSArray * parametersQuadraticCurveto;
@property(strong) NSArray * parametersQuadraticCurvetoSmooth;
@property(strong) NSArray * parametersEllipticalArc;
@property(strong) NSArray * parametersClosepath;

@property(strong) DOMElement * activeHandleDOMElement;

- (void) startPath;
- (void) extendPath;
- (void) modifyPath;
- (void) editPath;
- (void) handleMouseHoverEventForPath:(DOMEvent *)event;

-(void) updatePathMode:(NSString *)newPathMode;

- (void)updateActivePathInDOM;
- (void)updateSelectedPathInDOM;

- (void)updatePathInDOMForElement:(DOMElement *)pathElement pathSegmentsArray:(NSArray *)aPathSegmentsArray;

- (void)buildPathSegmentsArray:(NSXMLElement *)pathElement;

- (NSMutableArray *)buildPathSegmentsArrayWithPathString:(NSString *)pathString;
- (NSString *)buildPathStringWithPathSegmentsArray:(NSArray *)aPathSegmentsArray;

- (void)updatePathSegmentsAbsoluteValues:(NSMutableArray *)aPathSegmentsArray;

//-(void) makePathHandles;
-(void) makePathHandlesForXMLElement:(NSXMLElement *)pathXMLElement;

- (void)resetPathSegmentsArray;

- (void)deleteLastSegmentInPath;

- (void)offsetPath:(DOMElement *)pathElement deltaX:(float)deltaX deltaY:(float)deltaY;

//- (BOOL)findClickedPathSegmentHandle;
- (NSInteger)setActiveDOMHandle:(DOMElement *)handleDOMElement;


- (NSInteger)didBeginPathEditingWithTargetXMLElement:(NSXMLElement *)targetXMLElement handleDOMElement:(DOMElement *)handleDOMElement;

- (void)removePathHandles;

- (void)restartLastPathSegment;

- (NSPoint)endPointForSegmentIndex:(NSInteger)segmentIndex
        pathSegmentsArray:(NSArray *)aPathSegmentsArray;

@end
