//
//  XMLOutlineController.h
//  macSVG
//
//  Created by Douglas Ward on 9/18/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class XMLOutlineView;
@class MacSVGDocumentWindowController;
@class DOMSelectionControlsManager;
@class ToolSettingsPopoverViewController;
@class SelectedElementsInfoPopoverViewController;

#define XML_OUTLINE_PBOARD_TYPE      @"XMLOutlineViewPboardType"

@interface XMLOutlineController : NSObject <NSOutlineViewDelegate, NSOutlineViewDataSource, NSMenuDelegate>
{
    IBOutlet DOMSelectionControlsManager * domSelectionControlsManager;
    IBOutlet ToolSettingsPopoverViewController * toolSettingsPopoverViewController;
@private
    NSMutableDictionary * iconImagesDictionary;
    BOOL draggingOutlineItems;
    BOOL validatingDrop;
    BOOL acceptingDrop;
}

@property(weak) IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;
@property(weak) IBOutlet XMLOutlineView * xmlOutlineView;
@property(weak) IBOutlet NSWindow * xmlTextEditSheet;
@property(strong) IBOutlet NSTextField * editErrorTextField;
@property(strong) IBOutlet NSTextView * xmlTextEditView;

@property (strong) NSArray * holdSelectedItems;

@property(assign) BOOL draggingActive;

@property(strong) NSXMLElement * editElement;
@property(strong) NSArray * draggedNodes;

@property(weak) IBOutlet NSPopover * selectedElementsInfoPopover;
@property(weak) IBOutlet SelectedElementsInfoPopoverViewController * selectedElementsInfoPopoverViewController;

- (void)setColumnHeaders;
- (void)reloadData;
- (void)reloadView;
- (void)registerDragTypes;

- (IBAction)outlineViewAction:(id)sender;

@property (readonly, copy) NSArray *selectedNodes;

- (void)selectElement:(NSXMLElement *)aElement;

@property (readonly, copy) NSArray *selectedItems;
@property (readonly, copy) NSArray *selectedElementIDs;

- (void)setSelectedXMLElements:(NSArray *)selectedXMLElements;
- (void)setSelectedXMLDOMElements:(NSArray *)selectedXMLDOMElements;

- (IBAction)addElementAction:(id)sender;
- (IBAction)deleteElementAction:(id)sender;
- (IBAction)duplicateElementAction:(id)sender;
- (IBAction)addGroupElementAction:(id)sender;
- (IBAction)editXMLTextAction:(id)sender;
- (IBAction)selectedElementsInfoAction:(id)sender;

- (IBAction)visibilityCheckboxAction:(id)sender;

- (void)expandAllNodes;
- (void)expandElementInOutline:(NSXMLElement *)aElement;

- (IBAction) applyEditXMLText:(id)sender;
- (IBAction) cancelEditXMLText:(id)sender;

- (NSString *)addCSSStyleName:(NSString *)styleName styleValue:(NSString *)styleValue toXMLElement:(NSXMLElement *)targetElement;
- (NSString *)addCSSStyleName:(NSString *)styleName styleValue:(NSString *)styleValue toDOMElement:(DOMElement *)targetElement;

- (void)nudgeSelectedItemsUp;
- (void)nudgeSelectedItemsDown;
- (void)nudgeSelectedItemsLeft;
- (void)nudgeSelectedItemsRight;

@end
