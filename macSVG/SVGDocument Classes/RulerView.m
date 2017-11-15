//
//  RulerView.m
//  macSVG
//
//  Created by Douglas Ward on 11/12/17.
//  Copyright © 2017 ArkPhone, LLC. All rights reserved.
//

#import "RulerView.h"
#import "SVGWebView.h"

#define kRulerMarkerMaxSize 20

@implementation RulerView


- (void)dealloc
{
    self.rulerWebView.downloadDelegate = NULL;
    self.rulerWebView.frameLoadDelegate = NULL;
    self.rulerWebView.policyDelegate = NULL;
    self.rulerWebView.UIDelegate = NULL;
    self.rulerWebView.resourceLoadDelegate = NULL;

    self.rulerWebView = NULL;
}


- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.

        self.rulerUnit = @"px";

        self.minorMarkInterval = 10;
        self.minorMarkOffset = kRulerMarkerMaxSize * 0.5f;
        self.minorMarkLength = kRulerMarkerMaxSize * 0.5f;
        self.minorMarkWidth = 0.5f;

        self.midMarkInterval = self.minorMarkInterval * 5;
        self.midMarkOffset = kRulerMarkerMaxSize * 0.25f;
        self.midMarkLength = kRulerMarkerMaxSize * 0.75f;
        self.midMarkWidth = 1.0f;

        self.majorMarkInterval = self.minorMarkInterval * 10;
        self.majorMarkOffset = 0.0f;
        self.majorMarkLength = kRulerMarkerMaxSize;
        self.majorMarkWidth = 1.0f;

        self.fontSize = 10.0f;
    }
    
    return self;
}



- (void)awakeFromNib
{
    [super awakeFromNib];

    [self createRulerWebView];
}



- (void)createRulerWebView
{
    if (self.rulerWebView.isLoading == NO)
    {
        self.rulerWebView.drawsBackground = NO;
        WebPreferences * rulerWebPreferences = self.rulerWebView.preferences;
        [rulerWebPreferences setJavaScriptEnabled:NO];
        [rulerWebPreferences setPlugInsEnabled:NO];

        NSScrollView * webScrollView = [[[[self.svgWebView mainFrame] frameView] documentView] enclosingScrollView];
        NSRect documentVisibleRect = webScrollView.documentVisibleRect;
        CGFloat zoomFactor = self.svgWebView.zoomFactor;
        if (zoomFactor == 0.0f)
        {
            zoomFactor = 1.0f;
        }
        CGFloat viewScale = 1.0f / zoomFactor;

        NSRect scaledDocumentVisibleRect = NSMakeRect(documentVisibleRect.origin.x * viewScale, documentVisibleRect.origin.y * viewScale,
                documentVisibleRect.size.width * viewScale, documentVisibleRect.size.height * viewScale);
        
        NSString * svgRulerString = [self svgRulerString];
        
        NSData * xmlData = [svgRulerString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError * xmlError;
        NSXMLDocument * tempXMLDocument = [[NSXMLDocument alloc] initWithData:xmlData options:NSXMLNodePreserveCDATA error:&xmlError];
        
        [self addRulerMarksInXMLDocument:tempXMLDocument visibleRect:scaledDocumentVisibleRect];
        
        xmlData = tempXMLDocument.XMLData;
        
        NSURL * baseURL = NULL;
        
        NSString * mimeType = @"image/svg+xml";

        [(self.rulerWebView).mainFrame loadData:xmlData
                MIMEType:mimeType	
                textEncodingName:@"UTF-8" 
                baseURL:baseURL];
    }
}


- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame 
{
    //[self.rulerWebView setNeedsDisplay:YES];
}


- (BOOL)isHorizontal
{
    return NO;
}



- (NSString *)svgRulerString
{
    NSString * svgRulerString =
@"<?xml version=\"1.0\" encoding=\"utf-8\"?> \n\
<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\"> \n\
<svg xmlns=\"http://www.w3.org/2000/svg\" \n\
xmlns:xlink=\"http://www.w3.org/1999/xlink\" \n\
version=\"1.1\" baseProfile=\"full\" width=\"64px\" \n\
height=\"64px\" viewBox=\"0 0 64 64\" preserveAspectRatio=\"xMinYMin meet\" style=\"overflow: hidden;\" > \n\
</svg>";


    return svgRulerString;
}




- (void)element:(NSXMLElement *)element setAttribute:(NSString *)attributeName value:(NSString *)value
{
    NSXMLNode * attributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    attributeNode.name = attributeName;
    attributeNode.stringValue = value;
    
    [element addAttribute:attributeNode];
}




- (void)addRulerMarksInXMLDocument:(NSXMLDocument *)xmlDocument visibleRect:(NSRect)visibleRect
{
    NSXMLElement * svgElement = xmlDocument.rootElement;
    
    CGFloat widthFloat = self.bounds.size.width;
    NSString * widthString = [NSString stringWithFormat:@"%fpx", widthFloat];
    [self element:svgElement setAttribute:@"width" value:widthString];
    
    CGFloat heightFloat = self.bounds.size.height;
    NSString * heightString = [NSString stringWithFormat:@"%fpx", heightFloat];
    [self element:svgElement setAttribute:@"height" value:heightString];
    
    NSString * viewBoxString = [NSString stringWithFormat:@"%f %f %f %f",
            self.bounds.origin.x, self.bounds.origin.y,
            self.bounds.size.width, self.bounds.size.height];
    [self element:svgElement setAttribute:@"viewBox" value:viewBoxString];
    
    NSXMLElement * rulerGroupElement = [[NSXMLElement alloc] initWithName:@"g"];

    NSInteger startMarker = visibleRect.origin.x;
    NSInteger endMarker = visibleRect.origin.x + visibleRect.size.width + 1;
    if ([self isHorizontal] == NO)
    {
        startMarker = visibleRect.origin.y;
        endMarker = visibleRect.origin.y + visibleRect.size.height + 1;
    }
    
    //NSLog(@"visibleRect=%@", NSStringFromRect(visibleRect));
    //NSLog(@"startMarker = %ld, endMarker = %ld", startMarker, endMarker);
    
    for (NSInteger i = startMarker; i < endMarker; i++)
    {
        // For horizontal scrollbar, i is the x coordinate.  For vertical scrollbar, i is the y coordinate
        
        BOOL drawMark = NO;
        CGFloat markOffset = self.minorMarkOffset;
        CGFloat markLength = 0;
        CGFloat markWidth = 0;
        
        if ((i % self.majorMarkInterval) == 0)
        {
            drawMark = YES;
            markOffset = self.majorMarkOffset;
            markLength = self.majorMarkLength;
            markWidth = self.majorMarkWidth;
        }
        else if ((i % self.midMarkInterval) == 0)
        {
            drawMark = YES;
            markOffset = self.midMarkOffset;
            markLength = self.midMarkLength;
            markWidth = self.midMarkWidth;
        }
        else if ((i % self.minorMarkInterval) == 0)
        {
            drawMark = YES;
            markOffset = self.minorMarkOffset;
            markLength = self.minorMarkLength;
            markWidth = self.minorMarkWidth;
        }

        if (drawMark == YES)
        {
            CGFloat iTransformed = i;
            
            CGFloat scaleFactor = self.svgWebView.zoomFactor;
            if (scaleFactor == 0.0f)
            {
                scaleFactor = 1.0f;
            }
            
            if ([self isHorizontal] == YES)
            {
                iTransformed = (i - visibleRect.origin.x) * scaleFactor;
            }
            else
            {
                iTransformed = (i - visibleRect.origin.y) * scaleFactor;
            }
            
            NSXMLElement * rulerMarkElement = [[NSXMLElement alloc] initWithName:@"line"];
            
            [self element:rulerMarkElement setAttribute:@"stroke" value:@"black"];
            [self element:rulerMarkElement setAttribute:@"stroke-width" value:@"1px"];
            
            if ([self isHorizontal] == YES)
            {
                NSString * xString = [NSString stringWithFormat:@"%f%@", iTransformed, self.rulerUnit];
                
                NSString * beginString = [NSString stringWithFormat:@"%fpx", markOffset];
                NSString * endString = [NSString stringWithFormat:@"%fpx", markOffset + markLength];
            
                [self element:rulerMarkElement setAttribute:@"x1" value:xString];
                [self element:rulerMarkElement setAttribute:@"y1" value:beginString];
                [self element:rulerMarkElement setAttribute:@"x2" value:xString];
                [self element:rulerMarkElement setAttribute:@"y2" value:endString];
                
                if ((i % self.majorMarkInterval) == 0)
                {
                    NSString * fontSizeString = [NSString stringWithFormat:@"%f", self.fontSize];
                    NSString * fontBaselineString = [NSString stringWithFormat:@"%f", self.fontSize - 3];

                    NSXMLElement * rulerTextElement = [[NSXMLElement alloc] initWithName:@"text"];
                    
                    [self element:rulerTextElement setAttribute:@"x" value:xString];
                    [self element:rulerTextElement setAttribute:@"y" value:fontBaselineString];
                    [self element:rulerTextElement setAttribute:@"font-size" value:fontSizeString];
                    [self element:rulerTextElement setAttribute:@"alignment" value:@"left"];
                    
                    NSXMLNode * textNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind];
                    textNode.stringValue = [NSString stringWithFormat:@" %ld", i];  // first character is non-breaking space
                    
                    [rulerTextElement addChild:textNode];
                    
                    [rulerGroupElement addChild:rulerTextElement];
                }
            }
            else
            {
                NSString * yString = [NSString stringWithFormat:@"%f%@", iTransformed, self.rulerUnit];

                NSString * beginString = [NSString stringWithFormat:@"%fpx", markOffset];
                NSString * endString = [NSString stringWithFormat:@"%fpx", markOffset + markLength];
            
                [self element:rulerMarkElement setAttribute:@"x1" value:beginString];
                [self element:rulerMarkElement setAttribute:@"y1" value:yString];
                [self element:rulerMarkElement setAttribute:@"x2" value:endString];
                [self element:rulerMarkElement setAttribute:@"y2" value:yString];
                
                if ((i % self.majorMarkInterval) == 0)
                {
                    NSString * fontSizeString = [NSString stringWithFormat:@"%f", self.fontSize];
                    NSString * fontBaselineString = [NSString stringWithFormat:@"%f", self.fontSize - 3];

                    NSXMLElement * rulerTextElement = [[NSXMLElement alloc] initWithName:@"text"];
                    
                    [self element:rulerTextElement setAttribute:@"x" value:fontBaselineString];
                    [self element:rulerTextElement setAttribute:@"y" value:yString];
                    [self element:rulerTextElement setAttribute:@"font-size" value:fontSizeString];
                    [self element:rulerTextElement setAttribute:@"text-anchor" value:@"end"];
                    
                    NSString * rotateString = [NSString stringWithFormat:@"rotate(270 %@ %f)", fontBaselineString, iTransformed];
                    [self element:rulerTextElement setAttribute:@"transform" value:rotateString];
                    
                    NSXMLNode * textNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind];
                    textNode.stringValue = [NSString stringWithFormat:@"%ld ", i];  // last character is non-breaking space
                    
                    [rulerTextElement addChild:textNode];
                    
                    [rulerGroupElement addChild:rulerTextElement];
                }
            }
            
            [rulerGroupElement addChild:rulerMarkElement];
        }
    }

    [svgElement addChild:rulerGroupElement];
}





/*
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
*/

@end
