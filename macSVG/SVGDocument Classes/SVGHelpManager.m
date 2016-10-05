//
//  SVGHelpManager.m
//  macSVG
//
//  Created by Douglas Ward on 7/20/16.
//
//

#import "SVGHelpManager.h"
#import "MacSVGDocumentWindowController.h"
#import "XMLAttributesTableController.h"
#import "EditorUIFrameController.h"

@implementation SVGHelpManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self createElementsHelpDictionary];
        [self createAttributesHelpDictionary];
    }
    return self;
}


-(void)createElementsHelpDictionary
{
    self.elementsHelpDictionary = @{@"a": @"linking.html#AElement",
            @"altGlyph": @"text.html#AltGlyphElement", 
            @"altGlyphDef": @"text.html#AltGlyphDefElement", 
            @"altGlyphItem": @"text.html#AltGlyphItemElement", 
            @"animate": @"animate.html#AnimateElement", 
            @"animateColor": @"animate.html#AnimateColorElement", 
            @"animateMotion": @"animate.html#AnimateMotionElement", 
            @"animateTransform": @"animate.html#AnimateTransformElement", 
            @"circle": @"shapes.html#CircleElement", 
            @"clipPath": @"masking.html#ClipPathElement", 
            @"color-profile": @"color.html#ColorProfileElement", 
            @"cursor": @"interact.html#CursorElement", 
            @"defs": @"struct.html#DefsElement", 
            @"desc": @"struct.html#DescElement", 
            @"ellipse": @"shapes.html#EllipseElement", 
            @"feBlend": @"filters.html#feBlendElement", 
            @"feColorMatrix": @"filters.html#feColorMatrixElement", 
            @"feComponentTransfer": @"filters.html#feComponentTransferElement", 
            @"feComposite": @"filters.html#feCompositeElement", 
            @"feConvolveMatrix": @"filters.html#feConvolveMatrixElement", 
            @"feDiffuseLighting": @"filters.html#feDiffuseLightingElement", 
            @"feDisplacementMap": @"filters.html#feDisplacementMapElement", 
            @"feDistantLight": @"filters.html#feDistantLightElement", 
            @"feFlood": @"filters.html#feFloodElement", 
            @"feFuncA": @"filters.html#feFuncAElement", 
            @"feFuncB": @"filters.html#feFuncBElement", 
            @"feFuncG": @"filters.html#feFuncGElement", 
            @"feFuncR": @"filters.html#feFuncRElement", 
            @"feGaussianBlur": @"filters.html#feGaussianBlurElement", 
            @"feImage": @"filters.html#feImageElement", 
            @"feMerge": @"filters.html#feMergeElement", 
            @"feMergeNode": @"filters.html#feMergeNodeElement", 
            @"feMorphology": @"filters.html#feMorphologyElement", 
            @"feOffset": @"filters.html#feOffsetElement", 
            @"fePointLight": @"filters.html#fePointLightElement", 
            @"feSpecularLighting": @"filters.html#feSpecularLightingElement", 
            @"feSpotLight": @"filters.html#feSpotLightElement", 
            @"feTile": @"filters.html#feTileElement", 
            @"feTurbulence": @"filters.html#feTurbulenceElement", 
            @"filter": @"filters.html#FilterElement", 
            @"font": @"fonts.html#FontElement", 
            @"font-face": @"fonts.html#FontFaceElement", 
            @"font-face-format": @"fonts.html#FontFaceFormatElement", 
            @"font-face-name": @"fonts.html#FontFaceNameElement", 
            @"font-face-src": @"fonts.html#FontFaceSrcElement", 
            @"font-face-uri": @"fonts.html#FontFaceURIElement", 
            @"foreignObject": @"extend.html#ForeignObjectElement", 
            @"g": @"struct.html#GElement", 
            @"glyph": @"fonts.html#GlyphElement", 
            @"glyphRef": @"text.html#GlyphRefElement", 
            @"hkern": @"fonts.html#HKernElement", 
            @"image": @"struct.html#ImageElement", 
            @"line": @"shapes.html#LineElement", 
            @"linearGradient": @"pservers.html#LinearGradientElement", 
            @"marker": @"painting.html#MarkerElement", 
            @"mask": @"masking.html#MaskElement", 
            @"metadata": @"metadata.html#MetadataElement", 
            @"missing-glyph": @"fonts.html#MissingGlyphElement", 
            @"mpath": @"animate.html#MPathElement", 
            @"path": @"paths.html#PathElement", 
            @"pattern": @"pservers.html#PatternElement", 
            @"polygon": @"shapes.html#PolygonElement", 
            @"polyline": @"shapes.html#PolylineElement", 
            @"radialGradient": @"pservers.html#RadialGradientElement", 
            @"rect": @"shapes.html#RectElement", 
            @"script": @"script.html#ScriptElement", 
            @"set": @"animate.html#SetElement", 
            @"stop": @"pservers.html#StopElement", 
            @"style": @"styling.html#StyleElement", 
            @"svg": @"struct.html#SVGElement", 
            @"switch": @"struct.html#SwitchElement", 
            @"symbol": @"struct.html#SymbolElement", 
            @"text": @"text.html#TextElement", 
            @"textPath": @"text.html#TextPathElement", 
            @"title": @"struct.html#TitleElement", 
            @"tref": @"text.html#TRefElement", 
            @"tspan": @"text.html#TSpanElement", 
            @"use": @"struct.html#UseElement", 
            @"view": @"linking.html#ViewElement", 
            @"vkern": @"fonts.html#VKernElement"};
}


-(void)createAttributesHelpDictionary
{
    self.attributesHelpArray = [NSMutableArray array];

    NSBundle* myBundle = [NSBundle mainBundle];
    NSString* filePath = [myBundle pathForResource:@"svg_attributes_help" ofType:@"txt"];

    NSError * fileError = NULL;

    NSString * helpHTML = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&fileError];
    
    NSError * xmlError = NULL;
    NSXMLDocument * helpDocument = [[NSXMLDocument alloc] initWithXMLString:helpHTML options:0 error:&xmlError];
    
    NSError * xpathError = NULL;
    NSArray * rowElementsArray = [helpDocument nodesForXPath:@"html/tr" error:&xpathError];
    
    for (NSXMLElement * aRowElement in rowElementsArray)
    {
        NSArray * cellArray = [aRowElement nodesForXPath:@"td" error:&xpathError];
        
        NSXMLElement * attributeNameElement = cellArray[0];
        NSString * attributeName = attributeNameElement.stringValue;
        
        NSArray * attributeAElementArray = [attributeNameElement nodesForXPath:@"a" error:&xpathError];
        NSXMLElement * attributeAElement = attributeAElementArray.firstObject;
        NSXMLNode * hrefAttributeNode = [attributeAElement attributeForName:@"href"];
        NSString * hrefAttribute = hrefAttributeNode.stringValue;
        
        NSXMLElement * elementNamesElement = cellArray[1];
        
        NSMutableArray * attributeElementsArray = [NSMutableArray array];
        NSArray * attributeElementsRowArray = [elementNamesElement nodesForXPath:@"a/span" error:&xpathError];
        for (NSXMLElement * aAttributeElement in attributeElementsRowArray)
        {
            NSString * aElementName = aAttributeElement.stringValue;
            [attributeElementsArray addObject:aElementName];
        }
        
        NSXMLElement * attributeAnimatableElement = cellArray[2];
        NSString * attributeAnimatable = attributeAnimatableElement.stringValue;
        if (attributeAnimatable.length > 0)
        {
            attributeAnimatable = @"1";
        }
        else
        {
            attributeAnimatable = @"0";
        }

        NSDictionary * attributeHelpDictionary = @{@"attributeName": attributeName,
                @"attributeURL": hrefAttribute,
                @"attributeElements": attributeElementsArray,
                @"attributeAnimatable": attributeAnimatable,
                @"presentationAttribute": @"0"};
        
        [self.attributesHelpArray addObject:attributeHelpDictionary];
    }
    
    // add the presentation attributes
    filePath = [myBundle pathForResource:@"svg_presentation_attributes_help" ofType:@"txt"];

    helpHTML = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&fileError];
    
    xmlError = NULL;
    helpDocument = [[NSXMLDocument alloc] initWithXMLString:helpHTML options:0 error:&xmlError];
    
    xpathError = NULL;
    NSArray * elementsXPathArray = [helpDocument nodesForXPath:@"html/elements/a/span" error:&xpathError];

    NSMutableArray * elementsArray = [NSMutableArray array];
    
    for (NSXMLElement * aElement in elementsXPathArray)
    {
        NSString * aElementString = aElement.stringValue;
        [elementsArray addObject:aElementString];
    }
    
    NSArray * attributesXPathArray = [helpDocument nodesForXPath:@"html/tr/td/a" error:&xpathError];
    
    for (NSXMLElement * aAttributeElement in attributesXPathArray)
    {
        NSString * attributeName = aAttributeElement.stringValue;
        
        NSXMLNode * hrefAttributeNode = [aAttributeElement attributeForName:@"href"];
        NSString * hrefAttribute = hrefAttributeNode.stringValue;
    
        NSDictionary * attributeHelpDictionary = @{@"attributeName": attributeName,
                @"attributeURL": hrefAttribute,
                @"attributeElements": elementsArray,
                @"attributeAnimatable": @"1",
                @"presentationAttribute": @"1"};
        
        [self.attributesHelpArray addObject:attributeHelpDictionary];
    
    }
}


- (void)showDocumentationForElement:(NSString *)elementName
{
    NSString * urlFragment = (self.elementsHelpDictionary)[elementName];
    
    NSString * urlString = [NSString stringWithFormat:@"http://www.w3.org/TR/SVG/%@", urlFragment];

    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}


- (void)showDocumentationForAttribute:(NSString *)attributeName
{
    NSXMLElement * selectedElement = self.macSVGDocumentWindowController.editorUIFrameController.xmlAttributesTableController.xmlElementForAttributesTable;
    NSString * elementName = selectedElement.name;
    
    for (NSDictionary * attributeHelpDictionary in self.attributesHelpArray)
    {
        NSString * aAttributeName = attributeHelpDictionary[@"attributeName"];
        
        if ([attributeName isEqualToString:aAttributeName])
        {
            NSArray * attributeElementsArray = attributeHelpDictionary[@"attributeElements"];
        
            for (NSString * aElementName in attributeElementsArray)
            {
                if ([elementName isEqualToString:aElementName])
                {
                    NSString * attributeURL = attributeHelpDictionary[@"attributeURL"];

                    NSString * urlString = [NSString stringWithFormat:@"http://www.w3.org/TR/SVG/%@", attributeURL];

                    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
                    
                    break;
                }
            }
        }
    }
}

@end
