//
//  SVGtoImagesConverter.h
//  macSVG
//
//  Created by Douglas Ward on 9/24/16.
//
//

#import <Foundation/Foundation.h>
#import "WebKit/WebKit.h"

@class MacSVGDocumentWindowController;

@interface SVGtoImagesConverter : NSObject

@property (weak) IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;

@property (strong) NSString * path;
@property (strong) NSString * svgXmlString;
@property (assign) float imageWidth;
@property (assign) float imageHeight;
@property (assign) float imageScale;
@property (assign) float startTime;
@property (assign) float endTime;
@property (assign) float framesPerSecond;
@property (assign) float frameTimeInterval;
@property (assign) float currentTime;
@property (assign) NSInteger frameCount;
@property (assign) CGSize webFrameSize;

@property (strong) NSString * outputFormatString;
@property (strong) NSString * outputOptionsString;
@property (assign) BOOL includeAlpha;

@property (strong) NSWindow * hiddenWindow;
@property (strong) WebView * hiddenWebView;

@property (strong) NSMutableArray * iOSIconsetArray;
@property (strong) NSMutableArray * macOSIconsetArray;
@property (strong) NSArray * currentIconsetArray;
@property (assign) NSInteger iconsetIndex;

@property (weak) NSTextField * currentTimeTextLabel;
@property (weak) NSWindow * exportingImagesSheet;
@property (weak) NSWindow * hostWindow;

- (void) writeSVGAnimationAsImages:(NSString*)path svgXmlString:(NSString *)svgXmlString
        width:(NSInteger)imageWidth height:(NSInteger)imageHeight
        startTime:(CGFloat)startTime endTime:(CGFloat)endTime
        framesPerSecond:(NSInteger)framesPerSecond
        outputFormat:(NSString *)outputFormatString
        outputOptions:(NSString *)outputOptionsString
        includeAlpha:(BOOL)includeAlpha
        currentTimeTextLabel:(NSTextField *)currentTimeTextLabel
        exportingImagesSheet:(NSWindow *)exportingImagesSheet
        hostWindow:(NSWindow *)hostWindow;

@end
