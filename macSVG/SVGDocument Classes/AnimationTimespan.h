//
//  AnimationTimespan.h
//  macSVG
//
//  Created by Douglas Ward on 12/18/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimationTimespan : NSObject
{
}
    
@property(assign) float beginSeconds;
@property(assign) float durationSeconds;
@property(assign) NSRect timelineRect;
@property(assign) int colorIndex;

@end
