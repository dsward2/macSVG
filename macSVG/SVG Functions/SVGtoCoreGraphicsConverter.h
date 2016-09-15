//
//  SVGtoCoreGraphicsConverter.h
//  macSVG
//
//  Created by Douglas Ward on 7/25/16.
//
//

#import <Foundation/Foundation.h>

@class MacSVGDocumentWindowController;

@interface SVGtoCoreGraphicsConverter : NSObject

@property (strong) NSMutableArray * webColorsArray;

@property (weak) IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;

@property (strong) NSMutableSet * processedElementsSet;

@property (assign) NSInteger variableIndex;

@property (assign) NSRect webBBox;
@property (assign) CGFloat viewScale;

- (NSString *)convertSVGXMLElementsToCoreGraphics:(NSArray *)elementsArray;

@end
