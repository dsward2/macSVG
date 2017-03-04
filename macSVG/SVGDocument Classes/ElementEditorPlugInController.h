//
//  ElementEditorPlugInController.h
//  macSVG
//
//  Created by Douglas Ward on 3/2/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EditorUIFrameController;
@class DOMEvent;
@class SVGXMLDOMSelectionManager;

@interface ElementEditorPlugInController : NSObject
{
    IBOutlet SVGXMLDOMSelectionManager * svgXMLDOMSelectionManager;
    IBOutlet EditorUIFrameController * editorUIFrameController;
    IBOutlet NSView * elementEditorPlugInView;
}

@property(weak) IBOutlet NSScrollView * pluginHostScrollView;

@property(strong) NSXMLElement * currentXmlElement;
@property(strong) NSString * currentElementName;
@property(strong) id currentPlugin;

- (void)setEnabled:(BOOL)enabled;
- (void) handlePluginEvent:(DOMEvent *)event;
- (void)loadElementEditorPlugIn:(NSString *)selectedElementEditorPlugIn;
- (NSMutableArray *) contextMenuItemsForPlugin;

@end
