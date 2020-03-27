//
//  TargetIconView.m
//  macSVG
//
//  Created by Douglas Ward on 3/25/20.
//  Copyright © 2020 ArkPhone, LLC. All rights reserved.
//

#import "TargetIconView.h"

@implementation TargetIconView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [self drawTargetIcon:self.bounds];
}


- (void)drawTargetIcon:(NSRect)cellFrame {
	// ============================================
	// Common settings
    
	BOOL flipImage = YES;
	BOOL centerImage = YES;
	CGFloat translateX = 0.0f;
	CGFloat translateY = 0.0f;
	CGFloat scale = 0.8f;
	NSRect cellBounds = cellFrame;
	// ============================================
	//NSBezierPath * rectPath1 = [NSBezierPath bezierPathWithRect:cellBounds];
	//NSColor * rectColor2 = [NSColor orangeColor];
	//[rectColor2 set];
	//[rectPath1 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	//CGContextRef context = (CGContextRef)nsctx.graphicsPort;
    CGContextRef context = (CGContextRef)nsctx.CGContext;
	NSRect webBBox = NSMakeRect(0.000000, 0.000000, 200.000000, 200.000000);
	CGFloat hViewScale = cellFrame.size.width / (webBBox.size.width);
	CGFloat vViewScale = cellFrame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= scale; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="target_icon" visibility="hidden" macsvgid="8C6EC5B3-8CB6-429A-BEE8-358613D4B525-48813-000100E3EF857AD8"><circle stroke="none" id="circle1" cy="100px" stroke-width="0px" fill="red" r="100px" cx="100px" transform="" macsvgid="838FAD71-F2D9-4922-B613-3B6AE6975EC6-48813-000100E3EF859CE0"></circle><circle stroke="none" stroke-width="0px" cy="100px" id="circle2" fill="white" r="75px" cx="100px" transform="" macsvgid="006B1F1A-1909-4AB4-B8AC-ED2676AC39F8-48813-000100E3EF85C6B8"></circle><circle stroke="none" stroke-width="0px" cy="100px" fill="red" r="50px" cx="100px" transform="" id="circle3" macsvgid="EF6D2A20-6717-4926-83BB-00BCD230FAAC-48813-000100E3EF85F14B"></circle><circle stroke="none" stroke-width="0px" cy="100px" fill="white" r="25px" cx="100px" transform="" id="circle4" macsvgid="5A76DC48-64CC-48AA-BFF0-37590DD1DFD2-48813-000100E3EF861ABF"></circle></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform3 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix4 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, ctmMatrix4);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="none" id="circle1" cy="100px" stroke-width="0px" fill="red" r="100px" cx="100px" transform="" macsvgid="838FAD71-F2D9-4922-B613-3B6AE6975EC6-48813-000100E3EF859CE0"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform5 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix6 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, ctmMatrix6);
	CGMutablePathRef circlePath7 = CGPathCreateMutable();
	CGFloat cx8 = 100.000000;
	CGFloat cy9 = 100.000000;
	CGFloat r10 = 100.000000;
	CGRect circleRect11 = CGRectMake((cx8 - r10), (cy9 - r10), (r10 * 2.0f), (r10 * 2.0f));
	CGPathAddEllipseInRect(circlePath7, NULL, circleRect11);
	CGFloat strokeWidth12 = 0;
	CGRect pathBoundingBox13 = CGPathGetBoundingBox(circlePath7);
	pathBoundingBox13 = NSInsetRect(pathBoundingBox13, -strokeWidth12, -strokeWidth12);
	CGFloat scaledStrokeWidth14 = 0 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth14);
	NSColor * strokeColor15 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor15.CGColor);
	NSColor * fillColor16 = [NSColor colorWithRed:1 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor16.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip17 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform5 = CGAffineTransformConcat(currentTransform5, flip17);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect18 = cellBounds;
		CGFloat boundsMidX19 = NSMidX(boundsRect18) * (1.0f / viewScale);
		CGFloat boundsMidY20 = NSMidY(boundsRect18) * (1.0f / viewScale);
		CGFloat imageMidX21 = NSMidX(webBBox);
		CGFloat imageMidY22 = NSMidY(webBBox);
		CGFloat xTranslation23 = boundsMidX19 - imageMidX21;
		CGFloat yTranslation24 = boundsMidY20 - imageMidY22;
		CGAffineTransform centerTranslation25 = CGAffineTransformMakeTranslation(xTranslation23, yTranslation24);
		currentTransform5 = CGAffineTransformConcat(currentTransform5, centerTranslation25);
	}
	CGAffineTransform translate26 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, translate26);
	CGAffineTransform translateXY27 = CGAffineTransformMakeTranslation(translateX, translateY);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, translateXY27);
	CGAffineTransform scale28 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, scale28);
	CGPathRef finalPath29 = CGPathCreateCopyByTransformingPath(circlePath7, &currentTransform5);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath29);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath29);
	CGPathRelease(circlePath7);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="none" stroke-width="0px" cy="100px" id="circle2" fill="white" r="75px" cx="100px" transform="" macsvgid="006B1F1A-1909-4AB4-B8AC-ED2676AC39F8-48813-000100E3EF85C6B8"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform30 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix31 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform30 = CGAffineTransformConcat(currentTransform30, ctmMatrix31);
	CGMutablePathRef circlePath32 = CGPathCreateMutable();
	CGFloat cx33 = 100.000000;
	CGFloat cy34 = 100.000000;
	CGFloat r35 = 75.000000;
	CGRect circleRect36 = CGRectMake((cx33 - r35), (cy34 - r35), (r35 * 2.0f), (r35 * 2.0f));
	CGPathAddEllipseInRect(circlePath32, NULL, circleRect36);
	CGFloat strokeWidth37 = 0;
	CGRect pathBoundingBox38 = CGPathGetBoundingBox(circlePath32);
	pathBoundingBox38 = NSInsetRect(pathBoundingBox38, -strokeWidth37, -strokeWidth37);
	CGFloat scaledStrokeWidth39 = 0 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth39);
	NSColor * strokeColor40 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor40.CGColor);
	NSColor * fillColor41 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor41.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip42 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform30 = CGAffineTransformConcat(currentTransform30, flip42);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect43 = cellBounds;
		CGFloat boundsMidX44 = NSMidX(boundsRect43) * (1.0f / viewScale);
		CGFloat boundsMidY45 = NSMidY(boundsRect43) * (1.0f / viewScale);
		CGFloat imageMidX46 = NSMidX(webBBox);
		CGFloat imageMidY47 = NSMidY(webBBox);
		CGFloat xTranslation48 = boundsMidX44 - imageMidX46;
		CGFloat yTranslation49 = boundsMidY45 - imageMidY47;
		CGAffineTransform centerTranslation50 = CGAffineTransformMakeTranslation(xTranslation48, yTranslation49);
		currentTransform30 = CGAffineTransformConcat(currentTransform30, centerTranslation50);
	}
	CGAffineTransform translate51 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform30 = CGAffineTransformConcat(currentTransform30, translate51);
	CGAffineTransform translateXY52 = CGAffineTransformMakeTranslation(translateX, translateY);
	currentTransform30 = CGAffineTransformConcat(currentTransform30, translateXY52);
	CGAffineTransform scale53 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform30 = CGAffineTransformConcat(currentTransform30, scale53);
	CGPathRef finalPath54 = CGPathCreateCopyByTransformingPath(circlePath32, &currentTransform30);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath54);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath54);
	CGPathRelease(circlePath32);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="none" stroke-width="0px" cy="100px" fill="red" r="50px" cx="100px" transform="" id="circle3" macsvgid="EF6D2A20-6717-4926-83BB-00BCD230FAAC-48813-000100E3EF85F14B"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform55 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix56 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform55 = CGAffineTransformConcat(currentTransform55, ctmMatrix56);
	CGMutablePathRef circlePath57 = CGPathCreateMutable();
	CGFloat cx58 = 100.000000;
	CGFloat cy59 = 100.000000;
	CGFloat r60 = 50.000000;
	CGRect circleRect61 = CGRectMake((cx58 - r60), (cy59 - r60), (r60 * 2.0f), (r60 * 2.0f));
	CGPathAddEllipseInRect(circlePath57, NULL, circleRect61);
	CGFloat strokeWidth62 = 0;
	CGRect pathBoundingBox63 = CGPathGetBoundingBox(circlePath57);
	pathBoundingBox63 = NSInsetRect(pathBoundingBox63, -strokeWidth62, -strokeWidth62);
	CGFloat scaledStrokeWidth64 = 0 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth64);
	NSColor * strokeColor65 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor65.CGColor);
	NSColor * fillColor66 = [NSColor colorWithRed:1 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor66.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip67 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform55 = CGAffineTransformConcat(currentTransform55, flip67);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect68 = cellBounds;
		CGFloat boundsMidX69 = NSMidX(boundsRect68) * (1.0f / viewScale);
		CGFloat boundsMidY70 = NSMidY(boundsRect68) * (1.0f / viewScale);
		CGFloat imageMidX71 = NSMidX(webBBox);
		CGFloat imageMidY72 = NSMidY(webBBox);
		CGFloat xTranslation73 = boundsMidX69 - imageMidX71;
		CGFloat yTranslation74 = boundsMidY70 - imageMidY72;
		CGAffineTransform centerTranslation75 = CGAffineTransformMakeTranslation(xTranslation73, yTranslation74);
		currentTransform55 = CGAffineTransformConcat(currentTransform55, centerTranslation75);
	}
	CGAffineTransform translate76 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform55 = CGAffineTransformConcat(currentTransform55, translate76);
	CGAffineTransform translateXY77 = CGAffineTransformMakeTranslation(translateX, translateY);
	currentTransform55 = CGAffineTransformConcat(currentTransform55, translateXY77);
	CGAffineTransform scale78 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform55 = CGAffineTransformConcat(currentTransform55, scale78);
	CGPathRef finalPath79 = CGPathCreateCopyByTransformingPath(circlePath57, &currentTransform55);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath79);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath79);
	CGPathRelease(circlePath57);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="none" stroke-width="0px" cy="100px" fill="white" r="25px" cx="100px" transform="" id="circle4" macsvgid="5A76DC48-64CC-48AA-BFF0-37590DD1DFD2-48813-000100E3EF861ABF"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform80 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix81 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform80 = CGAffineTransformConcat(currentTransform80, ctmMatrix81);
	CGMutablePathRef circlePath82 = CGPathCreateMutable();
	CGFloat cx83 = 100.000000;
	CGFloat cy84 = 100.000000;
	CGFloat r85 = 25.000000;
	CGRect circleRect86 = CGRectMake((cx83 - r85), (cy84 - r85), (r85 * 2.0f), (r85 * 2.0f));
	CGPathAddEllipseInRect(circlePath82, NULL, circleRect86);
	CGFloat strokeWidth87 = 0;
	CGRect pathBoundingBox88 = CGPathGetBoundingBox(circlePath82);
	pathBoundingBox88 = NSInsetRect(pathBoundingBox88, -strokeWidth87, -strokeWidth87);
	CGFloat scaledStrokeWidth89 = 0 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth89);
	NSColor * strokeColor90 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor90.CGColor);
	NSColor * fillColor91 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor91.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip92 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform80 = CGAffineTransformConcat(currentTransform80, flip92);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect93 = cellBounds;
		CGFloat boundsMidX94 = NSMidX(boundsRect93) * (1.0f / viewScale);
		CGFloat boundsMidY95 = NSMidY(boundsRect93) * (1.0f / viewScale);
		CGFloat imageMidX96 = NSMidX(webBBox);
		CGFloat imageMidY97 = NSMidY(webBBox);
		CGFloat xTranslation98 = boundsMidX94 - imageMidX96;
		CGFloat yTranslation99 = boundsMidY95 - imageMidY97;
		CGAffineTransform centerTranslation100 = CGAffineTransformMakeTranslation(xTranslation98, yTranslation99);
		currentTransform80 = CGAffineTransformConcat(currentTransform80, centerTranslation100);
	}
	CGAffineTransform translate101 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform80 = CGAffineTransformConcat(currentTransform80, translate101);
	CGAffineTransform translateXY102 = CGAffineTransformMakeTranslation(translateX, translateY);
	currentTransform80 = CGAffineTransformConcat(currentTransform80, translateXY102);
	CGAffineTransform scale103 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform80 = CGAffineTransformConcat(currentTransform80, scale103);
	CGPathRef finalPath104 = CGPathCreateCopyByTransformingPath(circlePath82, &currentTransform80);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath104);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath104);
	CGPathRelease(circlePath82);
	CGContextRestoreGState(context);
}

@end
