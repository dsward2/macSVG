//
//  SVGElementEditor.h
//  SVGElementEditor
//
//  Created by Douglas Ward on 7/17/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <MacSVGPlugin/MacSVGPlugin.h>

@interface SVGElementEditor : MacSVGPlugin
{
    IBOutlet NSTextField * viewBoxMinXTextField;
    IBOutlet NSTextField * viewBoxMinYTextField;
    IBOutlet NSTextField * viewBoxWidthTextField;
    IBOutlet NSTextField * viewBoxHeightTextField;
    IBOutlet NSTextField * widthAttributeTextField;
    IBOutlet NSPopUpButton * widthUnitPopUpButton;
    IBOutlet NSTextField * heightAttributeTextField;
    IBOutlet NSPopUpButton * heightUnitPopUpButton;
    IBOutlet NSPopUpButton * scalePopUpButton;
}

- (IBAction)saveChangesButtonAction:(id)sender;
- (IBAction)revertButtonAction:(id)sender;

- (IBAction)scalePopUpButtonAction:(id)sender;

@end
