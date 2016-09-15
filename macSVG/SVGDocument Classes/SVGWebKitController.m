//
//  SVGWebKitController.m
//  macSVG
//
//  Created by Douglas Ward on 9/18/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "SVGWebKitController.h"
#import <WebKit/WebKit.h>
#import "MacSVGDocument.h"
#import "MacSVGDocumentWindowController.h"
#import "SVGXMLDOMSelectionManager.h"
#import "SelectedElementsManager.h"
#import "SVGWebView.h"
#import "SVGPathEditor.h"
#import "XMLOutlineController.h"
#import "AnimationTimelineView.h"
#import "DOMMouseEventsController.h"
#import "MacSVGAppDelegate.h"
#import "WebKitInterface.h"
#import "DOMSelectionRectsAndHandlesManager.h"
#import "objc/message.h"

@implementation SVGWebKitController

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

    [self stopPeriodicTimer];
    
    self.svgWebView.downloadDelegate = NULL;
    self.svgWebView.frameLoadDelegate = NULL;
    self.svgWebView.policyDelegate = NULL;
    self.svgWebView.UIDelegate = NULL;
    self.svgWebView.resourceLoadDelegate = NULL;
    self.svgWebView.editingDelegate = NULL;
}

/*
//==================================================================================
//	isSelectorExcludedFromWebScript
//==================================================================================

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector 
{
    // required for WebView JavaScript-to-Cocoa communication
    if (aSelector == @selector(consoleLog:)) 
    {
        return NO;
    }
    
    return YES;
}

//==================================================================================
//	isKeyExcludedFromWebScript
//==================================================================================

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name
{
    return NO;  // required for WebView JavaScript-to-Cocoa communication
}

//==================================================================================
//	setupJavascriptToCocoaCommunications
//==================================================================================
- (void)setupJavascriptToCocoaCommunications
{
    // For Javascript-to-Cocoa communications
    [[svgWebView windowScriptObject] setValue:self forKey:@"SVGWebKitController"];
}
//==================================================================================
//	logJSMessage
//==================================================================================

- (void)consoleLog:(NSString *)aMessage 
{
    // called from Javascript like this: 
    //      console.log("message");
    NSLog(@"Javascript console.log: %@", aMessage);
}
*/

//==================================================================================
//	init
//==================================================================================

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
        self.periodicTimer = NULL;
        self.mainFrameIsLoading = NO;
        self.lastLoadFinishedTime = 0;
    }
    
    return self;
}

//==================================================================================
//	awakeFromNib
//==================================================================================

- (void)awakeFromNib
{
    [super awakeFromNib];
}



//==================================================================================
//	updateTimerInfo:
//==================================================================================

- (void)updateTimerInfo:(NSTimer *)theTimer 
{
    NSInteger animationEnabled = self.macSVGDocumentWindowController.enableAnimationCheckbox.state;

    if (animationEnabled != 0)
    {
        DOMDocument * domDocument = [[self.svgWebView mainFrame] DOMDocument];
        
        DOMNodeList * svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
        
        if (svgElementsList.length > 0)
        {
            DOMNode * svgElementNode = [svgElementsList item:0];
            
            DOMElement * svgElement = (DOMElement *)svgElementNode;
            
            MacSVGAppDelegate * macSVGAppDelegate = [NSApp delegate];
            WebKitInterface * webKitInterface = [macSVGAppDelegate webKitInterface];

            if ([webKitInterface animationsPausedForSvgElement:svgElement] == NO)
            {
                float currentTime = [webKitInterface getCurrentTimeForSvgElement:svgElement];
                
                NSString * currentTimeString = [[NSString alloc] initWithFormat:@"%.2f", currentTime];
                
                [self.currentTimeTextField setStringValue:currentTimeString];
                
                self.macSVGDocumentWindowController.currentTimeString = currentTimeString;
                
                [self.macSVGDocumentWindowController.animationTimelineView setPlayHeadPosition:currentTime];
            }
        }
        else
        {
            [self.currentTimeTextField setStringValue:@"N/A"];
        }
    }
    else
    {
        [self.currentTimeTextField setStringValue:@"0.00"];
    }
}

//==================================================================================
//	startPeriodicTimer
//==================================================================================

-(void) startPeriodicTimer
{
    if (self.periodicTimer == NULL)
    {
        self.periodicTimer = [NSTimer scheduledTimerWithTimeInterval:0.025f
                 target:self
                 selector:@selector(updateTimerInfo:)
                 userInfo:nil
                 repeats:YES];
    }
}

//==================================================================================
//	stopPeriodicTimer
//==================================================================================

-(void) stopPeriodicTimer
{
	if (self.periodicTimer != NULL)
    {
        [self.periodicTimer invalidate];
        self.periodicTimer = NULL;
    }
}

//==================================================================================
//	reloadXML
//==================================================================================

- (void)reloadXML
{
    //NSLog(@"reloadXML");
    if (self.mainFrameIsLoading == NO)
    {
        NSURL * baseURL = NULL;
        
        MacSVGDocument * macSVGDocument = [self.macSVGDocumentWindowController document];
        
        NSString * fileName = [macSVGDocument lastComponentOfFileName];
        
        NSString * fileTypeExtension = [fileName pathExtension];
        
        NSString * fileType = @"svg";
        if (fileTypeExtension != NULL)
        {
            if ([fileTypeExtension isEqualToString:@"svg"] == YES)
            {
                fileType = @"svg";
            }
            if ([fileTypeExtension isEqualToString:@"xhtml"] == YES)
            {
                fileType = @"xhtml";
            }
        }
        
        NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;
        
        NSData * xmlData = [svgXmlDocument XMLData];

        BOOL getXmlString = NO;
        
        NSString * mimeType = @"image/svg+xml";
        if ([fileType isEqualToString:@"xhtml"] == YES)
        {
            mimeType = @"application/xhtml+xml";
        }

        [[self.svgWebView mainFrame] loadData:xmlData 
                MIMEType:mimeType	
                textEncodingName:@"UTF-8" 
                baseURL:baseURL];
        
        [self.svgWebView setSVGZoomStyleWithFloat:self.svgWebView.zoomFactor];

        if (getXmlString == YES)
        {
            NSString * xmlString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];   // test
            NSLog(@"reloadXML stringData = %@", xmlString);
        }
    }
    else
    {
        NSLog(@"SVGWebKitController - reloadXML skipped due to mainFrameIsLoading=YES");
    }
    
    [self.svgWebView setEditable:NO];
}

//==================================================================================
//	removeXMLAnimationElements:
//==================================================================================

- (void)removeXMLAnimationElements:(NSXMLElement *)aElement
{
    //NSLog(@"removeXMLAnimationElements");

    NSArray * childrenArray = [aElement children];
    
    for (NSXMLNode * childNode in childrenArray)
    {
        if ([childNode kind] == NSXMLElementKind)
        {
            NSXMLElement * childElement = (id)childNode;
            
            BOOL isAnimationElement = NO;
            
            NSString * tagName = [childElement name];
            
            if ([tagName isEqualToString:@"animate"]) isAnimationElement = YES;
            if ([tagName isEqualToString:@"animateMotion"]) isAnimationElement = YES;
            if ([tagName isEqualToString:@"animateColor"]) isAnimationElement = YES;
            if ([tagName isEqualToString:@"animateTransform"]) isAnimationElement = YES;
            if ([tagName isEqualToString:@"set"]) isAnimationElement = YES;
            
            if (isAnimationElement == YES)
            {
                //[childElement detach];
                NSInteger childElementIndex = [childElement index];
                [aElement removeChildAtIndex:childElementIndex];
            }
            else
            {
                [self removeXMLAnimationElements:childElement]; // recursive call
            }
        }
    }
}

//==================================================================================
//	reloadXMLWithoutAnimation
//==================================================================================

- (void)reloadXMLWithoutAnimation
{
    //NSLog(@"reloadXMLWithoutAnimation");

    NSURL * baseURL = NULL;
    
    MacSVGDocument * macSVGDocument = [self.macSVGDocumentWindowController document];
    
    NSString * fileName = [macSVGDocument lastComponentOfFileName];
    
    NSString * fileTypeExtension = [fileName pathExtension];
    
    NSString * fileType = @"svg";
    if (fileTypeExtension != NULL)
    {
        if ([fileTypeExtension isEqualToString:@"svg"] == YES)
        {
            fileType = @"svg";
        }
        if ([fileTypeExtension isEqualToString:@"xhtml"] == YES)
        {
            fileType = @"xhtml";
        }
    }
    
    NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;
    
    NSData * originalXmlData = [[NSData alloc] initWithData:[svgXmlDocument XMLData]];
    
    NSError * xmlError;
    NSXMLDocument * tempXMLDocument = [[NSXMLDocument alloc] initWithData:originalXmlData options:0 error:&xmlError];
    
    [self removeXMLAnimationElements:[tempXMLDocument rootElement]];

    NSData * finalXmlData = [tempXMLDocument XMLData];

    NSString * mimeType = @"image/svg+xml";
    if ([fileType isEqualToString:@"xhtml"] == YES)
    {
        mimeType = @"application/xhtml+xml";
    }

    [[self.svgWebView mainFrame] loadData:finalXmlData 
            MIMEType:mimeType	
            textEncodingName:@"UTF-8" 
            baseURL:baseURL];

    [self.svgWebView setSVGZoomStyleWithFloat:self.svgWebView.zoomFactor];
    
    [self.svgWebView setEditable:NO];
}

//==================================================================================
//	reloadView
//==================================================================================

- (void)reloadView
{
    MacSVGDocument * macSVGDocument = [self.macSVGDocumentWindowController document];
    NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;
    NSXMLElement * xmlSvgElement = [svgXmlDocument rootElement];
    
    NSXMLElement * macSVGTopGroupElement = [self copyDOMElementsToXML:@"_macsvg_top_group"];  // temporary copy of selection rects to XML
    [xmlSvgElement addChild:macSVGTopGroupElement];
    
    NSInteger animationEnabled = self.macSVGDocumentWindowController.enableAnimationCheckbox.state;

    if (animationEnabled != 0)
    {
        [self reloadXML];
    }
    else
    {
        DOMDocument * domDocument = [[self.svgWebView mainFrame] DOMDocument];
        DOMNodeList * svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
        if (svgElementsList.length > 0)
        {
            DOMNode * svgElementNode = [svgElementsList item:0];
            
            DOMElement * svgElement = (DOMElement *)svgElementNode;

            MacSVGAppDelegate * macSVGAppDelegate = [NSApp delegate];
            WebKitInterface * webKitInterface = [macSVGAppDelegate webKitInterface];

            if ([webKitInterface animationsPausedForSvgElement:svgElement] == NO)
            {
                [webKitInterface pauseAnimationsForSvgElement:svgElement];
            }
        }
        
        [self reloadXMLWithoutAnimation];
        
        [self.macSVGDocumentWindowController.animationTimelineView setPlayHeadPosition:0.0];

        NSImage * buttonImage = [NSImage imageNamed:@"NSGoRightTemplate"];
        [self.macSVGDocumentWindowController.pausePlayAnimationButton setImage:buttonImage];
    }
    
    // remove temporary copy of selection rects from XML
    [self removeXMLElements:@"_macsvg_top_group"];
    
    [self.svgXMLDOMSelectionManager resyncDOMElementsInSelectedElementsArray];
    
    //[self.domSelectionRectsAndHandlesManager updateDOMSelectionRectsAndHandles];    // 20160716
}

//==================================================================================
//	removeXMLElements:
//==================================================================================

- (void)removeXMLElements:(NSString *)elementID
{
    // delete specified elements from top level svg element
    MacSVGDocument * macSVGDocument = [self.macSVGDocumentWindowController document];
    NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;
    NSXMLElement * xmlSvgElement = [svgXmlDocument rootElement];

    NSArray * parentChildren = [xmlSvgElement children];
    NSInteger childCount = [parentChildren count];
    for (NSInteger i = 0; i < childCount; i++)
    {
        NSXMLNode * childNode = [parentChildren objectAtIndex:i];
        if ([childNode kind] == NSXMLElementKind)
        {
            NSXMLElement * childElement = (NSXMLElement *)childNode;
            NSXMLNode * childIDNode = [childElement attributeForName:@"id"];
            if (childIDNode != NULL)
            {
                NSString * childIDString = [childIDNode stringValue];
                if ([childIDString isEqualToString:elementID] == YES)
                {
                    [xmlSvgElement removeChildAtIndex:i];
                    break;
                }
            }
        }
    }
}

//==================================================================================
//	copyDOMParent:toXMLParent:
//==================================================================================

- (void)copyDOMParent:(DOMElement *)domParentElement
        toXMLParent:(NSXMLElement *)xmlParentElement
{
    //NSString * parentTagName = [domParentElement tagName];
    
    int domChildCount = [domParentElement childElementCount];
    
    for (unsigned int i = 0; i < domChildCount; i++)
    {
        DOMNode * domChildNode = [domParentElement.childNodes item:i];
        
        if (domChildNode.nodeType == DOM_ELEMENT_NODE)
        {
            DOMElement * domChildElement = (DOMElement *)domChildNode;
            
            NSString * domChildElementName = [domChildElement tagName];

            NSXMLElement * xmlChildElement = [[NSXMLElement alloc] initWithName:domChildElementName];

            DOMNamedNodeMap * domAttributes = [domChildElement attributes];
            NSInteger attCount = [domAttributes length];

            NSMutableDictionary * newAttributesDictionary = [[NSMutableDictionary alloc] init];
            
            for (unsigned int a = 0; a < attCount; a++) 
            {
                DOMNode * attributes = [domAttributes item:a];
                NSString * attributeName = [attributes nodeName];
                NSString * attributeValue = [attributes nodeValue];

                NSRange xmlnsRange = [attributeName rangeOfString:@"xmlns"];
                if (xmlnsRange.location != NSNotFound)
                {
                    NSLog(@"copyDOMParent:toXMLParent: - xmlns namespace found as attribute");
                }
                
                if ([attributeName length] > 0)
                {
                    unichar firstChar = [attributeName characterAtIndex:0];
                    if (firstChar != '_')
                    {
                        [newAttributesDictionary setObject:attributeValue forKey:attributeName];
                    }
                }
            }

            [xmlChildElement setAttributesWithDictionary:newAttributesDictionary];
            
            [xmlParentElement addChild:xmlChildElement];
            
            if ([domChildElementName isEqualToString:@"g"] == YES)
            {
                [self copyDOMParent:domChildElement toXMLParent:xmlChildElement];
            }
        }
        else if (domChildNode.nodeType == DOM_ATTRIBUTE_NODE)
        {
            // handled above
        }
        else
        {
            // error, should not happen
        }
    }
}

//==================================================================================
//	copyDOMElementsToXML
//==================================================================================

-(NSXMLElement *) copyDOMElementsToXML:(NSString *)elementID
{
    DOMDocument * domDocument = [[self.svgWebView mainFrame] DOMDocument];

    DOMElement * domSelectedRectsGroup = [domDocument getElementById:elementID];
    
    NSXMLElement * xmlSelectedRectsGroup = NULL;

    if (domSelectedRectsGroup != NULL)
    {
        xmlSelectedRectsGroup = [[NSXMLElement alloc] initWithName:@"g"];

        DOMNamedNodeMap * domAttributes = [domSelectedRectsGroup attributes];
        NSInteger attCount = [domAttributes length];

        NSMutableDictionary * newAttributesDictionary = [[NSMutableDictionary alloc] init];
        
        for (unsigned int a = 0; a < attCount; a++) 
        {
            DOMNode * attributes = [domAttributes item:a];
            NSString * attributeName = [attributes nodeName];
            NSString * attributeValue = [attributes nodeValue];

            NSRange xmlnsRange = [attributeName rangeOfString:@"xmlns"];
            if (xmlnsRange.location != NSNotFound)
            {
                NSLog(@"copyDOMSelectionRectsToXML - xmlns namespace found as attribute");
            }
            
            if ([attributeName length] > 0)
            {
                [newAttributesDictionary setObject:attributeValue forKey:attributeName];
            }
        }

        [xmlSelectedRectsGroup setAttributesWithDictionary:newAttributesDictionary];

        [self copyDOMParent:domSelectedRectsGroup
                toXMLParent:xmlSelectedRectsGroup]; // begin recursive deep copy
    }
    
    return xmlSelectedRectsGroup;
}

//==================================================================================
//	walkDOMNodeTree:level:
//==================================================================================

- (void)walkDOMNodeTree:(DOMNode *)parent level:(unsigned int)level
{
	DOMNodeList *nodeList = [parent childNodes];
	unsigned i, length = [nodeList length];
    
	for (i = 0; i < length; i++) 
    {
		DOMNode *node = [nodeList item:i];
        
		DOMNamedNodeMap *attributes = [node attributes];
		unsigned int a, attCount = [attributes length];
		NSMutableString *nodeInfo = [NSMutableString stringWithCapacity:0];
		NSString *nodeName = [node nodeName];
		NSString *nodeValue = [node nodeValue];
		[nodeInfo appendFormat:@"=========================\nnode[%i,%i]:\nname: %@\nvalue: %@\nattributes:\n", 
                level, i, nodeName, nodeValue];
                                
		for (a = 0; a < attCount; a++) 
        {
			DOMNode *att = [attributes item:a];
			NSString *attName = [att nodeName];
			NSString *attValue = [att nodeValue];
			[nodeInfo appendFormat:@"\tatt[%i] name: %@ value: %@\n", a, attName, attValue];
		}
        	
		NSLog(@"%@", nodeInfo);

		[self walkDOMNodeTree:node level:(level + 1)];   // recursive call
	}
}

//==================================================================================
//	logNode
//==================================================================================

-(void)logNode:(DOMNode *)aNode
{
    // Get node properties

    NSString * nodeName = aNode.nodeName;
    NSString * nodeValue = aNode.nodeValue;
    unsigned short nodeType = aNode.nodeType;
    DOMNode * parentNode = aNode.parentNode;
    DOMNodeList * childNodes = aNode.childNodes;
    DOMNode * firstChild = aNode.firstChild;
    DOMNode * lastChild = aNode.lastChild;
    DOMNode * previousSibling = aNode.previousSibling;
    DOMNode * nextSibling = aNode.nextSibling;
    DOMNamedNodeMap * attributes = aNode.attributes;
    DOMDocument * ownerDocument = aNode.ownerDocument;
    NSString * namespaceURI = aNode.namespaceURI;
    NSString * prefix = aNode.prefix;
    NSString * localName = aNode.localName;
    NSString * baseURI = aNode.baseURI;
    NSString * textContent = aNode.textContent;
    DOMElement * parentElement = aNode.parentElement;
    BOOL isContentEditable = aNode.isContentEditable;

    NSLog(@"logNodeProperties - DOMNode.nodeName=%@", nodeName);
    NSLog(@"logNodeProperties - DOMNode.nodeValue=%@", nodeValue);
    NSLog(@"logNodeProperties - DOMNode.nodeType=%hu", nodeType);
    
    #pragma unused(parentNode)
    #pragma unused(childNodes)
    #pragma unused(firstChild)
    #pragma unused(lastChild)
    #pragma unused(previousSibling)
    #pragma unused(nextSibling)
    #pragma unused(ownerDocument)
    #pragma unused(namespaceURI)
    #pragma unused(prefix)
    #pragma unused(localName)
    #pragma unused(baseURI)
    #pragma unused(textContent)
    #pragma unused(parentElement)
    #pragma unused(isContentEditable)
    
    // Get target node attributes
    int attributeCount = [attributes length];
    for (int i = 0; i < attributeCount; i++)
    {
        DOMNode * attributeItem = [attributes item:i];
        NSString * attributeName = attributeItem.nodeName;
        NSString * attributeValue = attributeItem.nodeValue;
        NSLog(@"logNodeProperties - attribute %@=%@", attributeName, attributeValue);
    }
}

//==================================================================================
//	logEvent
//==================================================================================

-(void)logEvent:(DOMEvent *)event
{
    // Get event properties
    NSString * type = event.type;
    DOMNode * target = event.target;
    DOMNode * currentTarget = event.currentTarget;
    unsigned short eventPhase = event.eventPhase;
    BOOL bubbles = event.bubbles;
    BOOL cancelable = event.cancelable;
    DOMTimeStamp timeStamp = event.timeStamp;
    DOMNode * srcElement = event.srcElement;

    #pragma unused(eventPhase)
    #pragma unused(bubbles)
    #pragma unused(cancelable)
    #pragma unused(timeStamp)
    #pragma unused(srcElement)
    #pragma unused(currentTarget)

    NSLog(@"logEvent - DOMEvent.type=%@, target=%@", type, target);
    
    // eventPhase values: DOM_CAPTURING_PHASE=1, DOM_AT_TARGET=2, DOM_BUBBLING_PHASE=3
    //NSLog(@"handleEvent - DOMEvent.eventPhase=%hu", eventPhase);
    
    //[self logNode:target];
}


//==================================================================================
//	updateLiveCoordinates
//==================================================================================

-(void) updateLiveCoordinates
{
    CGFloat xFloat = self.domMouseEventsController.currentMousePoint.x;
    CGFloat yFloat = self.domMouseEventsController.currentMousePoint.y;
    
    int originXInt = self.domMouseEventsController.clickPoint.x;
    int originYInt = self.domMouseEventsController.clickPoint.y;
    #pragma unused(originXInt)
    #pragma unused(originYInt)

    NSString * xString = [self allocFloatString:xFloat];
    NSString * yString = [self allocFloatString:yFloat];
    
    NSString * coordinatesString = [NSString stringWithFormat:@"x: %@ \ny: %@", xString, yString];
    
    [self.macSVGDocumentWindowController.liveCoordinatesTextField setStringValue:coordinatesString];
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
//	handleEvent
//==================================================================================

-(void) handleEvent:(DOMEvent *)event
{
    // Our callback from WebKit
    
    if (self.macSVGDocumentWindowController.currentToolMode == toolModePlugin)
    {
        [self.macSVGDocumentWindowController handlePluginEvent:event];
    }
    else
    {
        NSString * eventType = event.type;

        DOMNode * targetNode = event.target;
        DOMElement * targetElement = (DOMElement *)targetNode;
        NSString * tagName = [targetElement tagName];
        #pragma unused(tagName)

        if ([eventType isEqualToString:@"dblclick"] == YES)
        {
            [self.domMouseEventsController handleMouseDoubleClickEvent:event];
        }
        else if ([eventType isEqualToString:@"mousedown"] == YES)
        {
            [self.domMouseEventsController handleMouseDownEvent:event];
        }
        else if ([eventType isEqualToString:@"mousemove"] == YES)
        {
            [self.domMouseEventsController handleMouseMoveOrHoverEvent:event];
        }
        else if ([eventType isEqualToString:@"mouseup"] == YES)
        {
            [self.domMouseEventsController handleMouseUpEvent:event];
        }
        else if ([eventType isEqualToString:@"focus"] == YES)
        {
            //NSLog(@"handleEvent focus");
        }
        else if ([eventType isEqualToString:@"blur"] == YES)
        {
            //NSLog(@"handleEvent blur");
        }
        else if ([eventType isEqualToString:@"keydown"] == YES)
        {
            //NSLog(@"handleEvent keydown");
        }
        else if ([eventType isEqualToString:@"keypress"] == YES)
        {
            //NSLog(@"handleEvent keypress");
        }
        else if ([eventType isEqualToString:@"keyup"] == YES)
        {
            //NSLog(@"handleEvent keyup");
        }

        [self updateLiveCoordinates];
        
        //[self logEvent:event];
    }
}

//==================================================================================
//	setEventHandlers
//==================================================================================

- (void)setEventHandlers 
{                
    DOMDocument * domDocument = [[self.svgWebView mainFrame] DOMDocument];

    [domDocument.documentElement addEventListener:@"mousedown" listener:(id)self useCapture:NO];
    [domDocument.documentElement addEventListener:@"mousemove" listener:(id)self useCapture:NO];
    [domDocument.documentElement addEventListener:@"mouseup" listener:(id)self useCapture:NO];
    [domDocument.documentElement addEventListener:@"dblclick" listener:(id)self useCapture:NO];
    [domDocument.documentElement addEventListener:@"focus" listener:(id)self useCapture:NO];
    [domDocument.documentElement addEventListener:@"blur" listener:(id)self useCapture:NO];
    [domDocument.documentElement addEventListener:@"keydown" listener:(id)self useCapture:NO];
    [domDocument.documentElement addEventListener:@"keypress" listener:(id)self useCapture:NO];
    [domDocument.documentElement addEventListener:@"keyup" listener:(id)self useCapture:NO];
}

//==================================================================================
//	logStackSymbols
//==================================================================================

- (void)logStackSymbols:(NSString *)messagePrefix
{
    NSArray * stackSymbols = [NSThread callStackSymbols];

    NSMutableArray * filteredStackSymbols = [NSMutableArray array];
    
    for (NSString * aStackString in stackSymbols)
    {
        NSMutableString * outputString = [NSMutableString stringWithString:aStackString];
        
        // 0   macSVG                        0x00000001000354ee -[SVGWebKitController logStackSymbols:] + 78,
        // 0....5...10...15...20...25...30...35...40...45...50...55...60
        NSRange deleteRange = NSMakeRange(4, 55);
        [outputString deleteCharactersInRange:deleteRange];
        
        [filteredStackSymbols addObject:outputString];
    }
    
    NSLog(@"%@\n%@", messagePrefix, filteredStackSymbols);
}

//==================================================================================
// webView:decidePolicyForNavigationAction:request:frame:decisionListener:
//==================================================================================

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
/*
    Printing description of actionInformation:
    {
        WebActionModifierFlagsKey = 0;
        WebActionNavigationTypeKey = 5;
        WebActionOriginalURLKey = <The URL>;
    }

    typedef enum {
       WebNavigationTypeLinkClicked,
       WebNavigationTypeFormSubmitted,
       WebNavigationTypeBackForward,
       WebNavigationTypeReload,
       WebNavigationTypeFormResubmitted,
       WebNavigationTypeOther
    } WebNavigationType;
*/

    BOOL ignoreRequest = NO;

    BOOL usingMainThread = [[NSThread currentThread] isMainThread];

    WebFrame * webMainFrame = [self.svgWebView mainFrame];
    
    id webActionModifierFlags = [actionInformation objectForKey:WebActionModifierFlagsKey];
    id webActionNavigationType = [actionInformation objectForKey:WebActionNavigationTypeKey];
    id webActionOriginalURL = [actionInformation objectForKey:WebActionOriginalURLKey];
    id webActionElement = [actionInformation objectForKey:WebActionElementKey];
    id webActionButton = [actionInformation objectForKey:WebActionButtonKey];
        
    #pragma unused(webActionModifierFlags)
    #pragma unused(webActionNavigationType)
    #pragma unused(webActionOriginalURL)
    #pragma unused(webActionElement)
    #pragma unused(webActionButton)
    
    NSString * urlString = [webActionOriginalURL absoluteString];
    NSRange httpRange = [urlString rangeOfString:@"http"];
    if (httpRange.location == 0)
    {
        ignoreRequest = YES;
    }
        
    if (ignoreRequest == YES)
    {
        if (usingMainThread == YES)
        {
            [listener ignore];
        }
        else
        {
            NSObject * listenerObject = listener;
            [listenerObject performSelectorOnMainThread:@selector(ignore) withObject:NULL waitUntilDone:YES];
        }
    }
    else
    {
        if (frame == webMainFrame)
        {
        }
    
        if (usingMainThread == YES)
        {
            [listener use];
        }
        else
        {
            NSObject * listenerObject = listener;
            [listenerObject performSelectorOnMainThread:@selector(use) withObject:NULL waitUntilDone:YES];
        }
    }
}

//==================================================================================
//	webView:didStartProvisionalLoadForFrame:
//==================================================================================

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    //[self logStackSymbols:@"webView:didStartProvisionalLoadForFrame:"];   // enable this line to diagnose double-update problems

    WebFrame * mainFrame = [self.svgWebView mainFrame];
    if (frame == mainFrame)
    {
        if (self.mainFrameIsLoading == YES)
        {
            NSLog(@"SVGWebKitController - didStartProvisionalLoadForFrame - mainFrameIsLoading was already set YES");
        }
    
        self.mainFrameIsLoading = YES;
        self.lastLoadFinishedTime = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SVGWebViewMainFrameDidStartLoad" object:self];
    }
}

//==================================================================================
//	webView:didFinishLoadForFrame:
//==================================================================================

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame 
{
    WebFrame * mainFrame = [self.svgWebView mainFrame];
    if (frame == mainFrame)
    {
        self.mainFrameIsLoading = NO;
        self.lastLoadFinishedTime = time(NULL);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SVGWebViewMainFrameDidFinishLoad" object:self];
    }
    
    bool val = NO; // this value is to enable/disable scrollbars
    id scrollbarResult = [[self.svgWebView windowScriptObject] evaluateWebScript:
            [NSString stringWithFormat:@"document.body.style.overflow='%@';",
            val?@"visible":@"hidden"]];
    #pragma unused(scrollbarResult)

    [self setEventHandlers];

	WebDataSource *dataSource = [frame dataSource];
	NSArray *subresources = [dataSource subresources];
    #pragma unused(subresources)
	DOMDocument *svgDomDocument = [frame DOMDocument];
    #pragma unused(svgDomDocument)
    
    [self.macSVGDocumentWindowController setWebViewCursor];

    DOMDocument * domDocument = [[self.svgWebView mainFrame] DOMDocument];
    DOMElement * svgElement = NULL;
	DOMNodeList * svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
    if (svgElementsList.length > 0)
    {
        DOMNode * svgElementNode = [svgElementsList item:0];
        svgElement = (DOMElement *)svgElementNode;
    }
    
    [self startPeriodicTimer];
    
    if (frame == mainFrame)
    {
        if (svgElement != NULL)
        {
            [self refreshSelectionRectsAndHandles];
        }
    }
}

//==================================================================================
//	refreshSelectionRectsAndHandles
//==================================================================================

- (void)refreshSelectionRectsAndHandles
{
    [self.domSelectionRectsAndHandlesManager makeDOMSelectionRects];
    
    DOMElement * firstDOMElement = [self.svgXMLDOMSelectionManager.selectedElementsManager firstDomElement];
    
    [self.domSelectionRectsAndHandlesManager makeDOMSelectionHandles:firstDOMElement];
}


//==================================================================================
//	webView:didFailLoadWithError:forFrame:
//==================================================================================

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    //NSLog(@"webView didFailLoadWithError:%@", error);
    WebFrame * mainFrame = [self.svgWebView mainFrame];
    if (frame == mainFrame)
    {
        if (self.mainFrameIsLoading == NO)
        {
            NSLog(@"SVGWebKitController - didStartProvisionalLoadForFrame - mainFrameIsLoading was already set NO");
        }

        self.mainFrameIsLoading = NO;
        self.lastLoadFinishedTime = 0;
    }
}


//==================================================================================
//	willCloseSVGWebView
//==================================================================================

- (void)willCloseSVGWebView 
{
    [[self.svgWebView mainFrame] loadHTMLString:@"" baseURL:NULL];
}

//==================================================================================
//	restartAnimationButtonClicked:
//==================================================================================

- (IBAction)restartAnimationButtonClicked:(id)sender
{
    [self reloadView];
}

//==================================================================================
//	pausePlayAnimationButtonClicked:
//==================================================================================

- (IBAction)pausePlayAnimationButtonClicked:(id)sender
{
    DOMDocument * domDocument = [[self.svgWebView mainFrame] DOMDocument];
	DOMNodeList * svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
    if (svgElementsList.length > 0)
    {
        MacSVGAppDelegate * macSVGAppDelegate = [NSApp delegate];
        WebKitInterface * webKitInterface = [macSVGAppDelegate webKitInterface];

        DOMNode * svgElementNode = [svgElementsList item:0];
        
        DOMElement * svgElement = (DOMElement *)svgElementNode;

        if ([webKitInterface animationsPausedForSvgElement:svgElement] == YES)
        {
            // play animations
            self.macSVGDocumentWindowController.enableAnimationCheckbox.state = 1;
            
            [webKitInterface unpauseAnimationsForSvgElement:svgElement];
            
            NSImage * buttonImage = [NSImage imageNamed:@"Pause16"];
            [self.macSVGDocumentWindowController.pausePlayAnimationButton setImage:buttonImage];
        }
        else
        {
            // pause animations
            [webKitInterface pauseAnimationsForSvgElement:svgElement];
            
            NSImage * buttonImage = [NSImage imageNamed:@"NSGoRightTemplate"];
            [self.macSVGDocumentWindowController.pausePlayAnimationButton setImage:buttonImage];
        }
    }
}

// ================================================================

-(id)findDomElementForMacsvgid:(NSString *)macsvgid inElement:(DOMElement *)currentElement;
{
    id result = NULL;

    if (currentElement.nodeType == DOM_ELEMENT_NODE)
    {
        NSString * MacsvgidAttribute = [currentElement getAttribute:@"macsvgid"];
        
        if ([macsvgid isEqualToString:MacsvgidAttribute] == YES)
        {
            result = currentElement;
        }
        else
        {
            DOMNodeList * domNodeList = [currentElement childNodes];
            
            int domNodeListCount = domNodeList.length;
            
            for (int i = 0; i < domNodeListCount; i++)
            {
                // recursive call to check child nodes
                DOMNode *  aNode = [domNodeList item:i];
                
                result = [self findDomElementForMacsvgid:macsvgid inElement:(id)aNode];
                if (result != NULL)
                {
                    break;
                }
            }
        }
    }
    
    return result;
}

// ================================================================

- (DOMElement *)domElementForMacsvgid:(NSString *)macsvgid
{
    id result = NULL;
    
    DOMDocument * domDocument = [[self.svgWebView mainFrame] DOMDocument];
	DOMNodeList * svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
    if (svgElementsList.length > 0)
    {
        DOMNode * svgElementNode = [svgElementsList item:0];
        DOMElement * svgElement = (DOMElement *)svgElementNode;
    
        result = [self findDomElementForMacsvgid:macsvgid inElement:svgElement];
    }
    
    return result;
}

//==================================================================================
//	updateElementAttributes:
//==================================================================================

-(void) updateElementAttributes:(NSXMLElement *)aElement
{
    // set new attribute values in rendered DOM
    
    NSXMLNode * MacsvgidNode = [aElement attributeForName:@"macsvgid"];
    NSString * macsvgid = [MacsvgidNode stringValue];

    DOMElement * domElement = [self domElementForMacsvgid:macsvgid];
    
    NSArray * xmlAttributes = [aElement attributes];
    
    for (NSXMLNode * xmlNode in xmlAttributes)
    {
        NSString * attributeName = [xmlNode localName];
        NSString * attributeValue = [xmlNode stringValue];
        NSString * attributeURI = [xmlNode URI];
        
        if ([attributeName length] == 0)
        {
            NSLog(@"SVGWebKitController updateElementAttributes empty attributeName found, set to xlmns - but that is probably wrong thing to do");
            attributeName = @"xmlns";
        }

        if (attributeURI != NULL)
        {
            [domElement setAttributeNS:attributeURI qualifiedName:attributeName value:attributeValue];
        }
        else
        {
            [domElement setAttribute:attributeName value:attributeValue];
        }
    }

    // removed deleted attributes from rendered DOM
    NSMutableArray * deletedAttributes = [[NSMutableArray alloc] init];
    
    DOMNamedNodeMap * domAttributes = [domElement attributes];
    int domAttributeCount = domAttributes.length;
    for (int i = 0; i < domAttributeCount; i++)
    {
        DOMNode * aNode = [domAttributes item:i];
        
        NSString * domAttributeName = aNode.localName;
        NSString * namespaceURI = aNode.namespaceURI;
        
        BOOL matchFound = NO;
        
        for (NSXMLNode * xmlNode in xmlAttributes)
        {
            NSString * attributeName = [xmlNode localName];
            if ([attributeName isEqualToString:domAttributeName] == YES)
            {
                NSString * attributeURI = [xmlNode URI];
                
                if ([namespaceURI length] == 0)
                {
                    namespaceURI = NULL;
                }
                
                if (attributeURI == NULL)
                {
                    if (namespaceURI == NULL)
                    {
                        matchFound = YES;
                    }
                }
                
                if ([attributeURI isEqualToString:namespaceURI] == YES)
                {
                    matchFound =  YES;
                }
            }
        }
        
        if (matchFound == NO)
        {
            [deletedAttributes addObject:domAttributeName];
        }
    }

    for (NSString * aDeletedElement in deletedAttributes)
    {
        [domElement removeAttributeNS:NULL localName:aDeletedElement];
    }
}

// ================================================================

- (void)updateSelections
{
    // TEST 20130709
    NSUInteger currentToolMode = self.macSVGDocumentWindowController.currentToolMode;
    if (currentToolMode != toolModeCrosshairCursor)
    {
        [self.domSelectionRectsAndHandlesManager updateDOMSelectionRectsAndHandles];
    }
}

// ================================================================

- (void) addDOMElementForXMLElement:(NSXMLElement *)aXMLElement
{
    // currently not recursive
    NSString * tagName = [aXMLElement name];
    NSXMLElement * xmlParentElement = (NSXMLElement *)[aXMLElement parent];
    
    NSXMLNode * xmlParentMacsvgidNode = [xmlParentElement attributeForName:@"macsvgid"];
    NSString * parentMacsvgid = [xmlParentMacsvgidNode stringValue];
        
    DOMElement * domParentElement = [self domElementForMacsvgid:parentMacsvgid];
    
    DOMDocument * domDocument = [[self.svgWebView mainFrame] DOMDocument];

    DOMElement * newDOMElement = [domDocument createElementNS:svgNamespace
            qualifiedName:tagName];

    NSArray * xmlAttributeNodes = [aXMLElement attributes];
    
    for (NSXMLNode * aXMLAttributeNode in xmlAttributeNodes)
    {
        NSString * attributeName = [aXMLAttributeNode name];
        NSString * attributeValue = [aXMLAttributeNode stringValue];
        
        [newDOMElement setAttribute:attributeName value:attributeValue];
    }
    
    NSString * stringValue = [aXMLElement stringValue];
    
    NSString * copyStringValue = [[NSString alloc] initWithString:stringValue];
    
    [newDOMElement setTextContent:copyStringValue];
    
    [domParentElement appendChild:newDOMElement];
}

// ================================================================

- (NSMutableArray *)pathSegmentsArray
{
    NSMutableArray * pathSegmentsArray = self.domMouseEventsController.svgPathEditor.pathSegmentsArray;
    
    return pathSegmentsArray;
}

// ================================================================

- (NSMutableArray *)buildPathSegmentsArrayWithPathString:(NSString *)pathString
{
    NSMutableArray * pathSegmentsArray = [self.domMouseEventsController.svgPathEditor buildPathSegmentsArrayWithPathString:pathString];
    
    return pathSegmentsArray;
}

// ================================================================

- (void)updatePathSegmentsAbsoluteValues:(NSMutableArray *)pathSegmentsArray
{
    [self.domMouseEventsController.svgPathEditor updatePathSegmentsAbsoluteValues:pathSegmentsArray];
}

// ================================================================

- (void)updateActivePathInDOM
{
    [self.domMouseEventsController.svgPathEditor updateActivePathInDOM];
}

// ================================================================

- (void)updateSelectedPathInDOM
{
    [self.domMouseEventsController.svgPathEditor updateSelectedPathInDOM];
}

// ================================================================

- (void)updatePathInDOMForElement:(DOMElement *)pathElement pathSegmentsArray:(NSArray *)aPathSegmentsArray
{
    [self.domMouseEventsController.svgPathEditor updatePathInDOMForElement:pathElement pathSegmentsArray:aPathSegmentsArray];
}

// ================================================================

- (NSPoint)endPointForSegmentIndex:(NSInteger)segmentIndex
        pathSegmentsArray:(NSArray *)aPathSegmentsArray
{
    return [self.domMouseEventsController.svgPathEditor endPointForSegmentIndex:segmentIndex pathSegmentsArray:aPathSegmentsArray];
}

// ================================================================

- (void)setPathSegmentsArray:(NSMutableArray *)pathSegmentsArray;
{
    self.domMouseEventsController.svgPathEditor.pathSegmentsArray = pathSegmentsArray;
    
    self.domMouseEventsController.svgPathEditor.pathSegmentIndex =
            [pathSegmentsArray count] - 1;
}

// ================================================================

- (id)svgPathEditorSelectedPathElement   // returns NSXMLElement
{
    SVGPathEditor * svgPathEditor = self.domMouseEventsController.svgPathEditor;
    NSXMLElement * selectedPathElement = svgPathEditor.selectedPathElement;
    
    return selectedPathElement;
}

// ================================================================

- (void)svgPathEditorSetSelectedPathElement:(NSXMLElement *)aSelectedPathElement
{
    SVGPathEditor * svgPathEditor = self.domMouseEventsController.svgPathEditor;
    svgPathEditor.selectedPathElement = aSelectedPathElement;
}

// ================================================================

- (void) setDOMVisibility:(NSString *)visibility forMacsvgid:(NSString *)macsvgid
{
    DOMElement * domElement = [self domElementForMacsvgid:macsvgid];
    
    [domElement setAttribute:@"visibility" value:visibility];
}

// ================================================================

- (BOOL)webView:(WebView *)webView shouldBeginEditingInDOMRange:(DOMRange *)range
{
    //NSLog(@"webView:shouldBeginEditingInDOMRange");
    return YES;
}

// ================================================================

- (BOOL)webView:(WebView *)webView shouldEndEditingInDOMRange:(DOMRange *)range
{
    //NSLog(@"webView:shouldEndEditingInDOMRange");
    return YES;
}

// ================================================================

- (BOOL)webView:(WebView *)webView shouldInsertNode:(DOMNode *)node 
        replacingDOMRange:(DOMRange *)range givenAction:(WebViewInsertAction)action
{
    //NSLog(@"webView:shouldInsertNode:replacingDOMRange:givenAction");
    
    BOOL result = NO;
    
    switch (action) 
    {
        case WebViewInsertActionDropped:
            result = YES;
            break;

        case WebViewInsertActionPasted:
            result = YES;
            break;

        case WebViewInsertActionTyped:
            result = YES;
            break;

        default:
            result = NO;
            break;
    }
    
    return result;
}

// ================================================================

- (BOOL)webView:(WebView *)webView shouldInsertText:(NSString *)text 
        replacingDOMRange:(DOMRange *)range givenAction:(WebViewInsertAction)action
{
    //NSLog(@"webView:shouldInsertText:replacingDOMRange:givenAction");
    //NSLog(@"text length=%lu string=%@", [text length], text);

    BOOL result = NO;
    
    switch (action) 
    {
        case WebViewInsertActionDropped:
        {
            result = NO;
            break;
        }
        case WebViewInsertActionPasted:
        {
            result = NO;
            break;
        }
        case WebViewInsertActionTyped:
        {
            result = YES;

            if ([text length] == 1) 
            {
                unichar aChar = [text characterAtIndex:0];
                if (aChar == 13)
                {
                    result = NO;    // omit carriage returns
                }
            }

            break;
        }
        default:
        {
            result = NO;
            break;
        }
    }
    
    return result;
}

// ================================================================

- (BOOL)webView:(WebView *)webView shouldDeleteDOMRange:(DOMRange *)range
{
    //NSLog(@"webView:shouldDeleteDOMRange");
    return YES;
}

// ================================================================

- (BOOL)webView:(WebView *)webView shouldChangeSelectedDOMRange:(DOMRange *)currentRange 
        toDOMRange:(DOMRange *)proposedRange affinity:(NSSelectionAffinity)selectionAffinity 
        stillSelecting:(BOOL)flag
{
    //NSLog(@"webView:shouldChangeSelectedDOMRange:toDOMRange:affinity:stillSelecting");
    return YES;
}

// ================================================================

- (BOOL)webView:(WebView *)webView shouldApplyStyle:(DOMCSSStyleDeclaration *)style 
        toElementsInDOMRange:(DOMRange *)range
{
    //NSLog(@"webView:shouldApplyStyle:toElementsInDOMRange");
    return YES;
}

// ================================================================

- (BOOL)webView:(WebView *)webView shouldChangeTypingStyle:(DOMCSSStyleDeclaration *)currentStyle 
        toStyle:(DOMCSSStyleDeclaration *)proposedStyle
{
    //NSLog(@"webView:shouldChangeTypingStyle:toStyle");
    return YES;
}

// ================================================================

- (BOOL)webView:(WebView *)sender shouldPerformAction:(SEL)action fromSender:(id)fromObject
{
    //NSLog(@"webView:shouldPerformAction:fromSender");
    return YES;
}

//==================================================================================
//	webView:doCommandBySelector:
//==================================================================================

/*
-(BOOL)webView:(WebView *)webView doCommandBySelector:(SEL)command
{
    NSLog(@"doCommandBySelector %@", command);
    return NO;
}
*/

//==================================================================================
//	webViewDidBeginEditing:
//==================================================================================

- (void)webViewDidBeginEditing:(NSNotification *)notification
{
    // notification
    //NSLog(@"webViewDidBeginEditing");
}

//==================================================================================
//	webViewDidChange:
//==================================================================================

- (void)webViewDidChange:(NSNotification *)notification
{
    // notification
    //NSLog(@"webViewDidChange");
}

//==================================================================================
//	webViewDidEndEditing:
//==================================================================================

- (void)webViewDidEndEditing:(NSNotification *)notification
{
    // notification
    //NSLog(@"webViewDidEndEditing");
}

//==================================================================================
//	webViewDidChangeTypingStyle:
//==================================================================================

- (void)webViewDidChangeTypingStyle:(NSNotification *)notification
{
    // notification
    //NSLog(@"webViewDidChangeTypingStyle");
}

//==================================================================================
//	webViewDidChangeSelection:
//==================================================================================

- (void)webViewDidChangeSelection:(NSNotification *)notification
{
    // notification
    //NSLog(@"webViewDidChangeSelection");
    
    [self.domMouseEventsController endTextEditing];
}

//==================================================================================
//	undoManagerForWebView:
//==================================================================================

/*
- (NSUndoManager *)undoManagerForWebView:(WebView *)webView
{
    return YES;
}
*/

//==================================================================================
//	webView:dragDestinationActionMaskForDraggingInfo:
//==================================================================================

- (NSUInteger)webView:(WebView *)sender 
        dragDestinationActionMaskForDraggingInfo:(id <NSDraggingInfo>)draggingInfo
{
    // WebDragDestinationActionNone, WebDragDestinationActionDHTML, WebDragDestinationActionEdit
    // WebDragDestinationActionLoad, WebDragDestinationActionAny
    return WebDragDestinationActionAny;
}

//==================================================================================
//	webView:dragSourceActionMaskForPoint:
//==================================================================================

- (NSUInteger)webView:(WebView *)sender dragSourceActionMaskForPoint:(NSPoint)point
{
    // WebDragSourceActionNone, WebDragSourceActionDHTML, WebDragSourceActionImage, 
    // WebDragSourceActionLink, WebDragSourceActionSelection, WebDragSourceActionAny  
    return WebDragSourceActionAny;
}

//==================================================================================
//	webView:willPerformDragDestinationAction:forDraggingInfo:
//==================================================================================

- (void)webView:(WebView *)sender willPerformDragDestinationAction:(WebDragDestinationAction)action 
        forDraggingInfo:(id < NSDraggingInfo >)draggingInfo
{
    //NSLog(@"willPerformDragDestinationAction");
}

//==================================================================================
//	webView:willPerformDragSourceAction:fromPoint:withPasteboard:
//==================================================================================

- (void)webView:(WebView *)sender willPerformDragSourceAction:(WebDragSourceAction)action 
        fromPoint:(NSPoint)point withPasteboard:(NSPasteboard *)pasteboard
{
    //NSLog(@"willPerformDragSourceAction");
}

//==================================================================================
//	webView:validateUserInterfaceItem:defaultValidation:
//==================================================================================

- (BOOL)webView:(WebView *)sender 
        validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)item 
        defaultValidation:(BOOL)defaultValidation
{
    //NSLog(@"validateUserInterfaceItem");
    return defaultValidation;
}

//==================================================================================
//	webView:resource:didFinishLoadingFromDataSource:
//==================================================================================

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
    //NSLog(@"webView didFinishLoadingFromDataSource");
}

//==================================================================================
//	webView:resource:willSendRequest:redirectResponse:fromDataSource:
//==================================================================================

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request
        redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    NSString * urlRequestString = [[request URL] absoluteString];
    if ([urlRequestString isEqualToString:@"about:blank"] == NO)
    {
        request = [NSURLRequest requestWithURL:[request URL]
                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[request timeoutInterval]];
    }
    //NSLog(@"webView willSendRequest");
    return request;
}

//==================================================================================
//	webView:resource:didReceiveResponse:fromDataSource:
//==================================================================================

- (void)webView:(WebView *)sender resource:(id)identifier
        didReceiveResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)dataSource
{
    //NSLog(@"webView didReceiveResponse");
}

//==================================================================================
//	webView:resource:willSendRequest:redirectResponse:fromDataSource:
//==================================================================================

- (void)webView:(WebView *)sender resource:(id)identifier
        didFailLoadingWithError:(NSError *)error fromDataSource:(WebDataSource *)dataSource
{
    BOOL doLogError = YES;

    if (error.code == -999)
    {
        NSDictionary * userInfo = error.userInfo;
        
        NSURL * failingURL = [userInfo objectForKey:NSURLErrorFailingURLErrorKey];
        
        NSString * failingURLString = [failingURL absoluteString];
        
        if ([failingURLString isEqualToString:@"about:blank"] == YES)
        {
            doLogError = NO;
        }
    }

    if (doLogError == YES)
    {
        NSLog(@"webView didFailLoadingWithError:%@", error);
    }
}

//==================================================================================
//	showWebKitInspectorAction
//==================================================================================

- (IBAction)showWebKitInspectorAction:(id)sender
{
    if (self.webKitInspectorIsOpen == NO)
    {
        [self attachWebInspector];
        [self openWebInspector];
    }
    else
    {
        [self attachWebInspector];
        [self closeWebInspector];
    }
    
    [self configureWebKitMenu];
}

//==================================================================================
//	detachWebKitInspectorAction
//==================================================================================

- (IBAction)detachWebKitInspectorAction:(id)sender
{
    if (self.webKitInspectorIsAttached == YES)
    {
        [self detachWebInspector];
    }
    else
    {
        [self attachWebInspector];
    }
    
    [self configureWebKitMenu];
}

//==================================================================================
//
//==================================================================================

- (IBAction)disableJavaScriptAction:(id)sender
{
    if (self.javaScriptIsDisabled == YES)
    {
        [self enableJavaScript];
    }
    else
    {
        [self disableJavaScript];
    }
    
    [self configureWebKitMenu];
}

//==================================================================================
//	enableJavaScriptProfilingAction
//==================================================================================

- (IBAction)enableJavaScriptProfilingAction:(id)sender
{
    if ([self webInspectorIsJavaScriptProfilingEnabled] == YES)
    {
        [self webInspectorSetJavaScriptProfilingEnabled:NO];
    }
    else
    {
        [self webInspectorSetJavaScriptProfilingEnabled:YES];
    }
    
    [self configureWebKitMenu];
}

//==================================================================================
//	enableTimelineProfilingAction
//==================================================================================

- (IBAction)enableTimelineProfilingAction:(id)sender
{
    if ([self webInspectorIsTimelineProfilingEnabled] == YES)
    {
        [self webInspectorSetTimelineProfilingEnabled:NO];
    }
    else
    {
        [self webInspectorSetTimelineProfilingEnabled:YES];
    }
    
    [self configureWebKitMenu];
}

//==================================================================================
//	startDebuggingJavaScriptAction
//==================================================================================

- (IBAction)startDebuggingJavaScriptAction:(id)sender
{
    if ([self webInspectorIsDebuggingJavaScript] == YES)
    {
        [self webInspectorStopDebuggingJavaScript];
    }
    else
    {
        [self webInspectorStartDebuggingJavaScript];
    }

    [self configureWebKitMenu];
}

//==================================================================================
//	startProfilingJavaScriptAction
//==================================================================================

- (IBAction)startProfilingJavaScriptAction:(id)sender
{
    if ([self webInspectorIsProfilingJavaScript] == YES)
    {
        [self webInspectorStopProfilingJavaScript];
    }
    else
    {
        [self webInspectorStartProfilingJavaScript];
    }

    [self configureWebKitMenu];
}

//==================================================================================
//	webInspector
//==================================================================================

-(id)webInspector
{
    //[[self.webView inspector] show:sender]
    id aWebInspector = NULL;
    
    if (self.macSVGDocumentWindowController.svgWebKitController.svgWebView != NULL)
    {
        typedef id (*send_type)(id, SEL);
        send_type func = (send_type)objc_msgSend;
        aWebInspector = func(self.macSVGDocumentWindowController.svgWebKitController.svgWebView, NSSelectorFromString(@"inspector"));
    }
    
    return aWebInspector;
}

//==================================================================================
//	openWebInspector
//==================================================================================

-(void)openWebInspector
{
    //[[self.webView inspector] show:sender]
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef void (*send_type)(id, SEL, id);
        send_type func = (send_type)objc_msgSend;
        func(webInspector, NSSelectorFromString(@"show:"), self);

        self.webKitInspectorIsOpen = YES;
    }
}

//==================================================================================
//	closeWebInspector
//==================================================================================

-(void)closeWebInspector
{
    //[[self.webView inspector] close:sender]
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef void (*send_type)(id, SEL, id);
        send_type func = (send_type)objc_msgSend;
        func(webInspector, NSSelectorFromString(@"close:"), self);

        self.webKitInspectorIsOpen = NO;
    }
}

//==================================================================================
//	showWebInspectorConsole
//==================================================================================

-(void)showWebInspectorConsole
{
    //[[self.webView inspector] showConsole:sender]
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef void (*send_type)(id, SEL, id);
        send_type func = (send_type)objc_msgSend;
        func(webInspector, NSSelectorFromString(@"showConsole:"), self);

        self.webKitInspectorIsOpen = YES;
    }
}

//==================================================================================
//	attachWebInspector
//==================================================================================

-(void)attachWebInspector
{
    //[[self.webView inspector] attach:sender]
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef void (*send_type)(id, SEL, id);
        send_type func = (send_type)objc_msgSend;
        func(webInspector, NSSelectorFromString(@"attach:"), self);
        
        self.webKitInspectorIsAttached = YES;
    }
}

//==================================================================================
//	detachWebInspector
//==================================================================================

-(void)detachWebInspector
{
    //[[self.webView inspector] detach:sender]
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef void (*send_type)(id, SEL, id);
        send_type func = (send_type)objc_msgSend;
        func(webInspector, NSSelectorFromString(@"detach:"), self);
        
        self.webKitInspectorIsAttached = NO;
    }
}

//==================================================================================
//	enableJavaScript
//==================================================================================

- (void)enableJavaScript
{
    WebPreferences * customPreferences = [[WebPreferences alloc] initWithIdentifier:@"DOMInspector"];
    customPreferences.javaScriptEnabled = YES;
    
    self.macSVGDocumentWindowController.svgWebKitController.svgWebView.preferences = customPreferences;
    
    self.javaScriptIsDisabled = NO;
}

//==================================================================================
//	disableJavaScript
//==================================================================================

- (void)disableJavaScript
{
    WebPreferences * customPreferences = [[WebPreferences alloc] initWithIdentifier:@"DOMInspector"];
    customPreferences.javaScriptEnabled = NO;
    
    self.macSVGDocumentWindowController.svgWebKitController.svgWebView.preferences = customPreferences;
    
    self.javaScriptIsDisabled = YES;
}

//==================================================================================
//	webInspectorIsDebuggingJavaScript
//==================================================================================

-(BOOL)webInspectorIsDebuggingJavaScript
{
    //result = [[self.webView inspector] isDebuggingJavaScript]
    BOOL result = NO;
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef BOOL (*send_type)(id, SEL);
        send_type func = (send_type)objc_msgSend;
        result = func(webInspector, NSSelectorFromString(@"isDebuggingJavaScript"));
    }
    return result;
}

//==================================================================================
//	webInspectorToggleDebuggingJavaScript
//==================================================================================

-(void)webInspectorToggleDebuggingJavaScript
{
    //[[self.webView inspector] toggleDebuggingJavaScript:sender]
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef void (*send_type)(id, SEL, id);
        send_type func = (send_type)objc_msgSend;
        func(webInspector, NSSelectorFromString(@"toggleDebuggingJavaScript:"), self);
    }
}

//==================================================================================
//	webInspectorStartDebuggingJavaScript
//==================================================================================

-(void)webInspectorStartDebuggingJavaScript
{
    //[[self.webView inspector] startDebuggingJavaScript:sender]
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef void (*send_type)(id, SEL, id);
        send_type func = (send_type)objc_msgSend;
        func(webInspector, NSSelectorFromString(@"startDebuggingJavaScript:"), self);
    }
}

//==================================================================================
//	webInspectorStopDebuggingJavaScript
//==================================================================================

-(void)webInspectorStopDebuggingJavaScript
{
    //[[self.webView inspector] stopDebuggingJavaScript:sender]
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef void (*send_type)(id, SEL, id);
        send_type func = (send_type)objc_msgSend;
        func(webInspector, NSSelectorFromString(@"stopDebuggingJavaScript:"), self);
    }
}

//==================================================================================
//	webInspectorIsJavaScriptProfilingEnabled
//==================================================================================

-(BOOL)webInspectorIsJavaScriptProfilingEnabled
{
    //result = [[self.webView inspector] isJavaScriptProfilingEnabled]
    BOOL result = NO;
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef BOOL (*send_type)(id, SEL);
        send_type func = (send_type)objc_msgSend;
        result = func(webInspector, NSSelectorFromString(@"isJavaScriptProfilingEnabled"));
    }
    return result;
}

//==================================================================================
//	webInspectorSetJavaScriptProfilingEnabled
//==================================================================================

-(void)webInspectorSetJavaScriptProfilingEnabled:(BOOL)enabled;
{
    //[[self.webView inspector] setJavaScriptProfilingEnabled:YES]
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef void (*send_type)(id, SEL, BOOL);
        send_type func = (send_type)objc_msgSend;
        func(webInspector, NSSelectorFromString(@"setJavaScriptProfilingEnabled:"), enabled);
    }
}

//==================================================================================
//	webInspectorIsTimelineProfilingEnabled
//==================================================================================

-(BOOL)webInspectorIsTimelineProfilingEnabled
{
    //result = [[self.webView inspector] isTimelineProfilingEnabled]
    BOOL result = NO;
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef BOOL (*send_type)(id, SEL);
        send_type func = (send_type)objc_msgSend;
        result = func(webInspector, NSSelectorFromString(@"isTimelineProfilingEnabled"));
    }
    return result;
}

//==================================================================================
//	webInspectorSetTimelineProfilingEnabled
//==================================================================================

-(void)webInspectorSetTimelineProfilingEnabled:(BOOL)enabled;
{
    //[[self.webView inspector] setTimelineProfilingEnabled:YES]
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef void (*send_type)(id, SEL, BOOL);
        send_type func = (send_type)objc_msgSend;
        func(webInspector, NSSelectorFromString(@"setTimelineProfilingEnabled:"), enabled);
    }
}

//==================================================================================
//	webInspectorIsProfilingJavaScript
//==================================================================================

-(BOOL)webInspectorIsProfilingJavaScript
{
    //result = [[self.webView inspector] isProfilingJavaScript]
    BOOL result = NO;
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef BOOL (*send_type)(id, SEL);
        send_type func = (send_type)objc_msgSend;
        result = func(webInspector, NSSelectorFromString(@"isProfilingJavaScript"));
    }
    return result;
}

//==================================================================================
//	webInspectorToggleProfilingJavaScript
//==================================================================================

-(void)webInspectorToggleProfilingJavaScript
{
    //[[self.webView inspector] toggleProfilingJavaScript:sender]
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef void (*send_type)(id, SEL, id);
        send_type func = (send_type)objc_msgSend;
        func(webInspector, NSSelectorFromString(@"toggleProfilingJavaScript:"), self);
    }
}

//==================================================================================
//	webInspectorStartProfilingJavaScript
//==================================================================================

-(void)webInspectorStartProfilingJavaScript
{
    //[[self.webView inspector] startProfilingJavaScript:sender]
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef void (*send_type)(id, SEL, id);
        send_type func = (send_type)objc_msgSend;
        func(webInspector, NSSelectorFromString(@"startProfilingJavaScript:"), self);
    }
}

//==================================================================================
//	webInspectorStopProfilingJavaScript
//==================================================================================

-(void)webInspectorStopProfilingJavaScript
{
    //[[self.webView inspector] stopProfilingJavaScript:sender]
    id webInspector = [self webInspector];

    if (webInspector != NULL)
    {
        typedef void (*send_type)(id, SEL, id);
        send_type func = (send_type)objc_msgSend;
        func(webInspector, NSSelectorFromString(@"stopProfilingJavaScript:"), self);
    }
}

//==================================================================================
//	configureWebKitMenu
//==================================================================================

- (void)configureWebKitMenu
{
    MacSVGAppDelegate * appDelegate = (MacSVGAppDelegate *)[NSApp delegate];
    NSMenuItem * showWebKitInspectorMenuItem = appDelegate.showWebKitInspectorMenuItem;
    NSMenuItem * detachWebKitInspectorMenuItem = appDelegate.detachWebKitInspectorMenuItem;
    NSMenuItem * enableJavaScriptProfilingMenuItem = appDelegate.enableJavaScriptProfilingMenuItem;
    NSMenuItem * enableTimelineProfilingMenuItem = appDelegate.enableTimelineProfilingMenuItem;
    NSMenuItem * startDebuggingJavaScriptMenuItem = appDelegate.startDebuggingJavaScriptMenuItem;
    NSMenuItem * startProfilingJavaScriptMenuItem = appDelegate.startProfilingJavaScriptMenuItem;
    
    if (self.webKitInspectorIsOpen == YES)
    {
        [showWebKitInspectorMenuItem setTitle:@"Close WebKit Inspector"];
        
        [detachWebKitInspectorMenuItem setEnabled:YES];
        [enableJavaScriptProfilingMenuItem setEnabled:YES];
        [enableTimelineProfilingMenuItem setEnabled:YES];
        [startDebuggingJavaScriptMenuItem setEnabled:YES];
        [startProfilingJavaScriptMenuItem setEnabled:YES];
    }
    else
    {
        [showWebKitInspectorMenuItem setTitle:@"Open WebKit Inspector"];
        
        [detachWebKitInspectorMenuItem setEnabled:NO];
        [enableJavaScriptProfilingMenuItem setEnabled:NO];
        [enableTimelineProfilingMenuItem setEnabled:NO];
        [startDebuggingJavaScriptMenuItem setEnabled:NO];
        [startProfilingJavaScriptMenuItem setEnabled:NO];
    }
    
    if (self.webKitInspectorIsAttached == YES)
    {
        [detachWebKitInspectorMenuItem setTitle:@"Detach WebKit Inspector"];
    }
    else
    {
        [detachWebKitInspectorMenuItem setTitle:@"Attach WebKit Inspector"];
    }
    
    if ([self webInspectorIsJavaScriptProfilingEnabled] == YES)
    {
        [enableJavaScriptProfilingMenuItem setTitle:@"Disable JavaScript Profiling"];
    }
    else
    {
        [enableJavaScriptProfilingMenuItem setTitle:@"Enable JavaScript Profiling"];
    }
    
    if ([self webInspectorIsTimelineProfilingEnabled] == YES)
    {
        [enableTimelineProfilingMenuItem setTitle:@"Disable Timeline Profiling"];
    }
    else
    {
        [enableTimelineProfilingMenuItem setTitle:@"Enable Timeline Profiling"];
    }

    if (self.webInspectorIsDebuggingJavaScript == YES)
    {
        [startDebuggingJavaScriptMenuItem setTitle:@"Stop Debugging JavaScript"];
    }
    else
    {
        [startDebuggingJavaScriptMenuItem setTitle:@"Start Debugging JavaScript"];
    }

    if (self.webInspectorIsProfilingJavaScript == YES)
    {
        [startProfilingJavaScriptMenuItem setTitle:@"Stop Profiling JavaScript"];
    }
    else
    {
        [startProfilingJavaScriptMenuItem setTitle:@"Start Profiling JavaScript"];
    }
}


@end
