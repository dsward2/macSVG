//
//  SVGIconTableHeaderCell.m
//  macSVG
//
//  Created by Douglas Ward on 8/3/16.
//
//

#import "SVGIconTableHeaderCell.h"

@implementation SVGIconTableHeaderCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.iconIndex = 0;
    }
    return self;
}



- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.iconIndex = 0;
    }
    return self;
}


/*
- (instancetype)initImageCell:(NSImage *)anImage
{
    self = [super initImageCell:anImage];
    if (self) {
        self.iconIndex = 0;
    }
    return self;
}
*/


- (instancetype)initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];
    if (self) {
        self.iconIndex = 0;
    }
    return self;
}


- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	//[super drawInteriorWithFrame:cellFrame inView:controlView];
    
    switch (self.iconIndex)
    {
        case 0:
        {
            [self drawVisibleEyeIcon:cellFrame];
            break;
        }
        case 1:
        {
            [self drawPadlockIcon:cellFrame];
            break;
        }
        default:
        {
            [self drawFolderIcon:cellFrame];
            break;
        }
    }
}


- (void)drawVisibleEyeIcon:(NSRect)cellFrame {
	//NSBezierPath * rectPath1 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor2 = [NSColor orangeColor];
	//[rectColor2 set];
	//[rectPath1 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
    //CGContextRef context = (CGContextRef)nsctx.graphicsPort;
    CGContextRef context = (CGContextRef)nsctx.CGContext;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(-1.500000, -2.134995, 523.500000, 340.895996);
	CGFloat hViewScale = cellFrame.size.width / (webBBox.size.width);
	CGFloat vViewScale = cellFrame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 0.6f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="visible_eye_icon" visibility="visible" macsvgid="AFBCD74D-10B6-4844-A057-BB6A48B634F6-48030-0000FD8B79D9F6AA"><path d="M508.917969,147.117004 C482.266968,103.529999 446.432983,68.507996 401.42099,42.052002 C356.406006,15.595001 308.871979,2.365005 258.812988,2.365005 C208.753998,2.365005 161.217987,15.589996 116.202988,42.052002 C71.186996,68.507996 35.354996,103.529999 8.708,147.117004 C4.903,153.778015 3,160.345001 3,166.817993 C3,173.290985 4.903,179.858002 8.708,186.516998 C35.354996,230.105988 71.186996,265.130981 116.203003,291.580994 C161.218002,318.040985 208.753998,331.260986 258.812988,331.260986 C308.873016,331.260986 356.407013,318.084991 401.421021,291.724976 C446.433014,265.364014 482.27301,230.292999 508.91803,186.516998 C512.723999,179.858002 514.625977,173.294006 514.625977,166.817993 C514.625977,160.345001 512.723999,153.778015 508.917969,147.117004  z M197.567993,69.029999 C214.60199,51.996002 235.014984,43.475998 258.809998,43.475998 C262.61499,43.475998 265.852997,44.811996 268.518982,47.474991 C271.180969,50.138992 272.518982,53.375992 272.518982,57.181992 C272.518982,60.990997 271.180969,64.225998 268.524994,66.885986 C265.863007,69.553009 262.622986,70.884995 258.816986,70.884995 C242.448975,70.884995 228.454987,76.692993 216.845978,88.300995 C205.232971,99.916 199.429993,113.903992 199.429993,130.272003 C199.429993,134.083008 198.093994,137.31601 195.431,139.981995 C192.763992,142.649994 189.529999,143.980988 185.723999,143.980988 C181.914993,143.981018 178.679993,142.647003 176.013992,139.981995 C173.346985,137.315979 172.014999,134.078979 172.014999,130.271973 C172.014999,106.481995 180.535004,86.065002 197.567993,69.029999  z M382.867004,260.040009 C344.703003,283.160004 303.352997,294.72702 258.812988,294.72702 C214.273987,294.72702 172.924011,283.167023 134.761993,260.040009 S64.860992,205.839996 39.546997,166.817993 C68.478004,121.897003 104.737,88.300018 148.324005,66.035004 C136.714005,85.826996 130.907013,107.242004 130.907013,130.270996 C130.907013,165.487 143.424011,195.600006 168.451004,220.632996 S223.60199,258.177002 258.812988,258.177002 C294.027008,258.177002 324.141998,245.658997 349.174988,220.632996 S386.719971,165.487 386.719971,130.270996 C386.720001,107.242004 380.911987,85.824005 369.300995,66.035004 C412.885986,88.300003 449.147003,121.900024 478.077026,166.817993 C452.766998,205.839996 421.031006,236.912994 382.867004,260.040009  z " id="prototype_to_delete" visibility="hidden" macsvgid="BB28CE0F-CDDD-400D-B0C7-820EB2536201-48030-0000FD8B79DA1667"></path><path d="M510.917969,150.117004 C484.266968,106.529999 448.432983,71.507996 403.42099,45.052002 C358.406006,18.595001 310.871979,5.365005 260.812988,5.365005 C210.753998,5.365005 163.217987,18.589996 118.202988,45.052002 C73.186996,71.507996 37.354996,106.529999 10.708,150.117004 C6.903,156.778015 5,163.345001 5,169.817993 C5,176.290985 6.903,182.858002 10.708,189.516998 C37.354996,233.105988 73.186996,268.130981 118.203003,294.580994 C163.218002,321.040985 210.753998,334.260986 260.812988,334.260986 C310.873016,334.260986 358.407013,321.084991 403.421021,294.724976 C448.432983,268.364014 484.27301,233.292999 510.91803,189.516998 C514.723999,182.858002 516.625977,176.294006 516.625977,169.817993 C516.625977,163.345001 514.723999,156.778015 510.917969,150.117004  z M199.567993,72.029999 C216.60199,54.996002 237.014984,46.475998 260.809998,46.475998 C264.61499,46.475998 267.852997,47.811996 270.518982,50.474991 C273.180969,53.138992 274.518982,56.375992 274.518982,60.181992 C274.518982,63.990997 273.180969,67.225998 270.524994,69.885986 C267.863007,72.553009 264.622986,73.884995 260.816986,73.884995 C244.448975,73.884995 230.454987,79.692993 218.845978,91.300995 C207.232971,102.916 201.429993,116.903992 201.429993,133.272003 C201.429993,137.083008 200.093994,140.31601 197.431,142.981995 C194.763977,145.649994 191.529999,146.980988 187.723999,146.980988 C183.914993,146.981018 180.679993,145.647003 178.013992,142.981995 C175.346985,140.315979 174.014999,137.078979 174.014999,133.271973 C174.014999,109.481995 182.535004,89.065002 199.567993,72.029999  z M384.867004,263.040009 C346.703003,286.160004 305.352997,297.72702 260.812988,297.72702 C216.273987,297.72702 174.924011,286.167023 136.761993,263.040009 S66.860992,208.839996 41.546997,169.817993 C70.477997,124.897003 106.737,91.300018 150.324005,69.035004 C138.714005,88.826996 132.907013,110.242004 132.907013,133.270996 C132.907013,168.487 145.424011,198.600006 170.451004,223.632996 S225.60199,261.177002 260.812988,261.177002 C296.027008,261.177002 326.141998,248.658997 351.174988,223.632996 S388.719971,168.487 388.719971,133.270996 C388.720001,110.242004 382.911987,88.824005 371.300995,69.035004 C414.885986,91.300003 451.146973,124.900024 480.077026,169.817993 C454.766968,208.839996 423.031006,239.912994 384.867004,263.040009  z " id="path9" visibility="hidden" macsvgid="63EC4BD3-ECF1-43A8-AA17-FD94D131BDA5-48030-0000FD8B79DA3772" fill="crimson"></path><path stroke="#000000" transform="" id="path8" stroke-width="3px" d="M5,169 C4,205 78,268.5 104,285.5 C130,302.5 180,333 267.5,333 C355,333 406,296 433,274.5 C460,253 516.5,193 517,170.5 C517.5,148 454.5,75 420,54 C385.5,33 341,4.5 262.5,5 C184,5.5 118,43 94,61 C70,79 6,133 5,169 " fill="black" macsvgid="20185709-2BC4-40FD-95CD-FF1D8C780BA3-48030-0000FD95BF97E62A" visibility="visible"></path><path stroke="#000000" id="path10" stroke-width="3px" d="M149.5,69.5 C149.5,69.5 103,97 85,116 C67,135 41,169.5 41,169.5 C41,169.5 84,228.5 110.5,246.5 C137,264.5 173,295.5 263.5,296.5 C354,297.5 395.5,257.5 420,239 C444.5,220.5 480.5,171 480.5,171 C480.5,171 452.5,131.5 433,112 C413.5,92.5 372.5,70 372.5,70 C372.5,70 388.5,104.5 388,145 C387.5,185.5 341,261.5 262.5,260.5 C184,259.5 134,189.5 132.5,143.5 C131,97.5 150,69.5 150,69.5 " fill="white" transform="" macsvgid="4D497227-93AA-467B-966E-BE5C9893E0D6-48030-0000FDE4C3992A2A"></path><path stroke="#000000" visibility="visible" id="path12" stroke-width="3px" d="M258,47 A11,11 0 0 1 259,74 A55,55 0 0 0 202,134 A11,11 0 0 1 173,130 A85,85 0 0 1 258,47 " fill="white" macsvgid="9808AF7E-902F-4F9C-9CDB-6346DF242C81-48030-0000FD8B79DAABAA" transform=""></path></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform3 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix4 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, ctmMatrix4);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <path d="M508.917969,147.117004 C482.266968,103.529999 446.432983,68.507996 401.42099,42.052002 C356.406006,15.595001 308.871979,2.365005 258.812988,2.365005 C208.753998,2.365005 161.217987,15.589996 116.202988,42.052002 C71.186996,68.507996 35.354996,103.529999 8.708,147.117004 C4.903,153.778015 3,160.345001 3,166.817993 C3,173.290985 4.903,179.858002 8.708,186.516998 C35.354996,230.105988 71.186996,265.130981 116.203003,291.580994 C161.218002,318.040985 208.753998,331.260986 258.812988,331.260986 C308.873016,331.260986 356.407013,318.084991 401.421021,291.724976 C446.433014,265.364014 482.27301,230.292999 508.91803,186.516998 C512.723999,179.858002 514.625977,173.294006 514.625977,166.817993 C514.625977,160.345001 512.723999,153.778015 508.917969,147.117004  z M197.567993,69.029999 C214.60199,51.996002 235.014984,43.475998 258.809998,43.475998 C262.61499,43.475998 265.852997,44.811996 268.518982,47.474991 C271.180969,50.138992 272.518982,53.375992 272.518982,57.181992 C272.518982,60.990997 271.180969,64.225998 268.524994,66.885986 C265.863007,69.553009 262.622986,70.884995 258.816986,70.884995 C242.448975,70.884995 228.454987,76.692993 216.845978,88.300995 C205.232971,99.916 199.429993,113.903992 199.429993,130.272003 C199.429993,134.083008 198.093994,137.31601 195.431,139.981995 C192.763992,142.649994 189.529999,143.980988 185.723999,143.980988 C181.914993,143.981018 178.679993,142.647003 176.013992,139.981995 C173.346985,137.315979 172.014999,134.078979 172.014999,130.271973 C172.014999,106.481995 180.535004,86.065002 197.567993,69.029999  z M382.867004,260.040009 C344.703003,283.160004 303.352997,294.72702 258.812988,294.72702 C214.273987,294.72702 172.924011,283.167023 134.761993,260.040009 S64.860992,205.839996 39.546997,166.817993 C68.478004,121.897003 104.737,88.300018 148.324005,66.035004 C136.714005,85.826996 130.907013,107.242004 130.907013,130.270996 C130.907013,165.487 143.424011,195.600006 168.451004,220.632996 S223.60199,258.177002 258.812988,258.177002 C294.027008,258.177002 324.141998,245.658997 349.174988,220.632996 S386.719971,165.487 386.719971,130.270996 C386.720001,107.242004 380.911987,85.824005 369.300995,66.035004 C412.885986,88.300003 449.147003,121.900024 478.077026,166.817993 C452.766998,205.839996 421.031006,236.912994 382.867004,260.040009  z " id="prototype_to_delete" visibility="hidden" macsvgid="BB28CE0F-CDDD-400D-B0C7-820EB2536201-48030-0000FD8B79DA1667"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform5 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix6 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, ctmMatrix6);
	CGMutablePathRef path7 = CGPathCreateMutable();
	CGPathMoveToPoint(path7, NULL, 508.917969, 147.117004);
	CGPathAddCurveToPoint(path7, NULL, 482.266968, 103.529999, 446.432983, 68.507996, 401.42099, 42.052002);
	CGPathAddCurveToPoint(path7, NULL, 356.406006, 15.595001, 308.871979, 2.365005, 258.812988, 2.365005);
	CGPathAddCurveToPoint(path7, NULL, 208.753998, 2.365005, 161.217987, 15.589996, 116.202988, 42.052002);
	CGPathAddCurveToPoint(path7, NULL, 71.186996, 68.507996, 35.354996, 103.529999, 8.708, 147.117004);
	CGPathAddCurveToPoint(path7, NULL, 4.903, 153.778015, 3, 160.345001, 3, 166.817993);
	CGPathAddCurveToPoint(path7, NULL, 3, 173.290985, 4.903, 179.858002, 8.708, 186.516998);
	CGPathAddCurveToPoint(path7, NULL, 35.354996, 230.105988, 71.186996, 265.130981, 116.203003, 291.580994);
	CGPathAddCurveToPoint(path7, NULL, 161.218002, 318.040985, 208.753998, 331.260986, 258.812988, 331.260986);
	CGPathAddCurveToPoint(path7, NULL, 308.873016, 331.260986, 356.407013, 318.084991, 401.421021, 291.724976);
	CGPathAddCurveToPoint(path7, NULL, 446.433014, 265.364014, 482.27301, 230.292999, 508.91803, 186.516998);
	CGPathAddCurveToPoint(path7, NULL, 512.723999, 179.858002, 514.625977, 173.294006, 514.625977, 166.817993);
	CGPathAddCurveToPoint(path7, NULL, 514.625977, 160.345001, 512.723999, 153.778015, 508.917969, 147.117004);
	CGPathAddLineToPoint(path7, NULL, 508.917969, 147.117004);
	CGPathMoveToPoint(path7, NULL, 197.567993, 69.029999);
	CGPathAddCurveToPoint(path7, NULL, 214.60199, 51.996002, 235.014984, 43.475998, 258.809998, 43.475998);
	CGPathAddCurveToPoint(path7, NULL, 262.61499, 43.475998, 265.852997, 44.811996, 268.518982, 47.474991);
	CGPathAddCurveToPoint(path7, NULL, 271.180969, 50.138992, 272.518982, 53.375992, 272.518982, 57.181992);
	CGPathAddCurveToPoint(path7, NULL, 272.518982, 60.990997, 271.180969, 64.225998, 268.524994, 66.885986);
	CGPathAddCurveToPoint(path7, NULL, 265.863007, 69.553009, 262.622986, 70.884995, 258.816986, 70.884995);
	CGPathAddCurveToPoint(path7, NULL, 242.448975, 70.884995, 228.454987, 76.692993, 216.845978, 88.300995);
	CGPathAddCurveToPoint(path7, NULL, 205.232971, 99.916, 199.429993, 113.903992, 199.429993, 130.272003);
	CGPathAddCurveToPoint(path7, NULL, 199.429993, 134.083008, 198.093994, 137.31601, 195.431, 139.981995);
	CGPathAddCurveToPoint(path7, NULL, 192.763992, 142.649994, 189.529999, 143.980988, 185.723999, 143.980988);
	CGPathAddCurveToPoint(path7, NULL, 181.914993, 143.981018, 178.679993, 142.647003, 176.013992, 139.981995);
	CGPathAddCurveToPoint(path7, NULL, 173.346985, 137.315979, 172.014999, 134.078979, 172.014999, 130.271973);
	CGPathAddCurveToPoint(path7, NULL, 172.014999, 106.481995, 180.535004, 86.065002, 197.567993, 69.029999);
	CGPathAddLineToPoint(path7, NULL, 508.917969, 147.117004);
	CGPathMoveToPoint(path7, NULL, 382.867004, 260.040009);
	CGPathAddCurveToPoint(path7, NULL, 344.703003, 283.160004, 303.352997, 294.72702, 258.812988, 294.72702);
	CGPathAddCurveToPoint(path7, NULL, 214.273987, 294.72702, 172.924011, 283.167023, 134.761993, 260.040009);
	CGPathAddCurveToPoint(path7, NULL, -25.313995, 101.957001, 64.860992, 205.839996, 39.546997, 166.817993);
	CGPathAddCurveToPoint(path7, NULL, 68.478004, 121.897003, 104.737, 88.300018, 148.324005, 66.035004);
	CGPathAddCurveToPoint(path7, NULL, 136.714005, 85.826996, 130.907013, 107.242004, 130.907013, 130.270996);
	CGPathAddCurveToPoint(path7, NULL, 130.907013, 165.487, 143.424011, 195.600006, 168.451004, 220.632996);
	CGPathAddCurveToPoint(path7, NULL, 35.210999, 34.575012, 223.60199, 258.177002, 258.812988, 258.177002);
	CGPathAddCurveToPoint(path7, NULL, 294.027008, 258.177002, 324.141998, 245.658997, 349.174988, 220.632996);
	CGPathAddCurveToPoint(path7, NULL, 0.000000, -256.448975, 386.719971, 165.487, 386.719971, 130.270996);
	CGPathAddCurveToPoint(path7, NULL, 386.720001, 107.242004, 380.911987, 85.824005, 369.300995, 66.035004);
	CGPathAddCurveToPoint(path7, NULL, 412.885986, 88.300003, 449.147003, 121.900024, 478.077026, 166.817993);
	CGPathAddCurveToPoint(path7, NULL, 452.766998, 205.839996, 421.031006, 236.912994, 382.867004, 260.040009);
	CGPathAddLineToPoint(path7, NULL, 508.917969, 147.117004);
	CGFloat strokeWidth8 = 1;
	CGRect pathBoundingBox9 = CGPathGetBoundingBox(path7);
	pathBoundingBox9 = NSInsetRect(pathBoundingBox9, -strokeWidth8, -strokeWidth8);
	CGFloat scaledStrokeWidth10 = 1 * viewScale;
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
		NSRect boundsRect14 = cellFrame;
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

	// SVG element: <path d="M510.917969,150.117004 C484.266968,106.529999 448.432983,71.507996 403.42099,45.052002 C358.406006,18.595001 310.871979,5.365005 260.812988,5.365005 C210.753998,5.365005 163.217987,18.589996 118.202988,45.052002 C73.186996,71.507996 37.354996,106.529999 10.708,150.117004 C6.903,156.778015 5,163.345001 5,169.817993 C5,176.290985 6.903,182.858002 10.708,189.516998 C37.354996,233.105988 73.186996,268.130981 118.203003,294.580994 C163.218002,321.040985 210.753998,334.260986 260.812988,334.260986 C310.873016,334.260986 358.407013,321.084991 403.421021,294.724976 C448.432983,268.364014 484.27301,233.292999 510.91803,189.516998 C514.723999,182.858002 516.625977,176.294006 516.625977,169.817993 C516.625977,163.345001 514.723999,156.778015 510.917969,150.117004  z M199.567993,72.029999 C216.60199,54.996002 237.014984,46.475998 260.809998,46.475998 C264.61499,46.475998 267.852997,47.811996 270.518982,50.474991 C273.180969,53.138992 274.518982,56.375992 274.518982,60.181992 C274.518982,63.990997 273.180969,67.225998 270.524994,69.885986 C267.863007,72.553009 264.622986,73.884995 260.816986,73.884995 C244.448975,73.884995 230.454987,79.692993 218.845978,91.300995 C207.232971,102.916 201.429993,116.903992 201.429993,133.272003 C201.429993,137.083008 200.093994,140.31601 197.431,142.981995 C194.763977,145.649994 191.529999,146.980988 187.723999,146.980988 C183.914993,146.981018 180.679993,145.647003 178.013992,142.981995 C175.346985,140.315979 174.014999,137.078979 174.014999,133.271973 C174.014999,109.481995 182.535004,89.065002 199.567993,72.029999  z M384.867004,263.040009 C346.703003,286.160004 305.352997,297.72702 260.812988,297.72702 C216.273987,297.72702 174.924011,286.167023 136.761993,263.040009 S66.860992,208.839996 41.546997,169.817993 C70.477997,124.897003 106.737,91.300018 150.324005,69.035004 C138.714005,88.826996 132.907013,110.242004 132.907013,133.270996 C132.907013,168.487 145.424011,198.600006 170.451004,223.632996 S225.60199,261.177002 260.812988,261.177002 C296.027008,261.177002 326.141998,248.658997 351.174988,223.632996 S388.719971,168.487 388.719971,133.270996 C388.720001,110.242004 382.911987,88.824005 371.300995,69.035004 C414.885986,91.300003 451.146973,124.900024 480.077026,169.817993 C454.766968,208.839996 423.031006,239.912994 384.867004,263.040009  z " id="path9" visibility="hidden" macsvgid="63EC4BD3-ECF1-43A8-AA17-FD94D131BDA5-48030-0000FD8B79DA3772" fill="crimson"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform25 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix26 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform25 = CGAffineTransformConcat(currentTransform25, ctmMatrix26);
	CGMutablePathRef path27 = CGPathCreateMutable();
	CGPathMoveToPoint(path27, NULL, 510.917969, 150.117004);
	CGPathAddCurveToPoint(path27, NULL, 484.266968, 106.529999, 448.432983, 71.507996, 403.42099, 45.052002);
	CGPathAddCurveToPoint(path27, NULL, 358.406006, 18.595001, 310.871979, 5.365005, 260.812988, 5.365005);
	CGPathAddCurveToPoint(path27, NULL, 210.753998, 5.365005, 163.217987, 18.589996, 118.202988, 45.052002);
	CGPathAddCurveToPoint(path27, NULL, 73.186996, 71.507996, 37.354996, 106.529999, 10.708, 150.117004);
	CGPathAddCurveToPoint(path27, NULL, 6.903, 156.778015, 5, 163.345001, 5, 169.817993);
	CGPathAddCurveToPoint(path27, NULL, 5, 176.290985, 6.903, 182.858002, 10.708, 189.516998);
	CGPathAddCurveToPoint(path27, NULL, 37.354996, 233.105988, 73.186996, 268.130981, 118.203003, 294.580994);
	CGPathAddCurveToPoint(path27, NULL, 163.218002, 321.040985, 210.753998, 334.260986, 260.812988, 334.260986);
	CGPathAddCurveToPoint(path27, NULL, 310.873016, 334.260986, 358.407013, 321.084991, 403.421021, 294.724976);
	CGPathAddCurveToPoint(path27, NULL, 448.432983, 268.364014, 484.27301, 233.292999, 510.91803, 189.516998);
	CGPathAddCurveToPoint(path27, NULL, 514.723999, 182.858002, 516.625977, 176.294006, 516.625977, 169.817993);
	CGPathAddCurveToPoint(path27, NULL, 516.625977, 163.345001, 514.723999, 156.778015, 510.917969, 150.117004);
	CGPathAddLineToPoint(path27, NULL, 510.917969, 150.117004);
	CGPathMoveToPoint(path27, NULL, 199.567993, 72.029999);
	CGPathAddCurveToPoint(path27, NULL, 216.60199, 54.996002, 237.014984, 46.475998, 260.809998, 46.475998);
	CGPathAddCurveToPoint(path27, NULL, 264.61499, 46.475998, 267.852997, 47.811996, 270.518982, 50.474991);
	CGPathAddCurveToPoint(path27, NULL, 273.180969, 53.138992, 274.518982, 56.375992, 274.518982, 60.181992);
	CGPathAddCurveToPoint(path27, NULL, 274.518982, 63.990997, 273.180969, 67.225998, 270.524994, 69.885986);
	CGPathAddCurveToPoint(path27, NULL, 267.863007, 72.553009, 264.622986, 73.884995, 260.816986, 73.884995);
	CGPathAddCurveToPoint(path27, NULL, 244.448975, 73.884995, 230.454987, 79.692993, 218.845978, 91.300995);
	CGPathAddCurveToPoint(path27, NULL, 207.232971, 102.916, 201.429993, 116.903992, 201.429993, 133.272003);
	CGPathAddCurveToPoint(path27, NULL, 201.429993, 137.083008, 200.093994, 140.31601, 197.431, 142.981995);
	CGPathAddCurveToPoint(path27, NULL, 194.763977, 145.649994, 191.529999, 146.980988, 187.723999, 146.980988);
	CGPathAddCurveToPoint(path27, NULL, 183.914993, 146.981018, 180.679993, 145.647003, 178.013992, 142.981995);
	CGPathAddCurveToPoint(path27, NULL, 175.346985, 140.315979, 174.014999, 137.078979, 174.014999, 133.271973);
	CGPathAddCurveToPoint(path27, NULL, 174.014999, 109.481995, 182.535004, 89.065002, 199.567993, 72.029999);
	CGPathAddLineToPoint(path27, NULL, 510.917969, 150.117004);
	CGPathMoveToPoint(path27, NULL, 384.867004, 263.040009);
	CGPathAddCurveToPoint(path27, NULL, 346.703003, 286.160004, 305.352997, 297.72702, 260.812988, 297.72702);
	CGPathAddCurveToPoint(path27, NULL, 216.273987, 297.72702, 174.924011, 286.167023, 136.761993, 263.040009);
	CGPathAddCurveToPoint(path27, NULL, -25.313995, 102.957001, 66.860992, 208.839996, 41.546997, 169.817993);
	CGPathAddCurveToPoint(path27, NULL, 70.477997, 124.897003, 106.737, 91.300018, 150.324005, 69.035004);
	CGPathAddCurveToPoint(path27, NULL, 138.714005, 88.826996, 132.907013, 110.242004, 132.907013, 133.270996);
	CGPathAddCurveToPoint(path27, NULL, 132.907013, 168.487, 145.424011, 198.600006, 170.451004, 223.632996);
	CGPathAddCurveToPoint(path27, NULL, 35.210999, 35.575012, 225.60199, 261.177002, 260.812988, 261.177002);
	CGPathAddCurveToPoint(path27, NULL, 296.027008, 261.177002, 326.141998, 248.658997, 351.174988, 223.632996);
	CGPathAddCurveToPoint(path27, NULL, 0.000000, -255.448975, 388.719971, 168.487, 388.719971, 133.270996);
	CGPathAddCurveToPoint(path27, NULL, 388.720001, 110.242004, 382.911987, 88.824005, 371.300995, 69.035004);
	CGPathAddCurveToPoint(path27, NULL, 414.885986, 91.300003, 451.146973, 124.900024, 480.077026, 169.817993);
	CGPathAddCurveToPoint(path27, NULL, 454.766968, 208.839996, 423.031006, 239.912994, 384.867004, 263.040009);
	CGPathAddLineToPoint(path27, NULL, 510.917969, 150.117004);
	CGFloat strokeWidth28 = 1;
	CGRect pathBoundingBox29 = CGPathGetBoundingBox(path27);
	pathBoundingBox29 = NSInsetRect(pathBoundingBox29, -strokeWidth28, -strokeWidth28);
	CGFloat scaledStrokeWidth30 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth30);
	NSColor * strokeColor31 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor31.CGColor);
	NSColor * fillColor32 = [NSColor colorWithRed:0.862745 green:0.078431 blue:0.235294 alpha:1];
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

	//--------------------------------------------------------

	// SVG element: <path stroke="#000000" transform="" id="path8" stroke-width="3px" d="M5,169 C4,205 78,268.5 104,285.5 C130,302.5 180,333 267.5,333 C355,333 406,296 433,274.5 C460,253 516.5,193 517,170.5 C517.5,148 454.5,75 420,54 C385.5,33 341,4.5 262.5,5 C184,5.5 118,43 94,61 C70,79 6,133 5,169 " fill="black" macsvgid="20185709-2BC4-40FD-95CD-FF1D8C780BA3-48030-0000FD95BF97E62A" visibility="visible"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform45 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix46 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform45 = CGAffineTransformConcat(currentTransform45, ctmMatrix46);
	CGMutablePathRef path47 = CGPathCreateMutable();
	CGPathMoveToPoint(path47, NULL, 5, 169);
	CGPathAddCurveToPoint(path47, NULL, 4, 205, 78, 268.5, 104, 285.5);
	CGPathAddCurveToPoint(path47, NULL, 130, 302.5, 180, 333, 267.5, 333);
	CGPathAddCurveToPoint(path47, NULL, 355, 333, 406, 296, 433, 274.5);
	CGPathAddCurveToPoint(path47, NULL, 460, 253, 516.5, 193, 517, 170.5);
	CGPathAddCurveToPoint(path47, NULL, 517.5, 148, 454.5, 75, 420, 54);
	CGPathAddCurveToPoint(path47, NULL, 385.5, 33, 341, 4.5, 262.5, 5);
	CGPathAddCurveToPoint(path47, NULL, 184, 5.5, 118, 43, 94, 61);
	CGPathAddCurveToPoint(path47, NULL, 70, 79, 6, 133, 5, 169);
	CGFloat strokeWidth48 = 3;
	CGRect pathBoundingBox49 = CGPathGetBoundingBox(path47);
	pathBoundingBox49 = NSInsetRect(pathBoundingBox49, -strokeWidth48, -strokeWidth48);
	CGFloat scaledStrokeWidth50 = 3 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth50);
	NSColor * strokeColor51 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor51.CGColor);
	NSColor * fillColor52 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor52.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip53 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform45 = CGAffineTransformConcat(currentTransform45, flip53);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect54 = cellFrame;
		CGFloat boundsMidX55 = NSMidX(boundsRect54) * (1.0f / viewScale);
		CGFloat boundsMidY56 = NSMidY(boundsRect54) * (1.0f / viewScale);
		CGFloat imageMidX57 = NSMidX(webBBox);
		CGFloat imageMidY58 = NSMidY(webBBox);
		CGFloat xTranslation59 = boundsMidX55 - imageMidX57;
		CGFloat yTranslation60 = boundsMidY56 - imageMidY58;
		CGAffineTransform centerTranslation61 = CGAffineTransformMakeTranslation(xTranslation59, yTranslation60);
		currentTransform45 = CGAffineTransformConcat(currentTransform45, centerTranslation61);
	}
	CGAffineTransform translate62 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform45 = CGAffineTransformConcat(currentTransform45, translate62);
	CGAffineTransform scale63 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform45 = CGAffineTransformConcat(currentTransform45, scale63);
	CGPathRef finalPath64 = CGPathCreateCopyByTransformingPath(path47, &currentTransform45);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath64);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath64);
	CGPathRelease(path47);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <path stroke="#000000" id="path10" stroke-width="3px" d="M149.5,69.5 C149.5,69.5 103,97 85,116 C67,135 41,169.5 41,169.5 C41,169.5 84,228.5 110.5,246.5 C137,264.5 173,295.5 263.5,296.5 C354,297.5 395.5,257.5 420,239 C444.5,220.5 480.5,171 480.5,171 C480.5,171 452.5,131.5 433,112 C413.5,92.5 372.5,70 372.5,70 C372.5,70 388.5,104.5 388,145 C387.5,185.5 341,261.5 262.5,260.5 C184,259.5 134,189.5 132.5,143.5 C131,97.5 150,69.5 150,69.5 " fill="white" transform="" macsvgid="4D497227-93AA-467B-966E-BE5C9893E0D6-48030-0000FDE4C3992A2A"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform65 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix66 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform65 = CGAffineTransformConcat(currentTransform65, ctmMatrix66);
	CGMutablePathRef path67 = CGPathCreateMutable();
	CGPathMoveToPoint(path67, NULL, 149.5, 69.5);
	CGPathAddCurveToPoint(path67, NULL, 149.5, 69.5, 103, 97, 85, 116);
	CGPathAddCurveToPoint(path67, NULL, 67, 135, 41, 169.5, 41, 169.5);
	CGPathAddCurveToPoint(path67, NULL, 41, 169.5, 84, 228.5, 110.5, 246.5);
	CGPathAddCurveToPoint(path67, NULL, 137, 264.5, 173, 295.5, 263.5, 296.5);
	CGPathAddCurveToPoint(path67, NULL, 354, 297.5, 395.5, 257.5, 420, 239);
	CGPathAddCurveToPoint(path67, NULL, 444.5, 220.5, 480.5, 171, 480.5, 171);
	CGPathAddCurveToPoint(path67, NULL, 480.5, 171, 452.5, 131.5, 433, 112);
	CGPathAddCurveToPoint(path67, NULL, 413.5, 92.5, 372.5, 70, 372.5, 70);
	CGPathAddCurveToPoint(path67, NULL, 372.5, 70, 388.5, 104.5, 388, 145);
	CGPathAddCurveToPoint(path67, NULL, 387.5, 185.5, 341, 261.5, 262.5, 260.5);
	CGPathAddCurveToPoint(path67, NULL, 184, 259.5, 134, 189.5, 132.5, 143.5);
	CGPathAddCurveToPoint(path67, NULL, 131, 97.5, 150, 69.5, 150, 69.5);
	CGFloat strokeWidth68 = 3;
	CGRect pathBoundingBox69 = CGPathGetBoundingBox(path67);
	pathBoundingBox69 = NSInsetRect(pathBoundingBox69, -strokeWidth68, -strokeWidth68);
	CGFloat scaledStrokeWidth70 = 3 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth70);
	NSColor * strokeColor71 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor71.CGColor);
	NSColor * fillColor72 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor72.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip73 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform65 = CGAffineTransformConcat(currentTransform65, flip73);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect74 = cellFrame;
		CGFloat boundsMidX75 = NSMidX(boundsRect74) * (1.0f / viewScale);
		CGFloat boundsMidY76 = NSMidY(boundsRect74) * (1.0f / viewScale);
		CGFloat imageMidX77 = NSMidX(webBBox);
		CGFloat imageMidY78 = NSMidY(webBBox);
		CGFloat xTranslation79 = boundsMidX75 - imageMidX77;
		CGFloat yTranslation80 = boundsMidY76 - imageMidY78;
		CGAffineTransform centerTranslation81 = CGAffineTransformMakeTranslation(xTranslation79, yTranslation80);
		currentTransform65 = CGAffineTransformConcat(currentTransform65, centerTranslation81);
	}
	CGAffineTransform translate82 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform65 = CGAffineTransformConcat(currentTransform65, translate82);
	CGAffineTransform scale83 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform65 = CGAffineTransformConcat(currentTransform65, scale83);
	CGPathRef finalPath84 = CGPathCreateCopyByTransformingPath(path67, &currentTransform65);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath84);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath84);
	CGPathRelease(path67);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <path stroke="#000000" visibility="visible" id="path12" stroke-width="3px" d="M258,47 A11,11 0 0 1 259,74 A55,55 0 0 0 202,134 A11,11 0 0 1 173,130 A85,85 0 0 1 258,47 " fill="white" macsvgid="9808AF7E-902F-4F9C-9CDB-6346DF242C81-48030-0000FD8B79DAABAA" transform=""></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform85 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix86 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform85 = CGAffineTransformConcat(currentTransform85, ctmMatrix86);
	CGMutablePathRef path87 = CGPathCreateMutable();
	CGPathMoveToPoint(path87, NULL, 258, 47);
	CGFloat xAxisRotationRadians88 = 0.000000;
	CGAffineTransform transform89 = CGAffineTransformIdentity;
	transform89 = CGAffineTransformTranslate(transform89, 258.487528, 60.500462);
	transform89 = CGAffineTransformRotate(transform89, xAxisRotationRadians88);
	transform89 = CGAffineTransformScale(transform89, 1.000000, 1.000000);
	CGPathAddArc(path87, &transform89, 0.0, 0.0, 13.509262, -1.606893, 1.532841, 0);
	CGFloat xAxisRotationRadians90 = 0.000000;
	CGAffineTransform transform91 = CGAffineTransformIdentity;
	transform91 = CGAffineTransformTranslate(transform91, 256.768101, 128.954696);
	transform91 = CGAffineTransformRotate(transform91, xAxisRotationRadians90);
	transform91 = CGAffineTransformScale(transform91, 1.000000, 1.000000);
	CGPathAddArc(path87, &transform91, 0.0, 0.0, 55.000000, -1.530205, -3.233455, 1);
	CGFloat xAxisRotationRadians92 = 0.000000;
	CGAffineTransform transform93 = CGAffineTransformIdentity;
	transform93 = CGAffineTransformTranslate(transform93, 187.501904, 131.986196);
	transform93 = CGAffineTransformRotate(transform93, xAxisRotationRadians92);
	transform93 = CGAffineTransformScale(transform93, 1.000000, 1.000000);
	CGPathAddArc(path87, &transform93, 0.0, 0.0, 14.637288, 0.138018, 3.277720, 0);
	CGFloat xAxisRotationRadians94 = 0.000000;
	CGAffineTransform transform95 = CGAffineTransformIdentity;
	transform95 = CGAffineTransformTranslate(transform95, 257.976467, 131.999997);
	transform95 = CGAffineTransformRotate(transform95, xAxisRotationRadians94);
	transform95 = CGAffineTransformScale(transform95, 1.000000, 1.000000);
	CGPathAddArc(path87, &transform95, 0.0, 0.0, 85.000000, -3.118061, -1.570519, 0);
	CGFloat strokeWidth96 = 3;
	CGRect pathBoundingBox97 = CGPathGetBoundingBox(path87);
	pathBoundingBox97 = NSInsetRect(pathBoundingBox97, -strokeWidth96, -strokeWidth96);
	CGFloat scaledStrokeWidth98 = 3 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth98);
	NSColor * strokeColor99 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor99.CGColor);
	NSColor * fillColor100 = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor100.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip101 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform85 = CGAffineTransformConcat(currentTransform85, flip101);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect102 = cellFrame;
		CGFloat boundsMidX103 = NSMidX(boundsRect102) * (1.0f / viewScale);
		CGFloat boundsMidY104 = NSMidY(boundsRect102) * (1.0f / viewScale);
		CGFloat imageMidX105 = NSMidX(webBBox);
		CGFloat imageMidY106 = NSMidY(webBBox);
		CGFloat xTranslation107 = boundsMidX103 - imageMidX105;
		CGFloat yTranslation108 = boundsMidY104 - imageMidY106;
		CGAffineTransform centerTranslation109 = CGAffineTransformMakeTranslation(xTranslation107, yTranslation108);
		currentTransform85 = CGAffineTransformConcat(currentTransform85, centerTranslation109);
	}
	CGAffineTransform translate110 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform85 = CGAffineTransformConcat(currentTransform85, translate110);
	CGAffineTransform scale111 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform85 = CGAffineTransformConcat(currentTransform85, scale111);
	CGPathRef finalPath112 = CGPathCreateCopyByTransformingPath(path87, &currentTransform85);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath112);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGPathRelease(finalPath112);
	CGPathRelease(path87);
	CGContextRestoreGState(context);
}








- (void)drawPadlockIcon:(NSRect)cellFrame {
	//NSBezierPath * rectPath1 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor2 = [NSColor orangeColor];
	//[rectColor2 set];
	//[rectPath1 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	//CGContextRef context = (CGContextRef)nsctx.graphicsPort;
    CGContextRef context = (CGContextRef)nsctx.CGContext;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(-0.562500, -0.562500, 20.250000, 26.187500);
	CGFloat hViewScale = cellFrame.size.width / (webBBox.size.width);
	CGFloat vViewScale = cellFrame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 1.0f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="padlock_icon" visibility="visible" macsvgid="A9113079-5DF8-41A1-A7DC-28C354817EDB-48429-0000FF29E5C35DEC"><path stroke="dimgray" macsvgid="A3D4755B-6C1B-4580-9206-1F9CE021C553-48429-0000FF29E5C3826E" id="path4" stroke-width="0.25px" d="M5.5625,7.9375 L2.25,9.75 L16.8125,9.8125 L13.3125,7.9375 L5.5625,7.9375 " fill="url(#linearGradient2)" transform="" visibility="visible"></path><path stroke="dimgray" id="path3" stroke-width="1px" d="M16.6875,10.1875 L16.5,4.6875 L12.5,0.625 L6.0625,0.5625 L2.1875,4.5625 L2.1875,10.25 L6.25,10.25 L6.25,4.5 L12.25,4.5625 L12.25,10.3125 L16.6875,10.3125 " fill="url(#linearGradient2)" transform="" macsvgid="978CB6E0-EC11-4D6B-A6B2-FBC8D9AAF3DC-48429-0000FF29E5C3AABA"></path><path stroke="dimgray" id="path2" stroke-width="1px" d="M0.5625,11.875 L0.625,23.3125 L1.875,24.5 L17.375,24.5 L18.5625,23.25 L18.5,11.625 L17,10.25 L1.9375,10.1875 L0.5625,11.875 " fill="url(#linearGradient2)" transform="" macsvgid="C3C3D07B-4164-44CA-B7B6-7AF7DBB5450C-48429-0000FF29E5C3D4C6"></path><path stroke="dimgray" id="path5" stroke-width="2px" d="M4.75,14.0625 L16.375,14.0625 " fill="none" transform="" macsvgid="4CA1C509-659C-4B45-B3C8-6127BA571D4A-48429-0000FF29E5C3FD14"></path><path stroke="dimgray" stroke-width="2px" id="path6" d="M4.6875,17.6875 L16.3125,17.6875 " fill="none" transform="" macsvgid="00077F16-DE37-480D-8BB3-79329EE17D36-48429-0000FF29E5C4253A"></path><path stroke="dimgray" stroke-width="2px" id="path7" d="M4.6875,21.125 L16.3125,21.125 " fill="none" transform="" macsvgid="57F96D38-5D7A-4957-9DE4-5EE6C3AA00C2-48429-0000FF29E5C44D95"></path></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform3 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix4 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, ctmMatrix4);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <path stroke="dimgray" macsvgid="A3D4755B-6C1B-4580-9206-1F9CE021C553-48429-0000FF29E5C3826E" id="path4" stroke-width="0.25px" d="M5.5625,7.9375 L2.25,9.75 L16.8125,9.8125 L13.3125,7.9375 L5.5625,7.9375 " fill="url(#linearGradient2)" transform="" visibility="visible"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform5 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix6 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, ctmMatrix6);
	CGMutablePathRef path7 = CGPathCreateMutable();
	CGPathMoveToPoint(path7, NULL, 5.5625, 7.9375);
	CGPathAddLineToPoint(path7, NULL, 2.25, 9.75);
	CGPathAddLineToPoint(path7, NULL, 16.8125, 9.8125);
	CGPathAddLineToPoint(path7, NULL, 13.3125, 7.9375);
	CGPathAddLineToPoint(path7, NULL, 5.5625, 7.9375);
	CGFloat strokeWidth8 = 0.25;
	CGRect pathBoundingBox9 = CGPathGetBoundingBox(path7);
	pathBoundingBox9 = NSInsetRect(pathBoundingBox9, -strokeWidth8, -strokeWidth8);
	CGFloat scaledStrokeWidth10 = 0.25 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth10);
	NSColor * strokeColor11 = [NSColor colorWithRed:0.411765 green:0.411765 blue:0.411765 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor11.CGColor);
	NSColor * fillColor12 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor12.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip13 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform5 = CGAffineTransformConcat(currentTransform5, flip13);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect14 = cellFrame;
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
	CGColorSpaceRef linearGradientColorSpace25 = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGFloat linearGradientColorArray27[4] = {1, 1, 1, 1.0};
	CGColorRef linearGradientColor28 = CGColorCreate(linearGradientColorSpace25, linearGradientColorArray27);
	CGFloat linearGradientColorArray29[4] = {0.411765, 0.411765, 0.411765, 1.0};
	CGColorRef linearGradientColor30 = CGColorCreate(linearGradientColorSpace25, linearGradientColorArray29);
	CGFloat locationsArray31[] = {0.000000, 1.000000};
	NSArray * colorsArray32 = @[(__bridge id) linearGradientColor28, (__bridge id) linearGradientColor30];
	CGGradientRef linearGradient33 = CGGradientCreateWithColors(linearGradientColorSpace25, (__bridge CFArrayRef) colorsArray32, locationsArray31);
	CGRect pathBounds34 = CGPathGetPathBoundingBox(finalPath24);
	CGPoint linearGradientStartPoint35 = CGPointMake(CGRectGetMidX(pathBounds34), CGRectGetMinY(pathBounds34));
	CGPoint linearGradientEndPoint36 = CGPointMake(CGRectGetMidX(pathBounds34), CGRectGetMaxY(pathBounds34));
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath24);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, linearGradient33, linearGradientStartPoint35, linearGradientEndPoint36, 0);
	CGGradientRelease(linearGradient33);
	CGColorRelease(linearGradientColor28);
	CGColorRelease(linearGradientColor30);
	CGColorSpaceRelease(linearGradientColorSpace25);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath24);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath24);
	CGPathRelease(path7);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <path stroke="dimgray" id="path3" stroke-width="1px" d="M16.6875,10.1875 L16.5,4.6875 L12.5,0.625 L6.0625,0.5625 L2.1875,4.5625 L2.1875,10.25 L6.25,10.25 L6.25,4.5 L12.25,4.5625 L12.25,10.3125 L16.6875,10.3125 " fill="url(#linearGradient2)" transform="" macsvgid="978CB6E0-EC11-4D6B-A6B2-FBC8D9AAF3DC-48429-0000FF29E5C3AABA"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform37 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix38 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform37 = CGAffineTransformConcat(currentTransform37, ctmMatrix38);
	CGMutablePathRef path39 = CGPathCreateMutable();
	CGPathMoveToPoint(path39, NULL, 16.6875, 10.1875);
	CGPathAddLineToPoint(path39, NULL, 16.5, 4.6875);
	CGPathAddLineToPoint(path39, NULL, 12.5, 0.625);
	CGPathAddLineToPoint(path39, NULL, 6.0625, 0.5625);
	CGPathAddLineToPoint(path39, NULL, 2.1875, 4.5625);
	CGPathAddLineToPoint(path39, NULL, 2.1875, 10.25);
	CGPathAddLineToPoint(path39, NULL, 6.25, 10.25);
	CGPathAddLineToPoint(path39, NULL, 6.25, 4.5);
	CGPathAddLineToPoint(path39, NULL, 12.25, 4.5625);
	CGPathAddLineToPoint(path39, NULL, 12.25, 10.3125);
	CGPathAddLineToPoint(path39, NULL, 16.6875, 10.3125);
	CGFloat strokeWidth40 = 1;
	CGRect pathBoundingBox41 = CGPathGetBoundingBox(path39);
	pathBoundingBox41 = NSInsetRect(pathBoundingBox41, -strokeWidth40, -strokeWidth40);
	CGFloat scaledStrokeWidth42 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth42);
	NSColor * strokeColor43 = [NSColor colorWithRed:0.411765 green:0.411765 blue:0.411765 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor43.CGColor);
	NSColor * fillColor44 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor44.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip45 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform37 = CGAffineTransformConcat(currentTransform37, flip45);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect46 = cellFrame;
		CGFloat boundsMidX47 = NSMidX(boundsRect46) * (1.0f / viewScale);
		CGFloat boundsMidY48 = NSMidY(boundsRect46) * (1.0f / viewScale);
		CGFloat imageMidX49 = NSMidX(webBBox);
		CGFloat imageMidY50 = NSMidY(webBBox);
		CGFloat xTranslation51 = boundsMidX47 - imageMidX49;
		CGFloat yTranslation52 = boundsMidY48 - imageMidY50;
		CGAffineTransform centerTranslation53 = CGAffineTransformMakeTranslation(xTranslation51, yTranslation52);
		currentTransform37 = CGAffineTransformConcat(currentTransform37, centerTranslation53);
	}
	CGAffineTransform translate54 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform37 = CGAffineTransformConcat(currentTransform37, translate54);
	CGAffineTransform scale55 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform37 = CGAffineTransformConcat(currentTransform37, scale55);
	CGPathRef finalPath56 = CGPathCreateCopyByTransformingPath(path39, &currentTransform37);
	CGColorSpaceRef linearGradientColorSpace57 = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGFloat linearGradientColorArray59[4] = {1, 1, 1, 1.0};
	CGColorRef linearGradientColor60 = CGColorCreate(linearGradientColorSpace57, linearGradientColorArray59);
	CGFloat linearGradientColorArray61[4] = {0.411765, 0.411765, 0.411765, 1.0};
	CGColorRef linearGradientColor62 = CGColorCreate(linearGradientColorSpace57, linearGradientColorArray61);
	CGFloat locationsArray63[] = {0.000000, 1.000000};
	NSArray * colorsArray64 = @[(__bridge id) linearGradientColor60, (__bridge id) linearGradientColor62];
	CGGradientRef linearGradient65 = CGGradientCreateWithColors(linearGradientColorSpace57, (__bridge CFArrayRef) colorsArray64, locationsArray63);
	CGRect pathBounds66 = CGPathGetPathBoundingBox(finalPath56);
	CGPoint linearGradientStartPoint67 = CGPointMake(CGRectGetMidX(pathBounds66), CGRectGetMinY(pathBounds66));
	CGPoint linearGradientEndPoint68 = CGPointMake(CGRectGetMidX(pathBounds66), CGRectGetMaxY(pathBounds66));
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath56);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, linearGradient65, linearGradientStartPoint67, linearGradientEndPoint68, 0);
	CGGradientRelease(linearGradient65);
	CGColorRelease(linearGradientColor60);
	CGColorRelease(linearGradientColor62);
	CGColorSpaceRelease(linearGradientColorSpace57);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath56);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath56);
	CGPathRelease(path39);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <path stroke="dimgray" id="path2" stroke-width="1px" d="M0.5625,11.875 L0.625,23.3125 L1.875,24.5 L17.375,24.5 L18.5625,23.25 L18.5,11.625 L17,10.25 L1.9375,10.1875 L0.5625,11.875 " fill="url(#linearGradient2)" transform="" macsvgid="C3C3D07B-4164-44CA-B7B6-7AF7DBB5450C-48429-0000FF29E5C3D4C6"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform69 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix70 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform69 = CGAffineTransformConcat(currentTransform69, ctmMatrix70);
	CGMutablePathRef path71 = CGPathCreateMutable();
	CGPathMoveToPoint(path71, NULL, 0.5625, 11.875);
	CGPathAddLineToPoint(path71, NULL, 0.625, 23.3125);
	CGPathAddLineToPoint(path71, NULL, 1.875, 24.5);
	CGPathAddLineToPoint(path71, NULL, 17.375, 24.5);
	CGPathAddLineToPoint(path71, NULL, 18.5625, 23.25);
	CGPathAddLineToPoint(path71, NULL, 18.5, 11.625);
	CGPathAddLineToPoint(path71, NULL, 17, 10.25);
	CGPathAddLineToPoint(path71, NULL, 1.9375, 10.1875);
	CGPathAddLineToPoint(path71, NULL, 0.5625, 11.875);
	CGFloat strokeWidth72 = 1;
	CGRect pathBoundingBox73 = CGPathGetBoundingBox(path71);
	pathBoundingBox73 = NSInsetRect(pathBoundingBox73, -strokeWidth72, -strokeWidth72);
	CGFloat scaledStrokeWidth74 = 1 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth74);
	NSColor * strokeColor75 = [NSColor colorWithRed:0.411765 green:0.411765 blue:0.411765 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor75.CGColor);
	NSColor * fillColor76 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor76.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip77 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform69 = CGAffineTransformConcat(currentTransform69, flip77);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect78 = cellFrame;
		CGFloat boundsMidX79 = NSMidX(boundsRect78) * (1.0f / viewScale);
		CGFloat boundsMidY80 = NSMidY(boundsRect78) * (1.0f / viewScale);
		CGFloat imageMidX81 = NSMidX(webBBox);
		CGFloat imageMidY82 = NSMidY(webBBox);
		CGFloat xTranslation83 = boundsMidX79 - imageMidX81;
		CGFloat yTranslation84 = boundsMidY80 - imageMidY82;
		CGAffineTransform centerTranslation85 = CGAffineTransformMakeTranslation(xTranslation83, yTranslation84);
		currentTransform69 = CGAffineTransformConcat(currentTransform69, centerTranslation85);
	}
	CGAffineTransform translate86 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform69 = CGAffineTransformConcat(currentTransform69, translate86);
	CGAffineTransform scale87 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform69 = CGAffineTransformConcat(currentTransform69, scale87);
	CGPathRef finalPath88 = CGPathCreateCopyByTransformingPath(path71, &currentTransform69);
	CGColorSpaceRef linearGradientColorSpace89 = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGFloat linearGradientColorArray91[4] = {1, 1, 1, 1.0};
	CGColorRef linearGradientColor92 = CGColorCreate(linearGradientColorSpace89, linearGradientColorArray91);
	CGFloat linearGradientColorArray93[4] = {0.411765, 0.411765, 0.411765, 1.0};
	CGColorRef linearGradientColor94 = CGColorCreate(linearGradientColorSpace89, linearGradientColorArray93);
	CGFloat locationsArray95[] = {0.000000, 1.000000};
	NSArray * colorsArray96 = @[(__bridge id) linearGradientColor92, (__bridge id) linearGradientColor94];
	CGGradientRef linearGradient97 = CGGradientCreateWithColors(linearGradientColorSpace89, (__bridge CFArrayRef) colorsArray96, locationsArray95);
	CGRect pathBounds98 = CGPathGetPathBoundingBox(finalPath88);
	CGPoint linearGradientStartPoint99 = CGPointMake(CGRectGetMidX(pathBounds98), CGRectGetMinY(pathBounds98));
	CGPoint linearGradientEndPoint100 = CGPointMake(CGRectGetMidX(pathBounds98), CGRectGetMaxY(pathBounds98));
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath88);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, linearGradient97, linearGradientStartPoint99, linearGradientEndPoint100, 0);
	CGGradientRelease(linearGradient97);
	CGColorRelease(linearGradientColor92);
	CGColorRelease(linearGradientColor94);
	CGColorSpaceRelease(linearGradientColorSpace89);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath88);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath88);
	CGPathRelease(path71);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <path stroke="dimgray" id="path5" stroke-width="2px" d="M4.75,14.0625 L16.375,14.0625 " fill="none" transform="" macsvgid="4CA1C509-659C-4B45-B3C8-6127BA571D4A-48429-0000FF29E5C3FD14"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform101 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix102 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform101 = CGAffineTransformConcat(currentTransform101, ctmMatrix102);
	CGMutablePathRef path103 = CGPathCreateMutable();
	CGPathMoveToPoint(path103, NULL, 4.75, 14.0625);
	CGPathAddLineToPoint(path103, NULL, 16.375, 14.0625);
	CGFloat strokeWidth104 = 2;
	CGRect pathBoundingBox105 = CGPathGetBoundingBox(path103);
	pathBoundingBox105 = NSInsetRect(pathBoundingBox105, -strokeWidth104, -strokeWidth104);
	CGFloat scaledStrokeWidth106 = 2 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth106);
	NSColor * strokeColor107 = [NSColor colorWithRed:0.411765 green:0.411765 blue:0.411765 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor107.CGColor);
	NSColor * fillColor108 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor108.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip109 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform101 = CGAffineTransformConcat(currentTransform101, flip109);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect110 = cellFrame;
		CGFloat boundsMidX111 = NSMidX(boundsRect110) * (1.0f / viewScale);
		CGFloat boundsMidY112 = NSMidY(boundsRect110) * (1.0f / viewScale);
		CGFloat imageMidX113 = NSMidX(webBBox);
		CGFloat imageMidY114 = NSMidY(webBBox);
		CGFloat xTranslation115 = boundsMidX111 - imageMidX113;
		CGFloat yTranslation116 = boundsMidY112 - imageMidY114;
		CGAffineTransform centerTranslation117 = CGAffineTransformMakeTranslation(xTranslation115, yTranslation116);
		currentTransform101 = CGAffineTransformConcat(currentTransform101, centerTranslation117);
	}
	CGAffineTransform translate118 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform101 = CGAffineTransformConcat(currentTransform101, translate118);
	CGAffineTransform scale119 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform101 = CGAffineTransformConcat(currentTransform101, scale119);
	CGPathRef finalPath120 = CGPathCreateCopyByTransformingPath(path103, &currentTransform101);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath120);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath120);
	CGPathRelease(path103);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <path stroke="dimgray" stroke-width="2px" id="path6" d="M4.6875,17.6875 L16.3125,17.6875 " fill="none" transform="" macsvgid="00077F16-DE37-480D-8BB3-79329EE17D36-48429-0000FF29E5C4253A"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform121 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix122 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform121 = CGAffineTransformConcat(currentTransform121, ctmMatrix122);
	CGMutablePathRef path123 = CGPathCreateMutable();
	CGPathMoveToPoint(path123, NULL, 4.6875, 17.6875);
	CGPathAddLineToPoint(path123, NULL, 16.3125, 17.6875);
	CGFloat strokeWidth124 = 2;
	CGRect pathBoundingBox125 = CGPathGetBoundingBox(path123);
	pathBoundingBox125 = NSInsetRect(pathBoundingBox125, -strokeWidth124, -strokeWidth124);
	CGFloat scaledStrokeWidth126 = 2 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth126);
	NSColor * strokeColor127 = [NSColor colorWithRed:0.411765 green:0.411765 blue:0.411765 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor127.CGColor);
	NSColor * fillColor128 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor128.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip129 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform121 = CGAffineTransformConcat(currentTransform121, flip129);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect130 = cellFrame;
		CGFloat boundsMidX131 = NSMidX(boundsRect130) * (1.0f / viewScale);
		CGFloat boundsMidY132 = NSMidY(boundsRect130) * (1.0f / viewScale);
		CGFloat imageMidX133 = NSMidX(webBBox);
		CGFloat imageMidY134 = NSMidY(webBBox);
		CGFloat xTranslation135 = boundsMidX131 - imageMidX133;
		CGFloat yTranslation136 = boundsMidY132 - imageMidY134;
		CGAffineTransform centerTranslation137 = CGAffineTransformMakeTranslation(xTranslation135, yTranslation136);
		currentTransform121 = CGAffineTransformConcat(currentTransform121, centerTranslation137);
	}
	CGAffineTransform translate138 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform121 = CGAffineTransformConcat(currentTransform121, translate138);
	CGAffineTransform scale139 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform121 = CGAffineTransformConcat(currentTransform121, scale139);
	CGPathRef finalPath140 = CGPathCreateCopyByTransformingPath(path123, &currentTransform121);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath140);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath140);
	CGPathRelease(path123);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <path stroke="dimgray" stroke-width="2px" id="path7" d="M4.6875,21.125 L16.3125,21.125 " fill="none" transform="" macsvgid="57F96D38-5D7A-4957-9DE4-5EE6C3AA00C2-48429-0000FF29E5C44D95"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform141 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix142 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform141 = CGAffineTransformConcat(currentTransform141, ctmMatrix142);
	CGMutablePathRef path143 = CGPathCreateMutable();
	CGPathMoveToPoint(path143, NULL, 4.6875, 21.125);
	CGPathAddLineToPoint(path143, NULL, 16.3125, 21.125);
	CGFloat strokeWidth144 = 2;
	CGRect pathBoundingBox145 = CGPathGetBoundingBox(path143);
	pathBoundingBox145 = NSInsetRect(pathBoundingBox145, -strokeWidth144, -strokeWidth144);
	CGFloat scaledStrokeWidth146 = 2 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth146);
	NSColor * strokeColor147 = [NSColor colorWithRed:0.411765 green:0.411765 blue:0.411765 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor147.CGColor);
	NSColor * fillColor148 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor148.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip149 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform141 = CGAffineTransformConcat(currentTransform141, flip149);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect150 = cellFrame;
		CGFloat boundsMidX151 = NSMidX(boundsRect150) * (1.0f / viewScale);
		CGFloat boundsMidY152 = NSMidY(boundsRect150) * (1.0f / viewScale);
		CGFloat imageMidX153 = NSMidX(webBBox);
		CGFloat imageMidY154 = NSMidY(webBBox);
		CGFloat xTranslation155 = boundsMidX151 - imageMidX153;
		CGFloat yTranslation156 = boundsMidY152 - imageMidY154;
		CGAffineTransform centerTranslation157 = CGAffineTransformMakeTranslation(xTranslation155, yTranslation156);
		currentTransform141 = CGAffineTransformConcat(currentTransform141, centerTranslation157);
	}
	CGAffineTransform translate158 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform141 = CGAffineTransformConcat(currentTransform141, translate158);
	CGAffineTransform scale159 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform141 = CGAffineTransformConcat(currentTransform141, scale159);
	CGPathRef finalPath160 = CGPathCreateCopyByTransformingPath(path143, &currentTransform141);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath160);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath160);
	CGPathRelease(path143);
	CGContextRestoreGState(context);
}






- (void)drawFolderIcon:(NSRect)cellFrame {
	//NSBezierPath * rectPath1 = [NSBezierPath bezierPathWithRect:self.bounds];
	//NSColor * rectColor2 = [NSColor orangeColor];
	//[rectColor2 set];
	//[rectPath1 stroke];
	NSGraphicsContext * nsctx = [NSGraphicsContext currentContext];
	//CGContextRef context = (CGContextRef)nsctx.graphicsPort;
    CGContextRef context = (CGContextRef)nsctx.CGContext;
	BOOL flipImage = NO;
	BOOL centerImage = YES;
	NSRect webBBox = NSMakeRect(-0.218750, -0.218750, 16.500000, 16.500000);
	CGFloat hViewScale = cellFrame.size.width / (webBBox.size.width);
	CGFloat vViewScale = cellFrame.size.height / (webBBox.size.height);
	CGFloat viewScale = MIN(hViewScale, vViewScale);
	viewScale *= 1.0f; 	// A good place to adjust scale relative to view

	//--------------------------------------------------------

	// SVG element: <g id="folder_icon" visibility="visible" macsvgid="06AC96B3-E659-4F0A-9E67-E0F8AB6AE56B-47434-0000FA8BCBC9B8BD"><path stroke="black" id="path1" stroke-width="0.25px" d="M1.15625,2.1875 L1.15625,0.9375 L1.71875,0.1875 L5.40625,0.21875 L5.84375,0.9375 L5.84375,2.1875 L1.1875,2.1875" fill="url(#linearGradient1)" transform="" visibility="visible" macsvgid="CADF8BD4-D280-4095-8695-EF95924871C5-47434-0000FA8BCBCA06FE"></path><rect stroke="black" x="0.157px" height="11.75px" y="2.2px" id="rect1" stroke-width="0.25px" width="15.062px" fill="url(#linearGradient1)" transform="" macsvgid="98976042-C40E-4968-AD9B-63137F5C67FD-47434-0000FA8BCBCA3164"></rect></g>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform3 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix4 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform3 = CGAffineTransformConcat(currentTransform3, ctmMatrix4);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <image x="0.03125px" height="16px" y="0.03125px" id="image1" xlink:href="file:///Users/dsward/Documents/ArkPhone_LLC_Projects/MacSVG_Project%20StdWebKit/MacSVG/Resources/Outline%20Icons/folder.png" width="16px" transform="" visibility="hidden" macsvgid="5864368B-5B69-41C0-ADCF-B1B4901AED3-47434-0000FA8BCBC9DE23"></image>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform5 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix6 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform5 = CGAffineTransformConcat(currentTransform5, ctmMatrix6);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <path stroke="black" id="path1" stroke-width="0.25px" d="M1.15625,2.1875 L1.15625,0.9375 L1.71875,0.1875 L5.40625,0.21875 L5.84375,0.9375 L5.84375,2.1875 L1.1875,2.1875" fill="url(#linearGradient1)" transform="" visibility="visible" macsvgid="CADF8BD4-D280-4095-8695-EF95924871C5-47434-0000FA8BCBCA06FE"></path>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform7 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix8 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform7 = CGAffineTransformConcat(currentTransform7, ctmMatrix8);
	CGMutablePathRef path9 = CGPathCreateMutable();
	CGPathMoveToPoint(path9, NULL, 1.15625, 2.1875);
	CGPathAddLineToPoint(path9, NULL, 1.15625, 0.9375);
	CGPathAddLineToPoint(path9, NULL, 1.71875, 0.1875);
	CGPathAddLineToPoint(path9, NULL, 5.40625, 0.21875);
	CGPathAddLineToPoint(path9, NULL, 5.84375, 0.9375);
	CGPathAddLineToPoint(path9, NULL, 5.84375, 2.1875);
	CGPathAddLineToPoint(path9, NULL, 1.1875, 2.1875);
	CGFloat strokeWidth10 = 0.25;
	CGRect pathBoundingBox11 = CGPathGetBoundingBox(path9);
	pathBoundingBox11 = NSInsetRect(pathBoundingBox11, -strokeWidth10, -strokeWidth10);
	CGFloat scaledStrokeWidth12 = 0.25 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth12);
	NSColor * strokeColor13 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor13.CGColor);
	NSColor * fillColor14 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor14.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip15 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform7 = CGAffineTransformConcat(currentTransform7, flip15);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect16 = cellFrame;
		CGFloat boundsMidX17 = NSMidX(boundsRect16) * (1.0f / viewScale);
		CGFloat boundsMidY18 = NSMidY(boundsRect16) * (1.0f / viewScale);
		CGFloat imageMidX19 = NSMidX(webBBox);
		CGFloat imageMidY20 = NSMidY(webBBox);
		CGFloat xTranslation21 = boundsMidX17 - imageMidX19;
		CGFloat yTranslation22 = boundsMidY18 - imageMidY20;
		CGAffineTransform centerTranslation23 = CGAffineTransformMakeTranslation(xTranslation21, yTranslation22);
		currentTransform7 = CGAffineTransformConcat(currentTransform7, centerTranslation23);
	}
	CGAffineTransform translate24 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform7 = CGAffineTransformConcat(currentTransform7, translate24);
	CGAffineTransform scale25 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform7 = CGAffineTransformConcat(currentTransform7, scale25);
	CGPathRef finalPath26 = CGPathCreateCopyByTransformingPath(path9, &currentTransform7);
	CGColorSpaceRef linearGradientColorSpace27 = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGFloat linearGradientColorArray29[4] = {0.941176, 0.866667, 0.603922, 1.0};
	CGColorRef linearGradientColor30 = CGColorCreate(linearGradientColorSpace27, linearGradientColorArray29);
	CGFloat linearGradientColorArray31[4] = {0.854902, 0.647059, 0.12549, 1.0};
	CGColorRef linearGradientColor32 = CGColorCreate(linearGradientColorSpace27, linearGradientColorArray31);
	CGFloat locationsArray33[] = {0.000000, 1.000000};
	NSArray * colorsArray34 = @[(__bridge id) linearGradientColor30, (__bridge id) linearGradientColor32];
	CGGradientRef linearGradient35 = CGGradientCreateWithColors(linearGradientColorSpace27, (__bridge CFArrayRef) colorsArray34, locationsArray33);
	CGRect pathBounds36 = CGPathGetPathBoundingBox(finalPath26);
	CGPoint linearGradientStartPoint37 = CGPointMake(CGRectGetMidX(pathBounds36), CGRectGetMinY(pathBounds36));
	CGPoint linearGradientEndPoint38 = CGPointMake(CGRectGetMidX(pathBounds36), CGRectGetMaxY(pathBounds36));
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath26);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, linearGradient35, linearGradientStartPoint37, linearGradientEndPoint38, 0);
	CGGradientRelease(linearGradient35);
	CGColorRelease(linearGradientColor30);
	CGColorRelease(linearGradientColor32);
	CGColorSpaceRelease(linearGradientColorSpace27);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath26);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath26);
	CGPathRelease(path9);
	CGContextRestoreGState(context);

	//--------------------------------------------------------

	// SVG element: <rect stroke="black" x="0.157px" height="11.75px" y="2.2px" id="rect1" stroke-width="0.25px" width="15.062px" fill="url(#linearGradient1)" transform="" macsvgid="98976042-C40E-4968-AD9B-63137F5C67FD-47434-0000FA8BCBCA3164"></rect>
	CGContextSaveGState(context);
	CGAffineTransform currentTransform39 = CGAffineTransformIdentity;
	CGAffineTransform ctmMatrix40 = CGAffineTransformMake(1.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000);
	currentTransform39 = CGAffineTransformConcat(currentTransform39, ctmMatrix40);
	CGMutablePathRef rectPath41 = CGPathCreateMutable();
	CGFloat x42 = 0.157000;
	CGFloat y43 = 2.200000;
	CGFloat width44 = 15.062000;
	CGFloat height45 = 11.750000;
	CGRect rect48 = CGRectMake(x42, y43, width44, height45);
	CGPathAddRect(rectPath41, NULL, rect48);
	CGFloat strokeWidth49 = 0.25;
	CGRect pathBoundingBox50 = CGPathGetBoundingBox(rectPath41);
	pathBoundingBox50 = NSInsetRect(pathBoundingBox50, -strokeWidth49, -strokeWidth49);
	CGFloat scaledStrokeWidth51 = 0.25 * viewScale;
	CGContextSetLineWidth(context, scaledStrokeWidth51);
	NSColor * strokeColor52 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetStrokeColorWithColor(context, strokeColor52.CGColor);
	NSColor * fillColor53 = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
	CGContextSetFillColorWithColor(context, fillColor53.CGColor);
	if (flipImage == YES) { // flip image vertically
		CGAffineTransform flip54 = CGAffineTransformMake(1, 0, 0, -1, 0, webBBox.size.height);
		currentTransform39 = CGAffineTransformConcat(currentTransform39, flip54);
	}
	if (centerImage == YES) { // center image
		NSRect boundsRect55 = cellFrame;
		CGFloat boundsMidX56 = NSMidX(boundsRect55) * (1.0f / viewScale);
		CGFloat boundsMidY57 = NSMidY(boundsRect55) * (1.0f / viewScale);
		CGFloat imageMidX58 = NSMidX(webBBox);
		CGFloat imageMidY59 = NSMidY(webBBox);
		CGFloat xTranslation60 = boundsMidX56 - imageMidX58;
		CGFloat yTranslation61 = boundsMidY57 - imageMidY59;
		CGAffineTransform centerTranslation62 = CGAffineTransformMakeTranslation(xTranslation60, yTranslation61);
		currentTransform39 = CGAffineTransformConcat(currentTransform39, centerTranslation62);
	}
	CGAffineTransform translate63 = CGAffineTransformMakeTranslation(0, webBBox.origin.y + 1);
	currentTransform39 = CGAffineTransformConcat(currentTransform39, translate63);
	CGAffineTransform scale64 = CGAffineTransformMakeScale(viewScale, viewScale);
	currentTransform39 = CGAffineTransformConcat(currentTransform39, scale64);
	CGPathRef finalPath65 = CGPathCreateCopyByTransformingPath(rectPath41, &currentTransform39);
	CGColorSpaceRef linearGradientColorSpace66 = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGFloat linearGradientColorArray68[4] = {0.941176, 0.866667, 0.603922, 1.0};
	CGColorRef linearGradientColor69 = CGColorCreate(linearGradientColorSpace66, linearGradientColorArray68);
	CGFloat linearGradientColorArray70[4] = {0.854902, 0.647059, 0.12549, 1.0};
	CGColorRef linearGradientColor71 = CGColorCreate(linearGradientColorSpace66, linearGradientColorArray70);
	CGFloat locationsArray72[] = {0.000000, 1.000000};
	NSArray * colorsArray73 = @[(__bridge id) linearGradientColor69, (__bridge id) linearGradientColor71];
	CGGradientRef linearGradient74 = CGGradientCreateWithColors(linearGradientColorSpace66, (__bridge CFArrayRef) colorsArray73, locationsArray72);
	CGRect pathBounds75 = CGPathGetPathBoundingBox(finalPath65);
	CGPoint linearGradientStartPoint76 = CGPointMake(CGRectGetMidX(pathBounds75), CGRectGetMinY(pathBounds75));
	CGPoint linearGradientEndPoint77 = CGPointMake(CGRectGetMidX(pathBounds75), CGRectGetMaxY(pathBounds75));
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath65);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, linearGradient74, linearGradientStartPoint76, linearGradientEndPoint77, 0);
	CGGradientRelease(linearGradient74);
	CGColorRelease(linearGradientColor69);
	CGColorRelease(linearGradientColor71);
	CGColorSpaceRelease(linearGradientColorSpace66);
	CGContextBeginPath(context);
	CGContextAddPath(context, finalPath65);
	CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(finalPath65);
	CGPathRelease(rectPath41);
	CGContextRestoreGState(context);
}




@end
