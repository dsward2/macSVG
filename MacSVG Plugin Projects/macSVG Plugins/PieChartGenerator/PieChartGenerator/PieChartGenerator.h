//
//  PieChartGenerator.h
//  PieChartGenerator
//
//  Created by Douglas Ward on 10/5/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <MacSVGPlugin/MacSVGPlugin.h>

@class PieChartGeneratorWindowController;

@interface PieChartGenerator : MacSVGPlugin
{
    IBOutlet PieChartGeneratorWindowController * pieChartGeneratorWindowController;
}

- (void)createPieChartWithValues:(NSString *)pieChartValuesString
        centerX:(NSString *)centerXString centerY:(NSString *)centerYString
        radius:(NSString *)radiusString;

@end
