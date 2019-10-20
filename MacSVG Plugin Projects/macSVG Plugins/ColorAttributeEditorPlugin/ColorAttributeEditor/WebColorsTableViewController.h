//
//  WebColorsTableViewController.h
//  ColorAttributeEditor
//
//  Created by Douglas Ward on 10/5/19.
//  Copyright © 2019 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class ColorAttributeEditor;

@interface WebColorsTableViewController : NSObject <NSTableViewDelegate, NSTableViewDataSource>

@property(strong) IBOutlet ColorAttributeEditor * colorAttributeEditor;
@property(strong) IBOutlet NSTableView * webColorsTableView;
@property(strong) NSMutableArray * webColorsArray;

//- (void)buildWebColorsArray;

@end

NS_ASSUME_NONNULL_END
