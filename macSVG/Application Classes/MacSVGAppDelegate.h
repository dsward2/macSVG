//
//  MacSVGAppDelegate.h
//  macSVG
//
//  Created by Douglas Ward on 7/30/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SVGDTDData;
@class WebServerController;
@class WebKitInterface;
@class NetworkConnectionManager;
@class WebView;
@class MacSVGDocumentController;

@interface MacSVGAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource, NSWindowDelegate, NSMenuDelegate>
{
    WebKitInterface * webKitInterface;
    IBOutlet NetworkConnectionManager * networkConnectionManager;
}

@property (strong) IBOutlet WebServerController * webServerController;

@property (strong) SVGDTDData * svgDtdData;
@property (strong) NSDictionary * documentationDictionary;

@property (strong) NSString * svgDocumentPrototypeName;
@property (strong) NSString * svgDocumentPrototypeExtension;

@property (weak) IBOutlet NSMenuItem * showWebKitInspectorMenuItem;
@property (weak) IBOutlet NSMenuItem * detachWebKitInspectorMenuItem;
@property (weak) IBOutlet NSMenuItem * disableJavasScriptMenuItem;
@property (weak) IBOutlet NSMenuItem * enableJavaScriptProfilingMenuItem;
@property (weak) IBOutlet NSMenuItem * enableTimelineProfilingMenuItem;
@property (weak) IBOutlet NSMenuItem * startDebuggingJavaScriptMenuItem;
@property (weak) IBOutlet NSMenuItem * startProfilingJavaScriptMenuItem;

@property (weak) IBOutlet NSWindow * browseSVGExamplesWindow;
@property (weak) IBOutlet NSTableView * svgExampleTableView;
@property (weak) IBOutlet WebView * svgExampleWebView;
@property (strong) IBOutlet NSTextView * svgExampleTextView;
@property (strong) IBOutlet NSSearchField * svgExampleSearchField;
@property (strong) IBOutlet NSPopUpButton * svgExamplePopUpButton;
@property (strong) NSMutableArray * testSuiteArray;
@property (strong) NSMutableArray * macSVGExamplesArray;
@property (strong) NSMutableArray * filteredSvgExamplesArray;

@property (weak) IBOutlet NSWindow * createNewDocumentWindow;
@property (weak) IBOutlet NSPopUpButton * documentKindPopUpButton;
@property (weak) IBOutlet NSPopUpButton * presetSizesPopUpButton;
@property (weak) IBOutlet NSTextField * widthTextField;
@property (weak) IBOutlet NSTextField * heightTextField;
@property (weak) IBOutlet NSButton * includeBackgroundRectCheckBoxButton;
@property (weak) IBOutlet NSColorWell * backgroundRectColorWell;
@property (weak) IBOutlet NSButton * cancelCreateNewDocumentButton;
@property (weak) IBOutlet NSButton * createNewDocumentButton;

- (IBAction)openUntitledMacSVGDocument:(id)sender;
- (IBAction)openUntitledSVGBannerDocument:(id)sender;
- (IBAction)openUntitledMacSVGXHTMLDocument:(id)sender;
- (IBAction)openUntitledMacSVGXHTMLBanner:(id)sender;
- (IBAction)browseSVGExamples:(id)sender;

- (IBAction)openMacSVGDocumentWithNetworkConnection:(id)sender;
- (IBAction)saveMacSVGDocumentWithNetworkConnection:(id)sender;

@property (readonly, strong) WebKitInterface *webKitInterface;
@property (readonly, strong) NetworkConnectionManager *networkConnectionManager;

- (IBAction)launchWebBrowserDocument:(id)sender;

- (IBAction)selectAll:(id)sender;
- (IBAction)deselectAll:(id)sender;
- (IBAction)selectNone:(id)sender;

- (IBAction)exportImages:(id)sender;
- (IBAction)generateHTML5Video:(id)sender;
- (IBAction)generateCoreGraphicsCode:(id)sender;

- (IBAction)loadUntitledSVGExample:(id)sender;
- (IBAction)cancelUntitledSVGExample:(id)sender;
- (IBAction)svgExampleSearchFieldAction:(id)sender;
- (IBAction)svgExamplePopUpButtonAction:(id)sender;

- (IBAction)createNewMacSVGDocument:(id)sender;
- (IBAction)cancelCreateNewDocumentButtonAction:(id)sender;
- (IBAction)createNewDocumentButtonAction:(id)sender;
- (IBAction)presetSizesPopUpButtonAction:(id)sender;
- (void)applyNewSVGDocumentSettings:(NSXMLDocument *)svgXmlDocument;

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;

@end
