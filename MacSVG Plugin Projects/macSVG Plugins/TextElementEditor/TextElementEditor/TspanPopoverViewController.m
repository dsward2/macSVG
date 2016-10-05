//
//  TspanPopoverViewController.m
//  TextElementEditor
//
//  Created by Douglas Ward on 8/26/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "TspanPopoverViewController.h"
#import "TextElementEditor.h"
#import <MacSVGPlugin/MacSVGPluginCallbacks.h>

@interface TspanPopoverViewController ()

@end

@implementation TspanPopoverViewController

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    tspanPreviewWebView.downloadDelegate = NULL;
    tspanPreviewWebView.frameLoadDelegate = NULL;
    tspanPreviewWebView.policyDelegate = NULL;
    tspanPreviewWebView.resourceLoadDelegate = NULL;
    tspanPreviewWebView.UIDelegate = NULL;

    self.tspanSettingsArray = NULL;

    self.originalTextElement = NULL;
    self.originalTspanElement = NULL;
    self.masterTextElement = NULL;
    self.masterTspanElement = NULL;
    self.masterTextContentString = NULL;

    self.tspanPreviewXMLDocument = NULL;
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

    self.masterTextElement = NULL;
    
    self.masterTspanElement = NULL;
    
    self.masterTextContentString = NULL;
    
    self.tspanSettingsArray = [NSMutableArray array];
    
    [tspanPreviewWebView.mainFrame.frameView setAllowsScrolling:NO];
}


//==================================================================================
//	doneButtonAction
//==================================================================================

- (IBAction)doneButtonAction:(id)sender
{
    [self applyTspanAttributes];
    
    [textElementEditor updateDocumentViews];

    [tspanPopover performClose:self];
}

//==================================================================================
//	cancelButtonAction
//==================================================================================

- (IBAction)cancelButtonAction:(id)sender
{
    [tspanPopover performClose:self];
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
//	loadSettingsForTspan:textElement:
//==================================================================================

- (void)loadSettingsForTspan:(NSXMLElement *)tspanElement textElement:(NSXMLElement *)textElement
{
    self.originalTextElement = textElement;
    self.originalTspanElement = tspanElement;
    
    self.masterTextElement = [textElement copy];

    self.masterTspanElement = tspanElement;
    
    // remove all child elements and text data
    NSArray * masterTextElementChildArray = (self.masterTextElement).children;
    NSInteger childCount = masterTextElementChildArray.count;
    for (NSInteger childIndex = childCount - 1; childIndex >= 0; childIndex--)
    {
        NSXMLNode * aChildNode = [self.masterTextElement childAtIndex:childIndex];
        
        if (aChildNode.kind == NSXMLTextKind)
        {
            self.masterTextContentString = aChildNode.stringValue;
        }
        
        if (aChildNode.kind != NSXMLAttributeKind)
        {
            [self.masterTextElement removeChildAtIndex:childIndex];
        }
    }
    
    //NSXMLNode * cssStyleAttributeNode = [textElement attributeForName:@"style"];
    NSXMLNode * cssStyleAttributeNode = [tspanElement attributeForName:@"style"];
    if (cssStyleAttributeNode != NULL)
    {
        NSString * cssStyleAttributeString = cssStyleAttributeNode.stringValue;
        
        cssStyleTextView.string = cssStyleAttributeString;
    }
    else
    {
        cssStyleTextView.string = @"";
    }

    self.tspanSettingsArray = [NSMutableArray array];

    NSXMLNode * textContentNode = NULL;
    
    NSArray * tspanElementChildren = tspanElement.children;
    for (NSXMLNode * tspanChildNode in tspanElementChildren)
    {
        NSXMLNodeKind nodeKind = tspanChildNode.kind;
        if (nodeKind == NSXMLTextKind)
        {
            textContentNode = tspanChildNode;
        }
    }
    
    if (textContentNode != NULL)
    {
        NSString * textContentString = textContentNode.stringValue;
        
        NSInteger textContentStringLength = textContentString.length;
        
        for (NSInteger textIndex = 0; textIndex < textContentStringLength; textIndex++)
        {
            unichar aTextCharacter = [textContentString characterAtIndex:textIndex];
            
            NSMutableDictionary * textCharacterDictionary = [NSMutableDictionary dictionary];
            
            NSString * characterString = [NSString stringWithFormat:@"%C", aTextCharacter];
            textCharacterDictionary[@"character"] = characterString;

            textCharacterDictionary[@"dx"] = @"--";
            textCharacterDictionary[@"dy"] = @"--";
            textCharacterDictionary[@"rotate"] = @"--";
            
            [self.tspanSettingsArray addObject:textCharacterDictionary];
        }
    }

    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSXMLNode * dxAttributeNode = [tspanElement attributeForName:@"dx"];
    if (dxAttributeNode != NULL)
    {
        NSString * dxAttributeString = dxAttributeNode.stringValue;
        NSArray * dxAttributeArray = [dxAttributeString componentsSeparatedByString:@","];
        NSInteger dxAttributeArrayCount = dxAttributeArray.count;
        for (NSInteger i = 0; i < dxAttributeArrayCount; i++)
        {
            NSString * dxAttribute = dxAttributeArray[i];
            dxAttribute = [dxAttribute stringByTrimmingCharactersInSet:whitespaceSet];
            
            NSMutableDictionary * textCharacterDictionary = (self.tspanSettingsArray)[i];
            textCharacterDictionary[@"dx"] = dxAttribute;
        }
    }
    
    NSXMLNode * dyAttributeNode = [tspanElement attributeForName:@"dy"];
    if (dyAttributeNode != NULL)
    {
        NSString * dyAttributeString = dyAttributeNode.stringValue;
        NSArray * dyAttributeArray = [dyAttributeString componentsSeparatedByString:@","];
        NSInteger dyAttributeArrayCount = dyAttributeArray.count;
        for (NSInteger i = 0; i < dyAttributeArrayCount; i++)
        {
            NSString * dyAttribute = dyAttributeArray[i];
            dyAttribute = [dyAttribute stringByTrimmingCharactersInSet:whitespaceSet];
            
            NSMutableDictionary * textCharacterDictionary = (self.tspanSettingsArray)[i];
            textCharacterDictionary[@"dy"] = dyAttribute;
        }
    }
    
    NSXMLNode * rotateAttributeNode = [tspanElement attributeForName:@"rotate"];
    if (rotateAttributeNode != NULL)
    {
        NSString * rotateAttributeString = rotateAttributeNode.stringValue;
        NSArray * rotateAttributeArray = [rotateAttributeString componentsSeparatedByString:@","];
        NSInteger rotateAttributeArrayCount = rotateAttributeArray.count;
        for (NSInteger i = 0; i < rotateAttributeArrayCount; i++)
        {
            NSString * rotateAttribute = rotateAttributeArray[i];
            rotateAttribute = [rotateAttribute stringByTrimmingCharactersInSet:whitespaceSet];
            
            NSMutableDictionary * textCharacterDictionary = (self.tspanSettingsArray)[i];
            textCharacterDictionary[@"rotate"] = rotateAttribute;
        }
    }
    
    [tspanTableView reloadData];

    [self makeTspanPreviewSVG];
    NSString * tspanPreviewXmlString = (self.tspanPreviewXMLDocument).XMLString;
    [tspanPreviewWebView.mainFrame loadHTMLString:tspanPreviewXmlString baseURL:NULL];
}

//==================================================================================
//	applyTspanAttributes
//==================================================================================

- (void)applyTspanAttributes
{
    //NSXMLElement * textElement = [textElementEditor activeXMLTextElement];
    [self attachTspanAttributes:self.originalTspanElement];
    
    NSString * cssStyleAttributeString = cssStyleTextView.string;

    NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    cssStyleAttributeString = [cssStyleAttributeString stringByTrimmingCharactersInSet:whitespaceSet];

    if (cssStyleAttributeString.length == 0)
    {
        [self.originalTspanElement removeAttributeForName:@"style"];
    }
    else
    {
        NSXMLNode * cssStyleAttributeNode = [self.originalTspanElement attributeForName:@"style"];
        if (cssStyleAttributeNode == NULL)
        {
            cssStyleAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            cssStyleAttributeNode.name = @"style";
            [self.originalTspanElement addAttribute:cssStyleAttributeNode];
        }
        cssStyleAttributeNode.stringValue = cssStyleAttributeString;
    }
}

//==================================================================================
//	numberOfRowsInTableView:
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSInteger result = 0;
    
    if (aTableView == tspanTableView)
    {
        result = (self.tspanSettingsArray).count;
    }
    
    return result;
}

//==================================================================================
//	tableView:objectValueForTableColumn:row:
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString * result = @"Missing Result";
    
    NSString * columnIdentifier = aTableColumn.identifier;
    NSMutableDictionary * characterDictionary = (self.tspanSettingsArray)[rowIndex];
    
    if (aTableView == tspanTableView)
    {
        result = @"Missing Result";
        
        if ([columnIdentifier isEqualToString:@"charIndex"] == YES)
        {
            result = [NSString stringWithFormat:@"%ld", (rowIndex + 1)];
        }
        else if ([columnIdentifier isEqualToString:@"charValue"] == YES)
        {
            result = characterDictionary[@"character"];
        }
        else if ([columnIdentifier isEqualToString:@"charDX"] == YES)
        {
            result = characterDictionary[@"dx"];
        }
        else if ([columnIdentifier isEqualToString:@"charDY"] == YES)
        {
            result = characterDictionary[@"dy"];
        }
        else if ([columnIdentifier isEqualToString:@"charRotate"] == YES)
        {
            result = characterDictionary[@"rotate"];
        }
    }
    
    return result;
}

//==================================================================================
//	tableView:setObjectValue:forTableColumn:row:
//==================================================================================

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString * columnIdentifier = aTableColumn.identifier;
    NSMutableDictionary * characterDictionary = (self.tspanSettingsArray)[rowIndex];
    
    if (aTableView == tspanTableView)
    {
        if ([columnIdentifier isEqualToString:@"charDX"] == YES)
        {
            characterDictionary[@"dx"] = anObject;
            [self normalizeAttributesArray:@"dx"];
        }
        else if ([columnIdentifier isEqualToString:@"charDY"] == YES)
        {
            characterDictionary[@"dy"] = anObject;
            [self normalizeAttributesArray:@"dy"];
        }
        else if ([columnIdentifier isEqualToString:@"charRotate"] == YES)
        {
            characterDictionary[@"rotate"] = anObject;
            [self normalizeAttributesArray:@"rotate"];
        }
    }

    [self makeTspanPreviewSVG];
    NSString * tspanPreviewXmlString = (self.tspanPreviewXMLDocument).XMLString;
    [tspanPreviewWebView.mainFrame loadHTMLString:tspanPreviewXmlString baseURL:NULL];
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = aNotification.object;
    if (aTableView == tspanTableView)
    {
    }
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
version=\"1.1\" baseProfile=\"full\" width=\"354px\"\n\
height=\"94px\" viewBox=\"0 0 354 94\" preserveAspectRatio=\"none\">";
    return headerString;
}

//==================================================================================
//	makeTspanPreviewSVG
//==================================================================================

- (void)makeTspanPreviewSVG
{
    NSString * fontFamilyString = NULL;
    NSXMLNode * fontFamilyAttributeNode = [self.masterTextElement attributeForName:@"font-family"];
    if (fontFamilyAttributeNode != NULL)
    {
        fontFamilyString = fontFamilyAttributeNode.stringValue;
    }

    NSXMLElement * fontStyleElement = NULL;
    NSArray * styleElementsArray = [self findAllStyleElements];
    for (NSXMLElement * aStyleElement in styleElementsArray)
    {
        NSString * styleElementTextContent = aStyleElement.stringValue;
        
        NSRange fontFaceRange = [styleElementTextContent rangeOfString:@"@font-face"];
        if (fontFaceRange.location != NSNotFound)
        {
            NSString * aFontName = [self fontNameFromFontFace:styleElementTextContent];
            if (aFontName != NULL) fontStyleElement = aStyleElement;
        }
        
        NSRange importRange = [styleElementTextContent rangeOfString:@"@import"];
        if (importRange.location != NSNotFound)
        {
            NSString * aFontName = [self fontNameFromImport:styleElementTextContent];
            if (aFontName != NULL) fontStyleElement = aStyleElement;
        }
    }
    
    NSString * fontStyleString = @"";
    if (fontStyleElement != NULL)
    {
        NSString * fontStyleXMLString = fontStyleElement.XMLString;
        fontStyleString = [NSString stringWithFormat:@"<defs>%@</defs>", fontStyleXMLString];
    }

    // no path is selected
    NSString * headerString = [self svgHeaderString];

    NSXMLElement * previewTextElement = [self.masterTextElement copy];
    
    NSXMLNode * xAttributeNode = [previewTextElement attributeForName:@"x"];
    if (xAttributeNode == NULL)
    {
        xAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        xAttributeNode.name = @"x";
        xAttributeNode.stringValue = @"";
        [previewTextElement addChild:xAttributeNode];
    }
    xAttributeNode.stringValue = @"20";
    
    NSXMLNode * yAttributeNode = [previewTextElement attributeForName:@"y"];
    if (yAttributeNode == NULL)
    {
        yAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        yAttributeNode.name = @"x";
        yAttributeNode.stringValue = @"";
        [previewTextElement addChild:yAttributeNode];
    }
    yAttributeNode.stringValue = @"45";
    
    NSXMLNode * fontSizeAttributeNode = [previewTextElement attributeForName:@"font-size"];
    if (fontSizeAttributeNode == NULL)
    {
        fontSizeAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        fontSizeAttributeNode.name = @"font-size";
        fontSizeAttributeNode.stringValue = @"";
        [previewTextElement addChild:fontSizeAttributeNode];
    }
    fontSizeAttributeNode.stringValue = @"22";
    
    NSXMLNode * textAnchorAttributeNode = [previewTextElement attributeForName:@"text-anchor"];
    if (textAnchorAttributeNode == NULL)
    {
        textAnchorAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        textAnchorAttributeNode.name = @"text-anchor";
        textAnchorAttributeNode.stringValue = @"";
        [previewTextElement addChild:textAnchorAttributeNode];
    }
    textAnchorAttributeNode.stringValue = @"start";
    
    
    NSXMLElement * previewTspanElement = [self.masterTspanElement copy];
    
    [self attachTspanAttributes:previewTspanElement];
    
    NSXMLNode * textContentNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind];
    textContentNode.stringValue = self.masterTextContentString;
    [previewTspanElement addChild:textContentNode];

    [previewTextElement addChild:previewTspanElement];
    
    NSXMLNode * visibilityNode = [previewTextElement attributeForName:@"visibility"];
    if (visibilityNode != NULL)
    {
        visibilityNode.stringValue = @"visible";
    }

    NSString * textElementString = previewTextElement.XMLString;
    
    NSString * xmlString = [NSString stringWithFormat:@"<g id=\"previewContainer\">%@</g>",
            textElementString];
    
    NSString * footerString = @"</svg>";
    
    NSString * xmlDocString = [[NSString alloc] initWithFormat:@"%@%@%@", headerString, xmlString, footerString];
    
    NSError * docError = NULL;
    
    self.tspanPreviewXMLDocument = [[NSXMLDocument alloc]
            initWithXMLString:xmlDocString options:0 error:&docError];
}

//==================================================================================
//	normalizeAttributesArray
//==================================================================================

-(void)normalizeAttributesArray:(NSString *)attributeName
{
    NSInteger lastDefinedValueIndex = -1;
    
    NSInteger tspanArrayCount = (self.tspanSettingsArray).count;
    for (NSInteger i = 0; i < tspanArrayCount; i++)
    {
        NSMutableDictionary * characterDictionary = (self.tspanSettingsArray)[i];

        NSString * attributeValue = characterDictionary[attributeName];
        
        if ([attributeValue isEqualToString:@"--"] == NO)
        {
            lastDefinedValueIndex = i;
        }
    }
    
    if (lastDefinedValueIndex >= 0)
    {
        NSString * lastValidValue = @"0";
        
        for (NSInteger i = 0; i <= lastDefinedValueIndex; i++)
        {
            NSMutableDictionary * characterDictionary = (self.tspanSettingsArray)[i];

            NSString * attributeValue = characterDictionary[attributeName];
            
            if (attributeValue.length == 0)
            {
                attributeValue = lastValidValue;
            }
            
            if ([attributeValue isEqualToString:@"--"] == YES)
            {
                attributeValue = lastValidValue;
            }
            
            characterDictionary[attributeName] = attributeValue;
            
            lastValidValue = attributeValue;
        }
    }
}

//==================================================================================
//	attachTspanAttributes
//==================================================================================

-(void)attachTspanAttributes:(NSXMLElement *)tspanElement
{
    NSMutableString * dxAttributeString = [NSMutableString string];
    NSMutableString * dyAttributeString = [NSMutableString string];
    NSMutableString * rotateAttributeString = [NSMutableString string];
    
    [self normalizeAttributesArray:@"dx"];
    [self normalizeAttributesArray:@"dy"];
    [self normalizeAttributesArray:@"rotate"];
    
    NSInteger tspanArrayCount = (self.tspanSettingsArray).count;
    for (NSInteger i = 0; i < tspanArrayCount; i++)
    {
        NSMutableDictionary * characterDictionary = (self.tspanSettingsArray)[i];
        
        NSString * characterDXString = characterDictionary[@"dx"];
        if ([characterDXString isEqualToString:@"--"] == NO)
        {
            NSInteger dxAttributeStringLength = dxAttributeString.length;
            if (dxAttributeStringLength > 0)
            {
                [dxAttributeString appendString:@","];
            }
            [dxAttributeString appendString:characterDXString];
        }
        
        NSString * characterDYString = characterDictionary[@"dy"];
        if ([characterDYString isEqualToString:@"--"] == NO)
        {
            NSInteger dyAttributeStringLength = dyAttributeString.length;
            if (dyAttributeStringLength > 0)
            {
                [dyAttributeString appendString:@","];
            }
            [dyAttributeString appendString:characterDYString];
        }
        
        NSString * characterRotateString = characterDictionary[@"rotate"];
        if ([characterRotateString isEqualToString:@"--"] == NO)
        {
            NSInteger rotateAttributeStringLength = rotateAttributeString.length;
            if (rotateAttributeStringLength > 0)
            {
                [rotateAttributeString appendString:@","];
            }
            [rotateAttributeString appendString:characterRotateString];
        }
    }
    
    NSXMLNode * dxAttributeNode = [tspanElement attributeForName:@"dx"];
    if (dxAttributeNode == NULL)
    {
        dxAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        dxAttributeNode.name = @"dx";
        dxAttributeNode.stringValue = @"";
        [tspanElement addChild:dxAttributeNode];
    }
    dxAttributeNode.stringValue = dxAttributeString;
    
    NSXMLNode * dyAttributeNode = [tspanElement attributeForName:@"dy"];
    if (dyAttributeNode == NULL)
    {
        dyAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        dyAttributeNode.name = @"dy";
        dyAttributeNode.stringValue = @"";
        [tspanElement addChild:dyAttributeNode];
    }
    dyAttributeNode.stringValue = dyAttributeString;
    
    NSXMLNode * rotateAttributeNode = [tspanElement attributeForName:@"rotate"];
    if (rotateAttributeNode == NULL)
    {
        rotateAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        rotateAttributeNode.name = @"rotate";
        rotateAttributeNode.stringValue = @"";
        [tspanElement addChild:rotateAttributeNode];
    }
    rotateAttributeNode.stringValue = rotateAttributeString;
}

//==================================================================================
//	findAllStyleElements
//==================================================================================

 -(NSArray *)findAllStyleElements
 {       
    NSArray * resultArray = NULL;
    
    NSXMLDocument * svgXmlDocument = textElementEditor.svgXmlDocument;
    
    NSXMLElement * rootElement = [svgXmlDocument rootElement];
    
    NSString * xpathQuery = @".//style";
    
    NSError * error = NULL;
    resultArray = [rootElement nodesForXPath:xpathQuery error:&error];
    
    return resultArray;
}

//==================================================================================
//	fontNameFromURLData
//==================================================================================

- (NSString *)fontNameFromURLData:(NSURL *)fontURL
{
    // for file URLs like file:////Users/dsward/Downloads/Cabin_Condensed/CabinCondensed-Regular.ttf
    
    NSString * fontName = NULL;
    
    NSData * fontData = [NSData dataWithContentsOfURL:fontURL];

    if (fontData != NULL)
    {
        NSString * fontDataString = [[NSString alloc] initWithData:fontData encoding:NSUTF8StringEncoding];

        NSRange fontFaceRange = [fontDataString rangeOfString:@"@font-face"];
        
        if (fontFaceRange.location != NSNotFound)
        {
            fontName = [self fontNameFromFontFace:fontDataString];
        }
    }
    
    return fontName;
}

//==================================================================================
//	fontNameFromURL
//==================================================================================

- (NSString *)fontNameFromURL:(NSString *)fontURLString
{
    NSString * fontName = NULL;
    
    NSURL * fontURL = [NSURL URLWithString:fontURLString];
    
    if (fontURL != NULL)
    {
        fontName = [self fontNameFromURLData:fontURL];
    }

    return fontName;
}

//==================================================================================
//	fontNameFromFontFace:
//==================================================================================

- (NSString *)fontNameFromFontFace:(NSString *)fontFaceString
{
    NSString * fontName = NULL;

    NSRange fontFaceRange = [fontFaceString rangeOfString:@"@font-face"];
    
    if (fontFaceRange.location != NSNotFound)
    {
        /*
            data from: @import url(https://fonts.googleapis.com/css?family=Aclonica);
        
            @font-face {
              font-family: 'Aclonica';
              font-style: normal;
              font-weight: 400;
              src: local('Aclonica'), local('Aclonica-Regular'), url(https://themes.googleusercontent.com/static/fonts/aclonica/v3/SRPydzL0KLANO5G2lBcEnfesZW2xOQ-xsNqO47m55DA.ttf) format('truetype');
            }
        */
        
        NSInteger fontDataStringLength = fontFaceString.length;
        NSInteger openBracePosition = NSNotFound;
        NSInteger closeBracePosition = NSNotFound;
        for (NSInteger charIndex = fontFaceRange.location  + fontFaceRange.length - 1;
                charIndex < fontDataStringLength; charIndex++)
        {
            unichar aChar = [fontFaceString characterAtIndex:charIndex];
            
            if (aChar == '{') openBracePosition = charIndex;
            if (aChar == '}')
            {
                if (openBracePosition != NSNotFound)
                {
                    closeBracePosition = charIndex;
                }
                break;
            }
        }
        
        if (closeBracePosition != NSNotFound)
        {
            NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

            NSRange fontFaceInnerContentRange = NSMakeRange(openBracePosition + 1, closeBracePosition - openBracePosition - 1);
            NSString * fontFaceInnerContent = [fontFaceString substringWithRange:fontFaceInnerContentRange];
            NSString * trimmedFaceInnerContent = [fontFaceInnerContent stringByTrimmingCharactersInSet:whitespaceSet];
            
            NSArray * fontFaceCSSArray = [trimmedFaceInnerContent componentsSeparatedByString:@";"];
            
            for (NSString * aCSSString in fontFaceCSSArray)
            {
                NSArray * aCSSArray = [aCSSString componentsSeparatedByString:@":"];
                
                if (aCSSArray.count == 2)
                {
                    NSString * aCSSFragment = aCSSArray[0];

                    NSString * trimmedCSSFragment = [aCSSFragment stringByTrimmingCharactersInSet:whitespaceSet];
                    
                    if ([trimmedCSSFragment isEqualToString:@"font-family"])
                    {
                        NSString * fontFamilyName = aCSSArray[1];
                        
                        if (fontFamilyName.length > 0)
                        {
                            fontFamilyName = [fontFamilyName stringByTrimmingCharactersInSet:whitespaceSet];

                            NSString * firstCharacterString = [fontFamilyName substringWithRange:NSMakeRange(0, 1)];
                            
                            if ([firstCharacterString isEqualToString:@"'"] == YES)
                            {
                                NSMutableString * trimmedFontFamilyName = [NSMutableString stringWithString:fontFamilyName];
                                NSRange trimmedFontFamilyNameRange = NSMakeRange(0, trimmedFontFamilyName.length);
                                [trimmedFontFamilyName replaceOccurrencesOfString:@"'" withString:@""
                                        options:NSLiteralSearch range:trimmedFontFamilyNameRange];
                                fontFamilyName = trimmedFontFamilyName;
                            }
                            
                            if ([firstCharacterString isEqualToString:@"\""] == YES)
                            {
                                NSMutableString * trimmedFontFamilyName = [NSMutableString stringWithString:fontFamilyName];
                                NSRange trimmedFontFamilyNameRange = NSMakeRange(0, trimmedFontFamilyName.length);
                                [trimmedFontFamilyName replaceOccurrencesOfString:@"\"" withString:@""
                                        options:NSLiteralSearch range:trimmedFontFamilyNameRange];
                                fontFamilyName = trimmedFontFamilyName;
                            }
                            
                            fontName = fontFamilyName;
                        }
                    }
                }
            }
        }
    }
    
    return fontName;
}

//==================================================================================
//	fontNameFromImport:
//==================================================================================

- (NSString *)fontNameFromImport:(NSString *)fontImportString
{
    // e.g., @import url(https://fonts.googleapis.com/css?family=Archivo+Black);
    NSString * fontName = NULL;
    
    NSRange importRange = [fontImportString rangeOfString:@"@import"];
    
    if (importRange.location != NSNotFound)
    {
        // @import data found
        NSRange urlRange = [fontImportString rangeOfString:@"url"];
        if (urlRange.location != NSNotFound)
        {
            NSString * urlParameterString = [fontImportString
                    substringFromIndex:(urlRange.location + urlRange.length)];
            
            NSRange openParenthesisRange = [urlParameterString rangeOfString:@"("];
            
            if (openParenthesisRange.location != NSNotFound)
            {
                NSRange closeParenthesisRange = [urlParameterString rangeOfString:@")"];
                if (closeParenthesisRange.location != NSNotFound)
                {
                    if (openParenthesisRange.location < closeParenthesisRange.location)
                    {
                        NSInteger urlStartIndex = openParenthesisRange.location + 1;
                        NSInteger urlLength = closeParenthesisRange.location - urlStartIndex;
                        NSRange urlRange = NSMakeRange(urlStartIndex, urlLength);
                        NSString * untrimmedUrlString = [urlParameterString substringWithRange:urlRange];
                        
                        NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

                        NSString * urlString = [untrimmedUrlString stringByTrimmingCharactersInSet:whitespaceSet];
                        
                        NSString * aFontName = [self fontNameFromURL:urlString];
                        
                        if (aFontName != NULL)
                        {
                            fontName = aFontName;
                        }
                    }
                }
            }
        }
    }

    return fontName;
}

//==================================================================================
//	resetXButtonAction:
//==================================================================================

- (IBAction)resetDXButtonAction:(id)sender
{
    NSInteger tspanArrayCount = (self.tspanSettingsArray).count;
    for (NSInteger i = 0; i < tspanArrayCount; i++)
    {
        NSMutableDictionary * characterDictionary = (self.tspanSettingsArray)[i];
        
        characterDictionary[@"dx"] = @"--";
    }
    
    [tspanTableView reloadData];


    [self makeTspanPreviewSVG];
    NSString * tspanPreviewXmlString = (self.tspanPreviewXMLDocument).XMLString;
    [tspanPreviewWebView.mainFrame loadHTMLString:tspanPreviewXmlString baseURL:NULL];
}

//==================================================================================
//	resetYButtonAction:
//==================================================================================

- (IBAction)resetDYButtonAction:(id)sender
{
    NSInteger tspanArrayCount = (self.tspanSettingsArray).count;
    for (NSInteger i = 0; i < tspanArrayCount; i++)
    {
        NSMutableDictionary * characterDictionary = (self.tspanSettingsArray)[i];
        
        characterDictionary[@"dy"] = @"--";
    }
    
    [tspanTableView reloadData];

    [self makeTspanPreviewSVG];
    NSString * tspanPreviewXmlString = (self.tspanPreviewXMLDocument).XMLString;
    [tspanPreviewWebView.mainFrame loadHTMLString:tspanPreviewXmlString baseURL:NULL];
}

//==================================================================================
//	resetRotateButtonAction:
//==================================================================================

- (IBAction)resetRotateButtonAction:(id)sender
{
    NSInteger tspanArrayCount = (self.tspanSettingsArray).count;
    for (NSInteger i = 0; i < tspanArrayCount; i++)
    {
        NSMutableDictionary * characterDictionary = (self.tspanSettingsArray)[i];
        
        characterDictionary[@"rotate"] = @"--";
    }
    
    [tspanTableView reloadData];

    [self makeTspanPreviewSVG];
    NSString * tspanPreviewXmlString = (self.tspanPreviewXMLDocument).XMLString;
    [tspanPreviewWebView.mainFrame loadHTMLString:tspanPreviewXmlString baseURL:NULL];
}


@end
