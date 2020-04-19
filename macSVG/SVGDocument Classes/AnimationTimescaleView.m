//
//  AnimationTimescaleView.m
//  macSVG
//
//  Created by Douglas Ward on 12/17/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "AnimationTimescaleView.h"
#import "AnimationTimelineView.h"
#import "MacSVGDocumentWindowController.h"
#import "SVGWebKitController.h"
#import "SVGWebView.h"
#import "AnimationTimelineView.h"

@implementation AnimationTimescaleView

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.whiteColor = NULL;
    self.blackColor = NULL;
    self.grayColor = NULL;
    self.lightGrayColor = NULL;
    self.redColor = NULL;
}

//==================================================================================
//	initWithFrame:
//==================================================================================

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        playHeadImageView = NULL;
        playHeadSelectedImageView = NULL;

        self.whiteColor = [NSColor whiteColor];
        self.blackColor = [NSColor blackColor];
        self.grayColor = [NSColor grayColor];
        self.lightGrayColor = [NSColor lightGrayColor];
        self.redColor = [NSColor redColor];
    }
    
    return self;
}

//==================================================================================
//	initWithCoder:
//==================================================================================

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code here.
        playHeadImageView = NULL;
        playHeadSelectedImageView = NULL;

        self.whiteColor = [NSColor whiteColor];
        self.blackColor = [NSColor blackColor];
        self.grayColor = [NSColor grayColor];
        self.lightGrayColor = [NSColor lightGrayColor];
        self.redColor = [NSColor redColor];
    }
    
    return self;
}

//==================================================================================
//	setPlayHeadPosition:
//==================================================================================

#define playHeadYOffset 18

- (void)setPlayHeadPosition
{
    NSRect frameRect = self.frame;

    if (playHeadImageView == NULL)
    {
        NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
        NSString * imageFilePath = [thisBundle pathForResource:@"PlayHead" ofType:@"tiff"];

        NSImage * playHeadImage = [[NSImage alloc] initWithContentsOfFile:imageFilePath];
        NSRect playHeadImageViewRect = NSZeroRect;
        playHeadImageViewRect.size = playHeadImage.size;
        playHeadImageViewRect.origin.y = frameRect.size.height - playHeadYOffset;
        playHeadImageView = [[NSImageView alloc] initWithFrame:playHeadImageViewRect];
        playHeadImageView.image = playHeadImage;

        [self addSubview:playHeadImageView];
        
        [playHeadImageView setHidden:YES];
    }
    
    if (playHeadSelectedImageView == NULL)
    {
        NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
        NSString * imageFilePath = [thisBundle pathForResource:@"PlayHeadSelected-Graphite" ofType:@"tiff"];

        NSImage * playHeadSelectedImage = [[NSImage alloc] initWithContentsOfFile:imageFilePath];
        NSRect playHeadSelectedImageViewRect = NSZeroRect;
        playHeadSelectedImageViewRect.size = playHeadSelectedImage.size;
        playHeadSelectedImageViewRect.origin.y = frameRect.size.height - playHeadYOffset;
        playHeadSelectedImageView = [[NSImageView alloc] initWithFrame:playHeadSelectedImageViewRect];
        playHeadSelectedImageView.image = playHeadSelectedImage;

        [self addSubview:playHeadSelectedImageView];
        
        [playHeadSelectedImageView setHidden:NO];
    }
    
    float x = animationTimelineView.timeValue * animationTimelineView.pixelsPerSecond;

    NSRect playHeadFrameRect = playHeadImageView.frame;
    playHeadFrameRect.origin.x = x - (playHeadFrameRect.size.width / 2.0f);
    //playHeadFrameRect.origin.y = frameRect.size.height - playHeadYOffset;
    playHeadFrameRect.origin.y = playHeadYOffset;
    playHeadImageView.frame = playHeadFrameRect;

    NSRect playHeadSelectedFrameRect = playHeadSelectedImageView.frame;
    playHeadSelectedFrameRect.origin.x = x - (playHeadFrameRect.size.width / 2.0f);
    //playHeadSelectedFrameRect.origin.y = frameRect.size.height - playHeadYOffset;
    playHeadSelectedFrameRect.origin.y = playHeadYOffset;
    playHeadSelectedImageView.frame = playHeadSelectedFrameRect;
}

//==================================================================================
//	drawTimelineScale:
//==================================================================================

- (void)drawTimelineScale:(NSRect)dirtyRect
{
    // Drawing code here.
    NSRect frameRect = self.frame;
    
    [self.grayColor set];
    
    NSBezierPath* dividerPath = [NSBezierPath bezierPath];
    [dividerPath moveToPoint:NSMakePoint(0, frameRect.size.height - 2)];
    [dividerPath lineToPoint:NSMakePoint(frameRect.size.width, frameRect.size.height - 2)];
    dividerPath.lineWidth = 1;
    [dividerPath stroke];
        
    NSMutableDictionary * textAttributes = [[NSMutableDictionary alloc] init];
    textAttributes[NSForegroundColorAttributeName] = self.blackColor;
        
    float tenthInterval = animationTimelineView.pixelsPerSecond / 10.0f;
    
    int tickCounter = 0;
    
    for (int x = 0; x < frameRect.size.width; x += tenthInterval)
    {
        //float topY = frameRect.size.height - 18.0f;
        float topY = 18.0f;

        if (x > 0)
        {
            float tickWidth = 1.0f;
            float markerOffset = 0.5f;

            [self.lightGrayColor set];
                    
            if ((tickCounter % 10) == 0)
            {
                tickWidth = 2.0f;
                markerOffset = 0.0f;
                [self.grayColor set];
            }
            
            // Set the line width for a single NSBezierPath object.
            NSBezierPath* thePath = [NSBezierPath bezierPath];
            
            
            [thePath moveToPoint:NSMakePoint(x + markerOffset, topY)];
            [thePath lineToPoint:NSMakePoint(x + markerOffset, frameRect.size.height)];

            thePath.lineWidth = tickWidth;

            [thePath stroke];
        }

        if ((tickCounter % 10) == 0)
        {
            int tickSeconds = tickCounter / 10;
            
            NSString * secondsString = [[NSString alloc] initWithFormat:@"%d sec.", tickSeconds];
            
            float leftX = x + 1.0f;
            if (leftX > 5.0f)
            {
                leftX -= 5.0f;
            }
            //NSRect secondsRect = NSMakeRect(leftX, (topY + 1.0f), 64.0f, 14.0f);
            NSRect secondsRect = NSMakeRect(leftX, 2.0f, 64.0f, 14.0f);
            
            [secondsString drawInRect:secondsRect withAttributes:textAttributes];
        }
        
        tickCounter++;
    }
    
    [self setPlayHeadPosition];
}

//==================================================================================
//	isFlipped
//==================================================================================

- (BOOL) isFlipped
{
    return YES;
}

//==================================================================================
//	drawRect:
//==================================================================================

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect frameRect = self.frame;
    
    [self.whiteColor set];
    [NSBezierPath fillRect:frameRect];
    
    [self drawTimelineScale:dirtyRect];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

//==================================================================================
//	mouseDown:
//==================================================================================

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];

    NSEventModifierFlags modifiers = theEvent.modifierFlags;
    CGEventFlags flags = (NSEventModifierFlagShift | NSEventModifierFlagCommand);

    if ((modifiers & NSEventModifierFlagOption) != 0)
    {
        // option key is pressed - useful for drag-and-drop multiple items
    }
    else if ((modifiers & flags) == 0)
    {
        // shift key or command key are not pressed
    
        SVGWebView * svgWebView = macSVGDocumentWindowController.svgWebKitController.svgWebView;
        DOMDocument * domDocument = svgWebView.mainFrame.DOMDocument;
        DOMNodeList * svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
        if (svgElementsList.length > 0)
        {
            NSPoint globalLocation = theEvent.locationInWindow;
            NSPoint localLocation = [self convertPoint:globalLocation fromView:nil];
            
            float newTimeValue = localLocation.x / animationTimelineView.pixelsPerSecond;
            
            if (newTimeValue < 0.0f)
            {
                newTimeValue = 0.0f;
            }
            
            //animationTimelineView.timeValue = newTimeValue;
            
            [macSVGDocumentWindowController.animationTimelineView setPlayHeadPosition:newTimeValue];
            
            NSNumber * newTimeValueNumber = [NSNumber numberWithFloat:newTimeValue];
            DOMNode * svgElementNode = [svgElementsList item:0];
            DOMElement * svgElement = (DOMElement *)svgElementNode;
            
            NSArray * setCurrentTimeArgumentsArray = @[newTimeValueNumber];
            [svgElement callWebScriptMethod:@"setCurrentTime" withArguments:setCurrentTimeArgumentsArray];  // call JavaScript function

            [svgElement callWebScriptMethod:@"forceRedraw" withArguments:NULL];  // call JavaScript function
            
            NSString * currentTimeString = [[NSString alloc] initWithFormat:@"%.2f", newTimeValue];
            
            (macSVGDocumentWindowController.svgWebKitController.currentTimeTextField).stringValue = currentTimeString;
            
            macSVGDocumentWindowController.currentTimeString = currentTimeString;
            
            [macSVGDocumentWindowController.animationTimelineView setPlayHeadPosition:newTimeValue];
        }
    }
}

#pragma clang diagnostic pop


//==================================================================================
//	mouseDragged:
//==================================================================================

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self mouseDown:theEvent];
}


@end
