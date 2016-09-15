//
//  TextEditorController.h
//  macSVG
//
//  Created by Douglas Ward on 1/1/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EditorUIFrameController;

@interface TextEditorController : NSObject
{
    IBOutlet EditorUIFrameController * editorUIFrameController;
    IBOutlet NSView * textEditorView;
    IBOutlet NSTextView * textEditorTextView;
}

-(void)setEnabled:(BOOL)enabled;
-(void)reloadData;

- (IBAction)saveChangesButtonAction:(id)sender;
- (IBAction)revertButtonAction:(id)sender;

@end
