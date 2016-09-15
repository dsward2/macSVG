//
//  TextDocument.h
//  macSVG
//
//  Created by Douglas Ward on 1/18/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TextDocumentWindowController;

@interface TextDocument : NSDocument
{
}

@property (strong) IBOutlet TextDocumentWindowController * textDocumentWindowController;

@end
