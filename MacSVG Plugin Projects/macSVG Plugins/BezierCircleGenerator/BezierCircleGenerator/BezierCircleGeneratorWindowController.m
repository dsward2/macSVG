//
//  BezierCircleGeneratorWindowController.m
//  BezierCircleGenerator
//
//  Created by Douglas Ward on 7/12/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "BezierCircleGeneratorWindowController.h"
#import "BezierCircleGenerator.h"

@interface BezierCircleGeneratorWindowController ()

@end

@implementation BezierCircleGeneratorWindowController

- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (IBAction)generateBezierCircleButtonAction:(id)sender
{
    NSString * centerXString = centerXTextField.stringValue;
    NSString * centerYString = centerYTextField.stringValue;
    NSString * radiusString = radiusTextField.stringValue;
    NSString * segmentsString = segmentsTextField.stringValue;
    
    CGFloat centerX = centerXString.floatValue;
    CGFloat centerY = centerYString.floatValue;
    CGFloat radius = radiusString.floatValue;
    CGFloat segments = segmentsString.floatValue;
    
    [[NSApplication sharedApplication] stopModalWithCode:NSModalResponseOK];
    
    [self.window close];

    [bezierCircleGenerator makeBezierCircleAtCenterX:centerX centerY:centerY radius:radius segments:segments];
}


- (IBAction)cancelButtonAction:(id)sender
{
    [[NSApplication sharedApplication] stopModalWithCode:NSModalResponseCancel];
    
    [self.window close];
}

@end
