//
//  SVGRulerView.m
//  macSVG
//
//  Created by Douglas Ward on 9/22/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "HorizontalRulerView.h"


@implementation HorizontalRulerView

- (void)dealloc
{
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSRect frameRect = self.frame;
    
    for (int x = 0; x < frameRect.size.width; x += 10)
    {
        int markHeight = frameRect.size.height / 3.0;
        
        if ((x % 50) == 0)
        {
            markHeight = frameRect.size.height / 2.0;
        }
        
        if ((x % 100) == 0)
        {
            markHeight = frameRect.size.height;
        }
        
        // Set the line width for a single NSBezierPath object.
        NSBezierPath* thePath = [NSBezierPath bezierPath];
        
        [thePath moveToPoint:NSMakePoint(x + 0.5, 0.0)];
        [thePath lineToPoint:NSMakePoint(x + 0.5, markHeight)];

        [thePath setLineWidth:1.0];

        [thePath stroke];
    }
}


@end
