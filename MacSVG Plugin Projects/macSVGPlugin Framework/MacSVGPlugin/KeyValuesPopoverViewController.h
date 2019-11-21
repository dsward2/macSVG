//
//  KeyValuesPopoverViewController.h
//  MacSVGPlugin
//
//  Created by Douglas Ward on 10/12/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MacSVGPlugin;
@class KeySplinesView;

@interface KeyValuesPopoverViewController : NSViewController <NSComboBoxDelegate, NSTableViewDelegate, NSTableViewDataSource>
{
    IBOutlet NSPopover * keyValuesPopover;
    IBOutlet MacSVGPlugin * macSVGPlugin;
    IBOutlet NSTableView * keyValuesTableView;
    IBOutlet NSButton * addRowButton;
    IBOutlet NSButton * deleteRowButton;
    IBOutlet KeySplinesView * keySplinesView;
    IBOutlet NSPopUpButton * presetsPopUpButton;
}

@property(strong) NSMutableArray * keyValuesArray;

- (IBAction)tableCellChanged:(id)sender;

- (IBAction)doneButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;

- (NSInteger)validRowsCount:(NSArray *)valuesArray;

- (void)loadKeyValuesDataForValidRowsCount:(NSInteger)validRowsCount;

@end
