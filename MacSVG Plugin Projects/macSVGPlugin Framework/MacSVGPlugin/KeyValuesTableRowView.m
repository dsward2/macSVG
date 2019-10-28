//
//  KeyValuesTableRowView.m
//  MacSVGPlugin
//
//  Created by Douglas Ward on 10/27/19.
//  Copyright © 2019 ArkPhone LLC. All rights reserved.
//

#import "KeyValuesTableRowView.h"

@implementation KeyValuesTableRowView

/*
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
*/

- (void)awakeFromNib
{
    self.identifier = @"KeyValuesRowView";
}

- (NSBackgroundStyle)interiorBackgroundStyle
{
    return NSBackgroundStyleLight;
}

- (NSTableViewSelectionHighlightStyle)selectionHighlightStyle
{
    return NSTableViewSelectionHighlightStyleSourceList;
}

@end
