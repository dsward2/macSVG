//
//  KeyValuesPopoverViewController.m
//  MacSVGPlugin
//
//  Created by Douglas Ward on 10/12/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

/*

Notes from the SVG spec -

 keyTimes = "<list>"
    A semicolon-separated list of time values used to control the pacing of the animation. Each time in the list corresponds to a value in the ‘values’ attribute list, and defines when the value is used in the animation function. Each time value in the ‘keyTimes’ list is specified as a floating point value between 0 and 1 (inclusive), representing a proportional offset into the simple duration of the animation element.
    For animations specified with a ‘values’ list, the ‘keyTimes’ attribute if specified must have exactly as many values as there are in the ‘values’ attribute. For from/to/by animations, the ‘keyTimes’ attribute if specified must have two values.

    Each successive time value must be greater than or equal to the preceding time value.

    The ‘keyTimes’ list semantics depends upon the interpolation mode:

    For linear and spline animation, the first time value in the list must be 0, and the last time value in the list must be 1. The key time associated with each value defines when the value is set; values are interpolated between the key times.
    For discrete animation, the first time value in the list must be 0. The time associated with each value defines when the value is set; the animation function uses that value until the next time defined in ‘keyTimes’.

 keySplines = "<list>"
     A set of Bézier control points associated with the ‘keyTimes’ list, defining a cubic Bézier function that controls interval pacing. The attribute value is a semicolon-separated list of control point descriptions. Each control point description is a set of four values: x1 y1 x2 y2, describing the Bézier control points for one time segment. Note: SMIL allows these values to be separated either by commas with optional whitespace, or by whitespace alone. The ‘keyTimes’ values that define the associated segment are the Bézier "anchor points", and the ‘keySplines’ values are the control points. Thus, there must be one fewer sets of control points than there are ‘keyTimes’.

     The values must all be in the range 0 to 1.

 keyPoints = "<list-of-numbers>" (for animateMotion element only)
     ‘keyPoints’ takes a semicolon-separated list of floating point values between 0 and 1 and indicates how far along the motion path the object shall move at the moment in time specified by corresponding ‘keyTimes’ value. Distance calculations use the user agent's distance along the path algorithm. Each progress value in the list corresponds to a value in the ‘keyTimes’ attribute list.

     If a list of ‘keyPoints’ is specified, there must be exactly as many values in the ‘keyPoints’ list as in the ‘keyTimes’ list.
*/

#import "KeyValuesPopoverViewController.h"
#import "MacSVGPlugin.h"
#import "KeySplinesView.h"
#import "KeyValuesTableRowView.h"

@interface KeyValuesPopoverViewController ()

@end

@implementation KeyValuesPopoverViewController

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
//    initWithNibName:bundle:
//==================================================================================

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
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

    if (isAwake == NO)
    {
        isAwake = YES;
        
        self.keyValuesArray = [NSMutableArray array];
        
        // load xib file containing view from framework
        NSString * frameworksPath = [[NSBundle mainBundle] privateFrameworksPath];
        NSString * plugInsFrameworkPath = [frameworksPath stringByAppendingPathComponent:@"MacSVGPlugin.framework"];
        NSString * plugInsPath = [plugInsFrameworkPath stringByAppendingPathComponent:@"PlugIns"];
        NSString * plugInsBundlePath = [plugInsPath stringByAppendingPathComponent:@"MacSVGPluginBundle.bundle"];
        NSBundle * bundle = [NSBundle bundleWithPath:plugInsBundlePath];
        
        NSArray * topLevelObjects = NULL;
        
        if (bundle != NULL)
        {
            BOOL loadResult = [bundle loadNibNamed:@"AnimationKeysView" owner:self topLevelObjects:&topLevelObjects];
            
            for (id nibObject in topLevelObjects)
            {
                if ([nibObject isKindOfClass:[NSView class]] == YES)
                {
                    self.view = nibObject;
                    break;
                }
            }
        }
        else
        {
            NSLog(@"Error - MacSVGPluginBundle.bundle not found");
        }
    }
}

//==================================================================================
//  viewWillAppear
//==================================================================================

- (void)viewWillAppear
{
    self.keyValuesTableView.delegate = self;
    self.keyValuesTableView.dataSource = self;
    [self.keyValuesTableView reloadData];

    NSInteger numberOfRows = [self numberOfRowsInTableView:self.keyValuesTableView];
    for (NSInteger i = 0; i < numberOfRows; i++)
    {
        NSInteger keySplinesTableColumnIndex = [self.keyValuesTableView columnWithIdentifier:@"keySplinesColumn"];
        NSView * cellView = [self.keyValuesTableView viewAtColumn:keySplinesTableColumnIndex row:i makeIfNecessary:YES];
        NSArray * subviews = cellView.subviews;
        for (NSView * aSubview in subviews)
        {
            if ([aSubview isKindOfClass:[KeySplinesView class]] == YES)
            {
                [aSubview setNeedsDisplay:YES];
                break;
            }
        }
    }
}

//==================================================================================
//    tableView:rowViewForRow:
//==================================================================================

- (NSTableRowView *)tableView:(NSTableView *)tableView
                rowViewForRow:(NSInteger)row
{
    // from http://stackoverflow.com/questions/10910779/coloring-rows-in-view-based-nstableview
    static NSString* const kRowIdentifier = @"KeyValuesTableRowView";
    
    KeyValuesTableRowView * rowView = [tableView makeViewWithIdentifier:kRowIdentifier owner:NULL];

    if (rowView == NULL)
    {
        // Size doesn't matter, the table will set it
        rowView = [[KeyValuesTableRowView alloc] initWithFrame:NSZeroRect];

        // This seemingly magical line enables your view to be found
        // next time "makeViewWithIdentifier" is called.
        rowView.identifier = kRowIdentifier;
    }

    // Can customize properties here. Note that customizing
    // 'backgroundColor' isn't going to work at this point since the table
    // will reset it later. Use 'didAddRow' to customize if desired.

    return rowView;
}
//==================================================================================
//	numberOfRowsInTableView
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return self.keyValuesArray.count;
}

//==================================================================================
//    tableView:viewForTableColumn:row:
//==================================================================================

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString * tableColumnIdentifier = tableColumn.identifier;
    
    NSString * cellViewIdentifier = @"";
    
    if ([tableColumnIdentifier isEqualToString:@"rowNumberColumn"] == YES)
    {
        cellViewIdentifier = @"rowNumberCellView";
    }
    else if ([tableColumnIdentifier isEqualToString:@"keyTimesColumn"] == YES)
    {
        cellViewIdentifier = @"keyTimesCellView";
    }
    else if ([tableColumnIdentifier isEqualToString:@"keySplinesColumn"] == YES)
    {
        cellViewIdentifier = @"keySplinesCellView";
    }
    else if ([tableColumnIdentifier isEqualToString:@"keyPointsColumn"] == YES)
    {
        cellViewIdentifier = @"keyPointsCellView";
    }
        
    //NSTableCellView * tableCellView = (NSTableCellView *)[tableView makeViewWithIdentifier:tableColumnIdentifier owner:self];
    NSTableCellView * tableCellView = (NSTableCellView *)[tableView makeViewWithIdentifier:cellViewIdentifier owner:NULL];

    NSString * resultString = @"";

    if (tableCellView != NULL)
    {
        resultString = [self tableView:tableView objectValueForTableColumn:tableColumn row:row];
    
        if ([tableColumn.identifier isEqualToString:@"keySplinesColumn"] == YES)
        {
            NSArray * subviews = tableCellView.subviews;
            
            for (NSView * aSubview in subviews)
            {
                if ([aSubview isKindOfClass:[NSComboBox class]] == YES)
                {
                    NSComboBox * comboBox = (NSComboBox *)aSubview;
                    
                    comboBox.stringValue = resultString;
                    comboBox.target = self;
                    comboBox.action = @selector(tableCellChanged:);
                    
                    if (row < self.keyValuesArray.count -1)
                    {
                        comboBox.editable = YES;
                        comboBox.enabled = YES;
                    }
                    else
                    {
                        comboBox.editable = NO;
                        comboBox.enabled = NO;
                    }
                }
                else if ([aSubview isKindOfClass:[KeySplinesView class]] == YES)
                {
                    KeySplinesView * keySplinesView = (KeySplinesView *)aSubview;
                    keySplinesView.keyValuesPopoverViewController = self.macSVGPlugin.keyValuesPopoverViewController;
                }
            }
        }
        else
        {
            tableCellView.textField.stringValue = resultString;
            tableCellView.textField.target = self;
            tableCellView.textField.action = @selector(tableCellChanged:);
            
            if ([tableColumnIdentifier isEqualToString:@"keyTimesColumn"] == YES)
            {
                if (row == 0)
                {
                    tableCellView.textField.editable = NO;
                    tableCellView.textField.enabled = YES;
                    tableCellView.textField.stringValue = @"0";
                }
                else if (row == self.keyValuesArray.count - 1)
                {
                    tableCellView.textField.editable = NO;
                    tableCellView.textField.enabled = YES;
                    tableCellView.textField.stringValue = @"1";
                }
                else
                {
                    tableCellView.textField.editable = YES;
                    tableCellView.textField.enabled = YES;
                }
            }
            else if ([tableColumnIdentifier isEqualToString:@"keyPointsColumn"] == YES)
            {
                tableCellView.textField.editable = YES;
                tableCellView.textField.enabled = YES;
            }
            else if ([tableColumnIdentifier isEqualToString:@"rowNumberColumn"] == YES)
            {
                tableCellView.textField.editable = NO;
                tableCellView.textField.enabled = YES;
                tableCellView.textField.stringValue = [NSString stringWithFormat:@"%ld", row + 1];
            }
            else
            {
                tableCellView.textField.editable = NO;
                tableCellView.textField.enabled = YES;
            }
        }
    }

    return (NSView *)tableCellView;
}

//==================================================================================
//	tableView:objectValueForTableColumn:rowIndex
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    id objectValue = @"";
    
    if (rowIndex < self.keyValuesArray.count)
    {
        NSMutableDictionary * keyValuesDictionary = (self.keyValuesArray)[rowIndex];
        
        if (keyValuesDictionary != NULL)
        {
            if ([aTableColumn.identifier isEqualToString:@"rowNumberColumn"] == YES)
            {
                objectValue = [NSString stringWithFormat:@"%ld", (rowIndex + 1)];
            }
            else if ([aTableColumn.identifier isEqualToString:@"keyTimesColumn"] == YES)
            {
                objectValue = keyValuesDictionary[@"keyTimes"];
            }
            else if ([aTableColumn.identifier isEqualToString:@"keySplinesColumn"] == YES)
            {
                objectValue = keyValuesDictionary[@"keySplines"];
            }
            else if ([aTableColumn.identifier isEqualToString:@"keyPointsColumn"] == YES)
            {
                objectValue = keyValuesDictionary[@"keyPoints"];
            }
        }
    }
    else
    {
        NSLog(@"KeyValuesPopoverViewController - objectValueForTableColumn - row value is out of bounds for array");
    }
    
    return objectValue;
}

//==================================================================================
//    tableCellChanged:
//==================================================================================

- (IBAction)tableCellChanged:(id)sender
{
    NSControl * aControl = sender;

    NSArray * tableColumns = [self.keyValuesTableView tableColumns];
    NSInteger tableColumnIndex = aControl.tag;
    NSTableColumn * aTableColumn = [tableColumns objectAtIndex:tableColumnIndex];

    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSInteger rowIndex = [self.keyValuesTableView rowForView:sender];

    if (rowIndex >= 0)
    {
        NSString * columnIdentifier = aTableColumn.identifier;
        NSMutableDictionary * keyValuesDictionary = (self.keyValuesArray)[rowIndex];

        if ([columnIdentifier isEqualToString:@"keyTimesColumn"] == YES)
        {
            NSTextField * cellTextField = sender;
            NSString * trimmedString = [cellTextField.stringValue stringByTrimmingCharactersInSet:whitespaceSet];
            keyValuesDictionary[@"keyTimes"] = trimmedString;
        }
        else if ([columnIdentifier isEqualToString:@"keySplinesColumn"] == YES)
        {
            NSComboBox * comboBox = sender;
            NSString * rawKeySplinesString = comboBox.stringValue;
            NSMutableString * keySplineString = [NSMutableString string];
            for (NSInteger i = 0; i < rawKeySplinesString.length; i++)
            {
                unichar aChar = [rawKeySplinesString characterAtIndex:i];
                BOOL isValidChar = NO;
                if (aChar >= '0')
                {
                    if (aChar <= '9')
                    {
                        isValidChar = YES;
                    }
                }
                if (aChar == '.')
                {
                    isValidChar = YES;
                }
                if (aChar == ' ')
                {
                    isValidChar = YES;
                }
                if (aChar == ',')
                {
                    isValidChar = YES;
                }
                
                if (isValidChar == YES)
                {
                    [keySplineString appendFormat:@"%C", aChar];
                }
            }
            NSString * trimmedString = [keySplineString stringByTrimmingCharactersInSet:whitespaceSet];
            keyValuesDictionary[@"keySplines"] = trimmedString;
            
            NSIndexSet * selectedRowIndexSet = [NSIndexSet indexSetWithIndex:rowIndex];
            [self.keyValuesTableView selectRowIndexes:selectedRowIndexSet byExtendingSelection:NO];
            
            comboBox.stringValue = trimmedString;
        }
        else if ([columnIdentifier isEqualToString:@"keyPointsColumn"] == YES)
        {
            NSTextField * cellTextField = sender;
            NSString * trimmedString = [cellTextField.stringValue stringByTrimmingCharactersInSet:whitespaceSet];
            keyValuesDictionary[@"keyPoints"] = trimmedString;
        }
    }
    
    NSInteger numberOfRows = [self numberOfRowsInTableView:self.keyValuesTableView];
    for (NSInteger i = 0; i < numberOfRows; i++)
    {
        NSInteger keySplinesTableColumnIndex = [self.keyValuesTableView columnWithIdentifier:@"keySplinesColumn"];
        NSView * cellView = [self.keyValuesTableView viewAtColumn:keySplinesTableColumnIndex row:i makeIfNecessary:YES];        
        NSArray * subviews = cellView.subviews;
        for (NSView * aSubview in subviews)
        {
            if ([aSubview isKindOfClass:[KeySplinesView class]] == YES)
            {
                [aSubview setNeedsDisplay:YES];
                break;
            }
        }
    }
}



//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = aNotification.object;
	if (aTableView == self.keyValuesTableView)
	{
	}
}

//==================================================================================
//    cancelButtonAction
//==================================================================================

- (IBAction)cancelButtonAction:(id)sender
{
    [self.macSVGPlugin.keyValuesPopover performClose:self];
}

//==================================================================================
//    doneButtonAction
//==================================================================================

- (IBAction)doneButtonAction:(id)sender
{
    [self.macSVGPlugin.keyValuesPopover performClose:self];
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
//    removeTrailingSemicolon:
//==================================================================================

- (NSString *)removeTrailingSemicolons:(NSString *)listString
{
    NSMutableString * mutableListString = [listString mutableCopy];
    BOOL doSearch = mutableListString.length > 0;
    while (doSearch == YES)
    {
        unichar lastCharacter = [mutableListString characterAtIndex:(mutableListString.length - 1)];
        if (lastCharacter == ';')
        {
            [mutableListString deleteCharactersInRange:NSMakeRange((mutableListString.length - 1), 1)];
            doSearch = mutableListString.length > 0;
        }
        else
        {
            doSearch = NO;
        }
    }
    return [NSString stringWithString:mutableListString];
}

//==================================================================================
//    removeTrailingZeros:
//==================================================================================

- (NSString *)removeTrailingZeros:(NSString *)listString
{
    NSMutableString * mutableListString = [listString mutableCopy];
    
    if (mutableListString.floatValue == 0.0f)
    {
        mutableListString = [NSMutableString stringWithString:@"0"];
    }
    else
    {
        BOOL doSearch = mutableListString.length > 0;
        while (doSearch == YES)
        {
            unichar lastCharacter = [mutableListString characterAtIndex:(mutableListString.length - 1)];
            if (lastCharacter == '0')
            {
                [mutableListString deleteCharactersInRange:NSMakeRange((mutableListString.length - 1), 1)];
                doSearch = mutableListString.length > 0;
            }
            else if (lastCharacter == '.')
            {
                [mutableListString deleteCharactersInRange:NSMakeRange((mutableListString.length - 1), 1)];
                doSearch = mutableListString.length > 0;
            }
            else
            {
                doSearch = NO;
            }
        }
    }
    
    return [NSString stringWithString:mutableListString];
}


//==================================================================================
//    validRowsCount:
//==================================================================================

- (NSInteger)validRowsCount:(NSArray *)valuesArray
{
    NSInteger validRowsCount = 0;

    NSXMLElement * targetElement = self.macSVGPlugin.pluginTargetXMLElement;

    NSXMLNode * valuesNode = [targetElement attributeForName:@"values"];
    if (valuesNode != NULL)
    {
        if (valuesArray.count <= 1)
        {
            NSString * valuesString = valuesNode.stringValue;
            valuesString = [self removeTrailingSemicolons:valuesString];
            NSArray * valuesStringArray = [valuesString componentsSeparatedByString:@";"];
            if (valuesStringArray.count >= 2)
            {
                validRowsCount = valuesStringArray.count;
            }
        }
        else
        {
            validRowsCount = valuesArray.count;
        }
    }
    else
    {
        NSXMLNode * fromNode = [targetElement attributeForName:@"from"];
        if (fromNode != NULL)
        {
            NSXMLNode * toNode = [targetElement attributeForName:@"to"];
            if (toNode != NULL)
            {
                validRowsCount = 2;
            }
        }
    }
    
    return validRowsCount;
}

//==================================================================================
//	loadKeyValuesData
//==================================================================================

- (void)loadKeyValuesDataForValidRowsCount:(NSInteger)validRowsCount
{
    NSXMLElement * targetElement = self.macSVGPlugin.pluginTargetXMLElement;
    
    if (targetElement == NULL)
    {
        NSLog(@"KeyValuesPopoverViewController - loadKeyValuesData - targetElement is NULL");
    }

    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSString * keyTimesString = @"";
    NSXMLNode * keyTimesNode = [targetElement attributeForName:@"keyTimes"];
    if (keyTimesNode != NULL)
    {
        keyTimesString = keyTimesNode.stringValue;
    }
    keyTimesString = [keyTimesString stringByTrimmingCharactersInSet:whitespaceSet];
    keyTimesString = [self removeTrailingSemicolons:keyTimesString];

    NSString * keySplinesString = @"";
    NSXMLNode * keySplinesNode = [targetElement attributeForName:@"keySplines"];
    if (keySplinesNode != NULL)
    {
        keySplinesString = keySplinesNode.stringValue;
    }
    keySplinesString = [keySplinesString stringByTrimmingCharactersInSet:whitespaceSet];
    keySplinesString = [self removeTrailingSemicolons:keySplinesString];

    NSString * keyPointsString = @"";
    NSXMLNode * keyPointsNode = [targetElement attributeForName:@"keyPoints"];
    if (keyPointsNode != NULL)
    {
        keyPointsString = keyPointsNode.stringValue;
    }
    keyPointsString = [keyPointsString stringByTrimmingCharactersInSet:whitespaceSet];
    keyPointsString = [self removeTrailingSemicolons:keyPointsString];

    [self loadValuesForKeyTimes:keyTimesString keySplines:keySplinesString keyPoints:keyPointsString validRowsCount:validRowsCount];
}

//==================================================================================
//	loadValuesForKeyTimes:keySplines:keyPoints:validRowsCount:
//==================================================================================

- (void)loadValuesForKeyTimes:(NSString *)keyTimesString keySplines:(NSString *)keySplinesString
        keyPoints:(NSString *)keyPointsString validRowsCount:(NSInteger)validRowsCount
{
    if (validRowsCount >= 2)
    {
        NSArray * keyTimesArray = [keyTimesString componentsSeparatedByString:@";"];
        NSArray * keySplinesArray = [keySplinesString componentsSeparatedByString:@";"];
        NSArray * keyPointsArray = [keyPointsString componentsSeparatedByString:@";"];
        
        NSInteger keyTimesArrayCount = [self countValidElements:keyTimesArray];
        NSInteger keySplinesArrayCount = [self countValidElements:keySplinesArray];
        NSInteger keyPointsArrayCount = [self countValidElements:keyPointsArray];
        
        if (keyTimesArrayCount != validRowsCount)
        {
            float timeInterval = 1.0f / ((float)validRowsCount - 1.0f);
            float nextTime = 0.0f;
            
            NSMutableArray * newKeyTimesArray = [NSMutableArray array];
            
            for (NSInteger i = 0; i < validRowsCount; i++)
            {
                NSString * nextTimeString = [NSString stringWithFormat:@"%f", nextTime];
                nextTimeString = [self removeTrailingZeros:nextTimeString];
                [newKeyTimesArray addObject:nextTimeString];
                
                nextTime += timeInterval;
                
                if (i >= validRowsCount - 1)
                {
                    nextTime = 1.0f;
                }
            }
            
            keyTimesArray = [NSArray arrayWithArray:newKeyTimesArray];
            keyTimesArrayCount = [self countValidElements:keyTimesArray];
        }

        if (keySplinesArrayCount != (validRowsCount - 1))
        {
            NSMutableArray * newKeySplinesArray = [NSMutableArray array];
            
            for (NSInteger i = 0; i < validRowsCount - 1; i++)  // keySplines count must be keyTimes count - 1
            {
                NSString * nextKeySplinesString = @"";
                [newKeySplinesArray addObject:nextKeySplinesString];
            }
            
            keySplinesArray = [NSArray arrayWithArray:newKeySplinesArray];
            keySplinesArrayCount = [self countValidElements:keySplinesArray];
        }

        if (keyPointsArrayCount != validRowsCount)
        {
            NSMutableArray * newKeyPointsArray = [NSMutableArray array];
            
            for (NSInteger i = 0; i < validRowsCount; i++)
            {
                NSString * nextKeyPointsString = @"";
                [newKeyPointsArray addObject:nextKeyPointsString];
            }
            
            keyPointsArray = [NSArray arrayWithArray:newKeyPointsArray];
            keyPointsArrayCount = [self countValidElements:keyPointsArray];
        }

        [self.keyValuesArray removeAllObjects];
        
        for (NSInteger i = 0; i < validRowsCount; i++)
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
    }
    else
    {
        [self.keyValuesArray removeAllObjects];
    }
    
    [self.keyValuesTableView reloadData];
}

//==================================================================================
//    popoverDidShow:
//==================================================================================

-(void)popoverDidShow:(NSNotification *)notification
{
}

//==================================================================================
//    popoverDidShow:
//==================================================================================

- (void)useKeyPoints:(BOOL)useKeyPoints
{
    self.keyPointsTableColumn.hidden = !useKeyPoints;
}


@end
