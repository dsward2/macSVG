//
//  WebServerController.m
//  Web2PDF Server
//
//  Created by Jürgen on 13.09.06.
//  Copyright 2006 Cultured Code.
//  License: Creative Commons Attribution 2.5 License
//           http://creativecommons.org/licenses/by/2.5/
//

#import "WebServerController.h"
#import <WebKit/WebKit.h>
#import "MacSVGDocumentWindowController.h"
#import "MacSVGDocument.h"

// CocoaHTTPServer
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPLogging.h"
#import "SVGHTTPConnection.h"


// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;


@interface WebServerController (PrivateMethods)
@property (readonly, copy) NSString *applicationSupportFolder;
@end

@implementation WebServerController

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    if (self.httpServer != NULL)
    {
        [self stopProcessing];
    }
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self startProcessing];
    }
    return self;
}

//==================================================================================
//	startProcessing
//==================================================================================

- (void)startProcessing
{
    if (self.httpServer == NULL)
    {
        NSInteger httpServerPort = [[NSUserDefaults standardUserDefaults] integerForKey:@"HTTPServerPort"];
        if (httpServerPort <= 0)
        {
            httpServerPort = 8080;
        }
        self.webServerPort = httpServerPort;

        // For CocoaHTTPServer
        // Configure our logging framework.
        // To keep things simple and fast, we're just going to log to the Xcode console.
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        // Initalize our http server
        self.httpServer = [[HTTPServer alloc] init];
        
        // Tell server to use our custom SVGHTTPConnection class.
        [self.httpServer setConnectionClass:[SVGHTTPConnection class]];
        
        // Tell the server to broadcast its presence via Bonjour.
        // This allows browsers such as Safari to automatically discover our service.
        //[httpServer setType:@"_http._tcp."];
        
        // Normally there's no need to run our server on any specific port.
        // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
        // However, for easy testing you may want force a certain port so you can just hit the refresh button.
        [self.httpServer setPort:self.webServerPort];
        
        // Serve files from our embedded Web folder
        NSString * webPath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"Web"];
        //DDLogVerbose(@"Setting document root: %@", webPath);
        
        [self.httpServer setDocumentRoot:webPath];
        
        // Start the server (and check for problems)
        
        NSError *error;
        BOOL success = [self.httpServer start:&error];
        
        if(!success)
        {
            DDLogError(@"Error starting HTTP Server: %@", error);
        }
    }
}

//==================================================================================
//	stopProcessing
//==================================================================================

- (void)stopProcessing
{
    [self.httpServer stop];
    
    self.httpServer = NULL;
}

@end
