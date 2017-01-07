//
//  SVGDTDData.m
//  macSVG
//
//  Created by Douglas Ward on 10/24/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "SVGDTDData.h"

#define declarationKindUndefined 0
#define declarationKindNotation 1
#define declarationKindUnparsed 2
#define declarationKindAttribute 3
#define declarationKindElement 4
#define declarationKindInternalEntity 5
#define declarationKindExternalEntity 6


@implementation SVGDTDData

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc 
{
    self.svgXmlDtd = NULL;
    self.entitiesDictionary = NULL;
    self.classesDictionary = NULL;
    self.attribsDictionary = NULL;
    self.attlistDictionary = NULL;
    self.datatypesDictionary = NULL;
    self.elementsDictionary = NULL;
    self.elementContentsDictionary = NULL;
    
    self.dtdDatatypesDictionary = NULL;
    self.dtdAttributesDictionary = NULL;
    self.dtdElementsDictionary = NULL;
}

// ================================================================

- (NSString *)descriptionForDTDNodeKind:(NSXMLDTDNodeKind)dtdNodeKind
{
    NSString * result = @"";
    switch (dtdNodeKind)
    {
        case NSXMLEntityGeneralKind: result = @"NSXMLEntityGeneralKind"; break;
        case NSXMLEntityParsedKind: result = @"NSXMLEntityParsedKind"; break;
        case NSXMLEntityUnparsedKind: result = @"NSXMLEntityUnparsedKind"; break;
        case NSXMLEntityParameterKind: result = @"NSXMLEntityParameterKind"; break;
        case NSXMLEntityPredefined: result = @"NSXMLEntityPredefined"; break;
        case NSXMLAttributeCDATAKind: result = @"NSXMLAttributeCDATAKind"; break;
        case NSXMLAttributeIDKind: result = @"NSXMLAttributeIDKind"; break;
        case NSXMLAttributeIDRefKind: result = @"NSXMLAttributeIDRefKind"; break;
        case NSXMLAttributeIDRefsKind: result = @"NSXMLAttributeIDRefsKind"; break;
        case NSXMLAttributeEntityKind: result = @"NSXMLAttributeEntityKind"; break;
        case NSXMLAttributeEntitiesKind: result = @"NSXMLAttributeEntitiesKind"; break;
        case NSXMLAttributeNMTokenKind: result = @"NSXMLAttributeNMTokenKind"; break;
        case NSXMLAttributeNMTokensKind: result = @"NSXMLAttributeNMTokensKind"; break;
        case NSXMLAttributeEnumerationKind: result = @"NSXMLAttributeEnumerationKind"; break;
        case NSXMLAttributeNotationKind: result = @"NSXMLAttributeNotationKind"; break;
        case NSXMLElementDeclarationUndefinedKind: result = @"NSXMLElementDeclarationUndefinedKind"; break;
        case NSXMLElementDeclarationEmptyKind: result = @"NSXMLElementDeclarationEmptyKind"; break;
        case NSXMLElementDeclarationAnyKind: result = @"NSXMLElementDeclarationAnyKind"; break;
        case NSXMLElementDeclarationMixedKind: result = @"NSXMLElementDeclarationMixedKind"; break;
        case NSXMLElementDeclarationElementKind: result = @"NSXMLElementDeclarationElementKind"; break;
    }
    return result;
};

// ================================================================

- (void) buildValidChildElements:(NSMutableDictionary *)classDictionary withValue:(NSString *)entityValue
{
    // e.g., "| feBlend | feColorMatrix\n     | feComponentTransfer | feComposite\n     | feConvolveMatrix | feDiffuseLighting\n     | feDisplacementMap | feFlood\n     | feGaussianBlur | feImage | feMerge\n     | feMorphology | feOffset\n     | feSpecularLighting | feTile\n     | feTurbulence "
    
    NSMutableDictionary * childElementsDictionary = [[NSMutableDictionary alloc] init];
    classDictionary[@"class-elements"] = childElementsDictionary;
    
    NSMutableString * elementsString = [[NSMutableString alloc] initWithString:entityValue];
    
    [elementsString replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, elementsString.length)];
    
    NSArray * inputElementsArray = [elementsString componentsSeparatedByString:@"|"];
    
    for (NSString * elementName in inputElementsArray) 
    {
        NSString * trimmedName = [elementName stringByTrimmingCharactersInSet:
                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([trimmedName isEqualToString:@""] == NO)
        {
            NSString * aElementName = [[NSString alloc] initWithString:trimmedName];
            childElementsDictionary[aElementName] = aElementName;
        }
    }
}

 // ================================================================

- (void) buildValidAttributeValues:(NSMutableDictionary *)attributeDictionary xmlString:(NSString *)xmlString
{
    // <!ATTLIST element-name attribute-name attribute-type default-value>
    // e.g. "<!ATTLIST a font-weight (normal|bold|bolder|lighter|100|200|300|400|500|600|700|800|900|inherit) #IMPLIED>"
    NSMutableArray * enumeratedValuesArray = [[NSMutableArray alloc] init];
    NSMutableArray * defaultValuesArray = [[NSMutableArray alloc] init];
    
    //[attributeDictionary setObject:enumeratedValuesArray forKey:@"enumerated-values"];
    //[enumeratedValuesArray release];
    
    NSMutableString * valuesString = [[NSMutableString alloc] initWithString:xmlString];

    NSRange valuesStringRange;
    NSUInteger replaceCount; 
    
//    NSRange valuesStringRange = NSMakeRange(0, [valuesString length]);
//    NSUInteger replaceCount = [valuesString replaceOccurrencesOfString:@"\n" withString:@"" 
//            options:0 range:valuesStringRange];

    valuesStringRange = NSMakeRange(0, 1);
    replaceCount = [valuesString replaceOccurrencesOfString:@"<" withString:@"" 
            options:0 range:valuesStringRange];

    valuesStringRange = NSMakeRange(valuesString.length - 1, 1);
    replaceCount = [valuesString replaceOccurrencesOfString:@">" withString:@"" 
            options:0 range:valuesStringRange];

    valuesStringRange = NSMakeRange(0, valuesString.length);
    replaceCount = [valuesString replaceOccurrencesOfString:@"(" withString:@" ( " 
            options:0 range:valuesStringRange];

    valuesStringRange = NSMakeRange(0, valuesString.length);
    replaceCount = [valuesString replaceOccurrencesOfString:@")" withString:@" ) " 
            options:0 range:valuesStringRange];
    
    valuesStringRange = NSMakeRange(0, valuesString.length);
    replaceCount = [valuesString replaceOccurrencesOfString:@"|" withString:@" | " 
            options:0 range:valuesStringRange];
        
    NSArray * inputValuesArray = [valuesString componentsSeparatedByString:@" "];

    NSInteger fixArrayCount = inputValuesArray.count;
    if (fixArrayCount > 0)
    {
        NSMutableArray * fixArray = [NSMutableArray arrayWithArray:inputValuesArray];
        NSInteger fixArrayIndex = 0;
        BOOL continueFixLoop = YES;
        while (continueFixLoop == YES)
        {
            NSString * fixString = fixArray[fixArrayIndex];
            NSInteger fixStringLength = fixString.length;

            NSUInteger quotemarkCount = 0;
            for (int i = 0; i < fixStringLength; i++)
            {
                if ([fixString characterAtIndex:i] == '"')
                {
                    quotemarkCount++;
                }
            }
            
            if (quotemarkCount == 1)
            {
                if (fixArrayIndex < (fixArrayCount - 1))
                {
                    NSString * nextFixString = fixArray[(fixArrayIndex + 1)];
                    NSInteger nextFixStringLength = nextFixString.length;
                    NSUInteger nextQuotemarkCount = 0;
                    for (int i = 0; i < nextFixStringLength; i++)
                    {
                        if ([nextFixString characterAtIndex:i] == '"')
                        {
                            nextQuotemarkCount++;
                        }
                    }
                    if (nextQuotemarkCount == 1)
                    {
                        // recombine two consecutive string elements
                        NSString * replacementString = [NSString stringWithFormat:@"%@ %@", fixString, nextFixString];
                        fixArray[fixArrayIndex] = replacementString;
                        [fixArray removeObjectAtIndex:(fixArrayIndex + 1)];
                        fixArrayIndex++;
                        fixArrayCount--;
                    }
                }
            }
            
            fixArrayIndex++;
            if (fixArrayIndex >= fixArrayCount) continueFixLoop = NO;
        }
        
        inputValuesArray = fixArray;
    }

    NSString * tagName = @"";
    NSString * elementName = @"";
    NSString * attributeName = @"";

    int attributeIndex = 0;
    BOOL isAttributeList = NO;
    for (NSString * valueString in inputValuesArray) 
    {
        BOOL attributeFound = NO;

        // check for ATTLIST element
        if (attributeIndex == 0)
        {
            if ([valueString isEqualToString:@"!ATTLIST"] == YES)
            {
                attributeFound = YES;
                attributeIndex = 1;
                tagName = [[NSString alloc] initWithString:valueString];
            }
        }
        
        // check for element-name
        if (attributeFound == NO)
        {
            if (attributeIndex == 1)
            {
                if ([valueString isEqualToString:@""] == NO)
                {
                    attributeFound = YES;
                    attributeIndex = 2;
                    elementName = [[NSString alloc] initWithString:valueString];
                }
            }
        }

        // check for attribute-name
        if (attributeFound == NO)
        {
            if (attributeIndex == 2)
            {
                if ([valueString isEqualToString:@""] == NO)
                {
                    attributeFound = YES;
                    attributeIndex = 3;
                    attributeName = [[NSString alloc] initWithString:valueString];
                }
            }
        }


        // check for attribute-type
        if (attributeFound == NO)
        {
            if (attributeIndex == 3)
            {
                if ([valueString isEqualToString:@""] == NO)
                {
                    if ([valueString isEqualToString:@"("] == YES)
                    {
                        attributeFound = YES;
                        isAttributeList = YES;
                    }
                    if ([valueString isEqualToString:@")"] == YES)
                    {
                        attributeFound = YES;
                        attributeIndex = 4;
                    }
                    if (attributeFound == NO) 
                    {
                        NSString * attributeType = [valueString stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];

                        if ([attributeType isEqualToString:@""] == NO)
                        {
                            attributeFound = YES;

                            if ([attributeType isEqualToString:@"|"] == NO)
                            {
                                NSString * aValue = [[NSString alloc] initWithString:attributeType];
                                [enumeratedValuesArray addObject:aValue];
                                
                                if (isAttributeList == NO)
                                {
                                    attributeIndex = 4;
                                }
                            }
                        }
                    }
                }
            }
        }        

        // check for default value
        if (attributeFound == NO)
        {
            if (attributeIndex == 4)
            {
                if ([valueString isEqualToString:@""] == NO)
                {
                    attributeFound = YES;
                    
                    NSMutableString * mutableValueString = [[NSMutableString alloc] initWithString:valueString];

                    NSUInteger valueStringLength = mutableValueString.length;
                    if (valueStringLength > 1) 
                    {
                        NSUInteger quotemarkCount = 0;
                        for (int i = 0; i < valueStringLength; i++)
                        {
                            if ([mutableValueString characterAtIndex:i] == '"')
                            {
                                quotemarkCount++;
                            }
                        }
                        
                        if ((quotemarkCount != 0) && (quotemarkCount != 2))
                        {
                            NSLog(@"quotemarkCount != 2");
                        }

                        if ([mutableValueString characterAtIndex:0] == '"')
                        {
                            if ([mutableValueString characterAtIndex:(valueStringLength - 1)] == '"')
                            {
                                /*
                                NSUInteger quotemarkCount = 0;
                                for (int i = 0; i < valueStringLength; i++)
                                {
                                    if ([mutableValueString characterAtIndex:i] == '"')
                                    {
                                        quotemarkCount++;
                                    }
                                }
                                */
                                
                                if (quotemarkCount == 2)
                                {
                                    NSRange lastCharacterRange = NSMakeRange(valueStringLength - 1, 1);
                                    [mutableValueString deleteCharactersInRange:lastCharacterRange];
                                    NSRange firstCharacterRange = NSMakeRange(0, 1);
                                    [mutableValueString deleteCharactersInRange:firstCharacterRange];
                                }
                            }
                        }
                    }
                    
                    [defaultValuesArray addObject:mutableValueString];
                }
            }
        }
    }
    
//    NSLog(@"element-name=%@, attribute-name=%@, attribute-type=%@, default-value=%@)", 
//            elementName, attributeName, enumeratedValuesArray, defaultValuesArray);
    
    attributeDictionary[@"element_name"] = elementName;
    attributeDictionary[@"attribute_name"] = attributeName;
    attributeDictionary[@"attribute_type"] = enumeratedValuesArray;
    attributeDictionary[@"default_value"] = defaultValuesArray;
}

// ================================================================

- (void)analyzeDTD
{
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSUInteger optionsMask = NSXMLNodeCompactEmptyElement;	// or NSXMLNodePreserveEntities?
	NSString * dtdFilePath = [thisBundle pathForResource:@"svg11-flat-20110816" ofType:@"dtd"];
    NSURL * svgXmlDtdUrl = [NSURL fileURLWithPath:dtdFilePath isDirectory:NO];
	NSError * error;
    self.svgXmlDtd = [[NSXMLDTD alloc]
            initWithContentsOfURL:svgXmlDtdUrl 
            options:optionsMask error:&error];
    (self.svgXmlDtd).name = @"svg";

	//NSLog(@"DTD = %@", svgXmlDtd);
   
    NSArray * childArray = (self.svgXmlDtd).children;
    
    int childIndex = 0;

    NSString * entityName = @"";
    NSString * entityValue = @"";
    NSString * entityURI = @"";
    NSString * attributeName = @"";
    NSString * attributeValue = @"";
    NSString * attributeURI = @"";
    NSString * elementName = @"";
    NSString * elementValue = @"";
    NSString * elementURI = @"";
    NSString * notationName = @"";
    NSString * notationValue = @"";
    NSString * notationURI = @"";
    NSString * unknownName = @"";
    NSString * unknownValue = @"";
    NSString * unknownURI = @"";

    self.entitiesDictionary = [[NSMutableDictionary alloc] init];
    self.classesDictionary = [[NSMutableDictionary alloc] init];
    self.attribsDictionary = [[NSMutableDictionary alloc] init];
    self.attlistDictionary = [[NSMutableDictionary alloc] init];
    self.datatypesDictionary = [[NSMutableDictionary alloc] init];
    self.elementsDictionary = [[NSMutableDictionary alloc] init];
    self.elementContentsDictionary = [[NSMutableDictionary alloc] init];
     
    NSMutableDictionary * datatypeDictionary = NULL;
    NSMutableDictionary * entityDictionary = NULL;
    NSMutableDictionary * classDictionary = NULL;
    NSMutableDictionary * attribDictionary = NULL;
    NSMutableDictionary * attDictionary = NULL;
    NSMutableDictionary * elementDictionary = NULL;
    NSMutableDictionary * contentDictionary = NULL;
    
    for (NSXMLNode * childNode in childArray)
    {
        //NSLog(@"childIndex = %d", childIndex);

        //NSLog(@"%@", [childNode XMLString]);

        NSXMLNodeKind nodeKind = childNode.kind;
        
        switch (nodeKind) 
        {
            case NSXMLEntityDeclarationKind:
            {
                NSXMLDTDNode * dtdNode = (NSXMLDTDNode *)childNode;
                NSXMLDTDNodeKind dtdNodeKind = dtdNode.DTDKind;
                #pragma unused(dtdNodeKind)
                
                entityName = childNode.name;
                entityValue = childNode.stringValue;
                entityURI = childNode.URI;
                //NSLog(@"NSXMLEntityDeclarationKind %@ = %@, %@", entityName, entityValue, entityURI);
                
                NSArray * entityArray = [entityName componentsSeparatedByString:@"."];
                
                if (entityArray.count == 2)
                {
                    NSString * part1 = entityArray[0];
                    NSString * part2 = entityArray[1];

                    if ([part2 isEqualToString:@"datatype"] == YES)
                    {
                        datatypeDictionary = [[NSMutableDictionary alloc] init];
                        (self.datatypesDictionary)[part1] = datatypeDictionary;
                        datatypeDictionary[@"value"] = entityValue;
                    }
                }
                
                
                if (entityArray.count == 3)
                {
                    NSString * part1 = entityArray[0];
                    NSString * part2 = entityArray[1];
                    NSString * part3 = entityArray[2];
                    
                    if ([part1 isEqualToString:@"SVG"] == YES)
                    {
                        if ([part3 isEqualToString:@"qname"] == YES)
                        {
                            entityDictionary = [[NSMutableDictionary alloc] init];
                            (self.entitiesDictionary)[part2] = entityDictionary;
                            entityDictionary[@"value"] = entityValue;
                        }
                        if ([part3 isEqualToString:@"class"] == YES)
                        {
                            classDictionary = [[NSMutableDictionary alloc] init];
                            (self.classesDictionary)[part2] = classDictionary;
                            classDictionary[@"value"] = entityValue;
                            [self buildValidChildElements:classDictionary withValue:entityValue];
                        }
                        if ([part3 isEqualToString:@"attrib"] == YES)
                        {
                            attribDictionary = [[NSMutableDictionary alloc] init];
                            (self.attribsDictionary)[part2] = attribDictionary;
                            attribDictionary[@"value"] = entityValue;
                        }
                        if ([part3 isEqualToString:@"attlist"] == YES)
                        {
                            attDictionary = [[NSMutableDictionary alloc] init];
                            (self.attlistDictionary)[part2] = attDictionary;
                            attDictionary[@"value"] = entityValue;
                        }
                        if ([part3 isEqualToString:@"content"] == YES)
                        {
                            // the list of valid child elements per element
                            contentDictionary = [[NSMutableDictionary alloc] init];
                            (self.elementContentsDictionary)[part2] = contentDictionary;
                            //[contentDictionary setObject:entityValue forKey:@"value"];

                            NSMutableString * elementsString = [[NSMutableString alloc] initWithString:entityValue];
                            
                            [elementsString replaceOccurrencesOfString:@"(" withString:@"" options:0 range:NSMakeRange(0, elementsString.length)];
                            [elementsString replaceOccurrencesOfString:@")" withString:@"" options:0 range:NSMakeRange(0, elementsString.length)];
                            [elementsString replaceOccurrencesOfString:@"*" withString:@"" options:0 range:NSMakeRange(0, elementsString.length)];
                            
                            NSArray * elementsArray = [elementsString componentsSeparatedByString:@"|"];
                            
                            for (NSString * aElement in elementsArray)
                            {
                                NSString * elementName = [aElement stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            
                                if ([elementName isEqualToString:@""] == NO)
                                {
                                    contentDictionary[elementName] = elementName;
                                }
                            }
                        }
                    }
                }
                
                break;
            }
            case NSXMLAttributeDeclarationKind:
            {
                NSXMLDTDNode * dtdNode = (NSXMLDTDNode *)childNode;
                NSXMLDTDNodeKind dtdNodeKind = dtdNode.DTDKind;
                NSString * dtdNodeDescription = [self descriptionForDTDNodeKind:dtdNodeKind];
                
                attributeName = childNode.name;
                attributeValue = childNode.stringValue;
                attributeURI = childNode.URI;
                //NSLog(@"NSXMLAttributeDeclarationKind %@ = %@, %@", attributeName, attributeValue, attributeURI);
                
                // also add a dictionary to the current element dictionary
                NSMutableDictionary * elementAttributesDictionary = elementDictionary[@"attributes"];
                
                NSMutableDictionary * attributeDictionary = [[NSMutableDictionary alloc] init];
                //[attributeDictionary setObject:attributeValue forKey:@"default-value"];
                attributeDictionary[@"xml"] = childNode.XMLString;
                attributeDictionary[@"description"] = dtdNodeDescription;
                
                [self buildValidAttributeValues:attributeDictionary xmlString:childNode.XMLString];
                
                elementAttributesDictionary[attributeName] = attributeDictionary;
                break;
            }
            case NSXMLElementDeclarationKind:
            {
                NSXMLDTDNode * dtdNode = (NSXMLDTDNode *)childNode;
                NSXMLDTDNodeKind dtdNodeKind = dtdNode.DTDKind;
                #pragma unused(dtdNodeKind)
                
                elementName = childNode.name;
                elementValue = childNode.stringValue;
                elementURI = childNode.URI;
                //NSLog(@"NSXMLElementDeclarationKind %@ = %@, %@", elementName, elementValue, elementURI);
                
                elementDictionary = [[NSMutableDictionary alloc] init];
                (self.elementsDictionary)[elementName] = elementDictionary;
                elementDictionary[@"value"] = elementValue;
                elementDictionary[@"xml"] = childNode.XMLString;

                NSMutableDictionary * elementAttributesDictionary =  [[NSMutableDictionary alloc] init];
                elementDictionary[@"attributes"] = elementAttributesDictionary;
                

                break;
            }
            case NSXMLNotationDeclarationKind:
            {
                NSXMLDTDNode * dtdNode = (NSXMLDTDNode *)childNode;
                NSXMLDTDNodeKind dtdNodeKind = dtdNode.DTDKind;
                #pragma unused(dtdNodeKind)
                
                notationName = childNode.name;
                notationValue = childNode.stringValue;
                notationURI = childNode.URI;
                //NSLog(@"NSXMLNotationDeclarationKind %@ = %@, %@", notationName, notationValue, notationURI);
                break;
            }
            default:
            {
                unknownName = childNode.name;
                unknownValue = childNode.stringValue;
                unknownURI = childNode.URI;
                NSLog(@"Unknown kind %lu, %@ = %@, %@", nodeKind, unknownName, unknownValue, unknownURI);
               break;
            }
        }
                
        childIndex++;
    }

    // Customize the default DTD rules to fix some missing common cases

    // we add the 'stop' element to gradient class
    NSDictionary * gradientClassDictionary = (self.classesDictionary)[@"Gradient"];
    
    NSMutableDictionary * gradientClassElementsDictionary = 
            gradientClassDictionary[@"class-elements"];
    
    gradientClassElementsDictionary[@"stop"] = @"stop";



    // add the 'mpath' element to animation class
    NSDictionary * animateMotionClassDictionary = (self.classesDictionary)[@"Animation"];
    
    NSMutableDictionary * animateMotionClassElementsDictionary =
            animateMotionClassDictionary[@"class-elements"];
    
    animateMotionClassElementsDictionary[@"mpath"] = @"mpath";

    
    // add the 'mpath' element to animation element content
    NSMutableDictionary * animateMotionDictionary = (self.elementContentsDictionary)[@"animateMotion"];
        
    animateMotionDictionary[@"mpath"] = @"mpath";



    // add some elements to Font class

    NSDictionary * fontClassDictionary = (self.classesDictionary)[@"Font"];
    
    NSMutableDictionary * fontFaceFormatClassElementsDictionary = 
            fontClassDictionary[@"class-elements"];
    
    fontFaceFormatClassElementsDictionary[@"font-face-format"] = @"font-face-format";
    fontFaceFormatClassElementsDictionary[@"font-face-name"] = @"font-face-name";
    fontFaceFormatClassElementsDictionary[@"font-face-src"] = @"font-face-src";
    fontFaceFormatClassElementsDictionary[@"font-face-uri"] = @"font-face-uri";

    // allow extended font-face elements to be added - taking a wild guess here - check these someday
    NSMutableDictionary * fontFaceDictionary = (self.elementContentsDictionary)[@"font-face"];
    fontFaceDictionary[@"font-face-src"] = @"font-face-src";
    fontFaceDictionary[@"font-face-name"] = @"font-face-name";
    fontFaceDictionary[@"font-face-format"] = @"font-face-format";
    fontFaceDictionary[@"glyphRef"] = @"glyphRef";
    fontFaceDictionary[@"hkern"] = @"hkern";
    fontFaceDictionary[@"vkern"] = @"vkern";

    // allow some elements to Text class
    NSMutableDictionary * textDictionary = (self.elementContentsDictionary)[@"text"];
    textDictionary[@"tspan"] = @"tspan";
    textDictionary[@"textPath"] = @"textPath";
    
    // allow some elements to textPath class
    NSMutableDictionary * textPathDictionary = (self.elementContentsDictionary)[@"textPath"];
    textPathDictionary[@"tspan"] = @"tspan";
    
    // customize DTD attribute rules
    
    NSArray * allElementKeys = (self.elementsDictionary).allKeys;
    
    // set default opacity value 1.0f
    for (NSString * aElementKey in allElementKeys)
    {
        NSDictionary * aElementDictionary = (self.elementsDictionary)[aElementKey];
        NSDictionary * attributesDictionary = aElementDictionary[@"attributes"];
        
        if (attributesDictionary != NULL)
        {
            NSArray * allAttributeKeys = attributesDictionary.allKeys;
            for (NSString * attributeKey in allAttributeKeys)
            {
                NSMutableDictionary * aAttributeDictionary = attributesDictionary[attributeKey];
                NSString * attributeName = aAttributeDictionary[@"attribute_name"];
                
                NSRange opacityRange = [attributeName rangeOfString:@"opacity"];
                if (opacityRange.location == 0)
                {
                    NSMutableArray * defaultValuesArray = [NSMutableArray arrayWithObject:@"1.0"];
                    aAttributeDictionary[@"default_value"] = defaultValuesArray;
                }
            }
        }
    }

    // add 'indefinite' as a repeatCount attribute defined value for all elements where repeatCount is a valid attribute
    // also, set '0' as the default value for repeatCount attributes
    for (NSString * aElementKey in allElementKeys)
    {
        NSDictionary * aElementDictionary = (self.elementsDictionary)[aElementKey];
        NSDictionary * attributesDictionary = aElementDictionary[@"attributes"];
        
        if (attributesDictionary != NULL)
        {
            NSArray * allAttributeKeys = attributesDictionary.allKeys;
            for (NSString * attributeKey in allAttributeKeys)
            {
                NSMutableDictionary * aAttributeDictionary = attributesDictionary[attributeKey];
                NSString * attributeName = aAttributeDictionary[@"attribute_name"];
                
                NSRange repeatCountRange = [attributeName rangeOfString:@"repeatCount"];
                if (repeatCountRange.location != NSNotFound)
                {
                    NSArray * existingAttributeTypeArray = aAttributeDictionary[@"attribute_type"];
                    NSMutableArray * attributeTypeArray = [NSMutableArray arrayWithArray:existingAttributeTypeArray];
                    
                    //[attributeTypeArray addObject:@"indefinite"];
                    [self addValue:@"indefinite" toArray:attributeTypeArray];
                    
                    aAttributeDictionary[@"attribute_type"] = attributeTypeArray;
                    NSMutableArray * defaultValuesArray = [NSMutableArray arrayWithObject:@"0"];
                    aAttributeDictionary[@"default_value"] = defaultValuesArray;
                }
            }
        }
    }

    // add 'indefinite' as a repeatDur attribute defined value for all elements where repeatDur is a valid attribute
    // also, set 'indefinite' as the default value for repeatDur attributes
    for (NSString * aElementKey in allElementKeys)
    {
        NSDictionary * aElementDictionary = (self.elementsDictionary)[aElementKey];
        NSDictionary * attributesDictionary = aElementDictionary[@"attributes"];
        
        if (attributesDictionary != NULL)
        {
            NSArray * allAttributeKeys = attributesDictionary.allKeys;
            for (NSString * attributeKey in allAttributeKeys)
            {
                NSMutableDictionary * aAttributeDictionary = attributesDictionary[attributeKey];
                NSString * attributeName = aAttributeDictionary[@"attribute_name"];
                
                NSRange repeatCountRange = [attributeName rangeOfString:@"repeatDur"];
                if (repeatCountRange.location == 0)
                {
                    NSArray * existingAttributeTypeArray = aAttributeDictionary[@"attribute_type"];
                    NSMutableArray * attributeTypeArray = [NSMutableArray arrayWithArray:existingAttributeTypeArray];
                    
                    //[attributeTypeArray addObject:@"indefinite"];
                    //[attributeTypeArray addObject:@"media"];
                    
                    [self addValue:@"indefinite" toArray:attributeTypeArray];
                    [self addValue:@"media" toArray:attributeTypeArray];
                    
                    aAttributeDictionary[@"attribute_type"] = attributeTypeArray;
                    NSMutableArray * defaultValuesArray = [NSMutableArray arrayWithObject:@"indefinite"];
                    aAttributeDictionary[@"default_value"] = defaultValuesArray;
                }
            }
        }
    }
    

    // add 'none' as a preserveAspectRatio attribute defined value for all elements where preserveAspectRatio is a valid attribute
    // also, set 'xMidYMid meet' as the default value for preserveAspectRatio attributes
    for (NSString * aElementKey in allElementKeys)
    {
        NSDictionary * aElementDictionary = (self.elementsDictionary)[aElementKey];
        NSDictionary * attributesDictionary = aElementDictionary[@"attributes"];
        
        if (attributesDictionary != NULL)
        {
            NSArray * allAttributeKeys = attributesDictionary.allKeys;
            for (NSString * attributeKey in allAttributeKeys)
            {
                NSMutableDictionary * aAttributeDictionary = attributesDictionary[attributeKey];
                NSString * attributeName = aAttributeDictionary[@"attribute_name"];
                
                NSRange repeatCountRange = [attributeName rangeOfString:@"preserveAspectRatio"];
                if (repeatCountRange.location != NSNotFound)
                {
                    NSArray * existingAttributeTypeArray = aAttributeDictionary[@"attribute_type"];
                    NSMutableArray * attributeTypeArray = [NSMutableArray arrayWithArray:existingAttributeTypeArray];
                    
                    /*
                    [attributeTypeArray addObject:@"none"];
                    
                    [attributeTypeArray addObject:@"xMinYMin meet"];
                    [attributeTypeArray addObject:@"xMinYMid meet"];
                    [attributeTypeArray addObject:@"xMinYMax meet"];
                    [attributeTypeArray addObject:@"xMidYMin meet"];
                    [attributeTypeArray addObject:@"xMidYMid meet"];
                    [attributeTypeArray addObject:@"xMidYMax meet"];
                    [attributeTypeArray addObject:@"xMaxYMin meet"];
                    [attributeTypeArray addObject:@"xMaxYMid meet"];
                    [attributeTypeArray addObject:@"xMaxYMax meet"];
                    
                    [attributeTypeArray addObject:@"xMinYMin slice"];
                    [attributeTypeArray addObject:@"xMinYMid slice"];
                    [attributeTypeArray addObject:@"xMinYMax slice"];
                    [attributeTypeArray addObject:@"xMidYMin slice"];
                    [attributeTypeArray addObject:@"xMidYMid slice"];
                    [attributeTypeArray addObject:@"xMidYMax slice"];
                    [attributeTypeArray addObject:@"xMaxYMin slice"];
                    [attributeTypeArray addObject:@"xMaxYMid slice"];
                    [attributeTypeArray addObject:@"xMaxYMax slice"];
                    */

                    [self addValue:@"none" toArray:attributeTypeArray];

                    [self addValue:@"xMinYMin meet" toArray:attributeTypeArray];
                    [self addValue:@"xMinYMid meet" toArray:attributeTypeArray];
                    [self addValue:@"xMinYMax meet" toArray:attributeTypeArray];
                    [self addValue:@"xMidYMin meet" toArray:attributeTypeArray];
                    [self addValue:@"xMidYMid meet" toArray:attributeTypeArray];
                    [self addValue:@"xMidYMax meet" toArray:attributeTypeArray];
                    [self addValue:@"xMaxYMin meet" toArray:attributeTypeArray];
                    [self addValue:@"xMaxYMid meet" toArray:attributeTypeArray];
                    [self addValue:@"xMaxYMax meet" toArray:attributeTypeArray];
                    
                    [self addValue:@"xMinYMin slice" toArray:attributeTypeArray];
                    [self addValue:@"xMinYMid slice" toArray:attributeTypeArray];
                    [self addValue:@"xMinYMax slice" toArray:attributeTypeArray];
                    [self addValue:@"xMidYMin slice" toArray:attributeTypeArray];
                    [self addValue:@"xMidYMid slice" toArray:attributeTypeArray];
                    [self addValue:@"xMidYMax slice" toArray:attributeTypeArray];
                    [self addValue:@"xMaxYMin slice" toArray:attributeTypeArray];
                    [self addValue:@"xMaxYMid slice" toArray:attributeTypeArray];
                    [self addValue:@"xMaxYMax slice" toArray:attributeTypeArray];
                    
                    aAttributeDictionary[@"attribute_type"] = attributeTypeArray;
                    NSMutableArray * defaultValuesArray = [NSMutableArray arrayWithObject:@"xMidYMid meet"];
                    aAttributeDictionary[@"default_value"] = defaultValuesArray;
                }
            }
        }
    }

    // add 'indefinite' and '0s' as begin attribute defined values for elements where begin is a valid attribute
    // also, set '0s' as the default value for dur attributes
    for (NSString * aElementKey in allElementKeys)
    {
        NSDictionary * aElementDictionary = (self.elementsDictionary)[aElementKey];
        NSDictionary * attributesDictionary = aElementDictionary[@"attributes"];
        
        if (attributesDictionary != NULL)
        {
            NSArray * allAttributeKeys = attributesDictionary.allKeys;
            for (NSString * attributeKey in allAttributeKeys)
            {
                NSMutableDictionary * aAttributeDictionary = attributesDictionary[attributeKey];
                NSString * attributeName = aAttributeDictionary[@"attribute_name"];
                
                NSRange repeatCountRange = [attributeName rangeOfString:@"begin"];
                if (repeatCountRange.location != NSNotFound)
                {
                    NSArray * existingAttributeTypeArray = aAttributeDictionary[@"attribute_type"];
                    NSMutableArray * attributeTypeArray = [NSMutableArray arrayWithArray:existingAttributeTypeArray];
                    
                    //[attributeTypeArray addObject:@"none"];
                    [self addValue:@"none" toArray:attributeTypeArray];
                    
                    aAttributeDictionary[@"attribute_type"] = attributeTypeArray;
                    NSMutableArray * defaultValuesArray = [NSMutableArray arrayWithObject:@"0s"];
                    aAttributeDictionary[@"default_value"] = defaultValuesArray;
                }
            }
        }
    }

    // add several fill attribute defined values for all elements where fill is a valid attribute
    for (NSString * aElementKey in allElementKeys)
    {
        NSMutableDictionary * aElementDictionary = (self.elementsDictionary)[aElementKey];
        NSMutableDictionary * attributesDictionary = aElementDictionary[@"attributes"];
        
        BOOL isAnimateElement = NO;
        if ([aElementKey isEqualToString:@"set"] == YES)
        {
            isAnimateElement = YES;
        }
        else if ([aElementKey isEqualToString:@"animate"] == YES)
        {
            isAnimateElement = YES;
        }
        else if ([aElementKey isEqualToString:@"animateColor"] == YES)
        {
            isAnimateElement = YES;
        }
        else if ([aElementKey isEqualToString:@"animateMotion"] == YES)
        {
            isAnimateElement = YES;
        }
        else if ([aElementKey isEqualToString:@"animateTransform"] == YES)
        {
            isAnimateElement = YES;
        }
        
        if (attributesDictionary != NULL)
        {
            NSArray * allAttributeKeys = attributesDictionary.allKeys;
            
            BOOL fillAttributeFound = NO;
            
            for (NSString * attributeKey in allAttributeKeys)
            {
                NSMutableDictionary * aAttributeDictionary = attributesDictionary[attributeKey];
                NSString * attributeName = aAttributeDictionary[@"attribute_name"];
                
                NSRange fillRange = [attributeName rangeOfString:@"fill"];
                if (fillRange.location == 0)
                {
                    fillAttributeFound = YES;
                
                    NSArray * existingAttributeTypeArray = aAttributeDictionary[@"attribute_type"];
                    NSMutableArray * attributeTypeArray = [NSMutableArray arrayWithArray:existingAttributeTypeArray];
                    
                    //[attributeTypeArray addObject:@"none"];
                    [self addValue:@"none" toArray:attributeTypeArray];

                    if (isAnimateElement == YES)
                    {
                        //[attributeTypeArray addObject:@"freeze"];
                        //[attributeTypeArray addObject:@"remove"];
                        
                        [self addValue:@"freeze" toArray:attributeTypeArray];
                        [self addValue:@"remove" toArray:attributeTypeArray];
                    }
                    else
                    {
                        /*
                        [attributeTypeArray addObject:@"currentColor"];
                        [attributeTypeArray addObject:@"black"];
                        [attributeTypeArray addObject:@"white"];
                        [attributeTypeArray addObject:@"red"];
                        [attributeTypeArray addObject:@"blue"];
                        [attributeTypeArray addObject:@"green"];
                        [attributeTypeArray addObject:@"cyan"];
                        [attributeTypeArray addObject:@"magenta"];
                        [attributeTypeArray addObject:@"yellow"];
                        [attributeTypeArray addObject:@"#000000"];
                        [attributeTypeArray addObject:@"url(#aElementID)"];
                        */

                        //[self addValue:@"currentColor" toArray:attributeTypeArray];
                        [self addValue:@"black" toArray:attributeTypeArray];
                        [self addValue:@"white" toArray:attributeTypeArray];
                        [self addValue:@"red" toArray:attributeTypeArray];
                        [self addValue:@"blue" toArray:attributeTypeArray];
                        [self addValue:@"green" toArray:attributeTypeArray];
                        [self addValue:@"cyan" toArray:attributeTypeArray];
                        [self addValue:@"magenta" toArray:attributeTypeArray];
                        [self addValue:@"#000000" toArray:attributeTypeArray];
                        //[self addValue:@"url(#aElementID)" toArray:attributeTypeArray];
                        
                    }
                    
                    aAttributeDictionary[@"attribute_type"] = attributeTypeArray;
                }
            }
        }
    }
    
    // add several stroke attribute defined values for elements where stroke is a valid attribute
    for (NSString * aElementKey in allElementKeys)
    {
        NSDictionary * aElementDictionary = (self.elementsDictionary)[aElementKey];
        NSDictionary * attributesDictionary = aElementDictionary[@"attributes"];
        
        if (attributesDictionary != NULL)
        {
            NSArray * allAttributeKeys = attributesDictionary.allKeys;
            for (NSString * attributeKey in allAttributeKeys)
            {
                NSMutableDictionary * aAttributeDictionary = attributesDictionary[attributeKey];
                NSString * attributeName = aAttributeDictionary[@"attribute_name"];
                
                NSRange repeatCountRange = [attributeName rangeOfString:@"stroke"];
                if (repeatCountRange.location == 0)
                {
                    NSArray * existingAttributeTypeArray = aAttributeDictionary[@"attribute_type"];
                    NSMutableArray * attributeTypeArray = [NSMutableArray arrayWithArray:existingAttributeTypeArray];
                    
                    /*
                    [attributeTypeArray addObject:@"none"];
                    [attributeTypeArray addObject:@"currentColor"];
                    [attributeTypeArray addObject:@"black"];
                    [attributeTypeArray addObject:@"white"];
                    [attributeTypeArray addObject:@"red"];
                    [attributeTypeArray addObject:@"blue"];
                    [attributeTypeArray addObject:@"green"];
                    [attributeTypeArray addObject:@"cyan"];
                    [attributeTypeArray addObject:@"magenta"];
                    [attributeTypeArray addObject:@"yellow"];
                    [attributeTypeArray addObject:@"#000000"];
                    [attributeTypeArray addObject:@"url(#aElementID)"];
                    */

                    [self addValue:@"none" toArray:attributeTypeArray];
                    //[self addValue:@"currentColor" toArray:attributeTypeArray];
                    [self addValue:@"black" toArray:attributeTypeArray];
                    [self addValue:@"white" toArray:attributeTypeArray];
                    [self addValue:@"red" toArray:attributeTypeArray];
                    [self addValue:@"blue" toArray:attributeTypeArray];
                    [self addValue:@"green" toArray:attributeTypeArray];
                    [self addValue:@"cyan" toArray:attributeTypeArray];
                    [self addValue:@"magenta" toArray:attributeTypeArray];
                    [self addValue:@"#000000" toArray:attributeTypeArray];
                    //[self addValue:@"url(#aElementID)" toArray:attributeTypeArray];
                    
                    aAttributeDictionary[@"attribute_type"] = attributeTypeArray;
                }
            }
        }
    }
    
    //NSLog(@"entitiesDictionary = %@", entitiesDictionary);
    //NSLog(@"classesDictionary = %@", classesDictionary);
    //NSLog(@"attribsDictionary = %@", attribsDictionary);
    //NSLog(@"attlistDictionary = %@", attlistDictionary);
    //NSLog(@"datatypesDictionary = %@", datatypesDictionary);
    //NSLog(@"elementsDictionary = %@", elementsDictionary);    
    //NSLog(@"elementContentsDictionary = %@", elementContentsDictionary);    
}

//==================================================================================

- (void)addValue:(NSString *)valueString toArray:(NSMutableArray *)aMutableArray
{
    BOOL valueFound = NO;
    
    for (NSString * aAttributeName in aMutableArray)
    {
        if ([aAttributeName isEqualToString:valueString] == YES)
        {
            valueFound = YES;
            break;
        }
    }
    
    if (valueFound == NO)
    {
        [aMutableArray addObject:[NSString stringWithString:valueString]];
    }
}

//==================================================================================
//==================================================================================
//==================================================================================

// Document handling methods
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    // sent when the parser begins parsing of the document.
    NSLog(@"parserDidStartDocument");
}

//==================================================================================

- (void)parserDidEndDocument:(NSXMLParser *)parser;
{
    // sent when the parser has completed parsing. If this is encountered, the parse was successful.
    NSLog(@"parserDidEndDocument");
}

//==================================================================================

// DTD handling methods for various declarations.
- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
    // Example: <!NOTATION img PUBLIC "urn:mime:image/jpeg">
    declarationKind = declarationKindNotation;

    NSLog(@"Notation name %@, publicID %@, systemID %@", name, publicID, systemID);
}


//==================================================================================

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
{
    // Example: <!ENTITY corplogo SYSTEM "logo.jpg" NDATA img>
    declarationKind = declarationKindUnparsed;

    NSLog(@"UnparsedEntity name %@, publicID %@, systemID %@, notationName %@", name, publicID, systemID, notationName);
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{
    // Example: <!ATTLIST dictionary title CDATA #IMPLIED >
    declarationKind = declarationKindAttribute;

    NSLog(@"Attribute %@, %@, %@, %@", attributeName, elementName, type, defaultValue);
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{
    // Example: <!ELEMENT dictionary (documentation?, suite+)>
    declarationKind = declarationKindElement;

    NSLog(@"Element %@, %@", elementName, model);
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
{
    // Example: <!ENTITY % OSType "CDATA">
    // example: name=@"Boolean.datatype" value=@"( false | true )"
    // example: name=@"SVG.rect.qname" value=@"rect"
    // example: name=@"SVG.Gradient.class" value=@" | linearGradient | radialGradient"
    // example: name=@"SVG.Shape.class" value=@" | path | rect | circle | line | ellipse | polyline | polygon" (check for \n)
    // example: name=@"SVG.Clip.attrib" value=@"clip-path CDATA #IMPLIED\
     clip-rule ( nonzero | evenodd | inherit ) #IMPLIED"
     
    declarationKind = declarationKindInternalEntity;
    
    NSLog(@"InternalEntity %@ = %@", name, value);
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
    // Example: <!ENTITY name SYSTEM "name.xml">
    declarationKind = declarationKindExternalEntity;

    NSLog(@"ExternalEntity name %@, publicID %@, systemID %@", name, publicID, systemID);
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // sent when the parser finds an element start tag.
    // In the case of the cvslog tag, the following is what the delegate receives:
    //   elementName == cvslog, namespaceURI == http://xml.apple.com/cvslog, qualifiedName == cvslog
    // In the case of the radar tag, the following is what's passed in:
    //    elementName == radar, namespaceURI == http://xml.apple.com/radar, qualifiedName == radar:radar
    // If namespace processing >isn't< on, the xmlns:radar="http://xml.apple.com/radar" is returned as an attribute pair, the elementName is 'radar:radar' and there is no qualifiedName.
    
    NSLog(@"didStartElement %@", elementName);
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // sent when an end tag is encountered. The various parameters are supplied as above.

    NSLog(@"didEndElement %@", elementName);
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
    // sent when the parser first sees a namespace attribute.
    // In the case of the cvslog tag, before the didStartElement:, you'd get one of these with prefix == @"" and namespaceURI == @"http://xml.apple.com/cvslog" (i.e. the default namespace)
    // In the case of the radar:radar tag, before the didStartElement: you'd get one of these with prefix == @"radar" and namespaceURI == @"http://xml.apple.com/radar"
    NSLog(@"didStartMappingPrefix %@", prefix);
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
    // sent when the namespace prefix in question goes out of scope.
    NSLog(@"didEndMappingPrefix %@", prefix);
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // This returns the string of the characters encountered thus far. You may not necessarily get the longest character run. The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:
    NSLog(@"foundCharacters %@", string);
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
    // The parser reports ignorable whitespace in the same way as characters it's found.
    NSLog(@"foundIgnorableWhitespace %@", whitespaceString);
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
    // The parser reports a processing instruction to you using this method. In the case above, target == @"xml-stylesheet" and data == @"type='text/css' href='cvslog.css'"
    NSLog(@"foundProcessingInstructionWithTarget %@, %@", target, data);
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
    // A comment (Text in a <!-- --> block) is reported to the delegate as a single string
    NSLog(@"foundComment %@", comment);
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    // this reports a CDATA block to the delegate as an NSData.
    NSLog(@"foundCDATA %@", CDATABlock);
}

//==================================================================================

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID
{
    // this gives the delegate an opportunity to resolve an external entity itself and reply with the resulting data.
    NSLog(@"resolveExternalEntityName %@, %@", name, systemID);
    return NULL;
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    // ...and this reports a fatal error to the delegate. The parser will stop parsing.
    NSLog(@"parseErrorOccurred %@", parseError);
}

//==================================================================================

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    // If validation is on, this will report a fatal validation error to the delegate. The parser will stop parsing.
    NSLog(@"validationErrorOccurred %@", validationError);
}

//==================================================================================

- (void)parseDTD
{
    self.dtdDatatypesDictionary = [[NSMutableDictionary alloc] init];
    self.dtdAttributesDictionary = [[NSMutableDictionary alloc] init];
    self.dtdElementsDictionary = [[NSMutableDictionary alloc] init];
    
    declarationKind = declarationKindUndefined;

	//NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    
	//NSString * dtdFilePath = [thisBundle pathForResource:@"svg11-flat-20110816" ofType:@"dtd"];
    //NSURL * svgXmlDtdUrl = [NSURL fileURLWithPath:dtdFilePath isDirectory:NO];
    
    NSURL * svgXmlDtdUrl = 
            [NSURL URLWithString:@"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"];
    
    NSMutableString * inputString = [[NSMutableString alloc] init];
    
    [inputString appendFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"];
    [inputString appendFormat:@"<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"\n"];
    [inputString appendFormat:@"\"%@\">\n", svgXmlDtdUrl];
    [inputString appendFormat:@"<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" width=\"480\" height=\"320\" viewBox=\"0 0 480 320\" preserveAspectRatio=\"xMidYMid meet\"></svg>\n"];
    
    NSData * dtdXmlData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
    
    //NSXMLParser * dtdParser = [[NSXMLParser alloc] initWithContentsOfURL:svgXmlDtdUrl];
    NSXMLParser * dtdParser = [[NSXMLParser alloc] initWithData:dtdXmlData];

    dtdParser.delegate = self;
    
    [dtdParser setShouldProcessNamespaces:YES];
    [dtdParser setShouldReportNamespacePrefixes:YES];
    [dtdParser setShouldResolveExternalEntities:YES];

    [dtdParser parse];
    
    NSError * parseError = dtdParser.parserError;
    
    NSLog(@"parseError=%@", parseError);
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
        [self analyzeDTD];
        
        //[self parseDTD];
    }
    
    return self;
}


@end
