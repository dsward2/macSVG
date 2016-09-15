//
//  ArcSettingsPopoverViewController.m
//  PathElementEditor
//
//  Created by Douglas Ward on 9/13/16.
//
//

#import "ArcSettingsPopoverViewController.h"

@interface ArcSettingsPopoverViewController ()

@end

@implementation ArcSettingsPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

//==================================================================================
//	applyButtonAction
//==================================================================================

- (IBAction)applyButtonAction:(id)sender
{
    [arcSettingsPopover performClose:self];
}

//==================================================================================
//	cancelButtonAction
//==================================================================================

- (IBAction)cancelButtonAction:(id)sender
{
    [arcSettingsPopover performClose:self];
}


@end
