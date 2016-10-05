//
//  CheckeredBackgroundView.m
//  macSVG
//
//  Created by Douglas Ward on 8/13/13.
//
//

#import "CheckeredBackgroundView.h"
#import "ToolSettingsPopoverViewController.h"

@implementation CheckeredBackgroundView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
    
    NSRect boundsRect = self.bounds;
    
    if (toolSettingsPopoverViewController.showCheckerboardBackground == YES)
    {
        NSInteger columnsCount = boundsRect.size.width / 10.0f;
        NSInteger rowsCount = boundsRect.size.height / 10.0f;
        
        NSColor * grayColor = [NSColor lightGrayColor];
        NSColor * whiteColor = [NSColor whiteColor];
        
        for (NSInteger columnIdx = 0; columnIdx <= columnsCount; columnIdx++)
        {
            for (NSInteger rowIdx = 0; rowIdx <= rowsCount; rowIdx++)
            {
                NSRect checkerRect = NSMakeRect(columnIdx * 10.0f, rowIdx * 10.0f, 10.0f, 10.0f);

                if ( NSIntersectsRect( dirtyRect, checkerRect ) == YES)
                {
                    NSColor * checkerColor = grayColor;
                    
                    if (columnIdx % 2 == 0)
                    {
                        // even column
                        if (rowIdx % 2 == 0)
                        {
                            // even row
                            checkerColor = grayColor;
                        }
                        else
                        {
                            // odd row
                            checkerColor = whiteColor;
                        }
                    }
                    else
                    {
                        // odd column
                        if (rowIdx % 2 == 0)
                        {
                            // even row
                            checkerColor = whiteColor;
                        }
                        else
                        {
                            // odd row
                            checkerColor = grayColor;
                        }
                    }
                    
                    [checkerColor set];
                    
                    NSRectFill(checkerRect);
                }
            }
        }
    }
    else
    {
        NSColor * backgroundColor = [NSColor whiteColor];
        [backgroundColor set];
        NSRectFill(dirtyRect);
    }
}

@end
