//
//  IRIReferenceAttributeEditor.h
//  IRIReferenceAttributeEditor
//
//  Created by Douglas Ward on 9/3/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

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
