//
//  AnimationTimelineElement.m
//  macSVG
//
//  Created by Douglas Ward on 12/18/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "AnimationTimelineElement.h"
#import "AnimationTimelineView.h"
#import "AnimationTimespan.h"

@implementation AnimationTimelineElement

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.tagName = NULL;
    self.macsvgid = NULL;
    self.elementID = NULL;
    self.parentTagName = NULL;
    self.parentMacsvgid = NULL;
    self.parentID = NULL;

    self.elementDescription = NULL;
    
    self.animationTimespanArray = NULL;
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
        self.tagName = @"";
        self.macsvgid = @"";
        self.elementID = @"";
        self.parentTagName = @"";
        self.parentMacsvgid = @"";
        self.parentID = @"";
        
        self.elementDescription = @"";
        
        self.repeatCount = 0;

        self.animationTimespanArray = [[NSMutableArray alloc] init];
    }
    return self;
}

//==================================================================================
//	addTimespanAtBegin:dur:colorIndex:
//==================================================================================

-(void) addTimespanAtBegin:(float)beginSeconds dur:(float)durationSeconds colorIndex:(int)colorIndex
        pixelPerSecond:(float)pixelsPerSecond frameRect:(NSRect)frameRect rowIndex:(NSUInteger)rowIndex
{
    AnimationTimespan * animationTimespan = [[AnimationTimespan alloc] init];
    animationTimespan.beginSeconds = beginSeconds;
    animationTimespan.durationSeconds = durationSeconds;
    
    float width = durationSeconds * pixelsPerSecond;
    float height = timelineItemHeight;

    float x = beginSeconds * pixelsPerSecond;
    float y = rowIndex * timelineItemHeight;

    NSRect timelineRect = NSMakeRect(x, y, width, height);
    
    animationTimespan.timelineRect = timelineRect;
    animationTimespan.colorIndex = colorIndex;
    
    [self.animationTimespanArray addObject:animationTimespan];
}

//==================================================================================
//	earliestBeginSeconds
//==================================================================================

-(float) earliestBeginSeconds
{
    float result = FLT_MAX;
    
    for (AnimationTimespan * animationTimespan in self.animationTimespanArray)
    {
        if (animationTimespan.beginSeconds < result)
        {
            result = animationTimespan.beginSeconds;
        }
    }
    return result;
}



@end
