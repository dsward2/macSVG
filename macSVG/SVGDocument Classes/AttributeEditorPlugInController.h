//
//  AttributeEditorPlugInController.h
//  macSVG
//
//  Created by Douglas Ward on 1/1/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EditorUIFrameController;
@class DOMEvent;
@class SVGXMLDOMSelectionManager;

@interface AttributeEditorPlugInController : NSObject
{
    IBOutlet EditorUIFrameController * editorUIFrameController;
    IBOutlet NSView * attributeEditorPlugInView;
    //IBOutlet NSPopUpButton * attributeEditorPlugInPopUpButton;
    IBOutlet SVGXMLDOMSelectionManager * svgXMLDOMSelectionManager;
}

@property(weak)     IBOutlet NSScrollView * pluginHostScrollView;

@property(strong) NSXMLElement * currentXMLElementForAttribute;
@property(strong) NSString * currentAttributeName;
@property(strong) id currentPlugin;

-(void)setEnabled:(BOOL)enabled;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void) handlePluginEvent:(DOMEvent *)event;

#pragma clang diagnostic pop

- (void)loadAttributeEditorPlugIn:(NSString *)selectedAttributeEditorPlugIn;
- (NSMutableArray *) contextMenuItemsForPlugin;

@end
