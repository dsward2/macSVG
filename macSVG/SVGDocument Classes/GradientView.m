
#import "GradientView.h"

@implementation GradientView

// ============================================================================

- (void)initGradient
{
    angle = 90;
    NSColor * color1 = [NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1.0];
    NSColor * color2 = [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0];
    NSColor * color3 = [NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    NSColor * color4 = [NSColor colorWithCalibratedRed:0.85 green:0.85 blue:0.85 alpha:1.0];
    NSArray * colorArray = [NSArray arrayWithObjects: 
            color1, color2, color3, color4, color4, color3, color2, color1, nil];
    gradient = [[NSGradient alloc] initWithColors:colorArray];
}

// ============================================================================

- (id)initWithCoder:(NSCoder *)decoder
{    
    self = [super initWithCoder:decoder];
    if (self) 
    {
        [self initGradient];
    }
    return self;
}

// ============================================================================

- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) 
	{
        [self initGradient];
    }
    return self;
}

// ============================================================================

- (void)setTopColor:(NSColor *)topColor bottomColor:(NSColor *)bottomColor 
{
    gradient = [[NSGradient alloc] initWithStartingColor:topColor endingColor:bottomColor];
    
    [self setNeedsDisplay:YES];
}

// ============================================================================

- (void)setColorStopsArray:(NSArray *)colorStopsArray
{
    gradient = [[NSGradient alloc] initWithColors:colorStopsArray];
    
    [self setNeedsDisplay:YES];
}

// ============================================================================

- (void)layoutSubviews 
{
    [self setNeedsDisplay:YES];
}

// ============================================================================

- (void)drawRect:(NSRect)rect 
{
    [gradient drawInRect:[self bounds] angle:angle];
}

// ============================================================================

@end



