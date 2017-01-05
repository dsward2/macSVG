//
//  StyleAttributeEditor.h
//  StyleAttributeEditor
//
//  Created by Douglas Ward on 1/2/17.
//  Copyright © 2017 ArkPhone LLC. All rights reserved.
//

#import <MacSVGPlugin/MacSVGPlugin.h>

@interface StyleAttributeEditor : MacSVGPlugin
{
    IBOutlet NSTableView * stylePropertiesTableView;

    IBOutlet NSButton * cancelButton;
    IBOutlet NSButton * applyChangesButton;
    IBOutlet NSComboBox * propertyNameComboBox;
    IBOutlet NSComboBox * propertyValueComboBox;
}
@property (strong) NSMutableArray * stylePropertiesArray;
@property (strong) NSDictionary * cssPropertiesDictionary;

@property (strong) NSArray * styleNamesComboArray;
@property (strong) NSArray * styleValuesComboArray;

- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)applyChangesButtonAction:(id)sender;

- (IBAction)addStylePropertyRow:(id)sender;
- (IBAction)deleteStylePropertyRow:(id)sender;


@end
