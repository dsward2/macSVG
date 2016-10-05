//
//  PathElementEditor.h
//  PathElementEditor
//
//  Created by Douglas Ward on 3/2/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

//#import "MacSVGPlugin/MacSVGPlugin.h"
#import <MacSVGPlugin/MacSVGPlugin.h>

@class PathSegmentEditorPopoverViewController;
@class ArcSettingsPopoverViewController;
@class PathElementEditorFunctions;

#define kEditPathSegment 0
#define kAddPathSegment 1

@interface PathElementEditor : MacSVGPlugin
{
    // path element
    IBOutlet NSPopUpButton * pathModePopupButton;
    IBOutlet NSButton * useRelativePathCoordinatesButton;
    IBOutlet NSButton * closePathAutomaticallyCheckbox;
    IBOutlet NSButton * curveSegmentContinuityCheckbox;
    
    IBOutlet NSButton * arcSettingsButton;
    IBOutlet NSPopover * arcSettingsPopover;
    
    // segments
    IBOutlet NSPopover * pathSegmentEditorPopover;
    IBOutlet NSButton * editSegmentButton;
    IBOutlet NSButton * insertSegmentButton;
    IBOutlet NSButton * deleteSegmentButton;
    IBOutlet NSButton * subdivideSegmentButton;
    IBOutlet NSButton * highlightSelectedSegmentCheckbox;
    IBOutlet NSColorWell * highlightColorWell;
    IBOutlet NSButton * highlightUseCustomStrokeWidthCheckbox;
    IBOutlet NSTextField * highlightStrokeWidthTextField;
}

// path element
@property(strong) NSArray * parametersMoveto;
@property(strong) NSArray * parametersLineto;
@property(strong) NSArray * parametersHorizontalLineto;
@property(strong) NSArray * parametersVerticalLineto;
@property(strong) NSArray * parametersCubicCurveto;
@property(strong) NSArray * parametersCubicCurvetoSmooth;
@property(strong) NSArray * parametersQuadraticCurveto;
@property(strong) NSArray * parametersQuadraticCurvetoSmooth;
@property(strong) NSArray * parametersEllipticalArc;
@property(strong) NSArray * parametersClosepath;

@property(strong) IBOutlet NSPopUpButton * pathFunctionsPopupButton;

@property(strong) IBOutlet NSTextField * pathFunctionLabel1;
@property(strong) IBOutlet NSTextField * pathFunctionLabel2;
@property(strong) IBOutlet NSTextField * pathFunctionLabel3;
@property(strong) IBOutlet NSTextField * pathFunctionValue1;
@property(strong) IBOutlet NSTextField * pathFunctionValue2;
@property(strong) IBOutlet NSTextField * pathFunctionValue3;

// segments

@property(strong) IBOutlet NSTableView * pathTableView;
@property(strong) IBOutlet PathSegmentEditorPopoverViewController * pathSegmentEditorPopoverViewController;
@property(strong) IBOutlet ArcSettingsPopoverViewController * arcSettingsPopoverViewController;
@property(strong) IBOutlet NSTextField * pathLengthTextField;
@property(assign) NSInteger pathSegmentEditorMode;

// path functions
@property(strong) IBOutlet PathElementEditorFunctions * pathFunctions;

- (IBAction)updateSVGPathEditorAction:(id)sender;

- (IBAction)editPathSegmentButtonAction:(id)sender;
- (IBAction)addPathSegmentButtonAction:(id)sender;
- (IBAction)deletePathSegmentButtonAction:(id)sender;

- (IBAction)closePathNowButtonAction:(id)sender;

- (IBAction)arcSettingsButtonAction:(id)sender;

- (IBAction)subdivideSegmentButtonAction:(id)sender;

- (IBAction)performPathFunctionButtonAction:(id)sender;

- (IBAction)pathFunctionPopUpButtonAction:(id)sender;

- (void)updateWithPathSegmentsArray:(NSMutableArray *)aPathSegmentsArray;

@property (readonly, copy) NSMutableArray *pathSegmentsArray;


@end
