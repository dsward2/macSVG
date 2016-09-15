//
//  EditorUIFrameController.m
//  macSVG
//
//  Created by Douglas Ward on 1/1/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "EditorUIFrameController.h"

#import "ValidAttributesController.h"
#import "AttributeEditorController.h"
#import "AttributeEditorPlugInController.h"
#import "TextEditorController.h"
#import "MacSVGAppDelegate.h"
#import "SVGDTDData.h"
#import "MacSVGDocument.h"
#import "MacSVGDocumentWindowController.h"
#import "SVGXMLDOMSelectionManager.h"
#import "MacSVGPlugin/MacSVGPlugin.h"
#import "SelectedElementsManager.h"
#import "XMLAttributesTableView.h"

#import <objc/message.h>

@implementation EditorUIFrameController

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.elementName = NULL;
    self.attributeName = NULL;
    self.editorContext = NULL;
    self.editorPanelsArray = NULL;
    self.currentEditorKind = NULL;
}

//==================================================================================
//	init
//==================================================================================

- (id)init 
{
    if ((self = [super init])) 
    {
    }
    return self;
}

//==================================================================================
//	awakeFromNib
//==================================================================================

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.currentEditorKind = @"main";

    self.editorPanelsArray = [NSMutableArray array];
    
    [self buildEditorPanelsArrayForContext:@"disable"];
}

//==================================================================================
//	setElementEditorPlugInView
//==================================================================================

- (void)setElementEditorPlugInView:(NSString *)elementEditorPlugInName
{
    NSXMLElement * selectedXMLElement = NULL;
    
    selectedXMLElement = self.xmlAttributesTableController.xmlElementForAttributesTable;

    [self.editorPanelPopUpButton selectItemWithTitle:elementEditorPlugInName];
    [self.elementEditorPlugInController loadElementEditorPlugIn:elementEditorPlugInName];

    [self.elementEditorPlugInController setEnabled:YES];
    [self.attributeEditorPlugInController setEnabled:NO];
    [self.attributeEditorController setEnabled:NO];
    [self.textEditorController setEnabled:NO];
    [self.validAttributesController setEnabled:NO];

    NSScrollView * scrollView = self.elementEditorPlugInController.pluginHostScrollView;
    NSView * documentView = [scrollView documentView];
    NSView * contentView = [scrollView contentView];  // the NSClipView inside NSScrollView
    
    NSRect scrollViewFrame = scrollView.frame;
    NSRect scrollViewBounds = scrollView.bounds;
    NSRect documentViewFrame = documentView.frame;
    NSRect documentViewBounds = documentView.bounds;
    NSRect contentViewFrame = contentView.frame;
    NSRect contentViewBounds = contentView.bounds;
    
    #pragma unused(scrollViewFrame)
    #pragma unused(scrollViewBounds)
    #pragma unused(documentViewFrame)
    #pragma unused(documentViewBounds)
    #pragma unused(contentViewFrame)
    #pragma unused(contentViewBounds)
 
    //newScrollOrigin = NSMakePoint(0.0f, documentViewFrame.size.height);
 
    //[[scrollView documentView] scrollPoint:newScrollOrigin];

    [self.attributeEditorController reloadData];
    [self.textEditorController reloadData];
}

//==================================================================================
//	setAttributeEditorPlugInView
//==================================================================================

- (void)setAttributeEditorPlugInView:(NSString *)attributeEditorPlugInName
{
    NSXMLElement * selectedXMLElement = NULL;
    
    selectedXMLElement = self.xmlAttributesTableController.xmlElementForAttributesTable;

    [self.editorPanelPopUpButton selectItemWithTitle:attributeEditorPlugInName];
    [self.attributeEditorPlugInController loadAttributeEditorPlugIn:attributeEditorPlugInName];

    [self.elementEditorPlugInController setEnabled:NO];
    [self.attributeEditorPlugInController setEnabled:YES];
    [self.attributeEditorController setEnabled:NO];
    [self.textEditorController setEnabled:NO];
    [self.validAttributesController setEnabled:NO];
    
    NSScrollView * scrollView = self.attributeEditorPlugInController.pluginHostScrollView;
    NSView * documentView = [scrollView documentView];
    NSView * contentView = [scrollView contentView];
    #pragma unused(documentView)
    #pragma unused(contentView)
    
    //newScrollOrigin = NSMakePoint(0.0f, documentViewFrame.size.height);
 
    //[[scrollView documentView] scrollPoint:newScrollOrigin];

    [self.attributeEditorController reloadData];
    [self.textEditorController reloadData];
}

//==================================================================================
//	setAttributeEditorView
//==================================================================================

- (void)setAttributeEditorView
{
    [self.elementEditorPlugInController setEnabled:NO];
    [self.attributeEditorPlugInController setEnabled:NO];
    [self.attributeEditorController setEnabled:YES];
    [self.textEditorController setEnabled:NO];
    [self.validAttributesController setEnabled:NO];
    
    [self.attributeEditorController reloadData];
}

//==================================================================================
//	setValidAttributesView
//==================================================================================

- (void)setValidAttributesView
{
    [self.elementEditorPlugInController setEnabled:NO];
    [self.attributeEditorPlugInController setEnabled:NO];
    [self.attributeEditorController setEnabled:NO];
    [self.textEditorController setEnabled:NO];
    [self.validAttributesController setEnabled:YES];    

    [self.attributeEditorController reloadData];
    [self.textEditorController reloadData];
}

//==================================================================================
//	setTextEditorView
//==================================================================================

- (void)setTextEditorView
{
    [self.elementEditorPlugInController setEnabled:NO];
    [self.attributeEditorPlugInController setEnabled:NO];
    [self.attributeEditorController setEnabled:NO];
    [self.textEditorController setEnabled:YES];
    [self.validAttributesController setEnabled:NO];
    
    [self.textEditorController reloadData];
    [self.attributeEditorController reloadData];
}

//==================================================================================
//	setEmptyView
//==================================================================================

- (void)setEmptyView
{
    [self.elementEditorPlugInController setEnabled:NO];
    [self.attributeEditorPlugInController setEnabled:NO];
    [self.attributeEditorController setEnabled:NO];
    [self.textEditorController setEnabled:NO];
    [self.validAttributesController setEnabled:NO];
    
    [self.textEditorController reloadData];
    [self.attributeEditorController reloadData];
}

//==================================================================================
//	reloadData
//==================================================================================

- (void)reloadData
{
    [xmlElementTextView setString:@""];

    NSArray * selectedElementsArray =
            self.macSVGDocumentWindowController.svgXMLDOMSelectionManager.selectedElementsManager.selectedElementsArray;
    
    if ([selectedElementsArray count] > 0)
    {
        NSMutableDictionary * selectedElementDictionary = [selectedElementsArray objectAtIndex:0];
        
        NSXMLElement * selectedXMLElement = [selectedElementDictionary objectForKey:@"xmlElement"];
        
        if (selectedXMLElement == NULL)
        {
            NSLog(@"selectedXMLElement = NULL");
        }
        
        // macsvgid="D55D5E82-9E33-46BB-8C52-DF9206F6F662-19466-0000FEC9035385A8"
        // 1...5...10...15...20...25...30...35...40...45...50...55...60...65...70.

        // fast filter to remove macsvgid and child elements
        NSXMLElement * copyXMLElement = [selectedXMLElement copy];
        [copyXMLElement detach];
        NSArray * xmlChildArray = [copyXMLElement children];
        for (NSXMLNode * childNode in xmlChildArray)
        {
            if ([childNode kind] == NSXMLElementKind)
            {
                NSInteger childIndex = [childNode index];
                [copyXMLElement removeChildAtIndex:childIndex];
            }
        }
        [copyXMLElement removeAttributeForName:@"macsvgid"];
        NSString * filteredElementText = [copyXMLElement XMLStringWithOptions:NSXMLNodePreserveCDATA];

        [[xmlElementTextView textStorage] beginEditing];
        [xmlElementTextView setString:filteredElementText];
        [[xmlElementTextView textStorage] endEditing];
    }

    [xmlElementTextView scrollToBeginningOfDocument:NULL];
}

//==================================================================================
//	setEditorFrameContent
//==================================================================================

- (IBAction)setEditorFrameContent:(id)sender
{
    NSInteger * selectedItemIndex = [self.editorPanelPopUpButton indexOfSelectedItem];
    
    NSDictionary * selectedItemDictionary = [self.editorPanelsArray objectAtIndex:selectedItemIndex];

    NSString * selectedItemTitle = [selectedItemDictionary objectForKey:@"title"];
    NSString * selectedItemKind = [selectedItemDictionary objectForKey:@"kind"];
    
    [self loadEditor:selectedItemTitle kind:selectedItemKind];

    [self reloadData];
}

//==================================================================================
//	handlePluginEvent
//==================================================================================

- (void) handlePluginEvent:(DOMEvent *)event
{
    //NSString * eventType = objc_msgSend(event, sel_getUid("type"));
    //#pragma unused(eventType)

    NSInteger currentEditorIndex = [self.editorPanelPopUpButton indexOfSelectedItem];
    NSDictionary * currentEditorSelectionDictionary = [self.editorPanelsArray objectAtIndex:currentEditorIndex];
    
    NSString * currentEditorKind = [currentEditorSelectionDictionary objectForKey:@"kind"];

    if ([currentEditorKind isEqualToString:@"element"] == YES)
    {
        [self.elementEditorPlugInController handlePluginEvent:event];
    }
    else if ([currentEditorKind isEqualToString:@"attribute"] == YES)
    {
        [self.attributeEditorPlugInController handlePluginEvent:event];
    }
}

//==================================================================================
//	setCurrentEditor
//==================================================================================

- (void) setCurrentEditor:(NSString *)newCurrentEditor kind:(NSString *)editorKind
{
    [self loadEditor:newCurrentEditor kind:editorKind];
    
    [self reloadData];
}

//==================================================================================
//	loadEditor:kind:
//==================================================================================

- (void)loadEditor:(NSString *)newCurrentEditor kind:(NSString *)editorKind
{
    [self.macSVGDocumentWindowController.showAttributeHelpButton setEnabled:NO];

    NSString * currentEditor = [self.editorPanelPopUpButton titleOfSelectedItem];

    if ([currentEditor isEqualToString:newCurrentEditor] == NO)
    {
        [self.editorPanelPopUpButton selectItemWithTitle:newCurrentEditor];
    }
    
    if ([editorKind isEqualToString:@"main"] == YES)
    {
        self.currentEditorKind = @"main";
        if ([newCurrentEditor isEqualToString:@"Attribute Editor"] == YES)
        {
            [self setAttributeEditorView];
        }
        else if ([newCurrentEditor isEqualToString:@"Text Content Editor"] == YES)
        {
            [self setTextEditorView];
        }
        else if ([newCurrentEditor isEqualToString:@"Valid Attributes"] == YES)
        {
            [self setValidAttributesView];

            [self.macSVGDocumentWindowController.showAttributeHelpButton setEnabled:YES];
        }
    }
    else if ([editorKind isEqualToString:@"element"] == YES)
    {
        self.currentEditorKind = @"element";
        [self setElementEditorPlugInView:newCurrentEditor];
    }
    else if ([editorKind isEqualToString:@"attribute"] == YES)
    {
        self.currentEditorKind = @"attribute";
        [self setAttributeEditorPlugInView:newCurrentEditor];
    }
    else if ([editorKind isEqualToString:@"disable"] == YES)
    {
        self.currentEditorKind = @"main";
        [self setEmptyView];
    }
    else
    {
        self.currentEditorKind = @"main";
        [self.editorPanelPopUpButton removeAllItems];
        [self setEmptyView];
    }
    
    NSInteger selectedRow = [self.macSVGDocumentWindowController.xmlAttributesTableController.xmlAttributesTableView selectedRow];
    if (selectedRow >= 0)
    {
        [self.macSVGDocumentWindowController.showAttributeHelpButton setEnabled:YES];
    }
}

//==================================================================================
//	buildEditorPanelsArrayForContext
//==================================================================================

- (void)buildEditorPanelsArrayForContext:(NSString *)context
{
    [self.editorPanelsArray removeAllObjects];

    if ([context isEqualToString:@"disable"])
    {
        NSMutableDictionary * validAttributesEditorItemDictionary =
                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                @"No Element Selected", @"title",
                @"disable", @"kind",
                nil];
        [self.editorPanelsArray addObject:validAttributesEditorItemDictionary];
    }
    else
    {
        NSMutableDictionary * validAttributesEditorItemDictionary =
                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                @"Valid Attributes", @"title",
                @"main", @"kind",
                nil];
        [self.editorPanelsArray addObject:validAttributesEditorItemDictionary];

        if ([context isEqualToString:@"attribute"] == YES)
        {
            NSMutableDictionary * attributeEditorItemDictionary =
                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    @"Attribute Editor", @"title",
                    @"main", @"kind",
                    nil];
            [self.editorPanelsArray addObject:attributeEditorItemDictionary];
        }

        NSMutableDictionary * textContentEditorItemDictionary =
                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                @"Text Content Editor", @"title",
                @"main", @"kind",
                nil];
        [self.editorPanelsArray addObject:textContentEditorItemDictionary];
    }
    
    [self buildEditorPanelsMenu];
}

//==================================================================================
//	addEditorPanelItemWithTitle:kind:
//==================================================================================

- (void)addEditorPanelItemWithTitle:(NSString *)titleString kind:(NSString *)kindString
{
    NSMutableDictionary * editorPanelItemDictionary =
            [NSMutableDictionary dictionaryWithObjectsAndKeys:
            titleString, @"title",
            kindString, @"kind",
            nil];
    [self.editorPanelsArray addObject:editorPanelItemDictionary];
    
    [self buildEditorPanelsMenu];
}

//==================================================================================
//	buildEditorPanelsMenu
//==================================================================================

- (void)buildEditorPanelsMenu
{
    [self.editorPanelPopUpButton removeAllItems];
    
    for (NSMutableDictionary * itemDictionary in self.editorPanelsArray)
    {
        NSString * titleString = [itemDictionary objectForKey:@"title"];
        NSString * kindString = [itemDictionary objectForKey:@"kind"];
        
        [self.editorPanelPopUpButton addItemWithTitle:titleString];
        
        if ([kindString isEqualToString:@"disable"]  == YES)
        {
            NSMenuItem * menuItem = [self.editorPanelPopUpButton itemWithTitle:titleString];
            [menuItem setEnabled:NO];
        }
    }
}

//==================================================================================
//	setValidEditorsForXMLNode:elementName:attributeName:context:
//==================================================================================

- (void) setValidEditorsForXMLNode:(NSXMLNode *)node
        elementName:(NSString *)aElementName
        attributeName:(NSString *)aAttributeName context:(NSString *)aContext;
{
    //NSLog(@"setValidEditorsForXMLNode:%@ elementName:%@ attributeName:%@ context:%@", node, aElementName, aAttributeName, aContext);
    
    BOOL disableEditors = NO;
    
    if (node == NULL)
    {
        if (aElementName == NULL)
        {
            disableEditors = YES;
        }
        else
        {
            if ([aElementName length] == 0)
            {
                disableEditors = YES;
            }
        }
    }
    
    NSString * validContext = aContext;
    if ([validContext isEqualToString:@"attribute"] == YES)
    {
        if ([aAttributeName length] == 0)
        {
            validContext = @"element";
        }
    }
    
    if (disableEditors == YES)
    {
        [self buildEditorPanelsArrayForContext:@"disable"];
        [self.editorPanelPopUpButton selectItemAtIndex:0];
        [self setEmptyView];
    }
    else
    {
        [self buildEditorPanelsArrayForContext:validContext];
        
        NSXMLElement * selectedElement = NULL;
        if ([node kind] == NSXMLElementKind)
        {
            selectedElement = (NSXMLElement *)node;
        }
        else
        {
            NSXMLNode * nodeParent = [node parent];
            if ([nodeParent kind] == NSXMLElementKind)
            {
                selectedElement = (NSXMLElement *)nodeParent;
            }
        }

        self.elementName = aElementName;
        self.attributeName = aAttributeName;
        self.editorContext = validContext;
        
        if (aElementName == NULL)
        {
            NSLog(@"setValidEditorsForXMLNode:elementName:attributeName:context aElementName=NULL");
            self.elementName = @"";
        }
        
        if (aAttributeName == NULL)
        {
            self.attributeName = @"";
        }
        
        if ([self.elementName isEqualToString:@""] == YES)
        {
            if ([self.attributeName isEqualToString:@""] == YES)
            {
                // probably a newly-created element, check selected elements array
                SelectedElementsManager * selectedElementsManager =
                        self.macSVGDocumentWindowController.svgXMLDOMSelectionManager.selectedElementsManager;
                NSUInteger selectedItemsCount =
                        [selectedElementsManager selectedElementsCount];
                if (selectedItemsCount > 0)
                {
                    NSXMLElement * selectedXMLElement = [selectedElementsManager xmlElementAtIndex:0];
                    self.elementName = [selectedXMLElement name];
                }
                else
                {
                    NSLog(@"setValidEditorsForXMLNode:elementName:attributeName:context elementName='', attributeName=''");
                }
            }
        }
        
        NSMutableArray * pluginsArray = self.macSVGDocumentWindowController.pluginsArray;
        
        NSString * newCurrentEditor = NULL;
        NSString * newCurrentEditorKind = NULL;
        
        NSInteger bestEditorPriority = -1000;
        NSString * bestEditorName = @"";
        NSString * bestEditorKind = @"";

        if ([self.editorContext isEqualToString:@"tool"] == YES)
        {
            if ([self.elementName isEqualToString:@"plugin"] == YES)
            {
                NSLog(@"setValidEditorsForXMLNode:elementName:attributeName:context self.editorContext='tool' self.elementName='plugin'");
                newCurrentEditor = [self.editorPanelPopUpButton titleOfSelectedItem];
                newCurrentEditorKind = self.currentEditorKind;
                bestEditorName = newCurrentEditor;
                [self addEditorPanelItemWithTitle:newCurrentEditor kind:newCurrentEditorKind];
            }
            else if ([self.elementName isEqualToString:@""] == YES)
            {
                NSLog(@"setValidEditorsForXMLNode:elementName:attributeName:context self.editorContext='tool' self.elementName=''");
                newCurrentEditor = [self.editorPanelPopUpButton titleOfSelectedItem];
                newCurrentEditorKind = self.currentEditorKind;

                for (MacSVGPlugin * macSVGPlugin in pluginsArray)
                {
                    NSString * elementEditorLabel = [macSVGPlugin isEditorForElement:selectedElement elementName:self.elementName];
                            
                    if (elementEditorLabel != NULL)
                    {
                        // found a match for element tag name
                        newCurrentEditor = elementEditorLabel;
                        newCurrentEditorKind = @"element";
                        [self addEditorPanelItemWithTitle:newCurrentEditor kind:newCurrentEditorKind];
                        NSInteger editorPriority = [macSVGPlugin editorPriority:selectedElement context:@"tool"];
                        if (editorPriority > bestEditorPriority)
                        {
                            bestEditorName = newCurrentEditor;
                            bestEditorKind = newCurrentEditorKind;
                            bestEditorPriority = editorPriority;
                        }
                    }
                }
            }
            else
            {
                for (MacSVGPlugin * macSVGPlugin in pluginsArray)
                {
                    NSString * elementEditorLabel = [macSVGPlugin isEditorForElement:selectedElement elementName:self.elementName];
                            
                    if (elementEditorLabel != NULL)
                    {
                        // found a match for element tag name
                        newCurrentEditor = elementEditorLabel;
                        newCurrentEditorKind = @"element";
                        [self addEditorPanelItemWithTitle:newCurrentEditor kind:newCurrentEditorKind];
                        NSInteger editorPriority = [macSVGPlugin editorPriority:selectedElement context:@"tool"];
                        if (editorPriority > bestEditorPriority)
                        {
                            bestEditorName = newCurrentEditor;
                            bestEditorKind = newCurrentEditorKind;
                            bestEditorPriority = editorPriority;
                        }
                    }
                }
            }
        }
        else if ([self.editorContext isEqualToString:@"element"] == YES)
        {
            for (MacSVGPlugin * macSVGPlugin in pluginsArray)
            {
                NSString * elementEditorLabel = [macSVGPlugin isEditorForElement:selectedElement elementName:self.elementName];
                        
                if (elementEditorLabel != NULL)
                {
                    // found a match for element tag name
                    newCurrentEditor = elementEditorLabel;
                    newCurrentEditorKind = @"element";
                    [self addEditorPanelItemWithTitle:newCurrentEditor kind:newCurrentEditorKind];
                    NSInteger editorPriority = [macSVGPlugin editorPriority:selectedElement context:@"element"];
                    if (editorPriority > bestEditorPriority)
                    {
                        bestEditorName = newCurrentEditor;
                        bestEditorKind = newCurrentEditorKind;
                        bestEditorPriority = editorPriority;
                    }
                }
            }
        }
        else if ([self.editorContext isEqualToString:@"attribute"] == YES)
        {
            // add first add element editors
            NSString * bestElementEditorName = bestEditorName;
            NSString * bestElementEditorKind = bestEditorKind;
            NSInteger bestElementEditorPriority = bestEditorPriority;
            
            for (MacSVGPlugin * macSVGPlugin in pluginsArray)
            {
                NSString * elementEditorLabel = [macSVGPlugin isEditorForElement:selectedElement elementName:self.elementName];
                        
                if (elementEditorLabel != NULL)
                {
                    // found a match for element tag name
                    //newCurrentEditor = @"Element Editor Plug-in";
                    newCurrentEditor = elementEditorLabel;
                    newCurrentEditorKind = @"element";
                    [self addEditorPanelItemWithTitle:newCurrentEditor kind:newCurrentEditorKind];
                    NSInteger editorPriority = [macSVGPlugin editorPriority:selectedElement context:@"attribute"];
                    if (editorPriority > bestElementEditorPriority)
                    {
                        bestElementEditorName = newCurrentEditor;
                        bestElementEditorKind = newCurrentEditorKind;
                        bestElementEditorPriority = editorPriority;
                    }
                }
            }

            // add attribute editors after element editors
            for (MacSVGPlugin * macSVGPlugin in pluginsArray)
            {
                NSString * attributeEditorLabel = [macSVGPlugin isEditorForElement:selectedElement elementName:self.elementName
                        attribute:self.attributeName];
                        
                if (attributeEditorLabel != NULL)
                {
                    // found a match
                    //newCurrentEditor = @"Attribute Editor Plug-in";
                    newCurrentEditor = attributeEditorLabel;
                    newCurrentEditorKind = @"attribute";
                    [self addEditorPanelItemWithTitle:newCurrentEditor kind:newCurrentEditorKind];
                    NSInteger attributePriority = [macSVGPlugin editorPriority:selectedElement context:@"attribute"];
                    if (attributePriority > bestEditorPriority)
                    {
                        bestEditorName = newCurrentEditor;
                        bestEditorKind = newCurrentEditorKind;
                        bestEditorPriority = attributePriority;
                    }
                }
            }
            
            if (bestEditorPriority < 0)
            {
                if (bestElementEditorPriority >= 0)
                {
                    bestEditorName = bestElementEditorName;
                    bestEditorKind = bestElementEditorKind;
                    bestEditorPriority = bestElementEditorPriority;
                }
            }
            
            if ([bestEditorName length] == 0)
            {
                newCurrentEditor = @"Attribute Editor";
                newCurrentEditorKind = @"main";
                if (bestEditorPriority < 0)
                {
                    bestEditorName = newCurrentEditor;
                    bestEditorKind = newCurrentEditorKind;
                    bestEditorPriority = 0;
                    [self addEditorPanelItemWithTitle:bestEditorName kind:bestEditorKind];
                }
            }
        }
        else if ([self.editorContext isEqualToString:@"text"] == YES)
        {
            newCurrentEditor = @"Text Content Editor";
            newCurrentEditorKind = @"main";
            if (bestEditorPriority < 0)
            {
                bestEditorName = newCurrentEditor;
                bestEditorKind = newCurrentEditorKind;
                bestEditorPriority = 0;
                [self addEditorPanelItemWithTitle:bestEditorName kind:bestEditorKind];
            }
        }

        if ([bestEditorName length] > 0)
        {
            [self setCurrentEditor:bestEditorName kind:bestEditorKind];
        }
        else
        {
            bestEditorName = @"Valid Attributes";
            bestEditorKind = @"main";
            [self setCurrentEditor:bestEditorName kind:bestEditorKind];
        }
        
        if ([bestEditorName isEqualToString:@""] == YES)
        {
            NSLog(@"setValidEditorsForXMLNode:elementName:attributeName:context bestEditorName=''");
        }
        
        [self.editorPanelPopUpButton selectItemWithTitle:bestEditorName];
    }
}

@end
