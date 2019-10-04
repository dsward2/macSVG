//
//  ElementEditorPlugInController.m
//  macSVG
//
//  Created by Douglas Ward on 3/2/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "ElementEditorPlugInController.h"
#import "EditorUIFrameController.h"
#import "MacSVGAppDelegate.h"
#import "MacSVGPlugin/MacSVGPlugin.h"
#import "MacSVGDocument.h"
#import "MacSVGDocumentWindowController.h"
#import "SVGWebKitController.h"
#import "SVGWebView.h"
#import "DOMMouseEventsController.h"
#import "XMLAttributesTableController.h"
#import "XMLAttributesTableView.h"
#import "SVGDTDData.h"
#import "SVGXMLDOMSelectionManager.h"
#import "XMLOutlineController.h"

@implementation ElementEditorPlugInController

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.currentXmlElement = NULL;
    self.currentElementName = NULL;
    self.currentPlugin = NULL;
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init 
{
    if ((self = [super init])) 
    {
        self.currentXmlElement = NULL;
        self.currentElementName = NULL;
        self.currentPlugin = NULL;
    }
    return self;
}

// ================================================================

-(void)removeOldPluginView
{
    if (self.currentPlugin != NULL)
    {
        [self.currentPlugin endEdit];
    }

    [self.pluginHostScrollView setDocumentView:NULL];

    self.currentXmlElement = NULL;
    self.currentElementName = NULL;
    self.currentPlugin = NULL;
}

// ================================================================

-(void)setEnabled:(BOOL)enabled
{
    if (enabled == YES)
    {
        if (elementEditorPlugInView.superview == NULL) 
        {
            NSView * editorPanelFrameView = editorUIFrameController.editorPanelFrameView;
            if (editorPanelFrameView != NULL)
            {
                NSRect frameRect = editorPanelFrameView.frame;
                elementEditorPlugInView.frame = frameRect;
                elementEditorPlugInView.bounds = frameRect;
            
                [editorPanelFrameView addSubview:elementEditorPlugInView];
            }
        }
    }
    else
    {
        [elementEditorPlugInView removeFromSuperview];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

// ================================================================

- (void) handlePluginEvent:(DOMEvent *)event
{
    if (self.currentPlugin != NULL)
    {
        if ([self.currentPlugin respondsToSelector:@selector(handlePluginEvent:)] == YES)
        {
            [self.currentPlugin handlePluginEvent:event];
        }
    }
}

// ================================================================

- (void)loadElementEditorPlugIn:(NSString *)selectedElementEditorPlugIn
{
    BOOL loadNewPlugin = YES;

    MacSVGDocumentWindowController * macSVGDocumentWindowController =
            editorUIFrameController.macSVGDocumentWindowController;
    MacSVGDocument * macSVGDocument = macSVGDocumentWindowController.document;
    NSMutableArray * pluginsArray = macSVGDocumentWindowController.pluginsArray;

    XMLAttributesTableController * xmlAttributesTableController =
            macSVGDocumentWindowController.xmlAttributesTableController;

    NSXMLElement * xmlElementForAttributes = [xmlAttributesTableController xmlElementForAttributesTable];
    
    NSString * currentElementName = xmlElementForAttributes.name;

    if (xmlElementForAttributes != NULL)
    {
        NSString * elementName = xmlElementForAttributes.name;

        if ([elementName isEqualToString:currentElementName] == NO)
        {
            [self removeOldPluginView];
            loadNewPlugin = NO;
        }
    }

    if (xmlElementForAttributes != self.currentXmlElement)
    {
        [self removeOldPluginView];
        //loadNewPlugin = NO;
    }

    if ([selectedElementEditorPlugIn isEqualToString:@""] == YES)
    {
        loadNewPlugin = NO;
    }
    
    if (self.currentPlugin != NULL)
    {
        NSString * currentPluginName = [self.currentPlugin pluginName];
        if ([selectedElementEditorPlugIn isEqualToString:currentPluginName] == YES)
        {
            loadNewPlugin = NO;
        }
    }
    
    if (loadNewPlugin == YES)
    {
        [self removeOldPluginView];
                        
        MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)NSApp.delegate;
        SVGDTDData * svgDtdData = macSVGAppDelegate.svgDtdData;
        NSMutableDictionary * elementsDictionary = svgDtdData.elementsDictionary;
        NSMutableDictionary * elementContentsDictionary = svgDtdData.elementContentsDictionary;
        id svgXmlOutlineView =
                macSVGDocumentWindowController.xmlOutlineController.xmlOutlineView;
        WebView * svgWebView = macSVGDocumentWindowController.svgWebKitController.svgWebView;

        for (MacSVGPlugin * macSVGPlugin in pluginsArray)
        {
            [macSVGPlugin setMacSVGDocument:macSVGDocument
                    svgXmlOutlineView:svgXmlOutlineView
                    svgWebView:svgWebView
                    webKitInterface:macSVGAppDelegate.webKitInterface
                    elementsDictionary:elementsDictionary
                    elementContentsDictionary:elementContentsDictionary];
            
            NSString * pluginName = macSVGPlugin.pluginName;
            
            if ([selectedElementEditorPlugIn isEqualToString:pluginName] == YES)
            {
                [macSVGPlugin loadPluginViewInScrollView:self.pluginHostScrollView];
                 
                XMLAttributesTableController * xmlAttributesTableController = 
                        macSVGDocumentWindowController.xmlAttributesTableController;
                
                NSXMLElement * xmlElementForAttributes =
                        [xmlAttributesTableController xmlElementForAttributesTable];
                        
                SVGWebKitController * svgWebKitController = macSVGDocumentWindowController.svgWebKitController;
                
                NSXMLNode * MacsvgidNode = [xmlElementForAttributes attributeForName:@"macsvgid"];
                NSString * macsvgid = MacsvgidNode.stringValue;
                
                DOMElement * domElementForAttributes =
                        [svgWebKitController domElementForMacsvgid:macsvgid];
                                                
                [macSVGPlugin beginEditForXMLElement:xmlElementForAttributes domElement:domElementForAttributes];

                self.currentPlugin = macSVGPlugin;
                
                break;
            }
        }
    }
}

#pragma clang diagnostic pop

//==================================================================================
//	contextMenuItemsForPlugin
//==================================================================================

- (NSMutableArray *) contextMenuItemsForPlugin
{
    NSMutableArray * result = [NSMutableArray array];

    if (self.currentPlugin != NULL)
    {
        if ([self.currentPlugin respondsToSelector:@selector(contextMenuItemsForPlugin)] == YES)
        {
            result = [self.currentPlugin contextMenuItemsForPlugin];
        }
    }
    
    return result;
}


@end
