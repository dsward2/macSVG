//
//  AnimationTimescaleView.h
//  macSVG
//
//  Created by Douglas Ward on 12/17/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AnimationTimelineView;
@class MacSVGDocumentWindowController;

@interface AnimationTimescaleView : NSView
{
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;
    IBOutlet AnimationTimelineView * animationTimelineView;  
    NSImageView * playHeadImageView;
    NSImageView * playHeadSelectedImageView;
}

@property(strong) NSColor * whiteColor;
@property(strong) NSColor * blackColor;
@property(strong) NSColor * grayColor;
@property(strong) NSColor * lightGrayColor;
@property(strong) NSColor * redColor;

- (void)setPlayHeadPosition;

@end
