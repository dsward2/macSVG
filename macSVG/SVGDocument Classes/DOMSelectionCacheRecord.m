//
//  DOMSelectionCacheRecord.m
//  macSVG
//
//  Created by Douglas Ward on 1/11/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "DOMSelectionCacheRecord.h"

@implementation DOMSelectionCacheRecord

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.parentElement = NULL;
    self.shadowParentElement = NULL;
}

@end
