//
//  RulerView.h
//  macSVG
//
//  Created by Douglas Ward on 11/12/17.
//  Copyright © 2017 ArkPhone, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class SVGWebView;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface RulerView : NSView <WebUIDelegate, WebPolicyDelegate, WebEditingDelegate, WebFrameLoadDelegate, WebResourceLoadDelegate, WebDownloadDelegate>

@property (weak) IBOutlet WebView * rulerWebView;

@property (weak) IBOutlet SVGWebView * svgWebView;

@property (strong) NSString * rulerUnit;

@property (assign) NSInteger majorMarkInterval;
@property (assign) CGFloat majorMarkOffset;
@property (assign) CGFloat majorMarkLength;
@property (assign) CGFloat majorMarkWidth;

@property (assign) NSInteger midMarkInterval;
@property (assign) CGFloat midMarkOffset;
@property (assign) CGFloat midMarkLength;
@property (assign) CGFloat midMarkWidth;

@property (assign) NSInteger minorMarkInterval;
@property (assign) CGFloat minorMarkOffset;
@property (assign) CGFloat minorMarkLength;
@property (assign) CGFloat minorMarkWidth;

@property (assign) CGFloat fontSize;

- (void)createRulerWebView;

@end

#pragma clang diagnostic pop
