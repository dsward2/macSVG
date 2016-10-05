//
//  AnimationTimelineElement.h
//  macSVG
//
//  Created by Douglas Ward on 12/18/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define timelineItemHeight 24

@interface AnimationTimelineElement : NSObject
{
}

@property(strong) NSString * tagName;
@property(strong) NSString * macsvgid;
@property(strong) NSString * elementID;
    
@property(strong) NSString * parentTagName;
@property(strong) NSString * parentMacsvgid;
@property(strong) NSString * parentID;
    
@property(strong) NSString * elementDescription;

@property(strong) NSMutableArray * animationTimespanArray;

@property(assign) int repeatCount;

-(void) addTimespanAtBegin:(float)beginSeconds dur:(float)durationSeconds colorIndex:(int)colorIndex
        pixelPerSecond:(float)pixelsPerSecond frameRect:(NSRect)frameRect rowIndex:(NSUInteger)rowIndex;
        
@property (readonly) float earliestBeginSeconds;

@end
