//
//  SVGElementsTableController.m
//  macSVG
//
//  Created by Douglas Ward on 11/17/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "SVGElementsTableController.h"
#import "MacSVGAppDelegate.h"
#import "SVGDTDData.h"

@implementation SVGElementsTableController


//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.svgElementsArray = NULL;
    self.svgElementsDictionary = NULL;
    self.currentElementName = NULL;
    self.recordElementName = NULL;
    self.currentElementAttributes = NULL;
    self.parserRecordDictionary = NULL;
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
    }
    
    return self;
}

// =========================================================================

- (void)parser:(NSXMLParser *)parser 
		didStartElement:(NSString *)elementName 
		namespaceURI:(NSString *)namespaceURI 
		qualifiedName:(NSString *)qualifiedName 
		attributes:(NSDictionary *)attributeDict 
{
	//NSLog(@"didStartElement:%@", elementName);
	//NSLog(@"   attributes:%@", attributeDict);
	
	[self.currentElementName setString:elementName];
	self.currentElementAttributes = attributeDict;
	
	if ([self.currentElementName isEqualToString:@"svgElement"] == YES)
	{
		isElementItem = YES;

        NSString * idString = (self.currentElementAttributes)[@"id"];
        [self.recordElementName setString:idString]; 
	}
}

// =========================================================================

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (isElementItem == YES)
	{
		NSMutableString * dictionaryItem = 
				(self.parserRecordDictionary)[self.currentElementName];
		
		if (dictionaryItem == NULL) 
		{
			dictionaryItem = [[NSMutableString alloc] initWithString:string];
			(self.parserRecordDictionary)[self.currentElementName] = dictionaryItem;
		}
		else 
		{
			[dictionaryItem appendString:string];
		}
	}
}

// =========================================================================

- (void)parser:(NSXMLParser *)parser 
		didEndElement:(NSString *)elementName 
		namespaceURI:(NSString *)namespaceURI 
		qualifiedName:(NSString *)qName 
{
	if ([elementName isEqualToString:@"svgElement"] == YES) 
	{
		NSMutableDictionary * recordDictionary = [[NSMutableDictionary alloc] init];
		NSString * aKey;
		NSEnumerator * keyEnumerator = [self.parserRecordDictionary keyEnumerator];
		while ((aKey = [keyEnumerator nextObject]) != NULL)
		{
			NSString * aValue = (self.parserRecordDictionary)[aKey];
			NSMutableString * copyValue = [[NSMutableString alloc] initWithString:aValue];
			recordDictionary[aKey] = copyValue;
		}
        
        recordDictionary[@"svgElement"] = self.recordElementName;
        [recordDictionary removeObjectForKey:@""];
	
        (self.svgElementsDictionary)[self.recordElementName] = recordDictionary;
		
		[self.parserRecordDictionary removeAllObjects];

		isElementItem = NO;
	}
	
	[self.currentElementName setString:@""];

	//[parser abortParsing];
}

//==================================================================================
//	buildSvgElementsArray
//==================================================================================

- (void)buildSvgElementsArray:(NSString *)category
{
    [self.svgElementsArray removeAllObjects];
    
    MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)NSApp.delegate;
    SVGDTDData * svgDtdData = macSVGAppDelegate.svgDtdData;

    if ([category isEqualToString:@"All SVG Elements"] == YES)
    {
        NSDictionary * entitiesDictionary = svgDtdData.entitiesDictionary;
        
        NSArray * allCategoryKeys = entitiesDictionary.allKeys;

        unsigned long allCategoryKeysCount = allCategoryKeys.count;
        int j;
        for (j = 0; j < allCategoryKeysCount; j++) 
        {
            NSString * categoryName =  allCategoryKeys[j];
            [self.svgElementsArray addObject:categoryName];
        }	
    }
    else
    {
        NSDictionary * classesDictionary = svgDtdData.classesDictionary;
        
        NSDictionary * classDictionary = classesDictionary[category];
        
        NSDictionary * classElements = classDictionary[@"class-elements"];

        NSArray * allElementsKeys = classElements.allKeys;

        unsigned long allElementsKeysCount = allElementsKeys.count;
        int j;
        for (j = 0; j < allElementsKeysCount; j++) 
        {
            NSString * elementName =  allElementsKeys[j];
            [self.svgElementsArray addObject:elementName];
        }	
    }

/*
	unsigned long allCategoryKeysCount = [allCategoryKeys count];
	int j;
	for (j = 0; j < allCategoryKeysCount; j++) 
	{
		NSString * categoryName =  [allCategoryKeys objectAtIndex:j];
		[svgElementsArray addObject:categoryName];
	}	
*/
	
	[self.svgElementsArray sortUsingSelector:@selector(compare:)];

    [self.elementsTableView reloadData];
}

//==================================================================================
//	elementCategoriesPopUpButtonAction
//==================================================================================

- (IBAction)elementCategoriesPopUpButtonAction:(id)sender
{
    NSString * category = [sender titleOfSelectedItem];
    
    [self buildSvgElementsArray:category];
}

//==================================================================================
//	buildElementsDictionary
//==================================================================================

- (void)buildElementsDictionary
{
    self.svgElementsArray = [[NSMutableArray alloc] init];
    self.svgElementsDictionary = [[NSMutableDictionary alloc] init];
    self.parserRecordDictionary = [[NSMutableDictionary alloc] init];
	self.currentElementName = [[NSMutableString alloc] init];
	self.recordElementName = [[NSMutableString alloc] init];

	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	NSString * filePath = [thisBundle pathForResource:@"SvgElementsDictionary" ofType:@"xml"];
	
	NSData * xmlData = [NSData dataWithContentsOfFile:filePath];

    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:xmlData];
    parser.delegate = self;
    isElementItem = NO;
    [parser parse];

    /*
	NSArray * allCategoryKeys = [svgElementsDictionary allKeys];
	unsigned long allCategoryKeysCount = [allCategoryKeys count];
	int j;
	for (j = 0; j < allCategoryKeysCount; j++) 
	{
		NSString * categoryName =  [allCategoryKeys objectAtIndex:j];
		[svgElementsArray addObject:categoryName];
	}	
	
	[svgElementsArray sortUsingSelector:@selector(compare:)];
    */
    
    [self buildSvgElementsArray:@"All SVG Elements"];
}

//==================================================================================
//	loadElementsData
//==================================================================================

- (void)loadElementsData
{
    [self buildElementsDictionary];
}

//==================================================================================
//	numberOfRowsInTableView
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return (self.svgElementsArray).count;
}

//==================================================================================
//    tableView:viewForTableColumn:row:
//==================================================================================

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString * tableColumnIdentifier = tableColumn.identifier;
    
    //NSTableCellView * tableCellView = (NSTableCellView *)[tableView makeViewWithIdentifier:tableColumnIdentifier owner:self];
    NSTableCellView * tableCellView = (NSTableCellView *)[tableView makeViewWithIdentifier:tableColumnIdentifier owner:NULL];

    NSString * resultString = @"";

    if (tableCellView != NULL)
    {
        resultString = [self tableView:tableView objectValueForTableColumn:tableColumn row:row];
    }
    
    tableCellView.textField.stringValue = resultString;
    
    return (NSView *)tableCellView;
}

//==================================================================================
//	tableView:objectValueForTableColumn:row
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return (self.svgElementsArray)[rowIndex];
}

//==================================================================================
//	tableView:writeRowsWithIndexes:toPasteboard
//==================================================================================

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    NSUInteger rowIndex = rowIndexes.firstIndex;

    // Provide data for our custom type, and simple NSStrings.
    [pboard declareTypes:@[NSPasteboardTypeString] owner:self];
    
    NSString * elementTag = (self.svgElementsArray)[rowIndex];
    
    NSDictionary * elementDictionary = (self.svgElementsDictionary)[elementTag];

    NSString * prototypeElement = elementDictionary[@"prototype"];
    
    NSMutableString * elementXML = [NSMutableString stringWithFormat:@"<%@ />", prototypeElement];
    
    [pboard setString:elementXML forType:NSPasteboardTypeString];
    
    return YES;
}

//==================================================================================
//	tableView:validateDrop:proposedRow:proposedDropOperation:
//==================================================================================

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op
{
    // Add code here to validate the drop
    //NSLog(@"validate Drop");
    return NSDragOperationNone;
}

//==================================================================================
//	tableView:draggingSession:endedAtPoint:operation:
//==================================================================================

- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session
        endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{

}


@end
