//
//  SVGtoImagesConverter.m
//  macSVG
//
//  Created by Douglas Ward on 9/24/16.
//
//

#import "SVGtoImagesConverter.h"
#import "MacSVGDocumentWindowController.h"

@implementation SVGtoImagesConverter

//==================================================================================
// dealloc
//==================================================================================

- (void)dealloc
{
    [self.hiddenWebView stopLoading:self];

    self.hiddenWebView.downloadDelegate = NULL;
    self.hiddenWebView.frameLoadDelegate = NULL;
    self.hiddenWebView.policyDelegate = NULL;
    self.hiddenWebView.UIDelegate = NULL;
    self.hiddenWebView.resourceLoadDelegate = NULL;

    self.hiddenWebView = NULL;
    
    self.hiddenWindow = NULL;
}

//==================================================================================
// init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.currentIconsetArray = NULL;
        
        self.macOSIconsetArray = [NSMutableArray array];
        [self.macOSIconsetArray addObject:@"icon_512x512@2x.png 1024"];
        [self.macOSIconsetArray addObject:@"icon_512x512.png 512"];
        [self.macOSIconsetArray addObject:@"icon_256x256@2x.png 512"];
        [self.macOSIconsetArray addObject:@"icon_256x256.png 256"];
        [self.macOSIconsetArray addObject:@"icon_128x128@2x.png 256"];
        [self.macOSIconsetArray addObject:@"icon_128x128.png 128"];
        [self.macOSIconsetArray addObject:@"icon_32x32@2x.png 64"];
        [self.macOSIconsetArray addObject:@"icon_32x32.png 32"];
        [self.macOSIconsetArray addObject:@"icon_16x16@2x.png 32"];
        [self.macOSIconsetArray addObject:@"icon_16x16.png 16"];
        
        self.iOSIconsetArray = [NSMutableArray array];
        [self.iOSIconsetArray addObject:@"icon_1024x1024.png 1024"];
        [self.iOSIconsetArray addObject:@"icon_180x180.png 180"];
        [self.iOSIconsetArray addObject:@"icon_167x167.png 167"];
        [self.iOSIconsetArray addObject:@"icon_152x152.png 152"];
        [self.iOSIconsetArray addObject:@"icon_120x120.png 120"];
    }
    return self;
}

//==================================================================================
// writeSVGAnimationAsImages:svgXmlString:width:height:startTime:endTime:framesPerSecond:outputFormat:
//        outputOptions:includeAlpha:currentTimeTextLabel:exportingImagesSheet:hostWindow:
//==================================================================================

- (void) writeSVGAnimationAsImages:(NSString*)path
        svgXmlString:(NSString *)svgXmlString
        width:(NSInteger)imageWidth height:(NSInteger)imageHeight
        startTime:(CGFloat)startTime endTime:(CGFloat)endTime
        framesPerSecond:(NSInteger)framesPerSecond
        outputFormat:(NSString *)outputFormatString
        outputOptions:(NSString *)outputOptionsString
        includeAlpha:(BOOL)includeAlpha
        currentTimeTextLabel:(NSTextField *)currentTimeTextLabel
        exportingImagesSheet:(NSWindow *)exportingImagesSheet
        hostWindow:(NSWindow *)hostWindow
{
    self.path = path;
    
    self.svgXmlString = svgXmlString;
    
    self.imageWidth = imageWidth;
    self.imageHeight = imageHeight;
    self.startTime = startTime;
    self.endTime = endTime;
    self.framesPerSecond = framesPerSecond;

    self.currentTime = self.startTime;
    self.frameCount = 0;
    self.frameTimeInterval = 1.0f / self.framesPerSecond;
    
    self.currentTimeTextLabel = currentTimeTextLabel;
    self.exportingImagesSheet = exportingImagesSheet;
    self.hostWindow = hostWindow;
    
    self.outputFormatString = outputFormatString;
    self.outputOptionsString = outputOptionsString;
    self.includeAlpha = includeAlpha;

    NSString * currentTimeString = [NSString stringWithFormat:@"%f", self.currentTime];
    self.currentTimeTextLabel.stringValue = currentTimeString;

    if ([outputOptionsString isEqualToString:@"Current Image Only"] == YES)
    {
        [self createOffscreenWindow];
    }
    else if ([outputOptionsString isEqualToString:@"Animation Images"] == YES)
    {
        [self createOffscreenWindow];
    }
    else if ([outputOptionsString isEqualToString:@"macOS .iconset"] == YES)
    {
        self.currentIconsetArray = self.macOSIconsetArray;
        self.iconsetIndex = 0;
        
        [self createOffscreenWindowForIconset];
    }
    else if ([outputOptionsString isEqualToString:@"iOS .iconset"] == YES)
    {
        self.currentIconsetArray = self.iOSIconsetArray;
        self.iconsetIndex = 0;
        
        [self createOffscreenWindowForIconset];
    }
}

//==================================================================================
// createOffscreenWindowForIconset
//==================================================================================

- (void) createOffscreenWindowForIconset
{
    NSInteger currentIconsetArrayCount = (self.currentIconsetArray).count;
    
    if (self.iconsetIndex < currentIconsetArrayCount)
    {
        NSString * iconsetItemString = (self.currentIconsetArray)[self.iconsetIndex];
        
        NSArray * iconsetItemArray = [iconsetItemString componentsSeparatedByString:@" "];
        
        self.imageWidth = [iconsetItemArray[1] floatValue];
        self.imageHeight = self.imageWidth;
        
        self.imageScale = self.imageWidth / 512.0f;

        if (self.hiddenWebView != NULL)
        {
            [self.hiddenWebView stopLoading:self];
        
            self.hiddenWebView.downloadDelegate = NULL;
            self.hiddenWebView.frameLoadDelegate = NULL;
            self.hiddenWebView.policyDelegate = NULL;
            self.hiddenWebView.UIDelegate = NULL;
            self.hiddenWebView.resourceLoadDelegate = NULL;
            
            [self.hiddenWebView removeFromSuperview];

            self.hiddenWebView = NULL;
        }

        if (self.hiddenWindow != NULL)
        {
            [self.hiddenWindow close];
            self.hiddenWindow = NULL;
        }
        
        [self createOffscreenWindow];
    }
    else
    {
        [self.macSVGDocumentWindowController exportingImagesDoneAction:self];
    }
}

//==================================================================================
// createOffscreenWindow
//==================================================================================

- (void)createOffscreenWindow
{
    // create a new window, offscreen.
    NSRect webViewFrame = NSMakeRect(0, 0, self.imageWidth, self.imageHeight);

    self.hiddenWindow = [[NSWindow alloc]
            initWithContentRect: NSMakeRect( -2000,-2000, self.imageWidth, self.imageHeight)
            styleMask: NSTitledWindowMask | NSClosableWindowMask backing:NSBackingStoreNonretained defer:NO];
    
    self.hiddenWindow.releasedWhenClosed = NO;

    self.hiddenWebView = [[WebView alloc] initWithFrame:webViewFrame];
    
    self.hiddenWebView.drawsBackground = NO;

    (self.hiddenWindow).contentView = self.hiddenWebView;
    
    NSData * xmlData = [self.svgXmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError * xmlError;
    NSXMLDocument * tempXMLDocument = [[NSXMLDocument alloc] initWithData:xmlData options:NSXMLNodePreserveCDATA error:&xmlError];
    
    if ([self.outputOptionsString isEqualToString:@"macOS .iconset"] == YES)
    {
        [self adjustIconDocumentSize:tempXMLDocument];
    }
    else if ([self.outputOptionsString isEqualToString:@"iOS .iconset"] == YES)
    {
        [self adjustIconDocumentSize:tempXMLDocument];
    }

    xmlData = tempXMLDocument.XMLData;
    
    NSURL * baseURL = NULL;
    
    NSString * mimeType = @"image/svg+xml";

    [(self.hiddenWebView).mainFrame loadData:xmlData
            MIMEType:mimeType	
            textEncodingName:@"UTF-8" 
            baseURL:baseURL];

    [self performSelector:@selector(getNextFrameImage) withObject:NULL afterDelay:2.0f];
}

//==================================================================================
// adjustIconDocumentSize:
//==================================================================================

- (void)adjustIconDocumentSize:(NSXMLDocument *)xmlDocument
{
    NSXMLElement * rootElement = [xmlDocument rootElement];
    
    NSString * rootElementName = rootElement.name;
    
    if ([rootElementName isEqualToString:@"svg"] == YES)
    {
        NSXMLNode * widthAttributeNode = [rootElement attributeForName:@"width"];
        NSXMLNode * heightAttributeNode = [rootElement attributeForName:@"height"];
        NSXMLNode * viewBoxAttributeNode = [rootElement attributeForName:@"viewBox"];
        
        if ((widthAttributeNode != NULL) && (heightAttributeNode != NULL) && (viewBoxAttributeNode != NULL))
        {
            NSString * tempWidthString = [NSString stringWithFormat:@"%fpx", self.imageWidth];
            widthAttributeNode.stringValue = tempWidthString;
            
            NSString * tempHeightString = [NSString stringWithFormat:@"%fpx", self.imageHeight];
            heightAttributeNode.stringValue = tempHeightString;
            
            NSString * tempViewBoxString = @"0 0 512 512";
            viewBoxAttributeNode.stringValue = tempViewBoxString;

            NSString * styleString = @"overflow: hidden;";
            NSXMLNode * styleAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            styleAttributeNode.name = @"style";
            styleAttributeNode.stringValue = styleString;
            [rootElement addAttribute:styleAttributeNode];
        }
    }
}

//==================================================================================
// getNextFrameImage
//==================================================================================

- (void)getNextFrameImage
{
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

//==================================================================================
// webViewDidFinishLoad
//==================================================================================

- (void)webViewDidFinishLoad
{
    NSImage * webImage = [self imageFromWebView];

    CGImageRef cgImageRef = [webImage CGImageForProposedRect:NULL context:nil hints:nil];

    NSBitmapImageRep * cgImageRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImageRef];
    cgImageRep.size = webImage.size;
    
    NSData * imageData = NULL;

    if ([self.outputFormatString isEqualToString:@"PNG"] == YES)
    {
        NSDictionary * pngProperties = @{NSImageFallbackBackgroundColor: [NSColor clearColor]};

        imageData = [cgImageRep representationUsingType:NSPNGFileType properties:pngProperties];
    }
    else if ([self.outputFormatString isEqualToString:@"JPEG"] == YES)
    {
        NSDictionary * jpegProperties = @{NSImageFallbackBackgroundColor: [NSColor clearColor]};

        imageData = [cgImageRep representationUsingType:NSJPEGFileType properties:jpegProperties];
    }
    else if ([self.outputFormatString isEqualToString:@"TIFF"] == YES)
    {
        NSDictionary * tiffProperties = @{NSImageFallbackBackgroundColor: [NSColor clearColor]};

        imageData = [cgImageRep representationUsingType:NSTIFFFileType properties:tiffProperties];
    }
    
    NSString * outputPath = self.path;
    
    if ([self.outputOptionsString isEqualToString:@"iOS .iconset"] == YES)
    {
        outputPath = [self pathForIconset:outputPath];
    }
    else if ([self.outputOptionsString isEqualToString:@"macOS .iconset"] == YES)
    {
        outputPath = [self pathForIconset:outputPath];
    }
    
    self.macSVGDocumentWindowController.exportingImagesPathTextField.stringValue = outputPath;
    
    BOOL writeResult = [imageData writeToFile:outputPath atomically:NO];
    
    if (writeResult == NO)
    {
        NSLog(@"SVGtoImagesConverter writeToFile failed - %@", self.path);
    }

    if ([self.outputOptionsString isEqualToString:@"Current Image Only"] == YES)
    {
        [self.macSVGDocumentWindowController exportingImagesDoneAction:self];
    }
    else if ([self.outputOptionsString isEqualToString:@"Animation Images"] == YES)
    {
        self.frameCount++;
        self.currentTime += self.frameTimeInterval;

        if (self.currentTime > self.endTime)
        {
            // process is completed
            [self.macSVGDocumentWindowController exportingImagesDoneAction:self];
        }
        else
        {
            [self getNextFrameImage];
        }
    }
    else if ([self.outputOptionsString isEqualToString:@"iOS .iconset"] == YES)
    {
        self.iconsetIndex++;
        [self createOffscreenWindowForIconset];
    }
    else if ([self.outputOptionsString isEqualToString:@"macOS .iconset"] == YES)
    {
        self.iconsetIndex++;
        [self createOffscreenWindowForIconset];
    }
}

//==================================================================================
// pathForIconset:
//==================================================================================

- (NSString *)pathForIconset:(NSString *)originalPath
{
    NSString * result = originalPath;

    NSArray * originalPathComponents = originalPath.pathComponents;
    
    NSInteger originalPathComponentsCount = originalPathComponents.count;
    
    if (originalPathComponentsCount > 0)
    {
        NSString * newFileNameTemplate = (self.currentIconsetArray)[self.iconsetIndex];
        
        NSArray * templateComponents = [newFileNameTemplate componentsSeparatedByString:@" "];
        
        NSString * newFileName = templateComponents[0];
        
        NSMutableArray * newPathComponents = [originalPathComponents mutableCopy];
        
        [newPathComponents addObject:newFileName];
        
        result = [NSString pathWithComponents:newPathComponents];
    }
    
    return result;
}

//==================================================================================
// imageFromWebView
//==================================================================================

- (NSImage *)imageFromWebView
{
    NSRect imageBounds = NSMakeRect(0, 0, self.imageWidth, self.imageHeight);

    NSRect webViewBounds = self.hiddenWebView.bounds;

    NSBitmapImageRep * bitmapRep = NULL;

    if (self.includeAlpha == YES)
    {
        bitmapRep = [self.hiddenWebView bitmapImageRepForCachingDisplayInRect:webViewBounds];
        [self.hiddenWebView cacheDisplayInRect:webViewBounds toBitmapImageRep:bitmapRep];
    }
    else
    {
        [self.hiddenWebView lockFocus];
        bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:webViewBounds];
        [self.hiddenWebView unlockFocus];
    }

    bitmapRep.colorSpaceName = NSDeviceRGBColorSpace;
    
    // crop the view to document size
    NSImage * webImage = [[NSImage alloc] initWithSize:imageBounds.size];
    
    NSRect srcImageBounds = imageBounds;
    srcImageBounds.origin.y = webViewBounds.size.height - self.imageHeight;
    
    // draw to create bitmapImageRep
    [webImage lockFocus];
    [bitmapRep drawInRect:imageBounds fromRect:srcImageBounds operation:NSCompositeCopy
            fraction:1.0f respectFlipped:YES hints:NULL];
    [webImage unlockFocus];

    NSArray * destinationRepresentations = webImage.representations;
    NSBitmapImageRep * destinationBitmapImageRep = destinationRepresentations.firstObject;
    destinationBitmapImageRep.colorSpaceName = NSCalibratedRGBColorSpace;

    // redraw after color space setting
    [webImage lockFocus];
    [bitmapRep drawInRect:imageBounds fromRect:srcImageBounds operation:NSCompositeCopy
            fraction:1.0f respectFlipped:YES hints:NULL];
    [webImage unlockFocus];

    return webImage;
}


@end
