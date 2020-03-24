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

#import "GCDWebServer.h"
#import "GCDWebServerDataRequest.h"
#import "GCDWebServerDataResponse.h"


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
        
        // Tell the server to broadcast its presence via Bonjour.
        // This allows browsers such as Safari to automatically discover our service.
        //[httpServer setType:@"_http._tcp."];
                
        // Serve files from our embedded Web folder
        //NSString * webPath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"Web"];
        
        //[self.httpServer setDocumentRoot:webPath];
        
        // Start the server (and check for problems)
        self.httpServer = [[GCDWebServer alloc] init];
        
        __weak WebServerController * weakSelf = self;

        // Add a handler to respond to GET requests on any URL
        [self.httpServer addDefaultHandlerForMethod:@"GET"
                                  requestClass:[GCDWebServerDataRequest class]
                                  processBlock:^GCDWebServerDataResponse *(GCDWebServerRequest* request) {
          
          return [GCDWebServerDataResponse responseWithData:[weakSelf svgData] contentType:@"image/svg+xml"];
          
        }];

        BOOL success = [self.httpServer startWithPort:self.webServerPort bonjourName:NULL];

        if(success == YES)
        {
            NSLog(@"Web server running at %@", self.httpServer.serverURL);
        }
        else
        {
            NSLog(@"Error starting HTTP Server");
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

//==================================================================================
//    svgData
//==================================================================================

- (NSData *)svgData
{
    // FIXME TODO response header needs Content-Type image/svg+xml

    MacSVGDocument * macSVGDocument = [self findFrontmostMacSVGDocument];

    NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;
        
    NSData * svgData = svgXmlDocument.XMLData;
        
    return svgData;
}


//==================================================================================
//    findFrontmostMacSVGDocument
//==================================================================================

- (MacSVGDocument *)findFrontmostMacSVGDocument
{
    __block MacSVGDocument * result = NULL;

    dispatch_sync(dispatch_get_main_queue(), ^{
        NSArray *orderedDocuments = NSApp.orderedDocuments;
            NSUInteger documentCount = orderedDocuments.count;
            int i;
            for (i = 0; i < documentCount; i++)
            {
                if (result == NULL)
                {
                    NSDocument *aDocument = (NSDocument *)orderedDocuments[i];
                    if ([aDocument isMemberOfClass:[MacSVGDocument class]] == YES)
                    {
                        result = (MacSVGDocument *)aDocument;
                    }
                }
            }
    });

    return result;
}


@end
