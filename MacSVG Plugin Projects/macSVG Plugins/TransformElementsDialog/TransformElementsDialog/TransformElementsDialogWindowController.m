//
//  TransformElementsDialogWindowController.m
//  TransformElementsDialog
//
//  Created by Douglas Ward on 8/10/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "TransformElementsDialogWindowController.h"
#import "TransformElementsDialog.h"
#import "MacSVGPlugin/MacSVGPluginCallbacks.h"
#import "SVGWebKitController.h"
#import "SVGWebView.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface TransformElementsDialogWindowController ()

@end

@implementation TransformElementsDialogWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


//==================================================================================
//	awakeFromNib
//==================================================================================

- (void)awakeFromNib
{
    [self configureTextFields];
}

//==================================================================================
//	transformPopUpButtonAction:
//==================================================================================

- (IBAction)transformPopUpButtonAction:(id)sender
{
    [self configureTextFields];
}

//==================================================================================
//	configureTextFields
//==================================================================================

- (void)configureTextFields
{
    BOOL hideValue1 = YES;
    BOOL hideValue2 = YES;
    BOOL hideValue3 = YES;

    NSString * transformName = transformPopUpButton.titleOfSelectedItem;
    
    if ([transformName isEqualToString:@"Translate"] == YES)
    {
        hideValue1 = NO;
        hideValue2 = NO;

        textLabel1.stringValue = @"Transform x:";
        textValue1.stringValue = @"0.0";
        
        textLabel2.stringValue = @"Transform y:";
        textValue2.stringValue = @"0.0";
        
        transformNotes.stringValue = @"Selected elements will be translated normally.";
    }

    if ([transformName isEqualToString:@"Scale"] == YES)
    {
        hideValue1 = NO;
        hideValue2 = NO;

        textLabel1.stringValue = @"Scale x:";
        textValue1.stringValue = @"1.0";
        
        textLabel2.stringValue = @"Scale y:";
        textValue2.stringValue = @"1.0";

        transformNotes.stringValue = @"Scalling will be applied to 'stroke-width' attributes using the X scale factor.  Scaling will also apply to the 'font-size' attribute for 'text' elements.";
    }

    if ([transformName isEqualToString:@"Rotate"] == YES)
    {
        hideValue1 = NO;
        hideValue2 = NO;
        hideValue3 = NO;

        NSMutableArray * selectedElementsArray = (transformElementsDialog.macSVGPluginCallbacks).selectedElementsArray;
        
        CGPoint centerPoint = [self centerPointForElements:selectedElementsArray];

        textLabel1.stringValue = @"Center x:";
        textValue1.stringValue = [NSString stringWithFormat:@"%f", centerPoint.x];
        
        textLabel2.stringValue = @"Center y:";
        textValue2.stringValue = [NSString stringWithFormat:@"%f", centerPoint.y];
        
        textLabel3.stringValue = @"Degrees:";
        textValue3.stringValue = @"0.0";

        transformNotes.stringValue = @"'rect' and 'ellipse' elements will be converted to 'path' elements before rotation.  'text' and 'image' elements will not be rotated.";
    }

    textLabel1.hidden = hideValue1;
    textValue1.hidden = hideValue1;

    textLabel2.hidden = hideValue2;
    textValue2.hidden = hideValue2;

    textLabel3.hidden = hideValue3;
    textValue3.hidden = hideValue3;
}

//==================================================================================
//	cancelButtonAction:
//==================================================================================

- (IBAction)cancelButtonAction:(id)sender
{
    [[NSApplication sharedApplication] stopModalWithCode:NSModalResponseCancel];
    
    [self.window close];
}

//==================================================================================
//	applyButtonAction:
//==================================================================================

- (IBAction)applyButtonAction:(id)sender;
{
    [[NSApplication sharedApplication] stopModalWithCode:NSModalResponseOK];
    
    [self.window close];
    
    [transformElementsDialog.macSVGPluginCallbacks pushUndoRedoDocumentChanges];

    NSString * transformName = transformPopUpButton.titleOfSelectedItem;
    
    if ([transformName isEqualToString:@"Translate"] == YES)
    {
        float translateXFloat = textValue1.floatValue;
        float translateYFloat = textValue2.floatValue;

        [self translateSelectedElementsWithX:translateXFloat y:translateYFloat];
    }

    if ([transformName isEqualToString:@"Scale"] == YES)
    {
        float scaleXFloat = textValue1.floatValue;
        float scaleYFloat = textValue2.floatValue;
        
        [self scaleSelectedElementsWithXScale:scaleXFloat yScale:scaleYFloat];
    }

    if ([transformName isEqualToString:@"Rotate"] == YES)
    {
        float centerXFloat = textValue1.floatValue;
        float centerYFloat = textValue2.floatValue;
        float degreesFloat = textValue3.floatValue;
        
        [self rotateSelectedElementsWithCenterX:centerXFloat centerY:centerYFloat degrees:degreesFloat];
    }

    [transformElementsDialog updateDocumentViews];
}


//==================================================================================
//	translateSelectedElementsWithX:y:
//==================================================================================

- (void)translateSelectedElementsWithX:(float)xTranslate y:(float)yTranslate
{
    NSMutableArray * selectedElementsArray = (transformElementsDialog.macSVGPluginCallbacks).selectedElementsArray;
    
    for (id aSelectedElement in selectedElementsArray)
    {
        NSXMLElement * aSelectedXMLElement = aSelectedElement[@"xmlElement"];
        
        NSString * elementName = aSelectedXMLElement.name;
        
        if ([elementName isEqualToString:@"path"] == YES)
        {
            [self translatePathElement:aSelectedElement x:xTranslate y:yTranslate];
        }
        else if ([elementName isEqualToString:@"rect"] == YES)
        {
            [self translateRectElement:aSelectedElement x:xTranslate y:yTranslate];
        }
        else if ([elementName isEqualToString:@"circle"] == YES)
        {
            [self translateCircleElement:aSelectedElement x:xTranslate y:yTranslate];
        }
        else if ([elementName isEqualToString:@"ellipse"] == YES)
        {
            [self translateEllipseElement:aSelectedElement x:xTranslate y:yTranslate];
        }
        else if ([elementName isEqualToString:@"polyline"] == YES)
        {
            [self translatePolylineElement:aSelectedElement x:xTranslate y:yTranslate];
        }
        else if ([elementName isEqualToString:@"polygon"] == YES)
        {
            [self translatePolylineElement:aSelectedElement x:xTranslate y:yTranslate];
        }
        else if ([elementName isEqualToString:@"line"] == YES)
        {
            [self translateLineElement:aSelectedElement  x:xTranslate y:yTranslate];
        }
        else if ([elementName isEqualToString:@"text"] == YES)
        {
            [self translateRectElement:aSelectedElement  x:xTranslate y:yTranslate];
        }
        else if ([elementName isEqualToString:@"image"] == YES)
        {
            [self translateRectElement:aSelectedElement  x:xTranslate y:yTranslate];
        }
        else if ([elementName isEqualToString:@"foreignObject"] == YES)
        {
            [self translateRectElement:aSelectedElement  x:xTranslate y:yTranslate];
        }
    }
}

//==================================================================================
//	translatePathElement:scaleX:scaleY:
//==================================================================================

- (void)translatePathElement:(NSMutableDictionary *)pathElementDictionary x:(float)xTranslate y:(float)yTranslate
{
    NSXMLElement * pathElement = pathElementDictionary[@"xmlElement"];

    NSXMLNode * pathAttributeNode = [pathElement attributeForName:@"d"];
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [transformElementsDialog.macSVGPluginCallbacks buildPathSegmentsArrayWithPathString:pathAttributeString];
    
    NSMutableArray * rotatedSegmentsArray = [transformElementsDialog.macSVGPluginCallbacks
            translatePathCoordinatesWithPathSegmentsArray:pathSegmentsArray x:xTranslate y:yTranslate];

    [self updatePathElement:pathElementDictionary withPathSegmentsArray:rotatedSegmentsArray];
}

//==================================================================================
//	translateRectElement:scaleX:scaleY:
//==================================================================================

- (void)translateRectElement:(NSMutableDictionary *)rectElementDictionary x:(float)xTranslate y:(float)yTranslate
{
    NSXMLElement * rectElement = rectElementDictionary[@"xmlElement"];
    DOMElement * domRectElement = rectElementDictionary[@"domElement"];
    
    NSXMLNode * xAttributeNode = [rectElement attributeForName:@"x"];
    NSString * xAttributeString = xAttributeNode.stringValue;
    float x = xAttributeString.floatValue;
    
    NSXMLNode * yAttributeNode = [rectElement attributeForName:@"y"];
    NSString * yAttributeString = yAttributeNode.stringValue;
    float y = yAttributeString.floatValue;
    
    float newX = x + xTranslate;
    float newY = y + yTranslate;
    
    xAttributeString = [transformElementsDialog allocPxString:newX];
    yAttributeString = [transformElementsDialog allocPxString:newY];
    
    xAttributeNode.stringValue = xAttributeString;
    yAttributeNode.stringValue = yAttributeString;
    
    [domRectElement setAttribute:@"x" value:xAttributeString];
    [domRectElement setAttribute:@"y" value:yAttributeString];
}

//==================================================================================
//	translateCircleElement:scaleX:scaleY:
//==================================================================================

- (void)translateCircleElement:(NSMutableDictionary *)circleElementDictionary  x:(float)xTranslate y:(float)yTranslate
{
    NSXMLElement * circleElement = circleElementDictionary[@"xmlElement"];
    DOMElement * domCircleElement = circleElementDictionary[@"domElement"];
    
    NSXMLNode * cxAttributeNode = [circleElement attributeForName:@"cx"];
    NSString * cxAttributeString = cxAttributeNode.stringValue;
    float cx = cxAttributeString.floatValue;
    
    NSXMLNode * cyAttributeNode = [circleElement attributeForName:@"cy"];
    NSString * cyAttributeString = cyAttributeNode.stringValue;
    float cy = cyAttributeString.floatValue;
    
    float newCX = cx + xTranslate;
    float newCY = cy + yTranslate;
    
    cxAttributeString = [transformElementsDialog allocPxString:newCX];
    cyAttributeString = [transformElementsDialog allocPxString:newCY];
    
    cxAttributeNode.stringValue = cxAttributeString;
    cyAttributeNode.stringValue = cyAttributeString;
    
    [domCircleElement setAttribute:@"cx" value:cxAttributeString];
    [domCircleElement setAttribute:@"cy" value:cyAttributeString];
}

//==================================================================================
//	translateEllipseElement:scaleX:scaleY:
//==================================================================================

- (void)translateEllipseElement:(NSMutableDictionary *)ellipseElementDictionary x:(float)xTranslate y:(float)yTranslate
{
    NSXMLElement * ellipseElement = ellipseElementDictionary[@"xmlElement"];
    DOMElement * domEllipseElement = ellipseElementDictionary[@"domElement"];
    
    NSXMLNode * cxAttributeNode = [ellipseElement attributeForName:@"cx"];
    NSString * cxAttributeString = cxAttributeNode.stringValue;
    float cx = cxAttributeString.floatValue;
    
    NSXMLNode * cyAttributeNode = [ellipseElement attributeForName:@"cy"];
    NSString * cyAttributeString = cyAttributeNode.stringValue;
    float cy = cyAttributeString.floatValue;
    
    float newCX = cx + xTranslate;
    float newCY = cy + yTranslate;
    
    cxAttributeString = [transformElementsDialog allocPxString:newCX];
    cyAttributeString = [transformElementsDialog allocPxString:newCY];
    
    cxAttributeNode.stringValue = cxAttributeString;
    cyAttributeNode.stringValue = cyAttributeString;
    
    [domEllipseElement setAttribute:@"cx" value:cxAttributeString];
    [domEllipseElement setAttribute:@"cy" value:cyAttributeString];
}

//==================================================================================
//	translatePolylineElement:scaleX:scaleY:
//==================================================================================

- (void)translatePolylineElement:(NSMutableDictionary *)polylineElementDictionary x:(float)xTranslate y:(float)yTranslate
{
    NSXMLElement * polylineElement = polylineElementDictionary[@"xmlElement"];

    NSXMLNode * pointsAttributeNode = [polylineElement attributeForName:@"points"];
    NSString * pointsAttributeString = pointsAttributeNode.stringValue;

    NSCharacterSet * pointsCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" ,"];
    
    NSArray * pointsComponents = [pointsAttributeString componentsSeparatedByCharactersInSet:pointsCharacterSet];
    
    NSMutableArray * pointsArray = [[NSMutableArray alloc] init];
    
    for (NSString * aString in pointsComponents)
    {
        if ([aString isEqualToString:@""] == NO)
        {
            [pointsArray addObject:aString];
        }
    }
    
    NSUInteger pointsArrayCount = pointsArray.count;

    NSMutableString * newPointsString = [[NSMutableString alloc] init];
    
    for (int i = 0; i < pointsArrayCount; i+=2) 
    {
        NSString * xString = pointsArray[i];
        NSString * yString = pointsArray[(i + 1)];
        
        float x = xString.floatValue;
        float y = yString.floatValue;
        
        x = x + xTranslate;
        y = y + yTranslate;
        
        xString = [transformElementsDialog allocFloatString:x];
        yString = [transformElementsDialog allocFloatString:y];
        
        if (i > 0) 
        {
            [newPointsString appendString:@" "];
        }
        
        [newPointsString appendString:xString];
        [newPointsString appendString:@","];
        [newPointsString appendString:yString];
    }

    pointsAttributeNode.stringValue = newPointsString;
    
    DOMElement * domCircleElement = polylineElementDictionary[@"domElement"];

    [domCircleElement setAttribute:@"points" value:newPointsString];
}

//==================================================================================
//	translateLineElement:scaleX:scaleY:
//==================================================================================

- (void)translateLineElement:(NSMutableDictionary *)lineElementDictionary x:(float)xTranslate y:(float)yTranslate
{
    NSXMLElement * lineElement = lineElementDictionary[@"xmlElement"];
    DOMElement * domLineElement = lineElementDictionary[@"domElement"];
    
    NSXMLNode * x1AttributeNode = [lineElement attributeForName:@"x1"];
    NSString * x1AttributeString = x1AttributeNode.stringValue;
    float x1 = x1AttributeString.floatValue;
    
    NSXMLNode * y1AttributeNode = [lineElement attributeForName:@"y1"];
    NSString * y1AttributeString = y1AttributeNode.stringValue;
    float y1 = y1AttributeString.floatValue;
    
    NSXMLNode * x2AttributeNode = [lineElement attributeForName:@"x2"];
    NSString * x2AttributeString = x2AttributeNode.stringValue;
    float x2 = x2AttributeString.floatValue;
    
    NSXMLNode * y2AttributeNode = [lineElement attributeForName:@"y2"];
    NSString * y2AttributeString = y2AttributeNode.stringValue;
    float y2 = y2AttributeString.floatValue;
    
    float newX1 = x1 + xTranslate;
    float newY1 = y1 + yTranslate;
    float newX2 = x2 + yTranslate;
    float newY2 = y2 + yTranslate;
    
    x1AttributeString = [transformElementsDialog allocPxString:newX1];
    y1AttributeString = [transformElementsDialog allocPxString:newY1];
    x2AttributeString = [transformElementsDialog allocPxString:newX2];
    y2AttributeString = [transformElementsDialog allocPxString:newY2];
    
    x1AttributeNode.stringValue = x1AttributeString;
    y1AttributeNode.stringValue = y1AttributeString;
    x2AttributeNode.stringValue = x2AttributeString;
    y2AttributeNode.stringValue = y2AttributeString;
    
    [domLineElement setAttribute:@"x1" value:x1AttributeString];
    [domLineElement setAttribute:@"y1" value:y1AttributeString];
    [domLineElement setAttribute:@"x2" value:x2AttributeString];
    [domLineElement setAttribute:@"y2" value:y2AttributeString];
}





//==================================================================================
//	scaleSelectedElementsWithXScale:yScale:
//==================================================================================

- (void)scaleSelectedElementsWithXScale:(float)xScale yScale:(float)yScale
{
    NSMutableArray * selectedElementsArray = (transformElementsDialog.macSVGPluginCallbacks).selectedElementsArray;
    
    for (id aSelectedElement in selectedElementsArray)
    {
        NSXMLElement * aSelectedXMLElement = aSelectedElement[@"xmlElement"];
        
        NSString * elementName = aSelectedXMLElement.name;
        
        if ([elementName isEqualToString:@"path"] == YES)
        {
            [self scalePathElement:aSelectedElement xScale:xScale yScale:yScale];
        }
        else if ([elementName isEqualToString:@"rect"] == YES)
        {
            [self scaleRectElement:aSelectedElement xScale:xScale yScale:yScale];
        }
        else if ([elementName isEqualToString:@"circle"] == YES)
        {
            [self scaleCircleElement:aSelectedElement xScale:xScale yScale:yScale];
        }
        else if ([elementName isEqualToString:@"ellipse"] == YES)
        {
            [self scaleEllipseElement:aSelectedElement xScale:xScale yScale:yScale];
        }
        else if ([elementName isEqualToString:@"polyline"] == YES)
        {
            [self scalePolylineElement:aSelectedElement xScale:xScale yScale:yScale];
        }
        else if ([elementName isEqualToString:@"polygon"] == YES)
        {
            [self scalePolylineElement:aSelectedElement xScale:xScale yScale:yScale];
        }
        else if ([elementName isEqualToString:@"line"] == YES)
        {
            [self scaleLineElement:aSelectedElement xScale:xScale yScale:yScale];
        }
        else if ([elementName isEqualToString:@"text"] == YES)
        {
            [self scaleTextElement:aSelectedElement xScale:xScale yScale:yScale];
        }
        else if ([elementName isEqualToString:@"image"] == YES)
        {
            [self scaleRectElement:aSelectedElement xScale:xScale yScale:yScale];
        }
        else if ([elementName isEqualToString:@"foreignObject"] == YES)
        {
            [self scaleRectElement:aSelectedElement xScale:xScale yScale:yScale];
        }
    }
}

//==================================================================================
//	scalePathElement:scaleX:scaleY:
//==================================================================================

- (void)scalePathElement:(NSMutableDictionary *)pathElementDictionary xScale:(float)xScale yScale:(float)yScale
{
    NSXMLElement * pathElement = pathElementDictionary[@"xmlElement"];

    NSXMLNode * pathAttributeNode = [pathElement attributeForName:@"d"];
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [transformElementsDialog.macSVGPluginCallbacks buildPathSegmentsArrayWithPathString:pathAttributeString];
    
    NSMutableArray * rotatedSegmentsArray = [transformElementsDialog.macSVGPluginCallbacks
            scalePathCoordinatesWithPathSegmentsArray:pathSegmentsArray scaleX:xScale scaleY:yScale];

    NSXMLNode * strokeWidthAttributeNode = [pathElement attributeForName:@"stroke-width"];
    NSString * strokeWidthAttributeString = strokeWidthAttributeNode.stringValue;
    float strokeWidth = strokeWidthAttributeString.floatValue;

    float newStrokeWidth = strokeWidth * xScale;

    strokeWidthAttributeString = [transformElementsDialog allocPxString:newStrokeWidth];

    strokeWidthAttributeNode.stringValue = strokeWidthAttributeString;
    
    DOMElement * domPathElement = pathElementDictionary[@"domElement"];

    [domPathElement setAttribute:@"stroke-width" value:strokeWidthAttributeString];

    [self updatePathElement:pathElementDictionary withPathSegmentsArray:rotatedSegmentsArray];
}

//==================================================================================
//	scaleRectElement:scaleX:scaleY:
//==================================================================================

- (void)scaleRectElement:(NSMutableDictionary *)rectElementDictionary xScale:(float)xScale yScale:(float)yScale
{
    NSXMLElement * rectElement = rectElementDictionary[@"xmlElement"];
    DOMElement * domRectElement = rectElementDictionary[@"domElement"];
    
    NSXMLNode * xAttributeNode = [rectElement attributeForName:@"x"];
    NSString * xAttributeString = xAttributeNode.stringValue;
    float x = xAttributeString.floatValue;
    
    NSXMLNode * yAttributeNode = [rectElement attributeForName:@"y"];
    NSString * yAttributeString = yAttributeNode.stringValue;
    float y = yAttributeString.floatValue;
    
    NSXMLNode * widthAttributeNode = [rectElement attributeForName:@"width"];
    NSString * widthAttributeString = widthAttributeNode.stringValue;
    float width = widthAttributeString.floatValue;
    
    NSXMLNode * heightAttributeNode = [rectElement attributeForName:@"height"];
    NSString * heightAttributeString = heightAttributeNode.stringValue;
    float height = heightAttributeString.floatValue;

    NSXMLNode * strokeWidthAttributeNode = [rectElement attributeForName:@"stroke-width"];
    NSString * strokeWidthAttributeString = strokeWidthAttributeNode.stringValue;
    float strokeWidth = strokeWidthAttributeString.floatValue;

    float newX = x * xScale;
    float newY = y * yScale;
    float newWidth = width * xScale;
    float newHeight = height * yScale;
    float newStrokeWidth = strokeWidth * xScale;
    
    xAttributeString = [transformElementsDialog allocPxString:newX];
    yAttributeString = [transformElementsDialog allocPxString:newY];
    widthAttributeString = [transformElementsDialog allocPxString:newWidth];
    heightAttributeString = [transformElementsDialog allocPxString:newHeight];
    strokeWidthAttributeString = [transformElementsDialog allocPxString:newStrokeWidth];
    
    xAttributeNode.stringValue = xAttributeString;
    yAttributeNode.stringValue = yAttributeString;
    widthAttributeNode.stringValue = widthAttributeString;
    heightAttributeNode.stringValue = heightAttributeString;
    strokeWidthAttributeNode.stringValue = strokeWidthAttributeString;
    
    [domRectElement setAttribute:@"x" value:xAttributeString];
    [domRectElement setAttribute:@"y" value:yAttributeString];
    [domRectElement setAttribute:@"width" value:widthAttributeString];
    [domRectElement setAttribute:@"height" value:heightAttributeString];
    [domRectElement setAttribute:@"stroke-width" value:strokeWidthAttributeString];
}

//==================================================================================
//	scaleCircleElement:scaleX:scaleY:
//==================================================================================

- (void)scaleCircleElement:(NSMutableDictionary *)circleElementDictionary xScale:(float)xScale yScale:(float)yScale
{
    NSXMLElement * circleElement = circleElementDictionary[@"xmlElement"];
    DOMElement * domCircleElement = circleElementDictionary[@"domElement"];
    
    NSXMLNode * cxAttributeNode = [circleElement attributeForName:@"cx"];
    NSString * cxAttributeString = cxAttributeNode.stringValue;
    float cx = cxAttributeString.floatValue;
    
    NSXMLNode * cyAttributeNode = [circleElement attributeForName:@"cy"];
    NSString * cyAttributeString = cyAttributeNode.stringValue;
    float cy = cyAttributeString.floatValue;
    
    NSXMLNode * rAttributeNode = [circleElement attributeForName:@"r"];
    NSString * rAttributeString = rAttributeNode.stringValue;
    float r = rAttributeString.floatValue;

    NSXMLNode * strokeWidthAttributeNode = [circleElement attributeForName:@"stroke-width"];
    NSString * strokeWidthAttributeString = strokeWidthAttributeNode.stringValue;
    float strokeWidth = strokeWidthAttributeString.floatValue;
    
    float newCX = cx * xScale;
    float newCY = cy * yScale;
    float newR = r * xScale;
    float newStrokeWidth = strokeWidth * xScale;
    
    cxAttributeString = [transformElementsDialog allocPxString:newCX];
    cyAttributeString = [transformElementsDialog allocPxString:newCY];
    rAttributeString = [transformElementsDialog allocPxString:newR];
    strokeWidthAttributeString = [transformElementsDialog allocPxString:newStrokeWidth];
    
    cxAttributeNode.stringValue = cxAttributeString;
    cyAttributeNode.stringValue = cyAttributeString;
    rAttributeNode.stringValue = rAttributeString;
    strokeWidthAttributeNode.stringValue = strokeWidthAttributeString;
    
    [domCircleElement setAttribute:@"cx" value:cxAttributeString];
    [domCircleElement setAttribute:@"cy" value:cyAttributeString];
    [domCircleElement setAttribute:@"r" value:rAttributeString];
    [domCircleElement setAttribute:@"stroke-width" value:strokeWidthAttributeString];
}

//==================================================================================
//	scaleEllipseElement:scaleX:scaleY:
//==================================================================================

- (void)scaleEllipseElement:(NSMutableDictionary *)ellipseElementDictionary xScale:(float)xScale yScale:(float)yScale
{
    NSXMLElement * ellipseElement = ellipseElementDictionary[@"xmlElement"];
    DOMElement * domEllipseElement = ellipseElementDictionary[@"domElement"];
    
    NSXMLNode * cxAttributeNode = [ellipseElement attributeForName:@"cx"];
    NSString * cxAttributeString = cxAttributeNode.stringValue;
    float cx = cxAttributeString.floatValue;
    
    NSXMLNode * cyAttributeNode = [ellipseElement attributeForName:@"cy"];
    NSString * cyAttributeString = cyAttributeNode.stringValue;
    float cy = cyAttributeString.floatValue;
    
    NSXMLNode * rxAttributeNode = [ellipseElement attributeForName:@"rx"];
    NSString * rxAttributeString = rxAttributeNode.stringValue;
    float rx = rxAttributeString.floatValue;
    
    NSXMLNode * ryAttributeNode = [ellipseElement attributeForName:@"ry"];
    NSString * ryAttributeString = ryAttributeNode.stringValue;
    float ry = ryAttributeString.floatValue;

    NSXMLNode * strokeWidthAttributeNode = [ellipseElement attributeForName:@"stroke-width"];
    NSString * strokeWidthAttributeString = strokeWidthAttributeNode.stringValue;
    float strokeWidth = strokeWidthAttributeString.floatValue;
    
    float newCX = cx * xScale;
    float newCY = cy * yScale;
    float newRX = rx * xScale;
    float newRY = ry * yScale;
    float newStrokeWidth = strokeWidth * xScale;
    
    cxAttributeString = [transformElementsDialog allocPxString:newCX];
    cyAttributeString = [transformElementsDialog allocPxString:newCY];
    rxAttributeString = [transformElementsDialog allocPxString:newRX];
    ryAttributeString = [transformElementsDialog allocPxString:newRY];
    strokeWidthAttributeString = [transformElementsDialog allocPxString:newStrokeWidth];
    
    cxAttributeNode.stringValue = cxAttributeString;
    cyAttributeNode.stringValue = cyAttributeString;
    rxAttributeNode.stringValue = rxAttributeString;
    ryAttributeNode.stringValue = ryAttributeString;
    strokeWidthAttributeNode.stringValue = strokeWidthAttributeString;
    
    [domEllipseElement setAttribute:@"cx" value:cxAttributeString];
    [domEllipseElement setAttribute:@"cy" value:cyAttributeString];
    [domEllipseElement setAttribute:@"rx" value:rxAttributeString];
    [domEllipseElement setAttribute:@"ry" value:ryAttributeString];
    [domEllipseElement setAttribute:@"stroke-width" value:strokeWidthAttributeString];
}

//==================================================================================
//	scalePolylineElement:scaleX:scaleY:
//==================================================================================

- (void)scalePolylineElement:(NSMutableDictionary *)polylineElementDictionary xScale:(float)xScale yScale:(float)yScale
{
    NSXMLElement * polylineElement = polylineElementDictionary[@"xmlElement"];

    NSXMLNode * pointsAttributeNode = [polylineElement attributeForName:@"points"];
    NSString * pointsAttributeString = pointsAttributeNode.stringValue;

    NSCharacterSet * pointsCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" ,"];
    
    NSArray * pointsComponents = [pointsAttributeString componentsSeparatedByCharactersInSet:pointsCharacterSet];
    
    NSMutableArray * pointsArray = [[NSMutableArray alloc] init];
    
    for (NSString * aString in pointsComponents)
    {
        if ([aString isEqualToString:@""] == NO)
        {
            [pointsArray addObject:aString];
        }
    }
    
    NSUInteger pointsArrayCount = pointsArray.count;

    NSMutableString * newPointsString = [[NSMutableString alloc] init];
    
    for (int i = 0; i < pointsArrayCount; i+=2) 
    {
        NSString * xString = pointsArray[i];
        NSString * yString = pointsArray[(i + 1)];
        
        float x = xString.floatValue;
        float y = yString.floatValue;
        
        x = x * xScale;
        y = y * yScale;
        
        xString = [transformElementsDialog allocFloatString:x];
        yString = [transformElementsDialog allocFloatString:y];
        
        if (i > 0) 
        {
            [newPointsString appendString:@" "];
        }
        
        [newPointsString appendString:xString];
        [newPointsString appendString:@","];
        [newPointsString appendString:yString];
    }

    pointsAttributeNode.stringValue = newPointsString;

    NSXMLNode * strokeWidthAttributeNode = [polylineElement attributeForName:@"stroke-width"];
    NSString * strokeWidthAttributeString = strokeWidthAttributeNode.stringValue;
    float strokeWidth = strokeWidthAttributeString.floatValue;

    float newStrokeWidth = strokeWidth * xScale;

    strokeWidthAttributeString = [transformElementsDialog allocPxString:newStrokeWidth];

    strokeWidthAttributeNode.stringValue = strokeWidthAttributeString;
    
    DOMElement * domPolylineElement = polylineElementDictionary[@"domElement"];

    [domPolylineElement setAttribute:@"points" value:newPointsString];
    [domPolylineElement setAttribute:@"stroke-width" value:strokeWidthAttributeString];
}

//==================================================================================
//	scaleLineElement:scaleX:scaleY:
//==================================================================================

- (void)scaleLineElement:(NSMutableDictionary *)lineElementDictionary xScale:(float)xScale yScale:(float)yScale
{
    NSXMLElement * lineElement = lineElementDictionary[@"xmlElement"];
    DOMElement * domLineElement = lineElementDictionary[@"domElement"];
    
    NSXMLNode * x1AttributeNode = [lineElement attributeForName:@"x1"];
    NSString * x1AttributeString = x1AttributeNode.stringValue;
    float x1 = x1AttributeString.floatValue;
    
    NSXMLNode * y1AttributeNode = [lineElement attributeForName:@"y1"];
    NSString * y1AttributeString = y1AttributeNode.stringValue;
    float y1 = y1AttributeString.floatValue;
    
    NSXMLNode * x2AttributeNode = [lineElement attributeForName:@"x2"];
    NSString * x2AttributeString = x2AttributeNode.stringValue;
    float x2 = x2AttributeString.floatValue;
    
    NSXMLNode * y2AttributeNode = [lineElement attributeForName:@"y2"];
    NSString * y2AttributeString = y2AttributeNode.stringValue;
    float y2 = y2AttributeString.floatValue;

    NSXMLNode * strokeWidthAttributeNode = [lineElement attributeForName:@"stroke-width"];
    NSString * strokeWidthAttributeString = strokeWidthAttributeNode.stringValue;
    float strokeWidth = strokeWidthAttributeString.floatValue;
    
    float newX1 = x1 * xScale;
    float newY1 = y1 * yScale;
    float newX2 = x2 * xScale;
    float newY2 = y2 * yScale;
    float newStrokeWidth = strokeWidth * xScale;
    
    x1AttributeString = [transformElementsDialog allocPxString:newX1];
    y1AttributeString = [transformElementsDialog allocPxString:newY1];
    x2AttributeString = [transformElementsDialog allocPxString:newX2];
    y2AttributeString = [transformElementsDialog allocPxString:newY2];
    strokeWidthAttributeString = [transformElementsDialog allocPxString:newStrokeWidth];
    
    x1AttributeNode.stringValue = x1AttributeString;
    y1AttributeNode.stringValue = y1AttributeString;
    x2AttributeNode.stringValue = x2AttributeString;
    y2AttributeNode.stringValue = y2AttributeString;
    strokeWidthAttributeNode.stringValue = strokeWidthAttributeString;
    
    [domLineElement setAttribute:@"x1" value:x1AttributeString];
    [domLineElement setAttribute:@"y1" value:y1AttributeString];
    [domLineElement setAttribute:@"x2" value:x2AttributeString];
    [domLineElement setAttribute:@"y2" value:y2AttributeString];
    [domLineElement setAttribute:@"stroke-width" value:strokeWidthAttributeString];
}

//==================================================================================
//	scaleTextElement:scaleX:scaleY:
//==================================================================================

- (void)scaleTextElement:(NSMutableDictionary *)textElementDictionary xScale:(float)xScale yScale:(float)yScale
{
    NSXMLElement * textElement = textElementDictionary[@"xmlElement"];
    DOMElement * domTextElement = textElementDictionary[@"domElement"];
    
    NSXMLNode * xAttributeNode = [textElement attributeForName:@"x"];
    NSString * xAttributeString = xAttributeNode.stringValue;
    float x = xAttributeString.floatValue;
    
    NSXMLNode * yAttributeNode = [textElement attributeForName:@"y"];
    NSString * yAttributeString = yAttributeNode.stringValue;
    float y = yAttributeString.floatValue;
    
    NSXMLNode * fontSizeAttributeNode = [textElement attributeForName:@"font-size"];
    NSString * fontSizeAttributeString = fontSizeAttributeNode.stringValue;
    float fontSize = fontSizeAttributeString.floatValue;
    
    float newX = x * xScale;
    float newY = y * yScale;
    float newFontSize = fontSize * xScale;
    
    xAttributeString = [transformElementsDialog allocPxString:newX];
    yAttributeString = [transformElementsDialog allocPxString:newY];
    fontSizeAttributeString = [transformElementsDialog allocPxString:newFontSize];
    
    xAttributeNode.stringValue = xAttributeString;
    yAttributeNode.stringValue = yAttributeString;
    fontSizeAttributeNode.stringValue = fontSizeAttributeString;
    
    [domTextElement setAttribute:@"x" value:xAttributeString];
    [domTextElement setAttribute:@"y" value:yAttributeString];
    [domTextElement setAttribute:@"font-size" value:fontSizeAttributeString];

    NSXMLNode * strokeWidthAttributeNode = [textElement attributeForName:@"stroke-width"];
    if (strokeWidthAttributeNode != NULL)
    {
        NSString * strokeWidthAttributeString = strokeWidthAttributeNode.stringValue;
        float strokeWidth = strokeWidthAttributeString.floatValue;

        float newStrokeWidth = strokeWidth * xScale;

        strokeWidthAttributeString = [transformElementsDialog allocPxString:newStrokeWidth];

        strokeWidthAttributeNode.stringValue = strokeWidthAttributeString;
        
        [domTextElement setAttribute:@"stroke-width" value:strokeWidthAttributeString];
    }
}

//==================================================================================
//	rotateSelectedElementsWithCenterX:centerY:degrees:
//==================================================================================

- (void)rotateSelectedElementsWithCenterX:(float)centerX centerY:(float)centerY degrees:(float)degrees
{
    NSMutableArray * selectedElementsArray = (transformElementsDialog.macSVGPluginCallbacks).selectedElementsArray;
    
    for (id aSelectedElement in selectedElementsArray)
    {
        NSXMLElement * aSelectedXMLElement = aSelectedElement[@"xmlElement"];
        
        NSString * elementName = aSelectedXMLElement.name;
        
        if ([elementName isEqualToString:@"path"] == YES)
        {
            [self rotatePathElement:aSelectedElement centerX:centerX centerY:centerY degrees:degrees];
        }
        else if ([elementName isEqualToString:@"rect"] == YES)
        {
            [self rotateRectElement:aSelectedElement centerX:centerX centerY:centerY degrees:degrees];
        }
        else if ([elementName isEqualToString:@"circle"] == YES)
        {
            [self rotateCircleElement:aSelectedElement centerX:centerX centerY:centerY degrees:degrees];
        }
        else if ([elementName isEqualToString:@"ellipse"] == YES)
        {
            [self rotateEllipseElement:aSelectedElement centerX:centerX centerY:centerY degrees:degrees];
        }
        else if ([elementName isEqualToString:@"polyline"] == YES)
        {
            [self rotatePolylineElement:aSelectedElement centerX:centerX centerY:centerY degrees:degrees];
        }
        else if ([elementName isEqualToString:@"polygon"] == YES)
        {
            [self rotatePolylineElement:aSelectedElement centerX:centerX centerY:centerY degrees:degrees];
        }
        else if ([elementName isEqualToString:@"line"] == YES)
        {
            [self rotateLineElement:aSelectedElement centerX:centerX centerY:centerY degrees:degrees];
        }
    }
}

//==================================================================================
//	rotatePathElement:centerX:centerY:degrees:
//==================================================================================

- (void)rotatePathElement:(NSMutableDictionary *)pathElementDictionary centerX:(float)centerX centerY:(float)centerY degrees:(float)degrees
{
    NSXMLElement * pathElement = pathElementDictionary[@"xmlElement"];

    NSXMLNode * pathAttributeNode = [pathElement attributeForName:@"d"];
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [transformElementsDialog.macSVGPluginCallbacks buildPathSegmentsArrayWithPathString:pathAttributeString];
    
    NSMutableArray * rotatedSegmentsArray = [transformElementsDialog.macSVGPluginCallbacks
            rotatePathCoordinatesWithPathSegmentsArray:pathSegmentsArray
            x:centerX y:centerY degrees:degrees];

    [self updatePathElement:pathElementDictionary withPathSegmentsArray:rotatedSegmentsArray];
}

//==================================================================================
//	updatePathElement:withPathSegmentsArray:
//==================================================================================

- (void)updatePathElement:(NSMutableDictionary *)pathElementDictionary withPathSegmentsArray:(NSMutableArray *)aPathSegmentsArray
{
    NSXMLElement * pathElement = pathElementDictionary[@"xmlElement"];

    NSXMLElement * holdSelectedPathElement = (transformElementsDialog.macSVGPluginCallbacks).svgPathEditorSelectedPathElement;

    [transformElementsDialog.macSVGPluginCallbacks svgPathEditorSetSelectedPathElement:pathElement];
    
    (transformElementsDialog.macSVGPluginCallbacks).pathSegmentsArray = aPathSegmentsArray;

    [transformElementsDialog.macSVGPluginCallbacks updateSelectedPathInDOM:NO];

    [transformElementsDialog.macSVGPluginCallbacks svgPathEditorSetSelectedPathElement:holdSelectedPathElement];
}

//==================================================================================
//	rotateCircleElement:centerX:centerY:degrees:
//==================================================================================

- (void)rotateCircleElement:(NSMutableDictionary *)circleElementDictionary centerX:(float)centerX centerY:(float)centerY degrees:(float)degrees
{
    NSXMLElement * circleElement = circleElementDictionary[@"xmlElement"];

    NSXMLNode * cxAttributeNode = [circleElement attributeForName:@"cx"];
    NSString * cxAttributeString = cxAttributeNode.stringValue;
    float cx = cxAttributeString.floatValue;
    
    NSXMLNode * cyAttributeNode = [circleElement attributeForName:@"cy"];
    NSString * cyAttributeString = cyAttributeNode.stringValue;
    float cy = cyAttributeString.floatValue;
    
    CGPoint circlePoint = CGPointMake(cx, cy);
    CGPoint rotationPoint = CGPointMake(centerX, centerY);
    
    CGPoint rotatedPoint = [self rotatePoint:circlePoint
            centerPoint:rotationPoint degrees:degrees];
    
    cxAttributeString = [transformElementsDialog allocPxString:rotatedPoint.x];
    cyAttributeString = [transformElementsDialog allocPxString:rotatedPoint.y];
    
    cxAttributeNode.stringValue = cxAttributeString;
    cyAttributeNode.stringValue = cyAttributeString;

    DOMElement * domCircleElement = circleElementDictionary[@"domElement"];

    [domCircleElement setAttribute:@"cx" value:cxAttributeString];
    [domCircleElement setAttribute:@"cy" value:cyAttributeString];
}

//==================================================================================
//	rotateEllipseElement:centerX:centerY:degrees:
//==================================================================================

- (void)rotateEllipseElement:(NSMutableDictionary *)elementDictionary
        centerX:(float)centerX centerY:(float)centerY degrees:(float)degrees
{
    // convert rect element to a path element with four cubic beziers

    NSXMLElement * ellipseElement = elementDictionary[@"xmlElement"];
    DOMElement * domEllipseElement = elementDictionary[@"domElement"];
    
    NSXMLNode * cxAttributeNode = [ellipseElement attributeForName:@"cx"];
    NSString * cxAttributeString = cxAttributeNode.stringValue;
    float cx = cxAttributeString.floatValue;
    
    NSXMLNode * cyAttributeNode = [ellipseElement attributeForName:@"cy"];
    NSString * cyAttributeString = cyAttributeNode.stringValue;
    float cy = cyAttributeString.floatValue;
    
    NSXMLNode * rxAttributeNode = [ellipseElement attributeForName:@"rx"];
    NSString * rxAttributeString = rxAttributeNode.stringValue;
    float rx = rxAttributeString.floatValue;
    
    NSXMLNode * ryAttributeNode = [ellipseElement attributeForName:@"ry"];
    NSString * ryAttributeString = ryAttributeNode.stringValue;
    float ry = ryAttributeString.floatValue;
    
    float rxDiv2 = rx / 2.0f;
    float ryDiv2 = ry / 2.0f;
    
    NSString * pathString = [NSString stringWithFormat:@"M %f,%f C %f,%f %f,%f %f,%f C %f,%f %f,%f %f,%f C %f,%f %f,%f %f,%f C %f,%f %f,%f %f,%f Z",
            cx, cy - ry,    // moveto top of ellipse
            cx + rxDiv2, cy - ry, cx + rx, cy - ryDiv2, cx + rx, cy,    // top right curve
            cx + rx, cy + ryDiv2, cx + rxDiv2, cy + ry, cx, cy + ry,         // bottom right curve
            cx - rxDiv2, cy + ry, cx - rx, cy + ryDiv2, cx - rx, cy,        // bottom left curve
            cx - rx, cy - ryDiv2, cx - rxDiv2, cy - ry, cx, cy - ry     // top left curve
            ];

    ellipseElement.name = @"path";
    [ellipseElement removeAttributeForName:@"cx"];
    [ellipseElement removeAttributeForName:@"cy"];
    [ellipseElement removeAttributeForName:@"rx"];
    [ellipseElement removeAttributeForName:@"ry"];
    
    NSXMLNode * pathAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    pathAttributeNode.name = @"d";
    pathAttributeNode.stringValue = pathString;
    [ellipseElement addAttribute:pathAttributeNode];
    
    SVGWebKitController * svgWebKitController = (transformElementsDialog.macSVGPluginCallbacks).svgWebKitController;
    
    DOMDocument * domDocument = (svgWebKitController.svgWebView).mainFrame.DOMDocument;
    
    DOMElement * newDOMPathElement = [domDocument createElementNS:svgNamespace
            qualifiedName:@"path"];
    
    NSArray * xmlAttributesArray = ellipseElement.attributes;
    for (NSXMLNode * attributeNode in xmlAttributesArray)
    {
        NSString * attributeName = attributeNode.name;
        NSString * attributeValue = attributeNode.stringValue;
        
        attributeName = [attributeName copy];
        attributeValue = [attributeValue copy];
        
        [newDOMPathElement setAttribute:attributeName value:attributeValue];
    }

    DOMElement * parentElement = domEllipseElement.parentElement;

    [parentElement replaceChild:newDOMPathElement oldChild:domEllipseElement];
    
    elementDictionary[@"domElement"] = newDOMPathElement;
    
    [self rotatePathElement:elementDictionary centerX:centerX centerY:centerY degrees:degrees];
}

//==================================================================================
//	rotateRectElement:centerX:centerY:degrees:
//==================================================================================

- (void)rotateRectElement:(NSMutableDictionary *)elementDictionary
        centerX:(float)centerX centerY:(float)centerY degrees:(float)degrees
{
    // convert rect element to a path element
    
    NSXMLElement * rectElement = elementDictionary[@"xmlElement"];
    DOMElement * domRectElement = elementDictionary[@"domElement"];
    
    NSXMLNode * xAttributeNode = [rectElement attributeForName:@"x"];
    NSString * xAttributeString = xAttributeNode.stringValue;
    float x = xAttributeString.floatValue;
    
    NSXMLNode * yAttributeNode = [rectElement attributeForName:@"y"];
    NSString * yAttributeString = yAttributeNode.stringValue;
    float y = yAttributeString.floatValue;
    
    NSXMLNode * widthAttributeNode = [rectElement attributeForName:@"width"];
    NSString * widthAttributeString = widthAttributeNode.stringValue;
    float width = widthAttributeString.floatValue;
    
    NSXMLNode * heightAttributeNode = [rectElement attributeForName:@"height"];
    NSString * heightAttributeString = heightAttributeNode.stringValue;
    float height = heightAttributeString.floatValue;
    
    NSString * pathString = [NSString stringWithFormat:@"M %f,%f L %f,%f L %f,%f L %f,%f L %f,%f Z",
            x, y,
            (x + width), y,
            (x + width), (y + height),
            x, (y + height),
            x, y];

    rectElement.name = @"path";
    [rectElement removeAttributeForName:@"x"];
    [rectElement removeAttributeForName:@"y"];
    [rectElement removeAttributeForName:@"width"];
    [rectElement removeAttributeForName:@"height"];
    
    NSXMLNode * pathAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    pathAttributeNode.name = @"d";
    pathAttributeNode.stringValue = pathString;
    [rectElement addAttribute:pathAttributeNode];
    
    SVGWebKitController * svgWebKitController = (transformElementsDialog.macSVGPluginCallbacks).svgWebKitController;
    
    DOMDocument * domDocument = (svgWebKitController.svgWebView).mainFrame.DOMDocument;
    
    DOMElement * newDOMPathElement = [domDocument createElementNS:svgNamespace
            qualifiedName:@"path"];
    
    NSArray * xmlAttributesArray = rectElement.attributes;
    for (NSXMLNode * attributeNode in xmlAttributesArray)
    {
        NSString * attributeName = attributeNode.name;
        NSString * attributeValue = attributeNode.stringValue;
        
        attributeName = [attributeName copy];
        attributeValue = [attributeValue copy];
        
        [newDOMPathElement setAttribute:attributeName value:attributeValue];
    }

    DOMElement * parentElement = domRectElement.parentElement;

    [parentElement replaceChild:newDOMPathElement oldChild:domRectElement];
    
    elementDictionary[@"domElement"] = newDOMPathElement;
    
    [self rotatePathElement:elementDictionary centerX:centerX centerY:centerY degrees:degrees];
}

//==================================================================================
//	rotatePolylineElement:centerX:centerY:degrees:
//==================================================================================

- (void)rotatePolylineElement:(NSMutableDictionary *)polylineElementDictionary centerX:(float)centerX centerY:(float)centerY degrees:(float)degrees
{
    NSXMLElement * polylineElement = polylineElementDictionary[@"xmlElement"];

    NSXMLNode * pointsAttributeNode = [polylineElement attributeForName:@"points"];
    NSString * pointsAttributeString = pointsAttributeNode.stringValue;

    NSCharacterSet * pointsCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" ,"];
    
    NSArray * pointsComponents = [pointsAttributeString componentsSeparatedByCharactersInSet:pointsCharacterSet];
    
    NSMutableArray * pointsArray = [[NSMutableArray alloc] init];
    
    for (NSString * aString in pointsComponents)
    {
        if ([aString isEqualToString:@""] == NO)
        {
            [pointsArray addObject:aString];
        }
    }
    
    NSUInteger pointsArrayCount = pointsArray.count;

    NSMutableString * newPointsString = [[NSMutableString alloc] init];
    
    for (int i = 0; i < pointsArrayCount; i+=2) 
    {
        NSString * xString = pointsArray[i];
        NSString * yString = pointsArray[(i + 1)];
        
        float x = xString.floatValue;
        float y = yString.floatValue;
        
        CGPoint polylinePoint = CGPointMake(x, y);
        CGPoint rotationPoint = CGPointMake(centerX, centerY);

        CGPoint rotatedPoint = [self rotatePoint:polylinePoint
                centerPoint:rotationPoint degrees:degrees];
        
        xString = [transformElementsDialog allocFloatString:rotatedPoint.x];
        yString = [transformElementsDialog allocFloatString:rotatedPoint.y];
        
        if (i > 0) 
        {
            [newPointsString appendString:@" "];
        }
        
        [newPointsString appendString:xString];
        [newPointsString appendString:@","];
        [newPointsString appendString:yString];
    }

    pointsAttributeNode.stringValue = newPointsString;
    
    DOMElement * domCircleElement = polylineElementDictionary[@"domElement"];

    [domCircleElement setAttribute:@"points" value:newPointsString];
}

//==================================================================================
//	rotateLineElement:centerX:centerY:degrees:
//==================================================================================

- (void)rotateLineElement:(NSMutableDictionary *)lineElementDictionary centerX:(float)centerX centerY:(float)centerY degrees:(float)degrees
{
    NSXMLElement * lineElement = lineElementDictionary[@"xmlElement"];

    NSXMLNode * x1AttributeNode = [lineElement attributeForName:@"x1"];
    NSString * x1AttributeString = x1AttributeNode.stringValue;
    float x1 = x1AttributeString.floatValue;

    NSXMLNode * y1AttributeNode = [lineElement attributeForName:@"y1"];
    NSString * y1AttributeString = y1AttributeNode.stringValue;
    float y1 = y1AttributeString.floatValue;

    NSXMLNode * x2AttributeNode = [lineElement attributeForName:@"x2"];
    NSString * x2AttributeString = x2AttributeNode.stringValue;
    float x2 = x2AttributeString.floatValue;

    NSXMLNode * y2AttributeNode = [lineElement attributeForName:@"y2"];
    NSString * y2AttributeString = y2AttributeNode.stringValue;
    float y2 = y2AttributeString.floatValue;

    CGPoint xy1Point = CGPointMake(x1, y1);
    CGPoint xy2Point = CGPointMake(x2, y2);
    CGPoint rotationPoint = CGPointMake(centerX, centerY);

    CGPoint rotatedXY1Point = [self rotatePoint:xy1Point
            centerPoint:rotationPoint degrees:degrees];
    CGPoint rotatedXY2Point = [self rotatePoint:xy2Point
            centerPoint:rotationPoint degrees:degrees];
    
    x1AttributeString = [transformElementsDialog allocPxString:rotatedXY1Point.x];
    y1AttributeString = [transformElementsDialog allocPxString:rotatedXY1Point.y];
    x2AttributeString = [transformElementsDialog allocPxString:rotatedXY2Point.x];
    y2AttributeString = [transformElementsDialog allocPxString:rotatedXY2Point.y];
    
    x1AttributeNode.stringValue = x1AttributeString;
    y1AttributeNode.stringValue = y1AttributeString;
    x2AttributeNode.stringValue = x2AttributeString;
    y2AttributeNode.stringValue = y2AttributeString;
    
    DOMElement * domLineElement = lineElementDictionary[@"domElement"];

    [domLineElement setAttribute:@"x1" value:x1AttributeString];
    [domLineElement setAttribute:@"y1" value:y1AttributeString];
    [domLineElement setAttribute:@"x2" value:x2AttributeString];
    [domLineElement setAttribute:@"y2" value:y2AttributeString];
}

//==================================================================================
//	rotatePoint:centerPoint:degrees:
//==================================================================================

- (CGPoint)rotatePoint:(CGPoint)aPoint centerPoint:(CGPoint)centerPoint degrees:(float)degrees
{
    double radians = degrees * (M_PI / 180.0f);

    float s = sinf(radians);
    float c = cosf(radians);

    CGPoint translatePoint = aPoint;
    translatePoint.x -= centerPoint.x;
    translatePoint.y -= centerPoint.y;
    
    float rotX = (translatePoint.x * c) - (translatePoint.y * s);
    float rotY = (translatePoint.x * s) + (translatePoint.y * c);
    
    CGPoint result = CGPointZero;
    result.x = rotX + centerPoint.x;
    result.y = rotY + centerPoint.y;
    
    return result;
}

//==================================================================================
//	centerPointForElements:
//==================================================================================

- (CGPoint)centerPointForElements:(NSMutableArray *)selectedElements
{
    NSRect unionRect = NSZeroRect;

    for (NSMutableDictionary * selectedElementDictionary in selectedElements)
    {
        DOMNode * selectedDOMNode = selectedElementDictionary[@"domElement"];
    
        if (selectedDOMNode.nodeType == DOM_ELEMENT_NODE)
        {
            DOMElement * selectedDOMElement = (DOMElement *)selectedDOMNode;
            
            NSRect boundingBox = [transformElementsDialog.webKitInterface bBoxForDOMElement:selectedDOMElement];
            
            if (NSIsEmptyRect(boundingBox) == NO)
            {
                if (NSIsEmptyRect(unionRect) == YES)
                {
                    unionRect = boundingBox;
                }
                else
                {
                    unionRect = NSUnionRect(unionRect, boundingBox);
                }
            }
        }
    }

    CGPoint centerPoint = CGPointMake(NSMidX(unionRect), NSMidY(unionRect));
            
    return centerPoint;
}


@end


#pragma clang diagnostic pop
