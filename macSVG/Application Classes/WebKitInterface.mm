//
//  WebKitInterface.m
//  TransformAttributeEditor
//
//  Created by Douglas Ward on 7/9/13.
//
//

#import "WebKitInterface.h"
#import <WebKit/WebKit.h>
#import "objc/message.h"

#define ENABLE_SVG 1

@implementation WebKitInterface

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    //[super dealloc];  // if built with -fno-objc-arc
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
    }
    
    return self;
}

//==================================================================================
//	bBoxForDOMElement:
//==================================================================================

-(NSRect)bBoxForDOMElement:(DOMElement *)aDOMElement
{
    NSRect resultRect = NSZeroRect;
    
    id bBox = [aDOMElement callWebScriptMethod:@"getBBox"
        withArguments:NULL];  // call JavaScript function - note JavaScript must be enabled in the WebView
    
    if (bBox != NULL)
    {
        id xResult = [bBox valueForKey:@"x"];
        id yResult = [bBox valueForKey:@"y"];
        id widthResult = [bBox valueForKey:@"width"];
        id heightResult = [bBox valueForKey:@"height"];

        resultRect = NSMakeRect([xResult floatValue], [yResult floatValue], [widthResult floatValue], [heightResult floatValue]);
    }
    else
    {
        // this produces approximately the same result as getBBox, but with integer values, currently untested
        NSArray * lineBoxRectsArray = [aDOMElement lineBoxRects];   // gets an array of NSValue objects
        
        if (lineBoxRectsArray.count > 0)
        {
            id concreteValueObject = [lineBoxRectsArray firstObject];
            NSRect lineBoxRect;
            [concreteValueObject getValue:&lineBoxRect];
            resultRect = lineBoxRect;
        }
        else
        {
            resultRect = [aDOMElement boundingBox];     // this fallback is known to produce incorrect results
        }
    }

    return resultRect;
}

//==================================================================================
//	bBoxForDOMElement:webView:
//==================================================================================

-(NSRect)bBoxForDOMElement:(DOMElement *)aDOMElement webView:(WebView *)webView
{
    JSContextRef ctx = webView.mainFrame.globalContext;
    
    return [self bBoxForDOMElement:aDOMElement globalContext:ctx];
}

//==================================================================================
//	bBoxForDOMElement:globalContext:
//==================================================================================

-(NSRect)bBoxForDOMElement:(DOMElement *)aDOMElement globalContext:(JSContextRef)globalContext
{
    NSRect resultRect = NSZeroRect;

    JSValueRef * exception = NULL;
    
    JSObjectRef jsObject = [aDOMElement JSObject];
    
    if (jsObject != NULL)
    {
        JSStringRef getBBoxString = JSStringCreateWithUTF8CString("getBBox");
        JSStringRef xPropertyName = JSStringCreateWithUTF8CString("x");
        JSStringRef yPropertyName = JSStringCreateWithUTF8CString("y");
        JSStringRef widthPropertyName = JSStringCreateWithUTF8CString("width");
        JSStringRef heightPropertyName = JSStringCreateWithUTF8CString("height");

        //NSString * test = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, getBBoxString);
        
        JSValueRef getBBoxObjectValue = JSObjectGetProperty(globalContext, jsObject, getBBoxString, exception);

        JSStringRelease(getBBoxString);

        JSObjectRef getBBoxObject = JSValueToObject(globalContext, getBBoxObjectValue, exception);
        
        bool isFunction = JSObjectIsFunction(globalContext, getBBoxObject);
     
        if (isFunction == YES)
        {
            JSValueRef getBBoxValue = JSObjectCallAsFunction(globalContext, getBBoxObject, jsObject, 0, NULL, exception);
            
            if (getBBoxValue != NULL)
            {
                //JSType valueType = JSValueGetType(globalContext, getBBoxValue);

                JSObjectRef getBBoxValueObject = JSValueToObject(globalContext, getBBoxValue, exception);
                
                JSValueRef xValueRef = JSObjectGetProperty(globalContext, getBBoxValueObject, xPropertyName, exception);
                JSValueRef yValueRef = JSObjectGetProperty(globalContext, getBBoxValueObject, yPropertyName, exception);
                JSValueRef widthValueRef = JSObjectGetProperty(globalContext, getBBoxValueObject, widthPropertyName, exception);
                JSValueRef heightValueRef = JSObjectGetProperty(globalContext, getBBoxValueObject, heightPropertyName, exception);
                
                CGFloat x = JSValueToNumber(globalContext, xValueRef, exception);
                CGFloat y = JSValueToNumber(globalContext, yValueRef, exception);
                CGFloat width = JSValueToNumber(globalContext, widthValueRef, exception);
                CGFloat height = JSValueToNumber(globalContext, heightValueRef, exception);
            
                resultRect = NSMakeRect(x, y, width, height);
            }
        }
        
        JSStringRelease(getBBoxString);
        JSStringRelease(xPropertyName);
        JSStringRelease(yPropertyName);
        JSStringRelease(widthPropertyName);
        JSStringRelease(heightPropertyName);
    }
    else
    {
        // fallback to slower JavaScript injection
        resultRect = [self bBoxForDOMElement:aDOMElement];
    }
    
    return resultRect;
}

//==================================================================================
//	transformPoint:fromElement:toElement:
//==================================================================================

- (NSPoint)transformPoint:(NSPoint)aMousePoint fromElement:(DOMElement *)sourceElement toElement:(DOMElement *)targetElement
{
    //NSPoint resultPoint = NSZeroPoint;
    NSPoint resultPoint = aMousePoint;
    
    // current transform matrix
    id ctmMatrix = [targetElement callWebScriptMethod:@"getCTM"
            withArguments:NULL];  // call JavaScript function
    
    if (ctmMatrix != NULL)
    {
        id inverseCtmMatrix = [ctmMatrix callWebScriptMethod:@"inverse"
                withArguments:NULL];  // call JavaScript function
        
        if (inverseCtmMatrix != NULL)
        {
            id svgMousePoint = [sourceElement callWebScriptMethod:@"createSVGPoint"
                    withArguments:NULL];  // call JavaScript function
            
            NSNumber * xNumber = [NSNumber numberWithFloat:aMousePoint.x];
            [svgMousePoint setValue:xNumber forKey:@"x"];
            NSNumber * yNumber = [NSNumber numberWithFloat:aMousePoint.y];
            [svgMousePoint setValue:yNumber forKey:@"y"];
        
            NSArray * xformArray = @[inverseCtmMatrix];
            id transformCTMMousePoint = [svgMousePoint callWebScriptMethod:@"matrixTransform"
                    withArguments:xformArray];  // call JavaScript function
            
            if (transformCTMMousePoint != [WebUndefined undefined])
            {
                id xResult = [transformCTMMousePoint valueForKey:@"x"];
                
                id yResult = [transformCTMMousePoint valueForKey:@"y"];

                resultPoint = NSMakePoint([xResult floatValue], [yResult floatValue]);
            }
        }
    }
        
    return resultPoint;
}

//==================================================================================
//	pageRectForElement:svgRootElement:
//==================================================================================

/*
- (NSRect)pageRectForElement:(DOMElement *)aDOMElement svgRootElement:(DOMElement *)svgRootElement
{
    NSRect resultRect = NSZeroRect;
    DOMElement * domSvgSvgElement = svgRootElement;

    //if ([aDOMElement respondsToSelector:@selector(getBBox)])
    
    //id respondsToGetBBoxSelector = objc_msgSend(aDOMElement, respondsToSelectorSelector, getBBoxSelector);
    //if (respondsToGetBBoxSelector != NULL)

    send_type func1 = (send_type)objc_msgSend;
    aWebInspector = func1(aDOMElement, NSSelectorFromString(@"respondsToSelector"), NSSelectorFromString(@"getBBox"));
    {
        //DOMSVGRect * boundingBox = (id)[(id)aDOMElement getBBox];
        DOMSVGRect * boundingBox = objc_msgSend(aDOMElement, getBBoxSelector);

        typedef id (*send_type)(id, SEL);
        send_type func2 = (send_type)objc_msgSend;
        aWebInspector = func2(aDOMElement, NSSelectorFromString(@"getBBox"));

        if (boundingBox != NULL)
        {
            NSRect elementRect;
            elementRect.origin.x = boundingBox.x;
            elementRect.origin.y = boundingBox.y;
            elementRect.size.width = boundingBox.width;
            elementRect.size.height = boundingBox.height;

            id elementCtmMatrix = NULL;
            if ([aDOMElement respondsToSelector:@selector(getCTM)] == YES)
            {
                // current transform matrix
                elementCtmMatrix = [(id)aDOMElement getCTM];

                if (elementCtmMatrix != NULL)
                {
                    DOMSVGPoint * topLeftSvgMousePoint = [domSvgSvgElement createSVGPoint];

                    [topLeftSvgMousePoint setX:elementRect.origin.x];
                    [topLeftSvgMousePoint setY:elementRect.origin.y];
                    
                    DOMSVGPoint * topLeftCTMPoint = [topLeftSvgMousePoint matrixTransform:elementCtmMatrix];
                    
                    resultRect.origin.x = topLeftCTMPoint.x;
                    resultRect.origin.y = topLeftCTMPoint.y;

                    DOMSVGPoint * bottomRightSvgMousePoint = [domSvgSvgElement createSVGPoint];

                    [bottomRightSvgMousePoint setX:elementRect.origin.x + elementRect.size.width];
                    [bottomRightSvgMousePoint setY:elementRect.origin.y + elementRect.size.height];

                    DOMSVGPoint * bottomRightCTMPoint = [bottomRightSvgMousePoint matrixTransform:elementCtmMatrix];
                    
                    resultRect.size.width = bottomRightCTMPoint.x - topLeftCTMPoint.x;
                    resultRect.size.height = bottomRightCTMPoint.y - topLeftCTMPoint.y;
                }
            }
        }
    }
    
    return resultRect;
}
*/

- (NSRect)pageRectForElement:(DOMElement *)aDOMElement svgRootElement:(DOMElement *)svgRootElement
{
    NSRect resultRect = NSZeroRect;
    
    id boundingBox = [aDOMElement callWebScriptMethod:@"getBBox"
            withArguments:NULL];  // call JavaScript function

    if (boundingBox != NULL)
    {
        id xResult = [boundingBox valueForKey:@"x"];
        id yResult = [boundingBox valueForKey:@"y"];
        id widthResult = [boundingBox valueForKey:@"width"];
        id heightResult = [boundingBox valueForKey:@"height"];

        NSRect elementRect = NSMakeRect([xResult floatValue], [yResult floatValue], [widthResult floatValue], [heightResult floatValue]);

        id elementCtmMatrix = [aDOMElement callWebScriptMethod:@"getCTM"
                withArguments:NULL];  // call JavaScript function

        if (elementCtmMatrix != NULL)
        {
            id topLeftSvgMousePoint = [svgRootElement callWebScriptMethod:@"createSVGPoint"
                    withArguments:NULL];  // call JavaScript function
            
            NSNumber * xNumber = [NSNumber numberWithFloat:elementRect.origin.x];
            NSNumber * yNumber = [NSNumber numberWithFloat:elementRect.origin.y];
            
            [topLeftSvgMousePoint setValue:xNumber forKey:@"x"];
            [topLeftSvgMousePoint setValue:yNumber forKey:@"y"];
            
            NSArray * topleftMatrixArray = @[elementCtmMatrix];
            id topLeftCTMPoint = [topLeftSvgMousePoint callWebScriptMethod:@"matrixTransform"
                    withArguments:topleftMatrixArray];  // call JavaScript function
            
            if (topLeftCTMPoint != [WebUndefined undefined])
            {
                NSNumber * topLeftX = [topLeftCTMPoint valueForKey:@"x"];
                NSNumber * topLeftY = [topLeftCTMPoint valueForKey:@"y"];
                resultRect.origin.x = topLeftX.floatValue;
                resultRect.origin.y = topLeftY.floatValue;

                id bottomRightSvgMousePoint = [svgRootElement callWebScriptMethod:@"createSVGPoint"
                        withArguments:NULL];  // call JavaScript function

                NSNumber * bottomRightX = [NSNumber numberWithFloat:elementRect.origin.x + elementRect.size.width];
                NSNumber * bottomRightY = [NSNumber numberWithFloat:elementRect.origin.y + elementRect.size.height];
                [bottomRightSvgMousePoint setValue:bottomRightX forKey:@"x"];
                [bottomRightSvgMousePoint setValue:bottomRightY forKey:@"y"];

                //DOMSVGPoint * bottomRightCTMPoint = [bottomRightSvgMousePoint matrixTransform:elementCtmMatrix];

                NSArray * bottomRightMatrixArray = @[elementCtmMatrix];
                id bottomRightCTMPoint = [bottomRightSvgMousePoint callWebScriptMethod:@"matrixTransform"
                        withArguments:bottomRightMatrixArray];  // call JavaScript function
                
                NSNumber * topLeftCTMXNumber = [topLeftCTMPoint valueForKey:@"x"];
                NSNumber * topLeftCTMYNumber = [topLeftCTMPoint valueForKey:@"y"];
                NSNumber * bottomRightCTMXNumber = [bottomRightCTMPoint valueForKey:@"x"];
                NSNumber * bottomRightCTMYNumber = [bottomRightCTMPoint valueForKey:@"y"];
                
                CGFloat topLeftCTMX = topLeftCTMXNumber.floatValue;
                CGFloat topLeftCTMY = topLeftCTMYNumber.floatValue;
                CGFloat bottomRightCTMX = bottomRightCTMXNumber.floatValue;
                CGFloat bottomRightCTMY = bottomRightCTMYNumber.floatValue;
                
                resultRect.size.width = bottomRightCTMX - topLeftCTMX;
                resultRect.size.height = bottomRightCTMY - topLeftCTMY;
            }
        }
    }
    
    return resultRect;
}

//==================================================================================
//	animationsPausedForSvgElement:
//==================================================================================

- (BOOL)animationsPausedForSvgElement:(DOMNode *)svgElement
{
    NSNumber * animationsPaused = [svgElement callWebScriptMethod:@"animationsPaused"
            withArguments:NULL];  // call JavaScript function
    
    BOOL result = animationsPaused.boolValue;
    
    return result;
}

//==================================================================================
//	currentScaleForSvgElement:
//==================================================================================

- (float)currentScaleForSvgElement:(DOMNode *)svgElement
{
    //id currentScale = [svgElement getValueForKey:@"currentScale"];
    id currentScale = [svgElement callWebScriptMethod:@"currentScale"
            withArguments:NULL];  // call JavaScript function

    float result = [currentScale floatValue];
    
    return result;
}

//==================================================================================
//	pauseAnimationsForSvgElement:
//==================================================================================

- (void)pauseAnimationsForSvgElement:(DOMElement *)svgElement
{
    //NSLog(@"will pauseAnimations");
    [svgElement callWebScriptMethod:@"pauseAnimations"
            withArguments:NULL];  // call JavaScript function

    //NSLog(@"did pauseAnimations");
}

//==================================================================================
//	unpauseAnimationsForSvgElement:
//==================================================================================

- (void)unpauseAnimationsForSvgElement:(DOMElement *)svgElement
{
    //NSLog(@"will unpauseAnimations");

    [svgElement callWebScriptMethod:@"unpauseAnimations"
            withArguments:NULL];  // call JavaScript function

    //NSLog(@"did unpauseAnimations");
}

//==================================================================================
//	getCurrentTimeForSvgElement:
//==================================================================================

- (float)getCurrentTimeForSvgElement:(DOMElement *)svgElement
{
    NSNumber * currentTime = [svgElement callWebScriptMethod:@"getCurrentTime"
            withArguments:NULL];  // call JavaScript function

    float result = currentTime.floatValue;
    
    return result;
}

//==================================================================================
//	setRect:forElement:
//==================================================================================

- (void)setRect:(NSRect)aRect forElement:(DOMElement *)aElement
{
    if (aElement != NULL)
    {
        //NSString * elementDescription = [aElement outerHTML];
        //NSString * rectDescription = NSStringFromRect(aRect);
        //NSLog(@"updating element %@, %@", elementDescription, rectDescription);

        /*
        NSNumber * xNumber = [NSNumber numberWithFloat:aRect.origin.x];
        [aElement setValue:xNumber forKey:@"x"];
        
        NSNumber * yNumber = [NSNumber numberWithFloat:aRect.origin.y];
        [aElement setValue:yNumber forKey:@"y"];
        
        NSNumber * widthNumber = [NSNumber numberWithFloat:aRect.size.width];
        [aElement setValue:widthNumber forKey:@"width"];
        
        NSNumber * heightNumber = [NSNumber numberWithFloat:aRect.size.height];
        [aElement setValue:heightNumber forKey:@"height"];
        */

        NSString * xString = [NSString stringWithFormat:@"%fpx", aRect.origin.x];
        [aElement setAttribute:@"x" value:xString];

        NSString * yString = [NSString stringWithFormat:@"%fpx", aRect.origin.y];
        [aElement setAttribute:@"y" value:yString];

        NSString * widthString = [NSString stringWithFormat:@"%fpx", aRect.size.width];
        [aElement setAttribute:@"width" value:widthString];

        NSString * heightString = [NSString stringWithFormat:@"%fpx", aRect.size.height];
        [aElement setAttribute:@"height" value:heightString];
    }
    else
    {
        NSLog(@"setRect:forElement: aElement is NULL");
    }
}

//==================================================================================
//	getRectForElement:
//==================================================================================

- (NSRect)getRectForElement:(DOMElement *)aElement
{
    NSRect resultRect = NSZeroRect;
    
    /*
    DOMSVGRectElement * svgElement = (DOMSVGRectElement *)aElement;
    
    resultRect.origin.x = svgElement.x.baseVal.value;
    resultRect.origin.y = svgElement.y.baseVal.value;
    resultRect.size.width = svgElement.width.baseVal.value;
    resultRect.size.height = svgElement.height.baseVal.value;
    */
    
    NSNumber * xNumber = [aElement callWebScriptMethod:@"x.baseVal.value"
        withArguments:NULL];  // call JavaScript function
    NSNumber * yNumber = [aElement callWebScriptMethod:@"y.baseVal.value"
        withArguments:NULL];  // call JavaScript function
    NSNumber * widthNumber = [aElement callWebScriptMethod:@"width.baseVal.value"
        withArguments:NULL];  // call JavaScript function
    NSNumber * heightNumber = [aElement callWebScriptMethod:@"height"
        withArguments:NULL];  // call JavaScript function

    resultRect = NSMakeRect(xNumber.floatValue, yNumber.floatValue, widthNumber.floatValue, heightNumber.floatValue);
    
    return resultRect;
}

//==================================================================================
//	setPoint:forElement:
//==================================================================================

- (void)setPoint:(NSPoint)aPoint forElement:(DOMElement *)aElement
{
    if (aElement != NULL)
    {
        NSNumber * xNumber = [NSNumber numberWithFloat:aPoint.x];
        [aElement setValue:xNumber forKey:@"x"];
            
        NSNumber * yNumber = [NSNumber numberWithFloat:aPoint.y];
        [aElement setValue:yNumber forKey:@"y"];
    }
    else
    {
        NSLog(@"setPoint:forElement: aElement is NULL");
    }
}


//==================================================================================
//	replaceDOMElement:domDocument:
//==================================================================================

- (DOMElement *)replaceDOMElement:(DOMElement *)domElement domDocument:(DOMDocument *)domDocument
{
    // intended as work-around webkit bug to fix bounding rect, replace existing DOM path element
    NSString * elementName = domElement.tagName;
    
    DOMElement * newDOMElement = [domDocument createElementNS:@"http://www.w3.org/2000/svg"
            qualifiedName:elementName];

    DOMNamedNodeMap * domAttributesNodeMap = domElement.attributes;
    
    unsigned long itemCount = domAttributesNodeMap.length;
    for (unsigned i = 0; i < itemCount; i++)
    {
        DOMNode * attributeNode = [domAttributesNodeMap item:i];
        
        NSString * attributeName = attributeNode.nodeName;
        NSString * attributeValue = attributeNode.nodeValue;
        
        [newDOMElement setAttribute:attributeName value:attributeValue];
    }

    DOMElement * parentElement = domElement.parentElement;

    [parentElement replaceChild:newDOMElement oldChild:domElement];
    
    return newDOMElement;
}

//==================================================================================
//	extractValuesFromObject:name:
//==================================================================================

- (void)extractValuesFromObject:(WebScriptObject *)webScriptObject name:(NSString *)name
{
    id objCObject = [[webScriptObject JSValue] toObject];

    if ([objCObject isKindOfClass:[NSArray class]]) {
        for (id object in objCObject) {
            NSLog(@"object %@: %@", name, object);
        }
    }
    else if ([objCObject isKindOfClass:[NSDictionary class]]) {
        for (id<NSCopying> key in [objCObject allKeys]) {
           NSLog(@"object %@ for key %@: %@", name, key, objCObject[key]);
        }
    }
}


//==================================================================================
//	offsetRectElements:deltaX:deltaY:
//==================================================================================

/*
- (void) offsetRectElements:(DOMElement*)aElement deltaX:(float)deltaX deltaY:(float)deltaY
{
    NSString * nodeName = [aElement nodeName];

    if ([nodeName isEqualToString:@"rect"] == YES)
    {
        DOMElement * rectElement = (id)aElement;

        float x = rectElement.x.baseVal.value;
        float y = rectElement.y.baseVal.value;
        
        x += deltaX;
        y += deltaY;
                
        rectElement.x.baseVal.value = x;
        rectElement.y.baseVal.value = y;
    }

    int selectedRectsCount = aElement.childElementCount;
    for (int j = 0; j < selectedRectsCount; j++)
    {
        // recursive call for child elements
        DOMElement * childElement = (id)[aElement.childNodes item:j];
        [self offsetRectElements:childElement deltaX:deltaX deltaY:deltaY];
    }
}
*/


// copied from WebFrame.mm

// Pause a given SVG animation on the target node at a specific time.
// This method is only intended to be used for testing the SVG animation system.
/*
- (BOOL)_pauseSVGAnimation:(NSString*)elementId onSMILNode:(DOMNode *)node atTime:(NSTimeInterval)time
{
    Frame* frame = core(self);
    if (!frame)
        return false;
 
    Document* document = frame->document();
    if (!document || !document->svgExtensions())
        return false;

    Node* coreNode = core(node);
    if (!coreNode || !SVGSMILElement::isSMILElement(coreNode))
        return false;

#if ENABLE(SVG)
    return document->accessSVGExtensions()->sampleAnimationAtTime(elementId, static_cast<SVGSMILElement*>(coreNode), time);
#else
    return false;
#endif
}
*/



/*
- (BOOL)pauseSVGAnimationInFrame:(WebView *)webView elementId:(NSString*)elementId  onSMILNode:(DOMNode *)node atTime:(NSTimeInterval)time
{
    NSLog(@"Breakpoint this if enabled in development: pauseSVGAnimationInFrame test objc_msgSend");

    WebFrame * webFrame = [webView webFrame];

    //[webFrame _pauseSVGAnimation:elementId onSMILNode:node atTime:time];
    
    objc_msgSend(webFrame, sel_getUid("_pauseSVGAnimation:onSMILNode:atTime:time:"), elementId, node, time);

    //NSLog(@"pauseSVGAnimationInFrame done");
    
    return YES;
}
*/



        
        /*
        DOMSVGSVGElement * svgElement = (DOMSVGSVGElement *)svgElementNode;

        DOMSVGPoint * svgMousePoint = [svgElement createSVGPoint];
                
        [svgMousePoint setX:aMousePoint.x];
        [svgMousePoint setY:aMousePoint.y];
    
        // current transform matrix
        id screenCtmMatrix = [(id)targetElement getScreenCTM];
        id inverseScreenCtmMatrix = [screenCtmMatrix inverse];
        DOMSVGPoint * transformScreenCTMMousePoint = [svgMousePoint matrixTransform:inverseScreenCtmMatrix];
        */
        
        //NSLog(@"getScreenCTM original %f,%f - transformed  %f,%f", aMousePoint.x, aMousePoint.y, 
        //        transformScreenCTMMousePoint.x, transformScreenCTMMousePoint.y);
        
        //id ctmMatrix = [targetElement.parentElement getCTM];
        //id inverseCtmMatrix = [ctmMatrix inverse];
        //DOMSVGPoint * transformCTMMousePoint = [svgMousePoint matrixTransform:inverseScreenCtmMatrix];
        // NSLog(@"getCTM original %f,%f - transformed  %f,%f", aMousePoint.x, aMousePoint.y, 
        //        transformCTMMousePoint.x, transformCTMMousePoint.y);
        
        // N.B. getTransformToElement is removed in SVG 2
        //DOMSVGMatrix * transformToElementMatrix = [svgElement getTransformToElement:targetElement.parentElement];
        //id inverseTteMatrix = [transformToElementMatrix inverse];
        //DOMSVGPoint * transformTteMousePoint = [svgMousePoint matrixTransform:inverseTteMatrix];
        
        /*
        resultPoint.x = transformScreenCTMMousePoint.x;
        resultPoint.y = transformScreenCTMMousePoint.y;
        */


@end
