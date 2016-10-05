//
//  AnimateElementKeyValuesPopoverViewController.m
//  AnimateElementEditor
//
//  Created by Douglas Ward on 9/4/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "AnimateElementKeyValuesPopoverViewController.h"
#import "AnimateElementEditor.h"
#import "AnimateElementKeySplinesView.h"

@implementation AnimateElementKeyValuesPopoverViewController

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.keyValuesArray = NULL;
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
    [super awakeFromNib];

    self.keyValuesArray = [NSMutableArray array];
}

//==================================================================================
//	numberOfRowsInTableView
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return (self.keyValuesArray).count;
}

//==================================================================================
//	tableView:objectValueForTableColumn:rowIndex
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    id objectValue = NULL;
    NSMutableDictionary * keyValuesDictionary = (self.keyValuesArray)[rowIndex];
    
    if (keyValuesDictionary != NULL)
    {
        if ([aTableColumn.identifier isEqualToString:@"rowNumber"] == YES)
        {
            objectValue = [NSString stringWithFormat:@"%ld", (rowIndex + 1)];
        } 
        if ([aTableColumn.identifier isEqualToString:@"keyTimes"] == YES)
        {
            objectValue = keyValuesDictionary[@"keyTimes"];
        } 
        else if ([aTableColumn.identifier isEqualToString:@"keySplines"] == YES)
        {
            objectValue = keyValuesDictionary[@"keySplines"];
            
            if (rowIndex >= ((self.keyValuesArray).count - 1))
            {
                NSColor * redColor = [NSColor redColor];

                NSDictionary *redAttribute =
                        @{NSForegroundColorAttributeName: redColor};
                
                NSAttributedString * redString = [[NSAttributedString alloc] initWithString:objectValue attributes:redAttribute];

                objectValue = redString;
            }
        } 
        else if ([aTableColumn.identifier isEqualToString:@"keyPoints"] == YES)
        {
            objectValue = keyValuesDictionary[@"keyPoints"];
        } 
    }
    
    return objectValue;
}

//==================================================================================
//	tableView:setObjectValue:forTableColumn:row:
//==================================================================================

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString * columnIdentifier = aTableColumn.identifier;
    NSMutableDictionary * keyValuesDictionary = (self.keyValuesArray)[rowIndex];
    
    if (aTableView == keyValuesTableView)
    {
        if ([columnIdentifier isEqualToString:@"keyTimes"] == YES)
        {
            keyValuesDictionary[@"keyTimes"] = anObject;
        }
        else if ([columnIdentifier isEqualToString:@"keySplines"] == YES)
        {
            keyValuesDictionary[@"keySplines"] = anObject;
        }
        else if ([columnIdentifier isEqualToString:@"keyPoints"] == YES)
        {
            keyValuesDictionary[@"keyPoints"] = anObject;
        }
    }

    [keyValuesTableView reloadData];
    
    [keySplinesView setNeedsDisplay:YES];
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = aNotification.object;
	if (aTableView == keyValuesTableView)
	{
	}
}

//==================================================================================
//	doneButtonAction
//==================================================================================

- (IBAction)doneButtonAction:(id)sender
{
    [keyValuesPopover performClose:self];
}

//==================================================================================
//	countValidElements:
//==================================================================================

- (NSInteger)countValidElements:(NSArray *)aArray
{
    NSInteger result = 0;
    
    NSInteger arrayCount = aArray.count;
    
    for (NSInteger i = 0; i < arrayCount; i++)
    {
        NSString * aValue = aArray[i];
        if (aValue.length > 0)
        {
            result = i + 1;
        }
    }
    
    return result;
}

//==================================================================================
//	presetsPopUpButtonAction:
//==================================================================================

- (IBAction)presetsPopUpButtonAction:(id)sender
{
    NSString * keyTimesString = @"0;1;";
    NSString * keySplinesString = @"0 0 1 1;";
    NSString * keyPointsString = @"";
    
    NSInteger presetIndex = presetsPopUpButton.indexOfSelectedItem;
    
    switch (presetIndex)
    {
        case 1:
            keyTimesString = @"0;1;";
            keySplinesString = @"0 0 1 1;";
            keyPointsString = @"";
            break;

        case 2:
            keyTimesString = @"0;1;";
            keySplinesString = @"0.5 0 0.5 1;";
            keyPointsString = @"";
            break;

        case 3:
            keyTimesString = @"0;1;";
            keySplinesString = @"0 0.75 0.25 1;";
            keyPointsString = @"";
            break;

        case 4:
            keyTimesString = @"0;1;";
            keySplinesString = @"0 0.25 1 0.75;";
            keyPointsString = @"";
            break;

        case 5:
            keyTimesString = @"0;1;";
            keySplinesString = @"0 0 0 1;";
            keyPointsString = @"";
            break;

        case 6:
            keyTimesString = @"0;1;";
            keySplinesString = @"0 0 1 0;";
            keyPointsString = @"";
            break;

        case 7:
            keyTimesString = @"0;1;";
            keySplinesString = @"1 0 0.25 0.25;";
            keyPointsString = @"";
            break;

        default:
            break;
    }
    
    if (presetIndex > 0)
    {
        [self loadValuesForKeyTimes:keyTimesString keySplines:keySplinesString keyPoints:keyPointsString];
    }
}

//==================================================================================
//	loadKeyValuesData
//==================================================================================

- (void)loadKeyValuesData
{
    NSXMLElement * animateElement = animateElementEditor.pluginTargetXMLElement;

    NSString * keyTimesString = @"";
    NSXMLNode * keyTimesNode = [animateElement attributeForName:@"keyTimes"];
    if (keyTimesNode != NULL)
    {
        keyTimesString = keyTimesNode.stringValue;
    }

    NSString * keySplinesString = @"";
    NSXMLNode * keySplinesNode = [animateElement attributeForName:@"keySplines"];
    if (keySplinesNode != NULL)
    {
        keySplinesString = keySplinesNode.stringValue;
    }

    NSString * keyPointsString = @"";
    NSXMLNode * keyPointsNode = [animateElement attributeForName:@"keyPoints"];
    if (keyPointsNode != NULL)
    {
        keyPointsString = keyPointsNode.stringValue;
    }

    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    keyTimesString = [keyTimesString stringByTrimmingCharactersInSet:whitespaceSet];
    keySplinesString = [keySplinesString stringByTrimmingCharactersInSet:whitespaceSet];
    keyPointsString = [keyPointsString stringByTrimmingCharactersInSet:whitespaceSet];
    
    [self loadValuesForKeyTimes:keyTimesString keySplines:keySplinesString keyPoints:keyPointsString];
}

//==================================================================================
//	loadValuesForKeyTimes:keySplines:keyPoints:
//==================================================================================

- (void)loadValuesForKeyTimes:(NSString *)keyTimesString keySplines:(NSString *)keySplinesString
        keyPoints:(NSString *)keyPointsString
{
    NSArray * keyTimesArray = [keyTimesString componentsSeparatedByString:@";"];
    NSArray * keySplinesArray = [keySplinesString componentsSeparatedByString:@";"];
    NSArray * keyPointsArray = [keyPointsString componentsSeparatedByString:@";"];
    
    NSInteger keyTimesArrayCount = [self countValidElements:keyTimesArray];
    NSInteger keySplinesArrayCount = [self countValidElements:keySplinesArray];
    NSInteger keyPointsArrayCount = [self countValidElements:keyPointsArray];
    
    NSInteger rowsCount = keyTimesArrayCount;
    if (keySplinesArrayCount > rowsCount)
    {
        rowsCount = keySplinesArrayCount;
    }
    if (keyPointsArrayCount > rowsCount)
    {
        rowsCount = keyPointsArrayCount;
    }
    
    [self.keyValuesArray removeAllObjects];
    
    for (NSInteger i = 0; i < rowsCount; i++)
    {
        NSString * keyTimesString = @"";
        if (i < keyTimesArrayCount)
        {
            keyTimesString = keyTimesArray[i];
        }

        NSString * keySplinesString = @"";
        if (i < keySplinesArrayCount)
        {
            keySplinesString = keySplinesArray[i];
        }

        NSString * keyPointsString = @"";
        if (i < keyPointsArrayCount)
        {
            keyPointsString = keyPointsArray[i];
        }
        
        NSMutableDictionary * keyValuesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                keyTimesString, @"keyTimes",
                keySplinesString, @"keySplines",
                keyPointsString, @"keyPoints",
                nil];
        
        [self.keyValuesArray addObject:keyValuesDictionary];
    }
    
    [keyValuesTableView reloadData];
    
    [keySplinesView setNeedsDisplay:YES];
}

//==================================================================================
//	addRowButtonAction:
//==================================================================================

- (IBAction)addRowButtonAction:(id)sender
{
}

//==================================================================================
//	deleteRowButtonAction:
//==================================================================================

- (IBAction)deleteRowButtonAction:(id)sender
{
}

@end
