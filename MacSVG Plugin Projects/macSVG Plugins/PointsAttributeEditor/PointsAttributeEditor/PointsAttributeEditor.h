//
//  PointsAttributeEditor.h
//  PointsAttributeEditor
//
//  Created by Douglas Ward on 9/10/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <MacSVGPlugin/MacSVGPlugin.h>

@interface PointsAttributeEditor : MacSVGPlugin <NSTextFieldDelegate>
{
    IBOutlet NSTableView * pointsTableView;

    IBOutlet NSButton * cancelButton;
    IBOutlet NSButton * applyChangesButton;

    IBOutlet NSButton * highlightSelectedPointCheckbox;
    IBOutlet NSColorWell * highlightColorWell;
    IBOutlet NSButton * highlightUseCustomStrokeWidthCheckbox;
    IBOutlet NSTextField * highlightStrokeWidthTextField;
}
@property (strong) NSMutableArray * pointsArray;

- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)applyChangesButtonAction:(id)sender;

- (IBAction)addPointsRow:(id)sender;
- (IBAction)deletePointsRow:(id)sender;

@end
