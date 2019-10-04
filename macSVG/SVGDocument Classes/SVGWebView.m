//
//  SVGWebView.m
//  macSVG
//
//  Created by Douglas Ward on 9/30/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "SVGWebView.h"
#import "XMLOutlineController.h"
#import "MacSVGDocument.h"
#import "MacSVGDocumentWindowController.h"
#import "SVGWebKitController.h"
#import "NSOutlineView_Extensions.h"
#import "MacSVGAppDelegate.h"
#import "SVGDTDData.h"
#import "ToolSettingsPopoverViewController.h"
#import "HorizontalRulerView.h"
#import "VerticalRulerView.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation SVGWebView


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.drawsBackground = NO;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        // Initialization code here.
        self.drawsBackground = NO;
    }
    
    return self;
}


- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code here.
        self.drawsBackground = NO;
    }
    
    return self;
}


- (void) awakeFromNib
{
    [super awakeFromNib];

    self.zoomFactor = 1.0f;

    self.drawsBackground = NO;
    
    [self setAcceptsTouchEvents:NO];

    [self registerForDraggedTypes:@[XML_OUTLINE_PBOARD_TYPE, 
                                    NSPasteboardTypeURL, 
                                    NSPasteboardTypeString, 
            NSFilenamesPboardType, 
                                    NSPasteboardTypeTIFF]];

    self.postsFrameChangedNotifications = YES;
    self.postsBoundsChangedNotifications = YES;

    WebFrame * mainFrame = self.mainFrame;
    NSScrollView * webScrollView = [[[mainFrame frameView] documentView] enclosingScrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(webViewSizeChanged:)
            name:NSViewBoundsDidChangeNotification
            object:webScrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(webViewSizeChanged:)
            name:NSViewFrameDidChangeNotification
            object:webScrollView];
}


- (void)webViewSizeChanged:(NSNotification *)notification
{
    [macSVGDocumentWindowController.verticalRulerView createRulerWebView];
    [macSVGDocumentWindowController.horizontalRulerView createRulerWebView];
}


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender 
{
    //NSPasteboard *pboard;
    //NSDragOperation sourceDragMask;

    //NSLog(@"draggingEntered");
    
    return NSDragOperationEvery;  
}


- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
    //NSLog(@"draggingEntered");
    return YES;
}





- (BOOL)performDragOperation:(id < NSDraggingInfo >)draggingInfo
{
    //NSLog(@"performDragOperation");

    BOOL result = NO;

    MacSVGDocument * macSVGDocument = macSVGDocumentWindowController.document;
    NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;
    NSXMLElement * rootElement = [svgXmlDocument rootElement];
    
    XMLOutlineController * xmlOutlineController = macSVGDocumentWindowController.xmlOutlineController;
    XMLOutlineView * xmlOutlineView = xmlOutlineController.xmlOutlineView;

    NSInteger numberOfRows = xmlOutlineView.numberOfRows;
    NSInteger selectedRowIndex = xmlOutlineView.selectedRow;

    if (selectedRowIndex == -1)
    {
        if (numberOfRows > 0)
        {
            selectedRowIndex = 0;
        }
    }

    if (selectedRowIndex != -1)
    {
        NSXMLNode * targetNode = [xmlOutlineView itemAtRow:selectedRowIndex];
        
        // A target of "nil" means we are on the main root tree
        if (targetNode == nil) 
        {
            targetNode = rootElement;
        }
        
        NSUInteger childIndex = 0;

        if (targetNode != NULL)
        {
            childIndex = targetNode.childCount;
        }
        
        // Destination determined by current selection in NSXMLDocument
        // But it might not be a valid destination, so adjust accordingly

        NSDragOperation dragOperation = NSDragOperationNone;
        
        BOOL continueSearch = YES;
        
        while (continueSearch == YES)
        {
            dragOperation = [xmlOutlineController
                    outlineView:xmlOutlineView validateDrop:draggingInfo
                    proposedItem:targetNode proposedChildIndex:childIndex];
            
            if (dragOperation == NSDragOperationNone)
            {
                // change target to parent, and index one past old target
                
                NSXMLNode * targetParentNode = targetNode.parent;
                
                NSInteger targetIndexInParent = targetNode.index;
                
                targetNode = targetParentNode;
                childIndex = targetIndexInParent + 1;
            }
            else
            {
                continueSearch = NO;
            }
            
            if (targetNode == NULL)
            {
                continueSearch = NO;
            }
        }
        
        if (dragOperation == NSDragOperationGeneric)
        {
            result = [macSVGDocument dropElementsToXmlDocument:draggingInfo
                    item:targetNode childIndex:childIndex caller:self];
        }
    }
            
    return result;
}





- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender
{
    //NSLog(@"draggingUpdated");
    
    return NSDragOperationEvery;
}



- (void)keyDown:(NSEvent *)event
{
    unichar key = [event.charactersIgnoringModifiers characterAtIndex:0];
    if(key == NSDeleteCharacter)
    {
        NSBeep();
        return;
    }

    [super keyDown:event];
}

//==================================================================================
//	setSVGZoomStyleWithFloat:
//==================================================================================

- (void)setSVGZoomStyleWithFloat:(CGFloat)zoomFactor
{
    self.zoomFactor = zoomFactor;
    //NSString * zoomFactorString = [NSString stringWithFormat:@"%f", zoomFactor];
    NSString * zoomFactorString = [self allocFloatString:zoomFactor];

    MacSVGDocument * macSVGDocument = macSVGDocumentWindowController.document;
    NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;
    NSXMLElement * rootElement = [svgXmlDocument rootElement];

    XMLOutlineController * xmlOutlineController = macSVGDocumentWindowController.xmlOutlineController;
    
    NSString * newStyleAttributeString = [xmlOutlineController addCSSStyleName:@"zoom" styleValue:zoomFactorString toXMLElement:rootElement];
    
    NSXMLNode * styleAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    
    styleAttributeNode.name = @"style";
    styleAttributeNode.stringValue = newStyleAttributeString;
    
    [rootElement addAttribute:styleAttributeNode];
    
    NSXMLNode * MacsvgidAttributeNode = [rootElement attributeForName:@"macsvgid"];
    if (MacsvgidAttributeNode != NULL)
    {
        NSString * macsvgid = MacsvgidAttributeNode.stringValue;
        
        if (macsvgid.length > 0)
        {
            DOMElement * aDOMElement = [svgWebKitController domElementForMacsvgid:macsvgid];
            
            if (aDOMElement == NULL)
            {
                DOMDocument * domDocument = self.mainFrame.DOMDocument;
                DOMNodeList * svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
                if (svgElementsList.length > 0)
                {
                    DOMNode * domSvgElementNode = [svgElementsList item:0];
                    aDOMElement = (DOMElement *)domSvgElementNode;
                }
            }
            
            if (aDOMElement != NULL)
            {
                [aDOMElement setAttribute:@"style" value:newStyleAttributeString];
            }
        }
    }
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


@end


#pragma clang diagnostic pop
