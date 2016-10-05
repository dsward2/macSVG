//
//  EmbeddedFontEncoder.m
//  macSVG
//
//  Created by Douglas Ward on 1/3/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "EmbeddedFontEncoder.h"

/*
<style type="text/css" macsvgid="A9FEAEBB-5028-4C46-B1B4-19B671BC3BB4-4765-00006191F572855A">
@font-face {
	font-family: 'MyFontFamily';
	     url(data:font/truetype;charset=utf-8;base64,BASE64_ENCODED_DATA_HERE)  format('truetype'),
	     url(data:font/woff;charset=utf-8;base64,BASE64_ENCODED_DATA_HERE)  format('woff'),
	     url('myfont-webfont.svg#svgFontName') format('svg');
	}
</style>
*/

@implementation EmbeddedFontEncoder

// ================================================================

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString *)allocEncodeBase64Data:(NSData *)inputData
{
	if (inputData.length == 0)
		return @"";

    char *characters = malloc(((inputData.length + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < inputData.length)
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < inputData.length)
			buffer[bufferLength++] = ((char *)inputData.bytes)[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';	
	}
	
	return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

// ================================================================

- (NSString *)encodeFontWithURL:(NSURL *)fontURL fontFamily:(NSString *)fontFamily fontType:(NSString *)fontType
{
    NSString * cssString = @"";
    
    if (fontURL != NULL)
    {
        NSData * originalFontData = [[NSData alloc] initWithContentsOfURL:fontURL];
        
        NSString * base64String = [self allocEncodeBase64Data:originalFontData];
        
        cssString = [NSString stringWithFormat:@"@font-face {font-family:'%@'; src: url(data:font/%@;charset=utf-8;base64,%@) format('%@');}",
                fontFamily, fontType, base64String, fontType];
    }
    
    return cssString;
}

// ================================================================

- (IBAction)testFontEmbedder:(id)sender
{
    NSString * fontURLString = @"http://themes.googleusercontent.com/static/fonts/permanentmarker/v1/9vYsg5VgPHKK8SXYbf3sMgf-iVrhl8YPCq7ar5PCEqg.ttf";
    NSString * fontFamily = @"Font Diner";
    NSString * fontType = @"truetype";

    NSURL * fontURL = [NSURL URLWithString:fontURLString];
        
    NSString * resultString = [self encodeFontWithURL:fontURL fontFamily:fontFamily fontType:fontType];
    NSLog(@"testFontEmbedder - %@", resultString);
}


/* 
    See "Font Creation and Storage" and "CreateFlattenedFontData" sample code for serializing a font 
*/



/*

from http://stackoverflow.com/questions/360751/can-i-embed-a-custom-font-in-an-iphone-application

Load the font:

- (void)loadFont{
  // Get the path to our custom font and create a data provider.
  NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"mycustomfont" ofType:@"ttf"]; 
  CGDataProviderRef fontDataProvider = CGDataProviderCreateWithFilename([fontPath UTF8String]);

  // Create the font with the data provider, then release the data provider.
  customFont = CGFontCreateWithDataProvider(fontDataProvider);
  CGDataProviderRelease(fontDataProvider); 
}

Now, in your drawRect:, do something like this:

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    // Get the context.
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    // Set the customFont to be the font used to draw.
    CGContextSetFont(context, customFont);

    // Set how the context draws the font, what color, how big.
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    CGContextSetFillColorWithColor(context, self.fontColor.CGColor);
    UIColor * strokeColor = [UIColor blackColor];
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetFontSize(context, 48.0f);

    // Create an array of Glyph's the size of text that will be drawn.
    CGGlyph textToPrint[[self.theText length]];

    // Loop through the entire length of the text.
    for (int i = 0; i < [self.theText length]; ++i) {
        // Store each letter in a Glyph and subtract the MagicNumber to get appropriate value.
        textToPrint[i] = [[self.theText uppercaseString] characterAtIndex:i] + 3 - 32;
    }
    CGAffineTransform textTransform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
    CGContextSetTextMatrix(context, textTransform);
    CGContextShowGlyphsAtPoint(context, 20, 50, textToPrint, [self.theText length]);
}

Basically you have to do some brute force looping through the text and futzing about with the magic number to find your offset (here, see me using 29) in the font, but it works.

Also, you have to make sure the font is legally embeddable. Most aren't and there are lawyers who specialize in this sort of thing, so be warned.

*/



@end
