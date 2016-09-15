//
//  ValidAttributesController.h
//  macSVG
//
//  Created by Douglas Ward on 1/1/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EditorUIFrameController;

@interface ValidAttributesController : NSObject <NSTableViewDelegate, NSTableViewDataSource>
{
    IBOutlet EditorUIFrameController * editorUIFrameController;
    IBOutlet NSView * validAttributesFrameView;
}

@property (weak)IBOutlet NSTableView * validAttributesTableView;

@property (strong)NSArray * attributeKeysArray;
@property (strong)NSMutableDictionary * attributesDictionary;

-(void)setEnabled:(BOOL)enabled;
-(void)setValidAttributesForElement:(NSXMLElement *)xmlElement;

@end
