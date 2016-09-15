//
//  SVGLineEditor.m
//  macSVG
//
//  Created by Douglas Ward on 9/13/16.
//
//

#import "SVGLineEditor.h"
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
#import "DOMSelectionRectsAndHandlesManager.h"
#import "SVGXMLDOMSelectionManager.h"

@implementation SVGLineEditor

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.selectedLineElement = NULL;
}

//==================================================================================
//	init
//==================================================================================

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
        self.selectedLineElement = NULL;
        
        self.linePointIndex = -1;
        
        editingMode = kLineEditingModeNotActive;
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
        NSUInteger stringLength = [aString length];
        
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
        NSUInteger stringLength = [aString length];
        
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
//	makeHandleCircleDOMElementWithX1:y1:x2:y2:
//==================================================================================

- (DOMElement *)makeHandleCircleDOMElementWithCx:(NSString *)cxString cy:(NSString *)cyString
        strokeWidth:(NSString *)strokeWidthString radius:(NSString *)radiusString
        masterID:(NSString *)masterID segmentIndex:(NSString *)segmentIndexString
        handlePoint:(NSString *)handlePointString

{
    DOMDocument * domDocument = [[svgWebKitController.svgWebView mainFrame] DOMDocument];

    DOMElement * handleCircleElement = [domDocument createElementNS:svgNamespace
            qualifiedName:@"circle" ];
    
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_line_handle"];
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
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"_macsvg_line_handle_index" value:segmentIndexString];
    
    return handleCircleElement;
}

//==================================================================================
//	addHandleForLineElement:pointIndex:lineHandlesGroup:
//==================================================================================

-(void) addHandleForLineElement:(DOMElement *)lineElement
        pointIndex:(NSUInteger)pointIndex lineHandlesGroup:(DOMElement *)lineHandlesGroup
{
    DOMDocument * domDocument = [[svgWebKitController.svgWebView mainFrame] DOMDocument];

    NSString * x1String = [lineElement getAttribute:@"x1"];
    NSString * y1String = [lineElement getAttribute:@"y1"];
    NSString * x2String = [lineElement getAttribute:@"x2"];
    NSString * y2String = [lineElement getAttribute:@"y2"];
    
    //NSString * x1PxString = [x1String stringByAppendingString:@"px"];
    //NSString * y1PxString = [y1String stringByAppendingString:@"px"];
    //NSString * x2PxString = [x2String stringByAppendingString:@"px"];
    //NSString * y2PxString = [y2String stringByAppendingString:@"px"];

    CGFloat reciprocalZoomFactor = 1.0f / svgWebKitController.svgWebView.zoomFactor;
    
    NSString * linePointStrokeWidthString = toolSettingsPopoverViewController.pathEndpointStrokeWidth;
    CGFloat linePointStrokeWidthFloat = [linePointStrokeWidthString floatValue];
    linePointStrokeWidthFloat *= reciprocalZoomFactor;
    linePointStrokeWidthString = [self allocPxString:linePointStrokeWidthFloat];

    NSString * lineLineStrokeWidthString = toolSettingsPopoverViewController.pathLineStrokeWidth;
    CGFloat lineLineStrokeWidthFloat = [lineLineStrokeWidthString floatValue];
    lineLineStrokeWidthFloat *= reciprocalZoomFactor;
    lineLineStrokeWidthString = [self allocPxString:lineLineStrokeWidthFloat];

    NSString * linePointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
    CGFloat linePointRadiusFloat = [linePointRadiusString floatValue];
    linePointRadiusFloat *= reciprocalZoomFactor;
    linePointRadiusString = [self allocPxString:linePointRadiusFloat];
    
    NSString * cxString = x1String;
    NSString * cyString = y1String;
    
    if (pointIndex == 1)
    {
        cxString = x2String;
        cyString = y2String;
    }

    DOMElement * handleCircleElement = [domDocument createElementNS:svgNamespace
            qualifiedName:@"circle" ];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_line_handle"];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"pointer-events" value:@"all"]; // allow selection
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"cx" value:cxString];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"cy" value:cyString];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"fill"
            value:toolSettingsPopoverViewController.pathEndpointFillColor];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"stroke"
            value:toolSettingsPopoverViewController.pathEndpointStrokeColor];
    
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"stroke-width"
            value:linePointStrokeWidthString];
    
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"r"
            value:linePointRadiusString];
    
    NSString * pointIndexString = [NSString stringWithFormat:@"%ld", pointIndex];
    [handleCircleElement setAttributeNS:NULL qualifiedName:@"_macsvg_line_point_index" value:pointIndexString];

    NSXMLNode * MacsvgidNode = [self.selectedLineElement attributeForName:@"macsvgid"];
    NSString * selectedElementMacsvgid = [MacsvgidNode stringValue];

    [handleCircleElement setAttributeNS:NULL qualifiedName:@"_macsvg_master_Macsvgid" value:selectedElementMacsvgid];

    [lineHandlesGroup appendChild:handleCircleElement];
}

//==================================================================================
//	makeLineHandles
//==================================================================================

-(void) makeLineHandles
{
    DOMDocument * domDocument = [[svgWebKitController.svgWebView mainFrame] DOMDocument];

    DOMSelectionRectsAndHandlesManager * domSelectionRectsAndHandlesManager =
            svgXMLDOMSelectionManager.domSelectionRectsAndHandlesManager;
    
    DOMElement * newLineHandlesGroup = [domDocument createElementNS:svgNamespace
            qualifiedName:@"g"];
    [newLineHandlesGroup setAttributeNS:NULL qualifiedName:@"id" value:@"_macsvg_lineHandlesGroup"];

    DOMElement * activeDOMElement = [svgXMLDOMSelectionManager activeDOMElement];
    
    [self addHandleForLineElement:activeDOMElement pointIndex:0 lineHandlesGroup:newLineHandlesGroup];
    [self addHandleForLineElement:activeDOMElement pointIndex:1 lineHandlesGroup:newLineHandlesGroup];
    
    [domSelectionRectsAndHandlesManager setMacsvgTopGroupChild:newLineHandlesGroup];

    [domSelectionRectsAndHandlesManager highlightLinePoint];
}

//==================================================================================
//	updateLineInDOMForElement:xmlElement:
//==================================================================================

- (void)updateLineInDOMForElement:(DOMElement *)lineDOMElement xmlElement:(NSXMLElement *)lineXMLElement
{
    if (lineXMLElement != NULL)
    {
        if (lineDOMElement != NULL)
        {
            NSString * linePointIndexString = [self.activeHandleDOMElement getAttribute:@"_macsvg_line_point_index"];
            NSInteger linePointIndex = [linePointIndexString integerValue];

            NSString * xAttributeName = @"x1";
            NSString * yAttributeName = @"y1";
            
            if (linePointIndex > 0)
            {
                xAttributeName = @"x2";
                yAttributeName = @"y2";
            }

            NSXMLNode * xAttributeNode = [lineXMLElement attributeForName:xAttributeName];
            NSXMLNode * yAttributeNode = [lineXMLElement attributeForName:yAttributeName];
            
            NSString * xString = [xAttributeNode stringValue];
            NSString * yString = [yAttributeNode stringValue];
            
            [lineDOMElement setAttribute:xAttributeName value:xString];
            [lineDOMElement setAttribute:yAttributeName value:yString];
        }
    }
}

//==================================================================================
//	updateActiveLineInDOM
//==================================================================================

- (void)updateActiveLineInDOM
{
    NSUInteger currentToolMode = macSVGDocumentWindowController.currentToolMode;

    if ((currentToolMode == toolModeLine) || (currentToolMode == toolModeCrosshairCursor))
    {
        DOMElement * activeDOMElement = [svgXMLDOMSelectionManager activeDOMElement];
        if (activeDOMElement != NULL)
        {
            //[self updateLineInDOMForElement:selectedDOMLineElement];
            [self updateLineInDOMForElement:activeDOMElement xmlElement:svgXMLDOMSelectionManager.activeXMLElement];
        }
        
        [svgXMLDOMSelectionManager syncSelectedDOMElementsToXMLDocument];
        
        [macSVGDocumentWindowController reloadAttributesTableData];
        
        [self makeLineHandles];
    }
}

//==================================================================================
//	updateSelectedLineInDOM
//==================================================================================

- (void)updateSelectedLineInDOM
{
    if (self.selectedLineElement != NULL)
    {
        NSXMLNode * MacsvgidNode = [self.selectedLineElement attributeForName:@"macsvgid"];
        NSString * macsvgid = [MacsvgidNode stringValue];
        
        DOMElement * selectedDOMLineElement = [svgWebKitController domElementForMacsvgid:macsvgid];
    
        [self updateLineInDOMForElement:selectedDOMLineElement xmlElement:svgXMLDOMSelectionManager.activeXMLElement];
    }
    
    [svgXMLDOMSelectionManager syncSelectedDOMElementsToXMLDocument];
    
    [macSVGDocumentWindowController reloadAttributesTableData];
}

//==================================================================================
//	handleMouseHoverEventForLine:
//==================================================================================

-(void) handleMouseHoverEventForLine:(DOMEvent *)event
{
    DOMElement * lineElement = [svgXMLDOMSelectionManager.selectedElementsManager firstDomElement];
    
    if (lineElement != NULL)
    {
        NSString * newXString = [self allocFloatString:domMouseEventsController.currentMousePoint.x];
        NSString * newYString = [self allocFloatString:domMouseEventsController.currentMousePoint.y];
        
        if (self.linePointIndex == 0)
        {
            [lineElement setAttribute:@"x1" value:newXString];
            [lineElement setAttribute:@"y1" value:newYString];
        }
        else
        {
            [lineElement setAttribute:@"x2" value:newXString];
            [lineElement setAttribute:@"y2" value:newYString];
        }
    }

    [self updateActiveLineInDOM];
}

//==================================================================================
//	removeLineHandles
//==================================================================================

- (void)removeLineHandles
{
    // remove existing line handles from DOM
    
    [svgXMLDOMSelectionManager.domSelectionRectsAndHandlesManager
            removeMacsvgTopGroupChildByID:@"_macsvg_lineHandlesGroup"];
}

//==================================================================================
//	resetLinePoints
//==================================================================================

- (void)resetLinePoints
{
    self.selectedLineElement = NULL;
    self.linePointIndex = -1;
    editingMode = kLineEditingModeNotActive;

    [self removeLineHandles];
}

//==================================================================================
//	startLine
//==================================================================================

- (void)startLine
{
    [self resetLinePoints];

    [self updateActiveLineInDOM];
}

//==================================================================================
//	didBeginLineEditing
//==================================================================================

//- (int)didBeginLineEditing:(DOMEvent *)event;

- (NSInteger)didBeginLineEditingWithTargetXMLElement:(NSXMLElement *)targetXmlElement
        handleDOMElement:(DOMElement *)handleDOMElement
{
    NSInteger result = kLineEditingModeNotActive;
    
    editingMode = kLineEditingModeNotActive;
    
    if (self.selectedLineElement != NULL)
    {
        result = [self setActiveDOMHandle:handleDOMElement];
        
        if (handleDOMElement == NULL)
        {
            result = kLineEditingModeActive;
        }
    }
    
    return result;
}

//==================================================================================
//	editLine
//==================================================================================

- (void)editLine
{
    //NSLog(@"editLine");       // mousedown move event, i.e., dragging an endpoint or control point

    [self editLinePoint];

    svgXMLDOMSelectionManager.activeXMLElement = self.selectedLineElement;
    
    [self updateActiveLineInDOM];
}

//==================================================================================
//	editLinePoint
//==================================================================================

-(void) editLinePoint
{
    NSPoint  currentMousePoint = domMouseEventsController.currentMousePoint;
    
    NSString * xString = [self allocPxString:currentMousePoint.x];
    NSString * yString = [self allocPxString:currentMousePoint.y];
    
    if (self.linePointIndex == 0)
    {
        NSXMLNode * x1AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        [x1AttributeNode setName:@"x1"];
        [x1AttributeNode setStringValue:xString];
        [self.selectedLineElement addAttribute:x1AttributeNode];

        NSXMLNode * y1AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        [y1AttributeNode setName:@"y1"];
        [y1AttributeNode setStringValue:yString];
        [self.selectedLineElement addAttribute:y1AttributeNode];
    }
    else
    {
        NSXMLNode * x2AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        [x2AttributeNode setName:@"x2"];
        [x2AttributeNode setStringValue:xString];
        [self.selectedLineElement addAttribute:x2AttributeNode];

        NSXMLNode * y2AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        [y2AttributeNode setName:@"y2"];
        [y2AttributeNode setStringValue:yString];
        [self.selectedLineElement addAttribute:y2AttributeNode];
    }
}

//==================================================================================
//	setActiveDOMHandle:
//==================================================================================

- (NSInteger)setActiveDOMHandle:(DOMElement *)handleDOMElement
{
    NSInteger newEditingMode = kLineEditingModeNotActive;

    self.linePointIndex = -1;
    
    self.activeHandleDOMElement = handleDOMElement;
    
    if (self.activeHandleDOMElement != NULL)
    {
        if ([self.activeHandleDOMElement hasAttribute:@"class"] == YES)
        {
            NSString * domElementClass = [self.activeHandleDOMElement getAttribute:@"class"];
            if ([domElementClass isEqualToString:@"_macsvg_line_handle"] == YES)
            {
                if ([self.activeHandleDOMElement hasAttribute:@"_macsvg_line_point_index"] == YES)
                {
                    NSString * handleSegmentString = [self.activeHandleDOMElement getAttribute:@"_macsvg_line_point_index"];
                    NSInteger newLinePointIndex = [handleSegmentString integerValue];
                    
                    editingMode = kLineEditingModeActive;
                    newEditingMode = kLineEditingModeActive;
                    
                    self.linePointIndex = newLinePointIndex;
                }
            }
        }
    }

    return newEditingMode;
}


@end
