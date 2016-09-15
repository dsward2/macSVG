//
//  SVGHelpManager.h
//  macSVG
//
//  Created by Douglas Ward on 7/20/16.
//
//

#import <Foundation/Foundation.h>

@class MacSVGDocumentWindowController;

@interface SVGHelpManager : NSObject

@property (strong) NSDictionary * elementsHelpDictionary;
@property (strong) NSMutableArray * attributesHelpArray;
@property (weak) IBOutlet MacSVGDocumentWindowController * macSVGDocumentWindowController;


- (void)showDocumentationForElement:(NSString *)elementName;
- (void)showDocumentationForAttribute:(NSString *)attributeName;

@end
