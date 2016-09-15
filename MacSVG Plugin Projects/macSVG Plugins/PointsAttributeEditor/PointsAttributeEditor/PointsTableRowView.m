//
//  PointsTableRowView.m
//  PointsAttributeEditor
//
//  Created by Douglas Ward on 9/10/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "PointsTableRowView.h"

@implementation PointsTableRowView

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
