//
//  DOMSelectionRectsAndHandlesManager.m
//  macSVG
//
//  Created by Douglas Ward on 9/9/13.
//
//

#import "DOMSelectionRectsAndHandlesManager.h"
#import <WebKit/WebKit.h>
#import "MacSVGDocumentWindowController.h"
#import "MacSVGDocument.h"
#import "SVGXMLDOMSelectionManager.h"
#import "SVGWebKitController.h"
#import "SVGWebView.h"
#import "MacSVGAppDelegate.h"
#import "WebKitInterface.h"
#import "DOMSelectionCacheRecord.h"
#import "SelectedElementsManager.h"
#import "ToolSettingsPopoverViewController.h"
#import "PathFunctions.h"
#import "SVGPathEditor.h"
#import "SVGPolylineEditor.h"
#import "SVGLineEditor.h"
#import "DOMMouseEventsController.h"

@implementation DOMSelectionRectsAndHandlesManager

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.validElementsForTransformDictionary = NULL;
    self.domElementForHandles = NULL;
    self.domElementForHandlesCreationTime = 0;
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
        self.validElementsForTransformDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                @"rect", @"rect",
                @"circle", @"circle",
                @"ellipse", @"ellipse",
                @"text", @"text",
                @"image", @"image",
                @"line", @"line",
                @"polyline", @"polyline",
                @"polygon", @"polygon",
                @"path", @"path",
                @"use", @"use",
                @"g", @"g",
                @"foreignObject", @"foreignObject",
                nil];
        self.domElementForHandles = NULL;
        self.domElementForHandlesCreationTime = 0;
    }
    
    return self;
}

//==================================================================================
//	floatFromString:
//==================================================================================

-(float) floatFromString:(NSString *)valueString
{
    float floatValue = 0;
    
    NSMutableString * trimmedString = [[NSMutableString alloc] init];
    
    NSUInteger inputLength = [valueString length];
    for (int i = 0; i < inputLength; i++)
    {
        unichar aChar = [valueString characterAtIndex:i];
        
        BOOL validChar = YES;
        
        if (aChar < '0') validChar = NO;
        if (aChar > '9') validChar = NO;
        if (aChar == '.') validChar = YES;
        if (aChar == '-') validChar = YES;
        
        if (validChar == NO) 
        {
            break;
        }
        
        NSString * charString = [[NSString alloc] initWithFormat:@"%C", aChar];
        
        [trimmedString appendString:charString];
    }
    
    floatValue = [trimmedString floatValue];
    
    return floatValue;
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
//	macsvgControlsGroupElement
//==================================================================================

- (DOMElement *)macsvgTopGroupElement
{
    // find _macsvg_top_group in top level svg element
    DOMElement * macsvgTopGroupElement = NULL;
    
    DOMDocument * domDocument = [[svgWebView mainFrame] DOMDocument];
    
    DOMElement * domDocumentElement = [domDocument documentElement];
    
    DOMNodeList * childNodes = [domDocumentElement childNodes];

    unsigned int childCount = [childNodes length];
    
    NSInteger foundIndex = -1;
    
    for (int i = childCount - 1; i >= 0; i--)
    {
        DOMNode * aChildNode = [childNodes item:i];
        unsigned short childNodeType = [aChildNode nodeType];
        
		if (childNodeType == DOM_ELEMENT_NODE) 
        {
            DOMElement * aChildElement = (DOMElement *)aChildNode;
            
            NSString * idString = [aChildElement getAttribute:@"id"];
            
            if ([idString isEqualToString:@"_macsvg_top_group"] == YES)
            {
                macsvgTopGroupElement = aChildElement;
                foundIndex = i;
                break;
            }
        }
    }
    
    if (macsvgTopGroupElement == NULL)
    {
        macsvgTopGroupElement = [domDocument createElementNS:svgNamespace
                qualifiedName:@"g"];
        [macsvgTopGroupElement setAttributeNS:NULL qualifiedName:@"id" value:@"_macsvg_top_group"];
        [macsvgTopGroupElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_top_group"];
        
        [domDocumentElement appendChild:macsvgTopGroupElement];
    }
    else
    {
        if (foundIndex != (childCount - 1))
        {
            // move macsvgTopGroupElement to final child element in document
            [domDocumentElement removeChild:macsvgTopGroupElement];
            [domDocumentElement appendChild:macsvgTopGroupElement];
        }
    }
    
    return macsvgTopGroupElement;
}

//==================================================================================
//	getMacsvgTopGroupChildByID:createIfNew:
//==================================================================================

- (DOMElement *)getMacsvgTopGroupChildByID:(NSString *)idString createIfNew:(BOOL)createIfNew
{
    DOMElement * resultElement = NULL;

    DOMElement * macsvgTopGroupElement = [self macsvgTopGroupElement];
    
    DOMNodeList * childNodes = [macsvgTopGroupElement childNodes];

    unsigned int childCount = [childNodes length];
    
    for (int i = 0; i < childCount; i++)
    {
        DOMNode * aChildNode = [childNodes item:i];
        unsigned short childNodeType = [aChildNode nodeType];
        
		if (childNodeType == DOM_ELEMENT_NODE) 
        {
            DOMElement * aChildElement = (DOMElement *)aChildNode;
            
            NSString * aIDString = [aChildElement getAttribute:@"id"];
            
            if ([idString isEqualToString:aIDString] == YES)
            {
                resultElement = aChildElement;
                break;
            }
        }
    }
    
    if (resultElement == NULL)
    {
        if (createIfNew == YES)
        {
            DOMDocument * domDocument = [[svgWebView mainFrame] DOMDocument];

            macsvgTopGroupElement = [domDocument createElementNS:svgNamespace
                    qualifiedName:@"g"];
            [macsvgTopGroupElement setAttributeNS:NULL qualifiedName:@"id" value:idString];
            [macsvgTopGroupElement setAttributeNS:NULL qualifiedName:@"class" value:idString];
            
            [macsvgTopGroupElement appendChild:macsvgTopGroupElement];
        }
    }
    
    return resultElement;
}

//==================================================================================
//	setMacsvgTopGroupChildByID
//==================================================================================

- (void)setMacsvgTopGroupChild:(DOMElement *)childElement
{
    NSString * idString = [childElement getAttribute:@"id"];

    //if ([idString isEqualToString:@"_macsvg_selectedRectsGroup"] == YES)
    //{
    //    NSLog(@"setMacsvgTopGroupChild - _macsvg_selectedRectsGroup");
    //}

    DOMElement * existingChildElement = [self getMacsvgTopGroupChildByID:idString createIfNew:NO];
    
    if (existingChildElement != NULL)
    {
        DOMElement * parentElement = [existingChildElement parentElement];
        
        [parentElement replaceChild:childElement oldChild:existingChildElement];
    }
    else
    {
        // inject new pathHandlesGroup
        DOMElement * macsvgTopGroupElement = [self macsvgTopGroupElement];
        [macsvgTopGroupElement appendChild:childElement];
    }
}

//==================================================================================
//	removeMacsvgTopGroupChildByID:
//==================================================================================

- (void)removeMacsvgTopGroupChildByID:(NSString *)idString
{
    //if ([idString isEqualToString:@"_macsvg_selectedRectsGroup"] == YES)
    //{
    //    NSLog(@"removeMacsvgTopGroupChildByID - _macsvg_selectedRectsGroup");
    //}

    DOMElement * macsvgTopGroupElement = [self macsvgTopGroupElement];
    
    DOMNodeList * childNodes = [macsvgTopGroupElement childNodes];

    unsigned int childCount = [childNodes length];
    
    for (int i = 0; i < childCount; i++)
    {
        DOMNode * aChildNode = [childNodes item:i];
        unsigned short childNodeType = [aChildNode nodeType];
        
		if (childNodeType == DOM_ELEMENT_NODE) 
        {
            DOMElement * aChildElement = (DOMElement *)aChildNode;
            
            NSString * childIDString = [aChildElement getAttribute:@"id"];
            
            if ([idString isEqualToString:childIDString] == YES)
            {
                [[aChildElement parentElement] removeChild:aChildElement];
                break;
            }
        }
    }
}

//==================================================================================
//	copyChildAnimationFromDOMElement:toDOMElement:
//==================================================================================

-(void) copyChildAnimationFromDOMElement:(DOMElement *)sourceElement toDOMElement:(DOMElement *)destinationElement
{
    //NSLog(@"enter copyChildAnimationFromElement:toElement:");

    DOMDocument * domDocument = [[svgWebView mainFrame] DOMDocument];

    // copy transform attribute attached to source element, if present
    NSString * transformValue = [sourceElement getAttribute:@"transform"];
    if (transformValue != NULL)
    {
        if ([transformValue length] > 0)
        {
            [destinationElement setAttributeNS:NULL qualifiedName:@"transform" value:transformValue];
        }
    }

    DOMNodeList * childNodes = [sourceElement childNodes];

    unsigned int childCount = [childNodes length];
    
    for (int i = 0; i < childCount; i++)
    {
        DOMNode * aChildNode = [childNodes item:i];
        unsigned short childNodeType = [aChildNode nodeType];
        
		if (childNodeType == DOM_ELEMENT_NODE) 
        {
            DOMElement * aChildElement = (DOMElement *)aChildNode;
            
            NSString * childElementName = [aChildElement nodeName];
            
            BOOL isAnimationElement = NO;
            
            if ([childElementName isEqualToString:@"set"] == YES)
            {
                isAnimationElement = YES;
            }
            else if ([childElementName isEqualToString:@"animate"] == YES)
            {
                isAnimationElement = YES;
            }
            else if ([childElementName isEqualToString:@"animateMotion"] == YES)
            {
                isAnimationElement = YES;
            }
            else if ([childElementName isEqualToString:@"animateTransform"] == YES)
            {
                isAnimationElement = YES;
            }
            
            if (isAnimationElement == YES)
            {
                // copy a matching animation element to the selection rectangle, hopefully in sync with original element
                
                DOMElement * shadowAnimationElement = [domDocument createElementNS:svgNamespace
                        qualifiedName:childElementName];
                
                DOMNamedNodeMap * attributesNodeMap = [aChildNode attributes];

                unsigned int a, attCount = [attributesNodeMap length];
                NSString * beginValue = @"0s;";
                
                for (a = 0; a < attCount; a++) 
                {
                    DOMNode *att = [attributesNodeMap item:a];
                    NSString *attName = [att nodeName];
                    NSString *attValue = [att nodeValue];
                    
                    if ([attName isEqualToString:@"begin"] == YES)
                    {
                        beginValue = attValue;
                    }
                    
                    if ([attName isEqualToString:@"macsvgid"] == YES)
                    {
                        attName = @"shadow_Macsvgid";
                    }
                    
                    if ([attName isEqualToString:@"id"] == YES)
                    {
                        attValue = [NSString stringWithFormat:@"_macsvg_shadow_%@", attValue];
                    }
                    
                    [shadowAnimationElement setAttributeNS:NULL qualifiedName:attName value:attValue];  // TEST 20160810 reverted
                    //[shadowAnimationElement setAttributeNS:svgNamespace qualifiedName:attName value:attValue];  // TEST 20160806
                }

                [shadowAnimationElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_shadowAnimation"];
                                
                [destinationElement appendChild:shadowAnimationElement];
                
                [shadowAnimationElement setAttributeNS:NULL qualifiedName:@"begin" value:beginValue];   // enable animation for element in webkit
            }
        }
    }

    
    //NSLog(@"exit copyChildAnimationFromElement:toElement:");
}

//==================================================================================
//	removeDOMSelectionRectsAndHandles
//==================================================================================

-(void) removeDOMSelectionRectsAndHandles
{
    [self removeMacsvgTopGroupChildByID:@"_macsvg_selectionHandlesGroup"];

    self.domElementForHandles = NULL;
    self.domElementForHandlesCreationTime = 0;

    [self removeMacsvgTopGroupChildByID:@"_macsvg_selectedRectsGroup"];
    
    [self removeMacsvgTopGroupChildByID:@"_macsvg_highlightPathSegmentGroup"];
    [self removeMacsvgTopGroupChildByID:@"_macsvg_highlightPolylinePointGroup"];
    [self removeMacsvgTopGroupChildByID:@"_macsvg_highlightLinePointGroup"];
    
    //[self removeMacsvgTopGroupChildByID:@"_macsvg_lineHandlesGroup"];
    //[self removeMacsvgTopGroupChildByID:@"_macsvg_polylineHandlesGroup"];
    //[self removeMacsvgTopGroupChildByID:@"_macsvg_pathHandlesGroup"];
    
    //[self removeDOMPathSegmentHighlight]; // TEST 20160905
}

//==================================================================================
//	makeDOMSelectionRects
//==================================================================================

-(void) makeDOMSelectionRects
{
    MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)[NSApp delegate];
    WebKitInterface * webKitInterface = [macSVGAppDelegate webKitInterface];

    [svgXMLDOMSelectionManager resyncDOMElementsInSelectedElementsArray];

    //MacSVGDocument * macSVGDocument = [macSVGDocumentWindowController document];

    [self removeDOMSelectionRectsAndHandles];

    //NSLog(@"enter makeDOMSelectionRects");
    
    DOMDocument * domDocument = [[svgWebView mainFrame] DOMDocument];
	DOMNodeList * svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
    
    if ([svgElementsList length] == 0)
    {
        DOMElement * newSvgElement = [domDocument createElementNS:svgNamespace
                qualifiedName:@"svg"];

        DOMElement * documentElement = [domDocument documentElement];
        
        int clientLeft = [documentElement clientLeft];
        int clientTop = [documentElement clientTop];
        int clientWidth = [documentElement clientWidth];
        int clientHeight = [documentElement clientHeight];
        
        NSString * svgWidth = [NSString stringWithFormat:@"%dpx", clientWidth];
        NSString * svgHeight = [NSString stringWithFormat:@"%dpx", clientHeight];
        NSString * svgViewBox = [NSString stringWithFormat:@"%d %d %d %d", clientLeft, clientTop, clientWidth, clientHeight];

        [newSvgElement setAttribute:@"xmlns" value:@"http://www.w3.org/2000/svg"];
        [newSvgElement setAttribute:@"xmlns:xlink" value:@"http://www.w3.org/1999/xlink"];
        [newSvgElement setAttribute:@"cursor" value:@"crosshair"];
        [newSvgElement setAttribute:@"height" value:svgHeight];
        [newSvgElement setAttribute:@"id" value:@"svg_document"];
        [newSvgElement setAttribute:@"width" value:svgWidth];
        [newSvgElement setAttribute:@"version" value:@"1.1"];
        [newSvgElement setAttribute:@"preserveAspectRatio" value:@"none"];
        [newSvgElement setAttribute:@"viewBox" value:svgViewBox];
        
        [documentElement appendChild:newSvgElement];
        
        svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
    }
    
    //DOMNode * svgElementNode = [svgElementsList item:0];
    //DOMElement * topSvgElement = (DOMElement *)svgElementNode;
    
    DOMElement * newSelectedRectsGroup = [domDocument createElementNS:svgNamespace 
            qualifiedName:@"g"];
    [newSelectedRectsGroup setAttributeNS:NULL qualifiedName:@"id" value:@"_macsvg_selectedRectsGroup"];
    [newSelectedRectsGroup setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_selectedRectsGroup"];

    // inject new selectedRectsGroup into DOM
    //[topSvgElement appendChild:newSelectedRectsGroup];
    //[self setMacsvgTopGroupChild:newSelectedRectsGroup];

    
    NSMutableArray * commonParentElementsArray = [[NSMutableArray alloc] init];
    
    // create bounding boxes for selected items
    NSUInteger selectedItemsCount = [svgXMLDOMSelectionManager.selectedElementsManager selectedElementsCount];
    for (int i = 0; i < selectedItemsCount; i++) 
    {
        DOMElement * aSelectedSvgElement = [svgXMLDOMSelectionManager.selectedElementsManager domElementAtIndex:i];

        NSRect boundingBox = NSZeroRect;
        
        NSString * elementName = [aSelectedSvgElement nodeName];
        if ([self.validElementsForTransformDictionary objectForKey:elementName] != NULL)
        {
            //[aSelectedSvgElement focus];
            
        
            boundingBox = [webKitInterface bBoxForDOMElement:aSelectedSvgElement];
            //boundingBox = [webKitInterface bBoxForDOMElement:aSelectedSvgElement globalContext:[[svgWebView mainFrame] globalContext]];

            /*
            if (NSIsEmptyRect(boundingBox) == YES)
            {
                boundingBox = [webKitInterface bBoxForDOMElement:aSelectedSvgElement webView:svgWebView];
            }
            */
            
            if ([elementName isEqualToString:@"use"])
            {
                /*
                NSString * xAttributeString = [aSelectedSvgElement getAttribute:@"x"];
                NSString * yAttributeString = [aSelectedSvgElement getAttribute:@"y"];
                
                CGFloat xAttributeFloat = [xAttributeString floatValue];
                CGFloat yAttributeFloat = [yAttributeString floatValue];
                
                boundingBox.origin.x += xAttributeFloat;
                boundingBox.origin.y += yAttributeFloat;
                */
                NSString * xAttributeString = [aSelectedSvgElement getAttribute:@"x"];
                NSString * yAttributeString = [aSelectedSvgElement getAttribute:@"y"];
                NSString * widthAttributeString = [aSelectedSvgElement getAttribute:@"width"];
                NSString * heightAttributeString = [aSelectedSvgElement getAttribute:@"height"];
                
                CGFloat xAttributeFloat = [xAttributeString floatValue];
                CGFloat yAttributeFloat = [yAttributeString floatValue];
                CGFloat widthAttributeFloat = [widthAttributeString floatValue];
                CGFloat heightAttributeFloat = [heightAttributeString floatValue];
                
                boundingBox.origin.x += xAttributeFloat;
                boundingBox.origin.y += yAttributeFloat;
                boundingBox.size.width = widthAttributeFloat;
                boundingBox.size.height = heightAttributeFloat;
            }
            
            if ([elementName isEqualToString:@"foreignObject"])
            {
                NSString * xAttributeString = [aSelectedSvgElement getAttribute:@"x"];
                NSString * yAttributeString = [aSelectedSvgElement getAttribute:@"y"];
                NSString * widthAttributeString = [aSelectedSvgElement getAttribute:@"width"];
                NSString * heightAttributeString = [aSelectedSvgElement getAttribute:@"height"];
                
                CGFloat xAttributeFloat = [xAttributeString floatValue];
                CGFloat yAttributeFloat = [yAttributeString floatValue];
                CGFloat widthAttributeFloat = [widthAttributeString floatValue];
                CGFloat heightAttributeFloat = [heightAttributeString floatValue];
                
                boundingBox.origin.x = xAttributeFloat;
                boundingBox.origin.y = yAttributeFloat;
                boundingBox.size.width = widthAttributeFloat;
                boundingBox.size.height = heightAttributeFloat;
            }
            
            if (NSIsEmptyRect(boundingBox) == YES)
            {
                if (svgWebKitController.mainFrameIsLoading == YES)
                {
                    //NSLog(@"SVGXMLDOMSelectionManager boundingBox is empty, mainFrameIsLoading=YES %@", aSelectedSvgElement);
                }
                else
                {
                    //NSLog(@"SVGXMLDOMSelectionManager boundingBox is empty, mainFrameIsLoading=NO %@", aSelectedSvgElement);
                }
            }
            
            DOMElement * parentElement = (id)[aSelectedSvgElement parentNode];
            
            DOMElement * shadowParentElement = NULL;
            
            if ([commonParentElementsArray count] > 0)
            {
                // check for an existing shadow group for this level of the structure
                BOOL continueSearch = YES;
                NSUInteger parentIndex = 0;
                while (continueSearch == YES) 
                {
                    DOMSelectionCacheRecord * domSelectionCacheRecord = [commonParentElementsArray objectAtIndex:parentIndex];
                    if (domSelectionCacheRecord.parentElement == parentElement) 
                    {
                        // match found, a group exists for this level
                        shadowParentElement = domSelectionCacheRecord.shadowParentElement;
                        continueSearch = NO;
                    }
                    else
                    {
                        parentIndex++;
                        if (parentIndex >= [commonParentElementsArray count])
                        {
                            continueSearch = NO;
                        }
                    }
                }
            }
            
            if (shadowParentElement == NULL) 
            {
                // a shadow element was not found, so replicate the DOM path of selected item
                NSMutableArray * newParentsArray = [[NSMutableArray alloc] init];
                
                BOOL continueCreatingParents = YES;

                if (parentElement == NULL)
                {
                    continueCreatingParents = NO;
                }
                else
                {
                    NSString * firstParentTagName = [parentElement nodeName];
                    if ([firstParentTagName isEqualToString:@"svg"] == YES)
                    {
                        continueCreatingParents = NO;
                    }
                    if ([firstParentTagName isEqualToString:@"#document"] == YES)
                    {
                        continueCreatingParents = NO;
                    }
                }
                
                while (continueCreatingParents == YES)
                {
                    NSString * parentTagName = [parentElement nodeName];

                    DOMElement * newShadowParentElement = [domDocument createElementNS:svgNamespace
                            qualifiedName:parentTagName];

                    NSString * shadow_Macsvgid = [parentElement getAttribute:@"macsvgid"];
                    [newShadowParentElement setAttributeNS:NULL qualifiedName:@"shadow_Macsvgid" value:shadow_Macsvgid];
                    [newSelectedRectsGroup setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_selectionParent"];

                    [self copyChildAnimationFromDOMElement:parentElement toDOMElement:newShadowParentElement];
                    
                    DOMSelectionCacheRecord * newDOMSelectionCacheRecord = 
                            [[DOMSelectionCacheRecord alloc] init];
                    
                    newDOMSelectionCacheRecord.parentElement = parentElement;
                    newDOMSelectionCacheRecord.shadowParentElement = newShadowParentElement;
                                        
                    [commonParentElementsArray addObject:newDOMSelectionCacheRecord];
                    
                    [newParentsArray insertObject:newShadowParentElement atIndex:0];
                    
                    if ([parentElement parentNode] == NULL) 
                    {
                        continueCreatingParents = NO;
                    }
                    else
                    {
                        DOMNode * nextParentNode = [parentElement parentNode];

                        NSString * nextParentTagName = [nextParentNode nodeName];
                        if ([nextParentTagName isEqualToString:@"svg"] == YES)
                        {
                            continueCreatingParents = NO;
                        }
                        if ([nextParentTagName isEqualToString:@"#document"] == YES)
                        {
                            continueCreatingParents = NO;
                        }
                        else
                        {
                            parentElement = (DOMElement *)nextParentNode;
                        }
                    }
                }

                // inject new elements into DOM from the top down, starting as child of 'newSelectedRectsGroup'
                shadowParentElement = (DOMElement *)newSelectedRectsGroup;
                
                for (DOMElement * aElement in newParentsArray)
                {
                    [shadowParentElement appendChild:aElement];
                    
                    shadowParentElement = (DOMElement *)aElement;
                }
            }
            
            if (shadowParentElement != NULL)
            {    
                // inject blue rectangle around bounds of selected item
                
                if (NSIsEmptyRect(boundingBox) == NO)
                {
                    NSString * selectionStrokeColor = toolSettingsPopoverViewController.selectionStrokeColor;
                    NSString * selectionStrokeWidth = toolSettingsPopoverViewController.selectionStrokeWidth;
                    
                    CGFloat reciprocalZoomFactor = 1.0f / svgWebView.zoomFactor;
                    CGFloat selectionStrokeWidthFloat = [selectionStrokeWidth floatValue];
                    selectionStrokeWidthFloat = selectionStrokeWidthFloat * reciprocalZoomFactor;
                    selectionStrokeWidth = [self allocPxString:selectionStrokeWidthFloat];
                    
                    float bboxX = boundingBox.origin.x - 2;
                    float bboxY = boundingBox.origin.y - 2;
                    float bboxWidth = boundingBox.size.width + 4;
                    float bboxHeight = boundingBox.size.height + 4;

                    NSString * bboxXString = [self allocPxString:bboxX];
                    NSString * bboxYString = [self allocPxString:bboxY];
                    NSString * bboxWidthString = [self allocPxString:bboxWidth];
                    NSString * bboxHeightString = [self allocPxString:bboxHeight];
                    
                    DOMElement * selectedItemRectElement = [domDocument createElementNS:svgNamespace
                            qualifiedName:@"rect" ];
                    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"fill" value:@"none"];
                    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"stroke" value:selectionStrokeColor];
                    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"pointer-events" value:@"none"]; // disallow selection of section rects
                    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_selectedRect"];
                    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"x" value:bboxXString];
                    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"y" value:bboxYString];
                    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"width" value:bboxWidthString];
                    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"height" value:bboxHeightString];
                    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"stroke-width" value:selectionStrokeWidth];
                    
                    NSString * shadow_Macsvgid = [aSelectedSvgElement getAttribute:@"macsvgid"];
                    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"shadow_Macsvgid" value:shadow_Macsvgid];

                    [shadowParentElement appendChild:selectedItemRectElement];

                    [self copyChildAnimationFromDOMElement:aSelectedSvgElement toDOMElement:selectedItemRectElement];
                    
                    //NSLog(@"selectionRect added %@, %@, %@, %@", bboxXString, bboxYString, bboxWidthString, bboxHeightString);
                }
                else
                {
                    //NSLog(@"makeDOMSelectionRects - boundingBox = NULL");
                }
            }
        }
    }

    // set begin attributes again for animation elements
    DOMNodeList * animationElements = [domDocument getElementsByClassName:@"_macsvg_shadowAnimation"];
    unsigned animationElementsCount = [animationElements length];
    for (int i = 0; i < animationElementsCount; i++)
    {
        DOMElement * shadowAnimationElement = (id)[animationElements item:i];
        
        NSString * beginValue = [shadowAnimationElement getAttribute:@"begin"];
        
        [shadowAnimationElement setAttributeNS:NULL qualifiedName:@"begin" value:beginValue];   // enable animation for element in webkit
    }

    [self setMacsvgTopGroupChild:newSelectedRectsGroup];
}

//==================================================================================
//	updateDOMSelectionRectsAndHandles
//==================================================================================

- (void) updateDOMSelectionRectsAndHandles
{
    DOMElement * keyDOMElement = [self keyDOMElement];

    DOMElement * selectedRectsGroup = [self getMacsvgTopGroupChildByID:@"_macsvg_selectedRectsGroup" createIfNew:NO];
    
    if (selectedRectsGroup != NULL)
    {
        [self makeDOMSelectionRects];
        [self makeDOMSelectionHandles:keyDOMElement];
    }
    else if (keyDOMElement != NULL)
    {
        [self makeDOMSelectionHandles:keyDOMElement];
    }
}

//==================================================================================
//	updateSelectionRectsDOMElement:
//==================================================================================

- (void) updateSelectionRectsDOMElement:(DOMElement *)selectionRectsDOMElement
{
    // top-level caller can send selectionRectsDOMElement with <g id='selectedRectsGroup'>
    // then, this method will recursively handle all child elements
    //NSLog(@"enter updateSelectionRectsDOMElement");
    // recursive method
    NSString * nodeName = [selectionRectsDOMElement nodeName];

    NSString * shadow_Macsvgid = [selectionRectsDOMElement getAttribute:@"shadow_Macsvgid"];
    
    if (shadow_Macsvgid == NULL)
    {
        NSLog(@"shadow_Macsvgid = NULL");
    }
    else
    {
        if ([shadow_Macsvgid length] == 0)
        {
            NSLog(@"shadow_Macsvgid is empty");
        }
    }
    
    if ([nodeName isEqualToString:@"rect"] == YES)
    {
        DOMElement * rectElement = (id)selectionRectsDOMElement;

        if (shadow_Macsvgid != NULL)
        {
            if ([shadow_Macsvgid isEqualToString:@""] == NO)
            {
                DOMElement * originalElement = [svgWebKitController domElementForMacsvgid:shadow_Macsvgid];
                
                MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)[NSApp delegate];
                WebKitInterface * webKitInterface = [macSVGAppDelegate webKitInterface];
                
                NSRect boundingBox = [webKitInterface bBoxForDOMElement:originalElement];
                //NSRect boundingBox = [webKitInterface bBoxForDOMElement:originalElement globalContext:[[svgWebView mainFrame] globalContext]];
                
                if (NSIsEmptyRect(boundingBox) == NO)
                {
                    float bboxX = boundingBox.origin.x - 2;
                    float bboxY = boundingBox.origin.y - 2;
                    float bboxWidth = boundingBox.size.width + 4;
                    float bboxHeight = boundingBox.size.height + 4;

                    NSRect expandedRect = NSMakeRect(bboxX, bboxY, bboxWidth, bboxHeight);
                    
                    [webKitInterface setRect:expandedRect forElement:rectElement];

                    NSString * transformAttribute = [originalElement getAttribute:@"transform"];
                    
                    if (transformAttribute != NULL)
                    {
                        if ([transformAttribute length] > 0)
                        {
                            [rectElement setAttributeNS:NULL qualifiedName:@"transform" value:transformAttribute];
                        }
                        else
                        {
                            [rectElement setAttributeNS:NULL qualifiedName:@"transform" value:@""];
                        }
                    }
                    else
                    {
                        [rectElement removeAttributeNS:NULL localName:@"transform"];
                    }
                }
            }
        }
    }

    if ([nodeName isEqualToString:@"g"] == YES)
    {
        DOMElement * gElement = (id)selectionRectsDOMElement;

        if (shadow_Macsvgid != NULL)
        {
            if ([shadow_Macsvgid isEqualToString:@""] == NO)
            {
                DOMElement * originalElement = [svgWebKitController domElementForMacsvgid:shadow_Macsvgid];

                NSString * transformAttribute = [originalElement getAttribute:@"transform"];
                
                if (transformAttribute != NULL)
                {
                    if ([transformAttribute length] > 0)
                    {
                        [gElement setAttributeNS:NULL qualifiedName:@"transform" value:transformAttribute];
                    }
                    else
                    {
                        [gElement setAttributeNS:NULL qualifiedName:@"transform" value:@""];
                    }
                }
                else
                {
                    [gElement removeAttributeNS:NULL localName:@"transform"];
                }
            }
        }
    }

    int selectedRectsCount = selectionRectsDOMElement.childElementCount;
    for (int j = 0; j < selectedRectsCount; j++)
    {
        // recursive call for child elements
        DOMElement * childElement = (id)[(id)selectionRectsDOMElement.childNodes item:j];
        [self updateSelectionRectsDOMElement:childElement];
    }
}



//==================================================================================
//	makeDOMSelectionHandleAtPoint
//==================================================================================

-(void) makeDOMSelectionHandleAtPoint:(NSPoint)handlePoint macsvgid:(NSString *)macsvgid 
        handleOwnerElement:(DOMElement *)handleOwnerElement
        handleParentElement:(DOMElement *)handleParentElement
        orientation:(NSString *)orientation
{
    float bboxX = handlePoint.x - 3;
    float bboxY = handlePoint.y - 3;
    float bboxWidth = 7;
    float bboxHeight = 7;

    NSString * selectionHandleColor = toolSettingsPopoverViewController.selectionHandleColor;
    NSString * selectionHandleSize = toolSettingsPopoverViewController.selectionHandleSize;

    CGFloat reciprocalZoomFactor = 1.0f / svgWebView.zoomFactor;
    CGFloat handleStrokeWidthFloat = 0.0625f * reciprocalZoomFactor;
    NSString * handleStrokeWidth = [self allocPxString:handleStrokeWidthFloat];
    
    NSMutableString * mutableSelectionHandleSize = [NSMutableString stringWithString:selectionHandleSize];
    [mutableSelectionHandleSize replaceOccurrencesOfString:@"px"
            withString:@"" options:0 range:NSMakeRange(0, [mutableSelectionHandleSize length])];
    float selectionHandleSizeFloat = [mutableSelectionHandleSize floatValue];
    
    selectionHandleSizeFloat *= reciprocalZoomFactor;
    
    if (selectionHandleSizeFloat > 0)
    {
        bboxX = handlePoint.x - (selectionHandleSizeFloat / 2.0f);
        bboxY = handlePoint.y - (selectionHandleSizeFloat / 2.0f);
        bboxWidth = selectionHandleSizeFloat;
        bboxHeight = selectionHandleSizeFloat;
    }
    
    if ([orientation isEqualToString:@"top"] == YES)
    {
        bboxY -= 2.0f;
    }
    else if ([orientation isEqualToString:@"topLeft"] == YES)
    {
        bboxX -= 2.0f;
        bboxY -= 2.0f;
    }
    else if ([orientation isEqualToString:@"topRight"] == YES)
    {
        bboxX += 2.0f;
        bboxY -= 2.0f;
    }
    else if ([orientation isEqualToString:@"left"] == YES)
    {
        bboxX -= 2.0f;
    }
    else if ([orientation isEqualToString:@"right"] == YES)
    {
        bboxX += 2.0f;
    }
    else if ([orientation isEqualToString:@"bottom"] == YES)
    {
        bboxY += 2.0f;
    }
    else if ([orientation isEqualToString:@"bottomLeft"] == YES)
    {
        bboxX -= 2.0f;
        bboxY += 2.0f;
    }
    else if ([orientation isEqualToString:@"bottomRight"] == YES)
    {
        bboxX += 2.0f;
        bboxY += 2.0f;
    }

    NSString * bboxXString = [self allocPxString:bboxX];
    NSString * bboxYString = [self allocPxString:bboxY];
    NSString * bboxWidthString = [self allocPxString:bboxWidth];
    NSString * bboxHeightString = [self allocPxString:bboxHeight];

    DOMDocument * domDocument = [[svgWebView mainFrame] DOMDocument];

    DOMElement * selectedItemRectElement = [domDocument createElementNS:svgNamespace
            qualifiedName:@"rect" ];
    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"fill" value:selectionHandleColor];
    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"stroke" value:selectionHandleColor];
    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"pointer-events" value:@"all"]; // allow selection of handles
    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_selectionHandle"];
    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"x" value:bboxXString];
    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"y" value:bboxYString];
    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"width" value:bboxWidthString];
    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"height" value:bboxHeightString];
    //[selectedItemRectElement setAttributeNS:NULL qualifiedName:@"stroke-width" value:@"0.0625px"];
    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"stroke-width" value:handleStrokeWidth];
    
    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"_macsvg_master_Macsvgid" value:macsvgid];
    [selectedItemRectElement setAttributeNS:NULL qualifiedName:@"_macsvg_handle_orientation" value:orientation];
    
    [handleParentElement appendChild:selectedItemRectElement];
}

//==================================================================================
//	makeDOMSelectionHandles
//==================================================================================

-(void) makeDOMSelectionHandles:(DOMElement *)aDomElement
{
    //NSLog(@"enter makeDOMSelectionHandles");
    DOMDocument * domDocument = [[svgWebView mainFrame] DOMDocument];
    
	//DOMNodeList * svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
    //DOMNode * svgElementNode = [svgElementsList item:0];
    //DOMElement * svgElement = (DOMElement *)svgElementNode;
    
    DOMElement * svgElement = [domDocument documentElement];
    DOMNode * svgElementNode = (DOMNode *)svgElement;
    
    [self removeMacsvgTopGroupChildByID:@"_macsvg_selectionHandlesGroup"];
    
    self.domElementForHandles = NULL;
    self.domElementForHandlesCreationTime = 0;
    
    NSString * key_Macsvgid = [aDomElement getAttribute:@"macsvgid"];

    DOMElement * newSelectionHandlesGroup = [domDocument createElementNS:svgNamespace 
            qualifiedName:@"g"];
    [newSelectionHandlesGroup setAttributeNS:NULL qualifiedName:@"id" value:@"_macsvg_selectionHandlesGroup"];
    [newSelectionHandlesGroup setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_selectionHandlesGroup"];
    [newSelectionHandlesGroup setAttributeNS:NULL qualifiedName:@"key_Macsvgid" value:key_Macsvgid];

    // inject new selectionHandlesGroup into DOM
    //[svgElement appendChild:newSelectionHandlesGroup];  // test 20160904 - moved to end
    
    if (aDomElement != NULL)
    {
        DOMElement * handleParentElement = NULL;

        NSString * elementName = [aDomElement nodeName];
        if ([self.validElementsForTransformDictionary objectForKey:elementName] != NULL)
        {
            //DOMElement * parentElement = (id)[aDomElement parentNode];
            DOMElement * parentElement = aDomElement;   // 20160703
            
            // replicate the DOM path of selected item
            NSMutableArray * newParentsArray = [[NSMutableArray alloc] init];
            
            BOOL continueCreatingParents = YES;

            if (parentElement == NULL)
            {
                continueCreatingParents = NO;
            }
            else
            {
                NSString * firstParentTagName = [parentElement nodeName];
                if ([firstParentTagName isEqualToString:@"svg"] == YES)
                {
                    continueCreatingParents = NO;
                }
                if ([firstParentTagName isEqualToString:@"#document"] == YES)
                {
                    continueCreatingParents = NO;
                }
            }
            
            while (continueCreatingParents == YES)
            {
                NSString * parentTagName = [parentElement nodeName];
                
                if (parentElement == aDomElement)
                {
                    parentTagName = @"g";
                }

                DOMElement * newHandleParentElement = [domDocument createElementNS:svgNamespace
                        qualifiedName:parentTagName];

                NSString * parent_Macsvgid = [parentElement getAttribute:@"macsvgid"];
                [newHandleParentElement setAttributeNS:NULL qualifiedName:@"_macsvg_master_Macsvgid" value:parent_Macsvgid];
                [newSelectionHandlesGroup setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_selectionHandlesParent"];

                [self copyChildAnimationFromDOMElement:parentElement toDOMElement:newHandleParentElement];
                
                [newParentsArray insertObject:newHandleParentElement atIndex:0];
                
                if ([parentElement parentNode] == NULL) 
                {
                    continueCreatingParents = NO;
                }
                else
                {
                    DOMNode * nextParentNode = [parentElement parentNode];
                    if (nextParentNode == svgElementNode)
                    {
                        continueCreatingParents = NO;
                    }
                    else if ([[nextParentNode nodeName] isEqualToString:@"#document"] == YES)
                    {
                        continueCreatingParents = NO;
                    }
                    else
                    {
                        parentElement = (id)nextParentNode;
                    }
                }
            }

            // inject new elements into DOM from the top down, starting as child of 'newSelectionHandlesGroup'
            handleParentElement = (id)newSelectionHandlesGroup;
            
            for (DOMElement * aElement in newParentsArray)
            {
                [handleParentElement appendChild:aElement];
                
                handleParentElement = (id)aElement;
            }
        }

        MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)[NSApp delegate];
        WebKitInterface * webKitInterface = [macSVGAppDelegate webKitInterface];

        NSRect boundingBox = [webKitInterface bBoxForDOMElement:aDomElement];
        //boundingBox = [webKitInterface bBoxForDOMElement:aSelectedSvgElement globalContext:[[svgWebView mainFrame] globalContext]];


        if ([[aDomElement nodeName] isEqualToString:@"use"])
        {
            NSString * xAttributeString = [aDomElement getAttribute:@"x"];
            NSString * yAttributeString = [aDomElement getAttribute:@"y"];
            
            CGFloat xAttributeFloat = [xAttributeString floatValue];
            CGFloat yAttributeFloat = [yAttributeString floatValue];
            
            boundingBox.origin.x += xAttributeFloat;
            boundingBox.origin.y += yAttributeFloat;
        }

        if ([[aDomElement nodeName] isEqualToString:@"foreignObject"])
        {
            NSString * xAttributeString = [aDomElement getAttribute:@"x"];
            NSString * yAttributeString = [aDomElement getAttribute:@"y"];
            NSString * widthAttributeString = [aDomElement getAttribute:@"width"];
            NSString * heightAttributeString = [aDomElement getAttribute:@"height"];
            
            CGFloat xAttributeFloat = [xAttributeString floatValue];
            CGFloat yAttributeFloat = [yAttributeString floatValue];
            CGFloat widthAttributeFloat = [widthAttributeString floatValue];
            CGFloat heightAttributeFloat = [heightAttributeString floatValue];
            
            boundingBox.origin.x = xAttributeFloat;
            boundingBox.origin.y = yAttributeFloat;
            boundingBox.size.width = widthAttributeFloat;
            boundingBox.size.height = heightAttributeFloat;
        }
        
        if (NSIsEmptyRect(boundingBox) == NO)
        {
            NSString * macsvgid = [aDomElement getAttribute:@"macsvgid"];
            
            if (macsvgid == NULL)
            {
                NSLog(@"makeDOMSelectionHandles - macsvgid = NULL");
            }
            else
            {
                if ([macsvgid isEqualToString:@""] == YES)
                {
                    NSLog(@"makeDOMSelectionHandles - macsvgid empty");
                }
            }
            
            NSString * transformAttribute = [aDomElement getAttribute:@"transform"];
            if (transformAttribute != NULL)
            {
                if ([transformAttribute length] > 0)
                {
                    [handleParentElement setAttributeNS:NULL qualifiedName:@"transform" value:transformAttribute];
                }
            }
            
            NSString * elementName = [aDomElement nodeName];
            if ([self.validElementsForTransformDictionary objectForKey:elementName] != NULL)
            {
                NSPoint handlePoint = NSZeroPoint;

                handlePoint.x = boundingBox.origin.x;
                handlePoint.y = boundingBox.origin.y;
                [self makeDOMSelectionHandleAtPoint:handlePoint macsvgid:macsvgid 
                        handleOwnerElement:aDomElement
                        handleParentElement:handleParentElement orientation:@"topLeft"];

                handlePoint.x = boundingBox.origin.x + boundingBox.size.width;
                handlePoint.y = boundingBox.origin.y;
                [self makeDOMSelectionHandleAtPoint:handlePoint macsvgid:macsvgid 
                        handleOwnerElement:aDomElement
                        handleParentElement:handleParentElement orientation:@"topRight"];

                handlePoint.x = boundingBox.origin.x;
                handlePoint.y = boundingBox.origin.y + boundingBox.size.height;
                [self makeDOMSelectionHandleAtPoint:handlePoint macsvgid:macsvgid 
                        handleOwnerElement:aDomElement
                        handleParentElement:handleParentElement orientation:@"bottomLeft"];

                handlePoint.x = boundingBox.origin.x + boundingBox.size.width;
                handlePoint.y = boundingBox.origin.y + boundingBox.size.height;
                [self makeDOMSelectionHandleAtPoint:handlePoint macsvgid:macsvgid 
                        handleOwnerElement:aDomElement
                        handleParentElement:handleParentElement orientation:@"bottomRight"];

                handlePoint.x = boundingBox.origin.x + (boundingBox.size.width / 2.0f);
                handlePoint.y = boundingBox.origin.y;
                [self makeDOMSelectionHandleAtPoint:handlePoint macsvgid:macsvgid 
                        handleOwnerElement:aDomElement
                        handleParentElement:handleParentElement orientation:@"top"];

                handlePoint.x = boundingBox.origin.x;
                handlePoint.y = boundingBox.origin.y + (boundingBox.size.height / 2.0f);
                [self makeDOMSelectionHandleAtPoint:handlePoint macsvgid:macsvgid 
                        handleOwnerElement:aDomElement
                        handleParentElement:handleParentElement orientation:@"left"];

                handlePoint.x = boundingBox.origin.x + (boundingBox.size.width / 2.0f);
                handlePoint.y = boundingBox.origin.y + boundingBox.size.height;
                [self makeDOMSelectionHandleAtPoint:handlePoint macsvgid:macsvgid 
                        handleOwnerElement:aDomElement
                        handleParentElement:handleParentElement orientation:@"bottom"];

                handlePoint.x = boundingBox.origin.x + boundingBox.size.width;
                handlePoint.y = boundingBox.origin.y + (boundingBox.size.height / 2.0f);
                [self makeDOMSelectionHandleAtPoint:handlePoint macsvgid:macsvgid 
                        handleOwnerElement:aDomElement
                        handleParentElement:handleParentElement orientation:@"right"];

                [self copyChildAnimationFromDOMElement:aDomElement toDOMElement:handleParentElement];
                
                self.domElementForHandles = aDomElement;
                self.domElementForHandlesCreationTime = time(NULL);
            }
        }
    }
    else
    {
        //NSLog(@"makeDOMSelectionHandles aDomElement is NULL");
    }

    // inject new selectionHandlesGroup into DOM
    
    //[svgElement appendChild:newSelectionHandlesGroup];  // test 20160904 - moved to end
    [self setMacsvgTopGroupChild:newSelectionHandlesGroup];
}

//==================================================================================
//	removeDOMPathSegmentHighlight:
//==================================================================================

-(void) removeDOMPathSegmentHighlight
{
    [self removeMacsvgTopGroupChildByID:@"_macsvg_highlightPathSegmentGroup"];
    [self removeMacsvgTopGroupChildByID:@"_macsvg_highlightPathSegmentMarker"];
    
    //svgWebKitController.domMouseEventsController.svgPathEditor.pathSegmentIndex = -1;
}

//==================================================================================
//	removeDOMPolylinePointHighlight:
//==================================================================================

-(void) removeDOMPolylinePointHighlight
{
    [self removeMacsvgTopGroupChildByID:@"_macsvg_highlightPolylinePointGroup"];

    //svgWebKitController.domMouseEventsController.svgPolylineEditor.polylinePointIndex = -1;
}

//==================================================================================
//	removeDOMLinePointHighlight:
//==================================================================================

-(void) removeDOMLinePointHighlight
{
    [self removeMacsvgTopGroupChildByID:@"_macsvg_highlightLinePointGroup"];

    //svgWebKitController.domMouseEventsController.svgLineEditor.linePointIndex = -1;
}

//==================================================================================
//	highlightPolylinePoint
//==================================================================================

- (IBAction)highlightPolylinePoint
{
    NSUInteger selectedItemsCount = [svgXMLDOMSelectionManager.selectedElementsManager selectedElementsCount];
    
    if (selectedItemsCount == 1)
    {
        NSXMLElement * selectedXMLElement =
                [svgXMLDOMSelectionManager.selectedElementsManager xmlElementAtIndex:0];
        DOMElement * selectedDOMElement =
                [svgXMLDOMSelectionManager.selectedElementsManager domElementAtIndex:0];
        
        NSString * selectedXMLElementName = [selectedXMLElement name];

        BOOL validPolyline = NO;
        if ([selectedXMLElementName isEqualToString:@"polyline"] == YES)
        {
            validPolyline = YES;
        }
        else if ([selectedXMLElementName isEqualToString:@"polygon"] == YES)
        {
            validPolyline = YES;
        }
        
        if (validPolyline == YES)
        {
            if (svgWebKitController.domMouseEventsController.svgPolylineEditor.polylinePointIndex >= 0)
            {
                NSString * pointsString = [selectedDOMElement getAttribute:@"points"];
                
                NSMutableArray * polylinePointsArray = [svgWebKitController.domMouseEventsController.svgPolylineEditor buildPolylinePointsArrayWithPointsString:pointsString];
                
                if (svgWebKitController.domMouseEventsController.svgPolylineEditor.polylinePointIndex < [polylinePointsArray count])
                {
                    NSMutableDictionary * polylinePointDictionary = [polylinePointsArray objectAtIndex:svgWebKitController.domMouseEventsController.svgPolylineEditor.polylinePointIndex];

                    NSString * xString = [polylinePointDictionary objectForKey:@"x"];
                    NSString * yString = [polylinePointDictionary objectForKey:@"y"];
                    
                    CGFloat xFloat = [xString floatValue];
                    CGFloat yFloat = [yString floatValue];
                    
                    NSPoint polylinePoint = NSMakePoint(xFloat, yFloat);
                    
                    [self highlightPolylinePointInDOM:polylinePoint forDOMElement:selectedDOMElement];
                }
                else
                {
                    svgWebKitController.domMouseEventsController.svgPolylineEditor.polylinePointIndex = -1; // index was invalid
                }
            }
        }
    }
}

//==================================================================================
//	highlightPolylinePointInDOM:forDOMElement:
//==================================================================================

-(void) highlightPolylinePointInDOM:(NSPoint)polylinePoint forDOMElement:(DOMElement *)polylineDOMElement
{
    // pathSegmentString is basically a moveto, and a cubic curve
    NSString * selectionHandleColor = self.segmentStrokeHexColor;

    CGFloat reciprocalZoomFactor = 1.0f / svgWebView.zoomFactor;
    CGFloat reciprocalStrokeWidthFloat = self.segmentStrokeWidth * reciprocalZoomFactor;
    
    NSString * selectionStrokeWidth = [self allocPxString:reciprocalStrokeWidthFloat];
    
    if (self.segmentStrokeWidth == 0)
    {
        NSString * selectionStrokeWidthString = toolSettingsPopoverViewController.selectionStrokeWidth;
        reciprocalStrokeWidthFloat = [selectionStrokeWidthString floatValue];
        reciprocalStrokeWidthFloat *= reciprocalZoomFactor;
        
        selectionStrokeWidth = [self allocPxString:reciprocalStrokeWidthFloat];
    }

    DOMDocument * domDocument = [[svgWebView mainFrame] DOMDocument];
    
    DOMElement * topSvgElement = [self macsvgTopGroupElement];

    [self removeDOMPolylinePointHighlight];
    
    if (topSvgElement == NULL)
    {
        DOMNodeList * svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
        
        if ([svgElementsList length] == 0)
        {
            DOMElement * newSvgElement = [domDocument createElementNS:svgNamespace
                    qualifiedName:@"svg"];

            DOMElement * documentElement = [domDocument documentElement];
            
            int clientLeft = [documentElement clientLeft];
            int clientTop = [documentElement clientTop];
            int clientWidth = [documentElement clientWidth];
            int clientHeight = [documentElement clientHeight];
            
            NSString * svgWidth = [NSString stringWithFormat:@"%dpx", clientWidth];
            NSString * svgHeight = [NSString stringWithFormat:@"%dpx", clientHeight];
            NSString * svgViewBox = [NSString stringWithFormat:@"%d %d %d %d", clientLeft, clientTop, clientWidth, clientHeight];

            [newSvgElement setAttribute:@"xmlns" value:@"http://www.w3.org/2000/svg"];
            [newSvgElement setAttribute:@"xmlns:xlink" value:@"http://www.w3.org/1999/xlink"];
            [newSvgElement setAttribute:@"cursor" value:@"crosshair"];
            [newSvgElement setAttribute:@"height" value:svgHeight];
            [newSvgElement setAttribute:@"id" value:@"svg_document"];
            [newSvgElement setAttribute:@"width" value:svgWidth];
            [newSvgElement setAttribute:@"version" value:@"1.1"];
            [newSvgElement setAttribute:@"preserveAspectRatio" value:@"none"];
            [newSvgElement setAttribute:@"viewBox" value:svgViewBox];
            
            [documentElement appendChild:newSvgElement];
            
            svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
        }
        
        DOMNode * svgElementNode = [svgElementsList item:0];
        topSvgElement = (DOMElement *)svgElementNode;
    }

    
    DOMElement * newHighlightPolylinePointGroup = [domDocument createElementNS:svgNamespace
            qualifiedName:@"g"];
    [newHighlightPolylinePointGroup setAttributeNS:NULL qualifiedName:@"id" value:@"_macsvg_highlightPolylinePointGroup"];
    [newHighlightPolylinePointGroup setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_highlightPolylinePointGroup"];

    // inject new newHighlightPathSegmentGroup into DOM
    [topSvgElement appendChild:newHighlightPolylinePointGroup];
    
    NSString * elementName = [polylineDOMElement nodeName];
    if ([self.validElementsForTransformDictionary objectForKey:elementName] != NULL)
    {
        DOMElement * parentElement = (id)[polylineDOMElement parentNode];

        DOMElement * shadowParentElement = NULL;

        if (shadowParentElement == NULL)
        {
            // replicate the segment of the DOM path
            NSMutableArray * newParentsArray = [[NSMutableArray alloc] init];
            
            BOOL continueCreatingParents = YES;

            if (parentElement == NULL)
            {
                continueCreatingParents = NO;
            }
            else
            {
                NSString * firstParentTagName = [parentElement nodeName];
                if ([firstParentTagName isEqualToString:@"svg"] == YES)
                {
                    continueCreatingParents = NO;
                }
                if ([firstParentTagName isEqualToString:@"#document"] == YES)
                {
                    continueCreatingParents = NO;
                }
            }
            
            while (continueCreatingParents == YES)
            {
                NSString * parentTagName = [parentElement nodeName];

                DOMElement * newShadowParentElement = [domDocument createElementNS:svgNamespace
                        qualifiedName:parentTagName];

                NSString * shadow_Macsvgid = [parentElement getAttribute:@"macsvgid"];
                [newShadowParentElement setAttributeNS:NULL qualifiedName:@"shadow_Macsvgid" value:shadow_Macsvgid];
                [newHighlightPolylinePointGroup setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_selectionParent"];

                [self copyChildAnimationFromDOMElement:parentElement toDOMElement:newShadowParentElement];
                
                DOMSelectionCacheRecord * newDOMSelectionCacheRecord = 
                        [[DOMSelectionCacheRecord alloc] init];
                
                newDOMSelectionCacheRecord.parentElement = parentElement;
                newDOMSelectionCacheRecord.shadowParentElement = newShadowParentElement;
                
                [newParentsArray insertObject:newShadowParentElement atIndex:0];
                
                if ([parentElement parentNode] == NULL) 
                {
                    continueCreatingParents = NO;
                }
                else
                {
                    DOMNode * nextParentNode = [parentElement parentNode];

                    NSString * nextParentTagName = [nextParentNode nodeName];
                    if ([nextParentTagName isEqualToString:@"svg"] == YES)
                    {
                        continueCreatingParents = NO;
                    }
                    if ([nextParentTagName isEqualToString:@"#document"] == YES)
                    {
                        continueCreatingParents = NO;
                    }
                    else
                    {
                        parentElement = (DOMElement *)nextParentNode;
                    }
                }
            }

            // inject new elements into DOM from the top down, starting as child of 'newSelectedRectsGroup'
            shadowParentElement = (DOMElement *)newHighlightPolylinePointGroup;
            
            for (DOMElement * aElement in newParentsArray)
            {
                [shadowParentElement appendChild:aElement];
                
                shadowParentElement = (DOMElement *)aElement;
            }
        }
        
        if (shadowParentElement != NULL)
        {    
            // highlight the point
            
            NSString * pathWidthString = [polylineDOMElement getAttribute:@"stroke-width"];
            CGFloat pathWidth = [pathWidthString integerValue];
            if (pathWidth > 0)
            {
                pathWidth += 2;
                selectionStrokeWidth = [NSString stringWithFormat:@"%f", pathWidth];
            }
            
            NSString * xString = [self allocPxString:polylinePoint.x];
            NSString * yString = [self allocPxString:polylinePoint.y];

            DOMElement * pointHandleCircleElement = [domDocument createElementNS:svgNamespace
                    qualifiedName:@"circle" ];
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"pointer-events" value:@"none"]; // disallow selection
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"cx" value:xString];
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"cy" value:yString];
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_highlight_polyline_point"];
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"fill"
                    value:@"none"];
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"stroke" value:selectionHandleColor];
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"stroke-width" value:selectionStrokeWidth];
            
            NSString * pointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
            CGFloat pointRadius = [pointRadiusString floatValue];
            pointRadius *= 2.0f;
            pointRadiusString = [self allocPxString:pointRadius];
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"r"
                    value:pointRadiusString];
            
            //[polylinePointHandlesGroup appendChild:pointHandleCircleElement];



            [shadowParentElement appendChild:pointHandleCircleElement];

            [self copyChildAnimationFromDOMElement:polylineDOMElement toDOMElement:pointHandleCircleElement];



            
            /*
            DOMElement * polylineElement = [domDocument createElementNS:svgNamespace
                    qualifiedName:@"polyline" ];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"fill" value:@"none"];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"stroke" value:selectionHandleColor];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"pointer-events" value:@"none"]; // disallow selection of section rects
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_highlight_path"];
            
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"stroke-width" value:selectionStrokeWidth];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"points" value:polylinePointsString];
            
            
            NSString * shadow_Macsvgid = [polylineDOMElement getAttribute:@"macsvgid"];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"shadow_Macsvgid" value:shadow_Macsvgid];

            [shadowParentElement appendChild:pathSegmentElement];

            [self copyChildAnimationFromDOMElement:polylineDOMElement toDOMElement:pathSegmentElement];
            */
            
            //NSLog(@"selectionRect added %@, %@, %@, %@", bboxXString, bboxYString, bboxWidthString, bboxHeightString);
        }
    }

    // set begin attributes again for animation elements
    DOMNodeList * animationElements = [domDocument getElementsByClassName:@"_macsvg_shadowAnimation"];
    unsigned animationElementsCount = [animationElements length];
    for (int i = 0; i < animationElementsCount; i++)
    {
        DOMElement * shadowAnimationElement = (id)[animationElements item:i];
        
        NSString * beginValue = [shadowAnimationElement getAttribute:@"begin"];
        
        [shadowAnimationElement setAttributeNS:NULL qualifiedName:@"begin" value:beginValue];   // enable animation for element in webkit
    }
}


//==================================================================================
//	highlightLinePointInDOM:forDOMElement:
//==================================================================================

- (IBAction)highlightLinePoint
{
    NSUInteger selectedItemsCount = [svgXMLDOMSelectionManager.selectedElementsManager selectedElementsCount];
    
    if (selectedItemsCount == 1)
    {
        NSXMLElement * selectedXMLElement =
                [svgXMLDOMSelectionManager.selectedElementsManager xmlElementAtIndex:0];
        DOMElement * selectedDOMElement =
                [svgXMLDOMSelectionManager.selectedElementsManager domElementAtIndex:0];
        
        NSString * selectedXMLElementName = [selectedXMLElement name];

        BOOL validLine = NO;
        if ([selectedXMLElementName isEqualToString:@"line"] == YES)
        {
            validLine = YES;
        }
        
        if (validLine == YES)
        {
            if (svgWebKitController.domMouseEventsController.svgLineEditor.linePointIndex >= 0)
            {
                NSString * xString = [selectedDOMElement getAttribute:@"x1"];
                NSString * yString = [selectedDOMElement getAttribute:@"y1"];

                if (svgWebKitController.domMouseEventsController.svgLineEditor.linePointIndex > 0)
                {
                    xString = [selectedDOMElement getAttribute:@"x2"];
                    yString = [selectedDOMElement getAttribute:@"y2"];
                }
                
                CGFloat xFloat = [xString floatValue];
                CGFloat yFloat = [yString floatValue];
                
                NSPoint linePoint = NSMakePoint(xFloat, yFloat);
                
                [self highlightLinePointInDOM:linePoint forDOMElement:selectedDOMElement];
            }
        }
    }
}

//==================================================================================
//	highlightLinePointInDOM:forDOMElement:
//==================================================================================

-(void) highlightLinePointInDOM:(NSPoint)linePoint forDOMElement:(DOMElement *)lineDOMElement
{
    NSString * selectionHandleColor = self.segmentStrokeHexColor;

    CGFloat reciprocalZoomFactor = 1.0f / svgWebView.zoomFactor;
    CGFloat reciprocalStrokeWidthFloat = self.segmentStrokeWidth * reciprocalZoomFactor;
    
    NSString * selectionStrokeWidth = [self allocPxString:reciprocalStrokeWidthFloat];
    
    if (self.segmentStrokeWidth == 0)
    {
        NSString * selectionStrokeWidthString = toolSettingsPopoverViewController.selectionStrokeWidth;
        reciprocalStrokeWidthFloat = [selectionStrokeWidthString floatValue];
        reciprocalStrokeWidthFloat *= reciprocalZoomFactor;
        
        selectionStrokeWidth = [self allocPxString:reciprocalStrokeWidthFloat];
    }

    [self removeDOMLinePointHighlight];

    DOMDocument * domDocument = [[svgWebView mainFrame] DOMDocument];
    
    DOMElement * topSvgElement = [self macsvgTopGroupElement];

    if (topSvgElement == NULL)
    {
        DOMNodeList * svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
        
        if ([svgElementsList length] == 0)
        {
            DOMElement * newSvgElement = [domDocument createElementNS:svgNamespace
                    qualifiedName:@"svg"];

            DOMElement * documentElement = [domDocument documentElement];
            
            int clientLeft = [documentElement clientLeft];
            int clientTop = [documentElement clientTop];
            int clientWidth = [documentElement clientWidth];
            int clientHeight = [documentElement clientHeight];
            
            NSString * svgWidth = [NSString stringWithFormat:@"%dpx", clientWidth];
            NSString * svgHeight = [NSString stringWithFormat:@"%dpx", clientHeight];
            NSString * svgViewBox = [NSString stringWithFormat:@"%d %d %d %d", clientLeft, clientTop, clientWidth, clientHeight];

            [newSvgElement setAttribute:@"xmlns" value:@"http://www.w3.org/2000/svg"];
            [newSvgElement setAttribute:@"xmlns:xlink" value:@"http://www.w3.org/1999/xlink"];
            [newSvgElement setAttribute:@"cursor" value:@"crosshair"];
            [newSvgElement setAttribute:@"height" value:svgHeight];
            [newSvgElement setAttribute:@"id" value:@"svg_document"];
            [newSvgElement setAttribute:@"width" value:svgWidth];
            [newSvgElement setAttribute:@"version" value:@"1.1"];
            [newSvgElement setAttribute:@"preserveAspectRatio" value:@"none"];
            [newSvgElement setAttribute:@"viewBox" value:svgViewBox];
            
            [documentElement appendChild:newSvgElement];
            
            svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
        }
        
        DOMNode * svgElementNode = [svgElementsList item:0];
        topSvgElement = (DOMElement *)svgElementNode;
    }

    
    DOMElement * newHighlightLinePointGroup = [domDocument createElementNS:svgNamespace
            qualifiedName:@"g"];
    [newHighlightLinePointGroup setAttributeNS:NULL qualifiedName:@"id" value:@"_macsvg_highlightLinePointGroup"];
    [newHighlightLinePointGroup setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_highlightLinePointGroup"];

    // inject new newHighlightPathSegmentGroup into DOM
    [topSvgElement appendChild:newHighlightLinePointGroup];
    
    NSString * elementName = [lineDOMElement nodeName];
    if ([self.validElementsForTransformDictionary objectForKey:elementName] != NULL)
    {
        DOMElement * parentElement = (id)[lineDOMElement parentNode];

        DOMElement * shadowParentElement = NULL;

        if (shadowParentElement == NULL)
        {
            // replicate the segment of the DOM path
            NSMutableArray * newParentsArray = [[NSMutableArray alloc] init];
            
            BOOL continueCreatingParents = YES;

            if (parentElement == NULL)
            {
                continueCreatingParents = NO;
            }
            else
            {
                NSString * firstParentTagName = [parentElement nodeName];
                if ([firstParentTagName isEqualToString:@"svg"] == YES)
                {
                    continueCreatingParents = NO;
                }
                if ([firstParentTagName isEqualToString:@"#document"] == YES)
                {
                    continueCreatingParents = NO;
                }
            }
            
            while (continueCreatingParents == YES)
            {
                NSString * parentTagName = [parentElement nodeName];

                DOMElement * newShadowParentElement = [domDocument createElementNS:svgNamespace
                        qualifiedName:parentTagName];

                NSString * shadow_Macsvgid = [parentElement getAttribute:@"macsvgid"];
                [newShadowParentElement setAttributeNS:NULL qualifiedName:@"shadow_Macsvgid" value:shadow_Macsvgid];
                [newHighlightLinePointGroup setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_selectionParent"];

                [self copyChildAnimationFromDOMElement:parentElement toDOMElement:newShadowParentElement];
                
                DOMSelectionCacheRecord * newDOMSelectionCacheRecord = 
                        [[DOMSelectionCacheRecord alloc] init];
                
                newDOMSelectionCacheRecord.parentElement = parentElement;
                newDOMSelectionCacheRecord.shadowParentElement = newShadowParentElement;
                
                [newParentsArray insertObject:newShadowParentElement atIndex:0];
                
                if ([parentElement parentNode] == NULL) 
                {
                    continueCreatingParents = NO;
                }
                else
                {
                    DOMNode * nextParentNode = [parentElement parentNode];

                    NSString * nextParentTagName = [nextParentNode nodeName];
                    if ([nextParentTagName isEqualToString:@"svg"] == YES)
                    {
                        continueCreatingParents = NO;
                    }
                    if ([nextParentTagName isEqualToString:@"#document"] == YES)
                    {
                        continueCreatingParents = NO;
                    }
                    else
                    {
                        parentElement = (DOMElement *)nextParentNode;
                    }
                }
            }

            // inject new elements into DOM from the top down, starting as child of 'newSelectedRectsGroup'
            shadowParentElement = (DOMElement *)newHighlightLinePointGroup;
            
            for (DOMElement * aElement in newParentsArray)
            {
                [shadowParentElement appendChild:aElement];
                
                shadowParentElement = (DOMElement *)aElement;
            }
        }
        
        if (shadowParentElement != NULL)
        {    
            // highlight the point
            
            NSString * pathWidthString = [lineDOMElement getAttribute:@"stroke-width"];
            CGFloat pathWidth = [pathWidthString integerValue];
            if (pathWidth > 0)
            {
                pathWidth += 2;
                selectionStrokeWidth = [NSString stringWithFormat:@"%f", pathWidth];
            }
            
            NSString * xString = [self allocPxString:linePoint.x];
            NSString * yString = [self allocPxString:linePoint.y];

            DOMElement * pointHandleCircleElement = [domDocument createElementNS:svgNamespace
                    qualifiedName:@"circle" ];
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"pointer-events" value:@"none"]; // disallow selection
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"cx" value:xString];
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"cy" value:yString];
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_highlight_polyline_point"];
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"fill"
                    value:@"none"];
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"stroke" value:selectionHandleColor];
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"stroke-width" value:selectionStrokeWidth];
            
            NSString * pointRadiusString = toolSettingsPopoverViewController.pathEndpointRadius;
            CGFloat pointRadius = [pointRadiusString floatValue];
            pointRadius *= 2.0f;
            pointRadiusString = [self allocPxString:pointRadius];
            [pointHandleCircleElement setAttributeNS:NULL qualifiedName:@"r"
                    value:pointRadiusString];
            
            //[polylinePointHandlesGroup appendChild:pointHandleCircleElement];



            [shadowParentElement appendChild:pointHandleCircleElement];

            [self copyChildAnimationFromDOMElement:lineDOMElement toDOMElement:pointHandleCircleElement];



            
            /*
            DOMElement * polylineElement = [domDocument createElementNS:svgNamespace
                    qualifiedName:@"polyline" ];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"fill" value:@"none"];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"stroke" value:selectionHandleColor];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"pointer-events" value:@"none"]; // disallow selection of section rects
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_highlight_path"];
            
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"stroke-width" value:selectionStrokeWidth];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"points" value:polylinePointsString];
            
            
            NSString * shadow_Macsvgid = [polylineDOMElement getAttribute:@"macsvgid"];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"shadow_Macsvgid" value:shadow_Macsvgid];

            [shadowParentElement appendChild:pathSegmentElement];

            [self copyChildAnimationFromDOMElement:polylineDOMElement toDOMElement:pathSegmentElement];
            */
            
            //NSLog(@"selectionRect added %@, %@, %@, %@", bboxXString, bboxYString, bboxWidthString, bboxHeightString);
        }
    }

    // set begin attributes again for animation elements
    DOMNodeList * animationElements = [domDocument getElementsByClassName:@"_macsvg_shadowAnimation"];
    unsigned animationElementsCount = [animationElements length];
    for (int i = 0; i < animationElementsCount; i++)
    {
        DOMElement * shadowAnimationElement = (id)[animationElements item:i];
        
        NSString * beginValue = [shadowAnimationElement getAttribute:@"begin"];
        
        [shadowAnimationElement setAttributeNS:NULL qualifiedName:@"begin" value:beginValue];   // enable animation for element in webkit
    }
}

//==================================================================================
//	highlightPathSegmentInDOM:forDOMElement:
//==================================================================================

-(void) highlightPathSegmentInDOM:(NSString *)pathSegmentString forDOMElement:(DOMElement *)pathDOMElement
{
    // pathSegmentString is basically a moveto, and a cubic curve
    NSString * selectionHandleColor = self.segmentStrokeHexColor;

    CGFloat reciprocalZoomFactor = 1.0f / svgWebView.zoomFactor;
    CGFloat reciprocalStrokeWidthFloat = self.segmentStrokeWidth * reciprocalZoomFactor;
    
    NSString * selectionStrokeWidth = [self allocPxString:reciprocalStrokeWidthFloat];
    
    if (self.segmentStrokeWidth == 0)
    {
        NSString * selectionStrokeWidthString = toolSettingsPopoverViewController.selectionStrokeWidth;
        reciprocalStrokeWidthFloat = [selectionStrokeWidthString floatValue];
        reciprocalStrokeWidthFloat *= reciprocalZoomFactor;
        
        selectionStrokeWidth = [self allocPxString:reciprocalStrokeWidthFloat];
    }

    DOMDocument * domDocument = [[svgWebView mainFrame] DOMDocument];
    
    DOMElement * topSvgElement = [self macsvgTopGroupElement];

    [self removeDOMPathSegmentHighlight];
    
    if (topSvgElement == NULL)
    {
        DOMNodeList * svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
        
        if ([svgElementsList length] == 0)
        {
            DOMElement * newSvgElement = [domDocument createElementNS:svgNamespace
                    qualifiedName:@"svg"];

            DOMElement * documentElement = [domDocument documentElement];
            
            int clientLeft = [documentElement clientLeft];
            int clientTop = [documentElement clientTop];
            int clientWidth = [documentElement clientWidth];
            int clientHeight = [documentElement clientHeight];
            
            NSString * svgWidth = [NSString stringWithFormat:@"%dpx", clientWidth];
            NSString * svgHeight = [NSString stringWithFormat:@"%dpx", clientHeight];
            NSString * svgViewBox = [NSString stringWithFormat:@"%d %d %d %d", clientLeft, clientTop, clientWidth, clientHeight];

            [newSvgElement setAttribute:@"xmlns" value:@"http://www.w3.org/2000/svg"];
            [newSvgElement setAttribute:@"xmlns:xlink" value:@"http://www.w3.org/1999/xlink"];
            [newSvgElement setAttribute:@"cursor" value:@"crosshair"];
            [newSvgElement setAttribute:@"height" value:svgHeight];
            [newSvgElement setAttribute:@"id" value:@"svg_document"];
            [newSvgElement setAttribute:@"width" value:svgWidth];
            [newSvgElement setAttribute:@"version" value:@"1.1"];
            [newSvgElement setAttribute:@"preserveAspectRatio" value:@"none"];
            [newSvgElement setAttribute:@"viewBox" value:svgViewBox];
            
            [documentElement appendChild:newSvgElement];
            
            svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
        }
        
        DOMNode * svgElementNode = [svgElementsList item:0];
        topSvgElement = (DOMElement *)svgElementNode;
    }



    // inject marker ref into DOM
	DOMNodeList * defsElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"defs"];

    if ([defsElementsList length] == 0)
    {
        DOMElement * newDefsElement = [domDocument createElementNS:svgNamespace
                qualifiedName:@"defs"];
        
        DOMElement * firstElement = [topSvgElement firstElementChild];
        
        [topSvgElement insertBefore:newDefsElement refChild:firstElement];
        
        defsElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"defs"];
    }
    
    DOMElement * defsElement = (DOMElement *)[defsElementsList item:0];

    DOMElement * markerElement = [self getMacsvgTopGroupChildByID:@"_macsvg_highlightPathSegmentMarker" createIfNew:NO];

    if (markerElement == NULL)
    {
        markerElement = [domDocument createElementNS:svgNamespace
                qualifiedName:@"marker" ];
        [markerElement setAttributeNS:NULL qualifiedName:@"id" value:@"_macsvg_highlightPathSegmentMarker"];
        
        CGFloat markerWidthFloat = 4.0f * reciprocalZoomFactor;
        NSString * markerWidthString = [self allocPxString:markerWidthFloat];
        CGFloat markerHeightFloat = 3.0f * reciprocalZoomFactor;
        NSString * markerHeightString = [self allocPxString:markerHeightFloat];

        DOMElement * markerElement = [domDocument createElementNS:svgNamespace
                qualifiedName:@"marker" ];
        [markerElement setAttributeNS:NULL qualifiedName:@"id" value:@"_macsvg_highlightPathSegmentMarker"];
        [markerElement setAttributeNS:NULL qualifiedName:@"viewBox" value:@"0 0 10 10"];
        [markerElement setAttributeNS:NULL qualifiedName:@"refX" value:@"10"];
        [markerElement setAttributeNS:NULL qualifiedName:@"refY" value:@"5"];
        [markerElement setAttributeNS:NULL qualifiedName:@"markerUnits" value:@"strokeWidth"];
        //[markerElement setAttributeNS:NULL qualifiedName:@"markerWidth" value:@"4"];
        [markerElement setAttributeNS:NULL qualifiedName:@"markerWidth" value:markerWidthString];
        //[markerElement setAttributeNS:NULL qualifiedName:@"markerHeight" value:@"3"];
        [markerElement setAttributeNS:NULL qualifiedName:@"markerHeight" value:markerHeightString];
        [markerElement setAttributeNS:NULL qualifiedName:@"orient" value:@"auto"];
        //[markerElement setAttributeNS:NULL qualifiedName:@"stroke" value:selectionHandleColor];
        [markerElement setAttributeNS:NULL qualifiedName:@"fill" value:selectionHandleColor];
        [markerElement setAttributeNS:NULL qualifiedName:@"style" value:@"overflow : visible;"];
        
        DOMElement * markerPathElement = [domDocument createElementNS:svgNamespace
                qualifiedName:@"path" ];
        [markerPathElement setAttributeNS:NULL qualifiedName:@"d" value:@"M 0 0 L 10 5 L 0 10 z"];

        [markerElement appendChild:markerPathElement];

        [defsElement appendChild:markerElement];
    }
    



    
    DOMElement * newHighlightPathSegmentGroup = [domDocument createElementNS:svgNamespace
            qualifiedName:@"g"];
    [newHighlightPathSegmentGroup setAttributeNS:NULL qualifiedName:@"id" value:@"_macsvg_highlightPathSegmentGroup"];
    [newHighlightPathSegmentGroup setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_highlightPathSegmentGroup"];


    // inject new newHighlightPathSegmentGroup into DOM
    [topSvgElement appendChild:newHighlightPathSegmentGroup];
    
    NSString * elementName = [pathDOMElement nodeName];
    if ([self.validElementsForTransformDictionary objectForKey:elementName] != NULL)
    {
        DOMElement * parentElement = (id)[pathDOMElement parentNode];

        DOMElement * shadowParentElement = NULL;

        if (shadowParentElement == NULL)
        {
            // replicate the segment of the DOM path
            NSMutableArray * newParentsArray = [[NSMutableArray alloc] init];
            
            BOOL continueCreatingParents = YES;

            if (parentElement == NULL)
            {
                continueCreatingParents = NO;
            }
            else
            {
                NSString * firstParentTagName = [parentElement nodeName];
                if ([firstParentTagName isEqualToString:@"svg"] == YES)
                {
                    continueCreatingParents = NO;
                }
                if ([firstParentTagName isEqualToString:@"#document"] == YES)
                {
                    continueCreatingParents = NO;
                }
            }
            
            while (continueCreatingParents == YES)
            {
                NSString * parentTagName = [parentElement nodeName];

                DOMElement * newShadowParentElement = [domDocument createElementNS:svgNamespace
                        qualifiedName:parentTagName];

                NSString * shadow_Macsvgid = [parentElement getAttribute:@"macsvgid"];
                [newShadowParentElement setAttributeNS:NULL qualifiedName:@"shadow_Macsvgid" value:shadow_Macsvgid];
                [newHighlightPathSegmentGroup setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_selectionParent"];

                [self copyChildAnimationFromDOMElement:parentElement toDOMElement:newShadowParentElement];
                
                DOMSelectionCacheRecord * newDOMSelectionCacheRecord = 
                        [[DOMSelectionCacheRecord alloc] init];
                
                newDOMSelectionCacheRecord.parentElement = parentElement;
                newDOMSelectionCacheRecord.shadowParentElement = newShadowParentElement;
                
                [newParentsArray insertObject:newShadowParentElement atIndex:0];
                
                if ([parentElement parentNode] == NULL) 
                {
                    continueCreatingParents = NO;
                }
                else
                {
                    DOMNode * nextParentNode = [parentElement parentNode];

                    NSString * nextParentTagName = [nextParentNode nodeName];
                    if ([nextParentTagName isEqualToString:@"svg"] == YES)
                    {
                        continueCreatingParents = NO;
                    }
                    if ([nextParentTagName isEqualToString:@"#document"] == YES)
                    {
                        continueCreatingParents = NO;
                    }
                    else
                    {
                        parentElement = (DOMElement *)nextParentNode;
                    }
                }
            }

            // inject new elements into DOM from the top down, starting as child of 'newSelectedRectsGroup'
            shadowParentElement = (DOMElement *)newHighlightPathSegmentGroup;
            
            for (DOMElement * aElement in newParentsArray)
            {
                [shadowParentElement appendChild:aElement];
                
                shadowParentElement = (DOMElement *)aElement;
            }
        }
        
        if (shadowParentElement != NULL)
        {    
            // draw the path segment highlight
            
            NSString * pathWidthString = [pathDOMElement getAttribute:@"stroke-width"];
            CGFloat pathWidth = [pathWidthString integerValue];
            if (pathWidth > 0)
            {
                pathWidth += 2;
                selectionStrokeWidth = [NSString stringWithFormat:@"%f", pathWidth];
            }
            
            DOMElement * pathSegmentElement = [domDocument createElementNS:svgNamespace
                    qualifiedName:@"path" ];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"fill" value:@"none"];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"stroke" value:selectionHandleColor];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"pointer-events" value:@"none"]; // disallow selection of section rects
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"class" value:@"_macsvg_highlight_path"];
            
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"stroke-width" value:selectionStrokeWidth];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"marker-end" value:@"url(#_macsvg_highlightPathSegmentMarker)"];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"d" value:pathSegmentString];
            
            
            NSString * shadow_Macsvgid = [pathDOMElement getAttribute:@"macsvgid"];
            [pathSegmentElement setAttributeNS:NULL qualifiedName:@"shadow_Macsvgid" value:shadow_Macsvgid];

            [shadowParentElement appendChild:pathSegmentElement];

            [self copyChildAnimationFromDOMElement:pathDOMElement toDOMElement:pathSegmentElement];

            //NSLog(@"selectionRect added %@, %@, %@, %@", bboxXString, bboxYString, bboxWidthString, bboxHeightString);
        }
    }

    // set begin attributes again for animation elements
    DOMNodeList * animationElements = [domDocument getElementsByClassName:@"_macsvg_shadowAnimation"];
    unsigned animationElementsCount = [animationElements length];
    for (int i = 0; i < animationElementsCount; i++)
    {
        DOMElement * shadowAnimationElement = (id)[animationElements item:i];
        
        NSString * beginValue = [shadowAnimationElement getAttribute:@"begin"];
        
        [shadowAnimationElement setAttributeNS:NULL qualifiedName:@"begin" value:beginValue];   // enable animation for element in webkit
    }
}


//==================================================================================
//	highlightPathSegment:
//==================================================================================

- (IBAction)highlightPathSegment
{
    NSUInteger selectedItemsCount = [svgXMLDOMSelectionManager.selectedElementsManager selectedElementsCount];
    
    if (selectedItemsCount == 1)
    {
        NSXMLElement * selectedXMLElement =
                [svgXMLDOMSelectionManager.selectedElementsManager xmlElementAtIndex:0];
        DOMElement * selectedDOMElement =
                [svgXMLDOMSelectionManager.selectedElementsManager domElementAtIndex:0];
        
        NSString * selectedXMLElementName = [selectedXMLElement name];

        if ([selectedXMLElementName isEqualToString:@"path"] == YES)
        {
            //if (self.pathSegmentIndex >= 0)
            if (svgWebKitController.domMouseEventsController.svgPathEditor.pathSegmentIndex >= 0)
            {
                //NSMutableArray * pathSegmentsArray = svgXMLDOMSelectionManager.pathSegmentsArray;
                
                NSString * pathString = [selectedDOMElement getAttribute:@"d"];
                
                NSMutableArray * pathSegmentsArray = [svgWebKitController.domMouseEventsController.svgPathEditor buildPathSegmentsArrayWithPathString:pathString];
                
                //if (self.pathSegmentIndex < [pathSegmentsArray count])
                if (svgWebKitController.domMouseEventsController.svgPathEditor.pathSegmentIndex < [pathSegmentsArray count])
                {
                    NSMutableString * newPathString = [NSMutableString string];
                    
                    PathFunctions * pathFunctions = macSVGDocumentWindowController.pathFunctions;
                    
                    NSMutableArray * bezierPathSegmentsArray = [pathFunctions
                            convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray:pathSegmentsArray];
                    
                    //NSMutableDictionary * pathSegmentDictionary = [bezierPathSegmentsArray objectAtIndex:self.pathSegmentIndex];
                    NSMutableDictionary * pathSegmentDictionary =
                            [bezierPathSegmentsArray objectAtIndex:svgWebKitController.domMouseEventsController.svgPathEditor.pathSegmentIndex];

                    NSString * startXString = [pathSegmentDictionary objectForKey:@"x"];
                    NSString * startYString = [pathSegmentDictionary objectForKey:@"y"];
                    
                    //if (self.pathSegmentIndex > 0)
                    if (svgWebKitController.domMouseEventsController.svgPathEditor.pathSegmentIndex > 0)
                    {
                        // get current starting point from previous segment
                        //NSMutableDictionary * previousPathSegmentDictionary =
                        //        [pathSegmentsArray objectAtIndex:(self.pathSegmentIndex - 1)];
                        NSMutableDictionary * previousPathSegmentDictionary =
                                [pathSegmentsArray objectAtIndex:(svgWebKitController.domMouseEventsController.svgPathEditor.pathSegmentIndex - 1)];

                        NSNumber * startXNumber = [previousPathSegmentDictionary objectForKey:@"absoluteX"];
                        NSNumber * startYNumber = [previousPathSegmentDictionary objectForKey:@"absoluteY"];
                        
                        startXString = [startXNumber stringValue];
                        startYString = [startYNumber stringValue];
                    }
                    
                    if ([startXString length] == 0)
                    {
                        startXString = @"0";
                    }
                    if ([startYString length] == 0)
                    {
                        startYString = @"0";
                    }

                    // move to initial position of segment
                    [newPathString appendString:@"M"];

                    [newPathString appendString:startXString];

                    [newPathString appendString:@","];

                    [newPathString appendString:startYString];
                    
                    [newPathString appendString:@" "];
                    
                    
                    
                    NSString * pathCommandString = [pathSegmentDictionary objectForKey:@"command"];
                    unichar commandChar = [pathCommandString characterAtIndex:0];
                    
                    // draw the path segment
                    switch (commandChar) 
                    {
                        case 'M':     // moveto
                        case 'm':     // moveto
                        {
                            //if (self.pathSegmentIndex == 0)
                            if (svgWebKitController.domMouseEventsController.svgPathEditor.pathSegmentIndex == 0)
                            {
                                [newPathString appendString:@"M"];
                            }
                            else
                            {
                                [newPathString appendString:pathCommandString];
                            }
                            
                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            
                            [newPathString appendString:@","];
                            
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            
                            [newPathString appendString:@" "];
                            
                            break;
                        }
                        case 'L':     // lineto
                        {
                            [newPathString appendString:@"L"];
                            
                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            [newPathString appendString:@","];
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 'l':     // lineto
                        {
                            [newPathString appendString:@"l"];
                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            [newPathString appendString:@","];
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 'H':     // horizontal lineto
                        {
                            [newPathString appendString:@"H"];
                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 'h':     // horizontal lineto
                        {
                            [newPathString appendString:@"h"];
                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 'V':     // vertical lineto
                        {
                            [newPathString appendString:@"V"];
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 'v':     // vertical lineto
                        {
                            [newPathString appendString:@"v"];
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 'C':     // curveto
                        {
                            [newPathString appendString:@"C"];
                            NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                            [newPathString appendString:x1String];
                            [newPathString appendString:@","];
                            NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                            [newPathString appendString:y1String];
                            [newPathString appendString:@" "];

                            NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                            [newPathString appendString:x2String];
                            [newPathString appendString:@","];
                            NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                            [newPathString appendString:y2String];
                            [newPathString appendString:@" "];

                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            [newPathString appendString:@","];
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 'c':     // curveto
                        {
                            [newPathString appendString:@"c"];
                            NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                            [newPathString appendString:x1String];
                            [newPathString appendString:@","];
                            NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                            [newPathString appendString:y1String];
                            [newPathString appendString:@" "];

                            NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                            [newPathString appendString:x2String];
                            [newPathString appendString:@","];
                            NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                            [newPathString appendString:y2String];
                            [newPathString appendString:@" "];

                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            [newPathString appendString:@","];
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 'S':     // smooth curveto
                        {
                            [newPathString appendString:@"S"];

                            NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                            [newPathString appendString:x2String];
                            [newPathString appendString:@","];
                            NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                            [newPathString appendString:y2String];
                            [newPathString appendString:@" "];

                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            [newPathString appendString:@","];
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 's':     // smooth curveto
                        {
                            [newPathString appendString:@"s"];

                            NSString * x2String = [pathSegmentDictionary objectForKey:@"x2"];
                            [newPathString appendString:x2String];
                            [newPathString appendString:@","];
                            NSString * y2String = [pathSegmentDictionary objectForKey:@"y2"];
                            [newPathString appendString:y2String];
                            [newPathString appendString:@" "];

                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            [newPathString appendString:@","];
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 'Q':     // quadratic Bezier curve
                        {
                            [newPathString appendString:@"Q"];
                            NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                            [newPathString appendString:x1String];
                            [newPathString appendString:@","];
                            NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                            [newPathString appendString:y1String];
                            [newPathString appendString:@" "];

                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            [newPathString appendString:@","];
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 'q':     // quadratic Bezier curve
                        {
                            [newPathString appendString:@"q"];
                            NSString * x1String = [pathSegmentDictionary objectForKey:@"x1"];
                            [newPathString appendString:x1String];
                            [newPathString appendString:@","];
                            NSString * y1String = [pathSegmentDictionary objectForKey:@"y1"];
                            [newPathString appendString:y1String];
                            [newPathString appendString:@" "];

                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            [newPathString appendString:@","];
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 'T':     // smooth quadratic Bezier curve
                        {
                            [newPathString appendString:@"T"];
                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            [newPathString appendString:@","];
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 't':     // smooth quadratic Bezier curve
                        {
                            [newPathString appendString:@"t"];
                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            [newPathString appendString:@","];
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 'A':     // elliptical arc
                        {
                            [newPathString appendString:@"A"];
                            
                            NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                            [newPathString appendString:rxString];
                            [newPathString appendString:@","];
                            NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                            [newPathString appendString:ryString];
                            [newPathString appendString:@" "];
                            
                            NSString * dataXAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                            [newPathString appendString:dataXAxisRotationString];
                            [newPathString appendString:@" "];
                            
                            NSString * dataLargeArcString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                            [newPathString appendString:dataLargeArcString];
                            [newPathString appendString:@" "];
                            
                            NSString * sweepString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
                            [newPathString appendString:sweepString];
                            [newPathString appendString:@" "];
                            
                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            [newPathString appendString:@","];
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 'a':     // elliptical arc
                        {
                            [newPathString appendString:@"a"];
                            
                            NSString * rxString = [pathSegmentDictionary objectForKey:@"rx"];
                            [newPathString appendString:rxString];
                            [newPathString appendString:@","];
                            NSString * ryString = [pathSegmentDictionary objectForKey:@"ry"];
                            [newPathString appendString:ryString];
                            [newPathString appendString:@" "];
                            
                            NSString * aXAxisRotationString = [pathSegmentDictionary objectForKey:@"x-axis-rotation"];
                            [newPathString appendString:aXAxisRotationString];
                            [newPathString appendString:@" "];
                            
                            NSString * largeArcString = [pathSegmentDictionary objectForKey:@"large-arc-flag"];
                            [newPathString appendString:largeArcString];
                            [newPathString appendString:@" "];
                            
                            NSString * sweepString = [pathSegmentDictionary objectForKey:@"sweep-flag"];
                            [newPathString appendString:sweepString];
                            [newPathString appendString:@" "];
                            
                            NSString * xString = [pathSegmentDictionary objectForKey:@"x"];
                            [newPathString appendString:xString];
                            [newPathString appendString:@","];
                            NSString * yString = [pathSegmentDictionary objectForKey:@"y"];
                            [newPathString appendString:yString];
                            [newPathString appendString:@" "];
                            break;
                        }
                        case 'Z':     // closepath
                        {
                            [newPathString appendString:@" Z "];
                            break;
                        }
                        case 'z':     // closepath
                        {
                            [newPathString appendString:@" z "];
                            break;
                        }
                    }
                    
                    [self highlightPathSegmentInDOM:newPathString forDOMElement:selectedDOMElement];
                }
                else
                {
                    //self.pathSegmentIndex = -1; // index was invalid
                    svgWebKitController.domMouseEventsController.svgPolylineEditor.polylinePointIndex = -1; // index was invalid
                }
            }
        }
    }
}

//==================================================================================
//	keyDOMElement
//==================================================================================

- (DOMElement *)keyDOMElement
{
    DOMElement * keyDOMElement = NULL;
    
    // try fast method first
    if (self.domElementForHandles != NULL)
    {
        if (self.domElementForHandlesCreationTime != 0)
        {
            time_t lastWebViewLoadTime = svgWebKitController.lastLoadFinishedTime;
            if (lastWebViewLoadTime != 0)
            {
                if (lastWebViewLoadTime < self.domElementForHandlesCreationTime)
                {
                    keyDOMElement = self.domElementForHandles;
                }
            }
        }
    }

    if (keyDOMElement == NULL)
    {
        /*
        NSString * selectionHandlesGroupID = @"_macsvg_selectionHandlesGroup";
        
        DOMDocument * domDocument = [[svgWebView mainFrame] DOMDocument];

        DOMElement * domSelectedRectsGroup = [domDocument getElementById:selectionHandlesGroupID];
        */
        
        DOMElement * domSelectedRectsGroup = [self getMacsvgTopGroupChildByID:@"_macsvg_selectionHandlesGroup" createIfNew:NO];

        if (domSelectedRectsGroup != NULL)
        {
            NSString * key_Macsvgid = [domSelectedRectsGroup getAttribute:@"key_Macsvgid"];
            
            keyDOMElement = [svgWebKitController domElementForMacsvgid:key_Macsvgid];
        }
    }
    
    return keyDOMElement;
}


//==================================================================================
//	keyXMLElement
//==================================================================================

- (NSXMLElement *)keyXMLElement
{
    NSXMLElement * keyXMLElement = NULL;

    /*
    NSString * selectionHandlesGroupID = @"_macsvg_selectionHandlesGroup";
    
    DOMDocument * domDocument = [[svgWebView mainFrame] DOMDocument];

    DOMElement * domSelectedRectsGroup = [domDocument getElementById:selectionHandlesGroupID];
    */

    DOMElement * domSelectedRectsGroup = [self getMacsvgTopGroupChildByID:@"_macsvg_selectionHandlesGroup" createIfNew:NO];
    
    if (domSelectedRectsGroup != NULL)
    {
        NSString * key_Macsvgid = [domSelectedRectsGroup getAttribute:@"key_Macsvgid"];
        
        MacSVGDocument * macSVGDocument = [macSVGDocumentWindowController document];

        keyXMLElement = [macSVGDocument xmlElementForMacsvgid:key_Macsvgid];
    }
    
    //DOMElement * keyDOMElement = [self keyDOMElement];  // TEST remove after testing
    
    return keyXMLElement;
}



@end
