//
//  MacSVGPlugin.m
//  MacSVGPlugin
//
//  Created by Douglas Ward on 1/5/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "MacSVGPlugin.h"
#import "MacSVGPluginCallbacks.h"

#import "WebKitInterface.h"

#import <objc/message.h>


@implementation MacSVGPlugin

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.pluginView = NULL;
    self.webKitInterface = NULL;
}

//==================================================================================
//	initialize
//==================================================================================

+(void)initialize
{
    Class myClass = [self class];
    NSString * myClassName = [myClass className];
    
    // load the MacSVGPlugin.framework from the application bundle
    NSBundle * mainBundle = [NSBundle mainBundle];
    NSString * mainBundlePath = mainBundle.bundlePath;

    NSString * frameworkPathExtension = 
            @"Contents/Frameworks/MacSVGPlugin.framework";

    NSString * frameworkPath = [mainBundlePath 
            stringByAppendingPathComponent:frameworkPathExtension];
                        
    NSBundle * framework = [NSBundle bundleWithPath:frameworkPath];
    
    if (framework != NULL)
    {  
        if([framework load])
        {
            //NSLog(@"%@ - MacSVGPlugin Framework loaded", myClassName);
        }
        else
        {
            NSLog(@"%@ - Error, MacSVGPlugin framework failed to load", myClassName);
        }
    }
    else
    {
        NSLog(@"%@ - Error, MacSVGPlugin framework bundle not found", myClassName);
    }
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.svgXmlDocument = NULL;
        self.svgWebView = NULL;
        self.editingIsActive = NO;
    }
    
    return self;
}

//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    // Plugin implementations must override this
    return @"Unknown Plugin";
}

//==================================================================================
//	setMacSVGDocument:webKitInterface:elementsDictionary:elementContentsDictionary:
//==================================================================================

- (void)setMacSVGDocument:(id)aMacSVGDocument
        svgXmlOutlineView:(id)aSvgXmlOutlineView
        svgWebView:(id)aSvgWebView
        webKitInterface:(id)aWebKitInterface
        elementsDictionary:(NSMutableDictionary *)aElementsDictionary   // dictionary of valid attributes for defined elements
        elementContentsDictionary:(NSMutableDictionary *)aElementsContentsDictionary   // dictionary of valid child elements for defined elements
{
    [self setMacSVGDocumentObject:aMacSVGDocument];
    self.svgXmlOutlineView = aSvgXmlOutlineView;
    self.svgWebView = aSvgWebView;
    self.globalContext = [aSvgWebView mainFrame].globalContext;
    self.webKitInterface = aWebKitInterface;
    self.elementsDictionary = aElementsDictionary;
    self.elementContentsDictionary = aElementsContentsDictionary;
}

//==================================================================================
//	setMacSVGDocumentObject
//==================================================================================

- (void)setMacSVGDocumentObject:(id)aMacSVGDocument
{
    self.macSVGDocument = aMacSVGDocument;
    
    NSXMLDocument * aSvgXmlDocument = NULL;
    id aMacSVGDocumentWindowController = NULL;
    id aSvgWebKitController = NULL;

    if (aMacSVGDocument != NULL)
    {
        self.macSVGPluginCallbacks = [self.macSVGDocument macSVGPluginCallbacks];
        
        aSvgXmlDocument = [self.macSVGPluginCallbacks svgXmlDocument];
        aMacSVGDocumentWindowController = [self.macSVGPluginCallbacks macSVGDocumentWindowController];
        aSvgWebKitController = [self.macSVGPluginCallbacks svgWebKitController];
    }

    self.svgXmlDocument = aSvgXmlDocument;
    self.editingIsActive = NO;
    self.pluginTargetXMLElement = NULL;
    self.pluginTargetDOMElement = NULL;

}

//==================================================================================
//	loadPluginViewInScrollView:
//==================================================================================

- (BOOL)loadPluginViewInScrollView:(NSScrollView *)scrollView
{
    BOOL result = NO;
        
    if (self.pluginView == NULL)
    {
        NSString * pluginNameString = self.className;
        NSArray * topLevelObjects = NULL;

        NSString * bundlePath = [NSBundle bundleForClass:[self class]].bundlePath;

        NSBundle * pluginBundle = [NSBundle bundleWithPath:bundlePath];

        result = [pluginBundle loadNibNamed:pluginNameString owner:self topLevelObjects:&topLevelObjects];
    }

    scrollView.verticalScroller.floatValue = 0;

    scrollView.documentView = self.pluginView;

    [self resizePluginViewSizeForScrollView:scrollView];
    
    scrollView.verticalScroller.floatValue = 0;
    
    return result;
}

//==================================================================================
//	unloadPluginView
//==================================================================================

- (void)unloadPluginView
{
    [self.pluginView removeFromSuperview];
    self.pluginView = NULL;
}

//==================================================================================
//	dealloc
//==================================================================================

//==================================================================================
//	pluginMenuTitle
//==================================================================================

- (NSString *)pluginMenuTitle
{
    return NULL;    // override for menu plugins
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element and node kind, e.g. NSXMLTextKind
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    NSString * result = NULL;

    return result;
}

//==================================================================================
//	isEditorForElement:elementName:attribute:
//==================================================================================

// return label if this editor can edit specified element and attribute
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
        attribute:(NSString *)attributeName
{   
    NSString * result = NULL;

    return result;
}

//==================================================================================
//	editorPriority
//==================================================================================

- (NSInteger)editorPriority:(NSXMLElement *)targetElement context:(NSString *)context
{
    // subclasses should override this lowest rank for editor selection for a newly-selected element or attribute
    return 0;
}

//==================================================================================
//	beginEditForXMLElement:domElement:attributeName:existingValue:
//==================================================================================

- (BOOL)beginEditForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetDOMElement
        attributeName:(NSString *)newAttributeName
        existingValue:(NSString *)existingValue
{
    // for attribute editor plug-ins
    self.editingIsActive = YES;
    self.pluginTargetXMLElement = newPluginTargetXMLElement;
    self.pluginTargetDOMElement = newPluginTargetDOMElement;
    self.activeAttributeName = newAttributeName;

    return YES;
}

//==================================================================================
//	beginEditForXMLElement:domElement:
//==================================================================================

- (BOOL)beginEditForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetDOMElement
{
    // for element editor plug-ins
    self.editingIsActive = YES;
    self.pluginTargetXMLElement = newPluginTargetXMLElement;
    self.pluginTargetDOMElement = newPluginTargetDOMElement;
    self.activeAttributeName = NULL;

    return YES;
}

//==================================================================================
//	updateEditForXMLElement:domElement:info:
//==================================================================================

- (void)updateEditForXMLElement:(NSXMLElement *)xmlElement domElement:(DOMElement *)domElement info:(id)infoData
{
    // subclasses can override as needed
}

//==================================================================================
//	beginMenuPlugIn
//==================================================================================

- (BOOL)beginMenuPlugIn
{
    // start menu plug-ins
    
    return YES;
}

//==================================================================================
//	endMenuPlugIn
//==================================================================================

- (void)endMenuPlugIn
{
    // call when menu plug-in is finished
}

//==================================================================================
//	isMenuPlugIn
//==================================================================================

- (BOOL) isMenuPlugIn
{
    return NO;
}

//==================================================================================
//	updateDocumentViews
//==================================================================================

- (void)updateDocumentViews
{
    [self.macSVGPluginCallbacks updateSelections];

    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    [macSVGDocumentWindowController reloadAllViews];
}

//==================================================================================
//	endEdit
//==================================================================================

- (void)endEdit
{
    self.editingIsActive = NO;
    self.pluginTargetXMLElement = NULL;
    self.pluginTargetDOMElement = NULL;
}

//==================================================================================
//	closePath
//==================================================================================

- (void)closePath
{
    // for use by PathElementEditor
}

//==================================================================================
//	elementsWithAttribute:
//==================================================================================

- (NSMutableDictionary *)elementsWithAttribute:(NSString *)attributeName;
{
    // given an attribute name, return a dictionary of elements containing that attribute per the SVG DTD
    return [self.macSVGDocument elementsWithAttribute:attributeName];
}

//==================================================================================
//	resizePluginViewSizeForScrollView
//==================================================================================

- (void)resizePluginViewSizeForScrollView:(NSScrollView *)scrollView
{
/*
    NSView * documentView = [scrollView documentView];
    NSView * contentView = [scrollView contentView];

    NSLog(@"scrollView frameRect %f, %f, %f %f",
            scrollView.frame.origin.x,
            scrollView.frame.origin.y,
            scrollView.frame.size.width,
            scrollView.frame.size.height);
    
    NSLog(@"scrollView boundsRect %f, %f, %f %f",
            scrollView.bounds.origin.x,
            scrollView.bounds.origin.y,
            scrollView.bounds.size.width,
            scrollView.bounds.size.height);

    NSLog(@"contentView frameRect %f, %f, %f %f",
            contentView.frame.origin.x,
            contentView.frame.origin.y,
            contentView.frame.size.width,
            contentView.frame.size.height);
    
    NSLog(@"contentView boundsRect %f, %f, %f %f",
            contentView.bounds.origin.x,
            contentView.bounds.origin.y,
            contentView.bounds.size.width,
            contentView.bounds.size.height);

    NSLog(@"pluginView controller %@", [self className]);

    NSLog(@"pluginView frameRect %f, %f, %f %f",
            self.pluginView.frame.origin.x,
            self.pluginView.frame.origin.y,
            self.pluginView.frame.size.width,
            self.pluginView.frame.size.height);
    
    NSLog(@"pluginView boundsRect %f, %f, %f %f",
            self.pluginView.bounds.origin.x,
            self.pluginView.bounds.origin.y,
            self.pluginView.bounds.size.width,
            self.pluginView.bounds.size.height);
*/

    // resize pluginView to fit width of container

    NSRect viewFrame = scrollView.frame;
    NSRect viewBounds = scrollView.bounds;
    
    viewFrame.size.height = self.pluginView.frame.size.height;
    viewBounds.size.height = self.pluginView.bounds.size.height;
    
    NSScroller * verticalScroller = scrollView.verticalScroller;
    NSRect verticalScrollerBounds = verticalScroller.bounds;
    
    viewFrame.size.width -= verticalScrollerBounds.size.width;
    viewBounds.size.width -= verticalScrollerBounds.size.width;
    
    self.pluginView.frame = viewFrame;
    self.pluginView.bounds = viewBounds;
}

//==================================================================================
//	assignMacsvgidsForNode:
//==================================================================================

-(void)assignMacsvgidsForNode:(NSXMLNode *)aNode
{
    if (aNode.kind == NSXMLElementKind)
    {
        NSXMLElement * aXmlElement = (NSXMLElement *)aNode;
        NSXMLNode * macsvgid = [aXmlElement attributeForName:@"macsvgid"];
        if (macsvgid == NULL)
        {
            NSString * guid = [NSProcessInfo processInfo].globallyUniqueString;
            macsvgid = [NSXMLNode attributeWithName:@"macsvgid" stringValue:guid];
            [aXmlElement addAttribute:macsvgid];
        }
    }
    
    NSArray * children = aNode.children;
    for (id childNode in children)
    {
        [self assignMacsvgidsForNode:childNode];   // recursive call
    }
}


//==================================================================================
//	floatFromString:
//==================================================================================

-(float) floatFromString:(NSString *)valueString
{
    float floatValue = 0;
    
    NSMutableString * trimmedString = [[NSMutableString alloc] init];
    
    NSUInteger inputLength = valueString.length;
    for (int i = 0; i < inputLength; i++)
    {
        unichar aChar = [valueString characterAtIndex:i];
        
        BOOL validChar = YES;
        
        if (aChar < '0') validChar = NO;
        if (aChar > '9') validChar = NO;
        if (aChar == '.') validChar = YES;
        if (aChar == '-') validChar = YES;
        
        if (validChar == NO) 
        {
            break;
        }
        
        NSString * charString = [[NSString alloc] initWithFormat:@"%C", aChar];
        
        [trimmedString appendString:charString];
        
    }
    
    floatValue = trimmedString.floatValue;
    
        
    return floatValue;
}

//==================================================================================
//	allocFloatString:
//==================================================================================

- (NSMutableString *)allocFloatString:(float)aFloat
{
    NSMutableString * aString = [[NSMutableString alloc] initWithFormat:@"%f", aFloat];

    BOOL continueTrim = YES;
    while (continueTrim == YES)
    {
        NSUInteger stringLength = aString.length;
        
        if (stringLength <= 1)
        {
            continueTrim = NO;
        }
        else
        {
            unichar lastChar = [aString characterAtIndex:(stringLength - 1)];
            
            if (lastChar == '0')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
            }
            else if (lastChar == '.')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
                continueTrim = NO;
            }
            else
            {
                continueTrim = NO;
            }
        }
    }
    return aString;
}

//==================================================================================
//	allocPxString:
//==================================================================================

- (NSMutableString *)allocPxString:(float)aFloat
{
    NSMutableString * aString = [[NSMutableString alloc] initWithFormat:@"%f", aFloat];

    BOOL continueTrim = YES;
    while (continueTrim == YES)
    {
        NSUInteger stringLength = aString.length;
        
        if (stringLength <= 1)
        {
            continueTrim = NO;
        }
        else
        {
            unichar lastChar = [aString characterAtIndex:(stringLength - 1)];
            
            if (lastChar == '0')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
            }
            else if (lastChar == '.')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
                continueTrim = NO;
            }
            else
            {
                continueTrim = NO;
            }
        }
    }
    
    [aString appendString:@"px"];
    
    return aString;
}

//==================================================================================
//	isValidMenuItemSelection
//==================================================================================

- (BOOL)isValidMenuItemSelection
{
    return YES;
}

//==================================================================================
//	contextMenuItemsForPlugin
//==================================================================================

- (NSMutableArray *) contextMenuItemsForPlugin
{
    // override to customize contextual menu for right-click in web view
    NSMutableArray * result = [NSMutableArray array];
    
    return result;
}

//==================================================================================
//	addPluginSelectionHandlesWithDOMElement:handlesGroup:
//==================================================================================

-(void) addPluginSelectionHandlesWithDOMElement:(DOMElement *)aDomElement
        handlesGroup:(DOMElement *)newSelectionHandlesGroup
{
    // override to customize handles for plugin
}

//==================================================================================
//	logStackSymbols
//==================================================================================

- (void)logStackSymbols:(NSString *)messagePrefix
{
    NSArray * stackSymbols = [NSThread callStackSymbols];

    NSMutableArray * filteredStackSymbols = [NSMutableArray array];
    
    NSInteger lineIndex = 0;
    
    for (NSString * aStackString in stackSymbols)
    {
        NSMutableString * outputString = [NSMutableString stringWithString:aStackString];
        
        // 0   macSVG                        0x00000001000354ee -[SVGWebKitController logStackSymbols:] + 78,
        // 0....5...10...15...20...25...30...35...40...45...50...55...60
        NSRange deleteRange = NSMakeRange(4, 55);
        [outputString deleteCharactersInRange:deleteRange];
        
        [filteredStackSymbols addObject:outputString];
        
        lineIndex++;
    }
    
    NSLog(@"%@\n%@", messagePrefix, filteredStackSymbols);
}



@end
