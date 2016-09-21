//
//  MacSVGDocumentController.m
//  macSVG
//
//  Created by Douglas Ward on 10/2/13.
//
//

#import "MacSVGDocumentController.h"
#import "MacSVGDocument.h"
#import "TextDocument.h"
#import "MacSVGDocumentWindowController.h"

/*

// If change is made to application's Info.plist file types, exported UTIs, etc. - try this in Terminal.app -
// to unregister UTIs per https://github.com/ByteProject/Ascension/issues/6 -
// /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -u /path/to/build/products/Build/Products/Debug/macSVG.app

You can force an application to re-register file types for that application using the -f option followed by the application path. For example, to re-register Ascension (Terminal):
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -f /Applications/Ascension.app

You can also unregister a specific application using the -u option. 
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -u /Applications/Conflicting.app
You may try to unregister Ascension as well it will re-register upon next launch. Please wipe ANY conflicting apps as well.

The lsregister command is actually just a front-end management tool for the ~/Library/Preferences/com.apple.LaunchServices.plist file. The file’s contents can be read (in an unparsed form) using defaults: 
defaults read ~/Library/Preferences/com.apple.LaunchServices

The database can be a pretty fat beast over time. You can completely clean and rebuild it with the following command:
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain system -domain user

You can also set Ascension to open NFO's by doing the following:
defaults write com.apple.LaunchServices LSHandlers -array '{ LSHandlerContentType = "nfo"; LSHandlerRoleAll = "com.byteproject.ascension"; }';

// More troubleshooting advice available at -
// https://www.cocoanetics.com/2012/09/fun-with-uti/

*/

@implementation MacSVGDocumentController

//==================================================================================
//	init
//==================================================================================

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

// ================================================================

- (IBAction)openDocument:(id)sender
{
    [super openDocument:sender];
}

// ================================================================

- (NSInteger)runModalOpenPanel:(NSOpenPanel *)openPanel
                      forTypes:(NSArray<NSString *> *)types
{
    openPanel.delegate = self;
    
    // TODO: For unknown reason, this delegate method called with document types like "com.arkphone.macsvg.svg" only, which don't get resolved - and the svg file names in NSOpenPanel were dimmed gray.  Before renaming this project to macSVG, the previous project only used file name extensions like "svg".  The workaround for now is to add 'svg' and 'xhtml' to types array, to force those files to be enabled for selection.
    // FIXME: See above
    BOOL svgFound = NO;
    BOOL xhtmlFound = NO;
    
    for (NSString * aType in types)
    {
        if ([aType isEqualToString:@"svg"] == YES)
        {
            svgFound = YES;
        }
        else if ([aType isEqualToString:@"xhtml"] == YES)
        {
            xhtmlFound = YES;
        }
    }
    
    NSMutableArray * newTypesArray = [NSMutableArray arrayWithArray:types];
    
    if (svgFound == NO)
    {
        [newTypesArray addObject:@"svg"];
    }
    if (xhtmlFound == NO)
    {
        [newTypesArray addObject:@"xhtml"];
    }

    NSInteger result = [super runModalOpenPanel:openPanel forTypes:newTypesArray];
    
    return result;
}

// ================================================================

- (NSString *)displayNameForType:(NSString *)typeName
{
    // see http://www.cocoanetics.com/2012/09/fun-with-uti/
    
    NSString * result = typeName;
    
    if ([typeName isEqualToString:@"public.svg-image"])
    {
        result = @"SVG Document";
    }
    else if ([typeName isEqualToString:@"com.arkphone.macsvg.svg"])
    {
        result = @"SVG Document";
    }
    else if ([typeName isEqualToString:@"public.xhtml"])
    {
        result = @"XHTML Document";
    }
    else if ([typeName isEqualToString:@"com.arkphone.macsvg.xhtml"])
    {
        result = @"XHTML Document";
    }
    else if ([typeName isEqualToString:@"public.text"])
    {
        result = @"Text Document";
    }
    else if ([typeName isEqualToString:@"com.arkphone.macsvg.text"])
    {
        result = @"Text Document";
    }
    
	// return something usefully unique
	return result;
}

// ================================================================

- (NSString *)fileNameExtensionForType:(NSString *)typeName saveOperation:(NSSaveOperationType)saveOperation
{
    NSString * result = typeName;
    
    if ([typeName isEqualToString:@"public.svg-image"])
    {
        result = @"svg";
    }
    else if ([typeName isEqualToString:@"com.arkphone.macsvg.svg"])
    {
        result = @"svg";
    }
    else if ([typeName isEqualToString:@"public.xhtml"])
    {
        result = @"xhtml";
    }
    else if ([typeName isEqualToString:@"com.arkphone.macsvg.xhtml"])
    {
        result = @"xhtml";
    }
    else if ([typeName isEqualToString:@"public.text"])
    {
        result = @"txt";
    }
    else if ([typeName isEqualToString:@"com.arkphone.macsvg.text"])
    {
        result = @"txt";
    }
    
	return result;
}

// ================================================================

- (NSArray *)fileExtensionsFromType:(NSString *)documentTypeName
{
    NSArray * resultArray = NULL;

    if ([documentTypeName isEqualToString:@"public.svg-image"])
    {
        resultArray = [NSArray arrayWithObjects:@"svg", NULL];
    }
    else if ([documentTypeName isEqualToString:@"com.arkphone.macsvg.svg"])
    {
        resultArray = [NSArray arrayWithObjects:@"svg", NULL];
    }
    else if ([documentTypeName isEqualToString:@"public.xhtml"])
    {
        resultArray = [NSArray arrayWithObjects:@"xhtml", NULL];
    }
    else if ([documentTypeName isEqualToString:@"com.arkphone.macsvg.xhtml"])
    {
        resultArray = [NSArray arrayWithObjects:@"xhtml", NULL];
    }
    else if ([documentTypeName isEqualToString:@"public.text"])
    {
        resultArray = [NSArray arrayWithObjects:@"txt", NULL];
    }
    else if ([documentTypeName isEqualToString:@"com.arkphone.macsvg.text"])
    {
        resultArray = [NSArray arrayWithObjects:@"txt", NULL];
    }
    
	return resultArray;
}

// ================================================================

- (NSString *)defaultType
{
    return @"com.arkphone.macsvg.svg";
}

// ================================================================

- (id)makeDocumentWithContentsOfURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    id result = [super makeDocumentWithContentsOfURL:absoluteURL ofType:typeName error:outError];
    
    return result;
}

// ================================================================

- (Class)documentClassForType:(NSString *)documentTypeName
{
    //Class result = [super documentClassForType:documentTypeName];   // e.g., documentTypeName = "public.svg-image"
    
    Class result = [MacSVGDocument class]; // default result... network opens are sending 'com.arkphone.macsvg.svg'
    
    if ([documentTypeName isEqualToString:@"public.svg-image"] == YES)
    {
        result = [MacSVGDocument class];
    }
    else if ([documentTypeName isEqualToString:@"com.arkphone.macsvg.svg"])
    {
        result = [MacSVGDocument class];
    }
    else if ([documentTypeName isEqualToString:@"public.xhtml"] == YES)
    {
        result = [MacSVGDocument class];
    }
    else if ([documentTypeName isEqualToString:@"com.arkphone.macsvg.xhtml"])
    {
        result = [MacSVGDocument class];
    }
    else if ([documentTypeName isEqualToString:@"public.text"] == YES)
    {
        result = [TextDocument class];
    }
    else if ([documentTypeName isEqualToString:@"com.arkphone.macsvg.text"])
    {
        result = [TextDocument class];
    }
    
    return result;
}

// ================================================================

- (NSString *)typeForContentsOfURL:(NSURL *)inAbsoluteURL error:(NSError **)outError
{
    NSString * result = [super typeForContentsOfURL:inAbsoluteURL error:outError];
    
    return result;
}

// ================================================================

/*
// ================================================================

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url
{
    // NSOpenSavePanelDelegate method
    return YES;
}

// ================================================================

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError * _Nullable *)outError
{
    // NSOpenSavePanelDelegate method
    return YES;
}
*/

//==================================================================================
//	validateMenuItem:
//==================================================================================

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem 
{
    BOOL result = NO;

    MacSVGDocumentWindowController * frontmostMacSVGDocumentWindowController =
            [self findFrontmostMacSVGWindowController];
    
    if (frontmostMacSVGDocumentWindowController != NULL)
    {
        if ([[menuItem title] isEqualToString:@"Save As…"] == YES)
        {
            result = YES;
        }

        if ([[menuItem title] isEqualToString:@"Save"] == YES)
        {
            MacSVGDocument * macSVGDocument = [frontmostMacSVGDocumentWindowController document];
        
            if ([macSVGDocument hasUnautosavedChanges]  == YES)
            {
                result = YES;
            }
        }
        else
        {
            result = YES;
        }
    }
    else
    {
        if ([[menuItem title] isEqualToString:@"Open…"] == YES)
        {
            result = YES;
        }
        else if ([[menuItem title] isEqualToString:@"Open Recent"] == YES)
        {
            result = YES;
        }
        else
        {
            NSMenuItem * parentMenuItem = [menuItem parentItem];
            if ([[parentMenuItem title] isEqualToString:@"Open Recent"] == YES)
            {
                result = YES;
            }
        }
    }
    
    return result;
}

//==================================================================================
//	saveDocument:
//==================================================================================

- (IBAction)saveDocument:(id)sender
{
    MacSVGDocumentWindowController * frontmostMacSVGDocumentWindowController =
            [self findFrontmostMacSVGWindowController];
    
    if (frontmostMacSVGDocumentWindowController != NULL)
    {
        MacSVGDocument * macSVGDocument = [frontmostMacSVGDocumentWindowController document];
        
        [macSVGDocument saveDocument:sender];
    }
}

//==================================================================================
//	saveDocumentAs:
//==================================================================================

- (IBAction)saveDocumentAs:(id)sender
{
    MacSVGDocumentWindowController * frontmostMacSVGDocumentWindowController =
            [self findFrontmostMacSVGWindowController];
    
    if (frontmostMacSVGDocumentWindowController != NULL)
    {
        MacSVGDocument * macSVGDocument = [frontmostMacSVGDocumentWindowController document];
        
        [macSVGDocument saveDocumentAs:sender];
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


@end
