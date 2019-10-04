//
//  GradientEditorPopoverViewController.h
//  ColorAttributeEditor
//
//  Created by Douglas Ward on 9/12/13.
//
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class ColorAttributeEditor;

@interface GradientEditorPopoverViewController : NSViewController
{
    IBOutlet ColorAttributeEditor * colorAttributeEditor;
    IBOutlet NSPopover * gradientEditorPopover;

    IBOutlet NSTableView * gradientElementsTableView;
    IBOutlet NSTableView * colorStopElementsTableView;
    
    IBOutlet NSTextField * gradientTypeTextField;
    IBOutlet NSTextField * gradientIDTextField;
    IBOutlet NSTextField * gradientX1TextField;
    IBOutlet NSTextField * gradientY1TextField;
    IBOutlet NSTextField * gradientX2TextField;
    IBOutlet NSTextField * gradientY2TextField;
    IBOutlet NSTextField * gradientRTextField;
    
    IBOutlet NSTextField * gradientX1Label;
    IBOutlet NSTextField * gradientY1Label;
    IBOutlet NSTextField * gradientX2Label;
    IBOutlet NSTextField * gradientY2Label;
    IBOutlet NSTextField * gradientRLabel;
    
    IBOutlet NSPopUpButton * presetsPopUpButton;
    
    IBOutlet NSTextField * colorStopIDTextField;
    IBOutlet NSTextField * colorStopOffsetTextField;
    IBOutlet NSComboBox * colorStopColorComboBox;
    IBOutlet NSColorWell * colorStopColorWell;
    IBOutlet NSTextField * colorStopOpacityTextField;

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"

    IBOutlet WebView * gradientPreviewWebView;

    #pragma clang diagnostic pop

    IBOutlet NSButton * newColorStopButton;
    IBOutlet NSButton * deleteColorStopButton;
    IBOutlet NSButton * applyGradientButton;
}

@property(strong) NSMutableArray * gradientsArray;
@property(strong) NSMutableArray * colorStopsArray;
@property(strong) NSTimer * delayedUpdateTimer;

- (IBAction)newLinearGradientButtonAction:(id)sender;
- (IBAction)newRadialGradientButtonAction:(id)sender;
- (IBAction)newColorStopButtonAction:(id)sender;
- (IBAction)deleteColorStopButtonAction:(id)sender;
- (IBAction)presetsPopUpButtonAction:(id)sender;

- (IBAction)gradientTextFieldAction:(id)sender;
- (IBAction)colorStopTextFieldAction:(id)sender;

- (IBAction)colorStopColorWellAction:(id)sender;

- (IBAction)applyButtonAction:(id)sender;
- (IBAction)doneButtonAction:(id)sender;

 -(void)loadGradientsData;

@end
