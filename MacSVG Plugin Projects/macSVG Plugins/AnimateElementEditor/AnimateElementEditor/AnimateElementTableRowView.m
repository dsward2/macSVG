//
//  AnimateElementTableRowView.m
//  AnimateElementEditor
//
//  Created by Douglas Ward on 9/4/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "AnimateElementTableRowView.h"

@implementation AnimateElementTableRowView

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
