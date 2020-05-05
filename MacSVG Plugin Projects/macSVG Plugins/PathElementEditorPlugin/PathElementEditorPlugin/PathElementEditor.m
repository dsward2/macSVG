//
//  PathElementPlugin.m
//  PathElementPlugin
//
//  Created by Douglas Ward on 3/2/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "PathElementEditor.h"
#import "MacSVGPlugin/MacSVGPluginCallbacks.h"
#import <WebKit/WebKit.h>
#import "PathSegmentEditorPopoverViewController.h"
#import "ArcSettingsPopoverViewController.h"
#import "MacSVGDocumentWindowController.h"
#import "SVGXMLDOMSelectionManager.h"
#import "DOMSelectionControlsManager.h"
#import "PathElementEditorFunctions.h"
#import "DOMMouseEventsController.h"
#import "SVGWebKitController.h"
#import "SVGPathEditor.h"
#import "PathSegment.h"

#define PathTableViewDataType @"NSMutableDictionary"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation PathElementEditor

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.parametersMoveto = @[@"x", @"y"];
        self.parametersLineto = @[@"x", @"y"];
        self.parametersHorizontalLineto = @[@"x"];
        self.parametersVerticalLineto = @[@"y"];
        self.parametersCubicCurveto = @[@"x1", @"y1", @"x2", @"y2", @"x", @"y"];
        self.parametersCubicCurvetoSmooth = @[@"x2", @"y2", @"x", @"y"];
        self.parametersQuadraticCurveto = @[@"x1", @"y1", @"x", @"y"];
        self.parametersQuadraticCurvetoSmooth = @[@"x", @"y"];
        self.parametersEllipticalArc = @[@"rx", @"ry", @"x-axis-rotation", @"large-arc-flag", @"sweep-flag", @"x", @"y"];
        self.parametersClosepath = [[NSArray alloc] init];
    }
    
    return self;
}

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.parametersMoveto = NULL;
    self.parametersLineto = NULL;
    self.parametersHorizontalLineto = NULL;
    self.parametersVerticalLineto = NULL;
    self.parametersCubicCurveto = NULL;
    self.parametersCubicCurvetoSmooth = NULL;
    self.parametersQuadraticCurveto = NULL;
    self.parametersQuadraticCurvetoSmooth = NULL;
    self.parametersEllipticalArc = NULL;
    self.parametersClosepath = NULL;

    self.pathFunctionsPopupButton = NULL;

    self.pathFunctionLabel1 = NULL;
    self.pathFunctionLabel2 = NULL;
    self.pathFunctionLabel3 = NULL;
    self.pathFunctionValue1 = NULL;
    self.pathFunctionValue2 = NULL;
    self.pathFunctionValue3 = NULL;
}

//==================================================================================
//	awakeFromNib
//==================================================================================

- (void)awakeFromNib 
{
    [super awakeFromNib];

    [self.pathTableView registerForDraggedTypes:@[PathTableViewDataType]];

    [self.pathFunctions setInputFieldsForFunction];
}

//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    return @"Path Element Editor";
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element tag name
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    NSString * result = NULL;

    if ([elementName isEqualToString:@"path"] == YES)
    {
        result = self.pluginName;
    }

    return result;
}

//==================================================================================
//	isEditorForElement:elementName:attribute:
//==================================================================================

// return label if this editor can edit specified element and attribute
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName attribute:(NSString *)attributeName
{   
    NSString * result = NULL;
    
    return result;
}

//==================================================================================
//	editorPriority:context:
//==================================================================================

- (NSInteger)editorPriority:(NSXMLElement *)targetElement context:(NSString *)context
{
    return 30;
}

//==================================================================================
//	unloadPluginView
//==================================================================================

- (void)unloadPluginView
{
    [super unloadPluginView];
}

//==================================================================================
//	updateEditForXMLElement:domElement:info:
//==================================================================================

- (void)updateEditForXMLElement:(NSXMLElement *)xmlElement domElement:(DOMElement *)domElement info:(id)infoData updatePathLength:(BOOL)updatePathLength
{
    // subclasses can override as needed
    
    NSArray * aPathSegmentArray = infoData;
    #pragma unused(aPathSegmentArray)
    
    [self.pathTableView reloadData];

    if (updatePathLength == YES)
    {
        [self updateTotalLengthForPathElement:xmlElement];
    }
}

//==================================================================================
//	loadPluginViewInScrollView:
//==================================================================================

- (BOOL)loadPluginViewInScrollView:(NSScrollView *)scrollView
{
    BOOL result = [super loadPluginViewInScrollView:scrollView];

    return result;
}

//==================================================================================
//	svgWebViewReloaded:
//==================================================================================

- (void) svgWebViewReloaded:(NSNotification *)aNotification
{
    // After Undo/Redo, the path element should be re-selected
    if ([self.svgXmlOutlineView selectedRow] == -1)
    {
        NSXMLElement * selectedElement = [self.macSVGPluginCallbacks xmlElementForMacsvgid:self.selectedElementMacsvgid];
        
        if (selectedElement != NULL)
        {
            [self.macSVGPluginCallbacks selectXMLElement:selectedElement];
        }
    }
}

//==================================================================================
//	selectedPathMode
//==================================================================================

- (NSString *) selectedPathMode
{
    NSString * result = pathModePopupButton.titleOfSelectedItem;
    return result;
}

//==================================================================================
//	updateSVGPathEditorAction:
//==================================================================================

- (IBAction)updateSVGPathEditorAction:(id)sender
{
    NSString * newPathMode = pathModePopupButton.titleOfSelectedItem;
    (self.macSVGPluginCallbacks).selectedPathMode = newPathMode;

    NSInteger useRelativePathCoordinatesCheckboxState =
            useRelativePathCoordinatesButton.state;
    if (useRelativePathCoordinatesCheckboxState == 0)
    {
        [self.macSVGPluginCallbacks setUseRelativePathCoordinates:NO];
    }
    else
    {
        [self.macSVGPluginCallbacks setUseRelativePathCoordinates:YES];
    }

    NSInteger closePathAutomaticallyCheckboxState =
            closePathAutomaticallyCheckbox.state;
    if (closePathAutomaticallyCheckboxState == 0)
    {
        [self.macSVGPluginCallbacks setClosePathAutomatically:NO];
    }
    else
    {
        [self.macSVGPluginCallbacks setClosePathAutomatically:YES];
    }

    NSInteger curveSegmentContinuityCheckboxState =
            curveSegmentContinuityCheckbox.state;
    if (curveSegmentContinuityCheckboxState == 0)
    {
        [self.macSVGPluginCallbacks setCurveSegmentContinuity:NO];
    }
    else
    {
        [self.macSVGPluginCallbacks setCurveSegmentContinuity:YES];
    }
    
    NSInteger pathLargeArcValue = (self.arcSettingsPopoverViewController.pathLargeArcCheckbox).state;
    if (pathLargeArcValue == 0)
    {
        (self.macSVGPluginCallbacks).largeArcFlagString = @"0";
    }
    else
    {
        (self.macSVGPluginCallbacks).largeArcFlagString = @"1";
    }
    
    NSInteger pathSweepFlagValue = (self.arcSettingsPopoverViewController.pathSweepCheckbox).state;
    if (pathSweepFlagValue == 0)
    {
        (self.macSVGPluginCallbacks).sweepFlagString = @"0";
    }
    else
    {
        (self.macSVGPluginCallbacks).sweepFlagString = @"1";
    }
    
    NSString * xAxisRotationString = (self.arcSettingsPopoverViewController.xAxisRotationTextField).stringValue;
    (self.macSVGPluginCallbacks).xAxisRotationString = xAxisRotationString;
    
    NSString * pathRadiusXString = (self.arcSettingsPopoverViewController.pathRadiusXTextField).stringValue;
    (self.macSVGPluginCallbacks).pathRadiusXString = pathRadiusXString;
    
    NSString * pathRadiusYString = (self.arcSettingsPopoverViewController.pathRadiusYTextField).stringValue;
    (self.macSVGPluginCallbacks).pathRadiusYString = pathRadiusYString;

    // If currently drawing a new segment, restart the segment drawing to apply latest settings
    MacSVGDocumentWindowController * macSVGDocumentWindowController =
                [self.macSVGDocument macSVGDocumentWindowController];
    NSUInteger currentToolMode = macSVGDocumentWindowController.currentToolMode;
    if (currentToolMode == toolModePath)
    {
        id svgWebKitController = macSVGDocumentWindowController.svgWebKitController;
        id domMouseEventsController = [svgWebKitController domMouseEventsController];
        SVGPathEditor * svgPathEditor = [domMouseEventsController svgPathEditor];
        if (svgPathEditor.editingMode == kPathEditingModeNextSegment)
        {
            [self.macSVGPluginCallbacks restartLastPathSegment];
        }
    }
}

//==================================================================================
//	updateWithPathSegmentsArray:
//==================================================================================

- (void)updateWithPathSegmentsArray:(NSMutableArray *)aPathSegmentsArray updatePathLength:(BOOL)updatePathLength
{
    NSXMLElement * holdSelectedPathElement = (self.macSVGPluginCallbacks).svgPathEditorSelectedPathElement;

    [self.macSVGPluginCallbacks svgPathEditorSetSelectedPathElement:self.pluginTargetXMLElement];
    
    (self.macSVGPluginCallbacks).pathSegmentsArray = aPathSegmentsArray;

    [self.macSVGPluginCallbacks updateSelectedPathInDOM:updatePathLength];

    [self.macSVGPluginCallbacks svgPathEditorSetSelectedPathElement:holdSelectedPathElement];
    
    if (updatePathLength == YES)
    {
        [self updateTotalLengthForPathElement:self.pluginTargetXMLElement];
    }
}

//==================================================================================
//  updateTotalLengthForPathElement
//==================================================================================

- (void)updateTotalLengthForPathElement:(NSXMLElement *)pathElement
{
    //NSXMLElement * selectedPathElement = [self.macSVGPluginCallbacks svgPathEditorSelectedPathElement];

    if (pathElement != NULL)
    {
        NSXMLNode * pathIDAttributeNode = [pathElement attributeForName:@"id"];
        if (pathIDAttributeNode != NULL)
        {
            NSString * pathIDAttributeString = pathIDAttributeNode.stringValue;
            
            NSString * pathLengthFunction = [NSString stringWithFormat:
                    //@"function f() {var path = document.getElementById('%@'); return path.getTotalLength();} f();",
                    //@"function f() {var pathLength = 0; var path = document.getElementById('%@'); if (typeof path !== 'undefined') { pathLength = path.getTotalLength(); } return pathLength;} f();",
                    @"function f() {var pathLength = 0; var path = document.getElementById('%@'); if (typeof path !== null) { pathLength = path.getTotalLength(); } return pathLength;} f();",
                    pathIDAttributeString];

            // TODO: prevent stringByEvaluatingJavaScriptFromString lockups
            NSString * totalLengthString = [self.svgWebView stringByEvaluatingJavaScriptFromString:pathLengthFunction];
            
            float totalStringFloat = totalLengthString.floatValue;
            
            if (totalStringFloat == 0.0f)
            {
                totalLengthString = @"0";
            }
            else
            {
                totalLengthString = [NSString stringWithFormat:@"%.2f", totalStringFloat];
            }

            (self.pathLengthTextField).stringValue = totalLengthString;
        }
    }
    else
    {
        (self.pathLengthTextField).stringValue = @"0";
    }
}

//==================================================================================
//	closePath
//==================================================================================

- (void)closePath
{
    CGEventRef event = CGEventCreate(NULL);
    CGEventFlags modifiers = CGEventGetFlags(event);
    CFRelease(event);
    //CGEventFlags flags = (kCGEventFlagMaskShift | kCGEventFlagMaskCommand);
    CGEventFlags flags = kCGEventFlagMaskAlternate;   // check for option key

    if ((modifiers & flags) == 0)
    {
        // option key is not pressed
        [self closePathAndContinue:NO]; // close path and exit path drawing mode
    }
    else
    {
        // option key is  pressed
        [self closePathAndContinue:YES];    // close path and continue path drawing mode
    }
}

//==================================================================================
//	closePathAndContinue:
//==================================================================================

- (void)closePathAndContinue:(BOOL)continuePath
{
    NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];
    
    pathSegmentsArray = [self.macSVGPluginCallbacks closePathWithPathSegmentsArray:pathSegmentsArray];
    
    NSInteger pathSegmentsArrayCount = [pathSegmentsArray count];
    
    if (pathSegmentsArrayCount > 0)
    {
        
        PathSegment * closePathSegment = [pathSegmentsArray objectAtIndex:pathSegmentsArrayCount - 1];
        PathSegment * newClosePathSegment = [[PathSegment alloc] init];
        [newClosePathSegment copyValuesFromPathSegment:closePathSegment];
        [pathSegmentsArray addObject:newClosePathSegment];   // add a second the Z or z segment, the final one will be removed

        [self.macSVGPluginCallbacks updatePathSegmentsAbsoluteValues:pathSegmentsArray];
        
        [self updateWithPathSegmentsArray:pathSegmentsArray updatePathLength:YES];

        if (continuePath == NO)
        {
            MacSVGDocumentWindowController * macSVGDocumentWindowController =
                    [self.macSVGDocument macSVGDocumentWindowController];

            [macSVGDocumentWindowController setToolMode:toolModeArrowCursor];
            
            [self updateDocumentViews];
        }
        else
        {
            [self extendPathButtonAction:self];
        }
    }
}

//==================================================================================
//	closePathNowButtonAction:
//==================================================================================

- (IBAction)closePathNowButtonAction:(id)sender
{
    [self closePath];   // checks for option key to continue path
}

//==================================================================================
//	closePathAndContinueAction:
//==================================================================================

- (IBAction)closePathAndContinueAction:(id)sender
{
    [self closePathAndContinue:YES];
}

//==================================================================================
//	extendPathButtonAction:
//==================================================================================

- (IBAction)extendPathButtonAction:(id)sender
{
    MacSVGDocumentWindowController * macSVGDocumentWindowController =
            [self.macSVGDocument macSVGDocumentWindowController];

    [macSVGDocumentWindowController setToolMode:toolModeCrosshairCursor];

    [macSVGDocumentWindowController setToolMode:toolModePath];
    
    DOMSelectionControlsManager * domSelectionControlsManager =
    macSVGDocumentWindowController.svgXMLDOMSelectionManager.domSelectionControlsManager;

    [domSelectionControlsManager removeDOMSelectionRectsAndHandles];
    
    NSXMLElement * pathElement = self.macSVGPluginCallbacks.svgPathEditorSelectedPathElement;
    
    if (pathElement == NULL)
    {
        // Try to set the path element selection
        [self.macSVGPluginCallbacks buildPathSegmentsArray:self.pluginTargetXMLElement];
        
        pathElement = self.macSVGPluginCallbacks.svgPathEditorSelectedPathElement;
    }
    
    if (pathElement != NULL)
    {
        // add an extra path segment, it will be deleted when path drawing restarts
        NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];
        PathSegment * newPathSegment = [[PathSegment alloc] init];
        newPathSegment.pathCommand = 'Z';
        [pathSegmentsArray addObject:newPathSegment];

        [self.macSVGPluginCallbacks setActiveXMLElement:pathElement];

        id svgWebKitController = macSVGDocumentWindowController.svgWebKitController;
        id domMouseEventsController = [svgWebKitController domMouseEventsController];
        [domMouseEventsController setMouseMode:MOUSE_HOVERING];

        SVGPathEditor * svgPathEditor = [domMouseEventsController svgPathEditor];
        svgPathEditor.editingMode = kPathEditingModeNextSegment;

        [self updateSVGPathEditorAction:self];
    }
    else
    {
        NSBeep();
    }
}


// -------------------------------------------------------------------------------
//  arcSettingsButtonAction:
// -------------------------------------------------------------------------------

- (IBAction)arcSettingsButtonAction:(id)sender
{
    NSButton *targetButton = (NSButton *)sender;

    // configure the preferred position of the popover
    [arcSettingsPopover showRelativeToRect:targetButton.bounds ofView:sender preferredEdge:NSMaxYEdge];
}


//==================================================================================
//	loadSettingsForElement
//==================================================================================

- (void) loadSettingsForElement
{
    NSXMLNode * macsvgidNode = [self.pluginTargetXMLElement attributeForName:@"macsvgid"];
    NSString * selectedElementMacsvgid = macsvgidNode.stringValue;
    self.selectedElementMacsvgid = selectedElementMacsvgid;

    NSString * selectedPathMode = (self.macSVGPluginCallbacks).selectedPathMode;
    
    BOOL useRelativePathCoordinates = (self.macSVGPluginCallbacks).useRelativePathCoordinates;
    
    BOOL closePathAutomatically = (self.macSVGPluginCallbacks).closePathAutomatically;

    NSString * largeArcFlagString = (self.macSVGPluginCallbacks).largeArcFlagString;
    
    NSString * sweepFlagString = (self.macSVGPluginCallbacks).sweepFlagString;
    
    NSString * xAxisRotationString = (self.macSVGPluginCallbacks).xAxisRotationString;
    
    NSString * pathRadiusXString = (self.macSVGPluginCallbacks).pathRadiusXString;
    
    NSString * pathRadiusYString = (self.macSVGPluginCallbacks).pathRadiusYString;
    
    [pathModePopupButton selectItemWithTitle:selectedPathMode];
    
    useRelativePathCoordinatesButton.state = useRelativePathCoordinates;
    closePathAutomaticallyCheckbox.state = closePathAutomatically;
    
    if ([largeArcFlagString isEqualToString:@"1"] == YES)
    {
        [self.arcSettingsPopoverViewController.pathLargeArcCheckbox setState:YES];
    }
    else
    {
        [self.arcSettingsPopoverViewController.pathLargeArcCheckbox setState:NO];
    }
    
    if ([sweepFlagString isEqualToString:@"1"] == YES)
    {
        [self.arcSettingsPopoverViewController.pathSweepCheckbox setState:YES];
    }
    else
    {
        [self.arcSettingsPopoverViewController.pathSweepCheckbox setState:NO];
    }
    
    if ([sweepFlagString isEqualToString:@"1"] == YES)
    {
        [self.arcSettingsPopoverViewController.pathSweepCheckbox setState:YES];
    }
    else
    {
        [self.arcSettingsPopoverViewController.pathSweepCheckbox setState:NO];
    }
    
    (self.arcSettingsPopoverViewController.xAxisRotationTextField).stringValue = xAxisRotationString;
    (self.arcSettingsPopoverViewController.pathRadiusXTextField).stringValue = pathRadiusXString;
    (self.arcSettingsPopoverViewController.pathRadiusYTextField).stringValue = pathRadiusYString;

    NSXMLNode * pathAttributeNode = [self.pluginTargetXMLElement attributeForName:@"d"];
    NSString * pathAttributeString = pathAttributeNode.stringValue;

    NSMutableArray * pathSegmentsArray = [self.macSVGPluginCallbacks buildPathSegmentsArrayWithPathString:pathAttributeString];

    [self.macSVGPluginCallbacks updatePathSegmentsAbsoluteValues:pathSegmentsArray];
    
    [self updateWithPathSegmentsArray:pathSegmentsArray updatePathLength:YES];
    
    [self.pathTableView reloadData];
    
    NSInteger rowIndex = (self.pathTableView).selectedRow;

    if (rowIndex >= 0)
    {
        pathSegmentsArray = [self pathSegmentsArray];

        PathSegment * pathSegment = pathSegmentsArray[rowIndex];
            
        if (pathSegment != NULL)
        {
            [self.pathSegmentEditorPopoverViewController loadPathSegmentData:pathSegment];
        }
    }

    [self updateTotalLengthForPathElement:self.pluginTargetXMLElement];
}

//==================================================================================
//	beginEditForXMLElement:domElement:attributeName:existingValue:
//==================================================================================

- (BOOL)beginEditForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetDOMElement
        attributeName:(NSString *)newAttributeName
        existingValue:(NSString *)existingValue
{
    BOOL result = [super beginEditForXMLElement:newPluginTargetXMLElement
            domElement:newPluginTargetDOMElement
            attributeName:newAttributeName 
            existingValue:existingValue];
            
    [self loadSettingsForElement];
 
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(svgWebViewReloaded:)
            name:@"SVGWebViewReloaded"
            object:nil];

    return result;
}

//==================================================================================
//	beginEditForXMLElement:domElement:nodeKind:
//==================================================================================

- (BOOL)beginEditForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetDOMElement
{
    BOOL result = [super beginEditForXMLElement:newPluginTargetXMLElement
            domElement:newPluginTargetDOMElement];

    [self loadSettingsForElement];

    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(svgWebViewReloaded:)
            name:@"SVGWebViewReloaded"
            object:nil];

    return result;
}

//==================================================================================
//	endEdi:
//==================================================================================

- (void)endEdit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SVGWebViewReloaded" object:NULL];
    
    [super endEdit];
}

//==================================================================================
//	performPathFunctionButtonAction:
//==================================================================================

- (IBAction)performPathFunctionButtonAction:(id)sender
{
    [self.macSVGPluginCallbacks pushUndoRedoDocumentChanges];
    
    [self.pathFunctions performPathFunction];
}

//==================================================================================
//	pathFunctionPopUpButtonAction:
//==================================================================================

- (IBAction)pathFunctionPopUpButtonAction:(id)sender
{
    [self.pathFunctions setInputFieldsForFunction];
}

//==================================================================================
//	numberOfRowsInTableView
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];
    return pathSegmentsArray.count;
}

//==================================================================================
//    tableView:viewForTableColumn:row:
//==================================================================================

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString * tableColumnIdentifier = tableColumn.identifier;
    
    NSString * tableCellIdentifier = [NSString stringWithFormat:@"%@Cell", tableColumnIdentifier];
    
    //NSTableCellView * tableCellView = (NSTableCellView *)[tableView makeViewWithIdentifier:tableColumnIdentifier owner:self];
    NSTableCellView * tableCellView = (NSTableCellView *)[tableView makeViewWithIdentifier:tableCellIdentifier owner:NULL];

    NSString * resultString = [self tableView:tableView objectValueForTableColumn:tableColumn row:row];
    
    tableCellView.textField.stringValue = resultString;
    
    return (NSView *)tableCellView;
}

//==================================================================================
//	tableView:objectValueForTableColumn:rowIndex
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString *  objectValue = @"";
    
    NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];
    
    NSInteger pathSegmentsArrayCount = pathSegmentsArray.count;
    
    if (rowIndex < pathSegmentsArrayCount)
    {
        PathSegment * pathSegment = pathSegmentsArray[rowIndex];
        
        if ([aTableColumn.identifier isEqualToString:@"segmentIndex"] == YES)
        {
            objectValue = [NSString stringWithFormat:@"%ld", (rowIndex + 1)];
        }
        else if ([aTableColumn.identifier isEqualToString:@"segmentCommand"] == YES)
        {
            if (pathSegment != NULL)
            {
                if (pathSegment.pathCommand == 'M')
                {
                    objectValue = @"Moveto";
                }
                //else if ([segmentCommand isEqualToString:@"m"] == YES)
                else if (pathSegment.pathCommand == 'm')
                {
                    objectValue = @"Moveto Relative";
                }
                else if (pathSegment.pathCommand == 'L')
                {
                    objectValue = @"Lineto";
                }
                else if (pathSegment.pathCommand == 'l')
                {
                    objectValue = @"Lineto Relative";
                }
                else if (pathSegment.pathCommand == 'H')
                {
                    objectValue = @"Horizontal Lineto";
                }
                else if (pathSegment.pathCommand == 'h')
                {
                    objectValue = @"Horizontal Lineto Relative";
                }
                else if (pathSegment.pathCommand == 'V')
                {
                    objectValue = @"Vertical Lineto";
                }
                else if (pathSegment.pathCommand == 'v')
                {
                    objectValue = @"Vertical Lineto Relative";
                }
                else if (pathSegment.pathCommand == 'C')
                {
                    objectValue = @"Cubic Curveto";
                }
                else if (pathSegment.pathCommand == 'c')
                {
                    objectValue = @"Cubic Curveto Relative";
                }
                else if (pathSegment.pathCommand == 'S')
                {
                    objectValue = @"Smooth Cubic Curveto";
                }
                else if (pathSegment.pathCommand == 's')
                {
                    objectValue = @"Smooth Cubic Curveto Relative";
                }
                else if (pathSegment.pathCommand == 'Q')
                {
                    objectValue = @"Quadratic Curveto";
                }
                else if (pathSegment.pathCommand == 'q')
                {
                    objectValue = @"Quadratic Curveto Relative";
                }
                else if (pathSegment.pathCommand == 'T')
                {
                    objectValue = @"Smooth Quadratic Curveto";
                }
                else if (pathSegment.pathCommand == 't')
                {
                    objectValue = @"Smooth Quadratic Curveto Relative";
                }
                else if (pathSegment.pathCommand == 'A')
                {
                    objectValue = @"Elliptical Arc";
                }
                else if (pathSegment.pathCommand == 'a')
                {
                    objectValue = @"Elliptical Arc Relative";
                }
                else if (pathSegment.pathCommand == 'Z')
                {
                    objectValue = @"Close Path";
                }
                else if (pathSegment.pathCommand == 'z')
                {
                    objectValue = @"Close Path Relative";
                }
            }
        }
        else if ([aTableColumn.identifier isEqualToString:@"segmentData"] == YES)
        {
            if (pathSegment != NULL)
            {
                NSString * segmentValues = @"";
                
                if (pathSegment.pathCommand == 'M')
                {
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    segmentValues = [NSString stringWithFormat:@"%@ %@",
                            xString, yString];
                }
                else if (pathSegment.pathCommand == 'm')
                {
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    segmentValues = [NSString stringWithFormat:@"%@ %@",
                            xString, yString];
                }
                else if (pathSegment.pathCommand == 'L')
                {
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    segmentValues = [NSString stringWithFormat:@"%@ %@",
                            xString, yString];
                }
                else if (pathSegment.pathCommand == 'l')
                {
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    segmentValues = [NSString stringWithFormat:@"%@ %@",
                            xString, yString];
                }
                else if (pathSegment.pathCommand == 'H')
                {
                    NSString * xString = pathSegment.xString;
                    segmentValues = [NSString stringWithFormat:@"%@",
                            xString];
                }
                else if (pathSegment.pathCommand == 'h')
                {
                    NSString * xString = pathSegment.xString;
                    segmentValues = [NSString stringWithFormat:@"%@",
                            xString];
                }
                else if (pathSegment.pathCommand == 'V')
                {
                    NSString * yString = pathSegment.yString;
                    segmentValues = [NSString stringWithFormat:@"%@",
                            yString];
                }
                else if (pathSegment.pathCommand == 'v')
                {
                    NSString * yString = pathSegment.yString;
                    segmentValues = [NSString stringWithFormat:@"%@",
                            yString];
                }
                else if (pathSegment.pathCommand == 'C')
                {
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    NSString * x1String = pathSegment.x1String;
                    NSString * y1String = pathSegment.y1String;
                    NSString * x2String = pathSegment.x2String;
                    NSString * y2String = pathSegment.y2String;
                    segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",
                            x1String, y1String, x2String, y2String, xString, yString];
                }
                else if (pathSegment.pathCommand == 'c')
                {
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    NSString * x1String = pathSegment.x1String;
                    NSString * y1String = pathSegment.y1String;
                    NSString * x2String = pathSegment.x2String;
                    NSString * y2String = pathSegment.y2String;
                    segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",
                            x1String, y1String, x2String, y2String, xString, yString];
                }
                else if (pathSegment.pathCommand == 'S')
                {
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    NSString * x2String = pathSegment.x2String;
                    NSString * y2String = pathSegment.y2String;
                    segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@",
                            x2String, y2String, xString, yString];
                }
                else if (pathSegment.pathCommand == 's')
                {
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    NSString * x2String = pathSegment.x2String;
                    NSString * y2String = pathSegment.y2String;
                    segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@",
                            x2String, y2String, xString, yString];
                }
                else if (pathSegment.pathCommand == 'Q')
                {
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    NSString * x1String = pathSegment.x1String;
                    NSString * y1String = pathSegment.y1String;
                    segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@",
                            x1String, y1String, xString, yString];
                }
                else if (pathSegment.pathCommand == 'q')
                {
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    NSString * x1String = pathSegment.x1String;
                    NSString * y1String = pathSegment.y1String;
                    segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@",
                            x1String, y1String, xString, yString];
                }
                else if (pathSegment.pathCommand == 'T')
                {
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    segmentValues = [NSString stringWithFormat:@"%@ %@",
                            xString, yString];
                }
                else if (pathSegment.pathCommand == 't')
                {
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    segmentValues = [NSString stringWithFormat:@"%@ %@",
                            xString, yString];
                }
                else if (pathSegment.pathCommand == 'A')
                {
                    NSString * rxString = pathSegment.rxString;
                    NSString * ryString = pathSegment.ryString;
                    NSString * xAxisRotationString = pathSegment.xAxisRotationString;
                    NSString * largeArcFlagString = pathSegment.largeArcFlagString;
                    NSString * sweepFlagString = pathSegment.sweepFlagString;
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@",
                            rxString, ryString, xAxisRotationString, largeArcFlagString, sweepFlagString, xString, yString];
                }
                else if (pathSegment.pathCommand == 'a')
                {
                    NSString * rxString = pathSegment.rxString;
                    NSString * ryString = pathSegment.ryString;
                    NSString * xAxisRotationString = pathSegment.xAxisRotationString;
                    NSString * largeArcFlagString = pathSegment.largeArcFlagString;
                    NSString * sweepFlagString = pathSegment.sweepFlagString;
                    NSString * xString = pathSegment.xString;
                    NSString * yString = pathSegment.yString;
                    segmentValues = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@",
                            rxString, ryString, xAxisRotationString, largeArcFlagString, sweepFlagString, xString, yString];
                }
                else if (pathSegment.pathCommand == 'Z')
                {
                    segmentValues = @"";
                }
                else if (pathSegment.pathCommand == 'z')
                {
                    segmentValues = @"";
                }
                
                objectValue = [NSString stringWithFormat:@"%C %@", pathSegment.pathCommand, segmentValues];
            } 
        }
    }
    
    return objectValue;
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = aNotification.object;
	if (aTableView == self.pathTableView)
	{
        [self refreshSelectedRow];
    }
}

//==================================================================================
//	refreshSelectedRow
//==================================================================================

- (void)refreshSelectedRow
{
    NSInteger rowIndex = (self.pathTableView).selectedRow;

    MacSVGDocumentWindowController * macSVGDocumentWindowController =
            [self.macSVGDocument macSVGDocumentWindowController];

    DOMSelectionControlsManager * domSelectionControlsManager =
            macSVGDocumentWindowController.svgXMLDOMSelectionManager.domSelectionControlsManager;
    
    id svgWebKitController = macSVGDocumentWindowController.svgWebKitController;
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    SVGPathEditor * svgPathEditor = [domMouseEventsController svgPathEditor];
    
    if (rowIndex >= 0)
    {
        if (highlightSelectedSegmentCheckbox.state == YES)
        {
            NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];

            if (rowIndex < pathSegmentsArray.count)
            {
                PathSegment * pathSegment = pathSegmentsArray[rowIndex];
                    
                if (pathSegment != NULL)
                {
                    [self.pathSegmentEditorPopoverViewController loadPathSegmentData:pathSegment];
                }

                //domSelectionControlsManager.pathSegmentIndex = rowIndex;
                svgPathEditor.pathSegmentIndex = rowIndex;
                domSelectionControlsManager.segmentStrokeWidth =
                        (highlightStrokeWidthTextField.stringValue).floatValue;
                domSelectionControlsManager.segmentStrokeHexColor =
                        [self hexColorFromColorWell:highlightColorWell];

                [self highlightPathSegment];
            }
            else
            {
                [self removeHighlightPathSegment];
            }
        }
        else
        {
            [self removeHighlightPathSegment];
        }
    }
    else
    {
        svgPathEditor.pathSegmentIndex = -1;
        
        [self removeHighlightPathSegment];
    }
}

// -------------------------------------------------------------------------------
//  editPathSegmentButtonAction:
// -------------------------------------------------------------------------------

- (IBAction)editPathSegmentButtonAction:(id)sender
{
    self.pathSegmentEditorMode = kEditPathSegment;

    NSButton *targetButton = (NSButton *)sender;

    NSInteger rowIndex = (self.pathTableView).selectedRow;

    NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];

    PathSegment * pathSegment = pathSegmentsArray[rowIndex];
    
    [self.pathSegmentEditorPopoverViewController loadPathSegmentData:pathSegment];
    
    (self.pathSegmentEditorPopoverViewController.applyButton).title = @"Apply";
        
    // configure the preferred position of the popover
    [pathSegmentEditorPopover showRelativeToRect:targetButton.bounds ofView:sender preferredEdge:NSMaxYEdge];
}

// -------------------------------------------------------------------------------
//  addPathSegmentButtonAction:
// -------------------------------------------------------------------------------

- (IBAction)addPathSegmentButtonAction:(id)sender
{
    self.pathSegmentEditorMode = kAddPathSegment;

    NSButton *targetButton = (NSButton *)sender;
    
    NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];
    
    if (pathSegmentsArray.count == 0)
    {
        PathSegment * newPathSegment = [[PathSegment alloc] init];
        newPathSegment.pathCommand = 'M';
        newPathSegment.xFloat = 0;
        newPathSegment.yFloat = 0;
        newPathSegment.absoluteStartXFloat = 0;
        newPathSegment.absoluteStartYFloat = 0;
        newPathSegment.xFloat = 0;
        newPathSegment.yFloat = 0;
        
        [pathSegmentsArray addObject:newPathSegment];
    }

    NSInteger rowIndex = (self.pathTableView).selectedRow;
    
    if (rowIndex == -1)
    {
        rowIndex = pathSegmentsArray.count - 1;
        NSIndexSet * rowIndexSet = [NSIndexSet indexSetWithIndex:rowIndex];
        [self.pathTableView selectRowIndexes:rowIndexSet byExtendingSelection:NO];
    }

    PathSegment * pathSegment = pathSegmentsArray[rowIndex];
    
    [self.pathSegmentEditorPopoverViewController loadPathSegmentData:pathSegment];

    (self.pathSegmentEditorPopoverViewController.applyButton).title = @"Add";
    
    // configure the preferred position of the popover
    [pathSegmentEditorPopover showRelativeToRect:targetButton.bounds ofView:sender preferredEdge:NSMaxYEdge];
}

// -------------------------------------------------------------------------------
//  deletePathSegmentButtonAction:
// -------------------------------------------------------------------------------

- (IBAction)deletePathSegmentButtonAction:(id)sender
{
    NSInteger selectedRow = (self.pathTableView).selectedRow;

    if (selectedRow >= 0)
    {
        [self.macSVGPluginCallbacks pushUndoRedoDocumentChanges];

        [self.pathSegmentsArray removeObjectAtIndex:selectedRow];
        
        [self.macSVGPluginCallbacks updatePathSegmentsAbsoluteValues:self.pathSegmentsArray];
        
        [self updateWithPathSegmentsArray:self.pathSegmentsArray updatePathLength:YES];
    }
}

//==================================================================================
//	pathSegmentsArray
//==================================================================================

- (NSMutableArray * )pathSegmentsArray
{
    id macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
    id svgWebKitController = [macSVGDocumentWindowController svgWebKitController];
    
    NSMutableArray * pathSegmentsArray = [svgWebKitController pathSegmentsArray];
    
    return pathSegmentsArray;
}

//==================================================================================
//	syncDOMElementToXMLDocument:
//==================================================================================

-(void) syncDOMElementToXMLDocument
{
    NSMutableDictionary * newAttributesDictionary = [[NSMutableDictionary alloc] init];

    DOMNamedNodeMap * domAttributes = (self.pluginTargetDOMElement).attributes;
    NSInteger attCount = domAttributes.length;
    
    for (unsigned int a = 0; a < attCount; a++) 
    {
        DOMNode * attributes = [domAttributes item:a];
        NSString * attributeName = attributes.nodeName;
        NSString * attributeValue = attributes.nodeValue;

        NSRange xmlnsRange = [attributeName rangeOfString:@"xmlns"];
        if (xmlnsRange.location != NSNotFound)
        {
            NSLog(@"syncDOMElementToXMLDocument - xmlns namespace found as attribute");
        }
        
        if (attributeName.length > 0)
        {
            unichar firstChar = [attributeName characterAtIndex:0];
            if (firstChar != '_')
            {
                newAttributesDictionary[attributeName] = attributeValue;
            }
        }
    }
    
    [self.pluginTargetXMLElement setAttributesWithDictionary:newAttributesDictionary];
    
}

//==================================================================================
//	setPathDataAttribute
//==================================================================================

-(void) setPathDataAttribute
{
    [self syncDOMElementToXMLDocument];

    [self.macSVGDocument updateSelections]; // update selection rectangles and handles
    
    NSInteger selectedRow = (self.pathTableView).selectedRow;
    [self.pathTableView setNeedsDisplayInRect:[self.pathTableView
            frameOfCellAtColumn:0 row:selectedRow]];

    [self updateTotalLengthForPathElement:(self.macSVGPluginCallbacks).svgPathEditorSelectedPathElement];
}

//==================================================================================
//	tableView:writeRowsWithIndexes:toPasteboard
//==================================================================================

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    
    // archivedDataWithRootObject:requiringSecureCoding:error:
    NSError * archiveDataError = NULL;
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes requiringSecureCoding:NO error:&archiveDataError];

    [pboard declareTypes:@[PathTableViewDataType] owner:self];

    [pboard setData:data forType:PathTableViewDataType];
    
    return YES;
}

//==================================================================================
//	tableView:acceptDrop:row:dropOperation
//==================================================================================

- (BOOL)tableView:(NSTableView*)tableView 
        acceptDrop:(id <NSDraggingInfo>)info 
        row:(NSInteger)row
        dropOperation:(NSTableViewDropOperation)operation
{
    // handle drag-and-drop reordering
    
    NSPasteboard * pboard = [info draggingPasteboard];
    NSData * rowData = [pboard dataForType:PathTableViewDataType];

    NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];

    //NSIndexSet * rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];

    // unarchivedObjectOfClass:fromData:error:
    NSError * archiveDataError = NULL;
    NSIndexSet * rowIndexes = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSIndexSet class] fromData:rowData error:&archiveDataError];

    NSInteger from = rowIndexes.firstIndex;

    NSMutableDictionary * traveller = pathSegmentsArray[from];
    
    NSInteger length = pathSegmentsArray.count;
    //NSMutableArray * replacement = [NSMutableArray new];

    NSInteger i;
    for (i = 0; i <= length; i++)
    {
        if (i == row)
        {
            if (from > row)
            {
                [pathSegmentsArray insertObject:traveller atIndex:row];
                [pathSegmentsArray removeObjectAtIndex:(from + 1)];
            }
            else
            {
                [pathSegmentsArray insertObject:traveller atIndex:row];
                [pathSegmentsArray removeObjectAtIndex:from];
            }
        }
    }
    
    [self.pathTableView reloadData];

    [self updateTotalLengthForPathElement:(self.macSVGPluginCallbacks).svgPathEditorSelectedPathElement];
    
    [self setPathDataAttribute];

    [self updateWithPathSegmentsArray:pathSegmentsArray updatePathLength:NO];
    [self updateDocumentViews];
    
    return YES;
}


//==================================================================================
//	tableView:validateDrop:proposedRow:proposedDropOperation:
//==================================================================================

- (NSDragOperation)tableView:(NSTableView*)tableView 
        validateDrop:(id <NSDraggingInfo>)info 
        proposedRow:(NSInteger)row
        proposedDropOperation:(NSTableViewDropOperation)operation
{
    return NSDragOperationEvery;
}


//==================================================================================
//	handlePluginEvent
//==================================================================================

-(void) handlePluginEvent:(DOMEvent *)event
{
    // Our callback from WebKit
    NSString * eventType = event.type;
    
    DOMNode * targetNode = self.pluginTargetDOMElement;
    
    DOMElement * targetElement = (DOMElement *)targetNode;
    NSString * tagName = targetElement.tagName;
    #pragma unused(tagName)

    if ([eventType isEqualToString:@"dblclick"] == YES) // use mouseUp instead
    {
        //
    }
    else if ([eventType isEqualToString:@"mousedown"] == YES)
    {
        //
    }
    else if ([eventType isEqualToString:@"mousemove"] == YES)
    {
        //
    }
    else if ([eventType isEqualToString:@"mouseup"] == YES)
    {
        //
    }
    else if ([eventType isEqualToString:@"focus"] == YES)
    {
        //
    }
    else if ([eventType isEqualToString:@"blur"] == YES)
    {
        //
    }
    else if ([eventType isEqualToString:@"keydown"] == YES)
    {
        //
    }
    else if ([eventType isEqualToString:@"keypress"] == YES)
    {
        //
    }
    else if ([eventType isEqualToString:@"keyup"] == YES)
    {
        //
    }
}

//==================================================================================
//	setTransformAttribute
//==================================================================================

-(void) setTransformAttribute
{
    NSLog(@"PathElementEditor - setTranformAttribute method needed here");
}

//==================================================================================
//	highlightSelectedSegmentCheckboxAction:
//==================================================================================

-(IBAction)highlightSelectedSegmentCheckboxAction:(id)sender
{
    MacSVGDocumentWindowController * macSVGDocumentWindowController =
            [self.macSVGDocument macSVGDocumentWindowController];

    id svgWebKitController = macSVGDocumentWindowController.svgWebKitController;
    id domMouseEventsController = [svgWebKitController domMouseEventsController];
    SVGPathEditor * svgPathEditor = [domMouseEventsController svgPathEditor];
    
    svgPathEditor.highlightSelectedSegment = highlightSelectedSegmentCheckbox.state;
    
    [self refreshSelectedRow];
}

//==================================================================================
//	highlightPathSegment
//==================================================================================

- (void)highlightPathSegment
{
    if (highlightSelectedSegmentCheckbox.state == YES)
    {
        NSInteger selectedRow = (self.pathTableView).selectedRow;

        if (selectedRow != -1)
        {
            NSWindow * keyWindow = NSApp.keyWindow;
            id firstResponder = keyWindow.firstResponder;
            if (firstResponder != self.pathTableView)
            {
                [keyWindow makeFirstResponder:self.pathTableView];
            }

            MacSVGDocumentWindowController * macSVGDocumentWindowController = [self.macSVGDocument macSVGDocumentWindowController];
            
            DOMSelectionControlsManager * domSelectionControlsManager =
                    macSVGDocumentWindowController.svgXMLDOMSelectionManager.domSelectionControlsManager;
            
            domSelectionControlsManager.segmentStrokeWidth = 0;
            if (highlightUseCustomStrokeWidthCheckbox.state == YES)
            {
                domSelectionControlsManager.segmentStrokeWidth = (highlightStrokeWidthTextField.stringValue).floatValue;
            }
    
            domSelectionControlsManager.segmentStrokeHexColor = [self hexColorFromColorWell:highlightColorWell];

            [domSelectionControlsManager highlightPathSegment];
        }
    }
    else
    {
        [self removeHighlightPathSegment];
    }
}

//==================================================================================
//	removeHighlightPathSegment
//==================================================================================

- (void)removeHighlightPathSegment
{
    NSInteger selectedRow = (self.pathTableView).selectedRow;

    if (selectedRow != -1)
    {
        MacSVGDocumentWindowController * macSVGDocumentWindowController =
                [self.macSVGDocument macSVGDocumentWindowController];
        
        DOMSelectionControlsManager * domSelectionControlsManager =
                macSVGDocumentWindowController.svgXMLDOMSelectionManager.domSelectionControlsManager;
        
        [domSelectionControlsManager removeDOMPathSegmentHighlight];
    }
}

//==================================================================================
//	hexColorFromColorWell:
//==================================================================================

- (NSString *)hexColorFromColorWell:(NSColorWell *)aColorWell
{
    NSColor * aColor = aColorWell.color;
    
    NSString * hexColor = [self hexadecimalValueOfAnNSColor:aColor];
    
    return hexColor;
}

//==================================================================================
//	hexadecimalValueOfAnNSColor:
//==================================================================================

-(NSString *)hexadecimalValueOfAnNSColor:(NSColor *)aColor
{
    CGFloat redFloatValue, greenFloatValue, blueFloatValue;
    int redIntValue, greenIntValue, blueIntValue;
    NSString *redHexValue, *greenHexValue, *blueHexValue;

    // Convert the NSColor to the RGB color space before we can access its components
    //NSColor * convertedColor = [aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    NSColor * convertedColor = [aColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
    
    if(convertedColor)
    {
        // Get the red, green, and blue components of the color
        [convertedColor getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];

        // Convert the components to numbers (unsigned decimal integer) between 0 and 255
        redIntValue = redFloatValue * 255.99999f;
        greenIntValue = greenFloatValue * 255.99999f;
        blueIntValue = blueFloatValue * 255.99999f;

        // Convert the numbers to hex strings
        redHexValue=[NSString stringWithFormat:@"%02x", redIntValue]; 
        greenHexValue=[NSString stringWithFormat:@"%02x", greenIntValue];
        blueHexValue=[NSString stringWithFormat:@"%02x", blueIntValue];

        // Concatenate the red, green, and blue components' hex strings together with a "#"
        return [NSString stringWithFormat:@"#%@%@%@", redHexValue, greenHexValue, blueHexValue];
    }
    return nil;
}

//==================================================================================
//	subdivideSegmentButtonAction:
//==================================================================================

- (IBAction)subdivideSegmentButtonAction:(id)sender
{
    // adapted from http://antigrain.com/research/adaptive_bezier/#toc0003
    // and http://www.ericeastwood.com/blog/25/curves-and-arcs-quadratic-cubic-elliptical-svg-implementations
    
    NSInteger selectedRow = (self.pathTableView).selectedRow;

    NSMutableArray * pathSegmentsArray = [self pathSegmentsArray];
    
    if (selectedRow != -1)
    {
        PathSegment * pathSegment = pathSegmentsArray[selectedRow];

        PathSegment * newPathSegment = [[PathSegment alloc] init];
        [newPathSegment copyValuesFromPathSegment:pathSegment];

        // get starting point of segment

        NSString * startXString = pathSegment.xString;
        NSString * startYString = pathSegment.yString;
        NSString * previousX1String = pathSegment.x1String;
        NSString * previousY1String = pathSegment.y1String;
        NSString * previousX2String = pathSegment.x2String;
        NSString * previousY2String = pathSegment.y2String;
        
        unichar previousPathCommand = ' ';
        
        if (selectedRow > 0)
        {
            // get current starting point from previous segment
            
            PathSegment * previousPathSegment = pathSegmentsArray[(selectedRow - 1)];

            startXString = previousPathSegment.xString;
            startYString = previousPathSegment.yString;
            previousX1String = pathSegment.x1String;
            previousY1String = pathSegment.y1String;
            previousX2String = pathSegment.x2String;
            previousY2String = pathSegment.y2String;
            previousPathCommand = previousPathSegment.pathCommand;
        }
        
        if (startXString.length == 0)
        {
            startXString = @"0";
        }
        if (startYString.length == 0)
        {
            startYString = @"0";
        }
        if (previousX1String.length == 0)
        {
            previousX1String = @"0";
        }
        if (previousY1String.length == 0)
        {
            previousY1String = @"0";
        }
        if (previousX2String.length == 0)
        {
            previousX2String = @"0";
        }
        if (previousY2String.length == 0)
        {
            previousY2String = @"0";
        }
        
        float startX = startXString.floatValue;
        float startY = startYString.floatValue;
        float previousX1 = previousX1String.floatValue;
        float previousY1 = previousY1String.floatValue;
        
        unichar commandChar = pathSegment.pathCommand;
        
        BOOL subdividablePathFound = NO;
        
        // define the path segment
        switch (commandChar) 
        {
            case 'M':     // absolute moveto
            case 'm':     // relative moveto
            {
                // we can't subdivide a move path segment
                
                subdividablePathFound = NO;
                
                break;
            }
            case 'L':     // absolute lineto
            case 'l':     // relative lineto
            {
                subdividablePathFound = YES;

                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;
                
                float x = xString.floatValue;
                float y = yString.floatValue;
                
                float midX = (x + startX) / 2.0f;
                float midY = (y + startY) / 2.0f;
                
                NSString * midXString = [self allocFloatString:midX];
                NSString * midYString = [self allocFloatString:midY];
                
                pathSegment.xString = midXString;
                pathSegment.yString = midYString;

                newPathSegment.xString = xString;
                newPathSegment.yString = yString;

                break;
            }
            case 'H':     // absolute horizontal lineto
            case 'h':     // absolute horizontal lineto
            {
                subdividablePathFound = YES;

                NSString * xString = pathSegment.xString;
                float x = xString.floatValue;

                float midX = (x + startX) / 2.0f;
                NSString * midXString = [self allocFloatString:midX];

                pathSegment.xString = midXString;
                newPathSegment.xString = xString;
                
                break;
            }
            case 'V':     // absolute vertical lineto
            case 'v':     // absolute vertical lineto
            {
                subdividablePathFound = YES;

                NSString * yString = pathSegment.yString;
                float y = yString.floatValue;

                float midY = (y + startY) / 2.0f;
                NSString * midYString = [self allocFloatString:midY];

                pathSegment.yString = midYString;
                newPathSegment.yString = yString;

                break;
            }
            case 'C':     // absolute cubic curveto
            case 'c':     // absolute cubic curveto
            {
                subdividablePathFound = YES;

                NSString * x1String = pathSegment.x1String;
                NSString * y1String = pathSegment.y1String;
                NSString * x2String = pathSegment.x2String;
                NSString * y2String = pathSegment.y2String;
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;
                
                float x1 = x1String.floatValue;
                float y1 = y1String.floatValue;
                float x2 = x2String.floatValue;
                float y2 = y2String.floatValue;
                float x = xString.floatValue;
                float y = yString.floatValue;
                
                float x12 = (startX + x1) / 2.0f;
                float y12 = (startY + y1) / 2.0f;
                float x23 = (x1 + x2) / 2.0f;
                float y23 = (y1 + y2) / 2.0f;
                float x34 = (x2 + x) / 2.0f;
                float y34 = (y2 + y) / 2.0f;
                float x123  = (x12 + x23) / 2.0f;
                float y123  = (y12 + y23) / 2.0f;
                float x234  = (x23 + x34) / 2.0f;
                float y234  = (y23 + y34) / 2.0f;
                float x1234 = (x123 + x234) / 2.0f;
                float y1234 = (y123 + y234) / 2.0f;
                
                NSString * x12String = [self allocFloatString:x12];
                NSString * y12String = [self allocFloatString:y12];
                //NSString * x23String = [self allocFloatString:x23];
                //NSString * y23String = [self allocFloatString:y23];
                NSString * x34String = [self allocFloatString:x34];
                NSString * y34String = [self allocFloatString:y34];
                NSString * x123String = [self allocFloatString:x123];
                NSString * y123String = [self allocFloatString:y123];
                NSString * x234String = [self allocFloatString:x234];
                NSString * y234String = [self allocFloatString:y234];
                NSString * x1234String = [self allocFloatString:x1234];
                NSString * y1234String = [self allocFloatString:y1234];
                
                pathSegment.x1String = x12String;
                pathSegment.y1String = y12String;
                pathSegment.x2String = x123String;
                pathSegment.y2String = y123String;
                pathSegment.xString = x1234String;
                pathSegment.yString = y1234String;

                newPathSegment.x1String = x234String;
                newPathSegment.y1String = y234String;
                newPathSegment.x2String = x34String;
                newPathSegment.y2String = y34String;
                newPathSegment.xString = xString;
                newPathSegment.yString = yString;
                break;
            }
            case 'S':     // absolute smooth cubic curveto
            case 's':     // relative smooth cubic curveto
            {
                subdividablePathFound = YES;

                float x1 = startX - previousX1;
                float y1 = startY - previousY1;

                NSString * x2String = pathSegment.x2String;
                NSString * y2String = pathSegment.y2String;
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;
                
                float x2 = x2String.floatValue;
                float y2 = y2String.floatValue;
                float x = xString.floatValue;
                float y = yString.floatValue;
                
                float x12 = (startX + x1) / 2.0f;
                float y12 = (startY + y1) / 2.0f;
                float x23 = (x1 + x2) / 2.0f;
                float y23 = (y1 + y2) / 2.0f;
                float x34 = (x2 + x) / 2.0f;
                float y34 = (y2 + y) / 2.0f;
                float x123  = (x12 + x23) / 2.0f;
                float y123  = (y12 + y23) / 2.0f;
                float x234  = (x23 + x34) / 2.0f;
                float y234  = (y23 + y34) / 2.0f;
                float x1234 = (x123 + x234) / 2.0f;
                float y1234 = (y123 + y234) / 2.0f;
                
                NSString * x34String = [self allocFloatString:x34];
                NSString * y34String = [self allocFloatString:y34];
                NSString * x123String = [self allocFloatString:x123];
                NSString * y123String = [self allocFloatString:y123];
                NSString * x1234String = [self allocFloatString:x1234];
                NSString * y1234String = [self allocFloatString:y1234];

                pathSegment.x2String = x123String;
                pathSegment.y2String = y123String;
                pathSegment.xString = x1234String;
                pathSegment.yString = y1234String;

                newPathSegment.x2String = x34String;
                newPathSegment.y2String = y34String;
                newPathSegment.xString = xString;
                newPathSegment.yString = yString;
                break;
            }
            case 'Q':     // absolute quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
            {
                subdividablePathFound = YES;

                NSString * x1String = pathSegment.x1String;
                NSString * y1String = pathSegment.y1String;
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;

                float x1 = x1String.floatValue;
                float y1 = y1String.floatValue;
                float x = xString.floatValue;
                float y = yString.floatValue;
                
                float control1MidpointX = (startX + x1) / 2.0f;
                float control1MidpointY = (startY + y1) / 2.0f;

                float control2MidpointX = (x1 + x) / 2.0f;
                float control2MidpointY = (x1 + x) / 2.0f;
                
                float midpointX = [self calculateQuadraticBezierParameterAtx0:startX x1:x1 x2:x t:0.5f];
                float midpointY = [self calculateQuadraticBezierParameterAtx0:startY x1:y1 x2:y t:0.5f];
                
                NSString * control1MidpointXString = [self allocFloatString:control1MidpointX];
                NSString * control1MidpointYString = [self allocFloatString:control1MidpointY];
                NSString * control2MidpointXString = [self allocFloatString:control2MidpointX];
                NSString * control2MidpointYString = [self allocFloatString:control2MidpointY];
                NSString * midpointXString = [self allocFloatString:midpointX];
                NSString * midpointYString = [self allocFloatString:midpointY];

                pathSegment.x1String = control1MidpointXString;
                pathSegment.y1String = control1MidpointYString;
                pathSegment.xString = midpointXString;
                pathSegment.yString = midpointYString;

                newPathSegment.x1String = control2MidpointXString;
                newPathSegment.y1String = control2MidpointYString;
                newPathSegment.xString = xString;
                newPathSegment.yString = yString;
                break;
            }

            case 'T':     // absolute smooth quadratic Bezier curve
            case 't':     // relative smooth quadratic Bezier curve
            {
                subdividablePathFound = NO; // this is managed in the subroutine instead
                
                [self subdivideSmoothQuadraticAtSegementIndex:selectedRow pathSegmentsArray:pathSegmentsArray];
            
                break;
            }

            
            case 'A':     // absolute elliptical arc
            case 'a':     // relative elliptical arc
            {
                subdividablePathFound = YES;
                
                NSString * rxString = pathSegment.rxString;
                NSString * ryString = pathSegment.ryString;
                NSString * dataXAxisRotationString = pathSegment.xAxisRotationString;
                NSString * dataLargeArcString = pathSegment.largeArcFlagString;
                NSString * sweepString = pathSegment.sweepFlagString;
                NSString * xString = pathSegment.xString;
                NSString * yString = pathSegment.yString;

                float rx = rxString.floatValue;
                float ry = ryString.floatValue;
                float x = xString.floatValue;
                float y = yString.floatValue;
                float dataXAxisRotation = dataXAxisRotationString.floatValue;
                BOOL largeArcFlag = dataLargeArcString.boolValue;
                BOOL sweepFlag = sweepString.boolValue;
                
                CGPoint startPoint = CGPointMake(startX, startY);
                CGPoint endPoint = CGPointMake(x, y);
                
                NSDictionary * arcCenterDictionary = [self.macSVGPluginCallbacks convertArcToCenterPointWithStart:startPoint end:endPoint
                        rx:rx ry:ry rotation:dataXAxisRotation isLarge:largeArcFlag isCounterClockwise:sweepFlag];
                
                NSNumber * angleStartNumber = arcCenterDictionary[@"angleStart"];
                NSNumber * angleExtentNumber = arcCenterDictionary[@"angleExtent"];
                NSNumber * cxNumber = arcCenterDictionary[@"cx"];
                NSNumber * cyNumber = arcCenterDictionary[@"cy"];
                
                float angleStart = angleStartNumber.floatValue;
                float angleExtent = angleExtentNumber.floatValue;
                float cx = cxNumber.floatValue;
                float cy = cyNumber.floatValue;
                
                float halfAngleExtent = angleExtent / 2.0f;

                float angle1Start = angleStart;
                float angle2Start = angleStart + halfAngleExtent;
                
                NSDictionary * arc1Dictionary = [self.macSVGPluginCallbacks convertArcToEndPointWithRotation:dataXAxisRotation
                        angleStart:angle1Start angleExtent:halfAngleExtent cx:cx cy:cy rx:rx ry:ry];
                
                NSNumber * arc1EndXNumber = arc1Dictionary[@"endX"];
                NSNumber * arc1EndYNumber = arc1Dictionary[@"endY"];
                NSNumber * arc1IsCounterClockwiseNumber = arc1Dictionary[@"isCounterClockwise"];
                NSNumber * arc1IsLargeNumber = arc1Dictionary[@"isLarge"];
                
                float arc1EndX = arc1EndXNumber.floatValue;
                float arc1EndY = arc1EndYNumber.floatValue;
                BOOL arc1SweepFlag = arc1IsCounterClockwiseNumber.boolValue;
                BOOL arc1LargeArcFlag = arc1IsLargeNumber.boolValue;
                
                NSString * arc1EndXString = [self allocFloatString:arc1EndX];
                NSString * arc1EndYString = [self allocFloatString:arc1EndY];
                NSString * arc1SweepFlagString = [NSString stringWithFormat:@"%hhd", arc1SweepFlag];
                NSString * arc1LargeArcFlagString = [NSString stringWithFormat:@"%hhd", arc1LargeArcFlag];

                pathSegment.rxString = rxString;
                pathSegment.ryString = ryString;
                pathSegment.xAxisRotationString = dataXAxisRotationString;
                pathSegment.largeArcFlagString = arc1LargeArcFlagString;
                pathSegment.sweepFlagString = arc1SweepFlagString;
                pathSegment.xString = arc1EndXString;
                pathSegment.yString = arc1EndYString;
                
                NSDictionary * arc2Dictionary = [self.macSVGPluginCallbacks convertArcToEndPointWithRotation:dataXAxisRotation angleStart:angle2Start angleExtent:halfAngleExtent cx:cx cy:cy rx:rx ry:ry];

                NSNumber * arc2EndXNumber = arc2Dictionary[@"endX"];
                NSNumber * arc2EndYNumber = arc2Dictionary[@"endY"];
                NSNumber * arc2IsCounterClockwiseNumber = arc2Dictionary[@"isCounterClockwise"];
                NSNumber * arc2IsLargeNumber = arc2Dictionary[@"isLarge"];

                float arc2EndX = arc2EndXNumber.floatValue;
                float arc2EndY = arc2EndYNumber.floatValue;
                BOOL arc2SweepFlag = arc2IsCounterClockwiseNumber.boolValue;
                BOOL arc2LargeArcFlag = arc2IsLargeNumber.boolValue;
                
                NSString * arc2EndXString = [self allocFloatString:arc2EndX];
                NSString * arc2EndYString = [self allocFloatString:arc2EndY];
                NSString * arc2SweepFlagString = [NSString stringWithFormat:@"%hhd", arc2SweepFlag];
                NSString * arc2LargeArcFlagString = [NSString stringWithFormat:@"%hhd", arc2LargeArcFlag];

                newPathSegment.rxString = rxString;
                newPathSegment.ryString = ryString;
                newPathSegment.xAxisRotationString = dataXAxisRotationString;
                newPathSegment.largeArcFlagString = arc2LargeArcFlagString;
                newPathSegment.sweepFlagString = arc2SweepFlagString;
                newPathSegment.xString = arc2EndXString;
                newPathSegment.yString = arc2EndYString;
                break;
            }
            case 'Z':     // absolute closepath
            case 'z':     // relative closepath
            {
                // we can't subdivide a close-path segment
                
                subdividablePathFound = NO;
                break;
            }
        }
        
        if (subdividablePathFound == YES)
        {
            [pathSegmentsArray insertObject:newPathSegment atIndex:(selectedRow + 1)];
        }

            
        [self.macSVGPluginCallbacks updatePathSegmentsAbsoluteValues:pathSegmentsArray];
        
        [self updateWithPathSegmentsArray:pathSegmentsArray updatePathLength:YES];

        [self.pathTableView reloadData];

        [self updateTotalLengthForPathElement:(self.macSVGPluginCallbacks).svgPathEditorSelectedPathElement];
        
        [self.macSVGPluginCallbacks setActiveXMLElement:self.pluginTargetXMLElement];

        [self.macSVGPluginCallbacks setToolMode:toolModeCrosshairCursor];
        
        [self highlightPathSegment];
    }
}

//==================================================================================
//	subdivideSmoothQuadraticAtSegementIndex:pathSegmentsArray:
//==================================================================================

- (void)subdivideSmoothQuadraticAtSegementIndex:(NSInteger)segmentIndex pathSegmentsArray:(NSMutableArray *)pathSegmentsArray
{
    [self.macSVGPluginCallbacks updatePathSegmentsAbsoluteValues:pathSegmentsArray];

    unichar previousCommandCharacter = ' ';
    PathSegment * previousSegment = NULL;
    CGPoint controlPoint = NSZeroPoint;

    for (NSInteger currentSegmentIndex = 0; currentSegmentIndex <= segmentIndex; currentSegmentIndex++)
    {
        PathSegment * pathSegment = pathSegmentsArray[currentSegmentIndex];
    
        float absoluteStartXFloat = pathSegment.absoluteStartXFloat;
        float absoluteStartYFloat = pathSegment.absoluteStartYFloat;
        
        float absoluteXFloat = pathSegment.absoluteXFloat;
        float absoluteYFloat = pathSegment.absoluteYFloat;

        NSString * xString = pathSegment.xString;
        NSString * yString = pathSegment.yString;
        
        if (currentSegmentIndex == 0)
        {
            controlPoint = CGPointMake(absoluteStartXFloat, absoluteStartYFloat);
        }

        unichar commandCharacter = pathSegment.pathCommand;

        switch (commandCharacter)
        {
            case 'M':     // moveto
            case 'm':     // moveto
                break;
            
            case 'L':     // lineto
            case 'l':     // lineto
                break;

            case 'H':     // horizontal lineto
            case 'h':     // horizontal lineto
                break;

            case 'V':     // vertical lineto
            case 'v':     // vertical lineto
                break;

            case 'C':     // curveto
            case 'c':     // curveto
                break;

            case 'S':     // smooth curveto
            case 's':     // smooth curveto
                break;

            case 'Q':     // quadratic Bezier curve
            case 'q':     // quadratic Bezier curve
            {
                float oldAbsoluteX1Float = pathSegment.absoluteX1Float;    // quadratic x1,y1
                float oldAbsoluteY1Float = pathSegment.absoluteY1Float;

                controlPoint = CGPointMake(oldAbsoluteX1Float, oldAbsoluteY1Float);
                
                break;
            }

            case 'T':     // smooth quadratic Bezier curve
            case 't':     // smooth quadratic Bezier curve
            {
                // Based on WebKitSVGPathParser::parseCurveToQuadraticSmoothSegment()
                // to get cubic x1,x2 and quadratic control point for a quadratic smooth segment
                // from https://github.com/WebKit/webkit/blob/master/Source/WebCore/svg/SVGPathParser.cpp

                CGPoint currentPoint = CGPointMake(absoluteStartXFloat, absoluteStartYFloat);
                CGPoint targetPoint = CGPointMake(absoluteXFloat, absoluteYFloat);
                
                CGPoint point1 = currentPoint;
                CGPoint point2 = targetPoint;

                if (currentSegmentIndex > 0)
                {
                    switch (previousCommandCharacter)
                    {
                        case 'Q':
                        case 'q':
                        case 'T':
                        case 't':
                        {
                            break;
                        }
                        default:
                        {
                            controlPoint = currentPoint;
                        }
                    }
                    
                    CGPoint cubicPoint = currentPoint;
                    cubicPoint.x *= 2.0f;
                    cubicPoint.y *= 2.0f;
                    cubicPoint.x -= controlPoint.x;
                    cubicPoint.y -= controlPoint.y;
                    
                    point1 = CGPointMake((currentPoint.x + (2.0f * cubicPoint.x)), (currentPoint.y + (2.0f * cubicPoint.y)));
                    point2 = CGPointMake((targetPoint.x + (2.0f * cubicPoint.x)), (targetPoint.y + (2.0f * cubicPoint.y)));
                    
                    point1.x /= 3.0f;
                    point1.y /= 3.0f;
                    point2.x /= 3.0f;
                    point2.y /= 3.0f;
                    
                    controlPoint = cubicPoint;
                }

                if (currentSegmentIndex == segmentIndex)
                {
                    NSString * controlPointXString = [self allocFloatString:controlPoint.x];
                    NSString * controlPointYString = [self allocFloatString:controlPoint.y];
                    
                    unichar newCommand = 'Q';
                    if (commandCharacter == 't')
                    {
                        newCommand = 'q';
                    }

                    pathSegment.x1String = controlPointXString;
                    pathSegment.y1String = controlPointYString;
                    pathSegment.pathCommand = newCommand;
                    
                    PathSegment * newPathSegment = [[PathSegment alloc] init];
                    newPathSegment.xString = xString;
                    newPathSegment.yString = yString;
                    newPathSegment.x1String = controlPointXString;
                    newPathSegment.y1String = controlPointYString;
                    newPathSegment.pathCommand = newCommand;
                    
                    [pathSegmentsArray insertObject:newPathSegment atIndex:(segmentIndex + 1)];
                }
                
                break;
            }

            case 'A':     // elliptical arc
            case 'a':     // elliptical arc
                break;

            case 'Z':     // closepath
            case 'z':     // closepath
                break;
        }
        
        previousCommandCharacter = commandCharacter;
        previousSegment = pathSegment;
    }

    [self.macSVGPluginCallbacks updatePathSegmentsAbsoluteValues:pathSegmentsArray];
}

//==================================================================================
//	calculateQuadraticBezierParameterAtx0:x1:x2:t:
//==================================================================================

- (float)calculateQuadraticBezierParameterAtx0:(float)x0 x1:(float)x1 x2:(float)x2 t:(float)t
{
    float result = pow(1 - t, 2) * x0 + 2 * t * (1 - t) * x1 + pow(t, 2) * x2;
    
    return result;
}

//==================================================================================
//	pointOnQuadraticBezierCurveAtp0:p1:p2:t:
//==================================================================================

- (CGPoint)pointOnQuadraticBezierCurveAtp0:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2 t:(float)t
{
    float x = [self calculateQuadraticBezierParameterAtx0:p0.x x1:p1.x x2:p2.x t:t];
    float y = [self calculateQuadraticBezierParameterAtx0:p0.y x1:p1.y x2:p2.y t:t];
    
    CGPoint resultPoint = CGPointMake(x, y);
    return resultPoint;
};

//==================================================================================
//	contextMenuItemsForPlugin
//==================================================================================

- (NSMutableArray *) contextMenuItemsForPlugin
{
    // override to customize contextual menu for right-click in web view
    NSMutableArray * contextMenuItems = [NSMutableArray array];
    
    if ([self.macSVGPluginCallbacks currentToolMode] == toolModePath)
    {
        NSMenuItem * closePathMenuItem = [[NSMenuItem alloc] initWithTitle:@"Close Path" action:@selector(closePathNowButtonAction:) keyEquivalent:@""];
        [closePathMenuItem setTarget:self];
        [contextMenuItems addObject:closePathMenuItem];
        
        NSMenuItem * closePathAndContinueMenuItem = [[NSMenuItem alloc] initWithTitle:@"Close Path and Continue" action:@selector(closePathAndContinueAction:) keyEquivalent:@""];
        [closePathAndContinueMenuItem setTarget:self];
        [contextMenuItems addObject:closePathAndContinueMenuItem];
        
        NSMenuItem * movetoMenuItem = [[NSMenuItem alloc] initWithTitle:@"Move To" action:@selector(setPathMode:) keyEquivalent:@""];
        [movetoMenuItem setTarget:self];
        [contextMenuItems addObject:movetoMenuItem];

        NSMenuItem * linetoMenuItem = [[NSMenuItem alloc] initWithTitle:@"Line To" action:@selector(setPathMode:) keyEquivalent:@""];
        [linetoMenuItem setTarget:self];
        [contextMenuItems addObject:linetoMenuItem];

        NSMenuItem * cubicCurveMenuItem = [[NSMenuItem alloc] initWithTitle:@"Cubic Curve" action:@selector(setPathMode:) keyEquivalent:@""];
        [cubicCurveMenuItem setTarget:self];
        [contextMenuItems addObject:cubicCurveMenuItem];

        NSMenuItem * ellipticalArcMenuItem = [[NSMenuItem alloc] initWithTitle:@"Elliptical Arc" action:@selector(setPathMode:) keyEquivalent:@""];
        [ellipticalArcMenuItem setTarget:self];
        [contextMenuItems addObject:ellipticalArcMenuItem];

        NSString * pathMode = pathModePopupButton.titleOfSelectedItem;
        
        if ([pathMode isEqualToString:@"Elliptical Arc"] == YES)
        {
            NSString * largeArcTitle = @"Large Arc On";
            NSString * largeArcFlagString = (self.macSVGPluginCallbacks).largeArcFlagString;
            if ([largeArcFlagString isEqualToString:@"1"] == YES)
            {
                largeArcTitle = @"Large Arc Off";
            }
            NSMenuItem * largeArcMenuItem = [[NSMenuItem alloc] initWithTitle:largeArcTitle action:@selector(toggleLargeArcValue) keyEquivalent:@""];
            [largeArcMenuItem setTarget:self];
            [contextMenuItems addObject:largeArcMenuItem];

            NSString * sweepFlagTitle = @"Sweep Flag On";
            NSString * sweepFlagString = (self.macSVGPluginCallbacks).sweepFlagString;
            if ([sweepFlagString isEqualToString:@"1"] == YES)
            {
                sweepFlagTitle = @"Sweep Flag Off";
            }
            NSMenuItem * sweepFlagMenuItem = [[NSMenuItem alloc] initWithTitle:sweepFlagTitle action:@selector(toggleSweepFlagValue) keyEquivalent:@""];
            [sweepFlagMenuItem setTarget:self];
            [contextMenuItems addObject:sweepFlagMenuItem];
        }
    }
    
    return contextMenuItems;
}

-(IBAction)setPathMode:(NSMenuItem *)menuItem
{
    NSString * pathMode = [menuItem title];
    
    [pathModePopupButton selectItemWithTitle:pathMode];

    [self updateSVGPathEditorAction:self];
}


-(IBAction)toggleLargeArcValue
{
    NSString * largeArcFlagString = (self.macSVGPluginCallbacks).largeArcFlagString;
    if ([largeArcFlagString isEqualToString:@"1"] == YES)
    {
        //(self.macSVGPluginCallbacks).largeArcFlagString = @"0";
        (self.arcSettingsPopoverViewController.pathLargeArcCheckbox).state = 0;
    }
    else
    {
        //(self.macSVGPluginCallbacks).largeArcFlagString = @"1";
        (self.arcSettingsPopoverViewController.pathLargeArcCheckbox).state = 1;
    }

    [self updateSVGPathEditorAction:self];
}


-(IBAction)toggleSweepFlagValue
{
    NSString * sweepFlagString = (self.macSVGPluginCallbacks).sweepFlagString;
    if ([sweepFlagString isEqualToString:@"1"] == YES)
    {
        //(self.macSVGPluginCallbacks).sweepFlagString = @"0";
        (self.arcSettingsPopoverViewController.pathSweepCheckbox).state = 0;
    }
    else
    {
        //(self.macSVGPluginCallbacks).sweepFlagString = @"1";
        (self.arcSettingsPopoverViewController.pathSweepCheckbox).state = 1;
    }

    [self updateSVGPathEditorAction:self];
}


@end

#pragma clang diagnostic pop
