//
//  MacSVGAppDelegate.m
//  macSVG
//
//  Created by Douglas Ward on 7/30/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "MacSVGAppDelegate.h"
#import "MacSVGDocumentController.h"
#import "MacSVGDocument.h"
#import "MacSVGDocumentWindowController.h"
#import "SVGWebKitController.h"
#import "SVGWebView.h"
#import "XMLOutlineController.h"
#import "SVGDTDData.h"
#import "TextDocumentWindowController.h"
#import "TextDocument.h"
#import "WebKitInterface.h"
#import "NetworkConnectionManager.h"
#import "ToolSettingsPopoverViewController.h"

@implementation MacSVGAppDelegate

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.webServerController = NULL;
    self.svgDtdData = NULL;
    self.documentationDictionary = NULL;
    self.svgExampleTextView = NULL;
}

//==================================================================================
//	init
//==================================================================================

- (id)init
{
    self = [super init];	// change to nil if an error occurs during initialization
    if (self)
    {
		[NSApp setDelegate:self];

        self.svgDtdData = [[SVGDTDData alloc] init];

        webKitInterface = [[WebKitInterface alloc] init];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject: 
        [NSNumber numberWithBool:YES] forKey:@"WebKitDeveloperExtras"]];

        self.svgDocumentPrototypeName = @"Untitled";
        self.svgDocumentPrototypeExtension = @"svg";
    }
    return self;
}

//==================================================================================
//	applicationWillFinishLaunching
//==================================================================================

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification 
{
}

//==================================================================================
//	applicationDidFinishLaunching
//==================================================================================

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
    //NSString * localizedName = [[NSHost currentHost] localizedName];
}

//==================================================================================
//	awakeFromNib
//==================================================================================

- (void)awakeFromNib 
{
    [super awakeFromNib];

    [self loadDocumentationDictionary];
}

//==================================================================================
//	applicationShouldOpenUntitledFile
//==================================================================================

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return YES;
}

//==================================================================================
//	application:openFile:
//==================================================================================

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    // handle "Open Recent" menu commands
    BOOL result = NO;
    
    MacSVGDocumentController * macSVGDocumentController =
            [NSDocumentController sharedDocumentController];

    NSURL * absoluteURL = [NSURL fileURLWithPath:filename];
    
    NSError * outError = NULL;

    NSString * typeName = [macSVGDocumentController typeForContentsOfURL:absoluteURL
            error:&outError];

    if (outError == NULL)
    {
        [macSVGDocumentController makeDocumentWithContentsOfURL:absoluteURL
                ofType:typeName error:&outError];
        
        if (outError == NULL)
        {
            result = YES;
        }
    }
    
    return result;
}

//==================================================================================
//	panel:didChangeToDirectoryURL:
//==================================================================================

- (void)panel:(id)sender didChangeToDirectoryURL:(NSURL *)url
{

}

//==================================================================================
//	panel:shouldEnableURL:
//==================================================================================

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url
{
    return YES;
}

//==================================================================================
//	panel:validateURL:error:
//==================================================================================

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError
{
    return YES;
}

//==================================================================================
//	panelSelectionDidChange:
//==================================================================================

- (void)panelSelectionDidChange:(id)sender
{

}

//==================================================================================
//	openUntitledMacSVGDocument
//==================================================================================

- (IBAction)openUntitledMacSVGDocument:(id)sender
{
    NSError * docError = NULL;
    
    self.svgDocumentPrototypeName = @"Untitled";
    self.svgDocumentPrototypeExtension = @"svg";
    
    MacSVGDocumentController * svgDocumentController = [NSDocumentController sharedDocumentController];
    
    MacSVGDocument * macSVGDocument = [svgDocumentController
            openUntitledDocumentAndDisplay:YES error:&docError];

	if (macSVGDocument == NULL)
	{
		NSLog(@"OpenUntitledMacSVGDocument failed");
	}
}

//==================================================================================
//	openUntitledSVGBannerDocument
//==================================================================================

- (IBAction)openUntitledSVGBannerDocument:(id)sender
{
    NSError * docError = NULL;
    
    self.svgDocumentPrototypeName = @"Untitled-Banner";
    self.svgDocumentPrototypeExtension = @"svg";
    
    MacSVGDocument * macSVGDocument = [[NSDocumentController sharedDocumentController]
            openUntitledDocumentAndDisplay:YES error:&docError];

	if (macSVGDocument == NULL)
	{
		NSLog(@"openUntitledSVGBannerDocument failed");
	}
}

//==================================================================================
//	openUntitledMacSVGXHTMLDocument
//==================================================================================

- (IBAction)openUntitledMacSVGXHTMLDocument:(id)sender
{
    NSError * docError = NULL;

    self.svgDocumentPrototypeName = @"Untitled";
    self.svgDocumentPrototypeExtension = @"xhtml";
    
    MacSVGDocument * macSVGDocument = [[NSDocumentController sharedDocumentController]
            openUntitledDocumentAndDisplay:YES error:&docError];

	if (macSVGDocument == NULL)
	{
		NSLog(@"openUntitledMacSVGXHTMLDocument failed");
	}
}

//==================================================================================
//	openUntitledMacSVGXHTMLBanner
//==================================================================================

- (IBAction)openUntitledMacSVGXHTMLBanner:(id)sender
{
    NSError * docError = NULL;

    self.svgDocumentPrototypeName = @"Untitled-Banner";
    self.svgDocumentPrototypeExtension = @"xhtml";
    
    MacSVGDocumentController * macSVGDocumentController = [NSDocumentController sharedDocumentController];
    MacSVGDocument * macSVGDocument = [macSVGDocumentController
            openUntitledDocumentAndDisplay:YES error:&docError];

	if (macSVGDocument == NULL)
	{
		NSLog(@"openUntitledMacSVGXHTMLBanner failed");
	}
}

//==================================================================================
//	openMacSVGDocumentWithNetworkConnection:
//==================================================================================

- (IBAction)openMacSVGDocumentWithNetworkConnection:(id)sender
{
    [networkConnectionManager openMacSVGDocumentWithNetworkConnection:self];
}

//==================================================================================
//	saveMacSVGDocumentWithNetworkConnection:
//==================================================================================

- (IBAction)saveMacSVGDocumentWithNetworkConnection:(id)sender;
{
    MacSVGDocumentWindowController * macSVGDocumentWindowController =
            [self findFrontmostMacSVGWindowController];
    MacSVGDocument * macSVGDocument = [macSVGDocumentWindowController document];
    
    NSMutableDictionary * networkConnectionDictionary = [NSMutableDictionary dictionary];

    /*
    NSString * networkAccessMethod = [networkConnectionDictionary objectForKey:@"connectionType"];
    NSString * hostNameString = [networkConnectionDictionary objectForKey:@"hostName"];
    //NSString * portNumberString = [networkConnectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [networkConnectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [networkConnectionDictionary objectForKey:@"password"];
    NSString * urlFilePath = [networkConnectionDictionary objectForKey:@"urlFilePath"];
    */
    
    BOOL result = [networkConnectionManager saveAsDocument:macSVGDocument
        networkConnectionDictionary:networkConnectionDictionary];
    
    if (result == false)
    {
    }
}

//==================================================================================
//	openUntitledTextDocument
//==================================================================================

- (IBAction)openUntitledTextDocument:(id)sender
{
    TextDocument * textDocument = [TextDocument new];
    [textDocument makeWindowControllers];
    [[NSDocumentController sharedDocumentController] addDocument: textDocument];
    [textDocument showWindows];

    TextDocumentWindowController * aTextDocumentWindowController = 
            textDocument.textDocumentWindowController;

    NSWindow * aWindow = [aTextDocumentWindowController window];
    #pragma unused(aWindow)
    [aTextDocumentWindowController showWindow:self];
    
	if (textDocument == NULL)
	{
		NSLog(@"OpenUntitledTextDocument failed");
	}
}


//==================================================================================
//	applicationOpenUntitledFile
//==================================================================================

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
    [self openUntitledMacSVGDocument:theApplication];
    return YES;
}

//==================================================================================
//	webKitInterface
//==================================================================================

-(WebKitInterface *)webKitInterface
{
    return webKitInterface;
}

//==================================================================================
//	networkConnectionManager
//==================================================================================

- (NetworkConnectionManager *)networkConnectionManager
{
    return networkConnectionManager;
}

//==================================================================================
//	webKitInterface
//==================================================================================

-(void)loadDocumentationDictionary
{
    //NSString *errorDesc = nil;
    NSError *plistError = nil;
    NSPropertyListFormat format;

    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString * plistPath = [thisBundle pathForResource:@"DocumentationLinks" ofType:@"plist"];
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    
    //NSDictionary * tempDictionary1 = (NSDictionary *)[NSPropertyListSerialization
    //        propertyListFromData:plistXML
    //        mutabilityOption:NSPropertyListMutableContainersAndLeaves
    //        format:&format
    //        errorDescription:&errorDesc];
    
    NSDictionary * tempDictionary = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListMutableContainersAndLeaves format:&format error:&plistError];
    
    if (!tempDictionary)
    {
        NSString * errorDesc = [plistError localizedDescription];
    
        NSLog(@"Error reading plist: %@, format: %lu", errorDesc, format);
    }
    else
    {
        self.documentationDictionary = tempDictionary;
    }
}

// -------------------------------------------------------------------------------
//  launchWebBrowserDocument
// -------------------------------------------------------------------------------

- (IBAction)launchWebBrowserDocument:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]] == YES)
    {
        NSMenuItem * menuItem = sender;
        
        NSString * itemTitle = [menuItem title];
        
        NSString * urlString = [self.documentationDictionary objectForKey:itemTitle];

        if (urlString != NULL)
        {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
        }
    }
}

// -------------------------------------------------------------------------------
//  selectAll
// -------------------------------------------------------------------------------

- (IBAction)selectAll:(id)sender
{
    NSWindow * keyWindow = [NSApp keyWindow];
    NSWindowController * windowController = [keyWindow windowController];
    
    if ([windowController isKindOfClass:[MacSVGDocumentWindowController class]] == YES)
    {
        MacSVGDocumentWindowController * svgDocumentWindowController =
                (MacSVGDocumentWindowController *)windowController;
        id firstReponder = [keyWindow firstResponder];
        
        BOOL svgWebViewFound = NO;
        NSView * findSuperView = [firstReponder superview];
        while (findSuperView != NULL)
        {
            if (findSuperView == (NSView *)svgDocumentWindowController.svgWebKitController.svgWebView)
            {
                svgWebViewFound = YES;
                break;
            }
            else
            {
                findSuperView = [findSuperView superview];
            }
        }
        
        if (svgWebViewFound == YES)
        {
           firstReponder = svgDocumentWindowController.xmlOutlineController.xmlOutlineView;
        }
        [firstReponder selectAll:sender];
    }
    else
    {
        id firstReponder = [keyWindow firstResponder];
        [firstReponder selectAll:sender];
    }
}

// -------------------------------------------------------------------------------
//  deselectAll
// -------------------------------------------------------------------------------

- (IBAction)deselectAll:(id)sender
{
    [self selectNone:sender];
}

// -------------------------------------------------------------------------------
//  selectNone
// -------------------------------------------------------------------------------

- (IBAction)selectNone:(id)sender
{
    NSWindow * keyWindow = [NSApp keyWindow];
    NSWindowController * windowController = [keyWindow windowController];
    
    if ([windowController isKindOfClass:[MacSVGDocumentWindowController class]] == YES)
    {
        MacSVGDocumentWindowController * svgDocumentWindowController =
                (MacSVGDocumentWindowController *)windowController;
        id firstReponder = [keyWindow firstResponder];
        
        BOOL svgWebViewFound = NO;

        // 20160627 check for firstResponder is a view class
        if ([firstReponder isKindOfClass:[NSView class]] == YES)
        {
            NSView * findSuperView = [firstReponder superview];
            while (findSuperView != NULL)
            {
                if (findSuperView == (NSView *)svgDocumentWindowController.svgWebKitController.svgWebView)
                {
                    svgWebViewFound = YES;
                    break;
                }
                else
                {
                    findSuperView = [findSuperView superview];
                }
            }
        }
        
        if (svgWebViewFound == YES)
        {
           firstReponder = svgDocumentWindowController.xmlOutlineController.xmlOutlineView;
        }
        
        // 20160627 check for firstResponder is a view class
        if ([firstReponder respondsToSelector:@selector(selectNone:)] == YES)
        {
            [firstReponder selectNone:sender];
        }
    }
    else
    {
        id firstReponder = [keyWindow firstResponder];
        //[firstReponder selectNone:sender];
        if ([firstReponder respondsToSelector:@selector(selectNone:)] == YES)
        {
            [firstReponder selectNone:sender];
        }
    }
}

//==================================================================================
//	findFrontmostMacSVGWindowController
//==================================================================================

- (MacSVGDocumentWindowController *)findFrontmostMacSVGWindowController
{
    MacSVGDocumentWindowController * result = NULL;
    
    NSArray * windowsArray = [[NSApplication sharedApplication] orderedWindows];
    
    for (NSWindow * aWindow in windowsArray)
    {
        NSWindowController * aWindowController = aWindow.windowController;
        
        if ([aWindowController isKindOfClass:[MacSVGDocumentWindowController class]] == YES)
        {
            result = (MacSVGDocumentWindowController *)aWindowController;
            break;
        }
    }
    
    return result;
}

//==================================================================================
// showWebKitInspectorAction:
//==================================================================================

- (IBAction)showWebKitInspectorAction:(id)sender
{
    MacSVGDocumentWindowController * aMacSVGDocumentWindowController = [self findFrontmostMacSVGWindowController];
    if (aMacSVGDocumentWindowController != NULL)
    {
        [aMacSVGDocumentWindowController.svgWebKitController showWebKitInspectorAction:sender];
    }
}

//==================================================================================
// detachWebKitInspectorAction:
//==================================================================================

- (IBAction)detachWebKitInspectorAction:(id)sender
{
    MacSVGDocumentWindowController * aMacSVGDocumentWindowController = [self findFrontmostMacSVGWindowController];
    if (aMacSVGDocumentWindowController != NULL)
    {
        [aMacSVGDocumentWindowController.svgWebKitController detachWebKitInspectorAction:sender];
    }
}

//==================================================================================
// disableJavaScriptAction:
//==================================================================================

- (IBAction)disableJavaScriptAction:(id)sender
{
    MacSVGDocumentWindowController * aMacSVGDocumentWindowController = [self findFrontmostMacSVGWindowController];
    if (aMacSVGDocumentWindowController != NULL)
    {
        [aMacSVGDocumentWindowController.svgWebKitController disableJavaScriptAction:sender];
    }
    
    if (aMacSVGDocumentWindowController.svgWebKitController.javaScriptIsDisabled == YES)
    {
        self.disableJavasScriptMenuItem.title = @"Enable JavaScript";
    }
    else
    {
        self.disableJavasScriptMenuItem.title = @"Disable JavaScript";
    }
}

//==================================================================================
// enableJavaScriptProfilingAction:
//==================================================================================

- (IBAction)enableJavaScriptProfilingAction:(id)sender
{
    MacSVGDocumentWindowController * aMacSVGDocumentWindowController = [self findFrontmostMacSVGWindowController];
    if (aMacSVGDocumentWindowController != NULL)
    {
        [aMacSVGDocumentWindowController.svgWebKitController enableJavaScriptProfilingAction:sender];
    }
}

//==================================================================================
// enableTimelineProfilingAction:
//==================================================================================

- (IBAction)enableTimelineProfilingAction:(id)sender
{
    MacSVGDocumentWindowController * aMacSVGDocumentWindowController = [self findFrontmostMacSVGWindowController];
    if (aMacSVGDocumentWindowController != NULL)
    {
        [aMacSVGDocumentWindowController.svgWebKitController enableTimelineProfilingAction:sender];
    }
}

//==================================================================================
// startDebuggingJavaScriptAction:
//==================================================================================

- (IBAction)startDebuggingJavaScriptAction:(id)sender
{
    MacSVGDocumentWindowController * aMacSVGDocumentWindowController = [self findFrontmostMacSVGWindowController];
    if (aMacSVGDocumentWindowController != NULL)
    {
        [aMacSVGDocumentWindowController.svgWebKitController startDebuggingJavaScriptAction:sender];
    }
}

//==================================================================================
// startProfilingJavaScriptAction:
//==================================================================================

- (IBAction)startProfilingJavaScriptAction:(id)sender
{
    MacSVGDocumentWindowController * aMacSVGDocumentWindowController = [self findFrontmostMacSVGWindowController];
    if (aMacSVGDocumentWindowController != NULL)
    {
        [aMacSVGDocumentWindowController.svgWebKitController startProfilingJavaScriptAction:sender];
    }
}

//==================================================================================
// generateCoreGraphicsCode:
//==================================================================================

- (IBAction)generateCoreGraphicsCode:(id)sender
{
    MacSVGDocumentWindowController * aMacSVGDocumentWindowController = [self findFrontmostMacSVGWindowController];
    [aMacSVGDocumentWindowController generateCoreGraphicsCode:sender];
}

//==================================================================================
// generateHTML5Video:
//==================================================================================

- (IBAction)generateHTML5Video:(id)sender;

{
    MacSVGDocumentWindowController * aMacSVGDocumentWindowController = [self findFrontmostMacSVGWindowController];
    [aMacSVGDocumentWindowController generateHTML5Video:sender];
}

//==================================================================================
//	openUntitledSVGExample:
//==================================================================================

- (IBAction)browseSVGExamples:(id)sender
{
    self.svgExampleSearchField.stringValue = @"";

    [self buildSvgTestSuiteExamplesArray];
    [self buildMacSVGExamplesArray];
    
    [self.svgExampleTableView deselectAll:self];
    
    [self.svgExampleTableView reloadData];
    
    if ([self.filteredSvgExamplesArray count] > 0)
    {
        NSIndexSet * firstRowIndexSet = [NSIndexSet indexSetWithIndex:0];
        [self.svgExampleTableView selectRowIndexes:firstRowIndexSet byExtendingSelection:NO];
    }
    
    [self showSelectedSVGExample];

    NSModalSession session = [NSApp beginModalSessionForWindow:self.browseSVGExamplesWindow];
    //NSInteger result = NSRunContinuesResponse;
    NSInteger result = NSModalResponseContinue;

    while (result == NSModalResponseContinue)
    {
        //run the modal session
        //once the modal window finishes, it will return a different result and break out of the loop
        result = [NSApp runModalSession:session];

        //this gives the main run loop some time so your other code processes
        [[NSRunLoop currentRunLoop] limitDateForMode:NSDefaultRunLoopMode];

        //do some other non-intensive task if necessary
    }

    [NSApp endModalSession:session];

    [[self.svgExampleWebView mainFrame] loadHTMLString:@"" baseURL:NULL];

    [self.browseSVGExamplesWindow orderOut:self];
}

//==================================================================================
//	cancelUntitledSVGExample:
//==================================================================================

- (IBAction)cancelUntitledSVGExample:(id)sender
{
    [NSApp stopModalWithCode:NSModalResponseAbort];
}

//==================================================================================
//	loadUntitledSVGExample:
//==================================================================================

- (IBAction)loadUntitledSVGExample:(id)sender
{
    [NSApp stopModalWithCode:NSModalResponseStop];
    
    NSError * docError = NULL;
    
    self.svgDocumentPrototypeName = @"Untitled";
    self.svgDocumentPrototypeExtension = @"svg";
    
    MacSVGDocumentController * macSVGDocumentController = [NSDocumentController sharedDocumentController];
    
    MacSVGDocument * macSVGDocument = [macSVGDocumentController
            openUntitledDocumentAndDisplay:NO error:&docError];

    NSInteger selectedRow = [self.svgExampleTableView selectedRow];
    
    NSDictionary * exampleDictionary = [self.filteredSvgExamplesArray objectAtIndex:selectedRow];

    NSString * popUpTitle = self.svgExamplePopUpButton.title;
    NSArray * selectedExamplesArray = self.macSVGExamplesArray;
    if ([popUpTitle isEqualToString:@"SVG Test Suite"])
    {
        selectedExamplesArray = self.testSuiteArray;
    }
    
    NSString * pathString = [exampleDictionary objectForKey:@"path"];
    
    NSData * svgXmlData = [NSData dataWithContentsOfFile:pathString];

    BOOL result = [macSVGDocument readFromData:svgXmlData
            ofType:@"svg" error:&docError];
    
    if (result == YES)
    {
        NSXMLDocument * xmlDocument = macSVGDocument.svgXmlDocument;
    
        NSXMLElement * rootElement = [xmlDocument rootElement];
    
        if (selectedExamplesArray == self.testSuiteArray)
        {
            NSXMLNode * xrefBaseAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            [xrefBaseAttributeNode setName:@"xml:base"];
            [xrefBaseAttributeNode setStringValue:@"http://www.w3.org/Graphics/SVG/Test/20110816/svg/"];
            [rootElement addAttribute:xrefBaseAttributeNode];
            
            NSXMLNode * widthAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            [widthAttributeNode setName:@"width"];
            [widthAttributeNode setStringValue:@"480px"];
            [rootElement addAttribute:widthAttributeNode];

            NSXMLNode * heightAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            [heightAttributeNode setName:@"height"];
            [heightAttributeNode setStringValue:@"360px"];
            [rootElement addAttribute:heightAttributeNode];

            NSString * xpathQuery = @"//font-face-uri[@xlink:href=\"../resources/SVGFreeSans.svg#ascii\"]";
            NSError * error = NULL;
            NSArray * resultArray = [rootElement nodesForXPath:xpathQuery error:&error];
            for (NSXMLElement * resultElement in resultArray)
            {
                NSXMLNode * xlinkHrefAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                [xlinkHrefAttributeNode setName:@"xlink:href"];
                [xlinkHrefAttributeNode setStringValue:@"http://www.w3.org/Graphics/SVG/Test/20110816/resources/SVGFreeSans.svg"];
                [resultElement addAttribute:xlinkHrefAttributeNode];
            }
        }

        macSVGDocument.fileNameExtension = @"svg";
        
        [macSVGDocument makeWindowControllers];
        [macSVGDocument showWindows];

        if (selectedExamplesArray == self.testSuiteArray)
        {
            macSVGDocument.macSVGDocumentWindowController.toolSettingsPopoverViewController.showCheckerboardBackground = NO;
            macSVGDocument.macSVGDocumentWindowController.toolSettingsPopoverViewController.checkerboardBackgroundCheckboxButton.state = NO;
        }
        else
        {
            macSVGDocument.macSVGDocumentWindowController.toolSettingsPopoverViewController.showCheckerboardBackground = YES;
            macSVGDocument.macSVGDocumentWindowController.toolSettingsPopoverViewController.checkerboardBackgroundCheckboxButton.state = YES;
        }
    }
}

//==================================================================================
//	numberOfRowsInTableView
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [self.filteredSvgExamplesArray count];
}

//==================================================================================
//	tableView:objectValueForTableColumn:rowIndex
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSDictionary * exampleDictionary = [self.filteredSvgExamplesArray objectAtIndex:rowIndex];
    
    id objectValue = [exampleDictionary objectForKey:@"title"];

    return objectValue;
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    id notificationObject = [aNotification object];
    
    if (notificationObject == self.svgExampleTableView)
    {
        [self showSelectedSVGExample];
    }
}

//==================================================================================
//	showSelectedSVGExample
//==================================================================================

- (void)showSelectedSVGExample
{
    NSString * popUpTitle = self.svgExamplePopUpButton.title;
    NSArray * selectedExamplesArray = self.macSVGExamplesArray;
    if ([popUpTitle isEqualToString:@"SVG Test Suite"])
    {
        selectedExamplesArray = self.testSuiteArray;
    }

    NSInteger selectedRow = [self.svgExampleTableView selectedRow];
    
    if (selectedRow >= 0)
    {
        if (selectedRow < [self.filteredSvgExamplesArray count])
        {
            [self.svgExampleWebView setMaintainsBackForwardList:NO];

            NSDictionary * exampleDictionary = [self.filteredSvgExamplesArray objectAtIndex:selectedRow];

            NSString * pathString = [exampleDictionary objectForKey:@"path"];
            NSAttributedString * descriptionString = [exampleDictionary objectForKey:@"description"];
            
            NSData * xmlData = [NSData dataWithContentsOfFile:pathString];

            NSError * xmlError = NULL;
            NSXMLDocument * xmlDocument = [[NSXMLDocument alloc] initWithData:xmlData options:0 error:&xmlError];

            NSXMLElement * rootElement = [xmlDocument rootElement];

            if (selectedExamplesArray == self.testSuiteArray)
            {
                NSXMLNode * namespace = [NSXMLNode namespaceWithName:@"d"
                                          stringValue:@"http://www.w3.org/2000/02/svg/testsuite/description/"];
                [rootElement addNamespace:namespace];
                
                NSXMLNode * xrefBaseAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                [xrefBaseAttributeNode setName:@"xml:base"];
                [xrefBaseAttributeNode setStringValue:@"http://www.w3.org/Graphics/SVG/Test/20110816/svg/"];
                [rootElement addAttribute:xrefBaseAttributeNode];
            }
            
            NSData * xmlData2 = [xmlDocument XMLData];

            [[self.svgExampleWebView mainFrame] loadData:xmlData2
                    MIMEType:@"image/svg+xml"
                    textEncodingName:@"UTF-8" 
                    baseURL:NULL];
            
            [[self.svgExampleTextView textStorage] setAttributedString:descriptionString];
        }
    }
}

//==================================================================================
//	svgExamplePopUpButtonAction
//==================================================================================

- (IBAction)svgExamplePopUpButtonAction:(id)sender
{
    NSString * popUpTitle = self.svgExamplePopUpButton.title;
    if ([popUpTitle isEqualToString:@"SVG Test Suite"])
    {
        [self searchSVGExamplesInArray:self.testSuiteArray];
    }
    else
    {
        [self searchSVGExamplesInArray:self.macSVGExamplesArray];
    }
    
    [self.svgExampleTableView deselectAll:self];
    
    [self.svgExampleTableView reloadData];
    
    if ([self.filteredSvgExamplesArray count] > 0)
    {
        NSIndexSet * firstRowIndexSet = [NSIndexSet indexSetWithIndex:0];
        [self.svgExampleTableView selectRowIndexes:firstRowIndexSet byExtendingSelection:NO];
    }
    
    [self showSelectedSVGExample];
}

//==================================================================================
//	buildSvgTestSuiteExamplesArray
//==================================================================================

- (void)buildSvgTestSuiteExamplesArray
{
    if (self.testSuiteArray == NULL)
    {
        self.testSuiteArray = [NSMutableArray array];
        
        NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
        
        NSString * examplesPath = [resourcePath stringByAppendingPathComponent:@"svg_test_suite/svg"];
        
        NSArray * examplePathsArray = [NSBundle pathsForResourcesOfType:@"svg"
                inDirectory:examplesPath];

        NSFont * textFont = [NSFont systemFontOfSize:13];

        NSDictionary * textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                textFont, NSFontAttributeName,
                NULL];
        
        NSFont * boldFont = [NSFont boldSystemFontOfSize:13];
        
        NSDictionary * boldTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                boldFont, NSFontAttributeName,
                NULL];
        
        for (NSString * pathToExample in examplePathsArray)
        {
            NSError * fileError = NULL;
            NSString * svgString = [NSString stringWithContentsOfFile:pathToExample encoding:NSUTF8StringEncoding error:&fileError];
        
            NSError * xmlError = NULL;
            NSXMLDocument * xmlDocument = [[NSXMLDocument alloc] initWithXMLString:svgString options:0 error:&xmlError];

            NSXMLElement * rootElement = [xmlDocument rootElement];

            NSXMLNode * namespace = [NSXMLNode namespaceWithName:@"d"
                                      stringValue:@"http://www.w3.org/2000/02/svg/testsuite/description/"];
            [rootElement addNamespace:namespace];
            
            NSXMLNode * xrefBaseAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            [xrefBaseAttributeNode setName:@"xml:base"];
            [xrefBaseAttributeNode setStringValue:@"http://www.w3.org/Graphics/SVG/Test/20110816/svg/"];
            [rootElement addAttribute:xrefBaseAttributeNode];

            NSString * xpathQuery = @".//title";
            
            NSError * error = NULL;
            NSArray * resultArray = [rootElement nodesForXPath:xpathQuery error:&error];
            
            if ([resultArray count] > 0)
            {
                NSXMLElement * titleElement = [resultArray firstObject];
                
                NSString * titleString = [titleElement stringValue];
                
                titleString = [titleString stringByReplacingOccurrencesOfString:@"$RCSfile: " withString:@""];
                titleString = [titleString stringByReplacingOccurrencesOfString:@",v $" withString:@""];
                
                NSMutableAttributedString * descriptionString = [[NSMutableAttributedString alloc] init];

                NSAttributedString * titleAttributedString = [[NSAttributedString alloc]
                        initWithString:titleString attributes:boldTextAttributes];
                [descriptionString appendAttributedString:titleAttributedString];
            
                NSAttributedString * testSuiteDescriptionTitleAttributedString = [[NSAttributedString alloc]
                        initWithString:@"\n\nDescription:\n" attributes:boldTextAttributes];
                [descriptionString appendAttributedString:testSuiteDescriptionTitleAttributedString];

                NSString * testSuiteDescriptionXpathQuery = @"//d:testDescription";
                NSArray * testSuiteDescriptionResultArray = [rootElement nodesForXPath:testSuiteDescriptionXpathQuery error:&error];
                if ([testSuiteDescriptionResultArray count] > 0)
                {
                    NSXMLElement * testSuiteDescriptionElement = [testSuiteDescriptionResultArray firstObject];
                    NSString * testSuiteDescriptionString = [testSuiteDescriptionElement stringValue];

                    testSuiteDescriptionString = [testSuiteDescriptionString stringByReplacingOccurrencesOfString:@"   " withString:@" "];
                    testSuiteDescriptionString = [testSuiteDescriptionString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                    testSuiteDescriptionString = [testSuiteDescriptionString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                    
                    NSAttributedString * testSuiteDescriptionAttributedString = [[NSAttributedString alloc]
                            initWithString:testSuiteDescriptionString attributes:textAttributes];
                    
                    [descriptionString appendAttributedString:testSuiteDescriptionAttributedString];
                }
                

                NSAttributedString * testSuitePassCriteriaTitleAttributedString = [[NSAttributedString alloc]
                        initWithString:@"\n\nPass Criteria:\n" attributes:boldTextAttributes];
                [descriptionString appendAttributedString:testSuitePassCriteriaTitleAttributedString];


                NSString * testSuitePassCriteriaXpathQuery = @"//d:passCriteria";
                NSArray * testSuitePassCriteriaResultArray = [rootElement nodesForXPath:testSuitePassCriteriaXpathQuery error:&error];
                if ([testSuitePassCriteriaResultArray count] > 0)
                {
                    NSXMLElement * testSuitePassCriteriaElement = [testSuitePassCriteriaResultArray firstObject];
                    NSString * testSuitePassCriteriaString = [testSuitePassCriteriaElement stringValue];
                    
                    testSuitePassCriteriaString = [testSuitePassCriteriaString stringByReplacingOccurrencesOfString:@"   " withString:@" "];
                    testSuitePassCriteriaString = [testSuitePassCriteriaString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                    testSuitePassCriteriaString = [testSuitePassCriteriaString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                    
                    NSAttributedString * testSuitePassCriteriaAttributedString = [[NSAttributedString alloc]
                            initWithString:testSuitePassCriteriaString attributes:textAttributes];
                    
                    [descriptionString appendAttributedString:testSuitePassCriteriaAttributedString];
                }
                



                NSDictionary * exampleDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                    titleString, @"title",
                    pathToExample, @"path",
                    descriptionString, @"description",
                    nil];
                
                [self.testSuiteArray addObject:exampleDictionary];
            }
        }
    }
    
    self.filteredSvgExamplesArray = [NSMutableArray arrayWithArray:self.testSuiteArray];
}



//==================================================================================
//	buildMacSVGExamplesArray
//==================================================================================

- (void)buildMacSVGExamplesArray
{
    if (self.macSVGExamplesArray == NULL)
    {
        self.macSVGExamplesArray = [NSMutableArray array];
        
        NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
        
        NSString * examplesPath = [resourcePath stringByAppendingPathComponent:@"macsvg_examples/svg"];
        
        NSArray * examplePathsArray = [NSBundle pathsForResourcesOfType:@"svg"
                inDirectory:examplesPath];

        NSFont * textFont = [NSFont systemFontOfSize:13];

        NSDictionary * textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                textFont, NSFontAttributeName,
                NULL];
        
        NSFont * boldFont = [NSFont boldSystemFontOfSize:13];
        
        NSDictionary * boldTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                boldFont, NSFontAttributeName,
                NULL];
        
        for (NSString * pathToExample in examplePathsArray)
        {
            NSError * fileError = NULL;
            NSString * svgString = [NSString stringWithContentsOfFile:pathToExample encoding:NSUTF8StringEncoding error:&fileError];
        
            NSError * xmlError = NULL;
            NSXMLDocument * xmlDocument = [[NSXMLDocument alloc] initWithXMLString:svgString options:0 error:&xmlError];

            NSXMLElement * rootElement = [xmlDocument rootElement];

            NSString * xpathQuery = @".//title";
            
            NSError * error = NULL;
            NSArray * resultArray = [rootElement nodesForXPath:xpathQuery error:&error];
            
            if ([resultArray count] > 0)
            {
                NSXMLElement * titleElement = [resultArray firstObject];
                
                NSString * titleString = [titleElement stringValue];
                
                NSMutableAttributedString * descriptionString = [[NSMutableAttributedString alloc] init];

                NSAttributedString * titleAttributedString = [[NSAttributedString alloc]
                        initWithString:titleString attributes:boldTextAttributes];
                [descriptionString appendAttributedString:titleAttributedString];
            
                NSAttributedString * descriptionTitleAttributedString = [[NSAttributedString alloc]
                        initWithString:@"\n\nDescription:\n" attributes:boldTextAttributes];
                [descriptionString appendAttributedString:descriptionTitleAttributedString];

                NSString * descriptionXpathQuery = @"//desc";
                NSArray * descriptionResultArray = [rootElement nodesForXPath:descriptionXpathQuery error:&error];
                if ([descriptionResultArray count] > 0)
                {
                    NSXMLElement * descriptionElement = [descriptionResultArray firstObject];
                    NSString * descriptionElementString = [descriptionElement stringValue];

                    descriptionElementString = [descriptionElementString stringByReplacingOccurrencesOfString:@"   " withString:@" "];
                    descriptionElementString = [descriptionElementString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                    descriptionElementString = [descriptionElementString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                    
                    NSAttributedString * descriptionAttributedString = [[NSAttributedString alloc]
                            initWithString:descriptionElementString attributes:textAttributes];
                    
                    [descriptionString appendAttributedString:descriptionAttributedString];
                }
                
                NSDictionary * exampleDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                    titleString, @"title",
                    pathToExample, @"path",
                    descriptionString, @"description",
                    nil];
                
                [self.macSVGExamplesArray addObject:exampleDictionary];
            }
        }
    }
    
    self.filteredSvgExamplesArray = [NSMutableArray arrayWithArray:self.macSVGExamplesArray];
}




- (IBAction)svgExampleSearchFieldAction:(id)sender
{
    NSString * popUpTitle = [self.svgExamplePopUpButton titleOfSelectedItem];
    if ([popUpTitle isEqualToString:@"SVG Test Suite"])
    {
        [self searchSVGExamplesInArray:self.testSuiteArray];
    }
    else
    {
        [self searchSVGExamplesInArray:self.macSVGExamplesArray];
    }
}


- (void)searchSVGExamplesInArray:(NSMutableArray *)masterArray
{
    NSString * filterString = self.svgExampleSearchField.stringValue;
    
    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString * trimmedString = [filterString stringByTrimmingCharactersInSet:whitespaceSet];
    
    if ([trimmedString length] > 0)
    {
        NSMutableArray * newFilteredSvgExamplesArray = [NSMutableArray array];
        
        for (NSDictionary * exampleDictionary in masterArray)
        {
            NSString * titleString = [exampleDictionary objectForKey:@"title"];
            NSAttributedString * descriptionString = [exampleDictionary objectForKey:@"description"];
            
            BOOL matchFound = NO;
            
            NSRange matchFoundRange = [titleString rangeOfString:filterString options:NSCaseInsensitiveSearch];
            if (matchFoundRange.location != NSNotFound)
            {
                matchFound = YES;
            }
            
            if (matchFound == NO)
            {
                NSString * nonattributedDescriptionString = [descriptionString string];
                matchFoundRange = [nonattributedDescriptionString rangeOfString:filterString options:NSCaseInsensitiveSearch];
                if (matchFoundRange.location != NSNotFound)
                {
                    matchFound = YES;
                }
            }
            
            if (matchFound == YES)
            {
                [newFilteredSvgExamplesArray addObject:exampleDictionary];
            }
        }
        
        self.filteredSvgExamplesArray = newFilteredSvgExamplesArray;
    }
    else
    {
        self.filteredSvgExamplesArray = [NSMutableArray arrayWithArray:masterArray];
    }
    
    [self.svgExampleTableView deselectAll:self];
    
    [self.svgExampleTableView reloadData];
    
    if ([self.filteredSvgExamplesArray count] > 0)
    {
        NSIndexSet * firstRowIndexSet = [NSIndexSet indexSetWithIndex:0];
        [self.svgExampleTableView selectRowIndexes:firstRowIndexSet byExtendingSelection:NO];
    }
    
    [self showSelectedSVGExample];
}



@end
