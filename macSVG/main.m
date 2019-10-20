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
        
        raise(SIGSTOP); // debugger can attach to this process here, set breakpoint on this line for earliest attachment
        
        // Then click the Debugger's Resume button to continue execution
        
        // More LLDB Debugger breakpoint tips: https://stackoverflow.com/questions/9275195/how-to-automatically-set-breakpoints-on-all-methods-in-xcode

        /*
        There is many possibilities but there is no way to set breakpoints only to your functions. You can try:

        breakpoint set -r '\[ClassName .*\]$'

        to add breakpoints to all methods in class

        breakpoint set -f file.m -p ' *- *\('

        to add breakpoints to all methods in file

        You can also use it with many files:

        breakpoint set -f file1.m -f file2.m -p ' *- *\('

        Shortcut:

        br se -f file1.m -f file2.m -p ' *- *\('

        You can add breakpoints to all methods in all classes with some prefix (and it could me only your classes)

        br se -r . -s Prefix

        This line (wzbozon answer):

        breakpoint set -n viewDidLoad

        will set breakpoints on all methods viewDidLoad in all classes.

        I tried but I couldn't set breakpoints only on our own methods.
        */
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
