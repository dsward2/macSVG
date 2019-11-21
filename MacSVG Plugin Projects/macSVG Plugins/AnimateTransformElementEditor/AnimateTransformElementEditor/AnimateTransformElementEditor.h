//
//  AnimateTransformElementEditor.h
//  AnimateTransformElementEditor
//
//  Created by Douglas Ward on 9/1/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <MacSVGPlugin/MacSVGPlugin.h>
@class AnimateTransformKeyValuesPopoverViewController;

@interface AnimateTransformElementEditor : MacSVGPlugin <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, NSControlTextEditingDelegate>
{
    IBOutlet NSPopUpButton * typePopUpButton;
    IBOutlet NSPopUpButton * calcModePopUpButton;
    IBOutlet NSTextField * beginTextField;
    IBOutlet NSTextField * durTextField;
    IBOutlet NSStepper * durStepper;
    IBOutlet NSComboBox * repeatCountComboBox;
    IBOutlet NSTabView * animateTransformTabView;
    IBOutlet NSTextField * fromTextField;
    IBOutlet NSTextField * toTextField;
    IBOutlet NSTableView * valuesTableView;

    IBOutlet NSButton * addValuesRowButton;
    IBOutlet NSButton * deleteValuesRowButton;
    
    IBOutlet NSButton * cancelButton;
    IBOutlet NSButton * applyChangesButton;

    IBOutlet NSPopover * keyValuesPopover;
    IBOutlet AnimateTransformKeyValuesPopoverViewController * animateTransformKeyValuesPopoverViewController;
}

@property (strong) NSMutableArray * valuesArray;

- (IBAction)typePopupButtonAction:(id)sender;

- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)applyChangesButtonAction:(id)sender;
- (IBAction)editKeyValuesButtonAction:(id)sender;

- (IBAction)itemTextFieldUpdated:(id)sender;

- (IBAction)attributeDurStepperAction:(id)sender;

@end
