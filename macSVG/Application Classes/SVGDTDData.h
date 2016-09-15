//
//  SVGDTDData.h
//  macSVG
//
//  Created by Douglas Ward on 10/24/11.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVGDTDData : NSObject <NSXMLParserDelegate>
{
    int declarationKind;
}
@property (strong) NSXMLDTD * svgXmlDtd;
@property (strong) NSMutableDictionary * entitiesDictionary;
@property (strong) NSMutableDictionary * classesDictionary;
@property (strong) NSMutableDictionary * attribsDictionary;
@property (strong) NSMutableDictionary * attlistDictionary;
@property (strong) NSMutableDictionary * datatypesDictionary;
@property (strong) NSMutableDictionary * elementsDictionary;
@property (strong) NSMutableDictionary * elementContentsDictionary;

@property (strong) NSMutableDictionary * dtdDatatypesDictionary;
@property (strong) NSMutableDictionary * dtdAttributesDictionary;
@property (strong) NSMutableDictionary * dtdElementsDictionary;

@end
