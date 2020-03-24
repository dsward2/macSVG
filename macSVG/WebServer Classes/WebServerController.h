//
//  AppController.h
//  Web2PDF Server
//
//  Created by Jürgen on 13.09.06.
//  Copyright 2006 Cultured Code.
//  License: Creative Commons Attribution 2.5 License
//           http://creativecommons.org/licenses/by/2.5/
//

#import <Cocoa/Cocoa.h>

@class GCDWebServer;

@interface WebServerController : NSObject 
{
}

@property(strong) GCDWebServer * httpServer;
@property(assign) NSUInteger webServerPort;

- (void)startProcessing;
- (void)stopProcessing;

@end
