//
//  SelectedElementsInfoPopoverViewController.h
//  macSVG
//
//  Created by Douglas Ward on 8/31/16.
//
//

#import <Cocoa/Cocoa.h>
#import "MacSVGDocumentWindowController.h"

@interface SelectedElementsInfoPopoverViewController : NSViewController
{
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;
    
    IBOutlet NSTextField * selectedElementsCountTextField;
    IBOutlet NSTextField * topTextField;
    IBOutlet NSTextField * bottomTextField;
    IBOutlet NSTextField * leftTextField;
    IBOutlet NSTextField * rightTextField;
    IBOutlet NSTextField * widthTextField;
    IBOutlet NSTextField * heightTextField;
    IBOutlet NSTextField * centerXTextField;
    IBOutlet NSTextField * centerYTextField;
}

@end
