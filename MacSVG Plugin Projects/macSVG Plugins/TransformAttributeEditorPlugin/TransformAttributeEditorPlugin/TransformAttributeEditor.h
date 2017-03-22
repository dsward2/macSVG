//
//  TransformAttributeEditor.h
//  TransformAttributeEditor
//
//  Created by Douglas Ward on 1/26/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MacSVGPlugin/MacSVGPlugin.h"

@class DOMEvent;
@class DOMNode;

@interface TransformAttributeEditor : MacSVGPlugin <NSTableViewDelegate, NSTableViewDataSource>
{
    IBOutlet NSButton * translateToolButton;
    IBOutlet NSButton * scaleToolButton;
    IBOutlet NSButton * rotateToolButton;
    IBOutlet NSButton * skewXToolButton;
    IBOutlet NSButton * skewYToolButton;
    
    IBOutlet NSTextField * label1TextField;
    IBOutlet NSTextField * label2TextField;
    IBOutlet NSTextField * label3TextField;
    IBOutlet NSTextField * label4TextField;
    IBOutlet NSTextField * label5TextField;
    IBOutlet NSTextField * label6TextField;
    
    IBOutlet NSTextField * value1TextField;
    IBOutlet NSTextField * value2TextField;
    IBOutlet NSTextField * value3TextField;
    IBOutlet NSTextField * value4TextField;
    IBOutlet NSTextField * value5TextField;
    IBOutlet NSTextField * value6TextField;
    
    IBOutlet NSButton * functionButton;
    
    IBOutlet NSTableView * transformsTableView;
        
    NSUInteger currentTransformToolMode;
    
    int mouseMode;
    NSPoint clickPoint;
    NSPoint currentMousePoint;
    NSPoint previousMousePoint;
    DOMNode * clickTarget;

    BOOL selectionHandleClicked;
    NSString * handle_orientation;  // static string, e.g. @"topLeft"
    int mouseMoveCount;
    float handleDegrees;
    float currentScale;
    NSRect elementRectAtMouseDown;
    
    BOOL settingToolButton;
}

@property(strong) NSMutableArray * transformsArray;
@property(strong) NSDictionary * validElementsForTransformDictionary;


- (void) handlePluginEvent:(DOMEvent *)event;

- (IBAction)transformToolTextFieldAction:(id)sender;
- (IBAction)transformToolButtonAction:(id)sender;
- (IBAction)transformToolDeleteButtonAction:(id)sender;

- (IBAction)functionButtonAction:(id)sender;

@end


float getAngleABC( NSPoint a, NSPoint b, NSPoint c );
