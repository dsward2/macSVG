//
//  ImageElementEditor.m
//  ImageElementEditor
//
//  Created by Douglas Ward on 7/28/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "ImageElementEditor.h"
#import "MacSVGPlugin/MacSVGPluginCallbacks.h"

@implementation ImageElementEditor

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    imageWebView.downloadDelegate = NULL;
    imageWebView.frameLoadDelegate = NULL;
    imageWebView.policyDelegate = NULL;
    imageWebView.UIDelegate = NULL;
    imageWebView.resourceLoadDelegate = NULL;
    
    self.imageDictionary = NULL;
}

//==================================================================================
//	init
//==================================================================================

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        webViewUnitSquareScale = 1.0;
    }
    
    return self;
}

//==================================================================================
//	pluginName
//==================================================================================

- (void)awakeFromNib 
{
    [super awakeFromNib];

    [imageWebView setDrawsBackground:NO];
    
    NSURL * requestURL = [NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/161px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg"];
    NSString * pathExtension = [requestURL pathExtension];
    NSString * mimeType = @"image/jpeg";
    NSString * imageReferenceOptionString = @"Link to Image";
    NSImage * previewImage = [NSImage imageNamed:@"Mona_Lisa,_by_Leonardo_da_Vinci,_from_C2RMF_retouched.jpg"];
    
    NSNumber * jpegCompressionNumber = [NSNumber numberWithFloat:0.5];
    
    NSMutableDictionary * newImageDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            requestURL, @"url",
            pathExtension, @"pathExtension",
            mimeType, @"MIMEType",
            imageReferenceOptionString, @"imageReferenceOption",
            previewImage, @"previewImage",
            jpegCompressionNumber, @"jpegCompressionNumber",
            nil];
            
    self.imageDictionary = newImageDictionary;

    NSURLRequest * defaultImageRequest = [NSURLRequest requestWithURL:requestURL];
    [[imageWebView mainFrame] loadRequest:defaultImageRequest];
}


//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    return @"Image Element Editor";
}

//==================================================================================
//	loadPluginViewInScrollView:
//==================================================================================

- (BOOL)loadPluginViewInScrollView:(NSScrollView *)scrollView
{
    BOOL result = [super loadPluginViewInScrollView:scrollView];
        
    return result;
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element tag name
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    NSString * result = NULL;

    if ([elementName isEqualToString:@"image"] == YES)
    {
        result = [self pluginName];
    }

    return result;
}

//==================================================================================
//	isEditorForElement:elementName:attribute:
//==================================================================================

// return label if this editor can edit specified element and attribute
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName attribute:(NSString *)attributeName
{   
    NSString * result = NULL;
    
    return result;
}

//==================================================================================
//	editorPriority:context:
//==================================================================================

- (NSInteger)editorPriority:(NSXMLElement *)targetElement context:(NSString *)context
{
    return 30;
}

//==================================================================================
//	scalePreviewContentToFit
//==================================================================================

- (void)scalePreviewContentToFit
{
    NSRect contentRect = NSMakeRect(0, 0, 100, 100);
    float vScale = 1.0f;
    float hScale = 1.0f;

    WebFrame * mainFrame = [imageWebView mainFrame];
    WebFrameView * webFrameView = [mainFrame frameView];
    NSRect webFrameViewRect = webFrameView.frame;
    NSView * documentView = [webFrameView documentView];
    NSView * clipView = [documentView superview];

    DOMDocument * domDocument = [imageWebView mainFrameDocument];

    DOMDocumentType * docType = [domDocument doctype];
    NSString * docTypeName = [docType name];
    #pragma unused(docType)
    #pragma unused(docTypeName)

    DOMElement * documentElement = [domDocument documentElement];   // should be DOMSVGSVGElement        
    
    WebDataSource * dataSource = [mainFrame dataSource];
    NSMutableURLRequest * request = [dataSource request];
    
    NSURL * requestURL = [request URL];
    NSString * urlPath = [requestURL path];                         // e.g., file:///Users/username/Desktop/imageName.jpg
    NSString * lastPathComponent = [urlPath lastPathComponent];     // e.g., imageName.jpg
    NSString * pathExtension = [lastPathComponent pathExtension];   // e.g., jpg, png, svg, etc.
    
    NSDictionary * allHTTPHeaderFields = [request allHTTPHeaderFields];
    #pragma unused(allHTTPHeaderFields)

    BOOL isSVGfile = NO;

    if ([pathExtension isEqualToString:@"svg"]) isSVGfile = YES;
    if ([pathExtension isEqualToString:@"svgz"]) isSVGfile = YES;

    if (isSVGfile == YES)
    {
        NSString * widthAttributeString = [documentElement getAttribute:@"width"];
        NSString * heightAttributeString = [documentElement getAttribute:@"height"];
        NSString * viewBox = [documentElement getAttribute:@"viewBox"];
        
        NSInteger widthInteger = [widthAttributeString integerValue];
        NSInteger heightInteger = [heightAttributeString integerValue];
        if ((widthInteger > 0) && (heightInteger > 0))
        {
            contentRect = NSMakeRect(0, 0, widthInteger, heightInteger);
            vScale = (webFrameViewRect.size.height / contentRect.size.height);
            hScale = (webFrameViewRect.size.width / contentRect.size.width);
        }
        else
        {
            NSArray * viewBoxArray = [viewBox componentsSeparatedByString:@" "];
            if ([viewBoxArray count] == 4)
            {
                widthInteger = [[viewBoxArray objectAtIndex:2] integerValue];
                heightInteger = [[viewBoxArray objectAtIndex:3] integerValue];
                if ((widthInteger > 0) && (heightInteger > 0))
                {
                    contentRect = NSMakeRect(0, 0, widthInteger, heightInteger);
                    vScale = (webFrameViewRect.size.height / contentRect.size.height);
                    hScale = (webFrameViewRect.size.width / contentRect.size.width);
                }
            }
        }
        
    }
    else
    {
        //contentRect = documentView.frame;
        //vScale = (webFrameViewRect.size.height / contentRect.size.height);
        //hScale = (webFrameViewRect.size.width / contentRect.size.width);
        
        WebDataSource * dataSource = [mainFrame dataSource];
        
        //WebResource * webResource = [dataSource mainResource];
        //NSString * mimeType = [webResource MIMEType];       // e.g. image/jpeg
        
        
        NSData * previewOriginalData = [dataSource data];
        NSImage * previewOriginalImage = [[NSImage alloc] initWithData:previewOriginalData];

        NSSize imageSize = [previewOriginalImage size];
        
        contentRect = documentView.frame;
        vScale = (webFrameViewRect.size.height / imageSize.height);
        hScale = (webFrameViewRect.size.width / imageSize.width);
        
    }
    
    //NSLog(@"clipView before scale -");
    //NSLog(@"frame = %f, %f, %f, %f", clipView.frame.origin.x, clipView.frame.origin.y, clipView.frame.size.width, clipView.frame.size.height);
    //NSLog(@"bounds = %f, %f, %f, %f", clipView.bounds.origin.x, clipView.bounds.origin.y, clipView.bounds.size.width, clipView.bounds.size.height);
    
    float scale = vScale;
    if (hScale < vScale) scale = hScale;
    
    //[clipView scaleUnitSquareToSize:NSMakeSize((1.0f / webViewUnitSquareScale), (1.0f / webViewUnitSquareScale))];
    
    clipView.bounds = clipView.frame;
    
    [clipView scaleUnitSquareToSize:NSMakeSize(scale, scale)];
    
    [clipView setNeedsDisplay:YES];
    
    webViewUnitSquareScale = scale;

    //NSLog(@"clipView after scale -");
    //NSLog(@"frame = %f, %f, %f, %f", clipView.frame.origin.x, clipView.frame.origin.y, clipView.frame.size.width, clipView.frame.size.height);
    //NSLog(@"bounds = %f, %f, %f, %f", clipView.bounds.origin.x, clipView.bounds.origin.y, clipView.bounds.size.width, clipView.bounds.size.height);

}

//==================================================================================
//	updateDocumentImageDictionary
//==================================================================================

- (void)updateDocumentImageDictionary
{
    WebFrame * mainFrame = [imageWebView mainFrame];
    
    WebDataSource * dataSource = [mainFrame dataSource];
    NSMutableURLRequest * request = [dataSource request];
    
    NSURL * requestURL = [request URL];
    NSString * urlPath = [requestURL path];                         // e.g., file:///Users/dsward/Desktop/imageName.jpg
    NSString * lastPathComponent = [urlPath lastPathComponent];     // e.g., imageName.jpg
    NSString * pathExtension = [lastPathComponent pathExtension];   // e.g., jpg, png, svg, etc.
    
    WebResource * webResource = [dataSource mainResource];
    NSString * mimeType = [webResource MIMEType];       // e.g. image/jpeg
    
    NSCell * imageReferenceOptionButton = [imageReferenceOptionMatrix selectedCell];
    NSString * imageReferenceOptionString = [imageReferenceOptionButton title];
    
    float jpegCompressionFloat = [jpegCompressionSlider floatValue];
    NSNumber * jpegCompressionNumber = [NSNumber numberWithFloat:jpegCompressionFloat];

    if (pathExtension == NULL)
    {
        pathExtension = @"png";     // for image acquired from clipboard
        imageReferenceOptionString = @"Embed PNG";
    }
    
    NSMutableDictionary * imageDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            requestURL, @"url",
            pathExtension, @"pathExtension",
            mimeType, @"MIMEType",
            imageReferenceOptionString, @"imageReferenceOption",
            jpegCompressionNumber, @"jpegCompressionNumber",
            nil];
    
    NSData * previewImageData = [dataSource data];
    NSImage * previewImage = [[NSImage alloc] initWithData:previewImageData];
    
    if (previewImage != NULL)
    {
        [imageDictionary setObject:previewImage forKey:@"previewImage"];
        [imageDictionary setObject:previewImageData forKey:@"previewImageData"];
        
        [NSThread detachNewThreadSelector:@selector(calculateEmbedImageSize:) toTarget:self withObject:imageDictionary];
    }
    
    [self.macSVGPluginCallbacks setImageDictionary:self.imageDictionary];
    
    self.imageDictionary = imageDictionary;
    
    [imageURLTextField setStringValue:[requestURL absoluteString]];
    
}

//==================================================================================
//	calculateEmbedImageSize:
//==================================================================================

- (void)calculateEmbedImageSize:(NSDictionary *)imageDictionary
{
    [linkImageSizeTextField setStringValue:@"N/A"];
    
    NSData * previewImageData = [imageDictionary objectForKey:@"previewImageData"];
    
    if (previewImageData != NULL)
    {
        NSNumber * jpegCompressionNumber = [imageDictionary objectForKey:@"jpegCompressionNumber"];

        NSInteger previewImageDataSize = [previewImageData length] / 1024;
        NSString * previewImageDataSizeString = [NSString stringWithFormat:@"%ld K", previewImageDataSize];
        [linkImageSizeTextField setStringValue:previewImageDataSizeString];
    
        NSString * pngImageDataString = [self xmlStringForEmbeddedImageData:previewImageData outputFormat:@"png" jpegCompressionNumber:jpegCompressionNumber];

        NSInteger pngDataSize = [pngImageDataString length] / 1024;
        NSString * pngDataSizeString = [NSString stringWithFormat:@"%ld K", pngDataSize];
        [embedPNGSizeTextField setStringValue:pngDataSizeString];

        NSString * jpegImageDataString = [self xmlStringForEmbeddedImageData:previewImageData outputFormat:@"jpeg" jpegCompressionNumber:jpegCompressionNumber];

        NSInteger jpegDataSize = [jpegImageDataString length] / 1024;
        NSString * jpegDataSizeString = [NSString stringWithFormat:@"%ld K", jpegDataSize];
        [embedJPEGSizeTextField setStringValue:jpegDataSizeString];
    }
}

//==================================================================================
//	webView:didFinishLoadForFrame:
//==================================================================================

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    // an image was dragged into the preview box
    
    [self scalePreviewContentToFit];
    
    [self updateDocumentImageDictionary];
}

// ================================================================

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString *)allocEncodeBase64Data:(NSData *)inputData
{
	if ([inputData length] == 0)
		return @"";

    char *characters = malloc((([inputData length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [inputData length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [inputData length])
			buffer[bufferLength++] = ((char *)[inputData bytes])[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';	
	}
	
	return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

// ================================================================

- (NSString *)xmlStringForEmbeddedImageData:(NSData *)originalImageData outputFormat:(NSString *)outputFormat jpegCompressionNumber:(NSNumber *)jpegCompressionNumber
{
    // e.g.: <image x="39" y="422" width="450" height="305" id="photo" xlink:href="data:image/jpeg;base64,...">
    // where ... = base64 encoded image data
    
    NSImage * newImage = [[NSImage alloc] initWithData:originalImageData];

    NSSize imageSize = [newImage size];
    #pragma unused(imageSize)
    
    NSArray * imageReps = [newImage representations];

    NSBitmapImageRep * bits = [imageReps objectAtIndex:0];
    
    NSString * xmlString = @"";
    
    if ([outputFormat isEqualToString:@"png"] == YES)
    {
        NSDictionary * propertiesDictionary = [NSDictionary dictionary];
        NSData * pngImageData = [bits representationUsingType:NSPNGFileType properties:propertiesDictionary];
        
        NSString * base64String = [self allocEncodeBase64Data:pngImageData];
        
        xmlString = [NSString stringWithFormat:@"data:image/png;base64,%@", base64String];
    }
    else if ([outputFormat isEqualToString:@"jpeg"] == YES)
    {
        NSDictionary * jpegPropertiesDictionary = [NSDictionary dictionaryWithObject:jpegCompressionNumber forKey:NSImageCompressionFactor];
    
        NSData * jpegImageData = [bits representationUsingType:NSJPEGFileType properties:jpegPropertiesDictionary];
        
        NSString * base64String = [self allocEncodeBase64Data:jpegImageData];

        xmlString = [NSString stringWithFormat:@"data:image/png;base64,%@", base64String];
    }
    
    return xmlString;
}


// ================================================================

- (IBAction)getImageFromURLButtonAction:(id)sender
{
    NSString * imageUrlString = [imageURLTextField stringValue];
    
    if ([imageUrlString length] > 0)
    {
        if ([imageUrlString isEqualToString:@"about:blank"] == NO)
        {
            NSURL * imageURL = [NSURL URLWithString:imageUrlString];
            
            if (imageURL != NULL)
            {
                NSURLRequest * imageURLRequest = [NSURLRequest requestWithURL:imageURL];
                if (imageURLRequest != NULL)
                {
                    [[imageWebView mainFrame] loadRequest:imageURLRequest];
                    
                    NSString * urlScheme = [imageURL scheme];
                    
                    BOOL useURLReference = NO;
                    
                    if ([urlScheme isEqualToString:@"http"])
                    {
                        useURLReference = YES;
                    }
                    
                    if ([urlScheme isEqualToString:@"https"])
                    {
                        useURLReference = YES;
                    }
                    
                    if (useURLReference == YES)
                    {
                        [imageReferenceOptionMatrix selectCellAtRow:0 column:0];    // set Link to image option
                    }
                    else
                    {
                        [imageReferenceOptionMatrix selectCellAtRow:1 column:0];    // set PNG image embed option
                    }
                }
                else
                {
                    NSBeep();
                }
            }
            else
            {
                NSBeep();
            }
        }
        else
        {
            NSBeep();
        }
    }
    else
    {
        NSBeep();
    }
}

//==================================================================================
//	panel:shouldEnableURL:
//==================================================================================

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url
{
    BOOL result = NO;

    NSString * pathExtension = [url pathExtension];

    if ([pathExtension isEqualToString:@"jpg"] == YES)
    {
        result = YES;
    }

    if ([pathExtension isEqualToString:@"jpeg"] == YES)
    {
        result = YES;
    }

    if ([pathExtension isEqualToString:@"png"] == YES)
    {
        result = YES;
    }

    if ([pathExtension isEqualToString:@"svg"] == YES)
    {
        result = YES;
    }

    if ([pathExtension isEqualToString:@"svgz"] == YES)
    {
        result = YES;
    }

    BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDirectory];
    
    if (isDirectory == YES)
    {
        result = YES;
    }
    
    return result;
}

// ================================================================

- (IBAction)chooseFileButtonAction:(id)sender
{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    
    [panel setDelegate:(id)self];

    // This method displays the panel and returns immediately.
    // The completion handler is called when the user selects an
    // item or cancels the panel.
    
    [panel beginWithCompletionHandler:^(NSInteger result)
    {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSURL *  imageURL = [[panel URLs] objectAtIndex:0];
            
            NSString * pathExtension = [imageURL pathExtension];

            NSString * imageURLString = [imageURL absoluteString];
            
            [imageURLTextField setStringValue:imageURLString];

            NSURLRequest * imageURLRequest = [NSURLRequest requestWithURL:imageURL];
            if (imageURLRequest != NULL)
            {
                [[imageWebView mainFrame] loadRequest:imageURLRequest];
                
                if ([pathExtension isEqualToString:@"png"] == YES)
                {
                    [imageReferenceOptionMatrix selectCellAtRow:1 column:0];    // set PNG image embed option
                }
                else
                {
                    [imageReferenceOptionMatrix selectCellAtRow:2 column:0];    // set JPEG image embed option
                }
            }
            else
            {
                NSBeep();
            }
        }
    }];
}

// ================================================================

- (IBAction)getClipboardButtonAction:(id)sender
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *classArray = [NSArray arrayWithObject:[NSImage class]];
    NSDictionary *options = [NSDictionary dictionary];
 
    BOOL ok = [pasteboard canReadObjectForClasses:classArray options:options];
    if (ok)
    {
        NSArray * objectsToPaste = [pasteboard readObjectsForClasses:classArray options:options];
        NSImage * clipboardImage = [objectsToPaste objectAtIndex:0];

        NSArray * imageReps = [clipboardImage representations];

        NSBitmapImageRep * bits = [imageReps objectAtIndex:0];
        
        NSDictionary * propertiesDictionary = [NSDictionary dictionary];
        NSData * pngImageData = [bits representationUsingType:NSPNGFileType properties:propertiesDictionary];
        
        [[imageWebView mainFrame] loadData:pngImageData MIMEType:@"image/png" textEncodingName:nil baseURL:nil];

        [imageReferenceOptionMatrix selectCellAtRow:2 column:0];    // for clipboard, set JPEG image embed option
    }
}

// ================================================================

- (IBAction)updateImageSettings:(id)sender
{
    [self updateDocumentImageDictionary];
}



@end
