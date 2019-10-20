//
//  KeyValuesPopoverViewController.h
//  AnimateMotionElementEditor
//
//  Created by Douglas Ward on 10/12/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AnimateTransformElementEditor;
@class AnimateTransformKeySplinesView;

@interface AnimateTransformKeyValuesPopoverViewController : NSViewController
{
    IBOutlet NSPopover * keyValuesPopover;
    IBOutlet AnimateTransformElementEditor * animateTransformElementEditor;
    IBOutlet NSTableView * keyValuesTableView;
    IBOutlet NSButton * addRowButton;
    IBOutlet NSButton * deleteRowButton;
    IBOutlet AnimateTransformKeySplinesView * keySplinesView;
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
