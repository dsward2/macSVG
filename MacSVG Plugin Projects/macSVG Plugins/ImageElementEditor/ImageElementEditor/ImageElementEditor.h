//
//  ImageElementEditor.h
//  ImageElementEditor
//
//  Created by Douglas Ward on 7/28/13.
//  Copyright (c) 2013 ArkPhone LLC. All rights reserved.
//

#import <MacSVGPlugin/MacSVGPlugin.h>
#import <WebKit/WebKit.h>


@interface ImageElementEditor : MacSVGPlugin <WebUIDelegate, WebPolicyDelegate, WebEditingDelegate, WebDownloadDelegate, WebFrameLoadDelegate, WebResourceLoadDelegate>
{
    IBOutlet WebView * imageWebView;
    IBOutlet NSButton * chooseFileButton;
    IBOutlet NSButton * getImageFromURLButton;
    IBOutlet NSButton * getClipboardButton;
    
    IBOutlet NSTextField * linkImageSizeTextField;
    IBOutlet NSTextField * embedPNGSizeTextField;
    IBOutlet NSTextField * embedJPEGSizeTextField;
    
    IBOutlet NSSlider * jpegCompressionSlider;
    
    float webViewUnitSquareScale;
}

@property(strong) NSMutableDictionary * imageDictionary;
@property(strong) IBOutlet NSMatrix * imageReferenceOptionMatrix;
@property(strong) IBOutlet NSTextField * imageURLTextField;

- (IBAction)getImageFromURLButtonAction:(id)sender;
- (IBAction)chooseFileButtonAction:(id)sender;
- (IBAction)getClipboardButtonAction:(id)sender;
- (IBAction)updateImageSettings:(id)sender;
- (IBAction)setXlinkHrefButtonAction:(id)sender;

@end
