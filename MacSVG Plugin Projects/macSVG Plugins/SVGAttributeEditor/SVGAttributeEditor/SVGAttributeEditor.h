//
//  SVGAttributeEditor.h
//  SVGAttributeEditor
//
//  Created by Douglas Ward on 7/29/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <MacSVGPlugin/MacSVGPlugin.h>

@interface SVGAttributeEditor : MacSVGPlugin
{
    IBOutlet NSTextField * elementNameTextField;
    IBOutlet NSTextField * attributeNameTextField;
    IBOutlet NSTextField * attributeValueTextField;
    IBOutlet NSPopUpButton * attributeUnitPopUpButton;
    IBOutlet NSStepper * attributeStepper;
    IBOutlet NSPopUpButton * definedValuePopUpButton;
    IBOutlet NSButton * setAttributeValueButton;
    IBOutlet NSButton * setDefinedValueButton;
}

@property (strong) NSMutableArray * iriReferencesArray;


- (IBAction)setValueButtonAction:(id)sender;
- (IBAction)setDefinedValueButtonAction:(id)sender;
- (IBAction)definedValuePopUpButtonAction:(id)sender;
- (IBAction)attributeStepperAction:(id)sender;

@end
