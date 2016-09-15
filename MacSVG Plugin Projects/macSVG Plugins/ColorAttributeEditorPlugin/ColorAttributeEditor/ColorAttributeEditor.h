//
//  ColorEditorPlugin.h
//  ColorEditorPlugin
//
//  Created by Douglas Ward on 1/5/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MacSVGPlugin/MacSVGPlugin.h"

@class GradientEditorPopoverViewController;

@interface ColorAttributeEditor : MacSVGPlugin  <NSTableViewDelegate, NSTableViewDataSource>
{
    IBOutlet NSTableView * webColorsTableView;
    IBOutlet NSColorWell * colorWell;
    IBOutlet NSTextField * colorTextField;
    IBOutlet NSPopover * gradientEditorPopover;
    IBOutlet GradientEditorPopoverViewController * gradientEditorPopoverViewController;
    IBOutlet NSButton * setGradientButton;
    IBOutlet NSButton * setNoneButton;
}
@property(strong) NSMutableArray * webColorsArray;

- (void)buildWebColorsArray;
- (IBAction)setColorButtonAction:(id)sender;
- (IBAction)setNoneButtonAction:(id)sender;
- (IBAction)setWebColorButtonAction:(id)sender;
- (IBAction)colorWellAction:(id)sender;
- (IBAction)colorGradientButtonAction:(id)sender;

- (void)setGradientElement:(NSXMLElement *)gradientElement;

@end

