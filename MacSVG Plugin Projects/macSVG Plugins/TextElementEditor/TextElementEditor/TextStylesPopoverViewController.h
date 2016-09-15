//
//  TextStylesPopoverViewController.h
//  TextElementEditor
//
//  Created by Douglas Ward on 8/19/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TextElementEditor;

@interface TextStylesPopoverViewController : NSViewController
{
    IBOutlet TextElementEditor * textElementEditor;
    IBOutlet NSPopover * textStylesPopover;
    
    IBOutlet NSPopUpButton * fontStylePopUpButton;
    IBOutlet NSPopUpButton * fontVariantPopUpButton;
    IBOutlet NSPopUpButton * fontWeightPopUpButton;
    IBOutlet NSPopUpButton * fontStretchPopUpButton;
    
    IBOutlet NSButton * underlineCheckboxButton;
    IBOutlet NSButton * overlineCheckboxButton;
    IBOutlet NSButton * lineThroughCheckboxButton;
    IBOutlet NSButton * blinkCheckboxButton;
    IBOutlet NSButton * inheritDecorationCheckboxButton;
    
    IBOutlet NSTextField * letterSpacingTextfield;
    IBOutlet NSPopUpButton * letterSpacingUnitPopUpButton;
    IBOutlet NSTextField * wordSpacingTextfield;
    IBOutlet NSPopUpButton * wordSpacingUnitPopUpButton;
    
    IBOutlet NSTextView * cssStyleTextView;
    
    IBOutlet NSColorWell * shadowColorWell;
    IBOutlet NSTextField * horizontalOffsetTextField;
    IBOutlet NSPopUpButton * horizontalOffsetUnitPopUpButton;
    IBOutlet NSTextField * verticalOffsetTextField;
    IBOutlet NSPopUpButton * verticalOffsetUnitPopUpButton;
    IBOutlet NSTextField * blurRadiusTextField;
    IBOutlet NSPopUpButton * blurRadiusUnitPopUpButton;
    
    IBOutlet NSButton * addShadowButton;
    IBOutlet NSButton * cancelButton;
    IBOutlet NSButton * doneButton;
}

- (void)loadTextStyles;

- (IBAction)addShadowButtonAction:(id)sender;
- (IBAction)doneButtonAction:(id)sender;

@end
