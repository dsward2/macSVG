//
//  FolderIconView.m
//  macSVG
//
//  Created by Douglas Ward on 3/25/20.
//  Copyright © 2022 ArkPhone, LLC. All rights reserved.
//

#import "FolderIconView.h"

@implementation FolderIconView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [self drawFolderIcon:self.bounds];
}

//================================================================================
// drawFolderIcon:
//================================================================================

- (void)drawFolderIcon:(NSRect)cellFrame {
	// ============================================
	// Common settings
	BOOL flipImage = YES;
	BOOL centerImage = YES;
	CGFloat translateX = 0.0f;
	CGFloat translateY = 0.0f;
	CGFloat scale = 0.8f;
	NSRect cellBounds = cellFrame;
	// ============================================
	//NSBezierPath * rectPath105 = [NSBezierPath bezierPathWithRect:cellBounds];
	//NSColor * rectColor106 = [NSColor orangeColor];
	//[rectColor106 set];
	//[rectPath105 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	//CGContextRef context = (CGContextRef)nsctx.graphicsPort;
    CGContextRef context = (CGContextRef)nsctx.CGContext;
	NSRect webBBox = NSMakeRect(-0.093000, -0.062500, 15.562000, 14.262500);
	CGFloat hViewScale = cellFrame.size.width / (webBBox.size.width);
	CGFloat vViewScale = cellFrame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= scale; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="folder_icon" visibility="visible" macsvgid="FB99FB56-8859-4394-9587-115D103845F2-48813-000100E3EF82BD3A"><path stroke="black" id="path1" stroke-width="0.25px" d="M1.15625,2.1875 L1.15625,0.9375 L1.71875,0.1875 L5.40625,0.21875 L5.84375,0.9375 L5.84375,2.1875 L1.1875,2.1875" fill="url(#linearGradient1)" transform="" visibility="visible" macsvgid="77B1B1E6-CAEE-4F00-AA67-DE65DBA8B648-48813-000100E3EF830A71"></path><rect stroke="black" x="0.157px" height="11.75px" y="2.2px" id="rect1" stroke-width="0.25px" width="15.062px" fill="url(#linearGradient1)" transform="" visibility="visible" macsvgid="ACBBEDBA-6538-4875-8745-39EE4C88CDE4-48813-000100E3EF833571"></rect></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform107 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix108 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform107 = CGAffineTransformConcat(currentTransform107, ctmMatrix108);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <path stroke="black" id="path1" stroke-width="0.25px" d="M1.15625,2.1875 L1.15625,0.9375 L1.71875,0.1875 L5.40625,0.21875 L5.84375,0.9375 L5.84375,2.1875 L1.1875,2.1875" fill="url(#linearGradient1)" transform="" visibility="visible" macsvgid="77B1B1E6-CAEE-4F00-AA67-DE65DBA8B648-48813-000100E3EF830A71"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform109 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix110 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform109 = CGAffineTransformConcat(currentTransform109, ctmMatrix110);
	CGMutablePathRef path111 = CGPathCreateMutable();
	CGPathMoveToPoint(path111, NULL, 1.15625, 2.1875);
	CGPathAddLineToPoint(path111, NULL, 1.15625, 0.9375);
	CGPathAddLineToPoint(path111, NULL, 1.71875, 0.1875);
	CGPathAddLineToPoint(path111, NULL, 5.40625, 0.21875);
	CGPathAddLineToPoint(path111, NULL, 5.84375, 0.9375);
	CGPathAddLineToPoint(path111, NULL, 5.84375, 2.1875);
	CGPathAddLineToPoint(path111, NULL, 1.1875, 2.1875);
	CGFloat strokeWidth112 = 0.25;
	CGRect pathBoundingBox113 = CGPathGetBoundingBox(path111);
	pathBoundingBox113 = NSInsetRect(pathBoundingBox113, -strokeWidth112, -strokeWidth112);
	CGFloat scaledStrokeWidth114 = 0.25 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth114);
	NSColor * strokeColor115 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor115.CGColor);
	NSColor * fillColor116 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor116.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip117 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform109 = CGAffineTransformConcat(currentTransform109, flip117);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect118 = cellBounds;
		CGFloat boundsMidX119 = NSMidX(boundsRect118) * (1.0f / viewScale);
		CGFloat boundsMidY120 = NSMidY(boundsRect118) * (1.0f / viewScale);
		CGFloat imageMidX121 = NSMidX(webBBox);
		CGFloat imageMidY122 = NSMidY(webBBox);
		CGFloat xTranslation123 = boundsMidX119 - imageMidX121;
		CGFloat yTranslation124 = boundsMidY120 - imageMidY122;
		CGAffineTransform centerTranslation125 = CGAffineTransformMakeTranslation(xTranslation123, yTranslation124);
		currentTransform109 = CGAffineTransformConcat(currentTransform109, centerTranslation125);
	}
	CGAffineTransform translate126 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform109 = CGAffineTransformConcat(currentTransform109, translate126);
	CGAffineTransform translateXY127 = CGAffineTransformMakeTranslation(translateX, translateY);
	currentTransform109 = CGAffineTransformConcat(currentTransform109, translateXY127);
	CGAffineTransform scale128 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform109 = CGAffineTransformConcat(currentTransform109, scale128);
	CGPathRef finalPath129 = CGPathCreateCopyByTransformingPath(path111, &currentTransform109);
	CGColorSpaceRef linearGradientColorSpace130 = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGFloat linearGradientColorArray132[4] = {0.941176, 0.866667, 0.603922, 1.0};
	CGColorRef linearGradientColor133 = CGColorCreate(linearGradientColorSpace130, linearGradientColorArray132);
	CGFloat linearGradientColorArray134[4] = {0.854902, 0.647059, 0.12549, 1.0};
	CGColorRef linearGradientColor135 = CGColorCreate(linearGradientColorSpace130, linearGradientColorArray134);
	CGFloat locationsArray136[] = {0.000000, 1.000000};
	NSArray * colorsArray137 = @[(__bridge id) linearGradientColor133, (__bridge id) linearGradientColor135];
	CGGradientRef linearGradient138 = CGGradientCreateWithColors(linearGradientColorSpace130, (__bridge CFArrayRef) colorsArray137, locationsArray136);
	CGRect pathBounds139 = CGPathGetPathBoundingBox(finalPath129);
	CGPoint linearGradientStartPoint140 = CGPointMake(CGRectGetMidX(pathBounds139), CGRectGetMinY(pathBounds139));
	CGPoint linearGradientEndPoint141 = CGPointMake(CGRectGetMidX(pathBounds139), CGRectGetMaxY(pathBounds139));
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath129);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, linearGradient138, linearGradientStartPoint140, linearGradientEndPoint141, 0);
	CGGradientRelease(linearGradient138);
	CGColorRelease(linearGradientColor133);
	CGColorRelease(linearGradientColor135);
	CGColorSpaceRelease(linearGradientColorSpace130);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath129);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath129);
	CGPathRelease(path111);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="black" x="0.157px" height="11.75px" y="2.2px" id="rect1" stroke-width="0.25px" width="15.062px" fill="url(#linearGradient1)" transform="" visibility="visible" macsvgid="ACBBEDBA-6538-4875-8745-39EE4C88CDE4-48813-000100E3EF833571"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform142 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix143 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform142 = CGAffineTransformConcat(currentTransform142, ctmMatrix143);
	CGMutablePathRef rectPath144 = CGPathCreateMutable();
	CGFloat x145 = 0.157000;
	CGFloat y146 = 2.200000;
	CGFloat width147 = 15.062000;
	CGFloat height148 = 11.750000;
	CGRect rect151 = CGRectMake(x145, y146, width147, height148);
	CGPathAddRect(rectPath144, NULL, rect151);
	CGFloat strokeWidth152 = 0.25;
	CGRect pathBoundingBox153 = CGPathGetBoundingBox(rectPath144);
	pathBoundingBox153 = NSInsetRect(pathBoundingBox153, -strokeWidth152, -strokeWidth152);
	CGFloat scaledStrokeWidth154 = 0.25 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth154);
	NSColor * strokeColor155 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor155.CGColor);
	NSColor * fillColor156 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor156.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip157 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform142 = CGAffineTransformConcat(currentTransform142, flip157);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect158 = cellBounds;
		CGFloat boundsMidX159 = NSMidX(boundsRect158) * (1.0f / viewScale);
		CGFloat boundsMidY160 = NSMidY(boundsRect158) * (1.0f / viewScale);
		CGFloat imageMidX161 = NSMidX(webBBox);
		CGFloat imageMidY162 = NSMidY(webBBox);
		CGFloat xTranslation163 = boundsMidX159 - imageMidX161;
		CGFloat yTranslation164 = boundsMidY160 - imageMidY162;
		CGAffineTransform centerTranslation165 = CGAffineTransformMakeTranslation(xTranslation163, yTranslation164);
		currentTransform142 = CGAffineTransformConcat(currentTransform142, centerTranslation165);
	}
	CGAffineTransform translate166 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform142 = CGAffineTransformConcat(currentTransform142, translate166);
	CGAffineTransform translateXY167 = CGAffineTransformMakeTranslation(translateX, translateY);
	currentTransform142 = CGAffineTransformConcat(currentTransform142, translateXY167);
	CGAffineTransform scale168 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform142 = CGAffineTransformConcat(currentTransform142, scale168);
	CGPathRef finalPath169 = CGPathCreateCopyByTransformingPath(rectPath144, &currentTransform142);
	CGColorSpaceRef linearGradientColorSpace170 = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGFloat linearGradientColorArray172[4] = {0.941176, 0.866667, 0.603922, 1.0};
	CGColorRef linearGradientColor173 = CGColorCreate(linearGradientColorSpace170, linearGradientColorArray172);
	CGFloat linearGradientColorArray174[4] = {0.854902, 0.647059, 0.12549, 1.0};
	CGColorRef linearGradientColor175 = CGColorCreate(linearGradientColorSpace170, linearGradientColorArray174);
	CGFloat locationsArray176[] = {0.000000, 1.000000};
	NSArray * colorsArray177 = @[(__bridge id) linearGradientColor173, (__bridge id) linearGradientColor175];
	CGGradientRef linearGradient178 = CGGradientCreateWithColors(linearGradientColorSpace170, (__bridge CFArrayRef) colorsArray177, locationsArray176);
	CGRect pathBounds179 = CGPathGetPathBoundingBox(finalPath169);
	CGPoint linearGradientStartPoint180 = CGPointMake(CGRectGetMidX(pathBounds179), CGRectGetMinY(pathBounds179));
	CGPoint linearGradientEndPoint181 = CGPointMake(CGRectGetMidX(pathBounds179), CGRectGetMaxY(pathBounds179));
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath169);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, linearGradient178, linearGradientStartPoint180, linearGradientEndPoint181, 0);
	CGGradientRelease(linearGradient178);
	CGColorRelease(linearGradientColor173);
	CGColorRelease(linearGradientColor175);
	CGColorSpaceRelease(linearGradientColorSpace170);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath169);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath169);
	CGPathRelease(rectPath144);
	CGContextRestoreGState(context);
}


@end
