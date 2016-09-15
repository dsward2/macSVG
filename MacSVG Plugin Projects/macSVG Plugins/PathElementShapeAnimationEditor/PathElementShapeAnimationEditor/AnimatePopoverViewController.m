//
//  AnimatePopoverViewController.m
//  PathElementShapeAnimationEditor
//
//  Created by Douglas Ward on 8/15/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "AnimatePopoverViewController.h"
#import "PathElementShapeAnimationEditor.h"
#import "MacSVGPlugin/MacSVGPluginCallbacks.h"

@interface AnimatePopoverViewController ()

@end

@implementation AnimatePopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        createNewAnimateElement = NO;
    }
    return self;
}

//==================================================================================
//	numericStringWithFloat
//==================================================================================

- (NSString *)numericStringWithFloat:(float)attributeFloat
{
    NSString * numericString = @"0";

    numericString = [NSString stringWithFormat:@"%f", attributeFloat];
    
    NSRange decimalPointRange = [numericString rangeOfString:@"."];
    if (decimalPointRange.location != NSNotFound)
    {
        NSInteger index = [numericString length] - 1;
        BOOL continueTrim = YES;
        while (continueTrim == YES)
        {
            if ([numericString characterAtIndex:index] == '0')
            {
                index--;
            }
            else if ([numericString characterAtIndex:index] == '.')
            {
                index--;
                continueTrim = NO;
            }
            else
            {
                continueTrim = NO;
            }
            
            if (index < decimalPointRange.location)
            {
                continueTrim = NO;
            }
        }
        
        numericString = [numericString substringToIndex:index + 1];
    }
    

    return numericString;
}

//==================================================================================
//	numericStringWithAttributeString
//==================================================================================

- (NSString *)numericStringWithAttributeNode:(NSXMLNode *)attributeNode
{
    NSString * attributeString = [attributeNode stringValue];
    float attributeFloat = [attributeString floatValue];
    NSString * numericString = @"0";

    numericString = [NSString stringWithFormat:@"%f", attributeFloat];
    
    NSRange decimalPointRange = [numericString rangeOfString:@"."];
    if (decimalPointRange.location != NSNotFound)
    {
        NSInteger index = [numericString length] - 1;
        BOOL continueTrim = YES;
        while (continueTrim == YES)
        {
            if ([numericString characterAtIndex:index] == '0')
            {
                index--;
            }
            else if ([numericString characterAtIndex:index] == '.')
            {
                index--;
                continueTrim = NO;
            }
            else
            {
                continueTrim = NO;
            }
            
            if (index < decimalPointRange.location)
            {
                continueTrim = NO;
            }
        }
        
        numericString = [numericString substringToIndex:index + 1];
    }
    

    return numericString;
}

//==================================================================================
//	cancelButtonAction
//==================================================================================

- (IBAction)cancelButtonAction:(id)sender
{
    createNewAnimateElement = NO;

    [animatePopover performClose:self];

}

//==================================================================================
//	trimmedStringForTextField
//==================================================================================

- (NSString *)trimmedStringForTextField:(NSTextField *)aTextField
{
    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSString * result = [aTextField stringValue];
    
    result = [result stringByTrimmingCharactersInSet:whitespaceSet];
    
    return result;
}

//==================================================================================
//	formatBeginString:
//==================================================================================

- (NSString *)formatBeginString:(NSString *)beginString
{
    NSMutableString * formattedBeginString = [NSMutableString string];
    
    NSCharacterSet * separatorCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" ;"];

    NSArray * beginStringArray = [beginString componentsSeparatedByCharactersInSet:separatorCharacterSet];
    NSInteger beginStringArrayCount = [beginStringArray count];
    
    for (NSString * aTimeString in beginStringArray)
    {
        BOOL digitsFound = NO;
        BOOL nonDigitFound = NO;
        BOOL sFound = NO;
        NSInteger stringLength = [aTimeString length];
        for (NSInteger i = 0; i < stringLength; i++)
        {
            unichar aChar = [aTimeString characterAtIndex:i];
            
            BOOL matchFound = NO;
            
            if (aChar >= '0')
            {
                if (aChar <= '9')
                {
                    digitsFound = YES;
                    matchFound = YES;
                }
            }
            
            if (aChar == '.')
            {
                matchFound = YES;
            }
            
            if (matchFound == NO)
            {
                if (i == (stringLength - 1))
                {
                    if (aChar == 's')
                    {
                        if (nonDigitFound == NO)
                        {
                            sFound = YES;
                        }
                        else
                        {
                            nonDigitFound = YES;
                        }
                    }
                    else
                    {
                        nonDigitFound = YES;
                    }
                }
                else
                {
                    nonDigitFound = YES;
                }
            }
        }
        
        if (nonDigitFound == YES)
        {
            [formattedBeginString appendString:aTimeString];
            if (beginStringArrayCount > 1)
            {
                [formattedBeginString appendString:@"; "];
            }
        }
        else
        {
            [formattedBeginString appendString:aTimeString];
            if (sFound == NO)
            {
                [formattedBeginString appendString:@"s"];
            }
            if (beginStringArrayCount > 1)
            {
                [formattedBeginString appendString:@"; "];
            }
        }
    }
    
    return formattedBeginString;
}

//==================================================================================
//	formatBeginString:
//==================================================================================

- (NSString *)formatDurationString:(NSString *)durationString
{
    float durationFloat = [durationString floatValue];
    
    NSString * newDurationString = [self numericStringWithFloat:durationFloat];

    NSString * formattedDurationString = [NSString stringWithFormat:@"%@s", newDurationString];

    return formattedDurationString;
}

//==================================================================================
//	doneButtonAction
//==================================================================================

- (IBAction)doneButtonAction:(id)sender
{
    NSMutableDictionary * animateAttributesDictionary = [NSMutableDictionary dictionary];
    
    NSString * idString = [self trimmedStringForTextField:animateElementIDTextField];
    [animateAttributesDictionary setObject:idString forKey:@"id"];

    NSString * beginString = [self trimmedStringForTextField:beginAtTimesTextField];
    beginString = [self formatBeginString:beginString];
    [animateAttributesDictionary setObject:beginString forKey:@"begin"];

    NSString * durString = [self trimmedStringForTextField:durationTextField];
    durString = [self formatDurationString:durString];
    [animateAttributesDictionary setObject:durString forKey:@"dur"];

    NSString * repeatCountString = [self trimmedStringForTextField:repeatCountTextField];
    [animateAttributesDictionary setObject:repeatCountString forKey:@"repeatCount"];

    NSInteger repeatCountColumn = [repeatCountMatrix selectedColumn];
    if (repeatCountColumn == 1)
    {
        NSString * repeatCountString = [self trimmedStringForTextField:repeatCountTextField];
        [animateAttributesDictionary setObject:repeatCountString forKey:@"repeatCount"];
    }
    else
    {
        [animateAttributesDictionary setObject:@"indefinite" forKey:@"repeatCount"];
    }
    
    NSString * fillString = [fillPopUpButton titleOfSelectedItem];
    if (fillString == NULL) fillString = @"";
    [animateAttributesDictionary setObject:fillString forKey:@"fill"];
    
    if (createNewAnimateElement == YES)
    {
        [pathElementShapeAnimationEditor createNewAnimateElement];
    
        createNewAnimateElement = NO;
    }
    
    [pathElementShapeAnimationEditor setAttributesWithDictionary:animateAttributesDictionary];

    [animatePopover performClose:self];
}

//==================================================================================
//	loadSettingsForNewAnimateElement
//==================================================================================

-(void)loadSettingsForNewAnimateElement
{
    createNewAnimateElement = YES;

    NSString * idString =
            [pathElementShapeAnimationEditor.macSVGPluginCallbacks
            uniqueIDForElementTagName:@"animate" pendingIDs:NULL];
    //NSString * idString = @"UnknownID";
    [animateElementIDTextField setStringValue:idString];

    NSString * beginString = @"0s";
    [beginAtTimesTextField setStringValue:beginString];

    NSString * durString = @"1";
    [durationTextField setStringValue:durString];

    [repeatCountMatrix selectCellAtRow:0 column:0];

    NSString * repeatCountString = @"0";
    [repeatCountTextField setStringValue:repeatCountString];

    NSString * fillString = @"freeze";
    [fillPopUpButton selectItemWithTitle:fillString];
}

//==================================================================================
//	loadSettingsForAnimateElement:
//==================================================================================

-(void)loadSettingsForAnimateElement:(NSXMLElement *)animateElement
{
    createNewAnimateElement = NO;

    NSString * idString = @"UnknownID";
    NSXMLNode * idAttributeNode = [animateElement attributeForName:@"id"];
    if (idAttributeNode != NULL)
    {
        idString = [idAttributeNode stringValue];
    }
    [animateElementIDTextField setStringValue:idString];
    
    NSString * beginString = @"";
    NSXMLNode * beginAttributeNode = [animateElement attributeForName:@"begin"];
    if (beginAttributeNode != NULL)
    {
        beginString = [beginAttributeNode stringValue];
    }
    [beginAtTimesTextField setStringValue:beginString];
    
    NSString * durString = @"";
    NSXMLNode * durAttributeNode = [animateElement attributeForName:@"dur"];
    if (durAttributeNode != NULL)
    {
        durString = [self numericStringWithAttributeNode:durAttributeNode];
    }
    [durationTextField setStringValue:durString];
    
    NSString * repeatCountString = @"";
    NSXMLNode * repeatCountAttributeNode = [animateElement attributeForName:@"repeatCount"];
    if (repeatCountAttributeNode != NULL)
    {
        repeatCountString = [repeatCountAttributeNode stringValue];
    }
    if ([repeatCountString isEqualToString:@"indefinite"] == YES)
    {
        [repeatCountMatrix selectCellAtRow:1 column:0];
        [repeatCountTextField setStringValue:@""];
    }
    else
    {
        [repeatCountMatrix selectCellAtRow:0 column:0];
        [repeatCountTextField setStringValue:repeatCountString];
    }
    
    NSString * fillString = @"";
    NSXMLNode * fillAttributeNode = [animateElement attributeForName:@"fill"];
    if (fillAttributeNode != NULL)
    {
        fillString = [fillAttributeNode stringValue];
    }
    [fillPopUpButton selectItemWithTitle:fillString];    
}

@end
