//
//  TextIconView.m
//  macSVG
//
//  Created by Douglas Ward on 3/25/20.
//  Copyright © 2020 ArkPhone, LLC. All rights reserved.
//

#import "TextIconView.h"

@implementation TextIconView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [self drawTextIcon:self.bounds];
}

//================================================================================
// drawTextIcon:
//================================================================================

- (void)drawTextIcon:(NSRect)cellFrame {
	//NSBezierPath * rectPath23 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor24 = [NSColor orangeColor];
	//[rectColor24 set];
	//[rectPath23 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	//CGContextRef context = (CGContextRef)nsctx.graphicsPort;
    CGContextRef context = (CGContextRef)nsctx.CGContext;
	BOOL flipImage = YES;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(10.000000, 0.000000, 568.000000, 680.000000);
	CGFloat hViewScale = cellFrame.size.width / (webBBox.size.width);
	CGFloat vViewScale = cellFrame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.75f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <path stroke="blue" stroke-width="1" id="text_tool_path" d="M18,680 H570.000000 L578.000000,518.000000 H560.000000 Q547.000000,584.000000 518.000000,613.000000 Q485.000000,646.000000 420.000000,646.000000 H346.000000 V108.000000 Q346.000000,54.000000 366.500000,36.000000 T442.000000,18.000000 V0.000000 H146.000000 V18.000000 Q200.000000,18.000000 221.000000,36.000000 T242.000000,108.000000 V646.000000 H168.000000 Q104.000000,646.000000 72.000000,614.500000 T28.000000,518.000000 H10.000000  z " fill="black" transform="rotate(180 294 340) scale(0.625 0.625) translate(360 405)" macsvgid="F60EAD9D-3FA9-41B5-A738-E3D05B85BB13-10741-0000336B736C359A"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform25 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix26 = CGAffineTransformMake(-0.625000, 0.000000, -0.000000, -0.625000, 363.000000, 426.875000);
	currentTransform25 = CGAffineTransformConcat(currentTransform25, ctmMatrix26);
    
    CGAffineTransform adjustTransform = CGAffineTransformMakeTranslation(100, 125);
	currentTransform25 = CGAffineTransformConcat(currentTransform25, adjustTransform);
    
	CGMutablePathRef path27 = CGPathCreateMutable();
	CGPathMoveToPoint(path27, NULL, 18, 680);
	CGPathAddLineToPoint(path27, NULL, 570.000000, 680);
	CGPathAddLineToPoint(path27, NULL, 578.000000, 518.000000);
	CGPathAddLineToPoint(path27, NULL, 560.000000, 518);
	CGPathAddQuadCurveToPoint(path27, NULL, 547.000000, 584.000000, 518.000000, 613.000000);
	CGPathAddQuadCurveToPoint(path27, NULL, 485.000000, 646.000000, 420.000000, 646.000000);
	CGPathAddLineToPoint(path27, NULL, 346.000000, 646);
	CGPathAddLineToPoint(path27, NULL, 346, 108.000000);
	CGPathAddQuadCurveToPoint(path27, NULL, 346.000000, 54.000000, 366.500000, 36.000000);
	CGPathAddQuadCurveToPoint(path27, NULL, 442.000000, 18.000000, 442.000000, 18.000000);
	CGPathAddLineToPoint(path27, NULL, 442, 0.000000);
	CGPathAddLineToPoint(path27, NULL, 146.000000, 0);
	CGPathAddLineToPoint(path27, NULL, 146, 18.000000);
	CGPathAddQuadCurveToPoint(path27, NULL, 200.000000, 18.000000, 221.000000, 36.000000);
	CGPathAddQuadCurveToPoint(path27, NULL, 242.000000, 108.000000, 242.000000, 108.000000);
	CGPathAddLineToPoint(path27, NULL, 242, 646.000000);
	CGPathAddLineToPoint(path27, NULL, 168.000000, 646);
	CGPathAddQuadCurveToPoint(path27, NULL, 104.000000, 646.000000, 72.000000, 614.500000);
	CGPathAddQuadCurveToPoint(path27, NULL, 28.000000, 518.000000, 28.000000, 518.000000);
	CGPathAddLineToPoint(path27, NULL, 10.000000, 518);
    
    //CGPathClosePath(path);
	CGPathAddLineToPoint(path27, NULL, 18, 680);
	
    CGFloat strokeWidth28 = 1;
	CGRect pathBoundingBox29 = CGPathGetBoundingBox(path27);
	pathBoundingBox29 = NSInsetRect(pathBoundingBox29, -strokeWidth28, -strokeWidth28);
	CGFloat scaledStrokeWidth30 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth30);
	NSColor * strokeColor31 = [NSColor colorWithRed:0 green:0 blue:1 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor31.CGColor);
	NSColor * fillColor32 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor32.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip33 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform25 = CGAffineTransformConcat(currentTransform25, flip33);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect34 = cellFrame;
		CGFloat boundsMidX35 = NSMidX(boundsRect34) * (1.0f / viewScale);
		CGFloat boundsMidY36 = NSMidY(boundsRect34) * (1.0f / viewScale);
		CGFloat imageMidX37 = NSMidX(webBBox);
		CGFloat imageMidY38 = NSMidY(webBBox);
		CGFloat xTranslation39 = boundsMidX35 - imageMidX37;
		CGFloat yTranslation40 = boundsMidY36 - imageMidY38;
		CGAffineTransform centerTranslation41 = CGAffineTransformMakeTranslation(xTranslation39, yTranslation40);
		currentTransform25 = CGAffineTransformConcat(currentTransform25, centerTranslation41);
	}
	CGAffineTransform translate42 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform25 = CGAffineTransformConcat(currentTransform25, translate42);
	CGAffineTransform scale43 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform25 = CGAffineTransformConcat(currentTransform25, scale43);
	CGPathRef finalPath44 = CGPathCreateCopyByTransformingPath(path27, &currentTransform25);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath44);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath44);
	CGPathRelease(path27);
	CGContextRestoreGState(context);
}


@end
