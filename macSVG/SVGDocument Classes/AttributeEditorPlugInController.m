//
//  AttributeEditorPlugInController.m
//  macSVG
//
//  Created by Douglas Ward on 1/1/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "AttributeEditorPlugInController.h"
#import "EditorUIFrameController.h"
#import "MacSVGAppDelegate.h"
#import "MacSVGPlugin/MacSVGPlugin.h"
#import "MacSVGDocument.h"
#import "MacSVGDocumentWindowController.h"
#import "SVGXMLDOMSelectionManager.h"
#import "SVGWebKitController.h"
#import "SVGWebView.h"
#import "DOMMouseEventsController.h"
#import "XMLAttributesTableController.h"
#import "XMLAttributesTableView.h"
#import "SVGDTDData.h"
#import "XMLOutlineController.h"

@implementation AttributeEditorPlugInController

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.currentXMLElementForAttribute = NULL;
    self.currentAttributeName = NULL;
    self.currentPlugin = NULL;
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init {
    if ((self = [super init])) 
    {
        self.currentXMLElementForAttribute = NULL;
        self.currentAttributeName = NULL;
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
        
    self.currentXMLElementForAttribute = NULL;
    self.currentAttributeName = NULL;
    self.currentPlugin = NULL;
}

// ================================================================

-(void)setEnabled:(BOOL)enabled
{
    if (enabled == YES)
    {
        if (attributeEditorPlugInView.superview == NULL) 
        {
            NSView * attributeEditorFrameView = editorUIFrameController.editorPanelFrameView;
            if (attributeEditorFrameView != NULL)
            {
                NSRect frameRect = attributeEditorFrameView.frame;
                attributeEditorPlugInView.frame = frameRect;
                attributeEditorPlugInView.bounds = frameRect;
                
                [attributeEditorFrameView addSubview:attributeEditorPlugInView];
            }
        }
    }
    else
    {
        [attributeEditorPlugInView removeFromSuperview];
    }
}

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

- (void)loadAttributeEditorPlugIn:(NSString *)selectedAttributeEditorPlugIn
{
    BOOL loadNewPlugin = YES;

    NSString * attributeName = NULL;
    NSString * attributeValue = NULL;
    NSString * attributeKind = NULL;
    
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
        XMLAttributesTableView * xmlAttributesTableView =
                xmlAttributesTableController.xmlAttributesTableView;
                
        NSInteger selectedRow = xmlAttributesTableView.selectedRow;

        if (selectedRow == -1)
        {
            // no attribute is selected
            [self removeOldPluginView];
            loadNewPlugin = NO;
        }
        else
        {
            // an attribute is selected
            NSString * elementName = xmlElementForAttributes.name;

            NSMutableArray * xmlAttributesArray = 
                    xmlAttributesTableController.xmlAttributesArray;
            
            NSMutableDictionary * xmlAttributeDictionary = 
                    xmlAttributesArray[selectedRow];
            
            attributeName = xmlAttributeDictionary[@"name"];
            attributeValue = xmlAttributeDictionary[@"value"];
            attributeKind = xmlAttributeDictionary[@"kind"];
            
            if (xmlElementForAttributes != self.currentXMLElementForAttribute)
            {
                [self removeOldPluginView];
            }
            if ([elementName isEqualToString:currentElementName] == NO)
            {
                [self removeOldPluginView];
            }
            if ([attributeName isEqualToString:self.currentAttributeName] == NO)
            {
                [self removeOldPluginView];
            }
        }
    }

    if ([selectedAttributeEditorPlugIn isEqualToString:@""] == YES)
    {
        loadNewPlugin = NO;
        [self removeOldPluginView];
    }
    
    if (self.currentPlugin != NULL)
    {
        NSString * currentPluginName = [self.currentPlugin pluginName];
        if ([selectedAttributeEditorPlugIn isEqualToString:currentPluginName] == YES)
        {
            //loadNewPlugin = NO;
            if (xmlElementForAttributes == self.currentXMLElementForAttribute)
            {
                loadNewPlugin = NO;


                XMLAttributesTableController * xmlAttributesTableController =
                        macSVGDocumentWindowController.xmlAttributesTableController;
                
                NSXMLElement * xmlElementForAttributes =
                        [xmlAttributesTableController xmlElementForAttributesTable];
                        
                SVGWebKitController * svgWebKitController = macSVGDocumentWindowController.svgWebKitController;
                
                NSXMLNode * MacsvgidNode = [xmlElementForAttributes attributeForName:@"macsvgid"];
                NSString * macsvgid = MacsvgidNode.stringValue;
                
                DOMElement * domElementForAttributes =
                        [svgWebKitController domElementForMacsvgid:macsvgid];
                        
                [self.currentPlugin beginEditForXMLElement:xmlElementForAttributes domElement:domElementForAttributes
                        attributeName:attributeName existingValue:attributeValue];

                self.currentXMLElementForAttribute = xmlElementForAttributes;
                self.currentAttributeName = attributeName;
            }
        }
    }
    
    if (loadNewPlugin == YES)
    {
        [self removeOldPluginView];
                        
        if (xmlElementForAttributes != NULL)
        {
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
                        
                if ([selectedAttributeEditorPlugIn isEqualToString:pluginName] == YES)
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
                            
                    [macSVGPlugin beginEditForXMLElement:xmlElementForAttributes domElement:domElementForAttributes 
                            attributeName:attributeName existingValue:attributeValue];

                    self.currentXMLElementForAttribute = xmlElementForAttributes;
                    self.currentAttributeName = attributeName;
                    self.currentPlugin = macSVGPlugin;
                    
                    break;
                }
            }
        }
    }
}

@end
