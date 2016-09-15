//
//  AnimateMotionTableRowView.m
//  AnimateMotionElementEditor
//
//  Created by Douglas Ward on 9/3/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "AnimateMotionTableRowView.h"

@implementation AnimateMotionTableRowView

/*
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
*/

- (NSBackgroundStyle)interiorBackgroundStyle
{
    return NSBackgroundStyleLight;
}

- (NSTableViewSelectionHighlightStyle)selectionHighlightStyle
{
    return NSTableViewSelectionHighlightStyleSourceList;
}

@end
