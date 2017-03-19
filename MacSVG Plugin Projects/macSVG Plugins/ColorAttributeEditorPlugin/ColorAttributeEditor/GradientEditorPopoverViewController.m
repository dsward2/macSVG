//
//  GradientEditorPopoverViewController.m
//  ColorAttributeEditor
//
//  Created by Douglas Ward on 9/12/13.
//
//

#import "GradientEditorPopoverViewController.h"
#import "ColorAttributeEditor.h"

@interface GradientEditorPopoverViewController ()

@end

NSComparisonResult colorStopsSort(id element1, id element2, void *context);

@implementation GradientEditorPopoverViewController

//==================================================================================
//	initWithNibName
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
//	dealloc
//==================================================================================

- (void)dealloc
{
    if (self.delayedUpdateTimer != NULL)
    {
        [self.delayedUpdateTimer invalidate];
        self.delayedUpdateTimer = NULL;
    }

    self.gradientsArray = NULL;
    self.colorStopsArray = NULL;

    gradientPreviewWebView.downloadDelegate = NULL;
    gradientPreviewWebView.frameLoadDelegate = NULL;
    gradientPreviewWebView.policyDelegate = NULL;
    gradientPreviewWebView.UIDelegate = NULL;
    gradientPreviewWebView.resourceLoadDelegate = NULL;
}

//==================================================================================
//	awakeFromNib
//==================================================================================

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (self.gradientsArray == NULL)
    {
        self.gradientsArray = [NSMutableArray array];
    }
    
    if (self.colorStopsArray == NULL)
    {
        self.colorStopsArray = [NSMutableArray array];
    }
    
    [gradientPreviewWebView.mainFrame.frameView setAllowsScrolling:NO];
    [gradientPreviewWebView setEditable:NO];
}

//==================================================================================
//	popoverWillShow:
//==================================================================================

- (void)popoverWillShow:(NSNotification *)notification
{
}

//==================================================================================
//	popoverDidClose:
//==================================================================================

- (void)popoverDidClose:(NSNotification *)notification
{
    [colorAttributeEditor updateDocumentViews];
}

//==================================================================================
//	numericStringWithFloat
//==================================================================================

- (NSString *)numericStringWithFloat:(float)floatValue
{
    NSString * numericString = @"0";

    numericString = [NSString stringWithFormat:@"%f", floatValue];
    
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
//	defsElementForXMLDocument
//==================================================================================

- (NSXMLElement *)defsElementForXMLDocument:(NSXMLDocument *)xmlDocument;
{
    NSXMLElement * resultElement = NULL;

    NSXMLElement * rootElement = [xmlDocument rootElement];

    NSArray * styleElementsArray = [rootElement elementsForName:@"defs"];
    
    if (styleElementsArray.count > 0)
    {
        resultElement = styleElementsArray[0];
    }
    else
    {
        NSDictionary * drawableObjectsDictionary = @{@"rect": @"rect",
                @"circle": @"circle",
                @"ellipse": @"ellipse",
                @"text": @"text",
                @"image": @"image",
                @"line": @"line",
                @"polyline": @"polyline",
                @"polygon": @"polygon",
                @"path": @"path",
                @"use": @"use",
                @"g": @"g",
                @"foreignObject": @"foreignObject"};

        // determine a good insertion point for the defs element
        NSArray * nodesArray = rootElement.children;
        NSInteger nodeIndex = 0;
        for (NSXMLNode * aNode in nodesArray)
        {
            NSXMLNodeKind nodeKind = aNode.kind;
            
            if (nodeKind == NSXMLElementKind)
            {
                NSXMLElement * aElement = (NSXMLElement *)aNode;
                NSString * elementName = aElement.name;
                
                if (drawableObjectsDictionary[elementName] != NULL)
                {
                    break;
                }
            }
            nodeIndex++;
        }
        
        if (nodeIndex > 0) nodeIndex--;
        
        resultElement = [[NSXMLElement alloc] initWithName:@"defs"];
        
        NSXMLNode * idAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        idAttribute.name = @"id";
        idAttribute.stringValue = @"svg_document_defs";
        
        [resultElement addAttribute:idAttribute];
        
        [colorAttributeEditor assignMacsvgidsForNode:resultElement];
        
        [rootElement insertChild:resultElement atIndex:nodeIndex];
    }
    
    return resultElement;
}

//==================================================================================
//	numberOfRowsInGradientsTableView
//==================================================================================

- (NSInteger)numberOfRowsInGradientsTableView
{
    NSInteger result = 0;
    
    result = (self.gradientsArray).count;
    
    return result;
}

//==================================================================================
//	numberOfRowsInColorStopsTableView
//==================================================================================

- (NSInteger)numberOfRowsInColorStopsTableView
{
    NSInteger result = 0;
    
    result = (self.colorStopsArray).count;
    
    return result;
}

//==================================================================================
//	numberOfRowsInTableView:
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSInteger result = 0;
    
    if (aTableView == gradientElementsTableView)
    {
        result = [self numberOfRowsInGradientsTableView];
    }
    else if (aTableView == colorStopElementsTableView)
    {
        result = [self numberOfRowsInColorStopsTableView];
    }
    
    return result;
}

//==================================================================================
//	stringValueForGradientsColumn:rowIndex:
//==================================================================================

- (NSString *)stringValueForGradientsColumn:(NSTableColumn *)aTableColumn rowIndex:(NSInteger)rowIndex
{
    NSString * result = @"Missing Result";

    if ((self.gradientsArray).count > 0)
    {
        NSXMLElement * gradientElement = (self.gradientsArray)[rowIndex];

        NSString * tableColumnTitle= aTableColumn.identifier;
        
        if ([tableColumnTitle isEqualToString:@"gradientID"] == YES)
        {
            NSXMLNode * gradientElementIDNode = [gradientElement attributeForName:@"id"];
            NSString * gradientElementIDString = gradientElementIDNode.stringValue;
            result = gradientElementIDString;
        }
        else if ([tableColumnTitle isEqualToString:@"gradientType"] == YES)
        {
            NSString * gradientTagName = gradientElement.name;
            result = gradientTagName;
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
    
    if (aTableView == gradientElementsTableView)
    {
        result = [self stringValueForGradientsColumn:aTableColumn rowIndex:rowIndex];
    }
    else if (aTableView == colorStopElementsTableView)
    {
        result = NULL;
    }
    
    return result;
}

//==================================================================================
//	makeColorSwatchImage:
//==================================================================================

- (NSImage *)makeColorSwatchImage:(NSString *)colorString
{
    NSSize imageSize = NSMakeSize(17, 17);
    NSImage * colorSwatchImage = [[NSImage alloc] initWithSize:imageSize];

    float redFloat = 0.0f;
    float greenFloat = 1.0f;
    float blueFloat = 0.0f;

    NSInteger colorStringLength = colorString.length;
    if (colorString.length > 0)
    {
        unichar firstChar = [colorString characterAtIndex:0];
        if (firstChar == '#')
        {
            NSRange hexRange;
            hexRange.location = 0;
            hexRange.length = 0;

            if (colorStringLength == 4)
            {
                // short-form hex specification
                hexRange.location = 1;
                hexRange.length = 3;
            }
            
            if (colorStringLength == 7)
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
                    unichar colorChar = [colorString characterAtIndex:i];

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
                    
                    if (colorStringLength == 4)
                    {
                        unichar redChar = [colorString characterAtIndex:1];
                        unichar greenChar = [colorString characterAtIndex:2];
                        unichar blueChar = [colorString characterAtIndex:1];
                        
                        redString = [NSString stringWithFormat:@"%C%C", redChar, redChar];
                        greenString = [NSString stringWithFormat:@"%C%C", greenChar, greenChar];
                        blueString = [NSString stringWithFormat:@"%C%C", blueChar, blueChar];
                    }
                    
                    if (colorStringLength == 7)
                    {
                        NSRange redRange = NSMakeRange(1, 2);
                        NSRange greenRange = NSMakeRange(3, 2);
                        NSRange blueRange = NSMakeRange(5, 2);
                        
                        redString = [colorString substringWithRange:redRange];
                        greenString = [colorString substringWithRange:greenRange];
                        blueString = [colorString substringWithRange:blueRange];
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
                    
                    redFloat = (float)redInt / 255.0f;
                    greenFloat = (float)greenInt / 255.0f;
                    blueFloat = (float)blueInt / 255.0f;
                }
            }
        }
        else
        {
            // try web color lookup
            NSArray * webColorsArray = colorAttributeEditor.webColorsArray;
            
            for (NSDictionary * webColorDictionary in webColorsArray)
            {
                NSString * webColorName = webColorDictionary[@"name"];
                if ([colorString isEqualToString:webColorName] == YES)
                {
                    NSString * rgbColorString = webColorDictionary[@"rgb"];
                    
                    NSArray * rgbArray = [rgbColorString componentsSeparatedByString:@","];
                    
                    NSString * redString = rgbArray[0];
                    NSString * greenString = rgbArray[1];
                    NSString * blueString = rgbArray[2];
                    
                    NSInteger redInt = redString.integerValue;
                    NSInteger greenInt = greenString.integerValue;
                    NSInteger blueInt = blueString.integerValue;

                    redFloat = (float)redInt / 255.0f;
                    greenFloat = (float)greenInt / 255.0f;
                    blueFloat = (float)blueInt / 255.0f;
                    
                    break;
                }
            }
        }
    }

    [colorSwatchImage lockFocus];
    
    NSColor * swatchColor = [NSColor colorWithCalibratedRed:redFloat green:greenFloat blue:blueFloat alpha:1.0f];
    [swatchColor set];
    
    NSRect imageRect = NSMakeRect(0, 0, 17, 17);

    NSRectFill(imageRect);
    [colorSwatchImage unlockFocus];
    
    return colorSwatchImage;
}

//==================================================================================
//	viewForColorStopsColumn:rowIndex:
//==================================================================================

- (NSView *)viewForColorStopsColumn:(NSTableColumn *)aTableColumn rowIndex:(NSInteger)rowIndex
{
    NSView * resultView = NULL;

    if ((self.colorStopsArray).count > 0)
    {
        NSXMLElement * colorStopElement = (self.colorStopsArray)[rowIndex];

        NSString * tableColumnIdentifier= aTableColumn.identifier;
        
        if ([tableColumnIdentifier isEqualToString:@"stopIndex"] == YES)
        {
            NSTableCellView * cellView = [colorStopElementsTableView makeViewWithIdentifier:tableColumnIdentifier owner:self];

            NSString * rowIndexString = [NSString stringWithFormat:@"%ld", (rowIndex + 1)];
            
            cellView.textField.stringValue = rowIndexString;
            
            resultView = cellView;
        }
        else if ([tableColumnIdentifier isEqualToString:@"stopID"] == YES)
        {
            NSTableCellView * cellView = [colorStopElementsTableView makeViewWithIdentifier:tableColumnIdentifier owner:self];

            NSXMLNode * colorStopIDNode = [colorStopElement attributeForName:@"id"];
            NSString * colorStopIDString = colorStopIDNode.stringValue;
            
            NSXMLNode * offsetNode = [colorStopElement attributeForName:@"offset"];
            NSString * offsetString = offsetNode.stringValue;
            
            NSString * cellTextString = [NSString stringWithFormat:@"%@ - %@", offsetString, colorStopIDString];
            
            NSXMLNode * stopColorNode = [colorStopElement attributeForName:@"stop-color"];
            NSString * stopColorString = stopColorNode.stringValue;
            
            NSImage * colorImage = [self makeColorSwatchImage:stopColorString];
            
            cellView.textField.stringValue = cellTextString;
            cellView.imageView.objectValue = colorImage;
            
            resultView = cellView;
        }
        else
        {
            resultView = [colorStopElementsTableView makeViewWithIdentifier:tableColumnIdentifier owner:self];
        }
    }
    
    return resultView;
}

//==================================================================================
//	viewForGradientColumn:rowIndex:
//==================================================================================

- (NSView *)viewForGradientColumn:(NSTableColumn *)aTableColumn rowIndex:(NSInteger)rowIndex
{
    NSView * resultView = NULL;

    if ((self.gradientsArray).count > 0)
    {
        NSXMLElement * gradientElement = (self.gradientsArray)[rowIndex];

        NSString * tableColumnIdentifier= aTableColumn.identifier;
        
        if ([tableColumnIdentifier isEqualToString:@"gradientID"] == YES)
        {
            NSTableCellView * cellView = [gradientElementsTableView makeViewWithIdentifier:tableColumnIdentifier owner:self];

            NSString * gradientIDString = @"";
            NSXMLNode * gradientIDNode = [gradientElement attributeForName:@"id"];
            if (gradientIDNode != NULL)
            {
                gradientIDString = gradientIDNode.stringValue;
            }
            
            cellView.textField.stringValue = gradientIDString;
            
            resultView = cellView;
        }
        else if ([tableColumnIdentifier isEqualToString:@"gradientType"] == YES)
        {
            NSTableCellView * cellView = [gradientElementsTableView makeViewWithIdentifier:tableColumnIdentifier owner:self];

            NSString * gradientTagNameString = gradientElement.name;
            
            cellView.textField.stringValue = gradientTagNameString;
            
            resultView = cellView;
        }
        else
        {
            resultView = [colorStopElementsTableView makeViewWithIdentifier:tableColumnIdentifier owner:self];
        }
    }
    
    return resultView;
}

//==================================================================================
//	tableView:viewForTableColumn:row:
//==================================================================================

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSView * resultView = NULL;
    
    if (tableView == gradientElementsTableView)
    {
        resultView = [self viewForGradientColumn:tableColumn rowIndex:row];
    }
    else if (tableView == colorStopElementsTableView)
    {
        resultView = [self viewForColorStopsColumn:tableColumn rowIndex:row];
    }
    else
    {
        NSLog(@"GradientEditorPopoverViewController viewForTableColumn view error");
    }
    
    return resultView;
}

//==================================================================================
//	loadXML
//==================================================================================

- (void)loadXML:(NSString *)xmlString
{
    NSData * xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * baseURL = NULL;
    
    NSString * mimeType = @"image/svg+xml";

    [gradientPreviewWebView.mainFrame loadData:xmlData
            MIMEType:mimeType	
            textEncodingName:@"UTF-8" 
            baseURL:baseURL];
}

//==================================================================================
//	loadGradientTextFields
//==================================================================================

- (void)loadGradientTextFields
{
    NSInteger rowIndex = gradientElementsTableView.selectedRow;
    
    if (rowIndex != -1)
    {
        if ((self.gradientsArray).count > 0)
        {
            NSXMLElement * gradientElement = (self.gradientsArray)[rowIndex];

            [self loadPresetOptionsForGradientElement:gradientElement];
            
            NSString * elementName = gradientElement.name;
            gradientTypeTextField.stringValue = elementName;
            
            NSString * idString = @"";
            NSXMLNode * idNode = [gradientElement attributeForName:@"id"];
            if (idNode != NULL)
            {
                idString = idNode.stringValue;
            }
            gradientIDTextField.stringValue = idString;
            
            
            if ([elementName isEqualToString:@"radialGradient"] == YES)
            {
                gradientX1Label.stringValue = @"cx";
                NSString * cxString = @"";
                NSXMLNode * cxNode = [gradientElement attributeForName:@"cx"];
                if (cxNode != NULL)
                {
                    cxString = cxNode.stringValue;
                }
                gradientX1TextField.stringValue = cxString;
                
                gradientY1Label.stringValue = @"cy";
                NSString * cyString = @"";
                NSXMLNode * cyNode = [gradientElement attributeForName:@"cy"];
                if (cyNode != NULL)
                {
                    cyString = cyNode.stringValue;
                }
                gradientY1TextField.stringValue = cyString;
                
                gradientX2Label.stringValue = @"fx";
                NSString * fxString = @"";
                NSXMLNode * fxNode = [gradientElement attributeForName:@"fx"];
                if (fxNode != NULL)
                {
                    fxString = fxNode.stringValue;
                }
                gradientX2TextField.stringValue = fxString;
                
                gradientY2Label.stringValue = @"fy";
                NSString * fyString = @"";
                NSXMLNode * fyNode = [gradientElement attributeForName:@"fy"];
                if (fyNode != NULL)
                {
                    fyString = fyNode.stringValue;
                }
                gradientY2TextField.stringValue = fyString;

                NSString * rString = @"";
                NSXMLNode * rNode = [gradientElement attributeForName:@"r"];
                if (rNode != NULL)
                {
                    rString = rNode.stringValue;
                }
                gradientRTextField.stringValue = rString;
                [gradientRTextField setHidden:NO];
                
                [gradientRLabel setHidden:NO];
            }
            else
            {
                gradientX1Label.stringValue = @"x1";
                NSString * x1String = @"";
                NSXMLNode * x1Node = [gradientElement attributeForName:@"x1"];
                if (x1Node != NULL)
                {
                    x1String = x1Node.stringValue;
                }
                gradientX1TextField.stringValue = x1String;
                
                gradientY1Label.stringValue = @"y1";
                NSString * y1String = @"";
                NSXMLNode * y1Node = [gradientElement attributeForName:@"y1"];
                if (y1Node != NULL)
                {
                    y1String = y1Node.stringValue;
                }
                gradientY1TextField.stringValue = y1String;
                
                gradientX2Label.stringValue = @"x2";
                NSString * x2String = @"";
                NSXMLNode * x2Node = [gradientElement attributeForName:@"x2"];
                if (x2Node != NULL)
                {
                    x2String = x2Node.stringValue;
                }
                gradientX2TextField.stringValue = x2String;
                
                gradientY2Label.stringValue = @"y2";
                NSString * y2String = @"";
                NSXMLNode * y2Node = [gradientElement attributeForName:@"y2"];
                if (y2Node != NULL)
                {
                    y2String = y2Node.stringValue;
                }
                gradientY2TextField.stringValue = y2String;

                gradientRTextField.stringValue = @"";
                [gradientRTextField setHidden:YES];
                
                [gradientRLabel setHidden:YES];
            }
        }
        
        [newColorStopButton setEnabled:YES];
        [applyGradientButton setEnabled:YES];
    }
    else
    {
        gradientTypeTextField.stringValue = @"";
        gradientIDTextField.stringValue = @"";
        gradientX1TextField.stringValue = @"";
        gradientY1TextField.stringValue = @"";
        gradientX2TextField.stringValue = @"";
        gradientY2TextField.stringValue = @"";
        gradientRTextField.stringValue = @"";
        [self loadPresetOptionsForGradientElement:NULL];
        
        [newColorStopButton setEnabled:NO];
        [applyGradientButton setEnabled:NO];
    }
}

//==================================================================================
//	loadPresetsMenu:
//==================================================================================

- (void)loadPresetOptionsForGradientElement:(NSXMLElement *)gradientElement
{
    [presetsPopUpButton removeAllItems];
    
    [presetsPopUpButton addItemWithTitle:@"Presets"];
    NSMenuItem * presetsItem = [presetsPopUpButton itemWithTitle:@"Presets"];
    [presetsItem setEnabled:NO];
    [presetsPopUpButton selectItemAtIndex:0];

    if (gradientElement != NULL)
    {
        NSString * elementName = gradientElement.name;

        if ([elementName isEqualToString:@"linearGradient"] == YES)
        {
            [presetsPopUpButton addItemWithTitle:@"Top-to-Bottom"];
            [presetsPopUpButton addItemWithTitle:@"Left-to-Right"];
            [presetsPopUpButton addItemWithTitle:@"Top Left-to-Bottom Right"];
            [presetsPopUpButton addItemWithTitle:@"Bottom Left-to-Top Right"];
        }
        else if ([elementName isEqualToString:@"radialGradient"] == YES)
        {
            [presetsPopUpButton addItemWithTitle:@"Center"];
            [presetsPopUpButton addItemWithTitle:@"Top"];
            [presetsPopUpButton addItemWithTitle:@"Bottom"];
            [presetsPopUpButton addItemWithTitle:@"Left"];
            [presetsPopUpButton addItemWithTitle:@"Right"];
            [presetsPopUpButton addItemWithTitle:@"Top Left"];
            [presetsPopUpButton addItemWithTitle:@"Top Right"];
            [presetsPopUpButton addItemWithTitle:@"Bottom Left"];
            [presetsPopUpButton addItemWithTitle:@"Bottom Right"];
        }
    }
}

//==================================================================================
//	presetsPopUpButtonAction
//==================================================================================

- (IBAction)presetsPopUpButtonAction:(id)sender
{
    NSString * presetValue = presetsPopUpButton.titleOfSelectedItem;
    
    if ([presetValue isEqualToString:@"Top-to-Bottom"] == YES)
    {
        gradientX1TextField.stringValue = @"0%";
        gradientY1TextField.stringValue = @"0%";
        gradientX2TextField.stringValue = @"0%";
        gradientY2TextField.stringValue = @"100%";
    }
    else if ([presetValue isEqualToString:@"Left-to-Right"] == YES)
    {
        gradientX1TextField.stringValue = @"0%";
        gradientY1TextField.stringValue = @"0%";
        gradientX2TextField.stringValue = @"100%";
        gradientY2TextField.stringValue = @"0%";
    }
    else if ([presetValue isEqualToString:@"Top Left-to-Bottom Right"] == YES)
    {
        gradientX1TextField.stringValue = @"0%";
        gradientY1TextField.stringValue = @"0%";
        gradientX2TextField.stringValue = @"100%";
        gradientY2TextField.stringValue = @"100%";
    }
    else if ([presetValue isEqualToString:@"Bottom Left-to-Top Right"] == YES)
    {
        gradientX1TextField.stringValue = @"0%";
        gradientY1TextField.stringValue = @"100%";
        gradientX2TextField.stringValue = @"100%";
        gradientY2TextField.stringValue = @"0%";
    }
    else if ([presetValue isEqualToString:@"Center"] == YES)
    {
        gradientX1TextField.stringValue = @"50%";    // cx
        gradientY1TextField.stringValue = @"50%";    // cy
        gradientX2TextField.stringValue = @"50%";    // fx
        gradientY2TextField.stringValue = @"50%";    // fy
        gradientRTextField.stringValue = @"50%";     // r
    }
    else if ([presetValue isEqualToString:@"Top"] == YES)
    {
        gradientX1TextField.stringValue = @"50%";    // cx
        gradientY1TextField.stringValue = @"0%";     // cy
        gradientX2TextField.stringValue = @"50%";    // fx
        gradientY2TextField.stringValue = @"0%";    // fy
        gradientRTextField.stringValue = @"100%";     // r
    }
    else if ([presetValue isEqualToString:@"Bottom"] == YES)
    {
        gradientX1TextField.stringValue = @"50%";    // cx
        gradientY1TextField.stringValue = @"100%";     // cy
        gradientX2TextField.stringValue = @"50%";    // fx
        gradientY2TextField.stringValue = @"100%";    // fy
        gradientRTextField.stringValue = @"100%";     // r
    }
    else if ([presetValue isEqualToString:@"Left"] == YES)
    {
        gradientX1TextField.stringValue = @"0%";    // cx
        gradientY1TextField.stringValue = @"50%";     // cy
        gradientX2TextField.stringValue = @"0%";    // fx
        gradientY2TextField.stringValue = @"50%";    // fy
        gradientRTextField.stringValue = @"100%";     // r
    }
    else if ([presetValue isEqualToString:@"Right"] == YES)
    {
        gradientX1TextField.stringValue = @"100%";    // cx
        gradientY1TextField.stringValue = @"50%";     // cy
        gradientX2TextField.stringValue = @"100%";    // fx
        gradientY2TextField.stringValue = @"50%";    // fy
        gradientRTextField.stringValue = @"100%";     // r
    }
    else if ([presetValue isEqualToString:@"Top Left"] == YES)
    {
        gradientX1TextField.stringValue = @"0%";    // cx
        gradientY1TextField.stringValue = @"0%";     // cy
        gradientX2TextField.stringValue = @"0%";    // fx
        gradientY2TextField.stringValue = @"0%";    // fy
        gradientRTextField.stringValue = @"100%";     // r
    }
    else if ([presetValue isEqualToString:@"Top Right"] == YES)
    {
        gradientX1TextField.stringValue = @"100%";    // cx
        gradientY1TextField.stringValue = @"0%";     // cy
        gradientX2TextField.stringValue = @"100%";    // fx
        gradientY2TextField.stringValue = @"0%";    // fy
        gradientRTextField.stringValue = @"100%";     // r
    }
    else if ([presetValue isEqualToString:@"Bottom Left"] == YES)
    {
        gradientX1TextField.stringValue = @"0%";    // cx
        gradientY1TextField.stringValue = @"100%";     // cy
        gradientX2TextField.stringValue = @"0%";    // fx
        gradientY2TextField.stringValue = @"100%";    // fy
        gradientRTextField.stringValue = @"100%";     // r
    }
    else if ([presetValue isEqualToString:@"Bottom Right"] == YES)
    {
        gradientX1TextField.stringValue = @"100%";    // cx
        gradientY1TextField.stringValue = @"100%";     // cy
        gradientX2TextField.stringValue = @"100%";    // fx
        gradientY2TextField.stringValue = @"100%";    // fy
        gradientRTextField.stringValue = @"100%";     // r
    }
    
    [self updateGradientElement];
    [self updateGradientPreview];
    
    [presetsPopUpButton selectItemAtIndex:0];
    NSMenuItem * topMenuItem = [presetsPopUpButton itemAtIndex:0];
    [topMenuItem setEnabled:NO];
}

//==================================================================================
//	loadColorStopTextFields
//==================================================================================

- (void)loadColorStopTextFields
{
    NSInteger rowIndex = colorStopElementsTableView.selectedRow;
    
    if (rowIndex != -1)
    {
        if ((self.colorStopsArray).count > 0)
        {
            NSXMLElement * colorStopElement = (self.colorStopsArray)[rowIndex];
            
            NSString * idString = @"";
            NSXMLNode * idNode = [colorStopElement attributeForName:@"id"];
            if (idNode != NULL)
            {
                idString = idNode.stringValue;
            }
            colorStopIDTextField.stringValue = idString;
            
            NSString * offsetString = @"";
            NSXMLNode * offsetNode = [colorStopElement attributeForName:@"offset"];
            if (offsetNode != NULL)
            {
                offsetString = offsetNode.stringValue;
            }
            colorStopOffsetTextField.stringValue = offsetString;
            
            NSString * colorString = @"";
            NSXMLNode * colorNode = [colorStopElement attributeForName:@"stop-color"];
            if (colorNode != NULL)
            {
                colorString = colorNode.stringValue;
            }
            colorStopColorComboBox.stringValue = colorString;
            
            NSString * opacityString = @"";
            NSXMLNode * opacityNode = [colorStopElement attributeForName:@"stop-opacity"];
            if (opacityNode != NULL)
            {
                opacityString = opacityNode.stringValue;
            }
            colorStopOpacityTextField.stringValue = opacityString;
            
            [self updateColorWell];
        }
    }
    else
    {
        colorStopIDTextField.stringValue = @"";
        colorStopOffsetTextField.stringValue = @"";
        colorStopColorComboBox.stringValue = @"";
        colorStopOpacityTextField.stringValue = @"";
        colorStopColorWell.color = [NSColor whiteColor];
    }
}

//==================================================================================
//	gradientPreviewTableViewSelectionDidChange
//==================================================================================

- (void)gradientPreviewTableViewSelectionDidChange
{
    [self loadGradientTextFields];
    
    [colorStopElementsTableView deselectAll:self];

    [self loadColorStopTextFields];

    [self loadColorStopsData];
    
    [self updateGradientPreview];
}

//==================================================================================
//	updateGradientPreview
//==================================================================================

- (void)updateGradientPreview
{
    NSString * gradientXML = [self makeGradientPreviewSVG];
    
    [self loadXML:gradientXML];
}

//==================================================================================
//	colorStopsTableViewSelectionDidChange
//==================================================================================

- (void)colorStopsTableViewSelectionDidChange
{
    NSInteger rowIndex = colorStopElementsTableView.selectedRow;
    
    if (rowIndex != -1)
    {
        [deleteColorStopButton setEnabled:YES];
    }
    else
    {
        [deleteColorStopButton setEnabled:NO];
    }

    [self loadColorStopTextFields];
}

//==================================================================================
//	updateGradientElement
//==================================================================================

- (void)updateGradientElement
{
    NSInteger rowIndex = gradientElementsTableView.selectedRow;
    
    if (rowIndex != -1)
    {
        if ((self.gradientsArray).count > 0)
        {
            NSXMLElement * gradientElement = (self.gradientsArray)[rowIndex];
            
            NSString * elementName = gradientElement.name;
            gradientTypeTextField.stringValue = elementName;
            
            NSString * idString = gradientIDTextField.stringValue;
            NSXMLNode * idNode = [gradientElement attributeForName:@"id"];
            if (idNode == NULL)
            {
                idNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                idNode.name = @"id";
                idNode.stringValue = @"";
                [gradientElement addAttribute:idNode];
            }
            idNode.stringValue = idString;
            
            if ([elementName isEqualToString:@"radialGradient"] == YES)
            {
                NSString * cxString = gradientX1TextField.stringValue;
                NSXMLNode * cxNode = [gradientElement attributeForName:@"cx"];
                if (cxNode == NULL)
                {
                    cxNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                    cxNode.name = @"cx";
                    cxNode.stringValue = @"";
                    [gradientElement addAttribute:cxNode];
                }
                cxNode.stringValue = cxString;

                NSString * cyString = gradientY1TextField.stringValue;
                NSXMLNode * cyNode = [gradientElement attributeForName:@"cy"];
                if (cyNode == NULL)
                {
                    cyNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                    cyNode.name = @"cy";
                    cyNode.stringValue = @"";
                    [gradientElement addAttribute:cyNode];
                }
                cyNode.stringValue = cyString;

                NSString * fxString = gradientX2TextField.stringValue;
                NSXMLNode * fxNode = [gradientElement attributeForName:@"fx"];
                if (fxNode == NULL)
                {
                    fxNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                    fxNode.name = @"fx";
                    fxNode.stringValue = @"";
                    [gradientElement addAttribute:fxNode];
                }
                fxNode.stringValue = fxString;

                NSString * fyString = gradientY2TextField.stringValue;
                NSXMLNode * fyNode = [gradientElement attributeForName:@"fy"];
                if (fyNode == NULL)
                {
                    fyNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                    fyNode.name = @"fy";
                    fyNode.stringValue = @"";
                    [gradientElement addAttribute:fyNode];
                }
                fyNode.stringValue = fyString;

                NSString * rString = gradientRTextField.stringValue;
                NSXMLNode * rNode = [gradientElement attributeForName:@"r"];
                if (rNode == NULL)
                {
                    rNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                    rNode.name = @"r";
                    rNode.stringValue = @"";
                    [gradientElement addAttribute:rNode];
                }
                rNode.stringValue = rString;
            }
            else
            {
                NSString * x1String = gradientX1TextField.stringValue;
                NSXMLNode * x1Node = [gradientElement attributeForName:@"x1"];
                if (x1Node == NULL)
                {
                    x1Node = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                    x1Node.name = @"x1";
                    x1Node.stringValue = @"";
                    [gradientElement addAttribute:x1Node];
                }
                x1Node.stringValue = x1String;

                NSString * y1String = gradientY1TextField.stringValue;
                NSXMLNode * y1Node = [gradientElement attributeForName:@"y1"];
                if (y1Node == NULL)
                {
                    y1Node = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                    y1Node.name = @"y1";
                    y1Node.stringValue = @"";
                    [gradientElement addAttribute:y1Node];
                }
                y1Node.stringValue = y1String;

                NSString * x2String = gradientX2TextField.stringValue;
                NSXMLNode * x2Node = [gradientElement attributeForName:@"x2"];
                if (x2Node == NULL)
                {
                    x2Node = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                    x2Node.name = @"x2";
                    x2Node.stringValue = @"";
                    [gradientElement addAttribute:x2Node];
                }
                x2Node.stringValue = x2String;

                NSString * y2String = gradientY2TextField.stringValue;
                NSXMLNode * y2Node = [gradientElement attributeForName:@"y2"];
                if (y2Node == NULL)
                {
                    y2Node = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                    y2Node.name = @"y2";
                    y2Node.stringValue = @"";
                    [gradientElement addAttribute:y2Node];
                }
                y2Node.stringValue = y2String;
            }
        }
    }
}

//==================================================================================
//	updateColorStopElement
//==================================================================================

- (void)updateColorStopElement
{
    NSInteger rowIndex = colorStopElementsTableView.selectedRow;
    
    if (rowIndex != -1)
    {
        if ((self.colorStopsArray).count > 0)
        {
            NSXMLElement * colorStopElement = (self.colorStopsArray)[rowIndex];

            NSString * idString = colorStopIDTextField.stringValue;
            NSXMLNode * idNode = [colorStopElement attributeForName:@"id"];
            if (idNode == NULL)
            {
                idNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                idNode.name = @"x1";
                idNode.stringValue = @"";
                [colorStopElement addAttribute:idNode];
            }
            idNode.stringValue = idString;

            NSString * offsetString = colorStopOffsetTextField.stringValue;
            NSXMLNode * offsetNode = [colorStopElement attributeForName:@"offset"];
            if (offsetNode == NULL)
            {
                offsetNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                offsetNode.name = @"offset";
                offsetNode.stringValue = @"";
                [colorStopElement addAttribute:offsetNode];
            }
            offsetNode.stringValue = offsetString;

            NSString * colorString = colorStopColorComboBox.stringValue;
            NSXMLNode * colorNode = [colorStopElement attributeForName:@"stop-color"];
            if (colorNode == NULL)
            {
                colorNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                colorNode.name = @"stop-color";
                colorNode.stringValue = @"";
                [colorStopElement addAttribute:colorNode];
            }
            colorNode.stringValue = colorString;

            NSString * opacityString = colorStopOpacityTextField.stringValue;
            if (opacityString.length > 0)
            {
                NSXMLNode * opacityNode = [colorStopElement attributeForName:@"stop-opacity"];
                if (opacityNode == NULL)
                {
                    opacityNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                    opacityNode.name = @"stop-opacity";
                    opacityNode.stringValue = @"";
                    [colorStopElement addAttribute:opacityNode];
                }
                opacityNode.stringValue = opacityString;
            }
            else
            {
                [colorStopElement removeAttributeForName:@"stop-opacity"];
            }
            
            //[self updateColorWell];
        }
    }
    
    [self sortGradientColorStops];
    
    [colorStopElementsTableView reloadData];
}

//==================================================================================
//	sortGradientColorStops
//==================================================================================

- (void)sortGradientColorStops
{
    NSInteger rowIndex = gradientElementsTableView.selectedRow;
    
    if (rowIndex != -1)
    {
        if ((self.gradientsArray).count > 0)
        {
            NSXMLElement * gradientElement = (self.gradientsArray)[rowIndex];
            
            NSArray * gradientChildArray = gradientElement.children;
            
            NSMutableArray * unsortedColorStopsArray = [NSMutableArray array];
            
            for (NSXMLNode * childNode in gradientChildArray)
            {
                if (childNode.kind == NSXMLElementKind)
                {
                    NSXMLElement * childElement = (NSXMLElement *)childNode;
                    
                    NSString * childElementName = childElement.name;
                    
                    if ([childElementName isEqualToString:@"stop"] == YES)
                    {
                        [unsortedColorStopsArray addObject:childElement];
                    }
                }
            }
            
            if (unsortedColorStopsArray.count > 0)
            {
                NSArray * sortedColorStopsArray = [unsortedColorStopsArray
                        sortedArrayUsingFunction:colorStopsSort context:NULL];
                
                for (NSXMLElement * aElement in sortedColorStopsArray)
                {
                    [aElement detach];
                }
                
                for (NSXMLElement * aElement in sortedColorStopsArray)
                {
                    [gradientElement addChild:aElement];
                }
            }
        }
    }
}

//==================================================================================
//	selectionShouldChangeInTableView:
//==================================================================================

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
    if (aTableView == gradientElementsTableView)
    {
        [self updateGradientElement];
        [self updateColorStopElement];
    }
    else if (aTableView == colorStopElementsTableView)
    {
        [self updateColorStopElement];
    }
    return YES;
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = aNotification.object;
    if (aTableView == gradientElementsTableView)
    {
        [self gradientPreviewTableViewSelectionDidChange];
    }
    else if (aTableView == colorStopElementsTableView)
    {
        [self colorStopsTableViewSelectionDidChange];
    }
}

//==================================================================================
//	findAllLinearGradientElements
//==================================================================================

 -(NSArray *)findAllLinearGradientElements
 {       
    NSArray * resultArray = NULL;
    
    NSXMLDocument * svgXmlDocument = colorAttributeEditor.svgXmlDocument;
    NSXMLElement * rootElement = [svgXmlDocument rootElement];
    
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
    
    NSXMLDocument * svgXmlDocument = colorAttributeEditor.svgXmlDocument;
    NSXMLElement * rootElement = [svgXmlDocument rootElement];
    
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
//	loadGradientsData
//==================================================================================

 -(void)loadGradientsData
{
    gradientTypeTextField.stringValue = @"";
    gradientIDTextField.stringValue = @"";
    gradientX1TextField.stringValue = @"";
    gradientY1TextField.stringValue = @"";
    gradientX2TextField.stringValue = @"";
    gradientY2TextField.stringValue = @"";
    gradientRTextField.stringValue = @"";
    colorStopIDTextField.stringValue = @"";
    colorStopOffsetTextField.stringValue = @"";
    colorStopColorComboBox.stringValue = @"";
    colorStopOpacityTextField.stringValue = @"";
    colorStopColorWell.color = [NSColor whiteColor];

    [self.gradientsArray removeAllObjects];
    NSArray * gradientElementsArray = [self findAllGradientElements];
    [self.gradientsArray addObjectsFromArray:gradientElementsArray];

    [gradientElementsTableView reloadData];

    NSXMLElement * targetElement = colorAttributeEditor.pluginTargetXMLElement;
    NSString * activeAttributeName = colorAttributeEditor.activeAttributeName;
    
    NSXMLNode * attributeNode = [targetElement attributeForName:activeAttributeName];
    if (attributeNode != NULL)
    {
        NSString * attributeValue = attributeNode.stringValue;
        
        if (attributeValue.length > 1)
        {
            BOOL validGradientIDFound = NO;
            NSInteger foundGradientIndex = 0;
            
            unichar firstChar = [attributeValue characterAtIndex:0];
            
            if (firstChar == '#')
            {
                NSInteger extractLength = attributeValue.length - 1;
                NSRange extractURLRange = NSMakeRange(1, extractLength);
                NSString * idString = [attributeValue substringWithRange:extractURLRange];
                
                for (NSXMLElement * aGradientElement in self.gradientsArray)
                {
                    NSXMLNode * gradientIDNode = [aGradientElement attributeForName:@"id"];
                    NSString * gradientIDString = gradientIDNode.stringValue;
                    
                    if ([idString isEqualToString:gradientIDString] == YES)
                    {
                        validGradientIDFound = YES;
                        foundGradientIndex = [self.gradientsArray indexOfObject:aGradientElement];
                        break;
                    }
                }
            }
            else
            {
                NSRange urlRange = [attributeValue rangeOfString:@"url(#"];
                if (urlRange.location == 0)
                {
                    NSInteger extractLength = attributeValue.length - 6;
                    NSRange extractURLRange = NSMakeRange(5, extractLength);
                    NSString * idString = [attributeValue substringWithRange:extractURLRange];
                    
                    for (NSXMLElement * aGradientElement in self.gradientsArray)
                    {
                        NSXMLNode * gradientIDNode = [aGradientElement attributeForName:@"id"];
                        NSString * gradientIDString = gradientIDNode.stringValue;
                        
                        if ([idString isEqualToString:gradientIDString] == YES)
                        {
                            validGradientIDFound = YES;
                            foundGradientIndex = [self.gradientsArray indexOfObject:aGradientElement];
                            break;
                        }
                    }
                }
            }
            
            if (validGradientIDFound == YES)
            {
                NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:foundGradientIndex];
                [gradientElementsTableView selectRowIndexes:indexSet byExtendingSelection:NO];
            }
        }
    }

    [self loadColorStopsData];
}

//==================================================================================
//	loadColorStopsData
//==================================================================================

 -(void)loadColorStopsData
{
    [self.colorStopsArray removeAllObjects];

    NSInteger rowIndex = gradientElementsTableView.selectedRow;

    NSMutableArray * buildColorStopsArray = [NSMutableArray array];

    if (rowIndex != -1)
    {
        if ((self.gradientsArray).count > 0)
        {
            NSXMLElement * gradientElement = (self.gradientsArray)[rowIndex];
            
            [self sortGradientColorStops];
            
            NSArray * childElements = gradientElement.children;
            
            for (NSXMLNode * childNode in childElements)
            {
                if (childNode.kind == NSXMLElementKind)
                {
                    NSXMLElement * childElement = (NSXMLElement *)childNode;
                    NSString * elementName = childElement.name;
                    
                    if ([elementName isEqualToString:@"stop"] == YES)
                    {
                        [buildColorStopsArray addObject:childElement];
                    }
                }
            }
        }
    }

    [self.colorStopsArray addObjectsFromArray:buildColorStopsArray];

    [colorStopElementsTableView reloadData];
}

//==================================================================================
//	colorStopsSort()
//==================================================================================

NSComparisonResult colorStopsSort(id element1, id element2, void *context)
{
    NSComparisonResult sortResult = NSOrderedSame;

    NSXMLElement * colorStopElement1 = element1;
    NSXMLElement * colorStopElement2 = element2;

    NSString * offsetString1 = @"";
    NSString * offsetString2 = @"";

    float offsetFloat1 = 0;
    float offsetFloat2 = 0;

    NSXMLNode * offsetAttribute1 = [colorStopElement1 attributeForName:@"offset"];
    if (offsetAttribute1 != NULL)
    {
        offsetString1 = offsetAttribute1.stringValue;
        offsetFloat1 = offsetString1.floatValue;
    }

    NSXMLNode * offsetAttribute2 = [colorStopElement2 attributeForName:@"offset"];
    if (offsetAttribute2 != NULL)
    {
        offsetString2 = offsetAttribute2.stringValue;
        offsetFloat2 = offsetString2.floatValue;
    }

    //sortResult = [offsetString1 compare:offsetString2];
    if (offsetFloat1 > offsetFloat2)
    {
        sortResult = (NSComparisonResult)NSOrderedDescending;
    }
    else if (offsetFloat1 < offsetFloat2)
    {
        sortResult = (NSComparisonResult)NSOrderedAscending;
    }
    else
    {
        sortResult = (NSComparisonResult)NSOrderedSame;
    }

    return sortResult;
}

//==================================================================================
//	newLinearGradientButtonAction
//==================================================================================

- (IBAction)newLinearGradientButtonAction:(id)sender
{
    NSMutableArray * pendingIDs = [NSMutableArray array];

    NSXMLDocument * svgXmlDocument = colorAttributeEditor.svgXmlDocument;
    NSXMLElement * defsElement = [self defsElementForXMLDocument:svgXmlDocument];

    NSXMLElement * newLinearGradientElement = [[NSXMLElement alloc] init];
    newLinearGradientElement.name = @"linearGradient";

    NSString * linearGradientID =
            [colorAttributeEditor.macSVGPluginCallbacks
            uniqueIDForElementTagName:@"linearGradient" pendingIDs:pendingIDs];
    [pendingIDs addObject:linearGradientID];
    
    NSXMLNode * linearGradientIDAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    linearGradientIDAttributeNode.name = @"id";
    linearGradientIDAttributeNode.stringValue = linearGradientID;
    [newLinearGradientElement addAttribute:linearGradientIDAttributeNode];

    NSXMLNode * x1AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    x1AttributeNode.name = @"x1";
    x1AttributeNode.stringValue = @"0%";
    [newLinearGradientElement addAttribute:x1AttributeNode];

    NSXMLNode * y1AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    y1AttributeNode.name = @"y1";
    y1AttributeNode.stringValue = @"0%";
    [newLinearGradientElement addAttribute:y1AttributeNode];

    NSXMLNode * x2AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    x2AttributeNode.name = @"x2";
    x2AttributeNode.stringValue = @"0%";
    [newLinearGradientElement addAttribute:x2AttributeNode];

    NSXMLNode * y2AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    y2AttributeNode.name = @"y2";
    y2AttributeNode.stringValue = @"100%";
    [newLinearGradientElement addAttribute:y2AttributeNode];

    [colorAttributeEditor assignMacsvgidsForNode:newLinearGradientElement];

    NSXMLElement * newStop1Element = [[NSXMLElement alloc] init];
    newStop1Element.name = @"stop";

    NSString * stop1ID =
            [colorAttributeEditor.macSVGPluginCallbacks
            uniqueIDForElementTagName:@"stop" pendingIDs:pendingIDs];
    [pendingIDs addObject:stop1ID];

    NSXMLNode * stop1IDAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    stop1IDAttributeNode.name = @"id";
    stop1IDAttributeNode.stringValue = stop1ID;
    [newStop1Element addAttribute:stop1IDAttributeNode];

    NSXMLNode * offset1AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    offset1AttributeNode.name = @"offset";
    offset1AttributeNode.stringValue = @"0%";
    [newStop1Element addAttribute:offset1AttributeNode];

    NSXMLNode * stopColor1AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    stopColor1AttributeNode.name = @"stop-color";
    stopColor1AttributeNode.stringValue = @"white";
    [newStop1Element addAttribute:stopColor1AttributeNode];

    [colorAttributeEditor assignMacsvgidsForNode:newStop1Element];

    [newLinearGradientElement addChild:newStop1Element];

    NSXMLElement * newStop2Element = [[NSXMLElement alloc] init];
    newStop2Element.name = @"stop";

    NSString * stop2ID =
            [colorAttributeEditor.macSVGPluginCallbacks
            uniqueIDForElementTagName:@"stop" pendingIDs:pendingIDs];
    [pendingIDs addObject:stop2ID];

    NSXMLNode * stop2IDAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    stop2IDAttributeNode.name = @"id";
    stop2IDAttributeNode.stringValue = stop2ID;
    [newStop2Element addAttribute:stop2IDAttributeNode];

    NSXMLNode * offset2AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    offset2AttributeNode.name = @"offset";
    offset2AttributeNode.stringValue = @"100%";
    [newStop2Element addAttribute:offset2AttributeNode];

    NSXMLNode * stopColor2AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    stopColor2AttributeNode.name = @"stop-color";
    stopColor2AttributeNode.stringValue = @"black";
    [newStop2Element addAttribute:stopColor2AttributeNode];

    [colorAttributeEditor assignMacsvgidsForNode:newStop2Element];

    [newLinearGradientElement addChild:newStop2Element];

    [defsElement addChild:newLinearGradientElement];

    [self loadGradientsData];

    [gradientElementsTableView reloadData];
    [colorStopElementsTableView reloadData];

    NSInteger linearGradientIndex = [self.gradientsArray indexOfObject:newLinearGradientElement];
    NSIndexSet * rowIndexSet = [NSIndexSet indexSetWithIndex:linearGradientIndex];
    [gradientElementsTableView selectRowIndexes:rowIndexSet byExtendingSelection:NO];
}

//==================================================================================
//	newRadialGradientButtonAction
//==================================================================================

- (IBAction)newRadialGradientButtonAction:(id)sender
{
    NSMutableArray * pendingIDs = [NSMutableArray array];

    NSXMLDocument * svgXmlDocument = colorAttributeEditor.svgXmlDocument;
    NSXMLElement * defsElement = [self defsElementForXMLDocument:svgXmlDocument];

    NSXMLElement * newRadialGradientElement = [[NSXMLElement alloc] init];
    newRadialGradientElement.name = @"radialGradient";

    NSString * radialGradientID =
            [colorAttributeEditor.macSVGPluginCallbacks
            uniqueIDForElementTagName:@"radialGradient" pendingIDs:pendingIDs];
    [pendingIDs addObject:radialGradientID];

    NSXMLNode * radialGradientIDAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    radialGradientIDAttributeNode.name = @"id";
    radialGradientIDAttributeNode.stringValue = radialGradientID;
    [newRadialGradientElement addAttribute:radialGradientIDAttributeNode];

    NSXMLNode * cxAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    cxAttributeNode.name = @"cx";
    cxAttributeNode.stringValue = @"50%";
    [newRadialGradientElement addAttribute:cxAttributeNode];

    NSXMLNode * cyAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    cyAttributeNode.name = @"cy";
    cyAttributeNode.stringValue = @"50%";
    [newRadialGradientElement addAttribute:cyAttributeNode];

    NSXMLNode * fxAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    fxAttributeNode.name = @"fx";
    fxAttributeNode.stringValue = @"50%";
    [newRadialGradientElement addAttribute:fxAttributeNode];

    NSXMLNode * fyAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    fyAttributeNode.name = @"fy";
    fyAttributeNode.stringValue = @"50%";
    [newRadialGradientElement addAttribute:fyAttributeNode];

    NSXMLNode * rAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    rAttributeNode.name = @"r";
    rAttributeNode.stringValue = @"50%";
    [newRadialGradientElement addAttribute:rAttributeNode];

    [colorAttributeEditor assignMacsvgidsForNode:newRadialGradientElement];

    NSXMLElement * newStop1Element = [[NSXMLElement alloc] init];
    newStop1Element.name = @"stop";
    
    NSString * stop1ID =
            [colorAttributeEditor.macSVGPluginCallbacks
            uniqueIDForElementTagName:@"stop" pendingIDs:pendingIDs];
    [pendingIDs addObject:stop1ID];

    NSXMLNode * stop1IDAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    stop1IDAttributeNode.name = @"id";
    stop1IDAttributeNode.stringValue = stop1ID;
    [newStop1Element addAttribute:stop1IDAttributeNode];

    NSXMLNode * offset1AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    offset1AttributeNode.name = @"offset";
    offset1AttributeNode.stringValue = @"0%";
    [newStop1Element addAttribute:offset1AttributeNode];

    NSXMLNode * stopColor1AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    stopColor1AttributeNode.name = @"stop-color";
    stopColor1AttributeNode.stringValue = @"white";
    [newStop1Element addAttribute:stopColor1AttributeNode];

    [colorAttributeEditor assignMacsvgidsForNode:newStop1Element];

    [newRadialGradientElement addChild:newStop1Element];

    NSXMLElement * newStop2Element = [[NSXMLElement alloc] init];
    newStop2Element.name = @"stop";

    NSString * stop2ID =
            [colorAttributeEditor.macSVGPluginCallbacks
            uniqueIDForElementTagName:@"stop" pendingIDs:pendingIDs];
    [pendingIDs addObject:stop2ID];

    NSXMLNode * stop2IDAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    stop2IDAttributeNode.name = @"id";
    stop2IDAttributeNode.stringValue = stop2ID;
    [newStop2Element addAttribute:stop2IDAttributeNode];

    NSXMLNode * offset2AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    offset2AttributeNode.name = @"offset";
    offset2AttributeNode.stringValue = @"100%";
    [newStop2Element addAttribute:offset2AttributeNode];
    
    NSXMLNode * stopColor2AttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    stopColor2AttributeNode.name = @"stop-color";
    stopColor2AttributeNode.stringValue = @"black";
    [newStop2Element addAttribute:stopColor2AttributeNode];

    [colorAttributeEditor assignMacsvgidsForNode:newStop2Element];
    
    [newRadialGradientElement addChild:newStop2Element];
    
    [defsElement addChild:newRadialGradientElement];
    
    [self loadGradientsData];
    
    [gradientElementsTableView reloadData];
    [colorStopElementsTableView reloadData];
    
    NSInteger radialGradientIndex = [self.gradientsArray indexOfObject:newRadialGradientElement];
    NSIndexSet * rowIndexSet = [NSIndexSet indexSetWithIndex:radialGradientIndex];
    [gradientElementsTableView selectRowIndexes:rowIndexSet byExtendingSelection:NO];
}

//==================================================================================
//	newColorStopButtonAction
//==================================================================================

- (IBAction)newColorStopButtonAction:(id)sender
{
    [self sortGradientColorStops];
    
    NSXMLElement * gradientElement = NULL;
    NSXMLElement * colorStopElement = NULL;
    NSInteger gradientRowIndex = gradientElementsTableView.selectedRow;
    if (gradientRowIndex != -1)
    {
        if ((self.gradientsArray).count > 0)
        {
            gradientElement = (self.gradientsArray)[gradientRowIndex];
        }
    }
    
    NSInteger colorStopRowIndex = colorStopElementsTableView.selectedRow;
    if (colorStopRowIndex != -1)
    {
        if ((self.colorStopsArray).count > 0)
        {
            colorStopElement = (self.colorStopsArray)[colorStopRowIndex];
        }
    }

    NSXMLElement * newColorStopElement = [[NSXMLElement alloc] init];
    newColorStopElement.name = @"stop";
    
    NSString * colorStopID =
            [colorAttributeEditor.macSVGPluginCallbacks
            uniqueIDForElementTagName:@"stop" pendingIDs:NULL];
    NSXMLNode * colorStopIDNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    colorStopIDNode.name = @"id";
    colorStopIDNode.stringValue = colorStopID;
    [newColorStopElement addAttribute:colorStopIDNode];
    
    [colorAttributeEditor assignMacsvgidsForNode:newColorStopElement];
    
    NSXMLNode * colorStopColorNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    colorStopColorNode.name = @"stop-color";
    colorStopColorNode.stringValue = @"red";
    [newColorStopElement addAttribute:colorStopColorNode];

    float colorStopOffset = 50.0f;

    BOOL usePercentage = NO;
    
    NSInteger colorStopArrayCount = (self.colorStopsArray).count;
    if (colorStopArrayCount > 1)
    {
        float largestInterval = 0.0f;
        float lesserValue = 0.0f;
        float greaterValue = 0.0f;
        BOOL intervalUsePercentage = NO;
        
        for (NSInteger i = 1; i < colorStopArrayCount; i++)
        {
            NSXMLElement * colorStop1Element = (self.colorStopsArray)[(i - 1)];
            NSXMLElement * colorStop2Element = (self.colorStopsArray)[i];
            
            float offset1 = 0.0f;
            float offset2 = 100.0f;
            
            NSXMLNode * offset1Node = [colorStop1Element attributeForName:@"offset"];
            NSString * offset1String = offset1Node.stringValue;
            offset1 = offset1String.floatValue;
            
            NSXMLNode * offset2Node = [colorStop2Element attributeForName:@"offset"];
            NSString * offset2String = offset2Node.stringValue;
            offset2 = offset2String.floatValue;
            
            NSRange percentageRange = [offset1String rangeOfString:@"%"];
            if (percentageRange.location != NSNotFound)
            {
                percentageRange = [offset1String rangeOfString:@"%"];
                if (percentageRange.location != NSNotFound)
                {
                    intervalUsePercentage = YES;
                }
            }
            
            float offsetDifference = offset2 - offset1;
            if (offsetDifference > largestInterval)
            {
                largestInterval = offsetDifference;
                lesserValue = offset1;
                greaterValue = offset2;
                usePercentage = intervalUsePercentage;
            }
        }
        
        colorStopOffset = lesserValue + (largestInterval / 2.0f);
    }
    else if (colorStopArrayCount == 1)
    {
        NSXMLElement * colorStop1Element = (self.colorStopsArray)[0];
        
        float offset1 = 0.0f;
        
        NSXMLNode * offset1Node = [colorStop1Element attributeForName:@"offset"];
        NSString * offset1String = offset1Node.stringValue;
        offset1 = offset1String.floatValue;
        
        NSRange percentageRange = [offset1String rangeOfString:@"%"];
        if (percentageRange.location != NSNotFound)
        {
            usePercentage = YES;
        }
        
        if (offset1 == 0)
        {
            colorStopOffset = 100;
        }
        else
        {
            colorStopOffset = 0;
        }
    }
    else if (colorStopArrayCount == 0)
    {
        colorStopOffset = 0;
        usePercentage = YES;
    }
    
    NSString * colorStopOffsetString = [self numericStringWithFloat:colorStopOffset];
    if (usePercentage == YES)
    {
        colorStopOffsetString = [colorStopOffsetString stringByAppendingString:@"%"];
    }
    NSXMLNode * colorStopOffsetNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    colorStopOffsetNode.name = @"offset";
    colorStopOffsetNode.stringValue = colorStopOffsetString;
    [newColorStopElement addAttribute:colorStopOffsetNode];

    [gradientElement addChild:newColorStopElement];
    
    [self loadColorStopsData];
    
    [self sortGradientColorStops];
    
    [colorStopElementsTableView reloadData];
    
    NSInteger newColorStopIndex = [self.colorStopsArray indexOfObject:newColorStopElement];
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:newColorStopIndex];
    [colorStopElementsTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    
    [self updateGradientPreview];

    [colorAttributeEditor updateDocumentViews];
}

//==================================================================================
//	deleteColorStopButtonAction
//==================================================================================

- (IBAction)deleteColorStopButtonAction:(id)sender
{
    NSXMLElement * gradientElement = NULL;
    NSXMLElement * colorStopElement = NULL;
    NSInteger gradientRowIndex = gradientElementsTableView.selectedRow;
    if (gradientRowIndex != -1)
    {
        if ((self.gradientsArray).count > 0)
        {
            gradientElement = (self.gradientsArray)[gradientRowIndex];
        }
    }
    
    NSInteger colorStopRowIndex = colorStopElementsTableView.selectedRow;
    if (colorStopRowIndex != -1)
    {
        if ((self.colorStopsArray).count > 0)
        {
            colorStopElement = (self.colorStopsArray)[colorStopRowIndex];
        }
    }
    
    if (gradientElement != NULL)
    {
        if (colorStopElement != NULL)
        {
            NSInteger colorStopElementIndex = colorStopElement.index;
            [gradientElement removeChildAtIndex:colorStopElementIndex];
        }
    }

    [self loadColorStopsData];
    [colorStopElementsTableView reloadData];
    [self loadColorStopTextFields];
    [self updateGradientPreview];
    [colorAttributeEditor updateDocumentViews];
}

//==================================================================================
//	gradientTextFieldAction
//==================================================================================

- (IBAction)gradientTextFieldAction:(id)sender
{
    [self updateGradientElement];
    [self updateColorStopElement];
    [self updateGradientPreview];
}

//==================================================================================
//	colorStopTextFieldAction
//==================================================================================

- (IBAction)colorStopTextFieldAction:(id)sender
{
    NSXMLElement * gradientElement = NULL;
    NSXMLElement * colorStopElement = NULL;
    NSInteger gradientRowIndex = gradientElementsTableView.selectedRow;
    if (gradientRowIndex != -1)
    {
        if ((self.gradientsArray).count > 0)
        {
            gradientElement = (self.gradientsArray)[gradientRowIndex];
        }
    }
    
    NSInteger colorStopRowIndex = colorStopElementsTableView.selectedRow;
    if (colorStopRowIndex != -1)
    {
        if ((self.colorStopsArray).count > 0)
        {
            colorStopElement = (self.colorStopsArray)[colorStopRowIndex];
        }
    }

    [self updateColorStopElement];
    
    [self updateColorWell];

    [self sortGradientColorStops];
    [self loadColorStopsData];
    [colorAttributeEditor updateDocumentViews];

    if (colorStopElement != NULL)
    {
        NSInteger newColorStopRow = [self.colorStopsArray indexOfObject:colorStopElement];
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:newColorStopRow];
        [colorStopElementsTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    }
    else
    {
        [colorStopElementsTableView deselectAll:self];
    }
    
    [self updateGradientPreview];
}

//==================================================================================
//	updateColorWell
//==================================================================================

- (void)updateColorWell
{
    NSString * colorTextString = colorStopColorComboBox.stringValue;
    
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
                    
                    colorStopColorWell.color = colorWellColor;
                }
            }
        }
    }

    NSInteger webColorsArrayCount = (colorAttributeEditor.webColorsArray).count;
    for (NSInteger i = 0; i < webColorsArrayCount; i++)
    {
        NSDictionary * colorDictionary = (colorAttributeEditor.webColorsArray)[i];
        NSString * colorName = colorDictionary[@"name"];
        
        if ([colorName isEqualToString:colorTextString] == YES)
        {
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
            
            colorStopColorWell.color = wellColor;

            break;
        }
    }
}

//==================================================================================
//	colorStopColorWellAction
//==================================================================================

- (IBAction)colorStopColorWellAction:(id)sender
{
    NSColor * wellColor = colorStopColorWell.color;
    
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
    
    colorStopColorComboBox.stringValue = colorString;

    NSXMLElement * gradientElement = NULL;
    NSXMLElement * colorStopElement = NULL;
    NSInteger gradientRowIndex = gradientElementsTableView.selectedRow;
    if (gradientRowIndex != -1)
    {
        if ((self.gradientsArray).count > 0)
        {
            gradientElement = (self.gradientsArray)[gradientRowIndex];
        }
    }
    
    NSInteger colorStopRowIndex = colorStopElementsTableView.selectedRow;
    if (colorStopRowIndex != -1)
    {
        if ((self.colorStopsArray).count > 0)
        {
            colorStopElement = (self.colorStopsArray)[colorStopRowIndex];
        }
    }

    [self updateColorStopElement];
    
    [self updateColorWell];

    [self sortGradientColorStops];
    [self loadColorStopsData];
    
    // delay to avoid WebKit multiple-update during continuous color picking mode
    if (self.delayedUpdateTimer != NULL)
    {
        [self.delayedUpdateTimer invalidate];
        self.delayedUpdateTimer = NULL;
    }
    self.delayedUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
            selector:@selector(delayedDocumentUpdateViews:) userInfo:NULL repeats:NO];

    if (colorStopElement != NULL)
    {
        NSInteger newColorStopRow = [self.colorStopsArray indexOfObject:colorStopElement];
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:newColorStopRow];
        [colorStopElementsTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    }
    else
    {
        [colorStopElementsTableView deselectAll:self];
    }
    
    [self updateGradientPreview];
}

//==================================================================================
//	delayedDocumentUpdateViews
//==================================================================================

- (void)delayedDocumentUpdateViews:(id)sender
{
    [colorAttributeEditor updateDocumentViews];
}

//==================================================================================
//	applyButtonAction
//==================================================================================

- (IBAction)applyButtonAction:(id)sender
{
    [self updateGradientElement];
    [self updateColorStopElement];
    [self updateGradientPreview];

    NSInteger rowIndex = gradientElementsTableView.selectedRow;
    
    if (rowIndex != -1)
    {
        if ((self.gradientsArray).count > 0)
        {
            NSXMLElement * gradientElement = (self.gradientsArray)[rowIndex];

            [colorAttributeEditor setGradientElement:gradientElement];
        }
    }
}

//==================================================================================
//	doneButtonAction
//==================================================================================

- (IBAction)doneButtonAction:(id)sender
{
    [gradientEditorPopover performClose:self];
}

//==================================================================================
//	svgHeaderString
//==================================================================================

- (NSString *)svgHeaderString
{
    // width and height attributes should match dimensions in NIB file

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
version=\"1.1\" baseProfile=\"full\" width=\"118px\"\n\
height=\"118px\" viewBox=\"0 0 118 118\" preserveAspectRatio=\"xMidYMid meet\">";
    return headerString;
}

//==================================================================================
//	makeGradientPreviewSVG
//==================================================================================

- (NSString *)makeGradientPreviewSVG
{
    NSString * xmlDocString = @"No gradient selected";
    
    NSInteger rowIndex = gradientElementsTableView.selectedRow;
    
    if (rowIndex != -1)
    {
        if ((self.gradientsArray).count > 0)
        {
            NSXMLElement * gradientElement = (self.gradientsArray)[rowIndex];

            NSXMLNode * gradientIDAttributeNode = [gradientElement attributeForName:@"id"];
            NSString * gradientIDString = gradientIDAttributeNode.stringValue;

            NSString * gradientString = gradientElement.XMLString;
            
            NSString * headerString = [self svgHeaderString];
            
            NSString * rectElementString = [NSString
                    stringWithFormat:@"<rect x=\"0px\" y=\"0px\" width=\"118px\" height=\"118px\" fill=\"url(#%@)\" />",
                    gradientIDString];
            
            NSString * previewString = [NSString stringWithFormat:@"<g id=\"previewContainer\"><defs>%@</defs>%@</g>",
                    gradientString, rectElementString];
            
            NSString * footerString = @"</svg>";
            
            xmlDocString = [[NSString alloc] initWithFormat:@"%@%@%@",
                    headerString, previewString, footerString];
        }
    }
    else
    {
        NSString * headerString = [self svgHeaderString];
        
        NSString * rectElementString = @"<rect x=\"0px\" y=\"0px\" width=\"118px\" height=\"118px\" fill=\"white\" /><text font-size=\"14px\" fill=\"black\" text-anchor=\"middle\" x=\"59\" y=\"30\">No gradient</text><text font-size=\"14px\" fill=\"black\" text-anchor=\"middle\" x=\"59\" y=\"50\">selected</text>";
        
        NSString * previewString = [NSString stringWithFormat:@"<g id=\"previewContainer\">%@</g>",
                rectElementString];
        
        NSString * footerString = @"</svg>";
        
        xmlDocString = [[NSString alloc] initWithFormat:@"%@%@%@",
                headerString, previewString, footerString];
    }
    
    return xmlDocString;
}


//==================================================================================
//	numberOfItemsInComboBox
//==================================================================================

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    NSInteger result = 0;
    
    if (aComboBox == colorStopColorComboBox)
    {
        NSArray * webColorsArray = colorAttributeEditor.webColorsArray;
        NSInteger webColorsArrayCount = webColorsArray.count;
        result = webColorsArrayCount;
    }
    
    return result;
}

//==================================================================================
//	objectValueForItemAtIndex
//==================================================================================

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    NSString * result = @"Missing Item";
    
    if (aComboBox == colorStopColorComboBox)
    {
        NSArray * webColorsArray = colorAttributeEditor.webColorsArray;
        NSDictionary * webColorDictionary = webColorsArray[index];
        NSString * colorName = webColorDictionary[@"name"];
        result = colorName;
    }
    
    return result;
}



@end
