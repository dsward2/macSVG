//
//  SVGPolylineEditor.m
//  macSVG
//
//  Created by Douglas Ward on 9/6/16.
//
//

#import "SVGPolylineEditor.h"
#import "SVGWebKitController.h"
#import "SVGWebView.h"
#import "MacSVGDocumentWindowController.h"
#import "DOMMouseEventsController.h"
#import "SVGXMLDOMSelectionManager.h"
//#import "WebKitInterface.h"
//#import "MacSVGAppDelegate.h"
#import "SelectedElementsManager.h"
#import "ToolSettingsPopoverViewController.h"
#import "EditorUIFrameController.h"
//#import "ElementEditorPluginController.h"
#import "MacSVGPlugin/MacSVGPlugin.h"
#import "MacSVGDocument.h"
#import "DOMSelectionControlsManager.h"
#import "SVGXMLDOMSelectionManager.h"

#define kPolylineEditingModeNotActive 0
#define kPolylineEditingModeActive 1

@implementation SVGPolylineEditor

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.polylinePointsArray = NULL;
    self.selectedPolylineElement = NULL;
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
        self.selectedPolylineElement = NULL;
        
        self.polylinePointIndex = -1;
        
        editingMode = kPolylineEditingModeNotActive;
        
        self.polylinePointsArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

//==================================================================================
//	allocFloatString:
//==================================================================================

- (NSMutableString *)allocFloatString:(float)aFloat
{
    NSMutableString * aString = [[NSMutableString alloc] initWithFormat:@"%f", aFloat];

    BOOL continueTrim = YES;
    while (continueTrim == YES)
    {
        NSUInteger stringLength = aString.length;
        
        if (stringLength <= 1)
        {
            continueTrim = NO;
        }
        else
        {
            unichar lastChar = [aString characterAtIndex:(stringLength - 1)];
            
            if (lastChar == '0')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
            }
            else if (lastChar == '.')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
                continueTrim = NO;
            }
            else
            {
                continueTrim = NO;
            }
        }
    }
    return aString;
}

//==================================================================================
//	allocPxString:
//==================================================================================

- (NSMutableString *)allocPxString:(float)aFloat
{
    NSMutableString * aString = [[NSMutableString alloc] initWithFormat:@"%f", aFloat];

    BOOL continueTrim = YES;
    while (continueTrim == YES)
    {
        NSUInteger stringLength = aString.length;
        
        if (stringLength <= 1)
        {
            continueTrim = NO;
        }
        else
        {
            unichar lastChar = [aString characterAtIndex:(stringLength - 1)];
            
            if (lastChar == '0')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
            }
            else if (lastChar == '.')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
                continueTrim = NO;
            }
            else
            {
                continueTrim = NO;
            }
        }
    }
    
    [aString appendString:@"px"];
    
    return aString;
}

//==================================================================================
//	buildPolylinePointsArrayWithPointsString:
//==================================================================================

#define kSeparatorMode 0
#define kXValueMode 1
#define kYValueMode 1

- (NSMutableArray *)buildPolylinePointsArrayWithPointsString:(NSString *)aPointsString
{
    NSMutableArray * newPolylinePointsArray = [NSMutableArray array];

    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSString * pointsString = [aPointsString stringByTrimmingCharactersInSet:whitespaceSet];
    pointsString = [pointsString stringByReplacingOccurrencesOfString:@"," withString:@" "];
    pointsString = [pointsString stringByReplacingOccurrencesOfString:@";" withString:@" "];
    
    while ([pointsString rangeOfString:@"  "].location != NSNotFound)
    {
        pointsString = [pointsString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    
    NSCharacterSet * whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSArray * valuesArray = [pointsString componentsSeparatedByCharactersInSet:whitespaceCharacterSet];
    
    NSInteger valuesArrayCount = valuesArray.count;
    
    if (valuesArrayCount %2 == 0)
    {
        for (NSInteger i = 0; i < valuesArrayCount; i += 2)
        {
            NSString * xString = valuesArray[i];
            NSString * yString = valuesArray[i + 1];
            
            NSMutableDictionary * polylinePointDictionary = [NSMutableDictionary dictionary];
            polylinePointDictionary[@"x"] = xString;
            polylinePointDictionary[@"y"] = yString;
            
            [newPolylinePointsArray addObject:polylinePointDictionary];
        }
    }
    
    return newPolylinePointsArray;
}

//==================================================================================
//	buildPolylinePointsArray
//==================================================================================

- (void)buildPolylinePointsArray:(NSXMLElement *)polylineElement
{
    NSXMLNode * pointsAttribute = [polylineElement attributeForName:@"points"];
    NSString * pointsString = pointsAttribute.stringValue;
    
    NSMutableArray * activePolylinePointsArray = [self buildPolylinePointsArrayWithPointsString:pointsString];
    
    [self resetPolylinePointsArray];

    [self.polylinePointsArray setArray:activePolylinePointsArray];
    
    self.selectedPolylineElement = polylineElement;
}

//==================================================================================
//	makeHandleCircleDOMElementWithX1:y1:x2:y2:
//==================================================================================

- (DOMElement *)makeHandleCircleDOMElementWithCx:(NSString *)cxString cy:(NSString *)cyString
        strokeWidth:(NSString *)strokeWidthString radius:(NSString *)radiusString
        masterID:(NSString *)masterID segmentIndex:(NSString *)segmentIndexString
        handlePoint:(NSString *)handlePointString

{
    DOMDocument * domDocument = (svgWebKitController.svgWebView).mainFrame.DOMDocument;

    DOMElement * handleCircleElement = [domDocument createElementNS:svgNamespace
            qualifiedName:@"circle" ];
    
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_polyline_handle"];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"pointer-events" value:@"all"]; // allow selection
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"cx" value:cxString];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"cy" value:cyString];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"fill"
            value:toolSettingsPopoverViewController.pathCurvePointFillColor];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"stroke"
            value:toolSettingsPopoverViewController.pathCurvePointStrokeColor];
    
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"stroke-width"
            value:strokeWidthString];
    
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"r"
            value:radiusString];
    
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"_macsvg_master_Macsvgid" value:masterID];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"_macsvg_polyline_handle_index" value:segmentIndexString];
    
    return handleCircleElement;
}

//==================================================================================
//	addHandleForPoint:pointIndex:polylineHandlesGroup:
//==================================================================================

-(void) addHandleForPoint:(NSDictionary *)polylinePointDictionary
        pointIndex:(NSUInteger)pointIndex polylineHandlesGroup:(DOMElement *)polylineHandlesGroup
{
    DOMDocument * domDocument = (svgWebKitController.svgWebView).mainFrame.DOMDocument;

    NSString * xString = polylinePointDictionary[@"x"];
    NSString * yString = polylinePointDictionary[@"y"];
    
    NSString * xPxString = [xString stringByAppendingString:@"px"];
    NSString * yPxString = [yString stringByAppendingString:@"px"];

    CGFloat reciprocalZoomFactor = 1.0f / svgWebKitController.svgWebView.zoomFactor;
    
    NSString * polylinePointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
    CGFloat polylinePointStrokeWidthFloat = polylinePointStrokeWidthString.floatValue;
    polylinePointStrokeWidthFloat *= reciprocalZoomFactor;
    polylinePointStrokeWidthString = [self allocPxString:polylinePointStrokeWidthFloat];

    NSString * polylineLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
    CGFloat polylineLineStrokeWidthFloat = polylineLineStrokeWidthString.floatValue;
    polylineLineStrokeWidthFloat *= reciprocalZoomFactor;
    polylineLineStrokeWidthString = [self allocPxString:polylineLineStrokeWidthFloat];

    NSString * polylinePointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
    CGFloat polylinePointRadiusFloat = polylinePointRadiusString.floatValue;
    polylinePointRadiusFloat *= reciprocalZoomFactor;
    polylinePointRadiusString = [self allocPxString:polylinePointRadiusFloat];

    DOMElement * handleCircleElement = [domDocument createElementNS:svgNamespace
            qualifiedName:@"circle" ];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_polyline_handle"];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"pointer-events" value:@"all"]; // allow selection
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"cx" value:xPxString];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"cy" value:yPxString];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"fill"
            value:toolSettingsPopoverViewController.pathEndpointFillColor];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"stroke"
            value:toolSettingsPopoverViewController.pathEndpointStrokeColor];
    
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"stroke-width"
            value:polylinePointStrokeWidthString];
    
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"r"
            value:polylinePointRadiusString];
    
    NSString * pointIndexString = [NSString stringWithFormat:@"%ld", pointIndex];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"_macsvg_polyline_point_index" value:pointIndexString];

    NSXMLNode * MacsvgidNode = [self.selectedPolylineElement attributeForName:@"macsvgid"];
    NSString * selectedElementMacsvgid = MacsvgidNode.stringValue;

    [handleCircleElement setAttributeNS:NULL qualifiedName:@"_macsvg_master_Macsvgid" value:selectedElementMacsvgid];

    [polylineHandlesGroup appendChild:handleCircleElement];
}

//==================================================================================
//	makePolylineHandles
//==================================================================================

-(void) makePolylineHandles
{
    DOMDocument * domDocument = (svgWebKitController.svgWebView).mainFrame.DOMDocument;

    DOMSelectionControlsManager * domSelectionControlsManager =
            svgXMLDOMSelectionManager.domSelectionControlsManager;
    
    DOMElement * newPolylineHandlesGroup = [domDocument createElementNS:svgNamespace
            qualifiedName:@"g"];
    [newPolylineHandlesGroup setAttributeNS:NULL qualifiedName:@"id" value:@"_macsvg_polylineHandlesGroup"];
    [newPolylineHandlesGroup setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_polylineHandlesGroup"];
    
    NSUInteger polylinePointsCount = (self.polylinePointsArray).count;
            
    for (NSUInteger pointIdx = 0; pointIdx < polylinePointsCount; pointIdx++)
    {
        NSDictionary * polylinePointDictionary = (self.polylinePointsArray)[pointIdx];

        [self addHandleForPoint:polylinePointDictionary pointIndex:pointIdx polylineHandlesGroup:newPolylineHandlesGroup];
    }
    
    [domSelectionControlsManager setMacsvgTopGroupChild:newPolylineHandlesGroup];

    [domSelectionControlsManager highlightPolylinePoint];

    if (self.highlightSelectedPoint == YES)
    {
        [domSelectionControlsManager highlightPolylinePoint];
    }
    else
    {
        [domSelectionControlsManager removeDOMPolylinePointHighlight];
    }

}

//==================================================================================
//	buildStringWithPolylinePointsArray:
//==================================================================================

- (NSString *)buildStringWithPolylinePointsArray:(NSArray *)aPolylinePointsArray;
{
    // convert polyline points data
    NSUInteger polylinePointsCount = aPolylinePointsArray.count;

    NSMutableString * newPointsString = [[NSMutableString alloc] init];
    
    for (NSInteger i = 0; i < polylinePointsCount; i++)
    {
        NSMutableDictionary * polylinePointDictionary = aPolylinePointsArray[i];
        
        NSString * xString = polylinePointDictionary[@"x"];
        [newPointsString appendString:xString];
        [newPointsString appendString:@","];
        
        NSString * yString = polylinePointDictionary[@"y"];
        [newPointsString appendString:yString];
        [newPointsString appendString:@" "];
    }
    
    return newPointsString;
}

//==================================================================================
//	updatePolylineInDOMForElement:polylinePointsArray:
//==================================================================================

- (void)updatePolylineInDOMForElement:(DOMElement *)polylineElement polylinePointsArray:(NSArray *)aPolylinePointsArray
{
    NSString * newPointsString = [self buildStringWithPolylinePointsArray:aPolylinePointsArray];

    [polylineElement setAttribute:@"points" value:newPointsString];
    
    id currentPlugin = macSVGDocumentWindowController.editorUIFrameController.elementEditorPlugInController.currentPlugin;
    
    NSString * pluginName = [currentPlugin pluginName];
    
    if ([pluginName isEqualToString:@"Points Attribute Editor"] == YES)
    {
        NSString * macsvgid = [polylineElement getAttribute:@"macsvgid"];
        
        if (macsvgid != NULL)
        {
            MacSVGDocument * macSVGDocument = macSVGDocumentWindowController.document;
            
            NSXMLElement * polylineXMLElement = [macSVGDocument xmlElementForMacsvgid:macsvgid];
            
            [currentPlugin updateEditForXMLElement:polylineXMLElement domElement:polylineElement info:aPolylinePointsArray];
        }
    }
}


//==================================================================================
//	updateActivePolylineInDOM
//==================================================================================

- (void)updateActivePolylineInDOM
{
    NSUInteger currentToolMode = macSVGDocumentWindowController.currentToolMode;

    if ((currentToolMode == toolModePolyline) || (currentToolMode == toolModePolygon) || (currentToolMode == toolModeCrosshairCursor))
    {
        DOMElement * activeDOMElement = [svgXMLDOMSelectionManager activeDOMElement];
        if (activeDOMElement != NULL)
        {
            [self updatePolylineInDOMForElement:activeDOMElement
                    polylinePointsArray:self.polylinePointsArray];
        }
        
        [svgXMLDOMSelectionManager syncSelectedDOMElementsToXMLDocument];
        
        [macSVGDocumentWindowController reloadAttributesTableData];
        
        [self makePolylineHandles];
    }
}

//==================================================================================
//	updateSelectedPolylineInDOM
//==================================================================================

- (void)updateSelectedPolylineInDOM
{
    if (self.selectedPolylineElement != NULL)
    {
        NSXMLNode * MacsvgidNode = [self.selectedPolylineElement attributeForName:@"macsvgid"];
        NSString * macsvgid = MacsvgidNode.stringValue;
        
        DOMElement * selectedDOMPolylineElement = [svgWebKitController domElementForMacsvgid:macsvgid];
    
        [self updatePolylineInDOMForElement:selectedDOMPolylineElement
                polylinePointsArray:self.polylinePointsArray];
    }
    
    [svgXMLDOMSelectionManager syncSelectedDOMElementsToXMLDocument];
    
    [macSVGDocumentWindowController reloadAttributesTableData];
}

//==================================================================================
//	handleMouseHoverEventForPolyline:
//==================================================================================

-(void) handleMouseHoverEventForPolyline:(DOMEvent *)event
{
    DOMElement * polylineElement = [svgXMLDOMSelectionManager.selectedElementsManager firstDomElement];
    
    if (polylineElement != NULL)
    {
        NSString * pointsString = [polylineElement getAttribute:@"points"];
                
        self.polylinePointsArray = [self buildPolylinePointsArrayWithPointsString:pointsString];

        NSString * newXString = [self allocFloatString:domMouseEventsController.currentMousePoint.x];
        NSString * newYString = [self allocFloatString:domMouseEventsController.currentMousePoint.y];
        
        NSInteger polylinePointsArrayCount = (self.polylinePointsArray).count;
        
        if (polylinePointsArrayCount > 0)
        {
            NSInteger lastPointIndex = polylinePointsArrayCount - 1;
            NSMutableDictionary * pointDictionary = (self.polylinePointsArray)[lastPointIndex];
            
            pointDictionary[@"x"] = newXString;
            pointDictionary[@"y"] = newYString;
            
            NSString * newPointsString = [self buildStringWithPolylinePointsArray:self.polylinePointsArray];
            
            [polylineElement setAttribute:@"points" value:newPointsString];
        }
    }

    [self updateActivePolylineInDOM];

    id currentPlugin = macSVGDocumentWindowController.editorUIFrameController.elementEditorPlugInController.currentPlugin;

    NSString * pluginName = [currentPlugin pluginName];
    
    if ([pluginName isEqualToString:@"Points Attribute Editor"] == YES)
    {
        NSString * macsvgid = [polylineElement getAttribute:@"macsvgid"];
        
        if (macsvgid != NULL)
        {
            MacSVGDocument * macSVGDocument = macSVGDocumentWindowController.document;
            
            NSXMLElement * polylineXMLElement = [macSVGDocument xmlElementForMacsvgid:macsvgid];
            
            [currentPlugin updateEditForXMLElement:polylineXMLElement domElement:polylineElement info:self.polylinePointsArray];
        }
    }
    
}

//==================================================================================
//	removePolylineHandles
//==================================================================================

- (void)removePolylineHandles
{
    // remove existing polyline handles from DOM
    
    [svgXMLDOMSelectionManager.domSelectionControlsManager
            removeMacsvgTopGroupChildByID:@"_macsvg_polylineHandlesGroup"];
}

//==================================================================================
//	resetPolylinePointsArray
//==================================================================================

- (void)resetPolylinePointsArray
{
    self.selectedPolylineElement = NULL;
    [self.polylinePointsArray removeAllObjects];
    self.polylinePointIndex = -1;
    editingMode = kPolylineEditingModeNotActive;

    [self removePolylineHandles];
}

//==================================================================================
//	startPolyline
//==================================================================================

- (void)startPolyline
{
    // we start paths with an absolute moveto
    //NSLog(@"startPath");
    
    [self resetPolylinePointsArray];

    NSString * clickXString = [self allocFloatString:domMouseEventsController.clickPoint.x];
    NSString * clickYString = [self allocFloatString:domMouseEventsController.clickPoint.y];
    
    NSMutableDictionary * pointDictionary = [[NSMutableDictionary alloc] init];
    
    // start all paths with moveto
    pointDictionary[@"x"] = clickXString;
    pointDictionary[@"y"] = clickYString;
    
    [self.polylinePointsArray addObject:pointDictionary];
    
    [self updateActivePolylineInDOM];
}

//==================================================================================
//	didBeginPolylineEditing
//==================================================================================

//- (int)didBeginPolylineEditing:(DOMEvent *)event;

- (NSInteger)didBeginPolylineEditingWithTargetXMLElement:(NSXMLElement *)targetXmlElement
        handleDOMElement:(DOMElement *)handleDOMElement
{
    NSInteger result = kPolylineEditingModeNotActive;
    
    editingMode = kPolylineEditingModeNotActive;
    
    if (self.selectedPolylineElement != NULL)
    {
        if ((self.polylinePointsArray).count > 0)
        {
            result = [self setActiveDOMHandle:handleDOMElement];
        }
        else
        {
            NSLog(@"didBeginPolylineEditing - selectedPolylineElement not consistent with polylinePointsArray");
        }
    }
    
    return result;
}

//==================================================================================
//	editPolyline
//==================================================================================

- (void)editPolyline
{
    //NSLog(@"editPolyline");       // mousedown move event, i.e., dragging an endpoint or control point

    NSInteger polylinePointsCount = (self.polylinePointsArray).count;
    
    if (self.polylinePointIndex >= 0)
    {
        if (self.polylinePointIndex < polylinePointsCount)
        {
            NSMutableDictionary * polylinePointDictionary = (self.polylinePointsArray)[self.polylinePointIndex];

            [self editPolylinePoint:polylinePointDictionary];

            svgXMLDOMSelectionManager.activeXMLElement = self.selectedPolylineElement;
            
            [self updateActivePolylineInDOM];
        }
        else
        {
            NSLog(@"SVGPolylineEditor editPolyline invalid polylinePointIndex=%ld polylinePointsCount=%ld",
                    self.polylinePointIndex, polylinePointsCount);
        }
    }
    else
    {
        //NSLog(@"SVGPolylineEditor editPolyline invalid polylinePointIndex=%ld polylinePointsCount=%ld",
        //        self.polylinePointIndex, polylinePointsCount);
    }
}

//==================================================================================
//	editPolylinePoint:
//==================================================================================

-(void) editPolylinePoint:(NSMutableDictionary *)polylinePointDictionary
{
    NSString * previousXString = polylinePointDictionary[@"x"];     // endpoint x
    NSString * previousYString = polylinePointDictionary[@"y"];     // endpoint y

    float previousX = previousXString.floatValue;
    float previousY = previousYString.floatValue;

    NSPoint  currentMousePoint = domMouseEventsController.currentMousePoint;
    
    float deltaX = currentMousePoint.x - previousX;
    float deltaY = currentMousePoint.y - previousY;
    
    float newX = previousX + deltaX;
    float newY = previousY + deltaY;

    NSString * newXString = [self allocFloatString:newX];
    NSString * newYString = [self allocFloatString:newY];

    polylinePointDictionary[@"x"] = newXString;
    polylinePointDictionary[@"y"] = newYString;
}

//==================================================================================
//	setActiveDOMHandle:
//==================================================================================

- (NSInteger)setActiveDOMHandle:(DOMElement *)handleDOMElement
{
    NSInteger newEditingMode = kPolylineEditingModeNotActive;

    self.polylinePointIndex = -1;
    
    self.activeHandleDOMElement = handleDOMElement;
    
    if (self.activeHandleDOMElement != NULL)
    {
        if ([self.activeHandleDOMElement hasAttribute:@"class"] == YES)
        {
            NSString * domElementClass = [self.activeHandleDOMElement getAttribute:@"class"];
            if ([domElementClass isEqualToString:@"_macsvg_polyline_handle"] == YES)
            {
                if ([self.activeHandleDOMElement hasAttribute:@"_macsvg_polyline_point_index"] == YES)
                {
                    NSString * handleSegmentString = [self.activeHandleDOMElement getAttribute:@"_macsvg_polyline_point_index"];
                    NSInteger newPolylinePointIndex = handleSegmentString.integerValue;
                    
                    editingMode = kPolylineEditingModeActive;
                    newEditingMode = kPolylineEditingModeActive;
                    
                    self.polylinePointIndex = newPolylinePointIndex;
                }
            }
        }
    }

    return newEditingMode;
}

//==================================================================================
//	deleteLastLineInPolyline
//==================================================================================

-(void) deleteLastLineInPolyline
{
    NSUInteger polylinePointsCount = (self.polylinePointsArray).count;
    
    /*
    if (polylinePointsCount > 1)
    {
        if (self.polylinePointIndex > 1)
        {
            [self.polylinePointsArray removeLastObject];
            self.polylinePointIndex--;
            [self updateActivePolylineInDOM];
        }
    }
    */

    if (polylinePointsCount > 1)
    {
        [self.polylinePointsArray removeLastObject];
        
        if (self.polylinePointIndex >= 0)
        {
            if (self.polylinePointIndex >= polylinePointsCount)
            {
                self.polylinePointIndex = polylinePointsCount - 1;
            }
        }
        
        [self updateActivePolylineInDOM];
    }

}


@end
