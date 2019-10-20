//
//  ColorSwatchTableCellView.m
//  ColorAttributeEditor
//
//  Created by Douglas Ward on 10/4/19.
//  Copyright © 2019 ArkPhone LLC. All rights reserved.
//

#import "ColorSwatchTableCellView.h"

@implementation ColorSwatchTableCellView


- (instancetype)init {
    if ((self = [super init])) {
        //[self setSelectable:YES];
        self.colorString = @"255,0,0";
    }
    return self;
}

//==================================================================================
//    initWithCoder:
//==================================================================================

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        //[self setSelectable:YES];
        self.colorString = @"255,0,0";
    }
    return self;
}




- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSBezierPath * rectPath = [NSBezierPath bezierPathWithRect:self.frame];
    
    NSString * colorRGB = self.colorString;

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
}

@end
