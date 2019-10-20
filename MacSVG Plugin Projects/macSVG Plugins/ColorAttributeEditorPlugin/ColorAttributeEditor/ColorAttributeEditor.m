//
//  ColorAttributeEditor.m
//  ColorAttributeEditor
//
//  Created by Douglas Ward on 1/5/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "ColorAttributeEditor.h"
//#import <WebKit/WebKit.h>
#import "GradientEditorPopoverViewController.h"
#import "MacSVGDocumentWindowController.h"
#import "XMLAttributesTableController.h"
#import "WebColorsTableViewController.h"

@implementation ColorAttributeEditor


//==================================================================================
//	init
//==================================================================================

- (instancetype)init
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
    
    self.webColorsTableViewController.webColorsTableView.doubleAction = @selector(setWebColorButtonAction:);
    self.webColorsTableViewController.webColorsTableView.target = self;
}

//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    return @"Color Attribute Editor";
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element tag name
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    NSString * result = NULL;

    return result;
}

//==================================================================================
//	isEditorForElement:elementName:attribute:
//==================================================================================

// return label if this editor can edit specified element and attribute
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName attribute:(NSString *)attributeName
{
    NSString * result = NULL;
    
    BOOL validElement = NO;
    BOOL validAttribute = NO;

    if ([attributeName isEqualToString:@"fill"] == YES)
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"stroke"] == YES) 
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"stop-color"] == YES) 
    {
        validAttribute = YES;
    }

    if (validAttribute == YES)
    {
        NSDictionary * elementsWithAttribute = [self elementsWithAttribute:attributeName];
        if (elementsWithAttribute[elementName] != NULL)
        {
            validElement = YES;
        }

        if ([elementName isEqualToString:@"set"] == YES) 
        {
            validElement = NO;
        }
        else if ([elementName isEqualToString:@"animate"] == YES) 
        {
            validElement = NO;
        }
        else if ([elementName isEqualToString:@"animateColor"] == YES) 
        {
            validElement = NO;
        }
        else if ([elementName isEqualToString:@"animateMotion"] == YES) 
        {
            validElement = NO;
        }
        else if ([elementName isEqualToString:@"animateTransform"] == YES) 
        {
            validElement = NO;
        }
        
        if (validElement == YES)
        {
            result = self.pluginName;
        }
    }

    return result;
}

//==================================================================================
//	editorPriority:context:
//==================================================================================

- (NSInteger)editorPriority:(NSXMLElement *)targetElement context:(NSString *)context
{
    return 30;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

//==================================================================================
//	beginEditForXMLElement:domElement:attributeName:existingValue:
//==================================================================================

- (BOOL)beginEditForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetDOMElement
        attributeName:(NSString *)newAttributeName
        existingValue:(NSString *)existingValue
{
    BOOL result = [super beginEditForXMLElement:newPluginTargetXMLElement
            domElement:newPluginTargetDOMElement attributeName:newAttributeName
            existingValue:existingValue];
    
    NSString * tagName = (self.pluginTargetXMLElement).name;
    if ([tagName isEqualToString:@"stop"] == YES)
    {
        [self.setGradientButton setEnabled:NO];
    }
    else
    {
        [self.setGradientButton setEnabled:YES];
    }

    NSString * colorTextString = existingValue;

    self.colorTextField.stringValue = colorTextString;

    NSUInteger colorTextLength = colorTextString.length;

    if (colorTextLength > 0)
    {
        unichar firstCharacter = [colorTextString characterAtIndex:0];
                
        if (firstCharacter == '#') 
        {
            NSRange hexRange;
            hexRange.location = 0;
            hexRange.length = 0;

            if (colorTextLength == 4)
            {
                // short-form hex specification
                hexRange.location = 1;
                hexRange.length = 3;
            }
            
            if (colorTextLength == 7)
            {
                // check for full-length hex specification
                hexRange.location = 1;
                hexRange.length = 6;
            }
            
            if (hexRange.location > 0)
            {
                BOOL validColorChars = YES;

                for (NSUInteger i = hexRange.location; i < hexRange.length; i++)
                {
                    unichar colorChar = [colorTextString characterAtIndex:i];

                    BOOL validColorChar = NO;
                    
                    if ((colorChar >= '0') && (colorChar <= '9'))
                    {
                        validColorChar = YES;
                    }
                    else if ((colorChar >= 'A') && (colorChar <= 'F'))
                    {
                        validColorChar = YES;
                    }
                    else if ((colorChar >= 'a') && (colorChar <= 'f'))
                    {
                        validColorChar = YES;
                    }
                    
                    if (validColorChar == NO)
                    {
                        validColorChars = NO;
                    }
                }
                
                if (validColorChars == YES)
                {
                    NSString * redString = @"00";
                    NSString * greenString = @"00";
                    NSString * blueString = @"00";
                    
                    if (colorTextLength == 4)
                    {
                        unichar redChar = [colorTextString characterAtIndex:1];
                        unichar greenChar = [colorTextString characterAtIndex:2];
                        unichar blueChar = [colorTextString characterAtIndex:1];
                        
                        redString = [NSString stringWithFormat:@"%C%C", redChar, redChar];
                        greenString = [NSString stringWithFormat:@"%C%C", greenChar, greenChar];
                        blueString = [NSString stringWithFormat:@"%C%C", blueChar, blueChar];
                    }
                    
                    if (colorTextLength == 7)
                    {
                        NSRange redRange = NSMakeRange(1, 2);
                        NSRange greenRange = NSMakeRange(3, 2);
                        NSRange blueRange = NSMakeRange(5, 2);
                        
                        redString = [colorTextString substringWithRange:redRange];
                        greenString = [colorTextString substringWithRange:greenRange];
                        blueString = [colorTextString substringWithRange:blueRange];
                    }
                    
                    NSString * hexRedString = [NSString stringWithFormat:@"0x%@", redString];
                    NSString * hexGreenString = [NSString stringWithFormat:@"0x%@", greenString];
                    NSString * hexBlueString = [NSString stringWithFormat:@"0x%@", blueString];
                    
                    NSScanner* redScanner = [NSScanner scannerWithString:hexRedString];
                    unsigned int redInt;
                    [redScanner scanHexInt: &redInt];
                    
                    NSScanner* greenScanner = [NSScanner scannerWithString:hexGreenString];
                    unsigned int greenInt;
                    [greenScanner scanHexInt: &greenInt];
                    
                    NSScanner* blueScanner = [NSScanner scannerWithString:hexBlueString];
                    unsigned int blueInt;
                    [blueScanner scanHexInt: &blueInt];
                    
                    float redFloat = (float)redInt / 255.0f;
                    float greenFloat = (float)greenInt / 255.0f;
                    float blueFloat = (float)blueInt / 255.0f;
                    
                    NSColor * colorWellColor = [NSColor colorWithCalibratedRed:redFloat green:greenFloat blue:blueFloat alpha:1];
                    
                    self.colorWell.color = colorWellColor;
                }
            }
        }
    }


    
    NSInteger webColorsArrayCount = (self.webColorsTableViewController.webColorsArray).count;
    for (NSInteger i = 0; i < webColorsArrayCount; i++)
    {
        NSDictionary * colorDictionary = (self.webColorsTableViewController.webColorsArray)[i];
        NSString * colorName = colorDictionary[@"name"];
        
        if ([colorName isEqualToString:existingValue] == YES)
        {
            NSIndexSet * selectedIndexSet = [NSIndexSet indexSetWithIndex:i];
            [self.webColorsTableViewController.webColorsTableView selectRowIndexes:selectedIndexSet byExtendingSelection:NO];
            
            [self.webColorsTableViewController.webColorsTableView scrollRowToVisible:i];

            NSString * colorRGB = colorDictionary[@"rgb"];
            
            NSArray * channelsArray = [colorRGB componentsSeparatedByString:@","];
            NSString * redString = channelsArray[0];
            NSString * greenString = channelsArray[1];
            NSString * blueString = channelsArray[2];
            
            int redInt = redString.intValue;
            int greenInt = greenString.intValue;
            int blueInt = blueString.intValue;
            
            float redFloat = ((float)redInt / 255.0f);
            float greenFloat = ((float)greenInt / 255.0f);
            float blueFloat = ((float)blueInt / 255.0f);
            
            NSColor * wellColor = [NSColor colorWithCalibratedRed:redFloat green:greenFloat blue:blueFloat alpha:1.0f];
            
            self.colorWell.color = wellColor;

            break;
        }
    }

    return result;
}


#pragma clang diagnostic pop



//==================================================================================
//	updateAttributeValue
//==================================================================================

- (void)updateAttributeValue
{
    NSXMLNode * attributeNode = [self.pluginTargetXMLElement attributeForName:self.activeAttributeName];
    
    if (attributeNode != NULL)
    {
        NSString * colorTextString = self.colorTextField.stringValue;
        attributeNode.stringValue = colorTextString;
        
        [self updateDocumentViews];
    }
}

//==================================================================================
//	validateColorTextField
//==================================================================================

- (BOOL)validateColorTextField
{
    BOOL result = NO;

    NSString * colorTextString = self.colorTextField.stringValue;

    NSUInteger colorTextLength = colorTextString.length;

    if (colorTextLength > 0)
    {
        unichar firstCharacter = [colorTextString characterAtIndex:0];
                
        if (firstCharacter == '#') 
        {
            NSRange hexRange;
            hexRange.location = 0;
            hexRange.length = 0;

            if (colorTextLength == 4)
            {
                // short-form hex specification
                hexRange.location = 1;
                hexRange.length = 3;
            }
            
            if (colorTextLength == 7)
            {
                // check for full-length hex specification
                hexRange.location = 1;
                hexRange.length = 6;
            }
            
            if (hexRange.location > 0)
            {
                BOOL validColorChars = YES;

                for (NSUInteger i = hexRange.location; i < hexRange.length; i++)
                {
                    unichar colorChar = [colorTextString characterAtIndex:i];

                    BOOL validColorChar = NO;
                    
                    if ((colorChar >= '0') && (colorChar <= '9'))
                    {
                        validColorChar = YES;
                    }
                    else if ((colorChar >= 'A') && (colorChar <= 'F'))
                    {
                        validColorChar = YES;
                    }
                    else if ((colorChar >= 'a') && (colorChar <= 'f'))
                    {
                        validColorChar = YES;
                    }
                    
                    if (validColorChar == NO)
                    {
                        validColorChars = NO;
                    }
                }

                if (validColorChars == NO)
                {
                    // check for gradient
                    NSString * idString = [colorTextString substringFromIndex:1];
                    
                    NSArray * allGradientElements = [self findAllGradientElements];
                    
                    for (NSXMLElement * aGradientElement in allGradientElements)
                    {
                        NSXMLNode * gradientIDNode = [aGradientElement attributeForName:@"id"];
                        NSString * gradientIDString = gradientIDNode.stringValue;
                        
                        if ([idString isEqualToString:gradientIDString] == YES)
                        {
                            validColorChars = YES;
                            break;
                        }
                    }
                }
                
                if (validColorChars == YES)
                {
                    //[self updateAttributeValue];
                    result = YES;
                }
            }
        }
        else
        {
            // not a hex color, check for valid HTML color name
            BOOL validHTMLColor = NO; 
            BOOL continueSearch = YES;
            
            NSUInteger webColorsCount = (self.webColorsTableViewController.webColorsArray).count;
                        
            int colorIdx = 0;
            while (continueSearch == YES)
            {
                NSDictionary * colorNameDictionary = (self.webColorsTableViewController.webColorsArray)[colorIdx];
                
                NSString * aColorName = colorNameDictionary[@"name"];
                
                if ([colorTextString isEqualToString:aColorName] == YES) 
                {
                    continueSearch = NO;
                    validHTMLColor = YES;
                }
                else
                {
                    colorIdx++;
                    if (colorIdx >= webColorsCount)
                    {
                        continueSearch = NO;
                    }
                }
            }

            if (validHTMLColor == NO)
            {
                // check for gradient
                NSRange urlRange = [colorTextString rangeOfString:@"url(#"];
                if (urlRange.location == 0)
                {
                    NSInteger extractLength = colorTextString.length - 6;
                    NSRange extractURLRange = NSMakeRange(5, extractLength);
                    NSString * idString = [colorTextString substringWithRange:extractURLRange];
                    
                    NSArray * allGradientElements = [self findAllGradientElements];
                    
                    for (NSXMLElement * aGradientElement in allGradientElements)
                    {
                        NSXMLNode * gradientIDNode = [aGradientElement attributeForName:@"id"];
                        NSString * gradientIDString = gradientIDNode.stringValue;
                        
                        if ([idString isEqualToString:gradientIDString] == YES)
                        {
                            validHTMLColor = YES;
                            break;
                        }
                    }
                }
            }
            
            if (validHTMLColor == YES)
            {
                //[self updateAttributeValue];
                result = YES;
            }
        }
    }
    
    return result;
}

//==================================================================================
//	findAllLinearGradientElements
//==================================================================================

 -(NSArray *)findAllLinearGradientElements
 {       
    NSArray * resultArray = NULL;
    
    NSXMLElement * rootElement = [self.svgXmlDocument rootElement];
    
    NSString * xpathQuery = @".//linearGradient";
    
    NSError * error = NULL;
    resultArray = [rootElement nodesForXPath:xpathQuery error:&error];
    
    return resultArray;
}

//==================================================================================
//	findAllRadialGradientElements
//==================================================================================

 -(NSArray *)findAllRadialGradientElements
 {       
    NSArray * resultArray = NULL;
    
    NSXMLElement * rootElement = [self.svgXmlDocument rootElement];
    
    NSString * xpathQuery = @".//radialGradient";
    
    NSError * error = NULL;
    resultArray = [rootElement nodesForXPath:xpathQuery error:&error];
    
    return resultArray;
}

//==================================================================================
//	findAllGradientElements
//==================================================================================

 -(NSArray *)findAllGradientElements
{
    NSArray * linearGradientsArray = [self findAllLinearGradientElements];
    NSArray * radialGradientsArray = [self findAllRadialGradientElements];
    
    NSArray * mergeGradientsArray = [NSArray arrayWithArray:linearGradientsArray];
    mergeGradientsArray = [mergeGradientsArray arrayByAddingObjectsFromArray:radialGradientsArray];
    
    return mergeGradientsArray;
}


//==================================================================================
//	setColorButtonAction:
//==================================================================================

- (IBAction)setColorButtonAction:(id)sender
{
    XMLAttributesTableController * xmlAttributesTableController =
            [self.macSVGPluginCallbacks.macSVGDocumentWindowController xmlAttributesTableController];
    NSString * selectedAttributeName = [xmlAttributesTableController selectedAttributeName];

    NSXMLNode * attributeNode = [self.pluginTargetXMLElement attributeForName:self.activeAttributeName];
    if (attributeNode != NULL)
    {
        BOOL colorTextIsValid = [self validateColorTextField];
        
        if (colorTextIsValid == YES)
        {
            NSString * colorStringValue = self.colorTextField.stringValue;
            attributeNode.stringValue = colorStringValue;
        }
    }
    
    [self updateDocumentViews];

    if (self.macSVGPluginCallbacks.currentToolMode == toolModeCrosshairCursor)
    {
        [self.macSVGPluginCallbacks.macSVGDocumentWindowController performSelector:@selector(beginCrosshairToolMode) withObject:NULL afterDelay:0.05f];  // workaround for a problem that incorrectly added both selection rect/handles and path/polyline/polygon/line handles

        [xmlAttributesTableController performSelector:@selector(selectAttributeWithName:) withObject:selectedAttributeName afterDelay:0.1f];
    }
}

//==================================================================================
//	setGradientElement:
//==================================================================================

- (void)setGradientElement:(NSXMLElement *)gradientElement;
{
    XMLAttributesTableController * xmlAttributesTableController =
            [self.macSVGPluginCallbacks.macSVGDocumentWindowController xmlAttributesTableController];
    NSString * selectedAttributeName = [xmlAttributesTableController selectedAttributeName];

    NSXMLNode * gradientElementIDNode = [gradientElement attributeForName:@"id"];
    NSString * gradientElementIDString = gradientElementIDNode.stringValue;
    
    NSString * gradientURLString = [NSString stringWithFormat:@"url(#%@)", gradientElementIDString];
    
    self.colorTextField.stringValue = gradientURLString;
    
    NSXMLNode * attributeNode = [self.pluginTargetXMLElement attributeForName:self.activeAttributeName];
    attributeNode.stringValue = gradientURLString;
    
    [self updateDocumentViews];

    if (self.macSVGPluginCallbacks.currentToolMode == toolModeCrosshairCursor)
    {
        [self.macSVGPluginCallbacks.macSVGDocumentWindowController performSelector:@selector(beginCrosshairToolMode) withObject:NULL afterDelay:0.05f];  // workaround for a problem that incorrectly added both selection rect/handles and path/polyline/polygon/line handles

        [xmlAttributesTableController performSelector:@selector(selectAttributeWithName:) withObject:selectedAttributeName afterDelay:0.1f];
    }
}

//==================================================================================
//	setNoneButtonAction:
//==================================================================================

- (IBAction)setNoneButtonAction:(id)sender;
{
    NSXMLNode * attributeNode = [self.pluginTargetXMLElement attributeForName:self.activeAttributeName];
    if (attributeNode != NULL)
    {
        NSString * colorStringValue = @"none";
        attributeNode.stringValue = colorStringValue;
    }
    
    [self updateDocumentViews];

}

//==================================================================================
//	setWebColorButtonAction:
//==================================================================================

- (IBAction)setWebColorButtonAction:(id)sender
{
    NSInteger rowIndex = self.webColorsTableViewController.webColorsTableView.selectedRow;
    
    if (rowIndex != -1)
    {
        NSDictionary * webColorDictionary = (self.webColorsTableViewController.webColorsArray)[rowIndex];

        NSString * colorName = webColorDictionary[@"name"];
        //NSString * colorHex = [webColorDictionary objectForKey:@"hex"];
        NSString * colorRGB = webColorDictionary[@"rgb"];
        
        self.colorTextField.stringValue = colorName;
        
        NSArray * channelsArray = [colorRGB componentsSeparatedByString:@","];
        NSString * redString = channelsArray[0];
        NSString * greenString = channelsArray[1];
        NSString * blueString = channelsArray[2];
        
        int redInt = redString.intValue;
        int greenInt = greenString.intValue;
        int blueInt = blueString.intValue;
        
        float redFloat = ((float)redInt / 255.0f);
        float greenFloat = ((float)greenInt / 255.0f);
        float blueFloat = ((float)blueInt / 255.0f);
        
        NSColor * wellColor = [NSColor colorWithCalibratedRed:redFloat green:greenFloat blue:blueFloat alpha:1.0f];
        
        self.colorWell.color = wellColor;
        
        [self setColorButtonAction:self];
    }
}


//==================================================================================
//	colorWellAction:
//==================================================================================

- (IBAction)colorWellAction:(id)sender
{
    NSColor * wellColor = self.colorWell.color;
    
    CGFloat redFloat = 0;
    CGFloat greenFloat = 0;
    CGFloat blueFloat = 0;
    CGFloat alphaFloat = 0;
    
    [wellColor getRed:&redFloat green:&greenFloat blue:&blueFloat alpha:&alphaFloat];
    
    int redInt = redFloat * 255.0f;
    int greenInt = greenFloat * 255.0f;
    int blueInt = blueFloat * 255.0f;
    
    NSString * colorString = [[NSString alloc] initWithFormat:@"#%02x%02x%02x",
            redInt, greenInt, blueInt];
    
    self.colorTextField.stringValue = colorString;
    
    [self setColorButtonAction:self];
    
}

// -------------------------------------------------------------------------------
//  colorGradientButtonAction:
// -------------------------------------------------------------------------------
- (IBAction)colorGradientButtonAction:(id)sender
{
    NSButton *targetButton = (NSButton *)sender;
    
    [self.gradientEditorPopoverViewController loadGradientsData];
    
    // configure the preferred position of the popover
    [self.gradientEditorPopover showRelativeToRect:targetButton.bounds ofView:sender preferredEdge:NSMaxYEdge];
}


@end
