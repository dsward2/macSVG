//
//  TextElementEditor.h
//  TextElementEditor
//
//  Created by Douglas Ward on 7/29/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <MacSVGPlugin/MacSVGPlugin.h>

@class FontPopoverViewController;
@class TextStylesPopoverViewController;
@class TextPathPopoverViewController;
@class TspanPopoverViewController;

@interface TextElementEditor : MacSVGPlugin <NSTextFieldDelegate>
{
    IBOutlet NSPopUpButton * tspanPopUpButton;
    IBOutlet NSButton * addTspanButton;
    IBOutlet NSTextView * textContentTextView;
    IBOutlet NSTextField * fontFamilyTextField;
    IBOutlet NSButton * browseFontsButton;
    IBOutlet NSTextField * fontSizeTextField;
    IBOutlet NSPopUpButton * fontSizeUnitsPopUpButton;
    IBOutlet NSStepper * fontSizeStepper;
    IBOutlet NSPopUpButton * textAnchorPopUpButton;
    IBOutlet NSButton * editTextpathButton;
    IBOutlet NSButton * editTspanButton;
    
    IBOutlet NSPopover * fontPopover;
    IBOutlet FontPopoverViewController * fontPopoverViewController;
    
    IBOutlet NSPopover * textStylesPopover;
    IBOutlet TextStylesPopoverViewController * textStylesPopoverViewController;
    
    IBOutlet NSPopover * textPathPopover;
    IBOutlet TextPathPopoverViewController * textPathPopoverViewController;
    
    IBOutlet NSPopover * tspanPopover;
    IBOutlet TspanPopoverViewController * tspanPopoverViewController;
    
    BOOL creatingNewTspan;
}

@property (readonly, copy) NSXMLElement *activeXMLTextElement;
@property (readonly, copy) NSXMLDocument *activeXMLDocument;

- (IBAction)browseFontsButtonAction:(id)sender;
- (IBAction)fontSizeStepperAction:(id)sender;
- (IBAction)textStylesButtonAction:(id)sender;
- (IBAction)editTextPathButtonAction:(id)sender;

@property (readonly, copy) NSString *textElementContent;
- (void)setFontName:(NSString *)fontName;
@property (readonly, strong) NSButton *browseFontsButton;

- (IBAction)updateTextElementAction:(id)sender;
- (IBAction)tspanPopUpButtonAction:(id)sender;

- (IBAction)newTspanButtonAction:(id)sender;
- (IBAction)editTspanButtonAction:(id)sender;

@end
