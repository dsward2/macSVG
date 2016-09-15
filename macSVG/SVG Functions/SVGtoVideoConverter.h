//
//  SVGtoVideoConverter.h
//  macSVG
//
//  Created by Douglas Ward on 9/8/16.
//
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"
#import "WebKit/WebKit.h"

@interface SVGtoVideoConverter : NSObject

@property (strong) NSString * path;
@property (assign) float movieWidth;
@property (assign) float movieHeight;
@property (assign) float startTime;
@property (assign) float endTime;
@property (assign) float framesPerSecond;
@property (assign) float frameTimeInterval;
@property (assign) float currentTime;
@property (assign) NSInteger frameCount;
@property (assign) CGSize webFrameSize;

@property (strong) NSWindow * hiddenWindow;
@property (strong) WebView * hiddenWebView;

@property (strong) AVAssetWriter * videoWriter;
@property (strong) NSDictionary * videoSettings;
@property (strong) AVAssetWriterInput * writerInput;
@property (strong) AVAssetWriterInputPixelBufferAdaptor * adaptor;

@property (weak) NSTextField * currentTimeTextLabel;
@property (weak) NSWindow * generatingHTML5VideoSheet;
@property (weak) NSWindow * hostWindow;

- (void) writeSVGAnimationAsMovie:(NSString*)path svgXmlString:(NSString *)svgXmlString
        width:(NSInteger)movieWidth height:(NSInteger)movieHeight
        startTime:(CGFloat)startTime endTime:(CGFloat)endTime
        framesPerSecond:(NSInteger)framesPerSecond
        currentTimeTextLabel:(NSTextField *)currentTimeTextLabel
        generatingHTML5VideoSheet:(NSWindow *)generatingHTML5VideoSheet
        hostWindow:(NSWindow *)hostWindow;

@end
