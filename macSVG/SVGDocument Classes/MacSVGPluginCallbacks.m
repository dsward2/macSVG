//
//  MacSVGPluginCallbacks.m
//  macSVG
//
//  Created by Douglas Ward on 3/8/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "MacSVGPluginCallbacks.h"
#import "MacSVGDocument.h"
#import "MacSVGDocumentWindowController.h"
#import "SVGWebKitController.h"
#import "SVGWebView.h"
#import "SVGPathEditor.h"
#import "DOMMouseEventsController.h"
#import "SVGXMLDOMSelectionManager.h"


@implementation MacSVGPluginCallbacks

- (id)svgXmlDocument  
{
    // returns NSXMLDocument
    id result = [self.macSVGDocument svgXmlDocument];
    return result;
}

- (id)macSVGDocumentWindowController
{
    // returns MacSVGDocumentWindowController
    id result = [self.macSVGDocument macSVGDocumentWindowController];
    return result;
}


- (id)svgWebKitController   
{
    // returns SVGWebKitController
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id result = [macSVGDocumentWindowController svgWebKitController];
    return result;
}

- (void)setToolMode:(NSInteger)newToolMode
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    [macSVGDocumentWindowController setToolMode:newToolMode];
}

- (NSInteger)currentToolMode
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    return [macSVGDocumentWindowController currentToolMode];
}

- (void)beginPluginEditorToolMode
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    [macSVGDocumentWindowController beginPluginEditorToolMode];
}

- (void)reloadAllViews
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    [macSVGDocumentWindowController reloadAllViews];
}


- (void)updateSelections
{
    // redraw selection rectangles and handles
    [self.macSVGDocument updateSelections];
}

- (void)selectXMLElement:(NSXMLElement *)aXMLElement
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    [macSVGDocumentWindowController selectXMLElement:aXMLElement];
}


- (CGFloat)zoomFactor
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id svgWebView = [svgWebKitController svgWebView];

    CGFloat zoomFactor = [svgWebView zoomFactor];
    return zoomFactor;
}



- (NSPoint)scaleForDOMElementHandles:(DOMElement *)aDOMElement
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];

    NSPoint scalePoint = [svgWebKitController scaleForDOMElementHandles:aDOMElement];
    return scalePoint;
}


- (CGFloat)maxScaleForDOMElementHandles:(DOMElement *)aDOMElement
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];

    CGFloat scaleFactor = [svgWebKitController maxScaleForDOMElementHandles:aDOMElement];
    return scaleFactor;
}


- (void)addPluginSelectionHandleWithDOMElement:(DOMElement *)aDomElement
        handlesGroup:(DOMElement *)newSelectionHandlesGroup
        x:(CGFloat)x y:(CGFloat)y handleName:(NSString *)handleName
        pluginName:(NSString *)pluginName
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domSelectionControlsManager = [svgWebKitController domSelectionControlsManager];
    [domSelectionControlsManager addPluginSelectionHandleWithDOMElement:aDomElement
            handlesGroup:newSelectionHandlesGroup
            x:x y:y handleName:handleName pluginName:pluginName];
}


//@interface SVGWebKitController

- (id)svgWebView 
{
    // returns SVGWebView
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id svgWebView = [svgWebKitController svgWebView];
    return svgWebView;
}

- (NSMutableArray *)pathSegmentsArray
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id pathSegmentsArray = [svgWebKitController pathSegmentsArray];
    return pathSegmentsArray;
}


- (void)buildPathSegmentsArray:(NSXMLElement *)pathElement
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    [svgWebKitController buildPathSegmentsArray:pathElement];
}


- (NSMutableArray *)buildPathSegmentsArrayWithPathString:(NSString *)pathString
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id pathSegmentsArray = [svgWebKitController buildPathSegmentsArrayWithPathString:pathString];
    return pathSegmentsArray;
}


- (void)setPathSegmentsArray:(NSMutableArray *)pathSegmentsArray;
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    [svgWebKitController setPathSegmentsArray:pathSegmentsArray];
}


- (void)updatePathSegmentsAbsoluteValues:(NSMutableArray *)aPathSegmentsArray
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    [svgWebKitController updatePathSegmentsAbsoluteValues:aPathSegmentsArray];
}



- (NSPoint)endPointForSegmentIndex:(NSInteger)segmentIndex
        pathSegmentsArray:(NSArray *)aPathSegmentsArray
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    return [svgWebKitController endPointForSegmentIndex:segmentIndex pathSegmentsArray:aPathSegmentsArray];
}


- (void)setActiveXMLElement:(NSXMLElement *)aXMLElement;
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgXMLDOMSelectionManager = [macSVGDocumentWindowController svgXMLDOMSelectionManager];
    [svgXMLDOMSelectionManager setActiveXMLElement:aXMLElement];
}

- (void)updateActivePathInDOM:(BOOL)updatePathLength
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    [svgWebKitController updateActivePathInDOM:updatePathLength];
}

- (void)updateSelectedPathInDOM:(BOOL)updatePathLength
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    [svgWebKitController updateSelectedPathInDOM:updatePathLength];
}

- (void)updateDOMSelectionRectsAndHandles
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domSelectionControlsManager = [svgWebKitController domSelectionControlsManager];
    [domSelectionControlsManager updateDOMSelectionRectsAndHandles];
}

- (void)updatePathInDOMForElement:(DOMElement *)pathElement pathSegmentsArray:(NSArray *)aPathSegmentsArray
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    [svgWebKitController updatePathInDOMForElement:pathElement pathSegmentsArray:aPathSegmentsArray];
}


- (id)svgPathEditorSelectedPathElement
{
    // returns NSXMLElement
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id svgPathEditorSelectedPathElement = [svgWebKitController svgPathEditorSelectedPathElement];
    return svgPathEditorSelectedPathElement;
}

- (void)svgPathEditorSetSelectedPathElement:(NSXMLElement *)aSelectedPathElement
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    [svgWebKitController svgPathEditorSetSelectedPathElement:aSelectedPathElement];
}



- (id)mouseEventsControllerActiveDOMElement
{
    // returns DOMElement
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgXMLDOMSelectionManager = [macSVGDocumentWindowController svgXMLDOMSelectionManager];
    id activeDOMElement = [svgXMLDOMSelectionManager activeDOMElement];
    return activeDOMElement;
}

// Path creation controls

- (NSString *) selectedPathMode
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    return [macSVGDocumentWindowController selectedPathMode];
}


- (void) setSelectedPathMode:(NSString *)newValue
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    [macSVGDocumentWindowController setSelectedPathMode:newValue];
}

-(void) assignElementIDIfUnassigned:(NSXMLNode *)aNode
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    [macSVGDocumentWindowController assignElementIDIfUnassigned:aNode];
}

- (NSString *)uniqueIDForElementTagName:(NSString *)elementTagName pendingIDs:(NSArray *)pendingIDs
{
    //id macSVGDocumentWindowController = [macSVGDocument macSVGDocumentWindowController];
    //return [macSVGDocumentWindowController uniqueIDForElementTagName:elementTagName pendingIDs:pendingIDs];
    return [self.macSVGDocument uniqueIDForElementTagName:elementTagName pendingIDs:pendingIDs];
}

- (NSString *)newMacsvgid
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    return [macSVGDocumentWindowController newMacsvgid];
}

/*
- (void)pushUndoRedoElementAttributes:(NSXMLElement *)aElement
{
    //[macSVGDocument pushUndoRedoElementAttributes:aElement];
    [macSVGDocument pushUndoRedoDocumentChanges];
}

- (void)pushUndoRedoDeleteElement:(NSXMLElement *)aElement
{
    [macSVGDocument pushUndoRedoDeleteElement:aElement];
}

- (void)pushUndoRedoCreateElement:(NSXMLElement *)aElement
{
    [macSVGDocument pushUndoRedoCreateElement:aElement];
}
*/


- (void)pushUndoRedoDocumentChanges
{
    [self.macSVGDocument pushUndoRedoDocumentChanges];
}


- (BOOL) useRelativePathCoordinates
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    return [svgPathEditor useRelativePathCoordinates];
}

- (void) setUseRelativePathCoordinates:(BOOL)newValue
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    [svgPathEditor setUseRelativePathCoordinates:newValue];
}
    
- (BOOL) closePathAutomatically
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    return [svgPathEditor closePathAutomatically];
}

- (void) setClosePathAutomatically:(BOOL)newValue
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    [svgPathEditor setClosePathAutomatically:newValue];
}

- (BOOL) curveSegmentContinuity
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    return [svgPathEditor curveSegmentContinuity];
}

- (void) setCurveSegmentContinuity:(BOOL)newValue
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    [svgPathEditor setCurveSegmentContinuity:newValue];
}


// Elliptical arc parameters

- (NSString *)largeArcFlagString
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    return [svgPathEditor largeArcFlagString];
}

- (void)setLargeArcFlagString:(NSString *)newValue
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    [svgPathEditor setLargeArcFlagString:newValue];
}

- (NSString *)sweepFlagString
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    return [svgPathEditor sweepFlagString];
}

- (void)setSweepFlagString:(NSString *)newValue
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    return [svgPathEditor setSweepFlagString:newValue];
}

- (NSString *)xAxisRotationString
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    return [svgPathEditor xAxisRotationString];
}

- (void)setXAxisRotationString:(NSString *)newValue
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    [svgPathEditor setXAxisRotationString:newValue];
}

- (NSString *)pathRadiusXString
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    return [svgPathEditor pathRadiusXString];
}

- (void)setPathRadiusXString:(NSString *)newValue
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    [svgPathEditor setPathRadiusXString:newValue];
}

- (NSString *)pathRadiusYString
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    return [svgPathEditor pathRadiusYString];
}

- (void)setPathRadiusYString:(NSString *)newValue
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    [svgPathEditor setPathRadiusYString:newValue];
}

- (void)restartLastPathSegment
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    id svgPathEditor = [domMouseEventsController svgPathEditor];
    [svgPathEditor restartLastPathSegment];
}

- (NSMutableDictionary *)imageDictionary
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    NSMutableDictionary * imageDictionary = [macSVGDocumentWindowController imageDictionary];
    return imageDictionary;
}

- (void)setImageDictionary:(NSMutableDictionary *)newImageDictionary
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    [macSVGDocumentWindowController setImageDictionary:newImageDictionary];
}

- (NSString *)addCSSStyleName:(NSString *)styleName styleValue:(NSString *)styleValue toXMLElement:(NSXMLElement *)targetElement
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    return [macSVGDocumentWindowController addCSSStyleName:styleName styleValue:styleValue toXMLElement:targetElement];
}

- (NSString *)addCSSStyleName:(NSString *)styleName styleValue:(NSString *)styleValue toDOMElement:(DOMElement *)targetElement
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    return [macSVGDocumentWindowController addCSSStyleName:styleName styleValue:styleValue toDOMElement:targetElement];
}


- (NSMutableArray *)convertToAbsoluteCoordinates:(NSXMLElement *)pathElement
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions convertToAbsoluteCoordinates:pathElement];
}

- (NSMutableArray *)convertCurvesToAbsoluteCubicBezier:(NSXMLElement *)pathElement
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions convertCurvesToAbsoluteCubicBezier:pathElement];
}


- (NSMutableArray *)convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray:pathSegmentsArray];
}




- (NSMutableArray *)convertPathToAbsoluteCubicBezier:(NSXMLElement *)pathElement
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions convertPathToAbsoluteCubicBezier:pathElement];
}


- (NSMutableArray *)convertPathToAbsoluteCubicBezierWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions convertPathToAbsoluteCubicBezierWithPathSegmentsArray:pathSegmentsArray];
}





- (NSMutableArray *)reversePathWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions reversePathWithPathSegmentsArray:pathSegmentsArray];
}


- (NSMutableArray *)mirrorPathHorizontallyWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions mirrorPathHorizontallyWithPathSegmentsArray:pathSegmentsArray];
}


- (NSMutableArray *)mirrorPathVerticallyWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions mirrorPathVerticallyWithPathSegmentsArray:pathSegmentsArray];
}


- (NSMutableArray *)flipPathHorizontallyWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions flipPathHorizontallyWithPathSegmentsArray:pathSegmentsArray];
}


- (NSMutableArray *)flipPathVerticallyWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions flipPathVerticallyWithPathSegmentsArray:pathSegmentsArray];
}


- (NSMutableArray *)translatePathCoordinatesWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray x:(CGFloat)translateX y:(CGFloat)translateY
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions translatePathCoordinatesWithPathSegmentsArray:pathSegmentsArray x:translateX y:translateY];
}


- (NSMutableArray *)scalePathCoordinatesWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions scalePathCoordinatesWithPathSegmentsArray:pathSegmentsArray scaleX:scaleX scaleY:scaleY];

}

- (NSMutableArray *)rotatePathCoordinatesWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray x:(CGFloat)rotateX y:(CGFloat)rotateY degrees:(CGFloat)degrees
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions rotatePathCoordinatesWithPathSegmentsArray:pathSegmentsArray x:rotateX y:rotateY degrees:degrees];

}

- (NSMutableArray *)closePathWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions closePathWithPathSegmentsArray:pathSegmentsArray];
}


- (NSMutableArray *)rotateSegmentsWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray offset:(NSInteger)offset
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions rotateSegmentsWithPathSegmentsArray:pathSegmentsArray offset:offset];
}


- (NSDictionary *) convertArcToEndPointWithRotation:(CGFloat)rotation angleStart:(CGFloat)angleStart angleExtent:(CGFloat)angleExtent
        cx:(CGFloat)cx cy:(CGFloat)cy rx:(CGFloat)rx ry:(CGFloat)ry
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions convertArcToEndPointWithRotation:rotation angleStart:angleStart angleExtent:angleExtent
            cx:cx cy:cy rx:rx ry:ry];
}


- (NSDictionary *) convertArcToCenterPointWithStart:(CGPoint)start end:(CGPoint)end rx:(CGFloat)rx ry:(CGFloat)ry
        rotation:(CGFloat)rotation isLarge:(BOOL)isLarge isCounterClockwise:(BOOL)isCounterClockwise
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id pathFunctions = [macSVGDocumentWindowController pathFunctions];
    return [pathFunctions convertArcToCenterPointWithStart:start end:end rx:rx ry:ry
            rotation:rotation isLarge:isLarge isCounterClockwise:isCounterClockwise];
}




- (NSMutableArray *)selectedElementsArray
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    return [macSVGDocumentWindowController selectedElementsArray];
}


- (NSXMLElement *)xmlElementForMacsvgid:(NSString *)macsvgid
{
    id result = [self.macSVGDocument xmlElementForMacsvgid:macsvgid];
    return result;
}

- (DOMElement *)domElementForMacsvgid:(NSString *)macsvgid
{
    id result = [self.macSVGDocument domElementForMacsvgid:macsvgid];
    return result;
}


- (NSPoint) currentMouseClientPoint
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    NSPoint currentMouseClientPoint = [domMouseEventsController currentMouseClientPoint];
    return currentMouseClientPoint;
}


- (NSPoint) currentMousePagePoint
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    NSPoint currentMousePagePoint = [domMouseEventsController currentMousePagePoint];
    return currentMousePagePoint;
}


- (NSPoint) currentMouseScreenPoint
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    NSPoint currentMouseScreenPoint = [domMouseEventsController currentMouseScreenPoint];
    return currentMouseScreenPoint;
}



@end
