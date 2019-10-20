//
//  ValidAttributesController.m
//  macSVG
//
//  Created by Douglas Ward on 1/1/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "ValidAttributesController.h"
#import "MacSVGAppDelegate.h"
#import "SVGDTDData.h"
#import "EditorUIFrameController.h"

@implementation ValidAttributesController

/*
Printing description of aAttributeDictionary:
{
    "attribute_name" = "alignment-baseline";
    "attribute_type" =     (
        auto,
        baseline,
        "before-edge",
        "text-before-edge",
        middle,
        central,
        "after-edge",
        "text-after-edge",
        ideographic,
        alphabetic,
        hanging,
        mathematical,
        inherit
    );
    "default_value" =     (
        "#IMPLIED"
    );
    description = NSXMLAttributeEnumerationKind;
    "element_name" = line;
    xml = "<!ATTLIST line alignment-baseline (auto|baseline|before-edge|text-before-edge|middle|central|after-edge|text-after-edge|ideographic|alphabetic|hanging|mathematical|inherit) #IMPLIED>";
}
*/

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.attributeKeysArray = NULL;
    self.attributesDictionary = NULL;
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
        self.attributesDictionary = NULL;
        self.attributeKeysArray = NULL;
    }
    return self;
}

//==================================================================================
//	setEnabled:
//==================================================================================

-(void)setEnabled:(BOOL)enabled
{
    if (enabled == YES)
    {
        if (validAttributesFrameView.superview == NULL) 
        {
            NSView * attributeEditorFrameView = editorUIFrameController.editorPanelFrameView;
            NSRect frameRect = attributeEditorFrameView.frame;
            validAttributesFrameView.frame = frameRect;
            validAttributesFrameView.bounds = frameRect;
        
            [attributeEditorFrameView addSubview:validAttributesFrameView];
        }
    }
    else
    {
        [validAttributesFrameView removeFromSuperview];
    }
}

//==================================================================================
//	attributesSort()
//==================================================================================

NSComparisonResult attributesSort(id attribute1, id attribute2, void *context)
{
    return [attribute1 compare:attribute2];
}

//==================================================================================
//	setValidAttributesForElement:
//==================================================================================

-(void)setValidAttributesForElement:(NSXMLElement *)xmlElement
{
    if (xmlElement == NULL)
    {
        self.attributesDictionary = NULL;
        self.attributeKeysArray = NULL;
    }
    else
    {
        MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)NSApp.delegate;
        SVGDTDData * svgDtdData = macSVGAppDelegate.svgDtdData;
        NSDictionary * elementsDictionary = svgDtdData.elementsDictionary;
            
        if (elementsDictionary != NULL)
        {
            NSString * elementTagName = xmlElement.name;
            
            NSDictionary * aElementDictionary = elementsDictionary[elementTagName];
            if (aElementDictionary != NULL)
            {
                NSMutableDictionary * aAttributesDictionary = aElementDictionary[@"attributes"];
                
                //NSLog(@"aAttributesDictionary = %@", aAttributesDictionary);
                
                NSArray * allKeys = aAttributesDictionary.allKeys;

                NSArray * sortedArray = [allKeys sortedArrayUsingFunction:attributesSort context:NULL];
                
                self.attributesDictionary = aAttributesDictionary;
                self.attributeKeysArray = sortedArray;
            }
            else
            {
                //NSLog(@"setValidAttributesForElement error - attributes not found for element %@", xmlElement);
            }
        }
        else
        {
            //NSLog(@"setValidAttributesForElement error - element not found %@", xmlElement);
        }
    }
    
    [self.validAttributesTableView reloadData];
}

//==================================================================================
//	tableView:heightOfRow:
//==================================================================================

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 14.0f;
}

//==================================================================================
//	numberOfRowsInTableView:
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSUInteger rowCount = 0;
    if (self.attributeKeysArray != NULL)
    {
        rowCount = (self.attributeKeysArray).count;
    }
    return rowCount;
}

//==================================================================================
//	stringFromArray:
//==================================================================================

- (NSString *)stringFromArray:(NSArray *)aArray
{
    NSMutableString * resultString = [NSMutableString string];
    
    for (NSString * aString in aArray)
    {
        if (resultString.length > 0)
        {
            [resultString appendString:@", "];
        }
        [resultString appendString:aString];
    }
    
    return resultString;
}

//==================================================================================
//    tableView:viewForTableColumn:row:
//==================================================================================

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString * tableColumnIdentifier = tableColumn.identifier;
    
    NSTableCellView * tableCellView = (NSTableCellView *)[tableView makeViewWithIdentifier:tableColumnIdentifier owner:self];

    NSString * resultString = @"";

    if (tableCellView != NULL)
    {
        resultString = [self tableView:tableView objectValueForTableColumn:tableColumn row:row];
    }
    
    tableCellView.textField.stringValue = resultString;
    
    return (NSView *)tableCellView;
}

//==================================================================================
//	tableView:objectValueForTableColumn:rowIndex:
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    id objectValue = NULL;
    
    if (rowIndex < self.attributeKeysArray.count)
    {
        NSString * keyString = (self.attributeKeysArray)[rowIndex];
        
        NSMutableDictionary * aAttributeDictionary = (self.attributesDictionary)[keyString];
        
        if (aAttributeDictionary != NULL)
        {
            if ([aTableColumn.identifier isEqualToString:@"AttributeColumn"] == YES)
            {
                NSString * attributeName = aAttributeDictionary[@"attribute_name"];
                objectValue = attributeName;
            }
            else if ([aTableColumn.identifier isEqualToString:@"DefaultColumn"] == YES)
            {
                NSArray * default_valueArray = aAttributeDictionary[@"default_value"];
                NSString * default_valueStringOriginal = [self stringFromArray:default_valueArray];
                
                NSMutableString * default_valueString = [NSMutableString stringWithString:default_valueStringOriginal];
                
                NSRange stringRange;
                stringRange.location = 0; 
                stringRange.length = default_valueString.length;
                [default_valueString replaceOccurrencesOfString:@"#IMPLIED" withString:@"" options:0 range:stringRange];
                stringRange.length = default_valueString.length;
                [default_valueString replaceOccurrencesOfString:@"#REQUIRED" withString:@"" options:0 range:stringRange];
                stringRange.length = default_valueString.length;
                [default_valueString replaceOccurrencesOfString:@"#FIXED, " withString:@"" options:0 range:stringRange];
                
                objectValue = default_valueString;
            }
            else if ([aTableColumn.identifier isEqualToString:@"ValuesColumn"] == YES)
            {
                NSArray * attribute_typeArray = aAttributeDictionary[@"attribute_type"];
                
                NSString * attribute_typeString = [self stringFromArray:attribute_typeArray];
                
                if ([attribute_typeString isEqualToString:@"CDATA"] == YES)
                {
                    attribute_typeString = @"";
                }
                
                objectValue = attribute_typeString;
            }
            else if ([aTableColumn.identifier isEqualToString:@"DescriptionColumn"] == YES)
            {
                NSString * descriptionOriginal = aAttributeDictionary[@"description"];
                
                NSString * description = @"Unknown";
                
                if ([descriptionOriginal isEqualToString:@"NSXMLAttributeCDATAKind"] == YES) 
                {
                    description = @"CDATA";
                }
                else if ([descriptionOriginal isEqualToString:@"NSXMLAttributeIDKind"] == YES) 
                {
                    description = @"ID";
                }
                else if ([descriptionOriginal isEqualToString:@"NSXMLAttributeIDRefKind"] == YES) 
                {
                    description = @"ID Ref";
                }
                else if ([descriptionOriginal isEqualToString:@"NSXMLAttributeIDRefsKind"] == YES) 
                {
                    description = @"ID Refs";
                }
                else if ([descriptionOriginal isEqualToString:@"NSXMLAttributeEntityKind"] == YES) 
                {
                    description = @"Entity";
                }
                else if ([descriptionOriginal isEqualToString:@"NSXMLAttributeEntitiesKind"] == YES) 
                {
                    description = @"Entities";
                }
                else if ([descriptionOriginal isEqualToString:@"NSXMLAttributeNMTokenKind"] == YES) 
                {
                    description = @"NM Token";
                }
                else if ([descriptionOriginal isEqualToString:@"NSXMLAttributeNMTokensKind"] == YES) 
                {
                    description = @"NM Tokens";
                }
                else if ([descriptionOriginal isEqualToString:@"NSXMLAttributeEnumerationKind"] == YES) 
                {
                    description = @"Enumeration";
                }
                else if ([descriptionOriginal isEqualToString:@"NSXMLAttributeNotationKind"] == YES) 
                {
                    description = @"Notation";
                }
                
                objectValue = description;
            }
        } 
    }
    return objectValue;
}




@end
