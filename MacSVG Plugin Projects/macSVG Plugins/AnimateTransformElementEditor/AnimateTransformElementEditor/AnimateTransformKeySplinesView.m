//
//  KeySplinesView.m
//  AnimateMotionElementEditor
//
//  Created by Douglas Ward on 10/12/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "AnimateTransformKeySplinesView.h"
#import "AnimateTransformKeyValuesPopoverViewController.h"

@implementation AnimateTransformKeySplinesView

// ============================================================================

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

// ============================================================================

- (id)initWithCoder:(NSCoder *)decoder
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
	
    NSRect boxRect = NSMakeRect(10, 10, 100, 100);
    
    NSBezierPath * rectPath = [NSBezierPath bezierPathWithRect:boxRect];
                
    [[NSColor whiteColor] set];
    [rectPath fill];
    
    [[NSColor grayColor] set];
    [rectPath stroke];
    
    NSArray * keyValuesArray = keyValuesPopoverViewController.keyValuesArray;
    
    NSInteger keyValuesArrayCount = [keyValuesArray count];

    NSCharacterSet * delimitersCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" ,"];
    
    for (NSInteger i = 0; i < (keyValuesArrayCount - 1); i++)
    {
        NSDictionary * currentDictionary = [keyValuesArray objectAtIndex:i];
        
        NSString * keySplinesString = [currentDictionary objectForKey:@"keySplines"];
        
        float controlX1 = 0;
        float controlY1 = 0;
        float controlX2 = 1;
        float controlY2 = 1;

        NSInteger keySplineIndex = 0;
        
        NSArray * keySplinesArray = [keySplinesString componentsSeparatedByCharactersInSet:delimitersCharacterSet];
        NSInteger keySplinesArrayCount = [keySplinesArray count];
        if (keySplinesArrayCount > 3)
        {
            
            for (NSString * keySplineValueString in keySplinesArray)
            {
                if ([keySplineValueString length] > 0)
                {
                    float keySplineValue = [keySplineValueString floatValue] * 100;
                    
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
        }
        
        if (keySplineIndex != 4)
        {
            controlX1 = 0;
            controlY1 = 0;
            controlX2 = 0;
            controlY2 = 0;
        }
        
        NSPoint startPoint = NSMakePoint(10, 10);
        NSPoint endPoint = NSMakePoint(110, 110);
        NSPoint controlPoint1 = NSMakePoint(10 + controlX1, 10 + controlY1);
        NSPoint controlPoint2 = NSMakePoint(10 + controlX2, 10 + controlY2);

        NSBezierPath * splinePath = [NSBezierPath bezierPath];
        
        [splinePath moveToPoint:startPoint];
        
        [splinePath curveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];

        [splinePath setLineWidth:3.0];
        
        [[NSColor blackColor] set];
        [splinePath stroke];
    }

}

@end
