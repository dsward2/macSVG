
#import <Cocoa/Cocoa.h>

#define kMaxColorStops 32


@interface GradientView : NSView 
{
    NSGradient * gradient;
    float angle;
}

- (void)setTopColor:(NSColor *)topColor bottomColor:(NSColor *)bottomColor;
- (void)setColorStopsArray:(NSArray *)colorStopsArray;

@end
