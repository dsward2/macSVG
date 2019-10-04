//
//  SVGtoVideoConverter.m
//  macSVG
//
//  Created by Douglas Ward on 9/8/16.
//
//

// adapted from http://stackoverflow.com/questions/10647091/how-to-create-video-from-its-frames-iphone/19166876#19166876
// and http://chrisjdavis.org/capturing-the-contents-of-a-webview

#import "SVGtoVideoConverter.h"
//#import "CoreGraphics/CoreGraphics.h"
#import <VideoToolbox/VTCompressionProperties.h>

@implementation SVGtoVideoConverter

- (void)dealloc
{
    self.hiddenWebView.downloadDelegate = NULL;
    self.hiddenWebView.frameLoadDelegate = NULL;
    self.hiddenWebView.policyDelegate = NULL;
    self.hiddenWebView.UIDelegate = NULL;
    self.hiddenWebView.resourceLoadDelegate = NULL;

    self.hiddenWebView = NULL;
    self.videoWriter = NULL;
    self.videoSettings = NULL;
    self.writerInput = NULL;
    self.adaptor = NULL;
    
    self.hiddenWindow = NULL;
}



- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.videoWriterFailed = NO;
    }
    return self;
}



- (void) writeSVGAnimationAsMovie:(NSString*)path svgXmlString:(NSString *)svgXmlString
        width:(NSInteger)movieWidth height:(NSInteger)movieHeight
        startTime:(CGFloat)startTime endTime:(CGFloat)endTime
        framesPerSecond:(NSInteger)framesPerSecond
        currentTimeTextLabel:(NSTextField *)currentTimeTextLabel
        generatingHTML5VideoSheet:(NSWindow *)generatingHTML5VideoSheet
        hostWindow:(NSWindow *)hostWindow
{
    self.path = path;
    self.movieWidth = movieWidth;
    self.movieHeight = movieHeight;
    self.startTime = startTime;
    self.endTime = endTime;
    self.framesPerSecond = framesPerSecond;

    self.currentTime = self.startTime;
    self.frameCount = 0;
    self.frameTimeInterval = 1.0f / self.framesPerSecond;
    
    self.currentTimeTextLabel = currentTimeTextLabel;
    self.generatingHTML5VideoSheet = generatingHTML5VideoSheet;
    self.hostWindow = hostWindow;

    NSFileManager *manager = [[NSFileManager alloc] init];
    if ([manager fileExistsAtPath:path] == YES)
    {
        NSError *fileError;
        [manager removeItemAtPath:path error:&fileError];
        if (fileError)
        {
            NSLog(@"%@", fileError.localizedDescription);
        }
    }

    NSString * currentTimeString = [NSString stringWithFormat:@"%f", self.currentTime];
    self.currentTimeTextLabel.stringValue = currentTimeString;

    NSRect webViewFrame = NSMakeRect(0, 0, self.movieWidth, self.movieHeight);

    // create a new window, offscreen.
    self.hiddenWindow = [[NSWindow alloc]
            initWithContentRect: NSMakeRect( -2000,-2000, self.movieWidth, self.movieHeight)    // init offscreen
            //initWithContentRect: NSMakeRect( 100,100, self.movieWidth, self.movieHeight)  // init onscreen for testing
            styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
            //backing:NSBackingStoreNonretained
            backing:NSBackingStoreBuffered
            defer:NO];
    
    //[self.hiddenWindow makeKeyAndOrderFront:self];    // for testing purposes, when 'hiddenWindow' is init onscreen

    self.hiddenWebView = [[WebView alloc] initWithFrame:webViewFrame];
    
    self.hiddenWebView.drawsBackground = NO;

    WebPreferences * hiddenWebViewPreferences = self.hiddenWebView.preferences;
    [hiddenWebViewPreferences setJavaScriptEnabled:YES];

    (self.hiddenWindow).contentView = self.hiddenWebView;
    
    NSData * xmlData = [svgXmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * baseURL = NULL;
    
    NSString * mimeType = @"image/svg+xml";

    [(self.hiddenWebView).mainFrame loadData:xmlData
            MIMEType:mimeType	
            textEncodingName:@"UTF-8" 
            baseURL:baseURL];

    [self performSelector:@selector(getNextFrameImage) withObject:NULL afterDelay:2.0f];
}


- (void)initVideoWriter:(NSImage *)firstFrameImage
{
    self.videoWriterFailed = NO;

    NSError *error  = nil;
    
    self.webFrameSize = firstFrameImage.size;
    
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:
            [NSURL fileURLWithPath:self.path]
            //fileType:AVFileTypeQuickTimeMovie
            fileType:AVFileTypeMPEG4
            error:&error];
    
    NSParameterAssert(self.videoWriter);

    NSMutableDictionary *compressionSettings = NULL;
    compressionSettings = [NSMutableDictionary dictionary];

    /*
    Specify the HD output color space for the video color properties
    key (AVVideoColorPropertiesKey). During export, AV Foundation
    will perform a color match from the input color space to the HD
    output color space.
     
	Most clients will want to specify HD, which consists of:
 
		AVVideoColorPrimaries_ITU_R_709_2
		AVVideoTransferFunction_ITU_R_709_2
		AVVideoYCbCrMatrix_ITU_R_709_2
 
	If you require SD colorimetry use:
 
		AVVideoColorPrimaries_SMPTE_C
		AVVideoTransferFunction_ITU_R_709_2
		AVVideoYCbCrMatrix_ITU_R_601_4

	If you require wide gamut HD colorimetry, you can use:
 
		 AVVideoColorPrimaries_P3_D65
		 AVVideoTransferFunction_ITU_R_709_2
		 AVVideoYCbCrMatrix_ITU_R_709_2
    */

    //[compressionSettings setObject:AVVideoColorPrimaries_P3_D65   // TODO: requires macOS 10.12
    compressionSettings[AVVideoColorPrimariesKey] = AVVideoColorPrimaries_ITU_R_709_2;
    compressionSettings[AVVideoTransferFunctionKey] = AVVideoTransferFunction_ITU_R_709_2;
    compressionSettings[AVVideoYCbCrMatrixKey] = AVVideoYCbCrMatrix_ITU_R_709_2;
                
    //NSDictionary * encoder_spec = [NSDictionary dictionaryWithObjectsAndKeys:@(NO), kVTVideoEncoderSpecification_EnableHardwareAcceleratedVideoEncoder, nil];
    NSDictionary * encoder_spec = @{ (__bridge NSString *)kVTVideoEncoderSpecification_EnableHardwareAcceleratedVideoEncoder: @(NO)};

    self.videoSettings = @{AVVideoCodecKey: AVVideoCodecTypeH264,
            AVVideoWidthKey: [NSNumber numberWithInteger:self.movieWidth],
            AVVideoHeightKey: [NSNumber numberWithInteger:self.movieHeight],
            AVVideoColorPropertiesKey: compressionSettings,
            AVVideoEncoderSpecificationKey: encoder_spec
    };
    
    // on Mac Pro with Xeon processors, AVAssetWriterInput returns this warning message - AVDCreateGPUAccelerator: Error loading GPU renderer
    self.writerInput = [AVAssetWriterInput
            assetWriterInputWithMediaType:AVMediaTypeVideo
            outputSettings:self.videoSettings];

    NSDictionary* bufferAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32ARGB]};

    self.adaptor = [AVAssetWriterInputPixelBufferAdaptor
        assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.writerInput
        sourcePixelBufferAttributes:bufferAttributes];

    NSParameterAssert(self.writerInput);
    NSParameterAssert([self.videoWriter canAddInput:self.writerInput]);
    [self.videoWriter addInput:self.writerInput];
    
    if (self.videoWriter.status == AVAssetWriterStatusFailed)
    {
        NSLog(@"self.videoWriter.status = AVAssetWriterStatusFailed 1");
    }

    [self.videoWriter startWriting];

    if (self.videoWriter.status == AVAssetWriterStatusFailed)
    {
        NSLog(@"self.videoWriter.status = AVAssetWriterStatusFailed 2");
    }

    [self.videoWriter startSessionAtSourceTime:kCMTimeZero];

    if (self.videoWriter.status == AVAssetWriterStatusFailed)
    {
        NSLog(@"self.videoWriter.status = AVAssetWriterStatusFailed 3");
    }

}


- (void)getNextFrameImage
{
    // TODO: FIXME: Investigate use of RequestAnimationFrame() and callback, instead of setCurrentTime() and delay

    DOMDocument * domDocument = (self.hiddenWebView).mainFrame.DOMDocument;
    DOMElement * svgElement = domDocument.documentElement;
    
    NSString * currentTimeString = [NSString stringWithFormat:@"%f", self.currentTime];
    self.currentTimeTextLabel.stringValue = currentTimeString;
    NSNumber * newTimeValueNumber = @(self.currentTime);

    [svgElement callWebScriptMethod:@"pauseAnimations" withArguments:NULL];  // call JavaScript function
    
    NSArray * setCurrentTimeArgumentsArray = @[newTimeValueNumber];
    [svgElement callWebScriptMethod:@"setCurrentTime" withArguments:setCurrentTimeArgumentsArray];  // call JavaScript function

    [svgElement callWebScriptMethod:@"forceRedraw" withArguments:NULL];  // call JavaScript function

    [self.hiddenWebView setNeedsDisplay:YES];
    
    CGFloat delay = 0.1f;
    
    [self performSelector:@selector(webViewDidFinishLoad) withObject:NULL afterDelay:delay];
}



- (void)webViewDidFinishLoad
{
    NSImage * webImage = [self imageFromWebView];

    if (self.currentTime == self.startTime)
    {
        [self initVideoWriter:webImage];
    }

    CGImageSourceRef webCGImageSourceRef = CGImageSourceCreateWithData((CFDataRef)webImage.TIFFRepresentation, NULL);
    CGImageRef webCGImageRef =  CGImageSourceCreateImageAtIndex(webCGImageSourceRef, 0, NULL);

    CVPixelBufferRef buffer = [self newPixelBufferFromCGImage:webCGImageRef andFrameSize:self.webFrameSize];



    // per Technical Q&A QA1839: Specifying color space information for pixel buffers
    // https://developer.apple.com/library/content/qa/qa1839/_index.html
    CGColorSpaceRef sRGBColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    if (sRGBColorSpace != NULL)
    {
        //CFDataRef sRGBProfileData = CGColorSpaceCopyICCProfile(sRGBColorSpace);   // deprecated - Please use `CGColorSpaceCopyICCData'
        CFDataRef sRGBProfileData = CGColorSpaceCopyICCData(sRGBColorSpace);
        
        if (sRGBProfileData != NULL)
        {
            NSDictionary *pbAttachements =
                        @{(id)kCVImageBufferICCProfileKey : (__bridge id)sRGBProfileData};
     
            CFRelease(sRGBProfileData);
     
            //CVBufferRef pixelBuffer = <#Your pixel buffer#>;
     
            /* set the color space attachment on the buffer */
            CVBufferSetAttachments(buffer,
                        (__bridge CFDictionaryRef)pbAttachements, kCVAttachmentMode_ShouldPropagate);
        }
        else
        {
            NSLog(@"CGColorSpaceCopyICCProfile returned NULL");
     
            /* handle the error */
        }
     
        CFRelease(sRGBColorSpace);
    }
    else
    {
        NSLog(@"CGColorSpaceCreateWithName returned NULL");
     
        /* handle the error */
    }



    if (self.adaptor.assetWriterInput.readyForMoreMediaData)
    {
        CMTime frameTime = CMTimeMake(self.frameCount, (int32_t)self.framesPerSecond);
        BOOL appendResult = [self.adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
        
        if (appendResult == NO)
        {
            NSLog(@"appendPixelBuffer:withPresentationTime failed");
            NSLog(@"videoWriter.status = %ld", self.videoWriter.status);
            NSLog(@"videoWriter.error = %@", self.videoWriter.error);
            
            self.videoWriterFailed = YES;
        }
    }

    if (buffer)
    {
        CVBufferRelease(buffer);
    }

    if (webCGImageRef)
    {
        CGImageRelease((webCGImageRef));
    }
    
    if (self.videoWriterFailed == NO)
    {
        self.frameCount++;
        self.currentTime += self.frameTimeInterval;
        
        if (self.currentTime > self.endTime)
        {
            //[self finishWritingVideo];
            [self performSelector:@selector(finishWritingVideo) withObject:NULL afterDelay:1];
        }
        else
        {
            [self getNextFrameImage];
        }
    }
    else
    {
        // error detected, stop video output
        [self.hostWindow endSheet:self.generatingHTML5VideoSheet returnCode:NSModalResponseStop];
        [self.generatingHTML5VideoSheet orderOut:self];
        
        // TODO: add an error message for user here
    }
}



- (void)finishWritingVideo
{
    [self.writerInput markAsFinished];

    [self.videoWriter finishWritingWithCompletionHandler:^
    {
        if (self.videoWriter.status != AVAssetWriterStatusFailed && self.videoWriter.status == AVAssetWriterStatusCompleted)
        {
        }
        else
        {
            NSError * assetWriterError = self.videoWriter.error;
            
            NSLog(@"SVGtoVideoConverter error - %@", assetWriterError);
        }
        
        //self.videoWriter = NULL;
    }];
    
    [self.hostWindow endSheet:self.generatingHTML5VideoSheet returnCode:NSModalResponseStop];
    [self.generatingHTML5VideoSheet orderOut:self];
}



-(void)imageDump:(CGImageRef)cgimage
{
    size_t width  = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);

    size_t bpr = CGImageGetBytesPerRow(cgimage);
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t bytes_per_pixel = bpp / bpc;

    CGBitmapInfo info = CGImageGetBitmapInfo(cgimage);

    NSLog(
        @"\n"
        "CGImageGetWidth: %d\n"
        "CGImageGetHeight:  %d\n"
        "CGImageGetColorSpace: %@\n"
        "CGImageGetBitsPerPixel:     %d\n"
        "CGImageGetBitsPerComponent: %d\n"
        "CGImageGetBytesPerRow:      %d\n"
        "CGImageGetBitmapInfo: 0x%.8X\n"
        "  kCGBitmapAlphaInfoMask     = %s\n"
        "  kCGBitmapFloatComponents   = %s\n"
        "  kCGBitmapByteOrderMask     = 0x%.8X\n"
        "  kCGBitmapByteOrderDefault  = %s\n"
        "  kCGBitmapByteOrder16Little = %s\n"
        "  kCGBitmapByteOrder32Little = %s\n"
        "  kCGBitmapByteOrder16Big    = %s\n"
        "  kCGBitmapByteOrder32Big    = %s\n",
        (int)width,
        (int)height,
        CGImageGetColorSpace(cgimage),
        (int)bpp,
        (int)bpc,
        (int)bpr,
        (unsigned)info,
        (info & kCGBitmapAlphaInfoMask)     ? "YES" : "NO",
        (info & kCGBitmapFloatComponents)   ? "YES" : "NO",
        (info & kCGBitmapByteOrderMask),
        ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrderDefault)  ? "YES" : "NO",
        ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder16Little) ? "YES" : "NO",
        ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder32Little) ? "YES" : "NO",
        ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder16Big)    ? "YES" : "NO",
        ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder32Big)    ? "YES" : "NO"
    );

    CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
    NSData* data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
    const uint8_t* bytes = [data bytes];

    printf("Pixel Data:\n");
    //for(size_t row = 0; row < height; row++)
    for(size_t row = height / 2; row <= height / 2; row++)  // just sample the middle row
    {
        for(size_t col = 0; col < width; col++)
        {
            const uint8_t* pixel =
                &bytes[row * bpr + col * bytes_per_pixel];

            printf("(");
            for(size_t x = 0; x < bytes_per_pixel; x++)
            {
                printf("%.2X", pixel[x]);
                if( x < bytes_per_pixel - 1 )
                    printf(",");
            }

            printf(")");
            if( col < width - 1 )
                printf(", ");
        }

        printf("\n");
    }
}


- (CVPixelBufferRef) newPixelBufferFromCGImage:(CGImageRef)image andFrameSize:(CGSize)frameSize
{
    //[self imageDump:image];
    
    size_t imageWidth = CGImageGetWidth(image);
    size_t imageHeight = CGImageGetHeight(image);
    //CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(image);

    NSDictionary *options = @{(id)kCVPixelBufferCGImageCompatibilityKey: @YES,
            (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
            frameSize.width,
            frameSize.height,
            kCVPixelFormatType_32ARGB,
            (__bridge CFDictionaryRef)options,
            &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);

    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    NSParameterAssert(pxdata != NULL);

    //CGColorSpaceRef genericRGBColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGColorSpaceRef genericRGBColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
            frameSize.width,
            frameSize.height,
            8,
            4 * frameSize.width,
            genericRGBColorSpace,
            //kCGImageAlphaNoneSkipFirst);
            kCGImageAlphaPremultipliedFirst);
    
    NSParameterAssert(context);
    
    CGContextSetRenderingIntent(context, kCGRenderingIntentAbsoluteColorimetric);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image);
    
    CGColorSpaceRelease(genericRGBColorSpace);
    
    CGContextRelease(context);

    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);

    return pxbuffer;
}



- (NSImage *)imageFromWebView
{
    NSRect imageBounds = NSMakeRect(0, 0, self.movieWidth, self.movieHeight);

    NSRect webViewBounds = self.hiddenWebView.bounds;

    // grab the full view
	//[self.hiddenWebView lockFocus];
    //NSBitmapImageRep * bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:webViewBounds];
	//[self.hiddenWebView unlockFocus];

    //'initWithFocusedViewRect:' is deprecated: first deprecated in macOS 10.14 - Use -[NSView cacheDisplayInRect:toBitmapImageRep:] to snapshot a view.
    NSBitmapImageRep * bitmapRep = [self.hiddenWebView bitmapImageRepForCachingDisplayInRect:webViewBounds];
    [self.hiddenWebView cacheDisplayInRect:webViewBounds toBitmapImageRep:bitmapRep];

    bitmapRep.colorSpaceName = NSDeviceRGBColorSpace;
    
    // crop the view to document size
    NSImage * webImage = [[NSImage alloc] initWithSize:imageBounds.size];
    
    NSRect srcImageBounds = imageBounds;
    srcImageBounds.origin.y = webViewBounds.size.height - self.movieHeight;
    
    // draw to create bitmapImageRep
    [webImage lockFocus];
    [bitmapRep drawInRect:imageBounds fromRect:srcImageBounds operation:NSCompositingOperationCopy
            fraction:1.0f respectFlipped:YES hints:NULL];
    [webImage unlockFocus];

    NSArray * destinationRepresentations = webImage.representations;
    NSBitmapImageRep * destinationBitmapImageRep = destinationRepresentations.firstObject;
    destinationBitmapImageRep.colorSpaceName = NSCalibratedRGBColorSpace;

    // redraw after color space setting
    [webImage lockFocus];
    [bitmapRep drawInRect:imageBounds fromRect:srcImageBounds operation:NSCompositingOperationCopy
            fraction:1.0f respectFlipped:YES hints:NULL];
    [webImage unlockFocus];

    return webImage;
}


@end
