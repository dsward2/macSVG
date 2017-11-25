//
//  ElementInfoEditor.m
//  ElementInfoEditor
//
//  Created by Douglas Ward on 11/23/17.
//  Copyright © 2017 ArkPhone LLC. All rights reserved.
//

#import "ElementInfoEditor.h"
#import "ElementInfoEditor.h"

@implementation ElementInfoEditor

//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    return @"Element Info Editor";
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.textFont = [NSFont systemFontOfSize:10];

        self.textAttributes = @{NSFontAttributeName: self.textFont};
        
        self.boldFont = [NSFont boldSystemFontOfSize:10];
        
        self.boldTextAttributes = @{NSFontAttributeName: self.boldFont};
    }
    return self;
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element tag name
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    // works for any element
    
    NSString * result  = self.pluginName;

    return result;
}

//==================================================================================
//	isEditorForElement:elementName:attribute:
//==================================================================================

// return label if this editor can edit specified element and attribute
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName attribute:(NSString *)attributeName
{
    // works for no attributes
    NSString * result = NULL;
    
    return result;
}

//==================================================================================
//	editorPriority:context:
//==================================================================================

- (NSInteger)editorPriority:(NSXMLElement *)targetElement context:(NSString *)context
{
    return 30;
}

//==================================================================================
//	handlePluginEvent
//==================================================================================

-(void) handlePluginEvent:(DOMEvent *)event
{
    // Our callback from WebKit
    //NSString * eventType = event.type;
    
    DOMNode * targetNode = self.pluginTargetDOMElement;
    
    DOMElement * domElement = (DOMElement *)targetNode;
    
    NSString * domMacsvgid = [domElement getAttribute:@"macsvgid"];
    
    NSXMLElement * xmlElement = [self.macSVGPluginCallbacks xmlElementForMacsvgid:domMacsvgid];
    
    [self updateElementInfoForXMLElement:xmlElement domElement:domElement];
}

//==================================================================================
//	updateElementInfoForXMLElement:domElement:
//==================================================================================

-(void) updateElementInfoForXMLElement:(NSXMLElement *)xmlElement domElement:(DOMElement *)domElement
{
    // Our callback from WebKit
    if (xmlElement != NULL)
    {
        NSString * elementName = xmlElement.name;

        NSMutableAttributedString * descriptionString = [[NSMutableAttributedString alloc] init];

        NSAttributedString * elementLabelAttributedString = [[NSAttributedString alloc]
                initWithString:@"Element: " attributes:self.boldTextAttributes];
        [descriptionString appendAttributedString:elementLabelAttributedString];

        NSAttributedString * openBracketAttributedString = [[NSAttributedString alloc]
                initWithString:@"<" attributes:self.textAttributes];
        [descriptionString appendAttributedString:openBracketAttributedString];
        
        NSAttributedString * titleAttributedString = [[NSAttributedString alloc]
                initWithString:elementName attributes:self.textAttributes];
        [descriptionString appendAttributedString:titleAttributedString];

        NSAttributedString * closeBracketAttributedString = [[NSAttributedString alloc]
                initWithString:@">\n\n" attributes:self.textAttributes];
        [descriptionString appendAttributedString:closeBracketAttributedString];
        
        if ([elementName isEqualToString:@"rect"])
        {
            [self appendRect:xmlElement string:descriptionString];
            [self appendBBox:domElement string:descriptionString];
        }
        else if ([elementName isEqualToString:@"circle"])
        {
            [self appendCxCyR:xmlElement string:descriptionString];
            [self appendBBox:domElement string:descriptionString];
        }
        else if ([elementName isEqualToString:@"ellipse"])
        {
            [self appendCxCyRxRy:xmlElement string:descriptionString];
            [self appendBBox:domElement string:descriptionString];
        }
        else if ([elementName isEqualToString:@"polyline"])
        {
            [self appendBBox:domElement string:descriptionString];
        }
        else if ([elementName isEqualToString:@"polygon"])
        {
            [self appendBBox:domElement string:descriptionString];
        }
        else if ([elementName isEqualToString:@"line"])
        {
            [self appendBBox:domElement string:descriptionString];
        }
        else if ([elementName isEqualToString:@"text"])
        {
            [self appendBBox:domElement string:descriptionString];
        }
        else if ([elementName isEqualToString:@"image"])
        {
            [self appendRect:xmlElement string:descriptionString];
            [self appendBBox:domElement string:descriptionString];
        }
        else if ([elementName isEqualToString:@"path"])
        {
            [self appendBBox:domElement string:descriptionString];
        }
        else if ([elementName isEqualToString:@"g"])
        {
            [self appendBBox:domElement string:descriptionString];
        }
        
        //[self appendClientXY:descriptionString];
        [self appendPageXY:descriptionString];
        //[self appendScreenXY:descriptionString];
        

        NSAttributedString * testSuiteDescriptionTitleAttributedString = [[NSAttributedString alloc]
                initWithString:@"XML: " attributes:self.boldTextAttributes];
        [descriptionString appendAttributedString:testSuiteDescriptionTitleAttributedString];

        NSInteger nonTextChildNodes = 0;
        NSXMLElement * selectedXmlElement = [xmlElement copy];
        NSArray * xmlElementChildren = selectedXmlElement.children;
        for (NSXMLNode * childNode in xmlElementChildren)
        {
            if (childNode.kind != NSXMLTextKind)
            {
                [childNode detach];
                nonTextChildNodes++;
            }
        }
        if (nonTextChildNodes > 0)
        {
            NSXMLNode * ellipseTextNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind];
            ellipseTextNode.stringValue = @" … ";
            [selectedXmlElement addChild:ellipseTextNode];
        }
        
        [selectedXmlElement removeAttributeForName:@"macsvgid"];
        
        NSString * xmlString = [selectedXmlElement XMLString];
        
        NSAttributedString * xmlAttributedString = [[NSAttributedString alloc]
                initWithString:xmlString attributes:self.textAttributes];
        [descriptionString appendAttributedString:xmlAttributedString];
        
        [self.elementInfoTextField setAttributedStringValue:descriptionString];
    }
}




- (void)appendRect:(NSXMLElement *)targetElement string:(NSMutableAttributedString *)descriptionString
{
    NSString * xString = @"Undefined";
    NSString * yString = @"Undefined";
    NSString * widthString = @"Undefined";
    NSString * heightString = @"Undefined";
    
    NSXMLNode * xAttributeNode = [targetElement attributeForName:@"x"];
    if (xAttributeNode != NULL)
    {
        xString = xAttributeNode.stringValue;
    }
    
    NSXMLNode * yAttributeNode = [targetElement attributeForName:@"y"];
    if (yAttributeNode != NULL)
    {
        yString = yAttributeNode.stringValue;
    }
    
    NSXMLNode * widthAttributeNode = [targetElement attributeForName:@"width"];
    if (widthAttributeNode != NULL)
    {
        widthString = widthAttributeNode.stringValue;
    }
    
    NSXMLNode * heightAttributeNode = [targetElement attributeForName:@"height"];
    if (heightAttributeNode != NULL)
    {
        heightString = heightAttributeNode.stringValue;
    }

    NSAttributedString * xElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@"SVG x: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:xElementLabelAttributedString];
    
    NSAttributedString * xAttributedString = [[NSAttributedString alloc]
            initWithString:xString attributes:self.textAttributes];
    [descriptionString appendAttributedString:xAttributedString];

    NSAttributedString * yElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@" y: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:yElementLabelAttributedString];

    NSAttributedString * yAttributedString = [[NSAttributedString alloc]
            initWithString:yString attributes:self.textAttributes];
    [descriptionString appendAttributedString:yAttributedString];

    NSAttributedString * widthElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@"\nwidth: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:widthElementLabelAttributedString];
    
    NSAttributedString * widthAttributedString = [[NSAttributedString alloc]
            initWithString:widthString attributes:self.textAttributes];
    [descriptionString appendAttributedString:widthAttributedString];

    NSAttributedString * heightElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@" height: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:heightElementLabelAttributedString];

    NSAttributedString * heightAttributedString = [[NSAttributedString alloc]
            initWithString:heightString attributes:self.textAttributes];
    [descriptionString appendAttributedString:heightAttributedString];

    NSAttributedString * newLineString = [[NSAttributedString alloc]
            initWithString:@"\n\n" attributes:self.textAttributes];
    [descriptionString appendAttributedString:newLineString];
}


- (void)appendBBox:(DOMElement *)targetElement string:(NSMutableAttributedString *)descriptionString
{
    NSRect elementBBox = [self.webKitInterface bBoxForDOMElement:targetElement];
    
    NSString * xString = [self allocFloatString:elementBBox.origin.x];
    NSString * yString = [self allocFloatString:elementBBox.origin.y];
    NSString * widthString = [self allocFloatString:elementBBox.size.width];
    NSString * heightString = [self allocFloatString:elementBBox.size.height];

    NSAttributedString * xElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@"BBox x: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:xElementLabelAttributedString];
    
    NSAttributedString * xAttributedString = [[NSAttributedString alloc]
            initWithString:xString attributes:self.textAttributes];
    [descriptionString appendAttributedString:xAttributedString];

    NSAttributedString * yElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@" y: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:yElementLabelAttributedString];

    NSAttributedString * yAttributedString = [[NSAttributedString alloc]
            initWithString:yString attributes:self.textAttributes];
    [descriptionString appendAttributedString:yAttributedString];

    NSAttributedString * widthElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@"\nwidth: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:widthElementLabelAttributedString];
    
    NSAttributedString * widthAttributedString = [[NSAttributedString alloc]
            initWithString:widthString attributes:self.textAttributes];
    [descriptionString appendAttributedString:widthAttributedString];

    NSAttributedString * heightElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@" height: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:heightElementLabelAttributedString];

    NSAttributedString * heightAttributedString = [[NSAttributedString alloc]
            initWithString:heightString attributes:self.textAttributes];
    [descriptionString appendAttributedString:heightAttributedString];

    NSString * maxXString = [self allocFloatString:(elementBBox.origin.x + elementBBox.size.width)];
    NSString * maxYString = [self allocFloatString:(elementBBox.origin.y + elementBBox.size.height)];

    NSAttributedString * maxXElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@"\nmaxX: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:maxXElementLabelAttributedString];
    
    NSAttributedString * maxXAttributedString = [[NSAttributedString alloc]
            initWithString:maxXString attributes:self.textAttributes];
    [descriptionString appendAttributedString:maxXAttributedString];

    NSAttributedString * maxYElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@" maxY: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:maxYElementLabelAttributedString];

    NSAttributedString * maxYAttributedString = [[NSAttributedString alloc]
            initWithString:maxYString attributes:self.textAttributes];
    [descriptionString appendAttributedString:maxYAttributedString];





    NSAttributedString * newLineString = [[NSAttributedString alloc]
            initWithString:@"\n\n" attributes:self.textAttributes];
    [descriptionString appendAttributedString:newLineString];
}


- (void)appendCxCyR:(NSXMLElement *)targetElement string:(NSMutableAttributedString *)descriptionString
{
    NSString * cxString = @"Undefined";
    NSString * cyString = @"Undefined";
    NSString * rString = @"Undefined";
    
    NSXMLNode * cxAttributeNode = [targetElement attributeForName:@"cx"];
    if (cxAttributeNode != NULL)
    {
        cxString = cxAttributeNode.stringValue;
    }
    
    NSXMLNode * cyAttributeNode = [targetElement attributeForName:@"cy"];
    if (cyAttributeNode != NULL)
    {
        cyString = cyAttributeNode.stringValue;
    }
    
    NSXMLNode * rAttributeNode = [targetElement attributeForName:@"r"];
    if (rAttributeNode != NULL)
    {
        rString = rAttributeNode.stringValue;
    }

    NSAttributedString * xElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@"SVG x: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:xElementLabelAttributedString];
    
    NSAttributedString * cxAttributedString = [[NSAttributedString alloc]
            initWithString:cxString attributes:self.textAttributes];
    [descriptionString appendAttributedString:cxAttributedString];

    NSAttributedString * cyElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@" cy: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:cyElementLabelAttributedString];

    NSAttributedString * cyAttributedString = [[NSAttributedString alloc]
            initWithString:cyString attributes:self.textAttributes];
    [descriptionString appendAttributedString:cyAttributedString];

    NSAttributedString * rElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@"\nr: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:rElementLabelAttributedString];
    
    NSAttributedString * rAttributedString = [[NSAttributedString alloc]
            initWithString:rString attributes:self.textAttributes];
    [descriptionString appendAttributedString:rAttributedString];

    NSAttributedString * newLineString = [[NSAttributedString alloc]
            initWithString:@"\n\n" attributes:self.textAttributes];
    [descriptionString appendAttributedString:newLineString];
}



- (void)appendCxCyRxRy:(NSXMLElement *)targetElement string:(NSMutableAttributedString *)descriptionString
{
    NSString * cxString = @"Undefined";
    NSString * cyString = @"Undefined";
    NSString * rxString = @"Undefined";
    NSString * ryString = @"Undefined";
    
    NSXMLNode * cxAttributeNode = [targetElement attributeForName:@"cx"];
    if (cxAttributeNode != NULL)
    {
        cxString = cxAttributeNode.stringValue;
    }
    
    NSXMLNode * cyAttributeNode = [targetElement attributeForName:@"cy"];
    if (cyAttributeNode != NULL)
    {
        cyString = cyAttributeNode.stringValue;
    }
    
    NSXMLNode * rxAttributeNode = [targetElement attributeForName:@"rx"];
    if (rxAttributeNode != NULL)
    {
        rxString = rxAttributeNode.stringValue;
    }
    
    NSXMLNode * ryAttributeNode = [targetElement attributeForName:@"ry"];
    if (ryAttributeNode != NULL)
    {
        ryString = ryAttributeNode.stringValue;
    }

    NSAttributedString * cxElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@"SVG cx: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:cxElementLabelAttributedString];
    
    NSAttributedString * cxAttributedString = [[NSAttributedString alloc]
            initWithString:cxString attributes:self.textAttributes];
    [descriptionString appendAttributedString:cxAttributedString];

    NSAttributedString * cyElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@" cy: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:cyElementLabelAttributedString];

    NSAttributedString * cyAttributedString = [[NSAttributedString alloc]
            initWithString:cyString attributes:self.textAttributes];
    [descriptionString appendAttributedString:cyAttributedString];

    NSAttributedString * rxElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@"\nrx: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:rxElementLabelAttributedString];
    
    NSAttributedString * rxAttributedString = [[NSAttributedString alloc]
            initWithString:ryString attributes:self.textAttributes];
    [descriptionString appendAttributedString:rxAttributedString];

    NSAttributedString * ryElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@" ry: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:ryElementLabelAttributedString];

    NSAttributedString * ryAttributedString = [[NSAttributedString alloc]
            initWithString:ryString attributes:self.textAttributes];
    [descriptionString appendAttributedString:ryAttributedString];

    NSAttributedString * newLineString = [[NSAttributedString alloc]
            initWithString:@"\n\n" attributes:self.textAttributes];
    [descriptionString appendAttributedString:newLineString];
}






- (void)appendClientXY:(NSMutableAttributedString *)descriptionString
{
    NSAttributedString * xElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@"Mouse clientX: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:xElementLabelAttributedString];
    
    NSPoint currentMouseClientPoint = [self.macSVGPluginCallbacks currentMouseClientPoint];

    NSString * xString = [NSString stringWithFormat:@"%d", (int)currentMouseClientPoint.x];
    NSAttributedString * xAttributedString = [[NSAttributedString alloc]
            initWithString:xString attributes:self.textAttributes];
    [descriptionString appendAttributedString:xAttributedString];

    NSAttributedString * yElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@" clientY: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:yElementLabelAttributedString];

    NSString * yString = [NSString stringWithFormat:@"%d\n\n", (int)currentMouseClientPoint.y];
    NSAttributedString * yAttributedString = [[NSAttributedString alloc]
            initWithString:yString attributes:self.textAttributes];
    [descriptionString appendAttributedString:yAttributedString];
}


- (void)appendPageXY:(NSMutableAttributedString *)descriptionString
{
    NSAttributedString * xElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@"Mouse pageX: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:xElementLabelAttributedString];
    
    NSPoint currentMousePagePoint = [self.macSVGPluginCallbacks currentMousePagePoint];

    NSString * xString = [NSString stringWithFormat:@"%d", (int)currentMousePagePoint.x];
    NSAttributedString * xAttributedString = [[NSAttributedString alloc]
            initWithString:xString attributes:self.textAttributes];
    [descriptionString appendAttributedString:xAttributedString];

    NSAttributedString * yElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@" pageY: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:yElementLabelAttributedString];

    NSString * yString = [NSString stringWithFormat:@"%d\n\n", (int)currentMousePagePoint.y];
    NSAttributedString * yAttributedString = [[NSAttributedString alloc]
            initWithString:yString attributes:self.textAttributes];
    [descriptionString appendAttributedString:yAttributedString];
}


- (void)appendScreenXY:(NSMutableAttributedString *)descriptionString
{
    NSAttributedString * xElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@"Mouse screenX: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:xElementLabelAttributedString];
    
    NSPoint currentMouseScreenPoint = [self.macSVGPluginCallbacks currentMouseScreenPoint];

    NSString * xString = [NSString stringWithFormat:@"%d", (int)currentMouseScreenPoint.x];
    NSAttributedString * xAttributedString = [[NSAttributedString alloc]
            initWithString:xString attributes:self.textAttributes];
    [descriptionString appendAttributedString:xAttributedString];

    NSAttributedString * yElementLabelAttributedString = [[NSAttributedString alloc]
            initWithString:@" screenY: " attributes:self.boldTextAttributes];
    [descriptionString appendAttributedString:yElementLabelAttributedString];

    NSString * yString = [NSString stringWithFormat:@"%d\n\n", (int)currentMouseScreenPoint.y];
    NSAttributedString * yAttributedString = [[NSAttributedString alloc]
            initWithString:yString attributes:self.textAttributes];
    [descriptionString appendAttributedString:yAttributedString];
}


@end
