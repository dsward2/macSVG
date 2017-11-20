//
//  XMLOutlineRowView.m
//  macSVG
//
//  Created by Douglas Ward on 8/15/13.
//
//

#import "XMLOutlineRowView.h"

@implementation XMLOutlineRowView

- (NSBackgroundStyle)interiorBackgroundStyle
{
    return NSBackgroundStyleLight;
}


- (NSTableViewSelectionHighlightStyle)selectionHighlightStyle
{
    //return NSTableViewSelectionHighlightStyleSourceList;
    //return NSTableViewSelectionHighlightStyleRegular;
    return NSTableViewSelectionHighlightStyleNone;
}

-(void)setSelected:(BOOL)selected{

    [super setSelected:selected];
    [self setNeedsDisplay:YES];

}

- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
    // if ([[aTableView selectedRowIndexes] containsIndex:rowIndex])

    if (self.selected == YES)
    {
        [[NSColor lightGrayColor] set];
        NSRectFill(dirtyRect);;
    }
    else
    {
        [[NSColor whiteColor] set];
        NSRectFill(dirtyRect);
    }
}


@end
