//
//  VerticalRulerView.m
//  macSVG
//
//  Created by Douglas Ward on 9/22/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "VerticalRulerView.h"


@implementation VerticalRulerView

- (void)dealloc
{
}



- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}



- (BOOL)isHorizontal
{
    return NO;
}


/*
- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSRect frameRect = self.frame;
    
    int frameTop = (int)frameRect.size.height - 1;
    
    for (int y = frameTop; y >= 0; y -= 10)
    {
        int markHeight = frameRect.size.width / 3.0;
        
        int yDiff = frameTop - y;
        if ((yDiff % 50) == 0)
        {
            markHeight = frameRect.size.width / 2.0;
        }
        
        if ((yDiff % 100) == 0)
        {
            markHeight = frameRect.size.width;
        }
        
        // Set the line width for a single NSBezierPath object.
        NSBezierPath* thePath = [NSBezierPath bezierPath];
        
        [thePath moveToPoint:NSMakePoint(frameRect.size.width, y + 0.5)];
        [thePath lineToPoint:NSMakePoint(frameRect.size.width - markHeight, y + 0.5)];

        thePath.lineWidth = 1.0;

        [thePath stroke];
    }
}
*/


@end
