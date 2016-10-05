//
//  BezierCircleGenerator.m
//  BezierCircleGenerator
//
//  Created by Douglas Ward on 7/12/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

// adapted from http://paulhertz.net/factory/wp-content/uploads/2010/03/bezcircle_applet/bezCircle.pde


#import "BezierCircleGenerator.h"
#import "BezierCircleGeneratorWindowController.h"
#import "MacSVGPlugin/MacSVGPluginCallbacks.h"

@implementation BezierCircleGenerator


//==================================================================================
//	pluginMenuTitle
//==================================================================================

- (NSString *)pluginMenuTitle
{
    return @"Bezier Circle Path Generator";    // override for menu plugins
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
    if (bezierCircleGeneratorWindowController.window == NULL)
    {
        NSString * pluginNameString = self.className;
        NSArray * topLevelObjects = NULL;

        NSString * bundlePath = [NSBundle bundleForClass:[self class]].bundlePath;

        NSBundle * pluginBundle = [NSBundle bundleWithPath:bundlePath];

        BOOL result = [pluginBundle loadNibNamed:pluginNameString owner:self topLevelObjects:&topLevelObjects];
        #pragma unused(result)
    }

    [[NSApplication sharedApplication] runModalForWindow:bezierCircleGeneratorWindowController.window];

    return YES;
}

//==================================================================================
//	makeBezierCircleAtCenterX:centerY:radius:sectors:
//==================================================================================

-(void) makeBezierCircleAtCenterX:(CGFloat)x centerY:(CGFloat)y radius:(CGFloat)radius segments:(NSInteger)segments
{
    NSMutableString * svgString = [NSMutableString string];

    CGFloat kappa = 0.5522847498;

    CGFloat k = 4 * kappa / segments;
    CGFloat d = k * radius;
    
    CGFloat ax1 = 0;
    CGFloat ay1 = radius;
    
    CGFloat cx1 = d;
    CGFloat cy1 = radius;
    
    NSPoint cp2 = [self rotateCoordinatesWithDx:-d dy:radius theta:-(M_PI * 2)/segments];
    NSPoint ap2 = [self rotateCoordinatesWithDx:0 dy:radius theta:-(M_PI * 2)/segments];
    
    CGFloat cx2 = cp2.x;
    CGFloat cy2 = cp2.y;
    
    CGFloat ax2 = ap2.x;
    CGFloat ay2 = ap2.y;
 
    NSString * ax1String = [self allocFloatString:(ax1 + x)];
    NSString * ay1String = [self allocFloatString:(ay1 + y)];
    NSString * cx1String = [self allocFloatString:(cx1 + x)];
    NSString * cy1String = [self allocFloatString:(cy1 + y)];
    NSString * cx2String = [self allocFloatString:(cx2 + x)];
    NSString * cy2String = [self allocFloatString:(cy2 + y)];
    NSString * ax2String = [self allocFloatString:(ax2 + x)];
    NSString * ay2String = [self allocFloatString:(ay2 + y)];

    //vertex(ax1, ay1);
    [svgString appendString:@"M"];
    [svgString appendString:ax1String];
    [svgString appendString:@","];
    [svgString appendString:ay1String];
    [svgString appendString:@" "];
    
    //bezierVertex(cx1, cy1, cx2, cy2, ax2, ay2);
    [svgString appendString:@"C"];
    [svgString appendString:cx1String];
    [svgString appendString:@","];
    [svgString appendString:cy1String];
    [svgString appendString:@" "];

    [svgString appendString:cx2String];
    [svgString appendString:@","];
    [svgString appendString:cy2String];
    [svgString appendString:@" "];
    
    [svgString appendString:ax2String];
    [svgString appendString:@","];
    [svgString appendString:ay2String];
    [svgString appendString:@" "];
    
    // calculate new segments by rotating the first segment coordinates
    for (int i = 1; i < segments; i++)
    {
        //cp1 = rotateCoor(cx1, cy1, i * -TWO_PI/sectors);
        //cp2 = rotateCoor(cx2, cy2, i * -TWO_PI/sectors);
        //ap2 = rotateCoor(ax2, ay2, i * -TWO_PI/sectors);

        NSPoint cp1 = [self rotateCoordinatesWithDx:cx1 dy:cy1 theta:(i * -(M_PI * 2)/segments)];
        cp2 = [self rotateCoordinatesWithDx:cx2 dy:cy2 theta:(i * -(M_PI * 2)/segments)];
        ap2 = [self rotateCoordinatesWithDx:ax2 dy:ay2 theta:(i * -(M_PI * 2)/segments)];
        
        //bezierVertex(cp1.x, cp1.y, cp2.x, cp2.y, ap2.x, ap2.y);

        NSString * cpx1String = [self allocFloatString:(cp1.x + x)];
        NSString * cpy1String = [self allocFloatString:(cp1.y + y)];
        NSString * cpx2String = [self allocFloatString:(cp2.x + x)];
        NSString * cpy2String = [self allocFloatString:(cp2.y + y)];
        NSString * apx2String = [self allocFloatString:(ap2.x + x)];
        NSString * apy2String = [self allocFloatString:(ap2.y + y)];
        
        [svgString appendString:@"C"];
        [svgString appendString:cpx1String];
        [svgString appendString:@","];
        [svgString appendString:cpy1String];
        [svgString appendString:@" "];

        [svgString appendString:cpx2String];
        [svgString appendString:@","];
        [svgString appendString:cpy2String];
        [svgString appendString:@" "];
        
        [svgString appendString:apx2String];
        [svgString appendString:@","];
        [svgString appendString:apy2String];
        [svgString appendString:@" "];
    }

    [svgString appendString:@"Z"];
    
    [self addCirclePathXMLElement:svgString];
}

//==================================================================================
//	rotateCoordinatesWithDx:dy:theta:
//==================================================================================

- (NSPoint) rotateCoordinatesWithDx:(CGFloat)dx dy:(CGFloat)dy theta:(CGFloat)theta
{
    // Rotate vector or point (dx,dy) through an angle
    // degrees in radians
    // rotation is counterclockwise from the coordinate axis

    float sinTheta = sinf(theta);
    float cosTheta = cosf(theta);

    NSPoint resultPoint = NSZeroPoint;

    resultPoint.x = dx * cosTheta - dy * sinTheta;
    resultPoint.y = dx * sinTheta + dy * cosTheta;

    return resultPoint;
}

//==================================================================================
//	addCirclePathXMLElement:
//==================================================================================

- (void)addCirclePathXMLElement:(NSString *)pathString
{
    NSXMLElement * pathElement = [[NSXMLElement alloc] init];
    pathElement.name = @"path";
    
    NSXMLNode * strokeAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    strokeAttribute.name = @"stroke";
    strokeAttribute.stringValue = @"black";
    [pathElement addAttribute:strokeAttribute];

    NSXMLNode * strokeWidthAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    strokeWidthAttribute.name = @"stroke-width";
    strokeWidthAttribute.stringValue = @"3";
    [pathElement addAttribute:strokeWidthAttribute];

    NSXMLNode * fillAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    fillAttribute.name = @"fill";
    fillAttribute.stringValue = @"none";
    [pathElement addAttribute:fillAttribute];

    //NSString * idString = [NSString stringWithFormat:@"bezierCirclePath%d", 1];
    NSString * idString = [self.macSVGPluginCallbacks uniqueIDForElementTagName:@"bezierCirclePath" pendingIDs:NULL];

    NSXMLNode * idAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    idAttribute.name = @"id";
    idAttribute.stringValue = idString;
    [pathElement addAttribute:idAttribute];
    
    NSXMLNode * dAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    dAttribute.name = @"d";
    dAttribute.stringValue = pathString;
    [pathElement addAttribute:dAttribute];

    [self assignMacsvgidsForNode:pathElement];

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
        [parentElement insertChild:pathElement atIndex:childIndex];
    }
    else
    {
        [parentElement addChild:pathElement];
    }
    
    [self updateDocumentViews];
}


// Draw a circle with arbitrary number of Bezier curve segments
// @param sectors   integer for number of equal divisions of circle
/*
void bezCircle(int sectors) {
  float k = 4 * kappa / sectors;
  float d = k * radius;
  float ax1, ay1, cx1, cy1, cx2, cy2, ax2, ay2;
  Point2D.Float cp1 = new Point2D.Float();
  Point2D.Float cp2 = new Point2D.Float();
  Point2D.Float ap2 = new Point2D.Float();
  ax1 = 0;
  ay1 = radius;
  cx1 = d;
  cy1 = radius;
  cp2 = rotateCoor(-d, radius, -TWO_PI/sectors);
  ap2 = rotateCoor(0, radius, -TWO_PI/sectors);
  cx2 = cp2.x;
  cy2 = cp2.y;
  ax2 = ap2.x;
  ay2 = ap2.y;
  pushMatrix();
  // translate coordinate system to center of window
  translate(width/2, height/2);
  noFill();
  stroke(0, 0, 0);
  beginShape();
    vertex(ax1, ay1);
    bezierVertex(cx1, cy1, cx2, cy2, ax2, ay2);
    // can't rotate coordinate system within a shape, so we'll calculate new positions    
    for (int i = 1; i < sectors; i++) {
      cp1 = rotateCoor(cx1, cy1, i * -TWO_PI/sectors);
      cp2 = rotateCoor(cx2, cy2, i * -TWO_PI/sectors);
      ap2 = rotateCoor(ax2, ay2, i * -TWO_PI/sectors);
      bezierVertex(cp1.x, cp1.y, cp2.x, cp2.y, ap2.x, ap2.y);
    }
  endShape();
  popMatrix();
}


Point2D.Float rotateCoor(float dx, float dy, float theta) {
  // Rotate vector or point (dx,dy) through an angle
  // degrees in radians
  // rotation is counterclockwise from the coordinate axis
  float sintheta = sin(theta);
  float costheta = cos(theta);
  return new Point2D.Float(dx * costheta - dy * sintheta, dx * sintheta + dy * costheta);
}
*/


@end
