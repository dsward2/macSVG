//
//  MacSVGIconButton.m
//  macSVG
//
//  Created by Douglas Ward on 7/31/16.
//
//

#import "MacSVGIconButton.h"

@implementation MacSVGIconButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.iconIndex = self.tag;
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.iconIndex = self.tag;
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.iconIndex = self.tag;
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    switch (self.iconIndex)
    {
        case 0:
        {
            [self drawArrowCursorIcon:dirtyRect];
            break;
        }
        case 1:
        {
            [self drawRectToolIcon:dirtyRect];
            break;
        }
        case 2:
        {
            [self drawCircleToolIcon:dirtyRect];
            break;
        }
        case 3:
        {
            [self drawEllipseToolIcon:dirtyRect];
            break;
        }
        case 4:
        {
            [self drawCrosshairCursorIcon:dirtyRect];
            break;
        }
        case 5:
        {
            [self drawPolylineToolIcon:dirtyRect];
            break;
        }
        case 6:
        {
            [self drawPolygonToolIcon:dirtyRect];
            break;
        }
        case 7:
        {
            [self drawLineToolIcon:dirtyRect];
            break;
        }
        case 8:
        {
            [self drawPluginToolIcon:dirtyRect];
            break;
        }
        case 9:
        {
            [self drawTextToolIcon:dirtyRect];
            break;
        }
        case 10:
        {
            [self drawImageToolIcon:dirtyRect];
            break;
        }
        case 11:
        {
            [self drawPathToolIcon:dirtyRect];
            break;
        }
        case 12:
        {
            [self drawToolSettingsGearIcon:dirtyRect];
            break;
        }
        case 13:
        {
            [self drawTransformTranslateIcon:dirtyRect];
            break;
        }
        case 14:
        {
            [self drawTransformScaleIcon:dirtyRect];
            break;
        }
        case 15:
        {
            [self drawTransformRotateIcon:dirtyRect];
            break;
        }
        case 16:
        {
            [self drawTransformSkewXIcon:dirtyRect];
            break;
        }
        case 17:
        {
            [self drawTransformSkewYIcon:dirtyRect];
            break;
        }
        default:
        {
            [self drawArrowCursorIcon:dirtyRect];
            break;
        }
    }
}


/*
- (IBAction)buttonClicked:(id)sender
{
}
*/

//================================================================================
// drawArrowCursorIcon:
//================================================================================

- (void)drawArrowCursorIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath1 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor2 = [NSColor orangeColor];
	//[rectColor2 set];
	//[rectPath1 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	NSRect webBBox = NSMakeRect(0.000000, 0.000000, 182.000000, 311.000000);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.5f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <path stroke="#000000" macsvgid="49D5AACE-06AF-4DF9-A736-8307F87CCF42-7830-000026383E81C0F3" id="arrow_cursor" stroke-width="1px" d="M0,0 L6,251 L57,195 L108,311 L164,281 L98,178 L182,178 L0,0 " fill="black" transform="" visibility="visible"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform3 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix4 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, ctmMatrix4);
	CGMutablePathRef path5 = CGPathCreateMutable();
	CGPathMoveToPoint(path5, NULL, 0, 0);
	CGPathAddLineToPoint(path5, NULL, 6, 251);
	CGPathAddLineToPoint(path5, NULL, 57, 195);
	CGPathAddLineToPoint(path5, NULL, 108, 311);
	CGPathAddLineToPoint(path5, NULL, 164, 281);
	CGPathAddLineToPoint(path5, NULL, 98, 178);
	CGPathAddLineToPoint(path5, NULL, 182, 178);
	CGPathAddLineToPoint(path5, NULL, 0, 0);
	CGFloat strokeWidth6 = 1;
	CGRect pathBoundingBox7 = CGPathGetBoundingBox(path5);
	pathBoundingBox7 = NSInsetRect(pathBoundingBox7, -strokeWidth6, -strokeWidth6);
	CGFloat scaledStrokeWidth8 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth8);
	NSColor * strokeColor9 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor9.CGColor);
	NSColor * fillColor10 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor10.CGColor);
	if (NO) { // flip image vertically
		CGAffineTransform flip11 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform3 = CGAffineTransformConcat(currentTransform3, flip11);
	}
	if (YES) { // center image
		NSRect boundsRect12 = self.bounds;
		CGFloat boundsMidX13 = NSMidX(boundsRect12) * (1.0f / viewScale);
		CGFloat boundsMidY14 = NSMidY(boundsRect12) * (1.0f / viewScale);
		CGFloat imageMidX15 = NSMidX(webBBox);
		CGFloat imageMidY16 = NSMidY(webBBox);
		CGFloat xTranslation17 = boundsMidX13 - imageMidX15;
		CGFloat yTranslation18 = boundsMidY14 - imageMidY16;
		CGAffineTransform centerTranslation19 = CGAffineTransformMakeTranslation(xTranslation17, yTranslation18);
		currentTransform3 = CGAffineTransformConcat(currentTransform3, centerTranslation19);
	}
    CGAffineTransform translate20 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, translate20);
	CGAffineTransform scale21 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, scale21);
	CGPathRef finalPath22 = CGPathCreateCopyByTransformingPath(path5, &currentTransform3);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath22);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath22);
	CGPathRelease(path5);
	CGContextRestoreGState(context);
}

//================================================================================
// drawRectToolIcon:
//================================================================================

- (void)drawRectToolIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath1 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor2 = [NSColor orangeColor];
	//[rectColor2 set];
	//[rectPath1 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(10.000000, 10.000000, 435.000000, 438.000000);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.5f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <rect stroke="#000000" height="438px" x="10px" id="rect_tool" stroke-width="20px" width="435px" y="10px" fill="none" transform="" visibility="visible" macsvgid="8C482BA0-A5EB-4471-8C69-E39AB3E845A5-8258-000027CA241319FA"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform3 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix4 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, ctmMatrix4);
	CGMutablePathRef rectPath5 = CGPathCreateMutable();
	CGFloat x6 = 10.000000;
	CGFloat y7 = 10.000000;
	CGFloat width8 = 435.000000;
	CGFloat height9 = 438.000000;
	CGRect rect10 = CGRectMake(x6, y7, width8, height9);
	CGPathAddRect(rectPath5, NULL, rect10);
	CGFloat strokeWidth11 = 20;
	CGRect pathBoundingBox12 = CGPathGetBoundingBox(rectPath5);
	pathBoundingBox12 = NSInsetRect(pathBoundingBox12, -strokeWidth11, -strokeWidth11);
	CGFloat scaledStrokeWidth13 = 20 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth13);
	NSColor * strokeColor14 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor14.CGColor);
	NSColor * fillColor15 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor15.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip16 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform3 = CGAffineTransformConcat(currentTransform3, flip16);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect17 = self.bounds;
		CGFloat boundsMidX18 = NSMidX(boundsRect17) * (1.0f / viewScale);
		CGFloat boundsMidY19 = NSMidY(boundsRect17) * (1.0f / viewScale);
		CGFloat imageMidX20 = NSMidX(webBBox);
		CGFloat imageMidY21 = NSMidY(webBBox);
		CGFloat xTranslation22 = boundsMidX18 - imageMidX20;
		CGFloat yTranslation23 = boundsMidY19 - imageMidY21;
		CGAffineTransform centerTranslation24 = CGAffineTransformMakeTranslation(xTranslation22, yTranslation23);
		currentTransform3 = CGAffineTransformConcat(currentTransform3, centerTranslation24);
	}
	CGAffineTransform translate25 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, translate25);
	CGAffineTransform scale26 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, scale26);
	CGPathRef finalPath27 = CGPathCreateCopyByTransformingPath(rectPath5, &currentTransform3);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath27);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath27);
	CGPathRelease(rectPath5);
	CGContextRestoreGState(context);
}

//================================================================================
// drawCircleToolIcon:
//================================================================================

- (void)drawCircleToolIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath28 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor29 = [NSColor orangeColor];
	//[rectColor29 set];
	//[rectPath28 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(22.000000, 23.000000, 416.000000, 416.000000);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.5f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" cx="230px" id="circle_tool" stroke-width="20px" cy="231px" fill="none" r="208px" transform="" visibility="visible" macsvgid="5EAC59A0-D67F-493D-8B76-DDDB9C83B579-8258-000027CA241346DE"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform30 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix31 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform30 = CGAffineTransformConcat(currentTransform30, ctmMatrix31);
	CGMutablePathRef circlePath32 = CGPathCreateMutable();
	CGFloat cx33 = 230.000000;
	CGFloat cy34 = 231.000000;
	CGFloat r35 = 208.000000;
	CGRect circleRect36 = CGRectMake((cx33 - r35), (cy34 - r35), (r35 * 2.0f), (r35 * 2.0f));
	CGPathAddEllipseInRect(circlePath32, NULL, circleRect36);
	CGFloat strokeWidth37 = 20;
	CGRect pathBoundingBox38 = CGPathGetBoundingBox(circlePath32);
	pathBoundingBox38 = NSInsetRect(pathBoundingBox38, -strokeWidth37, -strokeWidth37);
	CGFloat scaledStrokeWidth39 = 20 * viewScale;
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
		NSRect boundsRect43 = self.bounds;
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
	CGAffineTransform scale52 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform30 = CGAffineTransformConcat(currentTransform30, scale52);
	CGPathRef finalPath53 = CGPathCreateCopyByTransformingPath(circlePath32, &currentTransform30);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath53);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath53);
	CGPathRelease(circlePath32);
	CGContextRestoreGState(context);
}

//================================================================================
// drawEllipseToolIcon:
//================================================================================

- (void)drawEllipseToolIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath54 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor55 = [NSColor orangeColor];
	//[rectColor55 set];
	//[rectPath54 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(11.000000, 18.000000, 436.000000, 286.000000);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.4f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <ellipse stroke="#000000" transform="" id="ellipse_tool" cy="161px" stroke-width="20px" fill="none" rx="218px" cx="229px" ry="143px" visibility="visible" macsvgid="F96E6D6D-37F4-47CE-935E-B51B564CB3D2-8258-000027CA24137457"></ellipse>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform56 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix57 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform56 = CGAffineTransformConcat(currentTransform56, ctmMatrix57);
	CGMutablePathRef ellipsePath58 = CGPathCreateMutable();
	CGFloat cx59 = 229.000000;
	CGFloat cy60 = 161.000000;
	CGFloat rx61 = 218.000000;
	CGFloat ry62 = 143.000000;
	CGRect ellipseRect63 = CGRectMake((cx59 - rx61), (cy60 - ry62), (rx61 * 2.0f), (ry62 * 2.0f));
	CGPathAddEllipseInRect(ellipsePath58, NULL, ellipseRect63);
	CGFloat strokeWidth64 = 20;
	CGRect pathBoundingBox65 = CGPathGetBoundingBox(ellipsePath58);
	pathBoundingBox65 = NSInsetRect(pathBoundingBox65, -strokeWidth64, -strokeWidth64);
	CGFloat scaledStrokeWidth66 = 20 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth66);
	NSColor * strokeColor67 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor67.CGColor);
	NSColor * fillColor68 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor68.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip69 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform56 = CGAffineTransformConcat(currentTransform56, flip69);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect70 = self.bounds;
		CGFloat boundsMidX71 = NSMidX(boundsRect70) * (1.0f / viewScale);
		CGFloat boundsMidY72 = NSMidY(boundsRect70) * (1.0f / viewScale);
		CGFloat imageMidX73 = NSMidX(webBBox);
		CGFloat imageMidY74 = NSMidY(webBBox);
		CGFloat xTranslation75 = boundsMidX71 - imageMidX73;
		CGFloat yTranslation76 = boundsMidY72 - imageMidY74;
		CGAffineTransform centerTranslation77 = CGAffineTransformMakeTranslation(xTranslation75, yTranslation76);
		currentTransform56 = CGAffineTransformConcat(currentTransform56, centerTranslation77);
	}
	CGAffineTransform translate78 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform56 = CGAffineTransformConcat(currentTransform56, translate78);
	CGAffineTransform scale79 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform56 = CGAffineTransformConcat(currentTransform56, scale79);
	CGPathRef finalPath80 = CGPathCreateCopyByTransformingPath(ellipsePath58, &currentTransform56);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath80);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath80);
	CGPathRelease(ellipsePath58);
	CGContextRestoreGState(context);
}

//================================================================================
// drawCrosshairCursorIcon:
//================================================================================

- (void)drawCrosshairCursorIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath81 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor82 = [NSColor orangeColor];
	//[rectColor82 set];
	//[rectPath81 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(3.000000, 3.000000, 258.000000, 259.000000);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.5f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <path stroke="#000000" macsvgid="48AA88D3-54C3-4946-B3E8-4D223DB234A1-8258-000027CA2413A2C4" id="crosshair_cursor" stroke-width="20px" d="M3,133 H81 M102,133 H159 M181,134 H261 M129,3 V84 M130,102 V161 M131,184 V262 " fill="none" transform="" visibility="visible"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform83 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix84 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform83 = CGAffineTransformConcat(currentTransform83, ctmMatrix84);
	CGMutablePathRef path85 = CGPathCreateMutable();
	CGPathMoveToPoint(path85, NULL, 3, 133);
	CGPathAddLineToPoint(path85, NULL, 81, 133);
	CGPathMoveToPoint(path85, NULL, 102, 133);
	CGPathAddLineToPoint(path85, NULL, 159, 133);
	CGPathMoveToPoint(path85, NULL, 181, 134);
	CGPathAddLineToPoint(path85, NULL, 261, 134);
	CGPathMoveToPoint(path85, NULL, 129, 3);
	CGPathAddLineToPoint(path85, NULL, 129, 84);
	CGPathMoveToPoint(path85, NULL, 130, 102);
	CGPathAddLineToPoint(path85, NULL, 130, 161);
	CGPathMoveToPoint(path85, NULL, 131, 184);
	CGPathAddLineToPoint(path85, NULL, 131, 262);
	CGFloat strokeWidth86 = 20;
	CGRect pathBoundingBox87 = CGPathGetBoundingBox(path85);
	pathBoundingBox87 = NSInsetRect(pathBoundingBox87, -strokeWidth86, -strokeWidth86);
	CGFloat scaledStrokeWidth88 = 20 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth88);
	NSColor * strokeColor89 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor89.CGColor);
	NSColor * fillColor90 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor90.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip91 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform83 = CGAffineTransformConcat(currentTransform83, flip91);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect92 = self.bounds;
		CGFloat boundsMidX93 = NSMidX(boundsRect92) * (1.0f / viewScale);
		CGFloat boundsMidY94 = NSMidY(boundsRect92) * (1.0f / viewScale);
		CGFloat imageMidX95 = NSMidX(webBBox);
		CGFloat imageMidY96 = NSMidY(webBBox);
		CGFloat xTranslation97 = boundsMidX93 - imageMidX95;
		CGFloat yTranslation98 = boundsMidY94 - imageMidY96;
		CGAffineTransform centerTranslation99 = CGAffineTransformMakeTranslation(xTranslation97, yTranslation98);
		currentTransform83 = CGAffineTransformConcat(currentTransform83, centerTranslation99);
	}
	CGAffineTransform translate100 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform83 = CGAffineTransformConcat(currentTransform83, translate100);
	CGAffineTransform scale101 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform83 = CGAffineTransformConcat(currentTransform83, scale101);
	CGPathRef finalPath102 = CGPathCreateCopyByTransformingPath(path85, &currentTransform83);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath102);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath102);
	CGPathRelease(path85);
	CGContextRestoreGState(context);
}

//================================================================================
// drawPolylineToolIcon:
//================================================================================

- (void)drawPolylineToolIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath1 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor2 = [NSColor orangeColor];
	//[rectColor2 set];
	//[rectPath1 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(-28.000000, -29.000000, 643.000000, 543.000000);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.65f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="polyline_tool" visibility="visible" macsvgid="886909DE-D816-4B2E-86D6-2112FD78CF1A-8927-00002A47C32AF19E"><path stroke="#000000" id="polyline_path" stroke-width="20px" d="M527,133 L116,45 L37,367 L274,274 L468,450" fill="none" transform="" macsvgid="9D28960C-1E94-418C-BB68-69DB9C8532B6-8927-00002A47C32B1471"></path><circle stroke="#000000" transform="" id="circle1" stroke-width="10px" cy="132.5px" fill="#ffffff" r="37.5px" cx="542.5px" macsvgid="D969EDB8-7D45-4E10-A706-F25B0273DEC3-8927-00002A47C32B4061"></circle><circle stroke="#000000" transform="" stroke-width="10px" id="circle2" cy="43.5px" fill="#ffffff" r="37.5px" cx="114.5px" macsvgid="F202DD5F-6AA3-42F5-AAC5-574AC64EE9A4-8927-00002A47C32B6CC4"></circle><circle stroke="#000000" transform="" stroke-width="10px" id="circle3" cy="358.5px" fill="#ffffff" r="37.5px" cx="44.5px" macsvgid="D3DF80DA-F8D6-4241-9BE3-21394C5B7118-8927-00002A47C32B96BF"></circle><circle stroke="#000000" transform="" stroke-width="10px" id="circle4" cy="278.5px" fill="#ffffff" r="37.5px" cx="268.5px" macsvgid="F6F4406A-E82E-4EDF-96DB-24E68AFA50ED-8927-00002A47C32BC15D"></circle><circle stroke="#000000" transform="" stroke-width="10px" id="circle5" cy="441.5px" fill="#ffffff" r="37.5px" cx="462.5px" macsvgid="52877522-364F-4F54-9347-0452363C72C7-8927-00002A47C32BED8C"></circle></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform3 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix4 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, ctmMatrix4);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <path stroke="#000000" id="polyline_path" stroke-width="20px" d="M527,133 L116,45 L37,367 L274,274 L468,450" fill="none" transform="" macsvgid="9D28960C-1E94-418C-BB68-69DB9C8532B6-8927-00002A47C32B1471"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform5 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix6 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, ctmMatrix6);
	CGMutablePathRef path7 = CGPathCreateMutable();
	CGPathMoveToPoint(path7, NULL, 527, 133);
	CGPathAddLineToPoint(path7, NULL, 116, 45);
	CGPathAddLineToPoint(path7, NULL, 37, 367);
	CGPathAddLineToPoint(path7, NULL, 274, 274);
	CGPathAddLineToPoint(path7, NULL, 468, 450);
	CGFloat strokeWidth8 = 20;
	CGRect pathBoundingBox9 = CGPathGetBoundingBox(path7);
	pathBoundingBox9 = NSInsetRect(pathBoundingBox9, -strokeWidth8, -strokeWidth8);
	CGFloat scaledStrokeWidth10 = 20 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth10);
	NSColor * strokeColor11 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor11.CGColor);
	NSColor * fillColor12 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor12.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip13 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform5 = CGAffineTransformConcat(currentTransform5, flip13);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect14 = self.bounds;
		CGFloat boundsMidX15 = NSMidX(boundsRect14) * (1.0f / viewScale);
		CGFloat boundsMidY16 = NSMidY(boundsRect14) * (1.0f / viewScale);
		CGFloat imageMidX17 = NSMidX(webBBox);
		CGFloat imageMidY18 = NSMidY(webBBox);
		CGFloat xTranslation19 = boundsMidX15 - imageMidX17;
		CGFloat yTranslation20 = boundsMidY16 - imageMidY18;
		CGAffineTransform centerTranslation21 = CGAffineTransformMakeTranslation(xTranslation19, yTranslation20);
		currentTransform5 = CGAffineTransformConcat(currentTransform5, centerTranslation21);
	}
	CGAffineTransform translate22 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, translate22);
	CGAffineTransform scale23 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, scale23);
	CGPathRef finalPath24 = CGPathCreateCopyByTransformingPath(path7, &currentTransform5);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath24);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath24);
	CGPathRelease(path7);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" transform="" id="circle1" stroke-width="10px" cy="132.5px" fill="#ffffff" r="37.5px" cx="542.5px" macsvgid="D969EDB8-7D45-4E10-A706-F25B0273DEC3-8927-00002A47C32B4061"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform25 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix26 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform25 = CGAffineTransformConcat(currentTransform25, ctmMatrix26);
	CGMutablePathRef circlePath27 = CGPathCreateMutable();
	CGFloat cx28 = 542.500000;
	CGFloat cy29 = 132.500000;
	CGFloat r30 = 37.500000;
	CGRect circleRect31 = CGRectMake((cx28 - r30), (cy29 - r30), (r30 * 2.0f), (r30 * 2.0f));
	CGPathAddEllipseInRect(circlePath27, NULL, circleRect31);
	CGFloat strokeWidth32 = 10;
	CGRect pathBoundingBox33 = CGPathGetBoundingBox(circlePath27);
	pathBoundingBox33 = NSInsetRect(pathBoundingBox33, -strokeWidth32, -strokeWidth32);
	CGFloat scaledStrokeWidth34 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth34);
	NSColor * strokeColor35 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor35.CGColor);
	NSColor * fillColor36 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor36.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip37 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform25 = CGAffineTransformConcat(currentTransform25, flip37);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect38 = self.bounds;
		CGFloat boundsMidX39 = NSMidX(boundsRect38) * (1.0f / viewScale);
		CGFloat boundsMidY40 = NSMidY(boundsRect38) * (1.0f / viewScale);
		CGFloat imageMidX41 = NSMidX(webBBox);
		CGFloat imageMidY42 = NSMidY(webBBox);
		CGFloat xTranslation43 = boundsMidX39 - imageMidX41;
		CGFloat yTranslation44 = boundsMidY40 - imageMidY42;
		CGAffineTransform centerTranslation45 = CGAffineTransformMakeTranslation(xTranslation43, yTranslation44);
		currentTransform25 = CGAffineTransformConcat(currentTransform25, centerTranslation45);
	}
	CGAffineTransform translate46 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform25 = CGAffineTransformConcat(currentTransform25, translate46);
	CGAffineTransform scale47 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform25 = CGAffineTransformConcat(currentTransform25, scale47);
	CGPathRef finalPath48 = CGPathCreateCopyByTransformingPath(circlePath27, &currentTransform25);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath48);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath48);
	CGPathRelease(circlePath27);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" transform="" stroke-width="10px" id="circle2" cy="43.5px" fill="#ffffff" r="37.5px" cx="114.5px" macsvgid="F202DD5F-6AA3-42F5-AAC5-574AC64EE9A4-8927-00002A47C32B6CC4"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform49 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix50 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform49 = CGAffineTransformConcat(currentTransform49, ctmMatrix50);
	CGMutablePathRef circlePath51 = CGPathCreateMutable();
	CGFloat cx52 = 114.500000;
	CGFloat cy53 = 43.500000;
	CGFloat r54 = 37.500000;
	CGRect circleRect55 = CGRectMake((cx52 - r54), (cy53 - r54), (r54 * 2.0f), (r54 * 2.0f));
	CGPathAddEllipseInRect(circlePath51, NULL, circleRect55);
	CGFloat strokeWidth56 = 10;
	CGRect pathBoundingBox57 = CGPathGetBoundingBox(circlePath51);
	pathBoundingBox57 = NSInsetRect(pathBoundingBox57, -strokeWidth56, -strokeWidth56);
	CGFloat scaledStrokeWidth58 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth58);
	NSColor * strokeColor59 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor59.CGColor);
	NSColor * fillColor60 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor60.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip61 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform49 = CGAffineTransformConcat(currentTransform49, flip61);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect62 = self.bounds;
		CGFloat boundsMidX63 = NSMidX(boundsRect62) * (1.0f / viewScale);
		CGFloat boundsMidY64 = NSMidY(boundsRect62) * (1.0f / viewScale);
		CGFloat imageMidX65 = NSMidX(webBBox);
		CGFloat imageMidY66 = NSMidY(webBBox);
		CGFloat xTranslation67 = boundsMidX63 - imageMidX65;
		CGFloat yTranslation68 = boundsMidY64 - imageMidY66;
		CGAffineTransform centerTranslation69 = CGAffineTransformMakeTranslation(xTranslation67, yTranslation68);
		currentTransform49 = CGAffineTransformConcat(currentTransform49, centerTranslation69);
	}
	CGAffineTransform translate70 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform49 = CGAffineTransformConcat(currentTransform49, translate70);
	CGAffineTransform scale71 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform49 = CGAffineTransformConcat(currentTransform49, scale71);
	CGPathRef finalPath72 = CGPathCreateCopyByTransformingPath(circlePath51, &currentTransform49);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath72);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath72);
	CGPathRelease(circlePath51);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" transform="" stroke-width="10px" id="circle3" cy="358.5px" fill="#ffffff" r="37.5px" cx="44.5px" macsvgid="D3DF80DA-F8D6-4241-9BE3-21394C5B7118-8927-00002A47C32B96BF"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform73 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix74 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform73 = CGAffineTransformConcat(currentTransform73, ctmMatrix74);
	CGMutablePathRef circlePath75 = CGPathCreateMutable();
	CGFloat cx76 = 44.500000;
	CGFloat cy77 = 358.500000;
	CGFloat r78 = 37.500000;
	CGRect circleRect79 = CGRectMake((cx76 - r78), (cy77 - r78), (r78 * 2.0f), (r78 * 2.0f));
	CGPathAddEllipseInRect(circlePath75, NULL, circleRect79);
	CGFloat strokeWidth80 = 10;
	CGRect pathBoundingBox81 = CGPathGetBoundingBox(circlePath75);
	pathBoundingBox81 = NSInsetRect(pathBoundingBox81, -strokeWidth80, -strokeWidth80);
	CGFloat scaledStrokeWidth82 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth82);
	NSColor * strokeColor83 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor83.CGColor);
	NSColor * fillColor84 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor84.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip85 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform73 = CGAffineTransformConcat(currentTransform73, flip85);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect86 = self.bounds;
		CGFloat boundsMidX87 = NSMidX(boundsRect86) * (1.0f / viewScale);
		CGFloat boundsMidY88 = NSMidY(boundsRect86) * (1.0f / viewScale);
		CGFloat imageMidX89 = NSMidX(webBBox);
		CGFloat imageMidY90 = NSMidY(webBBox);
		CGFloat xTranslation91 = boundsMidX87 - imageMidX89;
		CGFloat yTranslation92 = boundsMidY88 - imageMidY90;
		CGAffineTransform centerTranslation93 = CGAffineTransformMakeTranslation(xTranslation91, yTranslation92);
		currentTransform73 = CGAffineTransformConcat(currentTransform73, centerTranslation93);
	}
	CGAffineTransform translate94 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform73 = CGAffineTransformConcat(currentTransform73, translate94);
	CGAffineTransform scale95 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform73 = CGAffineTransformConcat(currentTransform73, scale95);
	CGPathRef finalPath96 = CGPathCreateCopyByTransformingPath(circlePath75, &currentTransform73);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath96);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath96);
	CGPathRelease(circlePath75);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" transform="" stroke-width="10px" id="circle4" cy="278.5px" fill="#ffffff" r="37.5px" cx="268.5px" macsvgid="F6F4406A-E82E-4EDF-96DB-24E68AFA50ED-8927-00002A47C32BC15D"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform97 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix98 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform97 = CGAffineTransformConcat(currentTransform97, ctmMatrix98);
	CGMutablePathRef circlePath99 = CGPathCreateMutable();
	CGFloat cx100 = 268.500000;
	CGFloat cy101 = 278.500000;
	CGFloat r102 = 37.500000;
	CGRect circleRect103 = CGRectMake((cx100 - r102), (cy101 - r102), (r102 * 2.0f), (r102 * 2.0f));
	CGPathAddEllipseInRect(circlePath99, NULL, circleRect103);
	CGFloat strokeWidth104 = 10;
	CGRect pathBoundingBox105 = CGPathGetBoundingBox(circlePath99);
	pathBoundingBox105 = NSInsetRect(pathBoundingBox105, -strokeWidth104, -strokeWidth104);
	CGFloat scaledStrokeWidth106 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth106);
	NSColor * strokeColor107 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor107.CGColor);
	NSColor * fillColor108 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor108.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip109 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform97 = CGAffineTransformConcat(currentTransform97, flip109);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect110 = self.bounds;
		CGFloat boundsMidX111 = NSMidX(boundsRect110) * (1.0f / viewScale);
		CGFloat boundsMidY112 = NSMidY(boundsRect110) * (1.0f / viewScale);
		CGFloat imageMidX113 = NSMidX(webBBox);
		CGFloat imageMidY114 = NSMidY(webBBox);
		CGFloat xTranslation115 = boundsMidX111 - imageMidX113;
		CGFloat yTranslation116 = boundsMidY112 - imageMidY114;
		CGAffineTransform centerTranslation117 = CGAffineTransformMakeTranslation(xTranslation115, yTranslation116);
		currentTransform97 = CGAffineTransformConcat(currentTransform97, centerTranslation117);
	}
	CGAffineTransform translate118 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform97 = CGAffineTransformConcat(currentTransform97, translate118);
	CGAffineTransform scale119 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform97 = CGAffineTransformConcat(currentTransform97, scale119);
	CGPathRef finalPath120 = CGPathCreateCopyByTransformingPath(circlePath99, &currentTransform97);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath120);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath120);
	CGPathRelease(circlePath99);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" transform="" stroke-width="10px" id="circle5" cy="441.5px" fill="#ffffff" r="37.5px" cx="462.5px" macsvgid="52877522-364F-4F54-9347-0452363C72C7-8927-00002A47C32BED8C"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform121 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix122 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform121 = CGAffineTransformConcat(currentTransform121, ctmMatrix122);
	CGMutablePathRef circlePath123 = CGPathCreateMutable();
	CGFloat cx124 = 462.500000;
	CGFloat cy125 = 441.500000;
	CGFloat r126 = 37.500000;
	CGRect circleRect127 = CGRectMake((cx124 - r126), (cy125 - r126), (r126 * 2.0f), (r126 * 2.0f));
	CGPathAddEllipseInRect(circlePath123, NULL, circleRect127);
	CGFloat strokeWidth128 = 10;
	CGRect pathBoundingBox129 = CGPathGetBoundingBox(circlePath123);
	pathBoundingBox129 = NSInsetRect(pathBoundingBox129, -strokeWidth128, -strokeWidth128);
	CGFloat scaledStrokeWidth130 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth130);
	NSColor * strokeColor131 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor131.CGColor);
	NSColor * fillColor132 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor132.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip133 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform121 = CGAffineTransformConcat(currentTransform121, flip133);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect134 = self.bounds;
		CGFloat boundsMidX135 = NSMidX(boundsRect134) * (1.0f / viewScale);
		CGFloat boundsMidY136 = NSMidY(boundsRect134) * (1.0f / viewScale);
		CGFloat imageMidX137 = NSMidX(webBBox);
		CGFloat imageMidY138 = NSMidY(webBBox);
		CGFloat xTranslation139 = boundsMidX135 - imageMidX137;
		CGFloat yTranslation140 = boundsMidY136 - imageMidY138;
		CGAffineTransform centerTranslation141 = CGAffineTransformMakeTranslation(xTranslation139, yTranslation140);
		currentTransform121 = CGAffineTransformConcat(currentTransform121, centerTranslation141);
	}
	CGAffineTransform translate142 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform121 = CGAffineTransformConcat(currentTransform121, translate142);
	CGAffineTransform scale143 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform121 = CGAffineTransformConcat(currentTransform121, scale143);
	CGPathRef finalPath144 = CGPathCreateCopyByTransformingPath(circlePath123, &currentTransform121);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath144);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath144);
	CGPathRelease(circlePath123);
	CGContextRestoreGState(context);
}


//================================================================================
// drawPolygonToolIcon:
//================================================================================

- (void)drawPolygonToolIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath1 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor2 = [NSColor orangeColor];
	//[rectColor2 set];
	//[rectPath1 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(-28.000000, -29.000000, 642.000000, 566.000000);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.65f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="polygon_tool" visibility="visible" macsvgid="A7526FA1-FDF4-4435-BE4D-223EC330401D-9432-00002BF987FA7032"><polygon points="530 136, 124 48, 38 383, 281 288, 483 463" stroke="#000000" id="polygon1" stroke-width="20px" fill="#ffffff" transform="" macsvgid="44AED2DA-FD65-45AD-BAB0-9AA1FACBE7F1-9432-00002BF987FA90BD"></polygon><circle stroke="#000000" transform="" id="circle6" stroke-width="10px" cy="128px" fill="#ffffff" r="41px" cx="538px" macsvgid="331A8C53-0B39-48BF-99D1-587CFEBAD720-9432-00002BF987FAB9E0"></circle><circle stroke="#000000" transform="" stroke-width="10px" id="circle7" cy="47px" fill="#ffffff" r="41px" cx="122px" macsvgid="5D389010-3FC2-4813-B3BD-51F2F258FB7E-9432-00002BF987FAE395"></circle><circle stroke="#000000" transform="" stroke-width="10px" id="circle8" cy="375px" fill="#ffffff" r="41px" cx="48px" macsvgid="2D7E10CB-1CE6-4095-8B6D-4089ABE16A78-9432-00002BF987FB0D38"></circle><circle stroke="#000000" transform="" stroke-width="10px" id="circle9" cy="289px" fill="#ffffff" r="41px" cx="282px" macsvgid="A3229660-9BE8-4F85-AC8E-8107C11D703D-9432-00002BF987FB35A5"></circle><circle stroke="#000000" stroke-width="10px" cy="461px" id="circle10" fill="#ffffff" r="41px" cx="476px" transform="" macsvgid="9BEC4FE3-858C-4196-8D1C-3C65F3837165-9432-00002BF987FB5EA5"></circle></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform3 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix4 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, ctmMatrix4);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <polygon points="530 136, 124 48, 38 383, 281 288, 483 463" stroke="#000000" id="polygon1" stroke-width="20px" fill="#ffffff" transform="" macsvgid="44AED2DA-FD65-45AD-BAB0-9AA1FACBE7F1-9432-00002BF987FA90BD"></polygon>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform5 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix6 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, ctmMatrix6);
	CGMutablePathRef polygonPath7 = CGPathCreateMutable();
	CGPathMoveToPoint(polygonPath7, NULL, 530, 136);
	CGPathAddLineToPoint(polygonPath7, NULL, 124, 48);
	CGPathAddLineToPoint(polygonPath7, NULL, 38, 383);
	CGPathAddLineToPoint(polygonPath7, NULL, 281, 288);
	CGPathAddLineToPoint(polygonPath7, NULL, 483, 463);
	CGPathAddLineToPoint(polygonPath7, NULL, 530, 136);
	CGFloat strokeWidth8 = 20;
	CGRect pathBoundingBox9 = CGPathGetBoundingBox(polygonPath7);
	pathBoundingBox9 = NSInsetRect(pathBoundingBox9, -strokeWidth8, -strokeWidth8);
	CGFloat scaledStrokeWidth10 = 20 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth10);
	NSColor * strokeColor11 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor11.CGColor);
	NSColor * fillColor12 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor12.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip13 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform5 = CGAffineTransformConcat(currentTransform5, flip13);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect14 = self.bounds;
		CGFloat boundsMidX15 = NSMidX(boundsRect14) * (1.0f / viewScale);
		CGFloat boundsMidY16 = NSMidY(boundsRect14) * (1.0f / viewScale);
		CGFloat imageMidX17 = NSMidX(webBBox);
		CGFloat imageMidY18 = NSMidY(webBBox);
		CGFloat xTranslation19 = boundsMidX15 - imageMidX17;
		CGFloat yTranslation20 = boundsMidY16 - imageMidY18;
		CGAffineTransform centerTranslation21 = CGAffineTransformMakeTranslation(xTranslation19, yTranslation20);
		currentTransform5 = CGAffineTransformConcat(currentTransform5, centerTranslation21);
	}
	CGAffineTransform translate22 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, translate22);
	CGAffineTransform scale23 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, scale23);
	CGPathRef finalPath24 = CGPathCreateCopyByTransformingPath(polygonPath7, &currentTransform5);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath24);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath24);
	CGPathRelease(polygonPath7);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" transform="" id="circle6" stroke-width="10px" cy="128px" fill="#ffffff" r="41px" cx="538px" macsvgid="331A8C53-0B39-48BF-99D1-587CFEBAD720-9432-00002BF987FAB9E0"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform25 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix26 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform25 = CGAffineTransformConcat(currentTransform25, ctmMatrix26);
	CGMutablePathRef circlePath27 = CGPathCreateMutable();
	CGFloat cx28 = 538.000000;
	CGFloat cy29 = 128.000000;
	CGFloat r30 = 41.000000;
	CGRect circleRect31 = CGRectMake((cx28 - r30), (cy29 - r30), (r30 * 2.0f), (r30 * 2.0f));
	CGPathAddEllipseInRect(circlePath27, NULL, circleRect31);
	CGFloat strokeWidth32 = 10;
	CGRect pathBoundingBox33 = CGPathGetBoundingBox(circlePath27);
	pathBoundingBox33 = NSInsetRect(pathBoundingBox33, -strokeWidth32, -strokeWidth32);
	CGFloat scaledStrokeWidth34 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth34);
	NSColor * strokeColor35 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor35.CGColor);
	NSColor * fillColor36 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor36.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip37 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform25 = CGAffineTransformConcat(currentTransform25, flip37);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect38 = self.bounds;
		CGFloat boundsMidX39 = NSMidX(boundsRect38) * (1.0f / viewScale);
		CGFloat boundsMidY40 = NSMidY(boundsRect38) * (1.0f / viewScale);
		CGFloat imageMidX41 = NSMidX(webBBox);
		CGFloat imageMidY42 = NSMidY(webBBox);
		CGFloat xTranslation43 = boundsMidX39 - imageMidX41;
		CGFloat yTranslation44 = boundsMidY40 - imageMidY42;
		CGAffineTransform centerTranslation45 = CGAffineTransformMakeTranslation(xTranslation43, yTranslation44);
		currentTransform25 = CGAffineTransformConcat(currentTransform25, centerTranslation45);
	}
	CGAffineTransform translate46 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform25 = CGAffineTransformConcat(currentTransform25, translate46);
	CGAffineTransform scale47 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform25 = CGAffineTransformConcat(currentTransform25, scale47);
	CGPathRef finalPath48 = CGPathCreateCopyByTransformingPath(circlePath27, &currentTransform25);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath48);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath48);
	CGPathRelease(circlePath27);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" transform="" stroke-width="10px" id="circle7" cy="47px" fill="#ffffff" r="41px" cx="122px" macsvgid="5D389010-3FC2-4813-B3BD-51F2F258FB7E-9432-00002BF987FAE395"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform49 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix50 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform49 = CGAffineTransformConcat(currentTransform49, ctmMatrix50);
	CGMutablePathRef circlePath51 = CGPathCreateMutable();
	CGFloat cx52 = 122.000000;
	CGFloat cy53 = 47.000000;
	CGFloat r54 = 41.000000;
	CGRect circleRect55 = CGRectMake((cx52 - r54), (cy53 - r54), (r54 * 2.0f), (r54 * 2.0f));
	CGPathAddEllipseInRect(circlePath51, NULL, circleRect55);
	CGFloat strokeWidth56 = 10;
	CGRect pathBoundingBox57 = CGPathGetBoundingBox(circlePath51);
	pathBoundingBox57 = NSInsetRect(pathBoundingBox57, -strokeWidth56, -strokeWidth56);
	CGFloat scaledStrokeWidth58 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth58);
	NSColor * strokeColor59 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor59.CGColor);
	NSColor * fillColor60 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor60.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip61 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform49 = CGAffineTransformConcat(currentTransform49, flip61);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect62 = self.bounds;
		CGFloat boundsMidX63 = NSMidX(boundsRect62) * (1.0f / viewScale);
		CGFloat boundsMidY64 = NSMidY(boundsRect62) * (1.0f / viewScale);
		CGFloat imageMidX65 = NSMidX(webBBox);
		CGFloat imageMidY66 = NSMidY(webBBox);
		CGFloat xTranslation67 = boundsMidX63 - imageMidX65;
		CGFloat yTranslation68 = boundsMidY64 - imageMidY66;
		CGAffineTransform centerTranslation69 = CGAffineTransformMakeTranslation(xTranslation67, yTranslation68);
		currentTransform49 = CGAffineTransformConcat(currentTransform49, centerTranslation69);
	}
	CGAffineTransform translate70 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform49 = CGAffineTransformConcat(currentTransform49, translate70);
	CGAffineTransform scale71 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform49 = CGAffineTransformConcat(currentTransform49, scale71);
	CGPathRef finalPath72 = CGPathCreateCopyByTransformingPath(circlePath51, &currentTransform49);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath72);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath72);
	CGPathRelease(circlePath51);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" transform="" stroke-width="10px" id="circle8" cy="375px" fill="#ffffff" r="41px" cx="48px" macsvgid="2D7E10CB-1CE6-4095-8B6D-4089ABE16A78-9432-00002BF987FB0D38"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform73 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix74 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform73 = CGAffineTransformConcat(currentTransform73, ctmMatrix74);
	CGMutablePathRef circlePath75 = CGPathCreateMutable();
	CGFloat cx76 = 48.000000;
	CGFloat cy77 = 375.000000;
	CGFloat r78 = 41.000000;
	CGRect circleRect79 = CGRectMake((cx76 - r78), (cy77 - r78), (r78 * 2.0f), (r78 * 2.0f));
	CGPathAddEllipseInRect(circlePath75, NULL, circleRect79);
	CGFloat strokeWidth80 = 10;
	CGRect pathBoundingBox81 = CGPathGetBoundingBox(circlePath75);
	pathBoundingBox81 = NSInsetRect(pathBoundingBox81, -strokeWidth80, -strokeWidth80);
	CGFloat scaledStrokeWidth82 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth82);
	NSColor * strokeColor83 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor83.CGColor);
	NSColor * fillColor84 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor84.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip85 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform73 = CGAffineTransformConcat(currentTransform73, flip85);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect86 = self.bounds;
		CGFloat boundsMidX87 = NSMidX(boundsRect86) * (1.0f / viewScale);
		CGFloat boundsMidY88 = NSMidY(boundsRect86) * (1.0f / viewScale);
		CGFloat imageMidX89 = NSMidX(webBBox);
		CGFloat imageMidY90 = NSMidY(webBBox);
		CGFloat xTranslation91 = boundsMidX87 - imageMidX89;
		CGFloat yTranslation92 = boundsMidY88 - imageMidY90;
		CGAffineTransform centerTranslation93 = CGAffineTransformMakeTranslation(xTranslation91, yTranslation92);
		currentTransform73 = CGAffineTransformConcat(currentTransform73, centerTranslation93);
	}
	CGAffineTransform translate94 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform73 = CGAffineTransformConcat(currentTransform73, translate94);
	CGAffineTransform scale95 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform73 = CGAffineTransformConcat(currentTransform73, scale95);
	CGPathRef finalPath96 = CGPathCreateCopyByTransformingPath(circlePath75, &currentTransform73);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath96);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath96);
	CGPathRelease(circlePath75);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" transform="" stroke-width="10px" id="circle9" cy="289px" fill="#ffffff" r="41px" cx="282px" macsvgid="A3229660-9BE8-4F85-AC8E-8107C11D703D-9432-00002BF987FB35A5"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform97 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix98 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform97 = CGAffineTransformConcat(currentTransform97, ctmMatrix98);
	CGMutablePathRef circlePath99 = CGPathCreateMutable();
	CGFloat cx100 = 282.000000;
	CGFloat cy101 = 289.000000;
	CGFloat r102 = 41.000000;
	CGRect circleRect103 = CGRectMake((cx100 - r102), (cy101 - r102), (r102 * 2.0f), (r102 * 2.0f));
	CGPathAddEllipseInRect(circlePath99, NULL, circleRect103);
	CGFloat strokeWidth104 = 10;
	CGRect pathBoundingBox105 = CGPathGetBoundingBox(circlePath99);
	pathBoundingBox105 = NSInsetRect(pathBoundingBox105, -strokeWidth104, -strokeWidth104);
	CGFloat scaledStrokeWidth106 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth106);
	NSColor * strokeColor107 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor107.CGColor);
	NSColor * fillColor108 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor108.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip109 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform97 = CGAffineTransformConcat(currentTransform97, flip109);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect110 = self.bounds;
		CGFloat boundsMidX111 = NSMidX(boundsRect110) * (1.0f / viewScale);
		CGFloat boundsMidY112 = NSMidY(boundsRect110) * (1.0f / viewScale);
		CGFloat imageMidX113 = NSMidX(webBBox);
		CGFloat imageMidY114 = NSMidY(webBBox);
		CGFloat xTranslation115 = boundsMidX111 - imageMidX113;
		CGFloat yTranslation116 = boundsMidY112 - imageMidY114;
		CGAffineTransform centerTranslation117 = CGAffineTransformMakeTranslation(xTranslation115, yTranslation116);
		currentTransform97 = CGAffineTransformConcat(currentTransform97, centerTranslation117);
	}
	CGAffineTransform translate118 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform97 = CGAffineTransformConcat(currentTransform97, translate118);
	CGAffineTransform scale119 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform97 = CGAffineTransformConcat(currentTransform97, scale119);
	CGPathRef finalPath120 = CGPathCreateCopyByTransformingPath(circlePath99, &currentTransform97);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath120);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath120);
	CGPathRelease(circlePath99);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" stroke-width="10px" cy="461px" id="circle10" fill="#ffffff" r="41px" cx="476px" transform="" macsvgid="9BEC4FE3-858C-4196-8D1C-3C65F3837165-9432-00002BF987FB5EA5"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform121 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix122 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform121 = CGAffineTransformConcat(currentTransform121, ctmMatrix122);
	CGMutablePathRef circlePath123 = CGPathCreateMutable();
	CGFloat cx124 = 476.000000;
	CGFloat cy125 = 461.000000;
	CGFloat r126 = 41.000000;
	CGRect circleRect127 = CGRectMake((cx124 - r126), (cy125 - r126), (r126 * 2.0f), (r126 * 2.0f));
	CGPathAddEllipseInRect(circlePath123, NULL, circleRect127);
	CGFloat strokeWidth128 = 10;
	CGRect pathBoundingBox129 = CGPathGetBoundingBox(circlePath123);
	pathBoundingBox129 = NSInsetRect(pathBoundingBox129, -strokeWidth128, -strokeWidth128);
	CGFloat scaledStrokeWidth130 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth130);
	NSColor * strokeColor131 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor131.CGColor);
	NSColor * fillColor132 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor132.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip133 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform121 = CGAffineTransformConcat(currentTransform121, flip133);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect134 = self.bounds;
		CGFloat boundsMidX135 = NSMidX(boundsRect134) * (1.0f / viewScale);
		CGFloat boundsMidY136 = NSMidY(boundsRect134) * (1.0f / viewScale);
		CGFloat imageMidX137 = NSMidX(webBBox);
		CGFloat imageMidY138 = NSMidY(webBBox);
		CGFloat xTranslation139 = boundsMidX135 - imageMidX137;
		CGFloat yTranslation140 = boundsMidY136 - imageMidY138;
		CGAffineTransform centerTranslation141 = CGAffineTransformMakeTranslation(xTranslation139, yTranslation140);
		currentTransform121 = CGAffineTransformConcat(currentTransform121, centerTranslation141);
	}
	CGAffineTransform translate142 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform121 = CGAffineTransformConcat(currentTransform121, translate142);
	CGAffineTransform scale143 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform121 = CGAffineTransformConcat(currentTransform121, scale143);
	CGPathRef finalPath144 = CGPathCreateCopyByTransformingPath(circlePath123, &currentTransform121);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath144);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath144);
	CGPathRelease(circlePath123);
	CGContextRestoreGState(context);
}


//================================================================================
// drawLineToolIcon:
//================================================================================

- (void)drawLineToolIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath145 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor146 = [NSColor orangeColor];
	//[rectColor146 set];
	//[rectPath145 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(-13.000000, -14.000000, 583.000000, 356.000000);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.5f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="line_tool" visibility="visible" macsvgid="1FD1C2C5-0C4E-4AA4-AE61-E57B3AA72BDA-9432-00002BF987FB84EF"><line stroke="#000000" y1="41px" id="line1" stroke-width="20px" x1="507px" y2="287px" x2="43px" transform="" macsvgid="7911340A-34E3-4DCA-8901-62D0DB39AF9E-9432-00002BF987FBA51F"></line><circle stroke="#000000" transform="" id="circle11" stroke-width="10px" cy="40px" fill="#ffffff" r="34px" cx="516px" macsvgid="353FDDB0-08A1-461F-85BE-CD22507A4A9E-9432-00002BF987FBCD7A"></circle><circle stroke="#000000" transform="" stroke-width="10px" id="circle12" cy="288px" fill="#ffffff" r="34px" cx="41px" macsvgid="9402BDC1-B5B4-49BB-898B-39A0602A2301-9432-00002BF987FBF63E"></circle></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform147 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix148 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform147 = CGAffineTransformConcat(currentTransform147, ctmMatrix148);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <line stroke="#000000" y1="41px" id="line1" stroke-width="20px" x1="507px" y2="287px" x2="43px" transform="" macsvgid="7911340A-34E3-4DCA-8901-62D0DB39AF9E-9432-00002BF987FBA51F"></line>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform149 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix150 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform149 = CGAffineTransformConcat(currentTransform149, ctmMatrix150);
	CGMutablePathRef linePath151 = CGPathCreateMutable();
	CGFloat x1_152 = 507.000000;
	CGFloat y1_153 = 41.000000;
	CGFloat x2_154 = 43.000000;
	CGFloat y2_155 = 287.000000;
	CGPathMoveToPoint(linePath151, NULL, x1_152, y1_153);
	CGPathAddLineToPoint(linePath151, NULL, x2_154, y2_155);
	CGFloat strokeWidth156 = 20;
	CGRect pathBoundingBox157 = CGPathGetBoundingBox(linePath151);
	pathBoundingBox157 = NSInsetRect(pathBoundingBox157, -strokeWidth156, -strokeWidth156);
	CGFloat scaledStrokeWidth158 = 20 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth158);
	NSColor * strokeColor159 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor159.CGColor);
	NSColor * fillColor160 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor160.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip161 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform149 = CGAffineTransformConcat(currentTransform149, flip161);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect162 = self.bounds;
		CGFloat boundsMidX163 = NSMidX(boundsRect162) * (1.0f / viewScale);
		CGFloat boundsMidY164 = NSMidY(boundsRect162) * (1.0f / viewScale);
		CGFloat imageMidX165 = NSMidX(webBBox);
		CGFloat imageMidY166 = NSMidY(webBBox);
		CGFloat xTranslation167 = boundsMidX163 - imageMidX165;
		CGFloat yTranslation168 = boundsMidY164 - imageMidY166;
		CGAffineTransform centerTranslation169 = CGAffineTransformMakeTranslation(xTranslation167, yTranslation168);
		currentTransform149 = CGAffineTransformConcat(currentTransform149, centerTranslation169);
	}
	CGAffineTransform translate170 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform149 = CGAffineTransformConcat(currentTransform149, translate170);
	CGAffineTransform scale171 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform149 = CGAffineTransformConcat(currentTransform149, scale171);
	CGPathRef finalPath172 = CGPathCreateCopyByTransformingPath(linePath151, &currentTransform149);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath172);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath172);
	CGPathRelease(linePath151);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" transform="" id="circle11" stroke-width="10px" cy="40px" fill="#ffffff" r="34px" cx="516px" macsvgid="353FDDB0-08A1-461F-85BE-CD22507A4A9E-9432-00002BF987FBCD7A"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform173 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix174 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform173 = CGAffineTransformConcat(currentTransform173, ctmMatrix174);
	CGMutablePathRef circlePath175 = CGPathCreateMutable();
	CGFloat cx176 = 516.000000;
	CGFloat cy177 = 40.000000;
	CGFloat r178 = 34.000000;
	CGRect circleRect179 = CGRectMake((cx176 - r178), (cy177 - r178), (r178 * 2.0f), (r178 * 2.0f));
	CGPathAddEllipseInRect(circlePath175, NULL, circleRect179);
	CGFloat strokeWidth180 = 10;
	CGRect pathBoundingBox181 = CGPathGetBoundingBox(circlePath175);
	pathBoundingBox181 = NSInsetRect(pathBoundingBox181, -strokeWidth180, -strokeWidth180);
	CGFloat scaledStrokeWidth182 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth182);
	NSColor * strokeColor183 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor183.CGColor);
	NSColor * fillColor184 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor184.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip185 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform173 = CGAffineTransformConcat(currentTransform173, flip185);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect186 = self.bounds;
		CGFloat boundsMidX187 = NSMidX(boundsRect186) * (1.0f / viewScale);
		CGFloat boundsMidY188 = NSMidY(boundsRect186) * (1.0f / viewScale);
		CGFloat imageMidX189 = NSMidX(webBBox);
		CGFloat imageMidY190 = NSMidY(webBBox);
		CGFloat xTranslation191 = boundsMidX187 - imageMidX189;
		CGFloat yTranslation192 = boundsMidY188 - imageMidY190;
		CGAffineTransform centerTranslation193 = CGAffineTransformMakeTranslation(xTranslation191, yTranslation192);
		currentTransform173 = CGAffineTransformConcat(currentTransform173, centerTranslation193);
	}
	CGAffineTransform translate194 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform173 = CGAffineTransformConcat(currentTransform173, translate194);
	CGAffineTransform scale195 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform173 = CGAffineTransformConcat(currentTransform173, scale195);
	CGPathRef finalPath196 = CGPathCreateCopyByTransformingPath(circlePath175, &currentTransform173);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath196);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath196);
	CGPathRelease(circlePath175);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" transform="" stroke-width="10px" id="circle12" cy="288px" fill="#ffffff" r="34px" cx="41px" macsvgid="9402BDC1-B5B4-49BB-898B-39A0602A2301-9432-00002BF987FBF63E"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform197 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix198 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform197 = CGAffineTransformConcat(currentTransform197, ctmMatrix198);
	CGMutablePathRef circlePath199 = CGPathCreateMutable();
	CGFloat cx200 = 41.000000;
	CGFloat cy201 = 288.000000;
	CGFloat r202 = 34.000000;
	CGRect circleRect203 = CGRectMake((cx200 - r202), (cy201 - r202), (r202 * 2.0f), (r202 * 2.0f));
	CGPathAddEllipseInRect(circlePath199, NULL, circleRect203);
	CGFloat strokeWidth204 = 10;
	CGRect pathBoundingBox205 = CGPathGetBoundingBox(circlePath199);
	pathBoundingBox205 = NSInsetRect(pathBoundingBox205, -strokeWidth204, -strokeWidth204);
	CGFloat scaledStrokeWidth206 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth206);
	NSColor * strokeColor207 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor207.CGColor);
	NSColor * fillColor208 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor208.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip209 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform197 = CGAffineTransformConcat(currentTransform197, flip209);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect210 = self.bounds;
		CGFloat boundsMidX211 = NSMidX(boundsRect210) * (1.0f / viewScale);
		CGFloat boundsMidY212 = NSMidY(boundsRect210) * (1.0f / viewScale);
		CGFloat imageMidX213 = NSMidX(webBBox);
		CGFloat imageMidY214 = NSMidY(webBBox);
		CGFloat xTranslation215 = boundsMidX211 - imageMidX213;
		CGFloat yTranslation216 = boundsMidY212 - imageMidY214;
		CGAffineTransform centerTranslation217 = CGAffineTransformMakeTranslation(xTranslation215, yTranslation216);
		currentTransform197 = CGAffineTransformConcat(currentTransform197, centerTranslation217);
	}
	CGAffineTransform translate218 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform197 = CGAffineTransformConcat(currentTransform197, translate218);
	CGAffineTransform scale219 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform197 = CGAffineTransformConcat(currentTransform197, scale219);
	CGPathRef finalPath220 = CGPathCreateCopyByTransformingPath(circlePath199, &currentTransform197);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath220);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath220);
	CGPathRelease(circlePath199);
	CGContextRestoreGState(context);
}

//================================================================================
// drawPluginToolIcon:
//================================================================================

- (void)drawPluginToolIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath221 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor222 = [NSColor orangeColor];
	//[rectColor222 set];
	//[rectPath221 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(14.000000, -1.052286, 392.000000, 613.052307);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.66f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g visibility="visible" id="plugin_tool" macsvgid="69BCDAE2-6022-4EC0-BA29-F04B83BC20DC-9432-00002BF987FC1D67" transform="translate(24 -21) rotate(45 210 305.473846)"><path stroke="#000000" id="path2" stroke-width="20px" d="M214,207 H148 V29 A20,20 0 0 0 107,31 V208 H24 L76,260 L74,383 L163,476 V564 A50,50 0 0 0 210,602 A50,50 0 0 0 257,564 V476 L346,383 L344,260 L396,208 H313 V31 A20,20 0 0 0 272,29 V207 H206 M502,-70" fill="none" transform="" macsvgid="6F13DDA5-F6CE-4A7A-8682-A274E1DD441C-9432-00002BF987FC3F15"></path></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform223 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix224 = CGAffineTransformMake(0.707107, 0.707107, -0.707107, 0.707107, 301.510193, -80.021210);
	currentTransform223 = CGAffineTransformConcat(currentTransform223, ctmMatrix224);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <path stroke="#000000" id="path2" stroke-width="20px" d="M214,207 H148 V29 A20,20 0 0 0 107,31 V208 H24 L76,260 L74,383 L163,476 V564 A50,50 0 0 0 210,602 A50,50 0 0 0 257,564 V476 L346,383 L344,260 L396,208 H313 V31 A20,20 0 0 0 272,29 V207 H206 M502,-70" fill="none" transform="" macsvgid="6F13DDA5-F6CE-4A7A-8682-A274E1DD441C-9432-00002BF987FC3F15"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform225 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix226 = CGAffineTransformMake(0.707107, 0.707107, -0.707107, 0.707107, 301.510193, -80.021210);
	currentTransform225 = CGAffineTransformConcat(currentTransform225, ctmMatrix226);

    CGAffineTransform adjustTransform = CGAffineTransformMakeTranslation(-25, 25);
	currentTransform225 = CGAffineTransformConcat(currentTransform225, adjustTransform);

	CGMutablePathRef path227 = CGPathCreateMutable();
	CGPathMoveToPoint(path227, NULL, 214, 207);
	CGPathAddLineToPoint(path227, NULL, 148, 207);
	CGPathAddLineToPoint(path227, NULL, 148, 29);
	CGFloat xAxisRotationRadians228 = 0.000000;
	CGAffineTransform transform229 = CGAffineTransformIdentity;
	transform229 = CGAffineTransformTranslate(transform229, 127.500961, 30.019697);
	transform229 = CGAffineTransformRotate(transform229, xAxisRotationRadians228);
	transform229 = CGAffineTransformScale(transform229, 1.000000, 1.000000);
	CGPathAddArc(path227, &transform229, 0.0, 0.0, 20.524385, -0.049703, -3.189374, 1);
	CGPathAddLineToPoint(path227, NULL, 107, 208);
	CGPathAddLineToPoint(path227, NULL, 24, 208);
	CGPathAddLineToPoint(path227, NULL, 76, 260);
	CGPathAddLineToPoint(path227, NULL, 74, 383);
	CGPathAddLineToPoint(path227, NULL, 163, 476);
	CGPathAddLineToPoint(path227, NULL, 163, 564);
	CGFloat xAxisRotationRadians230 = 0.000000;
	CGAffineTransform transform231 = CGAffineTransformIdentity;
	transform231 = CGAffineTransformTranslate(transform231, 211.544537, 552.023862);
	transform231 = CGAffineTransformRotate(transform231, xAxisRotationRadians230);
	transform231 = CGAffineTransformScale(transform231, 1.000000, 1.000000);
	CGPathAddArc(path227, &transform231, 0.0, 0.0, 50.000000, 2.899719, 1.601692, 1);
	CGFloat xAxisRotationRadians232 = 0.000000;
	CGAffineTransform transform233 = CGAffineTransformIdentity;
	transform233 = CGAffineTransformTranslate(transform233, 208.455463, 552.023862);
	transform233 = CGAffineTransformRotate(transform233, xAxisRotationRadians232);
	transform233 = CGAffineTransformScale(transform233, 1.000000, 1.000000);
	CGPathAddArc(path227, &transform233, 0.0, 0.0, 50.000000, 1.539901, 0.241874, 1);
	CGPathAddLineToPoint(path227, NULL, 257, 476);
	CGPathAddLineToPoint(path227, NULL, 346, 383);
	CGPathAddLineToPoint(path227, NULL, 344, 260);
	CGPathAddLineToPoint(path227, NULL, 396, 208);
	CGPathAddLineToPoint(path227, NULL, 313, 208);
	CGPathAddLineToPoint(path227, NULL, 313, 31);
	CGFloat xAxisRotationRadians234 = 0.000000;
	CGAffineTransform transform235 = CGAffineTransformIdentity;
	transform235 = CGAffineTransformTranslate(transform235, 292.499039, 30.019697);
	transform235 = CGAffineTransformRotate(transform235, xAxisRotationRadians234);
	transform235 = CGAffineTransformScale(transform235, 1.000000, 1.000000);
	CGPathAddArc(path227, &transform235, 0.0, 0.0, 20.524385, 0.047781, -3.091889, 1);
	CGPathAddLineToPoint(path227, NULL, 272, 207);
	CGPathAddLineToPoint(path227, NULL, 206, 207);
	CGPathMoveToPoint(path227, NULL, 502, -70);
	CGFloat strokeWidth236 = 20;
	CGRect pathBoundingBox237 = CGPathGetBoundingBox(path227);
	pathBoundingBox237 = NSInsetRect(pathBoundingBox237, -strokeWidth236, -strokeWidth236);
	CGFloat scaledStrokeWidth238 = 20 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth238);
	NSColor * strokeColor239 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor239.CGColor);
	NSColor * fillColor240 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor240.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip241 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform225 = CGAffineTransformConcat(currentTransform225, flip241);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect242 = self.bounds;
		CGFloat boundsMidX243 = NSMidX(boundsRect242) * (1.0f / viewScale);
		CGFloat boundsMidY244 = NSMidY(boundsRect242) * (1.0f / viewScale);
		CGFloat imageMidX245 = NSMidX(webBBox);
		CGFloat imageMidY246 = NSMidY(webBBox);
		CGFloat xTranslation247 = boundsMidX243 - imageMidX245;
		CGFloat yTranslation248 = boundsMidY244 - imageMidY246;
		CGAffineTransform centerTranslation249 = CGAffineTransformMakeTranslation(xTranslation247, yTranslation248);
		currentTransform225 = CGAffineTransformConcat(currentTransform225, centerTranslation249);
	}
	CGAffineTransform translate250 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform225 = CGAffineTransformConcat(currentTransform225, translate250);
	CGAffineTransform scale251 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform225 = CGAffineTransformConcat(currentTransform225, scale251);
	CGPathRef finalPath252 = CGPathCreateCopyByTransformingPath(path227, &currentTransform225);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath252);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath252);
	CGPathRelease(path227);
	CGContextRestoreGState(context);
}


//================================================================================
// drawTextToolIcon:
//================================================================================

- (void)drawTextToolIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath23 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor24 = [NSColor orangeColor];
	//[rectColor24 set];
	//[rectPath23 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(10.000000, 0.000000, 568.000000, 680.000000);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
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
		NSRect boundsRect34 = self.bounds;
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


//================================================================================
// drawImageToolIcon:
//================================================================================

- (void)drawImageToolIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath1 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor2 = [NSColor orangeColor];
	//[rectColor2 set];
	//[rectPath1 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(-38.000000, -44.000000, 559.000000, 462.000000);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.65f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="image_tool" visibility="visible" macsvgid="95470D75-CDAE-42A1-9D48-5AEE92459AEA-14456-000048B2F76C9585"><rect stroke="#000000" id="rect1" stroke-width="20px" x="12px" rx="20px" y="74px" width="459px" fill="white" transform="" ry="20px" height="294px" macsvgid="1C1FCCC1-D60A-4CE3-B1DB-D5C2B094B639-14456-000048B2F76CB8FD"></rect><rect stroke="gray" height="29px" x="50px" id="rect2" stroke-width="20px" width="45px" y="38px" fill="#ffffff" transform="" macsvgid="B139AB85-EC69-4FC4-96FC-AF4089F8A169-14456-000048B2F76CE3C0"></rect><rect stroke="gray" height="76px" x="31px" id="rect3" stroke-width="20px" width="80px" y="92px" fill="none" transform="" macsvgid="0B5C6298-4CB3-4F5C-A731-3838EC4DE6D6-14456-000048B2F76D0C19"></rect><rect stroke="gray" height="64px" x="312px" id="rect4" stroke-width="20px" width="118px" y="6px" fill="#ffffff" transform="" macsvgid="9311483C-4B81-4A95-8835-32BF9C964EAE-14456-000048B2F76D34A0"></rect><circle stroke="gray" id="circle13" cy="228px" stroke-width="20px" fill="none" r="91px" cx="242px" transform="" macsvgid="A76D8A50-48F9-4A59-9ECB-BC75D72A0A55-14456-000048B2F76D5C79"></circle></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform3 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix4 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, ctmMatrix4);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="#000000" id="rect1" stroke-width="20px" x="12px" rx="20px" y="74px" width="459px" fill="white" transform="" ry="20px" height="294px" macsvgid="1C1FCCC1-D60A-4CE3-B1DB-D5C2B094B639-14456-000048B2F76CB8FD"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform5 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix6 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, ctmMatrix6);

    CGAffineTransform adjustTransform = CGAffineTransformMakeTranslation(0, 25);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, adjustTransform);

	CGMutablePathRef rectPath7 = CGPathCreateMutable();
	CGFloat x8 = 12.000000;
	CGFloat y9 = 74.000000;
	CGFloat width10 = 459.000000;
	CGFloat height11 = 294.000000;
	CGRect rect14 = CGRectMake(x8, y9, width10, height11);
	CGFloat radius15 = 20.000000;
	CGPathMoveToPoint(rectPath7, NULL, rect14.origin.x, rect14.origin.y + radius15);
	CGPathAddLineToPoint(rectPath7, NULL, rect14.origin.x, rect14.origin.y + rect14.size.height - radius15);
	CGPathAddArc(rectPath7, NULL, rect14.origin.x + radius15, rect14.origin.y + rect14.size.height - radius15, radius15, M_PI, M_PI / 2, 1);
	CGPathAddLineToPoint(rectPath7, NULL, rect14.origin.x + rect14.size.width - radius15, rect14.origin.y + rect14.size.height);
	CGPathAddArc(rectPath7, NULL, rect14.origin.x + rect14.size.width - radius15, rect14.origin.y + rect14.size.height - radius15, radius15, M_PI / 2, 0.0f, 1);
	CGPathAddLineToPoint(rectPath7, NULL, rect14.origin.x + rect14.size.width, rect14.origin.y + radius15);
	CGPathAddArc(rectPath7, NULL, rect14.origin.x + rect14.size.width - radius15, rect14.origin.y + radius15, radius15, 0.0f, -M_PI / 2, 1);
	CGPathAddLineToPoint(rectPath7, NULL, rect14.origin.x + radius15, rect14.origin.y);
	CGPathAddArc(rectPath7, NULL, rect14.origin.x + radius15, rect14.origin.y + radius15, radius15, -M_PI / 2, M_PI, 1);
	CGFloat strokeWidth16 = 20;
	CGRect pathBoundingBox17 = CGPathGetBoundingBox(rectPath7);
	pathBoundingBox17 = NSInsetRect(pathBoundingBox17, -strokeWidth16, -strokeWidth16);
	CGFloat scaledStrokeWidth18 = 20 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth18);
	NSColor * strokeColor19 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor19.CGColor);
	NSColor * fillColor20 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor20.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip21 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform5 = CGAffineTransformConcat(currentTransform5, flip21);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect22 = self.bounds;
		CGFloat boundsMidX23 = NSMidX(boundsRect22) * (1.0f / viewScale);
		CGFloat boundsMidY24 = NSMidY(boundsRect22) * (1.0f / viewScale);
		CGFloat imageMidX25 = NSMidX(webBBox);
		CGFloat imageMidY26 = NSMidY(webBBox);
		CGFloat xTranslation27 = boundsMidX23 - imageMidX25;
		CGFloat yTranslation28 = boundsMidY24 - imageMidY26;
		CGAffineTransform centerTranslation29 = CGAffineTransformMakeTranslation(xTranslation27, yTranslation28);
		currentTransform5 = CGAffineTransformConcat(currentTransform5, centerTranslation29);
	}
	CGAffineTransform translate30 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, translate30);
	CGAffineTransform scale31 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, scale31);
	CGPathRef finalPath32 = CGPathCreateCopyByTransformingPath(rectPath7, &currentTransform5);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath32);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath32);
	CGPathRelease(rectPath7);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="gray" height="29px" x="50px" id="rect2" stroke-width="20px" width="45px" y="38px" fill="#ffffff" transform="" macsvgid="B139AB85-EC69-4FC4-96FC-AF4089F8A169-14456-000048B2F76CE3C0"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform33 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix34 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform33 = CGAffineTransformConcat(currentTransform33, ctmMatrix34);

	currentTransform33 = CGAffineTransformConcat(currentTransform33, adjustTransform);

	CGMutablePathRef rectPath35 = CGPathCreateMutable();
	CGFloat x36 = 50.000000;
	CGFloat y37 = 38.000000;
	CGFloat width38 = 45.000000;
	CGFloat height39 = 29.000000;
	CGRect rect42 = CGRectMake(x36, y37, width38, height39);
	CGPathAddRect(rectPath35, NULL, rect42);
	CGFloat strokeWidth43 = 20;
	CGRect pathBoundingBox44 = CGPathGetBoundingBox(rectPath35);
	pathBoundingBox44 = NSInsetRect(pathBoundingBox44, -strokeWidth43, -strokeWidth43);
	CGFloat scaledStrokeWidth45 = 20 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth45);
	NSColor * strokeColor46 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor46.CGColor);
	NSColor * fillColor47 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor47.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip48 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform33 = CGAffineTransformConcat(currentTransform33, flip48);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect49 = self.bounds;
		CGFloat boundsMidX50 = NSMidX(boundsRect49) * (1.0f / viewScale);
		CGFloat boundsMidY51 = NSMidY(boundsRect49) * (1.0f / viewScale);
		CGFloat imageMidX52 = NSMidX(webBBox);
		CGFloat imageMidY53 = NSMidY(webBBox);
		CGFloat xTranslation54 = boundsMidX50 - imageMidX52;
		CGFloat yTranslation55 = boundsMidY51 - imageMidY53;
		CGAffineTransform centerTranslation56 = CGAffineTransformMakeTranslation(xTranslation54, yTranslation55);
		currentTransform33 = CGAffineTransformConcat(currentTransform33, centerTranslation56);
	}
	CGAffineTransform translate57 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform33 = CGAffineTransformConcat(currentTransform33, translate57);
	CGAffineTransform scale58 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform33 = CGAffineTransformConcat(currentTransform33, scale58);
	CGPathRef finalPath59 = CGPathCreateCopyByTransformingPath(rectPath35, &currentTransform33);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath59);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath59);
	CGPathRelease(rectPath35);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="gray" height="76px" x="31px" id="rect3" stroke-width="20px" width="80px" y="92px" fill="none" transform="" macsvgid="0B5C6298-4CB3-4F5C-A731-3838EC4DE6D6-14456-000048B2F76D0C19"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform60 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix61 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform60 = CGAffineTransformConcat(currentTransform60, ctmMatrix61);

	currentTransform60 = CGAffineTransformConcat(currentTransform60, adjustTransform);

	CGMutablePathRef rectPath62 = CGPathCreateMutable();
	CGFloat x63 = 31.000000;
	CGFloat y64 = 92.000000;
	CGFloat width65 = 80.000000;
	CGFloat height66 = 76.000000;
	CGRect rect69 = CGRectMake(x63, y64, width65, height66);
	CGPathAddRect(rectPath62, NULL, rect69);
	CGFloat strokeWidth70 = 20;
	CGRect pathBoundingBox71 = CGPathGetBoundingBox(rectPath62);
	pathBoundingBox71 = NSInsetRect(pathBoundingBox71, -strokeWidth70, -strokeWidth70);
	CGFloat scaledStrokeWidth72 = 20 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth72);
	NSColor * strokeColor73 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor73.CGColor);
	NSColor * fillColor74 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor74.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip75 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform60 = CGAffineTransformConcat(currentTransform60, flip75);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect76 = self.bounds;
		CGFloat boundsMidX77 = NSMidX(boundsRect76) * (1.0f / viewScale);
		CGFloat boundsMidY78 = NSMidY(boundsRect76) * (1.0f / viewScale);
		CGFloat imageMidX79 = NSMidX(webBBox);
		CGFloat imageMidY80 = NSMidY(webBBox);
		CGFloat xTranslation81 = boundsMidX77 - imageMidX79;
		CGFloat yTranslation82 = boundsMidY78 - imageMidY80;
		CGAffineTransform centerTranslation83 = CGAffineTransformMakeTranslation(xTranslation81, yTranslation82);
		currentTransform60 = CGAffineTransformConcat(currentTransform60, centerTranslation83);
	}
	CGAffineTransform translate84 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform60 = CGAffineTransformConcat(currentTransform60, translate84);
	CGAffineTransform scale85 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform60 = CGAffineTransformConcat(currentTransform60, scale85);
	CGPathRef finalPath86 = CGPathCreateCopyByTransformingPath(rectPath62, &currentTransform60);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath86);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath86);
	CGPathRelease(rectPath62);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="gray" height="64px" x="312px" id="rect4" stroke-width="20px" width="118px" y="6px" fill="#ffffff" transform="" macsvgid="9311483C-4B81-4A95-8835-32BF9C964EAE-14456-000048B2F76D34A0"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform87 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix88 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform87 = CGAffineTransformConcat(currentTransform87, ctmMatrix88);

	currentTransform87 = CGAffineTransformConcat(currentTransform87, adjustTransform);

	CGMutablePathRef rectPath89 = CGPathCreateMutable();
	CGFloat x90 = 312.000000;
	CGFloat y91 = 6.000000;
	CGFloat width92 = 118.000000;
	CGFloat height93 = 64.000000;
	CGRect rect96 = CGRectMake(x90, y91, width92, height93);
	CGPathAddRect(rectPath89, NULL, rect96);
	CGFloat strokeWidth97 = 20;
	CGRect pathBoundingBox98 = CGPathGetBoundingBox(rectPath89);
	pathBoundingBox98 = NSInsetRect(pathBoundingBox98, -strokeWidth97, -strokeWidth97);
	CGFloat scaledStrokeWidth99 = 20 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth99);
	NSColor * strokeColor100 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor100.CGColor);
	NSColor * fillColor101 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor101.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip102 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform87 = CGAffineTransformConcat(currentTransform87, flip102);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect103 = self.bounds;
		CGFloat boundsMidX104 = NSMidX(boundsRect103) * (1.0f / viewScale);
		CGFloat boundsMidY105 = NSMidY(boundsRect103) * (1.0f / viewScale);
		CGFloat imageMidX106 = NSMidX(webBBox);
		CGFloat imageMidY107 = NSMidY(webBBox);
		CGFloat xTranslation108 = boundsMidX104 - imageMidX106;
		CGFloat yTranslation109 = boundsMidY105 - imageMidY107;
		CGAffineTransform centerTranslation110 = CGAffineTransformMakeTranslation(xTranslation108, yTranslation109);
		currentTransform87 = CGAffineTransformConcat(currentTransform87, centerTranslation110);
	}
	CGAffineTransform translate111 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform87 = CGAffineTransformConcat(currentTransform87, translate111);
	CGAffineTransform scale112 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform87 = CGAffineTransformConcat(currentTransform87, scale112);
	CGPathRef finalPath113 = CGPathCreateCopyByTransformingPath(rectPath89, &currentTransform87);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath113);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath113);
	CGPathRelease(rectPath89);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="gray" id="circle13" cy="228px" stroke-width="20px" fill="none" r="91px" cx="242px" transform="" macsvgid="A76D8A50-48F9-4A59-9ECB-BC75D72A0A55-14456-000048B2F76D5C79"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform114 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix115 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform114 = CGAffineTransformConcat(currentTransform114, ctmMatrix115);

	currentTransform114 = CGAffineTransformConcat(currentTransform114, adjustTransform);

	CGMutablePathRef circlePath116 = CGPathCreateMutable();
	CGFloat cx117 = 242.000000;
	CGFloat cy118 = 228.000000;
	CGFloat r119 = 91.000000;
	CGRect circleRect120 = CGRectMake((cx117 - r119), (cy118 - r119), (r119 * 2.0f), (r119 * 2.0f));
	CGPathAddEllipseInRect(circlePath116, NULL, circleRect120);
	CGFloat strokeWidth121 = 20;
	CGRect pathBoundingBox122 = CGPathGetBoundingBox(circlePath116);
	pathBoundingBox122 = NSInsetRect(pathBoundingBox122, -strokeWidth121, -strokeWidth121);
	CGFloat scaledStrokeWidth123 = 20 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth123);
	NSColor * strokeColor124 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor124.CGColor);
	NSColor * fillColor125 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor125.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip126 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform114 = CGAffineTransformConcat(currentTransform114, flip126);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect127 = self.bounds;
		CGFloat boundsMidX128 = NSMidX(boundsRect127) * (1.0f / viewScale);
		CGFloat boundsMidY129 = NSMidY(boundsRect127) * (1.0f / viewScale);
		CGFloat imageMidX130 = NSMidX(webBBox);
		CGFloat imageMidY131 = NSMidY(webBBox);
		CGFloat xTranslation132 = boundsMidX128 - imageMidX130;
		CGFloat yTranslation133 = boundsMidY129 - imageMidY131;
		CGAffineTransform centerTranslation134 = CGAffineTransformMakeTranslation(xTranslation132, yTranslation133);
		currentTransform114 = CGAffineTransformConcat(currentTransform114, centerTranslation134);
	}
	CGAffineTransform translate135 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform114 = CGAffineTransformConcat(currentTransform114, translate135);
	CGAffineTransform scale136 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform114 = CGAffineTransformConcat(currentTransform114, scale136);
	CGPathRef finalPath137 = CGPathCreateCopyByTransformingPath(circlePath116, &currentTransform114);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath137);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath137);
	CGPathRelease(circlePath116);
	CGContextRestoreGState(context);
}



//================================================================================
// drawPathToolIcon:
//================================================================================

- (void)drawPathToolIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath23 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor24 = [NSColor orangeColor];
	//[rectColor24 set];
	//[rectPath23 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	NSRect webBBox = NSMakeRect(-33.000000, -33.000000, 524.000000, 451.000000);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.7f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="path_tool" visibility="visible" macsvgid="662A4260-643C-4457-811E-E4D41F7FD422-7830-000026383E8737A7"><line stroke="gray" y1="280px" id="line2" stroke-width="10px" x1="42px" y2="355px" x2="390px" transform="" macsvgid="0CEC67A1-8874-49C9-96EA-B4CDF1E311BC-7830-000026383E875AE3"></line><line stroke="gray" y1="101px" id="line4" stroke-width="10px" x1="422px" y2="34px" x2="78px" transform="" macsvgid="9B526F45-1FAD-4538-B5B4-491B187D1460-7830-000026383E8787B7"></line><path stroke="#000000" id="path1" stroke-width="20px" d="M39,282 C385,361 53,17 421,98" fill="none" transform="" macsvgid="6604AA05-94E4-438C-A49A-BA67349B19A3-7830-000026383E87B53E"></path><circle stroke="#808080" transform="" id="circle14" stroke-width="10px" cy="35px" fill="#ffffff" r="28px" cx="84px" macsvgid="4E53187A-ADE5-42B6-ABE6-63BE08AA326C-7830-000026383E87E203"></circle><circle stroke="#808080" transform="" stroke-width="10px" id="circle15" cy="96px" fill="#ffffff" r="28px" cx="423px" macsvgid="5E5E7950-740E-41B6-9D59-D7A5CB697DC5-7830-000026383E880E7A"></circle><circle stroke="#808080" transform="" stroke-width="10px" id="circle16" cy="280px" fill="#ffffff" r="28px" cx="35px" macsvgid="E1C8EBE6-AE1A-453F-8BD8-96B1B5D2D7F2-7830-000026383E8854B1"></circle><circle stroke="#808080" stroke-width="10px" cy="350px" id="circle17" fill="#ffffff" r="28px" cx="384px" transform="" macsvgid="088F61A6-9196-4FA6-9C8F-E7C52ED0EFA4-7830-000026383E888017"></circle></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform25 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix26 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform25 = CGAffineTransformConcat(currentTransform25, ctmMatrix26);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <line stroke="gray" y1="280px" id="line2" stroke-width="10px" x1="42px" y2="355px" x2="390px" transform="" macsvgid="0CEC67A1-8874-49C9-96EA-B4CDF1E311BC-7830-000026383E875AE3"></line>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform27 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix28 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform27 = CGAffineTransformConcat(currentTransform27, ctmMatrix28);

    CGAffineTransform adjustTransform = CGAffineTransformMakeTranslation(-25, 25);
	currentTransform27 = CGAffineTransformConcat(currentTransform27, adjustTransform);

	CGMutablePathRef linePath29 = CGPathCreateMutable();
	CGFloat x1_30 = 42.000000;
	CGFloat y1_31 = 280.000000;
	CGFloat x2_32 = 390.000000;
	CGFloat y2_33 = 355.000000;
	CGPathMoveToPoint(linePath29, NULL, x1_30, y1_31);
	CGPathAddLineToPoint(linePath29, NULL, x2_32, y2_33);
	CGFloat strokeWidth34 = 10;
	CGRect pathBoundingBox35 = CGPathGetBoundingBox(linePath29);
	pathBoundingBox35 = NSInsetRect(pathBoundingBox35, -strokeWidth34, -strokeWidth34);
	CGFloat scaledStrokeWidth36 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth36);
	NSColor * strokeColor37 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor37.CGColor);
	NSColor * fillColor38 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor38.CGColor);
	if (NO) { // flip image vertically
		CGAffineTransform flip39 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform27 = CGAffineTransformConcat(currentTransform27, flip39);
	}
	if (YES) { // center image
		NSRect boundsRect40 = self.bounds;
		CGFloat boundsMidX41 = NSMidX(boundsRect40) * (1.0f / viewScale);
		CGFloat boundsMidY42 = NSMidY(boundsRect40) * (1.0f / viewScale);
		CGFloat imageMidX43 = NSMidX(webBBox);
		CGFloat imageMidY44 = NSMidY(webBBox);
		CGFloat xTranslation45 = boundsMidX41 - imageMidX43;
		CGFloat yTranslation46 = boundsMidY42 - imageMidY44;
		CGAffineTransform centerTranslation47 = CGAffineTransformMakeTranslation(xTranslation45, yTranslation46);
		currentTransform27 = CGAffineTransformConcat(currentTransform27, centerTranslation47);
	}
    CGAffineTransform translate48 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform27 = CGAffineTransformConcat(currentTransform27, translate48);
	CGAffineTransform scale49 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform27 = CGAffineTransformConcat(currentTransform27, scale49);
	CGPathRef finalPath50 = CGPathCreateCopyByTransformingPath(linePath29, &currentTransform27);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath50);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath50);
	CGPathRelease(linePath29);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <line stroke="gray" y1="101px" id="line4" stroke-width="10px" x1="422px" y2="34px" x2="78px" transform="" macsvgid="9B526F45-1FAD-4538-B5B4-491B187D1460-7830-000026383E8787B7"></line>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform51 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix52 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform51 = CGAffineTransformConcat(currentTransform51, ctmMatrix52);

	currentTransform51 = CGAffineTransformConcat(currentTransform51, adjustTransform);

	CGMutablePathRef linePath53 = CGPathCreateMutable();
	CGFloat x1_54 = 422.000000;
	CGFloat y1_55 = 101.000000;
	CGFloat x2_56 = 78.000000;
	CGFloat y2_57 = 34.000000;
	CGPathMoveToPoint(linePath53, NULL, x1_54, y1_55);
	CGPathAddLineToPoint(linePath53, NULL, x2_56, y2_57);
	CGFloat strokeWidth58 = 10;
	CGRect pathBoundingBox59 = CGPathGetBoundingBox(linePath53);
	pathBoundingBox59 = NSInsetRect(pathBoundingBox59, -strokeWidth58, -strokeWidth58);
	CGFloat scaledStrokeWidth60 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth60);
	NSColor * strokeColor61 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor61.CGColor);
	NSColor * fillColor62 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor62.CGColor);
	if (NO) { // flip image vertically
		CGAffineTransform flip63 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform51 = CGAffineTransformConcat(currentTransform51, flip63);
	}
	if (YES) { // center image
		NSRect boundsRect64 = self.bounds;
		CGFloat boundsMidX65 = NSMidX(boundsRect64) * (1.0f / viewScale);
		CGFloat boundsMidY66 = NSMidY(boundsRect64) * (1.0f / viewScale);
		CGFloat imageMidX67 = NSMidX(webBBox);
		CGFloat imageMidY68 = NSMidY(webBBox);
		CGFloat xTranslation69 = boundsMidX65 - imageMidX67;
		CGFloat yTranslation70 = boundsMidY66 - imageMidY68;
		CGAffineTransform centerTranslation71 = CGAffineTransformMakeTranslation(xTranslation69, yTranslation70);
		currentTransform51 = CGAffineTransformConcat(currentTransform51, centerTranslation71);
	}
    CGAffineTransform translate72 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform51 = CGAffineTransformConcat(currentTransform51, translate72);
	CGAffineTransform scale73 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform51 = CGAffineTransformConcat(currentTransform51, scale73);
	CGPathRef finalPath74 = CGPathCreateCopyByTransformingPath(linePath53, &currentTransform51);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath74);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath74);
	CGPathRelease(linePath53);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <path stroke="#000000" id="path1" stroke-width="20px" d="M39,282 C385,361 53,17 421,98" fill="none" transform="" macsvgid="6604AA05-94E4-438C-A49A-BA67349B19A3-7830-000026383E87B53E"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform75 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix76 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform75 = CGAffineTransformConcat(currentTransform75, ctmMatrix76);

	currentTransform75 = CGAffineTransformConcat(currentTransform75, adjustTransform);

	CGMutablePathRef path77 = CGPathCreateMutable();
	CGPathMoveToPoint(path77, NULL, 39, 282);
	CGPathAddCurveToPoint(path77, NULL, 385, 361, 53, 17, 421, 98);
	CGFloat strokeWidth78 = 20;
	CGRect pathBoundingBox79 = CGPathGetBoundingBox(path77);
	pathBoundingBox79 = NSInsetRect(pathBoundingBox79, -strokeWidth78, -strokeWidth78);
	CGFloat scaledStrokeWidth80 = 20 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth80);
	NSColor * strokeColor81 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor81.CGColor);
	NSColor * fillColor82 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor82.CGColor);
	if (NO) { // flip image vertically
		CGAffineTransform flip83 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform75 = CGAffineTransformConcat(currentTransform75, flip83);
	}
	if (YES) { // center image
		NSRect boundsRect84 = self.bounds;
		CGFloat boundsMidX85 = NSMidX(boundsRect84) * (1.0f / viewScale);
		CGFloat boundsMidY86 = NSMidY(boundsRect84) * (1.0f / viewScale);
		CGFloat imageMidX87 = NSMidX(webBBox);
		CGFloat imageMidY88 = NSMidY(webBBox);
		CGFloat xTranslation89 = boundsMidX85 - imageMidX87;
		CGFloat yTranslation90 = boundsMidY86 - imageMidY88;
		CGAffineTransform centerTranslation91 = CGAffineTransformMakeTranslation(xTranslation89, yTranslation90);
		currentTransform75 = CGAffineTransformConcat(currentTransform75, centerTranslation91);
	}
    CGAffineTransform translate92 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform75 = CGAffineTransformConcat(currentTransform75, translate92);
	CGAffineTransform scale93 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform75 = CGAffineTransformConcat(currentTransform75, scale93);
	CGPathRef finalPath94 = CGPathCreateCopyByTransformingPath(path77, &currentTransform75);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath94);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath94);
	CGPathRelease(path77);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#808080" transform="" id="circle14" stroke-width="10px" cy="35px" fill="#ffffff" r="28px" cx="84px" macsvgid="4E53187A-ADE5-42B6-ABE6-63BE08AA326C-7830-000026383E87E203"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform95 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix96 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform95 = CGAffineTransformConcat(currentTransform95, ctmMatrix96);

	currentTransform95 = CGAffineTransformConcat(currentTransform95, adjustTransform);

	CGMutablePathRef circlePath97 = CGPathCreateMutable();
	CGFloat cx98 = 84.000000;
	CGFloat cy99 = 35.000000;
	CGFloat r100 = 28.000000;
	CGRect circleRect101 = CGRectMake((cx98 - r100), (cy99 - r100), (r100 * 2.0f), (r100 * 2.0f));
	CGPathAddEllipseInRect(circlePath97, NULL, circleRect101);
	CGFloat strokeWidth102 = 10;
	CGRect pathBoundingBox103 = CGPathGetBoundingBox(circlePath97);
	pathBoundingBox103 = NSInsetRect(pathBoundingBox103, -strokeWidth102, -strokeWidth102);
	CGFloat scaledStrokeWidth104 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth104);
	NSColor * strokeColor105 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor105.CGColor);
	NSColor * fillColor106 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor106.CGColor);
	if (NO) { // flip image vertically
		CGAffineTransform flip107 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform95 = CGAffineTransformConcat(currentTransform95, flip107);
	}
	if (YES) { // center image
		NSRect boundsRect108 = self.bounds;
		CGFloat boundsMidX109 = NSMidX(boundsRect108) * (1.0f / viewScale);
		CGFloat boundsMidY110 = NSMidY(boundsRect108) * (1.0f / viewScale);
		CGFloat imageMidX111 = NSMidX(webBBox);
		CGFloat imageMidY112 = NSMidY(webBBox);
		CGFloat xTranslation113 = boundsMidX109 - imageMidX111;
		CGFloat yTranslation114 = boundsMidY110 - imageMidY112;
		CGAffineTransform centerTranslation115 = CGAffineTransformMakeTranslation(xTranslation113, yTranslation114);
		currentTransform95 = CGAffineTransformConcat(currentTransform95, centerTranslation115);
	}
    CGAffineTransform translate116 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform95 = CGAffineTransformConcat(currentTransform95, translate116);
	CGAffineTransform scale117 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform95 = CGAffineTransformConcat(currentTransform95, scale117);
	CGPathRef finalPath118 = CGPathCreateCopyByTransformingPath(circlePath97, &currentTransform95);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath118);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath118);
	CGPathRelease(circlePath97);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#808080" transform="" stroke-width="10px" id="circle15" cy="96px" fill="#ffffff" r="28px" cx="423px" macsvgid="5E5E7950-740E-41B6-9D59-D7A5CB697DC5-7830-000026383E880E7A"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform119 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix120 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform119 = CGAffineTransformConcat(currentTransform119, ctmMatrix120);

	currentTransform119 = CGAffineTransformConcat(currentTransform119, adjustTransform);

	CGMutablePathRef circlePath121 = CGPathCreateMutable();
	CGFloat cx122 = 423.000000;
	CGFloat cy123 = 96.000000;
	CGFloat r124 = 28.000000;
	CGRect circleRect125 = CGRectMake((cx122 - r124), (cy123 - r124), (r124 * 2.0f), (r124 * 2.0f));
	CGPathAddEllipseInRect(circlePath121, NULL, circleRect125);
	CGFloat strokeWidth126 = 10;
	CGRect pathBoundingBox127 = CGPathGetBoundingBox(circlePath121);
	pathBoundingBox127 = NSInsetRect(pathBoundingBox127, -strokeWidth126, -strokeWidth126);
	CGFloat scaledStrokeWidth128 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth128);
	NSColor * strokeColor129 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor129.CGColor);
	NSColor * fillColor130 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor130.CGColor);
	if (NO) { // flip image vertically
		CGAffineTransform flip131 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform119 = CGAffineTransformConcat(currentTransform119, flip131);
	}
	if (YES) { // center image
		NSRect boundsRect132 = self.bounds;
		CGFloat boundsMidX133 = NSMidX(boundsRect132) * (1.0f / viewScale);
		CGFloat boundsMidY134 = NSMidY(boundsRect132) * (1.0f / viewScale);
		CGFloat imageMidX135 = NSMidX(webBBox);
		CGFloat imageMidY136 = NSMidY(webBBox);
		CGFloat xTranslation137 = boundsMidX133 - imageMidX135;
		CGFloat yTranslation138 = boundsMidY134 - imageMidY136;
		CGAffineTransform centerTranslation139 = CGAffineTransformMakeTranslation(xTranslation137, yTranslation138);
		currentTransform119 = CGAffineTransformConcat(currentTransform119, centerTranslation139);
	}
    CGAffineTransform translate140 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform119 = CGAffineTransformConcat(currentTransform119, translate140);
	CGAffineTransform scale141 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform119 = CGAffineTransformConcat(currentTransform119, scale141);
	CGPathRef finalPath142 = CGPathCreateCopyByTransformingPath(circlePath121, &currentTransform119);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath142);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath142);
	CGPathRelease(circlePath121);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#808080" transform="" stroke-width="10px" id="circle16" cy="280px" fill="#ffffff" r="28px" cx="35px" macsvgid="E1C8EBE6-AE1A-453F-8BD8-96B1B5D2D7F2-7830-000026383E8854B1"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform143 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix144 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform143 = CGAffineTransformConcat(currentTransform143, ctmMatrix144);

	currentTransform143 = CGAffineTransformConcat(currentTransform143, adjustTransform);

	CGMutablePathRef circlePath145 = CGPathCreateMutable();
	CGFloat cx146 = 35.000000;
	CGFloat cy147 = 280.000000;
	CGFloat r148 = 28.000000;
	CGRect circleRect149 = CGRectMake((cx146 - r148), (cy147 - r148), (r148 * 2.0f), (r148 * 2.0f));
	CGPathAddEllipseInRect(circlePath145, NULL, circleRect149);
	CGFloat strokeWidth150 = 10;
	CGRect pathBoundingBox151 = CGPathGetBoundingBox(circlePath145);
	pathBoundingBox151 = NSInsetRect(pathBoundingBox151, -strokeWidth150, -strokeWidth150);
	CGFloat scaledStrokeWidth152 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth152);
	NSColor * strokeColor153 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor153.CGColor);
	NSColor * fillColor154 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor154.CGColor);
	if (NO) { // flip image vertically
		CGAffineTransform flip155 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform143 = CGAffineTransformConcat(currentTransform143, flip155);
	}
	if (YES) { // center image
		NSRect boundsRect156 = self.bounds;
		CGFloat boundsMidX157 = NSMidX(boundsRect156) * (1.0f / viewScale);
		CGFloat boundsMidY158 = NSMidY(boundsRect156) * (1.0f / viewScale);
		CGFloat imageMidX159 = NSMidX(webBBox);
		CGFloat imageMidY160 = NSMidY(webBBox);
		CGFloat xTranslation161 = boundsMidX157 - imageMidX159;
		CGFloat yTranslation162 = boundsMidY158 - imageMidY160;
		CGAffineTransform centerTranslation163 = CGAffineTransformMakeTranslation(xTranslation161, yTranslation162);
		currentTransform143 = CGAffineTransformConcat(currentTransform143, centerTranslation163);
	}
    CGAffineTransform translate164 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform143 = CGAffineTransformConcat(currentTransform143, translate164);
	CGAffineTransform scale165 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform143 = CGAffineTransformConcat(currentTransform143, scale165);
	CGPathRef finalPath166 = CGPathCreateCopyByTransformingPath(circlePath145, &currentTransform143);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath166);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath166);
	CGPathRelease(circlePath145);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#808080" stroke-width="10px" cy="350px" id="circle17" fill="#ffffff" r="28px" cx="384px" transform="" macsvgid="088F61A6-9196-4FA6-9C8F-E7C52ED0EFA4-7830-000026383E888017"></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform167 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix168 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform167 = CGAffineTransformConcat(currentTransform167, ctmMatrix168);

	currentTransform167 = CGAffineTransformConcat(currentTransform167, adjustTransform);

	CGMutablePathRef circlePath169 = CGPathCreateMutable();
	CGFloat cx170 = 384.000000;
	CGFloat cy171 = 350.000000;
	CGFloat r172 = 28.000000;
	CGRect circleRect173 = CGRectMake((cx170 - r172), (cy171 - r172), (r172 * 2.0f), (r172 * 2.0f));
	CGPathAddEllipseInRect(circlePath169, NULL, circleRect173);
	CGFloat strokeWidth174 = 10;
	CGRect pathBoundingBox175 = CGPathGetBoundingBox(circlePath169);
	pathBoundingBox175 = NSInsetRect(pathBoundingBox175, -strokeWidth174, -strokeWidth174);
	CGFloat scaledStrokeWidth176 = 10 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth176);
	NSColor * strokeColor177 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor177.CGColor);
	NSColor * fillColor178 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor178.CGColor);
	if (NO) { // flip image vertically
		CGAffineTransform flip179 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform167 = CGAffineTransformConcat(currentTransform167, flip179);
	}
	if (YES) { // center image
		NSRect boundsRect180 = self.bounds;
		CGFloat boundsMidX181 = NSMidX(boundsRect180) * (1.0f / viewScale);
		CGFloat boundsMidY182 = NSMidY(boundsRect180) * (1.0f / viewScale);
		CGFloat imageMidX183 = NSMidX(webBBox);
		CGFloat imageMidY184 = NSMidY(webBBox);
		CGFloat xTranslation185 = boundsMidX181 - imageMidX183;
		CGFloat yTranslation186 = boundsMidY182 - imageMidY184;
		CGAffineTransform centerTranslation187 = CGAffineTransformMakeTranslation(xTranslation185, yTranslation186);
		currentTransform167 = CGAffineTransformConcat(currentTransform167, centerTranslation187);
	}
    CGAffineTransform translate188 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform167 = CGAffineTransformConcat(currentTransform167, translate188);
	CGAffineTransform scale189 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform167 = CGAffineTransformConcat(currentTransform167, scale189);
	CGPathRef finalPath190 = CGPathCreateCopyByTransformingPath(circlePath169, &currentTransform167);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath190);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath190);
	CGPathRelease(circlePath169);
	CGContextRestoreGState(context);
}



//================================================================================
// drawToolSettingsGearIcon:
//================================================================================

- (void)drawToolSettingsGearIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath1 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor2 = [NSColor orangeColor];
	//[rectColor2 set];
	//[rectPath1 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(-0.875000, -0.840990, 167.500000, 170.090990);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.5f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="g1" macsvgid="220D3549-DD0B-42C0-919B-332F56F9CD72-21240-00006CC6B6290275"><rect stroke="#000000" height="163.5px" x="72px" id="rect1" stroke-width="0.5px" width="27.25px" y="1.75px" fill="black" transform="" macsvgid="A8EAA90A-1407-431C-8166-0A9829430EB7-21240-00006C4F7AFD8847"></rect><rect stroke="#000000" height="163.5px" x="73.060661px" id="rect2" stroke-width="0.5px" width="27.25px" y="1.75px" fill="black" transform="rotate(45 85.625 83.5)" macsvgid="4863A299-6C33-4B71-8030-33EE530F2883-21240-00006C892DDE6454"></rect><rect stroke="#000000" height="163.5px" x="72.25px" id="rect3" stroke-width="0.5px" width="27.25px" y="4.5px" fill="black" transform="rotate(90 85.625 83.5)" macsvgid="1F49E99D-536E-4B0A-BEC9-78184CA2859A-21240-00006C8EAB1C17F5"></rect><rect stroke="#000000" height="163.5px" x="72.176773px" id="rect4" stroke-width="0.5px" width="27.25px" y="0.15901px" fill="black" transform="rotate(315 85.625 83.5)" macsvgid="1F9F2ACF-C92B-4017-B4AE-F2EAB86B3A8A-21240-00006C996EBF9DA5"></rect><circle stroke="#000000" macsvgid="F8DFFDEE-E89B-411D-AEAF-0BC895A93E80-21240-00006CB1826FB5FD" id="circle1" cy="83.25px" stroke-width="1px" fill="black" r="56.75px" cx="84px" transform=""></circle><circle stroke="#000000" macsvgid="796DBF10-BF94-4CDE-ACD5-2DBAE36345BB-21240-00006CB984568FF8" id="circle2" cy="83.875px" stroke-width="1px" fill="white" r="21.875px" cx="85.625px" transform=""></circle></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform3 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix4 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, ctmMatrix4);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="#000000" height="163.5px" x="72px" id="rect1" stroke-width="0.5px" width="27.25px" y="1.75px" fill="black" transform="" macsvgid="A8EAA90A-1407-431C-8166-0A9829430EB7-21240-00006C4F7AFD8847"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform5 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix6 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, ctmMatrix6);
	CGMutablePathRef rectPath7 = CGPathCreateMutable();
	CGFloat x8 = 72.000000;
	CGFloat y9 = 1.750000;
	CGFloat width10 = 27.250000;
	CGFloat height11 = 163.500000;
	CGRect rect14 = CGRectMake(x8, y9, width10, height11);
	CGPathAddRect(rectPath7, NULL, rect14);
	CGFloat strokeWidth15 = 05;
	CGRect pathBoundingBox16 = CGPathGetBoundingBox(rectPath7);
	pathBoundingBox16 = NSInsetRect(pathBoundingBox16, -strokeWidth15, -strokeWidth15);
	CGFloat scaledStrokeWidth17 = 05 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth17);
	NSColor * strokeColor18 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor18.CGColor);
	NSColor * fillColor19 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor19.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip20 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform5 = CGAffineTransformConcat(currentTransform5, flip20);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect21 = self.bounds;
		CGFloat boundsMidX22 = NSMidX(boundsRect21) * (1.0f / viewScale);
		CGFloat boundsMidY23 = NSMidY(boundsRect21) * (1.0f / viewScale);
		CGFloat imageMidX24 = NSMidX(webBBox);
		CGFloat imageMidY25 = NSMidY(webBBox);
		CGFloat xTranslation26 = boundsMidX22 - imageMidX24;
		CGFloat yTranslation27 = boundsMidY23 - imageMidY25;
		CGAffineTransform centerTranslation28 = CGAffineTransformMakeTranslation(xTranslation26, yTranslation27);
		currentTransform5 = CGAffineTransformConcat(currentTransform5, centerTranslation28);
	}
	CGAffineTransform translate29 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, translate29);
	CGAffineTransform scale30 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, scale30);
	CGPathRef finalPath31 = CGPathCreateCopyByTransformingPath(rectPath7, &currentTransform5);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath31);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath31);
	CGPathRelease(rectPath7);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="#000000" height="163.5px" x="73.060661px" id="rect2" stroke-width="0.5px" width="27.25px" y="1.75px" fill="black" transform="rotate(45 85.625 83.5)" macsvgid="4863A299-6C33-4B71-8030-33EE530F2883-21240-00006C892DDE6454"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform32 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix33 = CGAffineTransformMake(0.707107, 0.707107, -0.707107, 0.707107, 84.122398, -36.089436);
	currentTransform32 = CGAffineTransformConcat(currentTransform32, ctmMatrix33);
	CGMutablePathRef rectPath34 = CGPathCreateMutable();
	CGFloat x35 = 73.060661;
	CGFloat y36 = 1.750000;
	CGFloat width37 = 27.250000;
	CGFloat height38 = 163.500000;
	CGRect rect41 = CGRectMake(x35, y36, width37, height38);
	CGPathAddRect(rectPath34, NULL, rect41);
	CGFloat strokeWidth42 = 05;
	CGRect pathBoundingBox43 = CGPathGetBoundingBox(rectPath34);
	pathBoundingBox43 = NSInsetRect(pathBoundingBox43, -strokeWidth42, -strokeWidth42);
	CGFloat scaledStrokeWidth44 = 05 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth44);
	NSColor * strokeColor45 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor45.CGColor);
	NSColor * fillColor46 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor46.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip47 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform32 = CGAffineTransformConcat(currentTransform32, flip47);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect48 = self.bounds;
		CGFloat boundsMidX49 = NSMidX(boundsRect48) * (1.0f / viewScale);
		CGFloat boundsMidY50 = NSMidY(boundsRect48) * (1.0f / viewScale);
		CGFloat imageMidX51 = NSMidX(webBBox);
		CGFloat imageMidY52 = NSMidY(webBBox);
		CGFloat xTranslation53 = boundsMidX49 - imageMidX51;
		CGFloat yTranslation54 = boundsMidY50 - imageMidY52;
		CGAffineTransform centerTranslation55 = CGAffineTransformMakeTranslation(xTranslation53, yTranslation54);
		currentTransform32 = CGAffineTransformConcat(currentTransform32, centerTranslation55);
	}
	CGAffineTransform translate56 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform32 = CGAffineTransformConcat(currentTransform32, translate56);
	CGAffineTransform scale57 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform32 = CGAffineTransformConcat(currentTransform32, scale57);
	CGPathRef finalPath58 = CGPathCreateCopyByTransformingPath(rectPath34, &currentTransform32);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath58);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath58);
	CGPathRelease(rectPath34);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="#000000" height="163.5px" x="72.25px" id="rect3" stroke-width="0.5px" width="27.25px" y="4.5px" fill="black" transform="rotate(90 85.625 83.5)" macsvgid="1F49E99D-536E-4B0A-BEC9-78184CA2859A-21240-00006C8EAB1C17F5"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform59 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix60 = CGAffineTransformMake(0.000000, 1.000000, -1.000000, 0.000000, 169.125000, -2.125000);
	currentTransform59 = CGAffineTransformConcat(currentTransform59, ctmMatrix60);
	CGMutablePathRef rectPath61 = CGPathCreateMutable();
	CGFloat x62 = 72.250000;
	CGFloat y63 = 4.500000;
	CGFloat width64 = 27.250000;
	CGFloat height65 = 163.500000;
	CGRect rect68 = CGRectMake(x62, y63, width64, height65);
	CGPathAddRect(rectPath61, NULL, rect68);
	CGFloat strokeWidth69 = 05;
	CGRect pathBoundingBox70 = CGPathGetBoundingBox(rectPath61);
	pathBoundingBox70 = NSInsetRect(pathBoundingBox70, -strokeWidth69, -strokeWidth69);
	CGFloat scaledStrokeWidth71 = 05 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth71);
	NSColor * strokeColor72 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor72.CGColor);
	NSColor * fillColor73 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor73.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip74 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform59 = CGAffineTransformConcat(currentTransform59, flip74);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect75 = self.bounds;
		CGFloat boundsMidX76 = NSMidX(boundsRect75) * (1.0f / viewScale);
		CGFloat boundsMidY77 = NSMidY(boundsRect75) * (1.0f / viewScale);
		CGFloat imageMidX78 = NSMidX(webBBox);
		CGFloat imageMidY79 = NSMidY(webBBox);
		CGFloat xTranslation80 = boundsMidX76 - imageMidX78;
		CGFloat yTranslation81 = boundsMidY77 - imageMidY79;
		CGAffineTransform centerTranslation82 = CGAffineTransformMakeTranslation(xTranslation80, yTranslation81);
		currentTransform59 = CGAffineTransformConcat(currentTransform59, centerTranslation82);
	}
	CGAffineTransform translate83 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform59 = CGAffineTransformConcat(currentTransform59, translate83);
	CGAffineTransform scale84 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform59 = CGAffineTransformConcat(currentTransform59, scale84);
	CGPathRef finalPath85 = CGPathCreateCopyByTransformingPath(rectPath61, &currentTransform59);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath85);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath85);
	CGPathRelease(rectPath61);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="#000000" height="163.5px" x="72.176773px" id="rect4" stroke-width="0.5px" width="27.25px" y="0.15901px" fill="black" transform="rotate(315 85.625 83.5)" macsvgid="1F9F2ACF-C92B-4017-B4AE-F2EAB86B3A8A-21240-00006C996EBF9DA5"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform86 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix87 = CGAffineTransformMake(0.707107, -0.707107, 0.707107, 0.707107, -33.964436, 85.002602);
	currentTransform86 = CGAffineTransformConcat(currentTransform86, ctmMatrix87);
	CGMutablePathRef rectPath88 = CGPathCreateMutable();
	CGFloat x89 = 72.176773;
	CGFloat y90 = 0.159010;
	CGFloat width91 = 27.250000;
	CGFloat height92 = 163.500000;
	CGRect rect95 = CGRectMake(x89, y90, width91, height92);
	CGPathAddRect(rectPath88, NULL, rect95);
	CGFloat strokeWidth96 = 05;
	CGRect pathBoundingBox97 = CGPathGetBoundingBox(rectPath88);
	pathBoundingBox97 = NSInsetRect(pathBoundingBox97, -strokeWidth96, -strokeWidth96);
	CGFloat scaledStrokeWidth98 = 05 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth98);
	NSColor * strokeColor99 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor99.CGColor);
	NSColor * fillColor100 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor100.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip101 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform86 = CGAffineTransformConcat(currentTransform86, flip101);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect102 = self.bounds;
		CGFloat boundsMidX103 = NSMidX(boundsRect102) * (1.0f / viewScale);
		CGFloat boundsMidY104 = NSMidY(boundsRect102) * (1.0f / viewScale);
		CGFloat imageMidX105 = NSMidX(webBBox);
		CGFloat imageMidY106 = NSMidY(webBBox);
		CGFloat xTranslation107 = boundsMidX103 - imageMidX105;
		CGFloat yTranslation108 = boundsMidY104 - imageMidY106;
		CGAffineTransform centerTranslation109 = CGAffineTransformMakeTranslation(xTranslation107, yTranslation108);
		currentTransform86 = CGAffineTransformConcat(currentTransform86, centerTranslation109);
	}
	CGAffineTransform translate110 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform86 = CGAffineTransformConcat(currentTransform86, translate110);
	CGAffineTransform scale111 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform86 = CGAffineTransformConcat(currentTransform86, scale111);
	CGPathRef finalPath112 = CGPathCreateCopyByTransformingPath(rectPath88, &currentTransform86);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath112);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath112);
	CGPathRelease(rectPath88);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" macsvgid="F8DFFDEE-E89B-411D-AEAF-0BC895A93E80-21240-00006CB1826FB5FD" id="circle1" cy="83.25px" stroke-width="1px" fill="black" r="56.75px" cx="84px" transform=""></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform113 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix114 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform113 = CGAffineTransformConcat(currentTransform113, ctmMatrix114);
	CGMutablePathRef circlePath115 = CGPathCreateMutable();
	CGFloat cx116 = 84.000000;
	CGFloat cy117 = 83.250000;
	CGFloat r118 = 56.750000;
	CGRect circleRect119 = CGRectMake((cx116 - r118), (cy117 - r118), (r118 * 2.0f), (r118 * 2.0f));
	CGPathAddEllipseInRect(circlePath115, NULL, circleRect119);
	CGFloat strokeWidth120 = 1;
	CGRect pathBoundingBox121 = CGPathGetBoundingBox(circlePath115);
	pathBoundingBox121 = NSInsetRect(pathBoundingBox121, -strokeWidth120, -strokeWidth120);
	CGFloat scaledStrokeWidth122 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth122);
	NSColor * strokeColor123 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor123.CGColor);
	NSColor * fillColor124 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor124.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip125 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform113 = CGAffineTransformConcat(currentTransform113, flip125);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect126 = self.bounds;
		CGFloat boundsMidX127 = NSMidX(boundsRect126) * (1.0f / viewScale);
		CGFloat boundsMidY128 = NSMidY(boundsRect126) * (1.0f / viewScale);
		CGFloat imageMidX129 = NSMidX(webBBox);
		CGFloat imageMidY130 = NSMidY(webBBox);
		CGFloat xTranslation131 = boundsMidX127 - imageMidX129;
		CGFloat yTranslation132 = boundsMidY128 - imageMidY130;
		CGAffineTransform centerTranslation133 = CGAffineTransformMakeTranslation(xTranslation131, yTranslation132);
		currentTransform113 = CGAffineTransformConcat(currentTransform113, centerTranslation133);
	}
	CGAffineTransform translate134 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform113 = CGAffineTransformConcat(currentTransform113, translate134);
	CGAffineTransform scale135 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform113 = CGAffineTransformConcat(currentTransform113, scale135);
	CGPathRef finalPath136 = CGPathCreateCopyByTransformingPath(circlePath115, &currentTransform113);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath136);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath136);
	CGPathRelease(circlePath115);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <circle stroke="#000000" macsvgid="796DBF10-BF94-4CDE-ACD5-2DBAE36345BB-21240-00006CB984568FF8" id="circle2" cy="83.875px" stroke-width="1px" fill="white" r="21.875px" cx="85.625px" transform=""></circle>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform137 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix138 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform137 = CGAffineTransformConcat(currentTransform137, ctmMatrix138);
	CGMutablePathRef circlePath139 = CGPathCreateMutable();
	CGFloat cx140 = 85.625000;
	CGFloat cy141 = 83.875000;
	CGFloat r142 = 21.875000;
	CGRect circleRect143 = CGRectMake((cx140 - r142), (cy141 - r142), (r142 * 2.0f), (r142 * 2.0f));
	CGPathAddEllipseInRect(circlePath139, NULL, circleRect143);
	CGFloat strokeWidth144 = 1;
	CGRect pathBoundingBox145 = CGPathGetBoundingBox(circlePath139);
	pathBoundingBox145 = NSInsetRect(pathBoundingBox145, -strokeWidth144, -strokeWidth144);
	CGFloat scaledStrokeWidth146 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth146);
	NSColor * strokeColor147 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor147.CGColor);
	NSColor * fillColor148 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor148.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip149 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform137 = CGAffineTransformConcat(currentTransform137, flip149);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect150 = self.bounds;
		CGFloat boundsMidX151 = NSMidX(boundsRect150) * (1.0f / viewScale);
		CGFloat boundsMidY152 = NSMidY(boundsRect150) * (1.0f / viewScale);
		CGFloat imageMidX153 = NSMidX(webBBox);
		CGFloat imageMidY154 = NSMidY(webBBox);
		CGFloat xTranslation155 = boundsMidX151 - imageMidX153;
		CGFloat yTranslation156 = boundsMidY152 - imageMidY154;
		CGAffineTransform centerTranslation157 = CGAffineTransformMakeTranslation(xTranslation155, yTranslation156);
		currentTransform137 = CGAffineTransformConcat(currentTransform137, centerTranslation157);
	}
	CGAffineTransform translate158 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform137 = CGAffineTransformConcat(currentTransform137, translate158);
	CGAffineTransform scale159 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform137 = CGAffineTransformConcat(currentTransform137, scale159);
	CGPathRef finalPath160 = CGPathCreateCopyByTransformingPath(circlePath139, &currentTransform137);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath160);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath160);
	CGPathRelease(circlePath139);
	CGContextRestoreGState(context);
}


//================================================================================
// drawTransformTranslateIcon:
//================================================================================

- (void)drawTransformTranslateIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath1 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor2 = [NSColor orangeColor];
	//[rectColor2 set];
	//[rectPath1 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(-0.437500, -0.375000, 20.000000, 19.125000);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.5f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="transformTranslate" visibility="hidden" macsvgid="80A68CE0-E357-44F4-8F49-5B12840C6FEF-23575-0000781202FA65E2"><rect stroke="gray" height="13px" x="0.5625px" id="rect1" stroke-width="1px" width="13px" y="0.625px" fill="none" transform="" stroke-dasharray="1, 1" macsvgid="62057488-B959-48BE-9133-F29911E3516B-23575-0000781202FA89C1"></rect><rect stroke="#000000" height="13px" x="5.5625px" id="rect2" stroke-width="1px" width="13px" y="4.75px" fill="none" transform="" macsvgid="93894BFC-172D-422F-894E-A34A2C1622FC-23575-0000781202FAB5FA"></rect></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform3 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix4 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, ctmMatrix4);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="gray" height="13px" x="0.5625px" id="rect1" stroke-width="1px" width="13px" y="0.625px" fill="none" transform="" stroke-dasharray="1, 1" macsvgid="62057488-B959-48BE-9133-F29911E3516B-23575-0000781202FA89C1"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform5 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix6 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, ctmMatrix6);
	CGMutablePathRef rectPath7 = CGPathCreateMutable();
	CGFloat x8 = 0.562500;
	CGFloat y9 = 0.625000;
	CGFloat width10 = 13.000000;
	CGFloat height11 = 13.000000;
	CGRect rect14 = CGRectMake(x8, y9, width10, height11);
	CGPathAddRect(rectPath7, NULL, rect14);
	CGFloat strokeWidth15 = 1;
	CGRect pathBoundingBox16 = CGPathGetBoundingBox(rectPath7);
	pathBoundingBox16 = NSInsetRect(pathBoundingBox16, -strokeWidth15, -strokeWidth15);
	CGFloat scaledStrokeWidth17 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth17);
	NSColor * strokeColor18 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor18.CGColor);
	NSColor * fillColor19 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor19.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip20 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform5 = CGAffineTransformConcat(currentTransform5, flip20);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect21 = self.bounds;
		CGFloat boundsMidX22 = NSMidX(boundsRect21) * (1.0f / viewScale);
		CGFloat boundsMidY23 = NSMidY(boundsRect21) * (1.0f / viewScale);
		CGFloat imageMidX24 = NSMidX(webBBox);
		CGFloat imageMidY25 = NSMidY(webBBox);
		CGFloat xTranslation26 = boundsMidX22 - imageMidX24;
		CGFloat yTranslation27 = boundsMidY23 - imageMidY25;
		CGAffineTransform centerTranslation28 = CGAffineTransformMakeTranslation(xTranslation26, yTranslation27);
		currentTransform5 = CGAffineTransformConcat(currentTransform5, centerTranslation28);
	}
	CGAffineTransform translate29 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, translate29);
	CGAffineTransform scale30 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, scale30);
	CGPathRef finalPath31 = CGPathCreateCopyByTransformingPath(rectPath7, &currentTransform5);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath31);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath31);
	CGPathRelease(rectPath7);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="#000000" height="13px" x="5.5625px" id="rect2" stroke-width="1px" width="13px" y="4.75px" fill="none" transform="" macsvgid="93894BFC-172D-422F-894E-A34A2C1622FC-23575-0000781202FAB5FA"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform32 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix33 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform32 = CGAffineTransformConcat(currentTransform32, ctmMatrix33);
	CGMutablePathRef rectPath34 = CGPathCreateMutable();
	CGFloat x35 = 5.562500;
	CGFloat y36 = 4.750000;
	CGFloat width37 = 13.000000;
	CGFloat height38 = 13.000000;
	CGRect rect41 = CGRectMake(x35, y36, width37, height38);
	CGPathAddRect(rectPath34, NULL, rect41);
	CGFloat strokeWidth42 = 1;
	CGRect pathBoundingBox43 = CGPathGetBoundingBox(rectPath34);
	pathBoundingBox43 = NSInsetRect(pathBoundingBox43, -strokeWidth42, -strokeWidth42);
	CGFloat scaledStrokeWidth44 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth44);
	NSColor * strokeColor45 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor45.CGColor);
	NSColor * fillColor46 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor46.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip47 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform32 = CGAffineTransformConcat(currentTransform32, flip47);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect48 = self.bounds;
		CGFloat boundsMidX49 = NSMidX(boundsRect48) * (1.0f / viewScale);
		CGFloat boundsMidY50 = NSMidY(boundsRect48) * (1.0f / viewScale);
		CGFloat imageMidX51 = NSMidX(webBBox);
		CGFloat imageMidY52 = NSMidY(webBBox);
		CGFloat xTranslation53 = boundsMidX49 - imageMidX51;
		CGFloat yTranslation54 = boundsMidY50 - imageMidY52;
		CGAffineTransform centerTranslation55 = CGAffineTransformMakeTranslation(xTranslation53, yTranslation54);
		currentTransform32 = CGAffineTransformConcat(currentTransform32, centerTranslation55);
	}
	CGAffineTransform translate56 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform32 = CGAffineTransformConcat(currentTransform32, translate56);
	CGAffineTransform scale57 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform32 = CGAffineTransformConcat(currentTransform32, scale57);
	CGPathRef finalPath58 = CGPathCreateCopyByTransformingPath(rectPath34, &currentTransform32);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath58);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath58);
	CGPathRelease(rectPath34);
	CGContextRestoreGState(context);
}


//================================================================================
// drawTransformScaleIcon:
//================================================================================

- (void)drawTransformScaleIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath59 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor60 = [NSColor orangeColor];
	//[rectColor60 set];
	//[rectPath59 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(-0.375000, -0.312500, 20.000000, 20.000000);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.5f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="transformScale" visibility="visible" macsvgid="D3B32A1B-5753-4FDB-A3D5-E8AD4D2B9832-23575-0000781202FADE80"><rect stroke="gray" height="13px" x="0.8125px" y="0.75px" stroke-width="1px" width="13px" fill="none" id="rect3" transform="" stroke-dasharray="1, 1" macsvgid="9F27A1C4-1EBE-4073-90A2-2B281CEEA915-23575-0000781202FB0035"></rect><rect stroke="#000000" height="18px" x="0.625px" y="0.6875px" stroke-width="1px" width="18px" id="rect3" fill="none" transform="" macsvgid="6AAC02D4-5183-42F3-9FCA-70D386504570-23575-0000781202FB2B6E"></rect></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform61 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix62 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform61 = CGAffineTransformConcat(currentTransform61, ctmMatrix62);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="gray" height="13px" x="0.8125px" y="0.75px" stroke-width="1px" width="13px" fill="none" id="rect3" transform="" stroke-dasharray="1, 1" macsvgid="9F27A1C4-1EBE-4073-90A2-2B281CEEA915-23575-0000781202FB0035"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform63 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix64 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform63 = CGAffineTransformConcat(currentTransform63, ctmMatrix64);
	CGMutablePathRef rectPath65 = CGPathCreateMutable();
	CGFloat x66 = 0.812500;
	CGFloat y67 = 0.750000;
	CGFloat width68 = 13.000000;
	CGFloat height69 = 13.000000;
	CGRect rect72 = CGRectMake(x66, y67, width68, height69);
	CGPathAddRect(rectPath65, NULL, rect72);
	CGFloat strokeWidth73 = 1;
	CGRect pathBoundingBox74 = CGPathGetBoundingBox(rectPath65);
	pathBoundingBox74 = NSInsetRect(pathBoundingBox74, -strokeWidth73, -strokeWidth73);
	CGFloat scaledStrokeWidth75 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth75);
	NSColor * strokeColor76 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor76.CGColor);
	NSColor * fillColor77 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor77.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip78 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform63 = CGAffineTransformConcat(currentTransform63, flip78);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect79 = self.bounds;
		CGFloat boundsMidX80 = NSMidX(boundsRect79) * (1.0f / viewScale);
		CGFloat boundsMidY81 = NSMidY(boundsRect79) * (1.0f / viewScale);
		CGFloat imageMidX82 = NSMidX(webBBox);
		CGFloat imageMidY83 = NSMidY(webBBox);
		CGFloat xTranslation84 = boundsMidX80 - imageMidX82;
		CGFloat yTranslation85 = boundsMidY81 - imageMidY83;
		CGAffineTransform centerTranslation86 = CGAffineTransformMakeTranslation(xTranslation84, yTranslation85);
		currentTransform63 = CGAffineTransformConcat(currentTransform63, centerTranslation86);
	}
	CGAffineTransform translate87 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform63 = CGAffineTransformConcat(currentTransform63, translate87);
	CGAffineTransform scale88 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform63 = CGAffineTransformConcat(currentTransform63, scale88);
	CGPathRef finalPath89 = CGPathCreateCopyByTransformingPath(rectPath65, &currentTransform63);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath89);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath89);
	CGPathRelease(rectPath65);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="#000000" height="18px" x="0.625px" y="0.6875px" stroke-width="1px" width="18px" id="rect3" fill="none" transform="" macsvgid="6AAC02D4-5183-42F3-9FCA-70D386504570-23575-0000781202FB2B6E"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform90 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix91 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform90 = CGAffineTransformConcat(currentTransform90, ctmMatrix91);
	CGMutablePathRef rectPath92 = CGPathCreateMutable();
	CGFloat x93 = 0.625000;
	CGFloat y94 = 0.687500;
	CGFloat width95 = 18.000000;
	CGFloat height96 = 18.000000;
	CGRect rect99 = CGRectMake(x93, y94, width95, height96);
	CGPathAddRect(rectPath92, NULL, rect99);
	CGFloat strokeWidth100 = 1;
	CGRect pathBoundingBox101 = CGPathGetBoundingBox(rectPath92);
	pathBoundingBox101 = NSInsetRect(pathBoundingBox101, -strokeWidth100, -strokeWidth100);
	CGFloat scaledStrokeWidth102 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth102);
	NSColor * strokeColor103 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor103.CGColor);
	NSColor * fillColor104 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor104.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip105 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform90 = CGAffineTransformConcat(currentTransform90, flip105);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect106 = self.bounds;
		CGFloat boundsMidX107 = NSMidX(boundsRect106) * (1.0f / viewScale);
		CGFloat boundsMidY108 = NSMidY(boundsRect106) * (1.0f / viewScale);
		CGFloat imageMidX109 = NSMidX(webBBox);
		CGFloat imageMidY110 = NSMidY(webBBox);
		CGFloat xTranslation111 = boundsMidX107 - imageMidX109;
		CGFloat yTranslation112 = boundsMidY108 - imageMidY110;
		CGAffineTransform centerTranslation113 = CGAffineTransformMakeTranslation(xTranslation111, yTranslation112);
		currentTransform90 = CGAffineTransformConcat(currentTransform90, centerTranslation113);
	}
	CGAffineTransform translate114 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform90 = CGAffineTransformConcat(currentTransform90, translate114);
	CGAffineTransform scale115 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform90 = CGAffineTransformConcat(currentTransform90, scale115);
	CGPathRef finalPath116 = CGPathCreateCopyByTransformingPath(rectPath92, &currentTransform90);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath116);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath116);
	CGPathRelease(rectPath92);
	CGContextRestoreGState(context);
}

//================================================================================
// drawTransformRotateIcon:
//================================================================================

- (void)drawTransformRotateIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath117 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor118 = [NSColor orangeColor];
	//[rectColor118 set];
	//[rectPath117 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(-0.437500, -0.375000, 18.822594, 20.385094);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.5f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="transformRotate" visibility="visible" macsvgid="B018F139-C479-4722-BE43-2CF96F942A5E-23575-0000781202FB52C9"><rect stroke="gray" height="13px" x="0.5625px" stroke-width="1px" width="13px" y="0.625px" fill="none" transform="" stroke-dasharray="1, 1" id="rect4" macsvgid="3B9BBB3E-684B-449B-A7CB-8BE766FC6592-23575-0000781202FB74C9"></rect><rect stroke="#000000" height="13px" x="2.5625px" y="4.1875px" stroke-width="1px" width="13px" id="rect4" fill="none" transform="rotate(19.874367 9.0625 10.6875)" macsvgid="36315C60-BD52-4B2A-BE0D-562D2A4E7880-23575-0000781202FBA067"></rect></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform119 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix120 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform119 = CGAffineTransformConcat(currentTransform119, ctmMatrix120);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="gray" height="13px" x="0.5625px" stroke-width="1px" width="13px" y="0.625px" fill="none" transform="" stroke-dasharray="1, 1" id="rect4" macsvgid="3B9BBB3E-684B-449B-A7CB-8BE766FC6592-23575-0000781202FB74C9"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform121 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix122 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform121 = CGAffineTransformConcat(currentTransform121, ctmMatrix122);
	CGMutablePathRef rectPath123 = CGPathCreateMutable();
	CGFloat x124 = 0.562500;
	CGFloat y125 = 0.625000;
	CGFloat width126 = 13.000000;
	CGFloat height127 = 13.000000;
	CGRect rect130 = CGRectMake(x124, y125, width126, height127);
	CGPathAddRect(rectPath123, NULL, rect130);
	CGFloat strokeWidth131 = 1;
	CGRect pathBoundingBox132 = CGPathGetBoundingBox(rectPath123);
	pathBoundingBox132 = NSInsetRect(pathBoundingBox132, -strokeWidth131, -strokeWidth131);
	CGFloat scaledStrokeWidth133 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth133);
	NSColor * strokeColor134 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor134.CGColor);
	NSColor * fillColor135 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor135.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip136 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform121 = CGAffineTransformConcat(currentTransform121, flip136);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect137 = self.bounds;
		CGFloat boundsMidX138 = NSMidX(boundsRect137) * (1.0f / viewScale);
		CGFloat boundsMidY139 = NSMidY(boundsRect137) * (1.0f / viewScale);
		CGFloat imageMidX140 = NSMidX(webBBox);
		CGFloat imageMidY141 = NSMidY(webBBox);
		CGFloat xTranslation142 = boundsMidX138 - imageMidX140;
		CGFloat yTranslation143 = boundsMidY139 - imageMidY141;
		CGAffineTransform centerTranslation144 = CGAffineTransformMakeTranslation(xTranslation142, yTranslation143);
		currentTransform121 = CGAffineTransformConcat(currentTransform121, centerTranslation144);
	}
	CGAffineTransform translate145 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform121 = CGAffineTransformConcat(currentTransform121, translate145);
	CGAffineTransform scale146 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform121 = CGAffineTransformConcat(currentTransform121, scale146);
	CGPathRef finalPath147 = CGPathCreateCopyByTransformingPath(rectPath123, &currentTransform121);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath147);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath147);
	CGPathRelease(rectPath123);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="#000000" height="13px" x="2.5625px" y="4.1875px" stroke-width="1px" width="13px" id="rect4" fill="none" transform="rotate(19.874367 9.0625 10.6875)" macsvgid="36315C60-BD52-4B2A-BE0D-562D2A4E7880-23575-0000781202FBA067"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform148 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix149 = CGAffineTransformMake(0.940440, 0.339959, -0.339959, 0.940440, 4.173070, -2.444333);
	currentTransform148 = CGAffineTransformConcat(currentTransform148, ctmMatrix149);
	CGMutablePathRef rectPath150 = CGPathCreateMutable();
	CGFloat x151 = 2.562500;
	CGFloat y152 = 4.187500;
	CGFloat width153 = 13.000000;
	CGFloat height154 = 13.000000;
	CGRect rect157 = CGRectMake(x151, y152, width153, height154);
	CGPathAddRect(rectPath150, NULL, rect157);
	CGFloat strokeWidth158 = 1;
	CGRect pathBoundingBox159 = CGPathGetBoundingBox(rectPath150);
	pathBoundingBox159 = NSInsetRect(pathBoundingBox159, -strokeWidth158, -strokeWidth158);
	CGFloat scaledStrokeWidth160 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth160);
	NSColor * strokeColor161 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor161.CGColor);
	NSColor * fillColor162 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor162.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip163 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform148 = CGAffineTransformConcat(currentTransform148, flip163);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect164 = self.bounds;
		CGFloat boundsMidX165 = NSMidX(boundsRect164) * (1.0f / viewScale);
		CGFloat boundsMidY166 = NSMidY(boundsRect164) * (1.0f / viewScale);
		CGFloat imageMidX167 = NSMidX(webBBox);
		CGFloat imageMidY168 = NSMidY(webBBox);
		CGFloat xTranslation169 = boundsMidX165 - imageMidX167;
		CGFloat yTranslation170 = boundsMidY166 - imageMidY168;
		CGAffineTransform centerTranslation171 = CGAffineTransformMakeTranslation(xTranslation169, yTranslation170);
		currentTransform148 = CGAffineTransformConcat(currentTransform148, centerTranslation171);
	}
	CGAffineTransform translate172 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform148 = CGAffineTransformConcat(currentTransform148, translate172);
	CGAffineTransform scale173 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform148 = CGAffineTransformConcat(currentTransform148, scale173);
	CGPathRef finalPath174 = CGPathCreateCopyByTransformingPath(rectPath150, &currentTransform148);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath174);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath174);
	CGPathRelease(rectPath150);
	CGContextRestoreGState(context);
}


//================================================================================
// drawTransformSkewXIcon:
//================================================================================

- (void)drawTransformSkewXIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath175 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor176 = [NSColor orangeColor];
	//[rectColor176 set];
	//[rectPath175 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(-0.438000, -0.375000, 19.976562, 20.000000);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.5f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="transformSkewX" visibility="visible" macsvgid="C9A1B32A-9426-41D0-93FC-91C2D442268C-23575-0000781202FBC7E5"><rect stroke="gray" height="18px" x="0.562px" stroke-width="1px" width="11px" y="0.625px" fill="none" transform="" stroke-dasharray="1, 1" id="rect5" macsvgid="C10A2B7A-C87B-4823-AB32-6CD208328292-23575-0000781202FBE990"></rect><rect stroke="#000000" height="18px" x="7.772937px" y="0.625px" stroke-width="1px" width="11px" id="rect5" fill="none" transform="skewX(-20.556047)" macsvgid="7AD2F7E7-CF78-499C-B768-8EA0E3A0E638-23575-0000781202FC153A"></rect></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform177 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix178 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform177 = CGAffineTransformConcat(currentTransform177, ctmMatrix178);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="gray" height="18px" x="0.562px" stroke-width="1px" width="11px" y="0.625px" fill="none" transform="" stroke-dasharray="1, 1" id="rect5" macsvgid="C10A2B7A-C87B-4823-AB32-6CD208328292-23575-0000781202FBE990"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform179 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix180 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform179 = CGAffineTransformConcat(currentTransform179, ctmMatrix180);
	CGMutablePathRef rectPath181 = CGPathCreateMutable();
	CGFloat x182 = 0.562000;
	CGFloat y183 = 0.625000;
	CGFloat width184 = 11.000000;
	CGFloat height185 = 18.000000;
	CGRect rect188 = CGRectMake(x182, y183, width184, height185);
	CGPathAddRect(rectPath181, NULL, rect188);
	CGFloat strokeWidth189 = 1;
	CGRect pathBoundingBox190 = CGPathGetBoundingBox(rectPath181);
	pathBoundingBox190 = NSInsetRect(pathBoundingBox190, -strokeWidth189, -strokeWidth189);
	CGFloat scaledStrokeWidth191 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth191);
	NSColor * strokeColor192 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor192.CGColor);
	NSColor * fillColor193 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor193.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip194 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform179 = CGAffineTransformConcat(currentTransform179, flip194);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect195 = self.bounds;
		CGFloat boundsMidX196 = NSMidX(boundsRect195) * (1.0f / viewScale);
		CGFloat boundsMidY197 = NSMidY(boundsRect195) * (1.0f / viewScale);
		CGFloat imageMidX198 = NSMidX(webBBox);
		CGFloat imageMidY199 = NSMidY(webBBox);
		CGFloat xTranslation200 = boundsMidX196 - imageMidX198;
		CGFloat yTranslation201 = boundsMidY197 - imageMidY199;
		CGAffineTransform centerTranslation202 = CGAffineTransformMakeTranslation(xTranslation200, yTranslation201);
		currentTransform179 = CGAffineTransformConcat(currentTransform179, centerTranslation202);
	}
	CGAffineTransform translate203 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform179 = CGAffineTransformConcat(currentTransform179, translate203);
	CGAffineTransform scale204 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform179 = CGAffineTransformConcat(currentTransform179, scale204);
	CGPathRef finalPath205 = CGPathCreateCopyByTransformingPath(rectPath181, &currentTransform179);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath205);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath205);
	CGPathRelease(rectPath181);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="#000000" height="18px" x="7.772937px" y="0.625px" stroke-width="1px" width="11px" id="rect5" fill="none" transform="skewX(-20.556047)" macsvgid="7AD2F7E7-CF78-499C-B768-8EA0E3A0E638-23575-0000781202FC153A"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform206 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix207 = CGAffineTransformMake(1.000000, 0.000000, -0.375000, 1.000000, 0.000000, 0.000000);
	currentTransform206 = CGAffineTransformConcat(currentTransform206, ctmMatrix207);
	CGMutablePathRef rectPath208 = CGPathCreateMutable();
	CGFloat x209 = 7.772937;
	CGFloat y210 = 0.625000;
	CGFloat width211 = 11.000000;
	CGFloat height212 = 18.000000;
	CGRect rect215 = CGRectMake(x209, y210, width211, height212);
	CGPathAddRect(rectPath208, NULL, rect215);
	CGFloat strokeWidth216 = 1;
	CGRect pathBoundingBox217 = CGPathGetBoundingBox(rectPath208);
	pathBoundingBox217 = NSInsetRect(pathBoundingBox217, -strokeWidth216, -strokeWidth216);
	CGFloat scaledStrokeWidth218 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth218);
	NSColor * strokeColor219 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor219.CGColor);
	NSColor * fillColor220 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor220.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip221 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform206 = CGAffineTransformConcat(currentTransform206, flip221);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect222 = self.bounds;
		CGFloat boundsMidX223 = NSMidX(boundsRect222) * (1.0f / viewScale);
		CGFloat boundsMidY224 = NSMidY(boundsRect222) * (1.0f / viewScale);
		CGFloat imageMidX225 = NSMidX(webBBox);
		CGFloat imageMidY226 = NSMidY(webBBox);
		CGFloat xTranslation227 = boundsMidX223 - imageMidX225;
		CGFloat yTranslation228 = boundsMidY224 - imageMidY226;
		CGAffineTransform centerTranslation229 = CGAffineTransformMakeTranslation(xTranslation227, yTranslation228);
		currentTransform206 = CGAffineTransformConcat(currentTransform206, centerTranslation229);
	}
	CGAffineTransform translate230 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform206 = CGAffineTransformConcat(currentTransform206, translate230);
	CGAffineTransform scale231 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform206 = CGAffineTransformConcat(currentTransform206, scale231);
	CGPathRef finalPath232 = CGPathCreateCopyByTransformingPath(rectPath208, &currentTransform206);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath232);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath232);
	CGPathRelease(rectPath208);
	CGContextRestoreGState(context);
}

//================================================================================
// drawTransformSkewYIcon:
//================================================================================

- (void)drawTransformSkewYIcon:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	//NSBezierPath * rectPath233 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor234 = [NSColor orangeColor];
	//[rectColor234 set];
	//[rectPath233 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)nsctx.graphicsPort;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(-0.438000, -0.375000, 24.187500, 24.694389);
	CGFloat hViewScale = self.frame.size.width / (webBBox.size.width);
	CGFloat vViewScale = self.frame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.5f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="transformSkewY" visibility="visible" macsvgid="59014B38-CEF2-48E6-A1E7-C185213D7A93-23575-0000781202FC3E0B"><rect stroke="gray" height="13px" x="0.562px" id="rect6" stroke-width="1px" width="22px" y="0.625px" fill="none" transform="" stroke-dasharray="1, 1" macsvgid="B865FBCB-01EF-4F60-A4BC-FFC6366277BB-23575-0000781202FC6103"></rect><rect stroke="#000000" height="13px" x="0.7495px" y="0.625px" stroke-width="1px" width="22px" id="rect6" fill="none" transform="skewY(23.080616)" macsvgid="DD0FAB09-F912-44B5-A1BF-2CC7642A9C31-23575-0000781202FC8D00"></rect></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform235 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix236 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform235 = CGAffineTransformConcat(currentTransform235, ctmMatrix236);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="gray" height="13px" x="0.562px" id="rect6" stroke-width="1px" width="22px" y="0.625px" fill="none" transform="" stroke-dasharray="1, 1" macsvgid="B865FBCB-01EF-4F60-A4BC-FFC6366277BB-23575-0000781202FC6103"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform237 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix238 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform237 = CGAffineTransformConcat(currentTransform237, ctmMatrix238);
	CGMutablePathRef rectPath239 = CGPathCreateMutable();
	CGFloat x240 = 0.562000;
	CGFloat y241 = 0.625000;
	CGFloat width242 = 22.000000;
	CGFloat height243 = 13.000000;
	CGRect rect246 = CGRectMake(x240, y241, width242, height243);
	CGPathAddRect(rectPath239, NULL, rect246);
	CGFloat strokeWidth247 = 1;
	CGRect pathBoundingBox248 = CGPathGetBoundingBox(rectPath239);
	pathBoundingBox248 = NSInsetRect(pathBoundingBox248, -strokeWidth247, -strokeWidth247);
	CGFloat scaledStrokeWidth249 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth249);
	NSColor * strokeColor250 = [NSColor colorWithRed:0.501961 green:0.501961 blue:0.501961 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor250.CGColor);
	NSColor * fillColor251 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor251.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip252 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform237 = CGAffineTransformConcat(currentTransform237, flip252);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect253 = self.bounds;
		CGFloat boundsMidX254 = NSMidX(boundsRect253) * (1.0f / viewScale);
		CGFloat boundsMidY255 = NSMidY(boundsRect253) * (1.0f / viewScale);
		CGFloat imageMidX256 = NSMidX(webBBox);
		CGFloat imageMidY257 = NSMidY(webBBox);
		CGFloat xTranslation258 = boundsMidX254 - imageMidX256;
		CGFloat yTranslation259 = boundsMidY255 - imageMidY257;
		CGAffineTransform centerTranslation260 = CGAffineTransformMakeTranslation(xTranslation258, yTranslation259);
		currentTransform237 = CGAffineTransformConcat(currentTransform237, centerTranslation260);
	}
	CGAffineTransform translate261 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform237 = CGAffineTransformConcat(currentTransform237, translate261);
	CGAffineTransform scale262 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform237 = CGAffineTransformConcat(currentTransform237, scale262);
	CGPathRef finalPath263 = CGPathCreateCopyByTransformingPath(rectPath239, &currentTransform237);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath263);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath263);
	CGPathRelease(rectPath239);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="#000000" height="13px" x="0.7495px" y="0.625px" stroke-width="1px" width="22px" id="rect6" fill="none" transform="skewY(23.080616)" macsvgid="DD0FAB09-F912-44B5-A1BF-2CC7642A9C31-23575-0000781202FC8D00"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform264 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix265 = CGAffineTransformMake(1.000000, 0.426136, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform264 = CGAffineTransformConcat(currentTransform264, ctmMatrix265);
	CGMutablePathRef rectPath266 = CGPathCreateMutable();
	CGFloat x267 = 0.749500;
	CGFloat y268 = 0.625000;
	CGFloat width269 = 22.000000;
	CGFloat height270 = 13.000000;
	CGRect rect273 = CGRectMake(x267, y268, width269, height270);
	CGPathAddRect(rectPath266, NULL, rect273);
	CGFloat strokeWidth274 = 1;
	CGRect pathBoundingBox275 = CGPathGetBoundingBox(rectPath266);
	pathBoundingBox275 = NSInsetRect(pathBoundingBox275, -strokeWidth274, -strokeWidth274);
	CGFloat scaledStrokeWidth276 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth276);
	NSColor * strokeColor277 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor277.CGColor);
	NSColor * fillColor278 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor278.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip279 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform264 = CGAffineTransformConcat(currentTransform264, flip279);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect280 = self.bounds;
		CGFloat boundsMidX281 = NSMidX(boundsRect280) * (1.0f / viewScale);
		CGFloat boundsMidY282 = NSMidY(boundsRect280) * (1.0f / viewScale);
		CGFloat imageMidX283 = NSMidX(webBBox);
		CGFloat imageMidY284 = NSMidY(webBBox);
		CGFloat xTranslation285 = boundsMidX281 - imageMidX283;
		CGFloat yTranslation286 = boundsMidY282 - imageMidY284;
		CGAffineTransform centerTranslation287 = CGAffineTransformMakeTranslation(xTranslation285, yTranslation286);
		currentTransform264 = CGAffineTransformConcat(currentTransform264, centerTranslation287);
	}
	CGAffineTransform translate288 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform264 = CGAffineTransformConcat(currentTransform264, translate288);
	CGAffineTransform scale289 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform264 = CGAffineTransformConcat(currentTransform264, scale289);
	CGPathRef finalPath290 = CGPathCreateCopyByTransformingPath(rectPath266, &currentTransform264);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath290);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath290);
	CGPathRelease(rectPath266);
	CGContextRestoreGState(context);
}


@end
