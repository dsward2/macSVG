//
//  EditorUIFrameController
//  macSVG
//
//  Created by Douglas Ward on 1/1/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XMLAttributesTableController.h"
#import "ElementEditorPlugInController.h"
#import "AttributeEditorPlugInController.h"
#import "AttributeEditorController.h"
#import "TextEditorController.h"
#import "ValidAttributesController.h"

@class MacSVGDocumentWindowController;
@class DOMEvent;

@class ElementEditorPlugInController;
@class AttributeEditorPlugInController;
@class AttributeEditorController;
@class TextEditorController;
@class ValidAttributesController;
@class MacSVGPlugin;

@interface EditorUIFrameController : NSObject
{
}
@property(weak) IBOutlet XMLAttributesTableController * xmlAttributesTableController;

@property(weak) IBOutlet NSView * editorPanelFrameView;
@property(weak) IBOutlet NSPopUpButton * editorPanelPopUpButton;

@property(weak) IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;

@property(weak) IBOutlet ElementEditorPlugInController * elementEditorPlugInController;
@property(weak) IBOutlet AttributeEditorPlugInController * attributeEditorPlugInController;
@property(weak) IBOutlet AttributeEditorController * attributeEditorController;
@property(weak) IBOutlet TextEditorController * textEditorController;
@property(weak) IBOutlet ValidAttributesController * validAttributesController;

@property(strong) NSString * editorContext;
@property(strong) NSString * elementName;
@property(strong) NSString * attributeName;
@property(strong) NSString * currentEditorKind;

@property(strong) NSMutableArray * editorPanelsArray;

- (MacSVGPlugin *)currentPlugin;

- (IBAction)setEditorFrameContent:(id)sender;

- (void)setAttributeEditorView;
- (void)setTextEditorView;
- (void)setValidAttributesView;
- (void)setEmptyView;

- (void)reloadData;
- (void)handlePluginEvent:(DOMEvent *)event;

- (void)addEditorPanelItemWithTitle:(NSString *)titleString kind:(NSString *)kindString;

- (void)setValidEditorsForXMLNode:(NSXMLNode *)node
        elementName:(NSString *)aElementName
        attributeName:(NSString *)aAttributeName context:(NSString *)aContext;

- (NSMutableArray *) contextMenuItemsForPlugin;

@end
