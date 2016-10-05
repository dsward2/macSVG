//
//  ColorSwatchCell.m
//  macSVG
//
//  Created by Douglas Ward on 1/6/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "ColorSwatchCell.h"

@implementation ColorSwatchCell

- (instancetype)init {
    if ((self = [super init])) {
        [self setSelectable:YES];
    }
    return self;
}

//==================================================================================
//	initWithCoder:
//==================================================================================

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setSelectable:YES];
    }
    return self;
}




- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView 
{
    NSBezierPath * rectPath = [NSBezierPath bezierPathWithRect:cellFrame]; 
    
    NSString * colorRGB = self.stringValue;

    NSArray * channelsArray = [colorRGB componentsSeparatedByString:@","];
    NSString * redString = channelsArray[0];
    NSString * greenString = channelsArray[1];
    NSString * blueString = channelsArray[2];
    
    int redInt = redString.intValue;
    int greenInt = greenString.intValue;
    int blueInt = blueString.intValue;
    
    float redFloat = ((float)redInt / 255.0f);
    float greenFloat = ((float)greenInt / 255.0f);
    float blueFloat = ((float)blueInt / 255.0f);

    NSColor * aColor = [NSColor colorWithCalibratedRed:redFloat green:greenFloat blue:blueFloat alpha:1.0];
    [aColor set];
    [rectPath fill];
    
    //[super drawWithFrame:cellFrame inView:controlView];
}

- (NSSize)cellSize {
    NSSize cellSize = super.cellSize;
    return cellSize;
}

@end
