//
//  AnimationPathsPopoverViewController.m
//  PathElementShapeAnimationEditor
//
//  Created by Douglas Ward on 8/15/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "AnimationPathsPopoverViewController.h"
#import "PathElementShapeAnimationEditor.h"
#import "MacSVGPlugin/MacSVGPluginCallbacks.h"
#import "PathSegment.h"

@interface AnimationPathsPopoverViewController ()

@end

#define PathElementDataType @"PathElement"
#define PathDataStringDataType @"PathDataString"

//#define XML_OUTLINE_PBOARD_TYPE      @"XMLOutlineViewPboardType"

@implementation AnimationPathsPopoverViewController

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    eligiblePathWebView.downloadDelegate = NULL;
    eligiblePathWebView.frameLoadDelegate = NULL;
    eligiblePathWebView.policyDelegate = NULL;
    eligiblePathWebView.resourceLoadDelegate = NULL;
    eligiblePathWebView.UIDelegate = NULL;

    animatePathWebView.downloadDelegate = NULL;
    animatePathWebView.frameLoadDelegate = NULL;
    animatePathWebView.policyDelegate = NULL;
    animatePathWebView.resourceLoadDelegate = NULL;
    animatePathWebView.UIDelegate = NULL;

    animationPreviewWebView.downloadDelegate = NULL;
    animationPreviewWebView.frameLoadDelegate = NULL;
    animationPreviewWebView.policyDelegate = NULL;
    animationPreviewWebView.resourceLoadDelegate = NULL;
    animationPreviewWebView.UIDelegate = NULL;

    self.eligiblePathElementsArray = NULL;
    self.animationPathStringsArray = NULL;
    
    self.eligiblePathXMLDocument = NULL;
    self.animatePathXMLDocument = NULL;
    self.animationPreviewXMLDocument = NULL;
    
    self.originalPathElement = NULL;
    self.originalAnimateElement = NULL;
    
    self.masterPathElement = NULL;
    self.masterAnimateElement = NULL;
}

//==================================================================================
//	initWithNibName:bundle:
//==================================================================================

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    //NSLog(@"AnimationPathsPopoverViewController - awakeFromNib");

    [super awakeFromNib];

    self.animationPathStringsArray = [NSMutableArray array];
    self.eligiblePathElementsArray = [NSMutableArray array];
    
    [eligiblePathWebView.mainFrame.frameView setAllowsScrolling:NO];
    [animatePathWebView.mainFrame.frameView setAllowsScrolling:NO];
    [animationPreviewWebView.mainFrame.frameView setAllowsScrolling:NO];
    
    [eligiblePathsTableView registerForDraggedTypes:
            @[PathElementDataType]];
    
    [animationPathsTableView registerForDraggedTypes:
            @[PathElementDataType, PathDataStringDataType]];
}

//==================================================================================
//    viewDidAppear
//==================================================================================

- (void)viewDidAppear
{
    [super viewDidAppear];

    [eligiblePathsTableView reloadData];
    [animationPathsTableView reloadData];
}

//==================================================================================
//	makeEligiblePathSVG
//==================================================================================

- (void)makeEligiblePathSVG
{
    NSString * headerString = [self svgHeaderString];

    NSString * pathString = @"<path stroke=\"#000000\" id=\"path1\" stroke-width=\"3px\" d=\"M363,185 C440,188 519,259 515,324 C511,389 476,519 343,518 C210,517 150,407 150,351 C150,295 279,185 362,185  Z \" fill=\"none\" transform=\"\" visibility=\"visible\" />";
    
    NSInteger rowIndex = eligiblePathsTableView.selectedRow;
    if (rowIndex != -1)
    {
        if (rowIndex < self.eligiblePathElementsArray.count)
        {
            NSXMLElement * selectedPathElement = (self.eligiblePathElementsArray)[rowIndex];

            NSString * previewPathString = selectedPathElement.XMLString;
            
            NSError * error = NULL;
            NSXMLElement * previewPathElement = [[NSXMLElement alloc] initWithXMLString:previewPathString error:&error];
            
            NSXMLNode * visibilityNode = [previewPathElement attributeForName:@"visibility"];
            if (visibilityNode != NULL)
            {
                visibilityNode.stringValue = @"visible";
            }
            
            NSArray * childNodes = previewPathElement.children;
            NSInteger childNodeCount = childNodes.count;
            for (NSInteger i = childNodeCount - 1; i >= 0; i--)
            {
                NSXMLNode * aChildNode = childNodes[i];
                NSXMLNodeKind nodeKind = aChildNode.kind;
                if (nodeKind == NSXMLElementKind)
                {
                    [previewPathElement removeChildAtIndex:i];
                }
            }

            pathString = previewPathElement.XMLString;
        }
        else
        {
        
        }
    }
    
    NSString * xmlString = [NSString stringWithFormat:@"<g id=\"previewContainer\">%@</g>", pathString];
    
    NSString * footerString = @"</svg>";
    
    NSString * xmlDocString = [[NSString alloc] initWithFormat:@"%@%@%@", headerString, xmlString, footerString];
    
    NSError * docError = NULL;
    
    self.eligiblePathXMLDocument = [[NSXMLDocument alloc]
            initWithXMLString:xmlDocString options:0 error:&docError];
}

//==================================================================================
//	makeAnimatePathSVG
//==================================================================================

- (void)makeAnimatePathSVG
{
    NSString * headerString = [self svgHeaderString];

    NSString * pathString = @"<path stroke=\"#000000\" id=\"path1\" stroke-width=\"3px\" d=\"M363,185 C440,188 519,259 515,324 C511,389 476,519 343,518 C210,517 150,407 150,351 C150,295 279,185 362,185  Z \" fill=\"none\" transform=\"\" visibility=\"visible\" />";
    
    NSInteger rowIndex = animationPathsTableView.selectedRow;
    if (rowIndex != -1)
    {
        if (rowIndex < self.animationPathStringsArray.count)
        {
            NSString * previewPathStringData = (self.animationPathStringsArray)[rowIndex];

            NSString * previewPathString = [NSString stringWithFormat:@"<path stroke=\"#000000\" id=\"path1\" stroke-width=\"3px\" d=\"%@\" fill=\"none\" transform=\"\" visibility=\"visible\" />", previewPathStringData];
            
            NSError * error = NULL;
            NSXMLElement * previewPathElement = [[NSXMLElement alloc] initWithXMLString:previewPathString error:&error];
            
            NSXMLNode * visibilityNode = [previewPathElement attributeForName:@"visibility"];
            if (visibilityNode != NULL)
            {
                visibilityNode.stringValue = @"visible";
            }
            
            NSArray * childNodes = previewPathElement.children;
            NSInteger childNodeCount = childNodes.count;
            for (NSInteger i = childNodeCount - 1; i >= 0; i--)
            {
                NSXMLNode * aChildNode = childNodes[i];
                NSXMLNodeKind nodeKind = aChildNode.kind;
                if (nodeKind == NSXMLElementKind)
                {
                    [previewPathElement removeChildAtIndex:i];
                }
            }

            pathString = previewPathElement.XMLString;
        }
    }
    
    NSString * xmlString = [NSString stringWithFormat:@"<g id=\"previewContainer\">%@</g>", pathString];
    
    NSString * footerString = @"</svg>";
    
    NSString * xmlDocString = [[NSString alloc] initWithFormat:@"%@%@%@", headerString, xmlString, footerString];
    
    NSError * docError = NULL;
    
    self.animatePathXMLDocument = [[NSXMLDocument alloc]
            initWithXMLString:xmlDocString options:0 error:&docError];
}

//==================================================================================
//	makeAnimationPreviewSVG
//==================================================================================

- (void)makeAnimationPreviewSVG
{
    NSString * headerString = [self svgHeaderString];

    NSString * pathString = @"<path stroke=\"#000000\" id=\"path1\" stroke-width=\"3px\" d=\"M363,185 C440,188 519,259 515,324 C511,389 476,519 343,518 C210,517 150,407 150,351 C150,295 279,185 362,185  Z \" fill=\"none\" transform=\"\" visibility=\"visible\" />";
    
    NSString * previewPathString = (self.masterPathElement).XMLString;
    
    NSError * error = NULL;
    NSXMLElement * previewPathElement = [[NSXMLElement alloc] initWithXMLString:previewPathString error:&error];
    
    NSXMLNode * visibilityNode = [previewPathElement attributeForName:@"visibility"];
    if (visibilityNode != NULL)
    {
        visibilityNode.stringValue = @"visible";
    }

    [previewPathElement removeAttributeForName:@"macsvgid"];
    
    NSArray * pathChildNodes = previewPathElement.children;
    NSInteger pathChildNodeCount = pathChildNodes.count;
    for (NSInteger i = pathChildNodeCount - 1; i >= 0; i--)
    {
        NSXMLNode * aChildNode = pathChildNodes[i];
        NSXMLNodeKind nodeKind = aChildNode.kind;
        if (nodeKind == NSXMLElementKind)
        {
            [previewPathElement removeChildAtIndex:i];
        }
    }

    NSString * previewAnimationString = (self.masterAnimateElement).XMLString;
    NSXMLElement * previewAnimateElement = [[NSXMLElement alloc] initWithXMLString:previewAnimationString error:&error];
    
    NSArray * animateChildNodes = previewAnimateElement.children;
    NSInteger animateChildNodesCount = animateChildNodes.count;
    for (NSInteger i = animateChildNodesCount - 1; i >= 0; i--)
    {
        NSXMLNode * aChildNode = animateChildNodes[i];
        NSXMLNodeKind nodeKind = aChildNode.kind;
        if (nodeKind == NSXMLElementKind)
        {
            [previewAnimateElement removeChildAtIndex:i];
        }
    }
    
    [previewAnimateElement removeAttributeForName:@"macsvgid"];
    NSMutableString * animationPathsString = [NSMutableString string];
    
    for (NSString * aPathString in self.animationPathStringsArray)
    {
        [animationPathsString appendString:aPathString];
        [animationPathsString appendString:@";"];
    }
    
    //NSXMLNode * valuesNode = [self.masterAnimateElement attributeForName:@"values"];
    NSXMLNode * valuesNode = [previewAnimateElement attributeForName:@"values"];
    if (valuesNode == NULL)
    {
        valuesNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        valuesNode.name = @"values";
        valuesNode.stringValue = @"";
        [previewAnimateElement addAttribute:valuesNode];
    }
    valuesNode.stringValue = animationPathsString;
    
    NSXMLNode * beginNode = [previewAnimateElement attributeForName:@"begin"];
    if (beginNode == NULL)
    {
        beginNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        beginNode.name = @"begin";
        beginNode.stringValue = @"";
        [previewAnimateElement addAttribute:beginNode];
    }
    beginNode.stringValue = @"0s";
    
    NSXMLNode * repeatCountNode = [previewAnimateElement attributeForName:@"repeatCount"];
    if (repeatCountNode == NULL)
    {
        repeatCountNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        repeatCountNode.name = @"repeatCount";
        repeatCountNode.stringValue = @"";
        [previewAnimateElement addAttribute:repeatCountNode];
    }
    repeatCountNode.stringValue = @"indefinite";
    
    
    [previewPathElement addChild:previewAnimateElement];

    pathString = previewPathElement.XMLString;
    
    NSString * xmlString = [NSString stringWithFormat:@"<g id=\"previewContainer\">%@</g>", pathString];
    
    NSString * footerString = @"</svg>";
    
    NSString * xmlDocString = [[NSString alloc] initWithFormat:@"%@%@%@", headerString, xmlString, footerString];
    
    NSError * docError = NULL;
    
    self.animationPreviewXMLDocument = [[NSXMLDocument alloc]
            initWithXMLString:xmlDocString options:0 error:&docError];
    
    pathElementTextView.string = pathString;
}

// ================================================================

- (NSString *)svgHeaderString
{
    NSString * headerString =
@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n\
<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \n\
\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n\
<svg xmlns=\"http://www.w3.org/2000/svg\"\n\
xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\"\n\
xmlns:cc=\"http://web.resource.org/cc/\"\n\
xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n\
xmlns:sodipodi=\"http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd\"\n\
xmlns:inkscape=\"http://www.inkscape.org/namespaces/inkscape\"\n\
version=\"1.1\" baseProfile=\"full\" width=\"150px\"\n\
height=\"150px\" viewBox=\"0 0 744 744\" preserveAspectRatio=\"xMidYMid meet\">";
    return headerString;
}


//==================================================================================
//	loadSettingsForMasterPathElement:
//==================================================================================

- (void)loadSettingsForMasterPathElement:(NSXMLElement *)masterPathElement animateElement:(NSXMLElement *)animateElement
{
    //NSLog(@"PathElementShapeAnimationEditor - loadSettingsForMasterPathElement");

    self.originalPathElement = masterPathElement;
    self.originalAnimateElement = animateElement;
    
    // temporarily remove attributes containing namespaces to avoid failure with NSXMLElement initWithXMLString
    NSArray * originalPathElementAttributes = self.originalPathElement.attributes;
    NSMutableArray * removedAttributes = [NSMutableArray array];
    for (NSXMLNode * attributeNode in originalPathElementAttributes)
    {
        NSString * attributeName = attributeNode.name;
        NSArray * attributeNameArray = [attributeName componentsSeparatedByString:@":"];
        if (attributeNameArray.count == 2)
        {
            [removedAttributes addObject:attributeNode];
            [self.originalPathElement removeAttributeForName:attributeName];
        }
    }

    NSString * originalPathElementXMLString = (self.originalPathElement).XMLString;
    
    NSString * originalAnimateElementXMLString = (self.originalAnimateElement).XMLString;

    NSError * pathError;
    self.masterPathElement = [[NSXMLElement alloc] initWithXMLString:originalPathElementXMLString error:&pathError];
    NSError * animateError;
    self.masterAnimateElement = [[NSXMLElement alloc] initWithXMLString:originalAnimateElementXMLString error:&animateError];;

    self.eligiblePathElementsArray = [self findEligiblePathElements];
    
    //NSLog(@"eligiblePathElementsArray = %@", self.eligiblePathElementsArray);
    
    [self loadAnimatePathsTable];
    
    //[eligiblePathsTableView reloadData];
    [animationPathsTableView reloadData];
    
    NSIndexSet * firstRowIndexSet = [NSIndexSet indexSetWithIndex:0];
    [eligiblePathsTableView selectRowIndexes:firstRowIndexSet byExtendingSelection:NO];
    [animationPathsTableView selectRowIndexes:firstRowIndexSet byExtendingSelection:NO];
    
    [self makeEligiblePathSVG];
    NSString * eligiblePathXmlString = (self.eligiblePathXMLDocument).XMLString;
    [eligiblePathWebView.mainFrame loadHTMLString:eligiblePathXmlString baseURL:NULL];

    [self makeAnimatePathSVG];
    NSString * animatePathXmlString = (self.animatePathXMLDocument).XMLString;
    [animatePathWebView.mainFrame loadHTMLString:animatePathXmlString baseURL:NULL];

    [self makeAnimationPreviewSVG];
    NSString * animationPreviewXmlString = (self.animationPreviewXMLDocument).XMLString;
    [animationPreviewWebView.mainFrame loadHTMLString:animationPreviewXmlString baseURL:NULL];
    
    // restore the removed attributes that contained namespaces
    for (NSXMLNode * removedAttribute in removedAttributes)
    {
        [self.originalPathElement addAttribute:removedAttribute];
    }
}

//==================================================================================
//	numberOfRowsInTableView:
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSInteger result = 0;
    
    if (aTableView == eligiblePathsTableView)
    {
        result = (self.eligiblePathElementsArray).count;
    }
    else if (aTableView == animationPathsTableView)
    {
        result = (self.animationPathStringsArray).count;
    }
    
    return result;
}

//==================================================================================
//	animationPathsTableViewObjectValueForTableColumn:row:
//==================================================================================

- (id)animationPathsTableViewObjectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString * result = @"Missing Result";
    
    NSString * tableColumnTitle= aTableColumn.identifier;
    
    if ([tableColumnTitle isEqualToString:@"PathIndex"] == YES)
    {
        NSString * rowIndexString = [NSString stringWithFormat:@"%ld", (rowIndex + 1)];
        result = rowIndexString;
    }
    else if ([tableColumnTitle isEqualToString:@"PathData"] == YES)
    {
        NSString * pathString = (self.animationPathStringsArray)[rowIndex];
        result = pathString;
    }
    
    return result;
}

//==================================================================================
//    tableView:viewForTableColumn:row:
//==================================================================================

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString * tableColumnIdentifier = tableColumn.identifier;
    
    //NSTableCellView * tableCellView = (NSTableCellView *)[tableView makeViewWithIdentifier:tableColumnIdentifier owner:self];
    NSTableCellView * tableCellView = (NSTableCellView *)[tableView makeViewWithIdentifier:tableColumnIdentifier owner:NULL];   // pass NULL owner to avoid problem of reinstantiating the AnimationPathsPopoverViewController class

    NSString * resultString = @"";

    if (tableCellView != NULL)
    {
        resultString = [self tableView:tableView objectValueForTableColumn:tableColumn row:row];
    }
    
    tableCellView.textField.stringValue = resultString;
    
    return (NSView *)tableCellView;
}

//==================================================================================
//	tableView:objectValueForTableColumn:row:
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString * result = @"Missing Result";
    
    if (aTableView == eligiblePathsTableView)
    {
        NSString * tableColumnTitle= aTableColumn.identifier;
        
        if ([tableColumnTitle isEqualToString:@"PathIndex"] == YES)
        {
            NSString * rowIndexString = [NSString stringWithFormat:@"%ld", (rowIndex + 1)];
            result = rowIndexString;
        }
        else if ([tableColumnTitle isEqualToString:@"PathID"] == YES)
        {
            if (rowIndex < self.eligiblePathElementsArray.count)
            {
                NSXMLElement * pathElement = (self.eligiblePathElementsArray)[rowIndex];
                NSXMLNode * idAttributeNode = [pathElement attributeForName:@"id"];
                NSString * idAttributeString = idAttributeNode.stringValue;
                result = idAttributeString;
            }
        }
        else if ([tableColumnTitle isEqualToString:@"PathLocation"] == YES)
        {
            if (rowIndex < self.eligiblePathElementsArray.count)
            {
                NSXMLElement * pathElement = NULL;
                pathElement = (self.eligiblePathElementsArray)[rowIndex];
                NSString * pathXPath = pathElement.XPath;
                result = pathXPath;
            }
        }
    }
    else if (aTableView == animationPathsTableView)
    {
        if (rowIndex < self.animationPathStringsArray.count)
        {
            result = [self animationPathsTableViewObjectValueForTableColumn:aTableColumn row:rowIndex];
        }
    }
    
    if ([result isEqualToString:@"Missing Result"] == YES)
    {
        // error
    }
    
    return result;
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = aNotification.object;
    if (aTableView == eligiblePathsTableView)
    {
        [self makeEligiblePathSVG];
        NSString * pathXmlString = (self.eligiblePathXMLDocument).XMLString;
        [eligiblePathWebView.mainFrame loadHTMLString:pathXmlString baseURL:NULL];
    }
    else if (aTableView == animationPathsTableView)
    {
        [self makeAnimatePathSVG];
        NSString * animatePathXmlString = (self.animatePathXMLDocument).XMLString;
        [animatePathWebView.mainFrame loadHTMLString:animatePathXmlString baseURL:NULL];
    }
}

//==================================================================================
//    tableView:writeRowsWithIndexes:toPasteboard:
//==================================================================================

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes
        toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];   // deprecated

    NSError * archiveDataError = NULL;
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes requiringSecureCoding:NO error:&archiveDataError];
    
    NSString * sourceDataType = @"";
    if (tableView == eligiblePathsTableView)
    {
        sourceDataType = PathElementDataType;
    }
    else if (tableView == animationPathsTableView)
    {
        sourceDataType = PathDataStringDataType;
    }

    [pboard declareTypes:@[sourceDataType] owner:self];

    [pboard setData:data forType:sourceDataType];
    
    return YES;
}

//==================================================================================
//    tableView:validateDrop:proposedRow:
//==================================================================================

- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(id <NSDraggingInfo>)info
        proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
    // Add code here to validate the drop
    
    NSDragOperation result = NSDragOperationNone;
    
    if (tableView == eligiblePathsTableView)
    {
        result = NSDragOperationNone;
    }
    else if (tableView == animationPathsTableView)
    {
        result = NSDragOperationEvery;
    }
    
    return result;
}

//==================================================================================
//    tableView:acceptDrop:row:
//==================================================================================

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info
        row:(int)to dropOperation:(NSTableViewDropOperation)operation
{
    BOOL result = NO;

    if (aTableView == animationPathsTableView)
    {
        NSPasteboard * pboard = [info draggingPasteboard];

        NSArray * pboardArray  = @[PathDataStringDataType, PathElementDataType];
        NSString * availableType = [pboard availableTypeFromArray:pboardArray];
        
        if ([availableType isEqualToString:PathElementDataType])
        {
            // drag from path elements list to path strings list
            NSData * sourceRowData = [pboard dataForType:PathElementDataType];

            //NSIndexSet * sourceRowIndex = [NSKeyedUnarchiver unarchiveObjectWithData:sourceRowData];
            NSError * archiveError = NULL;
            NSIndexSet * sourceRowIndex = [NSKeyedUnarchiver  unarchivedObjectOfClass:NSIndexSet.class fromData:sourceRowData error:&archiveError];

            NSUInteger from = sourceRowIndex.firstIndex;
            
            NSXMLElement * sourcePathElement = (self.eligiblePathElementsArray)[from];
            NSXMLNode * pathDataAttribute = [sourcePathElement attributeForName:@"d"];
            if (pathDataAttribute != NULL)
            {
                NSString * pathDataString = pathDataAttribute.stringValue;
                [self.animationPathStringsArray insertObject:pathDataString atIndex:to];
                result = YES;
            }
        }
        else if ([availableType isEqualToString:PathDataStringDataType])
        {
            // rearrange items in path strings list
            NSData * sourceRowData = [pboard dataForType:PathDataStringDataType];
            
            //NSIndexSet * sourceRowIndex = [NSKeyedUnarchiver unarchiveObjectWithData:sourceRowData];
            NSError * archiveError = NULL;
            NSIndexSet * sourceRowIndex = [NSKeyedUnarchiver  unarchivedObjectOfClass:NSIndexSet.class fromData:sourceRowData error:&archiveError];

            NSUInteger from = sourceRowIndex.firstIndex;

            NSString * traveller = (self.animationPathStringsArray)[from];

            NSInteger length = (self.animationPathStringsArray).count;

            int i;
            for (i = 0; i <= length; i++)
            {
                if (i == to)
                {
                    if (from > to)
                    {
                        [self.animationPathStringsArray insertObject:traveller atIndex:to];
                        [self.animationPathStringsArray removeObjectAtIndex:(from + 1)];
                        result = YES;
                    }
                    else
                    {
                        [self.animationPathStringsArray insertObject:traveller atIndex:to];
                        [self.animationPathStringsArray removeObjectAtIndex:from];
                        result = YES;
                    }
                }
            }
        }
    }
    
    [self makeAnimationPreviewSVG];
    NSString * animationPreviewXmlString = (self.animationPreviewXMLDocument).XMLString;
    [animationPreviewWebView.mainFrame loadHTMLString:animationPreviewXmlString baseURL:NULL];

    [animationPathsTableView reloadData];

    return result;
}

//==================================================================================
//	addAnimationPathButtonAction:
//==================================================================================

- (IBAction)addAnimationPathButtonAction:(id)sender
{
    NSInteger eligibleRowIndex = eligiblePathsTableView.selectedRow;
    if (eligibleRowIndex != -1)
    {
        NSXMLElement * eligiblePathElement =
                (self.eligiblePathElementsArray)[eligibleRowIndex];
        NSXMLNode * aPathStringNode = [eligiblePathElement attributeForName:@"d"];
        NSString * aPathString = aPathStringNode.stringValue;
    
        NSInteger animationRowIndex = animationPathsTableView.selectedRow;
        if (animationRowIndex == -1)
        {
            animationRowIndex = (self.animationPathStringsArray).count;
        }
        else
        {
            animationRowIndex++;
        }
        
        [self.animationPathStringsArray insertObject:aPathString atIndex:animationRowIndex];

        [animationPathsTableView reloadData];

        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:animationRowIndex];
        [animationPathsTableView selectRowIndexes:indexSet byExtendingSelection:NO];

        [self makeAnimatePathSVG];
        NSString * animatePathXmlString = (self.animatePathXMLDocument).XMLString;
        [animatePathWebView.mainFrame loadHTMLString:animatePathXmlString baseURL:NULL];

        [self makeAnimationPreviewSVG];
        NSString * animationPreviewXmlString = (self.animationPreviewXMLDocument).XMLString;
        [animationPreviewWebView.mainFrame loadHTMLString:animationPreviewXmlString baseURL:NULL];
    }
}

//==================================================================================
//	deleteAnimationPathButtonAction:
//==================================================================================

- (IBAction)deleteAnimationPathButtonAction:(id)sender
{
    NSInteger rowIndex = animationPathsTableView.selectedRow;
    if (rowIndex != -1)
    {
        [self.animationPathStringsArray removeObjectAtIndex:rowIndex];
    }
    
    [animationPathsTableView reloadData];

    [self makeAnimatePathSVG];
    NSString * animatePathXmlString = (self.animatePathXMLDocument).XMLString;
    [animatePathWebView.mainFrame loadHTMLString:animatePathXmlString baseURL:NULL];

    [self makeAnimationPreviewSVG];
    NSString * animationPreviewXmlString = (self.animationPreviewXMLDocument).XMLString;
    [animationPreviewWebView.mainFrame loadHTMLString:animationPreviewXmlString baseURL:NULL];
}

//==================================================================================
//	cancelButtonAction
//==================================================================================

- (IBAction)cancelButtonAction:(id)sender
{
    [self.eligiblePathElementsArray removeAllObjects];
    [self.animationPathStringsArray removeAllObjects];
    
    [eligiblePathsTableView reloadData];
    [animationPathsTableView reloadData];

    [eligiblePathWebView.mainFrame loadHTMLString:@"" baseURL:NULL];
    [animatePathWebView.mainFrame loadHTMLString:@"" baseURL:NULL];
    [animationPreviewWebView.mainFrame loadHTMLString:@"" baseURL:NULL];

    self.eligiblePathXMLDocument = NULL;
    self.animatePathXMLDocument = NULL;
    self.animationPreviewXMLDocument = NULL;

    self.originalPathElement = NULL;
    self.originalAnimateElement = NULL;
    self.masterPathElement = NULL;
    self.masterAnimateElement = NULL;

    [animationPathsPopover performClose:self];
}

//==================================================================================
//	doneButtonAction
//==================================================================================

- (IBAction)doneButtonAction:(id)sender
{
    [self updateOriginalPathElement];

    [self.eligiblePathElementsArray removeAllObjects];
    [self.animationPathStringsArray removeAllObjects];
    
    [eligiblePathsTableView reloadData];
    [animationPathsTableView reloadData];

    [eligiblePathWebView.mainFrame loadHTMLString:@"" baseURL:NULL];
    [animatePathWebView.mainFrame loadHTMLString:@"" baseURL:NULL];
    [animationPreviewWebView.mainFrame loadHTMLString:@"" baseURL:NULL];

    self.eligiblePathXMLDocument = NULL;
    self.animatePathXMLDocument = NULL;
    self.animationPreviewXMLDocument = NULL;
    
    // update original animate element here

    self.originalPathElement = NULL;
    self.originalAnimateElement = NULL;
    self.masterPathElement = NULL;
    self.masterAnimateElement = NULL;

    [animationPathsPopover performClose:self];
    
    [pathElementShapeAnimationEditor updateDocumentViews];
}


//==================================================================================
//	updateOriginalPathElement
//==================================================================================

- (void)updateOriginalPathElement
{
    NSMutableString * animationPathsString = [NSMutableString string];
    
    for (NSString * aPathString in self.animationPathStringsArray)
    {
        [animationPathsString appendString:aPathString];
        [animationPathsString appendString:@";"];
    }
    
    [self.originalAnimateElement removeAttributeForName:@"from"];
    [self.originalAnimateElement removeAttributeForName:@"to"];
    
    BOOL attributeFound = NO;
    NSXMLNode * valuesAttributeNode = [self.originalAnimateElement attributeForName:@"values"];
    if (valuesAttributeNode == NULL)
    {
        valuesAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        valuesAttributeNode.name = @"values";
    }
    else
    {
        attributeFound = YES;
    }
    
    valuesAttributeNode.stringValue = animationPathsString;
    
    if (attributeFound == NO)
    {
        [self.originalAnimateElement addAttribute:valuesAttributeNode];
    }
}

//==================================================================================
//	pathArray:matchesPathArray:
//==================================================================================

- (BOOL)pathArray:(NSArray *)pathArray1 matchesPathArray:(NSArray *)pathArray2
{
    BOOL result = YES;
    
    NSInteger pathArray1Count = pathArray1.count;
    NSInteger pathArray2Count = pathArray2.count;
    
    if (pathArray1Count != pathArray2Count)
    {
        result = NO;
    }
    else
    {
        for (NSInteger i = 0; i < pathArray1Count; i++)
        {
            PathSegment * pathSegment1 = pathArray1[i];
            PathSegment * pathSegment2 = pathArray2[i];
            
            if (pathSegment1.pathCommand != pathSegment2.pathCommand)
            {
                result = NO;
                break;
            }
        }
    }
    
    return result;
}

//==================================================================================
//	makePathArray:
//==================================================================================

- (NSArray *)makePathSegmentsArray:(NSString *)aPathString
{
    MacSVGPluginCallbacks * macSVGPluginCallbacks =
            pathElementShapeAnimationEditor.macSVGPluginCallbacks;

    NSMutableArray * pathSegmentsArray = [macSVGPluginCallbacks
            buildPathSegmentsArrayWithPathString:aPathString];
            
    return pathSegmentsArray;
}

//==================================================================================
//	loadAnimatePathsTable:
//==================================================================================

- (void)loadAnimatePathsTable
{
    [self.animationPathStringsArray removeAllObjects];

    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSXMLNode * masterPathNode = [self.masterPathElement attributeForName:@"d"];
    NSString * masterPathString = masterPathNode.stringValue;

    NSString * trimmedMasterPathString = [masterPathString stringByTrimmingCharactersInSet:whitespaceSet];

    NSArray * masterPathArray = [self makePathSegmentsArray:trimmedMasterPathString];

    NSString * valuesAttributeString = NULL;
    NSString * fromAttributeString = NULL;
    NSString * toAttributeString = NULL;

    NSXMLNode * valuesAttributeNode = [self.masterAnimateElement attributeForName:@"values"];
    if (valuesAttributeNode != NULL)
    {
        valuesAttributeString = valuesAttributeNode.stringValue;
    }

    NSXMLNode * fromAttributeNode = [self.masterAnimateElement attributeForName:@"from"];
    if (fromAttributeNode != NULL)
    {
        fromAttributeString = fromAttributeNode.stringValue;
    }

    NSXMLNode * toAttributeNode = [self.masterAnimateElement attributeForName:@"to"];
    if (toAttributeNode != NULL)
    {
        toAttributeString = toAttributeNode.stringValue;
    }
    
    if (valuesAttributeString == NULL)
    {
        NSMutableString * newValuesAttributeString = [NSMutableString string];
        
        if (fromAttributeString != NULL)
        {
            [newValuesAttributeString appendString:fromAttributeString];
            [newValuesAttributeString appendString:@";"];
        }
        
        if (toAttributeString != NULL)
        {
            [newValuesAttributeString appendString:toAttributeString];
            [newValuesAttributeString appendString:@";"];
        }
        
        valuesAttributeString = newValuesAttributeString;
    }
    
    NSArray * splitPathsArray = [valuesAttributeString componentsSeparatedByString:@";"];
    
    for (NSString * aPathString in splitPathsArray)
    {
        NSString * trimmedPathString = [aPathString stringByTrimmingCharactersInSet:whitespaceSet];
        
        NSArray * aPathArray = [self makePathSegmentsArray:trimmedPathString];
        
        BOOL pathMatchesMasterPath = [self pathArray:aPathArray matchesPathArray:masterPathArray];
        
        if (pathMatchesMasterPath == YES)
        {
            [self.animationPathStringsArray addObject:trimmedPathString];
        }
    }
    
    [animationPathsTableView reloadData];
}

//==================================================================================
//	findAllPathElements
//==================================================================================

 -(NSArray *)findAllPathElements
 {       
    NSArray * resultArray = NULL;
    
    NSXMLDocument * svgXmlDocument = pathElementShapeAnimationEditor.svgXmlDocument;
    
    NSXMLElement * rootElement = [svgXmlDocument rootElement];
    
    NSString * xpathQuery = @".//path";
    
    NSError * error = NULL;
    resultArray = [rootElement nodesForXPath:xpathQuery error:&error];
    
    return resultArray;
}

//==================================================================================
//	findEligiblePathElements
//==================================================================================

 -(NSMutableArray *)findEligiblePathElements
 {       
    NSMutableArray * resultArray = [NSMutableArray array];

    NSXMLNode * masterPathStringNode = [self.masterPathElement attributeForName:@"d"];
    NSString * masterPathString = masterPathStringNode.stringValue;

    NSArray * masterPathArray = [self makePathSegmentsArray:masterPathString];

    NSArray * allPathsArray = [self findAllPathElements];

    for (NSXMLElement * aPathElement in allPathsArray)
    {
        NSXMLNode * aPathStringNode = [aPathElement attributeForName:@"d"];
        NSString * aPathString = aPathStringNode.stringValue;
        NSArray * aPathArray = [self makePathSegmentsArray:aPathString];
        
        BOOL pathMatchesMasterPath = [self pathArray:aPathArray matchesPathArray:masterPathArray];

        if (pathMatchesMasterPath == YES)
        {
            [resultArray addObject:aPathElement];
        }
    }
    
    return resultArray;
}

@end
