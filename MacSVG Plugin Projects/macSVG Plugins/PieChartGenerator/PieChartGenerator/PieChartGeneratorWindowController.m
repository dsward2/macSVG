//
//  PieChartGeneratorWindowController.m
//  PieChartGenerator
//
//  Created by Douglas Ward on 10/5/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "PieChartGeneratorWindowController.h"
#import "PieChartGenerator.h"

@interface PieChartGeneratorWindowController ()

@end

@implementation PieChartGeneratorWindowController

- (id)initWithWindow:(NSWindow *)window
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

- (IBAction)generatePieChartButtonAction:(id)sender
{
    NSString * pieChartValuesString = [pieChartValuesTextField stringValue];
    NSString * centerXString = [centerXTextField stringValue];
    NSString * centerYString = [centerYTextField stringValue];
    NSString * radiusString = [radiusTextField stringValue];

    [[NSApplication sharedApplication] stopModalWithCode:NSModalResponseOK];
    
    [self.window close];
    
    [pieChartGenerator createPieChartWithValues:pieChartValuesString
            centerX:centerXString centerY:centerYString radius:radiusString];
}


- (IBAction)cancelButtonAction:(id)sender
{
    [[NSApplication sharedApplication] stopModalWithCode:NSModalResponseCancel];
    
    [self.window close];
}

@end
