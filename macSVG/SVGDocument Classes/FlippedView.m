//
//  FlippedView.m
//  macSVG
//
//  Created by Douglas Ward on 12/21/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "FlippedView.h"

@implementation FlippedView

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
}

//==================================================================================
//	isFlipped
//==================================================================================

- (BOOL) isFlipped
{
    return YES;
}


@end
