//
//  PathTextGenerator.h
//  PathTextGenerator
//
//  Created by Douglas Ward on 9/25/17.
//  Copyright © 2017 ArkPhone LLC. All rights reserved.
//

// Based on TextToSvgPath by revarbat -
// https://github.com/revarbat/TextToSvgPath

#import <MacSVGPlugin/MacSVGPlugin.h>

@class PathTextGeneratorWindowController;

@interface PathTextGenerator : MacSVGPlugin
{
    IBOutlet PathTextGeneratorWindowController * pathTextGeneratorWindowController;
}

- (NSXMLElement *)createPathWithString:(NSString *)pathTextString
        font:(NSFont *)font fontSize:(CGFloat)fontSize
        originX:(CGFloat)originX originY:(CGFloat)originY;

- (NSXMLElement *)createMultiplePathsWithString:(NSString *)pathTextString
        font:(NSFont *)font fontSize:(CGFloat)fontSize
        originX:(CGFloat)originX originY:(CGFloat)originY;

@end
