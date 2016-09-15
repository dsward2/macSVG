//
//  EmbeddedFontEncoder.h
//  macSVG
//
//  Created by Douglas Ward on 1/3/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmbeddedFontEncoder : NSObject
{
}

- (IBAction)testFontEmbedder:(id)sender;
- (NSString *)encodeFontWithURL:(NSURL *)fontURL fontFamily:(NSString *)fontFamily fontType:(NSString *)fontType;

@end
