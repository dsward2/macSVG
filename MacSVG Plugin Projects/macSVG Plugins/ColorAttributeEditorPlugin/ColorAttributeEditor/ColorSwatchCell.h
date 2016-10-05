//
//  ColorSwatchCell.h
//  macSVG
//
//  Created by Douglas Ward on 1/6/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface ColorSwatchCell : NSCell
{
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
@property (readonly) NSSize cellSize;

@end
