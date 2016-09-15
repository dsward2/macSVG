//
//  PieChartGeneratorWindowController.h
//  PieChartGenerator
//
//  Created by Douglas Ward on 10/5/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PieChartGenerator;

@interface PieChartGeneratorWindowController : NSWindowController
{
    IBOutlet PieChartGenerator * pieChartGenerator;
    IBOutlet NSTextField * pieChartValuesTextField;
    IBOutlet NSTextField * centerXTextField;
    IBOutlet NSTextField * centerYTextField;
    IBOutlet NSTextField * radiusTextField;
}

- (IBAction)generatePieChartButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;

@end
