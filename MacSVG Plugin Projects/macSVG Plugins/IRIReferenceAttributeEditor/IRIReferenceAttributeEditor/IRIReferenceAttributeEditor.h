//
//  IRIReferenceAttributeEditor.h
//  IRIReferenceAttributeEditor
//
//  Created by Douglas Ward on 9/3/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

/*********************

20170106 This plugin editor was merged with the SVGElementEditor and removed from the macSVG application bundle

**********************/

#import <MacSVGPlugin/MacSVGPlugin.h>

@interface IRIReferenceAttributeEditor : MacSVGPlugin <NSComboBoxDelegate, NSComboBoxDataSource>
{
    IBOutlet NSTextField * elementNameTextField;
    IBOutlet NSTextField * attributeNameTextField;
    IBOutlet NSComboBox * iriReferenceComboBox;
}

@property (strong) NSMutableArray * iriReferencesArray;

- (IBAction)setValueButtonAction:(id)sender;

@end
