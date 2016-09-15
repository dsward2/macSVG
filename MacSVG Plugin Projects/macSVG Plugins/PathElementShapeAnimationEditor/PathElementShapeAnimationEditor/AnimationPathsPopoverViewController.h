//
//  AnimationPathsPopoverViewController.h
//  PathElementShapeAnimationEditor
//
//  Created by Douglas Ward on 8/15/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@class PathElementShapeAnimationEditor;

@interface AnimationPathsPopoverViewController : NSViewController
{
    IBOutlet PathElementShapeAnimationEditor * pathElementShapeAnimationEditor;
    IBOutlet NSPopover * animationPathsPopover;
    
    IBOutlet NSTableView * eligiblePathsTableView;
    IBOutlet NSTableView * animationPathsTableView;
    
    IBOutlet WebView * eligiblePathWebView;
    IBOutlet WebView * animatePathWebView;
    IBOutlet WebView * animationPreviewWebView;
    
    IBOutlet NSButton * addPathButton;
    IBOutlet NSButton * doneButton;
    
    IBOutlet NSTextView * pathElementTextView;

    NSArray * draggedNodes;
    BOOL acceptingDrop;
}

@property(strong) NSXMLElement * originalPathElement;
@property(strong) NSXMLElement * originalAnimateElement;

@property(strong) NSXMLElement * masterPathElement;
@property(strong) NSXMLElement * masterAnimateElement;

@property(strong) NSMutableArray * eligiblePathElementsArray;
@property(strong) NSMutableArray * animationPathStringsArray;

@property(strong) NSXMLDocument * eligiblePathXMLDocument;
@property(strong) NSXMLDocument * animatePathXMLDocument;
@property(strong) NSXMLDocument * animationPreviewXMLDocument;

- (void)loadSettingsForMasterPathElement:(NSXMLElement *)masterPathElement animateElement:(NSXMLElement *)animateElement;

- (IBAction)addAnimationPathButtonAction:(id)sender;
- (IBAction)deleteAnimationPathButtonAction:(id)sender;
- (IBAction)doneButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;

@end
