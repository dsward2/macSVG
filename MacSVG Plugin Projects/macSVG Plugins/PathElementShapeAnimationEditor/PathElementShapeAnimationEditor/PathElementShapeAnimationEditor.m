//
//  PathElementShapeAnimationEditor.m
//  PathElementShapeAnimationEditor
//
//  Created by Douglas Ward on 8/14/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "PathElementShapeAnimationEditor.h"
#import "AnimatePopoverViewController.h"
#import "AnimationPathsPopoverViewController.h"
#import "MacSVGPlugin/MacSVGPluginCallbacks.h"

@implementation PathElementShapeAnimationEditor


//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
}

//==================================================================================
//	init
//==================================================================================

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//==================================================================================
//	awakeFromNib
//==================================================================================

- (void)awakeFromNib
{
    [super awakeFromNib];
}

//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    return @"Path Element Shape Animation Editor";
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element tag name
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    NSString * result = NULL;
    if ([elementName isEqualToString:@"path"] == YES)
    {
        result = [self pluginName];
    }
    else if ([elementName isEqualToString:@"animate"] == YES)
    {
        if (aElement != NULL)
        {
            NSXMLElement * parentElement = (NSXMLElement *)[aElement parent];
            NSString * parentElementName = [parentElement name];
            if ([parentElementName isEqualToString:@"path"] == YES)
            {
                result = [self pluginName];
            }
        }
    }
    return result;
}

//==================================================================================
//	isEditorForElement:elementName:attribute:
//==================================================================================

// return label if this editor can edit specified element and attribute
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName attribute:(NSString *)attributeName
{
    return NULL;
}

//==================================================================================
//	editorPriority:context:
//==================================================================================

- (NSInteger)editorPriority:(NSXMLElement *)targetElement context:(NSString *)context
{
    NSInteger result = 10;
    
    NSString * targetElementName = [targetElement name];
    
    if ([targetElementName isEqualToString:@"path"] == YES)
    {
        NSArray * animateElementsArray = [targetElement elementsForName:@"animate"];
        
        for (NSXMLElement * aAnimateElement in animateElementsArray)
        {
            NSXMLNode * animateAttributeNameNode = [aAnimateElement attributeForName:@"attributeName"];
            if (animateAttributeNameNode != NULL)
            {
                NSString * animateAttributeNameString = [animateAttributeNameNode stringValue];
                
                if ([animateAttributeNameString isEqualToString:@"d"] == YES)
                {
                    // animate element for path shape found
                    result = 40;
                }
            }
        }
    }
    
    return result;
}

//==================================================================================
//	loadPluginViewInScrollView:
//==================================================================================

- (BOOL)loadPluginViewInScrollView:(NSScrollView *)scrollView
{
    BOOL result = [super loadPluginViewInScrollView:scrollView];
        
    return result;
}

//==================================================================================
//	beginEditForXMLElement:domElement:
//==================================================================================

- (BOOL)beginEditForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetDOMElement
{
    BOOL result = [super beginEditForXMLElement:newPluginTargetXMLElement
            domElement:newPluginTargetDOMElement];

    [self loadSettingsForElement];

    [self enableButtons];
    
    return result;
}

//==================================================================================
//	loadSettingsForElement
//==================================================================================

- (void) loadSettingsForElement
{
    [animateElementsTableView reloadData];
}

//==================================================================================
//	updateElement
//==================================================================================

- (void)updateElement
{
    [self updateDocumentViews];
}

//==================================================================================
//	addAnimateElementButtonAction:
//==================================================================================

- (IBAction)addAnimateElementButtonAction:(id)sender
{
    NSButton *targetButton = (NSButton *)sender;
    
    // configure the preferred position of the popover
    [animatePopover showRelativeToRect:[targetButton bounds] ofView:sender preferredEdge:NSMaxYEdge];

    [animatePopoverViewController loadSettingsForNewAnimateElement];
}

//==================================================================================
//	editAnimateElementButtonAction:
//==================================================================================

- (IBAction)editAnimateElementButtonAction:(id)sender
{
    NSButton *targetButton = (NSButton *)sender;
    
    // configure the preferred position of the popover
    [animatePopover showRelativeToRect:[targetButton bounds] ofView:sender preferredEdge:NSMaxYEdge];
    
    NSInteger selectedAnimateElementIndex = [animateElementsTableView selectedRow];
    
    NSXMLElement * animateElement = [self animateElementAtCount:selectedAnimateElementIndex];
    
    [animatePopoverViewController loadSettingsForAnimateElement:animateElement];
}

//==================================================================================
//	deleteAnimateElementButtonAction:
//==================================================================================

- (IBAction)deleteAnimateElementButtonAction:(id)sender
{
}

//==================================================================================
//	manageAnimationPathButtonAction:
//==================================================================================

- (IBAction)manageAnimationPathButtonAction:(id)sender
{
    NSInteger selectedRow = [animateElementsTableView selectedRow];
    
    if (selectedRow != -1)
    {
        NSXMLElement * animateElement = [self animateElementAtCount:selectedRow];
        
        if (animateElement != NULL)
        {
            NSXMLElement * targetElement = self.pluginTargetXMLElement;
            NSString * targetName = [self.pluginTargetXMLElement name];
            if ([targetName isEqualToString:@"animate"] == YES)
            {
                NSXMLNode * parentNode = [self.pluginTargetXMLElement parent];
                if ([parentNode kind] == NSXMLElementKind)
                {
                    NSXMLElement * parentElement = (NSXMLElement *)parentNode;
                    NSString * parentName = [parentElement name];
                    if ([parentName isEqualToString:@"path"] == YES)
                    {
                        targetElement = (NSXMLElement *)[self.pluginTargetXMLElement parent];
                    }
                    else
                    {
                        targetElement = NULL;
                    }
                }
            }
        
            if (targetElement != NULL)
            {
                //[animationPathsPopoverViewController loadSettingsForMasterPathElement:self.pluginTargetXMLElement animateElement:animateElement];
                [animationPathsPopoverViewController loadSettingsForMasterPathElement:targetElement animateElement:animateElement];
                
                // configure the preferred position of the popover
                NSButton * targetButton = (NSButton *)sender;
                [animationPathsPopover showRelativeToRect:[targetButton bounds] ofView:sender preferredEdge:NSMaxYEdge];
            }
            else
            {
                NSBeep();
            }
        }
    }
}

//==================================================================================
//	setAttributesWithDictionary:
//==================================================================================

- (void) setAttributesWithDictionary:(NSMutableDictionary *)animateAttributesDictionary
{
    NSInteger selectedAnimateElementIndex = [animateElementsTableView selectedRow];
    
    NSXMLElement * animateElement = [self animateElementAtCount:selectedAnimateElementIndex];

    NSArray * allKeys = [animateAttributesDictionary allKeys];
    
    for (NSString * aKey in allKeys)
    {
        NSString * aValue = [animateAttributesDictionary objectForKey:aKey];
        
        if ([aValue length] == 0)
        {
            // if attribute value is empty, remove attribute
            [animateElement removeAttributeForName:aKey];
        }
        else
        {
            NSXMLNode * attributeNode = [animateElement attributeForName:aKey];
            
            if (attributeNode == NULL)
            {
                attributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                [attributeNode setName:aKey];
                [attributeNode setStringValue:aValue];
                [animateElement addAttribute:attributeNode];
            }
            else
            {
                [attributeNode setStringValue:aValue];
            }
        }
    }
    
    [self updateDocumentViews];
}

//==================================================================================
//	countAnimateElements
//==================================================================================

- (NSInteger)countAnimateElements
{
    NSInteger result = 0;
    
    //NSArray * childArray = [self.pluginTargetXMLElement children];

    /*
    NSXMLElement * targetElement = self.pluginTargetXMLElement;
    NSString * targetName = [self.pluginTargetXMLElement name];
    if ([targetName isEqualToString:@"animate"] == YES)
    {
        targetElement = [self.pluginTargetXMLElement parent];
    }
    */


    NSXMLElement * targetElement = self.pluginTargetXMLElement;
    NSString * targetName = [self.pluginTargetXMLElement name];
    if ([targetName isEqualToString:@"animate"] == YES)
    {
        NSXMLNode * parentNode = [self.pluginTargetXMLElement parent];
        if ([parentNode kind] == NSXMLElementKind)
        {
            NSXMLElement * parentElement = (NSXMLElement *)parentNode;
            NSString * parentName = [parentElement name];
            if ([parentName isEqualToString:@"path"] == YES)
            {
                targetElement = (NSXMLElement *)[self.pluginTargetXMLElement parent];
            }
            else
            {
                targetElement = NULL;
            }
        }
    }

    if (targetElement != NULL)
    {
        NSArray * childArray = [targetElement children];
        
        for (NSXMLNode * aChildNode in childArray)
        {
            NSXMLNodeKind nodeKind = [aChildNode kind];
            if (nodeKind == NSXMLElementKind)
            {
                NSXMLElement * aChildElement = (NSXMLElement *)aChildNode;
                
                NSString * tagName = [aChildElement name];
                
                if ([tagName isEqualToString:@"animate"] == YES)
                {
                    NSXMLNode * attributeNameAttributeNode = [aChildElement attributeForName:@"attributeName"];
                    if (attributeNameAttributeNode != NULL)
                    {
                        NSString * attributeNameValueString = [attributeNameAttributeNode stringValue];
                        
                        if ([attributeNameValueString isEqualToString:@"d"])
                        {
                            result++;;    // path animate found, increment count
                        }
                    }
                }
            }
        }
    }
    
    return result;
}

//==================================================================================
//	numberOfRowsInTableView:
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSInteger result = 0;
    
    if (aTableView == animateElementsTableView)
    {
        result = [self countAnimateElements];
    }
    
    return result;
}

//==================================================================================
//	animateElementAtCount:
//==================================================================================

- (NSXMLElement *)animateElementAtCount:(NSInteger)countIndex
{
    NSXMLElement * result = NULL;
    NSInteger currentCount = 0;

    NSXMLElement * targetElement = self.pluginTargetXMLElement;
    NSString * targetName = [self.pluginTargetXMLElement name];
    if ([targetName isEqualToString:@"animate"] == YES)
    {
        NSXMLNode * parentNode = [self.pluginTargetXMLElement parent];
        if ([parentNode kind] == NSXMLElementKind)
        {
            NSXMLElement * parentElement = (NSXMLElement *)parentNode;
            NSString * parentName = [parentElement name];
            if ([parentName isEqualToString:@"path"] == YES)
            {
                targetElement = (NSXMLElement *)[self.pluginTargetXMLElement parent];
            }
            else
            {
                targetElement = NULL;
            }
        }
    }

    if (targetElement != NULL)
    {
        NSArray * childArray = [targetElement children];
        
        for (NSXMLNode * aChildNode in childArray)
        {
            NSXMLNodeKind nodeKind = [aChildNode kind];
            if (nodeKind == NSXMLElementKind)
            {
                NSXMLElement * aChildElement = (NSXMLElement *)aChildNode;
                
                NSString * tagName = [aChildElement name];
                
                if ([tagName isEqualToString:@"animate"] == YES)
                {
                    NSXMLNode * attributeNameAttributeNode = [aChildElement attributeForName:@"attributeName"];
                    if (attributeNameAttributeNode != NULL)
                    {
                        NSString * attributeNameValueString = [attributeNameAttributeNode stringValue];
                        
                        if ([attributeNameValueString isEqualToString:@"d"])
                        {
                            if (countIndex == currentCount)
                            {
                                // requested animate element found
                                result = aChildElement;
                                break;
                            }
                        
                            currentCount++;
                        }
                    }
                }
            }
        }
    }

    return result;
}

//==================================================================================
//	animateElementsTableViewObjectValueForTableColumn:row:
//==================================================================================

- (id)animateElementsTableViewObjectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString * result = @"Missing Result";
    
    NSString * tableColumnTitle= [aTableColumn identifier];
    
    if ([tableColumnTitle isEqualToString:@"AnimateIndex"] == YES)
    {
        NSString * rowIndexString = [NSString stringWithFormat:@"%ld", (rowIndex + 1)];
        result = rowIndexString;
    }
    else if ([tableColumnTitle isEqualToString:@"AnimateID"] == YES)
    {
        NSXMLElement * animateElement = [self animateElementAtCount:rowIndex];

        if (animateElement != NULL)
        {
            NSXMLNode * idAttributeNode = [animateElement attributeForName:@"id"];
            NSString * idAttributeString = [idAttributeNode stringValue];
            result = idAttributeString;
        }
    }
    
    return result;
}

//==================================================================================
//	tableView:objectValueForTableColumn:row:
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString * result = @"Missing Result";
    
    if (aTableView == animateElementsTableView)
    {
        result = [self animateElementsTableViewObjectValueForTableColumn:aTableColumn row:rowIndex];
    }
    
    return result;
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = [aNotification object];
    if (aTableView == animateElementsTableView)
    {
        [self enableButtons];
    }
}

//==================================================================================
//	createNewAnimateElement
//==================================================================================

- (NSXMLElement *)createNewAnimateElement
{
    NSXMLElement * resultElement = NULL;
    
    NSXMLElement * newAnimateElement = [[NSXMLElement alloc] initWithName:@"animate"];
    
    NSString * macsvgid = [self.macSVGPluginCallbacks newMacsvgid];
    NSXMLNode * MacsvgidAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    [MacsvgidAttributeNode setName:@"macsvgid"];
    [MacsvgidAttributeNode setStringValue:macsvgid];
    [newAnimateElement addAttribute:MacsvgidAttributeNode];
    
    NSXMLNode * attributeNameAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    [attributeNameAttributeNode setName:@"attributeName"];
    [attributeNameAttributeNode setStringValue:@"d"];
    [newAnimateElement addAttribute:attributeNameAttributeNode];

    NSXMLElement * targetElement = self.pluginTargetXMLElement;
    NSString * targetName = [self.pluginTargetXMLElement name];
    if ([targetName isEqualToString:@"animate"] == YES)
    {
        NSXMLNode * parentNode = [self.pluginTargetXMLElement parent];
        if ([parentNode kind] == NSXMLElementKind)
        {
            NSXMLElement * parentElement = (NSXMLElement *)parentNode;
            NSString * parentName = [parentElement name];
            if ([parentName isEqualToString:@"path"] == YES)
            {
                targetElement = (NSXMLElement *)[self.pluginTargetXMLElement parent];
            }
            else
            {
                targetElement = NULL;
            }
        }
    }



    if (targetElement != NULL)
    {
        NSString * masterPathString = @"";
        //NSXMLNode * masterPathAttributeNode = [self.pluginTargetXMLElement attributeForName:@"d"];
        NSXMLNode * masterPathAttributeNode = [targetElement attributeForName:@"d"];
        if (masterPathAttributeNode != NULL)
        {
            masterPathString = [masterPathAttributeNode stringValue];
        }
        NSXMLNode * valuesAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        [valuesAttributeNode setName:@"values"];
        [valuesAttributeNode setStringValue:masterPathString];
        [newAnimateElement addAttribute:valuesAttributeNode];
        
        //[self.pluginTargetXMLElement addChild:newAnimateElement];  // add animate element to path element
        [targetElement addChild:newAnimateElement];  // add animate element to path element
        
        [animateElementsTableView reloadData];
        
        NSInteger animateElementsCount = [self countAnimateElements];

        NSIndexSet * newRowIndex = [NSIndexSet indexSetWithIndex:(animateElementsCount - 1)];

        [animateElementsTableView selectRowIndexes:newRowIndex byExtendingSelection:NO];
        
        [self enableButtons];
    }
    
    return resultElement;
}

//==================================================================================
//	enableButtons
//==================================================================================

-(void)enableButtons
{
    NSInteger animateElementsCount = [self countAnimateElements];
    
    if (animateElementsCount == 0)
    {
        [editAnimateElementButton setEnabled:NO];
        [deleteAnimateElementButton setEnabled:NO];
        [managePathsForAnimateButton setEnabled:NO];
    }
    else
    {
        NSInteger selectedRow = [animateElementsTableView selectedRow];
        if (selectedRow == -1)
        {
            [editAnimateElementButton setEnabled:NO];
            [deleteAnimateElementButton setEnabled:NO];
            [managePathsForAnimateButton setEnabled:NO];
        }
        else
        {
            [editAnimateElementButton setEnabled:YES];
            [deleteAnimateElementButton setEnabled:YES];
            [managePathsForAnimateButton setEnabled:YES];
        }
    }
}

@end
