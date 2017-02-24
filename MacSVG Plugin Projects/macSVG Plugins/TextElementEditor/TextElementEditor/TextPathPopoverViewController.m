//
//  TextPathPopoverViewController.m
//  TextElementEditor
//
//  Created by Douglas Ward on 8/19/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "TextPathPopoverViewController.h"
#import "TextElementEditor.h"
#import <MacSVGPlugin/MacSVGPluginCallbacks.h>

@interface TextPathPopoverViewController ()

@end

@implementation TextPathPopoverViewController

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    textPathPreviewWebView.downloadDelegate = NULL;
    textPathPreviewWebView.frameLoadDelegate = NULL;
    textPathPreviewWebView.policyDelegate = NULL;
    textPathPreviewWebView.resourceLoadDelegate = NULL;
    textPathPreviewWebView.UIDelegate = NULL;

    self.eligiblePathElementsArray = NULL;
    
    self.eligiblePathXMLDocument = NULL;
    self.textPathPreviewXMLDocument = NULL;
    
    self.originalTextElement = NULL;
    
    self.masterTextElement = NULL;
    self.masterTextPathElement = NULL;
    self.masterAnimateElementsArray = NULL;
    self.masterTextContentString = NULL;
}

//==================================================================================
//	initWithNibName:bundle:
//==================================================================================

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
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

    self.eligiblePathElementsArray = [NSMutableArray array];
    
    self.masterTextElement = NULL;
    
    self.masterTextPathElement = NULL;
    
    self.masterTextContentString = NULL;
    
    self.masterAnimateElementsArray = [NSMutableArray array];
    
    [textPathPreviewWebView.mainFrame.frameView setAllowsScrolling:NO];
}

//==================================================================================
//	fontNameFromTruetypeFontURL
//==================================================================================

- (NSString *)fontNameFromTruetypeFontURL:(NSURL *)fontURL
{
    // test file:////Users/dsward/Downloads/Cabin_Condensed/CabinCondensed-Regular.ttf
    
    NSString * fontName = NULL;
    
    NSData * fontData = [NSData dataWithContentsOfURL:fontURL];

    CTFontDescriptorRef cfFontDescriptor = CTFontManagerCreateFontDescriptorFromData((__bridge CFDataRef)fontData);
    
    CFDictionaryRef fontDescriptorCFDictionary = CTFontDescriptorCopyAttributes(cfFontDescriptor);
    NSDictionary * fontDescriptorDictionary = CFBridgingRelease(fontDescriptorCFDictionary);
    
    fontName = fontDescriptorDictionary[@"NSFontNameAttribute"];
    
    return fontName;
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
    
    /*
    if (fontURL != NULL)
    {
        fontName = [self fontNameFromURLData:fontURL];
    }
    */

    if (fontURL != NULL)
    {
        NSString * fontFileNameExtension = [fontURLString pathExtension];
        if ([fontFileNameExtension isEqualToString:@"ttf"] == YES)
        {
            fontName = [self fontNameFromTruetypeFontURL:fontURL];
        }
        else if ([fontFileNameExtension isEqualToString:@"otf"] == YES)
        {
            fontName = [self fontNameFromTruetypeFontURL:fontURL];
        }
        else
        {
            fontName = [self fontNameFromURLData:fontURL];
        }
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
                        
                        //NSURL * fontURL = [NSURL URLWithString:urlString];
                        
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
//	makeTextPathPreviewSVG
//==================================================================================

- (void)makeTextPathPreviewSVG
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

    NSInteger rowIndex = eligiblePathsTableView.selectedRow;
    if (rowIndex != -1)
    {
        NSXMLElement * selectedPathElement = (self.eligiblePathElementsArray)[rowIndex];
        
        NSXMLNode * pathIDAttributeNode = [selectedPathElement attributeForName:@"id"];
        if (pathIDAttributeNode != NULL)
        {
            NSString * pathIDString = pathIDAttributeNode.stringValue;
        
            NSString * pathString = selectedPathElement.XMLString;
            
            NSString * headerString = [self svgHeaderString];

            NSXMLElement * previewTextElement = [self.masterTextElement copy];
            
            NSXMLNode * visibilityNode = [previewTextElement attributeForName:@"visibility"];
            if (visibilityNode != NULL)
            {
                visibilityNode.stringValue = @"visible";
            }

            [self attachTextPathForTextElement:previewTextElement pathID:pathIDString];
            
            NSArray * textPathsElementArray = [previewTextElement elementsForName:@"textPath"];
            
            NSXMLElement * previewTextPathElement = textPathsElementArray[0];

            NSArray * tspanElementsArray = [self.originalTextElement elementsForName:@"tspan"];
            
            for (NSXMLElement * aTspanElement in tspanElementsArray)
            {
                NSXMLElement * copyTspanElement = [aTspanElement copy];
                [copyTspanElement detach];
                [previewTextPathElement addChild:copyTspanElement];
            }
            
            [self attachAnimateElementsForTextElement:previewTextElement];
            
            NSString * textElementString = previewTextElement.XMLString;
            
            NSString * xmlString = [NSString stringWithFormat:@"<g id=\"previewContainer\">%@%@</g>",
                    pathString, textElementString];
            
            NSString * footerString = @"</svg>";
            
            NSString * xmlDocString = [[NSString alloc] initWithFormat:@"%@%@%@%@", headerString, fontStyleString, xmlString, footerString];
            
            NSError * docError = NULL;
            
            self.textPathPreviewXMLDocument = [[NSXMLDocument alloc]
                    initWithXMLString:xmlDocString options:0 error:&docError];
        }
    }
    else
    {
        // no path is selected
        NSString * headerString = [self svgHeaderString];

        NSXMLElement * previewTextElement = [self.masterTextElement copy];
        
        NSXMLNode * textContentNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind];
        textContentNode.stringValue = self.masterTextContentString;
        [previewTextElement addChild:textContentNode];
        
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
        
        self.textPathPreviewXMLDocument = [[NSXMLDocument alloc]
                initWithXMLString:xmlDocString options:0 error:&docError];
    }

    [self getTotalPathLength];
}

//==================================================================================
//	attachTextPathForTextElement:pathID:
//==================================================================================

- (void)attachTextPathForTextElement:(NSXMLElement *)aTextElement pathID:(NSString *)pathIDString
{
    NSXMLElement * textPathElement = [self.masterTextPathElement copy];
    
    NSXMLNode * pathXlinkHrefAttributeNode = [textPathElement attributeForName:@"xlink:href"];
    if (pathXlinkHrefAttributeNode == NULL)
    {
        pathXlinkHrefAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        pathXlinkHrefAttributeNode.name = @"xlink:href";
        pathXlinkHrefAttributeNode.stringValue = @"";
        [textPathElement addAttribute:pathXlinkHrefAttributeNode];
    }
    NSString * pathXlinkHrefString = [NSString stringWithFormat:@"#%@", pathIDString];
    pathXlinkHrefAttributeNode.stringValue = pathXlinkHrefString;

    NSXMLNode * textContentNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind];
    
    textContentNode.stringValue = self.masterTextContentString;
    
    [textPathElement addChild:textContentNode];

    [textPathElement normalizeAdjacentTextNodesPreservingCDATA:YES];
    
    [aTextElement addChild:textPathElement];
}

//==================================================================================
//	attachAnimateElementsForTextElement
//==================================================================================

- (void)attachAnimateElementsForTextElement:(NSXMLElement *)aTextElement
{
    NSArray * textPathElementsArray = [aTextElement elementsForName:@"textPath"];
    if (textPathElementsArray.count > 0)
    {
        NSXMLElement * textPathElement = textPathElementsArray[0];

        NSArray * textPathChildNodesArray = textPathElement.children;
        for (NSXMLNode * aChildNode in textPathChildNodesArray)
        {
            NSXMLNodeKind nodeKind = aChildNode.kind;
            if (nodeKind == NSXMLElementKind)
            {
                NSString * childNodeName = aChildNode.name;
                if ([childNodeName isEqualToString:@"tspan"] == NO)
                {
                    NSInteger childIndex = aChildNode.index;
                    [textPathElement removeChildAtIndex:childIndex];
                }
            }
        }
        
        
        NSInteger matrixChoice = previewOptionsMatrix.selectedColumn;
        if (matrixChoice == 0)
        {
            // preview selected animate element only
            NSInteger rowIndex = animateElementsTableView.selectedRow;
            
            if (rowIndex != -1)
            {
                NSXMLElement * aAnimateElement = (self.masterAnimateElementsArray)[rowIndex];
                [aAnimateElement detach];
                [textPathElement addChild:aAnimateElement];
            }
        }
        else
        {
            // preview all animate elements
            for (NSXMLElement * aAnimateElement in self.masterAnimateElementsArray)
            {
                [aAnimateElement detach];
                [textPathElement addChild:aAnimateElement];
            }
        }
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
version=\"1.1\" baseProfile=\"full\" width=\"269px\"\n\
height=\"269px\" viewBox=\"0 0 744 744\" preserveAspectRatio=\"xMidYMid meet\">";
    return headerString;
}

//==================================================================================
//	moveTspanElementsFromTextElement:toTextPathElement:
//==================================================================================

- (void)moveTspanElementsFromTextElement:(NSXMLElement *)aTextElement
        toTextPathElement:(NSXMLElement *)aTextPathElement
{
    NSArray * tspanElementsArray = [aTextElement elementsForName:@"tspan"];
    
    for (NSXMLElement * aTspanElement in tspanElementsArray)
    {
        [aTspanElement detach];
        [aTextPathElement addChild:aTspanElement];
    }
}

//==================================================================================
//	loadSettingsForTextElement:
//==================================================================================

- (void)loadSettingsForTextElement:(NSXMLElement *)textElement
{
    self.originalTextElement = textElement;
    
    self.masterTextElement = [textElement copy];
    
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
    
    self.masterTextPathElement = NULL;
    
    NSArray * textPathArray = [self.originalTextElement elementsForName:@"textPath"];
    if (textPathArray.count == 1)
    {
        // use existing textPath element from SVG document
        self.masterTextPathElement = textPathArray[0];
    }
    else
    {
        // create a new textPath element
        NSXMLElement * newTextPathElement = [[NSXMLElement alloc] init];
        newTextPathElement.name = @"textPath";

        NSString * idString = [self newElementID:@"textPath"];
        NSXMLNode * idAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        idAttributeNode.name = @"id";
        idAttributeNode.stringValue = idString;
        [newTextPathElement addAttribute:idAttributeNode];
        
        self.masterTextPathElement = newTextPathElement;
    }
    
    [self moveTspanElementsFromTextElement:self.masterTextElement
            toTextPathElement:self.masterTextPathElement];
    
    [self.masterAnimateElementsArray removeAllObjects];
    
    [self convertTextPathAnimateValues];

    self.eligiblePathElementsArray = [self findEligiblePathElements];
    
    [eligiblePathsTableView reloadData];
    [animateElementsTableView reloadData];
    
    NSIndexSet * currentPathRowIndexSet = [NSIndexSet indexSetWithIndex:0];
    NSXMLNode * xlinkHrefAttributeNode = [self.masterTextPathElement attributeForName:@"xlink:href"];
    if (xlinkHrefAttributeNode != NULL)
    {
        NSString * xlinkHrefString = xlinkHrefAttributeNode.stringValue;
        NSCharacterSet * parenthesisCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"()"];
        NSArray * xlinkHrefArray = [xlinkHrefString componentsSeparatedByCharactersInSet:parenthesisCharacterSet];
        
        NSString * currentPathIDString = NULL;
        if (xlinkHrefArray.count == 1)
        {
            currentPathIDString = xlinkHrefArray[0];
        }
        else
        {
            NSInteger openParenthesisIndex = 0;
            NSInteger closeParenthesisIndex = 0;
            NSInteger xlinkHrefArrayCount = xlinkHrefArray.count;
            for (NSInteger i = 0; i < xlinkHrefArrayCount; i++)
            {
                NSString * componentString = xlinkHrefArray[i];
                if ([componentString isEqualToString:@"("] == YES) openParenthesisIndex = i;
                if ([componentString isEqualToString:@")"] == YES) openParenthesisIndex = i;
            }
            if (closeParenthesisIndex == (openParenthesisIndex + 2))
            {
                currentPathIDString = xlinkHrefArray[(openParenthesisIndex + 1)];
            }
        }
        
        if (currentPathIDString != NULL)
        {
            NSInteger currentPathIDStringLength = currentPathIDString.length;
            if (currentPathIDStringLength > 1)
            {
                unichar firstIDCharacter = [currentPathIDString characterAtIndex:0];
                if (firstIDCharacter == '#')
                {
                    currentPathIDString = [currentPathIDString substringFromIndex:1];

                    NSInteger pathArrayCount = (self.eligiblePathElementsArray).count;
                    for (NSInteger pathIndex = 0; pathIndex < pathArrayCount; pathIndex++)
                    {
                        NSXMLElement * pathElement = (self.eligiblePathElementsArray)[pathIndex];
                        NSXMLNode * pathIDAttributeNode = [pathElement attributeForName:@"id"];
                        if (pathIDAttributeNode != NULL)
                        {
                            NSString * pathIDString = pathIDAttributeNode.stringValue;
                            if ([pathIDString isEqualToString:currentPathIDString] == YES)
                            {
                                currentPathRowIndexSet = [NSIndexSet indexSetWithIndex:pathIndex];
                            }
                        }
                    }
                }
            }
        }
    }
    [eligiblePathsTableView selectRowIndexes:currentPathRowIndexSet byExtendingSelection:NO];

    NSIndexSet * firstRowIndexSet = [NSIndexSet indexSetWithIndex:0];
    [animateElementsTableView selectRowIndexes:firstRowIndexSet byExtendingSelection:NO];

    [self makeTextPathPreviewSVG];
    NSString * textPathPreviewXmlString = (self.textPathPreviewXMLDocument).XMLString;
    [textPathPreviewWebView.mainFrame loadHTMLString:textPathPreviewXmlString baseURL:NULL];
}

//==================================================================================
//	convertTextPathAnimateValues
//==================================================================================

- (void)convertTextPathAnimateValues
{
    NSArray * textPathArray = [self.originalTextElement elementsForName:@"textPath"];
    if (textPathArray.count == 1)
    {
        self.masterTextPathElement = textPathArray[0];
        
        NSArray * animateElementsArray = [self.masterTextPathElement elementsForName:@"animate"];
        
        for (NSXMLElement * aAnimateElement in animateElementsArray)
        {
            [self convertAnimateElementValues:aAnimateElement];
        }
    }
}

//==================================================================================
//	convertAnimateElementValues
//==================================================================================

- (void)convertAnimateElementValues:(NSXMLElement *)aAnimateElement
{
    NSXMLNode * fromAttributeNode = [aAnimateElement attributeForName:@"from"];
    NSXMLNode * toAttributeNode = [aAnimateElement attributeForName:@"to"];
    NSXMLNode * valuesAttributeNode = [aAnimateElement attributeForName:@"values"];
    
    NSString * fromAttributeString = NULL;
    NSString * toAttributeString = NULL;
    NSString * valuesAttributeString = NULL;
    
    if (fromAttributeNode != NULL)
    {
        fromAttributeString = fromAttributeNode.stringValue;
    }

    if (toAttributeNode != NULL)
    {
        toAttributeString = toAttributeNode.stringValue;
    }

    if (valuesAttributeNode != NULL)
    {
        valuesAttributeString = valuesAttributeNode.stringValue;
    }
    
    if (valuesAttributeNode != NULL)
    {
        if (fromAttributeNode != NULL)
        {
            NSInteger fromAttributeIndex = fromAttributeNode.index;
            [aAnimateElement removeChildAtIndex:fromAttributeIndex];
        }
        
        if (toAttributeNode != NULL)
        {
            NSInteger toAttributeIndex = toAttributeNode.index;
            [aAnimateElement removeChildAtIndex:toAttributeIndex];
        }
    }
    else
    {
        NSMutableString * tempValuesAttributeString = [NSMutableString string];
        
        if (fromAttributeString != NULL)
        {
            [tempValuesAttributeString appendString:fromAttributeString];
            
            NSInteger fromAttributeIndex = fromAttributeNode.index;
            [aAnimateElement removeChildAtIndex:fromAttributeIndex];
        }
        
        if (toAttributeString != NULL)
        {
            if (fromAttributeString != NULL)
            {
                [tempValuesAttributeString appendString:@";"];
            }
            [tempValuesAttributeString appendString:toAttributeString];
            if (fromAttributeString != NULL)
            {
                [tempValuesAttributeString appendString:@";"];
            }
            
            NSInteger toAttributeIndex = toAttributeNode.index;
            [aAnimateElement removeChildAtIndex:toAttributeIndex];
        }
        
        valuesAttributeString = [NSString stringWithString:tempValuesAttributeString];
        
        valuesAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        valuesAttributeNode.name = @"values";
        valuesAttributeNode.stringValue = valuesAttributeString;
        [aAnimateElement addAttribute:valuesAttributeNode];
    }

    NSXMLElement * copyAnimateElement = [aAnimateElement copy];
    [copyAnimateElement detach];
    [self.masterAnimateElementsArray addObject:copyAnimateElement];
}

//==================================================================================
//	numberOfRowsInTableView:
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSInteger result = 0;
    
    if (aTableView == eligiblePathsTableView)
    {
        result = (self.eligiblePathElementsArray).count;
    }
    else if (aTableView == animateElementsTableView)
    {
        result = (self.masterAnimateElementsArray).count;
    }
    
    return result;
}

//==================================================================================
//	tableView:objectValueForTableColumn:row:
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString * result = @"Missing Result";

    NSString * tableColumnTitle= aTableColumn.identifier;
    
    if (aTableView == eligiblePathsTableView)
    {
        if ([tableColumnTitle isEqualToString:@"PathIndex"] == YES)
        {
            NSString * rowIndexString = [NSString stringWithFormat:@"%ld", (rowIndex + 1)];
            result = rowIndexString;
        }
        else if ([tableColumnTitle isEqualToString:@"PathID"] == YES)
        {
            NSXMLElement * pathElement = (self.eligiblePathElementsArray)[rowIndex];
            
            NSXMLNode * idAttributeNode = [pathElement attributeForName:@"id"];
            NSString * idAttributeString = idAttributeNode.stringValue;
            result = idAttributeString;
        }
        else if ([tableColumnTitle isEqualToString:@"PathLocation"] == YES)
        {
            NSXMLElement * pathElement = (self.eligiblePathElementsArray)[rowIndex];

            NSString * pathXPath = pathElement.XPath;
            result = pathXPath;
        }
    }
    else if (aTableView == animateElementsTableView)
    {
        if ([tableColumnTitle isEqualToString:@"AnimateIndex"] == YES)
        {
            NSString * rowIndexString = [NSString stringWithFormat:@"%ld", (rowIndex + 1)];
            result = rowIndexString;
        }
        else if ([tableColumnTitle isEqualToString:@"AnimateID"] == YES)
        {
            NSXMLElement * animateElement = (self.masterAnimateElementsArray)[rowIndex];

            NSXMLNode * idAttributeNode = [animateElement attributeForName:@"id"];
            NSString * idAttributeString = idAttributeNode.stringValue;
            result = idAttributeString;
        }
    }
    
    return result;
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

-(void)loadSettingsForAnimateElement
{
    NSInteger rowIndex = animateElementsTableView.selectedRow;
    if (rowIndex == -1)
    {
        animateBeginValueTextField.stringValue = @"";
        animateDurationValueTextField.stringValue = @"";
        animateStartOffsetValuesTextField.stringValue = @"";
        
        [animateFillPopUpButton selectItemWithTitle:@""];
    }
    else
    {
        NSXMLElement * animateElement = (self.masterAnimateElementsArray)[rowIndex];
        
        NSXMLNode * beginAttributeNode = [animateElement attributeForName:@"begin"];
        NSString * beginAttributeString = beginAttributeNode.stringValue;
        animateBeginValueTextField.stringValue = beginAttributeString;

        NSXMLNode * durAttributeNode = [animateElement attributeForName:@"dur"];
        NSString * durAttributeString = durAttributeNode.stringValue;
        animateDurationValueTextField.stringValue = durAttributeString;

        NSXMLNode * valuesAttributeNode = [animateElement attributeForName:@"values"];
        NSString * valuesAttributeString = valuesAttributeNode.stringValue;
        animateStartOffsetValuesTextField.stringValue = valuesAttributeString;

        NSXMLNode * fillAttributeNode = [animateElement attributeForName:@"fill"];
        NSString * fillAttributeString = fillAttributeNode.stringValue;
        [animateFillPopUpButton selectItemWithTitle:fillAttributeString];
    }
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = aNotification.object;
    if (aTableView == eligiblePathsTableView)
    {
        [self makeTextPathPreviewSVG];
        NSString * textPathPreviewXmlString = (self.textPathPreviewXMLDocument).XMLString;
        [textPathPreviewWebView.mainFrame loadHTMLString:textPathPreviewXmlString baseURL:NULL];
    }
    else if (aTableView == animateElementsTableView)
    {
        [self loadSettingsForAnimateElement];
        
        [self makeTextPathPreviewSVG];
        NSString * textPathPreviewXmlString = (self.textPathPreviewXMLDocument).XMLString;
        [textPathPreviewWebView.mainFrame loadHTMLString:textPathPreviewXmlString baseURL:NULL];
    }
}

//==================================================================================
//  getTotalPathLength
//==================================================================================

- (void)getTotalPathLength
{
    NSInteger rowIndex = eligiblePathsTableView.selectedRow;
    if (rowIndex != -1)
    {
        NSXMLElement * selectedPathElement = (self.eligiblePathElementsArray)[rowIndex];
        NSXMLNode * pathIDAttributeNode = [selectedPathElement attributeForName:@"id"];
        if (pathIDAttributeNode != NULL)
        {
            NSString * pathIDAttributeString = pathIDAttributeNode.stringValue;
            
            NSString * pathLengthFunction = [NSString stringWithFormat:
                    @"function f() {var path = document.getElementById('%@'); return path.getTotalLength();} f();",
                    pathIDAttributeString];

            NSString * totalLengthString = [textPathPreviewWebView stringByEvaluatingJavaScriptFromString:pathLengthFunction];
            
            float totalStringFloat = totalLengthString.floatValue;
            
            if (totalStringFloat == 0.0f)
            {
                totalLengthString = @"--";
            }
            else
            {
                totalLengthString = [NSString stringWithFormat:@"%.2f", totalStringFloat];
            }

            pathLengthTextField.stringValue = totalLengthString;
        }
    }
    
    NSString * textIDAttributeString = NULL;
    NSXMLElement * textPathElement = self.masterTextPathElement;
    NSXMLNode * textPathIDAttributeNode = [textPathElement attributeForName:@"id"];
    if (textPathIDAttributeNode != NULL)
    {
        textIDAttributeString = textPathIDAttributeNode.stringValue;
    }
    else
    {
        NSXMLElement * textElement = self.masterTextElement;
        NSXMLNode * textIDAttributeNode = [textElement attributeForName:@"id"];
        if (textIDAttributeNode != NULL)
        {
            textIDAttributeString = textIDAttributeNode.stringValue;
        }
    }
    
    if (textIDAttributeString != NULL)
    {
        NSString * textLengthFunction = [NSString stringWithFormat:
                @"function f() {var textElement = document.getElementById('%@'); return textElement.getComputedTextLength();} f();",
                textIDAttributeString];

        NSString * textLengthString = [textPathPreviewWebView stringByEvaluatingJavaScriptFromString:textLengthFunction];

        float textStringFloat = textLengthString.floatValue;
        
        if (textStringFloat == 0.0f)
        {
            textLengthString = @"--";
        }
        else
        {
            textLengthString = [NSString stringWithFormat:@"%.2f", textStringFloat];
        }

        textLengthTextField.stringValue = textLengthString;
    }
    else
    {
        textLengthTextField.stringValue = @"text element ID not set";
    }
}

//==================================================================================
//  webView:didFinishLoadForFrame:
//==================================================================================

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    if (sender == textPathPreviewWebView)
    {
        [self getTotalPathLength];
    }
}

//==================================================================================
//	cancelButtonAction
//==================================================================================

- (IBAction)cancelButtonAction:(id)sender
{
    [self.eligiblePathElementsArray removeAllObjects];
    self.masterTextElement = NULL;
    self.masterTextPathElement = NULL;
    self.masterTextContentString = NULL;
    [self.masterAnimateElementsArray removeAllObjects];
    
    [eligiblePathsTableView reloadData];
    [animateElementsTableView reloadData];

    [textPathPreviewWebView.mainFrame loadHTMLString:@"" baseURL:NULL];

    self.eligiblePathXMLDocument = NULL;
    self.textPathPreviewXMLDocument = NULL;

    self.originalTextElement = NULL;
    self.masterTextElement = NULL;

    [textPathPopover performClose:self];
}

//==================================================================================
//	doneButtonAction
//==================================================================================

- (IBAction)doneButtonAction:(id)sender
{
    [self updateOriginalTextElement];

    [self.eligiblePathElementsArray removeAllObjects];
    self.masterTextElement = NULL;
    self.masterTextPathElement = NULL;
    self.masterTextContentString = NULL;
    [self.masterAnimateElementsArray removeAllObjects];
    
    [eligiblePathsTableView reloadData];
    [animateElementsTableView reloadData];

    [textPathPreviewWebView.mainFrame loadHTMLString:@"" baseURL:NULL];

    self.eligiblePathXMLDocument = NULL;
    self.textPathPreviewXMLDocument = NULL;
    
    // update original animate element here

    self.originalTextElement = NULL;
    self.masterTextElement = NULL;

    [textPathPopover performClose:self];
    
    [textElementEditor updateDocumentViews];
}

//==================================================================================
//	updateOriginalTextElement
//==================================================================================

- (void)updateOriginalTextElement
{
    NSInteger rowIndex = eligiblePathsTableView.selectedRow;
    if (rowIndex != -1)
    {
        NSXMLElement * selectedPathElement = (self.eligiblePathElementsArray)[rowIndex];
        NSXMLNode * pathIDAttributeNode = [selectedPathElement attributeForName:@"id"];
        if (pathIDAttributeNode != NULL)
        {
            NSString * pathIDString = pathIDAttributeNode.stringValue;

            NSXMLElement * originalTextPathElement = NULL;
            
            NSArray * textPathsArray = [self.originalTextElement elementsForName:@"textPath"];

            NSInteger textPathsArrayCount = textPathsArray.count;

            if (textPathsArrayCount == 1)
            {
                originalTextPathElement = textPathsArray[0];
            }
            else if (textPathsArrayCount == 0)
            {
                originalTextPathElement = [[NSXMLElement alloc] init];
                originalTextPathElement.name = @"textPath";
                [textElementEditor assignMacsvgidsForNode:originalTextPathElement];
                [self.originalTextElement addChild:originalTextPathElement];
            }
            
            if (originalTextPathElement != NULL)
            {
                
                NSXMLNode * textNodeForOriginalTextElement = NULL;
                NSXMLNode * textNodeForOriginalTextPathElement = NULL;
                
                [self.originalTextElement normalizeAdjacentTextNodesPreservingCDATA:YES];
                NSArray * textElementChildArray = (self.originalTextElement).children;
                for (NSXMLNode * aChildNode in textElementChildArray)
                {
                    if (aChildNode.kind == NSXMLTextKind)
                    {
                        textNodeForOriginalTextElement = aChildNode;
                    }
                }
                
                NSArray * textPathElementChildArray = originalTextPathElement.children;
                for (NSXMLNode * aChildNode in textPathElementChildArray)
                {
                    if (aChildNode.kind == NSXMLTextKind)
                    {
                        textNodeForOriginalTextPathElement = aChildNode;
                    }
                    else if (aChildNode.kind == NSXMLElementKind)
                    {
                        NSXMLElement * aChildElement = (NSXMLElement *)aChildNode;
                        NSString * elementTag = aChildElement.name;
                        if ([elementTag isEqualToString:@"animate"] == YES)
                        {
                            NSXMLNode * attributeNameAttributeNode = [aChildElement attributeForName:@"attributeName"];
                            if (attributeNameAttributeNode != NULL)
                            {
                                NSString * attributeNameAttributeString = attributeNameAttributeNode.stringValue;
                                if ([attributeNameAttributeString isEqualToString:@"startOffset"] == YES)
                                {
                                    // remove existing animate element from textPath element
                                    NSInteger animateElementIndex = aChildElement.index;
                                    [originalTextPathElement removeChildAtIndex:animateElementIndex];
                                }
                            }
                        }
                    }
                }
                
                if (textNodeForOriginalTextElement != NULL)
                {
                    [textNodeForOriginalTextElement detach];
                    
                    if (textNodeForOriginalTextPathElement == NULL)
                    {
                        [originalTextPathElement addChild:textNodeForOriginalTextElement];
                        [originalTextPathElement normalizeAdjacentTextNodesPreservingCDATA:YES];
                    }
                }

                [self moveTspanElementsFromTextElement:self.originalTextElement
                        toTextPathElement:originalTextPathElement];
                
                NSXMLNode * pathXlinkHrefAttributeNode = [originalTextPathElement attributeForName:@"xlink:href"];
                if (pathXlinkHrefAttributeNode == NULL)
                {
                    pathXlinkHrefAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                    pathXlinkHrefAttributeNode.name = @"xlink:href";
                    pathXlinkHrefAttributeNode.stringValue = @"";
                    [originalTextPathElement addAttribute:pathXlinkHrefAttributeNode];
                }
                NSString * pathXlinkHrefString = [NSString stringWithFormat:@"#%@", pathIDString];
                pathXlinkHrefAttributeNode.stringValue = pathXlinkHrefString;
                
                for (NSXMLElement * aAnimateElement in self.masterAnimateElementsArray)
                {
                    NSXMLElement * newAnimateElement = [aAnimateElement copy];
                    [newAnimateElement detach];
                    
                    NSXMLNode * fromAttributeNode = [newAnimateElement attributeForName:@"from"];
                    if (fromAttributeNode != NULL)
                    {
                        NSInteger fromAttributeIndex = fromAttributeNode.index;
                        [newAnimateElement removeChildAtIndex:fromAttributeIndex];
                    }
                    
                    NSXMLNode * toAttributeNode = [newAnimateElement attributeForName:@"to"];
                    if (toAttributeNode != NULL)
                    {
                        NSInteger toAttributeIndex = toAttributeNode.index;
                        [newAnimateElement removeChildAtIndex:toAttributeIndex];
                    }
                    
                    [originalTextPathElement addChild:newAnimateElement];
                }
            }
        }
    }
    
    //[textElementEditor updateDocumentViews];
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
//	findAllPathElements
//==================================================================================

 -(NSArray *)findAllPathElements
 {       
    NSArray * resultArray = NULL;
    
    NSXMLDocument * svgXmlDocument = textElementEditor.svgXmlDocument;
    
    NSXMLElement * rootElement = [svgXmlDocument rootElement];
    
    NSString * xpathQuery = @".//path";
    
    NSError * error = NULL;
    resultArray = [rootElement nodesForXPath:xpathQuery error:&error];
    
    return resultArray;
}

//==================================================================================
//	findEligiblePathElements
//==================================================================================

- (NSMutableArray *)findEligiblePathElements
{
    NSMutableArray * resultArray = [NSMutableArray array];

    NSArray * allPathsArray = [self findAllPathElements];

    for (NSXMLElement * aPathElement in allPathsArray)
    {
        NSXMLNode * aPathStringNode = [aPathElement attributeForName:@"d"];
        NSString * aPathString = aPathStringNode.stringValue;

        if (aPathString.length > 0)
        {
            [resultArray addObject:aPathElement];
        }
    }
    
    NSArray * sortedPathsArray = [resultArray sortedArrayUsingFunction:pathSort context:NULL];
    resultArray = [NSMutableArray arrayWithArray:sortedPathsArray];
    
    return resultArray;
}

//==================================================================================
//	pathSort()
//==================================================================================

NSComparisonResult pathSort(id element1, id element2, void *context)
{
    NSComparisonResult sortResult = NSOrderedSame;
    
    NSXMLElement * pathElement1 = element1;
    NSXMLElement * pathElement2 = element2;

    NSString * pathIDString1 = @"";
    NSString * pathIDString2 = @"";
    
    NSXMLNode * pathIDAttribute1 = [pathElement1 attributeForName:@"id"];
    if (pathIDAttribute1 != NULL)
    {
        pathIDString1 = pathIDAttribute1.stringValue;
    }
    
    NSXMLNode * pathIDAttribute2 = [pathElement2 attributeForName:@"id"];
    if (pathIDAttribute2 != NULL)
    {
        pathIDString2 = pathIDAttribute2.stringValue;
    }

    sortResult = [pathIDString1 compare:pathIDString2];
        
    return sortResult;
}

//==================================================================================
//	findAllAnimateElements
//==================================================================================

 -(NSArray *)findAllAnimateElements
 {       
    NSArray * resultArray = NULL;
    
    NSXMLDocument * svgXmlDocument = textElementEditor.svgXmlDocument;
    
    NSXMLElement * rootElement = [svgXmlDocument rootElement];
    
    NSString * xpathQuery = @".//animate";
    
    NSError * error = NULL;
    resultArray = [rootElement nodesForXPath:xpathQuery error:&error];
    
    return resultArray;
}

//==================================================================================
//	newElementID
//==================================================================================

 -(NSString *)newElementID:(NSString *)tagName
{
    NSString * newElementIDString = [NSString stringWithFormat:@"%@1", tagName];
    
    NSArray * allAnimateElements = [self findAllAnimateElements];
    
    NSMutableDictionary * animateElementsDictionary = [NSMutableDictionary dictionary];
    
    // add all animate IDs in SVG document
    for (NSXMLElement * aAnimateElement in allAnimateElements)
    {
        NSXMLNode * animateIDNode = [aAnimateElement attributeForName:@"id"];
        
        if (animateIDNode != NULL)
        {
            NSString * animateIDString = animateIDNode.stringValue;
            animateElementsDictionary[animateIDString] = @"exists";
        }
    }

    // add all animate IDs in working array
    for (NSXMLElement * aAnimateElement in self.masterAnimateElementsArray)
    {
        NSXMLNode * animateIDNode = [aAnimateElement attributeForName:@"id"];
        
        if (animateIDNode != NULL)
        {
            NSString * animateIDString = animateIDNode.stringValue;
            animateElementsDictionary[animateIDString] = @"exists";
        }
    }
    
    NSInteger idIndex = 1;
    BOOL continueSearch = YES;
    while (continueSearch == YES)
    {
        newElementIDString = [NSString stringWithFormat:@"%@%ld", tagName, idIndex];
        NSString * idExistsString = animateElementsDictionary[newElementIDString];
        {
            if (idExistsString == NULL)
            {
                continueSearch = NO;
            }
            else
            {
                idIndex++;
            }
        }
    }
    
    return newElementIDString;
}

//==================================================================================
//	addAnimateButtonAction
//==================================================================================

- (IBAction)addAnimateButtonAction:(id)sender
{
    NSXMLElement * newAnimateElement = [[NSXMLElement alloc] init];
    newAnimateElement.name = @"animate";

    [textElementEditor assignMacsvgidsForNode:newAnimateElement];

    NSInteger currentRowIndex = 0;
    NSInteger newRowIndex = 0;
    NSInteger masterAnimateElementsArrayCount =
            (self.masterAnimateElementsArray).count;
    if (masterAnimateElementsArrayCount > 0)
    {
        currentRowIndex = animateElementsTableView.selectedRow;
        if (currentRowIndex == -1)
        {
            currentRowIndex = (self.masterAnimateElementsArray).count - 1;
        }
        newRowIndex = currentRowIndex + 1;
    }

    NSXMLElement * previousAnimateElement = NULL;
    
    if (masterAnimateElementsArrayCount > 0)
    {
        previousAnimateElement = (self.masterAnimateElementsArray)[currentRowIndex];
    }
    
    //NSString * idString = [self newAnimateElementID];
    NSString * idString = [self newElementID:@"animate"];
    NSXMLNode * idAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    idAttributeNode.name = @"id";
    idAttributeNode.stringValue = idString;
    [newAnimateElement addAttribute:idAttributeNode];
    
    NSXMLNode * beginAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    beginAttributeNode.name = @"begin";
    NSString * beginTime = @"0s";
    if (previousAnimateElement != NULL)
    {
        NSXMLNode * previousAnimateElementIDAttributeNode =
                [previousAnimateElement attributeForName:@"id"];
        NSString * previousAnimateElementIDString =
                previousAnimateElementIDAttributeNode.stringValue;
        beginTime = [NSString stringWithFormat:@"%@.end",
                previousAnimateElementIDString];
    }
    beginAttributeNode.stringValue = beginTime;
    [newAnimateElement addAttribute:beginAttributeNode];

    NSXMLNode * durAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    durAttributeNode.name = @"dur";
    durAttributeNode.stringValue = @"5s";
    [newAnimateElement addAttribute:durAttributeNode];

    NSXMLNode * fillAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    fillAttributeNode.name = @"fill";
    fillAttributeNode.stringValue = @"freeze";
    [newAnimateElement addAttribute:fillAttributeNode];

    NSXMLNode * repeatCountAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    repeatCountAttributeNode.name = @"repeatCount";
    repeatCountAttributeNode.stringValue = @"0";
    [newAnimateElement addAttribute:repeatCountAttributeNode];

    NSXMLNode * valuesAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    valuesAttributeNode.name = @"values";
    valuesAttributeNode.stringValue = @"100; 200; 100;";
    [newAnimateElement addAttribute:valuesAttributeNode];

    NSXMLNode * attributeNameAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    attributeNameAttributeNode.name = @"attributeName";
    attributeNameAttributeNode.stringValue = @"startOffset";
    [newAnimateElement addAttribute:attributeNameAttributeNode];

    NSXMLNode * attributeTypeAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    attributeTypeAttributeNode.name = @"attributeType";
    attributeTypeAttributeNode.stringValue = @"XML";
    [newAnimateElement addAttribute:attributeTypeAttributeNode];

    [self.masterAnimateElementsArray insertObject:newAnimateElement atIndex:newRowIndex];

    [animateElementsTableView reloadData];
    
    NSIndexSet * newIndexSet = [NSIndexSet indexSetWithIndex:(currentRowIndex + 1)];
    [animateElementsTableView selectRowIndexes:newIndexSet byExtendingSelection:NO];
}

//==================================================================================
//	removeAnimateButtonAction
//==================================================================================

- (IBAction)removeAnimateButtonAction:(id)sender
{
}

//==================================================================================
//	updateTextPathData
//==================================================================================

- (IBAction)updateTextPathData:(id)sender
{
    NSString * startOffsetString = startOffsetValueTextField.stringValue;
    
    NSXMLNode * startOffsetAttributeNode = [self.masterTextPathElement attributeForName:@"startOffset"];
    if (startOffsetAttributeNode == NULL)
    {
        startOffsetAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        startOffsetAttributeNode.name = @"startOffset";
        startOffsetAttributeNode.stringValue = @"";
        [self.masterTextPathElement addAttribute:startOffsetAttributeNode];
    }
    startOffsetAttributeNode.stringValue = startOffsetString;
    
    NSString * animateBeginString = animateBeginValueTextField.stringValue;
    NSString * animateDurationString = animateDurationValueTextField.stringValue;
    NSString * animateStartOffsetValuesString = animateStartOffsetValuesTextField.stringValue;
    NSString * animateFillString = animateFillPopUpButton.titleOfSelectedItem;
    NSString * animateRepeatCountString = animateRepeatCountComboBox.stringValue;

    NSInteger animateRowIndex = animateElementsTableView.selectedRow;
    
    if (animateRowIndex != -1)
    {
        NSXMLElement * selectedAnimateElement = (self.masterAnimateElementsArray)[animateRowIndex];
        
        NSXMLNode * animateBeginAttributeNode = [selectedAnimateElement attributeForName:@"begin"];
        if (animateBeginAttributeNode == NULL)
        {
            animateBeginAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            animateBeginAttributeNode.name = @"begin";
            animateBeginAttributeNode.stringValue = @"";
            [selectedAnimateElement addAttribute:animateBeginAttributeNode];
        }
        animateBeginAttributeNode.stringValue = animateBeginString;
        
        NSXMLNode * animateDurationAttributeNode = [selectedAnimateElement attributeForName:@"dur"];
        if (animateDurationAttributeNode == NULL)
        {
            animateDurationAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            animateDurationAttributeNode.name = @"dur";
            animateDurationAttributeNode.stringValue = @"";
            [selectedAnimateElement addAttribute:animateDurationAttributeNode];
        }
        animateDurationAttributeNode.stringValue = animateDurationString;
        
        NSXMLNode * animateFillAttributeNode = [selectedAnimateElement attributeForName:@"fill"];
        if (animateFillAttributeNode == NULL)
        {
            animateFillAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            animateFillAttributeNode.name = @"fill";
            animateFillAttributeNode.stringValue = @"";
            [selectedAnimateElement addAttribute:animateFillAttributeNode];
        }
        animateFillAttributeNode.stringValue = animateFillString;
        
        NSXMLNode * animateStartOffsetValuesAttributeNode = [selectedAnimateElement attributeForName:@"values"];
        if (animateStartOffsetValuesAttributeNode == NULL)
        {
            animateStartOffsetValuesAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            animateStartOffsetValuesAttributeNode.name = @"values";
            animateStartOffsetValuesAttributeNode.stringValue = @"";
            [selectedAnimateElement addAttribute:animateStartOffsetValuesAttributeNode];
        }
        animateStartOffsetValuesAttributeNode.stringValue = animateStartOffsetValuesString;
        
        NSXMLNode * animateRepeatCountAttributeNode = [selectedAnimateElement attributeForName:@"repeatCount"];
        if (animateRepeatCountAttributeNode == NULL)
        {
            animateRepeatCountAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            animateRepeatCountAttributeNode.name = @"repeatCount";
            animateRepeatCountAttributeNode.stringValue = @"";
            [selectedAnimateElement addAttribute:animateRepeatCountAttributeNode];
        }
        animateRepeatCountAttributeNode.stringValue = animateRepeatCountString;
    }
    
    [eligiblePathsTableView reloadData];
    [animateElementsTableView reloadData];

    [self makeTextPathPreviewSVG];
    NSString * textPathPreviewXmlString = (self.textPathPreviewXMLDocument).XMLString;
    [textPathPreviewWebView.mainFrame loadHTMLString:textPathPreviewXmlString baseURL:NULL];
}

@end
