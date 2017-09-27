//
//  PieChartGenerator.m
//  PieChartGenerator
//
//  Created by Douglas Ward on 10/5/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "PieChartGenerator.h"
#import "PieChartGeneratorWindowController.h"

@implementation PieChartGenerator

//==================================================================================
//	pluginMenuTitle
//==================================================================================

- (NSString *)pluginMenuTitle
{
    return @"Pie Chart Generator";    // override for menu plugins
}

//==================================================================================
//	isMenuPlugIn
//==================================================================================

- (BOOL) isMenuPlugIn
{
    return YES;
}

//==================================================================================
//	beginMenuPlugInForSelectedXMLItems:
//==================================================================================

- (BOOL)beginMenuPlugIn
{
    // for menu plug-ins
    if (pieChartGeneratorWindowController.window == NULL)
    {
        NSString * pluginNameString = self.className;
        NSArray * topLevelObjects = NULL;

        NSString * bundlePath = [NSBundle bundleForClass:[self class]].bundlePath;

        NSBundle * pluginBundle = [NSBundle bundleWithPath:bundlePath];

        BOOL result = [pluginBundle loadNibNamed:pluginNameString owner:self topLevelObjects:&topLevelObjects];
        #pragma unused(result)
    }

    [[NSApplication sharedApplication] runModalForWindow:pieChartGeneratorWindowController.window];

    return YES;
}

//==================================================================================
//	createPieChartWithValues:centerX:centerY:radius:
//==================================================================================

- (void)createPieChartWithValues:(NSString *)pieChartValuesString
        centerX:(NSString *)centerXString centerY:(NSString *)centerYString
        radius:(NSString *)radiusString
{
    NSCharacterSet * arrayCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" ,;\n\r"];
    NSArray * unfilteredValuesArray = [pieChartValuesString componentsSeparatedByCharactersInSet:arrayCharacterSet];
    
    NSMutableArray * valuesArray = [NSMutableArray array];
    
    for (NSString * aValue in unfilteredValuesArray)
    {
        if (aValue.floatValue > 0.0f)
        {
            [valuesArray addObject:aValue];
        }
    }

    float valuesTotal = 0;
    
    for (NSString * aValue in valuesArray)
    {
        valuesTotal += aValue.floatValue;
    }
    
    NSMutableArray * anglesArray = [NSMutableArray array];

    NSInteger valuesArrayCount = valuesArray.count;
    for (NSInteger i = 0; i < valuesArrayCount; i++)
    {
        NSString * aValue = valuesArray[i];
        float aValueFloat = aValue.floatValue;
        float angle = ceilf(360 * aValueFloat / valuesTotal);
        NSNumber * angleNumber = @(angle);
        [anglesArray addObject:angleNumber];
    }
    
    NSInteger anglesArrayCount = anglesArray.count;
    
    
    float startAngle = 0;
    float endAngle = 0;
    float centerX = centerXString.floatValue;
    float centerY = centerYString.floatValue;
    float radius = radiusString.floatValue;
    
    NSXMLElement * pieChartGroupElement = [[NSXMLElement alloc] init];
    pieChartGroupElement.name = @"g";
    NSXMLNode * groupIdAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    groupIdAttribute.name = @"id";
    groupIdAttribute.stringValue = @"pieChart";
    [pieChartGroupElement addAttribute:groupIdAttribute];
    
    for (NSInteger i = 0; i < anglesArrayCount; i++)
    {
        startAngle = endAngle;
        
        NSNumber * angleNumber = anglesArray[i];
        float angleValue = angleNumber.floatValue;
        
        endAngle = startAngle + angleValue;
        
        float x1 = centerX + radius * cosf(M_PI * startAngle / 180);
        float y1 = centerY + radius * sinf(M_PI * startAngle / 180);
        
        float x2 = centerX + radius * cosf(M_PI * endAngle / 180);
        float y2 = centerY + radius * sinf(M_PI * endAngle / 180);
        
        NSXMLElement * pathElement = [[NSXMLElement alloc] init];
        pathElement.name = @"path";
        
        NSXMLNode * strokeAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        strokeAttribute.name = @"stroke";
        strokeAttribute.stringValue = @"black";
        [pathElement addAttribute:strokeAttribute];

        NSXMLNode * strokeWidthAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        strokeWidthAttribute.name = @"stroke-width";
        strokeWidthAttribute.stringValue = @"1";
        [pathElement addAttribute:strokeWidthAttribute];

        NSXMLNode * fillAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        fillAttribute.name = @"fill";
        
        NSInteger colorIndex = i % 3;
        switch (colorIndex)
        {
            case 0:
                fillAttribute.stringValue = @"red";
                break;
            case 1:
                fillAttribute.stringValue = @"green";
                break;
            case 2:
                fillAttribute.stringValue = @"blue";
                break;
        }

        [pathElement addAttribute:fillAttribute];

        NSString * idString = [NSString stringWithFormat:@"chartSegment%ld", i];

        NSXMLNode * idAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        idAttribute.name = @"id";
        idAttribute.stringValue = idString;
        [pathElement addAttribute:idAttribute];
        
        NSString * segmentString = [NSString stringWithFormat:@"M%f,%f L%f,%f A%f,%f 0 0,1 %f,%f z",
                centerX, centerY, x1, y1, radius, radius, x2, y2];

        NSXMLNode * dAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        dAttribute.name = @"d";
        dAttribute.stringValue = segmentString;
        [pathElement addAttribute:dAttribute];
        
        [pieChartGroupElement addChild:pathElement];
    }

    [self assignMacsvgidsForNode:pieChartGroupElement];
    
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
        //[parentElement insertChild:pieChartGroupElement atIndex:childIndex];
        if (childIndex < pieChartGroupElement.childCount)
        {
            [parentElement insertChild:pieChartGroupElement atIndex:childIndex];
        }
        else
        {
            [parentElement addChild:pieChartGroupElement];
        }
    }
    else
    {
        [parentElement addChild:pieChartGroupElement];
    }
    
    [self updateDocumentViews];
}

@end
