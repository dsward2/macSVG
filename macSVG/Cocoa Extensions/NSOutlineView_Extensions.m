//
//  NSOutlineView_Extensions.m
//  macSVG
//
//  Adapted by Douglas Ward on 1/18/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

/*
     File: NSOutlineView_Extensions.m
 Abstract: Extensions to outline view to enable drag and drop.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 */

#import "MacSVGAppDelegate.h"
#import "NSOutlineView_Extensions.h"
#import "XMLOutlineController.h"
#import "DOMMouseEventsController.h"
#import "SVGXMLDOMSelectionManager.h"
#import "SVGWebKitController.h"
#import "MacSVGDocumentWindowController.h"

@implementation NSOutlineView(MyExtensions)



- (NSArray *)selectedItems 
{
    // returns a flat array of selected items
    NSMutableArray *items = [NSMutableArray array];
    NSIndexSet * selectedRows = self.selectedRowIndexes;
    if (selectedRows != nil) 
    {
        /*
        for (NSInteger row = [selectedRows firstIndex]; row != NSNotFound; row = [selectedRows indexGreaterThanIndex:row])
        {
            //id aItem = [self itemAtRow:row];
        
            NSXMLNode * aItemNode = [self itemAtRow:row];
        
            if ([aItemNode kind] == NSXMLElementKind)
            {
                [items addObject:aItemNode];
            }
        }
        */

        [selectedRows enumerateIndexesUsingBlock:^(NSUInteger i, BOOL *stop) {
            NSXMLNode * aItemNode = [self itemAtRow:i];
        
            if (aItemNode.kind == NSXMLElementKind)
            {
                [items addObject:aItemNode];
            }
        }];

    }
    return items;
}




- (void)setSelectedItems:(NSArray *)items 
{
    // If we are extending the selection, we start with the existing selection; otherwise, we create a new blank set of the indexes.
    NSMutableIndexSet *newSelection = [[NSMutableIndexSet alloc] init];
    
    for (NSInteger i = 0; i < items.count; i++) 
    {
        NSInteger row = [self rowForItem:items[i]];
        if (row >= 0) 
        {
            [newSelection addIndex:row];
        }
    }
    
    [self selectRowIndexes:newSelection byExtendingSelection:NO];
}

@end



@implementation XMLOutlineView

/* This NSOutlineView subclass is necessary only if you want to delete items by dragging them to the trash.  In order to support drags to the trash, you need to implement draggedImage:endedAt:operation: and handle the NSDragOperationDelete operation.  For any other operation, pass the message to the superclass 
*/

/*
- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation 
{
    if (operation == NSDragOperationDelete)
    {
        // Tell all of the dragged nodes to remove themselves from the model.
        NSArray * selection = [(XMLOutlineController *)[self dataSource] draggedNodes];
        for (NSTreeNode * node in selection) 
        {
            [[[node parentNode] mutableChildNodes] removeObject:node];
        }
        [self reloadData];
        [self deselectAll:nil];
    } 
    else 
    {
        [super draggedImage:image endedAt:screenPoint operation:operation];
    }
 
    [super draggedImage:image endedAt:screenPoint operation:operation];
}
*/


- (BOOL)becomeFirstResponder
{
    //NSLog(@"NSOutlineView_Extensions becomeFirstResponder");
    return [super becomeFirstResponder];
}


- (BOOL)resignFirstResponder
{
    //NSLog(@"NSOutlineView_Extensions resignFirstResponder");
    BOOL result = [super resignFirstResponder];
    return result;
}

- (BOOL)canResignFirstResponder
{
    //NSLog(@"NSOutlineView_Extensions canResignFirstResponder");
    //BOOL result = [super canResignFirstResponder];
    BOOL result = YES;
    return result;
}

- (void)reloadData
{
    //NSLog(@"NSOutlineView_Extensions reloadData");
    [super reloadData];
}

- (void)reloadItem:(id)item
{
    //NSLog(@"NSOutlineView_Extensions reloadItem:%@", item);
    [super reloadItem:item];
}

- (void)reloadItem:(id)item reloadChildren:(BOOL)reloadChildren
{
    //NSLog(@"NSOutlineView_Extensions reloadItem:%@ reloadChildren:%hhd", item, reloadChildren);
    [super reloadItem:item reloadChildren:reloadChildren];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    //NSLog(@"NSOutlineView_Extensions draggingEntered:%@", sender);

    XMLOutlineController * xmlOutlineController = (XMLOutlineController *)self.delegate;

    xmlOutlineController.draggingActive = YES;
    
    return NSDragOperationEvery;
}


- (void)concludeDragOperation:(id<NSDraggingInfo>)sender
{
    //NSLog(@"NSOutlineView_Extensions concludeDragOperation:%@", sender);

    XMLOutlineController * xmlOutlineController = (XMLOutlineController *)self.delegate;

    xmlOutlineController.draggingActive = NO;
}



- (void)mouseDown:(NSEvent *)theEvent
{
    NSEventModifierFlags modifiers = theEvent.modifierFlags;
    CGEventFlags flags = (NSShiftKeyMask | NSCommandKeyMask);

    if ((modifiers & NSAlternateKeyMask) != 0)
    {
        // option key is pressed - useful for drag-and-drop multiple items
        [super mouseDown:theEvent];
    }
    else if ((modifiers & flags) == 0)
    {
        // shift key or command key are not pressed
        
        BOOL doDeselectAll = YES;

        XMLOutlineController * xmlOutlineController = (XMLOutlineController *)self.delegate;
        MacSVGDocumentWindowController * macSVGDocumentWindowController = xmlOutlineController.macSVGDocumentWindowController;
        
        xmlOutlineController.holdSelectedItems = NULL;

        if (macSVGDocumentWindowController.currentToolMode == toolModeCrosshairCursor)
        {
            NSPoint globalLocation = theEvent.locationInWindow;
            NSPoint localLocation = [self convertPoint:globalLocation fromView:nil];
            NSInteger clickedRow = [self rowAtPoint:localLocation];
        
            NSXMLNode * aRowItem = [self itemAtRow:clickedRow];
            
            if (aRowItem.kind == NSXMLElementKind)
            {
                NSXMLElement * aElement = (NSXMLElement *)aRowItem;
                
                NSString * elementName = aElement.name;
                if ([elementName isEqualToString:@"path"])
                {
                    doDeselectAll = NO;
                }
            }
        }

        if (macSVGDocumentWindowController.currentToolMode == toolModeText)
        {
            doDeselectAll = NO;
        }

        if (macSVGDocumentWindowController.currentToolMode == toolModeImage)
        {
            doDeselectAll = NO;
        }

        if (doDeselectAll == YES)
        {
            // workaround for NSXMLOutlineView problem when click-selecting on a child item in an active selection path
            // in XMLOutlineController, outlineView:writeItems:toPasteboard: may reselect the items
            
            xmlOutlineController.holdSelectedItems = [self selectedItems];  // these items should be reselected if dragging occurs
        
            [self deselectAll:self];
        }

        [super mouseDown:theEvent];
    }
    else
    {
        // shift key and/or command key are pressed
        NSPoint globalLocation = theEvent.locationInWindow;
        NSPoint localLocation = [self convertPoint:globalLocation fromView:nil];
        NSInteger clickedRow = [self rowAtPoint:localLocation];
    
        NSIndexSet * selectedRowIndexes = self.selectedRowIndexes;
        
        if ([selectedRowIndexes containsIndex:clickedRow] == YES)
        {
            //[self deselectRow:clickedRow];
            
            id aRowItem = [self itemAtRow:clickedRow];
            
            [self recursiveDeselectItem:aRowItem];
        }
        else
        {
            [super mouseDown:theEvent];
        }
    }
}


- (void)recursiveDeselectItem:(id)aRowItem;
{
    NSInteger rowIndexForItem = [self rowForItem:aRowItem];
    [self deselectRow:rowIndexForItem];
    
    NSXMLNode * itemNode = (NSXMLNode *)aRowItem;
    if (itemNode.kind != NSXMLElementKind)
    {
        id parentItem = [self parentForItem:aRowItem];
        NSInteger rowIndexForParentItem = [self rowForItem:parentItem];
        [self deselectRow:rowIndexForParentItem];
    }

    NSInteger numberOfChildrenOfItem = [self numberOfChildrenOfItem:aRowItem];
    
    for (NSInteger childIndex = 0; childIndex < numberOfChildrenOfItem; childIndex++)
    {
        id aChildItem = [self child:childIndex ofItem:aRowItem];
        [self recursiveDeselectItem:aChildItem];
    }
}

- (void)drawBackgroundInClipRect:(NSRect)clipRect
{
    NSBezierPath * clipRectPath = [NSBezierPath bezierPathWithRect:clipRect]; //6.0
    clipRectPath.lineWidth = 1;
    [[NSColor whiteColor] set];
    //[clipRectPath stroke];
    [clipRectPath fill];
}


- (void)highlightSelectionInClipRect:(NSRect)theClipRect
{
    self.selectionHighlightStyle = NSTableViewSelectionHighlightStyleSourceList;

    NSBezierPath * clipRectPath = [NSBezierPath bezierPathWithRect:theClipRect]; //6.0
    clipRectPath.lineWidth = 1;
    [[NSColor whiteColor] set];
    //[clipRectPath stroke];
    [clipRectPath fill];

    NSRange         visibleRowsRange = [self rowsInRect:theClipRect];
    NSIndexSet *    selectedRowIndexes = self.selectedRowIndexes;
    NSInteger       startRow = visibleRowsRange.location;
    NSInteger       endRow = startRow + visibleRowsRange.length;

    // if the view is focused, use highlight color, otherwise use the out-of-focus highlight color
    BOOL windowIsActive = NO;
    if (self == self.window.firstResponder && self.window.mainWindow && self.window.keyWindow)
    {
        windowIsActive = YES;
    }

    //NSColor * selectedControlColor = [NSColor alternateSelectedControlColor];
    NSColor * selectedControlColor = [NSColor whiteColor];
    
    //NSColor * secondarySelectedControlColor = [NSColor selectedMenuItemColor];
    //NSColor * secondarySelectedControlColor = [NSColor controlShadowColor];
    NSColor * secondarySelectedControlColor = [NSColor whiteColor];

    // draw highlight for the visible, selected rows
    for (NSInteger aRow = startRow; aRow < endRow; aRow++)
    {
        NSRect aRowRect = NSInsetRect([self rectOfRow:aRow], 0, 0);
        NSBezierPath * path = [NSBezierPath bezierPathWithRect:aRowRect]; //6.0
        path.lineWidth = 1;
        
        if([selectedRowIndexes containsIndex:aRow])
        {
            if (windowIsActive == YES)
            {
                NSColor * rowColor = selectedControlColor;
            
                NSXMLNode * nodeForRow = [self itemAtRow:aRow];
                NSXMLNode * parentNode = nodeForRow.parent;
                if (parentNode != NULL)
                {
                    NSInteger rowForParentItem = [self rowForItem:parentNode];
                    if([selectedRowIndexes containsIndex:rowForParentItem])
                    {
                        rowColor = secondarySelectedControlColor;
                    }
                }
                else
                {
                    // check root element
                    if([selectedRowIndexes containsIndex:0])
                    {
                        rowColor = secondarySelectedControlColor;
                    }
                }
                
                [rowColor set];
            }
            else
            {
                [secondarySelectedControlColor set];
            }
            //[path stroke];
            [path fill];
        }
        else
        [path fill];
    }
}



- (IBAction)selectNone:(id)sender
{
    [self deselectAll:sender];
}



- (IBAction)deselectAll:(id)sender
{
    [super deselectAll:sender];
    
    XMLOutlineController * xmlOutlineController = (XMLOutlineController *)self.delegate;
    MacSVGDocumentWindowController * macSVGDocumentWindowController = xmlOutlineController.macSVGDocumentWindowController;
    [macSVGDocumentWindowController setToolMode:toolModeArrowCursor];
}



- (void)keyDown:(NSEvent *)event
{
    unichar key = [event.charactersIgnoringModifiers characterAtIndex:0];
    
    BOOL skipSuperclassKeyDown = NO;
    
    switch (key)
    {
        case NSDeleteCharacter:
        {
            if(self.selectedRow == -1)
            {
                NSBeep();
            }
            else
            {
                XMLOutlineController * xmlOutlineController = (XMLOutlineController *)self.delegate;
                
                [xmlOutlineController deleteElementAction:self];
                
                skipSuperclassKeyDown = YES;
                
                break;
            }
        }
        
        case '\x1b':    // escape key
        {
            XMLOutlineController * xmlOutlineController = (XMLOutlineController *)self.delegate;

            DOMMouseEventsController * domMouseEventsController =
                    xmlOutlineController.macSVGDocumentWindowController.svgWebKitController.domMouseEventsController;
        
            [domMouseEventsController endPathDrawing];
            [domMouseEventsController endPolylineDrawing];
            
            domMouseEventsController.mouseMode = MOUSE_DISENGAGED;

            //self.clickPoint = self.currentMousePoint;
            domMouseEventsController.clickTarget = NULL;
            domMouseEventsController.svgXMLDOMSelectionManager.activeXMLElement = NULL;

            skipSuperclassKeyDown = YES;

            break;
        }
        
        case NSUpArrowFunctionKey:  // up arrow key
        {
            if (event.modifierFlags & NSAlternateKeyMask) // option key
            {
                XMLOutlineController * xmlOutlineController = (XMLOutlineController *)self.delegate;

                [xmlOutlineController nudgeSelectedItemsUp];
                
                skipSuperclassKeyDown = YES;
            }
            break;
        }
        
        case NSDownArrowFunctionKey:  // down arrow key
        {
            if (event.modifierFlags & NSAlternateKeyMask) // option key
            {
                XMLOutlineController * xmlOutlineController = (XMLOutlineController *)self.delegate;

                [xmlOutlineController nudgeSelectedItemsDown];
                
                skipSuperclassKeyDown = YES;
            }
            break;
        }
        
        case NSLeftArrowFunctionKey:  // left arrow key
        {
            if (event.modifierFlags & NSAlternateKeyMask) // option key
            {
                XMLOutlineController * xmlOutlineController = (XMLOutlineController *)self.delegate;

                [xmlOutlineController nudgeSelectedItemsLeft];
                
                skipSuperclassKeyDown = YES;
            }
            break;
        }
        
        case NSRightArrowFunctionKey:  // right arrow key
        {
            if (event.modifierFlags & NSAlternateKeyMask) // option key
            {
                XMLOutlineController * xmlOutlineController = (XMLOutlineController *)self.delegate;

                [xmlOutlineController nudgeSelectedItemsRight];
                
                skipSuperclassKeyDown = YES;
            }
            break;
        }
    }
    
    if (skipSuperclassKeyDown == NO)
    {
        [super keyDown:event];
    }
}





@end


