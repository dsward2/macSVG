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

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
        NSInteger index = numericString.length - 1;
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
    NSString * attributeString = attributeNode.stringValue;
    float attributeFloat = attributeString.floatValue;
    NSString * numericString = @"0";

    numericString = [NSString stringWithFormat:@"%f", attributeFloat];
    
    NSRange decimalPointRange = [numericString rangeOfString:@"."];
    if (decimalPointRange.location != NSNotFound)
    {
        NSInteger index = numericString.length - 1;
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
//	attributeString:endsWithSuffix:
//==================================================================================

- (BOOL)attributeString:(NSString *)attributeString endsWithSuffix:(NSString *)suffix
{
    BOOL result = NO;

    NSInteger attributeStringLength = attributeString.length;
    NSInteger suffixLength = suffix.length;
    
    if (attributeStringLength > suffixLength)
    {
        NSRange unitRange = [attributeString rangeOfString:suffix];
        
        if (unitRange.location == (attributeStringLength - suffixLength))
        {
            BOOL allNumericValue = YES;
            
            for (NSInteger i = 0; i < unitRange.location; i++)
            {
                unichar valueChar = [attributeString characterAtIndex:i];
                
                if ((valueChar < '0') || (valueChar > '9'))
                {
                    allNumericValue = NO;
                    break;
                }
            }
            
            if (allNumericValue == YES)
            {
                result = YES;
            }
        }
    }
    
    return result;
}

//==================================================================================
//	unitForAttributeNode:
//==================================================================================

- (NSString *)unitForAttributeNode:(NSXMLNode *)attributeNode
{
    NSString * attributeString = attributeNode.stringValue;

    NSString * resultUnit = NULL;

    if ([self attributeString:attributeString endsWithSuffix:@"em"] == YES)
    {
        resultUnit = @"em";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"ex"] == YES)
    {
        resultUnit = @"ex";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"px"] == YES)
    {
        resultUnit = @"px";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"pt"] == YES)
    {
        resultUnit = @"pt";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"pc"] == YES)
    {
        resultUnit = @"pc";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"cm"] == YES)
    {
        resultUnit = @"cm";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"mm"] == YES)
    {
        resultUnit = @"mm";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"in"] == YES)
    {
        resultUnit = @"in";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"h"] == YES)
    {
        resultUnit = @"h";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"min"] == YES)
    {
        resultUnit = @"min";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"s"] == YES)
    {
        resultUnit = @"s";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"%"] == YES)
    {
        resultUnit = @"%";
    }

    if (resultUnit == NULL)
    {
        resultUnit = @"";
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

    NSString * horizontalOffsetString = horizontalOffsetTextField.stringValue;
    NSString * horizontalOffsetUnitString = horizontalOffsetUnitPopUpButton.titleOfSelectedItem;
    
    NSString * verticalOffsetString = verticalOffsetTextField.stringValue;
    NSString * verticalOffsetUnitString = verticalOffsetUnitPopUpButton.titleOfSelectedItem;
    
    NSString * blurRadiusString = blurRadiusTextField.stringValue;
    NSString * blurRadiusUnitString = blurRadiusUnitPopUpButton.titleOfSelectedItem;

    NSColor * shadowColor = shadowColorWell.color;
    NSString * hexColorString = [self hexadecimalValueOfAnNSColor:shadowColor];
    
    NSInteger horizontalOffsetStringLength = horizontalOffsetString.length;
    NSInteger verticalOffsetStringLength = verticalOffsetString.length;
    
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

        NSString * cssStyleString = cssStyleTextView.string;
        
        NSString * newCssStyleString = [cssStyleString stringByAppendingString:textShadowString];
        
        cssStyleTextView.string = newCssStyleString;
    }
}

//==================================================================================
//	loadTextStyles
//==================================================================================

- (void)loadTextStyles
{
    NSXMLElement * textElement = textElementEditor.pluginTargetXMLElement;
    
    NSXMLNode * textStyleAttributeNode = [textElement attributeForName:@"text-style"];
    if (textStyleAttributeNode != NULL)
    {
        NSString * textStyleAttributeString = textStyleAttributeNode.stringValue;
        [fontStylePopUpButton selectItemWithTitle:textStyleAttributeString];
    }
    else
    {
        [fontStylePopUpButton selectItemWithTitle:@""];
    }
    
    NSXMLNode * fontVariantAttributeNode = [textElement attributeForName:@"font-variant"];
    if (fontVariantAttributeNode != NULL)
    {
        NSString * fontVariantAttributeString = fontVariantAttributeNode.stringValue;
        [fontVariantPopUpButton selectItemWithTitle:fontVariantAttributeString];
    }
    else
    {
        [fontVariantPopUpButton selectItemWithTitle:@""];
    }
    
    NSXMLNode * fontWeightAttributeNode = [textElement attributeForName:@"font-weight"];
    if (fontWeightAttributeNode != NULL)
    {
        NSString * fontWeightAttributeString = fontWeightAttributeNode.stringValue;
        [fontWeightPopUpButton selectItemWithTitle:fontWeightAttributeString];
    }
    else
    {
        [fontWeightPopUpButton selectItemWithTitle:@""];
    }
    
    NSXMLNode * fontStretchAttributeNode = [textElement attributeForName:@"font-stretch"];
    if (fontStretchAttributeNode != NULL)
    {
        NSString * fontStretchAttributeString = fontStretchAttributeNode.stringValue;
        [fontStretchPopUpButton selectItemWithTitle:fontStretchAttributeString];
    }
    else
    {
        [fontStretchPopUpButton selectItemWithTitle:@""];
    }

    underlineCheckboxButton.integerValue = 0;
    overlineCheckboxButton.integerValue = 0;
    lineThroughCheckboxButton.integerValue = 0;
    blinkCheckboxButton.integerValue = 0;
    inheritDecorationCheckboxButton.integerValue = 0;

    NSXMLNode * textDecorationAttributeNode = [textElement attributeForName:@"text-decoration"];
    if (textDecorationAttributeNode != NULL)
    {
        NSString * textDecorationAttributeString = textDecorationAttributeNode.stringValue;

        //NSRange noneRange = [textDecorationAttributeString rangeOfString:@"none"];
        NSRange underlineRange = [textDecorationAttributeString rangeOfString:@"underline"];
        NSRange overlineRange = [textDecorationAttributeString rangeOfString:@"overline"];
        NSRange lineThroughRange = [textDecorationAttributeString rangeOfString:@"line-through"];
        NSRange blinkRange = [textDecorationAttributeString rangeOfString:@"blink"];
        NSRange inheritRange = [textDecorationAttributeString rangeOfString:@"inherit"];
        
        if (inheritRange.location != NSNotFound)
        {
            inheritDecorationCheckboxButton.integerValue = 1;
        }
        else
        {
            if (underlineRange.location != NSNotFound)
            {
                underlineCheckboxButton.integerValue = 1;
            }
            
            if (overlineRange.location != NSNotFound)
            {
                overlineCheckboxButton.integerValue = 1;
            }
            
            if (lineThroughRange.location != NSNotFound)
            {
                lineThroughCheckboxButton.integerValue = 1;
            }
            
            if (blinkRange.location != NSNotFound)
            {
                blinkCheckboxButton.integerValue = 1;
            }
        }
    }
    
    NSXMLNode * letterSpacingAttributeNode = [textElement attributeForName:@"letter-spacing"];
    if (letterSpacingAttributeNode != NULL)
    {
        NSString * letterSpacingAttributeString = [self numericStringWithAttributeNode:letterSpacingAttributeNode];
        NSString * letterSpacingUnitString = [self unitForAttributeNode:letterSpacingAttributeNode];
        
        letterSpacingTextfield.stringValue = letterSpacingAttributeString;
        [letterSpacingUnitPopUpButton selectItemWithTitle:letterSpacingUnitString];
    }
    else
    {
        letterSpacingTextfield.stringValue = @"";
        [letterSpacingUnitPopUpButton selectItemWithTitle:@"px"];
    }
    
    NSXMLNode * wordSpacingAttributeNode = [textElement attributeForName:@"word-spacing"];
    if (wordSpacingAttributeNode != NULL)
    {
        NSString * wordSpacingAttributeString = [self numericStringWithAttributeNode:wordSpacingAttributeNode];
        NSString * wordSpacingUnitString = [self unitForAttributeNode:wordSpacingAttributeNode];
        
        wordSpacingTextfield.stringValue = wordSpacingAttributeString;
        [wordSpacingUnitPopUpButton selectItemWithTitle:wordSpacingUnitString];
    }
    else
    {
        wordSpacingTextfield.stringValue = @"";
        [wordSpacingUnitPopUpButton selectItemWithTitle:@"px"];
    }

    
    NSXMLNode * cssStyleAttributeNode = [textElement attributeForName:@"style"];
    if (cssStyleAttributeNode != NULL)
    {
        NSString * cssStyleAttributeString = cssStyleAttributeNode.stringValue;
        
        cssStyleTextView.string = cssStyleAttributeString;
    }
    else
    {
        cssStyleTextView.string = @"";
    }

    // shadowColorWell retains existing color
    
    NSString * oldHorizontalOffsetString = horizontalOffsetTextField.stringValue;
    if (oldHorizontalOffsetString.length == 0)
    {
        horizontalOffsetTextField.stringValue = @"3";
        [horizontalOffsetUnitPopUpButton selectItemWithTitle:@"px"];
    }
    
    NSString * oldVerticalOffsetString = verticalOffsetTextField.stringValue;
    if (oldVerticalOffsetString.length == 0)
    {
        verticalOffsetTextField.stringValue = @"3";
        [verticalOffsetUnitPopUpButton selectItemWithTitle:@"px"];
    }
}

//==================================================================================
//	applyTextStyles
//==================================================================================

- (void)applyTextStyles
{
    NSXMLElement * textElement = [textElementEditor activeXMLTextElement];

    NSString * fontStyleAttributeString = fontStylePopUpButton.titleOfSelectedItem;
    if (fontStyleAttributeString.length == 0)
    {
        [textElement removeAttributeForName:@"font-style"];
    }
    else
    {
        NSXMLNode * fontStyleAttributeNode = [textElement attributeForName:@"font-style"];
        if (fontStyleAttributeNode == NULL)
        {
            fontStyleAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            fontStyleAttributeNode.name = @"font-style";
            [textElement addAttribute:fontStyleAttributeNode];
        }
        fontStyleAttributeNode.stringValue = fontStyleAttributeString;
    }

    NSString * fontVariantAttributeString = fontVariantPopUpButton.titleOfSelectedItem;
    if (fontVariantAttributeString.length == 0)
    {
        [textElement removeAttributeForName:@"font-variant"];
    }
    else
    {
        NSXMLNode * fontVariantAttributeNode = [textElement attributeForName:@"font-variant"];
        if (fontVariantAttributeNode == NULL)
        {
            fontVariantAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            fontVariantAttributeNode.name = @"font-variant";
            [textElement addAttribute:fontVariantAttributeNode];
        }
        fontVariantAttributeNode.stringValue = fontVariantAttributeString;
    }

    NSString * fontWeightAttributeString = fontWeightPopUpButton.titleOfSelectedItem;
    if (fontWeightAttributeString.length == 0)
    {
        [textElement removeAttributeForName:@"font-weight"];
    }
    else
    {
        NSXMLNode * fontWeightAttributeNode = [textElement attributeForName:@"font-weight"];
        if (fontWeightAttributeNode == NULL)
        {
            fontWeightAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            fontWeightAttributeNode.name = @"font-weight";
            [textElement addAttribute:fontWeightAttributeNode];
        }
        fontWeightAttributeNode.stringValue = fontWeightAttributeString;
    }
    
    NSString * fontStretchAttributeString = fontStretchPopUpButton.titleOfSelectedItem;
    if (fontStretchAttributeString.length == 0)
    {
        [textElement removeAttributeForName:@"font-stretch"];
    }
    else
    {
        NSXMLNode * fontStretchAttributeNode = [textElement attributeForName:@"font-stretch"];
        if (fontStretchAttributeNode == NULL)
        {
            fontStretchAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            fontStretchAttributeNode.name = @"font-stretch";
            [textElement addAttribute:fontStretchAttributeNode];
        }
        fontStretchAttributeNode.stringValue = fontStretchAttributeString;
    }
    
    NSInteger underlineCheckboxValue = underlineCheckboxButton.integerValue;
    NSInteger overlineCheckboxValue = overlineCheckboxButton.integerValue;
    NSInteger lineThroughCheckboxValue = lineThroughCheckboxButton.integerValue;
    NSInteger blinkCheckboxValue = blinkCheckboxButton.integerValue;
    NSInteger inheritCheckboxValue = inheritDecorationCheckboxButton.integerValue;

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
                textDecorationAttributeNode.name = @"text-decoration";
                [textElement addAttribute:textDecorationAttributeNode];
            }
            textDecorationAttributeNode.stringValue = @"inherit";
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
                if (decorationString.length > 0)
                {
                    [decorationString appendString:@" "];
                }
                [decorationString appendString:@"overline"];
            }
            
            if (lineThroughCheckboxValue != 0)
            {
                if (decorationString.length > 0)
                {
                    [decorationString appendString:@" "];
                }
                [decorationString appendString:@"line-through"];
            }
            
            if (blinkCheckboxValue != 0)
            {
                if (decorationString.length > 0)
                {
                    [decorationString appendString:@" "];
                }
                [decorationString appendString:@"blink"];
            }

            NSXMLNode * textDecorationAttributeNode = [textElement attributeForName:@"text-decoration"];
            if (textDecorationAttributeNode == NULL)
            {
                textDecorationAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                textDecorationAttributeNode.name = @"text-decoration";
                [textElement addAttribute:textDecorationAttributeNode];
            }
            textDecorationAttributeNode.stringValue = decorationString;
        }
    }

    NSString * letterSpacingAttributeString = letterSpacingTextfield.stringValue;
    if (letterSpacingAttributeString.length == 0)
    {
        [textElement removeAttributeForName:@"letter-spacing"];
    }
    else
    {
        float letterSpacingFloat = letterSpacingTextfield.floatValue;
        NSString * numericLetterSpacingString = [self numericStringWithFloat:letterSpacingFloat];
        NSString * letterSpacingUnitString = letterSpacingUnitPopUpButton.titleOfSelectedItem;
        NSString * letterSpacingString = [NSString stringWithFormat:@"%@%@", numericLetterSpacingString, letterSpacingUnitString];
        NSXMLNode * letterSpacingAttributeNode = [textElement attributeForName:@"letter-spacing"];
        if (letterSpacingAttributeNode == NULL)
        {
            letterSpacingAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            letterSpacingAttributeNode.name = @"letter-spacing";
            [textElement addAttribute:letterSpacingAttributeNode];
        }
        letterSpacingAttributeNode.stringValue = letterSpacingString;
    }
    
    NSString * wordSpacingAttributeString = wordSpacingTextfield.stringValue;
    if (wordSpacingAttributeString.length == 0)
    {
        [textElement removeAttributeForName:@"word-spacing"];
    }
    else
    {
        float wordSpacingFloat = wordSpacingTextfield.floatValue;
        NSString * numericWordSpacingString = [self numericStringWithFloat:wordSpacingFloat];
        NSString * wordSpacingUnitString = wordSpacingUnitPopUpButton.titleOfSelectedItem;
        NSString * wordSpacingString = [NSString stringWithFormat:@"%@%@", numericWordSpacingString, wordSpacingUnitString];
        NSXMLNode * wordSpacingAttributeNode = [textElement attributeForName:@"word-spacing"];
        if (wordSpacingAttributeNode == NULL)
        {
            wordSpacingAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            wordSpacingAttributeNode.name = @"word-spacing";
            [textElement addAttribute:wordSpacingAttributeNode];
        }
        wordSpacingAttributeNode.stringValue = wordSpacingString;
    }
    
    
    NSString * cssStyleAttributeString = cssStyleTextView.string;

    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    cssStyleAttributeString = [cssStyleAttributeString stringByTrimmingCharactersInSet:whitespaceSet];

    if (cssStyleAttributeString.length == 0)
    {
        [textElement removeAttributeForName:@"style"];
    }
    else
    {
        NSXMLNode * cssStyleAttributeNode = [textElement attributeForName:@"style"];
        if (cssStyleAttributeNode == NULL)
        {
            cssStyleAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            cssStyleAttributeNode.name = @"style";
            [textElement addAttribute:cssStyleAttributeNode];
        }
        cssStyleAttributeNode.stringValue = cssStyleAttributeString;
    }
}



@end
