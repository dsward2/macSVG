//
//  ToolSettingsPopoverViewController.m
//  macSVG
//
//  Created by Douglas Ward on 7/15/13.
//
//

#import "ToolSettingsPopoverViewController.h"
#import "SVGWebKitController.h"
#import "SVGWebView.h"

@implementation ToolSettingsPopoverViewController

-(void)awakeFromNib
{
    [super awakeFromNib];

    [self setDefaultsButtonAction:self];
}

-(NSString *)hexadecimalValueOfAnNSColor:(NSColor *)aColor
{
    CGFloat redFloatValue, greenFloatValue, blueFloatValue;
    int redIntValue, greenIntValue, blueIntValue;
    NSString *redHexValue, *greenHexValue, *blueHexValue;

    // Convert the NSColor to the RGB color space before we can access its components
    NSColor * convertedColor = [aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

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



- (NSString *)hexColorFromColorWell:(NSColorWell *)aColorWell
{
    NSColor * aColor = aColorWell.color;
    
    NSString * hexColor = [self hexadecimalValueOfAnNSColor:aColor];
    
    return hexColor;
}

- (NSString *)pxStringValueForTextField:(NSTextField *)aTextField
{
    NSString * textFieldString = aTextField.stringValue;
    
    NSString * pxString = [NSString stringWithFormat:@"%@px", textFieldString];
    
    return pxString;
}



- (void)updateSettingsFromUserInterface
{
    self.selectionStrokeColor =
            [self hexColorFromColorWell:selectionStrokeColorWell];
    
    self.selectionStrokeWidth =
            [self pxStringValueForTextField:selectionStrokeWidthTextField];

    self.selectionHandleColor =
            [self hexColorFromColorWell:selectionHandleColorWell];
    
    self.selectionHandleSize =
            [self pxStringValueForTextField:selectionHandleSizeTextField];

    self.showCheckerboardBackground =
            (self.checkerboardBackgroundCheckboxButton).state;
    
    self.validateElementPlacement =
            (self.validateElementPlacementCheckboxButton).state;

    self.pathEndpointStrokeColor =
            [self hexColorFromColorWell:pathEndpointStrokeColorWell];
    
    self.pathEndpointStrokeWidth =
            [self pxStringValueForTextField:pathEndpointStrokeWidthTextField];
    
    self.pathEndpointFillColor =
            [self hexColorFromColorWell:pathEndpointFillColorWell];

    self.pathEndpointRadius =
            [self pxStringValueForTextField:pathEndpointRadiusTextField];

    self.pathCurvePointStrokeColor =
            [self hexColorFromColorWell:pathCurvePointStrokeColorWell];
    
    self.pathCurvePointStrokeWidth =
            [self pxStringValueForTextField:pathCurvePointStrokeWidthTextField];

    self.pathCurvePointFillColor =
            [self hexColorFromColorWell:pathCurvePointFillColorWell];

    self.pathCurvePointRadius =
            [self pxStringValueForTextField:pathCurvePointRadiusTextField];

    self.pathLineStrokeColor =
            [self hexColorFromColorWell:pathLineStrokeColorWell];

    self.pathLineStrokeWidth =
            [self pxStringValueForTextField:pathLineStrokeWidthTextField];
    
    [checkeredBackgroundView setNeedsDisplay:YES];
}


- (IBAction)setDefaultsButtonAction:(id)sender
{
    selectionStrokeColorWell.color = [NSColor blueColor];
    selectionStrokeWidthTextField.stringValue = @"1";

    selectionHandleColorWell.color = [NSColor redColor];
    selectionHandleSizeTextField.stringValue = @"7";
    
    (self.checkerboardBackgroundCheckboxButton).state = 1;
    (self.validateElementPlacementCheckboxButton).state = 1;

    pathEndpointStrokeColorWell.color = [NSColor blueColor];
    pathEndpointStrokeWidthTextField.stringValue = @"1";
    pathEndpointFillColorWell.color = [NSColor yellowColor];
    pathEndpointRadiusTextField.stringValue = @"3";

    pathCurvePointStrokeColorWell.color = [NSColor redColor];
    pathCurvePointStrokeWidthTextField.stringValue = @"1";
    pathCurvePointFillColorWell.color = [NSColor yellowColor];
    pathCurvePointRadiusTextField.stringValue = @"3";

    pathLineStrokeColorWell.color = [NSColor blueColor];
    pathLineStrokeWidthTextField.stringValue = @"1";
    
    [self updateSettingsFromUserInterface];
}


- (IBAction)toolSettingsAction:(id)sender
{
    [self updateSettingsFromUserInterface];
}

- (IBAction)increaseScaleButtonAction:(id)sender
{
    NSString * selectionStrokeWidth =
            [self pxStringValueForTextField:selectionStrokeWidthTextField];

    NSString * selectionHandleSize =
            [self pxStringValueForTextField:selectionHandleSizeTextField];

    NSString * pathEndpointStrokeWidth =
            [self pxStringValueForTextField:pathEndpointStrokeWidthTextField];
    
    NSString * pathEndpointRadius =
            [self pxStringValueForTextField:pathEndpointRadiusTextField];

    NSString * pathCurvePointStrokeWidth =
            [self pxStringValueForTextField:pathCurvePointStrokeWidthTextField];

    NSString * pathCurvePointRadius =
            [self pxStringValueForTextField:pathCurvePointRadiusTextField];

    NSString * pathLineStrokeWidth =
            [self pxStringValueForTextField:pathLineStrokeWidthTextField];
    
    float selectionStrokeWidthFloat = selectionStrokeWidth.floatValue;
    float selectionHandleSizeFloat = selectionHandleSize.floatValue;
    float pathEndpointStrokeWidthFloat = pathEndpointStrokeWidth.floatValue;
    float pathEndpointRadiusFloat = pathEndpointRadius.floatValue;
    float pathCurvePointStrokeWidthFloat = pathCurvePointStrokeWidth.floatValue;
    float pathCurvePointRadiusFloat = pathCurvePointRadius.floatValue;
    float pathLineStrokeWidthFloat = pathLineStrokeWidth.floatValue;
    
    selectionStrokeWidthFloat *= 2.0f;
    selectionHandleSizeFloat *= 2.0f;
    pathEndpointStrokeWidthFloat *= 2.0f;
    pathEndpointRadiusFloat *= 2.0f;
    pathCurvePointStrokeWidthFloat *= 2.0f;
    pathCurvePointRadiusFloat *= 2.0f;
    pathLineStrokeWidthFloat *= 2.0f;
    
    selectionStrokeWidth = [NSString stringWithFormat:@"%f", selectionStrokeWidthFloat];
    selectionHandleSize = [NSString stringWithFormat:@"%f", selectionHandleSizeFloat];
    pathEndpointStrokeWidth = [NSString stringWithFormat:@"%f", pathEndpointStrokeWidthFloat];
    pathEndpointRadius = [NSString stringWithFormat:@"%f", pathEndpointRadiusFloat];
    pathCurvePointStrokeWidth = [NSString stringWithFormat:@"%f", pathCurvePointStrokeWidthFloat];
    pathCurvePointRadius = [NSString stringWithFormat:@"%f", pathCurvePointRadiusFloat];
    pathLineStrokeWidth = [NSString stringWithFormat:@"%f", pathLineStrokeWidthFloat];

    selectionStrokeWidthTextField.stringValue = selectionStrokeWidth;

    selectionHandleSizeTextField.stringValue = selectionHandleSize;

    pathEndpointStrokeWidthTextField.stringValue = pathEndpointStrokeWidth;

    pathEndpointRadiusTextField.stringValue = pathEndpointRadius;

    pathCurvePointStrokeWidthTextField.stringValue = pathCurvePointStrokeWidth;

    pathCurvePointRadiusTextField.stringValue = pathCurvePointRadius;

    pathLineStrokeWidthTextField.stringValue = pathLineStrokeWidth;
    
    [self updateSettingsFromUserInterface];
}


- (IBAction)decreaseScaleButtonAction:(id)sender
{
    NSString * selectionStrokeWidth =
            [self pxStringValueForTextField:selectionStrokeWidthTextField];

    NSString * selectionHandleSize =
            [self pxStringValueForTextField:selectionHandleSizeTextField];

    NSString * pathEndpointStrokeWidth =
            [self pxStringValueForTextField:pathEndpointStrokeWidthTextField];
    
    NSString * pathEndpointRadius =
            [self pxStringValueForTextField:pathEndpointRadiusTextField];

    NSString * pathCurvePointStrokeWidth =
            [self pxStringValueForTextField:pathCurvePointStrokeWidthTextField];

    NSString * pathCurvePointRadius =
            [self pxStringValueForTextField:pathCurvePointRadiusTextField];

    NSString * pathLineStrokeWidth =
            [self pxStringValueForTextField:pathLineStrokeWidthTextField];
    
    float selectionStrokeWidthFloat = selectionStrokeWidth.floatValue;
    float selectionHandleSizeFloat = selectionHandleSize.floatValue;
    float pathEndpointStrokeWidthFloat = pathEndpointStrokeWidth.floatValue;
    float pathEndpointRadiusFloat = pathEndpointRadius.floatValue;
    float pathCurvePointStrokeWidthFloat = pathCurvePointStrokeWidth.floatValue;
    float pathCurvePointRadiusFloat = pathCurvePointRadius.floatValue;
    float pathLineStrokeWidthFloat = pathLineStrokeWidth.floatValue;
    
    selectionStrokeWidthFloat /= 2.0f;
    selectionHandleSizeFloat /= 2.0f;
    pathEndpointStrokeWidthFloat /= 2.0f;
    pathEndpointRadiusFloat /= 2.0f;
    pathCurvePointStrokeWidthFloat /= 2.0f;
    pathCurvePointRadiusFloat /= 2.0f;
    pathLineStrokeWidthFloat /= 2.0f;
    
    selectionStrokeWidth = [NSString stringWithFormat:@"%f", selectionStrokeWidthFloat];
    selectionHandleSize = [NSString stringWithFormat:@"%f", selectionHandleSizeFloat];
    pathEndpointStrokeWidth = [NSString stringWithFormat:@"%f", pathEndpointStrokeWidthFloat];
    pathEndpointRadius = [NSString stringWithFormat:@"%f", pathEndpointRadiusFloat];
    pathCurvePointStrokeWidth = [NSString stringWithFormat:@"%f", pathCurvePointStrokeWidthFloat];
    pathCurvePointRadius = [NSString stringWithFormat:@"%f", pathCurvePointRadiusFloat];
    pathLineStrokeWidth = [NSString stringWithFormat:@"%f", pathLineStrokeWidthFloat];

    selectionStrokeWidthTextField.stringValue = selectionStrokeWidth;

    selectionHandleSizeTextField.stringValue = selectionHandleSize;

    pathEndpointStrokeWidthTextField.stringValue = pathEndpointStrokeWidth;

    pathEndpointRadiusTextField.stringValue = pathEndpointRadius;

    pathCurvePointStrokeWidthTextField.stringValue = pathCurvePointStrokeWidth;

    pathCurvePointRadiusTextField.stringValue = pathCurvePointRadius;

    pathLineStrokeWidthTextField.stringValue = pathLineStrokeWidth;
    
    [self updateSettingsFromUserInterface];

}


@end
