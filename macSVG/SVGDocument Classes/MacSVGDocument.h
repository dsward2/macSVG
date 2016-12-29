//
//  MacSVGDocument.h
//  macSVG
//
//  Created by Douglas Ward on 7/29/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SimpleTreeNode;
@class MacSVGDocumentWindowController;
@class MacSVGPluginCallbacks;

@interface MacSVGDocument : NSDocument
{
}

@property(strong) MacSVGDocumentWindowController * macSVGDocumentWindowController;
@property(strong) NSXMLDocument * svgXmlDocument;
@property(strong) MacSVGPluginCallbacks * macSVGPluginCallbacks;
@property(strong) id svgLoadFinishedObserver;

@property(strong) NSString * storageKind;
@property(strong) NSDictionary * networkConnectionDictionary;

@property(strong) NSString * fileNameExtension;

@property(strong) NSMutableArray * insertedXMLNodes;

//- (void)createEmptySvgXmlDocument;

- (NSXMLElement *)xmlElementForMacsvgid:(NSString *)macsvgid;

- (void) addElement:(NSXMLElement *)aElement insertAtMacsvgid:(NSString *)macsvgid;
- (void) deleteElementForMacsvgid:(NSString *)aMacsvgid;

- (void) setAttributesForXMLElement:(NSMutableDictionary *)attributesDictionary;
- (void) setAttributes:(NSMutableDictionary *)newAttributesDictionary forElement:(NSXMLElement *)aElement;

- (void) updateXMLTextContent:(NSString *)textContent macsvgid:(NSString *)macsvgid;

-(void) assignNewMacsvgidsForNode:(NSXMLNode *)aNode;

- (NSXMLElement *) createElement:(NSString *)tagName atPoint:(NSPoint)aPoint;

- (void) pushUndoRedoDocumentChanges;

- (NSString *) downloadSVGFromURL:(NSString *)svgURLString;

- (BOOL) dropElementsToXmlDocument:(id <NSDraggingInfo>)info 
        item:(id)item childIndex:(NSInteger)childIndex caller:(id)caller;
        
- (NSString *) xmlStringForEmbeddedImageData:(NSData *)originalImageData outputFormat:(NSString *)outputFormat jpegCompressionNumber:(NSNumber *)jpegCompressionNumber;

- (NSMutableDictionary *) elementsWithAttribute:(NSString *)attributeName;

- (BOOL) insertElementToXmlDocument:(NSString *)xmlElementString 
        item:(id)item childIndex:(NSInteger)childIndex;
        
- (BOOL) duplicateElement:(NSXMLElement *)sourceXMLElement;

@property (readonly, copy) NSString *svgHeaderString;
- (NSString *) filteredSvgXmlDocumentStringWithOptions:(NSUInteger)xmlOptions;


- (void) beginPluginEditorToolMode;  // should be called when a plugin needs mouse control

- (void) updateSelections;

- (void) assignElementIDIfUnassigned:(NSXMLNode *)aNode;
- (NSString *)uniqueIDForElementTagName:(NSString *)elementTagName pendingIDs:(NSArray *)pendingIDs;
@property (readonly, copy) NSString *newMacsvgid;

- (id) macSVGPluginCallbacks;

- (void)deepCopyElement:(NSXMLElement *)sourceElement 
        destinationElement:(NSXMLElement *)destinationElement
        pendingIDsArray:(NSMutableArray *)pendingIDsArray;

- (NSDictionary *)validParentForNewElement:(NSXMLElement *)newElement;

- (NSMutableString *)allocFloatString:(float)aFloat;

- (void)saveDocument:(id)sender;
- (void)saveDocumentAs:(id)sender;

@end
