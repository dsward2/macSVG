//
//  AnimationTimelineView.h
//  macSVG
//
//  Created by Douglas Ward on 12/17/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MacSVGDocumentWindowController;
@class AnimationTimescaleView;
@class SynchroScrollView;
@class TimelineLabelsTableViewDelegate;

@interface AnimationTimelineView : NSView
{
}

@property(weak) IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;
@property(weak) IBOutlet AnimationTimescaleView * animationTimescaleView; 
@property(weak) IBOutlet SynchroScrollView * timelineScrollView;
@property(weak) IBOutlet SynchroScrollView * timescaleScrollView;
@property(weak) IBOutlet SynchroScrollView * labelScrollView;
    
@property(weak) IBOutlet TimelineLabelsTableViewDelegate * timelineLabelsTableViewDelegate;    

@property(strong) NSMutableArray * timelineElementsArray;
@property(assign) float timeValue;
@property(assign) float pixelsPerSecond;
@property(assign) float timelineMaxSeconds;

@property(strong) NSColor * whiteColor;
@property(strong) NSColor * blackColor;
@property(strong) NSColor * lightGrayColor;
@property(strong) NSColor * grayColor;
@property(strong) NSColor * darkGrayColor;
@property(strong) NSColor * redColor;
@property(strong) NSColor * greenColor;
@property(strong) NSColor * blueColor;
@property(strong) NSColor * cyanColor;
@property(strong) NSColor * magentaColor;
@property(strong) NSColor * yellowColor;
@property(strong) NSColor * lightBlueColor;
@property(strong) NSColor * lightGreenColor;
@property(strong) NSColor * lighterGreenColor;
@property(strong) NSColor * lightYellowColor;

@property(strong) NSCharacterSet * separationSet;
@property(strong) NSCharacterSet * whitespaceSet;

- (void)setPlayHeadPosition:(float)newTimeValue;

- (void)reloadData;

@end
