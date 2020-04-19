//
//  PathTextGeneratorWindowController.m
//  PathTextGenerator
//
//  Created by Douglas Ward on 9/25/17.
//  Copyright © 2017 ArkPhone LLC. All rights reserved.
//

#import "PathTextGeneratorWindowController.h"
#import "PathTextGenerator.h"
#import <MacSVGPlugin/MacSVGPlugin.h>
#import "NSFileManager+DirectoryLocations.h"
#import <MacSVGPlugin/SZJsonParser.h>

@interface PathTextGeneratorWindowController ()

@end

@implementation PathTextGeneratorWindowController

//==================================================================================
//	initWithWindow:
//==================================================================================

- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
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
//	windowDidLoad
//==================================================================================

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

//==================================================================================
//	setupFontsBrowser
//==================================================================================

- (void)setupFontsBrowser
{
}

//==================================================================================
//	generatePathButtonAction
//==================================================================================

- (IBAction)generatePathButtonAction:(id)sender
{
    NSString * inputTextString = inputTextField.stringValue;
    CGFloat fontSize = inputTextField.floatValue;
    float originX = originXTextField.floatValue;
    float originY = originYTextField.floatValue;

    [[NSApplication sharedApplication] stopModalWithCode:NSModalResponseOK];
    
    [self.window close];
    
    NSFont * font = [self selectedFont];
    
    if (font != NULL)
    {
        NSXMLElement * pathXMLElement = NULL;
        
        if ([singleOrMultiplePathPopUpButton.titleOfSelectedItem isEqualToString:@"Single Path"] == YES)
        {
            pathXMLElement = [pathTextGenerator createPathWithString:inputTextString font:font fontSize:fontSize originX:originX originY:originY];
        }
        else
        {
            pathXMLElement = [pathTextGenerator createMultiplePathsWithString:inputTextString font:font fontSize:fontSize originX:originX originY:originY];
        }
        
        //NSLog(@"pathXMLElement = %@", pathXMLElement);
    }
    else
    {
        NSBeep();
    }
}

/*

Printing description of googleWebfontDictionary:
{
    category = display;
    family = Bevan;
    files =     {
        regular = "http://fonts.gstatic.com/s/bevan/v8/Rtg3zDsCeQiaJ_Qno22OJA.ttf";
    };
    kind = "webfonts#webfont";
    lastModified = "2017-01-11";
    subsets =     (
        latin,
        "latin-ext",
        vietnamese
    );
    variants =     (
        regular
    );
    version = v8;
}

*/

//==================================================================================
//	fontFromData:withHeight:
//==================================================================================

- (NSFont *) fontFromData : (NSData *) fontData withHeight : (CGFloat) fontHeight;
{  
    // Get the path to our custom font and create a data provider.  
    //CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename ([fontPath UTF8String]);
    
    CFDataRef fontDataRef = (__bridge CFDataRef)(fontData);
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData (fontDataRef);
    if (NULL == dataProvider)
        return NULL;  
    
    // Create the font with the data provider, then release the data provider.  
    CGFontRef fontRef = CGFontCreateWithDataProvider ( dataProvider );  
    if ( NULL == fontRef )  
    {  
        CGDataProviderRelease ( dataProvider );   
        return NULL;  
    }
    
    CTFontRef fontCore = CTFontCreateWithGraphicsFont(fontRef, fontHeight, NULL, NULL);
    CGDataProviderRelease (dataProvider);   
    CGFontRelease(fontRef);
    
    NSFont * resultFont = (NSFont *)CFBridgingRelease(fontCore);
      
    return resultFont;
}  


//==================================================================================
//	selectedFont
//==================================================================================

- (NSFont *)selectedFont
{
    NSFont * resultFont = NULL;

    BOOL boldFontFlag = boldFontCheckboxButton.state;
    BOOL italicFontFlag = italicFontCheckboxButton.state;

    NSTabViewItem * tabViewItem = tabView.selectedTabViewItem;
    NSInteger tabViewItemIndex = [tabView indexOfTabViewItem:tabViewItem];
    
    switch (tabViewItemIndex)
    {
        case 0:
        {
            // Browser font tab
            NSInteger rowIndex = browserFontsTableView.selectedRow;
            NSString * fontName = [self stringValueForBrowserFontsRowIndex:rowIndex];
            //[textElementEditor setFontName:fontName];
            
            //resultFont = [NSFont fontWithName:fontName size:fontSizeTextField.floatValue];

            NSFontSymbolicTraits traits = 0;
            if (boldFontFlag == YES) {
                traits |= NSBoldFontMask;
            } else {
                traits |= NSUnboldFontMask;
            }
            if (italicFontFlag == YES) {
                traits |= NSItalicFontMask;
            } else {
                traits |= NSUnitalicFontMask;
            }

            NSFontManager * fontManager = [NSFontManager sharedFontManager];
            resultFont = [fontManager fontWithFamily:fontName traits:traits weight:5 size:fontSizeTextField.floatValue];
            
            if (resultFont == NULL)
            {
                resultFont = [NSFont fontWithName:fontName size:fontSizeTextField.floatValue];
            }
            
            if (resultFont == NULL)
            {
                NSLog(@"PathGeneratorWindowController - could not load font %@", fontName);
            }
            
            break;
        }
        case 1:
        {
            // Google Webfont tab
            //[self importOrEmbedGoogleWebFonts];
            NSInteger rowIndex = googleWebfontsTableView.selectedRow;
            NSString * fontName = @"Helvetica";
            NSArray * googleWebfontsListArray = (self.googleWebFontsCatalogDictionary)[@"items"];
            
            if (googleWebfontsListArray != NULL)
            {
                NSDictionary * googleWebfontDictionary = googleWebfontsListArray[rowIndex];
                
                if (googleWebfontDictionary != NULL)
                {
                    fontName = googleWebfontDictionary[@"family"];
                    
                    NSDictionary * filesDictionary = googleWebfontDictionary[@"files"];
                    
                    if (filesDictionary != NULL)
                    {
                        NSString * fileURLString = filesDictionary[@"regular"];
                        
                        if (fileURLString == NULL)
                        {
                            NSArray * allKeys = filesDictionary.allKeys;
                            if (allKeys.count > 0)
                            {
                                NSString * firstKey = allKeys.firstObject;
                                fileURLString = filesDictionary[firstKey];
                            }
                        }

                        if (fileURLString != NULL)
                        {
                            NSURL * googleWebFontURL = [NSURL URLWithString:fileURLString];
                        
                            NSData * downloadedFontData = [[NSData alloc] initWithContentsOfURL:googleWebFontURL];
                            
                            resultFont = [self fontFromData:downloadedFontData withHeight:fontSizeTextField.floatValue];
                        }
                    }
                }
            }
            //[textElementEditor setFontName:fontName];
            
            break;
        }

        case 2:
        {
            // Webfont or TrueType file tab
            //NSString * fontName = [self importOrEmbedFont];

            //[textElementEditor setFontName:fontName];

            //NSString * fontName = @"Helvetica";
            //NSArray * googleWebfontsListArray = (self.googleWebFontsCatalogDictionary)[@"items"];
            
            NSString * fileURLString = webfontPathTextField.stringValue;
            
            if (fileURLString != NULL)
            {
                NSURL * googleWebFontURL = [NSURL URLWithString:fileURLString];
            
                NSData * downloadedFontData = [[NSData alloc] initWithContentsOfURL:googleWebFontURL];
                
                resultFont = [self fontFromData:downloadedFontData withHeight:fontSizeTextField.floatValue];
            }

            break;
        }
        default:
            break;
    }
    
    return resultFont;
}

//==================================================================================
//	cancelButtonAction
//==================================================================================

- (IBAction)cancelButtonAction:(id)sender
{
    [[NSApplication sharedApplication] stopModalWithCode:NSModalResponseCancel];
    
    [self.window close];
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

        /*
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
        */
        
        __weak NSTableView * weakGoogleWebfontsTableView = googleWebfontsTableView;
        
        NSURLSessionDataTask * downloadTask = [[NSURLSession sharedSession] dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          // Handle response here
            NSData * receivedData = [NSData dataWithContentsOfURL:requestURL];
            self.googleWebFontsCatalogReceivedData = [receivedData mutableCopy];



            NSString * jsonDataString = [[NSString alloc]
                    initWithData:self.googleWebFontsCatalogReceivedData encoding:NSUTF8StringEncoding];
            
            SZJsonParser *parser = [[SZJsonParser alloc] initWithSource:jsonDataString];
            
            id obj = [parser parse];
            
            if (obj != NULL)
            {
                self.googleWebFontsCatalogDictionary = obj;
            }
            
            self.googleWebFontsCatalogReceivedData = NULL;
            
            //[weakGoogleWebfontsTableView reloadData];
            [weakGoogleWebfontsTableView performSelectorOnMainThread:@selector(reloadData) withObject:NULL waitUntilDone:YES];

            [self storeGoogleWebFontsCatalog];

        }];
            
        [downloadTask resume];

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
    
    NSXMLDocument * xmlDocument = [pathTextGenerator svgXmlDocument];
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
    [self updateWebViewFontPreview:self];
}

//==================================================================================
//	controlTextDidChange:
//==================================================================================

- (void)controlTextDidChange:(NSNotification *)notification {
    //NSTextField *textField = [notification object];
    //NSLog(@"controlTextDidChange: stringValue == %@", [textField stringValue]);
    [self updateWebViewFontPreview:self];
}

//==================================================================================
//	updateWebViewFontPreview:
//==================================================================================

- (IBAction)updateWebViewFontPreview:(id)sender
{
    NSTabViewItem * aTabViewItem = [tabView selectedTabViewItem];
    NSInteger tabViewIndex = [tabView indexOfTabViewItem:aTabViewItem];

    NSString * fontName = @"Helvetica";

    NSString * textContent = inputTextField.stringValue;

    NSString * htmlString = [NSString stringWithFormat:
            @"<html><head><style>p.preview{font-family:'%@'; font-size:%@px;}</style></head><body><p class='preview'>%@</p></body></html>",
            fontName, fontSizeTextField.stringValue, textContent];

    switch (tabViewIndex)
    {
        case 0:
            if (self.browserPreviewHTML != NULL)
            {
                //htmlString = self.browserPreviewHTML;
                [self browserFontsTableViewSelectionDidChange];
            }
            break;

        case 1:
            if (self.googleWebfontsPreviewHTML != NULL)
            {
                //htmlString = self.googleWebfontsPreviewHTML;
                [self googleWebfontsTableViewSelectionDidChange];
            }
            break;

        case 2:
            if (self.importPreviewHTML != NULL)
            {
                htmlString = self.importPreviewHTML;
                [fontPreviewWebView.mainFrame loadHTMLString:htmlString baseURL:NULL];
            }
            break;

        case 3:
            [self buildDefinedFontsArray];
        
            if (self.definedPreviewHTML != NULL)
            {
                //htmlString = self.definedPreviewHTML;
                [self definedFontsTableViewSelectionDidChange];
            }
            
            break;

        default:
            break;
    }
    
    //[fontPreviewWebView.mainFrame loadHTMLString:htmlString baseURL:NULL];
}

/*
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
*/

//==================================================================================
//	previewImportSelectionWithURL
//==================================================================================

- (void)previewImportSelectionWithURL:(NSString *)urlString fontName:(NSString *) fontName
{
    NSString * textContent = inputTextField.stringValue;
    
    NSString * htmlString = [NSString stringWithFormat:
            @"<html><head><link href='%@' rel='stylesheet' type='text/css'><style>p.preview{font-family:'%@'; font-size:%@px;}</style></head><body><p class='preview'>%@</p></body></html>",
            urlString, fontName, fontSizeTextField.stringValue, textContent];
    
    [fontPreviewWebView.mainFrame loadHTMLString:htmlString baseURL:NULL];
    
    self.importPreviewHTML = htmlString;
}

//==================================================================================
//	previewImportSelectionWithURL
//==================================================================================

- (void)previewTruetypeSelectionWithURL:(NSString *)urlString fontName:(NSString *) fontName
{
    NSString * textContent = inputTextField.stringValue;
    
    NSString * fontWeight = @"normal";
    NSString * fontStyle = @"normal";
    NSString * fontStretch = @"normal";
    NSString * fontType = @"truetype";

    NSString * cssString = [NSString stringWithFormat:@"@font-face {font-family:'%@'; font-weight:%@; font-style:%@; font-stretch:%@; src:url(%@) format('%@');}",
                fontName, fontWeight, fontStyle, fontStretch, urlString, fontType];
    
    NSString * htmlString = [NSString stringWithFormat:
            @"<html><head><style>%@p.preview{font-family:'%@'; font-size:%@px;}</style></head><body><p class='preview'>%@</p></body></html>",
            cssString, fontName, fontSizeTextField.stringValue, textContent];
    
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
    
    NSString * textContent = inputTextField.stringValue;
    
    NSString * htmlString = [NSString stringWithFormat:
            @"<html><head><style>p.preview{font-family:'%@'; font-size:%@px;}</style></head><body><p class='preview'>%@</p></body></html>",
            fontName, fontSizeTextField.stringValue, textContent];
    
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
    
    NSString * textContent = inputTextField.stringValue;
    
    NSString * htmlString = [NSString
            stringWithFormat:@"<html><head><link href='http://fonts.googleapis.com/css?family=%@' rel='stylesheet' type='text/css'><style>p.preview{font-family:'%@'; font-size:%@px;}</style></head><body><p class='preview'>%@</p></body></html>",
            fontURLName, fontName, fontSizeTextField.stringValue, textContent];
    
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
    
    NSString * textContent = inputTextField.stringValue;
    
    NSString * htmlString = [NSString stringWithFormat:
            @"<html><head><style>p.preview{font-family:'%@'; font-size:%@px;}</style></head><body><p class='preview'>%@</p></body></html>",
            fontName, fontSizeTextField.stringValue, textContent];
    
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
    
    __block NSTextField * weakWebfontPathTextField = webfontPathTextField;
    __block NSTextField * weakWebfontStatusMessageTextField = webfontStatusMessageTextField;

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
        }
    }];
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
    
    if (cfFontDescriptor != NULL)
    {
        CFDictionaryRef fontDescriptorCFDictionary = CTFontDescriptorCopyAttributes(cfFontDescriptor);
        NSDictionary * fontDescriptorDictionary = CFBridgingRelease(fontDescriptorCFDictionary);
        
        fontName = fontDescriptorDictionary[@"NSFontNameAttribute"];
    }
    else
    {
        NSBeep();
    }
    
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
    
    NSIndexSet * firstRowIndexSet = [NSIndexSet indexSetWithIndex:0];
    [browserFontsTableView selectRowIndexes:firstRowIndexSet byExtendingSelection:NO];
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




@end
