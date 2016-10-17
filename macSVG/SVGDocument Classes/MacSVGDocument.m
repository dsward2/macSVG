//
//  MacSVGDocument.m
//  macSVG
//
//  Created by Douglas Ward on 7/29/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "MacSVGDocument.h"
#import "MacSVGDocumentWindowController.h"
#import "XMLOutlineController.h"
#import "MacSVGAppDelegate.h"
#import "SVGDTDData.h"
#import "EmbeddedFontEncoder.h"
#import "NSOutlineView_Extensions.h"
#import "MacSVGPluginCallbacks.h"
#import "svgXMLDOMSelectionManager.h"
#import "SVGWebKitController.h"
#import "DOMSelectionControlsManager.h"
#import "SelectedElementsManager.h"
#import "NetworkConnectionManager.h"


@implementation MacSVGDocument

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    if (self.svgLoadFinishedObserver != NULL)
    {
        NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter removeObserver:self.svgLoadFinishedObserver];
        self.svgLoadFinishedObserver = NULL;
    }

    self.macSVGDocumentWindowController = NULL;
    self.svgXmlDocument = NULL;
    
    self.storageKind = NULL;
    self.networkConnectionDictionary = NULL;
    self.fileNameExtension = NULL;
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
        self.macSVGPluginCallbacks = [[MacSVGPluginCallbacks alloc] init];
        //[self.macSVGPluginCallbacks setMacSVGDocumentObject:self];
        self.macSVGPluginCallbacks.macSVGDocument = self;
        
        self.storageKind = @"new";

        self.fileNameExtension = @"svg";
        
        [self createEmptySvgXmlDocument];
    }
    return self;
}

//==================================================================================
//	initForURL:withContentsOfURL:ofType:error:
//==================================================================================

- (instancetype)initForURL:(NSURL *)absoluteDocumentURL withContentsOfURL:(NSURL *)absoluteDocumentContentsURL
        ofType:(NSString *)typeName error:(NSError **)outError
{
    self = [super initForURL:absoluteDocumentURL withContentsOfURL:absoluteDocumentContentsURL
            ofType:typeName error:outError];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    }
    return self;
}

//==================================================================================
//	initWithContentsOfURL:ofType:error:
//==================================================================================

- (instancetype)initWithContentsOfURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    self = [super initWithContentsOfURL:absoluteURL ofType:typeName error:outError];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    }
    return self;
}

//==================================================================================
//	initWithType:error:
//==================================================================================

- (instancetype)initWithType:(NSString *)typeName error:(NSError **)outError
{
    self = [super initWithType:typeName error:outError];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    }
    return self;
}


//==================================================================================
//	handleError
//==================================================================================

- (void)handleError:(NSError *)error
{
}

//==================================================================================
//	windowControllerDidLoadNib:
//==================================================================================

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.    
}

//==================================================================================
//	revertToContentsOfURL:ofType:error:
//==================================================================================

- (BOOL)revertToContentsOfURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    BOOL result = [super revertToContentsOfURL:absoluteURL ofType:typeName error:outError];
    
    [self.macSVGDocumentWindowController reloadAllViews];

    [self.macSVGDocumentWindowController.xmlOutlineController expandAllNodes];
    
    return result;
}

//==================================================================================
//	makeWindowControllers:
//==================================================================================

- (void)makeWindowControllers
{
    // create character set document window
    self.macSVGDocumentWindowController = [[MacSVGDocumentWindowController alloc]
            initWithWindowNibName:@"MacSVGDocument" owner:self];
    [self addWindowController:self.macSVGDocumentWindowController];
}

//==================================================================================
//	assignMacsvgidsForNode:
//==================================================================================

-(void)assignMacsvgidsForNode:(NSXMLNode *)aNode
{
    // assigns macsvgid if one does not exist
    if (aNode.kind == NSXMLElementKind)
    {
        NSXMLElement * aXmlElement = (NSXMLElement *)aNode;
        NSXMLNode * macsvgid = [aXmlElement attributeForName:@"macsvgid"];
        if (macsvgid == NULL)
        {
            NSString * guid = [NSProcessInfo processInfo].globallyUniqueString;
            macsvgid = [NSXMLNode attributeWithName:@"macsvgid" stringValue:guid];
            [aXmlElement addAttribute:macsvgid];
        }
    }
    else if ([aNode isKindOfClass:[NSXMLNode class]])
    {
        //NSXMLNode * aXmlNode = aNode;
    }
    else
    {
    
    }
    
    NSArray * children = aNode.children;
    for (id childNode in children)
    {
        [self assignMacsvgidsForNode:childNode];   // recursive call
    }
}

//==================================================================================
//	assignNewMacsvgidsForNode:
//==================================================================================

-(void) assignNewMacsvgidsForNode:(NSXMLNode *)aNode
{
    // replaces existing macsvgid if found, or assigns if macsvgid does not exist
    if (aNode.kind == NSXMLElementKind)
    {
        NSXMLElement * aXmlElement = (NSXMLElement *)aNode;
        NSXMLNode * macsvgid = [aXmlElement attributeForName:@"macsvgid"];
        
        if (macsvgid != NULL) 
        {
            [aXmlElement removeAttributeForName:@"macsvgid"];
        }
        
        macsvgid = [aXmlElement attributeForName:@"macsvgid"];
        
        if (macsvgid == NULL)
        {
            NSString * guid = [NSProcessInfo processInfo].globallyUniqueString;
            macsvgid = [NSXMLNode attributeWithName:@"macsvgid" stringValue:guid];
            [aXmlElement addAttribute:macsvgid];
        }
        else
        {
            NSLog(@"Error - assignNewMacsvgidsForNode %@", aNode);
        }
    }
    else if ([aNode isKindOfClass:[NSXMLNode class]])
    {
        //NSXMLNode * aXmlNode = aNode;
    }
    else
    {
    
    }
    
    NSArray * children = aNode.children;
    for (id childNode in children)
    {
        [self assignNewMacsvgidsForNode:childNode];   // recursive call
    }
}

//==================================================================================
//	findElementForMacsvgid:inElement:
//==================================================================================

-(id)findElementForMacsvgid:(NSString *)macsvgid inElement:(NSXMLElement *)currentElement;
{
    id result = NULL;
    
    if (currentElement.kind == NSXMLElementKind)
    {
        NSXMLNode * MacsvgidAttributeNode = [currentElement attributeForName:@"macsvgid"];
        
        NSString * MacsvgidAttribute = MacsvgidAttributeNode.stringValue;
        
        if ([macsvgid isEqualToString:MacsvgidAttribute] == YES)
        {
            result = currentElement;
        }
        else
        {
            NSArray * childNodes = currentElement.children;
            
            for (NSXMLNode * aNode in childNodes)
            {
                // recursive call to check child nodes
                result = [self findElementForMacsvgid:macsvgid inElement:(id)aNode];
                if (result != NULL)
                {
                    break;
                }
            }
        }
    }
    
    return result;
}

//==================================================================================
//	xmlElementForMacsvgid:
//==================================================================================

-(NSXMLElement *)xmlElementForMacsvgid:(NSString *)macsvgid
{
    NSXMLElement * rootElement = [self.svgXmlDocument rootElement];
    
    id item = [self findElementForMacsvgid:macsvgid inElement:rootElement];
    
    return item;
}

//==================================================================================
//	deleteElementForMacsvgid:
//==================================================================================

- (void)deleteElementForMacsvgid:(NSString *)aMacsvgid
{
    NSXMLElement * elementForDeletion = [self xmlElementForMacsvgid:aMacsvgid];
    
    if (elementForDeletion != NULL)
    {
        NSXMLNode * parentNode = elementForDeletion.parent;
        
        NSXMLElement * parentElement = (NSXMLElement *)parentNode;
        
        NSUInteger childCount = parentNode.childCount;
        
        for (NSUInteger i = 0; i < childCount; i++)
        {
            NSXMLNode * aNode = [parentNode childAtIndex:i];
            
            if (aNode == elementForDeletion)
            {
                [parentElement removeChildAtIndex:i];
                break;
            }
        }        
    }        
}

//==================================================================================
//	uniqueIDForElementTagName:pendingIDs:
//==================================================================================

- (NSString *)uniqueIDForElementTagName:(NSString *)elementTagName pendingIDs:(NSArray *)pendingIDs
{
    NSString * result = @"";
    
    int elementIdIndex = 1;

    NSXMLElement * rootElement = [self.svgXmlDocument rootElement];
    
    BOOL continueIDSearch = YES;
    while (continueIDSearch == YES)
    {
        NSString * elementIdString = [[NSString alloc] initWithFormat:@"%@%d", elementTagName, elementIdIndex];
        NSString * xpathQuery = [[NSString alloc] initWithFormat:@".//*[@id=\"%@\"]", elementIdString];
        
        NSError * error = NULL;
        NSArray * foundNodes = [rootElement nodesForXPath:xpathQuery error:&error];
        
        BOOL matchFound = NO;
        
        if (foundNodes != NULL)
        {
            if (foundNodes.count > 0)
            {
                matchFound = YES;  // elementIdString is not unique
            }
        }
        
        if (matchFound == NO)
        {
            if (pendingIDs != NULL)
            {
                for (NSString * aPendingID in pendingIDs)
                {
                    if ([elementIdString isEqualToString:aPendingID] == YES)
                    {
                        matchFound = YES;
                        break;
                    }
                }
            }
        }
        
        if (matchFound == NO)
        {
            // unique id found
            result = [NSString stringWithString:elementIdString];
            continueIDSearch = NO;
        }
        else
        {
            elementIdIndex++;
        }
    }
    
    return result;
}

//==================================================================================
//	newMacsvgid
//==================================================================================

- (NSString *)newMacsvgid
{
    NSString * guid = [NSProcessInfo processInfo].globallyUniqueString;
    return guid;
}

//==================================================================================
//	assignElementIDIfUnassigned:
//==================================================================================

-(void) assignElementIDIfUnassigned:(NSXMLNode *)aNode
{
    if (aNode.kind == NSXMLElementKind)
    {
        NSXMLElement * aXmlElement = (id)aNode;
        NSXMLNode * idNode = [aXmlElement attributeForName:@"id"];
        
        if (idNode == NULL) 
        {
            // id is missing, assign one
            NSString * elementName = aXmlElement.name;
            NSString * uniqueID = [self uniqueIDForElementTagName:elementName pendingIDs:NULL];
            
            idNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            idNode.name = @"id";
            idNode.stringValue = uniqueID;
            
            [aXmlElement addAttribute:idNode];
        }
    }
}

//==================================================================================
//	addElement:insertAtMacsvgid:
//==================================================================================

- (void) addElement:(NSXMLElement *)aElement insertAtMacsvgid:(NSString *)macsvgid
{
    // aElement is a prototype element

    if (macsvgid != NULL)
    {
        NSXMLElement * insertTargetElement = [self xmlElementForMacsvgid:macsvgid];
        
        if (insertTargetElement != NULL)
        {
            // assign fresh 'id' and 'macsvgid' attributes
            NSString * elementTagName = aElement.name;

            [self assignNewMacsvgidsForNode:aElement];
            
            NSString * newIDAttribute = [self uniqueIDForElementTagName:elementTagName pendingIDs:NULL];
            NSXMLNode * idAttributeNode = [aElement attributeForName:@"id"];
            idAttributeNode.stringValue = newIDAttribute;
                    
            [insertTargetElement addChild:aElement];
        
            //[aElement setAttributesWithDictionary:attributesDictionary];
            [self.macSVGDocumentWindowController reloadAttributesTableData];
       }
    }
}

// ================================================================

-(void) setAttributesForXMLElement:(NSMutableDictionary *)attributesDictionary
{
    NSString * macsvgid = attributesDictionary[@"macsvgid"];
    
    if (macsvgid != NULL)
    {
        NSXMLElement * aElement = [self xmlElementForMacsvgid:macsvgid];
        
        if (aElement != NULL)
        {
            NSString * xmlnsAttributeString = attributesDictionary[@"xmlns"];
            if (xmlnsAttributeString != NULL)
            {
                //NSLog(@"MacSVGDocument - setAttributesForXMLElement - found nsxlm attribute");
                [attributesDictionary removeObjectForKey:@"xmlns"];
            }

            [aElement setAttributesWithDictionary:attributesDictionary];
       }
    }
}

// ================================================================

- (void)setAttributes:(NSMutableDictionary *)newAttributesDictionary forElement:(NSXMLElement *)aElement
{
    NSString * xmlnsAttributeString = newAttributesDictionary[@"xmlns"];
    if (xmlnsAttributeString != NULL)
    {
        //NSLog(@"MacSVGDocument - setAttributes:forElement: - found nsxlm attribute");
        [newAttributesDictionary removeObjectForKey:@"xmlns"];
    }

    // preserve existing macsvgid
    NSXMLNode * macsvgidNode = [aElement attributeForName:@"macsvgid"];
    if (macsvgidNode != NULL)
    {
        NSString * macsvgid = macsvgidNode.stringValue;
        newAttributesDictionary[@"macsvgid"] = macsvgid;
    }
    else
    {
        NSString * macsvgid = [self newMacsvgid];
        newAttributesDictionary[@"macsvgid"] = macsvgid;
    }
    
    [aElement setAttributesWithDictionary:newAttributesDictionary]; // crashes animations sometimes
}

// ================================================================

- (NSString *)svgHeaderString
{
    NSString * headerString =
@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n\
<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \n\
\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n\
<svg xmlns=\"http://www.w3.org/2000/svg\"\n\
xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\"\n\
xmlns:cc=\"http://web.resource.org/cc/\"\n\
xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n\
xmlns:sodipodi=\"http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd\"\n\
xmlns:inkscape=\"http://www.inkscape.org/namespaces/inkscape\"\n\
version=\"1.1\" baseProfile=\"full\" width=\"640px\"\n\
height=\"744px\" viewBox=\"0 0 640 744\" preserveAspectRatio=\"none\"\n\
style=\"zoom: 1;\">";
    return headerString;
}


// ================================================================

- (NSXMLDocument *)createXMLDocumentFromXmlString:(NSString *)xmlString 
        contentKind:(NSXMLDocumentContentKind)contentKind
{
    NSXMLDocument * xmlDoc;
	NSError * err = NULL;
	//NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	
    //NSUInteger xmlOptions = NSXMLNodeCompactEmptyElement;
    NSUInteger xmlOptions = NSXMLNodeExpandEmptyElement;
    
    xmlDoc = [[NSXMLDocument alloc] initWithXMLString:xmlString
            options:xmlOptions
            error:&err];
            
	xmlDoc.documentContentKind = contentKind;
 
    if (err) 
	{
        [self handleError:err];
    }

    // add some attributes
    NSXMLElement * rootElement = [xmlDoc rootElement];
    
    MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)NSApp.delegate;
    [macSVGAppDelegate applyNewSVGDocumentSettings:xmlDoc];
    
    [self assignMacsvgidsForNode:rootElement];
	
	return xmlDoc;
}

//==================================================================================
//	removeMacsvgidAtElement
//==================================================================================

-(void) removeMacsvgidAtElement:(NSXMLElement *)aElement
{
    NSXMLNode * MacsvgidNode = [aElement attributeForName:@"macsvgid"];
    
    if (MacsvgidNode != NULL)
    {
        //[MacsvgidNode detach];
        [aElement removeAttributeForName:@"macsvgid"];
        MacsvgidNode = NULL;
    }
    
    NSArray * childElementsArray = aElement.children;
    
    for (NSXMLNode * aChild in childElementsArray)
    {
        if (aChild.kind == NSXMLElementKind)
        {
            [self removeMacsvgidAtElement:(id)aChild]; // recursive call for child elements
        }
    }
}

//==================================================================================
//	filteredSvgXmlDocumentString
//==================================================================================

- (NSString *)filteredSvgXmlDocumentStringWithOptions:(NSUInteger)xmlOptions
{
    NSData * originalXmlData = [self.svgXmlDocument XMLDataWithOptions:NSXMLNodePreserveCDATA];
    
    NSError * xmlError;
    NSXMLDocument * tempXMLDocument = [[NSXMLDocument alloc] initWithData:originalXmlData options:NSXMLNodePreserveCDATA error:&xmlError];
    
    [self removeMacsvgidAtElement:[tempXMLDocument rootElement]];

    NSString * xmlString = [tempXMLDocument XMLStringWithOptions:xmlOptions];

    return xmlString;
}


// ================================================================

- (void)analyzeDTD:(NSXMLDTD *)aDTD
{
	//NSLog(@"DTD = %@", aDTD);
    
    NSArray * childArray = aDTD.children;
    
    int childIndex = 0;
    
    for (NSXMLNode * childNode in childArray)
    {
        //NSLog(@"childIndex = %d", childIndex);

        NSXMLNodeKind nodeKind = childNode.kind;
        
        switch (nodeKind) 
        {
            case NSXMLDTDKind:
            {
                //NSLog(@"NSXMLDTDKind");

                NSXMLDTDNode * dtdNode = (NSXMLDTDNode *)childNode;
                NSXMLDTDNodeKind dtdNodeKind = dtdNode.DTDKind;
                #pragma unused(dtdNodeKind)
                
                NSLog(@"dtdNode = %@", dtdNode);

                NSString * dtdName = childNode.name;
                NSString * dtdValue = childNode.stringValue;

                NSLog(@"DTD %@ =  %@", dtdName, dtdValue);

                break;
            }
            case NSXMLEntityDeclarationKind:
            {
                //NSLog(@"NSXMLEntityDeclarationKind");
                                
                NSString * entityName = childNode.name;
                NSString * entityValue = childNode.stringValue;
                #pragma unused(entityName)
                #pragma unused(entityValue)

                //NSLog(@"entity declaration %@ =  %@", entityName, entityValue);
                
                break;
            }
            case NSXMLAttributeDeclarationKind:
            {
                //NSLog(@"NSXMLAttributeDeclarationKind");

                NSString * elementName = childNode.name;
                NSString * elementValue = childNode.stringValue;
                #pragma unused(elementName)
                #pragma unused(elementValue)

                //NSLog(@"attribute declaration %@ =  %@", elementName, elementValue);

                break;
            }
            case NSXMLElementDeclarationKind:
            {
                //NSLog(@"NSXMLElementDeclarationKind");

                NSString * elementName = childNode.name;
                NSString * elementValue = childNode.stringValue;
                #pragma unused(elementName)
                #pragma unused(elementValue)

                //NSLog(@"element declaration %@ =  %@", elementName, elementValue);
                
                NSLog(@"element declaration %@", elementName);
                
                break;
            }
            case NSXMLNotationDeclarationKind:
            {
                NSLog(@"NSXMLNotationDeclarationKind");
                break;
            }
            default:
            {
                NSLog(@"Unknown kind %lu", nodeKind);
                break;
            }
        }
        
        childIndex++;
    }
}

// ================================================================

- (void)createEmptySvgXmlDocument
{
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];

    MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)NSApp.delegate;
    NSString * svgDocumentPrototypeName = macSVGAppDelegate.svgDocumentPrototypeName;
    NSString * svgDocumentPrototypeExtension = macSVGAppDelegate.svgDocumentPrototypeExtension;
    
    self.fileNameExtension = svgDocumentPrototypeExtension;
    
	NSString * svgFilePath = [thisBundle pathForResource:svgDocumentPrototypeName
            ofType:svgDocumentPrototypeExtension];
    	
	NSError * error;
	NSString * svgString = [NSString stringWithContentsOfFile:svgFilePath
			encoding:NSUTF8StringEncoding error:&error];
    
    NSXMLDocumentContentKind contentKind = NSXMLDocumentXMLKind;
    
    contentKind = NSXMLDocumentXMLKind;

	self.svgXmlDocument = [self createXMLDocumentFromXmlString:svgString contentKind:contentKind];
}

// ================================================================

- (void)saveDocument:(id)sender
{
    if ([self.storageKind isEqualToString:@"new"])
    {
        [super saveDocument:sender];
    }
    else if ([self.storageKind isEqualToString:@"file"])
    {
        [super saveDocument:sender];
    }
    else if ([self.storageKind isEqualToString:@"network"])
    {
        NSLog(@"saveDocument storageKind = network");
        
        MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)NSApp.delegate;
        NetworkConnectionManager * networkConnectionManager =
                [macSVGAppDelegate networkConnectionManager];
        
        [networkConnectionManager saveDocument:self
                networkConnectionDictionary:self.networkConnectionDictionary];
    }
}

// ================================================================

- (void)saveDocumentAs:(id)sender
{
    [super saveDocumentAs:sender];
}

// ================================================================

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    NSString * xmlString = [self filteredSvgXmlDocumentStringWithOptions:NSXMLNodePreserveCDATA];
    
    NSData * svgXmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    //NSData * svgXmlData = [svgXmlDocument XMLData];

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    
	return svgXmlData;
}

// ================================================================

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.

    NSXMLDocumentContentKind contentKind = NSXMLDocumentXMLKind;
    
    NSString * fileURLString = (self.fileURL).absoluteString;
    NSString * pathExtension = fileURLString.pathExtension;
    
    if ([pathExtension isEqualToString:@"svg"] == YES)
    {
        contentKind = NSXMLDocumentXMLKind;
    }
    else if ([pathExtension isEqualToString:@"xhtml"] == YES)
    {
        contentKind = NSXMLDocumentXHTMLKind;
    }
    else if ([pathExtension isEqualToString:@"html"] == YES)
    {
        contentKind = NSXMLDocumentHTMLKind;
    }
    else if ([pathExtension isEqualToString:@"htm"] == YES)
    {
        contentKind = NSXMLDocumentHTMLKind;
    }
    else if ([pathExtension isEqualToString:@"asp"] == YES)
    {
        contentKind = NSXMLDocumentHTMLKind;
    }
    else if ([pathExtension isEqualToString:@"php"] == YES)
    {
        contentKind = NSXMLDocumentHTMLKind;
    }
    
	NSXMLDocument * newSvgXmlDocument = [self createXMLDocumentFromURL:url contentKind:contentKind];
    
    self.svgXmlDocument = newSvgXmlDocument;
    
	//NSLog(@"characterEncoding = %@", [svgXmlDocument characterEncoding]);
	//NSLog(@"documentContentKind = %lu", [svgXmlDocument documentContentKind]);
	//NSLog(@"DTD = %@", [svgXmlDocument DTD]);
	//NSLog(@"MIMEType = %@", [svgXmlDocument MIMEType]);
	//NSLog(@"version = %@", [svgXmlDocument version]);
	//NSLog(@"URI = %@", [svgXmlDocument URI]);
    
    if ( outError != NULL ) 
    {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}

    self.storageKind = @"file";
    
    return YES;
}

// ================================================================

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSXMLDocumentContentKind contentKind = NSXMLDocumentXMLKind;
    
    NSString * fileURLString = (self.fileURL).absoluteString;
    NSString * pathExtension = fileURLString.pathExtension;
    
    if ([pathExtension isEqualToString:@"svg"] == YES)
    {
        contentKind = NSXMLDocumentXMLKind;
    }
    else if ([pathExtension isEqualToString:@"xhtml"] == YES)
    {
        contentKind = NSXMLDocumentXHTMLKind;
    }
    else if ([pathExtension isEqualToString:@"html"] == YES)
    {
        contentKind = NSXMLDocumentHTMLKind;
    }
    else if ([pathExtension isEqualToString:@"htm"] == YES)
    {
        contentKind = NSXMLDocumentHTMLKind;
    }
    else if ([pathExtension isEqualToString:@"asp"] == YES)
    {
        contentKind = NSXMLDocumentHTMLKind;
    }
    else if ([pathExtension isEqualToString:@"php"] == YES)
    {
        contentKind = NSXMLDocumentHTMLKind;
    }
    
	//NSXMLDocument * newSvgXmlDocument = [self createXMLDocumentFromURL:url contentKind:contentKind];

	NSXMLDocument * newSvgXmlDocument = [self createXMLDocumentFromData:data contentKind:contentKind];
    
    self.svgXmlDocument = newSvgXmlDocument;
    
	//NSLog(@"characterEncoding = %@", [svgXmlDocument characterEncoding]);
	//NSLog(@"documentContentKind = %lu", [svgXmlDocument documentContentKind]);
	//NSLog(@"DTD = %@", [svgXmlDocument DTD]);
	//NSLog(@"MIMEType = %@", [svgXmlDocument MIMEType]);
	//NSLog(@"version = %@", [svgXmlDocument version]);
	//NSLog(@"URI = %@", [svgXmlDocument URI]);
    
    if ( outError != NULL ) 
    {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}

    self.storageKind = @"network";
    
    return YES;
}

// ================================================================

- (NSXMLDocument *)createXMLDocumentFromURL:(NSURL *)url
        contentKind:(NSXMLDocumentContentKind)contentKind
{
    NSXMLDocument * xmlDoc;
	NSError * err = NULL;
    
    if (contentKind == NSXMLDocumentXMLKind)
    {
        NSUInteger xmlOptions = NSXMLDocumentTidyXML;
        
        xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:url
                options:xmlOptions
                error:&err];

        xmlDoc.documentContentKind = contentKind;
    }
    else if (contentKind == NSXMLDocumentXHTMLKind)
    {
        NSUInteger xmlOptions = NSXMLDocumentTidyXML;
        
        xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:url
                options:xmlOptions
                error:&err];

        xmlDoc.documentContentKind = contentKind;
    }
    else if (contentKind == NSXMLDocumentHTMLKind)
    {
        NSUInteger xmlOptions = NSXMLDocumentTidyXML;
        
        xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:url
                options:xmlOptions
                error:&err];

        xmlDoc.documentContentKind = NSXMLDocumentXHTMLKind; // change to XHTML
        //[xmlDoc setDocumentContentKind:contentKind];
    }
    
    [xmlDoc setStandalone:YES];     // No DTD in current implementation

    if (err)
	{
        [self handleError:err];
    }

    // add some attributes
    NSXMLElement * rootElement = [xmlDoc rootElement];
    [self assignMacsvgidsForNode:rootElement];
	
	return xmlDoc;
}

// ================================================================

- (NSXMLDocument *)createXMLDocumentFromData:(NSData *)data
        contentKind:(NSXMLDocumentContentKind)contentKind
{
    NSXMLDocument * xmlDoc;
	NSError * err = NULL;
    
    if (contentKind == NSXMLDocumentXMLKind)
    {
        NSUInteger xmlOptions = NSXMLDocumentTidyXML;
        
        xmlDoc = [[NSXMLDocument alloc] initWithData:data
                options:xmlOptions
                error:&err];

        xmlDoc.documentContentKind = contentKind;
    }
    else if (contentKind == NSXMLDocumentXHTMLKind)
    {
        NSUInteger xmlOptions = NSXMLDocumentTidyXML;
        
        xmlDoc = [[NSXMLDocument alloc] initWithData:data
                options:xmlOptions
                error:&err];

        xmlDoc.documentContentKind = contentKind;
    }
    else if (contentKind == NSXMLDocumentHTMLKind)
    {
        NSUInteger xmlOptions = NSXMLDocumentTidyXML;
        
        xmlDoc = [[NSXMLDocument alloc] initWithData:data
                options:xmlOptions
                error:&err];

        xmlDoc.documentContentKind = NSXMLDocumentXHTMLKind; // change to XHTML
    }
    
    [xmlDoc setStandalone:YES];     // No DTD in current implementation
 
    if (err) 
	{
        [self handleError:err];
    }

    // add some attributes
    NSXMLElement * rootElement = [xmlDoc rootElement];
    [self assignMacsvgidsForNode:rootElement];
	
	return xmlDoc;
}

//==================================================================================
//	validParentForNewElement:
//==================================================================================

- (NSDictionary *)validParentForNewElement:(NSXMLElement *)newElement
{
    NSXMLElement * parentElement = NULL;
    NSXMLElement * childOfParent = NULL;
    NSUInteger insertIndex = 0;
    
    NSArray * selectedItemsArray = [self.macSVGDocumentWindowController selectedItemsInOutlineView];
    
    if (selectedItemsArray.count > 0)
    {
        parentElement = selectedItemsArray[0];
        
        MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)NSApp.delegate;
        SVGDTDData * svgDtdData = macSVGAppDelegate.svgDtdData;
        
        NSDictionary * elementContentsDictionary = svgDtdData.elementContentsDictionary;
        NSString * newTagName = newElement.name;
        BOOL continueSearch = YES;
        
        while (continueSearch == YES)
        {
            NSString * parentTagName = parentElement.name;
            NSDictionary * parentContentDictionary = elementContentsDictionary[parentTagName];

            if ([parentTagName isEqualToString:@"head"])
            {
                parentContentDictionary = @{newTagName: parentTagName};
            }
            
            if ([parentTagName isEqualToString:@"body"])
            {
                parentContentDictionary = @{newTagName: parentTagName};
            }
            
            if (parentContentDictionary == NULL)
            {
                NSLog(@"Error - validParentForNewElement %@, %@", newTagName, parentTagName);
            }
            else
            {
                NSString * foundContentTagName = parentContentDictionary[newTagName];
                if (foundContentTagName != NULL)
                {
                    // new element is valid for parent
                    continueSearch = NO;
                    NSUInteger childCount = parentElement.childCount;
                    insertIndex = childCount;
                    
                    for (int i = 0; i < childCount; i++)
                    {
                        NSXMLNode * aChild = [parentElement childAtIndex:i];
                        if (aChild == childOfParent) 
                        {
                            insertIndex = i + 1;
                        }
                    }
                }
            }
            
            if (continueSearch == YES)
            {
                if ([parentTagName isEqualToString:@"svg"] == YES)
                {
                    parentElement = NULL;
                    continueSearch = NO;
                }
            }
            
            if (continueSearch == YES)
            {
                // match not found, try next parent element
                childOfParent = parentElement;
                parentElement = (id)parentElement.parent;
                if (parentElement == NULL) 
                {
                    continueSearch = NO;
                }
            }
        }
    }
    
    if (parentElement == NULL)
    {
        // nothing was selected in the outline view, so insert at end of document
        NSXMLElement * rootElement = [self.svgXmlDocument rootElement];
        parentElement = rootElement;
        insertIndex = parentElement.childCount;
        
        if ([rootElement.name isEqualToString:@"svg"] == NO)
        {
            NSArray * svgElements = [rootElement elementsForName:@"svg"];
            if (svgElements.count > 0)
            {
                parentElement = svgElements[0];
                
                insertIndex = parentElement.childCount;
            }
        }
    }
    
    NSDictionary * parentDictionary = NULL;
    
    if (parentElement != NULL)
    {
        NSNumber * insertIndexNumber = @((unsigned int)insertIndex);
        parentDictionary = @{@"parentElement": parentElement,
                @"insertIndex": insertIndexNumber};
    }
    
    return parentDictionary;
}

//==================================================================================
//	allocFloatString:
//==================================================================================

- (NSMutableString *)allocFloatString:(float)aFloat
{
    NSMutableString * aString = [[NSMutableString alloc] initWithFormat:@"%f", aFloat];

    BOOL continueTrim = YES;
    while (continueTrim == YES)
    {
        NSUInteger stringLength = aString.length;
        
        if (stringLength <= 1)
        {
            continueTrim = NO;
        }
        else
        {
            unichar lastChar = [aString characterAtIndex:(stringLength - 1)];
            
            if (lastChar == '0')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
            }
            else if (lastChar == '.')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
                continueTrim = NO;
            }
            else
            {
                continueTrim = NO;
            }
        }
    }
    return aString;
}

//==================================================================================
//	allocPxString:
//==================================================================================

- (NSMutableString *)allocPxString:(float)aFloat
{
    NSMutableString * aString = [[NSMutableString alloc] initWithFormat:@"%f", aFloat];

    BOOL continueTrim = YES;
    while (continueTrim == YES)
    {
        NSUInteger stringLength = aString.length;
        
        if (stringLength <= 1)
        {
            continueTrim = NO;
        }
        else
        {
            unichar lastChar = [aString characterAtIndex:(stringLength - 1)];
            
            if (lastChar == '0')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
            }
            else if (lastChar == '.')
            {
                NSRange deleteRange = NSMakeRange(stringLength - 1, 1);
                [aString deleteCharactersInRange:deleteRange];
                continueTrim = NO;
            }
            else
            {
                continueTrim = NO;
            }
        }
    }
    
    [aString appendString:@"px"];
    
    return aString;
}

//==================================================================================
//	createElement:atPoint:
//==================================================================================

- (NSXMLElement *) createElement:(NSString *)tagName atPoint:(NSPoint)aPoint;
{
    NSXMLElement * newElement = [[NSXMLElement alloc] initWithName:tagName];
    
    NSString * xString = [self allocPxString:aPoint.x];
    NSString * yString = [self allocPxString:aPoint.y];
    
    NSString * strokeColorString = [self.macSVGDocumentWindowController strokeColorString];
    NSString * fillColorString = [self.macSVGDocumentWindowController fillColorString];
    NSString * strokeWidthString = [self.macSVGDocumentWindowController strokeWidthString];
    
    NSMutableDictionary * attributesDictionary = [[NSMutableDictionary alloc] init];
    
    NSString * elementID = [self uniqueIDForElementTagName:tagName pendingIDs:NULL];
            
    if ([tagName isEqualToString:@"rect"] == YES)
    {
        attributesDictionary[@"id"] = elementID;
        attributesDictionary[@"x"] = xString;
        attributesDictionary[@"y"] = yString;
        attributesDictionary[@"width"] = @"1px";
        attributesDictionary[@"height"] = @"1px";
        attributesDictionary[@"stroke"] = strokeColorString;
        attributesDictionary[@"stroke-width"] = strokeWidthString;
        attributesDictionary[@"fill"] = fillColorString;
        attributesDictionary[@"transform"] = @"";
    }
    
    if ([tagName isEqualToString:@"circle"] == YES)
    {
        attributesDictionary[@"id"] = elementID;
        attributesDictionary[@"cx"] = xString;
        attributesDictionary[@"cy"] = yString;
        attributesDictionary[@"r"] = @"1px";
        attributesDictionary[@"stroke"] = strokeColorString;
        attributesDictionary[@"stroke-width"] = strokeWidthString;
        attributesDictionary[@"fill"] = fillColorString;
        attributesDictionary[@"transform"] = @"";
    }
    
    if ([tagName isEqualToString:@"ellipse"] == YES)
    {
        attributesDictionary[@"id"] = elementID;
        attributesDictionary[@"cx"] = xString;
        attributesDictionary[@"cy"] = yString;
        attributesDictionary[@"rx"] = @"1px";
        attributesDictionary[@"ry"] = @"1px";
        attributesDictionary[@"stroke"] = strokeColorString;
        attributesDictionary[@"stroke-width"] = strokeWidthString;
        attributesDictionary[@"fill"] = fillColorString;
        attributesDictionary[@"transform"] = @"";
    }
    
    if ([tagName isEqualToString:@"line"] == YES)
    {
        attributesDictionary[@"id"] = elementID;
        attributesDictionary[@"x1"] = xString;
        attributesDictionary[@"y1"] = yString;
        attributesDictionary[@"x2"] = xString;
        attributesDictionary[@"y2"] = yString;
        attributesDictionary[@"stroke"] = strokeColorString;
        attributesDictionary[@"stroke-width"] = strokeWidthString;
        attributesDictionary[@"transform"] = @"";
    }
    
    if ([tagName isEqualToString:@"polyline"] == YES)
    {
        attributesDictionary[@"id"] = elementID;
        NSString * x1String = [self allocFloatString:aPoint.x];
        NSString * y1String = [self allocFloatString:aPoint.y];

        NSString * pointsString = [[NSString alloc] initWithFormat:
                @"%@,%@ %@,%@", x1String, y1String, x1String, y1String];
        attributesDictionary[@"points"] = pointsString;
        attributesDictionary[@"stroke"] = strokeColorString;
        attributesDictionary[@"stroke-width"] = strokeWidthString;
        attributesDictionary[@"fill"] = fillColorString;
        attributesDictionary[@"transform"] = @"";
    }
    
    if ([tagName isEqualToString:@"polygon"] == YES)
    {
        attributesDictionary[@"id"] = elementID;
        NSString * x1String = [self allocFloatString:aPoint.x];
        NSString * y1String = [self allocFloatString:aPoint.y];

        NSString * pointsString = [[NSString alloc] initWithFormat:
                @"%@,%@ %@,%@", x1String, y1String, x1String, y1String];
        attributesDictionary[@"points"] = pointsString;
        attributesDictionary[@"stroke"] = strokeColorString;
        attributesDictionary[@"stroke-width"] = strokeWidthString;
        attributesDictionary[@"fill"] = fillColorString;
        attributesDictionary[@"transform"] = @"";
    }
    
    if ([tagName isEqualToString:@"path"] == YES)
    {
        attributesDictionary[@"id"] = elementID;
        NSString * x1String = [self allocFloatString:aPoint.x];
        NSString * y1String = [self allocFloatString:aPoint.y];

        NSString * pathString = [[NSString alloc] initWithFormat:
                @"M %@ %@ C %@ %@ %@ %@ %@ %@", x1String, y1String, x1String, y1String, x1String, y1String, x1String, y1String];
                
        attributesDictionary[@"d"] = pathString;
        attributesDictionary[@"stroke"] = strokeColorString;
        attributesDictionary[@"stroke-width"] = strokeWidthString;
        attributesDictionary[@"fill"] = fillColorString;
        attributesDictionary[@"transform"] = @"";
    }
    
    if ([tagName isEqualToString:@"text"] == YES)
    {
        attributesDictionary[@"id"] = elementID;
        attributesDictionary[@"font-family"] = @"Helvetica";
        attributesDictionary[@"font-size"] = @"32px";
        attributesDictionary[@"stroke"] = strokeColorString;
        attributesDictionary[@"fill"] = fillColorString;
        attributesDictionary[@"stroke-width"] = strokeWidthString;
        attributesDictionary[@"text-anchor"] = @"middle";
        attributesDictionary[@"x"] = xString;
        attributesDictionary[@"y"] = yString;
        attributesDictionary[@"transform"] = @"";
        attributesDictionary[@"style"] = @"outline-style:none;";

        NSString * newTextValue = [NSString stringWithFormat:@"Text Element %@", elementID];
        newElement.stringValue = newTextValue;
    }

    if ([tagName isEqualToString:@"image"] == YES)
    {
        NSMutableDictionary * imageDictionary = (self.macSVGDocumentWindowController).imageDictionary;
        
        NSImage * previewImage = imageDictionary[@"previewImage"];
        NSString * imageURLString = imageDictionary[@"url"];
        NSString * imageReferenceOptionString = imageDictionary[@"imageReferenceOption"];
        NSString * pathExtension = imageDictionary[@"pathExtension"];
        NSNumber * jpegCompressionNumber = imageDictionary[@"jpegCompressionNumber"];
        
        attributesDictionary[@"id"] = elementID;
        attributesDictionary[@"x"] = xString;
        attributesDictionary[@"y"] = yString;
        attributesDictionary[@"transform"] = @"";
        attributesDictionary[@"preserveAspectRatio"] = @"xMidYMid meet";

        if (imageURLString == NULL)
        {
            attributesDictionary[@"width"] = @"161px";
            attributesDictionary[@"height"] = @"240px";
            attributesDictionary[@"xlink:href"] = @"https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/161px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg";
        }
        else
        {
            NSString * widthString = @"100px";
            NSString * heightString = @"100px";
            
            if (previewImage != NULL)
            {
                NSSize imageSize = previewImage.size;
                widthString = [self allocPxString:imageSize.width];
                heightString = [self allocPxString:imageSize.height];
            }
            
            if ([pathExtension isEqualToString:@"svg"] == YES)
            {
                imageReferenceOptionString = @"Link to Image";
            }

            if ([pathExtension isEqualToString:@"svgz"] == YES)
            {
                imageReferenceOptionString = @"Link to Image";
            }

            attributesDictionary[@"width"] = widthString;
            attributesDictionary[@"height"] = heightString;
            
            if ([imageReferenceOptionString isEqualToString:@"Link to Image"] == YES)
            {
                attributesDictionary[@"xlink:href"] = imageURLString;
            }
            else if ([imageReferenceOptionString isEqualToString:@"Embed PNG"] == YES)
            {
                NSData * tiffData = previewImage.TIFFRepresentation;
                NSString * pngEmbeddedDataString = [self xmlStringForEmbeddedImageData:tiffData outputFormat:@"png" jpegCompressionNumber:jpegCompressionNumber];
                attributesDictionary[@"xlink:href"] = pngEmbeddedDataString;
            }
            else if ([imageReferenceOptionString isEqualToString:@"Embed JPEG"] == YES)
            {
                NSData * tiffData = previewImage.TIFFRepresentation;
                NSString * jpegEmbeddedDataString = [self xmlStringForEmbeddedImageData:tiffData outputFormat:@"jpeg" jpegCompressionNumber:jpegCompressionNumber];
                attributesDictionary[@"xlink:href"] = jpegEmbeddedDataString;
            }
        }
    }
    
    [newElement setAttributesWithDictionary:attributesDictionary];
    
    [self assignNewMacsvgidsForNode:newElement];
    
    NSDictionary * parentDictionary = [self validParentForNewElement:newElement];
    
    if (parentDictionary != NULL)
    {
        NSXMLElement * parentElement = parentDictionary[@"parentElement"];
        NSNumber * insertIndexNumber = parentDictionary[@"insertIndex"];
        NSUInteger insertIndex = insertIndexNumber.unsignedIntValue;
        
        [parentElement insertChild:newElement atIndex:insertIndex];
        
        [self.macSVGDocumentWindowController addDOMElementForXMLElement:newElement];
        
        [self.macSVGDocumentWindowController reloadData];
        
        [self.macSVGDocumentWindowController expandElementInOutline:newElement];
    }
    else
    {
        NSLog(@"CreateElement:atPoint failed - parentElement is NULL");
        newElement = NULL;
    }
    
    return newElement;
}

//==================================================================================
//	updateXMLTextContent:macsvgid:
//==================================================================================

- (void) updateXMLTextContent:(NSString *)textContent macsvgid:(NSString *)macsvgid
{
    NSXMLElement * xmlElement = [self xmlElementForMacsvgid:macsvgid];
    
    if (xmlElement != NULL)
    {
        NSMutableArray * holdChildNodes = [NSMutableArray array];
        
        NSArray * children = xmlElement.children;
        
        for (NSXMLNode * aChildNode in children)
        {
            [aChildNode detach];
            
            if (aChildNode.kind != NSXMLTextKind)
            {
                [holdChildNodes addObject:aChildNode];  // preserve child for restoration
            }
        }
    
        xmlElement.stringValue = textContent;    // removes existing child nodes
        
        for (NSXMLNode * aChildNode in holdChildNodes)
        {
            [xmlElement addChild:aChildNode];       // restore child nodes
        }
        
        [xmlElement normalizeAdjacentTextNodesPreservingCDATA:YES];
    }
    
    [self.macSVGDocumentWindowController reloadData];
}

//==================================================================================
//	undoRedoDocumentChanges:
//==================================================================================

- (void)undoRedoDocumentChanges:(NSString *)xmlDocumentString
{
    [self.macSVGDocumentWindowController beginArrowToolMode];

    NSError * error;
    NSXMLElement * newRootElement = [[NSXMLElement alloc] initWithXMLString:xmlDocumentString error:&error];
    
    if (error == NULL)
    {
        NSMutableArray * expandedItemsArray = [NSMutableArray array];
 
        XMLOutlineController * xmlOutlineController = self.macSVGDocumentWindowController.xmlOutlineController;
        XMLOutlineView * xmlOutlineView = xmlOutlineController.xmlOutlineView;
       
        NSInteger numberOfRows = xmlOutlineView.numberOfRows;
        for (NSInteger i = 0; i < numberOfRows; i++)
        {
            NSXMLNode * xmlNode = [xmlOutlineView itemAtRow:i];
            
            BOOL itemIsExpanded = [xmlOutlineView isItemExpanded:xmlNode];
            
            NSXMLNodeKind nodeKind = xmlNode.kind;
            
            if (nodeKind == NSXMLElementKind)
            {
                if (itemIsExpanded == YES)
                {
                    NSXMLElement * xmlElement = (NSXMLElement *)xmlNode;
                
                    NSXMLNode * MacsvgidNode = [xmlElement attributeForName:@"macsvgid"];
                    
                    NSString * macsvgid = MacsvgidNode.stringValue;
                    
                    [expandedItemsArray addObject:macsvgid];
                }
            }
        }
    
        NSString * existingXMLString = [self.svgXmlDocument XMLStringWithOptions:NSXMLNodePreserveCDATA];
        
        [[(self.macSVGDocumentWindowController).window.undoManager prepareWithInvocationTarget:self] 
                undoRedoDocumentChanges:existingXMLString];

        [self.svgXmlDocument setRootElement:newRootElement];
        
        [self.macSVGDocumentWindowController reloadAllViews];
        
        for (NSString * macsvgid in expandedItemsArray)
        {
            NSXMLElement * xmlElement = [self xmlElementForMacsvgid:macsvgid];
            
            if (xmlElement != NULL)
            {
                [xmlOutlineView expandItem:xmlElement];
            }
        }
    }
    else
    {
        NSBeep();
    }
}

//==================================================================================
//	pushUndoRedoDocumentChanges
//==================================================================================

- (void)pushUndoRedoDocumentChanges
{
    NSString * existingXMLString = [self.svgXmlDocument XMLStringWithOptions:NSXMLNodePreserveCDATA];

    [[(self.macSVGDocumentWindowController).window.undoManager prepareWithInvocationTarget:self] 
            undoRedoDocumentChanges:existingXMLString];
    
    [self updateChangeCount:NSChangeDone];
}

//==================================================================================
//	close
//==================================================================================

-(void)close
{
	[super close];
}

// ================================================================

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString *)allocEncodeBase64Data:(NSData *)inputData
{
	if (inputData.length == 0)
		return @"";

    char *characters = malloc(((inputData.length + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < inputData.length)
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < inputData.length)
			buffer[bufferLength++] = ((char *)inputData.bytes)[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';	
	}
	
	return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

// ================================================================

- (NSString *)xmlStringForEmbeddedImageData:(NSData *)originalImageData outputFormat:(NSString *)outputFormat jpegCompressionNumber:(NSNumber *)jpegCompressionNumber
{
    // e.g.: <image x="39" y="422" width="450" height="305" id="photo" xlink:href="data:image/jpeg;base64,...">
    // where ... = base64 encoded image data
    
    NSImage * newImage = [[NSImage alloc] initWithData:originalImageData];

    NSSize imageSize = newImage.size;
    #pragma unused(imageSize)
    
    NSArray * imageReps = newImage.representations;

    NSBitmapImageRep * bits = imageReps[0];
    
    NSString * xmlString = @"";
    
    if ([outputFormat isEqualToString:@"png"] == YES)
    {
        NSDictionary * propertiesDictionary = @{};
        NSData * pngImageData = [bits representationUsingType:NSPNGFileType properties:propertiesDictionary];
        
        NSString * base64String = [self allocEncodeBase64Data:pngImageData];
        
        xmlString = [NSString stringWithFormat:@"data:image/png;base64,%@", base64String];
    }
    else if ([outputFormat isEqualToString:@"jpeg"] == YES)
    {
        NSLog(@"jpegCompressionNumber = %@", jpegCompressionNumber);
    
        NSDictionary * jpegPropertiesDictionary = @{NSImageCompressionFactor: jpegCompressionNumber};
    
        NSData * jpegImageData = [bits representationUsingType:NSJPEGFileType properties:jpegPropertiesDictionary];
        
        NSString * base64String = [self allocEncodeBase64Data:jpegImageData];
        
        xmlString = [NSString stringWithFormat:@"data:image/png;base64,%@", base64String];
    }
    
    return xmlString;
}

// ================================================================

-(NSString *)downloadSVGFromURL:(NSString *)svgURLString
{
    NSString * resultString = NULL;

    NSURL * svgURL = [NSURL URLWithString:svgURLString];
    
    if (svgURL != NULL)
    {
        NSError * svgError = NULL;
        NSString * svgString = [[NSString alloc] initWithContentsOfURL:svgURL encoding:NSUTF8StringEncoding error:&svgError];
        
        if (svgString != NULL)
        {
            NSRange svgStartRange = [svgString rangeOfString:@"<svg"];
            
            if (svgStartRange.location != NSNotFound) 
            {
                resultString = [svgString substringFromIndex:svgStartRange.location];
            }
        }
    }
    
    return resultString;
}

// ================================================================

-(NSXMLElement *)makeImageElementWithURL:(NSString *)imageURLString
{
    NSXMLElement * imageElement = NULL;

    NSURL * imageURL = [NSURL URLWithString:imageURLString];
    NSImage * aImage = [[NSImage alloc] initWithContentsOfURL:imageURL];
    
    if (aImage != NULL)
    {
        CGFloat xFloat = 10;
        NSString * xString = [NSString stringWithFormat:@"%fpx", xFloat];

        CGFloat yFloat = 10;
        NSString * yString = [NSString stringWithFormat:@"%fpx", yFloat];

        CGFloat widthFloat = aImage.size.width;
        NSString * widthString = [NSString stringWithFormat:@"%fpx", widthFloat];

        CGFloat heightFloat = aImage.size.height;
        NSString * heightString = [NSString stringWithFormat:@"%fpx", heightFloat];
        
        NSString * newIDString = [self uniqueIDForElementTagName:@"image" pendingIDs:NULL];

        NSString * MacsvgidString = [self newMacsvgid];

        NSString * formatString = @"<image x=\"%@\" y=\"%@\" width=\"%@\" height=\"%@\" id=\"%@\" xlink:href=\"%@\" transform=\"\" macsvgid=\"%@\"/>";
        
        NSString * imageXmlString = [NSString stringWithFormat:formatString, xString, yString, widthString, heightString, newIDString, imageURLString, MacsvgidString];
        
        NSError * xmlError = NULL;

        imageElement = [[NSXMLElement alloc] initWithXMLString:imageXmlString error:&xmlError];
    }
    
    return imageElement;
}

// ================================================================

-(NSXMLElement *)makePNGImageElementWithEmbeddedData:(NSData *)tiffImageData
{
    NSXMLElement * imageElement = NULL;

    NSImage * aImage = [[NSImage alloc] initWithData:tiffImageData];
    
    if (aImage != NULL)
    {
        NSNumber * jpegCompressionNumber = (self.macSVGDocumentWindowController.imageDictionary)[@"jpegCompressionNumber"];
        NSString * pngDataString = [self xmlStringForEmbeddedImageData:tiffImageData outputFormat:@"png" jpegCompressionNumber:jpegCompressionNumber];

        CGFloat xFloat = 10;
        NSString * xString = [NSString stringWithFormat:@"%fpx", xFloat];

        CGFloat yFloat = 10;
        NSString * yString = [NSString stringWithFormat:@"%fpx", yFloat];

        CGFloat widthFloat = aImage.size.width;
        NSString * widthString = [NSString stringWithFormat:@"%fpx", widthFloat];

        CGFloat heightFloat = aImage.size.height;
        NSString * heightString = [NSString stringWithFormat:@"%fpx", heightFloat];
        
        NSString * newIDString = [self uniqueIDForElementTagName:@"image" pendingIDs:NULL];

        NSString * MacsvgidString = [self newMacsvgid];

        NSString * formatString = @"<image x=\"%@\" y=\"%@\" width=\"%@\" height=\"%@\" id=\"%@\" xlink:href=\"%@\" transform=\"\" macsvgid=\"%@\"/>";
        
        NSString * imageXmlString = [NSString stringWithFormat:formatString, xString, yString, widthString, heightString, newIDString, pngDataString, MacsvgidString];
        
        NSError * xmlError = NULL;

        imageElement = [[NSXMLElement alloc] initWithXMLString:imageXmlString error:&xmlError];
    }
    
    return imageElement;
}

// ================================================================

-(NSXMLElement *)makeJPEGImageElementWithEmbeddedData:(NSData *)jpegData
{
    NSXMLElement * imageElement = NULL;

    NSImage * aImage = [[NSImage alloc] initWithData:jpegData];

    if (aImage != NULL)
    {
        NSNumber * jpegCompressionNumber = (self.macSVGDocumentWindowController.imageDictionary)[@"jpegCompressionNumber"];
        NSString * jpegDataString = [self xmlStringForEmbeddedImageData:jpegData outputFormat:@"jpeg" jpegCompressionNumber:jpegCompressionNumber];

        CGFloat xFloat = 10;
        NSString * xString = [NSString stringWithFormat:@"%fpx", xFloat];

        CGFloat yFloat = 10;
        NSString * yString = [NSString stringWithFormat:@"%fpx", yFloat];

        CGFloat widthFloat = aImage.size.width;
        NSString * widthString = [NSString stringWithFormat:@"%fpx", widthFloat];

        CGFloat heightFloat = aImage.size.height;
        NSString * heightString = [NSString stringWithFormat:@"%fpx", heightFloat];
        
        NSString * newIDString = [self uniqueIDForElementTagName:@"image" pendingIDs:NULL];

        NSString * MacsvgidString = [self newMacsvgid];

        NSString * formatString = @"<image x=\"%@\" y=\"%@\" width=\"%@\" height=\"%@\" id=\"%@\" xlink:href=\"%@\" transform=\"\" macsvgid=\"%@\"/>";
        
        NSString * imageXmlString = [NSString stringWithFormat:formatString, xString, yString, widthString, heightString, newIDString, jpegDataString, MacsvgidString];
        
        NSError * xmlError = NULL;

        imageElement = [[NSXMLElement alloc] initWithXMLString:imageXmlString error:&xmlError];
    }
    
    return imageElement;
}

// ================================================================

- (BOOL)isImageFilenameExtension:(NSString *)filenameExtension
{
    BOOL isImageFile = NO;
    if ([filenameExtension isEqualToString:@"jpg"] == YES)
    {
        isImageFile = YES;
    }
    else if ([filenameExtension isEqualToString:@"jpeg"] == YES)
    {
        isImageFile = YES;
    }
    else if ([filenameExtension isEqualToString:@"png"] == YES)
    {
        isImageFile = YES;
    }
    else if ([filenameExtension isEqualToString:@"tif"] == YES)
    {
        isImageFile = YES;
    }
    else if ([filenameExtension isEqualToString:@"tiff"] == YES)
    {
        isImageFile = YES;
    }
    else if ([filenameExtension isEqualToString:@"gif"] == YES)
    {
        isImageFile = YES;
    }
    
    return isImageFile;
}

// ================================================================


- (BOOL)dropElementsToXmlDocument:(id <NSDraggingInfo>)info 
        item:(id)item childIndex:(NSInteger)childIndex 
{
    //NSLog(@"XMLOutlineController - acceptDrop");
    
    XMLOutlineController * xmlOutlineController = self.macSVGDocumentWindowController.xmlOutlineController;
    XMLOutlineView * xmlOutlineView = xmlOutlineController.xmlOutlineView;

    NSXMLElement * rootElement = [self.svgXmlDocument rootElement];

    NSXMLNode * targetNode = item;
    
    // A target of "nil" means we are on the main root tree
    if (targetNode == nil) 
	{
        targetNode = rootElement;
    }
    
    // Determine the parent to insert into and the child index to insert at.
    if (targetNode.kind != NSXMLElementKind)
   {
        // If our target is a leaf, and we are dropping on it
        if (childIndex == NSOutlineViewDropOnItemIndex) 
        {
            // If we are dropping on a leaf, we will have to turn it into a container node
            childIndex = 0;
        } 
        else 
        {
            // We will be dropping on the item's parent at the target index of this child, plus one
            NSXMLNode * oldTargetNode = targetNode;
            targetNode = targetNode.parent;
            childIndex = [targetNode.children indexOfObject:oldTargetNode] + 1;
        }
    } 
    else 
    {            
        if (childIndex == NSOutlineViewDropOnItemIndex) 
        {
            // Insert it at the start, if we were dropping on it
            childIndex = 0;
        }
    }
    
    NSArray * sourceNodes = nil;
    
    // If the source was ourselves, we use our dragged nodes.
    
    id draggingSource = [info draggingSource];
    NSPasteboard * draggingPasteboard = [info draggingPasteboard];
    
    /*
    NSArray * pasteboardItems = [draggingPasteboard pasteboardItems];
    {
        for (NSPasteboardItem * aPasteboardItem in pasteboardItems)
        {
            NSArray * pasteboardTypes = [aPasteboardItem types];
            NSLog(@"pasteboardTypes=%@", pasteboardTypes);
        }
    }
    */
    
    NSArray * pboardArray  = @[XML_OUTLINE_PBOARD_TYPE];
    NSString * availableType = [draggingPasteboard availableTypeFromArray:pboardArray];
    
    if ((draggingSource == xmlOutlineView) && (availableType != NULL))
    {
        // Drag is originating from ourselves. Use existing item on the pasteboard
        sourceNodes = xmlOutlineController.draggedNodes;
    } 
    else 
    {
        // Create a new item for the dropped data, in an NSXMLNode
        
        NSString * pasteboardString = [draggingPasteboard stringForType:NSStringPboardType];
        NSString * xmlString = NULL;
        NSString * pasteboardType = NULL;

        if (pasteboardString != NULL) 
        {
            NSRange tagRange = [pasteboardString rangeOfString:@"<"];
            if (tagRange.location == 0)
            {
                if ([pasteboardString isEqualToString:@"<nil>"] == NO)
                {
                    // probably XML
                    xmlString = pasteboardString;
                    pasteboardType = NSStringPboardType;
                }
            }
            
            if (xmlString == nil) 
            {
                NSRange httpSchemeRange = [pasteboardString rangeOfString:@"http"];
                if (httpSchemeRange.location == 0)
                {
                    NSString * filenameExtension = pasteboardString.pathExtension;
                    filenameExtension = filenameExtension.lowercaseString;
                
                    if ([filenameExtension isEqualToString:@"svg"])
                    {
                        NSString * downloadString = [self downloadSVGFromURL:pasteboardString];
                        if (downloadString != NULL)
                        {
                            xmlString = downloadString;
                            pasteboardType = NSStringPboardType;
                        }
                    }
                    else
                    {
                        NSData * tiffData = [draggingPasteboard dataForType:NSTIFFPboardType];

                        if (tiffData != NULL)
                        {
                            NSXMLElement * imageElement = [self makeImageElementWithURL:pasteboardString];
                            
                            if (imageElement != NULL)
                            {
                                xmlString = imageElement.XMLString;
                                pasteboardType = NSStringPboardType;
                            }
                        }
                    }
                }
            }
        }
        
        
        if (xmlString == nil) 
        {
            // Try a URL -- it is an array of URLs, so we just grab one.
            NSString * urlString = [[draggingPasteboard propertyListForType:NSURLPboardType] lastObject];
            
            if (urlString.length > 4) 
            {
                NSString * filename  = urlString.lastPathComponent;

                if (filename != nil) 
                {
                    NSUInteger filenameLength = filename.length;
                    NSRange suffixRange = [filename rangeOfString:@".svg"];
                    if (suffixRange.location == filenameLength - 4)
                    {
                        NSError * svgError = NULL;
                        NSURL * aURL = [NSURL URLWithString:urlString];
                        NSString * svgString = [[NSString alloc] initWithContentsOfURL:aURL encoding:NSUTF8StringEncoding error:&svgError];
                        if (svgString != NULL)
                        {
                            NSRange svgStartRange = [svgString rangeOfString:@"<svg"];
                            
                            if (svgStartRange.location != NSNotFound)
                            {
                                xmlString = [svgString substringFromIndex:svgStartRange.location];
                                pasteboardType = NSURLPboardType;
                            }
                        }
                    }
                }
            }
        }
        
        if (xmlString == nil) 
        {
            // Try the filename -- it is an array of filenames, so we just grab one.
            NSString * filepath = [[draggingPasteboard propertyListForType:NSFilenamesPboardType] lastObject];
            NSString * filename = filepath.lastPathComponent;

            if (filename != nil) 
            {
                NSUInteger filenameLength = filename.length;
                NSRange suffixRange = [filename rangeOfString:@".svg"];
                if (suffixRange.location == filenameLength - 4)
                {
                    NSError * svgError = NULL;
                    NSString * svgString = [[NSString alloc] initWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&svgError];
                    if (svgString != NULL)
                    {
                        NSRange svgStartRange = [svgString rangeOfString:@"<svg"];
                        
                        if (svgStartRange.location != NSNotFound) 
                        {
                            xmlString = [svgString substringFromIndex:svgStartRange.location];
                            pasteboardType = NSFilenamesPboardType;
                        }
                    }
                }
            }
        }

        if (xmlString == nil) 
        {
            // Try for a TIFF image, and convert to PNG
            pasteboardType = NSTIFFPboardType;
            NSData * tiffImageData = [draggingPasteboard dataForType:NSTIFFPboardType];
            
            if (tiffImageData != NULL)
            {
                pasteboardType = NSTIFFPboardType;

                id tiffPropertyList = [draggingPasteboard propertyListForType:NSTIFFPboardType];
                
                if (tiffPropertyList != NULL)
                {
                    NSString * filepath = [tiffPropertyList lastObject];
                    NSString * filename = filepath.lastPathComponent;
                    if (filename != nil) 
                    {
                        NSUInteger filenameLength = filename.length;
                        NSRange suffixRange = [filename rangeOfString:@".svg"];
                        if (suffixRange.location == filenameLength - 4)
                        {
                            NSError * svgError = NULL;
                            NSString * svgString = [[NSString alloc] initWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&svgError];
                            if (svgString != NULL)
                            {
                                NSRange svgStartRange = [svgString rangeOfString:@"<svg"];
                                
                                if (svgStartRange.location != NSNotFound) 
                                {
                                    xmlString = [svgString substringFromIndex:svgStartRange.location];
                                }
                            }
                        }
                    }
                }
                else
                {
                    NSXMLElement * imageElement = [self makePNGImageElementWithEmbeddedData:tiffImageData];
                    
                    xmlString = imageElement.XMLString;
                    
                    pasteboardType = NSTIFFPboardType;
                }
            }
        }
        
        if (xmlString == nil)
        {
            // Try a PNG image
            NSString * filepath = [[draggingPasteboard propertyListForType:NSFilenamesPboardType] lastObject];
            NSString * filename = filepath.lastPathComponent;

            if (filename != nil) 
            {
                NSUInteger filenameLength = filename.length;
                NSRange suffixRange = [filename rangeOfString:@".png"];
                if (suffixRange.location == filenameLength - 4)
                {
                    NSData * pngData = [[NSData alloc] initWithContentsOfFile:filepath];
                    if (pngData != NULL)
                    {
                        NSNumber * jpegCompressionNumber = (self.macSVGDocumentWindowController.imageDictionary)[@"jpegCompressionNumber"];
                        xmlString = [self xmlStringForEmbeddedImageData:pngData outputFormat:@"png" jpegCompressionNumber:jpegCompressionNumber];
                        pasteboardType = NSFilenamesPboardType;
                    }
                }
            }
        }
        
        if (xmlString == nil) 
        {
            // Try a JPEG image
            NSString * filepath = [[draggingPasteboard propertyListForType:NSFilenamesPboardType] lastObject];
            NSString * filename = filepath.lastPathComponent;

            if (filename != nil) 
            {
                NSUInteger filenameLength = filename.length;
                
                BOOL isJpegFile = NO;
                
                NSRange suffixRange = [filename rangeOfString:@".jpg"];
                if (suffixRange.location == filenameLength - 4)
                {
                    isJpegFile = YES;
                }
                
                suffixRange = [filename rangeOfString:@".jpeg"];
                if (suffixRange.location == filenameLength - 5)
                {
                    isJpegFile = YES;
                }
                
                if (isJpegFile == YES)
                {
                    NSData * jpegData = [[NSData alloc] initWithContentsOfFile:filepath];

                    NSXMLElement * imageElement = [self makeJPEGImageElementWithEmbeddedData:jpegData];
                    
                    xmlString = imageElement.XMLString;
                    
                    pasteboardType = NSTIFFPboardType;
                }
            }
        }
        
        if (xmlString == nil)
        {
            // Try a TrueType font
            NSString * filepath = [[draggingPasteboard propertyListForType:NSFilenamesPboardType] lastObject];
            NSString * filename = filepath.lastPathComponent;

            if (filename != nil) 
            {
                NSUInteger filenameLength = filename.length;
                
                BOOL isTrueTypeFontFile = NO;
                
                NSRange suffixRange = [filename rangeOfString:@".ttf"];
                if (suffixRange.location == filenameLength - 4)
                {
                    isTrueTypeFontFile = YES;
                }
                
                if (isTrueTypeFontFile == YES)
                {
                    NSString * fontFamilyString = [filename substringToIndex:(filenameLength - 4)];
                                        
                    EmbeddedFontEncoder * embeddedFontEncoder = self.macSVGDocumentWindowController.embeddedFontEncoder;
 
                    NSURL * fontURL = [NSURL fileURLWithPath:filepath];
                   
                    NSString * fontString = [embeddedFontEncoder 
                            encodeFontWithURL:fontURL 
                            fontFamily:fontFamilyString fontType:@"truetype"];
                            
                    xmlString = [NSString stringWithFormat:@"<style type='text/css'>%@</style>]",
                            fontString];
                            
                    pasteboardType = NSFilenamesPboardType;
                }
            }            
        }
        
        if (xmlString == nil) 
        {
            pasteboardType = NULL;
            //xmlString = @"Unknown data dragged";
        }

        if (pasteboardType != NULL)
        {
            // Create a temporary XML document with the dragged object and namespace declarations
            NSError * docError = NULL;

            NSString * headerString = [self svgHeaderString];

            NSString * footerString = @"</svg>";
            
            NSString * xmlDocString = [[NSString alloc] initWithFormat:@"%@%@%@", headerString, xmlString, footerString];
            
            NSXMLDocument * tempDocument = [[NSXMLDocument alloc] initWithXMLString:xmlDocString options:NSXMLNodePreserveCDATA error:&docError];
            
            NSXMLElement * rootElement = [tempDocument rootElement];
            
            // retrieve the dragged nodes
            NSXMLElement * newNode = (id)[rootElement childAtIndex:0];

            [newNode detach];
            
            if (newNode != NULL)
            {
                [self assignNewMacsvgidsForNode:newNode];
                
                [self assignElementIDIfUnassigned:newNode];
                        
                // Finally, add it to the array of dragged items to insert
                sourceNodes = @[newNode];
            }
        }
    }
    
    NSXMLElement * targetElement = (NSXMLElement *)targetNode;
    
    NSInteger targetChildCount = targetElement.childCount;
    
    NSXMLNode * destinationNode = NULL;

    if (childIndex < targetChildCount)
    {
        destinationNode = [targetElement childAtIndex:childIndex];
    }

    // remove nodes from DOM, unless it is a child of another moved node
    for (NSXMLNode * aNode in sourceNodes) 
    {
        NSXMLNodeKind nodeKind = aNode.kind;

        if (nodeKind == NSXMLElementKind)
        {
            NSXMLNode * parentNode = aNode.parent;
            
            NSUInteger parentIndexInSourceNodes = [sourceNodes indexOfObject:parentNode];
            if (parentIndexInSourceNodes == NSNotFound)
            {
                // Remove the node from its old location
                [aNode detach];
            }
        }
    }

    // insert paste nodes to new destination

    NSInteger destinationIndex = targetChildCount - 1;
    
    if (destinationIndex < 0)
    {
        destinationIndex = 0;
    }
    
    if (destinationNode != NULL)
    {
        destinationIndex = destinationNode.index;
    }
    else
    {
        if (childIndex == targetChildCount)
        {
            destinationIndex = targetChildCount;    // TEST 20160730
        }
    }
    
    self.insertedXMLNodes = [NSMutableArray array];
    
    for (NSXMLNode * aNode in sourceNodes) 
    {
        NSXMLNodeKind nodeKind = aNode.kind;

        if (nodeKind == NSXMLElementKind)
        {
            [aNode detach];
            
            NSInteger targetChildCount2 = targetElement.childCount;
            if (destinationIndex > targetChildCount2)
            {
                destinationIndex = targetChildCount2;
            }
        
            [targetElement insertChild:aNode atIndex:destinationIndex];
            
            [self.insertedXMLNodes addObject:aNode];
            
            destinationIndex++;
        }
    }


    
    [self.macSVGDocumentWindowController reloadAllViews];
    
    NSXMLElement * parentElement = targetElement;
    NSMutableArray * parentElementsArray = [NSMutableArray array];
    while (parentElement != NULL)
    {
        [parentElementsArray insertObject:parentElement atIndex:0];
        parentElement = (NSXMLElement *)parentElement.parent;
    }
    for (NSXMLElement * aElement in parentElementsArray)
    {
        [xmlOutlineView expandItem:aElement];
    }
    
    // Make sure the target is expanded
    [xmlOutlineView expandItem:targetNode expandChildren:YES];

    for (NSXMLNode * aNode in sourceNodes) 
    {
        //[xmlOutlineView expandItem:aNode expandChildren:YES];
        [xmlOutlineView expandItem:aNode];
    }
    
    // Select target item
    NSArray * newSelectedItems = @[targetNode];
    [xmlOutlineView setSelectedItems:newSelectedItems];
    
    // Return YES to indicate we were successful with the drop. Otherwise, it would slide back the drag image.
    return YES;
}

// ================================================================

- (BOOL)insertElementToXmlDocument:(NSString *)xmlElementString 
        item:(id)item childIndex:(NSInteger)childIndex 
{
    NSString * xmlString = xmlElementString;
        
    XMLOutlineController * xmlOutlineController = self.macSVGDocumentWindowController.xmlOutlineController;
    XMLOutlineView * xmlOutlineView = xmlOutlineController.xmlOutlineView;

    NSArray * oldSelectedNodes = [xmlOutlineController selectedNodes];
 
    NSXMLElement * rootElement = [self.svgXmlDocument rootElement];

    NSXMLNode * targetNode = item;
    
    // A target of "nil" means we are on the main root tree
    if (targetNode == nil) 
	{
        targetNode = rootElement;
    }
    
    // Determine the parent to insert into and the child index to insert at.
    if (targetNode.kind != NSXMLElementKind)
   {
        // If our target is a leaf, and we are dropping on it
        if (childIndex == NSOutlineViewDropOnItemIndex) 
        {
            // If we are dropping on a leaf, we will have to turn it into a container node
            childIndex = 0;
        } 
        else 
        {
            // We will be dropping on the item's parent at the target index of this child, plus one
            NSXMLNode * oldTargetNode = targetNode;
            targetNode = targetNode.parent;
            childIndex = [targetNode.children indexOfObject:oldTargetNode] + 1;
        }
    } 
    else 
    {            
        if (childIndex == NSOutlineViewDropOnItemIndex) 
        {
            // Insert it at the start, if we were dropping on it
            childIndex = 0;
        }
    }
    
    // Create a temporary XML document with the dragged object and namespace declarations
    NSError * docError = NULL;

    NSString * headerString = [self svgHeaderString];

    NSString * footerString = @"</svg>";
    
    NSString * xmlDocString = [[NSString alloc] initWithFormat:@"%@%@%@", headerString, xmlString, footerString];
    
    NSXMLDocument * tempDocument = [[NSXMLDocument alloc] initWithXMLString:xmlDocString options:0 error:&docError];
    
    NSXMLElement * tempRootElement = [tempDocument rootElement];
    
    // retrieve the dragged nodes
    NSXMLElement * newNode = (id)[tempRootElement childAtIndex:0];

    [newNode detach];
    
    [self assignNewMacsvgidsForNode:newNode];
    
    [self assignElementIDIfUnassigned:newNode];

    NSDictionary * parentDictionary = [self validParentForNewElement:newNode];
    
    if (parentDictionary != NULL)
    {
        NSXMLElement * parentElement = parentDictionary[@"parentElement"];
        NSNumber * insertIndexNumber = parentDictionary[@"insertIndex"];
        NSUInteger insertIndex = insertIndexNumber.unsignedIntValue;

        [parentElement insertChild:newNode atIndex:insertIndex];
    }

    [self.macSVGDocumentWindowController reloadAllViews];
    
    // Make sure the target is expanded
    [xmlOutlineView expandItem:targetNode expandChildren:YES];
    
    // Reselect old items.
    [xmlOutlineView setSelectedItems:oldSelectedNodes];
    
    // Return YES to indicate we were successful with the insertion.
    return YES;
}

// ================================================================

- (void)deepCopyElement:(NSXMLElement *)sourceElement 
        destinationElement:(NSXMLElement *)destinationElement
        pendingIDsArray:(NSMutableArray *)pendingIDsArray
{
    // copy attributes and child nodes
    
    BOOL keepExistingID = NO;

    NSString * uniqueID = @"id_error";

    NSString * tagName = sourceElement.name;
    
    NSArray * attributes = sourceElement.attributes;
    for (NSXMLNode * attributeNode in attributes)
    {
        NSString * attributeName = attributeNode.name;

        BOOL copyAttribute = YES;
        
        if ([attributeName isEqualToString:@"id"] == YES)
        {
            NSXMLElement * rootElement = [self.svgXmlDocument rootElement];
    
            BOOL idConflictFound = NO;
            
            NSString * elementIdString = attributeNode.stringValue;
            NSString * xpathQuery = [[NSString alloc] initWithFormat:@".//*[@id=\"%@\"]", elementIdString];
            
            NSError * error = NULL;
            NSArray * foundNodes = [rootElement nodesForXPath:xpathQuery error:&error];
            
            if (foundNodes != NULL)
            {
                if (foundNodes.count > 0)
                {
                    idConflictFound = YES;  // elementIdString is not unique
                }
            }

            if (idConflictFound == YES)
            {
                copyAttribute = NO;
            }
            else
            {
                keepExistingID = YES;
                uniqueID = elementIdString;
            }
        }
        
        if ([attributeName isEqualToString:@"macsvgid"] == YES)
        {
            copyAttribute = NO;
        }
        
        if (copyAttribute == YES)
        {
            NSString * attributeValue = attributeNode.stringValue;
            NSXMLNode * newAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
            newAttribute.name = attributeName;
            newAttribute.stringValue = attributeValue;
            [destinationElement addAttribute:newAttribute];
        }
    }
    
    [self assignNewMacsvgidsForNode:destinationElement];
    
    if (keepExistingID == NO)
    {
        uniqueID = [self uniqueIDForElementTagName:tagName pendingIDs:NULL];
    }
    
    NSXMLNode * idAttributeNode = [destinationElement attributeForName:@"id"];
    if (idAttributeNode == NULL)
    {
        NSXMLNode * idAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        idAttributeNode.name = @"id";
        idAttributeNode.stringValue = uniqueID;
        [destinationElement addAttribute:idAttributeNode];
    }
    else
    {
        idAttributeNode.stringValue = uniqueID;
    }
    
    NSArray * children = sourceElement.children;
    
    NSMutableArray * pendingIDs = [NSMutableArray array];
    
    for (NSXMLNode * childNode in children)
    {
        NSXMLNodeKind childKind = childNode.kind;
        
        if (childKind == NSXMLAttributeKind) 
        {
            NSString * attributeName = childNode.name;
            #pragma unused(attributeName)
        }
        else if (childKind == NSXMLElementKind) 
        {
            NSXMLElement * childElement = (id)childNode;
            NSString * childTagName = childElement.name;
            NSXMLElement * newElement = [[NSXMLElement alloc] initWithName:childTagName];
            
            NSString * childUniqueID = [self uniqueIDForElementTagName:childTagName pendingIDs:pendingIDsArray];
            [pendingIDsArray addObject:childUniqueID];
                
            NSXMLNode * childIdAttributeNode = [destinationElement attributeForName:@"id"];
            if (childIdAttributeNode == NULL)
            {
                NSXMLNode * childIdAttributeNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
                childIdAttributeNode.name = @"id";
                childIdAttributeNode.stringValue = uniqueID;
                [destinationElement addAttribute:childIdAttributeNode];
            }
            else
            {
                childIdAttributeNode.stringValue = uniqueID;
            }

            [destinationElement addChild:newElement];
            
            [self deepCopyElement:childElement destinationElement:newElement pendingIDsArray:pendingIDs];  // recursive copy
        }
        else if (childKind == NSXMLTextKind) 
        {
            NSString * nodeString = childNode.stringValue;
            NSXMLNode * newTextNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind];
            newTextNode.stringValue = nodeString;
            [destinationElement addChild:newTextNode];
            
            [destinationElement normalizeAdjacentTextNodesPreservingCDATA:YES];
        }
        else
        {
            // other kinds not copied for now
        }
    }
}

// ================================================================

- (BOOL)duplicateElement:(NSXMLElement *)sourceXMLElement 
{
    BOOL result = NO;
    
    XMLOutlineController * xmlOutlineController = self.macSVGDocumentWindowController.xmlOutlineController;
    XMLOutlineView * xmlOutlineView = xmlOutlineController.xmlOutlineView;

    NSXMLElement * rootElement = [self.svgXmlDocument rootElement];
    
    NSUInteger childIndex = 0;
    
    // Determine the parent to insert into and the child index to insert at.
    if (sourceXMLElement.kind == NSXMLElementKind)
    {
        NSXMLElement * targetNode = (id)sourceXMLElement.parent;
        if (targetNode == NULL)
        {
            targetNode = rootElement;
        }

        NSUInteger indexOfSourceElement = [targetNode.children indexOfObject:sourceXMLElement];

        if (indexOfSourceElement == NSNotFound) 
        {
            childIndex = targetNode.children.count;
        }
        else
        {
            childIndex = indexOfSourceElement + 1;
        }
        
        NSString * tagName = sourceXMLElement.name;
        
        NSXMLElement * newNode = [[NSXMLElement alloc] initWithName:tagName];
        
        NSMutableArray * pendingIDs = [NSMutableArray array];
        [self deepCopyElement:sourceXMLElement destinationElement:newNode pendingIDsArray:pendingIDs];

        NSXMLElement * parentElement = (NSXMLElement *)sourceXMLElement.parent;
        NSInteger sourceIndex = sourceXMLElement.index;
        [parentElement insertChild:newNode atIndex:(sourceIndex + 1)];

        // Return YES to indicate we were successful with the insertion.
        result = YES;

        NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];

        [self.macSVGDocumentWindowController reloadAllViews];

        self.svgLoadFinishedObserver = [notificationCenter addObserverForName:@"SVGWebViewMainFrameDidFinishLoad" object:nil
                queue:mainQueue usingBlock:^(NSNotification *note)
        {
            NSNotificationCenter * notificationCenter2 = [NSNotificationCenter defaultCenter];
            [notificationCenter2 removeObserver:self.svgLoadFinishedObserver];
            self.svgLoadFinishedObserver = NULL;
            
            // Make sure the target is expanded

            [xmlOutlineView expandItem:targetNode expandChildren:NO];
            
            [xmlOutlineView deselectAll:self];
            
            // Select new duplicated items.
            [self.macSVGDocumentWindowController.xmlOutlineController.xmlOutlineView expandItem:newNode];
            
            NSMutableArray * duplicatedItemsArray = [NSMutableArray array];
            
            [duplicatedItemsArray addObject:newNode];
            
            [self buildChildElementsArray:duplicatedItemsArray parentNode:newNode];

            [self.macSVGDocumentWindowController.svgXMLDOMSelectionManager
                        setSelectedXMLElements:duplicatedItemsArray];
            
            [self.macSVGDocumentWindowController updateXMLOutlineViewSelections];
        }];
    }
    
    return result;
}


- (void)buildChildElementsArray:(NSMutableArray *)elementsArray parentNode:(NSXMLElement *)parentElement
{
    NSArray * childNodes = parentElement.children;
    
    for (NSXMLNode * aChildNode in childNodes)
    {
        [elementsArray addObject:aChildNode];
        
        [self buildChildElementsArray:elementsArray parentNode:(NSXMLElement *)aChildNode];  // recursive call
    }
}

//==================================================================================
//	elementsWithAttribute:
//==================================================================================

- (NSMutableDictionary *)elementsWithAttribute:(NSString *)attributeName
{
    NSMutableDictionary * resultDictionary = [NSMutableDictionary dictionary];

    MacSVGAppDelegate * macSVGAppDelegate = (MacSVGAppDelegate *)NSApp.delegate;
    SVGDTDData * svgDtdData = macSVGAppDelegate.svgDtdData;
    
    NSDictionary * elementsDictionary = svgDtdData.elementsDictionary;
    
    NSArray * allKeys = elementsDictionary.allKeys;
    
    for (NSString * elementKey in allKeys)
    {
        NSDictionary * aElementDictionary = elementsDictionary[elementKey];
        
        NSDictionary * attributesDictionary = aElementDictionary[@"attributes"];
        
        NSDictionary * aAttributeDictionary = attributesDictionary[attributeName];
        
        if (aAttributeDictionary != NULL)
        {
            resultDictionary[elementKey] = attributeName;
        }
    }

    return resultDictionary;
}

// ================================================================

- (void)beginPluginEditorToolMode
{
    [self.macSVGDocumentWindowController beginPluginEditorToolMode];
}

// ================================================================

- (void)updateSelections
{
    [self.macSVGDocumentWindowController updateSelections];
}

// ================================================================

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError **)outError
{
    NSPrintInfo *pi = [NSPrintInfo sharedPrintInfo];

    SVGWebView * svgWebView = self.macSVGDocumentWindowController.svgWebKitController.svgWebView;
    
    return [NSPrintOperation printOperationWithView:(NSView *)svgWebView printInfo:pi];
}

@end
