//
//  SVGWebView.h
//  macSVG
//
//  Created by Douglas Ward on 9/30/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class MacSVGDocumentWindowController;
@class SVGWebKitController;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface SVGWebView : WebView
{
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;
    IBOutlet SVGWebKitController * svgWebKitController;
}

@property (assign) float zoomFactor;

- (void)setSVGZoomStyleWithFloat:(float)zoomFactor;


@end


#pragma clang diagnostic pop
