//
//  AnimatePopoverViewController.h
//  PathElementShapeAnimationEditor
//
//  Created by Douglas Ward on 8/15/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PathElementShapeAnimationEditor;

@interface AnimatePopoverViewController : NSViewController
{
    IBOutlet PathElementShapeAnimationEditor * pathElementShapeAnimationEditor;
    IBOutlet NSPopover * animatePopover;
    
    IBOutlet NSTextField * animateElementIDTextField;
    IBOutlet NSTextField * beginAtTimesTextField;
    IBOutlet NSButton * afterPreviousAnimateButton;
    IBOutlet NSButton * afterFinalAnimateButton;
    IBOutlet NSTextField * durationTextField;
    IBOutlet NSMatrix * repeatCountMatrix;
    IBOutlet NSTextField * repeatCountTextField;
    IBOutlet NSPopUpButton * fillPopUpButton;
    IBOutlet NSButton * cancelButton;
    IBOutlet NSButton * doneButton;
    
    BOOL createNewAnimateElement;
}

-(void)loadSettingsForNewAnimateElement;
-(void)loadSettingsForAnimateElement:(NSXMLElement *)animateElement;

- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)doneButtonAction:(id)sender;

@end
