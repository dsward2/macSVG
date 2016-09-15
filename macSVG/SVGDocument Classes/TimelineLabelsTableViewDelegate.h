//
//  TimelineLabelsTableViewDelegate.h
//  macSVG
//
//  Created by Douglas Ward on 12/22/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

@class AnimationTimelineView;
@class MacSVGDocumentWindowController;

@interface TimelineLabelsTableViewDelegate : NSObject <NSTableViewDelegate, NSTableViewDataSource>
{
    IBOutlet NSTableView * timelineLabelsTableView;
    IBOutlet AnimationTimelineView * animationTimelineView;
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;
}

- (void)reloadData;
- (void)reloadView;

@end
