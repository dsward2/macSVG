//
//  XMLAttributesTableController.h
//  macSVG
//
//  Created by Douglas Ward on 9/20/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MacSVGDocumentWindowController;
@class XMLAttributesTableView;

@interface XMLAttributesTableController : NSObject <NSTableViewDelegate, NSTableViewDataSource>
{
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;
}

@property (weak) IBOutlet XMLAttributesTableView * xmlAttributesTableView;

@property (strong) NSMutableArray * xmlAttributesArray;

- (void)reloadView;
- (void)reloadData;

- (IBAction)addAttributeAction:(id)sender;
- (IBAction)deleteAttributeAction:(id)sender;

- (void)buildAttributesTableForElement;

- (NSXMLElement *)xmlElementForAttributesTable;
- (void)setXmlElementForAttributesTable:(NSXMLElement *)selectedElement;
- (void)unsetXmlElementForAttributesTable;

@end
