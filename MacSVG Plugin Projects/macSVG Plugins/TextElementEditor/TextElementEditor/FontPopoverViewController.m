//
//  FontPopoverViewController.m
//  TextElementEditor
//
//  Created by Douglas Ward on 8/8/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

/*
    Example from self.googleWebFontsCatalogDictionary[items]
    {
            family = ABeeZee;
            files =             {
                italic = "http://themes.googleusercontent.com/static/fonts/abeezee/v1/kpplLynmYgP0YtlJA3atRw.ttf";
                regular = "http://themes.googleusercontent.com/static/fonts/abeezee/v1/mE5BOuZKGln_Ex0uYKpIaw.ttf";
            };
            kind = "webfonts#webfont";
            lastModified = "2012-10-31";
            subsets =             (
                latin
            );
            variants =             (
                regular,
                italic
            );
            version = v1;
    },
*/

#import "FontPopoverViewController.h"
#import <WebKit/WebKit.h>
#import "TextElementEditor.h"
#import <MacSVGPlugin/MacSVGPlugin.h>
#import "NSFileManager+DirectoryLocations.h"
//#import "SZJsonParser.h"
#import <MacSVGPlugin/SZJsonParser.h>

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@interface FontPopoverViewController ()

@end

@implementation FontPopoverViewController

//==================================================================================
//	initWithNibName:bundle:
//==================================================================================

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.googleWebFontsCatalogDictionary = NULL;
    }
    return self;
}

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    fontPreviewWebView.downloadDelegate = NULL;
    fontPreviewWebView.frameLoadDelegate = NULL;
    fontPreviewWebView.policyDelegate = NULL;
    fontPreviewWebView.resourceLoadDelegate = NULL;
    fontPreviewWebView.UIDelegate = NULL;
    
    self.googleWebFontsCatalogReceivedData = NULL;
    self.googleWebFontsCatalogDictionary = NULL;

    self.browserPreviewHTML = NULL;
    self.googleWebfontsPreviewHTML = NULL;
    self.importPreviewHTML = NULL;
    self.definedPreviewHTML = NULL;

    self.browserFontsDictionary = NULL;
    self.definedFontsArray = NULL;
}

//==================================================================================
//	awakeFromNib
//==================================================================================

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.definedFontsArray = [NSMutableArray array];
    
    [self getBrowserFonts];

    //[self fetchGoogleWebFontsCatalog];
    [self loadGoogleWebFontsCatalog];
}

//==================================================================================
//	getBrowserFonts
//==================================================================================

- (void)getBrowserFonts
{
    NSString *errorDesc = nil;
    NSPropertyListFormat format;

    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString * plistPath = [thisBundle pathForResource:@"BrowserFonts" ofType:@"plist"];
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    
    NSError * error;
    NSDictionary * tempDictionary = (NSDictionary *)[NSPropertyListSerialization
            propertyListWithData:plistXML
            options:NSPropertyListMutableContainersAndLeaves
            format:&format
            error:&error];
    
    if (!tempDictionary)
    {
        NSLog(@"Error reading plist: %@, format: %lu", errorDesc, format);
    }
    
    self.browserFontsDictionary = [NSMutableDictionary dictionaryWithDictionary:tempDictionary];
    
    NSMutableDictionary * workDictionary = [NSMutableDictionary dictionary];
    
    NSArray * allKeys = (self.browserFontsDictionary).allKeys;
    
    for (NSString * aKey in allKeys)
    {
        NSArray * fontNamesArray = (self.browserFontsDictionary)[aKey];
        
        for (NSString * aFontName in fontNamesArray)
        {
            workDictionary[aFontName] = @"";
        }
    }
    
    NSArray * allFontNamesKeys = workDictionary.allKeys;
    
    NSArray * sortedFontNamesArray = [allFontNamesKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    (self.browserFontsDictionary)[@"All Fonts"] = sortedFontNamesArray;
    
    NSArray * allCategoryKeys = (self.browserFontsDictionary).allKeys;
    
    NSArray * sortedCategoriesArray = [allCategoryKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    [browserFontsFilterPopUpButton removeAllItems];
    
    [browserFontsFilterPopUpButton addItemsWithTitles:sortedCategoriesArray];
    
    [browserFontsFilterPopUpButton selectItemAtIndex:0];
    
    [browserFontsTableView reloadData];
}

//==================================================================================
//	browserFontsFilterPopUpButtonAction:
//==================================================================================

- (IBAction)browserFontsFilterPopUpButtonAction:(id)sender
{
    NSIndexSet * newIndexSet = [NSIndexSet indexSetWithIndex:0];
    [browserFontsTableView selectRowIndexes:newIndexSet byExtendingSelection:NO];

    [browserFontsTableView reloadData];
}

//==================================================================================
//	defsElementForXMLDocument
//==================================================================================

- (NSXMLElement *)defsElementForXMLDocument:(NSXMLDocument *)xmlDocument;
{
    NSXMLElement * resultElement = NULL;

    NSXMLElement * rootElement = [xmlDocument rootElement];

    NSArray * styleElementsArray = [rootElement elementsForName:@"defs"];
    
    if (styleElementsArray.count > 0)
    {
        resultElement = styleElementsArray[0];
    }
    else
    {
        NSDictionary * drawableObjectsDictionary = @{@"rect": @"rect",
                @"circle": @"circle",
                @"ellipse": @"ellipse",
                @"text": @"text",
                @"image": @"image",
                @"line": @"line",
                @"polyline": @"polyline",
                @"polygon": @"polygon",
                @"path": @"path",
                @"use": @"use",
                @"g": @"g",
                @"foreignObject": @"foreignObject"};

        // determine a good insertion point for the defs element
        NSArray * nodesArray = rootElement.children;
        NSInteger nodeIndex = 0;
        for (NSXMLNode * aNode in nodesArray)
        {
            NSXMLNodeKind nodeKind = aNode.kind;
            
            if (nodeKind == NSXMLElementKind)
            {
                NSXMLElement * aElement = (NSXMLElement *)aNode;
                NSString * elementName = aElement.name;
                
                if (drawableObjectsDictionary[elementName] != NULL)
                {
                    break;
                }
            }
            nodeIndex++;
        }
        
        if (nodeIndex > 0) nodeIndex--;
        
        resultElement = [[NSXMLElement alloc] initWithName:@"defs"];
        
        NSXMLNode * idAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        idAttribute.name = @"id";
        idAttribute.stringValue = @"svg_document_defs";
        
        [resultElement addAttribute:idAttribute];
        
        [textElementEditor assignMacsvgidsForNode:resultElement];
        
        [rootElement insertChild:resultElement atIndex:nodeIndex];
    }
    
    return resultElement;
}

//==================================================================================
//	importGoogleWebfont
//==================================================================================

- (void)importGoogleWebfont:(NSString *)fontName;
{
    // Import Google webfont when SVG is loaded, e.g.,
    // <defs id="svg_document_defs">
    //     <style id="style1" type="text/css">@import url(https://fonts.googleapis.com/css?family=Alex+Brush);</style>
    // </defs>
    // <text font-family="Alex Brush" font-size="8">Text content</text>
    
    NSMutableString * fontURLName = [NSMutableString stringWithString:fontName];
    NSRange fontURLNameRange = NSMakeRange(0, fontURLName.length);
    [fontURLName replaceOccurrencesOfString:@" " withString:@"+" options: NSLiteralSearch range:fontURLNameRange];
    
    NSString * importStatement = [NSString stringWithFormat:@"@import url(https://fonts.googleapis.com/css?family=%@);", fontURLName];

    //NSXMLElement * textElement = [textElementEditor activeXMLTextElement];
    NSXMLDocument * xmlDocument = [textElementEditor activeXMLDocument];
    NSXMLElement * rootElement = [xmlDocument rootElement];
    
    // check for existing import of font
    BOOL existingImportFound = NO;
    NSArray * styleElementsArray = [rootElement elementsForName:@"style"];
    for (NSXMLElement * aStyleElement in styleElementsArray)
    {
        NSString * styleElementTextContent = aStyleElement.stringValue;
        if ([styleElementTextContent isEqualToString:importStatement] == YES)
        {
            existingImportFound = YES;
            break;
        }
    }
    
    if (existingImportFound == NO)
    {
        // add the import style elements to defs element
        NSXMLElement * defsElement = [self defsElementForXMLDocument:xmlDocument];
        
        NSXMLElement * styleElement = [[NSXMLElement alloc] initWithName:@"style"];
        
        styleElement.stringValue = importStatement;
        
        NSXMLNode * idAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        idAttribute.name = @"id";
        NSString * idAttributeString = [NSString stringWithFormat:@"%@_Google_Webfont_import", fontName];
        
        idAttribute.stringValue = idAttributeString;
        
        [styleElement addAttribute:idAttribute];
        
        [textElementEditor assignMacsvgidsForNode:styleElement];
        
        [defsElement addChild:styleElement];
    }
}

//==================================================================================
//	embedGoogleWebfont:
//==================================================================================

- (void)embedGoogleWebfont:(NSDictionary *)fontDictionary;
{
    /* Example -
    <defs id="svg_document_defs">
        <style type="text/css" macsvgid="A9FEAEBB-5028-4C46-B1B4-19B671BC3BB4-4765-00006191F572855A">
        @font-face {
            font-family: 'MyFontFamily';
                 url(data:font/truetype;charset=utf-8;base64,BASE64_ENCODED_DATA_HERE)  format('truetype'),
                 url(data:font/woff;charset=utf-8;base64,BASE64_ENCODED_DATA_HERE)  format('woff'),
                 url('myfont-webfont.svg#svgFontName') format('svg');
            }
        </style>
    </defs>
    <text font-family="MyFontFamily" font-size="8">Text content</text>
    */

    NSXMLDocument * xmlDocument = [textElementEditor activeXMLDocument];
    NSXMLElement * rootElement = [xmlDocument rootElement];
    NSXMLElement * defsElement = [self defsElementForXMLDocument:xmlDocument];
    
    NSString * fontFamilyString = fontDictionary[@"family"];
    NSDictionary * fontFilesDictionary = fontDictionary[@"files"];
    NSArray * fontVariantKeys = fontFilesDictionary.allKeys;

    for (NSString * aFontVariantKey in fontVariantKeys)
    {
        NSString * fontURLString = fontFilesDictionary[aFontVariantKey];
    
        BOOL existingEmbedFound = NO;
        
        NSString * fontType = @"truetype";

        NSURL * fontURL = [NSURL URLWithString:fontURLString];
            
        NSString * embedStatement = [self encodeFontWithURL:fontURL fontFamily:fontFamilyString fontVariant:aFontVariantKey fontType:fontType];
        
        // check for existing import of font
        NSArray * styleElementsArray = [rootElement elementsForName:@"style"];
        for (NSXMLElement * aStyleElement in styleElementsArray)
        {
            NSString * styleElementTextContent = aStyleElement.stringValue;
            if ([styleElementTextContent isEqualToString:embedStatement] == YES)
            {
                existingEmbedFound = YES;
                break;
            }
        }
        
        if (existingEmbedFound == NO)
        {
            // add the import style elements to defs element
            
            NSXMLElement * styleElement = [[NSXMLElement alloc] initWithName:@"style"];
            
            styleElement.stringValue = embedStatement;
            
            NSXMLNode * idAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            idAttribute.name = @"id";
            NSString * idAttributeString = [NSString stringWithFormat:@"%@_%@_Google_Webfont_embed", fontFamilyString, aFontVariantKey];
            
            idAttribute.stringValue = idAttributeString;
            
            [styleElement addAttribute:idAttribute];
            
            [textElementEditor assignMacsvgidsForNode:styleElement];
            
            [defsElement addChild:styleElement];
        }
    }
}

//==================================================================================
//	importOrEmbedGoogleWebFonts
//==================================================================================

- (void)importOrEmbedGoogleWebFonts
{
    NSInteger rowIndex = googleWebfontsTableView.selectedRow;

    NSString * fontName = @"";

    NSArray * googleWebfontsListArray = (self.googleWebFontsCatalogDictionary)[@"items"];
    
    if (googleWebfontsListArray != NULL)
    {
        NSDictionary * googleWebfontDictionary = googleWebfontsListArray[rowIndex];
        
        if (googleWebfontDictionary != NULL)
        {
            fontName = googleWebfontDictionary[@"family"];

            NSInteger importOptionRow = googleWebfontOptionsMatrix.selectedRow;
            
            if (importOptionRow == 0)
            {
                // Import Google webfont when SVG is loaded
                [self importGoogleWebfont:fontName];
            }
            else
            {
                // embed font in SVG
                [self embedGoogleWebfont:googleWebfontDictionary];
            }
        }
    }
}

//==================================================================================
//	fontNameFromTruetypeFontURL
//==================================================================================

- (NSString *)fontNameFromTruetypeFontURL:(NSURL *)fontURL
{
    // test file:////Users/dsward/Downloads/Cabin_Condensed/CabinCondensed-Regular.ttf
    
    NSString * fontName = NULL;
    
    NSData * fontData = [NSData dataWithContentsOfURL:fontURL];

    CTFontDescriptorRef cfFontDescriptor = CTFontManagerCreateFontDescriptorFromData((__bridge CFDataRef)fontData);
    
    CFDictionaryRef fontDescriptorCFDictionary = CTFontDescriptorCopyAttributes(cfFontDescriptor);
    NSDictionary * fontDescriptorDictionary = CFBridgingRelease(fontDescriptorCFDictionary);
    
    fontName = fontDescriptorDictionary[@"NSFontNameAttribute"];
    
    return fontName;
}

//==================================================================================
//	fontNameFromURLData
//==================================================================================

- (NSString *)fontNameFromURLData:(NSURL *)fontURL
{
    // for file URLs like file:////Users/dsward/Downloads/Cabin_Condensed/CabinCondensed-Regular.ttf
    
    NSString * fontName = NULL;
    
    NSData * fontData = [NSData dataWithContentsOfURL:fontURL];

    if (fontData != NULL)
    {
        NSString * fontDataString = [[NSString alloc] initWithData:fontData encoding:NSUTF8StringEncoding];

        NSRange fontFaceRange = [fontDataString rangeOfString:@"@font-face"];
        
        if (fontFaceRange.location != NSNotFound)
        {
            fontName = [self fontNameFromFontFace:fontDataString];
        }
    }
    
    return fontName;
}

//==================================================================================
//	fontNameFromURL
//==================================================================================

- (NSString *)fontNameFromURL:(NSString *)fontURLString
{
    NSString * fontName = NULL;
    
    NSURL * fontURL = [NSURL URLWithString:fontURLString];
    
    if (fontURL != NULL)
    {
        NSString * fontFileNameExtension = [fontURLString pathExtension];
        if ([fontFileNameExtension isEqualToString:@"ttf"] == YES)
        {
            fontName = [self fontNameFromTruetypeFontURL:fontURL];
        }
        else if ([fontFileNameExtension isEqualToString:@"otf"] == YES)
        {
            fontName = [self fontNameFromTruetypeFontURL:fontURL];
        }
        else
        {
            fontName = [self fontNameFromURLData:fontURL];
        }
    }

    return fontName;
}

//==================================================================================
//	importWebfont
//==================================================================================

- (NSString *)importWebfont:(NSString *)fontURLString;
{
    // Import Google webfont when SVG is loaded, e.g.,
    // <defs id="svg_document_defs">
    //     <style id="style1" type="text/css">@import url(http://webhost.com/path/to/font.ttf);</style>
    // </defs>
    // <text font-family="Alex Brush" font-size="8">Text content</text>

    NSString * importStatement = NULL;

    // attempt font name acquisition by download
    NSString * fontName = [self fontNameFromURL:fontURLString];
    
    if (fontName != NULL)
    {
        importStatement = [NSString stringWithFormat:@"@import url(%@);", fontURLString];
    }
    else
    {
        NSURL * fontURL = [NSURL URLWithString:fontURLString];
        
        fontName = [self fontNameFromTruetypeFontURL:fontURL];

        if (fontName != NULL)
        {
            importStatement = [NSString stringWithFormat:@"@font-face { font-family: '%@'; src: url(%@);}",
                    fontName, fontURLString];
        }
    }
    
    if (fontName != NULL)
    {
        NSXMLDocument * xmlDocument = [textElementEditor activeXMLDocument];
        NSXMLElement * rootElement = [xmlDocument rootElement];
        
        // check for existing import of font
        BOOL existingImportFound = NO;
        NSArray * styleElementsArray = [rootElement elementsForName:@"style"];
        for (NSXMLElement * aStyleElement in styleElementsArray)
        {
            NSString * styleElementTextContent = aStyleElement.stringValue;
            if ([styleElementTextContent isEqualToString:importStatement] == YES)
            {
                existingImportFound = YES;
                break;
            }
        }
        
        if (existingImportFound == NO)
        {
            // add the import style elements to defs element
            NSXMLElement * defsElement = [self defsElementForXMLDocument:xmlDocument];
            
            NSXMLElement * styleElement = [[NSXMLElement alloc] initWithName:@"style"];
            
            styleElement.stringValue = importStatement;
            
            NSXMLNode * idAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            idAttribute.name = @"id";
            NSString * idAttributeString = [NSString stringWithFormat:@"%@_font_import", fontName];
            
            idAttribute.stringValue = idAttributeString;
            
            [styleElement addAttribute:idAttribute];
            
            [textElementEditor assignMacsvgidsForNode:styleElement];
            
            [defsElement addChild:styleElement];
        }
    }
    
    return fontName;
}

//==================================================================================
//	embedGoogleWebfont:
//==================================================================================

- (NSString * )embedWebfont:(NSString *)fontURLString;
{
    NSXMLDocument * xmlDocument = [textElementEditor activeXMLDocument];
    NSXMLElement * rootElement = [xmlDocument rootElement];
    NSXMLElement * defsElement = [self defsElementForXMLDocument:xmlDocument];
    
    BOOL existingEmbedFound = NO;
    
    NSString * fontType = @"truetype";

    NSURL * fontURL = [NSURL URLWithString:fontURLString];
    
    NSString * fontFamilyString = [self fontNameFromTruetypeFontURL:fontURL];
        
    NSString * embedStatement = [self encodeFontWithURL:fontURL
            fontFamily:fontFamilyString fontVariant:NULL fontType:fontType];
    
    // check for existing import of font
    NSArray * styleElementsArray = [rootElement elementsForName:@"style"];
    for (NSXMLElement * aStyleElement in styleElementsArray)
    {
        NSString * styleElementTextContent = aStyleElement.stringValue;
        if ([styleElementTextContent isEqualToString:embedStatement] == YES)
        {
            existingEmbedFound = YES;
            break;
        }
    }
    
    if (existingEmbedFound == NO)
    {
        // add the import style elements to defs element
        
        NSXMLElement * styleElement = [[NSXMLElement alloc] initWithName:@"style"];
        
        styleElement.stringValue = embedStatement;
        
        NSXMLNode * idAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        
        idAttribute.name = @"id";
        
        NSString * idAttributeString =
                [NSString stringWithFormat:@"%@_Webfont_embed",
                fontFamilyString];
        
        idAttribute.stringValue = idAttributeString;
        
        [styleElement addAttribute:idAttribute];
        
        [textElementEditor assignMacsvgidsForNode:styleElement];
        
        [defsElement addChild:styleElement];
    }
    
    return fontFamilyString;
}

//==================================================================================
//	importOrEmbedWebFont
//==================================================================================

- (NSString *)importOrEmbedWebfont:(NSString *)fontURLString
{
    NSString * fontName = @"Helvetica";
    
    NSInteger importOptionRow = webfontImportOptionsMatrix.selectedRow;
    
    if (importOptionRow == 0)
    {
        // Import Google webfont when SVG is loaded
        fontName = [self importWebfont:fontURLString];
    }
    else
    {
        // embed font in SVG
        fontName = [self embedWebfont:fontURLString];
    }
    
    return fontName;
}

//==================================================================================
//	importOrEmbedFont
//==================================================================================

- (NSString *)importOrEmbedFont
{
    NSString * fontName = @"Helvetica";
    
    NSString * fontURLString = webfontPathTextField.stringValue;
    
    if (fontURLString.length > 0)
    {
        // Import webfont when SVG is loaded
        fontName = [self importOrEmbedWebfont:fontURLString];
    }
    
    return fontName;
}

//==================================================================================
//	panel:shouldEnableURL:
//==================================================================================

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url
{
    BOOL result = NO;

    NSString * pathExtension = url.pathExtension;

    if ([pathExtension isEqualToString:@"ttf"] == YES)
    {
        result = YES;
    }

    if ([pathExtension isEqualToString:@"otf"] == YES)
    {
        result = YES;
    }

    BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:&isDirectory];
    
    if (isDirectory == YES)
    {
        result = YES;
    }
    
    return result;
}

//==================================================================================
//	chooseTruetypeFontFileButtonAction
//==================================================================================

- (IBAction)chooseTruetypeFontFileButtonAction:(id)sender
{
    webfontStatusMessageTextField.stringValue = @"";

    NSOpenPanel* panel = [NSOpenPanel openPanel];
    
    panel.delegate = self;

    // This method displays the panel and returns immediately.
    // The completion handler is called when the user selects an
    // item or cancels the panel.
    
    __weak NSTextField * weakWebfontPathTextField = webfontPathTextField;
    __weak NSTextField * weakWebfontStatusMessageTextField = webfontStatusMessageTextField;

    [panel beginWithCompletionHandler:^(NSInteger result)
    {
        if (result == NSModalResponseOK)
        {
            NSURL *  fontURL = panel.URLs[0];
            
            NSString * pathExtension = fontURL.pathExtension;

            if ([pathExtension isEqualToString:@"ttf"] == YES)
            {
                // Open  the document.
                NSString * urlString = fontURL.absoluteString;
                
                weakWebfontPathTextField.stringValue = urlString;
                
                NSString * fontName = [self fontNameFromTruetypeFontURL:fontURL];
                
                [self previewTruetypeSelectionWithURL:urlString fontName:fontName];
            }
            else if ([pathExtension isEqualToString:@"otf"] == YES)
            {
                // Open  the document.
                NSString * urlString = fontURL.absoluteString;
                
                weakWebfontPathTextField.stringValue = urlString;
                
                NSString * fontName = [self fontNameFromTruetypeFontURL:fontURL];
                
                [self previewTruetypeSelectionWithURL:urlString fontName:fontName];
            }
            else
            {
                weakWebfontStatusMessageTextField.stringValue = @"Import error - Truetype font not found";
            }
            
            [self reopenPopover];
        }
    }];
}

//==================================================================================
//	reopenPopover
//==================================================================================

-(void)reopenPopover
{
    // re-open the popover
    NSButton * targetButton = [textElementEditor browseFontsButton];
    
    // configure the preferred position of the popover
    [fontPopover showRelativeToRect:targetButton.bounds ofView:targetButton preferredEdge:NSMaxYEdge];
}

//==================================================================================
//	previewImportSelectionWithURL
//==================================================================================

- (void)previewImportSelectionWithURL:(NSString *)urlString fontName:(NSString *) fontName
{
    NSString * textContent = [textElementEditor textElementContent];
    
    NSString * htmlString = [NSString stringWithFormat:
            @"<html><head><link href='%@' rel='stylesheet' type='text/css'><style>p.preview{font-family:'%@'; font-size:24px;}</style></head><body><p class='preview'>%@</p></body></html>",
            urlString, fontName, textContent];
    
    [fontPreviewWebView.mainFrame loadHTMLString:htmlString baseURL:NULL];
    
    self.importPreviewHTML = htmlString;
}

//==================================================================================
//	previewImportSelectionWithURL
//==================================================================================

- (void)previewTruetypeSelectionWithURL:(NSString *)urlString fontName:(NSString *) fontName
{
    NSString * textContent = [textElementEditor textElementContent];
    
    NSString * fontWeight = @"normal";
    NSString * fontStyle = @"normal";
    NSString * fontStretch = @"normal";
    NSString * fontType = @"truetype";

    NSString * cssString = [NSString stringWithFormat:@"@font-face {font-family:'%@'; font-weight:%@; font-style:%@; font-stretch:%@; src:url(%@) format('%@');}",
                fontName, fontWeight, fontStyle, fontStretch, urlString, fontType];
    
    NSString * htmlString = [NSString stringWithFormat:
            @"<html><head><style>%@p.preview{font-family:'%@'; font-size:24px;}</style></head><body><p class='preview'>%@</p></body></html>",
            cssString, fontName, textContent];
    
    [fontPreviewWebView.mainFrame loadHTMLString:htmlString baseURL:NULL];
    
    self.importPreviewHTML = htmlString;
}


//==================================================================================
//	previewImportedFontButtonAction
//==================================================================================

- (IBAction)previewImportedFontButtonAction:(id)sender
{
    NSString * fontURLString = webfontPathTextField.stringValue;
    
    if (fontURLString.length > 0)
    {
        NSString * fontName = [self fontNameFromURL:fontURLString];
        
        if (fontName != NULL)
        {
            [self previewImportSelectionWithURL:fontURLString fontName:fontName];
        }
    }
}

//==================================================================================
//	chooseDisplayedFontButtonAction
//==================================================================================

- (IBAction)chooseDisplayedFontButtonAction:(id)sender
{
    NSTabViewItem * tabViewItem = tabView.selectedTabViewItem;
    NSInteger tabViewItemIndex = [tabView indexOfTabViewItem:tabViewItem];
    
    switch (tabViewItemIndex)
    {
        case 0:
        {
            // Browser font tab
            NSInteger rowIndex = browserFontsTableView.selectedRow;
            NSString * fontName = [self stringValueForBrowserFontsRowIndex:rowIndex];
            [textElementEditor setFontName:fontName];
            break;
        }
        case 1:
        {
            // Google Webfont tab
            [self importOrEmbedGoogleWebFonts];
            NSInteger rowIndex = googleWebfontsTableView.selectedRow;
            NSString * fontName = @"Helvetica";
            NSArray * googleWebfontsListArray = (self.googleWebFontsCatalogDictionary)[@"items"];
            
            if (googleWebfontsListArray != NULL)
            {
                NSDictionary * googleWebfontDictionary = googleWebfontsListArray[rowIndex];
                
                if (googleWebfontDictionary != NULL)
                {
                    fontName = googleWebfontDictionary[@"family"];
                }
            }
            [textElementEditor setFontName:fontName];
            break;
        }

        case 2:
        {
            // Webfont or TrueType file tab
            NSString * fontName = [self importOrEmbedFont];

            [textElementEditor setFontName:fontName];
            break;
        }
        case 3:
        {
            // Embedded file tab
            NSInteger rowIndex = definedFontsTableView.selectedRow;
            
            NSString * fontName = [self stringValueForDefinedFontsRowIndex:rowIndex];

            [textElementEditor setFontName:fontName];
            
            break;
        }
        default:
            break;
    }

    [fontPopover performClose:self];
}


//==================================================================================
//	numberOfRowsInBrowserFontsTableView
//==================================================================================

- (NSInteger)numberOfRowsInBrowserFontsTableView
{
    NSInteger result = 0;
    
    NSString * browserListKey = browserFontsFilterPopUpButton.titleOfSelectedItem;
    
    NSArray * browserListArray = (self.browserFontsDictionary)[browserListKey];
    
    result = browserListArray.count;
    
    return result;
}

//==================================================================================
//	numberOfRowsInGoogleWebfontsTableView
//==================================================================================

- (NSInteger)numberOfRowsInGoogleWebfontsTableView
{
    NSInteger result = 0;
    
    if (self.googleWebFontsCatalogDictionary != NULL)
    {
        NSArray * googleWebfontsListArray = (self.googleWebFontsCatalogDictionary)[@"items"];
        
        if (googleWebfontsListArray != NULL)
        {
            result = googleWebfontsListArray.count;
        }
    }

    return result;
}

//==================================================================================
//	numberOfRowsInDefinedFontsTableView
//==================================================================================

- (NSInteger)numberOfRowsInDefinedFontsTableView
{
    NSInteger result = 0;
    
    result = (self.definedFontsArray).count;
    
    return result;
}


//==================================================================================
//	numberOfRowsInTableView:
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSInteger result = 0;
    
    if (aTableView == browserFontsTableView)
    {
        result = [self numberOfRowsInBrowserFontsTableView];
    }
    else if (aTableView == googleWebfontsTableView)
    {
        result = [self numberOfRowsInGoogleWebfontsTableView];
    }
    else if (aTableView == definedFontsTableView)
    {
        result = [self numberOfRowsInDefinedFontsTableView];
    }
    
    return result;
}

//==================================================================================
//	stringValueForBrowserFontsRowIndex:
//==================================================================================

- (NSString *)stringValueForBrowserFontsRowIndex:(NSInteger)rowIndex
{
    NSString * result = @"Missing Result";
    
    NSString * browserListKey = browserFontsFilterPopUpButton.titleOfSelectedItem;
    
    NSArray * browserListArray = (self.browserFontsDictionary)[browserListKey];
    
    result = browserListArray[rowIndex];
    
    return result;
}

//==================================================================================
//	stringValueForGoogleWebfontsRowIndex:
//==================================================================================

- (NSString *)stringValueForGoogleWebfontsRowIndex:(NSInteger)rowIndex
{
    NSString * result = @"Missing Result";
    
    NSArray * googleWebfontsListArray = (self.googleWebFontsCatalogDictionary)[@"items"];
    
    if (googleWebfontsListArray != NULL)
    {
        NSDictionary * googleWebfontDictionary = googleWebfontsListArray[rowIndex];
        
        if (googleWebfontDictionary != NULL)
        {
            NSString * fontFamily = googleWebfontDictionary[@"family"];
            
            NSMutableString * variantsString = [NSMutableString string];
            
            NSArray * variantsArray = googleWebfontDictionary[@"variants"];
            for (NSString * aVariantString in variantsArray)
            {
                if (variantsString.length > 0)
                {
                    [variantsString appendString:@", "];
                }
                [variantsString appendString:aVariantString];
            }
        
            result = [NSString stringWithFormat:@"%@ (%@)", fontFamily, variantsString];
        }
    }
    
    return result;
}

//==================================================================================
//	stringValueForDefinedFontsRowIndex:
//==================================================================================

- (NSString *)stringValueForDefinedFontsRowIndex:(NSInteger)rowIndex
{
    NSString * result = @"Missing Result";
    
    if (rowIndex >= 0)
    {
        result = (self.definedFontsArray)[rowIndex];
    }
    
    return result;
}

//==================================================================================
//    tableView:viewForTableColumn:row:
//==================================================================================

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString * tableColumnIdentifier = tableColumn.identifier;
    
    //NSTableCellView * tableCellView = (NSTableCellView *)[tableView makeViewWithIdentifier:tableColumnIdentifier owner:self];
    NSTableCellView * tableCellView = (NSTableCellView *)[tableView makeViewWithIdentifier:tableColumnIdentifier owner:NULL];

    NSString * resultString = @"";

    if (tableCellView != NULL)
    {
        resultString = [self tableView:tableView objectValueForTableColumn:tableColumn row:row];
    }
    
    tableCellView.textField.stringValue = resultString;
    
    return (NSView *)tableCellView;
}

//==================================================================================
//	tableView:objectValueForTableColumn:row:
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString * result = @"Missing Result";
    
    if (aTableView == browserFontsTableView)
    {
        result = [self stringValueForBrowserFontsRowIndex:rowIndex];
    }
    else if (aTableView == googleWebfontsTableView)
    {
        result = [self stringValueForGoogleWebfontsRowIndex:rowIndex];
    }
    else if (aTableView == definedFontsTableView)
    {
        result = [self stringValueForDefinedFontsRowIndex:rowIndex];
    }
    
    return result;
}

//==================================================================================
//	browserFontsTableViewSelectionDidChange
//==================================================================================

- (void)browserFontsTableViewSelectionDidChange
{
    NSInteger rowIndex = browserFontsTableView.selectedRow;
    
    NSString * fontName = [self stringValueForBrowserFontsRowIndex:rowIndex];
    
    NSString * textContent = [textElementEditor textElementContent];
    
    NSString * htmlString = [NSString stringWithFormat:
            @"<html><head><style>p.preview{font-family:'%@'; font-size:24px;}</style></head><body><p class='preview'>%@</p></body></html>",
            fontName, textContent];
    
    [fontPreviewWebView.mainFrame loadHTMLString:htmlString baseURL:NULL];
    
    self.browserPreviewHTML = htmlString;
}

//==================================================================================
//	googleWebfontsTableViewSelectionDidChange
//==================================================================================

- (void)googleWebfontsTableViewSelectionDidChange
{
    NSInteger rowIndex = googleWebfontsTableView.selectedRow;

    NSString * fontName = @"";

    NSArray * googleWebfontsListArray = (self.googleWebFontsCatalogDictionary)[@"items"];
    
    if (googleWebfontsListArray != NULL)
    {
        NSDictionary * googleWebfontDictionary = googleWebfontsListArray[rowIndex];
        
        if (googleWebfontDictionary != NULL)
        {
            fontName = googleWebfontDictionary[@"family"];
        }
    }
    
    NSMutableString * fontURLName = [NSMutableString stringWithString:fontName];
    
    NSRange fontURLNameRange = NSMakeRange(0, fontURLName.length);
    [fontURLName replaceOccurrencesOfString:@" " withString:@"+" options: NSLiteralSearch range:fontURLNameRange];
    
    NSString * textContent = [textElementEditor textElementContent];
    
    NSString * htmlString = [NSString
            stringWithFormat:@"<html><head><link href='https://fonts.googleapis.com/css?family=%@' rel='stylesheet' type='text/css'><style>p.preview{font-family:'%@'; font-size:24px;}</style></head><body><p class='preview'>%@</p></body></html>",
            fontURLName, fontName, textContent];
    
    [fontPreviewWebView.mainFrame loadHTMLString:htmlString baseURL:NULL];
    
    self.googleWebfontsPreviewHTML = htmlString;
}

//==================================================================================
//	browserFontsTableViewSelectionDidChange
//==================================================================================

- (void)definedFontsTableViewSelectionDidChange
{
    NSInteger rowIndex = browserFontsTableView.selectedRow;
    
    NSString * fontName = [self stringValueForDefinedFontsRowIndex:rowIndex];
    
    NSString * textContent = [textElementEditor textElementContent];
    
    NSString * htmlString = [NSString stringWithFormat:
            @"<html><head><style>p.preview{font-family:'%@'; font-size:24px;}</style></head><body><p class='preview'>%@</p></body></html>",
            fontName, textContent];
    
    [fontPreviewWebView.mainFrame loadHTMLString:htmlString baseURL:NULL];
    
    self.browserPreviewHTML = htmlString;
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = aNotification.object;
    if (aTableView == browserFontsTableView)
    {
        [self browserFontsTableViewSelectionDidChange];
    }
    else if (aTableView == googleWebfontsTableView)
    {
        [self googleWebfontsTableViewSelectionDidChange];
    }
    else if (aTableView == definedFontsTableView)
    {
        [self definedFontsTableViewSelectionDidChange];
    }
}

//==================================================================================
//	embedTrueTypeFont:
//==================================================================================

- (void)embedTrueTypeFont:(NSString *)filepath
{
    NSString * filename = filepath.lastPathComponent;

    if (filename != nil) 
    {
        NSUInteger filenameLength = filename.length;
        
        BOOL isTrueTypeFontFile = NO;
        
        NSRange suffixRange = [filename rangeOfString:@".ttf"];
        if (suffixRange.location == filenameLength - 4)
        {
            isTrueTypeFontFile = YES;
        }
        
        suffixRange = [filename rangeOfString:@".otf"];
        if (suffixRange.location == filenameLength - 4)
        {
            isTrueTypeFontFile = YES;
        }
        
        if (isTrueTypeFontFile == YES)
        {
            NSString * fontFamilyString = [filename substringToIndex:(filenameLength - 4)];
                                
            NSURL * fontURL = [NSURL fileURLWithPath:filepath];
           
            NSString * fontString = [self
                    encodeFontWithURL:fontURL 
                    fontFamily:fontFamilyString
                    fontVariant:@"regular"
                    fontType:@"truetype"];
                    
            NSString * xmlString = [NSString stringWithFormat:@"<style type='text/css'>%@</style>",
                    fontString];
            
            // insert xmlString into document
            
            NSXMLDocument * xmlDocument = [textElementEditor activeXMLDocument];
            NSXMLElement * rootElement = [xmlDocument rootElement];
            NSXMLElement * defsElement = [self defsElementForXMLDocument:xmlDocument];
 
            BOOL existingEmbedFound = NO;
           
            // check for existing import of font
            NSArray * styleElementsArray = [rootElement elementsForName:@"style"];
            for (NSXMLElement * aStyleElement in styleElementsArray)
            {
                NSString * styleElementTextContent = aStyleElement.stringValue;
                if ([styleElementTextContent isEqualToString:xmlString] == YES)
                {
                    existingEmbedFound = YES;
                    break;
                }
            }
            
            if (existingEmbedFound == NO)
            {
                // add the import style elements to defs element
                
                NSXMLElement * styleElement = [[NSXMLElement alloc] initWithName:@"style"];
                
                styleElement.stringValue = xmlString;
                
                NSXMLNode * idAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                idAttribute.name = @"id";
                NSString * idAttributeString = [NSString stringWithFormat:@"%@_%@_TrueType_font_embed", fontFamilyString, @"regular"];
                
                idAttribute.stringValue = idAttributeString;
                
                [styleElement addAttribute:idAttribute];
                
                [textElementEditor assignMacsvgidsForNode:styleElement];
                
                [defsElement addChild:styleElement];
            }
        }
    }            
}


//==================================================================================
//	allocEncodeBase64Data:
//==================================================================================

- (NSString *)allocEncodeBase64Data:(NSData *)inputData
{
	if (inputData.length == 0)
		return @"";

    char *characters = malloc(((inputData.length + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < inputData.length)
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < inputData.length)
			buffer[bufferLength++] = ((char *)inputData.bytes)[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';	
	}
	
	return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

// ================================================================

- (BOOL)fontVariant:(NSString *)fontVariant containsProperty:(NSString *)property
{
    BOOL result = NO;
    
    if (fontVariant != NULL)
    {
        NSRange foundRange = [fontVariant rangeOfString:property];
        
        if (foundRange.location != NSNotFound)
        {
            result = YES;
        }
    }
    
    return result;
}

/*
font-stretch	normal, condensed, ultra-condensed, extra-condensed, semi-condensed, expanded, semi-expanded, extra-expanded, ultra-expanded
font-style      normal, italic, oblique
font-weight     normal, bold, 100, 200, 300, 400, 500, 600, 700, 800, 900
*/

- (NSString *)encodeFontWithURL:(NSURL *)fontURL fontFamily:(NSString *)fontFamily
        fontVariant:(NSString *)fontVariant fontType:(NSString *)fontType
{
    NSString * cssString = @"";
    
    if (fontURL != NULL)
    {
        NSData * originalFontData = [[NSData alloc] initWithContentsOfURL:fontURL];
        
        NSString * base64String = [self allocEncodeBase64Data:originalFontData];
        
        NSString * fontStretch = @"normal";
        NSString * fontStyle = @"normal";
        NSString * fontWeight = @"normal";
        
        if (fontVariant != NULL)
        {
            if ([self fontVariant:fontVariant containsProperty:@"condensed"] == YES) fontStretch = @"condensed";
            if ([self fontVariant:fontVariant containsProperty:@"ultra-condensed"] == YES) fontStretch = @"ultra-condensed";
            if ([self fontVariant:fontVariant containsProperty:@"extra-condensed"] == YES) fontStretch = @"extra-condensed";
            if ([self fontVariant:fontVariant containsProperty:@"semi-condensed"] == YES) fontStretch = @"semi-condensed";
            if ([self fontVariant:fontVariant containsProperty:@"expanded"] == YES) fontStretch = @"expanded";
            if ([self fontVariant:fontVariant containsProperty:@"semi-expanded"] == YES) fontStretch = @"semi-expanded";
            if ([self fontVariant:fontVariant containsProperty:@"extra-expanded"] == YES) fontStretch = @"extra-expanded";
            if ([self fontVariant:fontVariant containsProperty:@"ultra-expanded"] == YES) fontStretch = @"ultra-expanded";
            
            if ([self fontVariant:fontVariant containsProperty:@"italic"] == YES) fontStyle = @"italic";
            if ([self fontVariant:fontVariant containsProperty:@"oblique"] == YES) fontStyle = @"oblique";

            if ([self fontVariant:fontVariant containsProperty:@"bold"] == YES) fontWeight = @"bold";
            if ([self fontVariant:fontVariant containsProperty:@"100"] == YES) fontWeight = @"100";
            if ([self fontVariant:fontVariant containsProperty:@"200"] == YES) fontWeight = @"200";
            if ([self fontVariant:fontVariant containsProperty:@"300"] == YES) fontWeight = @"300";
            if ([self fontVariant:fontVariant containsProperty:@"400"] == YES) fontWeight = @"400";
            if ([self fontVariant:fontVariant containsProperty:@"500"] == YES) fontWeight = @"500";
            if ([self fontVariant:fontVariant containsProperty:@"600"] == YES) fontWeight = @"600";
            if ([self fontVariant:fontVariant containsProperty:@"700"] == YES) fontWeight = @"700";
            if ([self fontVariant:fontVariant containsProperty:@"800"] == YES) fontWeight = @"800";
            if ([self fontVariant:fontVariant containsProperty:@"900"] == YES) fontWeight = @"900";
        }
        
        cssString = [NSString stringWithFormat:@"@font-face {font-family:'%@'; font-weight:%@; font-style:%@; font-stretch:%@; src:url(data:font/%@;charset=utf-8;base64,%@) format('%@');}",
                fontFamily, fontWeight, fontStyle, fontStretch, fontType, base64String, fontType];
    }
    
    return cssString;
}

//==================================================================================
//	loadGoogleWebFontsCatalog
//==================================================================================

- (void)loadGoogleWebFontsCatalog
{
    NSString * applicationSupportDirectoryPath =
            [[NSFileManager defaultManager] applicationSupportDirectory];

    NSString * googleWebFontsCatalogPath = [applicationSupportDirectoryPath stringByAppendingPathComponent:@"googleWebFontsCatalog.plist"];
    
    BOOL catalogLoaded = NO;
    
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:googleWebFontsCatalogPath] == YES)
    {
        NSData * plistXML = [[NSFileManager defaultManager]
                contentsAtPath:googleWebFontsCatalogPath];

        NSError * error;
        NSDictionary * tempDictionary = (NSDictionary *)[NSPropertyListSerialization
                propertyListWithData:plistXML options:NSPropertyListMutableContainersAndLeaves
                format:&format error:&error];
        
        if (tempDictionary != NULL)
        {
            NSMutableDictionary * tempMutableDictionary = [NSMutableDictionary dictionaryWithDictionary:tempDictionary];
            self.googleWebFontsCatalogDictionary = tempMutableDictionary;
            catalogLoaded = YES;
        }
        else
        {
            NSLog(@"Error reading plist: %@, format: %lu", errorDesc, format);
        }
    }

    if (catalogLoaded == NO)
    {
        //[self fetchGoogleWebFontsCatalog];
        [self refreshGoogleFontsCatalogButtonAction:self];
    }
}

//==================================================================================
//	refreshGoogleFontsCatalogButtonAction
//==================================================================================

- (IBAction)refreshGoogleFontsCatalogButtonAction:(id)sender
{
    [self fetchGoogleWebFontsCatalog];
}

//==================================================================================
//	storeGoogleWebFontsCatalog
//==================================================================================

- (void)storeGoogleWebFontsCatalog
{
    NSString * applicationSupportDirectoryPath =
            [[NSFileManager defaultManager] applicationSupportDirectory];

    NSString * googleWebFontsCatalogPath = [applicationSupportDirectoryPath stringByAppendingPathComponent:@"googleWebFontsCatalog.plist"];

    NSError * error;
    NSData * plistData = [NSPropertyListSerialization
            dataWithPropertyList:self.googleWebFontsCatalogDictionary
            format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    
    if (plistData)
    {
        [plistData writeToFile:googleWebFontsCatalogPath atomically:YES];
    }
    else
    {
        NSLog(@"storeGoogleWebFontsCatalog error - %@", error);
    }
}

//==================================================================================
//	fetchGoogleWebFontsCatalog
//==================================================================================

- (void)fetchGoogleWebFontsCatalog
{
    // Google WebFonts API - Request fonts catalog in JSON format
    // https://www.googleapis.com/webfonts/v1/webfonts?key=AIzaSyB9CgNBagpCVZ6kbc3G8Jgn7jNL-ZUsdXY
    
    if (self.googleWebFontsCatalogDictionary == NULL)
    {
        NSString * urlString = @"https://www.googleapis.com/webfonts/v1/webfonts?key=AIzaSyB9CgNBagpCVZ6kbc3G8Jgn7jNL-ZUsdXY";
        
        NSURL * requestURL = [NSURL URLWithString:urlString];

        // Create the request.
        NSURLRequest * theRequest=[NSURLRequest requestWithURL:requestURL
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:60.0];
        
        // create the connection with the request
        // and start loading the data
        NSURLConnection * theConnection= [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if (theConnection)
        {
            // Create the NSMutableData to hold the received data.
            self.googleWebFontsCatalogReceivedData = [NSMutableData data];
        }
        else
        {
            // Inform the user that the connection failed.
            NSLog(@"fetchGoogleWebFontsCatalog - NSURLConnection failed");
        }
    }
}

//==================================================================================
//	fontNameFromFontFace:
//==================================================================================

- (NSString *)fontNameFromFontFace:(NSString *)fontFaceString
{
    NSString * fontName = NULL;

    NSRange fontFaceRange = [fontFaceString rangeOfString:@"@font-face"];
    
    if (fontFaceRange.location != NSNotFound)
    {
        /*
            data from: @import url(https://fonts.googleapis.com/css?family=Aclonica);
        
            @font-face {
              font-family: 'Aclonica';
              font-style: normal;
              font-weight: 400;
              src: local('Aclonica'), local('Aclonica-Regular'), url(https://themes.googleusercontent.com/static/fonts/aclonica/v3/SRPydzL0KLANO5G2lBcEnfesZW2xOQ-xsNqO47m55DA.ttf) format('truetype');
            }
        */
        
        NSInteger fontDataStringLength = fontFaceString.length;
        NSInteger openBracePosition = NSNotFound;
        NSInteger closeBracePosition = NSNotFound;
        for (NSInteger charIndex = fontFaceRange.location  + fontFaceRange.length - 1;
                charIndex < fontDataStringLength; charIndex++)
        {
            unichar aChar = [fontFaceString characterAtIndex:charIndex];
            
            if (aChar == '{') openBracePosition = charIndex;
            if (aChar == '}')
            {
                if (openBracePosition != NSNotFound)
                {
                    closeBracePosition = charIndex;
                }
                break;
            }
        }
        
        if (closeBracePosition != NSNotFound)
        {
            NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

            NSRange fontFaceInnerContentRange = NSMakeRange(openBracePosition + 1, closeBracePosition - openBracePosition - 1);
            NSString * fontFaceInnerContent = [fontFaceString substringWithRange:fontFaceInnerContentRange];
            NSString * trimmedFaceInnerContent = [fontFaceInnerContent stringByTrimmingCharactersInSet:whitespaceSet];
            
            NSArray * fontFaceCSSArray = [trimmedFaceInnerContent componentsSeparatedByString:@";"];
            
            for (NSString * aCSSString in fontFaceCSSArray)
            {
                NSArray * aCSSArray = [aCSSString componentsSeparatedByString:@":"];
                
                if (aCSSArray.count == 2)
                {
                    NSString * aCSSFragment = aCSSArray[0];

                    NSString * trimmedCSSFragment = [aCSSFragment stringByTrimmingCharactersInSet:whitespaceSet];
                    
                    if ([trimmedCSSFragment isEqualToString:@"font-family"])
                    {
                        NSString * fontFamilyName = aCSSArray[1];
                        
                        if (fontFamilyName.length > 0)
                        {
                            fontFamilyName = [fontFamilyName stringByTrimmingCharactersInSet:whitespaceSet];

                            NSString * firstCharacterString = [fontFamilyName substringWithRange:NSMakeRange(0, 1)];
                            
                            if ([firstCharacterString isEqualToString:@"'"] == YES)
                            {
                                NSMutableString * trimmedFontFamilyName = [NSMutableString stringWithString:fontFamilyName];
                                NSRange trimmedFontFamilyNameRange = NSMakeRange(0, trimmedFontFamilyName.length);
                                [trimmedFontFamilyName replaceOccurrencesOfString:@"'" withString:@""
                                        options:NSLiteralSearch range:trimmedFontFamilyNameRange];
                                fontFamilyName = trimmedFontFamilyName;
                            }
                            
                            if ([firstCharacterString isEqualToString:@"\""] == YES)
                            {
                                NSMutableString * trimmedFontFamilyName = [NSMutableString stringWithString:fontFamilyName];
                                NSRange trimmedFontFamilyNameRange = NSMakeRange(0, trimmedFontFamilyName.length);
                                [trimmedFontFamilyName replaceOccurrencesOfString:@"\"" withString:@""
                                        options:NSLiteralSearch range:trimmedFontFamilyNameRange];
                                fontFamilyName = trimmedFontFamilyName;
                            }
                            
                            fontName = fontFamilyName;
                        }
                    }
                }
            }
        }
    }
    
    return fontName;
}

//==================================================================================
//	fontNameFromImport:
//==================================================================================

- (NSString *)fontNameFromImport:(NSString *)fontImportString
{
    // e.g., @import url(https://fonts.googleapis.com/css?family=Archivo+Black);
    NSString * fontName = NULL;
    
    NSRange importRange = [fontImportString rangeOfString:@"@import"];
    
    if (importRange.location != NSNotFound)
    {
        // @import data found
        NSRange urlRange = [fontImportString rangeOfString:@"url"];
        if (urlRange.location != NSNotFound)
        {
            NSString * urlParameterString = [fontImportString
                    substringFromIndex:(urlRange.location + urlRange.length)];
            
            NSRange openParenthesisRange = [urlParameterString rangeOfString:@"("];
            
            if (openParenthesisRange.location != NSNotFound)
            {
                NSRange closeParenthesisRange = [urlParameterString rangeOfString:@")"];
                if (closeParenthesisRange.location != NSNotFound)
                {
                    if (openParenthesisRange.location < closeParenthesisRange.location)
                    {
                        NSInteger urlStartIndex = openParenthesisRange.location + 1;
                        NSInteger urlLength = closeParenthesisRange.location - urlStartIndex;
                        NSRange urlRange = NSMakeRange(urlStartIndex, urlLength);
                        NSString * untrimmedUrlString = [urlParameterString substringWithRange:urlRange];
                        
                        NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

                        NSString * urlString = [untrimmedUrlString stringByTrimmingCharactersInSet:whitespaceSet];
                        
                        NSString * aFontName = [self fontNameFromURL:urlString];
                        
                        if (aFontName != NULL)
                        {
                            fontName = aFontName;
                        }
                    }
                }
            }
        }
    }

    return fontName;
}

//==================================================================================
//	buildDefinedFontsArray
//==================================================================================

- (void)buildDefinedFontsArray
{
    // build array from top-level defs/style elements, lower style element not currently included without recursion
    [self.definedFontsArray removeAllObjects];
    
    NSXMLDocument * xmlDocument = [textElementEditor activeXMLDocument];
    NSXMLElement * rootElement = [xmlDocument rootElement];
    
    // check for existing import of font
    NSArray * defsElementsArray = [rootElement elementsForName:@"defs"];
    for (NSXMLElement * aDefsElement in defsElementsArray)
    {
        NSArray * styleElementsArray = [aDefsElement elementsForName:@"style"];
        for (NSXMLElement * aStyleElement in styleElementsArray)
        {
            BOOL fontDefinitionFound = NO;
            NSString * fontName = @"Helvetica";

            NSString * styleElementTextContent = aStyleElement.stringValue;
            
            NSRange fontFaceRange = [styleElementTextContent rangeOfString:@"@font-face"];
            if (fontFaceRange.location != NSNotFound)
            {
                fontDefinitionFound = YES;
                NSString * aFontName = [self fontNameFromFontFace:styleElementTextContent];
                if (aFontName != NULL) fontName = aFontName;
            }
            
            NSRange importRange = [styleElementTextContent rangeOfString:@"@import"];
            if (importRange.location != NSNotFound)
            {
                fontDefinitionFound = YES;
                NSString * aFontName = [self fontNameFromImport:styleElementTextContent];
                if (aFontName != NULL) fontName = aFontName;
            }
            
            if (fontDefinitionFound == YES)
            {
                [self.definedFontsArray addObject:fontName];
            }
        }
    }
    [definedFontsTableView reloadData];
}

//==================================================================================
//	tabView:didSelectTabViewItem:
//==================================================================================

- (void)tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    NSInteger tabViewIndex = [aTabView indexOfTabViewItem:tabViewItem];

    NSString * fontName = @"Helvetica";

    NSString * textContent = [textElementEditor textElementContent];

    NSString * htmlString = [NSString stringWithFormat:
            @"<html><head><style>p.preview{font-family:'%@'; font-size:24px;}</style></head><body><p class='preview'>%@</p></body></html>",
            fontName, textContent];
    
    switch (tabViewIndex)
    {
        case 0:
            if (self.browserPreviewHTML != NULL)
            {
                htmlString = self.browserPreviewHTML;
            }
            break;

        case 1:
            if (self.googleWebfontsPreviewHTML != NULL)
            {
                htmlString = self.googleWebfontsPreviewHTML;
            }
            break;

        case 2:
            if (self.importPreviewHTML != NULL)
            {
                htmlString = self.importPreviewHTML;
            }
            break;

        case 3:
            [self buildDefinedFontsArray];
        
            if (self.definedPreviewHTML != NULL)
            {
                htmlString = self.definedPreviewHTML;
            }
            
            break;

        default:
            break;
    }
    
    [fontPreviewWebView.mainFrame loadHTMLString:htmlString baseURL:NULL];
}

//==================================================================================
//	connection:didReceiveResponse:
//==================================================================================

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
 
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
 
    // receivedData is an instance variable declared elsewhere.
    (self.googleWebFontsCatalogReceivedData).length = 0;
}

//==================================================================================
//	connection:didReceiveData:
//==================================================================================

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    [self.googleWebFontsCatalogReceivedData appendData:data];
}

//==================================================================================
//	connection:didFailWithError:
//==================================================================================

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          error.localizedDescription,
          error.userInfo[NSURLErrorFailingURLStringErrorKey]);
}

//==================================================================================
//	connectionDidFinishLoading:
//==================================================================================

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"Succeeded! Received %lu bytes of data",
    //        (unsigned long)[self.googleWebFontsCatalogReceivedData length]);

    NSString * jsonDataString = [[NSString alloc]
            initWithData:self.googleWebFontsCatalogReceivedData encoding:NSUTF8StringEncoding];
    
    SZJsonParser *parser = [[SZJsonParser alloc] initWithSource:jsonDataString];
    
    id obj = [parser parse];
    
    if (obj != NULL)
    {
        self.googleWebFontsCatalogDictionary = obj;
    }
    
    self.googleWebFontsCatalogReceivedData = NULL;
    
    [googleWebfontsTableView reloadData];
    
    [self storeGoogleWebFontsCatalog];
}



@end
