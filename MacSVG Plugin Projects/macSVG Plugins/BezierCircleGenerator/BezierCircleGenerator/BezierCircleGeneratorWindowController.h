//
//  BezierCircleGeneratorWindowController.h
//  BezierCircleGenerator
//
//  Created by Douglas Ward on 7/12/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BezierCircleGenerator;

@interface BezierCircleGeneratorWindowController : NSWindowController
{
    IBOutlet BezierCircleGenerator * bezierCircleGenerator;
    IBOutlet NSTextField * centerXTextField;
    IBOutlet NSTextField * centerYTextField;
    IBOutlet NSTextField * radiusTextField;
    IBOutlet NSTextField * segmentsTextField;
}

- (IBAction)generateBezierCircleButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;

@end
