//
//  TextStylesPopoverViewController.m
//  TextElementEditor
//
//  Created by Douglas Ward on 8/19/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "TextStylesPopoverViewController.h"
#import "TextElementEditor.h"
#import <MacSVGPlugin/MacSVGPluginCallbacks.h>

@interface TextStylesPopoverViewController ()

@end

@implementation TextStylesPopoverViewController

//==================================================================================
//	initWithNibName:bundle:
//==================================================================================

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
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
//	unitForAttribute:
//==================================================================================

- (NSString *)unitForAttributeNode:(NSXMLNode *)attributeNode
{
    NSString * attributeString = [attributeNode stringValue];

    NSString * resultUnit = @"px";
    NSRange unitRange = NSMakeRange(NSNotFound, NSNotFound);
    
    unitRange = [attributeString rangeOfString:@"em"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"em";
    }
    unitRange = [attributeString rangeOfString:@"ex"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"ex";
    }
    unitRange = [attributeString rangeOfString:@"px"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"px";
    }
    unitRange = [attributeString rangeOfString:@"pt"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"pt";
    }
    unitRange = [attributeString rangeOfString:@"pc"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"pc";
    }
    unitRange = [attributeString rangeOfString:@"cm"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"cm";
    }
    unitRange = [attributeString rangeOfString:@"mm"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"mm";
    }
    unitRange = [attributeString rangeOfString:@"in"];
    if (unitRange.location != NSNotFound)
    {
        resultUnit = @"in";
    }
    
    return resultUnit;
}

//==================================================================================
//	doneButtonAction
//==================================================================================

- (IBAction)doneButtonAction:(id)sender
{
    [self applyTextStyles];
    
    [textElementEditor updateDocumentViews];

    [textStylesPopover performClose:self];
}

//==================================================================================
//	cancelButtonAction
//==================================================================================

- (IBAction)cancelButtonAction:(id)sender
{
    [textStylesPopover performClose:self];
}

//==================================================================================
//	hexadecimalValueOfAnNSColor:
//==================================================================================

-(NSString *)hexadecimalValueOfAnNSColor:(NSColor *)aColor
{
    CGFloat redFloatValue, greenFloatValue, blueFloatValue;
    int redIntValue, greenIntValue, blueIntValue;
    NSString *redHexValue, *greenHexValue, *blueHexValue;

    // Convert the NSColor to the RGB color space before we can access its components
    NSColor * convertedColor = [aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

    if(convertedColor)
    {
        // Get the red, green, and blue components of the color
        [convertedColor getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];

        // Convert the components to numbers (unsigned decimal integer) between 0 and 255
        redIntValue = redFloatValue * 255.99999f;
        greenIntValue = greenFloatValue * 255.99999f;
        blueIntValue = blueFloatValue * 255.99999f;

        // Convert the numbers to hex strings
        redHexValue=[NSString stringWithFormat:@"%02x", redIntValue]; 
        greenHexValue=[NSString stringWithFormat:@"%02x", greenIntValue];
        blueHexValue=[NSString stringWithFormat:@"%02x", blueIntValue];

        // Concatenate the red, green, and blue components' hex strings together with a "#"
        return [NSString stringWithFormat:@"#%@%@%@", redHexValue, greenHexValue, blueHexValue];
    }
    return nil;
}

//==================================================================================
//	addShadowButtonAction
//==================================================================================

- (IBAction)addShadowButtonAction:(id)sender
{
    // e.g., text-shadow: 2px 2px 3px #ff0000;

    NSString * horizontalOffsetString = [horizontalOffsetTextField stringValue];
    NSString * horizontalOffsetUnitString = [horizontalOffsetUnitPopUpButton titleOfSelectedItem];
    
    NSString * verticalOffsetString = [verticalOffsetTextField stringValue];
    NSString * verticalOffsetUnitString = [verticalOffsetUnitPopUpButton titleOfSelectedItem];
    
    NSString * blurRadiusString = [blurRadiusTextField stringValue];
    NSString * blurRadiusUnitString = [blurRadiusUnitPopUpButton titleOfSelectedItem];

    NSColor * shadowColor = [shadowColorWell color];
    NSString * hexColorString = [self hexadecimalValueOfAnNSColor:shadowColor];
    
    NSInteger horizontalOffsetStringLength = [horizontalOffsetString length];
    NSInteger verticalOffsetStringLength = [verticalOffsetString length];
    
    if ((horizontalOffsetStringLength > 0) && (verticalOffsetStringLength > 0))
    {
        NSMutableString * textShadowString = [NSMutableString stringWithString:@" text-shadow: "];
        
        [textShadowString appendString:horizontalOffsetString];
        [textShadowString appendString:horizontalOffsetUnitString];
        
        [textShadowString appendString:@" "];
        [textShadowString appendString:verticalOffsetString];
        [textShadowString appendString:verticalOffsetUnitString];
        
        [textShadowString appendString:@" "];
        [textShadowString appendString:blurRadiusString];
        [textShadowString appendString:blurRadiusUnitString];

        [textShadowString appendString:@" "];
        [textShadowString appendString:hexColorString];
        [textShadowString appendString:@";"];

        NSString * cssStyleString = [cssStyleTextView string];
        
        NSString * newCssStyleString = [cssStyleString stringByAppendingString:textShadowString];
        
        [cssStyleTextView setString:newCssStyleString];
    }
}

//==================================================================================
//	loadTextStyles
//==================================================================================

- (void)loadTextStyles
{
    NSXMLElement * textElement = [textElementEditor pluginTargetXMLElement];
    
    NSXMLNode * textStyleAttributeNode = [textElement attributeForName:@"text-style"];
    if (textStyleAttributeNode != NULL)
    {
        NSString * textStyleAttributeString = [textStyleAttributeNode stringValue];
        [fontStylePopUpButton selectItemWithTitle:textStyleAttributeString];
    }
    else
    {
        [fontStylePopUpButton selectItemWithTitle:@""];
    }
    
    NSXMLNode * fontVariantAttributeNode = [textElement attributeForName:@"font-variant"];
    if (fontVariantAttributeNode != NULL)
    {
        NSString * fontVariantAttributeString = [fontVariantAttributeNode stringValue];
        [fontVariantPopUpButton selectItemWithTitle:fontVariantAttributeString];
    }
    else
    {
        [fontVariantPopUpButton selectItemWithTitle:@""];
    }
    
    NSXMLNode * fontWeightAttributeNode = [textElement attributeForName:@"font-weight"];
    if (fontWeightAttributeNode != NULL)
    {
        NSString * fontWeightAttributeString = [fontWeightAttributeNode stringValue];
        [fontWeightPopUpButton selectItemWithTitle:fontWeightAttributeString];
    }
    else
    {
        [fontWeightPopUpButton selectItemWithTitle:@""];
    }
    
    NSXMLNode * fontStretchAttributeNode = [textElement attributeForName:@"font-stretch"];
    if (fontStretchAttributeNode != NULL)
    {
        NSString * fontStretchAttributeString = [fontStretchAttributeNode stringValue];
        [fontStretchPopUpButton selectItemWithTitle:fontStretchAttributeString];
    }
    else
    {
        [fontStretchPopUpButton selectItemWithTitle:@""];
    }

    [underlineCheckboxButton setIntegerValue:0];
    [overlineCheckboxButton setIntegerValue:0];
    [lineThroughCheckboxButton setIntegerValue:0];
    [blinkCheckboxButton setIntegerValue:0];
    [inheritDecorationCheckboxButton setIntegerValue:0];

    NSXMLNode * textDecorationAttributeNode = [textElement attributeForName:@"text-decoration"];
    if (textDecorationAttributeNode != NULL)
    {
        NSString * textDecorationAttributeString = [textDecorationAttributeNode stringValue];

        //NSRange noneRange = [textDecorationAttributeString rangeOfString:@"none"];
        NSRange underlineRange = [textDecorationAttributeString rangeOfString:@"underline"];
        NSRange overlineRange = [textDecorationAttributeString rangeOfString:@"overline"];
        NSRange lineThroughRange = [textDecorationAttributeString rangeOfString:@"line-through"];
        NSRange blinkRange = [textDecorationAttributeString rangeOfString:@"blink"];
        NSRange inheritRange = [textDecorationAttributeString rangeOfString:@"inherit"];
        
        if (inheritRange.location != NSNotFound)
        {
            [inheritDecorationCheckboxButton setIntegerValue:1];
        }
        else
        {
            if (underlineRange.location != NSNotFound)
            {
                [underlineCheckboxButton setIntegerValue:1];
            }
            
            if (overlineRange.location != NSNotFound)
            {
                [overlineCheckboxButton setIntegerValue:1];
            }
            
            if (lineThroughRange.location != NSNotFound)
            {
                [lineThroughCheckboxButton setIntegerValue:1];
            }
            
            if (blinkRange.location != NSNotFound)
            {
                [blinkCheckboxButton setIntegerValue:1];
            }
        }
    }
    
    NSXMLNode * letterSpacingAttributeNode = [textElement attributeForName:@"letter-spacing"];
    if (letterSpacingAttributeNode != NULL)
    {
        NSString * letterSpacingAttributeString = [self numericStringWithAttributeNode:letterSpacingAttributeNode];
        NSString * letterSpacingUnitString = [self unitForAttributeNode:letterSpacingAttributeNode];
        
        [letterSpacingTextfield setStringValue:letterSpacingAttributeString];
        [letterSpacingUnitPopUpButton selectItemWithTitle:letterSpacingUnitString];
    }
    else
    {
        [letterSpacingTextfield setStringValue:@""];
        [letterSpacingUnitPopUpButton selectItemWithTitle:@"px"];
    }
    
    NSXMLNode * wordSpacingAttributeNode = [textElement attributeForName:@"word-spacing"];
    if (wordSpacingAttributeNode != NULL)
    {
        NSString * wordSpacingAttributeString = [self numericStringWithAttributeNode:wordSpacingAttributeNode];
        NSString * wordSpacingUnitString = [self unitForAttributeNode:wordSpacingAttributeNode];
        
        [wordSpacingTextfield setStringValue:wordSpacingAttributeString];
        [wordSpacingUnitPopUpButton selectItemWithTitle:wordSpacingUnitString];
    }
    else
    {
        [wordSpacingTextfield setStringValue:@""];
        [wordSpacingUnitPopUpButton selectItemWithTitle:@"px"];
    }

    
    NSXMLNode * cssStyleAttributeNode = [textElement attributeForName:@"style"];
    if (cssStyleAttributeNode != NULL)
    {
        NSString * cssStyleAttributeString = [cssStyleAttributeNode stringValue];
        
        [cssStyleTextView setString:cssStyleAttributeString];
    }
    else
    {
        [cssStyleTextView setString:@""];
    }

    // shadowColorWell retains existing color
    
    NSString * oldHorizontalOffsetString = [horizontalOffsetTextField stringValue];
    if ([oldHorizontalOffsetString length] == 0)
    {
        [horizontalOffsetTextField setStringValue:@"3"];
        [horizontalOffsetUnitPopUpButton selectItemWithTitle:@"px"];
    }
    
    NSString * oldVerticalOffsetString = [verticalOffsetTextField stringValue];
    if ([oldVerticalOffsetString length] == 0)
    {
        [verticalOffsetTextField setStringValue:@"3"];
        [verticalOffsetUnitPopUpButton selectItemWithTitle:@"px"];
    }
}

//==================================================================================
//	applyTextStyles
//==================================================================================

- (void)applyTextStyles
{
    NSXMLElement * textElement = [textElementEditor activeXMLTextElement];

    NSString * fontStyleAttributeString = [fontStylePopUpButton titleOfSelectedItem];
    if ([fontStyleAttributeString length] == 0)
    {
        [textElement removeAttributeForName:@"font-style"];
    }
    else
    {
        NSXMLNode * fontStyleAttributeNode = [textElement attributeForName:@"font-style"];
        if (fontStyleAttributeNode == NULL)
        {
            fontStyleAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            [fontStyleAttributeNode setName:@"font-style"];
            [textElement addAttribute:fontStyleAttributeNode];
        }
        [fontStyleAttributeNode setStringValue:fontStyleAttributeString];
    }

    NSString * fontVariantAttributeString = [fontVariantPopUpButton titleOfSelectedItem];
    if ([fontVariantAttributeString length] == 0)
    {
        [textElement removeAttributeForName:@"font-variant"];
    }
    else
    {
        NSXMLNode * fontVariantAttributeNode = [textElement attributeForName:@"font-variant"];
        if (fontVariantAttributeNode == NULL)
        {
            fontVariantAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            [fontVariantAttributeNode setName:@"font-variant"];
            [textElement addAttribute:fontVariantAttributeNode];
        }
        [fontVariantAttributeNode setStringValue:fontVariantAttributeString];
    }

    NSString * fontWeightAttributeString = [fontWeightPopUpButton titleOfSelectedItem];
    if ([fontWeightAttributeString length] == 0)
    {
        [textElement removeAttributeForName:@"font-weight"];
    }
    else
    {
        NSXMLNode * fontWeightAttributeNode = [textElement attributeForName:@"font-weight"];
        if (fontWeightAttributeNode == NULL)
        {
            fontWeightAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            [fontWeightAttributeNode setName:@"font-weight"];
            [textElement addAttribute:fontWeightAttributeNode];
        }
        [fontWeightAttributeNode setStringValue:fontWeightAttributeString];
    }
    
    NSString * fontStretchAttributeString = [fontStretchPopUpButton titleOfSelectedItem];
    if ([fontStretchAttributeString length] == 0)
    {
        [textElement removeAttributeForName:@"font-stretch"];
    }
    else
    {
        NSXMLNode * fontStretchAttributeNode = [textElement attributeForName:@"font-stretch"];
        if (fontStretchAttributeNode == NULL)
        {
            fontStretchAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            [fontStretchAttributeNode setName:@"font-stretch"];
            [textElement addAttribute:fontStretchAttributeNode];
        }
        [fontStretchAttributeNode setStringValue:fontStretchAttributeString];
    }
    
    NSInteger underlineCheckboxValue = [underlineCheckboxButton integerValue];
    NSInteger overlineCheckboxValue = [overlineCheckboxButton integerValue];
    NSInteger lineThroughCheckboxValue = [lineThroughCheckboxButton integerValue];
    NSInteger blinkCheckboxValue = [blinkCheckboxButton integerValue];
    NSInteger inheritCheckboxValue = [inheritDecorationCheckboxButton integerValue];

    NSInteger valuesSum = underlineCheckboxValue + overlineCheckboxValue +
            lineThroughCheckboxValue + blinkCheckboxValue + inheritCheckboxValue;
    if (valuesSum == 0)
    {
        [textElement removeAttributeForName:@"text-decoration"];
    }
    else
    {
        if (inheritCheckboxValue != 0)
        {
            NSXMLNode * textDecorationAttributeNode = [textElement attributeForName:@"text-decoration"];
            if (textDecorationAttributeNode == NULL)
            {
                textDecorationAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                [textDecorationAttributeNode setName:@"text-decoration"];
                [textElement addAttribute:textDecorationAttributeNode];
            }
            [textDecorationAttributeNode setStringValue:@"inherit"];
        }
        else
        {
            NSMutableString * decorationString = [NSMutableString string];
            
            if (underlineCheckboxValue != 0)
            {
                [decorationString appendString:@"underline"];
            }
            
            if (overlineCheckboxValue != 0)
            {
                if ([decorationString length] > 0)
                {
                    [decorationString appendString:@" "];
                }
                [decorationString appendString:@"overline"];
            }
            
            if (lineThroughCheckboxValue != 0)
            {
                if ([decorationString length] > 0)
                {
                    [decorationString appendString:@" "];
                }
                [decorationString appendString:@"line-through"];
            }
            
            if (blinkCheckboxValue != 0)
            {
                if ([decorationString length] > 0)
                {
                    [decorationString appendString:@" "];
                }
                [decorationString appendString:@"blink"];
            }

            NSXMLNode * textDecorationAttributeNode = [textElement attributeForName:@"text-decoration"];
            if (textDecorationAttributeNode == NULL)
            {
                textDecorationAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                [textDecorationAttributeNode setName:@"text-decoration"];
                [textElement addAttribute:textDecorationAttributeNode];
            }
            [textDecorationAttributeNode setStringValue:decorationString];
        }
    }

    NSString * letterSpacingAttributeString = [letterSpacingTextfield stringValue];
    if ([letterSpacingAttributeString length] == 0)
    {
        [textElement removeAttributeForName:@"letter-spacing"];
    }
    else
    {
        float letterSpacingFloat = [letterSpacingTextfield floatValue];
        NSString * numericLetterSpacingString = [self numericStringWithFloat:letterSpacingFloat];
        NSString * letterSpacingUnitString = [letterSpacingUnitPopUpButton titleOfSelectedItem];
        NSString * letterSpacingString = [NSString stringWithFormat:@"%@%@", numericLetterSpacingString, letterSpacingUnitString];
        NSXMLNode * letterSpacingAttributeNode = [textElement attributeForName:@"letter-spacing"];
        if (letterSpacingAttributeNode == NULL)
        {
            letterSpacingAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            [letterSpacingAttributeNode setName:@"letter-spacing"];
            [textElement addAttribute:letterSpacingAttributeNode];
        }
        [letterSpacingAttributeNode setStringValue:letterSpacingString];
    }
    
    NSString * wordSpacingAttributeString = [wordSpacingTextfield stringValue];
    if ([wordSpacingAttributeString length] == 0)
    {
        [textElement removeAttributeForName:@"word-spacing"];
    }
    else
    {
        float wordSpacingFloat = [wordSpacingTextfield floatValue];
        NSString * numericWordSpacingString = [self numericStringWithFloat:wordSpacingFloat];
        NSString * wordSpacingUnitString = [wordSpacingUnitPopUpButton titleOfSelectedItem];
        NSString * wordSpacingString = [NSString stringWithFormat:@"%@%@", numericWordSpacingString, wordSpacingUnitString];
        NSXMLNode * wordSpacingAttributeNode = [textElement attributeForName:@"word-spacing"];
        if (wordSpacingAttributeNode == NULL)
        {
            wordSpacingAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            [wordSpacingAttributeNode setName:@"word-spacing"];
            [textElement addAttribute:wordSpacingAttributeNode];
        }
        [wordSpacingAttributeNode setStringValue:wordSpacingString];
    }
    
    
    NSString * cssStyleAttributeString = [cssStyleTextView string];

    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    cssStyleAttributeString = [cssStyleAttributeString stringByTrimmingCharactersInSet:whitespaceSet];

    if ([cssStyleAttributeString length] == 0)
    {
        [textElement removeAttributeForName:@"style"];
    }
    else
    {
        NSXMLNode * cssStyleAttributeNode = [textElement attributeForName:@"style"];
        if (cssStyleAttributeNode == NULL)
        {
            cssStyleAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            [cssStyleAttributeNode setName:@"style"];
            [textElement addAttribute:cssStyleAttributeNode];
        }
        [cssStyleAttributeNode setStringValue:cssStyleAttributeString];
    }
}



@end
