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

@interface SVGWebView : WebView
{
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;
    IBOutlet SVGWebKitController * svgWebKitController;
@private
    
}

@property (assign)CGFloat zoomFactor;

- (void)setSVGZoomStyleWithFloat:(CGFloat)zoomFactor;


@end
