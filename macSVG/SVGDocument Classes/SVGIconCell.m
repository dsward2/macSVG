//
//  SVGIconCell.m
//  macSVG
//
//  Created by Douglas Ward on 8/4/16.
//
//

#import "SVGIconCell.h"

@implementation SVGIconCell

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}



- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}



- (instancetype)initImageCell:(NSImage *)anImage
{
    self = [super initImageCell:anImage];
    if (self) {
    }
    return self;
}



- (instancetype)initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];
    if (self) {
    }
    return self;
}


- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	//[super drawInteriorWithFrame:cellFrame inView:controlView];
    
    NSInteger objectValue = [self.objectValue integerValue];
    
    switch (objectValue)
    {
        case 0:
        {
            [self drawFolderIcon:cellFrame];
            break;
        }
        case 1:
        {
            [self drawTargetIcon:cellFrame];
            break;
        }
        case 2:
        {
            [self drawTextIcon:cellFrame];
            break;
        }
        otherwise:
        {
            [self drawFolderIcon:cellFrame];
            break;
        }
    }
}


//================================================================================
// drawFolderIcon:
//================================================================================

- (void)drawFolderIcon:(NSRect)cellFrame {
	// ============================================
	// Common settings
	BOOL flipImage = NO;
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
	CGContextRef context = (CGContextRef)[nsctx graphicsPort];
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
	CGContextSetStrokeColorWithColor(context, [strokeColor115 CGColor]);
	NSColor * fillColor116 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, [fillColor116 CGColor]);
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
	CGContextSetStrokeColorWithColor(context, [strokeColor155 CGColor]);
	NSColor * fillColor156 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, [fillColor156 CGColor]);
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


//================================================================================
// drawTextIcon:
//================================================================================

- (void)drawTextIcon:(NSRect)cellFrame {
	//NSBezierPath * rectPath23 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor24 = [NSColor orangeColor];
	//[rectColor24 set];
	//[rectPath23 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)[nsctx graphicsPort];
	BOOL flipImage = NO;
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
	CGContextSetStrokeColorWithColor(context, [strokeColor31 CGColor]);
	NSColor * fillColor32 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, [fillColor32 CGColor]);
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





- (void)drawTargetIcon:(NSRect)cellFrame {
	// ============================================
	// Common settings
	BOOL flipImage = NO;
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
	CGContextRef context = (CGContextRef)[nsctx graphicsPort];
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
	CGContextSetStrokeColorWithColor(context, [strokeColor15 CGColor]);
	NSColor * fillColor16 = [NSColor colorWithRed:1 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, [fillColor16 CGColor]);
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
	CGContextSetStrokeColorWithColor(context, [strokeColor40 CGColor]);
	NSColor * fillColor41 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, [fillColor41 CGColor]);
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
	CGContextSetStrokeColorWithColor(context, [strokeColor65 CGColor]);
	NSColor * fillColor66 = [NSColor colorWithRed:1 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, [fillColor66 CGColor]);
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
	CGContextSetStrokeColorWithColor(context, [strokeColor90 CGColor]);
	NSColor * fillColor91 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, [fillColor91 CGColor]);
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
