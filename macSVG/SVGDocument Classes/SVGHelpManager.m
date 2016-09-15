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
    self.elementsHelpDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
            @"linking.html#AElement", @"a",
            @"text.html#AltGlyphElement", @"altGlyph", 
            @"text.html#AltGlyphDefElement", @"altGlyphDef", 
            @"text.html#AltGlyphItemElement", @"altGlyphItem", 
            @"animate.html#AnimateElement", @"animate", 
            @"animate.html#AnimateColorElement", @"animateColor", 
            @"animate.html#AnimateMotionElement", @"animateMotion", 
            @"animate.html#AnimateTransformElement", @"animateTransform", 
            @"shapes.html#CircleElement", @"circle", 
            @"masking.html#ClipPathElement", @"clipPath", 
            @"color.html#ColorProfileElement", @"color-profile", 
            @"interact.html#CursorElement", @"cursor", 
            @"struct.html#DefsElement", @"defs", 
            @"struct.html#DescElement", @"desc", 
            @"shapes.html#EllipseElement", @"ellipse", 
            @"filters.html#feBlendElement", @"feBlend", 
            @"filters.html#feColorMatrixElement", @"feColorMatrix", 
            @"filters.html#feComponentTransferElement", @"feComponentTransfer", 
            @"filters.html#feCompositeElement", @"feComposite", 
            @"filters.html#feConvolveMatrixElement", @"feConvolveMatrix", 
            @"filters.html#feDiffuseLightingElement", @"feDiffuseLighting", 
            @"filters.html#feDisplacementMapElement", @"feDisplacementMap", 
            @"filters.html#feDistantLightElement", @"feDistantLight", 
            @"filters.html#feFloodElement", @"feFlood", 
            @"filters.html#feFuncAElement", @"feFuncA", 
            @"filters.html#feFuncBElement", @"feFuncB", 
            @"filters.html#feFuncGElement", @"feFuncG", 
            @"filters.html#feFuncRElement", @"feFuncR", 
            @"filters.html#feGaussianBlurElement", @"feGaussianBlur", 
            @"filters.html#feImageElement", @"feImage", 
            @"filters.html#feMergeElement", @"feMerge", 
            @"filters.html#feMergeNodeElement", @"feMergeNode", 
            @"filters.html#feMorphologyElement", @"feMorphology", 
            @"filters.html#feOffsetElement", @"feOffset", 
            @"filters.html#fePointLightElement", @"fePointLight", 
            @"filters.html#feSpecularLightingElement", @"feSpecularLighting", 
            @"filters.html#feSpotLightElement", @"feSpotLight", 
            @"filters.html#feTileElement", @"feTile", 
            @"filters.html#feTurbulenceElement", @"feTurbulence", 
            @"filters.html#FilterElement", @"filter", 
            @"fonts.html#FontElement", @"font", 
            @"fonts.html#FontFaceElement", @"font-face", 
            @"fonts.html#FontFaceFormatElement", @"font-face-format", 
            @"fonts.html#FontFaceNameElement", @"font-face-name", 
            @"fonts.html#FontFaceSrcElement", @"font-face-src", 
            @"fonts.html#FontFaceURIElement", @"font-face-uri", 
            @"extend.html#ForeignObjectElement", @"foreignObject", 
            @"struct.html#GElement", @"g", 
            @"fonts.html#GlyphElement", @"glyph", 
            @"text.html#GlyphRefElement", @"glyphRef", 
            @"fonts.html#HKernElement", @"hkern", 
            @"struct.html#ImageElement", @"image", 
            @"shapes.html#LineElement", @"line", 
            @"pservers.html#LinearGradientElement", @"linearGradient", 
            @"painting.html#MarkerElement", @"marker", 
            @"masking.html#MaskElement", @"mask", 
            @"metadata.html#MetadataElement", @"metadata", 
            @"fonts.html#MissingGlyphElement", @"missing-glyph", 
            @"animate.html#MPathElement", @"mpath", 
            @"paths.html#PathElement", @"path", 
            @"pservers.html#PatternElement", @"pattern", 
            @"shapes.html#PolygonElement", @"polygon", 
            @"shapes.html#PolylineElement", @"polyline", 
            @"pservers.html#RadialGradientElement", @"radialGradient", 
            @"shapes.html#RectElement", @"rect", 
            @"script.html#ScriptElement", @"script", 
            @"animate.html#SetElement", @"set", 
            @"pservers.html#StopElement", @"stop", 
            @"styling.html#StyleElement", @"style", 
            @"struct.html#SVGElement", @"svg", 
            @"struct.html#SwitchElement", @"switch", 
            @"struct.html#SymbolElement", @"symbol", 
            @"text.html#TextElement", @"text", 
            @"text.html#TextPathElement", @"textPath", 
            @"struct.html#TitleElement", @"title", 
            @"text.html#TRefElement", @"tref", 
            @"text.html#TSpanElement", @"tspan", 
            @"struct.html#UseElement", @"use", 
            @"linking.html#ViewElement", @"view", 
            @"fonts.html#VKernElement", @"vkern", NULL];
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
        
        NSXMLElement * attributeNameElement = [cellArray objectAtIndex:0];
        NSString * attributeName = [attributeNameElement stringValue];
        
        NSArray * attributeAElementArray = [attributeNameElement nodesForXPath:@"a" error:&xpathError];
        NSXMLElement * attributeAElement = [attributeAElementArray firstObject];
        NSXMLNode * hrefAttributeNode = [attributeAElement attributeForName:@"href"];
        NSString * hrefAttribute = [hrefAttributeNode stringValue];
        
        NSXMLElement * elementNamesElement = [cellArray objectAtIndex:1];
        
        NSMutableArray * attributeElementsArray = [NSMutableArray array];
        NSArray * attributeElementsRowArray = [elementNamesElement nodesForXPath:@"a/span" error:&xpathError];
        for (NSXMLElement * aAttributeElement in attributeElementsRowArray)
        {
            NSString * aElementName = [aAttributeElement stringValue];
            [attributeElementsArray addObject:aElementName];
        }
        
        NSXMLElement * attributeAnimatableElement = [cellArray objectAtIndex:2];
        NSString * attributeAnimatable = [attributeAnimatableElement stringValue];
        if ([attributeAnimatable length] > 0)
        {
            attributeAnimatable = @"1";
        }
        else
        {
            attributeAnimatable = @"0";
        }

        NSDictionary * attributeHelpDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                attributeName, @"attributeName",
                hrefAttribute, @"attributeURL",
                attributeElementsArray, @"attributeElements",
                attributeAnimatable, @"attributeAnimatable",
                @"0", @"presentationAttribute",
                nil];
        
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
        NSString * aElementString = [aElement stringValue];
        [elementsArray addObject:aElementString];
    }
    
    NSArray * attributesXPathArray = [helpDocument nodesForXPath:@"html/tr/td/a" error:&xpathError];
    
    for (NSXMLElement * aAttributeElement in attributesXPathArray)
    {
        NSString * attributeName = [aAttributeElement stringValue];
        
        NSXMLNode * hrefAttributeNode = [aAttributeElement attributeForName:@"href"];
        NSString * hrefAttribute = [hrefAttributeNode stringValue];
    
        NSDictionary * attributeHelpDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                attributeName, @"attributeName",
                hrefAttribute, @"attributeURL",
                elementsArray, @"attributeElements",
                @"1", @"attributeAnimatable",
                @"1", @"presentationAttribute",
                nil];
        
        [self.attributesHelpArray addObject:attributeHelpDictionary];
    
    }
}


- (void)showDocumentationForElement:(NSString *)elementName
{
    NSString * urlFragment = [self.elementsHelpDictionary objectForKey:elementName];
    
    NSString * urlString = [NSString stringWithFormat:@"http://www.w3.org/TR/SVG/%@", urlFragment];

    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}


- (void)showDocumentationForAttribute:(NSString *)attributeName
{
    NSXMLElement * selectedElement = self.macSVGDocumentWindowController.editorUIFrameController.xmlAttributesTableController.xmlElementForAttributesTable;
    NSString * elementName = [selectedElement name];
    
    for (NSDictionary * attributeHelpDictionary in self.attributesHelpArray)
    {
        NSString * aAttributeName = [attributeHelpDictionary objectForKey:@"attributeName"];
        
        if ([attributeName isEqualToString:aAttributeName])
        {
            NSArray * attributeElementsArray = [attributeHelpDictionary objectForKey:@"attributeElements"];
        
            for (NSString * aElementName in attributeElementsArray)
            {
                if ([elementName isEqualToString:aElementName])
                {
                    NSString * attributeURL = [attributeHelpDictionary objectForKey:@"attributeURL"];

                    NSString * urlString = [NSString stringWithFormat:@"http://www.w3.org/TR/SVG/%@", attributeURL];

                    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
                    
                    break;
                }
            }
        }
    }
}

@end
