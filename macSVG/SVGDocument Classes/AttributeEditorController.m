//
//  AttributeEditorController.m
//  macSVG
//
//  Created by Douglas Ward on 1/1/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "AttributeEditorController.h"
#import "EditorUIFrameController.h"
#import "XMLAttributesTableController.h"
#import "XMLAttributesTableView.h"
#import "MacSVGDocumentWindowController.h"
#import "MacSVGDocument.h"

@implementation AttributeEditorController

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
}

//==================================================================================
//	reloadData
//==================================================================================

-(void)reloadData
{
    [attributeEditorTextView setRichText:NO];
    [attributeEditorTextView setContinuousSpellCheckingEnabled:NO];
    [attributeEditorTextView setGrammarCheckingEnabled:NO];

    XMLAttributesTableController * xmlAttributesTableController =
            editorUIFrameController.macSVGDocumentWindowController.xmlAttributesTableController;
    
    XMLAttributesTableView * xmlAttributesTableView = xmlAttributesTableController.xmlAttributesTableView;
    
    [xmlAttributesTableView abortEditing];
    
    NSInteger selectedRow = xmlAttributesTableView.selectedRow;
    
    if (selectedRow != -1)
    {
        NSArray * xmlAttributesArray = xmlAttributesTableController.xmlAttributesArray;
    
        NSMutableDictionary * attributeDictionary = xmlAttributesArray[selectedRow];
        
        NSString * attributeName = attributeDictionary[@"name"];
        NSString * attributeValue = attributeDictionary[@"value"];
        #pragma unused(attributeName)

        NSString * attributeKind = attributeDictionary[@"kind"];
        #pragma unused(attributeKind)

        attributeEditorTextView.string = attributeValue;
    }
    else
    {
        attributeEditorTextView.string = @"";
    }
}

//==================================================================================
//	setEnabled
//==================================================================================

-(void)setEnabled:(BOOL)enabled
{
    if (enabled == YES)
    {
        if (attributeEditorView.superview == NULL) 
        {
            NSView * attributeEditorFrameView = editorUIFrameController.editorPanelFrameView;
            NSRect frameRect = attributeEditorFrameView.frame;
            attributeEditorView.frame = frameRect;
            attributeEditorView.bounds = frameRect;
        
            [attributeEditorFrameView addSubview:attributeEditorView];
            
            [self reloadData];
        }
    }
    else
    {
        [attributeEditorView removeFromSuperview];
    }
}

//==================================================================================
//	saveChangesButtonAction
//==================================================================================

- (IBAction)saveChangesButtonAction:(id)sender
{
    MacSVGDocumentWindowController * macSVGDocumentWindowController =
            editorUIFrameController.macSVGDocumentWindowController;

    if (macSVGDocumentWindowController != NULL)
    {
        XMLAttributesTableController * xmlAttributesTableController =
                macSVGDocumentWindowController.xmlAttributesTableController;
                
        if (xmlAttributesTableController != NULL)
        {
            XMLAttributesTableView * xmlAttributesTableView = xmlAttributesTableController.xmlAttributesTableView;
            
            NSInteger selectedRow = xmlAttributesTableView.selectedRow;
            
            if (selectedRow != -1)
            {
                NSArray * xmlAttributesArray = xmlAttributesTableController.xmlAttributesArray;
            
                NSMutableDictionary * attributeDictionary = xmlAttributesArray[selectedRow];
                
                NSString * attributeName = attributeDictionary[@"name"];
                NSString * attributeValue = attributeDictionary[@"value"];
                #pragma unused(attributeValue)
                NSString * attributeKind = attributeDictionary[@"kind"];
                #pragma unused(attributeKind)

                NSXMLElement * xmlElementForAttributes = 
                        [xmlAttributesTableController xmlElementForAttributesTable];
                
                if (xmlElementForAttributes != NULL)
                {
                    NSString * newAttributeValue = attributeEditorTextView.string;
                    
                    NSXMLNode * attributeNode = [xmlElementForAttributes attributeForName:attributeName];
                    
                    attributeNode.stringValue = newAttributeValue;
                    
                    [macSVGDocumentWindowController reloadAllViews];
                }
            }
        }
    }
}

//==================================================================================
//	revertButtonAction
//==================================================================================

- (IBAction)revertButtonAction:(id)sender
{
    [self reloadData];
}


@end
