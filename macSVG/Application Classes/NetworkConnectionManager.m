//
//  NetworkConnectionManager.m
//  macSVG
//
//  Created by Douglas Ward on 9/25/13.
//
//

#import "NetworkConnectionManager.h"

#import "MacSVGDocument.h"

#import "DFSSHServer.h"
#import "DFSSHConnector.h"
#import "SSHCommand.h"
#import "SCPDownload.h"
#import "SCPUpload.h"
#import "SFTPReadDir.h"
#import "SFTPDownload.h"
#import "SFTPUpload.h"
//#import "SFTPUploadWithBlocking.h"
#import "SFTPMkdir.h"

#import <zlib.h>


@implementation NetworkConnectionManager

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    networkFileBrowserPreviewWebView.downloadDelegate = NULL;
    networkFileBrowserPreviewWebView.frameLoadDelegate = NULL;
    networkFileBrowserPreviewWebView.policyDelegate = NULL;
    networkFileBrowserPreviewWebView.UIDelegate = NULL;
    networkFileBrowserPreviewWebView.resourceLoadDelegate = NULL;
}

//==================================================================================
//	numberOfRowsInTableView
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSInteger rowsCount = 0;
    
    if (aTableView == networkFileBrowserTableView)
    {
        rowsCount = [self.networkFileDirectoryArray count];
    }
    else if (aTableView == saveNetworkDirectoryBrowserTableView)
    {
        rowsCount = [self.networkFileDirectoryArray count];
    }
    
    return rowsCount;
}

//==================================================================================
//	tableView:viewForTableColumn:row:
//==================================================================================

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSView * resultView = NULL;
    
    if (tableView == networkFileBrowserTableView)
    {
        resultView = [self viewForFileBrowserTableColumn:tableColumn rowIndex:row];
    }
    else if (tableView == saveNetworkDirectoryBrowserTableView)
    {
        resultView = [self viewForSaveNetworkDirectoryBrowserTableColumn:tableColumn rowIndex:row];
    }
    else
    {
        NSLog(@"NetworkConnectionManager viewForTableColumn view error");
    }
    
    return resultView;
}
//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = [aNotification object];
    if (aTableView == networkFileBrowserTableView)
    {
        //
    }
    else if (aTableView == saveNetworkDirectoryBrowserTableView)
    {
        [self saveNetworkDirectoryBrowserTableViewSelectionDidChange];
    }
}

//==================================================================================
//	viewForSaveNetworkDirectoryBrowserTableColumn:rowIndex
//==================================================================================

- (NSView *)viewForFileBrowserTableColumn:(NSTableColumn *)aTableColumn rowIndex:(NSInteger)rowIndex
{
    NSView * resultView = NULL;

    if ([self.networkFileDirectoryArray count] > 0)
    {
        NSDictionary * itemDictionary = [self.networkFileDirectoryArray objectAtIndex:rowIndex];
        NSString * fileName = [itemDictionary objectForKey:@"name"];
        NSString * fileNameExtension = [fileName pathExtension];
        NSString * flagsString = [itemDictionary objectForKey:@"flags"];
        unichar fileTypeChar = [flagsString characterAtIndex:0];

        NSString * tableColumnIdentifier= [aTableColumn identifier];
        
        if ([tableColumnIdentifier isEqualToString:@"fileName"] == YES)
        {
            NSTableCellView * cellView = [networkFileBrowserTableView makeViewWithIdentifier:tableColumnIdentifier owner:self];

            NSImage * iconImage = NULL;

            if (fileTypeChar == 'd')
            {
                iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
            }
            else
            {
                iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:fileNameExtension];
            }
            
            cellView.textField.stringValue = fileName;
            cellView.imageView.objectValue = iconImage;
            
            resultView = cellView;
        }
        else if ([tableColumnIdentifier isEqualToString:@"listingType"] == YES)
        {
            NSTableCellView * cellView = [networkFileBrowserTableView makeViewWithIdentifier:tableColumnIdentifier owner:self];

            
            NSString * listingType = @"Unknown";
            
            if ([fileNameExtension isEqualToString:@"svg"] == YES)
            {
                listingType = @"SVG";
            }
            else if ([fileNameExtension isEqualToString:@"svgz"] == YES)
            {
                listingType = @"SVGZ";
            }
            else if ([fileNameExtension isEqualToString:@"xhtml"] == YES)
            {
                listingType = @"XHTML";
            }
            else if ([fileNameExtension isEqualToString:@"html"] == YES)
            {
                listingType = @"HTML";
            }
            
            if (fileTypeChar == 'd')
            {
                listingType = @"Folder";
            }
            
            cellView.textField.stringValue = listingType;
            
            resultView = cellView;
        }
        else if ([tableColumnIdentifier isEqualToString:@"properties"] == YES)
        {
            NSTableCellView * cellView = [networkFileBrowserTableView makeViewWithIdentifier:tableColumnIdentifier owner:self];

            NSString * dateTimeString = [itemDictionary objectForKey:@"dateTime"];
            
            cellView.textField.stringValue = dateTimeString;
            
            resultView = cellView;
        }
        else
        {
            NSTableCellView * cellView = [networkFileBrowserTableView makeViewWithIdentifier:tableColumnIdentifier owner:self];
            resultView = cellView;
        }
    }
    
    return resultView;
}



//==================================================================================
//	textDidChange:
//==================================================================================

- (void)textDidChange:(NSNotification *)aNotification
{
    //NSString * name = [aNotification name];
    id object = [aNotification object];
    //NSDictionary * userInfo = [aNotification userInfo];
    NSWindow * aWindow = NULL;
    
    if ([object isKindOfClass:[NSTextField class]] == YES)
    {
        NSTextField * aTextField = object;
        aWindow = [aTextField window];
    }

    if (aWindow == openNetworkConnectionWindow)
    {
        [self openNetworkConnectionTextFieldAction:self];
    }
    else if (aWindow == networkFileBrowserWindow)
    {
    }
    else if (aWindow == saveAsNetworkConnectionWindow)
    {
        [self saveAsNetworkConnectionTextFieldAction:self];
    }
    else if (aWindow == saveAsNetworkDirectoryBrowserWindow)
    {
        [self saveAsBrowserNetworkConnectionTextFieldAction:self];
    }
}

//==================================================================================
//  controlTextDidChange:
//==================================================================================

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    //NSString * name = [aNotification name];
    id object = [aNotification object];
    //NSDictionary * userInfo = [aNotification userInfo];
    NSWindow * aWindow = NULL;
    
    if ([object isKindOfClass:[NSTextField class]] == YES)
    {
        NSTextField * aTextField = object;
        aWindow = [aTextField window];
    }

    if (aWindow == openNetworkConnectionWindow)
    {
        [self openNetworkConnectionTextFieldAction:self];
    }
    else if (aWindow == networkFileBrowserWindow)
    {
    }
    else if (aWindow == saveAsNetworkConnectionWindow)
    {
        [self saveAsNetworkConnectionTextFieldAction:self];
    }
    else if (aWindow == saveAsNetworkDirectoryBrowserWindow)
    {
        [self saveAsBrowserNetworkConnectionTextFieldAction:self];
    }
}

//==================================================================================
//	openMacSVGDocumentWithNetworkConnection:
//==================================================================================

- (IBAction)openMacSVGDocumentWithNetworkConnection:(id)sender
{
    [self openNetworkConnectionTextFieldAction:self];

    [openNetworkConnectionWindow makeKeyAndOrderFront:self];
}

//==================================================================================
//	openNetworkConnectionTextFieldAction:
//==================================================================================

- (IBAction)openNetworkConnectionTextFieldAction:(id)sender
{
    NSString * connectionTypeString = [openNetworkConnectionTypePopUpButton titleOfSelectedItem];
    NSString * urlFilePathString = [openNetworkUrlFilePathTextField stringValue];
    //NSString * hostNameString = [openNetworkHostNameTextField stringValue];
    //NSString * portNumberString = [openNetworkPortNumberTextField stringValue];
    NSString * userNameString = [openNetworkUserNameTextField stringValue];
    NSString * passwordString = [openNetworkPasswordTextField stringValue];
    
    NSString * pathExtension = [urlFilePathString pathExtension];
    
    BOOL validPathExtension = NO;
    if ([pathExtension isEqualToString:@"svg"] == YES)
    {
        validPathExtension = YES;
    }
    else if ([pathExtension isEqualToString:@"svgz"] == YES)
    {
        validPathExtension = YES;
    }
    else if ([pathExtension isEqualToString:@"xhtml"] == YES)
    {
        validPathExtension = YES;
    }
    else if ([pathExtension isEqualToString:@"html"] == YES)
    {
        validPathExtension = YES;
    }
    
    BOOL validLoginCredentials = NO;
    if ([userNameString length] > 0)
    {
        if ([passwordString length] > 0)
        {
            validLoginCredentials = YES;
        }
    }

    if ([connectionTypeString isEqualToString:@"HTTP Web Server"] == YES)
    {
        [openNetworkBrowseFilesButton setEnabled:NO];
        if ([urlFilePathString length] > 0)
        {
            if (validPathExtension == YES)
            {
                [openNetworkOpenButton setEnabled:YES];
            }
            else
            {
                [openNetworkOpenButton setEnabled:NO];
            }
        }
        else
        {
            [openNetworkOpenButton setEnabled:NO];
        }
    }
    else if ([connectionTypeString isEqualToString:@"SFTP Server"] == YES)
    {
        if ([urlFilePathString length] > 0)
        {
            [openNetworkBrowseFilesButton setEnabled:YES];
            if (validPathExtension == YES)
            {
                [openNetworkOpenButton setEnabled:YES];
            }
            else
            {
                [openNetworkOpenButton setEnabled:NO];
            }
        }
        else
        {
            [openNetworkBrowseFilesButton setEnabled:NO];
            [openNetworkOpenButton setEnabled:NO];
        }
    }
    else if ([connectionTypeString isEqualToString:@"SSH Connection"] == YES)
    {
        if (validLoginCredentials == YES)
        {
            if ([urlFilePathString length] > 0)
            {
                [openNetworkBrowseFilesButton setEnabled:YES];
                if (validPathExtension == YES)
                {
                    [openNetworkOpenButton setEnabled:YES];
                }
                else
                {
                    [openNetworkOpenButton setEnabled:NO];
                }
            }
            else
            {
                [openNetworkBrowseFilesButton setEnabled:YES];
                [openNetworkOpenButton setEnabled:NO];
            }
        }
        else
        {
            [openNetworkBrowseFilesButton setEnabled:NO];
            [openNetworkOpenButton setEnabled:NO];
        }
    }
}

//==================================================================================
//	networkFileBrowserDirectoryPopUpButtonAction:
//==================================================================================

- (IBAction)networkFileBrowserDirectoryPopUpButtonAction:(id)sender
{
    NSString * networkAccessMethod = [self.workingConnectionDictionary objectForKey:@"connectionType"];
    //NSString * oldNetworkDirectoryPath = [self.workingConnectionDictionary objectForKey:@"urlFilePath"];
    NSString * hostNameString = [self.workingConnectionDictionary objectForKey:@"hostName"];
    NSString * portNumberString = [self.workingConnectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [self.workingConnectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [self.workingConnectionDictionary objectForKey:@"password"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];

    NSInteger selectedIndex = [networkFileBrowserDirectoryPopUpButton indexOfSelectedItem];
    
    NSMutableString * networkDirectoryPath = [NSMutableString string];
    
    for (NSInteger i = 0; i <= selectedIndex; i++)
    {
        NSMenuItem * componentItem = [networkFileBrowserDirectoryPopUpButton itemAtIndex:i];
        NSString * componentString = [componentItem title];
        [networkDirectoryPath appendString:componentString];
        
        if (i > 0)
        {
            [networkDirectoryPath appendString:@"/"];
        }
    }

    NSDictionary * connectionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
            networkAccessMethod, @"connectionType",
            networkDirectoryPath, @"urlFilePath",
            hostAddrString, @"hostName",
            portNumberString, @"portNumber",
            userNameString, @"userName",
            passwordString, @"password",
            nil];
    
    self.workingConnectionDictionary = connectionDictionary;

    [self loadNetworkFileBrowserForSSHConnection:connectionDictionary];
}

//==================================================================================
//	openNetworkConnectionCancelButtonAction:
//==================================================================================

- (IBAction)openNetworkConnectionCancelButtonAction:(id)sender
{
    [openNetworkConnectionWindow orderOut:self];
}

//==================================================================================
//	openNetworkConnectionOpenButtonAction:
//==================================================================================

- (IBAction)openNetworkConnectionOpenButtonAction:(id)sender
{
    [openNetworkConnectionWindow orderOut:self];
    
    [self openFileListingItem:self];
}

//==================================================================================
//	openNetworkConnectionBrowseFilesButtonAction:
//==================================================================================

- (IBAction)openNetworkConnectionBrowseFilesButtonAction:(id)sender
{
    NSString * connectionTypeString = [openNetworkConnectionTypePopUpButton titleOfSelectedItem];
    NSString * urlFilePathString = [openNetworkUrlFilePathTextField stringValue];
    NSString * hostNameString = [openNetworkHostNameTextField stringValue];
    NSString * portNumberString = [openNetworkPortNumberTextField stringValue];
    NSString * userNameString = [openNetworkUserNameTextField stringValue];
    NSString * passwordString = [openNetworkPasswordTextField stringValue];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];

    NSDictionary * connectionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
            connectionTypeString, @"connectionType",
            urlFilePathString, @"urlFilePath",
            hostAddrString, @"hostName",
            portNumberString, @"portNumber",
            userNameString, @"userName",
            passwordString, @"password",
            nil];

    [openNetworkConnectionWindow orderOut:self];
    
    [networkFileBrowserWindow makeKeyAndOrderFront:self];
    
    [self loadNetworkFileBrowserForConnection:connectionDictionary];
}

//==================================================================================
//	networkFileBrowserCancelButtonAction:
//==================================================================================

- (IBAction)networkFileBrowserCancelButtonAction:(id)sender
{
    self.networkFileDirectoryArray = [NSArray array];
    [networkFileBrowserTableView reloadData];
    [networkFileBrowserWindow orderOut:self];
}

//==================================================================================
//	networkFileBrowserOpenButtonAction:
//==================================================================================

- (IBAction)networkFileBrowserOpenButtonAction:(id)sender
{
    [self openFileListingItem:self];
}

//==================================================================================
//	networkFileBrowserPreviewFileButtonAction:
//==================================================================================

- (IBAction)networkFileBrowserPreviewFileButtonAction:(id)sender
{
}

//==================================================================================
//	loadNetworkFileBrowserForConnection:
//==================================================================================

- (void)loadNetworkFileBrowserForConnection:(NSDictionary *)connectionDictionary
{
    self.workingConnectionDictionary = connectionDictionary;

    NSString * connectionTypeString = [connectionDictionary objectForKey:@"connectionType"];
    
    if ([connectionTypeString isEqualToString:@"HTTP Web Server"] == YES)
    {
        // not a valid function for HTTP
    }
    else if ([connectionTypeString isEqualToString:@"SFTP Server"] == YES)
    {
        [self loadNetworkFileBrowserForSFTPConnection:connectionDictionary];
    }
    else if ([connectionTypeString isEqualToString:@"SSH Connection"] == YES)
    {
        [self loadNetworkFileBrowserForSSHConnection:connectionDictionary];
    }
}

//==================================================================================
//	loadNetworkFileBrowserForSSHConnection:
//==================================================================================

- (void)loadNetworkFileBrowserForSSHConnection:(NSDictionary *)connectionDictionary
{
    //NSString * connectionTypeString = [connectionDictionary objectForKey:@"connectionType"];
    NSString * urlFilePathString = [connectionDictionary objectForKey:@"urlFilePath"];
    NSString * hostNameString = [connectionDictionary objectForKey:@"hostName"];
    NSString * portNumberString = [connectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [connectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [connectionDictionary objectForKey:@"password"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];

    NSImage * iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
    [iconImage setSize:NSMakeSize(16,16)];
    
    [networkFileBrowserDirectoryPopUpButton removeAllItems];
    
    [networkFileBrowserDirectoryPopUpButton addItemWithTitle:@"/"];
    NSMenuItem * menuItem = [networkFileBrowserDirectoryPopUpButton itemAtIndex:0];
    [menuItem setImage:iconImage];

    NSArray * pathArray = [urlFilePathString componentsSeparatedByString:@"/"];
    NSInteger pathArrayCount = [pathArray count];
    for (NSInteger i = 0; i < pathArrayCount; i++)
    {
        NSString * directoryString = [pathArray objectAtIndex:i];
        if ([directoryString length] > 0)
        {
            NSString * fileNameExtension = [directoryString pathExtension];
            BOOL displayListing = YES;
            if ([fileNameExtension isEqualToString:@"svg"] == YES)
            {
                displayListing = NO;
            }
            else if ([fileNameExtension isEqualToString:@"svgz"] == YES)
            {
                displayListing = NO;
            }
            else if ([fileNameExtension isEqualToString:@"xhtml"] == YES)
            {
                displayListing = NO;
            }
            else if ([fileNameExtension isEqualToString:@"html"] == YES)
            {
                displayListing = NO;
            }

            if (displayListing == YES)
            {
                [networkFileBrowserDirectoryPopUpButton addItemWithTitle:directoryString];
                
                NSInteger lastItemIndex = [networkFileBrowserDirectoryPopUpButton numberOfItems] - 1;
                NSMenuItem * menuItem = [networkFileBrowserDirectoryPopUpButton itemAtIndex:lastItemIndex];
                [menuItem setImage:iconImage];
            }
        }
    }
    NSInteger lastItemIndex = [networkFileBrowserDirectoryPopUpButton numberOfItems] - 1;
    [networkFileBrowserDirectoryPopUpButton selectItemAtIndex:lastItemIndex];
    
    int portNumber = [portNumberString intValue];

    DFSSHServer *server = [[DFSSHServer alloc] init];   

    [server setSSHHost:hostAddrString port:portNumber user:userNameString key:@"" keypub:@"" password:passwordString];

    DFSSHConnector *connection = [[DFSSHConnector alloc] init];

    [connection connect:server connectionType:[DFSSHConnectionType auto]];

    if ([server connectionStatus] == YES)
    {
        NSString * lsCommandString = [NSString stringWithFormat:@"ls -l -w 160 %@", urlFilePathString];
        
        NSNumber * timeoutNumber = [NSNumber numberWithDouble:60];
        NSError * sshError = NULL;
        NSString * lsDirectoryResult = [SSHCommand execCommand:lsCommandString server:server timeout:timeoutNumber sshError:&sshError];

        [connection closeSSH:server];
        
        NSArray * directoryListingArray = [lsDirectoryResult componentsSeparatedByString:@"\n"];
        //NSInteger directoryListingArrayCount = [directoryListingArray count];

        //NSLog(@"lsCommandString = %@", lsCommandString);
        //NSLog(@"directoryListingArrayCount = %ld", (long)directoryListingArrayCount);
        
        // -rw-r--r--.  1 dsward   apache     74241 Nov 28  2011 firstsvg.svg
        // -rw-r--r--. 1 dsward dsward   19327 Feb 11  2012 Accelerate_Graphic_for_Animation2.svg
        // -rw-r--r--. 1 dsward dsward   19327 Feb 11  2012 Accelerate_Graphic_for_Animation2.svg
        // 0....5...10...15...20...25...30...35...40...45...50...55...60...65...70...75
        
        NSMutableArray * formattedDirectoryArray = [NSMutableArray array];
        
        for (NSString * listingString in directoryListingArray)
        {
            NSArray * listingArray = [listingString componentsSeparatedByString:@" "];
            
            //NSLog(@"listingArray = %@", listingArray);
            
            NSInteger listingArrayCount = [listingArray count];
            
            if (listingArrayCount > 6)
            {
                NSString * flagsString = @"";
                NSString * ownerString = @"";
                NSString * groupString = @"";
                NSString * sizeString = @"";
                NSString * dateTimeString = @"";
                NSString * nameString = @"";

                NSInteger fieldIndex = 0;
                for (NSInteger i = 0; i < listingArrayCount; i++)
                {
                    NSString * listingComponent = [listingArray objectAtIndex:i];
                    
                    if ([listingComponent length] > 0)
                    {
                        switch (fieldIndex)
                        {
                            case 0:
                                flagsString = listingComponent;
                                fieldIndex++;
                                break;

                            case 1:
                                fieldIndex++;
                                break;

                            case 2:
                                ownerString = listingComponent;
                                fieldIndex++;
                                break;

                            case 3:
                                groupString = listingComponent;
                                fieldIndex++;
                                break;

                            case 4:
                                sizeString = listingComponent;
                                fieldIndex++;
                                break;

                            case 5:
                                if ([dateTimeString length] > 0)
                                {
                                    dateTimeString = [dateTimeString stringByAppendingString:@" "];
                                }
                                dateTimeString = [dateTimeString stringByAppendingString:listingComponent];
                                if ([dateTimeString length] > 9)
                                {
                                    fieldIndex++;
                                }
                                break;

                            case 6:
                                if ([nameString length] > 0)
                                {
                                    nameString = [nameString stringByAppendingString:@" "];
                                }
                                nameString = [nameString stringByAppendingString:listingComponent];
                                break;
                            default:
                                break;
                        }
                        
                    }
                }
                
                NSString * fileNameExtension = [nameString pathExtension];
                
                BOOL displayListing = NO;
                
                if ([fileNameExtension isEqualToString:@"svg"] == YES)
                {
                    displayListing = YES;
                }
                else if ([fileNameExtension isEqualToString:@"svgz"] == YES)
                {
                    displayListing = YES;
                }
                else if ([fileNameExtension isEqualToString:@"xhtml"] == YES)
                {
                    displayListing = YES;
                }
                else if ([fileNameExtension isEqualToString:@"html"] == YES)
                {
                    displayListing = YES;
                }
                
                unichar fileTypeChar = [flagsString characterAtIndex:0];
                if (fileTypeChar == 'd')
                {
                    displayListing = YES;
                }

                if (displayListing == YES)
                {
                    NSDictionary * formattedListingDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                            flagsString, @"flags",
                            ownerString, @"owner",
                            groupString, @"group",
                            sizeString, @"size",
                            dateTimeString, @"dateTime",
                            nameString, @"name",
                            nil];

                    [formattedDirectoryArray addObject:formattedListingDictionary];
                }
            }
        }

        self.networkFileDirectoryArray = formattedDirectoryArray;
    }
    else
    {
        [connection closeSSH:server];
    }

    [networkFileBrowserTableView setTarget:self];
    [networkFileBrowserTableView setDoubleAction:@selector(openFileListingItem:)];
    [networkFileBrowserTableView reloadData];
}

//==================================================================================
//	loadNetworkFileBrowserForSFTPConnection:
//==================================================================================

- (void)loadNetworkFileBrowserForSFTPConnection:(NSDictionary *)connectionDictionary
{
    //NSString * connectionTypeString = [connectionDictionary objectForKey:@"connectionType"];
    NSString * urlFilePathString = [connectionDictionary objectForKey:@"urlFilePath"];
    NSString * hostNameString = [connectionDictionary objectForKey:@"hostName"];
    //NSString * portNumberString = [connectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [connectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [connectionDictionary objectForKey:@"password"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];

    NSImage * iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
    [iconImage setSize:NSMakeSize(16,16)];
    
    [networkFileBrowserDirectoryPopUpButton removeAllItems];

    [networkFileBrowserDirectoryPopUpButton addItemWithTitle:@"/"];
    NSMenuItem * menuItem = [networkFileBrowserDirectoryPopUpButton itemAtIndex:0];
    [menuItem setImage:iconImage];

    NSArray * pathArray = [urlFilePathString componentsSeparatedByString:@"/"];
    NSInteger pathArrayCount = [pathArray count];
    for (NSInteger i = 0; i < pathArrayCount; i++)
    {
        NSString * directoryString = [pathArray objectAtIndex:i];
        if ([directoryString length] > 0)
        {
            NSString * fileNameExtension = [directoryString pathExtension];
            BOOL displayListing = YES;
            if ([fileNameExtension isEqualToString:@"svg"] == YES)
            {
                displayListing = NO;
            }
            else if ([fileNameExtension isEqualToString:@"svgz"] == YES)
            {
                displayListing = NO;
            }
            else if ([fileNameExtension isEqualToString:@"xhtml"] == YES)
            {
                displayListing = NO;
            }
            else if ([fileNameExtension isEqualToString:@"html"] == YES)
            {
                displayListing = NO;
            }

            if (displayListing == YES)
            {
                [networkFileBrowserDirectoryPopUpButton addItemWithTitle:directoryString];
                
                NSInteger lastItemIndex = [networkFileBrowserDirectoryPopUpButton numberOfItems] - 1;
                NSMenuItem * menuItem = [networkFileBrowserDirectoryPopUpButton itemAtIndex:lastItemIndex];
                [menuItem setImage:iconImage];
            }
        }
    }
    NSInteger lastItemIndex = [networkFileBrowserDirectoryPopUpButton numberOfItems] - 1;
    [networkFileBrowserDirectoryPopUpButton selectItemAtIndex:lastItemIndex];
 
/*
    int portNumber = [portNumberString intValue];

    DFSSHServer *server = [[DFSSHServer alloc] init];   

    [server setSSHHost:hostNameString port:portNumber user:userNameString key:@"" keypub:@"" password:passwordString];

    DFSSHConnector *connection = [[DFSSHConnector alloc] init];

    [connection connect:server connectionType:[DFSSHConnectionType auto]];

    if ([server connectionStatus] == YES)
    {
    }
    else
    {
        [connection closeSSH:server];
    }
*/

    SFTPReadDir * sftpReadDir = [[SFTPReadDir alloc] init];
    
    NSError * sftpError = NULL;
    
    NSString * lsDirectoryResult = [sftpReadDir execSFTPReadDir:hostAddrString user:userNameString
            password:passwordString sftppath:urlFilePathString sftpError:&sftpError];
    
    NSArray * directoryListingArray = [lsDirectoryResult componentsSeparatedByString:@"\n"];
    //NSInteger directoryListingArrayCount = [directoryListingArray count];

    //NSLog(@"lsCommandString = %@", lsCommandString);
    //NSLog(@"directoryListingArrayCount = %ld", (long)directoryListingArrayCount);
    
    // -rw-r--r--.  1 dsward   apache     74241 Nov 28  2011 firstsvg.svg
    // -rw-r--r--. 1 dsward dsward   19327 Feb 11  2012 Accelerate_Graphic_for_Animation2.svg
    // -rw-r--r--. 1 dsward dsward   19327 Feb 11  2012 Accelerate_Graphic_for_Animation2.svg
    // 0....5...10...15...20...25...30...35...40...45...50...55...60...65...70...75
    
    NSMutableArray * formattedDirectoryArray = [NSMutableArray array];
    
    for (NSString * listingString in directoryListingArray)
    {
        NSArray * listingArray = [listingString componentsSeparatedByString:@" "];
        
        //NSLog(@"listingArray = %@", listingArray);
        
        NSInteger listingArrayCount = [listingArray count];
        
        if (listingArrayCount > 6)
        {
            NSString * flagsString = @"";
            NSString * ownerString = @"";
            NSString * groupString = @"";
            NSString * sizeString = @"";
            NSString * dateTimeString = @"";
            NSString * nameString = @"";

            NSInteger fieldIndex = 0;
            for (NSInteger i = 0; i < listingArrayCount; i++)
            {
                NSString * listingComponent = [listingArray objectAtIndex:i];
                
                if ([listingComponent length] > 0)
                {
                    switch (fieldIndex)
                    {
                        case 0:
                            flagsString = listingComponent;
                            fieldIndex++;
                            break;

                        case 1:
                            fieldIndex++;
                            break;

                        case 2:
                            ownerString = listingComponent;
                            fieldIndex++;
                            break;

                        case 3:
                            groupString = listingComponent;
                            fieldIndex++;
                            break;

                        case 4:
                            sizeString = listingComponent;
                            fieldIndex++;
                            break;

                        case 5:
                            if ([dateTimeString length] > 0)
                            {
                                dateTimeString = [dateTimeString stringByAppendingString:@" "];
                            }
                            dateTimeString = [dateTimeString stringByAppendingString:listingComponent];
                            if ([dateTimeString length] > 9)
                            {
                                fieldIndex++;
                            }
                            break;

                        case 6:
                            if ([nameString length] > 0)
                            {
                                nameString = [nameString stringByAppendingString:@" "];
                            }
                            nameString = [nameString stringByAppendingString:listingComponent];
                            break;
                        default:
                            break;
                    }
                    
                }
            }
            
            NSString * fileNameExtension = [nameString pathExtension];
            
            BOOL displayListing = NO;
            
            if ([fileNameExtension isEqualToString:@"svg"] == YES)
            {
                displayListing = YES;
            }
            else if ([fileNameExtension isEqualToString:@"svgz"] == YES)
            {
                displayListing = YES;
            }
            else if ([fileNameExtension isEqualToString:@"xhtml"] == YES)
            {
                displayListing = YES;
            }
            else if ([fileNameExtension isEqualToString:@"html"] == YES)
            {
                displayListing = YES;
            }
            
            unichar fileTypeChar = [flagsString characterAtIndex:0];
            if (fileTypeChar == 'd')
            {
                displayListing = YES;
            }

            unichar fileNameChar = [nameString characterAtIndex:0];
            if (fileNameChar == '.')
            {
                displayListing = NO;
            }

            if (displayListing == YES)
            {
                NSDictionary * formattedListingDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                        flagsString, @"flags",
                        ownerString, @"owner",
                        groupString, @"group",
                        sizeString, @"size",
                        dateTimeString, @"dateTime",
                        nameString, @"name",
                        nil];

                [formattedDirectoryArray addObject:formattedListingDictionary];
            }
        }
    }
    
    NSArray * sortedDirectoryArray = [formattedDirectoryArray
            sortedArrayUsingFunction:directoryListingSort context:NULL];

    self.networkFileDirectoryArray = sortedDirectoryArray;

    [networkFileBrowserTableView setTarget:self];
    [networkFileBrowserTableView setDoubleAction:@selector(openFileListingItem:)];
    [networkFileBrowserTableView reloadData];
}

//==================================================================================
//	directoryListingSort()
//==================================================================================

NSComparisonResult directoryListingSort(id listing1, id listing2, void *context)
{
    NSComparisonResult sortResult = NSOrderedSame;

    NSDictionary * listingDictionary1 = listing1;
    NSDictionary * listingDictionary2 = listing2;

    NSString * name1 = [listingDictionary1 objectForKey:@"name"];
    NSString * name2 = [listingDictionary2 objectForKey:@"name"];

    sortResult = [name1 compare:name2];

    return sortResult;
}

//==================================================================================
//	openFileListingItem:
//==================================================================================

- (IBAction)openFileListingItem:(id)sender
{
    NSInteger rowIndex = [networkFileBrowserTableView selectedRow];
    
    if (rowIndex != -1)
    {
        NSDictionary * listingDictionary = [self.networkFileDirectoryArray objectAtIndex:rowIndex];
        
        NSString * flagsString = [listingDictionary objectForKey:@"flags"];
        //NSString * ownerString = [listingDictionary objectForKey:@"owner"];
        //NSString * groupString = [listingDictionary objectForKey:@"group"];
        //NSString * sizeString = [listingDictionary objectForKey:@"size"];
        //NSString * dateTimeString = [listingDictionary objectForKey:@"dateTime"];
        NSString * nameString = [listingDictionary objectForKey:@"name"];

        NSString * networkAccessMethod = [self.workingConnectionDictionary objectForKey:@"connectionType"];
        NSString * networkDirectoryPath = [self.workingConnectionDictionary objectForKey:@"urlFilePath"];
        NSString * hostNameString = [self.workingConnectionDictionary objectForKey:@"hostName"];
        NSString * portNumberString = [self.workingConnectionDictionary objectForKey:@"portNumber"];
        NSString * userNameString = [self.workingConnectionDictionary objectForKey:@"userName"];
        NSString * passwordString = [self.workingConnectionDictionary objectForKey:@"password"];

        NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];

        networkDirectoryPath = [networkDirectoryPath stringByAppendingPathComponent:nameString];
        
        NSDictionary * connectionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                networkAccessMethod, @"connectionType",
                networkDirectoryPath, @"urlFilePath",
                hostAddrString, @"hostName",
                portNumberString, @"portNumber",
                userNameString, @"userName",
                passwordString, @"password",
                nil];
        
        self.workingConnectionDictionary = connectionDictionary;

        BOOL isDirectory = NO;
        unichar fileTypeChar = [flagsString characterAtIndex:0];
        if (fileTypeChar == 'd')
        {
            isDirectory = YES;
        }
        
        if (isDirectory == YES)
        {
            if ([networkAccessMethod isEqualToString:@"SFTP Server"] == YES)
            {
                [self loadNetworkFileBrowserForSFTPConnection:connectionDictionary];
            }
            else if ([networkAccessMethod isEqualToString:@"SSH Connection"] == YES)
            {
                [self loadNetworkFileBrowserForSSHConnection:connectionDictionary];
            }
        }
        else
        {
            self.networkFileDirectoryArray = [NSArray array];
            [networkFileBrowserTableView reloadData];
            [networkFileBrowserWindow orderOut:self];
            
            if ([networkAccessMethod isEqualToString:@"SFTP Server"] == YES)
            {
                [self openMacSVGDocumentWithSftpConnection];
            }
            else if ([networkAccessMethod isEqualToString:@"SSH Connection"] == YES)
            {
                [self openMacSVGDocumentWithScpConnection];
            }
        }
    }
}

//==================================================================================
//	openMacSVGDocumentWithScpConnection:
//==================================================================================

- (void)openMacSVGDocumentWithScpConnection
{
    //NSString * networkAccessMethod = [self.workingConnectionDictionary objectForKey:@"connectionType"];
    NSString * urlFilePath = [self.workingConnectionDictionary objectForKey:@"urlFilePath"];
    NSString * hostNameString = [self.workingConnectionDictionary objectForKey:@"hostName"];
    //NSString * portNumberString = [self.workingConnectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [self.workingConnectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [self.workingConnectionDictionary objectForKey:@"password"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];

    SCPDownload * scpDownload = [[SCPDownload alloc] init];
    NSError * sshError = NULL;
    NSData * fileData = [scpDownload execSCPDownloadHostaddr:hostAddrString user:userNameString
            password:passwordString scppath:urlFilePath sshError:&sshError];
    
    if (fileData != NULL)
    {
        NSString * pathExtension = [urlFilePath pathExtension];
        
        if ([pathExtension isEqualToString:@"svgz"] == YES)
        {
            fileData = [self gzipInflate:fileData];
        }
    
        //NSString * fileString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        //NSLog(@"fileData = %@", fileString);

        NSError * docError = NULL;

        MacSVGDocument * macSVGDocument = [[NSDocumentController sharedDocumentController]
                openUntitledDocumentAndDisplay:NO error:&docError];
        
        //BOOL result = [macSVGDocument readFromData:fileData
        //        ofType:typeName error:&docError];
        BOOL result = [macSVGDocument readFromData:fileData
                ofType:@"MacSVGDocument" error:&docError];
        
        if (result == YES)
        {
            macSVGDocument.fileNameExtension = pathExtension;
            macSVGDocument.networkConnectionDictionary = self.workingConnectionDictionary;
            
            NSString * documentTitle = [urlFilePath lastPathComponent];
            [macSVGDocument setDisplayName:documentTitle];
        
            [macSVGDocument makeWindowControllers];
            [macSVGDocument showWindows];
        }
        else
        {
            [macSVGDocument close];
        }
    }
}

//==================================================================================
//	openMacSVGDocumentWithSftpConnection
//==================================================================================

- (void)openMacSVGDocumentWithSftpConnection
{
    //NSString * networkAccessMethod = [self.workingConnectionDictionary objectForKey:@"connectionType"];
    NSString * urlFilePath = [self.workingConnectionDictionary objectForKey:@"urlFilePath"];
    NSString * hostNameString = [self.workingConnectionDictionary objectForKey:@"hostName"];
    //NSString * portNumberString = [self.workingConnectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [self.workingConnectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [self.workingConnectionDictionary objectForKey:@"password"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];

    SFTPDownload * sftpDownload = [[SFTPDownload alloc] init];
    
    NSError * sftpError = NULL;
    
    NSData * fileData = [sftpDownload execSFTPDownloadHostaddr:hostAddrString user:userNameString
            password:passwordString sftppath:urlFilePath sftpError:&sftpError];

    if (fileData != NULL)
    {
        //NSString * fileString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        //NSLog(@"fileData = %@", fileString);

        NSError * docError = NULL;

        MacSVGDocument * macSVGDocument = [[NSDocumentController sharedDocumentController]
                openUntitledDocumentAndDisplay:NO error:&docError];
        
        NSString * typeName = [urlFilePath pathExtension];
        
        BOOL result = [macSVGDocument readFromData:fileData
                ofType:typeName error:&docError];
        
        if (result == YES)
        {
            macSVGDocument.fileNameExtension = typeName;
            macSVGDocument.networkConnectionDictionary = self.workingConnectionDictionary;
        
            [macSVGDocument makeWindowControllers];
            [macSVGDocument showWindows];
        }
        else
        {
            [macSVGDocument close];
        }
    }
}

//==================================================================================
//	makeTemporaryFileWithSSHConnection:
//==================================================================================

- (NSString *)makeTemporaryFileWithSSHConnection:(NSDictionary *)networkConnectionDictionary
{
    NSString * result = NULL;
    NSString * hostNameString = [networkConnectionDictionary objectForKey:@"hostName"];
    NSString * portNumberString = [networkConnectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [networkConnectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [networkConnectionDictionary objectForKey:@"password"];
    NSString * urlFilePath = [networkConnectionDictionary objectForKey:@"urlFilePath"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];
    
    NSString * fileName = [urlFilePath lastPathComponent];

    int portNumber = [portNumberString intValue];

    DFSSHServer *server = [[DFSSHServer alloc] init];

    [server setSSHHost:hostAddrString port:portNumber
            user:userNameString key:@"" keypub:@"" password:passwordString];

    DFSSHConnector *connection = [[DFSSHConnector alloc] init];

    [connection connect:server connectionType:[DFSSHConnectionType auto]];

    if ([server connectionStatus] == YES)
    {
        NSString * directoryPath = [urlFilePath stringByDeletingLastPathComponent];
        NSString * nameTemplate = [fileName stringByAppendingString:@".XXXXXXXX"];
    
        // dry-run temporary name generation
        NSNumber * timeoutNumber = [NSNumber numberWithDouble:60];

        NSString * mktempCommandString = [NSString
                stringWithFormat:@"mktemp -u --tmpdir=%@ %@", directoryPath, nameTemplate];
        
        NSError * sshError = NULL;
        NSString * tempFilePath = [SSHCommand execCommand:mktempCommandString server:server timeout:timeoutNumber sshError:&sshError];
        
        NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        tempFilePath = [tempFilePath stringByTrimmingCharactersInSet:whitespaceSet];

        tempFilePath = [tempFilePath stringByAppendingString:@".svg"];
        
        NSString * touchCommandString = [NSString
                stringWithFormat:@"touch %@", tempFilePath];
        NSString * touchResult = [SSHCommand execCommand:touchCommandString server:server timeout:timeoutNumber sshError:&sshError];
        #pragma unused(touchResult)

        [connection closeSSH:server];

        result = tempFilePath;
    }
    else
    {
        //NSAlert * errorAlert = [NSAlert alertWithMessageText:@"The file failed to save to the SSH network connection." defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"Check your network settings and try again."];

        NSAlert * errorAlert = [[NSAlert alloc] init];
        [errorAlert setMessageText:@"The file failed to save to the SSH network connection."];
        [errorAlert addButtonWithTitle:@"OK"];
        [errorAlert setInformativeText:@"Check your network settings and try again."];
        
        [errorAlert runModal];
    }
    
    return result;
}

//==================================================================================
//	renameFile:toName:sshConnection:
//==================================================================================

- (BOOL)renameFile:(NSString *)existingFileName toName:(NSString *)newFileName
        sshConnection:(NSDictionary *)networkConnectionDictionary
{
    BOOL result = NO;

    NSString * hostNameString = [networkConnectionDictionary objectForKey:@"hostName"];
    NSString * portNumberString = [networkConnectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [networkConnectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [networkConnectionDictionary objectForKey:@"password"];
    //NSString * urlFilePath = [networkConnectionDictionary objectForKey:@"urlFilePath"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];
    
    int portNumber = [portNumberString intValue];

    DFSSHServer *server = [[DFSSHServer alloc] init];

    [server setSSHHost:hostAddrString port:portNumber
            user:userNameString key:@"" keypub:@"" password:passwordString];

    DFSSHConnector *connection = [[DFSSHConnector alloc] init];

    [connection connect:server connectionType:[DFSSHConnectionType auto]];

    if ([server connectionStatus] == YES)
    {
        NSNumber * timeoutNumber = [NSNumber numberWithDouble:60];
        NSString * rename1CommandString = [NSString
                stringWithFormat:@"mv %@ %@", existingFileName, newFileName];
        NSError * sshError = NULL;
        NSString * rename1Result = [SSHCommand execCommand:rename1CommandString
                server:server timeout:timeoutNumber sshError:&sshError];
        #pragma unused(rename1Result)

        [connection closeSSH:server];

        result = YES;
    }

    return result;
}

//==================================================================================
//	saveDocument:networkConnectionDictionary:
//==================================================================================

- (BOOL)saveDocument:(MacSVGDocument *)macSVGDocument
        networkConnectionDictionary:(NSDictionary *)networkConnectionDictionary
{
    BOOL result = NO;
    
    NSString * networkAccessMethod = [self.workingConnectionDictionary objectForKey:@"connectionType"];
    //NSString * urlFilePath = [self.workingConnectionDictionary objectForKey:@"urlFilePath"];
    //NSString * hostNameString = [self.workingConnectionDictionary objectForKey:@"hostName"];
    //NSString * portNumberString = [self.workingConnectionDictionary objectForKey:@"portNumber"];
    //NSString * userNameString = [self.workingConnectionDictionary objectForKey:@"userName"];
    //NSString * passwordString = [self.workingConnectionDictionary objectForKey:@"password"];
    
    if ([networkAccessMethod isEqualToString:@"SFTP Server"] == YES)
    {
        result = [self saveDocumentWithSftpConnection:macSVGDocument
                networkConnectionDictionary:networkConnectionDictionary];
    }
    if ([networkAccessMethod isEqualToString:@"SSH Connection"] == YES)
    {
        result = [self saveDocumentWithScpConnection:macSVGDocument
                networkConnectionDictionary:networkConnectionDictionary];
    }
    
    return result;
}

//==================================================================================
//	saveDocumentWithSftpConnection:networkConnectionDictionary:
//==================================================================================

- (BOOL)saveDocumentWithSftpConnection:(MacSVGDocument *)macSVGDocument
        networkConnectionDictionary:(NSDictionary *)networkConnectionDictionary
{
    BOOL result = NO;
    NSError * networkError = NULL;
    
    //SFTPUploadWithBlocking * sftpUpload = [[SFTPUploadWithBlocking alloc] init];
    SFTPUpload * sftpUpload = [[SFTPUpload alloc] init];
    
    NSString * hostNameString = [networkConnectionDictionary objectForKey:@"hostName"];
    //NSString * portNumberString = [networkConnectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [networkConnectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [networkConnectionDictionary objectForKey:@"password"];
    NSString * urlFilePath = [networkConnectionDictionary objectForKey:@"urlFilePath"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];
    
    NSString * fileName = [urlFilePath lastPathComponent];
    NSString * fileExtension = [fileName pathExtension];

    NSString * dataType = @"public.svg-image";
    if ([fileExtension isEqualToString:@"xhtml"] == YES)
    {
        dataType = @"public.xhtml";
    }
    NSData * data = [macSVGDocument dataOfType:dataType error:&networkError];
    
    if ([fileExtension isEqualToString:@"svg"] == YES)
    {
        if (saveAsNetworkCompressedCheckboxButton.state == YES)
        {
            data = [self gzipDeflate:data];
        }
    }
    
    BOOL validExtensionFound = NO;
    if ([fileExtension isEqualToString:@"svg"] == YES)
    {
        validExtensionFound = YES;
    }
    else if ([fileExtension isEqualToString:@"svgz"] == YES)
    {
        validExtensionFound = YES;
    }
    else if ([fileExtension isEqualToString:@"xhtml"] == YES)
    {
        validExtensionFound = YES;
    }
    else if ([fileExtension isEqualToString:@"html"] == YES)
    {
        validExtensionFound = YES;
    }
    
    if (validExtensionFound == YES)
    {
        NSString * tempFilePath = [self makeTemporaryFileWithSSHConnection:networkConnectionDictionary];
        
        if (tempFilePath != NULL)
        {
            // upload file with temporary name
            NSError * uploadError = [sftpUpload execSFTPUploadData:data hostaddr:hostAddrString
                    user:userNameString password:passwordString sftppath:tempFilePath];
            
            if (uploadError != NULL)
            {
                NSAlert * errorAlert = [NSAlert alertWithError:uploadError];
                [errorAlert runModal];
                result = NO;
            }
            else
            {
                // rename existing file with tilde appended
                NSString * replacedFilePath = [urlFilePath stringByAppendingString:@"~"];
                [self renameFile:urlFilePath toName:replacedFilePath sshConnection:networkConnectionDictionary];
            
                // rename temporary file to final name
                [self renameFile:tempFilePath toName:urlFilePath sshConnection:networkConnectionDictionary];
                
                result = YES;
            }
        }
    }
    
    return result;
}


//==================================================================================
//	saveDocumentWithScpConnection:networkConnectionDictionary:
//==================================================================================

- (BOOL)saveDocumentWithScpConnection:(MacSVGDocument *)macSVGDocument
        networkConnectionDictionary:(NSDictionary *)networkConnectionDictionary
{
    BOOL result = NO;
    NSError * networkError = NULL;
    
    SCPUpload * scpUpload = [[SCPUpload alloc] init];
    
    //NSData * data = [macSVGDocument dataOfType:@"MacSVGDocument" error:&networkError];
    
    NSString * hostNameString = [networkConnectionDictionary objectForKey:@"hostName"];
    //NSString * portNumberString = [networkConnectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [networkConnectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [networkConnectionDictionary objectForKey:@"password"];
    NSString * urlFilePath = [networkConnectionDictionary objectForKey:@"urlFilePath"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];
    
    NSString * fileName = [urlFilePath lastPathComponent];
    NSString * fileExtension = [fileName pathExtension];

    NSString * dataType = @"public.svg-image";
    if ([fileExtension isEqualToString:@"xhtml"] == YES)
    {
        dataType = @"public.xhtml";
    }
    NSData * data = [macSVGDocument dataOfType:dataType error:&networkError];
    
    BOOL validExtensionFound = NO;
    if ([fileExtension isEqualToString:@"svg"] == YES)
    {
        validExtensionFound = YES;
    }
    else if ([fileExtension isEqualToString:@"svgz"] == YES)
    {
        validExtensionFound = YES;
    }
    else if ([fileExtension isEqualToString:@"xhtml"] == YES)
    {
        validExtensionFound = YES;
    }
    else if ([fileExtension isEqualToString:@"html"] == YES)
    {
        validExtensionFound = YES;
    }
    
    if (validExtensionFound == YES)
    {
        NSString * tempFilePath = [self makeTemporaryFileWithSSHConnection:networkConnectionDictionary];
        
        if (tempFilePath != NULL)
        {
            // upload file with temporary name
            NSError * uploadError = [scpUpload execSCPUploadData:data hostaddr:hostAddrString user:userNameString
                    password:passwordString scppath:tempFilePath];
            
            if (uploadError != NULL)
            {
                NSAlert * errorAlert = [NSAlert alertWithError:uploadError];
                [errorAlert runModal];
                result = NO;
            }
            else
            {
                // rename existing file with tilde appended
                NSString * replacedFilePath = [urlFilePath stringByAppendingString:@"~"];
                [self renameFile:urlFilePath toName:replacedFilePath sshConnection:networkConnectionDictionary];
            
                // rename temporary file to final name
                [self renameFile:tempFilePath toName:urlFilePath sshConnection:networkConnectionDictionary];
                
                result = YES;
            }
        }
    }
    
    return result;
}

//==================================================================================
//	findFrontmostMacSVGDocument
//==================================================================================

- (MacSVGDocument *)findFrontmostMacSVGDocument
{
    MacSVGDocument * result = NULL;
    NSArray *orderedDocuments = [NSApp orderedDocuments];
    NSUInteger documentCount = [orderedDocuments count];
    int i;
    for (i = 0; i < documentCount; i++)
    {
        if (result == NULL)
        {
            NSDocument *aDocument = (NSDocument *)[orderedDocuments objectAtIndex:i];
            if ([aDocument isMemberOfClass:[MacSVGDocument class]] == YES)
            {
                result = (MacSVGDocument *)aDocument;
            }
        }
    }
    return result;
}

//==================================================================================
//	saveAsDocument:networkConnectionDictionary:
//==================================================================================

- (BOOL)saveAsDocument:(MacSVGDocument *)macSVGDocument
        networkConnectionDictionary:(NSDictionary *)networkConnectionDictionary
{
    NSString * connectionTypeString = [saveAsNetworkConnectionTypePopUpButton titleOfSelectedItem];
    NSString * urlFilePathString = [saveAsNetworkUrlFilePathTextField stringValue];
    NSString * hostNameString = [saveAsNetworkHostNameTextField stringValue];
    NSString * portNumberString = [saveAsNetworkPortNumberTextField stringValue];
    NSString * userNameString = [saveAsNetworkUserNameTextField stringValue];
    NSString * passwordString = [saveAsNetworkPasswordTextField stringValue];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];
    
    NSString * lastPathComponent = [urlFilePathString lastPathComponent];
    NSString * pathExtension = [lastPathComponent pathExtension];

    BOOL fileNameFound = NO;
    if ([pathExtension isEqualToString:@"svg"] == YES)
    {
        fileNameFound = YES;
    }
    else if ([pathExtension isEqualToString:@"svgz"] == YES)
    {
        fileNameFound = YES;
    }
    else if ([pathExtension isEqualToString:@"xhtml"] == YES)
    {
        fileNameFound = YES;
    }
    else if ([pathExtension isEqualToString:@"html"] == YES)
    {
        fileNameFound = YES;
    }
    
    NSDictionary * connectionDictionary = networkConnectionDictionary;
    
    if (fileNameFound == NO)
    {
        //NSString * defaultDraftName = [macSVGDocument defaultDraftName];
        NSString * defaultDraftName = [macSVGDocument displayName];

        NSString * newPathExtension = [defaultDraftName pathExtension];
        
        if ([newPathExtension length] == 0)
        {
            //newPathExtension = [macSVGDocument
            //        fileNameExtensionForType:@"MacSVGDocument"
            //        saveOperation:NSSaveOperation];
            
            defaultDraftName = [macSVGDocument defaultDraftName];
            
            newPathExtension = macSVGDocument.fileNameExtension;
            
            defaultDraftName = [defaultDraftName stringByAppendingPathExtension:newPathExtension];
        }

        if ([newPathExtension length] == 0)
        {
            NSLog(@"NetworkConnectionManager - valid path extension not found");
        }
        
        NSString * filePath = [urlFilePathString stringByAppendingPathComponent:defaultDraftName];

        [saveAsNetworkUrlFilePathTextField setStringValue:filePath];
        
        connectionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                connectionTypeString, @"connectionType",
                filePath, @"urlFilePath",
                hostAddrString, @"hostName",
                portNumberString, @"portNumber",
                userNameString, @"userName",
                passwordString, @"password",
                nil];
        
        macSVGDocument.networkConnectionDictionary = connectionDictionary;
    }

    self.workingConnectionDictionary = connectionDictionary;

    [self saveAsNetworkConnectionTextFieldAction:self];

    [saveAsNetworkConnectionWindow makeKeyAndOrderFront:self];
    
    return YES;
}

//==================================================================================
//	saveAsNetworkConnectionTextFieldAction:
//==================================================================================

- (IBAction)saveAsNetworkConnectionTextFieldAction:(id)sender
{
    NSString * connectionTypeString = [saveAsNetworkConnectionTypePopUpButton titleOfSelectedItem];
    NSString * urlFilePathString = [saveAsNetworkUrlFilePathTextField stringValue];
    //NSString * hostNameString = [saveAsNetworkHostNameTextField stringValue];
    //NSString * portNumberString = [saveAsNetworkPortNumberTextField stringValue];
    NSString * userNameString = [saveAsNetworkUserNameTextField stringValue];
    NSString * passwordString = [saveAsNetworkPasswordTextField stringValue];
    //NSInteger compressFileOption = [saveAsNetworkCompressedCheckboxButton state];
    
    NSString * pathExtension = [urlFilePathString pathExtension];
    
    BOOL validPathExtension = NO;
    if ([pathExtension isEqualToString:@"svg"] == YES)
    {
        validPathExtension = YES;
    }
    else if ([pathExtension isEqualToString:@"svgz"] == YES)
    {
        validPathExtension = YES;
    }
    else if ([pathExtension isEqualToString:@"xhtml"] == YES)
    {
        validPathExtension = YES;
    }
    else if ([pathExtension isEqualToString:@"html"] == YES)
    {
        validPathExtension = YES;
    }
    
    BOOL validLoginCredentials = NO;
    if ([userNameString length] > 0)
    {
        if ([passwordString length] > 0)
        {
            validLoginCredentials = YES;
        }
    }

    if ([connectionTypeString isEqualToString:@"SFTP Server"] == YES)
    {
        if ([urlFilePathString length] > 0)
        {
            [saveAsNetworkBrowseDirectoriesButton setEnabled:YES];
            if (validPathExtension == YES)
            {
                [saveAsNetworkSaveButton setEnabled:YES];
            }
            else
            {
                [saveAsNetworkSaveButton setEnabled:NO];
            }
        }
        else
        {
            [saveAsNetworkBrowseDirectoriesButton setEnabled:NO];
            [saveAsNetworkSaveButton setEnabled:NO];
        }
    }
    else if ([connectionTypeString isEqualToString:@"SSH Connection"] == YES)
    {
        if (validLoginCredentials == YES)
        {
            if ([urlFilePathString length] > 0)
            {
                [saveAsNetworkBrowseDirectoriesButton setEnabled:YES];
                if (validPathExtension == YES)
                {
                    [saveAsNetworkSaveButton setEnabled:YES];
                }
                else
                {
                    [saveAsNetworkSaveButton setEnabled:NO];
                }
            }
            else
            {
                [saveAsNetworkBrowseDirectoriesButton setEnabled:NO];
                [saveAsNetworkSaveButton setEnabled:NO];
            }
        }
        else
        {
            [saveAsNetworkBrowseDirectoriesButton setEnabled:NO];
            [saveAsNetworkSaveButton setEnabled:NO];
        }
    }
}

//==================================================================================
//	saveAsNetworkConnectionCancelButtonAction:
//==================================================================================

- (IBAction)saveAsNetworkConnectionCancelButtonAction:(id)sender
{
    [saveAsNetworkConnectionWindow orderOut:self];
}

//==================================================================================
//	saveAsNetworkConnectionSaveButtonAction:
//==================================================================================

- (IBAction)saveAsNetworkConnectionSaveButtonAction:(id)sender
{
    [saveAsNetworkConnectionWindow orderOut:self];
    
    //[self saveFileListingItem:self];
}

//==================================================================================
//	saveAsNetworkConnectionBrowseDirectoriesButtonAction:
//==================================================================================

- (IBAction)saveAsNetworkConnectionBrowseDirectoriesButtonAction:(id)sender
{
    NSString * connectionTypeString = [saveAsNetworkConnectionTypePopUpButton titleOfSelectedItem];
    NSString * urlFilePathString = [saveAsNetworkUrlFilePathTextField stringValue];
    NSString * hostNameString = [saveAsNetworkHostNameTextField stringValue];
    NSString * portNumberString = [saveAsNetworkPortNumberTextField stringValue];
    NSString * userNameString = [saveAsNetworkUserNameTextField stringValue];
    NSString * passwordString = [saveAsNetworkPasswordTextField stringValue];
    NSInteger compressFileOptionState = [saveAsNetworkCompressedCheckboxButton state];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];
    
    NSString * compressFileOption = @"NO";
    if (compressFileOptionState != 0)
    {
        compressFileOption = @"YES";
    }

    NSDictionary * connectionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
            connectionTypeString, @"connectionType",
            urlFilePathString, @"urlFilePath",
            hostAddrString, @"hostName",
            portNumberString, @"portNumber",
            userNameString, @"userName",
            passwordString, @"password",
            compressFileOption, @"compressFileOption",
            nil];

    [saveAsNetworkConnectionWindow orderOut:self];
    
    NSString * lastPathComponent = [urlFilePathString lastPathComponent];
    
    BOOL validFileName = NO;
    
    if ([lastPathComponent length] > 0)
    {
        NSString * fileNameExtension = [lastPathComponent pathExtension];
        
        if ([fileNameExtension isEqualToString:@"svg"] == YES)
        {
            validFileName = YES;
        }
        else if ([fileNameExtension isEqualToString:@"svgz"] == YES)
        {
            validFileName = YES;
        }
        else if ([fileNameExtension isEqualToString:@"xhtml"] == YES)
        {
            validFileName = YES;
        }
        else if ([fileNameExtension isEqualToString:@"html"] == YES)
        {
            validFileName = YES;
        }
    }

    if (validFileName == YES)
    {
        [saveNetworkDirectoryBrowserFileNameTextField setStringValue:lastPathComponent];
        [saveNetworkDirectoryBrowserSaveButton setEnabled:YES];
    }
    else
    {
        [saveNetworkDirectoryBrowserFileNameTextField setStringValue:@""];
        [saveNetworkDirectoryBrowserSaveButton setEnabled:NO];
    }
    
    [saveAsNetworkDirectoryBrowserWindow makeKeyAndOrderFront:self];
    
    [self loadNetworkDirectoryBrowserForConnection:connectionDictionary];
}

//==================================================================================
//	loadNetworkDirectoryBrowserForConnection:
//==================================================================================

- (void)loadNetworkDirectoryBrowserForConnection:(NSDictionary *)connectionDictionary
{
    self.workingConnectionDictionary = connectionDictionary;

    NSString * connectionTypeString = [connectionDictionary objectForKey:@"connectionType"];
    
    if ([connectionTypeString isEqualToString:@"HTTP Web Server"] == YES)
    {
        // not a valid function for HTTP
    }
    else if ([connectionTypeString isEqualToString:@"SFTP Server"] == YES)
    {
        [self loadNetworkDirectoryBrowserForSFTPConnection:connectionDictionary];
    }
    else if ([connectionTypeString isEqualToString:@"SSH Connection"] == YES)
    {
        [self loadNetworkDirectoryBrowserForSSHConnection:connectionDictionary];
    }
}

//==================================================================================
//	loadNetworkDirectoryBrowserForSSHConnection:
//==================================================================================

- (void)loadNetworkDirectoryBrowserForSSHConnection:(NSDictionary *)connectionDictionary
{
    //NSString * connectionTypeString = [connectionDictionary objectForKey:@"connectionType"];
    NSString * urlFilePathString = [connectionDictionary objectForKey:@"urlFilePath"];
    NSString * hostNameString = [connectionDictionary objectForKey:@"hostName"];
    NSString * portNumberString = [connectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [connectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [connectionDictionary objectForKey:@"password"];
    //NSString * compressFileOption = [connectionDictionary objectForKey:@"compressFileOption"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];

    NSImage * iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
    [iconImage setSize:NSMakeSize(16,16)];
    
    [saveNetworkDirectoryBrowserDirectoryPopUpButton removeAllItems];
    
    [saveNetworkDirectoryBrowserDirectoryPopUpButton addItemWithTitle:@"/"];
    NSMenuItem * menuItem = [saveNetworkDirectoryBrowserDirectoryPopUpButton itemAtIndex:0];
    [menuItem setImage:iconImage];
    
    NSArray * pathArray = [urlFilePathString componentsSeparatedByString:@"/"];
    NSInteger pathArrayCount = [pathArray count];
    for (NSInteger i = 0; i < pathArrayCount; i++)
    {
        NSString * directoryString = [pathArray objectAtIndex:i];
        if ([directoryString length] > 0)
        {
            NSString * fileNameExtension = [directoryString pathExtension];
            BOOL displayListing = YES;
            if ([fileNameExtension isEqualToString:@"svg"] == YES)
            {
                displayListing = NO;
            }
            else if ([fileNameExtension isEqualToString:@"svgz"] == YES)
            {
                displayListing = NO;
            }
            else if ([fileNameExtension isEqualToString:@"xhtml"] == YES)
            {
                displayListing = NO;
            }
            else if ([fileNameExtension isEqualToString:@"html"] == YES)
            {
                displayListing = NO;
            }

            if (displayListing == YES)
            {
                [saveNetworkDirectoryBrowserDirectoryPopUpButton addItemWithTitle:directoryString];
                
                NSInteger lastItemIndex = [saveNetworkDirectoryBrowserDirectoryPopUpButton numberOfItems] - 1;
                NSMenuItem * menuItem = [saveNetworkDirectoryBrowserDirectoryPopUpButton itemAtIndex:lastItemIndex];
                [menuItem setImage:iconImage];
            }
        }
    }
    NSInteger lastItemIndex = [saveNetworkDirectoryBrowserDirectoryPopUpButton numberOfItems] - 1;
    [saveNetworkDirectoryBrowserDirectoryPopUpButton selectItemAtIndex:lastItemIndex];
    
    int portNumber = [portNumberString intValue];

    DFSSHServer *server = [[DFSSHServer alloc] init];   

    [server setSSHHost:hostAddrString port:portNumber user:userNameString key:@"" keypub:@"" password:passwordString];

    DFSSHConnector *connection = [[DFSSHConnector alloc] init];

    [connection connect:server connectionType:[DFSSHConnectionType auto]];

    if ([server connectionStatus] == YES)
    {
        NSString * directoryPathString = urlFilePathString;
    
        NSString * lastPathComponent = [urlFilePathString lastPathComponent];
        NSString * pathExtension = [lastPathComponent pathExtension];
        BOOL omitFileName = NO;
        
        if ([pathExtension isEqualToString:@"svg"] == YES)
        {
            omitFileName = YES;
        }
        else if ([pathExtension isEqualToString:@"svgz"] == YES)
        {
            omitFileName = YES;
        }
        else if ([pathExtension isEqualToString:@"xhtml"] == YES)
        {
            omitFileName = YES;
        }
        else if ([pathExtension isEqualToString:@"html"] == YES)
        {
            omitFileName = YES;
        }
        
        if (omitFileName == YES)
        {
            NSInteger directoryPathStringLength = [directoryPathString length];
            NSInteger fileNameLength = [lastPathComponent length];
            NSInteger trimIndex = directoryPathStringLength - fileNameLength;
            directoryPathString = [directoryPathString substringToIndex:trimIndex];
        }
    
        NSString * lsCommandString = [NSString stringWithFormat:@"ls -l -w 160 %@", directoryPathString];
        
        NSNumber * timeoutNumber = [NSNumber numberWithDouble:60];
        NSError * sshError = NULL;
        NSString * lsDirectoryResult = [SSHCommand execCommand:lsCommandString server:server timeout:timeoutNumber sshError:&sshError];

        [connection closeSSH:server];
        
        NSArray * directoryListingArray = [lsDirectoryResult componentsSeparatedByString:@"\n"];
        //NSInteger directoryListingArrayCount = [directoryListingArray count];

        //NSLog(@"lsCommandString = %@", lsCommandString);
        //NSLog(@"directoryListingArrayCount = %ld", (long)directoryListingArrayCount);
        
        // -rw-r--r--.  1 dsward   apache     74241 Nov 28  2011 firstsvg.svg
        // -rw-r--r--. 1 dsward dsward   19327 Feb 11  2012 Accelerate_Graphic_for_Animation2.svg
        // 0....5...10...15...20...25...30...35...40...45...50...55...60...65...70...75
        
        NSMutableArray * formattedDirectoryArray = [NSMutableArray array];
        
        for (NSString * listingString in directoryListingArray)
        {
            NSArray * listingArray = [listingString componentsSeparatedByString:@" "];
            
            //NSLog(@"listingArray = %@", listingArray);
            
            NSInteger listingArrayCount = [listingArray count];
            
            if (listingArrayCount > 6)
            {
                NSString * flagsString = @"";
                NSString * ownerString = @"";
                NSString * groupString = @"";
                NSString * sizeString = @"";
                NSString * dateTimeString = @"";
                NSString * nameString = @"";

                NSInteger fieldIndex = 0;
                for (NSInteger i = 0; i < listingArrayCount; i++)
                {
                    NSString * listingComponent = [listingArray objectAtIndex:i];
                    
                    if ([listingComponent length] > 0)
                    {
                        switch (fieldIndex)
                        {
                            case 0:
                                flagsString = listingComponent;
                                fieldIndex++;
                                break;

                            case 1:
                                fieldIndex++;
                                break;

                            case 2:
                                ownerString = listingComponent;
                                fieldIndex++;
                                break;

                            case 3:
                                groupString = listingComponent;
                                fieldIndex++;
                                break;

                            case 4:
                                sizeString = listingComponent;
                                fieldIndex++;
                                break;

                            case 5:
                                if ([dateTimeString length] > 0)
                                {
                                    dateTimeString = [dateTimeString stringByAppendingString:@" "];
                                }
                                dateTimeString = [dateTimeString stringByAppendingString:listingComponent];
                                if ([dateTimeString length] > 9)
                                {
                                    fieldIndex++;
                                }
                                break;

                            case 6:
                                if ([nameString length] > 0)
                                {
                                    nameString = [nameString stringByAppendingString:@" "];
                                }
                                nameString = [nameString stringByAppendingString:listingComponent];
                                break;
                            default:
                                break;
                        }
                        
                    }
                }
                
                NSString * fileNameExtension = [nameString pathExtension];
                
                BOOL displayListing = NO;
                
                if ([fileNameExtension isEqualToString:@"svg"] == YES)
                {
                    displayListing = YES;
                }
                else if ([fileNameExtension isEqualToString:@"svgz"] == YES)
                {
                    displayListing = YES;
                }
                else if ([fileNameExtension isEqualToString:@"xhtml"] == YES)
                {
                    displayListing = YES;
                }
                else if ([fileNameExtension isEqualToString:@"html"] == YES)
                {
                    displayListing = YES;
                }
                
                unichar fileTypeChar = [flagsString characterAtIndex:0];
                if (fileTypeChar == 'd')
                {
                    displayListing = YES;
                }

                if (displayListing == YES)
                {
                    NSDictionary * formattedListingDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                            flagsString, @"flags",
                            ownerString, @"owner",
                            groupString, @"group",
                            sizeString, @"size",
                            dateTimeString, @"dateTime",
                            nameString, @"name",
                            nil];

                    [formattedDirectoryArray addObject:formattedListingDictionary];
                }
            }
        }

        self.networkFileDirectoryArray = formattedDirectoryArray;
    }
    else
    {
        [connection closeSSH:server];
    }

    [saveNetworkDirectoryBrowserTableView setTarget:self];
    [saveNetworkDirectoryBrowserTableView setDoubleAction:@selector(openDirectoryListingItem:)];
    [saveNetworkDirectoryBrowserTableView reloadData];
}

//==================================================================================
//	loadNetworkDirectoryBrowserForSFTPConnection:
//==================================================================================

- (void)loadNetworkDirectoryBrowserForSFTPConnection:(NSDictionary *)connectionDictionary
{
    //NSString * connectionTypeString = [connectionDictionary objectForKey:@"connectionType"];
    NSString * urlFilePathString = [connectionDictionary objectForKey:@"urlFilePath"];
    NSString * hostNameString = [connectionDictionary objectForKey:@"hostName"];
    NSString * portNumberString = [connectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [connectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [connectionDictionary objectForKey:@"password"];
    //NSString * compressFileOption = [connectionDictionary objectForKey:@"compressFileOption"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];

    NSImage * iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
    [iconImage setSize:NSMakeSize(16,16)];
    
    [saveNetworkDirectoryBrowserDirectoryPopUpButton removeAllItems];
    
    [saveNetworkDirectoryBrowserDirectoryPopUpButton addItemWithTitle:@"/"];
    NSMenuItem * menuItem = [saveNetworkDirectoryBrowserDirectoryPopUpButton itemAtIndex:0];
    [menuItem setImage:iconImage];
    
    NSArray * pathArray = [urlFilePathString componentsSeparatedByString:@"/"];
    NSInteger pathArrayCount = [pathArray count];
    for (NSInteger i = 0; i < pathArrayCount; i++)
    {
        NSString * directoryString = [pathArray objectAtIndex:i];
        if ([directoryString length] > 0)
        {
            NSString * fileNameExtension = [directoryString pathExtension];
            BOOL displayListing = YES;
            if ([fileNameExtension isEqualToString:@"svg"] == YES)
            {
                displayListing = NO;
            }
            else if ([fileNameExtension isEqualToString:@"svgz"] == YES)
            {
                displayListing = NO;
            }
            else if ([fileNameExtension isEqualToString:@"xhtml"] == YES)
            {
                displayListing = NO;
            }
            else if ([fileNameExtension isEqualToString:@"html"] == YES)
            {
                displayListing = NO;
            }

            if (displayListing == YES)
            {
                [saveNetworkDirectoryBrowserDirectoryPopUpButton addItemWithTitle:directoryString];
                
                NSInteger lastItemIndex = [saveNetworkDirectoryBrowserDirectoryPopUpButton numberOfItems] - 1;
                NSMenuItem * menuItem = [saveNetworkDirectoryBrowserDirectoryPopUpButton itemAtIndex:lastItemIndex];
                [menuItem setImage:iconImage];
            }
        }
    }
    NSInteger lastItemIndex = [saveNetworkDirectoryBrowserDirectoryPopUpButton numberOfItems] - 1;
    [saveNetworkDirectoryBrowserDirectoryPopUpButton selectItemAtIndex:lastItemIndex];
    
    int portNumber = [portNumberString intValue];

    DFSSHServer *server = [[DFSSHServer alloc] init];   

    [server setSSHHost:hostAddrString port:portNumber user:userNameString key:@"" keypub:@"" password:passwordString];

    DFSSHConnector *connection = [[DFSSHConnector alloc] init];

    [connection connect:server connectionType:[DFSSHConnectionType auto]];

    if ([server connectionStatus] == YES)
    {
        NSString * directoryPathString = urlFilePathString;
    
        NSString * lastPathComponent = [urlFilePathString lastPathComponent];
        NSString * pathExtension = [lastPathComponent pathExtension];
        BOOL omitFileName = NO;
        
        if ([pathExtension isEqualToString:@"svg"] == YES)
        {
            omitFileName = YES;
        }
        else if ([pathExtension isEqualToString:@"svgz"] == YES)
        {
            omitFileName = YES;
        }
        else if ([pathExtension isEqualToString:@"xhtml"] == YES)
        {
            omitFileName = YES;
        }
        else if ([pathExtension isEqualToString:@"html"] == YES)
        {
            omitFileName = YES;
        }
        
        if (omitFileName == YES)
        {
            NSInteger directoryPathStringLength = [directoryPathString length];
            NSInteger fileNameLength = [lastPathComponent length];
            NSInteger trimIndex = directoryPathStringLength - fileNameLength;
            directoryPathString = [directoryPathString substringToIndex:trimIndex];
        }
    
        NSString * lsCommandString = [NSString stringWithFormat:@"ls -l -w 160 %@", directoryPathString];
        
        NSNumber * timeoutNumber = [NSNumber numberWithDouble:60];
        NSError * sshError = NULL;
        NSString * lsDirectoryResult = [SSHCommand execCommand:lsCommandString server:server timeout:timeoutNumber sshError:&sshError];

        [connection closeSSH:server];
        
        NSArray * directoryListingArray = [lsDirectoryResult componentsSeparatedByString:@"\n"];
        //NSInteger directoryListingArrayCount = [directoryListingArray count];

        //NSLog(@"lsCommandString = %@", lsCommandString);
        //NSLog(@"directoryListingArrayCount = %ld", (long)directoryListingArrayCount);
        
        // -rw-r--r--.  1 dsward   apache     74241 Nov 28  2011 firstsvg.svg
        // -rw-r--r--. 1 dsward dsward   19327 Feb 11  2012 Accelerate_Graphic_for_Animation2.svg
        // 0....5...10...15...20...25...30...35...40...45...50...55...60...65...70...75
        
        NSMutableArray * formattedDirectoryArray = [NSMutableArray array];
        
        for (NSString * listingString in directoryListingArray)
        {
            NSArray * listingArray = [listingString componentsSeparatedByString:@" "];
            
            //NSLog(@"listingArray = %@", listingArray);
            
            NSInteger listingArrayCount = [listingArray count];
            
            if (listingArrayCount > 6)
            {
                NSString * flagsString = @"";
                NSString * ownerString = @"";
                NSString * groupString = @"";
                NSString * sizeString = @"";
                NSString * dateTimeString = @"";
                NSString * nameString = @"";

                NSInteger fieldIndex = 0;
                for (NSInteger i = 0; i < listingArrayCount; i++)
                {
                    NSString * listingComponent = [listingArray objectAtIndex:i];
                    
                    if ([listingComponent length] > 0)
                    {
                        switch (fieldIndex)
                        {
                            case 0:
                                flagsString = listingComponent;
                                fieldIndex++;
                                break;

                            case 1:
                                fieldIndex++;
                                break;

                            case 2:
                                ownerString = listingComponent;
                                fieldIndex++;
                                break;

                            case 3:
                                groupString = listingComponent;
                                fieldIndex++;
                                break;

                            case 4:
                                sizeString = listingComponent;
                                fieldIndex++;
                                break;

                            case 5:
                                if ([dateTimeString length] > 0)
                                {
                                    dateTimeString = [dateTimeString stringByAppendingString:@" "];
                                }
                                dateTimeString = [dateTimeString stringByAppendingString:listingComponent];
                                if ([dateTimeString length] > 9)
                                {
                                    fieldIndex++;
                                }
                                break;

                            case 6:
                                if ([nameString length] > 0)
                                {
                                    nameString = [nameString stringByAppendingString:@" "];
                                }
                                nameString = [nameString stringByAppendingString:listingComponent];
                                break;
                            default:
                                break;
                        }
                        
                    }
                }
                
                NSString * fileNameExtension = [nameString pathExtension];
                
                BOOL displayListing = NO;
                
                if ([fileNameExtension isEqualToString:@"svg"] == YES)
                {
                    displayListing = YES;
                }
                else if ([fileNameExtension isEqualToString:@"svgz"] == YES)
                {
                    displayListing = YES;
                }
                else if ([fileNameExtension isEqualToString:@"xhtml"] == YES)
                {
                    displayListing = YES;
                }
                else if ([fileNameExtension isEqualToString:@"html"] == YES)
                {
                    displayListing = YES;
                }
                
                unichar fileTypeChar = [flagsString characterAtIndex:0];
                if (fileTypeChar == 'd')
                {
                    displayListing = YES;
                }

                if (displayListing == YES)
                {
                    NSDictionary * formattedListingDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                            flagsString, @"flags",
                            ownerString, @"owner",
                            groupString, @"group",
                            sizeString, @"size",
                            dateTimeString, @"dateTime",
                            nameString, @"name",
                            nil];

                    [formattedDirectoryArray addObject:formattedListingDictionary];
                }
            }
        }

        self.networkFileDirectoryArray = formattedDirectoryArray;
    }
    else
    {
        [connection closeSSH:server];
    }

    [saveNetworkDirectoryBrowserTableView setTarget:self];
    [saveNetworkDirectoryBrowserTableView setDoubleAction:@selector(openDirectoryListingItem:)];
    [saveNetworkDirectoryBrowserTableView reloadData];
}

//==================================================================================
//	openDirectoryListingItem:
//==================================================================================

- (IBAction)openDirectoryListingItem:(id)sender
{
    NSInteger rowIndex = [saveNetworkDirectoryBrowserTableView selectedRow];
    
    if (rowIndex != -1)
    {
        NSDictionary * listingDictionary = [self.networkFileDirectoryArray objectAtIndex:rowIndex];
        
        NSString * flagsString = [listingDictionary objectForKey:@"flags"];
        //NSString * ownerString = [listingDictionary objectForKey:@"owner"];
        //NSString * groupString = [listingDictionary objectForKey:@"group"];
        //NSString * sizeString = [listingDictionary objectForKey:@"size"];
        //NSString * dateTimeString = [listingDictionary objectForKey:@"dateTime"];
        NSString * nameString = [listingDictionary objectForKey:@"name"];

        NSString * networkAccessMethod = [self.workingConnectionDictionary objectForKey:@"connectionType"];
        NSString * networkDirectoryPath = [self.workingConnectionDictionary objectForKey:@"urlFilePath"];
        NSString * hostNameString = [self.workingConnectionDictionary objectForKey:@"hostName"];
        NSString * portNumberString = [self.workingConnectionDictionary objectForKey:@"portNumber"];
        NSString * userNameString = [self.workingConnectionDictionary objectForKey:@"userName"];
        NSString * passwordString = [self.workingConnectionDictionary objectForKey:@"password"];

        NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];
        
        NSString * lastPathComponent = [networkDirectoryPath lastPathComponent];
        NSString * pathExtension = [lastPathComponent pathExtension];
        
        BOOL fileNameFound = NO;
        if ([pathExtension isEqualToString:@"svg"] == YES)
        {
            fileNameFound = YES;
        }
        else if ([pathExtension isEqualToString:@"svgz"] == YES)
        {
            fileNameFound = YES;
        }
        else if ([pathExtension isEqualToString:@"xhtml"] == YES)
        {
            fileNameFound = YES;
        }
        else if ([pathExtension isEqualToString:@"html"] == YES)
        {
            fileNameFound = YES;
        }
        
        if (fileNameFound == YES)
        {
            networkDirectoryPath = [networkDirectoryPath stringByDeletingLastPathComponent];
        }

        networkDirectoryPath = [networkDirectoryPath stringByAppendingPathComponent:nameString];

        if (fileNameFound == YES)
        {
            networkDirectoryPath = [networkDirectoryPath stringByAppendingPathComponent:lastPathComponent];
        }
        
        NSDictionary * connectionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                networkAccessMethod, @"connectionType",
                networkDirectoryPath, @"urlFilePath",
                hostAddrString, @"hostName",
                portNumberString, @"portNumber",
                userNameString, @"userName",
                passwordString, @"password",
                nil];
        
        self.workingConnectionDictionary = connectionDictionary;

        BOOL isDirectory = NO;
        unichar fileTypeChar = [flagsString characterAtIndex:0];
        if (fileTypeChar == 'd')
        {
            isDirectory = YES;
        }
        
        if (isDirectory == YES)
        {
            //[self loadNetworkDirectoryBrowserForSSHConnection:connectionDictionary];

            if ([networkAccessMethod isEqualToString:@"HTTP Web Server"] == YES)
            {
                // not a valid function for HTTP
            }
            else if ([networkAccessMethod isEqualToString:@"SFTP Server"] == YES)
            {
                [self loadNetworkDirectoryBrowserForSFTPConnection:connectionDictionary];
            }
            else if ([networkAccessMethod isEqualToString:@"SSH Connection"] == YES)
            {
                [self loadNetworkDirectoryBrowserForSSHConnection:connectionDictionary];
            }
        }
        else
        {
            //self.networkFileDirectoryArray = [NSArray array];
            //[networkFileBrowserTableView reloadData];
            //[networkFileBrowserWindow orderOut:self];
            //[self openMacSVGDocumentWithScpConnection];
        }
    }
}

//==================================================================================
//	saveAsBrowserNetworkConnectionTextFieldAction:
//==================================================================================

- (IBAction)saveAsBrowserNetworkConnectionTextFieldAction:(id)sender
{
    NSString * fileName = [saveNetworkDirectoryBrowserFileNameTextField stringValue];
    BOOL validFileName = NO;
    
    if ([fileName length] > 0)
    {
        NSString * fileNameExtension = [fileName pathExtension];
        
        if ([fileNameExtension isEqualToString:@"svg"] == YES)
        {
            validFileName = YES;
        }
        else if ([fileNameExtension isEqualToString:@"svg"] == YES)
        {
            validFileName = YES;
        }
        else if ([fileNameExtension isEqualToString:@"xhtml"] == YES)
        {
            validFileName = YES;
        }
        else if ([fileNameExtension isEqualToString:@"html"] == YES)
        {
            validFileName = YES;
        }
    }
    
    if (validFileName == YES)
    {
        [saveNetworkDirectoryBrowserSaveButton setEnabled:YES];
    }
    else
    {
        [saveNetworkDirectoryBrowserSaveButton setEnabled:NO];
    }
}

//==================================================================================
//	saveAsNetworkDirectoryBrowserDirectoryPopUpButtonAction:
//==================================================================================

- (IBAction)saveAsNetworkDirectoryBrowserDirectoryPopUpButtonAction:(id)sender
{
    NSString * networkAccessMethod = [self.workingConnectionDictionary objectForKey:@"connectionType"];
    //NSString * oldNetworkDirectoryPath = [self.workingConnectionDictionary objectForKey:@"urlFilePath"];
    NSString * hostNameString = [self.workingConnectionDictionary objectForKey:@"hostName"];
    NSString * portNumberString = [self.workingConnectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [self.workingConnectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [self.workingConnectionDictionary objectForKey:@"password"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];

    NSInteger selectedIndex = [saveNetworkDirectoryBrowserDirectoryPopUpButton indexOfSelectedItem];
    
    NSMutableString * networkDirectoryPath = [NSMutableString string];
    
    for (NSInteger i = 0; i <= selectedIndex; i++)
    {
        NSMenuItem * componentItem = [saveNetworkDirectoryBrowserDirectoryPopUpButton itemAtIndex:i];
        NSString * componentString = [componentItem title];
        [networkDirectoryPath appendString:componentString];
        
        if (i > 0)
        {
            [networkDirectoryPath appendString:@"/"];
        }
    }

    NSDictionary * connectionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
            networkAccessMethod, @"connectionType",
            networkDirectoryPath, @"urlFilePath",
            hostAddrString, @"hostName",
            portNumberString, @"portNumber",
            userNameString, @"userName",
            passwordString, @"password",
            nil];
    
    self.workingConnectionDictionary = connectionDictionary;

//    [self loadNetworkDirectoryBrowserForSSHConnection:connectionDictionary];

    if ([networkAccessMethod isEqualToString:@"HTTP Web Server"] == YES)
    {
        // not a valid function for HTTP
    }
    else if ([networkAccessMethod isEqualToString:@"SFTP Server"] == YES)
    {
        [self loadNetworkDirectoryBrowserForSFTPConnection:connectionDictionary];
    }
    else if ([networkAccessMethod isEqualToString:@"SSH Connection"] == YES)
    {
        [self loadNetworkDirectoryBrowserForSSHConnection:connectionDictionary];
    }
}

//==================================================================================
//	saveAsNetworkDirectoryBrowserNewFolderButtonAction:
//==================================================================================

- (IBAction)saveAsNetworkDirectoryBrowserNewFolderButtonAction:(id)sender
{
/*
    NSString * networkAccessMethod = [self.workingConnectionDictionary objectForKey:@"connectionType"];
    //NSString * oldNetworkDirectoryPath = [self.workingConnectionDictionary objectForKey:@"urlFilePath"];
    NSString * hostNameString = [self.workingConnectionDictionary objectForKey:@"hostName"];
    NSString * portNumberString = [self.workingConnectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [self.workingConnectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [self.workingConnectionDictionary objectForKey:@"password"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];

    NSInteger selectedIndex = [saveNetworkDirectoryBrowserDirectoryPopUpButton indexOfSelectedItem];
    
    NSMutableString * networkDirectoryPath = [NSMutableString string];
    
    for (NSInteger i = 0; i <= selectedIndex; i++)
    {
        NSMenuItem * componentItem = [saveNetworkDirectoryBrowserDirectoryPopUpButton itemAtIndex:i];
        NSString * componentString = [componentItem title];
        [networkDirectoryPath appendString:componentString];
        
        if (i > 0)
        {
            [networkDirectoryPath appendString:@"/"];
        }
    }

    NSDictionary * connectionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
            networkAccessMethod, @"connectionType",
            networkDirectoryPath, @"urlFilePath",
            hostAddrString, @"hostName",
            portNumberString, @"portNumber",
            userNameString, @"userName",
            passwordString, @"password",
            nil];
    
    self.workingConnectionDictionary = connectionDictionary;

    [self loadNetworkDirectoryBrowserForSSHConnection:connectionDictionary];
*/
}


//==================================================================================
//	saveAsNetworkDirectoryBrowserOpenFolderButtonAction:
//==================================================================================

- (IBAction)saveAsNetworkDirectoryBrowserOpenFolderButtonAction:(id)sender
{
    [self openDirectoryListingItem:self];
}

//==================================================================================
//	saveAsNetworkDirectoryBrowserCancelButtonAction:
//==================================================================================

- (IBAction)saveAsNetworkDirectoryBrowserCancelButtonAction:(id)sender
{
    self.networkFileDirectoryArray = [NSArray array];
    [saveNetworkDirectoryBrowserTableView reloadData];
    [saveAsNetworkDirectoryBrowserWindow orderOut:self];
}

//==================================================================================
//	saveAsNetworkDirectoryBrowserSaveButtonAction:
//==================================================================================

- (IBAction)saveAsNetworkDirectoryBrowserSaveButtonAction:(id)sender
{
    NSString * networkAccessMethod = [self.workingConnectionDictionary objectForKey:@"connectionType"];
    //NSString * oldNetworkDirectoryPath = [self.workingConnectionDictionary objectForKey:@"urlFilePath"];
    NSString * hostNameString = [self.workingConnectionDictionary objectForKey:@"hostName"];
    NSString * portNumberString = [self.workingConnectionDictionary objectForKey:@"portNumber"];
    NSString * userNameString = [self.workingConnectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [self.workingConnectionDictionary objectForKey:@"password"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];

    NSArray * pathItemsArray = [saveNetworkDirectoryBrowserDirectoryPopUpButton itemArray];
    
    NSMutableString * pathString = [NSMutableString string];
    
    NSInteger itemIndex = 0;
    for (NSMenuItem * aMenuItem in pathItemsArray)
    {
        NSString * itemTitle = [aMenuItem title];
        
        [pathString appendString:itemTitle];
        
        if (itemIndex > 0)
        {
            [pathString appendString:@"/"];
        }
        
        itemIndex++;
    }
    
    NSString * fileName = [saveNetworkDirectoryBrowserFileNameTextField stringValue];
    
    [pathString appendString:fileName];
    
    NSDictionary * connectionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
            networkAccessMethod, @"connectionType",
            pathString, @"urlFilePath",
            hostAddrString, @"hostName",
            portNumberString, @"portNumber",
            userNameString, @"userName",
            passwordString, @"password",
            nil];
    
    self.workingConnectionDictionary = connectionDictionary;
    
    MacSVGDocument * macSVGDocument = [self findFrontmostMacSVGDocument];
    
    macSVGDocument.networkConnectionDictionary = connectionDictionary;
    
    [self saveDocument:macSVGDocument
            networkConnectionDictionary:macSVGDocument.networkConnectionDictionary];

    [saveAsNetworkDirectoryBrowserWindow orderOut:self];
}

//==================================================================================
//	saveNetworkDirectoryBrowserTableViewSelectionDidChange
//==================================================================================

- (void)saveNetworkDirectoryBrowserTableViewSelectionDidChange
{
    NSInteger selectedRow = [saveNetworkDirectoryBrowserTableView selectedRow];
    
    if (selectedRow != -1)
    {
        NSDictionary * itemDictionary = [self.networkFileDirectoryArray objectAtIndex:selectedRow];
        
        NSString * flagsString = [itemDictionary objectForKey:@"flags"];
        
        unichar firstCharacter = [flagsString characterAtIndex:0];
        
        if (firstCharacter == 'd')
        {
            [saveNetworkDirectoryBrowserOpenFolderButton setEnabled:YES];
        }
        else
        {
            [saveNetworkDirectoryBrowserOpenFolderButton setEnabled:NO];
        }
    }
    else
    {
        [saveNetworkDirectoryBrowserOpenFolderButton setEnabled:NO];
    }
}

//==================================================================================
//	viewForSaveNetworkDirectoryBrowserTableColumn:rowIndex
//==================================================================================

- (NSView *)viewForSaveNetworkDirectoryBrowserTableColumn:(NSTableColumn *)aTableColumn rowIndex:(NSInteger)rowIndex
{
    NSView * resultView = NULL;

    if ([self.networkFileDirectoryArray count] > 0)
    {
        NSDictionary * itemDictionary = [self.networkFileDirectoryArray objectAtIndex:rowIndex];
        NSString * fileName = [itemDictionary objectForKey:@"name"];
        NSString * fileNameExtension = [fileName pathExtension];
        NSString * flagsString = [itemDictionary objectForKey:@"flags"];
        unichar fileTypeChar = [flagsString characterAtIndex:0];

        NSString * tableColumnIdentifier= [aTableColumn identifier];
        
        if ([tableColumnIdentifier isEqualToString:@"fileName"] == YES)
        {
            NSTableCellView * cellView = [saveNetworkDirectoryBrowserTableView makeViewWithIdentifier:tableColumnIdentifier owner:self];

            NSImage * iconImage = NULL;

            if (fileTypeChar == 'd')
            {
                iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
                [cellView.textField setTextColor:[NSColor blackColor]];
            }
            else
            {
                iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:fileNameExtension];
                [cellView.textField setTextColor:[NSColor grayColor]];
            }
            
            cellView.textField.stringValue = fileName;
            cellView.imageView.objectValue = iconImage;
            
            resultView = cellView;
        }
        else if ([tableColumnIdentifier isEqualToString:@"listingType"] == YES)
        {
            NSTableCellView * cellView = [saveNetworkDirectoryBrowserTableView makeViewWithIdentifier:tableColumnIdentifier owner:self];

            
            NSString * listingType = @"Unknown";
            
            if ([fileNameExtension isEqualToString:@"svg"] == YES)
            {
                listingType = @"SVG";
            }
            else if ([fileNameExtension isEqualToString:@"svgz"] == YES)
            {
                listingType = @"SVGZ";
            }
            else if ([fileNameExtension isEqualToString:@"xhtml"] == YES)
            {
                listingType = @"XHTML";
            }
            else if ([fileNameExtension isEqualToString:@"html"] == YES)
            {
                listingType = @"HTML";
            }
            
            if (fileTypeChar == 'd')
            {
                listingType = @"Folder";
                [cellView.textField setTextColor:[NSColor blackColor]];
            }
            else
            {
                [cellView.textField setTextColor:[NSColor grayColor]];
            }
            
            cellView.textField.stringValue = listingType;
            
            resultView = cellView;
        }
        else if ([tableColumnIdentifier isEqualToString:@"properties"] == YES)
        {
            NSTableCellView * cellView = [saveNetworkDirectoryBrowserTableView makeViewWithIdentifier:tableColumnIdentifier owner:self];

            NSString * dateTimeString = [itemDictionary objectForKey:@"dateTime"];

            if (fileTypeChar == 'd')
            {
                [cellView.textField setTextColor:[NSColor blackColor]];
            }
            else
            {
                [cellView.textField setTextColor:[NSColor grayColor]];
            }
            
            cellView.textField.stringValue = dateTimeString;
            
            resultView = cellView;
        }
        else
        {
            NSTableCellView * cellView = [saveNetworkDirectoryBrowserTableView makeViewWithIdentifier:tableColumnIdentifier owner:self];
            resultView = cellView;
        }
    }
    
    return resultView;
}

//==================================================================================
//	gzipInflate:
//==================================================================================

- (NSData *)gzipInflate:(NSData *)inputData
{
    if ([inputData length] == 0) return inputData;

    unsigned int full_length = (unsigned int)[inputData length];
    unsigned int half_length = (unsigned int)[inputData length] / 2;

    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;

    z_stream strm;
    strm.next_in = (Bytef *)[inputData bytes];
    strm.avail_in = (unsigned int)[inputData length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;

    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
        {
            [decompressed increaseLengthBy: half_length];
        }
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (unsigned int)([decompressed length] - strm.total_out);

        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
    }
    if (inflateEnd (&strm) != Z_OK) return nil;

    // Set real length.
    if (done)
    {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}

//==================================================================================
//	gzipDeflate:
//==================================================================================

- (NSData *)gzipDeflate:(NSData *)inputData
{
    if ([inputData length] == 0) return inputData;

    z_stream strm;

    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[inputData bytes];
    strm.avail_in = (unsigned int)[inputData length];

    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION

    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;

    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion

    do {
        if (strm.total_out >= [compressed length])
        {
            [compressed increaseLengthBy: 16384];
        }

        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (unsigned int)([compressed length] - strm.total_out);

        deflate(&strm, Z_FINISH);  
    } while (strm.avail_out == 0);

    deflateEnd(&strm);

    [compressed setLength: strm.total_out];
    return [NSData dataWithData:compressed];
}

//==================================================================================
//	showCreateNewFolderSheet:
//==================================================================================

- (IBAction) showCreateNewFolderSheet:(id)sender
{
    [createNewFolderNameTextField setStringValue:@""];

    NSString * pathString = [self.workingConnectionDictionary objectForKey:@"urlFilePath"];
    
    NSString * lastPathComponent = [pathString lastPathComponent];
    NSString * pathExtension = [lastPathComponent pathExtension];
    
    BOOL fileNameFound = NO;
    if ([pathExtension isEqualToString:@"svg"] == YES)
    {
        fileNameFound = YES;
    }
    else if ([pathExtension isEqualToString:@"svgz"] == YES)
    {
        fileNameFound = YES;
    }
    else if ([pathExtension isEqualToString:@"xhtml"] == YES)
    {
        fileNameFound = YES;
    }
    else if ([pathExtension isEqualToString:@"html"] == YES)
    {
        fileNameFound = YES;
    }
    
    if (fileNameFound == YES)
    {
        pathString = [pathString stringByDeletingLastPathComponent];
    }
    
    [createNewFolderPathTextField setStringValue:pathString];

    //[NSApp beginSheet:createNewFolderSheet modalForWindow:saveAsNetworkDirectoryBrowserWindow
    //        modalDelegate:self didEndSelector:nil contextInfo:nil];

    [saveAsNetworkDirectoryBrowserWindow beginSheet:createNewFolderSheet
            completionHandler:^(NSModalResponse returnCode)
    {
       
    }];
}

//==================================================================================
//	createNewFolder:
//==================================================================================

- (IBAction) createNewFolder:(id)sender
{
    BOOL createFolderSuccess = NO;
    
    NSString * newFolderName = [createNewFolderNameTextField stringValue];
    
    NSInteger newFolderNameLength = [newFolderName length];
    if ([newFolderName length] > 0)
    {
        BOOL validFolderName = YES;
        for (NSInteger i = 0; i < newFolderNameLength; i++)
        {
            unichar aChar = [newFolderName characterAtIndex:i];
            
            if (aChar == '/')
            {
                validFolderName = NO;
            }
        }
    
        if (validFolderName == YES)
        {
            NSString * networkAccessMethod = [self.workingConnectionDictionary objectForKey:@"connectionType"];
            //NSString * oldNetworkDirectoryPath = [self.workingConnectionDictionary objectForKey:@"urlFilePath"];
            NSString * hostNameString = [self.workingConnectionDictionary objectForKey:@"hostName"];
            NSString * portNumberString = [self.workingConnectionDictionary objectForKey:@"portNumber"];
            NSString * userNameString = [self.workingConnectionDictionary objectForKey:@"userName"];
            NSString * passwordString = [self.workingConnectionDictionary objectForKey:@"password"];

            NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];
            
            NSString * pathString = [createNewFolderPathTextField stringValue];
            
            NSError * directoryError = NULL;
            
            if ([networkAccessMethod isEqualToString:@"SFTP Server"] == YES)
            {
                directoryError = [self createNewDirectory:newFolderName
                        atPath:pathString
                        withSFTPConnection:self.workingConnectionDictionary];
            }
            else if ([networkAccessMethod isEqualToString:@"SSH Connection"] == YES)
            {
                directoryError = [self createNewDirectory:newFolderName
                        atPath:pathString
                        withSSHConnection:self.workingConnectionDictionary];
            }

            if (directoryError == NULL)
            {
                NSString * newPathString = [pathString stringByAppendingPathComponent:newFolderName];
            
                NSDictionary * connectionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                        networkAccessMethod, @"connectionType",
                        newPathString, @"urlFilePath",
                        hostAddrString, @"hostName",
                        portNumberString, @"portNumber",
                        userNameString, @"userName",
                        passwordString, @"password",
                        nil];

                self.workingConnectionDictionary = connectionDictionary;

                if ([networkAccessMethod isEqualToString:@"HTTP Web Server"] == YES)
                {
                    // not a valid function for HTTP
                }
                else if ([networkAccessMethod isEqualToString:@"SFTP Server"] == YES)
                {
                    [self loadNetworkDirectoryBrowserForSFTPConnection:connectionDictionary];
                }
                else if ([networkAccessMethod isEqualToString:@"SSH Connection"] == YES)
                {
                    [self loadNetworkDirectoryBrowserForSSHConnection:connectionDictionary];
                }

                [NSApp endSheet:createNewFolderSheet];
                [createNewFolderSheet orderOut:sender];
                
                createFolderSuccess = YES;
            }
        }
    }

    if (createFolderSuccess == NO)
    {
        NSBeep();
    }
}

//==================================================================================
//	cancelCreateNewFolder:
//==================================================================================

- (IBAction) cancelCreateNewFolder:(id)sender
{
    [NSApp endSheet:createNewFolderSheet];
    [createNewFolderSheet orderOut:sender];
}

//==================================================================================
//	createNewDirectory:withSSHConnection:
//==================================================================================

- (NSError *)createNewDirectory:(NSString *)directoryName atPath:pathString
        withSSHConnection:connectionDictionary
{
    NSError * directoryError = NULL;

    //NSString * networkAccessMethod = [self.workingConnectionDictionary objectForKey:@"connectionType"];
    NSString * oldNetworkDirectoryPath = [self.workingConnectionDictionary objectForKey:@"urlFilePath"];
    NSString * hostNameString = [self.workingConnectionDictionary objectForKey:@"hostName"];
    NSString * portNumberString = [self.workingConnectionDictionary objectForKey:@"portNumber"];
    NSString * usernameString = [self.workingConnectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [self.workingConnectionDictionary objectForKey:@"password"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];

    int portNumber = [portNumberString intValue];

    DFSSHServer *server = [[DFSSHServer alloc] init];   

    [server setSSHHost:hostAddrString port:portNumber user:usernameString key:@"" keypub:@"" password:passwordString];

    DFSSHConnector *connection = [[DFSSHConnector alloc] init];

    [connection connect:server connectionType:[DFSSHConnectionType auto]];

    if ([server connectionStatus] == YES)
    {
        NSString * newDirectoryPath = [oldNetworkDirectoryPath stringByAppendingPathComponent:directoryName];
    
        NSString * mkdirCommandString = [NSString stringWithFormat:@"mkdir %@", newDirectoryPath];
        
        NSNumber * timeoutNumber = [NSNumber numberWithDouble:60];
        NSError * sshError = NULL;
        NSString * lsDirectoryResult = [SSHCommand execCommand:mkdirCommandString
                server:server timeout:timeoutNumber sshError:&sshError];
        #pragma unused(lsDirectoryResult)
    }
    else
    {
        NSString * errorString = [NSString stringWithFormat:@"SSH connection failed to initialize."];
        directoryError = [NSError errorWithDomain:errorString code:7 userInfo:NULL];
    }
    
    return directoryError;
}

//==================================================================================
//	createNewDirectory:withSFTPConnection:
//==================================================================================

- (NSError *)createNewDirectory:(NSString *)directoryName atPath:pathString
        withSFTPConnection:connectionDictionary
{
    //NSString * networkAccessMethod = [self.workingConnectionDictionary objectForKey:@"connectionType"];
    //NSString * oldNetworkDirectoryPath = [self.workingConnectionDictionary objectForKey:@"urlFilePath"];
    NSString * hostNameString = [self.workingConnectionDictionary objectForKey:@"hostName"];
    //NSString * portNumberString = [self.workingConnectionDictionary objectForKey:@"portNumber"];
    NSString * usernameString = [self.workingConnectionDictionary objectForKey:@"userName"];
    NSString * passwordString = [self.workingConnectionDictionary objectForKey:@"password"];

    NSString * hostAddrString = [[NSHost hostWithName:hostNameString] address];

    SFTPMkdir * sftpMkdir = [[SFTPMkdir alloc] init];
    
    NSError * directoryError = [sftpMkdir execSFTPMkdir:directoryName
            hostaddr:hostAddrString
            user:usernameString password:passwordString
            sftppath:pathString];

    return directoryError;
}


@end
