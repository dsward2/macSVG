//
//  XMLAttributesTableRowView.m
//  
//
//  Created by Douglas Ward on 12/20/17.
//
//

#import "XMLAttributesTableRowView.h"

@implementation XMLAttributesTableRowView

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
