//
//  main.m
//  macSVG
//
//  Created by Douglas Ward on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/* WebKit Inspector notes -

http://alblue.bandlem.com/2013/03/nsconf-day-1.html

Daniel also showed that a WebKit based app can have developer mode enabled, by passing the -WebKitDeveloperExtras YES to XCode’s build parameters, or by using the setting defaults write -g WebKitDeveloperExtras -bool YES to turn it on for every application.

For those apps that don’t support a custom context menu on a web view, Daniel shared a tip to do this with lldb:

Attach to the target process (using lldb -n Mail)
Set a breakpoint on -[NSView menuForEvent:]
Control click in the application
Execute [[[$rdi _webView] inspector] show:0] to bring up the inspector
*/


int main(int argc, char *argv[])
{

#ifndef __OPTIMIZE__
    // Option to temporarily halt execution at applicaton launch time, to allow debugger attachment

    // ======================================================================================================\
    // ==== lldb debugging support ==========================================================================\
    // ======================================================================================================\

    NSInteger forceWaitForDebuggerAtStartup = 0;    // will halt if non-zero, change this value as needed
    
    NSEventModifierFlags modifierFlags = [NSEvent modifierFlags];   // will halt if Option key is pressed
    
    if (((modifierFlags & NSEventModifierFlagOption) | forceWaitForDebuggerAtStartup) != 0)
    {
        // When needed. next line can halt the app -
        // In Xcode select the app in Xcode menu 'Debug->Attach to Process' menu,
        // then click Resume button.  Or - set a WebBrowser.app breakpoint.
        
        // This option should be disabled in release versions
        
        raise(SIGSTOP); // debugger can be attached here, set breakpoint on this line for earliest attachment
        
        // Click the Debugger's Resume button to continue execution
    }
#endif

    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitScriptDebugger"];
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"IncludeInternalDebugMenu"];
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"IncludeDebugMenu"];
    
    //[[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"EnableHTTPServer"];
    //[[NSUserDefaults standardUserDefaults] setInteger:8080 forKey:@"HTTPServerPort"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    return NSApplicationMain(argc, (const char **)argv);
}
