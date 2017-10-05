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

@interface XMLAttributesTableController : NSObject <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, NSControlTextEditingDelegate>
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

@property (copy) NSXMLElement *xmlElementForAttributesTable;
- (void)unsetXmlElementForAttributesTable;

- (NSString *)selectedAttributeName;
- (void)selectAttributeWithName:(NSString *)attributeName;

- (void)removeAllTableRows;

@end
