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
    IBOutlet NSPopUpButton * attributeUnitPopUpButton;
    IBOutlet NSStepper * attributeStepper;
    IBOutlet NSButton * setAttributeValueButton;
    IBOutlet NSButton * selectIRIReferenceElementButton;
    IBOutlet NSComboBox * attributeValueComboBox;
}

@property (strong) NSMutableArray * iriReferencesArray;

@property (strong) NSMutableArray * comboBoxValuesArray;

- (IBAction)setValueButtonAction:(id)sender;
- (IBAction)attributeStepperAction:(id)sender;
- (IBAction)itemTextFieldUpdated:(id)sender;
- (IBAction)selectIRIReferenceElementButtonAction:(id)sender;

@end
