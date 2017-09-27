//
//  NSBezierPath+EMMBezierPath.h
//  TextToSvgPath
//

// Based on TextToSvgPath by revarbat -
// https://github.com/revarbat/TextToSvgPath

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (EMMBezierPath)

- (CGFloat)appendBezierPathWithString:(NSString *)string font:(NSFont *)font;
- (void)transformIntoSVGCoordinateSpaceWithOffset:(NSPoint)offsetPoint;

@end
