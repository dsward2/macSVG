//
//  SZJsonParser.m
//  JSON Parser
//
//  Created by numata on 09/09/04.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "SZJsonParser.h"


@interface SZJsonParser ()

- (BOOL)hasMoreCharacters;
- (unichar)lookAtNextCharacter;
- (unichar)getNextCharacter;

- (void)skipCharacter;
- (void)skipWhiteSpaces;

- (void)skipLineComment;
- (void)skipNormalComment;
- (void)skipComment;

- (NSString *)parseString;
- (NSNumber *)parseTrue;
- (NSNumber *)parseFalse;
- (NSNumber *)parseNumber;
- (NSNull *)parseNull;
- (NSArray *)parseArray;
- (NSDictionary *)parseHashTable;

@end


@implementation SZJsonParser

- (id)initWithSource:(NSString *)source
{
    self = [super init];
    if (self) {
        //mSource = [source retain];
        self.mSource = source;
        mLength = [source length];
    }
    return self;
}

- (void)dealloc
{
    self.mSource = NULL;
    
    //[mSource release];
    //[super dealloc];
}


#pragma mark -
#pragma mark JSON Parsing Utilities

- (BOOL)hasMoreCharacters
{
    return (mPos < mLength);
}

- (unichar)lookAtNextCharacter
{
    if (mPos >= mLength) {
        @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                       reason:@"Unexpected end of source string."
                                     userInfo:nil];
    }
    return [self.mSource characterAtIndex:mPos];
}

- (unichar)getNextCharacter
{
    if (mPos >= mLength) {
        @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                       reason:@"Unexpected end of source string."
                                     userInfo:nil];
    }
    return [self.mSource characterAtIndex:mPos++];
}

- (NSString *)getNextString:(NSUInteger)length
{
    if (mPos + length > mLength) {
        @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                       reason:@"Unexpected end of source string."
                                     userInfo:nil];
    }
    NSString *ret = [self.mSource substringWithRange:NSMakeRange(mPos, length)];
    mPos += length;
    return ret;
}

- (void)skipCharacter
{
    mPos++;
}

- (void)skipWhiteSpaces
{
    while ([self hasMoreCharacters]) {
        unichar c = [self lookAtNextCharacter];
        if (!isspace((int)c)) {
            break;
        }
        [self skipCharacter];
    }
}


#pragma mark -
#pragma mark JSON Parsing Implementation

- (void)skipLineComment
{
    [self skipCharacter];   // '/'
    
    while ([self hasMoreCharacters]) {
        unichar c = [self getNextCharacter];
        if (c == '\r' || c == '\n') {
            break;
        }
    }
}

- (void)skipNormalComment
{
    [self skipCharacter];   // '*'
    
    while ([self hasMoreCharacters]) {
        unichar c = [self getNextCharacter];
        if (c == '*') {
            c = [self lookAtNextCharacter];
            if (c == '/') {
                [self skipCharacter];
                break;
            }
        }
    }
}

- (void)skipComment
{
    [self skipCharacter];
    
    unichar c = [self lookAtNextCharacter];
    if (c == '/') {
        [self skipLineComment];
    } else if (c == '*') {
        [self skipNormalComment];
    } else {
        @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                       reason:@"Illegal comment beginning."
                                     userInfo:nil];
    }
}

- (void)skipWhiteSpacesAndComments
{
    unichar c = [self lookAtNextCharacter];
    
    while (YES) {
        if (isspace((int)c)) {
            [self skipWhiteSpaces];
        } else if (c == '/') {
            [self skipComment];
        } else {
            break;
        }
        
        c = [self lookAtNextCharacter];
    }
}

- (NSString *)parseString
{
    unichar c1 = [self getNextCharacter];
    
    int stringEdgeType;     // 0:Double quotation, 1:Single quotation
    
    if (c1 == '"') {
        stringEdgeType = 0;
    } else if (c1 == '\'') {
        stringEdgeType = 1;
    } else {
        @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                       reason:@"Illegal string start character."
                                     userInfo:nil];
    }
    
    NSMutableString *ret = [NSMutableString string];
    
    BOOL isEscaped = NO;
    while ([self hasMoreCharacters]) {
        unichar c = [self getNextCharacter];
        if (!isEscaped && ((stringEdgeType == 0 && c == '"') || (stringEdgeType == 1 && c == '\''))) {
            break;
        }
        if (!isEscaped) {
            if (c == '\\') {
                isEscaped = YES;
            } else {
                [ret appendFormat:@"%C", c];
            }
        } else {
            if (c == '"') {
                [ret appendString:@"\""];
            } else if (c == '\'') {
                [ret appendString:@"'"];
            } else if (c == '/') {
                [ret appendString:@"/"];
            } else if (c == 'b') {
                [ret appendString:@"\b"];
            } else if (c == 'f') {
                [ret appendString:@"\f"];
            } else if (c == 'n') {
                [ret appendString:@"\n"];
            } else if (c == 'r') {
                [ret appendString:@"\r"];
            } else if (c == 't') {
                [ret appendString:@"\t"];
            } else if (c == 'u') {
                NSString *fourHexDigits = [self getNextString:4];
                NSScanner *scanner = [NSScanner scannerWithString:fourHexDigits];
                unsigned charCode;
                if ([scanner scanHexInt:&charCode]) {
                    [ret appendFormat:@"%C", (unichar)charCode];
                } else {
                    @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                                   reason:[NSString stringWithFormat:@"Illegal unicode character (u%@).", fourHexDigits]
                                                 userInfo:nil];
                }
            } else {
                @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                               reason:[NSString stringWithFormat:@"Illegal string escaped character (%C).", c]
                                             userInfo:nil];
            }
            isEscaped = NO;
        }
    }
    
    return ret;
}

- (NSNumber *)parseTrue
{
    NSString *str = [self getNextString:4];
    
    if (![str isEqualToString:@"true"]) {
        @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                       reason:@"Illegal character appeared."
                                     userInfo:nil];
    }
    
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)parseFalse
{
    NSString *str = [self getNextString:5];
    
    if (![str isEqualToString:@"false"]) {
        @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                       reason:@"Illegal character appeared."
                                     userInfo:nil];
    }
    
    return [NSNumber numberWithBool:NO];
}

- (NSNumber *)parseNumber
{
    NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"+-.eE0123456789"];
    
    NSMutableString *numberStr = [NSMutableString string];
    
    BOOL isFloat = NO;
    
    while ([self hasMoreCharacters]) {
        unichar c = [self lookAtNextCharacter];
        if (![numberSet characterIsMember:c]) {
            break;
        }
        if (c == '.' || c == 'e' || c == 'E') {
            isFloat = YES;
        }
        [numberStr appendFormat:@"%C", c];
        [self skipCharacter];
    }
    
    NSNumber *ret;
    NSScanner *scanner = [NSScanner scannerWithString:numberStr];
    
    if (isFloat) {
        float floatValue;
        if ([scanner scanFloat:&floatValue]) {
            ret = [NSNumber numberWithFloat:floatValue];
        } else {
            @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                           reason:@"Illegal number format."
                                         userInfo:nil];
        }
    } else {
        int intValue;
        if ([scanner scanInt:&intValue]) {
            ret = [NSNumber numberWithInt:intValue];
        } else {
            @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                           reason:@"Illegal number format."
                                         userInfo:nil];
        }
    }
    
    return ret;
}

- (NSNull *)parseNull
{
    NSString *str = [self getNextString:4];
    
    if (![str isEqualToString:@"null"]) {
        @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                       reason:@"Illegal character appeared."
                                     userInfo:nil];
    }
    
    return [NSNull null];
}

- (NSArray *)parseArray
{
    NSMutableArray *ret = [NSMutableArray array];
    
    [self skipCharacter];   // '['
    
    while (YES) {
        [self skipWhiteSpacesAndComments];
        
        // Check for empty array or sudden end
        if ([self lookAtNextCharacter] == ']') {
            [self skipCharacter];
            break;
        }
        
        id anObj = [self parseObject];
        [ret addObject:anObj];
        
        [self skipWhiteSpacesAndComments];
        
        unichar c = [self getNextCharacter];
        if (c == ']') {
            break;
        } else if (c != ',') {
            @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                           reason:@"Illegal array entry divider."
                                         userInfo:nil];
        }
    }
    
    return ret;
}

- (NSDictionary *)parseHashTable
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    
    [self skipCharacter];   // '{'
    
    while (YES) {
        [self skipWhiteSpacesAndComments];
        
        // Check for empty table or sudden end
        if ([self lookAtNextCharacter] == '}') {
            [self skipCharacter];
            break;
        }
        
        NSString *keyStr = [self parseString];
        
        [self skipWhiteSpacesAndComments];
        
        unichar c1 = [self getNextCharacter];
        if (c1 != ':') {
            @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                           reason:@"Missing ':' after a key of a hash table."
                                         userInfo:nil];
        }
        
        [self skipWhiteSpacesAndComments];
        
        id valueObj = [self parseObject];
        
        [ret setObject:valueObj forKey:keyStr];
        
        [self skipWhiteSpacesAndComments];
        
        unichar c2 = [self getNextCharacter];
        if (c2 == '}') {
            break;
        } else if (c2 != ',') {
            @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                           reason:@"Illegal hash table entry divider."
                                         userInfo:nil];
        }
    }
    
    return ret;
}

- (id)parseObject
{
    [self skipWhiteSpacesAndComments];

    unichar c = [self lookAtNextCharacter];
    
    if (c == '"' || c == '\'') {
        return [self parseString];
    } else if (c == '[') {
        return [self parseArray];
    } else if (c == '{') {
        return [self parseHashTable];
    } else if (isdigit((int)c) || c == '-' || c == '+' || c == '.') {
        return [self parseNumber];
    } else if (c == 't') {
        return [self parseTrue];
    } else if (c == 'f') {
        return [self parseFalse];
    } else if (c == 'n') {
        return [self parseNull];
    } else {
        @throw [NSException exceptionWithName:@"JSON Parsing Error"
                                       reason:[NSString stringWithFormat:@"Illegal Object Prefix: \'%C\' (0x%02x)", c, c]
                                     userInfo:nil];
    }
    
    return nil;
}

- (id)parseImpl
{
    mPos = 0;

    return [self parseObject];
}


#pragma mark -
#pragma mark JSON Parser Interface

- (id)parse
{
    id ret = nil;
    @try {
        ret = [self parseImpl];
    }
    @catch (NSException *e) {
        NSLog(@"JSON Parsing Error: %@", [e reason]);
    }
    return ret;
}

@end


#pragma mark -

/*
@implementation NSString (JsonParser)

- (id)jsonObject
{
    SZJsonParser *parser = [[SZJsonParser alloc] initWithSource:self];
    
    id obj = [parser parse];
    
    //[parser release];
    
    return obj;
}

@end
*/


