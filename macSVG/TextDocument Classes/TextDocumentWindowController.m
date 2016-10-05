//
//  TextDocumentWindowController.m
//  macSVG
//
//  Created by Douglas Ward on 1/18/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "TextDocumentWindowController.h"

@implementation TextDocumentWindowController

- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//==================================================================================
//	initWithWindowNibName
//==================================================================================

- (instancetype)initWithWindowNibName:(NSString *)windowNibName owner:(id)owner
{
    //self = [super initWithWindowNibName:windowNibName owner:owner];
    self = [super initWithWindowNibName:windowNibName owner:self];
    if (self)
    {
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    }
    return self;
}

//==================================================================================
//	windowDidLoad
//==================================================================================

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    (self.documentTextView).delegate = self;
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

//==================================================================================
//	windowDidBecomeMain:
//==================================================================================

- (void)windowDidBecomeMain:(NSNotification *)aNotification
{
    [self enableEditMenuItems];  // for cut/copy/paste elements
}

//==================================================================================
//	textViewDidChangeSelection:
//==================================================================================

- (void)textViewDidChangeSelection:(NSNotification *)notification
{
    [self enableEditMenuItems];  // for cut/copy/paste elements
}

//==================================================================================
//	enableEditMenuItems
//==================================================================================

- (void)enableEditMenuItems
{
    NSMenu * mainMenu = NSApp.mainMenu;

    NSUInteger editMenuIndex = [mainMenu indexOfItemWithTitle:@"Edit"];
    NSMenuItem * editMenuItem = [mainMenu itemAtIndex:editMenuIndex];
    NSMenu * editMenu = editMenuItem.submenu;

    NSArray * selectedRangesArray = (self.documentTextView).selectedRanges;
    
    BOOL validSelectionRangeFound = NO;
    if (selectedRangesArray.count > 0)
    {
        for (NSValue * aValue in selectedRangesArray)
        {
            NSRange selectedRange = NSMakeRange(0, 0);
            [aValue getValue:&selectedRange];
            if (selectedRange.length > 0)
            {
                validSelectionRangeFound = YES;
                break;
            }
        }
    }
    
    if (validSelectionRangeFound == YES)
    {
        // enable pasteboard functions for selected elements
        NSMenuItem * cutElementMenuItem = [editMenu itemWithTitle:@"Cut"];
        cutElementMenuItem.target = self.documentTextView;
        cutElementMenuItem.action = @selector(cut:);
        cutElementMenuItem.enabled = YES;

        NSMenuItem * copyElementMenuItem = [editMenu itemWithTitle:@"Copy"];
        copyElementMenuItem.target = self.documentTextView;
        copyElementMenuItem.action = @selector(copy:);
        copyElementMenuItem.enabled = YES;
    }
    else
    {
        NSMenuItem * cutElementMenuItem = [editMenu itemWithTitle:@"Cut"];
        [cutElementMenuItem setTarget:NULL];
        [cutElementMenuItem setAction:NULL];
        cutElementMenuItem.enabled = NO;
    
        NSMenuItem * copyElementMenuItem = [editMenu itemWithTitle:@"Copy"];
        [copyElementMenuItem setTarget:NULL];
        [copyElementMenuItem setAction:NULL];
        copyElementMenuItem.enabled = NO;
    }
}

@end
