//
//  TransformElementsDialogWindowController.h
//  TransformElementsDialog
//
//  Created by Douglas Ward on 8/10/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TransformElementsDialog;

@interface TransformElementsDialogWindowController : NSWindowController
{
    IBOutlet TransformElementsDialog * transformElementsDialog;
    
    IBOutlet NSPopUpButton * transformPopUpButton;
    
    IBOutlet NSTextField * textLabel1;
    IBOutlet NSTextField * textLabel2;
    IBOutlet NSTextField * textLabel3;
    
    IBOutlet NSTextField * textValue1;
    IBOutlet NSTextField * textValue2;
    IBOutlet NSTextField * textValue3;

    IBOutlet NSTextField * transformNotes;
    
    IBOutlet NSButton * applyButton;
    IBOutlet NSButton * cancelButton;
}

- (IBAction)transformPopUpButtonAction:(id)sender;
- (IBAction)applyButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;

@end
