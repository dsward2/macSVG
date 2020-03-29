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
    BOOL isAwake;
}

@property(strong) IBOutlet MacSVGPlugin * macSVGPlugin;
@property(strong) NSMutableArray * keyValuesArray;
@property(weak) IBOutlet NSTableView * keyValuesTableView;
@property(weak) IBOutlet NSTableColumn * keyPointsTableColumn;

- (IBAction)tableCellChanged:(id)sender;

- (IBAction)doneButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)resetConfigurationButtonAction:(id)sender;

- (NSInteger)validRowsCount:(NSArray *)valuesArray;

- (void)loadKeyValuesDataForValidRowsCount:(NSInteger)validRowsCount;

- (void)useKeyPoints:(BOOL)useKeyPoints;

@end
