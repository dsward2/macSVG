//
//  AttributeEditorController.h
//  macSVG
//
//  Created by Douglas Ward on 1/1/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EditorUIFrameController;

@interface AttributeEditorController : NSObject
{
    IBOutlet EditorUIFrameController * editorUIFrameController;
    IBOutlet NSView * attributeEditorView;
    IBOutlet NSTextView * attributeEditorTextView;
}

-(void)setEnabled:(BOOL)enabled;
-(void)reloadData;

- (IBAction)saveChangesButtonAction:(id)sender;
- (IBAction)revertButtonAction:(id)sender;

@end
