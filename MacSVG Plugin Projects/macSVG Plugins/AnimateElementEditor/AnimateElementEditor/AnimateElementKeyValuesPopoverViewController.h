//
//  AnimateElementKeyValuesPopoverViewController.h
//  AnimateElementEditor
//
//  Created by Douglas Ward on 9/4/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <MacSVGPlugin/MacSVGPlugin.h>

@class AnimateElementEditor;
@class AnimateElementKeySplinesView;

@interface AnimateElementKeyValuesPopoverViewController : NSViewController
{
    IBOutlet NSPopover * keyValuesPopover;
    IBOutlet AnimateElementEditor * animateElementEditor;
    IBOutlet NSTableView * keyValuesTableView;
    IBOutlet NSButton * addRowButton;
    IBOutlet NSButton * deleteRowButton;
    IBOutlet AnimateElementKeySplinesView * keySplinesView;
    IBOutlet NSPopUpButton * presetsPopUpButton;
}

@property(strong) NSMutableArray * keyValuesArray;

- (IBAction)doneButtonAction:(id)sender;
- (IBAction)addRowButtonAction:(id)sender;
- (IBAction)deleteRowButtonAction:(id)sender;
- (IBAction)presetsPopUpButtonAction:(id)sender;

- (void)loadKeyValuesData;

@end
