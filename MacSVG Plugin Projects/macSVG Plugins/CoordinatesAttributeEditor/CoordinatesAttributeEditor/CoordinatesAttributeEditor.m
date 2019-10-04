//
//  CoordinatesAttributeEditor.m
//  CoordinatesAttributeEditor
//
//  Created by Douglas Ward on 7/30/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import "CoordinatesAttributeEditor.h"
#import "WebKit/WebKit.h"

#define svgNamespace @"http://www.w3.org/2000/svg"

@implementation CoordinatesAttributeEditor


//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.previousValue1 = NULL;
    self.previousValue2 = NULL;
    self.previousValue3 = NULL;
    self.previousValue4 = NULL;
    self.previousValue5 = NULL;
    self.previousValue6 = NULL;
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
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

    [stepper1 setMinValue:FLT_MIN];
    [stepper1 setMaxValue:FLT_MAX];
    
    [stepper2 setMinValue:FLT_MIN];
    [stepper2 setMaxValue:FLT_MAX];
    
    [stepper3 setMinValue:FLT_MIN];
    [stepper3 setMaxValue:FLT_MAX];
    
    [stepper4 setMinValue:FLT_MIN];
    [stepper4 setMaxValue:FLT_MAX];
    
    [stepper5 setMinValue:FLT_MIN];
    [stepper5 setMaxValue:FLT_MAX];
    
    [stepper6 setMinValue:FLT_MIN];
    [stepper6 setMaxValue:FLT_MAX];
    
    self.previousValue1 = @"";
    self.previousValue2 = @"";
    self.previousValue3 = @"";
    self.previousValue4 = @"";
    self.previousValue5 = @"";
    self.previousValue6 = @"";
}

//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    return @"Coordinates Attribute Editor";
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element tag name
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    NSString * result = NULL;

    return result;
}

//==================================================================================
//	isEditorForElement:elementName:attribute:
//==================================================================================

// return label if this editor can edit specified element and attribute
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName attribute:(NSString *)attributeName
{   
    NSString * result = NULL;
    
    BOOL validElement = NO;
    BOOL validAttribute = NO;

    if ([attributeName isEqualToString:@"x"] == YES)
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"y"] == YES)
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"width"] == YES) 
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"height"] == YES) 
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"r"] == YES)
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"rx"] == YES) 
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"ry"] == YES)
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"cx"] == YES)
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"cy"] == YES)
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"x1"] == YES)
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"y1"] == YES)
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"x2"] == YES)
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"y2"] == YES)
    {
        validAttribute = YES;
    }

    if (validAttribute == YES)
    {
        NSDictionary * elementsWithAttribute = [self elementsWithAttribute:attributeName];
        if (elementsWithAttribute[elementName] != NULL)
        {
            validElement = YES;
        }
        
        if (validElement == YES)
        {
            result = self.pluginName;
        }
    }

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
//	updateXMLAttributes
//==================================================================================

- (void)updateXMLAttributes
{
    NSString * elementName = (self.pluginTargetXMLElement).name;

    if ([elementName isEqualToString:@"rect"] == YES)
    {
        [self updateRectXMLElement];
    }
    
    if ([elementName isEqualToString:@"circle"] == YES)
    {
        [self updateCircleXMLElement];
    }
    
    if ([elementName isEqualToString:@"ellipse"] == YES)
    {
        [self updateEllipseXMLElement];
    }
    
    if ([elementName isEqualToString:@"line"] == YES)
    {
        [self updateLineXMLElement];
    }
    
    if ([elementName isEqualToString:@"text"] == YES)
    {
        [self updateTextXMLElement];
    }
    
    if ([elementName isEqualToString:@"image"] == YES)
    {
        [self updateImageXMLElement];
    }
    
    if ([elementName isEqualToString:@"svg"] == YES)
    {
        [self updateSVGXMLElement];
    }
    
    if ([elementName isEqualToString:@"use"] == YES)
    {
        [self updateUseXMLElement];
    }
    if ([elementName isEqualToString:@"foreignObject"] == YES)
    {
        [self updateUseXMLElement];
    }
    
    [self retainPreviousValues];
    
    [self updateDocumentViews];
}

//==================================================================================
//	updateRectXMLElement
//==================================================================================

- (void)updateRectXMLElement
{
    float x = attribute1.floatValue;
    float y = attribute2.floatValue;
    float width = attribute3.floatValue;
    float height = attribute4.floatValue;
    float rx = attribute5.floatValue;
    float ry = attribute6.floatValue;

    NSString * unit1String = unit1.titleOfSelectedItem;
    NSString * unit2String = unit2.titleOfSelectedItem;
    NSString * unit3String = unit3.titleOfSelectedItem;
    NSString * unit4String = unit4.titleOfSelectedItem;
    NSString * unit5String = unit5.titleOfSelectedItem;
    NSString * unit6String = unit6.titleOfSelectedItem;
    
    if (unit1String == NULL)
    {
        unit1String = @"";
    }
    if (unit2String == NULL)
    {
        unit2String = @"";
    }
    if (unit3String == NULL)
    {
        unit3String = @"";
    }
    if (unit4String == NULL)
    {
        unit4String = @"";
    }
    if (unit5String == NULL)
    {
        unit5String = @"";
    }
    if (unit6String == NULL)
    {
        unit6String = @"";
    }
    
    if (proportionalWidthHeightCheckboxButton.state != 0)
    {
        float previousWidth = (self.previousValue3).floatValue;
        float previousHeight = (self.previousValue4).floatValue;
        
        BOOL widthChanged = (width != previousWidth);
        BOOL heightChanged = (height != previousHeight);
        BOOL bothChanged = (widthChanged && heightChanged);
        
        if (bothChanged == NO)
        {
            if (widthChanged == YES)
            {
                float ratio = width / previousWidth;
                height = height * ratio;
                NSString * newHeightString = [self numericStringWithFloat:height];
                attribute4.stringValue = newHeightString;
                stepper4.floatValue = height;
            }
            else if (heightChanged == YES)
            {
                float ratio = height / previousHeight;
                width = width * ratio;
                NSString * newWidthString = [self numericStringWithFloat:width];
                attribute3.stringValue = newWidthString;
                stepper3.floatValue = width;
            }
        }
    }
    
    if (unit1String == NULL)
    {
        unit1String = @"";
    }
    if (unit2String == NULL)
    {
        unit2String = @"";
    }
    if (unit3String == NULL)
    {
        unit3String = @"";
    }
    if (unit4String == NULL)
    {
        unit4String = @"";
    }
    if (unit5String == NULL)
    {
        unit5String = @"";
    }
    if (unit6String == NULL)
    {
        unit6String = @"";
    }
    
    NSString * xString = [self numericStringWithFloat:x];
    NSString * xValue = [NSString stringWithFormat:@"%@%@", xString, unit1String];
    NSXMLNode * xAttributeNode = [self.pluginTargetXMLElement attributeForName:@"x"];
    xAttributeNode.stringValue = xValue;

    NSString * yString = [self numericStringWithFloat:y];
    NSString * yValue = [NSString stringWithFormat:@"%@%@", yString, unit2String];
    NSXMLNode * yAttributeNode = [self.pluginTargetXMLElement attributeForName:@"y"];
    yAttributeNode.stringValue = yValue;

    NSString * widthString = [self numericStringWithFloat:width];
    NSString * widthValue = [NSString stringWithFormat:@"%@%@", widthString, unit3String];
    NSXMLNode * widthAttributeNode = [self.pluginTargetXMLElement attributeForName:@"width"];
    widthAttributeNode.stringValue = widthValue;

    NSString * heightString = [self numericStringWithFloat:height];
    NSString * heightValue = [NSString stringWithFormat:@"%@%@", heightString, unit4String];
    NSXMLNode * heightAttributeNode = [self.pluginTargetXMLElement attributeForName:@"height"];
    heightAttributeNode.stringValue = heightValue;
    
    if ((rx == 0) && (ry == 0))
    {
        [self.pluginTargetXMLElement removeAttributeForName:@"rx"];
        [self.pluginTargetXMLElement removeAttributeForName:@"ry"];
    }
    else
    {
        NSString * rxString = [self numericStringWithFloat:rx];
        NSString * rxValue = [NSString stringWithFormat:@"%@%@", rxString, unit5String];
        NSXMLNode * rxAttributeNode = [self.pluginTargetXMLElement attributeForName:@"rx"];
        rxAttributeNode.stringValue = rxValue;

        NSString * ryString = [self numericStringWithFloat:ry];
        NSString * ryValue = [NSString stringWithFormat:@"%@%@", ryString, unit6String];
        NSXMLNode * ryAttributeNode = [self.pluginTargetXMLElement attributeForName:@"ry"];
        ryAttributeNode.stringValue = ryValue;
    }
}

//==================================================================================
//	updateCircleXMLElement
//==================================================================================

- (void)updateCircleXMLElement
{
    float cx = attribute1.floatValue;
    float cy = attribute2.floatValue;
    float r = attribute3.floatValue;

    NSString * unit1String = unit1.titleOfSelectedItem;
    NSString * unit2String = unit2.titleOfSelectedItem;
    NSString * unit3String = unit3.titleOfSelectedItem;

    if (unit1String == NULL)
    {
        unit1String = @"";
    }
    if (unit2String == NULL)
    {
        unit2String = @"";
    }
    if (unit3String == NULL)
    {
        unit3String = @"";
    }
    
    NSString * cxString = [self numericStringWithFloat:cx];
    NSString * cxValue = [NSString stringWithFormat:@"%@%@", cxString, unit1String];
    NSXMLNode * cxAttributeNode = [self.pluginTargetXMLElement attributeForName:@"cx"];
    cxAttributeNode.stringValue = cxValue;

    NSString * cyString = [self numericStringWithFloat:cy];
    NSString * cyValue = [NSString stringWithFormat:@"%@%@", cyString, unit2String];
    NSXMLNode * cyAttributeNode = [self.pluginTargetXMLElement attributeForName:@"cy"];
    cyAttributeNode.stringValue = cyValue;

    NSString * rString = [self numericStringWithFloat:r];
    NSString * rValue = [NSString stringWithFormat:@"%@%@", rString, unit3String];
    NSXMLNode * rAttributeNode = [self.pluginTargetXMLElement attributeForName:@"r"];
    rAttributeNode.stringValue = rValue;

}

//==================================================================================
//	updateEllipseXMLElement
//==================================================================================

- (void)updateEllipseXMLElement
{
    float cx = attribute1.floatValue;
    float cy = attribute2.floatValue;
    float rx = attribute3.floatValue;
    float ry = attribute4.floatValue;

    NSString * unit1String = unit1.titleOfSelectedItem;
    NSString * unit2String = unit2.titleOfSelectedItem;
    NSString * unit3String = unit3.titleOfSelectedItem;
    NSString * unit4String = unit4.titleOfSelectedItem;

    if (unit1String == NULL)
    {
        unit1String = @"";
    }
    if (unit2String == NULL)
    {
        unit2String = @"";
    }
    if (unit3String == NULL)
    {
        unit3String = @"";
    }
    if (unit4String == NULL)
    {
        unit4String = @"";
    }

    if (proportionalWidthHeightCheckboxButton.state != 0)
    {
        float previousRx = (self.previousValue3).floatValue;
        float previousRy = (self.previousValue4).floatValue;
        
        BOOL rxChanged = (rx != previousRx);
        BOOL ryChanged = (ry != previousRy);
        BOOL bothChanged = (rxChanged && ryChanged);
        
        if (bothChanged == NO)
        {
            if (rxChanged == YES)
            {
                float ratio = rx / previousRx;
                ry = ry * ratio;
                NSString * newRyString = [self numericStringWithFloat:ry];
                attribute4.stringValue = newRyString;
                stepper4.floatValue = ry;
            }
            else if (ryChanged == YES)
            {
                float ratio = ry / previousRy;
                rx = rx * ratio;
                NSString * newRxString = [self numericStringWithFloat:rx];
                attribute3.stringValue = newRxString;
                stepper3.floatValue = rx;
            }
        }
    }

    NSString * cxString = [self numericStringWithFloat:cx];
    NSString * cxValue = [NSString stringWithFormat:@"%@%@", cxString, unit1String];
    NSXMLNode * cxAttributeNode = [self.pluginTargetXMLElement attributeForName:@"cx"];
    cxAttributeNode.stringValue = cxValue;

    NSString * cyString = [self numericStringWithFloat:cy];
    NSString * cyValue = [NSString stringWithFormat:@"%@%@", cyString, unit2String];
    NSXMLNode * cyAttributeNode = [self.pluginTargetXMLElement attributeForName:@"cy"];
    cyAttributeNode.stringValue = cyValue;

    NSString * rxString = [self numericStringWithFloat:rx];
    NSString * rxValue = [NSString stringWithFormat:@"%@%@", rxString, unit3String];
    NSXMLNode * rxAttributeNode = [self.pluginTargetXMLElement attributeForName:@"rx"];
    rxAttributeNode.stringValue = rxValue;

    NSString * ryString = [self numericStringWithFloat:ry];
    NSString * ryValue = [NSString stringWithFormat:@"%@%@", ryString, unit4String];
    NSXMLNode * ryAttributeNode = [self.pluginTargetXMLElement attributeForName:@"ry"];
    ryAttributeNode.stringValue = ryValue;
}

//==================================================================================
//	updateLineXMLElement
//==================================================================================

- (void)updateLineXMLElement
{
    float x1 = attribute1.floatValue;
    float y1 = attribute2.floatValue;
    float x2 = attribute3.floatValue;
    float y2 = attribute4.floatValue;
    
    NSString * unit1String = unit1.titleOfSelectedItem;
    NSString * unit2String = unit2.titleOfSelectedItem;
    NSString * unit3String = unit3.titleOfSelectedItem;
    NSString * unit4String = unit4.titleOfSelectedItem;

    if (unit1String == NULL)
    {
        unit1String = @"";
    }
    if (unit2String == NULL)
    {
        unit2String = @"";
    }
    if (unit3String == NULL)
    {
        unit3String = @"";
    }
    if (unit4String == NULL)
    {
        unit4String = @"";
    }

    NSString * x1Value = [NSString stringWithFormat:@"%f%@", x1, unit1String];
    NSXMLNode * x1AttributeNode = [self.pluginTargetXMLElement attributeForName:@"x1"];
    x1AttributeNode.stringValue = x1Value;

    NSString * y1Value = [NSString stringWithFormat:@"%f%@", y1, unit2String];
    NSXMLNode * y1AttributeNode = [self.pluginTargetXMLElement attributeForName:@"y1"];
    y1AttributeNode.stringValue = y1Value;

    NSString * x2Value = [NSString stringWithFormat:@"%f%@", x2, unit3String];
    NSXMLNode * x2AttributeNode = [self.pluginTargetXMLElement attributeForName:@"x2"];
    x2AttributeNode.stringValue = x2Value;

    NSString * y2Value = [NSString stringWithFormat:@"%f%@", y2, unit4String];
    NSXMLNode * y2AttributeNode = [self.pluginTargetXMLElement attributeForName:@"y2"];
    y2AttributeNode.stringValue = y2Value;
}

//==================================================================================
//	updateTextXMLElement
//==================================================================================

- (void)updateTextXMLElement
{
    float x = attribute1.floatValue;
    float y = attribute2.floatValue;

    NSString * unit1String = unit1.titleOfSelectedItem;
    NSString * unit2String = unit2.titleOfSelectedItem;

    if (unit1String == NULL)
    {
        unit1String = @"";
    }
    if (unit2String == NULL)
    {
        unit2String = @"";
    }

    NSString * xString = [self numericStringWithFloat:x];
    NSString * xValue = [NSString stringWithFormat:@"%@%@", xString, unit1String];
    NSXMLNode * xAttributeNode = [self.pluginTargetXMLElement attributeForName:@"x"];
    xAttributeNode.stringValue = xValue;

    NSString * yString = [self numericStringWithFloat:y];
    NSString * yValue = [NSString stringWithFormat:@"%@%@", yString, unit2String];
    NSXMLNode * yAttributeNode = [self.pluginTargetXMLElement attributeForName:@"y"];
    yAttributeNode.stringValue = yValue;
}

//==================================================================================
//	updateImageXMLElement
//==================================================================================

- (void)updateImageXMLElement
{
    float x = attribute1.floatValue;
    float y = attribute2.floatValue;
    float width = attribute3.floatValue;
    float height = attribute4.floatValue;

    NSString * unit1String = unit1.titleOfSelectedItem;
    NSString * unit2String = unit2.titleOfSelectedItem;
    NSString * unit3String = unit3.titleOfSelectedItem;
    NSString * unit4String = unit4.titleOfSelectedItem;

    if (unit1String == NULL)
    {
        unit1String = @"";
    }
    if (unit2String == NULL)
    {
        unit2String = @"";
    }
    if (unit3String == NULL)
    {
        unit3String = @"";
    }
    if (unit4String == NULL)
    {
        unit4String = @"";
    }

    if (proportionalWidthHeightCheckboxButton.state != 0)
    {
        float previousWidth = (self.previousValue3).floatValue;
        float previousHeight = (self.previousValue4).floatValue;
        
        BOOL widthChanged = (width != previousWidth);
        BOOL heightChanged = (height != previousHeight);
        BOOL bothChanged = (widthChanged && heightChanged);
        
        if (bothChanged == NO)
        {
            if (widthChanged == YES)
            {
                float ratio = width / previousWidth;
                height = height * ratio;
                NSString * newHeightString = [self numericStringWithFloat:height];
                attribute4.stringValue = newHeightString;
                stepper4.floatValue = height;
            }
            else if (heightChanged == YES)
            {
                float ratio = height / previousHeight;
                width = width * ratio;
                NSString * newWidthString = [self numericStringWithFloat:width];
                attribute3.stringValue = newWidthString;
                stepper3.floatValue = width;
            }
        }
    }
    
    NSString * xString = [self numericStringWithFloat:x];
    NSString * xValue = [NSString stringWithFormat:@"%@%@", xString, unit1String];
    NSXMLNode * xAttributeNode = [self.pluginTargetXMLElement attributeForName:@"x"];
    xAttributeNode.stringValue = xValue;

    NSString * yString = [self numericStringWithFloat:y];
    NSString * yValue = [NSString stringWithFormat:@"%@%@", yString, unit2String];
    NSXMLNode * yAttributeNode = [self.pluginTargetXMLElement attributeForName:@"y"];
    yAttributeNode.stringValue = yValue;

    NSString * widthString = [self numericStringWithFloat:width];
    NSString * widthValue = [NSString stringWithFormat:@"%@%@", widthString, unit3String];
    NSXMLNode * widthAttributeNode = [self.pluginTargetXMLElement attributeForName:@"width"];
    widthAttributeNode.stringValue = widthValue;

    NSString * heightString = [self numericStringWithFloat:height];
    NSString * heightValue = [NSString stringWithFormat:@"%@%@", heightString, unit4String];
    NSXMLNode * heightAttributeNode = [self.pluginTargetXMLElement attributeForName:@"height"];
    heightAttributeNode.stringValue = heightValue;

}

//==================================================================================
//	updateUseXMLElement
//==================================================================================

- (void)updateUseXMLElement
{
    float x = attribute1.floatValue;
    float y = attribute2.floatValue;
    float width = attribute3.floatValue;
    float height = attribute4.floatValue;

    NSString * unit1String = unit1.titleOfSelectedItem;
    NSString * unit2String = unit2.titleOfSelectedItem;
    NSString * unit3String = unit3.titleOfSelectedItem;
    NSString * unit4String = unit4.titleOfSelectedItem;

    if (unit1String == NULL)
    {
        unit1String = @"";
    }
    if (unit2String == NULL)
    {
        unit2String = @"";
    }
    if (unit3String == NULL)
    {
        unit3String = @"";
    }
    if (unit4String == NULL)
    {
        unit4String = @"";
    }

    if (proportionalWidthHeightCheckboxButton.state != 0)
    {
        float previousWidth = (self.previousValue3).floatValue;
        float previousHeight = (self.previousValue4).floatValue;
        
        BOOL widthChanged = (width != previousWidth);
        BOOL heightChanged = (height != previousHeight);
        BOOL bothChanged = (widthChanged && heightChanged);
        
        if (bothChanged == NO)
        {
            if (widthChanged == YES)
            {
                float ratio = width / previousWidth;
                height = height * ratio;
                NSString * newHeightString = [self numericStringWithFloat:height];
                attribute4.stringValue = newHeightString;
                stepper4.floatValue = height;
            }
            else if (heightChanged == YES)
            {
                float ratio = height / previousHeight;
                width = width * ratio;
                NSString * newWidthString = [self numericStringWithFloat:width];
                attribute3.stringValue = newWidthString;
                stepper3.floatValue = width;
            }
        }
    }
    
    NSString * xString = [self numericStringWithFloat:x];
    NSString * xValue = [NSString stringWithFormat:@"%@%@", xString, unit1String];
    NSXMLNode * xAttributeNode = [self.pluginTargetXMLElement attributeForName:@"x"];
    xAttributeNode.stringValue = xValue;

    NSString * yString = [self numericStringWithFloat:y];
    NSString * yValue = [NSString stringWithFormat:@"%@%@", yString, unit2String];
    NSXMLNode * yAttributeNode = [self.pluginTargetXMLElement attributeForName:@"y"];
    yAttributeNode.stringValue = yValue;

    NSString * widthString = [self numericStringWithFloat:width];
    NSString * widthValue = [NSString stringWithFormat:@"%@%@", widthString, unit3String];
    NSXMLNode * widthAttributeNode = [self.pluginTargetXMLElement attributeForName:@"width"];
    widthAttributeNode.stringValue = widthValue;

    NSString * heightString = [self numericStringWithFloat:height];
    NSString * heightValue = [NSString stringWithFormat:@"%@%@", heightString, unit4String];
    NSXMLNode * heightAttributeNode = [self.pluginTargetXMLElement attributeForName:@"height"];
    heightAttributeNode.stringValue = heightValue;
}

//==================================================================================
//	updateImageXMLElement
//==================================================================================

- (void)updateSVGXMLElement
{
    float x = attribute1.floatValue;
    float y = attribute2.floatValue;
    float width = attribute3.floatValue;
    float height = attribute4.floatValue;

    NSString * unit1String = unit1.titleOfSelectedItem;
    NSString * unit2String = unit2.titleOfSelectedItem;
    NSString * unit3String = unit3.titleOfSelectedItem;
    NSString * unit4String = unit4.titleOfSelectedItem;

    if (unit1String == NULL)
    {
        unit1String = @"";
    }
    if (unit2String == NULL)
    {
        unit2String = @"";
    }
    if (unit3String == NULL)
    {
        unit3String = @"";
    }
    if (unit4String == NULL)
    {
        unit4String = @"";
    }

    if (proportionalWidthHeightCheckboxButton.state != 0)
    {
        float previousWidth = (self.previousValue3).floatValue;
        float previousHeight = (self.previousValue4).floatValue;
        
        BOOL widthChanged = (width != previousWidth);
        BOOL heightChanged = (height != previousHeight);
        BOOL bothChanged = (widthChanged && heightChanged);
        
        if (bothChanged == NO)
        {
            if (widthChanged == YES)
            {
                float ratio = width / previousWidth;
                height = height * ratio;
                NSString * newHeightString = [self numericStringWithFloat:height];
                attribute4.stringValue = newHeightString;
                stepper4.floatValue = height;
            }
            else if (heightChanged == YES)
            {
                float ratio = height / previousHeight;
                width = width * ratio;
                NSString * newWidthString = [self numericStringWithFloat:width];
                attribute3.stringValue = newWidthString;
                stepper3.floatValue = width;
            }
        }
    }
    
    NSString * xString = [self numericStringWithFloat:x];
    NSString * xValue = [NSString stringWithFormat:@"%@%@", xString, unit1String];
    NSXMLNode * xAttributeNode = [self.pluginTargetXMLElement attributeForName:@"x"];
    xAttributeNode.stringValue = xValue;

    NSString * yString = [self numericStringWithFloat:y];
    NSString * yValue = [NSString stringWithFormat:@"%@%@", yString, unit2String];
    NSXMLNode * yAttributeNode = [self.pluginTargetXMLElement attributeForName:@"y"];
    yAttributeNode.stringValue = yValue;

    NSString * widthString = [self numericStringWithFloat:width];
    NSString * widthValue = [NSString stringWithFormat:@"%@%@", widthString, unit3String];
    NSXMLNode * widthAttributeNode = [self.pluginTargetXMLElement attributeForName:@"width"];
    widthAttributeNode.stringValue = widthValue;

    NSString * heightString = [self numericStringWithFloat:height];
    NSString * heightValue = [NSString stringWithFormat:@"%@%@", heightString, unit4String];
    NSXMLNode * heightAttributeNode = [self.pluginTargetXMLElement attributeForName:@"height"];
    heightAttributeNode.stringValue = heightValue;

}


//==================================================================================
//	updateStepperValue:withAttributeNode:
//==================================================================================

- (void)updateStepperValue:(NSStepper *)aStepper withTextField:(NSTextField *)aTextField
{
    float floatValue = aTextField.floatValue;
    aStepper.floatValue = floatValue;
}

//==================================================================================
//	attributeControlAction:
//==================================================================================

- (IBAction)attributeControlAction:(id)sender
{
    [self updateStepperValue:stepper1 withTextField:attribute1];
    [self updateStepperValue:stepper2 withTextField:attribute2];
    [self updateStepperValue:stepper3 withTextField:attribute3];
    [self updateStepperValue:stepper4 withTextField:attribute4];
    [self updateStepperValue:stepper5 withTextField:attribute5];
    [self updateStepperValue:stepper6 withTextField:attribute6];
    
    [self updateXMLAttributes];
}

//==================================================================================
//	incrementAttributeTextField:withStepper:
//==================================================================================

- (void)incrementAttributeTextField:(NSTextField *)aTextField withStepper:(NSStepper *)stepper
{
    double stepperValue = stepper.floatValue;
    
    aTextField.floatValue = stepperValue;

    [self updateXMLAttributes];
}

//==================================================================================
//	stepper1Action:
//==================================================================================

- (IBAction)stepper1Action:(id)sender
{
    [self incrementAttributeTextField:attribute1 withStepper:sender];
}

//==================================================================================
//	stepper2Action:
//==================================================================================

- (IBAction)stepper2Action:(id)sender
{
    [self incrementAttributeTextField:attribute2 withStepper:sender];
}

//==================================================================================
//	stepper3Action:
//==================================================================================

- (IBAction)stepper3Action:(id)sender
{
    [self incrementAttributeTextField:attribute3 withStepper:sender];
}

//==================================================================================
//	stepper4Action:
//==================================================================================

- (IBAction)stepper4Action:(id)sender
{
    [self incrementAttributeTextField:attribute4 withStepper:sender];
}

//==================================================================================
//	stepper5Action:
//==================================================================================

- (IBAction)stepper5Action:(id)sender
{
    [self incrementAttributeTextField:attribute5 withStepper:sender];
}

//==================================================================================
//	stepper6Action:
//==================================================================================

- (IBAction)stepper6Action:(id)sender
{
    [self incrementAttributeTextField:attribute6 withStepper:sender];
}

//==================================================================================
//	attributeString:endsWithSuffix:
//==================================================================================

- (BOOL)attributeString:(NSString *)attributeString endsWithSuffix:(NSString *)suffix
{
    BOOL result = NO;

    NSInteger attributeStringLength = attributeString.length;
    NSInteger suffixLength = suffix.length;
    
    if (attributeStringLength > suffixLength)
    {
        NSRange unitRange = [attributeString rangeOfString:suffix];
        
        if (unitRange.location == (attributeStringLength - suffixLength))
        {
            BOOL allNumericValue = YES;
            
            for (NSInteger i = 0; i < unitRange.location; i++)
            {
                unichar valueChar = [attributeString characterAtIndex:i];
                
                if ((valueChar < '0') || (valueChar > '9'))
                {
                    if (valueChar != '.')
                    {
                        allNumericValue = NO;
                        break;
                    }
                }
            }
            
            if (allNumericValue == YES)
            {
                result = YES;
            }
        }
    }
    
    return result;
}

//==================================================================================
//	unitForAttributeNode:
//==================================================================================

- (NSString *)unitForAttributeNode:(NSXMLNode *)attributeNode
{
    NSString * attributeString = attributeNode.stringValue;

    NSString * resultUnit = NULL;

    if ([self attributeString:attributeString endsWithSuffix:@"em"] == YES)
    {
        resultUnit = @"em";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"ex"] == YES)
    {
        resultUnit = @"ex";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"px"] == YES)
    {
        resultUnit = @"px";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"pt"] == YES)
    {
        resultUnit = @"pt";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"pc"] == YES)
    {
        resultUnit = @"pc";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"cm"] == YES)
    {
        resultUnit = @"cm";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"mm"] == YES)
    {
        resultUnit = @"mm";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"in"] == YES)
    {
        resultUnit = @"in";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"h"] == YES)
    {
        resultUnit = @"h";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"min"] == YES)
    {
        resultUnit = @"min";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"s"] == YES)
    {
        resultUnit = @"s";
    }
    else if ([self attributeString:attributeString endsWithSuffix:@"%"] == YES)
    {
        resultUnit = @"%";
    }

    if (resultUnit == NULL)
    {
        resultUnit = @"";
    }
    
    return resultUnit;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

//==================================================================================
//	beginEditForXMLElement:domElement:attributeName:existingValue:
//==================================================================================

- (BOOL)beginEditForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetDOMElement
        attributeName:(NSString *)newAttributeName
        existingValue:(NSString *)existingValue
{
    BOOL result = [super beginEditForXMLElement:newPluginTargetXMLElement
            domElement:newPluginTargetDOMElement attributeName:newAttributeName
            existingValue:existingValue];

    viewBoxMinX = 0;
    viewBoxMinY = 0;
    viewBoxWidth = 640;
    viewBoxHeight = 744;

    DOMDocument * domDocument = (self.svgWebView).mainFrame.DOMDocument;
    DOMNodeList * svgElementsList = [domDocument getElementsByTagNameNS:svgNamespace localName:@"svg"];
    if (svgElementsList.length > 0)
    {
        DOMNode * svgElementNode = [svgElementsList item:0];
        DOMElement * svgElement = (DOMElement *)svgElementNode;
        
        NSString * viewBoxAttribute = [svgElement getAttribute:@"viewBox"];
        if (viewBoxAttribute != NULL)
        {
            NSArray * viewBoxValuesArray = [viewBoxAttribute componentsSeparatedByString:@" "];

            if (viewBoxValuesArray.count == 4)
            {
                NSString * viewBoxMinXString = viewBoxValuesArray[0];
                NSString * viewBoxMinYString = viewBoxValuesArray[1];
                NSString * viewBoxWidthString = viewBoxValuesArray[2];
                NSString * viewBoxHeightString = viewBoxValuesArray[3];
                
                viewBoxMinX = viewBoxMinXString.floatValue;
                viewBoxMinY = viewBoxMinYString.floatValue;
                viewBoxWidth = viewBoxWidthString.floatValue;
                viewBoxHeight = viewBoxHeightString.floatValue;
            }
        }
    }
    
    NSString * elementName = newPluginTargetXMLElement.name;
    
    if ([elementName isEqualToString:@"rect"] == YES)
    {
        [self setRectAttributes:newPluginTargetXMLElement];
    }
    
    if ([elementName isEqualToString:@"circle"] == YES)
    {
        [self setCircleAttributes:newPluginTargetXMLElement];
    }
    
    if ([elementName isEqualToString:@"ellipse"] == YES)
    {
        [self setEllipseAttributes:newPluginTargetXMLElement];
    }
    
    if ([elementName isEqualToString:@"line"] == YES)
    {
        [self setLineAttributes:newPluginTargetXMLElement];
    }
    
    if ([elementName isEqualToString:@"text"] == YES)
    {
        [self setTextAttributes:newPluginTargetXMLElement];
    }
    
    if ([elementName isEqualToString:@"image"] == YES)
    {
        [self setImageAttributes:newPluginTargetXMLElement];
    }
    
    if ([elementName isEqualToString:@"svg"] == YES)
    {
        [self setSVGAttributes:newPluginTargetXMLElement];
    }
    
    if ([elementName isEqualToString:@"use"] == YES)
    {
        [self setUseAttributes:newPluginTargetXMLElement];
    }
    if ([elementName isEqualToString:@"foreignObject"] == YES)
    {
        [self setUseAttributes:newPluginTargetXMLElement];
    }
    
    [self retainPreviousValues];
    
    return result;
}

#pragma clang diagnostic pop

//==================================================================================
//	numericStringWithFloat
//==================================================================================

- (NSString *)numericStringWithFloat:(float)floatValue
{
    NSString * numericString = @"0";

    numericString = [NSString stringWithFormat:@"%.3f", floatValue];    // round off small errors
    
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
//	numericStringWithAttributeString
//==================================================================================

- (NSString *)numericStringWithAttributeNode:(NSXMLNode *)attributeNode
{
    NSString * attributeString = attributeNode.stringValue;
    float attributeFloat = attributeString.floatValue;
    NSString * numericString = @"0";

    numericString = [NSString stringWithFormat:@"%f", attributeFloat];
    
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
//	setStepper:attributeNode:
//==================================================================================

- (void)setStepper:(NSStepper *)aStepper attributeNode:(NSXMLNode *)attributeNode
{
    NSString * attributeString = attributeNode.stringValue;
    float attributeFloat = attributeString.floatValue;
    aStepper.floatValue = attributeFloat;
}

//==================================================================================
//	setRectAttributes
//==================================================================================

- (void)setRectAttributes:(NSXMLElement *)targetXMLElement
{
    NSString * xAttributeString = @"0";
    NSString * xUnit = @"px";
    NSXMLNode * xAttributeNode = [targetXMLElement attributeForName:@"x"];
    if (xAttributeNode != NULL)
    {
        xAttributeString = [self numericStringWithAttributeNode:xAttributeNode];
        xUnit = [self unitForAttributeNode:xAttributeNode];
    }
    
    NSString * yAttributeString = @"0";
    NSString * yUnit = @"px";
    NSXMLNode * yAttributeNode = [targetXMLElement attributeForName:@"y"];
    if (yAttributeNode != NULL)
    {
        yAttributeString = [self numericStringWithAttributeNode:yAttributeNode];
        yUnit = [self unitForAttributeNode:yAttributeNode];
    }
    
    NSString * widthAttributeString = @"0";
    NSString * widthUnit = @"px";
    NSXMLNode * widthAttributeNode = [targetXMLElement attributeForName:@"width"];
    if (widthAttributeNode != NULL)
    {
        widthAttributeString = [self numericStringWithAttributeNode:widthAttributeNode];
        widthUnit = [self unitForAttributeNode:widthAttributeNode];
    }
    
    NSString * heightAttributeString = @"0";
    NSString * heightUnit = @"px";
    NSXMLNode * heightAttributeNode = [targetXMLElement attributeForName:@"height"];
    if (heightAttributeNode != NULL)
    {
        heightAttributeString = [self numericStringWithAttributeNode:heightAttributeNode];
        heightUnit = [self unitForAttributeNode:heightAttributeNode];
    }
    
    NSString * rxAttributeString = @"0";
    NSString * rxUnit = @"px";
    NSXMLNode * rxAttributeNode = [targetXMLElement attributeForName:@"rx"];
    if (rxAttributeNode != NULL)
    {
        rxAttributeString = [self numericStringWithAttributeNode:rxAttributeNode];
        rxUnit = [self unitForAttributeNode:rxAttributeNode];
    }
    
    NSString * ryAttributeString = @"0";
    NSString * ryUnit = @"px";
    NSXMLNode * ryAttributeNode = [targetXMLElement attributeForName:@"ry"];
    if (ryAttributeNode != NULL)
    {
        ryAttributeString = [self numericStringWithAttributeNode:ryAttributeNode];
        ryUnit = [self unitForAttributeNode:ryAttributeNode];
    }
    
    label1.stringValue = @"x";
    [label1 setHidden:NO];
    attribute1.stringValue = xAttributeString;
    [attribute1 setHidden:NO];
    [unit1 selectItemWithTitle:xUnit];
    [unit1 setHidden:NO];
    [self setStepper:stepper1 attributeNode:xAttributeNode];
    [stepper1 setHidden:NO];
    
    label2.stringValue = @"y";
    [label2 setHidden:NO];
    attribute2.stringValue = yAttributeString;
    [attribute2 setHidden:NO];
    [unit2 selectItemWithTitle:yUnit];
    [unit2 setHidden:NO];
    [self setStepper:stepper2 attributeNode:yAttributeNode];
    [stepper2 setHidden:NO];
    
    label3.stringValue = @"width";
    [label3 setHidden:NO];
    attribute3.stringValue = widthAttributeString;
    [attribute3 setHidden:NO];
    [unit3 selectItemWithTitle:widthUnit];
    [unit3 setHidden:NO];
    [self setStepper:stepper3 attributeNode:widthAttributeNode];
    [stepper3 setHidden:NO];
    
    label4.stringValue = @"height";
    [label4 setHidden:NO];
    attribute4.stringValue = heightAttributeString;
    [attribute4 setHidden:NO];
    [unit4 selectItemWithTitle:heightUnit];
    [unit4 setHidden:NO];
    [self setStepper:stepper4 attributeNode:heightAttributeNode];
    [stepper4 setHidden:NO];

    label5.stringValue = @"rx";
    [label5 setHidden:NO];
    attribute5.stringValue = rxAttributeString;
    [attribute5 setHidden:NO];
    [unit5 selectItemWithTitle:rxUnit];
    [unit5 setHidden:NO];
    [self setStepper:stepper5 attributeNode:rxAttributeNode];
    [stepper5 setHidden:NO];
    
    label6.stringValue = @"ry";
    [label6 setHidden:NO];
    attribute6.stringValue = ryAttributeString;
    [attribute6 setHidden:NO];
    [unit6 selectItemWithTitle:ryUnit];
    [unit6 setHidden:NO];
    [self setStepper:stepper6 attributeNode:ryAttributeNode];
    [stepper6 setHidden:NO];
}

//==================================================================================
//	setCircleAttributes
//==================================================================================

- (void)setCircleAttributes:(NSXMLElement *)targetXMLElement
{
    NSString * cxAttributeString = @"100";
    NSString * cxUnit = @"px";
    NSXMLNode * cxAttributeNode = [targetXMLElement attributeForName:@"cx"];
    if (cxAttributeNode != NULL)
    {
        cxAttributeString = [self numericStringWithAttributeNode:cxAttributeNode];
        cxUnit = [self unitForAttributeNode:cxAttributeNode];
    }
    
    NSString * cyAttributeString = @"100";
    NSString * cyUnit = @"px";
    NSXMLNode * cyAttributeNode = [targetXMLElement attributeForName:@"cy"];
    if (cyAttributeNode != NULL)
    {
        cyAttributeString = [self numericStringWithAttributeNode:cyAttributeNode];
        cyUnit = [self unitForAttributeNode:cyAttributeNode];
    }
    
    NSString * rAttributeString = @"50";
    NSString * rUnit = @"px";
    NSXMLNode * rAttributeNode = [targetXMLElement attributeForName:@"r"];
    if (rAttributeNode != NULL)
    {
        rAttributeString = [self numericStringWithAttributeNode:rAttributeNode];
        rUnit = [self unitForAttributeNode:rAttributeNode];
    }
    
    label1.stringValue = @"cx";
    [label1 setHidden:NO];
    attribute1.stringValue = cxAttributeString;
    [attribute1 setHidden:NO];
    [unit1 selectItemWithTitle:cxUnit];
    [unit1 setHidden:NO];
    [self setStepper:stepper1 attributeNode:cxAttributeNode];
    [stepper1 setHidden:NO];
    
    label2.stringValue = @"cy";
    [label2 setHidden:NO];
    attribute2.stringValue = cyAttributeString;
    [attribute2 setHidden:NO];
    [unit2 selectItemWithTitle:cyUnit];
    [unit2 setHidden:NO];
    [self setStepper:stepper2 attributeNode:cyAttributeNode];
    [stepper2 setHidden:NO];
    
    label3.stringValue = @"r";
    [label3 setHidden:NO];
    attribute3.stringValue = rAttributeString;
    [attribute3 setHidden:NO];
    [unit3 selectItemWithTitle:rUnit];
    [unit3 setHidden:NO];
    [self setStepper:stepper3 attributeNode:rAttributeNode];
    [stepper3 setHidden:NO];
    
    [label4 setHidden:YES];
    [attribute4 setHidden:YES];
    [unit4 setHidden:YES];
    [stepper4 setHidden:YES];

    [label5 setHidden:YES];
    [attribute5 setHidden:YES];
    [unit5 setHidden:YES];
    [stepper5 setHidden:YES];
    
    [label6 setHidden:YES];
    [attribute6 setHidden:YES];
    [unit6 setHidden:YES];
    [stepper6 setHidden:YES];
}

//==================================================================================
//	setEllipseAttributes
//==================================================================================

- (void)setEllipseAttributes:(NSXMLElement *)targetXMLElement
{
    NSString * cxAttributeString = @"100";
    NSString * cxUnit = @"px";
    NSXMLNode * cxAttributeNode = [targetXMLElement attributeForName:@"cx"];
    if (cxAttributeNode != NULL)
    {
        cxAttributeString = [self numericStringWithAttributeNode:cxAttributeNode];
        cxUnit = [self unitForAttributeNode:cxAttributeNode];
    }
    
    NSString * cyAttributeString = @"100";
    NSString * cyUnit = @"px";
    NSXMLNode * cyAttributeNode = [targetXMLElement attributeForName:@"cy"];
    if (cyAttributeNode != NULL)
    {
        cyAttributeString = [self numericStringWithAttributeNode:cyAttributeNode];
        cyUnit = [self unitForAttributeNode:cyAttributeNode];
    }
    
    NSString * rxAttributeString = @"50";
    NSString * rxUnit = @"px";
    NSXMLNode * rxAttributeNode = [targetXMLElement attributeForName:@"rx"];
    if (rxAttributeNode != NULL)
    {
        rxAttributeString = [self numericStringWithAttributeNode:rxAttributeNode];
        rxUnit = [self unitForAttributeNode:rxAttributeNode];
    }
    
    NSString * ryAttributeString = @"50";
    NSString * ryUnit = @"px";
    NSXMLNode * ryAttributeNode = [targetXMLElement attributeForName:@"ry"];
    if (ryAttributeNode != NULL)
    {
        ryAttributeString = [self numericStringWithAttributeNode:ryAttributeNode];
        ryUnit = [self unitForAttributeNode:ryAttributeNode];
    }
    
    label1.stringValue = @"cx";
    [label1 setHidden:NO];
    attribute1.stringValue = cxAttributeString;
    [attribute1 setHidden:NO];
    [unit1 selectItemWithTitle:cxUnit];
    [unit1 setHidden:NO];
    [self setStepper:stepper1 attributeNode:cxAttributeNode];
    [stepper1 setHidden:NO];
    
    label2.stringValue = @"cy";
    [label2 setHidden:NO];
    attribute2.stringValue = cyAttributeString;
    [attribute2 setHidden:NO];
    [unit2 selectItemWithTitle:cyUnit];
    [unit2 setHidden:NO];
    [self setStepper:stepper2 attributeNode:cyAttributeNode];
    [stepper2 setHidden:NO];
    
    label3.stringValue = @"rx";
    [label3 setHidden:NO];
    attribute3.stringValue = rxAttributeString;
    [attribute3 setHidden:NO];
    [unit3 selectItemWithTitle:rxUnit];
    [unit3 setHidden:NO];
    [self setStepper:stepper3 attributeNode:rxAttributeNode];
    [stepper3 setHidden:NO];
    
    label4.stringValue = @"ry";
    [label4 setHidden:NO];
    attribute4.stringValue = ryAttributeString;
    [attribute4 setHidden:NO];
    [unit4 selectItemWithTitle:ryUnit];
    [unit4 setHidden:NO];
    [self setStepper:stepper4 attributeNode:ryAttributeNode];
    [stepper4 setHidden:NO];

    [label5 setHidden:YES];
    [attribute5 setHidden:YES];
    [unit5 setHidden:YES];
    [stepper5 setHidden:YES];
    
    [label6 setHidden:YES];
    [attribute6 setHidden:YES];
    [unit6 setHidden:YES];
    [stepper6 setHidden:YES];
}


//==================================================================================
//	setLineAttributes
//==================================================================================

- (void)setLineAttributes:(NSXMLElement *)targetXMLElement
{
    NSString * x1AttributeString = @"50";
    NSString * x1Unit = @"px";
    NSXMLNode * x1AttributeNode = [targetXMLElement attributeForName:@"x1"];
    if (x1AttributeNode != NULL)
    {
        x1AttributeString = [self numericStringWithAttributeNode:x1AttributeNode];
        x1Unit = [self unitForAttributeNode:x1AttributeNode];
    }
    
    NSString * y1AttributeString = @"50";
    NSString * y1Unit = @"px";
    NSXMLNode * y1AttributeNode = [targetXMLElement attributeForName:@"y1"];
    if (y1AttributeNode != NULL)
    {
        y1AttributeString = [self numericStringWithAttributeNode:y1AttributeNode];
        y1Unit = [self unitForAttributeNode:y1AttributeNode];
    }
    
    NSString * x2AttributeString = @"100";
    NSString * x2Unit = @"px";
    NSXMLNode * x2AttributeNode = [targetXMLElement attributeForName:@"x2"];
    if (x2AttributeNode != NULL)
    {
        x2AttributeString = [self numericStringWithAttributeNode:x2AttributeNode];
        x2Unit = [self unitForAttributeNode:x2AttributeNode];
    }
    
    NSString * y2AttributeString = @"100";
    NSString * y2Unit = @"px";
    NSXMLNode * y2AttributeNode = [targetXMLElement attributeForName:@"y2"];
    if (y2AttributeNode != NULL)
    {
        y2AttributeString = [self numericStringWithAttributeNode:y2AttributeNode];
        y2Unit = [self unitForAttributeNode:y2AttributeNode];
    }
    
    label1.stringValue = @"x1";
    [label1 setHidden:NO];
    attribute1.stringValue = x1AttributeString;
    [attribute1 setHidden:NO];
    [unit1 selectItemWithTitle:x1Unit];
    [unit1 setHidden:NO];
    [self setStepper:stepper1 attributeNode:x1AttributeNode];
    [stepper1 setHidden:NO];
    
    label2.stringValue = @"y1";
    [label2 setHidden:NO];
    attribute2.stringValue = y1AttributeString;
    [attribute2 setHidden:NO];
    [unit2 selectItemWithTitle:y1Unit];
    [unit2 setHidden:NO];
    [self setStepper:stepper2 attributeNode:y1AttributeNode];
    [stepper2 setHidden:NO];
    
    label3.stringValue = @"x2";
    [label3 setHidden:NO];
    attribute3.stringValue = x2AttributeString;
    [attribute3 setHidden:NO];
    [unit3 selectItemWithTitle:x2Unit];
    [unit3 setHidden:NO];
    [self setStepper:stepper3 attributeNode:x2AttributeNode];
    [stepper3 setHidden:NO];
    
    label4.stringValue = @"y2";
    [label4 setHidden:NO];
    attribute4.stringValue = y2AttributeString;
    [attribute4 setHidden:NO];
    [unit4 selectItemWithTitle:y2Unit];
    [unit4 setHidden:NO];
    [self setStepper:stepper4 attributeNode:y2AttributeNode];
    [stepper4 setHidden:NO];

    [label5 setHidden:YES];
    [attribute5 setHidden:YES];
    [unit5 setHidden:YES];
    [stepper5 setHidden:YES];
    
    [label6 setHidden:YES];
    [attribute6 setHidden:YES];
    [unit6 setHidden:YES];
    [stepper6 setHidden:YES];
}

//==================================================================================
//	setTextAttributes
//==================================================================================

- (void)setTextAttributes:(NSXMLElement *)targetXMLElement
{
    NSString * xAttributeString = @"0";
    NSString * xUnit = @"px";
    NSXMLNode * xAttributeNode = [targetXMLElement attributeForName:@"x"];
    if (xAttributeNode != NULL)
    {
        xAttributeString = [self numericStringWithAttributeNode:xAttributeNode];
        xUnit = [self unitForAttributeNode:xAttributeNode];
    }
    
    NSString * yAttributeString = @"0";
    NSString * yUnit = @"px";
    NSXMLNode * yAttributeNode = [targetXMLElement attributeForName:@"y"];
    if (yAttributeNode != NULL)
    {
        yAttributeString = [self numericStringWithAttributeNode:yAttributeNode];
        yUnit = [self unitForAttributeNode:yAttributeNode];
    }
    
    label1.stringValue = @"x";
    [label1 setHidden:NO];
    attribute1.stringValue = xAttributeString;
    [attribute1 setHidden:NO];
    [unit1 selectItemWithTitle:xUnit];
    [unit1 setHidden:NO];
    [self setStepper:stepper1 attributeNode:xAttributeNode];
    [stepper1 setHidden:NO];
    
    label2.stringValue = @"y";
    [label2 setHidden:NO];
    attribute2.stringValue = yAttributeString;
    [attribute2 setHidden:NO];
    [unit2 selectItemWithTitle:yUnit];
    [unit2 setHidden:NO];
    [self setStepper:stepper2 attributeNode:yAttributeNode];
    [stepper2 setHidden:NO];
    
    [label3 setHidden:YES];
    [attribute3 setHidden:YES];
    [unit3 setHidden:YES];
    [stepper3 setHidden:YES];
    
    [label4 setHidden:YES];
    [attribute4 setHidden:YES];
    [unit4 setHidden:YES];
    [stepper4 setHidden:YES];

    [label5 setHidden:YES];
    [attribute5 setHidden:YES];
    [unit5 setHidden:YES];
    [stepper5 setHidden:YES];
    
    [label6 setHidden:YES];
    [attribute6 setHidden:YES];
    [unit6 setHidden:YES];
    [stepper6 setHidden:YES];
}

//==================================================================================
//	setImageAttributes
//==================================================================================

- (void)setImageAttributes:(NSXMLElement *)targetXMLElement
{
    NSString * xAttributeString = @"0";
    NSString * xUnit = @"px";
    NSXMLNode * xAttributeNode = [targetXMLElement attributeForName:@"x"];
    if (xAttributeNode != NULL)
    {
        xAttributeString = [self numericStringWithAttributeNode:xAttributeNode];
        xUnit = [self unitForAttributeNode:xAttributeNode];
    }
    
    NSString * yAttributeString = @"0";
    NSString * yUnit = @"px";
    NSXMLNode * yAttributeNode = [targetXMLElement attributeForName:@"y"];
    if (yAttributeNode != NULL)
    {
        yAttributeString = [self numericStringWithAttributeNode:yAttributeNode];
        yUnit = [self unitForAttributeNode:yAttributeNode];
    }
    
    NSString * widthAttributeString = @"0";
    NSString * widthUnit = @"px";
    NSXMLNode * widthAttributeNode = [targetXMLElement attributeForName:@"width"];
    if (widthAttributeNode != NULL)
    {
        widthAttributeString = [self numericStringWithAttributeNode:widthAttributeNode];
        widthUnit = [self unitForAttributeNode:widthAttributeNode];
    }
    
    NSString * heightAttributeString = @"0";
    NSString * heightUnit = @"px";
    NSXMLNode * heightAttributeNode = [targetXMLElement attributeForName:@"height"];
    if (heightAttributeNode != NULL)
    {
        heightAttributeString = [self numericStringWithAttributeNode:heightAttributeNode];
        heightUnit = [self unitForAttributeNode:heightAttributeNode];
    }
    
    
    label1.stringValue = @"x";
    [label1 setHidden:NO];
    attribute1.stringValue = xAttributeString;
    [attribute1 setHidden:NO];
    [unit1 selectItemWithTitle:xUnit];
    [unit1 setHidden:NO];
    [self setStepper:stepper1 attributeNode:xAttributeNode];
    [stepper1 setHidden:NO];
    
    label2.stringValue = @"y";
    [label2 setHidden:NO];
    attribute2.stringValue = yAttributeString;
    [attribute2 setHidden:NO];
    [unit2 selectItemWithTitle:yUnit];
    [unit2 setHidden:NO];
    [self setStepper:stepper2 attributeNode:yAttributeNode];
    [stepper2 setHidden:NO];
    
    label3.stringValue = @"width";
    [label3 setHidden:NO];
    attribute3.stringValue = widthAttributeString;
    [attribute3 setHidden:NO];
    [unit3 selectItemWithTitle:widthUnit];
    [unit3 setHidden:NO];
    [self setStepper:stepper3 attributeNode:widthAttributeNode];
    [stepper3 setHidden:NO];
    
    label4.stringValue = @"height";
    [label4 setHidden:NO];
    attribute4.stringValue = heightAttributeString;
    [attribute4 setHidden:NO];
    [unit4 selectItemWithTitle:heightUnit];
    [unit4 setHidden:NO];
    [self setStepper:stepper4 attributeNode:heightAttributeNode];
    [stepper4 setHidden:NO];

    [label5 setHidden:YES];
    [attribute5 setHidden:YES];
    [unit5 setHidden:YES];
    [stepper5 setHidden:YES];
    
    [label6 setHidden:YES];
    [attribute6 setHidden:YES];
    [unit6 setHidden:YES];
    [stepper6 setHidden:YES];
}

//==================================================================================
//	setSVGAttributes
//==================================================================================

- (void)setSVGAttributes:(NSXMLElement *)targetXMLElement
{
    NSString * xAttributeString = @"0";
    NSString * xUnit = @"px";
    NSXMLNode * xAttributeNode = [targetXMLElement attributeForName:@"x"];
    if (xAttributeNode != NULL)
    {
        xAttributeString = [self numericStringWithAttributeNode:xAttributeNode];
        xUnit = [self unitForAttributeNode:xAttributeNode];
    }
    
    NSString * yAttributeString = @"0";
    NSString * yUnit = @"px";
    NSXMLNode * yAttributeNode = [targetXMLElement attributeForName:@"y"];
    if (yAttributeNode != NULL)
    {
        yAttributeString = [self numericStringWithAttributeNode:yAttributeNode];
        yUnit = [self unitForAttributeNode:yAttributeNode];
    }
    
    NSString * widthAttributeString = @"0";
    NSString * widthUnit = @"px";
    NSXMLNode * widthAttributeNode = [targetXMLElement attributeForName:@"width"];
    if (widthAttributeNode != NULL)
    {
        widthAttributeString = [self numericStringWithAttributeNode:widthAttributeNode];
        widthUnit = [self unitForAttributeNode:widthAttributeNode];
    }
    
    NSString * heightAttributeString = @"0";
    NSString * heightUnit = @"px";
    NSXMLNode * heightAttributeNode = [targetXMLElement attributeForName:@"height"];
    if (heightAttributeNode != NULL)
    {
        heightAttributeString = [self numericStringWithAttributeNode:heightAttributeNode];
        heightUnit = [self unitForAttributeNode:heightAttributeNode];
    }
    
    label1.stringValue = @"x";
    [label1 setHidden:NO];
    attribute1.stringValue = xAttributeString;
    [attribute1 setHidden:NO];
    [unit1 selectItemWithTitle:xUnit];
    [unit1 setHidden:NO];
    [self setStepper:stepper1 attributeNode:xAttributeNode];
    [stepper1 setHidden:NO];
    
    label2.stringValue = @"y";
    [label2 setHidden:NO];
    attribute2.stringValue = yAttributeString;
    [attribute2 setHidden:NO];
    [unit2 selectItemWithTitle:yUnit];
    [unit2 setHidden:NO];
    [self setStepper:stepper2 attributeNode:yAttributeNode];
    [stepper2 setHidden:NO];
    
    label3.stringValue = @"width";
    [label3 setHidden:NO];
    attribute3.stringValue = widthAttributeString;
    [attribute3 setHidden:NO];
    [unit3 selectItemWithTitle:widthUnit];
    [unit3 setHidden:NO];
    [self setStepper:stepper3 attributeNode:widthAttributeNode];
    [stepper3 setHidden:NO];
    
    label4.stringValue = @"height";
    [label4 setHidden:NO];
    attribute4.stringValue = heightAttributeString;
    [attribute4 setHidden:NO];
    [unit4 selectItemWithTitle:heightUnit];
    [unit4 setHidden:NO];
    [self setStepper:stepper4 attributeNode:heightAttributeNode];
    [stepper4 setHidden:NO];

    [label5 setHidden:YES];
    [attribute5 setHidden:YES];
    [unit5 setHidden:YES];
    [stepper5 setHidden:YES];
    
    [label6 setHidden:YES];
    [attribute6 setHidden:YES];
    [unit6 setHidden:YES];
    [stepper6 setHidden:YES];
}


//==================================================================================
//	setUseAttributes
//==================================================================================

- (void)setUseAttributes:(NSXMLElement *)targetXMLElement
{
    NSString * xAttributeString = @"0";
    NSString * xUnit = @"px";
    NSXMLNode * xAttributeNode = [targetXMLElement attributeForName:@"x"];
    if (xAttributeNode != NULL)
    {
        xAttributeString = [self numericStringWithAttributeNode:xAttributeNode];
        xUnit = [self unitForAttributeNode:xAttributeNode];
    }
    
    NSString * yAttributeString = @"0";
    NSString * yUnit = @"px";
    NSXMLNode * yAttributeNode = [targetXMLElement attributeForName:@"y"];
    if (yAttributeNode != NULL)
    {
        yAttributeString = [self numericStringWithAttributeNode:yAttributeNode];
        yUnit = [self unitForAttributeNode:yAttributeNode];
    }
    
    NSString * widthAttributeString = @"0";
    NSString * widthUnit = @"px";
    NSXMLNode * widthAttributeNode = [targetXMLElement attributeForName:@"width"];
    if (widthAttributeNode != NULL)
    {
        widthAttributeString = [self numericStringWithAttributeNode:widthAttributeNode];
        widthUnit = [self unitForAttributeNode:widthAttributeNode];
    }
    
    NSString * heightAttributeString = @"0";
    NSString * heightUnit = @"px";
    NSXMLNode * heightAttributeNode = [targetXMLElement attributeForName:@"height"];
    if (heightAttributeNode != NULL)
    {
        heightAttributeString = [self numericStringWithAttributeNode:heightAttributeNode];
        heightUnit = [self unitForAttributeNode:heightAttributeNode];
    }
    
    label1.stringValue = @"x";
    [label1 setHidden:NO];
    attribute1.stringValue = xAttributeString;
    [attribute1 setHidden:NO];
    [unit1 selectItemWithTitle:xUnit];
    [unit1 setHidden:NO];
    [self setStepper:stepper1 attributeNode:xAttributeNode];
    [stepper1 setHidden:NO];
    
    label2.stringValue = @"y";
    [label2 setHidden:NO];
    attribute2.stringValue = yAttributeString;
    [attribute2 setHidden:NO];
    [unit2 selectItemWithTitle:yUnit];
    [unit2 setHidden:NO];
    [self setStepper:stepper2 attributeNode:yAttributeNode];
    [stepper2 setHidden:NO];
    
    label3.stringValue = @"width";
    [label3 setHidden:NO];
    attribute3.stringValue = widthAttributeString;
    [attribute3 setHidden:NO];
    [unit3 selectItemWithTitle:widthUnit];
    [unit3 setHidden:NO];
    [self setStepper:stepper3 attributeNode:widthAttributeNode];
    [stepper3 setHidden:NO];
    
    label4.stringValue = @"height";
    [label4 setHidden:NO];
    attribute4.stringValue = heightAttributeString;
    [attribute4 setHidden:NO];
    [unit4 selectItemWithTitle:heightUnit];
    [unit4 setHidden:NO];
    [self setStepper:stepper4 attributeNode:heightAttributeNode];
    [stepper4 setHidden:NO];

    [label5 setHidden:YES];
    [attribute5 setHidden:YES];
    [unit5 setHidden:YES];
    [stepper5 setHidden:YES];
    
    [label6 setHidden:YES];
    [attribute6 setHidden:YES];
    [unit6 setHidden:YES];
    [stepper6 setHidden:YES];
}

//==================================================================================
//	retainPreviousValues
//==================================================================================

- (void)retainPreviousValues
{
    self.previousValue1 = [NSString stringWithString:attribute1.stringValue];
    self.previousValue2 = [NSString stringWithString:attribute2.stringValue];
    self.previousValue3 = [NSString stringWithString:attribute3.stringValue];
    self.previousValue4 = [NSString stringWithString:attribute4.stringValue];
    self.previousValue5 = [NSString stringWithString:attribute5.stringValue];
    self.previousValue6 = [NSString stringWithString:attribute6.stringValue];
}


@end
