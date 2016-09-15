//
//  BezierCircleGenerator.h
//  BezierCircleGenerator
//
//  Created by Douglas Ward on 7/12/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <MacSVGPlugin/MacSVGPlugin.h>

@class BezierCircleGeneratorWindowController;

@interface BezierCircleGenerator : MacSVGPlugin
{
    IBOutlet BezierCircleGeneratorWindowController * bezierCircleGeneratorWindowController;
}

-(void) makeBezierCircleAtCenterX:(CGFloat)x centerY:(CGFloat)y radius:(CGFloat)radius segments:(NSInteger)segments;

@end
