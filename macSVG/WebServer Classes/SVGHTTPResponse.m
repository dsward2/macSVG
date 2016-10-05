//
//  SVGHTTPResponse.m
//  macSVG
//
//  Created by Douglas Ward on 7/5/13.
//
//

#import "SVGHTTPResponse.h"

@implementation SVGHTTPResponse

- (NSDictionary *)httpHeaders
{
	//HTTPLogTrace();
    
	return @{@"Content-Type": @"image/svg+xml"};
}


@end
