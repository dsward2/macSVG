//
//  XMLAttributesTableView.m
//  macSVG
//
//  Created by Douglas Ward on 10/15/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "XMLAttributesTableView.h"
#import "XMLAttributesTableController.h"

@implementation XMLAttributesTableView

- (void)dealloc
{
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void) textDidEndEditing: (NSNotification *) notification
{
    // make return and tab only end editing, and not cause other cells to edit
    NSDictionary *userInfo = notification.userInfo;

    int textMovement = [[userInfo valueForKey:@"NSTextMovement"] intValue];

    if (textMovement == NSReturnTextMovement
            || textMovement == NSTabTextMovement
            || textMovement == NSBacktabTextMovement) 
    {
        NSMutableDictionary *newInfo;
        newInfo = [NSMutableDictionary dictionaryWithDictionary: userInfo];

        newInfo[@"NSTextMovement"] = @(NSIllegalTextMovement);

        notification = [NSNotification notificationWithName: notification.name
                object: notification.object
                userInfo: newInfo];
    }

    [super textDidEndEditing: notification];
         
    [self.window makeFirstResponder:self];

} // textDidEndEditing

@end
