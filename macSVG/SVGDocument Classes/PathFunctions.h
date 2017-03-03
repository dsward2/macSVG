//
//  PathFunctions.h
//  macSVG
//
//  Created by Douglas Ward on 8/9/16.
//
//

#import <Foundation/Foundation.h>

@class MacSVGDocumentWindowController;

@interface PathFunctions : NSObject

@property (weak) IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;

- (NSMutableArray *)convertToAbsoluteCoordinates:(NSXMLElement *)pathElement;
- (NSMutableArray *)convertCurvesToAbsoluteCubicBezier:(NSXMLElement *)pathElement;
- (NSMutableArray *)convertCurvesToAbsoluteCubicBezierWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray;

- (NSMutableArray *)convertPathToAbsoluteCubicBezier:(NSXMLElement *)pathElement;
- (NSMutableArray *)convertPathToAbsoluteCubicBezierWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray;

- (NSMutableArray *)reversePathWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray;
- (NSMutableArray *)mirrorPathHorizontallyWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray;
- (NSMutableArray *)mirrorPathVerticallyWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray;
- (NSMutableArray *)flipPathHorizontallyWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray;
- (NSMutableArray *)flipPathVerticallyWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray;
- (NSMutableArray *)translatePathCoordinatesWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray x:(CGFloat)translateX y:(CGFloat)translateY;
- (NSMutableArray *)scalePathCoordinatesWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY;
- (NSMutableArray *)rotatePathCoordinatesWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray x:(CGFloat)rotateX y:(CGFloat)rotateY degrees:(CGFloat)degrees;

- (NSMutableArray *)closePathWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray;

- (NSMutableArray *)rotateSegmentsWithPathSegmentsArray:(NSMutableArray *)pathSegmentsArray offset:(NSInteger)offset;

@end
