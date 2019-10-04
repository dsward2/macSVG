//
//  SVGHTTPConnection.m
//  macSVG
//
//  Created by Douglas Ward on 7/4/13.
//
//

#import "SVGHTTPConnection.h"
#import "HTTPDataResponse.h"
#import "HTTPMessage.h"
#import "HTTPLogging.h"
#import "SVGHTTPResponse.h"

#import <WebKit/WebKit.h>
#import "MacSVGDocumentWindowController.h"
#import "MacSVGDocument.h"

//static const int httpLogLevel = HTTP_LOG_LEVEL_WARN;

@implementation SVGHTTPConnection

//==================================================================================
//	httpResponseForMethod:URI:
//==================================================================================

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    // FIXME TODO response header needs Content-Type image/svg+xml

    MacSVGDocument * macSVGDocument = [self findFrontmostMacSVGDocument];

    NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;
        
    NSData * svgData = svgXmlDocument.XMLData;
    
    //HTTPDataResponse * httpDataResponse = [[HTTPDataResponse alloc] initWithData:svgData];
	//[httpDataResponse setHeaderField:@"Content-Type" value:@"image/svg+xml"];

    SVGHTTPResponse * svgHTTPResponse = [[SVGHTTPResponse alloc] initWithData:svgData];
	
    return svgHTTPResponse;
}

//==================================================================================
//	findFrontmostMacSVGDocument
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
