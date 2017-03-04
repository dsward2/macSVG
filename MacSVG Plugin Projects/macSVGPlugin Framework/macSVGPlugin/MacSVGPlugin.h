//
//  MacSVGPlugin.h
//  MacSVGPlugin
//
//  Created by Douglas Ward on 1/5/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//
//  Three types of plug-ins are defined:
//  - Element editor plug-ins
//  - Attribute editor plug-ins
//  - Menu plug-ins

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class WebView;
@class MacSVGPluginCallbacks;
@class DOMElement;
@class WebKitInterface;

@interface MacSVGPlugin : NSObject
{
}

@property(strong) IBOutlet NSView * pluginView;
@property(strong) IBOutlet NSPanel * panelForMenuPlugIn;    // used only for menu plug-ins

@property(strong) id macSVGDocument;             // the MacSVGDocument host for this plugin

@property(strong) NSXMLDocument * svgXmlDocument;     // the master copy of the data, apply changes here
@property(strong) NSOutlineView * svgXmlOutlineView;
@property(strong) WebView * svgWebView;               // derived from xml document, ok for temporary modifications
    
@property(strong) NSXMLElement * pluginTargetXMLElement;    // the XML element currently edited
@property(strong) DOMElement * pluginTargetDOMElement;      // the DOM element corresponding to pluginTargetXMLElement
    
@property(strong) NSString * activeAttributeName;     // the name of the attribute currently edited, if applicable
    
@property(assign) BOOL editingIsActive;               // YES if this plugin is currently in an editing session

    // A couple of useful shared dictionaries constructed from the SVG 1.1 XML DTD
@property(strong) NSMutableDictionary * elementsDictionary; // valid element tag names, attributes and values
@property(strong) NSMutableDictionary * elementContentsDictionary; // valid child elements per parent element
    
@property(strong) MacSVGPluginCallbacks * macSVGPluginCallbacks;
@property(strong) WebKitInterface * webKitInterface;
@property(assign) JSContextRef globalContext;

@property (readonly, copy) NSString *pluginName;

- (void)setMacSVGDocumentObject:(id)aMacSVGDocument;

- (BOOL)loadPluginViewInScrollView:(NSScrollView *)scrollView;

- (void)unloadPluginView;

// Override and return a label if this editor is for Plug-Ins menu
@property (readonly, copy) NSString *pluginMenuTitle;

// Override and return a label if this editor can edit specified element tag name, or nil if not applicable
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName;

// Override and return a label if this editor can edit specified attribute for specified element,
// or nil if not applicable
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
        attribute:(NSString *)attributeName;

// Used to determine the initial editor shown for a newly-selected element or attribute.
// Most subclasses should return a value greater than 0.
// The value 10 is generally for special-purpose editors, e.g. path animation
// The value 30 or greater is mostly for common general element and attributes, e.g. rect, stroke-width, etc.
// Typical context values are "element", "attribute", "tool", or "none" if no element is selected
- (NSInteger)editorPriority:(NSXMLElement *)targetElement context:(NSString *)context;

// Attribute editor plugin implementations can call this method to obtain a list of elements where the attribute is valid
- (NSMutableDictionary *)elementsWithAttribute:(NSString *)attributeName;

// Plugin subclasses probably don't need to override this method
- (void)setMacSVGDocument:(id)aMacSVGDocument
        svgXmlOutlineView:(id)aSvgXmlOutlineView
        svgWebView:(id)aSvgWebView
        webKitInterface:(id)aWebKitInterface
        elementsDictionary:(NSMutableDictionary *)aElementsDictionary   // dictionary of valid attributes for defined elements
        elementContentsDictionary:(NSMutableDictionary *)aElementsContentsDictionary;   // dictionary of valid child elements for defined elements

// For element editors and text nodes, override this method to begin plugin session
- (BOOL)beginEditForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetDOMElement;

// For attribute editors, override this method to begin plugin session
- (BOOL)beginEditForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetDOMElement
        attributeName:(NSString *)attributeName 
        existingValue:(NSString *)existingValue;

// Update the display, usually called by host application when a change occurred there
- (void)updateEditForXMLElement:(NSXMLElement *)xmlElement domElement:(DOMElement *)domElement info:(id)infoData;

// For menu plug-ins, override this method to begin plugin session
@property (readonly) BOOL beginMenuPlugIn;

// Plugin implementations should call this method after changes are applied to update the host application user interfaces
- (void)updateDocumentViews;

// Plugin implementations should override this method to be notified when the host application is ending the plugin's session
- (void)endEdit;

// Used for automatic path closing
- (void)closePath;

// Plugin implementations should override this method to be notified when the host application is resizing the plugin panel in it's scrollview
- (void)resizePluginViewSizeForScrollView:(NSScrollView *)scrollView;

@property (getter=isMenuPlugIn, readonly) BOOL menuPlugIn;

- (void)assignMacsvgidsForNode:(NSXMLNode *)aNode;  // for plug-ins that create new elements, call after creation

-(float) floatFromString:(NSString *)valueString;
- (NSMutableString *)allocFloatString:(float)aFloat;
- (NSMutableString *)allocPxString:(float)aFloat;

@property (getter=isValidMenuItemSelection, readonly) BOOL validMenuItemSelection;

// Customize contextual menu for right-clicks in web view
- (NSMutableArray *) contextMenuItemsForPlugin;

@end
