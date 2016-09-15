// This plugin is discontinued, and replaced by PathElementEditor.


//
//  PathEditorPlugin.h
//  PathEditorPlugin
//
//  Created by Douglas Ward on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MacSVGPlugin/MacSVGPlugin.h"

@interface PathAttributeEditor : MacSVGPlugin <NSTableViewDelegate, NSTableViewDataSource>
{
    IBOutlet NSTableView * pathTableView;
    
    IBOutlet NSPopUpButton * segmentTypePopUpButton;
    IBOutlet NSButton * insertSegmentButton;
    IBOutlet NSButton * deleteSegmentButton;
    
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
    
    IBOutlet NSButton * highlightSegmentButton;
    IBOutlet NSButton * subdivideSegmentButton;
}

- (IBAction)highlightSegmentButtonAction:(id)sender;
- (IBAction)subdivideSegmentButtonAction:(id)sender;

@end
