//
//  WebKitInterface.h
//  TransformAttributeEditor
//
//  Created by Douglas Ward on 7/9/13.
//
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class DOMDocument;
@class DOMElement;
@class DOMNode;
@class WebView;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface WebKitInterface : NSObject
{
}

- (NSRect)bBoxForDOMElement:(DOMElement *)aDOMElement;
- (NSRect)bBoxForDOMElement:(DOMElement *)aDOMElement webView:(WebView *)webView;
- (NSRect)bBoxForDOMElement:(DOMElement *)aDOMElement globalContext:(JSContextRef)globalContext;

- (NSRect)pageRectForElement:(DOMElement *)aDOMElement svgRootElement:(DOMElement *)svgRootElement;

- (NSRect)getRectForElement:(DOMElement *)aElement;
- (void)setRect:(NSRect)aRect forElement:(DOMElement *)aElement;

- (void)setPoint:(NSPoint)aPoint forElement:(DOMElement *)aElement;

- (NSPoint)transformPoint:(NSPoint)aMousePoint fromElement:(DOMElement *)sourceElement toElement:(DOMElement *)targetElement;

- (float)getCurrentTimeForSvgElement:(DOMElement *)svgElement;

- (BOOL)animationsPausedForSvgElement:(DOMElement *)svgElement;
- (void)pauseAnimationsForSvgElement:(DOMElement *)svgElement;
- (void)unpauseAnimationsForSvgElement:(DOMElement *)svgElement;

- (DOMElement *)replaceDOMElement:(DOMElement *)domElement domDocument:(DOMDocument *)domDocument;

- (float)currentScaleForSvgElement:(DOMNode *)svgElement;

@end

#pragma clang diagnostic pop
