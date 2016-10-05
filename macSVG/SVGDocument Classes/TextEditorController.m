//
//  TextEditorController.m
//  macSVG
//
//  Created by Douglas Ward on 1/1/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "TextEditorController.h"
#import "EditorUIFrameController.h"
#import "XMLAttributesTableController.h"
#import "MacSVGDocumentWindowController.h"
#import "MacSVGDocument.h"



@implementation TextEditorController


-(void)reloadData
{
    [textEditorTextView setRichText:NO];
    [textEditorTextView setContinuousSpellCheckingEnabled:NO];
    [textEditorTextView setGrammarCheckingEnabled:NO];
    
    [textEditorTextView setSmartInsertDeleteEnabled:NO];
    [textEditorTextView setAutomaticQuoteSubstitutionEnabled:NO];
    [textEditorTextView setAutomaticLinkDetectionEnabled:NO];
    [textEditorTextView setAutomaticDashSubstitutionEnabled:NO];
    [textEditorTextView setAutomaticDataDetectionEnabled:NO];
    [textEditorTextView setAutomaticSpellingCorrectionEnabled:NO];
    [textEditorTextView setAutomaticTextReplacementEnabled:NO];

    MacSVGDocumentWindowController * macSVGDocumentWindowController =
            editorUIFrameController.macSVGDocumentWindowController;

    BOOL textContentFound = NO;

    if (macSVGDocumentWindowController != NULL)
    {
        XMLAttributesTableController * xmlAttributesTableController =
                macSVGDocumentWindowController.xmlAttributesTableController;
        if (xmlAttributesTableController != NULL)
        {
            NSXMLElement * xmlElementForAttributes = 
                    xmlAttributesTableController.xmlElementForAttributesTable;

            if (xmlElementForAttributes != NULL)
            {
                //NSString * textContentString = [xmlElementForAttributes stringValue];
                //[textEditorTextView setString:textContentString];
                
                NSMutableString * textString = [[NSMutableString alloc] init];
                
                NSArray * childrenArray = xmlElementForAttributes.children;
                for (NSXMLNode * childNode in childrenArray)
                {
                    NSXMLNodeKind nodeKind = childNode.kind;
                    
                    switch (nodeKind) 
                    {
                        case NSXMLInvalidKind:
                            break;

                        case NSXMLDocumentKind:
                            break;

                        case NSXMLElementKind:
                            break;

                        case NSXMLAttributeKind:
                            break;

                        case NSXMLNamespaceKind:
                            break;

                        case NSXMLProcessingInstructionKind:
                            break;

                        case NSXMLCommentKind:
                        {
                            NSString * nodeString = childNode.stringValue;
                            [textString appendString:nodeString];
                            break;
                        }
                        case NSXMLTextKind:
                        {
                            NSString * nodeString = childNode.stringValue;
                            [textString appendString:nodeString];
                            break;
                        }
                        case NSXMLDTDKind:
                            break;

                        case NSXMLEntityDeclarationKind:
                            break;

                        case NSXMLAttributeDeclarationKind:
                            break;

                        case NSXMLElementDeclarationKind:
                            break;

                        case NSXMLNotationDeclarationKind:
                            break;

                        default:
                            break;
                    }
                }
                
                //[textEditorTextView setString:textString];
                
                NSAttributedString * attributedTextString = [[NSAttributedString alloc] initWithString:textString];
                
                NSTextStorage *storage = textEditorTextView.textStorage;
                [storage beginEditing];
                [storage setAttributedString:attributedTextString];
                [storage endEditing];
                
                textContentFound = YES;
            }
        }
    }
    
    if (textContentFound == NO)
    {
        textEditorTextView.string = @"";
    }
}


-(void)setEnabled:(BOOL)enabled
{
    if (enabled == YES)
    {
        if (textEditorView.superview == NULL) 
        {
            NSView * attributeEditorFrameView = editorUIFrameController.editorPanelFrameView;
            NSRect frameRect = attributeEditorFrameView.frame;
            textEditorView.frame = frameRect;
            textEditorView.bounds = frameRect;
            
            textEditorTextView.textStorage.font = [NSFont fontWithName:@"Courier" size:11];
        
            [attributeEditorFrameView addSubview:textEditorView];
            
            [self reloadData];
        }
    }
    else
    {
        [textEditorView removeFromSuperview];
    }
}



- (IBAction)saveChangesButtonAction:(id)sender
{
    // remove existing text nodes
    MacSVGDocumentWindowController * macSVGDocumentWindowController =
            editorUIFrameController.macSVGDocumentWindowController;

    if (macSVGDocumentWindowController != NULL)
    {
        XMLAttributesTableController * xmlAttributesTableController =
                macSVGDocumentWindowController.xmlAttributesTableController;
        if (xmlAttributesTableController != NULL)
        {
            NSXMLElement * xmlElementForAttributes =
                xmlAttributesTableController.xmlElementForAttributesTable;

            if (xmlElementForAttributes != NULL)
            {
                NSArray * childrenArray = xmlElementForAttributes.children;
                for (NSXMLNode * childNode in childrenArray)
                {
                    NSXMLNodeKind nodeKind = childNode.kind;
                    
                    switch (nodeKind) 
                    {
                        case NSXMLInvalidKind:
                            break;

                        case NSXMLDocumentKind:
                            break;

                        case NSXMLElementKind:
                            break;

                        case NSXMLAttributeKind:
                            break;

                        case NSXMLNamespaceKind:
                            break;

                        case NSXMLProcessingInstructionKind:
                            break;

                        case NSXMLCommentKind:
                            break;

                        case NSXMLTextKind:
                        {
                            [childNode detach];
                            break;
                        }
                        case NSXMLDTDKind:
                            break;

                        case NSXMLEntityDeclarationKind:
                            break;

                        case NSXMLAttributeDeclarationKind:
                            break;

                        case NSXMLElementDeclarationKind:
                            break;

                        case NSXMLNotationDeclarationKind:
                            break;

                        default:
                            break;
                    }
                }
                
                NSString * elementName = xmlElementForAttributes.name;
                
                if (([elementName isEqualToString:@"script"]) || ([elementName isEqualToString:@"style"]))
                {
                    NSString * newStringValue = textEditorTextView.string;
                    
                    NSXMLNode * cdataNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind  options:NSXMLNodeIsCDATA];
                    
                    cdataNode.stringValue = newStringValue;
                    
                    xmlElementForAttributes.stringValue = @"";
                    
                    [xmlElementForAttributes addChild:cdataNode];
                }
                else
                {
                    NSString * newStringValue = textEditorTextView.string;
                    
                    NSXMLNode * newTextNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind];
                    
                    newTextNode.stringValue = newStringValue;
                    
                    [xmlElementForAttributes addChild:newTextNode];

                    [xmlElementForAttributes normalizeAdjacentTextNodesPreservingCDATA:YES];
                }

                
                [macSVGDocumentWindowController reloadAllViews];
            }
        }
    }
}


- (IBAction)revertButtonAction:(id)sender
{
    [self reloadData];
}



@end
