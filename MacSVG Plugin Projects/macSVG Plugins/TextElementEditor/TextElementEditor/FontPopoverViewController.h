//
//  FontPopoverViewController.h
//  TextElementEditor
//
//  Created by Douglas Ward on 8/8/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView;
@class TextElementEditor;

@interface FontPopoverViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSOpenSavePanelDelegate, NSTabViewDelegate>
{
    IBOutlet TextElementEditor * textElementEditor;

    IBOutlet NSPopover * fontPopover;
    IBOutlet WebView * fontPreviewWebView;
    IBOutlet NSTabView * tabView;
    
    IBOutlet NSPopUpButton * browserFontsFilterPopUpButton;
    IBOutlet NSTableView * browserFontsTableView;
    
    IBOutlet NSTableView * googleWebfontsTableView;
    IBOutlet NSMatrix * googleWebfontOptionsMatrix;
    
    IBOutlet NSTextField * webfontPathTextField;
    IBOutlet NSTextField * webfontStatusMessageTextField;
    IBOutlet NSMatrix * webfontImportOptionsMatrix;
    IBOutlet NSButton * previewFontButton;
    
    IBOutlet NSTableView * definedFontsTableView;
    IBOutlet NSButton * deleteUnusedWebfontCharactersButton;
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

@end
