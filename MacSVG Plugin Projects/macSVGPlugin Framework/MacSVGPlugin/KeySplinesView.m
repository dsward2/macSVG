//
//  KeySplinesView.m
//  MacSVGPlugin
//
//  Created by Douglas Ward on 10/12/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "KeySplinesView.h"
#import "KeyValuesPopoverViewController.h"

@implementation KeySplinesView

// ============================================================================

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

// ============================================================================

- (instancetype)initWithCoder:(NSCoder *)decoder
{    
    self = [super initWithCoder:decoder];
    if (self) 
    {
    }
    return self;
}

// ============================================================================

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSRect boxRect = NSMakeRect(0, 0, 60, 60);
        
    NSCharacterSet * delimitersCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" ,"];
    
    NSArray * siblingViews = self.superview.subviews;
    
    NSString * keySplinesString = @"";
    
    for (NSView * aSiblingView in siblingViews)
    {
        if ([aSiblingView isKindOfClass:[NSComboBox class]] == YES)
        {
            NSComboBox * comboBox = (NSComboBox *)aSiblingView;
            keySplinesString = comboBox.stringValue;
        }
    }
    
    float controlX1 = 0;
    float controlY1 = 0;
    float controlX2 = 1;
    float controlY2 = 1;

    NSInteger keySplineIndex = 0;
    
    NSArray * keySplinesArray = [keySplinesString componentsSeparatedByCharactersInSet:delimitersCharacterSet];
    NSInteger keySplinesArrayCount = keySplinesArray.count;
    if (keySplinesArrayCount == 4)
    {
        for (NSString * keySplineValueString in keySplinesArray)
        {
            if (keySplineValueString.length > 0)
            {
                float keySplineValue = keySplineValueString.floatValue * 60;
                
                if (keySplineIndex == 0)
                {
                    controlX1 = keySplineValue;
                    keySplineIndex++;
                }
                else if (keySplineIndex == 1)
                {
                    controlY1 = keySplineValue;
                    keySplineIndex++;
                }
                else if (keySplineIndex == 2)
                {
                    controlX2 = keySplineValue;
                    keySplineIndex++;
                }
                else if (keySplineIndex == 3)
                {
                    controlY2 = keySplineValue;
                    keySplineIndex++;
                }
            }
        }
    
        NSBezierPath * rectPath = [NSBezierPath bezierPathWithRect:boxRect];
                    
        [[NSColor whiteColor] set];
        [rectPath fill];
        
        [[NSColor grayColor] set];
        [rectPath stroke];

        NSPoint startPoint = NSMakePoint(0, 0);
        NSPoint endPoint = NSMakePoint(60, 60);
        NSPoint controlPoint1 = NSMakePoint(controlX1, controlY1);
        NSPoint controlPoint2 = NSMakePoint(controlX2, controlY2);

        NSBezierPath * splinePath = [NSBezierPath bezierPath];
        
        [splinePath moveToPoint:startPoint];
        
        [splinePath curveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];

        splinePath.lineWidth = 2.0;
        
        [[NSColor blackColor] set];
        [splinePath stroke];
    }
}

@end
