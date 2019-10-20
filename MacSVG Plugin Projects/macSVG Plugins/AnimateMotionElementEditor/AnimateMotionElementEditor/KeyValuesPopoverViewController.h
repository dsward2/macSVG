//
//  KeyValuesPopoverViewController.h
//  AnimateMotionElementEditor
//
//  Created by Douglas Ward on 10/12/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AnimateMotionElementEditor;
@class KeySplinesView;

@interface KeyValuesPopoverViewController : NSViewController
{
    IBOutlet NSPopover * keyValuesPopover;
    IBOutlet AnimateMotionElementEditor * animateMotionElementEditor;
    IBOutlet NSTableView * keyValuesTableView;
    IBOutlet NSButton * addRowButton;
    IBOutlet NSButton * deleteRowButton;
    IBOutlet KeySplinesView * keySplinesView;
    IBOutlet NSPopUpButton * presetsPopUpButton;
}

@property(strong) NSMutableArray * keyValuesArray;

- (IBAction)tableCellChanged:(id)sender;

- (IBAction)doneButtonAction:(id)sender;
- (IBAction)addRowButtonAction:(id)sender;
- (IBAction)deleteRowButtonAction:(id)sender;
- (IBAction)presetsPopUpButtonAction:(id)sender;

- (void)loadKeyValuesData;

@end
