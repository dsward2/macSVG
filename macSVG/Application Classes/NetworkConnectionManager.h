//
//  NetworkConnectionManager.h
//  macSVG
//
//  Created by Douglas Ward on 9/25/13.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class MacSVGDocument;

@interface NetworkConnectionManager : NSObject <NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet NSWindow * openNetworkConnectionWindow;
    IBOutlet NSWindow * networkFileBrowserWindow;
    IBOutlet NSWindow * saveAsNetworkConnectionWindow;
    IBOutlet NSWindow * saveAsNetworkDirectoryBrowserWindow;
    
    IBOutlet NSPanel * createNewFolderSheet;
    IBOutlet NSTextField * createNewFolderNameTextField;
    IBOutlet NSTextField * createNewFolderPathTextField;
    IBOutlet NSButton * createNewFolderButton;

    IBOutlet NSPopUpButton * openNetworkBookmarksPopUpButton;
    IBOutlet NSPopUpButton * openNetworkConnectionTypePopUpButton;
    IBOutlet NSTextField * openNetworkUrlFilePathTextField;
    IBOutlet NSTextField * openNetworkHostNameLabel;
    IBOutlet NSTextField * openNetworkHostNameTextField;
    IBOutlet NSTextField * openNetworkPortNumberLabel;
    IBOutlet NSTextField * openNetworkPortNumberTextField;
    IBOutlet NSTextField * openNetworkUserNameLabel;
    IBOutlet NSTextField * openNetworkUserNameTextField;
    IBOutlet NSTextField * openNetworkPasswordLabel;
    IBOutlet NSTextField * openNetworkPasswordTextField;
    IBOutlet NSButton * openNetworkBrowseFilesButton;
    IBOutlet NSButton * openNetworkOpenButton;

    IBOutlet NSTextField * networkFileBrowserLabelTextField;
    IBOutlet NSPopUpButton * networkFileBrowserDirectoryPopUpButton;
    IBOutlet NSTableView * networkFileBrowserTableView;

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"

    IBOutlet WebView * networkFileBrowserPreviewWebView;

    #pragma clang diagnostic pop


    IBOutlet NSButton * networkFileBrowserCancelButton;
    IBOutlet NSButton * networkFileBrowserOpenButton;
    IBOutlet NSButton * networkFileBrowserPreviewFileButton;

    IBOutlet NSPopUpButton * saveAsNetworkBookmarksPopUpButton;
    IBOutlet NSPopUpButton * saveAsNetworkConnectionTypePopUpButton;
    IBOutlet NSTextField * saveAsNetworkUrlFilePathTextField;
    IBOutlet NSTextField * saveAsNetworkHostNameTextField;
    IBOutlet NSTextField * saveAsNetworkPortNumberTextField;
    IBOutlet NSTextField * saveAsNetworkUserNameTextField;
    IBOutlet NSTextField * saveAsNetworkPasswordTextField;
    IBOutlet NSButton * saveAsNetworkBrowseDirectoriesButton;
    IBOutlet NSButton * saveAsNetworkSaveButton;
    IBOutlet NSButton * saveAsNetworkCompressedCheckboxButton;

    IBOutlet NSTextField * saveNetworkDirectoryBrowserLabelTextField;
    IBOutlet NSPopUpButton * saveNetworkDirectoryBrowserDirectoryPopUpButton;
    IBOutlet NSTableView * saveNetworkDirectoryBrowserTableView;
    IBOutlet NSTextField * saveNetworkDirectoryBrowserFileNameTextField;
    IBOutlet NSButton * saveNetworkDirectoryBrowserNewFolderButton;
    IBOutlet NSButton * saveNetworkDirectoryBrowserOpenFolderButton;
    IBOutlet NSButton * saveNetworkDirectoryBrowserCancelButton;
    IBOutlet NSButton * saveNetworkDirectoryBrowserSaveButton;
    IBOutlet NSButton * saveNetworkDirectoryBrowserCompressedCheckboxButton;
    
}

@property (strong) NSDictionary * workingConnectionDictionary;
@property (strong) NSArray * networkFileDirectoryArray;

- (IBAction)openNetworkConnectionTypePopupButtonAction:(id)sender;

- (IBAction)openNetworkConnectionCancelButtonAction:(id)sender;
- (IBAction)openNetworkConnectionOpenButtonAction:(id)sender;
- (IBAction)openNetworkConnectionBrowseFilesButtonAction:(id)sender;
- (IBAction)openNetworkConnectionTextFieldAction:(id)sender;

- (IBAction)networkFileBrowserDirectoryPopUpButtonAction:(id)sender;
- (IBAction)networkFileBrowserCancelButtonAction:(id)sender;
- (IBAction)networkFileBrowserOpenButtonAction:(id)sender;
- (IBAction)networkFileBrowserPreviewFileButtonAction:(id)sender;

- (IBAction)saveAsNetworkConnectionSaveButtonAction:(id)sender;
- (IBAction)saveAsNetworkConnectionCancelButtonAction:(id)sender;
- (IBAction)saveAsNetworkConnectionBrowseDirectoriesButtonAction:(id)sender;

- (IBAction)saveAsNetworkDirectoryBrowserDirectoryPopUpButtonAction:(id)sender;
- (IBAction)saveAsNetworkDirectoryBrowserNewFolderButtonAction:(id)sender;
- (IBAction)saveAsNetworkDirectoryBrowserOpenFolderButtonAction:(id)sender;
- (IBAction)saveAsNetworkDirectoryBrowserCancelButtonAction:(id)sender;
- (IBAction)saveAsNetworkDirectoryBrowserSaveButtonAction:(id)sender;

- (IBAction)openMacSVGDocumentWithNetworkConnection:(id)sender;

- (BOOL)saveDocument:(MacSVGDocument *)macSVGDocument
        networkConnectionDictionary:(NSDictionary *)networkConnectionDictionary;

- (BOOL)saveAsDocument:(MacSVGDocument *)macSVGDocument
        networkConnectionDictionary:(NSDictionary *)networkConnectionDictionary;

- (IBAction) showCreateNewFolderSheet:(id)sender;
- (IBAction) createNewFolder:(id)sender;
- (IBAction) cancelCreateNewFolder:(id)sender;

@end
