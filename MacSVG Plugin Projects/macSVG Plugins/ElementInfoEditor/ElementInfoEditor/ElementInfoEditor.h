//
//  ElementInfoEditor.h
//  ElementInfoEditor
//
//  Created by Douglas Ward on 11/23/17.
//  Copyright © 2017 ArkPhone LLC. All rights reserved.
//

#import <MacSVGPlugin/MacSVGPlugin.h>

@interface ElementInfoEditor : MacSVGPlugin

@property (weak) IBOutlet NSTextField * elementInfoTextField;

@property (strong) NSFont * textFont;
@property (strong) NSDictionary * textAttributes;
@property (strong) NSFont * boldFont;
@property (strong) NSDictionary * boldTextAttributes;

- (void) handlePluginEvent:(DOMEvent *)event;

@end
