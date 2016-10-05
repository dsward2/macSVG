//
//  SelectedElementsInfoPopoverViewController.m
//  macSVG
//
//  Created by Douglas Ward on 8/31/16.
//
//

#import "SelectedElementsInfoPopoverViewController.h"
#import "SVGXMLDOMSelectionManager.h"
#import "SelectedElementsManager.h"
#import "WebKitInterface.h"
#import "MacSVGAppDelegate.h"

@interface SelectedElementsInfoPopoverViewController ()

@end

@implementation SelectedElementsInfoPopoverViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
}

//==================================================================================
//	popoverWillShow:
//==================================================================================

- (void)popoverWillShow:(NSNotification *)notification
{
    [self showSelectedElementsInfo];
}

//==================================================================================
//	popoverDidClose:
//==================================================================================

- (void)popoverDidClose:(NSNotification *)notification
{
}

//==================================================================================
//	showSelectedElementsInfo
//==================================================================================

- (void)showSelectedElementsInfo
{
    NSMutableArray * selectedElementsArray =
            macSVGDocumentWindowController.svgXMLDOMSelectionManager.selectedElementsManager.selectedElementsArray;
    
    NSInteger selectedElementsArrayCount = selectedElementsArray.count;

    if (selectedElementsArrayCount > 0)
    {
        MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)NSApp.delegate;
        
        CGRect unionRect = CGRectNull;
        
        for (NSMutableDictionary * elementDictionary in selectedElementsArray)
        {
            DOMElement * aDOMElement = elementDictionary[@"domElement"];
        
            CGRect boundingBox = [macSVGAppDelegate.webKitInterface bBoxForDOMElement:aDOMElement];
            
            /*
            if (CGRectIsNull(unionRect) == YES)
            {
                unionRect = boundingBox;
            }
            else
            {
                unionRect = CGRectUnion(unionRect, boundingBox);
            }
            */

            unionRect = CGRectUnion(unionRect, boundingBox);
        }
        
        NSString * selectedElementsCountString = [NSString stringWithFormat:@"%ld", selectedElementsArrayCount];
        NSString * topString = [NSString stringWithFormat:@"%f", unionRect.origin.y];
        NSString * bottomString = [NSString stringWithFormat:@"%f", (unionRect.origin.y + unionRect.size.height)];
        NSString * leftString = [NSString stringWithFormat:@"%f", unionRect.origin.x];
        NSString * rightString = [NSString stringWithFormat:@"%f", (unionRect.origin.x + unionRect.size.width)];
        NSString * widthString = [NSString stringWithFormat:@"%f", unionRect.size.width];
        NSString * heightString = [NSString stringWithFormat:@"%f", unionRect.size.height];
        NSString * centerXString = [NSString stringWithFormat:@"%f", (unionRect.origin.x + (unionRect.size.width / 2.0f))];
        NSString * centerYString = [NSString stringWithFormat:@"%f", (unionRect.origin.y + (unionRect.size.height / 2.0f))];
        
        selectedElementsCountTextField.stringValue = selectedElementsCountString;
        topTextField.stringValue = topString;
        bottomTextField.stringValue = bottomString;
        leftTextField.stringValue = leftString;
        rightTextField.stringValue = rightString;
        widthTextField.stringValue = widthString;
        heightTextField.stringValue = heightString;
        centerXTextField.stringValue = centerXString;
        centerYTextField.stringValue = centerYString;
    }
    else
    {
        selectedElementsCountTextField.stringValue = @"0";
        topTextField.stringValue = @"--";
        bottomTextField.stringValue = @"--";
        leftTextField.stringValue = @"--";
        rightTextField.stringValue = @"--";
        widthTextField.stringValue = @"--";
        heightTextField.stringValue = @"--";
        centerXTextField.stringValue = @"--";
        centerYTextField.stringValue = @"--";
    }
}


@end
