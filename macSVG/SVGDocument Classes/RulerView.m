//
//  RulerView.m
//  macSVG
//
//  Created by Douglas Ward on 11/12/17.
//  Copyright © 2017 ArkPhone, LLC. All rights reserved.
//

#import "RulerView.h"
#import "SVGWebView.h"

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

        self.majorMarkInterval = 100;   // should be a multiple of minorMarkInterval
        self.majorMarkOffset = 0.0f;
        self.majorMarkLength = 20.0f;
        self.majorMarkWidth = 1.0f;

        self.minorMarkInterval = 10;
        self.minorMarkOffset = 10.0f;
        self.minorMarkLength = 10.0f;
        self.minorMarkWidth = 0.5f;

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
    self.rulerWebView.drawsBackground = NO;
    WebPreferences * rulerWebPreferences = self.rulerWebView.preferences;
    [rulerWebPreferences setJavaScriptEnabled:NO];
    [rulerWebPreferences setPlugInsEnabled:NO];
    
    NSString * svgRulerString = [self svgRulerString];
    
    NSData * xmlData = [svgRulerString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError * xmlError;
    NSXMLDocument * tempXMLDocument = [[NSXMLDocument alloc] initWithData:xmlData options:NSXMLNodePreserveCDATA error:&xmlError];
    
    [self addRulerMarksInXMLDocument:tempXMLDocument];
    
    xmlData = tempXMLDocument.XMLData;
    
    NSURL * baseURL = NULL;
    
    NSString * mimeType = @"image/svg+xml";

    [(self.rulerWebView).mainFrame loadData:xmlData
            MIMEType:mimeType	
            textEncodingName:@"UTF-8" 
            baseURL:baseURL];
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




- (void)addRulerMarksInXMLDocument:(NSXMLDocument *)xmlDocument
{
    NSXMLElement * svgElement = xmlDocument.rootElement;
    
    CGFloat widthFloat = self.bounds.size.width;
    if ([self isHorizontal] == YES)
    {
        widthFloat = 2000.0f;
    }
    NSString * widthString = [NSString stringWithFormat:@"%fpx", widthFloat];
    [self element:svgElement setAttribute:@"width" value:widthString];
    
    CGFloat heightFloat = self.bounds.size.height;
    if ([self isHorizontal] == NO)
    {
        heightFloat = 2000;
    }
    NSString * heightString = [NSString stringWithFormat:@"%fpx", heightFloat];
    [self element:svgElement setAttribute:@"height" value:heightString];
    
    NSString * viewBoxString = [NSString stringWithFormat:@"0 0 %f %f", widthFloat, heightFloat];
    [self element:svgElement setAttribute:@"viewBox" value:viewBoxString];
    
    NSXMLElement * rulerGroupElement = [[NSXMLElement alloc] initWithName:@"g"];
    
    for (NSInteger i = 0; i < 2000; i += self.minorMarkInterval)
    {
        CGFloat markOffset = self.minorMarkOffset;
        CGFloat markLength = self.minorMarkLength;
        CGFloat markWidth = self.minorMarkWidth;
        
        if ((i % self.majorMarkInterval) == 0)
        {
            markOffset = self.majorMarkOffset;
            markLength = self.majorMarkLength;
            markWidth = self.majorMarkWidth;
        }
        
        NSXMLElement * rulerMarkElement = [[NSXMLElement alloc] initWithName:@"line"];
        
        [self element:rulerMarkElement setAttribute:@"stroke" value:@"black"];
        [self element:rulerMarkElement setAttribute:@"stroke-width" value:@"1px"];
        
        NSInteger iScaled = i;
        if ((self.svgWebView.zoomFactor != 0.0f) && (self.svgWebView.zoomFactor != 1.0f))
        {
            iScaled = i * self.svgWebView.zoomFactor;
        }
        
        if ([self isHorizontal] == YES)
        {
            //NSString * xString = [NSString stringWithFormat:@"%ld%@", i, self.rulerUnit];
            NSString * xString = [NSString stringWithFormat:@"%ld%@", iScaled, self.rulerUnit];
            
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
            //NSString * yString = [NSString stringWithFormat:@"%ld%@", i, self.rulerUnit];
            NSString * yString = [NSString stringWithFormat:@"%ld%@", iScaled, self.rulerUnit];

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
                
                NSString * rotateString = [NSString stringWithFormat:@"rotate(270 %@ %ld)", fontBaselineString, iScaled];
                [self element:rulerTextElement setAttribute:@"transform" value:rotateString];
                
                NSXMLNode * textNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind];
                textNode.stringValue = [NSString stringWithFormat:@"%ld ", i];  // last character is non-breaking space
                
                [rulerTextElement addChild:textNode];
                
                [rulerGroupElement addChild:rulerTextElement];
            }
        }
        
        [rulerGroupElement addChild:rulerMarkElement];
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
