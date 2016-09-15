//
//  SVGElementsTableController.h
//  macSVG
//
//  Created by Douglas Ward on 11/17/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MacSVGDocumentWindowController;

@interface SVGElementsTableController : NSObject <NSTableViewDelegate, NSTableViewDataSource, NSXMLParserDelegate>
{
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;  
    IBOutlet NSPopUpButton * elementCategoriesPopUpButton;
    
	BOOL isElementItem;
}
@property(weak) IBOutlet NSTableView * elementsTableView;
@property(strong) NSMutableArray * svgElementsArray;
@property(strong) NSMutableDictionary * svgElementsDictionary;

@property(strong) NSMutableString * currentElementName;
@property(strong) NSMutableString * recordElementName;
@property(strong) NSDictionary * currentElementAttributes;
@property(strong) NSMutableDictionary * parserRecordDictionary;

- (void)loadElementsData;
- (IBAction)elementCategoriesPopUpButtonAction:(id)sender;

@end
