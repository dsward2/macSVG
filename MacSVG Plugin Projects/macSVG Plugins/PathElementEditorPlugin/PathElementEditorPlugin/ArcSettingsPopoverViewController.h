//
//  ArcSettingsPopoverViewController.h
//  PathElementEditor
//
//  Created by Douglas Ward on 9/13/16.
//
//

#import <Cocoa/Cocoa.h>

@class PathElementEditor;

@interface ArcSettingsPopoverViewController : NSViewController
{
    IBOutlet NSPopover * arcSettingsPopover;
    
    IBOutlet NSButton * applyButton;
    IBOutlet NSButton * cancelButton;
}

@property (strong) IBOutlet PathElementEditor * pathElementEditor;

@property (strong) IBOutlet NSButton * pathLargeArcCheckbox;
@property (strong) IBOutlet NSButton * pathSweepCheckbox;
@property (strong) IBOutlet NSTextField * pathRadiusXTextField;
@property (strong) IBOutlet NSTextField * pathRadiusYTextField;
@property (strong) IBOutlet NSTextField * xAxisRotationTextField;


- (IBAction)applyButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;

@end
