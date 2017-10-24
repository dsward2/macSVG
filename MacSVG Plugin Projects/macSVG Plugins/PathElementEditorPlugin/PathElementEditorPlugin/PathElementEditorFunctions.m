//
//  PathElementEditorFunctions.m
//  PathElementEditor
//
//  Created by Douglas Ward on 8/7/16.
//
//

#import "PathElementEditorFunctions.h"
#import "PathElementEditor.h"

@implementation PathElementEditorFunctions

//==================================================================================
//	performPathFunction
//==================================================================================

- (void)performPathFunction
{
    NSString * functionTitle = (self.pathElementEditor.pathFunctionsPopupButton).titleOfSelectedItem;
    
    if ([functionTitle isEqualToString:@"Convert to Absolute Coordinates"] == YES)
    {
        [self convertToAbsoluteCoordinates];
    }

    if ([functionTitle isEqualToString:@"Convert Curves to Absolute Cubic Bezier"] == YES)
    {
        [self convertCurvesToAbsoluteCubicBezier];
    }

    if ([functionTitle isEqualToString:@"Convert Path to Absolute Cubic Bezier"] == YES)
    {
        [self convertPathToAbsoluteCubicBezier];
    }

    if ([functionTitle isEqualToString:@"Scale Path Coordinates"] == YES)
    {
        [self scalePathCoordinates];
    }
    
    if ([functionTitle isEqualToString:@"Rotate Path Coordinates"] == YES)
    {
        [self rotatePathCoordinates];
    }
    
    if ([functionTitle isEqualToString:@"Reverse Path"] == YES)
    {
        [self reversePath];
    }

    if ([functionTitle isEqualToString:@"Flip Path Horizontally"] == YES)
    {
        [self flipPathHorizontally];
    }
    
    if ([functionTitle isEqualToString:@"Flip Path Vertically"] == YES)
    {
        [self flipPathVertically];
    }
    
    if ([functionTitle isEqualToString:@"Mirror Path Horizontally"] == YES)
    {
        [self mirrorPathHorizontally];
    }
    
    if ([functionTitle isEqualToString:@"Mirror Path Vertically"] == YES)
    {
        [self mirrorPathVertically];
    }
    if ([functionTitle isEqualToString:@"Rotate Path Segments Left"] == YES)
    {
        [self rotatePathSegmentsLeft];
    }
    if ([functionTitle isEqualToString:@"Rotate Path Segments Right"] == YES)
    {
        [self rotatePathSegmentsRight];
    }
}

//==================================================================================
//	setInputFieldsForFunction
//==================================================================================

- (void)setInputFieldsForFunction
{
    BOOL hideValue1 = YES;
    BOOL hideValue2 = YES;
    BOOL hideValue3 = YES;

    NSString * functionTitle = (self.pathElementEditor.pathFunctionsPopupButton).titleOfSelectedItem;
    
    if ([functionTitle isEqualToString:@"Scale Path Coordinates"] == YES)
    {
        hideValue1 = NO;
        hideValue2 = NO;

        self.pathElementEditor.pathFunctionLabel1.stringValue = @"Scale x:";
        self.pathElementEditor.pathFunctionValue1.stringValue = @"1";
        
        self.pathElementEditor.pathFunctionLabel2.stringValue = @"Scale y:";
        self.pathElementEditor.pathFunctionValue2.stringValue = @"1";
    }

    if ([functionTitle isEqualToString:@"Rotate Path Coordinates"] == YES)
    {
        hideValue1 = NO;
        hideValue2 = NO;
        hideValue3 = NO;

        self.pathElementEditor.pathFunctionLabel1.stringValue = @"Center x:";
        self.pathElementEditor.pathFunctionValue1.stringValue = @"1";
        
        self.pathElementEditor.pathFunctionLabel2.stringValue = @"Center y:";
        self.pathElementEditor.pathFunctionValue2.stringValue = @"1";
        
        self.pathElementEditor.pathFunctionLabel3.stringValue = @"Degrees:";
        self.pathElementEditor.pathFunctionValue3.stringValue = @"0.0";
    }

    self.pathElementEditor.pathFunctionLabel1.hidden = hideValue1;
    self.pathElementEditor.pathFunctionValue1.hidden = hideValue1;

    self.pathElementEditor.pathFunctionLabel2.hidden = hideValue2;
    self.pathElementEditor.pathFunctionValue2.hidden = hideValue2;

    self.pathElementEditor.pathFunctionLabel3.hidden = hideValue3;
    self.pathElementEditor.pathFunctionValue3.hidden = hideValue3;

}

//==================================================================================
//	convertToAbsoluteCoordinates
//==================================================================================

- (void)convertToAbsoluteCoordinates
{
    NSMutableArray * pathSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            convertToAbsoluteCoordinates:self.pathElementEditor.pluginTargetXMLElement];

    [self.pathElementEditor updateWithPathSegmentsArray:pathSegmentsArray updatePathLength:NO];
    [self.pathElementEditor updateDocumentViews];
}


//==================================================================================
//	convertCurvesToAbsoluteCubicBezier
//==================================================================================

- (void)convertCurvesToAbsoluteCubicBezier
{
    NSMutableArray * pathSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            convertCurvesToAbsoluteCubicBezier:self.pathElementEditor.pluginTargetXMLElement];

    [self.pathElementEditor updateWithPathSegmentsArray:pathSegmentsArray updatePathLength:NO];
    [self.pathElementEditor updateDocumentViews];
}

//==================================================================================
//	convertPathToAbsoluteCubicBezier
//==================================================================================

- (void)convertPathToAbsoluteCubicBezier
{
    NSMutableArray * pathSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            convertPathToAbsoluteCubicBezier:self.pathElementEditor.pluginTargetXMLElement];

    [self.pathElementEditor updateWithPathSegmentsArray:pathSegmentsArray updatePathLength:NO];
    [self.pathElementEditor updateDocumentViews];
}

//==================================================================================
//	reversePath
//==================================================================================

- (void)reversePath
{
    NSXMLNode * pathAttributeNode = [self.pathElementEditor.pluginTargetXMLElement attributeForName:@"d"];
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            buildPathSegmentsArrayWithPathString:pathAttributeString];
    
    NSMutableArray * reversedSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            reversePathWithPathSegmentsArray:pathSegmentsArray];
    
    [self.pathElementEditor updateWithPathSegmentsArray:reversedSegmentsArray updatePathLength:NO];
    [self.pathElementEditor updateDocumentViews];
}


//==================================================================================
//	mirrorPathHorizontally
//==================================================================================

- (void)mirrorPathHorizontally
{
    NSXMLNode * pathAttributeNode = [self.pathElementEditor.pluginTargetXMLElement attributeForName:@"d"];
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            buildPathSegmentsArrayWithPathString:pathAttributeString];
    
    NSMutableArray * flippedSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            mirrorPathHorizontallyWithPathSegmentsArray:pathSegmentsArray];
    
    for (NSMutableDictionary * flippedSegmentDictionary in flippedSegmentsArray)
    {
        [pathSegmentsArray addObject:flippedSegmentDictionary];
    }

    [self.pathElementEditor updateWithPathSegmentsArray:pathSegmentsArray updatePathLength:NO];
    [self.pathElementEditor updateDocumentViews];
}

//==================================================================================
//	mirrorPathVertically
//==================================================================================

- (void)mirrorPathVertically
{
    NSXMLNode * pathAttributeNode = [self.pathElementEditor.pluginTargetXMLElement attributeForName:@"d"];
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            buildPathSegmentsArrayWithPathString:pathAttributeString];
    
    NSMutableArray * flippedSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            mirrorPathVerticallyWithPathSegmentsArray:pathSegmentsArray];
    
    for (NSMutableDictionary * flippedSegmentDictionary in flippedSegmentsArray)
    {
        [pathSegmentsArray addObject:flippedSegmentDictionary];
    }

    [self.pathElementEditor updateWithPathSegmentsArray:pathSegmentsArray updatePathLength:NO];
    [self.pathElementEditor updateDocumentViews];
}

//==================================================================================
//	flipPathHorizontally
//==================================================================================

- (void)flipPathHorizontally
{
    NSXMLNode * pathAttributeNode = [self.pathElementEditor.pluginTargetXMLElement attributeForName:@"d"];
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            buildPathSegmentsArrayWithPathString:pathAttributeString];
    
    NSMutableArray * flippedSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            flipPathHorizontallyWithPathSegmentsArray:pathSegmentsArray];
    
    [self.pathElementEditor updateWithPathSegmentsArray:flippedSegmentsArray updatePathLength:NO];
    [self.pathElementEditor updateDocumentViews];
}


//==================================================================================
//	flipPathVertically
//==================================================================================

- (void)flipPathVertically
{
    NSXMLNode * pathAttributeNode = [self.pathElementEditor.pluginTargetXMLElement attributeForName:@"d"];
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks buildPathSegmentsArrayWithPathString:pathAttributeString];
    
    NSMutableArray * flippedSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            flipPathVerticallyWithPathSegmentsArray:pathSegmentsArray];
    
    [self.pathElementEditor updateWithPathSegmentsArray:flippedSegmentsArray updatePathLength:NO];
    [self.pathElementEditor updateDocumentViews];
}

//==================================================================================
//	scalePathCoordinates
//==================================================================================

- (void)scalePathCoordinates
{
    NSXMLNode * pathAttributeNode = [self.pathElementEditor.pluginTargetXMLElement attributeForName:@"d"];
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks buildPathSegmentsArrayWithPathString:pathAttributeString];
    
    CGFloat scaleX = (self.pathElementEditor.pathFunctionValue1).floatValue;
    CGFloat scaleY = (self.pathElementEditor.pathFunctionValue2).floatValue;
    
    NSMutableArray * scaledSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            scalePathCoordinatesWithPathSegmentsArray:pathSegmentsArray
            scaleX:scaleX scaleY:scaleY];
    
    [self.pathElementEditor updateWithPathSegmentsArray:scaledSegmentsArray updatePathLength:NO];
    [self.pathElementEditor updateDocumentViews];
}

//==================================================================================
//	rotatePathCoordinates
//==================================================================================

- (void)rotatePathCoordinates
{
    NSXMLNode * pathAttributeNode = [self.pathElementEditor.pluginTargetXMLElement attributeForName:@"d"];
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks buildPathSegmentsArrayWithPathString:pathAttributeString];
    
    CGFloat rotateX = (self.pathElementEditor.pathFunctionValue1).floatValue;
    CGFloat rotateY = (self.pathElementEditor.pathFunctionValue2).floatValue;
    CGFloat degrees = (self.pathElementEditor.pathFunctionValue3).floatValue;
    
    NSMutableArray * rotatedSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            rotatePathCoordinatesWithPathSegmentsArray:pathSegmentsArray
            x:rotateX y:rotateY degrees:degrees];
    
    [self.pathElementEditor updateWithPathSegmentsArray:rotatedSegmentsArray updatePathLength:NO];
    [self.pathElementEditor updateDocumentViews];
}

//==================================================================================
//	rotatePathSegmentsLeft
//==================================================================================

- (void)rotatePathSegmentsLeft
{
    NSXMLNode * pathAttributeNode = [self.pathElementEditor.pluginTargetXMLElement attributeForName:@"d"];
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks buildPathSegmentsArrayWithPathString:pathAttributeString];
    
    NSMutableArray * rotatedSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            rotateSegmentsWithPathSegmentsArray:pathSegmentsArray offset:-1];
    
    [self.pathElementEditor updateWithPathSegmentsArray:rotatedSegmentsArray updatePathLength:NO];
    [self.pathElementEditor updateDocumentViews];
}

//==================================================================================
//	rotatePathSegmentsRight
//==================================================================================

- (void)rotatePathSegmentsRight
{
    NSXMLNode * pathAttributeNode = [self.pathElementEditor.pluginTargetXMLElement attributeForName:@"d"];
    NSString * pathAttributeString = pathAttributeNode.stringValue;
    
    NSMutableArray * pathSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks buildPathSegmentsArrayWithPathString:pathAttributeString];
    
    NSMutableArray * rotatedSegmentsArray = [self.pathElementEditor.macSVGPluginCallbacks
            rotateSegmentsWithPathSegmentsArray:pathSegmentsArray offset:1];
    
    [self.pathElementEditor updateWithPathSegmentsArray:rotatedSegmentsArray updatePathLength:NO];
    [self.pathElementEditor updateDocumentViews];
}



@end
