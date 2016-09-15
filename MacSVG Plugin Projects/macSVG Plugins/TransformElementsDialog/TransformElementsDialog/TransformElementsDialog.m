//
//  TransformElementsDialog.m
//  TransformElementsDialog
//
//  Created by Douglas Ward on 8/10/16.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "TransformElementsDialog.h"
#import "TransformElementsDialogWindowController.h"
#import "MacSVGPlugin/MacSVGPluginCallbacks.h"

@implementation TransformElementsDialog

//==================================================================================
//	pluginMenuTitle
//==================================================================================

- (NSString *)pluginMenuTitle
{
    return @"Transform Elements Base Coordinates";    // override for menu plugins
}

//==================================================================================
//	isMenuPlugIn
//==================================================================================

- (BOOL) isMenuPlugIn
{
    return YES;
}

//==================================================================================
//	beginMenuPlugIn
//==================================================================================

- (BOOL)beginMenuPlugIn
{
    // for menu plug-ins
    if (transformElementsDialogWindowController.window == NULL)
    {
        NSString * pluginNameString = [self className];
        NSArray * topLevelObjects = NULL;

        NSString * bundlePath = [[NSBundle bundleForClass:[self class]] bundlePath];

        NSBundle * pluginBundle = [NSBundle bundleWithPath:bundlePath];

        BOOL result = [pluginBundle loadNibNamed:pluginNameString owner:self topLevelObjects:&topLevelObjects];
        #pragma unused(result)
    }

    [[NSApplication sharedApplication] runModalForWindow:transformElementsDialogWindowController.window];

    return YES;
}

@end
