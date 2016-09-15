//
//  SynchroScrollView.h
//  edenx
//
//  Created by Guillaume Laurent on 2/21/09.
//  Copied from http://developer.apple.com/documentation/Cocoa/Conceptual/NSScrollViewGuide/Articles/SynchroScroll.html
//

#import <Cocoa/Cocoa.h>


@interface SynchroScrollView : NSScrollView {
    NSScrollView* synchronizedScrollView; // not retained
}
@property(assign) BOOL scrollHorizontal;

- (void)setSynchronizedScrollView:(NSScrollView*)scrollview;
- (void)stopSynchronizing;
- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)notification;

@end