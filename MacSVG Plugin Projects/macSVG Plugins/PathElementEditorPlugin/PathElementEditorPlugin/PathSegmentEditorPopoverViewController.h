//
//  PathSegmentEditorPopoverViewController.h
//  PathElementEditor
//
//  Created by Douglas Ward on 7/13/16.
//
//

#import <Cocoa/Cocoa.h>

@class PathElementEditor;
@class PathSegment;

@interface PathSegmentEditorPopoverViewController : NSViewController
{
    IBOutlet NSPopover * pathSegmentEditorPopover;

    IBOutlet NSPopUpButton * segmentTypePopUpButton;
    IBOutlet NSButton * relativeCoordinatesCheckboxButton;
    IBOutlet NSButton * curveSegmentContinuityCheckboxButton;
    
    IBOutlet NSTextField * label1;
    IBOutlet NSTextField * textfield1;
    
    IBOutlet NSTextField * label2;
    IBOutlet NSTextField * textfield2;
    
    IBOutlet NSTextField * label3;
    IBOutlet NSTextField * textfield3;
    
    IBOutlet NSTextField * label4;
    IBOutlet NSTextField * textfield4;
    
    IBOutlet NSTextField * label5;
    IBOutlet NSTextField * textfield5;
    
    IBOutlet NSTextField * label6;
    IBOutlet NSTextField * textfield6;
    
    IBOutlet NSTextField * label7;
    IBOutlet NSTextField * textfield7;
    
    IBOutlet NSTextField * absoluteStartXTextField;
    IBOutlet NSTextField * absoluteStartYTextField;
    IBOutlet NSTextField * absoluteXTextField;
    IBOutlet NSTextField * absoluteYTextField;
}

@property (strong) IBOutlet PathElementEditor * pathElementEditor;

@property (strong) IBOutlet NSButton * applyButton;
@property (strong) IBOutlet NSButton * cancelButton;

- (IBAction)applyButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;

 -(void)loadPathSegmentData:(PathSegment *)pathSegment;

- (IBAction)segmentTypePopUpButtonAction:(id)sender;

@end
