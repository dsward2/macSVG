//
//  FlippedView.m
//  macSVG
//
//  Created by Douglas Ward on 12/21/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "FlippedView.h"

@implementation FlippedView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

/*
- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSColor * backgroundColor = [NSColor whiteColor];
    [backgroundColor set];
    NSRectFill(dirtyRect);
}
*/

//==================================================================================
//	isFlipped
//==================================================================================

- (BOOL) isFlipped
{
    return YES;
}


@end
