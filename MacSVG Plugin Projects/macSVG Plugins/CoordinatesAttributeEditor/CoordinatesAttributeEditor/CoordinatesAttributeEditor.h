//
//  CoordinatesAttributeEditor.h
//  CoordinatesAttributeEditor
//
//  Created by Douglas Ward on 7/30/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <MacSVGPlugin/MacSVGPlugin.h>

@interface CoordinatesAttributeEditor : MacSVGPlugin
{
    IBOutlet NSTextField * label1;
    IBOutlet NSTextField * label2;
    IBOutlet NSTextField * label3;
    IBOutlet NSTextField * label4;
    IBOutlet NSTextField * label5;
    IBOutlet NSTextField * label6;
    
    IBOutlet NSTextField * attribute1;
    IBOutlet NSTextField * attribute2;
    IBOutlet NSTextField * attribute3;
    IBOutlet NSTextField * attribute4;
    IBOutlet NSTextField * attribute5;
    IBOutlet NSTextField * attribute6;
    
    IBOutlet NSPopUpButton * unit1;
    IBOutlet NSPopUpButton * unit2;
    IBOutlet NSPopUpButton * unit3;
    IBOutlet NSPopUpButton * unit4;
    IBOutlet NSPopUpButton * unit5;
    IBOutlet NSPopUpButton * unit6;

    IBOutlet NSStepper * stepper1;
    IBOutlet NSStepper * stepper2;
    IBOutlet NSStepper * stepper3;
    IBOutlet NSStepper * stepper4;
    IBOutlet NSStepper * stepper5;
    IBOutlet NSStepper * stepper6;

    IBOutlet NSButton * proportionalWidthHeightCheckboxButton;
    IBOutlet NSTextField * unitIncrement;

    float viewBoxMinX;
    float viewBoxMinY;
    float viewBoxWidth;
    float viewBoxHeight;
}

@property(strong) NSString * previousValue1;
@property(strong) NSString * previousValue2;
@property(strong) NSString * previousValue3;
@property(strong) NSString * previousValue4;
@property(strong) NSString * previousValue5;
@property(strong) NSString * previousValue6;

- (IBAction)stepper1Action:(id)sender;
- (IBAction)stepper2Action:(id)sender;
- (IBAction)stepper3Action:(id)sender;
- (IBAction)stepper4Action:(id)sender;
- (IBAction)stepper5Action:(id)sender;
- (IBAction)stepper6Action:(id)sender;

- (IBAction)attributeControlAction:(id)sender;


@end
