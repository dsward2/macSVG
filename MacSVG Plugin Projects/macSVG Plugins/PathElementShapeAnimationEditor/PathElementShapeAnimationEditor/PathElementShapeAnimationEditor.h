//
//  PathElementShapeAnimationEditor.h
//  PathElementShapeAnimationEditor
//
//  Created by Douglas Ward on 8/14/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <MacSVGPlugin/MacSVGPlugin.h>

@class AnimatePopoverViewController;
@class AnimationPathsPopoverViewController;

@interface PathElementShapeAnimationEditor : MacSVGPlugin
{
    IBOutlet NSTableView * animateElementsTableView;
    IBOutlet NSButton * addAnimateElementButton;
    IBOutlet NSButton * editAnimateElementButton;
    IBOutlet NSButton * deleteAnimateElementButton;
    IBOutlet NSButton * managePathsForAnimateButton;
    
    IBOutlet NSPopover * animatePopover;
    IBOutlet AnimatePopoverViewController * animatePopoverViewController;

    IBOutlet NSPopover * animationPathsPopover;
    IBOutlet AnimationPathsPopoverViewController * animationPathsPopoverViewController;
}


- (IBAction)addAnimateElementButtonAction:(id)sender;
- (IBAction)editAnimateElementButtonAction:(id)sender;
- (IBAction)deleteAnimateElementButtonAction:(id)sender;

- (IBAction)manageAnimationPathButtonAction:(id)sender;

- (void) setAttributesWithDictionary:(NSMutableDictionary *)animateAttributesDictionary;

@property (readonly, copy) NSXMLElement *createNewAnimateElement;

@end
