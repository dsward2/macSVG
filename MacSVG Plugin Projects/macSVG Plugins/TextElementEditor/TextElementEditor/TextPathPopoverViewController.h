//
//  TextPathPopoverViewController.h
//  TextElementEditor
//
//  Created by Douglas Ward on 8/19/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class TextElementEditor;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


@interface TextPathPopoverViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>
{
    IBOutlet TextElementEditor * textElementEditor;
    IBOutlet NSPopover * textPathPopover;
    
    IBOutlet NSTableView * eligiblePathsTableView;
    
    IBOutlet WebView * textPathPreviewWebView;
    IBOutlet NSMatrix * previewOptionsMatrix;
    
    IBOutlet NSTextField * startOffsetValueTextField;
    
    IBOutlet NSTableView * animateElementsTableView;
    
    IBOutlet NSTextField * animateBeginValueTextField;
    IBOutlet NSTextField * animateDurationValueTextField;
    IBOutlet NSTextField * animateStartOffsetValuesTextField;
    
    IBOutlet NSTextField * pathLengthTextField;
    IBOutlet NSTextField * textLengthTextField;
    
    IBOutlet NSPopUpButton * animateFillPopUpButton;
    IBOutlet NSComboBox * animateRepeatCountComboBox;
    
    IBOutlet NSButton * addAnimateButton;
    IBOutlet NSButton * removeAnimateButton;
    IBOutlet NSButton * cancelButton;
    IBOutlet NSButton * doneButton;
}

@property(strong) NSXMLElement * originalTextElement;
@property(strong) NSXMLElement * masterTextElement;
@property(strong) NSXMLElement * masterTextPathElement;
@property(strong) NSString * masterTextContentString;

@property(strong) NSMutableArray * masterAnimateElementsArray;
@property(strong) NSMutableArray * eligiblePathElementsArray;

@property(strong) NSXMLDocument * eligiblePathXMLDocument;
@property(strong) NSXMLDocument * textPathPreviewXMLDocument;

- (void)loadSettingsForTextElement:(NSXMLElement *)textElement;

- (IBAction)doneButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)addAnimateButtonAction:(id)sender;
- (IBAction)removeAnimateButtonAction:(id)sender;
- (IBAction)updateTextPathData:(id)sender;

@end


#pragma clang diagnostic pop

