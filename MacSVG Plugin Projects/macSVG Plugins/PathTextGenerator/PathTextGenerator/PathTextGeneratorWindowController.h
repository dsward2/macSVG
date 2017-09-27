//
//  PathTextGeneratorWindowController.h
//  PathTextGenerator
//
//  Created by Douglas Ward on 9/25/17.
//  Copyright © 2017 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class PathTextGenerator;

@interface PathTextGeneratorWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSOpenSavePanelDelegate, NSTabViewDelegate>
{
    IBOutlet PathTextGenerator * pathTextGenerator;
    IBOutlet NSTextField * inputTextField;
    IBOutlet NSTextField * fontSizeTextField;
    IBOutlet NSButton * boldFontCheckboxButton;
    IBOutlet NSButton * italicFontCheckboxButton;
    IBOutlet NSTextField * originXTextField;
    IBOutlet NSTextField * originYTextField;
    IBOutlet WebView * fontPreviewWebView;

    IBOutlet NSTabView * tabView;
    
    IBOutlet NSPopUpButton * browserFontsFilterPopUpButton;
    IBOutlet NSTableView * browserFontsTableView;
    
    IBOutlet NSTableView * googleWebfontsTableView;
//    IBOutlet NSMatrix * googleWebfontOptionsMatrix;
    
    IBOutlet NSTextField * webfontPathTextField;
    IBOutlet NSTextField * webfontStatusMessageTextField;
//    IBOutlet NSMatrix * webfontImportOptionsMatrix;
    IBOutlet NSButton * previewFontButton;
    
    IBOutlet NSTableView * definedFontsTableView;

    IBOutlet NSPopUpButton * singleOrMultiplePathPopUpButton;
}

@property(strong) NSMutableData * googleWebFontsCatalogReceivedData;
@property(strong) NSMutableDictionary * googleWebFontsCatalogDictionary;

@property(strong) NSString * browserPreviewHTML;
@property(strong) NSString * googleWebfontsPreviewHTML;
@property(strong) NSString * importPreviewHTML;
@property(strong) NSString * definedPreviewHTML;

@property(strong) NSMutableDictionary * browserFontsDictionary;
@property(strong) NSMutableArray * definedFontsArray;

- (IBAction)browserFontsFilterPopUpButtonAction:(id)sender;

- (IBAction)chooseDisplayedFontButtonAction:(id)sender;

- (IBAction)chooseTruetypeFontFileButtonAction:(id)sender;

- (IBAction)previewImportedFontButtonAction:(id)sender;

- (IBAction)refreshGoogleFontsCatalogButtonAction:(id)sender;

- (IBAction)updateWebViewFontPreview:(id)sender;

- (void)setupFontsBrowser;

- (IBAction)generatePathButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;

@end
