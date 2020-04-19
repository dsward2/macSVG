//
//  SVGtoCoreGraphicsConverter.m
//  macSVG
//
//  Created by Douglas Ward on 7/25/16.
//
//

#import "SVGtoCoreGraphicsConverter.h"
#import "MacSVGDocumentWindowController.h"
#import "MacSVGDocument.h"
#import "SVGWebKitController.h"
#import "TextDocument.h"
#import "TextDocumentWindowController.h"
#import "MacSVGAppDelegate.h"
#import "WebKitInterface.h"
#import "WebKit/WebKit.h"
#import "JavaScriptCore/JavaScriptCore.h"
#import "PathSegment.h"

@implementation SVGtoCoreGraphicsConverter

//========================================================================================
// init
//========================================================================================

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self buildWebColorsArray];
        self.variableIndex = 0;
    }
    return self;
}


//========================================================================================
// indexVarName:
//========================================================================================

- (NSString *)indexVarName:(NSString *)baseVarName
{
    self.variableIndex++;

    NSString * resultString = [NSString stringWithFormat:@"%@%ld", baseVarName, self.variableIndex];
    
    return resultString;
}

//========================================================================================
// convertSVGXMLElementsToCoreGraphics:
//========================================================================================

- (NSString *)convertSVGXMLElementsToCoreGraphics:(NSArray *)svgElementsArray
{
    NSMutableString * resultString = [NSMutableString string];
    
    [resultString appendString:@"- (void)drawRect:(NSRect)dirtyRect {\n"];
    [resultString appendString:@"\t[super drawRect:dirtyRect];\n"];

    [resultString appendString:@"\t// ============================================\n"];
    [resultString appendString:@"\t// Common settings\n"];
    [resultString appendString:@"\tBOOL flipImage = NO;\n"];
    [resultString appendString:@"\tBOOL centerImage = NO;\n"];
    [resultString appendString:@"\tCGFloat translateX = 0.0f;\n"];
    [resultString appendString:@"\tCGFloat translateY = 0.0f;\n"];
    [resultString appendString:@"\tCGFloat scale = 1.0f;\n"];
    [resultString appendString:@"\tNSRect cellBounds = self.bounds;\n"];
    [resultString appendString:@"\tNSRect cellFrame = self.frame;\n"];
    [resultString appendString:@"\t// ============================================\n"];

    NSString * rectPathVar = [self indexVarName:@"rectPath"];
    [resultString appendFormat:@"\tNSBezierPath * %@ = [NSBezierPath bezierPathWithRect:cellBounds];\n", rectPathVar];
    
    NSString * rectColorVar = [self indexVarName:@"rectColor"];
    [resultString appendFormat:@"\tNSColor * %@ = [NSColor orangeColor];\n", rectColorVar];
    
    [resultString appendFormat:@"\t[%@ set];\n", rectColorVar];
    [resultString appendFormat:@"\t[%@ stroke];\n", rectPathVar];

    [resultString appendString:@"\tNSGraphicsContext * nsctx = [NSGraphicsContext currentContext];\n"];
    [resultString appendString:@"\tCGContextRef context = (CGContextRef)[nsctx graphicsPort];\n"];
    

    self.processedElementsSet = [NSMutableSet set];
    
    self.webBBox = NSZeroRect;

    if (svgElementsArray.count > 0)
    {
        for (NSXMLNode * aXMLNode in svgElementsArray)
        {
            NSXMLNodeKind nodeKind = aXMLNode.kind;
            
            if (nodeKind == NSXMLElementKind)
            {
                NSXMLElement * aXMLElement = (NSXMLElement *)aXMLNode;
                
                [self computeBounds:aXMLElement];
            }
        }
    }
    
    [resultString appendFormat:@"\tNSRect webBBox = NSMakeRect(%f, %f, %f, %f);\n",
            self.webBBox.origin.x, self.webBBox.origin.y,
            self.webBBox.size.width, self.webBBox.size.height];

    [resultString appendString:@"\tCGFloat hViewScale = cellFrame.size.width / (webBBox.size.width);\n"];
    [resultString appendString:@"\tCGFloat vViewScale = cellFrame.size.height / (webBBox.size.height);\n"];
    [resultString appendString:@"\tCGFloat viewScale = MIN(hViewScale, vViewScale);\n"];

    [resultString appendString:@"\tviewScale *= scale; \t// A good place to adjust scale relative to view\n"];

    self.processedElementsSet = [NSMutableSet set];

    if (svgElementsArray.count > 0)
    {
        for (NSXMLNode * aXMLNode in svgElementsArray)
        {
            NSXMLNodeKind nodeKind = aXMLNode.kind;
            
            if (nodeKind == NSXMLElementKind)
            {
                NSXMLElement * aXMLElement = (NSXMLElement *)aXMLNode;
                
                [self convertSVGXMLElement:aXMLElement resultString:resultString];
            }
        }
    }
    
    self.processedElementsSet = NULL;

    [resultString appendString:@"}\n"];

    TextDocument * textDocument = [TextDocument new];
    [textDocument makeWindowControllers];
    [[NSDocumentController sharedDocumentController] addDocument: textDocument];
    [textDocument showWindows];
    
    TextDocumentWindowController * aTextDocumentWindowController =
            textDocument.textDocumentWindowController;
    
    [aTextDocumentWindowController showWindow:self];
    
    if (textDocument == NULL)
    {
        NSLog(@"OpenUntitledTextDocument failed");
    }

    NSTextView * documentTextView = aTextDocumentWindowController.documentTextView;
    
    documentTextView.string = resultString;
    
    [textDocument showWindows];

    return resultString;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

//========================================================================================
// computeBounds:
//========================================================================================

- (void)computeBounds:(NSXMLElement *)svgElement
{
    if ([self.processedElementsSet member:svgElement] == NULL)
    {
        [self.processedElementsSet addObject:svgElement];

        MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)NSApp.delegate;
        WebKitInterface * webKitInterface = [macSVGAppDelegate webKitInterface];
        NSXMLNode * MacsvgidNode = [svgElement attributeForName:@"macsvgid"];
        if (MacsvgidNode != NULL)
        {
            NSString * macsvgid = MacsvgidNode.stringValue;
            DOMElement * domElement = [self.macSVGDocumentWindowController.svgWebKitController domElementForMacsvgid:macsvgid];
            if (domElement != NULL)
            {
                NSRect elementRect = [webKitInterface bBoxForDOMElement:domElement];
                
                if (NSIsEmptyRect(elementRect) == NO)
                {
                    if (NSIsEmptyRect(self.webBBox) == YES)
                    {
                        self.webBBox = elementRect;
                    }
                    else
                    {
                        NSXMLNode * strokeWidthAttributeNode = [svgElement attributeForName:@"stroke-width"];
                        if (strokeWidthAttributeNode != NULL)
                        {
                            NSString * strokeWidthString = strokeWidthAttributeNode.stringValue;
                            CGFloat strokeWidth = strokeWidthString.floatValue;
                            self.webBBox = NSInsetRect(self.webBBox, -(strokeWidth / 2.0f), -(strokeWidth / 2.0f));
                        }
                    
                        self.webBBox = NSUnionRect(self.webBBox, elementRect);
                    }

                    NSArray * childElementsArray = svgElement.children;
                    
                    for (NSXMLNode * childNode in childElementsArray)
                    {
                        NSXMLNodeKind kind = childNode.kind;
                        
                        if (kind == NSXMLElementKind)
                        {
                            NSXMLElement * childElement = (NSXMLElement *)childNode;
                            
                            [self computeBounds:childElement]; // recursive call
                        }
                    }
                }
            }
        }
    }
}

//========================================================================================
// convertSVGXMLElement:resultString:
//========================================================================================

- (NSString *)convertSVGXMLElement:(NSXMLElement *)svgElement resultString:(NSMutableString *)resultString
{
    if ([self.processedElementsSet member:svgElement] == NULL)
    {
        [self.processedElementsSet addObject:svgElement];
    
        [self insertSeparatorLine:resultString];

        NSString * svgElementXmlString = svgElement.XMLString;
        NSString * commentString = [NSString stringWithFormat:@"\t// SVG element: %@\n", svgElementXmlString];
        [resultString appendString:commentString];

        [resultString appendString:@"\tCGContextSaveGState(context);\n"];
        
        NSString * ctmMatrixVar = NULL;
        
        NSString * currenTransformVar = [self indexVarName:@"currentTransform"];
        [resultString appendFormat:@"\tCGAffineTransform %@ = CGAffineTransformIdentity;\n", currenTransformVar];
        
        NSXMLNode * MacsvgidNode = [svgElement attributeForName:@"macsvgid"];
        if (MacsvgidNode != NULL)
        {
            NSString * macsvgid = MacsvgidNode.stringValue;
            DOMElement * domElement = [self.macSVGDocumentWindowController.svgWebKitController domElementForMacsvgid:macsvgid];
            if (domElement != NULL)
            {
                id ctmMatrix = [domElement callWebScriptMethod:@"getCTM" withArguments:NULL];  // call JavaScript function
                
                if (ctmMatrix != NULL)
                {
                    NSString * ctmMatrixAString = [ctmMatrix valueForKey:@"a"];
                    NSString * ctmMatrixBString = [ctmMatrix valueForKey:@"b"];
                    NSString * ctmMatrixCString = [ctmMatrix valueForKey:@"c"];
                    NSString * ctmMatrixDString = [ctmMatrix valueForKey:@"d"];
                    NSString * ctmMatrixEString = [ctmMatrix valueForKey:@"e"];
                    NSString * ctmMatrixFString = [ctmMatrix valueForKey:@"f"];
                    
                    CGFloat ctmMatrixA = ctmMatrixAString.floatValue;
                    CGFloat ctmMatrixB = ctmMatrixBString.floatValue;
                    CGFloat ctmMatrixC = ctmMatrixCString.floatValue;
                    CGFloat ctmMatrixD = ctmMatrixDString.floatValue;
                    CGFloat ctmMatrixE = ctmMatrixEString.floatValue;
                    CGFloat ctmMatrixF = ctmMatrixFString.floatValue;

                    ctmMatrixVar = [self indexVarName:@"ctmMatrix"];
                    [resultString appendFormat:@"\tCGAffineTransform %@ = CGAffineTransformMake(%f, %f, %f, %f, %f, %f);\n",
                            ctmMatrixVar, ctmMatrixA, ctmMatrixB, ctmMatrixC, ctmMatrixD, ctmMatrixE, ctmMatrixF];
                    
                    [resultString appendFormat:@"\t%@ = CGAffineTransformConcat(%@, %@);\n", currenTransformVar, currenTransformVar, ctmMatrixVar];
                }
            }
        }

        NSString * svgElementName = svgElement.name;
        
        if ([svgElementName isEqualToString:@"rect"] == YES)
        {
            [self convertRectElement:svgElement currentTransformVar:currenTransformVar resultString:resultString];
        }
        else if ([svgElementName isEqualToString:@"circle"] == YES)
        {
            [self convertCircleElement:svgElement currentTransformVar:currenTransformVar resultString:resultString];
        }
        else if ([svgElementName isEqualToString:@"ellipse"] == YES)
        {
            [self convertEllipseElement:svgElement currentTransformVar:currenTransformVar resultString:resultString];
        }
        else if ([svgElementName isEqualToString:@"polyline"] == YES)
        {
            [self convertPolylineElement:svgElement currentTransformVar:currenTransformVar resultString:resultString];
        }
        else if ([svgElementName isEqualToString:@"polygon"] == YES)
        {
            [self convertPolygonElement:svgElement currentTransformVar:currenTransformVar resultString:resultString];
        }
        else if ([svgElementName isEqualToString:@"line"] == YES)
        {
            [self convertLineElement:svgElement currentTransformVar:currenTransformVar resultString:resultString];
        }
        else if ([svgElementName isEqualToString:@"path"] == YES)
        {
            [self convertPathElement:svgElement currentTransformVar:currenTransformVar resultString:resultString];
        }
        else if ([svgElementName isEqualToString:@"image"] == YES)
        {
        }
        else if ([svgElementName isEqualToString:@"text"] == YES)
        {
        }
        else if ([svgElementName isEqualToString:@"g"] == YES)
        {
        }
        else if ([svgElementName isEqualToString:@"use"] == YES)
        {
        }
        
        NSArray * childElementsArray = svgElement.children;

        [resultString appendString:@"\tCGContextRestoreGState(context);\n"];
        
        for (NSXMLNode * childNode in childElementsArray)
        {
            NSXMLNodeKind kind = childNode.kind;
            
            if (kind == NSXMLElementKind)
            {
                NSXMLElement * childElement = (NSXMLElement *)childNode;
                
                [self convertSVGXMLElement:childElement resultString:resultString]; // recursive call
            }
        }
    }
    
    return resultString;
}

#pragma clang diagnostic pop

//========================================================================================
// insertSeparatorLine:
//========================================================================================

- (void)insertSeparatorLine:(NSMutableString *)resultString
{
    [resultString appendString:@"\n\t//--------------------------------------------------------\n\n"];
}

//========================================================================================
// convertLineElement:resultString:
//========================================================================================

- (void)convertLineElement:(NSXMLElement *)svgElement currentTransformVar:(NSString *)currentTransformVar  resultString:(NSMutableString *)resultString
{
    NSString * linePathVar = [self indexVarName:@"linePath"];
    [resultString appendFormat:@"\tCGMutablePathRef %@ = CGPathCreateMutable();\n", linePathVar];

    NSXMLNode * x1AttributeNode = [svgElement attributeForName:@"x1"];
    NSXMLNode * y1AttributeNode = [svgElement attributeForName:@"y1"];
    NSXMLNode * x2AttributeNode = [svgElement attributeForName:@"x2"];
    NSXMLNode * y2AttributeNode = [svgElement attributeForName:@"y2"];

    NSString * x1String = x1AttributeNode.stringValue;
    NSString * y1String = y1AttributeNode.stringValue;
    NSString * x2String = x2AttributeNode.stringValue;
    NSString * y2String = y2AttributeNode.stringValue;
    
    CGFloat x1 = x1String.floatValue;
    CGFloat y1 = y1String.floatValue;
    CGFloat x2 = x2String.floatValue;
    CGFloat y2 = y2String.floatValue;
    
    NSString * x1VarName = [self indexVarName:@"x1_"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", x1VarName, x1];
    
    NSString * y1VarName = [self indexVarName:@"y1_"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", y1VarName, y1];
    
    NSString * x2VarName = [self indexVarName:@"x2_"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", x2VarName, x2];
    
    NSString * y2VarName = [self indexVarName:@"y2_"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", y2VarName, y2];
    
    NSString * movetoString = [NSString stringWithFormat:@"\tCGPathMoveToPoint(%@, NULL, %@, %@);\n", linePathVar, x1VarName, y1VarName];
    [resultString appendString:movetoString];

    NSString * linetoString = [NSString stringWithFormat:@"\tCGPathAddLineToPoint(%@, NULL, %@, %@);\n", linePathVar, x2VarName, y2VarName];
    [resultString appendString:linetoString];



    [self setStrokeWidthForElement:svgElement resultString:resultString pathVar:linePathVar];
    
    [self setStrokeColorForElement:svgElement resultString:resultString];
    
    [self setFillColorForElement:svgElement resultString:resultString];
    
    [self drawTransformedPath:svgElement pathVar:linePathVar currentTransformVar:currentTransformVar resultString:resultString];
    
    [resultString appendFormat:@"\tCGPathRelease(%@);\n", linePathVar];
}

//========================================================================================
// convertRectElement:resultString:
//========================================================================================

- (void)convertRectElement:(NSXMLElement *)svgElement
        currentTransformVar:(NSString *)currentTransformVar resultString:(NSMutableString *)resultString
{
    NSString * rectPathVar = [self indexVarName:@"rectPath"];
    [resultString appendFormat:@"\tCGMutablePathRef %@ = CGPathCreateMutable();\n", rectPathVar];

    NSXMLNode * xAttributeNode = [svgElement attributeForName:@"x"];
    NSXMLNode * yAttributeNode = [svgElement attributeForName:@"y"];
    NSXMLNode * widthAttributeNode = [svgElement attributeForName:@"width"];
    NSXMLNode * heightAttributeNode = [svgElement attributeForName:@"height"];
    NSXMLNode * rxAttributeNode = [svgElement attributeForName:@"rx"];
    NSXMLNode * ryAttributeNode = [svgElement attributeForName:@"ry"];

    NSString * xString = xAttributeNode.stringValue;
    NSString * yString = yAttributeNode.stringValue;
    NSString * widthString = widthAttributeNode.stringValue;
    NSString * heightString = heightAttributeNode.stringValue;
    NSString * rxString = @"0";
    if (rxAttributeNode != NULL)
    {
        rxString = rxAttributeNode.stringValue;
    }
    NSString * ryString = @"0";
    if (ryAttributeNode != NULL)
    {
        ryString = ryAttributeNode.stringValue;
    }

    CGFloat xFloat = xString.floatValue;
    CGFloat yFloat = yString.floatValue;
    CGFloat widthFloat = widthString.floatValue;
    CGFloat heightFloat = heightString.floatValue;
    CGFloat rxFloat = rxString.floatValue;
    CGFloat ryFloat = ryString.floatValue;
    #pragma unused(ryFloat)

    NSString * xVarName = [self indexVarName:@"x"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", xVarName, xFloat];
    NSString * yVarName = [self indexVarName:@"y"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", yVarName, yFloat];
    NSString * widthVarName = [self indexVarName:@"width"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", widthVarName, widthFloat];
    NSString * heightVarName = [self indexVarName:@"height"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", heightVarName, heightFloat];

    NSString * rxVarName = [self indexVarName:@"rx"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", rxVarName, rxFloat];
    NSString * ryVarName = [self indexVarName:@"ry"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", ryVarName, rxFloat];    // use rx for both h and v dimensions
    
    NSString * rectVar = [self indexVarName:@"rect"];
    NSString * rectString = [NSString stringWithFormat:@"\tCGRect %@ = CGRectMake(%@, %@, %@, %@);\n",
            rectVar, xVarName, yVarName, widthVarName, heightVarName];
    
    [resultString appendString:rectString];
    
    if ((rxFloat == 0.0f) && (rxFloat == 0.0f))
    {
        [resultString appendFormat:@"\tCGPathAddRect(%@, NULL, %@);\n", rectPathVar, rectVar];
    }
    else
    {
        // draw rectangle with rounded corners (using rx only for radius)
        NSString * radiusString = [NSString stringWithFormat:@"%f", rxFloat];
        NSString * radiusVarName = [self indexVarName:@"radius"];
        [resultString appendFormat:@"\tCGFloat %@ = %@;\n", radiusVarName, radiusString];

        // adapted from http://snipplr.com/view/8559/
        [resultString appendFormat:@"\tCGPathMoveToPoint(%@, NULL, %@.origin.x, %@.origin.y + %@);\n", rectPathVar, rectVar, rectVar, radiusVarName];
        
        [resultString appendFormat:@"\tCGPathAddLineToPoint(%@, NULL, %@.origin.x, %@.origin.y + %@.size.height - %@);\n",
                rectPathVar, rectVar, rectVar, rectVar, radiusVarName];
        
        //[resultString appendFormat:@"\tCGPathAddArc(%@, NULL, %@.origin.x + %@, %@.origin.y + %@.size.height - %@, %@, M_PI / 4, M_PI / 2, 1);\n",
        //        rectPathVar, rectVar, radiusVarName, rectVar, rectVar, radiusVarName, radiusVarName];

        [resultString appendFormat:@"\tCGPathAddArc(%@, NULL, %@.origin.x + %@, %@.origin.y + %@.size.height - %@, %@, M_PI, M_PI / 2, 1);\n",
                rectPathVar, rectVar, radiusVarName, rectVar, rectVar, radiusVarName, radiusVarName];
        
        [resultString appendFormat:@"\tCGPathAddLineToPoint(%@, NULL, %@.origin.x + %@.size.width - %@, %@.origin.y + %@.size.height);\n",
                rectPathVar, rectVar, rectVar, radiusVarName, rectVar, rectVar];
        
        [resultString appendFormat:@"\tCGPathAddArc(%@, NULL, %@.origin.x + %@.size.width - %@, %@.origin.y + %@.size.height - %@, %@, M_PI / 2, 0.0f, 1);\n",
                rectPathVar, rectVar, rectVar, radiusVarName, rectVar, rectVar, radiusVarName, radiusVarName];
         
        [resultString appendFormat:@"\tCGPathAddLineToPoint(%@, NULL, %@.origin.x + %@.size.width, %@.origin.y + %@);\n",
                rectPathVar, rectVar, rectVar, rectVar, radiusVarName];
        
        [resultString appendFormat:@"\tCGPathAddArc(%@, NULL, %@.origin.x + %@.size.width - %@, %@.origin.y + %@, %@, 0.0f, -M_PI / 2, 1);\n",
                rectPathVar, rectVar, rectVar, radiusVarName, rectVar, radiusVarName, radiusVarName];
         
        [resultString appendFormat:@"\tCGPathAddLineToPoint(%@, NULL, %@.origin.x + %@, %@.origin.y);\n",
                rectPathVar, rectVar, radiusVarName, rectVar];
        
        [resultString appendFormat:@"\tCGPathAddArc(%@, NULL, %@.origin.x + %@, %@.origin.y + %@, %@, -M_PI / 2, M_PI, 1);\n",
                rectPathVar, rectVar, radiusVarName, rectVar, radiusVarName, radiusVarName];
    }

    [self setStrokeWidthForElement:svgElement resultString:resultString pathVar:rectPathVar];
    
    [self setStrokeColorForElement:svgElement resultString:resultString];
    
    [self setFillColorForElement:svgElement resultString:resultString];
    
    [self drawTransformedPath:svgElement pathVar:rectPathVar currentTransformVar:currentTransformVar resultString:resultString];
    
    [resultString appendFormat:@"\tCGPathRelease(%@);\n", rectPathVar];
}


//========================================================================================
// convertCircleElement:resultString:
//========================================================================================

- (void)convertCircleElement:(NSXMLElement *)svgElement
        currentTransformVar:(NSString *)currentTransformVar resultString:(NSMutableString *)resultString
{
    NSString * circlePathVar = [self indexVarName:@"circlePath"];
    [resultString appendFormat:@"\tCGMutablePathRef %@ = CGPathCreateMutable();\n", circlePathVar];

    NSXMLNode * cxAttributeNode = [svgElement attributeForName:@"cx"];
    NSXMLNode * cyAttributeNode = [svgElement attributeForName:@"cy"];
    NSXMLNode * rAttributeNode = [svgElement attributeForName:@"r"];

    NSString * cxString = cxAttributeNode.stringValue;
    NSString * cyString = cyAttributeNode.stringValue;
    NSString * rString = rAttributeNode.stringValue;

    CGFloat cxFloat = cxString.floatValue;
    CGFloat cyFloat = cyString.floatValue;
    CGFloat rFloat = rString.floatValue;

    NSString * cxVarName = [self indexVarName:@"cx"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", cxVarName, cxFloat];
    NSString * cyVarName = [self indexVarName:@"cy"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", cyVarName, cyFloat];
    NSString * rVarName = [self indexVarName:@"r"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", rVarName, rFloat];
    
    NSString * circleRectVar = [self indexVarName:@"circleRect"];
    NSString * circleRectString = [NSString stringWithFormat:@"\tCGRect %@ = CGRectMake((%@ - %@), (%@ - %@), (%@ * 2.0f), (%@ * 2.0f));\n",
            circleRectVar, cxVarName, rVarName, cyVarName, rVarName, rVarName, rVarName];
    
    [resultString appendString:circleRectString];

    //[resultString appendFormat:@"\tCGContextFillEllipseInRect(context, %@);\n", circleRectVar];
    //[resultString appendFormat:@"\tCGContextStrokeEllipseInRect(context, %@);\n", circleRectVar];

    [resultString appendFormat:@"\tCGPathAddEllipseInRect(%@, NULL, %@);\n",
            circlePathVar, circleRectVar];


    [self setStrokeWidthForElement:svgElement resultString:resultString pathVar:circlePathVar];
    
    [self setStrokeColorForElement:svgElement resultString:resultString];
    
    [self setFillColorForElement:svgElement resultString:resultString];
    
    [self drawTransformedPath:svgElement pathVar:circlePathVar
            currentTransformVar:currentTransformVar resultString:resultString];


    
    
    [resultString appendFormat:@"\tCGPathRelease(%@);\n", circlePathVar];
}

//========================================================================================
// convertEllipseElement:resultString:
//========================================================================================

- (void)convertEllipseElement:(NSXMLElement *)svgElement
        currentTransformVar:(NSString *)currentTransformVar resultString:(NSMutableString *)resultString
{
    NSString * ellipsePathVar = [self indexVarName:@"ellipsePath"];
    [resultString appendFormat:@"\tCGMutablePathRef %@ = CGPathCreateMutable();\n", ellipsePathVar];

    NSXMLNode * cxAttributeNode = [svgElement attributeForName:@"cx"];
    NSXMLNode * cyAttributeNode = [svgElement attributeForName:@"cy"];
    NSXMLNode * rxAttributeNode = [svgElement attributeForName:@"rx"];
    NSXMLNode * ryAttributeNode = [svgElement attributeForName:@"ry"];

    NSString * cxString = cxAttributeNode.stringValue;
    NSString * cyString = cyAttributeNode.stringValue;
    NSString * rxString = rxAttributeNode.stringValue;
    NSString * ryString = ryAttributeNode.stringValue;

    CGFloat cxFloat = cxString.floatValue;
    CGFloat cyFloat = cyString.floatValue;
    CGFloat rxFloat = rxString.floatValue;
    CGFloat ryFloat = ryString.floatValue;

    NSString * cxVarName = [self indexVarName:@"cx"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", cxVarName, cxFloat];
    NSString * cyVarName = [self indexVarName:@"cy"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", cyVarName, cyFloat];
    NSString * rxVarName = [self indexVarName:@"rx"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", rxVarName, rxFloat];
    NSString * ryVarName = [self indexVarName:@"ry"];
    [resultString appendFormat:@"\tCGFloat %@ = %f;\n", ryVarName, ryFloat];
    
    //NSString * ellipseRectString = [NSString stringWithFormat:@"\tCGRect ellipseRect = CGRectMake(%f, %f, %f, %f);\n",
    //        cxFloat - rxFloat, cyFloat - ryFloat, rxFloat * 2.0f, ryFloat * 2.0f];

    NSString * ellipseRectVar = [self indexVarName:@"ellipseRect"];
    NSString * ellipseRectString = [NSString stringWithFormat:@"\tCGRect %@ = CGRectMake((%@ - %@), (%@ - %@), (%@ * 2.0f), (%@ * 2.0f));\n",
            ellipseRectVar, cxVarName, rxVarName, cyVarName, ryVarName, rxVarName, ryVarName];
    
    [resultString appendString:ellipseRectString];
    
    //[resultString appendString:@"\tCGContextFillEllipseInRect(context, ellipseRect);\n"];
    //[resultString appendString:@"\tCGContextStrokeEllipseInRect(context, ellipseRect);\n"];


    [resultString appendFormat:@"\tCGPathAddEllipseInRect(%@, NULL, %@);\n",
            ellipsePathVar, ellipseRectVar];

    [self setStrokeWidthForElement:svgElement resultString:resultString pathVar:ellipsePathVar];
    
    [self setStrokeColorForElement:svgElement resultString:resultString];
    
    [self setFillColorForElement:svgElement resultString:resultString];
    
    [self drawTransformedPath:svgElement pathVar:ellipsePathVar
            currentTransformVar:currentTransformVar resultString:resultString];

    [resultString appendFormat:@"\tCGPathRelease(%@);\n", ellipsePathVar];
}

//========================================================================================
// convertPolylineElement:resultString:
//========================================================================================

- (void)convertPolylineElement:(NSXMLElement *)svgElement
        currentTransformVar:(NSString *)currentTransformVar  resultString:(NSMutableString *)resultString
{
    NSString * polylinePathVar = [self indexVarName:@"polylinePath"];
    [resultString appendFormat:@"\tCGMutablePathRef %@ = CGPathCreateMutable();\n", polylinePathVar];
    
    NSXMLNode * pointsAttributeNode = [svgElement attributeForName:@"points"];
    if (pointsAttributeNode != NULL)
    {
        NSString * pointsAttributeString = pointsAttributeNode.stringValue;
        
        NSCharacterSet * arrayCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" ,;\n\r"];
        NSArray * pointsArray = [pointsAttributeString componentsSeparatedByCharactersInSet:arrayCharacterSet];
        
        NSInteger pointsArrayCount = pointsArray.count;
        if ((pointsArrayCount % 2) == 0)
        {
            for (NSInteger i = 0; i < pointsArrayCount; i+= 2)
            {
                NSString * xString = pointsArray[i];
                NSString * yString = pointsArray[(i + 1)];
                
                if (i == 0)
                {
                    NSString * movetoString = [NSString stringWithFormat:@"\tCGPathMoveToPoint(%@, NULL, %@, %@);\n", polylinePathVar, xString, yString];
                    [resultString appendString:movetoString];
                }
                else
                {
                    NSString * linetoString = [NSString stringWithFormat:@"\tCGPathAddLineToPoint(%@, NULL, %@, %@);\n", polylinePathVar, xString, yString];
                    [resultString appendString:linetoString];
                }
            
            }
        }
    }

    [self setStrokeWidthForElement:svgElement resultString:resultString pathVar:polylinePathVar];
    
    [self setStrokeColorForElement:svgElement resultString:resultString];
    
    [self setFillColorForElement:svgElement resultString:resultString];
    
    [self drawTransformedPath:svgElement pathVar:polylinePathVar
            currentTransformVar:currentTransformVar resultString:resultString];
    
    [resultString appendFormat:@"\tCGPathRelease(%@);\n", polylinePathVar];
}


//========================================================================================
// convertPolygonElement:resultString:
//========================================================================================

- (void)convertPolygonElement:(NSXMLElement *)svgElement
        currentTransformVar:(NSString *)currentTransformVar  resultString:(NSMutableString *)resultString
{
    NSString * polygonPathVar = [self indexVarName:@"polygonPath"];
    [resultString appendFormat:@"\tCGMutablePathRef %@ = CGPathCreateMutable();\n", polygonPathVar];
    
    NSXMLNode * pointsAttributeNode = [svgElement attributeForName:@"points"];
    if (pointsAttributeNode != NULL)
    {
        NSString * pointsAttributeString = pointsAttributeNode.stringValue;
        
        NSCharacterSet * arrayCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" ,;\n\r"];
        NSArray * tempPointsArray = [pointsAttributeString componentsSeparatedByCharactersInSet:arrayCharacterSet];
        
        NSMutableArray * pointsArray = [NSMutableArray array];
        for (NSString * aPointValue in tempPointsArray)
        {
            if (aPointValue.length > 0)
            {
                [pointsArray addObject:aPointValue];
            }
        }
        
        NSInteger pointsArrayCount = pointsArray.count;
        if ((pointsArrayCount % 2) == 0)
        {
            for (NSInteger i = 0; i < pointsArrayCount; i+= 2)
            {
                NSString * xString = pointsArray[i];
                NSString * yString = pointsArray[(i + 1)];
                
                if (i == 0)
                {
                    NSString * movetoString = [NSString stringWithFormat:@"\tCGPathMoveToPoint(%@, NULL, %@, %@);\n", polygonPathVar, xString, yString];
                    [resultString appendString:movetoString];
                }
                else
                {
                    NSString * linetoString = [NSString stringWithFormat:@"\tCGPathAddLineToPoint(%@, NULL, %@, %@);\n", polygonPathVar, xString, yString];
                    [resultString appendString:linetoString];
                }
            
            }

            NSString * lastXString = pointsArray[0];
            NSString * lastYString = pointsArray[1];
            
            NSString * linetoString = [NSString stringWithFormat:@"\tCGPathAddLineToPoint(%@, NULL, %@, %@);\n", polygonPathVar, lastXString, lastYString];
            [resultString appendString:linetoString];
        }
    }

    [self setStrokeWidthForElement:svgElement resultString:resultString pathVar:polygonPathVar];
    
    [self setStrokeColorForElement:svgElement resultString:resultString];
    
    [self setFillColorForElement:svgElement resultString:resultString];
    
    [self drawTransformedPath:svgElement pathVar:polygonPathVar currentTransformVar:currentTransformVar resultString:resultString];
    
    [resultString appendFormat:@"\tCGPathRelease(%@);\n", polygonPathVar];
}

//========================================================================================
// convertPathElement:currentTransformVar:resultString:
//========================================================================================

- (void)convertPathElement:(NSXMLElement *)svgElement
        currentTransformVar:(NSString *)currentTransformVar resultString:(NSMutableString *)resultString
{
    NSString * pathDataString = @"";
    NSXMLNode * pathDataNode = [svgElement attributeForName:@"d"];
    if (pathDataNode.kind == NSXMLAttributeKind)
    {
        pathDataString = pathDataNode.stringValue;
    }

    // kCGPathEOFill kCGPathEOFillStroke kCGPathFillStroke kCGPathStroke
    
    NSMutableArray * pathSegmentsArray = [self.macSVGDocumentWindowController.svgWebKitController
            buildPathSegmentsArrayWithPathString:pathDataString];
    

    NSString * pathVar = [self indexVarName:@"path"];
    [resultString appendFormat:@"\tCGMutablePathRef %@ = CGPathCreateMutable();\n", pathVar];

    for (PathSegment * pathSegment in pathSegmentsArray)
    {
        unichar commandCharacter = pathSegment.pathCommand;
        
        switch (commandCharacter)
        {
            case 'M':     // moveto
            {
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;
                
                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathMoveToPoint(%@, NULL, %@, %@);\n", pathVar, xString, yString];
                
                [resultString appendString:segmentString];
                
                break;
            }
            case 'm':     // moveto
            {
                CGFloat absoluteX = pathSegment.absoluteXFloat;
                CGFloat absoluteY = pathSegment.absoluteYFloat;

                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathMoveToPoint(%@, NULL, %f, %f);\n", pathVar, absoluteX, absoluteY];

                [resultString appendString:segmentString];
                
                break;
            }
            case 'L':     // lineto
            {
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;

                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddLineToPoint(%@, NULL, %@, %@);\n", pathVar, xString, yString];
                [resultString appendString:segmentString];
                
                break;
            }
            case 'l':     // lineto
            {
                CGFloat absoluteX = pathSegment.absoluteXFloat;
                CGFloat absoluteY = pathSegment.absoluteYFloat;

                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddLineToPoint(%@, NULL, %f, %f);\n", pathVar, absoluteX, absoluteY];
                [resultString appendString:segmentString];

                break;
            }
            case 'H':     // horizontal lineto
            {
                NSString * xString = pathSegment.xString;
                CGFloat yString = pathSegment.absoluteYFloat;

                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddLineToPoint(%@, NULL, %@, %f);\n", pathVar, xString, yString];
                [resultString appendString:segmentString];

                break;
            }
            case 'h':     // horizontal lineto
            {
                CGFloat absoluteX = pathSegment.absoluteXFloat;
                CGFloat absoluteY = pathSegment.absoluteYFloat;

                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddLineToPoint(%@, NULL, %f, %f);\n", pathVar, absoluteX, absoluteY];
                [resultString appendString:segmentString];

                break;
            }
            case 'V':     // vertical lineto
            {
                CGFloat absoluteX = pathSegment.absoluteXFloat;
                NSString * yString = pathSegment.yString;

                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddLineToPoint(%@, NULL, %f, %@);\n", pathVar, absoluteX, yString];
                [resultString appendString:segmentString];

                break;
            }
            case 'v':     // vertical lineto
            {
                CGFloat absoluteX = pathSegment.absoluteXFloat;
                CGFloat absoluteY = pathSegment.absoluteYFloat;

                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddLineToPoint(%@, NULL, %f, %f);\n", pathVar, absoluteX, absoluteY];
                [resultString appendString:segmentString];

                break;
            }
            case 'C':     // curveto
            {
                NSString * x1String = pathSegment.x1String;
                NSString * y1String = pathSegment.y1String;

                NSString * x2String = pathSegment.x2String;
                NSString * y2String = pathSegment.y2String;

                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;
                
                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddCurveToPoint(%@, NULL, %@, %@, %@, %@, %@, %@);\n",
                        pathVar, x1String, y1String, x2String, y2String, xString, yString];
                [resultString appendString:segmentString];

                break;
            }
            case 'c':     // curveto
            {
                CGFloat absoluteX1 = pathSegment.absoluteX1Float;
                CGFloat absoluteY1 = pathSegment.absoluteY1Float;

                CGFloat absoluteX2 = pathSegment.absoluteX2Float;
                CGFloat absoluteY2 = pathSegment.absoluteY2Float;

                CGFloat absoluteX = pathSegment.absoluteXFloat;
                CGFloat absoluteY = pathSegment.absoluteYFloat;

                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddCurveToPoint(%@, NULL, %f, %f, %f, %f, %f, %f);\n",
                        pathVar, absoluteX1, absoluteY1, absoluteX2, absoluteY2, absoluteX, absoluteY];
                [resultString appendString:segmentString];

                break;
            }
            case 'S':     // smooth curveto
            {
                NSString * x2String = pathSegment.x2String;
                NSString * y2String = pathSegment.y2String;

                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;
                
                NSInteger currentSegmentIndex = [pathSegmentsArray indexOfObject:pathSegment];
                
                if (currentSegmentIndex > 0)
                {
                    NSString * previousX2String = pathSegment.x2String;
                    NSString * previousY2String = pathSegment.y2String;
                    
                    CGFloat previousX2 = previousX2String.floatValue;
                    CGFloat previousY2 = previousY2String.floatValue;
                    
                    CGFloat x = xString.floatValue;
                    CGFloat y = yString.floatValue;
                    
                    CGFloat x1 = x - previousX2;
                    CGFloat y1 = y - previousY2;
                    
                    NSString * x1String = [NSString stringWithFormat:@"%f", x1];
                    NSString * y1String = [NSString stringWithFormat:@"%f", y1];

                    NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddCurveToPoint(%@, NULL, %@, %@, %@, %@, %@, %@);\n",
                            pathVar, x1String, y1String, x2String, y2String, xString, yString];
                    [resultString appendString:segmentString];
                }
                
                break;
            }
            case 's':     // smooth curveto
            {
                NSString * x2String = pathSegment.x2String;
                NSString * y2String = pathSegment.y2String;

                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;

                NSInteger currentSegmentIndex = [pathSegmentsArray indexOfObject:pathSegment];

                if (currentSegmentIndex > 0)
                {
                    NSString * previousX2String = pathSegment.x2String;
                    NSString * previousY2String = pathSegment.y2String;
                    
                    CGFloat previousX2 = previousX2String.floatValue;
                    CGFloat previousY2 = previousY2String.floatValue;
                    
                    CGFloat x = xString.floatValue;
                    CGFloat y = yString.floatValue;
                    
                    CGFloat x1 = x - previousX2;
                    CGFloat y1 = y - previousY2;
                    
                    NSString * x1String = [NSString stringWithFormat:@"%f", x1];
                    NSString * y1String = [NSString stringWithFormat:@"%f", y1];

                    NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddCurveToPoint(%@, NULL, %@, %@, %@, %@, %@, %@);\n",
                            pathVar, x1String, y1String, x2String, y2String, xString, yString];
                    [resultString appendString:segmentString];
                }

                break;
            }
            case 'Q':     // quadratic Bezier curve
            {
                NSString * x1String = pathSegment.x1String;
                NSString * y1String = pathSegment.y1String;

                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;

                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddQuadCurveToPoint(%@, NULL, %@, %@, %@, %@);\n",
                        pathVar, x1String, y1String, xString, yString];
                [resultString appendString:segmentString];

                break;
            }
            case 'q':     // quadratic Bezier curve
            {
                CGFloat absoluteX1 = pathSegment.absoluteX1Float;
                CGFloat absoluteY1 = pathSegment.absoluteY1Float;

                CGFloat absoluteX = pathSegment.absoluteXFloat;
                CGFloat absoluteY = pathSegment.absoluteYFloat;

                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddQuadCurveToPoint(%@, NULL, %f, %f, %f, %f);\n",
                        pathVar, absoluteX1, absoluteY1, absoluteX, absoluteY];
                [resultString appendString:segmentString];

                break;
            }
            case 'T':     // smooth quadratic Bezier curve
            {
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;

                NSInteger currentSegmentIndex = [pathSegmentsArray indexOfObject:pathSegment];

                if (currentSegmentIndex > 0)
                {
                    NSString * previousX2String = pathSegment.x2String;
                    NSString * previousY2String = pathSegment.y2String;
                    
                    CGFloat previousX2 = previousX2String.floatValue;
                    CGFloat previousY2 = previousY2String.floatValue;
                    
                    CGFloat x = xString.floatValue;
                    CGFloat y = yString.floatValue;
                    
                    CGFloat x1 = x - previousX2;
                    CGFloat y1 = y - previousY2;
                    
                    NSString * x1String = [NSString stringWithFormat:@"%f", x1];
                    NSString * y1String = [NSString stringWithFormat:@"%f", y1];

                    NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddQuadCurveToPoint(%@, NULL, %@, %@, %@, %@);\n",
                            pathVar, x1String, y1String, xString, yString];
                    [resultString appendString:segmentString];
                }
                
                break;
            }
            case 't':     // smooth quadratic Bezier curve
            {
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;

                NSInteger currentSegmentIndex = [pathSegmentsArray indexOfObject:pathSegment];

                if (currentSegmentIndex > 0)
                {
                    NSString * previousX2String = pathSegment.x2String;
                    NSString * previousY2String = pathSegment.y2String;
                    
                    CGFloat previousX2 = previousX2String.floatValue;
                    CGFloat previousY2 = previousY2String.floatValue;
                    
                    CGFloat x = xString.floatValue;
                    CGFloat y = yString.floatValue;
                    
                    CGFloat x1 = x - previousX2;
                    CGFloat y1 = y - previousY2;
                    
                    NSString * x1String = [NSString stringWithFormat:@"%f", x1];
                    NSString * y1String = [NSString stringWithFormat:@"%f", y1];

                    NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddQuadCurveToPoint(%@, NULL, %@, %@, %@, %@);\n",
                            pathVar, x1String, y1String, xString, yString];
                    [resultString appendString:segmentString];
                }

                break;
            }
            case 'A':     // elliptical arc
            {
                NSString * rxString = pathSegment.rxString;
                NSString * ryString = pathSegment.ryString;
                
                NSString * dataXAxisRotationString = pathSegment.xAxisRotationString;
                
                NSString * largeArcString = pathSegment.largeArcFlagString;
                
                NSString * sweepString = pathSegment.sweepFlagString;
                
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;

                CGFloat absoluteStartX = pathSegment.absoluteStartXFloat;
                CGFloat absoluteStartY = pathSegment.absoluteStartYFloat;

                //CGContextAddArcToPoint (context, x1, y1, x2, y2, radius)
                
                /*
                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddArcToPoint(%@, NULL, %@, %@, %@, %@, %@);\n",
                        pathVar, startXString, startYString, xString, yString, rxString];
                [resultString appendString:segmentString];
                */
                
                CGPoint curPoint = CGPointMake(absoluteStartX, absoluteStartY);
                CGFloat xRadius = rxString.floatValue;
                CGFloat yRadius = ryString.floatValue;
                double dataXAxisRotation = dataXAxisRotationString.doubleValue;
                BOOL largeArcFlag = largeArcString.boolValue;
                BOOL sweepFlag = sweepString.boolValue;
                CGFloat endPointX = xString.floatValue;
                CGFloat endPointY = yString.floatValue;
                
                [self addSVGArcToPathVar:pathVar curPoint:curPoint xRadius:xRadius yRadius:yRadius
                        xAxisRotationDegrees:dataXAxisRotation largeArcFlag:largeArcFlag sweepFlag:sweepFlag
                        endPointX:endPointX endPointY:endPointY resultString:resultString];

                break;
            }
            case 'a':     // elliptical arc
            {
                NSString * rxString = pathSegment.rxString;
                NSString * ryString = pathSegment.ryString;   // CoreGraphics does not support rx/ry, so we just use rx
                #pragma unused(ryString)
                
                NSString * dataXAxisRotationString = pathSegment.xAxisRotationString;   // not sure how to handle these yet
                NSString * largeArcString = pathSegment.largeArcFlagString;
                NSString * sweepString = pathSegment.sweepFlagString;

                #pragma unused(dataXAxisRotationString)
                #pragma unused(largeArcString)
                #pragma unused(sweepString)
                
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;

                CGFloat absoluteStartX = pathSegment.absoluteStartXFloat;
                CGFloat absoluteStartY = pathSegment.absoluteStartYFloat;

                //CGContextAddArcToPoint (context, x1, y1, x2, y2, radius)
                
                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddArcToPoint(%@, NULL, %f, %f, %@, %@, %@);\n",
                        pathVar, absoluteStartX, absoluteStartY, xString, yString, rxString];
                [resultString appendString:segmentString];

                break;
            }
            case 'Z':     // closepath
            {
                //[resultString appendFormat:@"CGPathClosePath(%@);\n", pathVar];

                PathSegment * firstPathSegment = pathSegmentsArray.firstObject;

                NSString * firstXString = firstPathSegment.xString;
                NSString * firstYString = firstPathSegment.yString;

                if (firstXString == NULL)
                {
                    firstXString = @"0";
                }
                if (firstYString == NULL)
                {
                    firstYString = @"0";
                }

                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddLineToPoint(%@, NULL, %@, %@);\n", pathVar, firstXString, firstYString];
                [resultString appendString:segmentString];

                break;
            }
            case 'z':     // closepath
            {
                //[resultString appendFormat:@"CGPathClosePath(%@);\n", pathVar];

                PathSegment * firstPathSegment = pathSegmentsArray.firstObject;

                NSString * firstXString = firstPathSegment.xString;
                NSString * firstYString = firstPathSegment.yString;
                
                if (firstXString == NULL)
                {
                    firstXString = @"0";
                }
                if (firstYString == NULL)
                {
                    firstYString = @"0";
                }

                NSString * segmentString = [NSString stringWithFormat:@"\tCGPathAddLineToPoint(%@, NULL, %@, %@);\n", pathVar, firstXString, firstYString];
                [resultString appendString:segmentString];

                break;
            }
        }
    }
    

    [self setStrokeWidthForElement:svgElement resultString:resultString pathVar:pathVar];
    
    [self setStrokeColorForElement:svgElement resultString:resultString];
    
    [self setFillColorForElement:svgElement resultString:resultString];
    
    [self drawTransformedPath:svgElement pathVar:pathVar currentTransformVar:currentTransformVar resultString:resultString];
    
    [resultString appendFormat:@"\tCGPathRelease(%@);\n", pathVar];
}

//==================================================================================
//	drawTransformedPath:drawTransformedPath:pathVar:
//==================================================================================

- (void)drawTransformedPath:(NSXMLElement *)svgElement pathVar:(NSString *)pathVar
        currentTransformVar:(NSString *)currentTransformVar resultString:(NSMutableString *)resultString
{
    [resultString appendFormat:@"\tif (flipImage == YES) { // flip image vertically\n"];
    NSString * flipVar = [self indexVarName:@"flip"];
    [resultString appendFormat:@"\t\tCGAffineTransform %@ = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);\n", flipVar];
    [resultString appendFormat:@"\t\t%@ = CGAffineTransformConcat(%@, %@);\n", currentTransformVar, currentTransformVar, flipVar];
    [resultString appendFormat:@"\t}\n"];

    [resultString appendFormat:@"\tif (centerImage == YES) { // center image\n"];
    NSString * boundsRectVar = [self indexVarName:@"boundsRect"];
    [resultString appendFormat:@"\t\tNSRect %@ = cellBounds;\n", boundsRectVar];
    NSString * boundsMidXVar = [self indexVarName:@"boundsMidX"];
    [resultString appendFormat:@"\t\tCGFloat %@ = NSMidX(%@) * (1.0f / viewScale);\n", boundsMidXVar, boundsRectVar];
    NSString * boundsMidYVar = [self indexVarName:@"boundsMidY"];
    [resultString appendFormat:@"\t\tCGFloat %@ = NSMidY(%@) * (1.0f / viewScale);\n", boundsMidYVar, boundsRectVar];
    
    NSString * imageMidXVar = [self indexVarName:@"imageMidX"];
    [resultString appendFormat:@"\t\tCGFloat %@ = NSMidX(webBBox);\n", imageMidXVar];

    NSString * imageMidYVar = [self indexVarName:@"imageMidY"];
    [resultString appendFormat:@"\t\tCGFloat %@ = NSMidY(webBBox);\n", imageMidYVar];

    NSString * xTranslationVar = [self indexVarName:@"xTranslation"];
    [resultString appendFormat:@"\t\tCGFloat %@ = %@ - %@;\n", xTranslationVar, boundsMidXVar, imageMidXVar];

    NSString * yTranslationVar = [self indexVarName:@"yTranslation"];
    [resultString appendFormat:@"\t\tCGFloat %@ = %@ - %@;\n", yTranslationVar, boundsMidYVar, imageMidYVar];
    
    NSString * centerTranslationVar = [self indexVarName:@"centerTranslation"];
	[resultString appendFormat:@"\t\tCGAffineTransform %@ = CGAffineTransformMakeTranslation(%@, %@);\n",
            centerTranslationVar, xTranslationVar, yTranslationVar];
    
	[resultString appendFormat:@"\t\t%@ = CGAffineTransformConcat(%@, %@);\n",
            currentTransformVar, currentTransformVar, centerTranslationVar];
    
    [resultString appendFormat:@"\t}\n"];
    
    NSString * translateVar = [self indexVarName:@"translate"];
    [resultString appendFormat:@"\tCGAffineTransform %@ = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);\n", translateVar];
    [resultString appendFormat:@"\t%@ = CGAffineTransformConcat(%@, %@);\n", currentTransformVar, currentTransformVar, translateVar];

    NSString * translateXYVar = [self indexVarName:@"translateXY"];
    [resultString appendFormat:@"\tCGAffineTransform %@ = CGAffineTransformMakeTranslation(translateX, translateY);\n", translateXYVar];
    [resultString appendFormat:@"\t%@ = CGAffineTransformConcat(%@, %@);\n", currentTransformVar, currentTransformVar, translateXYVar];

    NSString * scaleVar = [self indexVarName:@"scale"];
    [resultString appendFormat:@"\tCGAffineTransform %@ = CGAffineTransformMakeScale(viewScale, viewScale);\n", scaleVar];
    [resultString appendFormat:@"\t%@ = CGAffineTransformConcat(%@, %@);\n", currentTransformVar, currentTransformVar, scaleVar];
    
    NSString * finalPathVar = [self indexVarName:@"finalPath"];
    [resultString appendFormat:@"\tCGPathRef %@ = CGPathCreateCopyByTransformingPath(%@, &%@);\n", finalPathVar, pathVar, currentTransformVar];

    NSString * pathMode = @"kCGPathStroke";
    NSXMLNode * fillAttributeNode = [svgElement attributeForName:@"fill"];
    if (fillAttributeNode != NULL)
    {
        NSString * fillString = fillAttributeNode.stringValue;
        if ([fillString isEqualToString:@"none"] == NO)
        {
            pathMode = @"kCGPathFillStroke";
        }
        
        NSRange urlRange = [fillString rangeOfString:@"url(#"];
        if (urlRange.location != NSNotFound)
        {
            NSCharacterSet * parenthesesCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"()"];
            NSArray * fillURLArray = [fillString componentsSeparatedByCharactersInSet:parenthesesCharacterSet];
            
            if (fillURLArray.count >= 2)
            {
                NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                
                NSString * urlString = fillURLArray[1];
                urlString = [urlString stringByTrimmingCharactersInSet:whitespaceSet];
                
                if (urlString.length > 1)
                {
                    unichar firstChar = [urlString characterAtIndex:0];
                    
                    if (firstChar == '#')   // URL id symbol
                    {
                        NSString * elementIDString = [urlString substringFromIndex:1];
                        
                        MacSVGDocument * macSVGDocument = (self.macSVGDocumentWindowController).document;
                        NSXMLDocument * svgXmlDocument = macSVGDocument.svgXmlDocument;
                        
                        NSXMLElement * rootElement = [svgXmlDocument rootElement];
                        
                        NSString * xpathQuery = [[NSString alloc] initWithFormat:@".//*[@id=\"%@\"]", elementIDString];
                        
                        NSError * error = NULL;
                        NSArray * resultArray = [rootElement nodesForXPath:xpathQuery error:&error];
                        
                        if (resultArray.count > 0)
                        {
                            NSXMLNode * firstResultNode = resultArray.firstObject;
                            
                            if (firstResultNode.kind == NSXMLElementKind)
                            {
                                NSXMLElement * firstResultElement = (NSXMLElement *)firstResultNode;
                                
                                NSString * firstResultElementName = firstResultElement.name;
                                
                                if ([firstResultElementName isEqualToString:@"linearGradient"] == YES)
                                {
                                    [self addLinearGradient:firstResultElement pathVar:finalPathVar resultString:resultString];
                                }
                            }
                        }
                    
                        pathMode = @"kCGPathStroke";
                    }
                }
            }
        }
    }

    [resultString appendString:@"\tCGContextBeginPath(context);\n"];
    [resultString appendFormat:@"\tCGContextAddPath(context, %@);\n", finalPathVar];
    
    [resultString appendFormat:@"\tCGContextDrawPath(context, %@);\n", pathMode];
    
    [resultString appendFormat:@"\tCGPathRelease(%@);\n", finalPathVar];
}


//==================================================================================
//	addLinearGradient:pathVar:resultString
//==================================================================================

- (void)addLinearGradient:(NSXMLElement *)linearGradientElement pathVar:(NSString *)pathVar
        resultString:(NSMutableString *)resultString
{
    NSString * linearGradientColorSpaceVar = [self indexVarName:@"linearGradientColorSpace"];
    [resultString appendFormat:@"\tCGColorSpaceRef %@ = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);\n", linearGradientColorSpaceVar];

    NSXMLNode * x1AttributeNode = [linearGradientElement attributeForName:@"x1"];
    NSXMLNode * y1AttributeNode = [linearGradientElement attributeForName:@"y1"];
    NSXMLNode * x2AttributeNode = [linearGradientElement attributeForName:@"x2"];
    NSXMLNode * y2AttributeNode = [linearGradientElement attributeForName:@"y2"];
    
    NSString * x1String = x1AttributeNode.stringValue;
    NSString * y1String = y1AttributeNode.stringValue;
    NSString * x2String = x2AttributeNode.stringValue;
    NSString * y2String = y2AttributeNode.stringValue;
    
    NSString * opacityString = @"1.0";
    NSXMLNode * linearGradientElementOpacityAttributeNode = [linearGradientElement attributeForName:@"opacity"];
    if (linearGradientElementOpacityAttributeNode != NULL)
    {
        opacityString = linearGradientElementOpacityAttributeNode.stringValue;
    }
    
    NSRange percentSignRange = [x1String rangeOfString:@"%"];
    if (percentSignRange.location != NSNotFound)
    {
        CGFloat percentFloat = x1String.floatValue;
        percentFloat /= 100.0f;
        x1String = [self allocFloatString:percentFloat];
    }
    percentSignRange = [y1String rangeOfString:@"%"];
    if (percentSignRange.location != NSNotFound)
    {
        CGFloat percentFloat = y1String.floatValue;
        percentFloat /= 100.0f;
        y1String = [self allocFloatString:percentFloat];
    }
    percentSignRange = [x2String rangeOfString:@"%"];
    if (percentSignRange.location != NSNotFound)
    {
        CGFloat percentFloat = x2String.floatValue;
        percentFloat /= 100.0f;
        x2String = [self allocFloatString:percentFloat];
    }
    percentSignRange = [y2String rangeOfString:@"%"];
    if (percentSignRange.location != NSNotFound)
    {
        CGFloat percentFloat = y2String.floatValue;
        percentFloat /= 100.0f;
        y2String = [self allocFloatString:percentFloat];
    }
    
    NSMutableString * gradientStopLocationsString = [NSMutableString string];
    NSMutableString * gradientColorsString = [NSMutableString string];
    NSMutableString * releaseGradientColorsString = [NSMutableString string];
    
    NSArray * childNodes = linearGradientElement.children;
    for (NSXMLNode * aChildNode in childNodes)
    {
        if (aChildNode.kind == NSXMLElementKind)
        {
            NSXMLElement * childElement = (NSXMLElement *)aChildNode;
            
            NSString * childElementName = childElement.name;
            
            if ([childElementName isEqualToString:@"stop"] == YES)
            {
                NSXMLNode * offsetAttributeNode = [childElement attributeForName:@"offset"];
                NSXMLNode * stopColorAttributeNode = [childElement attributeForName:@"stop-color"];
                
                NSString * offsetString = offsetAttributeNode.stringValue;
                NSString * stopColorString = stopColorAttributeNode.stringValue;
                
                stopColorString = [self hexColorForColorName:stopColorString];
                
                NSString * gradientRGBString = [self gradientColorStringForHexColor:stopColorString opacity:opacityString];

                NSString * linearGradientColorArrayVar = [self indexVarName:@"linearGradientColorArray"];
                [resultString appendFormat:@"\tCGFloat %@[4] = {%@};\n", linearGradientColorArrayVar, gradientRGBString];

                NSString * linearGradientColorVar = [self indexVarName:@"linearGradientColor"];
                [resultString appendFormat:@"\tCGColorRef %@ = CGColorCreate(%@, %@);\n",
                        linearGradientColorVar, linearGradientColorSpaceVar, linearGradientColorArrayVar];
                
                if (gradientStopLocationsString.length > 0)
                {
                    [gradientStopLocationsString appendString:@", "];
                }
                
                NSRange percentSignRange = [offsetString rangeOfString:@"\%"];
                if (percentSignRange.location != NSNotFound)
                {
                    CGFloat percentFloat = offsetString.floatValue;
                    percentFloat /= 100.0f;
                    offsetString = [NSString stringWithFormat:@"%f", percentFloat];
                }
                
                [gradientStopLocationsString appendString:offsetString];


                
                if (gradientColorsString.length > 0)
                {
                    [gradientColorsString appendString:@", "];
                }
                
                NSString * aColorString = [NSString stringWithFormat:@"(__bridge id) %@", linearGradientColorVar];
                
                [gradientColorsString appendString:aColorString];
                
                [releaseGradientColorsString appendFormat:@"\tCGColorRelease(%@);\n", linearGradientColorVar];
            }
        }
    }
    
    NSString * locationsArrayVar = [self indexVarName:@"locationsArray"];
    [resultString appendFormat:@"\tCGFloat %@[] = {%@};\n", locationsArrayVar, gradientStopLocationsString];
    
    NSString * colorsArrayVar = [self indexVarName:@"colorsArray"];
    [resultString appendFormat:@"\tNSArray * %@ = @[%@];\n", colorsArrayVar, gradientColorsString];

    NSString * linearGradientVar = [self indexVarName:@"linearGradient"];
    [resultString appendFormat:@"\tCGGradientRef %@ = CGGradientCreateWithColors(%@, (__bridge CFArrayRef) %@, %@);\n",
            linearGradientVar, linearGradientColorSpaceVar, colorsArrayVar, locationsArrayVar];

    NSString * pathBoundsVar = [self indexVarName:@"pathBounds"];
    [resultString appendFormat:@"\tCGRect %@ = CGPathGetPathBoundingBox(%@);\n", pathBoundsVar, pathVar];
    
    NSString * linearGradientStartPointVar = [self indexVarName:@"linearGradientStartPoint"];
    [resultString appendFormat:@"\tCGPoint %@ = CGPointMake(CGRectGetMidX(%@), CGRectGetMinY(%@));\n",
            linearGradientStartPointVar, pathBoundsVar, pathBoundsVar];
    
    NSString * linearGradientEndPointVar = [self indexVarName:@"linearGradientEndPoint"];
    [resultString appendFormat:@"\tCGPoint %@ = CGPointMake(CGRectGetMidX(%@), CGRectGetMaxY(%@));\n",
            linearGradientEndPointVar, pathBoundsVar, pathBoundsVar];
    
    [resultString appendString:@"\tCGContextBeginPath(context);\n"];

    [resultString appendFormat:@"\tCGContextAddPath(context, %@);\n", pathVar];

    [resultString appendString:@"\tCGContextClip(context);\n"];

    [resultString appendFormat:@"\tCGContextDrawLinearGradient(context, %@, %@, %@, 0);\n",
            linearGradientVar, linearGradientStartPointVar, linearGradientEndPointVar];
    
    [resultString appendFormat:@"\tCGGradientRelease(%@);\n", linearGradientVar];
    
    [resultString appendString:releaseGradientColorsString];
    
    [resultString appendFormat:@"\tCGColorSpaceRelease(%@);\n", linearGradientColorSpaceVar];
    
    /*
    //CGColorSpaceRef gradientColorSpaceRef = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    //CGFloat startColorArray[4] = {0.94117647f, 0.86666667f, 0.60392157f, 1.0f};      // 240, 221, 154
    //CGFloat endColorArray[4] = {0.85490196f, 0.64705882f, 0.12549020, 1};        // 218, 165, 32
    //CGColorRef startColor = CGColorCreate(gradientColorSpaceRef, startColorArray);
    //CGColorRef endColor = CGColorCreate(gradientColorSpaceRef, endColorArray);
    //CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //CGFloat locations[] = { 0.0, 1.0 };
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGRect pathBounds = CGPathGetPathBoundingBox(finalPath53);
    CGPoint startPoint = CGPointMake(CGRectGetMidX(pathBounds), CGRectGetMinY(pathBounds));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(pathBounds), CGRectGetMaxY(pathBounds));
    CGContextBeginPath(context);
    CGContextAddPath(context, finalPath53);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    CGColorRelease(startColor);
    CGColorRelease(endColor);
    //CGColorSpaceRelease(gradientColorSpaceRef);
    */
}

//==================================================================================
//	addSVGArcToPathVar:curPoint:xRadius:yRadius:xAxisRotationDegrees:largeArcFlag:sweepFlag:endPointX:endPointY:resultString:
//==================================================================================

const CGFloat kDegreesToRadiansConstant = (CGFloat)(M_PI/180.0);

-(void) addSVGArcToPathVar:(NSString *)pathVar
        curPoint:(CGPoint)curPoint
        xRadius:(CGFloat)xRadius
        yRadius:(CGFloat)yRadius
        xAxisRotationDegrees:(double)xAxisRotationDegrees
        largeArcFlag:(BOOL)largeArcFlag
        sweepFlag:(BOOL)sweepFlag
        endPointX:(CGFloat)endPointX
        endPointY:(CGFloat)endPointY
        resultString:(NSMutableString *)resultString
{
    //implementation notes http://www.w3.org/TR/SVG11/implnote.html#ArcConversionEndpointToCenter
    // adapted from https://github.com/GenerallyHelpfulSoftware/SVGgh/blob/master/SVGgh/SVG/SVGUtilities.m

	// first do first aid to the parameters to keep them in line
	
	//CGPoint curPoint = CGPathGetCurrentPoint(thePath);
    
	if(curPoint.x == endPointX && endPointY == curPoint.y)
	{ // do nothing
	}
	else if (xRadius == 0.0 || yRadius == 0.0) // not an actual arc, draw a line segment
	{
		//CGPathAddLineToPoint(thePath, NULL, endPointX, endPointY);
        [resultString appendFormat:@"CGPathAddLineToPoint(%@, NULL, %f, %f);\n", pathVar, endPointX, endPointY];
	}
	else // actually try to draw an arc
	{
		xRadius = fabs(xRadius); // make sure radius are positive
		yRadius = fabs(yRadius);
		xAxisRotationDegrees = fmod(xAxisRotationDegrees, 360.0);
		CGFloat	xAxisRotationRadians = xAxisRotationDegrees * kDegreesToRadiansConstant;
		CGFloat cosineAxisRotation = cosf(xAxisRotationRadians);
		CGFloat sineAxisRotation = sinf(xAxisRotationRadians);
		CGFloat deltaX = curPoint.x - endPointX;
		CGFloat deltaY = curPoint.y - endPointY;
        
        NSString * xAxisRotationRadiansVar = [self indexVarName:@"xAxisRotationRadians"];
        [resultString appendFormat:@"\tCGFloat %@ = %f;\n", xAxisRotationRadiansVar, (xAxisRotationDegrees * kDegreesToRadiansConstant)];
		
		// steps are from the implementation notes
		// F.6.5  Step 1: Compute (x1′, y1′)
		CGPoint	translatedCurPoint = CGPointMake(cosineAxisRotation*deltaX/2.0f + sineAxisRotation * deltaY / 2.0f,
                      -1.0f * sineAxisRotation * deltaX / 2.0f + cosineAxisRotation * deltaY / 2.0f);
		
		// (skipping to different section) F.6.6 Step 3: Ensure radii are large enough
		CGFloat	shouldBeNoMoreThanOne = translatedCurPoint.x * translatedCurPoint.x / (xRadius * xRadius) +
                translatedCurPoint.y * translatedCurPoint.y / (yRadius * yRadius);
        
		if(shouldBeNoMoreThanOne > 1.0)
		{
			xRadius *= sqrtf(shouldBeNoMoreThanOne);
			yRadius *= sqrtf(shouldBeNoMoreThanOne);
			
			shouldBeNoMoreThanOne = translatedCurPoint.x*translatedCurPoint.x/(xRadius*xRadius)
			+ translatedCurPoint.y*translatedCurPoint.y/(yRadius*yRadius);
			if(shouldBeNoMoreThanOne > 1.0) // sometimes just a bit north of 1.0000000 after first pass
			{
				shouldBeNoMoreThanOne += .000001; // making sure
				xRadius *= sqrtf(shouldBeNoMoreThanOne);
				yRadius *= sqrtf(shouldBeNoMoreThanOne);
			}
		}
		
		//CGAffineTransform	transform = CGAffineTransformIdentity;
        NSString * transformVar = [self indexVarName:@"transform"];
		[resultString appendFormat:@"\tCGAffineTransform %@ = CGAffineTransformIdentity;\n", transformVar];
        
		// back to  F.6.5   Step 2: Compute (cx′, cy′)
		double  centerScalingDivisor = xRadius * xRadius * translatedCurPoint.y * translatedCurPoint.y +
                yRadius * yRadius * translatedCurPoint.x * translatedCurPoint.x;
		double	centerScaling = 0.0;
		
		if (centerScalingDivisor != 0.0)
		{
			centerScaling = sqrt((xRadius * xRadius * yRadius * yRadius
                    - xRadius * xRadius * translatedCurPoint.y * translatedCurPoint.y
                    - yRadius * yRadius * translatedCurPoint.x * translatedCurPoint.x)
                    / centerScalingDivisor);
            
            if (centerScaling != centerScaling)
            {
                centerScaling = 0.0;
            }
            
			if (largeArcFlag == sweepFlag)
			{
				centerScaling *= -1.0;
			}
		}
		
		CGPoint translatedCenterPoint = CGPointMake(centerScaling * xRadius * translatedCurPoint.y / yRadius,
                                                    -1.0f * centerScaling * yRadius * translatedCurPoint.x / xRadius);
		
		// F.6.5  Step 3: Compute (cx, cy) from (cx′, cy′)
		CGPoint centerPoint = CGPointMake(
                (curPoint.x + endPointX) / 2.0f + cosineAxisRotation * translatedCenterPoint.x - sineAxisRotation * translatedCenterPoint.y,
                (curPoint.y + endPointY) / 2.0f + sineAxisRotation * translatedCenterPoint.x + cosineAxisRotation * translatedCenterPoint.y);
		// F.6.5   Step 4: Compute θ1 and Δθ
		
		// misusing CGPoint as a vector
		CGPoint vectorX = CGPointMake(1.0, 0.0);
		CGPoint vectorU = CGPointMake((translatedCurPoint.x - translatedCenterPoint.x) / xRadius,
									  (translatedCurPoint.y - translatedCenterPoint.y) / yRadius);
		CGPoint vectorV = CGPointMake((-1.0f * translatedCurPoint.x - translatedCenterPoint.x) / xRadius,
									  (-1.0f * translatedCurPoint.y - translatedCenterPoint.y) / yRadius);
		
		CGFloat	startAngle = CalculateVectorAngle(vectorX, vectorU);
		CGFloat	angleDelta = CalculateVectorAngle(vectorU, vectorV);
		CGFloat vectorRatio = CalculateVectorRatio(vectorU, vectorV);
		if(vectorRatio <= -1)
		{
			angleDelta = M_PI;
		}
		else if(vectorRatio >= 1.0)
		{
			angleDelta = 0.0;
		}
		
		if (sweepFlag == 0 && angleDelta > 0.0)
		{
			angleDelta = angleDelta - 2.0 * M_PI;
		}
		if (sweepFlag == 1 && angleDelta < 0.0)
		{
			angleDelta = angleDelta + 2.0 * M_PI;
		}
		
		//transform = CGAffineTransformTranslate(transform,
		//									   centerPoint.x, centerPoint.y);
		[resultString appendFormat:@"\t%@ = CGAffineTransformTranslate(%@, %f, %f);\n", transformVar, transformVar, centerPoint.x, centerPoint.y];
		
		//transform = CGAffineTransformRotate(transform, xAxisRotationRadians);
		[resultString appendFormat:@"\t%@ = CGAffineTransformRotate(%@, %@);\n", transformVar, transformVar, xAxisRotationRadiansVar];
		
		CGFloat radius = (xRadius > yRadius) ? xRadius : yRadius;
		CGFloat scaleX = (xRadius > yRadius) ? 1.0 : xRadius / yRadius;
		CGFloat scaleY = (xRadius > yRadius) ? yRadius / xRadius : 1.0;
		
		//transform = CGAffineTransformScale(transform, scaleX, scaleY);
		[resultString appendFormat:@"\t%@ = CGAffineTransformScale(%@, %f, %f);\n", transformVar, transformVar, scaleX, scaleY];
		
		//CGPathAddArc(thePath, &transform, 0.0, 0.0, radius, startAngle, startAngle+angleDelta,
		//			 !sweepFlag);
		[resultString appendFormat:@"\tCGPathAddArc(%@, &%@, 0.0, 0.0, %f, %f, %f, %ld);\n",
                pathVar, transformVar, radius, startAngle, (startAngle+angleDelta), (NSInteger)(!sweepFlag)];
	}
}

CGFloat CalculateVectorRatio(CGPoint	vector1, CGPoint vector2)
{
	CGFloat	result = vector1.x * vector2.x+vector1.y * vector2.y;
	result /= (CalculateVectorMagnitude(vector1) * CalculateVectorMagnitude(vector2));
	return result;
}

CGFloat CalculateVectorAngle(CGPoint	vector1, CGPoint vector2)
{
	CGFloat	vectorRatio = CalculateVectorRatio(vector1, vector2);
	
	CGFloat	result = acosf(vectorRatio);
	
	if((vector1.x*vector2.y) < (vector1.y*vector2.x))
	{
		result *= -1.0;
	}
	return result;
}

// misusing CGPoint as a vector for laziness
CGFloat CalculateVectorMagnitude(CGPoint aVector)
{
	CGFloat	result = sqrtf(aVector.x * aVector.x + aVector.y * aVector.y);
	
	
	return result;
}


//==================================================================================
//	setStrokeWidthForElement:resultString:
//==================================================================================

- (void)setStrokeWidthForElement:(NSXMLElement *)svgElement resultString:(NSMutableString *)resultString pathVar:(NSString *)pathVar
{
    NSString * strokeWidthString = @"1";
    
    NSXMLNode * strokeWidthNode = [svgElement attributeForName:@"stroke-width"];
    if (strokeWidthNode != NULL)
    {
        strokeWidthString = strokeWidthNode.stringValue;
        
        NSMutableString * copyStrokeWidthString = [NSMutableString string];
        NSInteger strokeWidthStringLength = strokeWidthString.length;
        for (NSInteger i = 0; i < strokeWidthStringLength; i++)
        {
            unichar aChar = [strokeWidthString characterAtIndex:i];
            
            if (((aChar >= '0') && (aChar <= '9')) || (aChar == '.'))
            {
                [copyStrokeWidthString appendFormat:@"%C", aChar];
            }
        }
        
        strokeWidthString = copyStrokeWidthString;
    }

    NSString * strokeWidthVar = [self indexVarName:@"strokeWidth"];
    [resultString appendFormat:@"\tCGFloat %@ = %@;\n", strokeWidthVar, strokeWidthString];

    if (pathVar != NULL)
    {
        NSString * pathBoundingBoxVar = [self indexVarName:@"pathBoundingBox"];
        [resultString appendFormat:@"\tCGRect %@ = CGPathGetBoundingBox(%@);\n", pathBoundingBoxVar, pathVar];
        [resultString appendFormat:@"\t%@ = NSInsetRect(%@, -%@, -%@);\n", pathBoundingBoxVar, pathBoundingBoxVar, strokeWidthVar, strokeWidthVar];
    }
    
    NSString * scaledStrokeWidthVar = [self indexVarName:@"scaledStrokeWidth"];
    [resultString appendFormat:@"\tCGFloat %@ = %@ * viewScale;\n", scaledStrokeWidthVar, strokeWidthString];
    [resultString appendFormat:@"\tCGContextSetLineWidth(context, %@);\n", scaledStrokeWidthVar];
}

//==================================================================================
//	setStrokeColorForElement:resultString:
//==================================================================================

- (void)setStrokeColorForElement:(NSXMLElement *)svgElement resultString:(NSMutableString *)resultString
{
    // set stroke color
    NSString * opacityString = @"1";
    
    NSXMLNode * opacityNode = [svgElement attributeForName:@"opacity"];
    if (opacityNode != NULL)
    {
        opacityString = opacityNode.stringValue;
    }

    NSString * strokeColorString = @"#000000";
    NSXMLNode * strokeColorNode = [svgElement attributeForName:@"stroke"];
    if (strokeColorNode != NULL)
    {
        strokeColorString = strokeColorNode.stringValue;
    }
    if (strokeColorString.length == 0)
    {
        strokeColorString = @"#000000";
    }
    strokeColorString = [self hexColorForColorName:strokeColorString];
    
    NSString * strokeNSColorString = [self colorStringForHexColor:strokeColorString opacity:opacityString];
    
    NSString * strokeColorVar = [self indexVarName:@"strokeColor"];
    [resultString appendFormat:@"\tNSColor * %@ = %@;\n", strokeColorVar, strokeNSColorString];
    
    [resultString appendFormat:@"\tCGContextSetStrokeColorWithColor(context, [%@ CGColor]);\n", strokeColorVar];
}

//==================================================================================
//	setFillColorForElement:resultString:
//==================================================================================

- (void)setFillColorForElement:(NSXMLElement *)svgElement resultString:(NSMutableString *)resultString
{
    // set fill color

    NSString * opacityString = @"1";
    
    NSXMLNode * opacityNode = [svgElement attributeForName:@"opacity"];
    if (opacityNode != NULL)
    {
        opacityString = opacityNode.stringValue;
    }
    NSString * fillColorString = @"#000000";
    NSXMLNode * fillColorNode = [svgElement attributeForName:@"fill"];
    if (fillColorNode != NULL)
    {
        fillColorString = fillColorNode.stringValue;
    }
    if (fillColorString.length == 0)
    {
        fillColorString = @"#000000";
    }
    fillColorString = [self hexColorForColorName:fillColorString];
    
    NSString * fillNSColorString = [self colorStringForHexColor:fillColorString opacity:opacityString];
    
    NSString * fillColorVar = [self indexVarName:@"fillColor"];
    [resultString appendFormat:@"\tNSColor * %@ = %@;\n", fillColorVar, fillNSColorString];
    [resultString appendFormat:@"\tCGContextSetFillColorWithColor(context, [%@ CGColor]);\n", fillColorVar];
}

//==================================================================================
//	gradientColorStringForHexColor:
//==================================================================================

- (NSString *)gradientColorStringForHexColor:(NSString *)hexColor opacity:(NSString *)opacity
{
    NSString * resultString = @"[NSColor colorWithRed:0 green:0 blue:0 alpha:1]";
    
    if (hexColor.length == 7)
    {
        unichar firstChar = [hexColor characterAtIndex:0];
        
        if (firstChar == '#')
        {
            NSString * redHex = [hexColor substringWithRange:NSMakeRange(1, 2)];
            NSString * greenHex = [hexColor substringWithRange:NSMakeRange(3, 2)];
            NSString * blueHex = [hexColor substringWithRange:NSMakeRange(5, 2)];
            
            NSString * redDecimalString = [self getDecimalValueWithHex:redHex];
            NSString * greenDecimalString = [self getDecimalValueWithHex:greenHex];
            NSString * blueDecimalString = [self getDecimalValueWithHex:blueHex];
            
            NSInteger redInteger = redDecimalString.integerValue;
            NSInteger greenInteger = greenDecimalString.integerValue;
            NSInteger blueInteger = blueDecimalString.integerValue;
            
            CGFloat redFloat = (CGFloat)redInteger / 255.0f;
            CGFloat greenFloat = (CGFloat)greenInteger / 255.0f;
            CGFloat blueFloat = (CGFloat)blueInteger / 255.0f;
            
            NSString * redFloatString = [self allocFloatString:redFloat];
            NSString * greenFloatString = [self allocFloatString:greenFloat];
            NSString * blueFloatString = [self allocFloatString:blueFloat];
            
            resultString = [NSString stringWithFormat:@"%@, %@, %@, %@",
                    redFloatString, greenFloatString, blueFloatString, opacity];
        }
    }
    
    return resultString;
}

//==================================================================================
//	colorStringForHexColor:
//==================================================================================

- (NSString *)colorStringForHexColor:(NSString *)hexColor opacity:(NSString *)opacity
{
    NSString * resultString = @"[NSColor colorWithRed:0 green:0 blue:0 alpha:1]";
    
    if (hexColor.length == 7)
    {
        unichar firstChar = [hexColor characterAtIndex:0];
        
        if (firstChar == '#')
        {
            NSString * redHex = [hexColor substringWithRange:NSMakeRange(1, 2)];
            NSString * greenHex = [hexColor substringWithRange:NSMakeRange(3, 2)];
            NSString * blueHex = [hexColor substringWithRange:NSMakeRange(5, 2)];
            
            NSString * redDecimalString = [self getDecimalValueWithHex:redHex];
            NSString * greenDecimalString = [self getDecimalValueWithHex:greenHex];
            NSString * blueDecimalString = [self getDecimalValueWithHex:blueHex];
            
            NSInteger redInteger = redDecimalString.integerValue;
            NSInteger greenInteger = greenDecimalString.integerValue;
            NSInteger blueInteger = blueDecimalString.integerValue;
            
            CGFloat redFloat = (CGFloat)redInteger / 255.0f;
            CGFloat greenFloat = (CGFloat)greenInteger / 255.0f;
            CGFloat blueFloat = (CGFloat)blueInteger / 255.0f;
            
            NSString * redFloatString = [self allocFloatString:redFloat];
            NSString * greenFloatString = [self allocFloatString:greenFloat];
            NSString * blueFloatString = [self allocFloatString:blueFloat];
            
            resultString = [NSString stringWithFormat:@"[NSColor colorWithRed:%@ green:%@ blue:%@ alpha:%@]",
                    redFloatString, greenFloatString, blueFloatString, opacity];
        }
    }
    
    return resultString;
}

//==================================================================================
//	getDecimalValueWithHex:
//==================================================================================

- (NSString *)getDecimalValueWithHex:(NSString *)hexString
{
    unichar hexHigh = [hexString characterAtIndex:0];
    unichar hexLow = [hexString characterAtIndex:1];
    
    NSInteger decimalHigh = 0;
    NSInteger decimalLow = 0;
    
    if ((hexHigh >= '0') && (hexHigh <= '9'))
    {
        decimalHigh = (hexHigh - '0') * 16;
    }
    else if ((hexHigh >= 'A') && (hexHigh <= 'F'))
    {
        decimalHigh = (hexHigh - 'A') + 10;
        decimalHigh *= 16;
    }
    else if ((hexHigh >= 'a') && (hexHigh <= 'f'))
    {
        decimalHigh = (hexHigh - 'a') + 10;
        decimalHigh *= 16;
    }

    if ((hexLow >= '0') && (hexLow <= '9'))
    {
        decimalLow = hexLow - '0';
    }
    else if ((hexLow >= 'A') && (hexLow <= 'F'))
    {
        decimalLow = (hexLow - 'A') + 10;
    
    }
    else if ((hexLow >= 'a') && (hexLow <= 'f'))
    {
        decimalLow = (hexLow - 'a') + 10;
    }

    NSInteger result = decimalHigh + decimalLow;
    NSString * resultString = [NSString stringWithFormat:@"%ld", result];
    
    return resultString;
}

//==================================================================================
//	allocFloatString:
//==================================================================================

- (NSMutableString *)allocFloatString:(float)aFloat
{
    NSMutableString * aString = [[NSMutableString alloc] initWithFormat:@"%f", aFloat];

    BOOL continueTrim = YES;
    while (continueTrim == YES)
    {
        NSUInteger stringLength = aString.length;
        
        if (stringLength <= 1)
        {
            continueTrim = NO;
        }
        else
        {
            unichar lastChar = [aString characterAtIndex:(stringLength - 1)];
            
            if (lastChar == '0')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
            }
            else if (lastChar == '.')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
                continueTrim = NO;
            }
            else
            {
                continueTrim = NO;
            }
        }
    }
    return aString;
}

//==================================================================================
//	allocPxString:
//==================================================================================

- (NSMutableString *)allocPxString:(float)aFloat
{
    NSMutableString * aString = [[NSMutableString alloc] initWithFormat:@"%f", aFloat];

    BOOL continueTrim = YES;
    while (continueTrim == YES)
    {
        NSUInteger stringLength = aString.length;
        
        if (stringLength <= 1)
        {
            continueTrim = NO;
        }
        else
        {
            unichar lastChar = [aString characterAtIndex:(stringLength - 1)];
            
            if (lastChar == '0')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
            }
            else if (lastChar == '.')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
                continueTrim = NO;
            }
            else
            {
                continueTrim = NO;
            }
        }
    }
    
    [aString appendString:@"px"];
    
    return aString;
}

//==================================================================================
//	hexColorForColorName:
//==================================================================================

- (NSString *)hexColorForColorName:(NSString *)colorName
{
    NSString * resultName = colorName;

    unichar colorFirstCharacter = [colorName characterAtIndex:0];

    if (colorFirstCharacter == '#')
    {
        if (colorName.length == 4)
        {
            unichar digit1 = [colorName characterAtIndex:1];
            unichar digit2 = [colorName characterAtIndex:2];
            unichar digit3 = [colorName characterAtIndex:3];
        
            resultName = [NSString stringWithFormat:@"#%C%C%C%C%C%C",
                    digit1, digit1, digit2, digit2, digit3, digit3];
        }
    }
    else
    {
        for (NSDictionary * aColorDictionary in self.webColorsArray)
        {
            NSString * aColorName = aColorDictionary[@"name"];
            
            if ([colorName isEqualToString:aColorName] == YES)
            {
                resultName  = aColorDictionary[@"hex"];
                break;
            }
        }
    }
    
    return resultName;
}

//==================================================================================
//	addWebColorName:hex:rgb:
//==================================================================================

- (void)addWebColorName:(NSString *)colorName hex:(NSString *)hex rgb:(NSString *)rgb
{
    NSDictionary * colorDictionary = @{@"name": colorName,
            @"hex": hex,
            @"rgb": rgb};
            
    [self.webColorsArray addObject:colorDictionary];
    
}

//==================================================================================
//	buildWebColorsArray
//==================================================================================

- (void)buildWebColorsArray
{
    self.webColorsArray = [[NSMutableArray alloc] init];

    [self addWebColorName:@"aliceblue" hex:@"#f0f8ff" rgb:@"240,248,255"];
    [self addWebColorName:@"antiquewhite" hex:@"#faebd7" rgb:@"250,235,215"];
    [self addWebColorName:@"aqua" hex:@"#00ffff" rgb:@"0,255,255"];
    [self addWebColorName:@"aquamarine" hex:@"#7fffd4" rgb:@"127,255,212"];
    [self addWebColorName:@"azure" hex:@"#f0ffff" rgb:@"240,255,255"];
    [self addWebColorName:@"beige" hex:@"#f5f5dc" rgb:@"245,245,220"];
    [self addWebColorName:@"bisque" hex:@"#ffe4c4" rgb:@"255,228,196"];
    [self addWebColorName:@"black" hex:@"#000000" rgb:@"0,0,0"];
    [self addWebColorName:@"blanchedalmond" hex:@"#ffebcd" rgb:@"255,235,205"];
    [self addWebColorName:@"blue" hex:@"#0000ff" rgb:@"0,0,255"];
    [self addWebColorName:@"blueviolet" hex:@"#8a2be2" rgb:@"138,43,226"];
    [self addWebColorName:@"brown" hex:@"#a52a2a" rgb:@"165,42,42"];
    [self addWebColorName:@"burlywood" hex:@"#deb887" rgb:@"222,184,135"];
    [self addWebColorName:@"cadetblue" hex:@"#5f9ea0" rgb:@"95,158,160"];
    [self addWebColorName:@"chartreuse" hex:@"#7fff00" rgb:@"127,255,0"];
    [self addWebColorName:@"chocolate" hex:@"#d2691e" rgb:@"210,105,30"];
    [self addWebColorName:@"coral" hex:@"#ff7f50" rgb:@"255,127,80"];
    [self addWebColorName:@"cornflowerblue" hex:@"#6495ed" rgb:@"100,149,237"];
    [self addWebColorName:@"cornsilk" hex:@"#fff8dc" rgb:@"255,248,220"];
    [self addWebColorName:@"crimson" hex:@"#dc143c" rgb:@"220,20,60"];
    [self addWebColorName:@"cyan" hex:@"#00ffff" rgb:@"0,255,255"];
    [self addWebColorName:@"darkblue" hex:@"#00008b" rgb:@"0,0,139"];
    [self addWebColorName:@"darkcyan" hex:@"#008b8b" rgb:@"0,139,139"];
    [self addWebColorName:@"darkgoldenrod" hex:@"#b8860b" rgb:@"184,134,11"];
    [self addWebColorName:@"darkgray" hex:@"#a9a9a9" rgb:@"169,169,169"];
    [self addWebColorName:@"darkgreen" hex:@"#006400" rgb:@"0,100,0"];
    [self addWebColorName:@"darkgrey" hex:@"#a9a9a9" rgb:@"169,169,169"];
    [self addWebColorName:@"darkkhaki" hex:@"#bdb76b" rgb:@"189,183,107"];
    [self addWebColorName:@"darkmagenta" hex:@"#8b008b" rgb:@"139,0,139"];
    [self addWebColorName:@"darkolivegreen" hex:@"#556b2f" rgb:@"85,107,47"];
    [self addWebColorName:@"darkorange" hex:@"#ff8c00" rgb:@"255,140,0"];
    [self addWebColorName:@"darkorchid" hex:@"#9932cc" rgb:@"153,50,204"];
    [self addWebColorName:@"darkred" hex:@"#8b0000" rgb:@"139,0,0"];
    [self addWebColorName:@"darksalmon" hex:@"#e9967a" rgb:@"233,150,122"];
    [self addWebColorName:@"darkseagreen" hex:@"#8fbc8f" rgb:@"143,188,143"];
    [self addWebColorName:@"darkslateblue" hex:@"#483d8b" rgb:@"72,61,139"];
    [self addWebColorName:@"darkslategray" hex:@"#2f4f4f" rgb:@"47,79,79"];
    [self addWebColorName:@"darkslategrey" hex:@"#2f4f4f" rgb:@"47,79,79"];
    [self addWebColorName:@"darkturquoise" hex:@"#00ced1" rgb:@"0,206,209"];
    [self addWebColorName:@"darkviolet" hex:@"#9400d3" rgb:@"148,0,211"];
    [self addWebColorName:@"deeppink" hex:@"#ff1493" rgb:@"255,20,147"];
    [self addWebColorName:@"deepskyblue" hex:@"#00bfff" rgb:@"0,191,255"];
    [self addWebColorName:@"dimgray" hex:@"#696969" rgb:@"105,105,105"];
    [self addWebColorName:@"dimgrey" hex:@"#696969" rgb:@"105,105,105"];
    [self addWebColorName:@"dodgerblue" hex:@"#1e90ff" rgb:@"30,144,255"];
    [self addWebColorName:@"firebrick" hex:@"#b22222" rgb:@"178,34,34"];
    [self addWebColorName:@"floralwhite" hex:@"#fffaf0" rgb:@"255,250,240"];
    [self addWebColorName:@"forestgreen" hex:@"#228b22" rgb:@"34,139,34"];
    [self addWebColorName:@"fuchsia" hex:@"#ff00ff" rgb:@"255,0,255"];
    [self addWebColorName:@"gainsboro" hex:@"#dcdcdc" rgb:@"220,220,220"];
    [self addWebColorName:@"ghostwhite" hex:@"#f8f8ff" rgb:@"248,248,255"];
    [self addWebColorName:@"gold" hex:@"#ffd700" rgb:@"255,215,0"];
    [self addWebColorName:@"goldenrod" hex:@"#daa520" rgb:@"218,165,32"];
    [self addWebColorName:@"gray" hex:@"#808080" rgb:@"128,128,128"];
    [self addWebColorName:@"green" hex:@"#008000" rgb:@"0,128,0"];
    [self addWebColorName:@"greenyellow" hex:@"#adff2f" rgb:@"173,255,47"];
    [self addWebColorName:@"grey" hex:@"#808080" rgb:@"128,128,128"];
    [self addWebColorName:@"honeydew" hex:@"#f0fff0" rgb:@"240,255,240"];
    [self addWebColorName:@"hotpink" hex:@"#ff69b4" rgb:@"255,105,180"];
    [self addWebColorName:@"indianred" hex:@"#cd5c5c" rgb:@"205,92,92"];
    [self addWebColorName:@"indigo" hex:@"#4b0082" rgb:@"75,0,130"];
    [self addWebColorName:@"ivory" hex:@"#fffff0" rgb:@"255,255,240"];
    [self addWebColorName:@"khaki" hex:@"#f0e68c" rgb:@"240,230,140"];
    [self addWebColorName:@"lavender" hex:@"#e6e6fa" rgb:@"230,230,250"];
    [self addWebColorName:@"lavenderblush" hex:@"#fff0f5" rgb:@"255,240,245"];
    [self addWebColorName:@"lawngreen" hex:@"#7cfc00" rgb:@"124,252,0"];
    [self addWebColorName:@"lemonchiffon" hex:@"#fffacd" rgb:@"255,250,205"];
    [self addWebColorName:@"lightblue" hex:@"#add8e6" rgb:@"173,216,230"];
    [self addWebColorName:@"lightcoral" hex:@"#f08080" rgb:@"240,128,128"];
    [self addWebColorName:@"lightcyan" hex:@"#e0ffff" rgb:@"224,255,255"];
    [self addWebColorName:@"lightgoldenrodyellow" hex:@"#fafad2" rgb:@"250,250,210"];
    [self addWebColorName:@"lightgray" hex:@"#d3d3d3" rgb:@"211,211,211"];
    [self addWebColorName:@"lightgreen" hex:@"#90ee90" rgb:@"144,238,144"];
    [self addWebColorName:@"lightgrey" hex:@"#d3d3d3" rgb:@"211,211,211"];
    [self addWebColorName:@"lightpink" hex:@"#ffb6c1" rgb:@"255,182,193"];
    [self addWebColorName:@"lightsalmon" hex:@"#ffa07a" rgb:@"255,160,122"];
    [self addWebColorName:@"lightseagreen" hex:@"#20b2aa" rgb:@"32,178,170"];
    [self addWebColorName:@"lightskyblue" hex:@"#87cefa" rgb:@"135,206,250"];
    [self addWebColorName:@"lightslategray" hex:@"#778899" rgb:@"119,136,153"];
    [self addWebColorName:@"lightslategrey" hex:@"#778899" rgb:@"119,136,153"];
    [self addWebColorName:@"lightsteelblue" hex:@"#b0c4de" rgb:@"176,196,222"];
    [self addWebColorName:@"lightyellow" hex:@"#ffffe0" rgb:@"255,255,224"];
    [self addWebColorName:@"lime" hex:@"#00ff00" rgb:@"0,255,0"];
    [self addWebColorName:@"limegreen" hex:@"#32cd32" rgb:@"50,205,50"];
    [self addWebColorName:@"linen" hex:@"#faf0e6" rgb:@"250,240,230"];
    [self addWebColorName:@"magenta" hex:@"#ff00ff" rgb:@"255,0,255"];
    [self addWebColorName:@"maroon" hex:@"#800000" rgb:@"128,0,0"];
    [self addWebColorName:@"mediumaquamarine" hex:@"#66cdaa" rgb:@"102,205,170"];
    [self addWebColorName:@"mediumblue" hex:@"#0000cd" rgb:@"0,0,205"];
    [self addWebColorName:@"mediumorchid" hex:@"#ba55d3" rgb:@"186,85,211"];
    [self addWebColorName:@"mediumpurple" hex:@"#9370db" rgb:@"147,112,219"];
    [self addWebColorName:@"mediumseagreen" hex:@"#3cb371" rgb:@"60,179,113"];
    [self addWebColorName:@"mediumslateblue" hex:@"#7b68ee" rgb:@"123,104,238"];
    [self addWebColorName:@"mediumspringgreen" hex:@"#00fa9a" rgb:@"0,250,154"];
    [self addWebColorName:@"mediumturquoise" hex:@"#48d1cc" rgb:@"72,209,204"];
    [self addWebColorName:@"mediumvioletred" hex:@"#c71585" rgb:@"199,21,133"];
    [self addWebColorName:@"midnightblue" hex:@"#191970" rgb:@"25,25,112"];
    [self addWebColorName:@"mintcream" hex:@"#f5fffa" rgb:@"245,255,250"];
    [self addWebColorName:@"mistyrose" hex:@"#ffe4e1" rgb:@"255,228,225"];
    [self addWebColorName:@"moccasin" hex:@"#ffe4b5" rgb:@"255,228,181"];
    [self addWebColorName:@"navajowhite" hex:@"#ffdead" rgb:@"255,222,173"];
    [self addWebColorName:@"navy" hex:@"#000080" rgb:@"0,0,128"];
    [self addWebColorName:@"oldlace" hex:@"#fdf5e6" rgb:@"253,245,230"];
    [self addWebColorName:@"olive" hex:@"#808000" rgb:@"128,128,0"];
    [self addWebColorName:@"olivedrab" hex:@"#6b8e23" rgb:@"107,142,35"];
    [self addWebColorName:@"orange" hex:@"#ffa500" rgb:@"255,165,0"];
    [self addWebColorName:@"orangered" hex:@"#ff4500" rgb:@"255,69,0"];
    [self addWebColorName:@"orchid" hex:@"#da70d6" rgb:@"218,112,214"];
    [self addWebColorName:@"palegoldenrod" hex:@"#eee8aa" rgb:@"238,232,170"];
    [self addWebColorName:@"palegreen" hex:@"#98fb98" rgb:@"152,251,152"];
    [self addWebColorName:@"paleturquoise" hex:@"#afeeee" rgb:@"175,238,238"];
    [self addWebColorName:@"palevioletred" hex:@"#db7093" rgb:@"219,112,147"];
    [self addWebColorName:@"papayawhip" hex:@"#ffefd5" rgb:@"255,239,213"];
    [self addWebColorName:@"peachpuff" hex:@"#ffdab9" rgb:@"255,218,185"];
    [self addWebColorName:@"peru" hex:@"#cd853f" rgb:@"205,133,63"];
    [self addWebColorName:@"pink" hex:@"#ffc0cb" rgb:@"255,192,203"];
    [self addWebColorName:@"plum" hex:@"#dda0dd" rgb:@"221,160,221"];
    [self addWebColorName:@"powderblue" hex:@"#b0e0e6" rgb:@"176,224,230"];
    [self addWebColorName:@"purple" hex:@"#800080" rgb:@"128,0,128"];
    [self addWebColorName:@"red" hex:@"#ff0000" rgb:@"255,0,0"];
    [self addWebColorName:@"rosybrown" hex:@"#bc8f8f" rgb:@"188,143,143"];
    [self addWebColorName:@"royalblue" hex:@"#4169e1" rgb:@"65,105,225"];
    [self addWebColorName:@"saddlebrown" hex:@"#8b4513" rgb:@"139,69,19"];
    [self addWebColorName:@"salmon" hex:@"#fa8072" rgb:@"250,128,114"];
    [self addWebColorName:@"sandybrown" hex:@"#f4a460" rgb:@"244,164,96"];
    [self addWebColorName:@"seagreen" hex:@"#2e8b57" rgb:@"46,139,87"];
    [self addWebColorName:@"seashell" hex:@"#fff5ee" rgb:@"255,245,238"];
    [self addWebColorName:@"sienna" hex:@"#a0522d" rgb:@"160,82,45"];
    [self addWebColorName:@"silver" hex:@"#c0c0c0" rgb:@"192,192,192"];
    [self addWebColorName:@"skyblue" hex:@"#87ceeb" rgb:@"135,206,235"];
    [self addWebColorName:@"slateblue" hex:@"#6a5acd" rgb:@"106,90,205"];
    [self addWebColorName:@"slategray" hex:@"#708090" rgb:@"112,128,144"];
    [self addWebColorName:@"slategrey" hex:@"#708090" rgb:@"112,128,144"];
    [self addWebColorName:@"snow" hex:@"#fffafa" rgb:@"255,250,250"];
    [self addWebColorName:@"springgreen" hex:@"#00ff7f" rgb:@"0,255,127"];
    [self addWebColorName:@"steelblue" hex:@"#4682b4" rgb:@"70,130,180"];
    [self addWebColorName:@"tan" hex:@"#d2b48c" rgb:@"210,180,140"];
    [self addWebColorName:@"teal" hex:@"#008080" rgb:@"0,128,128"];
    [self addWebColorName:@"thistle" hex:@"#d8bfd8" rgb:@"216,191,216"];
    [self addWebColorName:@"tomato" hex:@"#ff6347" rgb:@"255,99,71"];
    [self addWebColorName:@"turquoise" hex:@"#40e0d0" rgb:@"64,224,208"];
    [self addWebColorName:@"violet" hex:@"#ee82ee" rgb:@"238,130,238"];
    [self addWebColorName:@"wheat" hex:@"#f5deb3" rgb:@"245,222,179"];
    [self addWebColorName:@"white" hex:@"#ffffff" rgb:@"255,255,255"];
    [self addWebColorName:@"whitesmoke" hex:@"#f5f5f5" rgb:@"245,245,245"];
    [self addWebColorName:@"yellow" hex:@"#ffff00" rgb:@"255,255,0"];
    [self addWebColorName:@"yellowgreen" hex:@"#9acd32" rgb:@"154,205,50"];
}


@end
