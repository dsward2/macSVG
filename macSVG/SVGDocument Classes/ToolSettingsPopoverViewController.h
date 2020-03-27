//
//  ToolSettingsPopoverViewController.h
//  macSVG
//
//  Created by Douglas Ward on 7/15/13.
//
//

#import <Cocoa/Cocoa.h>
#import "MacSVGDocumentWindowController.h"

@interface ToolSettingsPopoverViewController : NSViewController <NSTextFieldDelegate>
{
    IBOutlet NSColorWell * selectionStrokeColorWell;
    IBOutlet NSTextField * selectionStrokeWidthTextField;
    IBOutlet NSStepper * selectionStrokeWidthStepper;

    IBOutlet NSColorWell * selectionHandleColorWell;
    IBOutlet NSTextField * selectionHandleSizeTextField;
    IBOutlet NSStepper * selectionHandleSizeStepper;
    
    IBOutlet NSColorWell * pathEndpointStrokeColorWell;
    IBOutlet NSTextField * pathEndpointStrokeWidthTextField;
    IBOutlet NSStepper * pathEndpointStrokeWidthStepper;
    IBOutlet NSColorWell * pathEndpointFillColorWell;
    IBOutlet NSTextField * pathEndpointRadiusTextField;
    IBOutlet NSStepper * pathEndpointRadiusStepper;

    IBOutlet NSColorWell * pathCurvePointStrokeColorWell;
    IBOutlet NSTextField * pathCurvePointStrokeWidthTextField;
    IBOutlet NSStepper * pathCurvePointStrokeWidthStepper;
    IBOutlet NSColorWell * pathCurvePointFillColorWell;
    IBOutlet NSTextField * pathCurvePointRadiusTextField;
    IBOutlet NSStepper * pathCurvePointRadiusStepper;

    IBOutlet NSColorWell * pathLineStrokeColorWell;
    IBOutlet NSTextField * pathLineStrokeWidthTextField;
    IBOutlet NSStepper * pathLineStrokeWidthStepper;
    
    IBOutlet NSView * checkeredBackgroundView;
    
    IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;
}

- (IBAction)setDefaultsButtonAction:(id)sender;

- (IBAction)increaseScaleButtonAction:(id)sender;
- (IBAction)decreaseScaleButtonAction:(id)sender;

- (IBAction)toolSettingsAction:(id)sender;

@property(weak) IBOutlet NSButton * checkerboardBackgroundCheckboxButton;
@property(weak) IBOutlet NSButton * validateElementPlacementCheckboxButton;

@property(strong) NSString * selectionStrokeColor;
@property(strong) NSString * selectionStrokeWidth;

@property(strong) NSString * selectionHandleColor;
@property(strong) NSString * selectionHandleSize;

@property(assign) BOOL showCheckerboardBackground;
@property(assign) BOOL validateElementPlacement;

@property(strong) NSString * pathEndpointStrokeColor;
@property(strong) NSString * pathEndpointStrokeWidth;
@property(strong) NSString * pathEndpointFillColor;
@property(strong) NSString * pathEndpointRadius;

@property(strong) NSString * pathCurvePointStrokeColor;
@property(strong) NSString * pathCurvePointStrokeWidth;
@property(strong) NSString * pathCurvePointFillColor;
@property(strong) NSString * pathCurvePointRadius;

@property(strong) NSString * pathLineStrokeColor;
@property(strong) NSString * pathLineStrokeWidth;

- (IBAction)updateStepperValuesWithTextFields:(id)sender;
- (IBAction)updateTextFieldValuesWithSteppers:(id)sender;
- (IBAction)performClose:(id)sender;

@end
