//
//  AnimateMotionElementEditor.h
//  AnimateMotionElementEditor
//
//  Created by Douglas Ward on 8/26/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <MacSVGPlugin/MacSVGPlugin.h>

@class AnimateMotionKeyValuesPopoverViewController;

@interface AnimateMotionElementEditor : MacSVGPlugin <NSControlTextEditingDelegate, NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource, NSTextDelegate>
{
    IBOutlet NSPopUpButton * calcModePopUpButton;
    IBOutlet NSTextField * beginTextField;
    IBOutlet NSTextField * durTextField;
    IBOutlet NSComboBox * repeatCountComboBox;
    IBOutlet NSTabView * animateMotionTabView;
    IBOutlet NSTextField * fromTextField;
    IBOutlet NSTextField * toTextField;
    IBOutlet NSTableView * valuesTableView;
    IBOutlet NSTextField * pathTextField;
    IBOutlet NSComboBox * pathRotateComboBox;
    IBOutlet NSPopUpButton * mpathPopUpButton;
    IBOutlet NSComboBox * mpathRotateComboBox;

    IBOutlet NSButton * addValuesRowButton;
    IBOutlet NSButton * deleteValuesRowButton;
    
    IBOutlet NSButton * cancelButton;
    IBOutlet NSButton * applyChangesButton;

    IBOutlet NSPopover * animateMotionKeyValuesPopover;
    IBOutlet AnimateMotionKeyValuesPopoverViewController * animateMotionKeyValuesPopoverViewController;
}

@property (strong) NSMutableArray * valuesArray;


- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)applyChangesButtonAction:(id)sender;
- (IBAction)editKeyValuesButtonAction:(id)sender;

@end
