//
//  TextDocumentWindowController.h
//  macSVG
//
//  Created by Douglas Ward on 1/18/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TextDocumentWindowController : NSWindowController <NSTextDelegate, NSTextViewDelegate>
{
}
@property(strong) IBOutlet NSTextView * documentTextView;   // compiler says NSTextView doesn't support weak references

@end
