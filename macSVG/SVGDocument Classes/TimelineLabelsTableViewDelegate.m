//
//  TimelineLabelsTableViewDelegate.m
//  macSVG
//
//  Created by Douglas Ward on 12/22/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "TimelineLabelsTableViewDelegate.h"
#import "AnimationTimelineView.h"
#import "AnimationTimelineElement.h"
#import "MacSVGDocumentWindowController.h"
#import "MacSVGDocument.h"
#import "XMLOutlineController.h"
#import "NSOutlineView_Extensions.h"

@implementation TimelineLabelsTableViewDelegate

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
    if (self) 
    {
        // Initialization code here.
    }
    
    return self;
}

//==================================================================================
//	reloadData
//==================================================================================

- (void)reloadData 
{
    [timelineLabelsTableView reloadData];
    [timelineLabelsTableView setNeedsDisplay:YES];
}

//==================================================================================
//	reloadView
//==================================================================================

- (void)reloadView
{
    [self reloadData];
}

//==================================================================================
//	numberOfRowsInTableView
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [animationTimelineView.timelineElementsArray count];
}

//==================================================================================
//	numberOfRowsInTableView
//==================================================================================

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return timelineItemHeight - 2;
}

//==================================================================================
//	tableView:objectValueForTableColumn:rowIndex
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSMutableArray * timelineElementsArray = animationTimelineView.timelineElementsArray;
    
    AnimationTimelineElement * timelineElement = [timelineElementsArray objectAtIndex:rowIndex];
    
    NSString * labelString = 
            [[NSString alloc] initWithFormat:@"%@ id=\"%@\"", timelineElement.tagName, timelineElement.elementID];
    
    NSNumber * baselineOffset = [[NSNumber alloc] initWithFloat:-2.0f];
    
    NSDictionary * attributesDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:baselineOffset, NSBaselineOffsetAttributeName, nil];
    
    NSAttributedString * attributedString = 
            [[NSAttributedString alloc] initWithString:labelString attributes:attributesDictionary];
            
    id objectValue = attributedString;
    
    return objectValue;
}

//==================================================================================
//	setObjectValue:forTableColumn:row
//==================================================================================

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
}

//==================================================================================
//	syncToElementSelection
//==================================================================================

- (void)syncToElementSelection
{
    NSInteger rowIndex = [timelineLabelsTableView selectedRow];

    if (rowIndex != -1)
    {
        AnimationTimelineElement * timelineElement = [animationTimelineView.timelineElementsArray 
                objectAtIndex:rowIndex];

        NSString * macsvgid = timelineElement.macsvgid;
        
        MacSVGDocument * macSVGDocument = [macSVGDocumentWindowController document];
        
        NSXMLElement * xmlElement = [macSVGDocument xmlElementForMacsvgid:macsvgid];
        
        NSMutableArray * expandElementsArray = [NSMutableArray array];
        NSXMLElement * parentXMLElement = xmlElement;
        while (parentXMLElement != NULL)
        {
            [expandElementsArray insertObject:parentXMLElement atIndex:0];
            parentXMLElement = (NSXMLElement *)[parentXMLElement parent];
        }
        
        for (NSXMLElement * expandElement in expandElementsArray)
        {
            [macSVGDocumentWindowController.xmlOutlineController.xmlOutlineView expandItem:expandElement];
        }
        
        [macSVGDocumentWindowController.xmlOutlineController selectElement:xmlElement]; 
     
        NSUInteger outlineRowIndex = [macSVGDocumentWindowController.xmlOutlineController.xmlOutlineView selectedRow];
        
        if (outlineRowIndex != -1)
        {
            //NSLog(@"rowIndex=%lu outlineRowIndex=%lu", rowIndex, outlineRowIndex);
           
            [macSVGDocumentWindowController.xmlOutlineController.xmlOutlineView scrollRowToVisible:outlineRowIndex];
        }
    }
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = [aNotification object];
	if (aTableView == timelineLabelsTableView)
	{
		[self syncToElementSelection];
	}
}

@end
