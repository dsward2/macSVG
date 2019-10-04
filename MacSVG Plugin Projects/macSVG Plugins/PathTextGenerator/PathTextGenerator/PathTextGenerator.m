//
//  PathTextGenerator.m
//  PathTextGenerator
//
//  Created by Douglas Ward on 9/25/17.
//  Copyright © 2017 ArkPhone LLC. All rights reserved.
//

//  based on -
//  TextToSvgPath
//
//  Created by Garth Minette on 7/24/11.
//  Copyright 2011 Belfry DevWorks. All rights reserved.
//

#import "PathTextGenerator.h"
#import "PathTextGeneratorWindowController.h"
#import "NSBezierPath+EMMBezierPath.h"

@implementation PathTextGenerator

//==================================================================================
//	pluginMenuTitle
//==================================================================================

- (NSString *)pluginMenuTitle
{
    return @"Path Text Generator";    // override for menu plugins
}

//==================================================================================
//	isMenuPlugIn
//==================================================================================

- (BOOL) isMenuPlugIn
{
    return YES;
}

//==================================================================================
//	beginMenuPlugIn
//==================================================================================

- (BOOL)beginMenuPlugIn
{
    // for menu plug-ins
    if (pathTextGeneratorWindowController.window == NULL)
    {
        NSString * pluginNameString = self.className;
        NSArray * topLevelObjects = NULL;

        NSString * bundlePath = [NSBundle bundleForClass:[self class]].bundlePath;

        NSBundle * pluginBundle = [NSBundle bundleWithPath:bundlePath];

        BOOL result = [pluginBundle loadNibNamed:pluginNameString owner:self topLevelObjects:&topLevelObjects];
        #pragma unused(result)
    }
    
    [pathTextGeneratorWindowController setupFontsBrowser];

    [[NSApplication sharedApplication] runModalForWindow:pathTextGeneratorWindowController.window];

    return YES;
}

//==================================================================================
//	createPathWithString:font:fontSize:originX:originY:
//==================================================================================

- (NSXMLElement *)createPathWithString:(NSString *)pathTextString
        font:(NSFont *)font fontSize:(CGFloat)fontSize
        originX:(CGFloat)originX originY:(CGFloat)originY
{
    NSXMLElement * resultElement = NULL;

    NSLayoutManager *aLayoutManager = [[NSLayoutManager alloc] init];
    NSFont * screenFont = [aLayoutManager substituteFontForFont:font];
    
    NSBezierPath *bezierPath = [NSBezierPath bezierPath];
    [bezierPath moveToPoint:(NSPoint){originX, -originY}];
    [bezierPath appendBezierPathWithString:pathTextString font:screenFont];
    [bezierPath transformIntoSVGCoordinateSpaceWithOffset:NSMakePoint(0, 0)];

    NSMutableString * outStr = [NSMutableString string];
    NSInteger elements = [bezierPath elementCount];
    for (int i = 0; i < elements; i++) {
        NSPoint points[3];
        
        if (i != 0) {
            [outStr appendString:@" "];
        }
        switch ([bezierPath elementAtIndex:i associatedPoints:points]) {
            case NSMoveToBezierPathElement:
                // MoveTo
                if (i < elements-1) {
                    [outStr appendFormat:@"M %.1f %.1f", points[0].x, points[0].y];
                }
                break;
            case NSLineToBezierPathElement:
                // LineTo
                [outStr appendFormat:@"L %.1f %.1f", points[0].x, points[0].y];
                break;
            case NSCurveToBezierPathElement:
                // CurveTo
                [outStr appendFormat:@"C %.1f %.1f %.1f %.1f %.1f %.1f",
                    points[0].x, points[0].y,
                    points[1].x, points[1].y,
                    points[2].x, points[2].y];
                break;
            case NSClosePathBezierPathElement:
                // ClosePath
                [outStr appendString:@"Z"];
                break;
        }
    }
    
    resultElement = [self xmlPathElementWithPathData:outStr];

    [self assignMacsvgidsForNode:resultElement];
    
    NSInteger selectedRow = (self.svgXmlOutlineView).selectedRow;
    NSXMLElement * parentElement = NULL;
    NSInteger childIndex = -1;
    
    if (selectedRow != -1)
    {
        NSXMLNode * selectedNode = [self.svgXmlOutlineView itemAtRow:selectedRow];
        NSXMLNode * parentNode = selectedNode;
        childIndex = parentNode.index + 1;
        
        BOOL continueSearch = YES;
        while (continueSearch == YES)
        {
            if (parentNode.kind == NSXMLElementKind)
            {
                NSString * selectedNodeName = parentNode.name;
                
                if ([selectedNodeName isEqualToString:@"g"] == YES)
                {
                    parentElement = (NSXMLElement *)parentNode;
                    continueSearch = NO;
                }
                else if ([selectedNodeName isEqualToString:@"svg"] == YES)
                {
                    parentElement = (NSXMLElement *)parentNode;
                    continueSearch = NO;
                }
            }
            
            if (continueSearch == YES)
            {
                childIndex = parentNode.index + 1;
                parentNode = parentNode.parent;
                if (parentNode == NULL)
                {
                    parentElement = [self.svgXmlOutlineView itemAtRow:0];
                    childIndex = -1;
                    continueSearch = NO;
                }
            }
        }
    }
    else
    {
        parentElement = [self.svgXmlOutlineView itemAtRow:0];
        childIndex = -1;
    }

    if (childIndex != -1)
    {
        if (childIndex < parentElement.childCount)
        {
            [parentElement insertChild:resultElement atIndex:childIndex];
        }
        else
        {
            [parentElement addChild:resultElement];
        }
    }
    else
    {
        [parentElement addChild:resultElement];
    }
    
    [self updateDocumentViews];
    
    return resultElement;
}


//==================================================================================
//	createMultiplePathsWithString:font:fontSize:originX:originY:
//==================================================================================

- (NSXMLElement *)createMultiplePathsWithString:(NSString *)pathTextString
        font:(NSFont *)font fontSize:(CGFloat)fontSize
        originX:(CGFloat)originX originY:(CGFloat)originY
{
    NSInteger pathTextStringLength = pathTextString.length;
    
    
    NSXMLElement * textPathGroupElement = [[NSXMLElement alloc] init];
    textPathGroupElement.name = @"g";
    NSXMLNode * groupIdAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    groupIdAttribute.name = @"id";
    groupIdAttribute.stringValue = @"textToPathGroup";
    [textPathGroupElement addAttribute:groupIdAttribute];

    NSLayoutManager *aLayoutManager = [[NSLayoutManager alloc] init];
    NSFont * screenFont = [aLayoutManager substituteFontForFont:font];

    NSPoint currentPoint = (NSPoint){originX, -originY};
    
    for (NSInteger charIndex = 0; charIndex < pathTextStringLength; charIndex++)
    {
        unichar aChar = [pathTextString characterAtIndex:charIndex];
        
        NSString * aCharString = [NSString stringWithFormat:@"%C", aChar];
    
        NSBezierPath * bezierPath = [NSBezierPath bezierPath];
        
        //[bezierPath moveToPoint:currentPoint];
        [bezierPath moveToPoint:NSMakePoint(currentPoint.x, 0)];
        
        //CGFloat xAdvancement = [bezierPath appendBezierPathWithString:aCharString font:font];
        CGFloat xAdvancement = [bezierPath appendBezierPathWithString:aCharString font:screenFont];
        
        currentPoint.x += xAdvancement;
        
        [bezierPath transformIntoSVGCoordinateSpaceWithOffset:currentPoint];

        NSMutableString * outStr = [NSMutableString string];
        NSInteger elements = [bezierPath elementCount];
        for (int i = 0; i < elements; i++) {
            NSPoint points[3];
            
            if (i != 0) {
                [outStr appendString:@" "];
            }
            switch ([bezierPath elementAtIndex:i associatedPoints:points]) {
                case NSMoveToBezierPathElement:
                    // MoveTo
                    if (i < elements-1) {
                        [outStr appendFormat:@"M %.1f %.1f", points[0].x, points[0].y];
                    }
                    break;
                case NSLineToBezierPathElement:
                    // LineTo
                    [outStr appendFormat:@"L %.1f %.1f", points[0].x, points[0].y];
                    break;
                case NSCurveToBezierPathElement:
                    // CurveTo
                    [outStr appendFormat:@"C %.1f %.1f %.1f %.1f %.1f %.1f",
                        points[0].x, points[0].y,
                        points[1].x, points[1].y,
                        points[2].x, points[2].y];
                    break;
                case NSClosePathBezierPathElement:
                    // ClosePath
                    [outStr appendString:@"Z"];
                    break;
            }
        }
        
        //NSXMLElement * aPathElement = [self xmlPathElementWithPathData:outStr];

        NSXMLElement * pathElement = [self newPathElement];
        
        NSXMLNode * pathDataAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        pathDataAttribute.name = @"d";
        pathDataAttribute.stringValue = outStr;
        [pathElement addAttribute:pathDataAttribute];

        NSString * idString = [NSString stringWithFormat:@"textToPath-%d", 0];

        NSXMLNode * idAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        idAttribute.name = @"id";
        idAttribute.stringValue = idString;
        [pathElement addAttribute:idAttribute];
        
        [textPathGroupElement addChild:pathElement];
    }

    [self assignMacsvgidsForNode:textPathGroupElement];
    
    NSInteger selectedRow = (self.svgXmlOutlineView).selectedRow;
    NSXMLElement * parentElement = NULL;
    NSInteger childIndex = -1;
    
    if (selectedRow != -1)
    {
        NSXMLNode * selectedNode = [self.svgXmlOutlineView itemAtRow:selectedRow];
        NSXMLNode * parentNode = selectedNode;
        childIndex = parentNode.index + 1;
        
        BOOL continueSearch = YES;
        while (continueSearch == YES)
        {
            if (parentNode.kind == NSXMLElementKind)
            {
                NSString * selectedNodeName = parentNode.name;
                
                if ([selectedNodeName isEqualToString:@"g"] == YES)
                {
                    parentElement = (NSXMLElement *)parentNode;
                    continueSearch = NO;
                }
                else if ([selectedNodeName isEqualToString:@"svg"] == YES)
                {
                    parentElement = (NSXMLElement *)parentNode;
                    continueSearch = NO;
                }
            }
            
            if (continueSearch == YES)
            {
                childIndex = parentNode.index + 1;
                parentNode = parentNode.parent;
                if (parentNode == NULL)
                {
                    parentElement = [self.svgXmlOutlineView itemAtRow:0];
                    childIndex = -1;
                    continueSearch = NO;
                }
            }
        }
    }
    else
    {
        parentElement = [self.svgXmlOutlineView itemAtRow:0];
        childIndex = -1;
    }

    if (childIndex != -1)
    {
        if (childIndex < parentElement.childCount)
        {
            [parentElement insertChild:textPathGroupElement atIndex:childIndex];
        }
        else
        {
            [parentElement addChild:textPathGroupElement];
        }
    }
    else
    {
        [parentElement addChild:textPathGroupElement];
    }
    
    [self updateDocumentViews];
    
    return textPathGroupElement;
}

//==================================================================================
//	xmlPathElementWithPathData:
//==================================================================================

- (NSXMLElement *)xmlPathElementWithPathData:(NSString *)pathData
{
    NSXMLElement * textPathGroupElement = [[NSXMLElement alloc] init];
    textPathGroupElement.name = @"g";
    NSXMLNode * groupIdAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    groupIdAttribute.name = @"id";
    groupIdAttribute.stringValue = @"textToPathGroup";
    [textPathGroupElement addAttribute:groupIdAttribute];

    NSXMLElement * pathElement = [self newPathElement];
    
    NSXMLNode * pathDataAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    pathDataAttribute.name = @"d";
    pathDataAttribute.stringValue = pathData;
    [pathElement addAttribute:pathDataAttribute];

    NSString * idString = [NSString stringWithFormat:@"textToPath-%d", 0];

    NSXMLNode * idAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    idAttribute.name = @"id";
    idAttribute.stringValue = idString;
    [pathElement addAttribute:idAttribute];
    
    [textPathGroupElement addChild:pathElement];

    return textPathGroupElement;
}

//==================================================================================
//	newPathElement
//==================================================================================

- (NSXMLElement *)newPathElement
{
    NSXMLElement * pathElement = [[NSXMLElement alloc] init];
    pathElement.name = @"path";
    
    NSXMLNode * strokeAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    strokeAttribute.name = @"stroke";
    strokeAttribute.stringValue = @"none";
    [pathElement addAttribute:strokeAttribute];

    NSXMLNode * strokeWidthAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    strokeWidthAttribute.name = @"stroke-width";
    strokeWidthAttribute.stringValue = @"1";
    [pathElement addAttribute:strokeWidthAttribute];

    NSXMLNode * fillAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    fillAttribute.name = @"fill";
    fillAttribute.stringValue = @"black";
    [pathElement addAttribute:fillAttribute];

    NSXMLNode * transformAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    transformAttribute.name = @"transform";
    transformAttribute.stringValue = @"";
    [pathElement addAttribute:transformAttribute];

    return pathElement;
}



@end
