//
//  ColorEditorPlugin.m
//  ColorEditorPlugin
//
//  Created by Douglas Ward on 1/5/12.
//  Copyright © 2016 ArkPhone LLC. All rights reserved.
//

#import "ColorAttributeEditor.h"
//#import <WebKit/WebKit.h>
#import "GradientEditorPopoverViewController.h"
#import "MacSVGDocumentWindowController.h"
#import "XMLAttributesTableController.h"

@implementation ColorAttributeEditor

//==================================================================================
//	dealloc
//==================================================================================

- (void)dealloc
{
    self.webColorsArray = NULL;
}

//==================================================================================
//	init
//==================================================================================

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


//==================================================================================
//	awakeFromNib
//==================================================================================

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self buildWebColorsArray];

    [webColorsTableView reloadData];
    
    webColorsTableView.doubleAction = @selector(setWebColorButtonAction:);
    webColorsTableView.target = self;
}

//==================================================================================
//	pluginName
//==================================================================================

- (NSString *)pluginName
{
    return @"Color Attribute Editor";
}

//==================================================================================
//	isEditorForElement:elementName:
//==================================================================================

// return label if this editor can edit specified element tag name
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName
{
    NSString * result = NULL;

    return result;
}

//==================================================================================
//	isEditorForElement:elementName:attribute:
//==================================================================================

// return label if this editor can edit specified element and attribute
- (NSString *)isEditorForElement:(NSXMLElement *)aElement elementName:(NSString *)elementName attribute:(NSString *)attributeName
{
    NSString * result = NULL;
    
    BOOL validElement = NO;
    BOOL validAttribute = NO;

    if ([attributeName isEqualToString:@"fill"] == YES)
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"stroke"] == YES) 
    {
        validAttribute = YES;
    }
    else if ([attributeName isEqualToString:@"stop-color"] == YES) 
    {
        validAttribute = YES;
    }

    if (validAttribute == YES)
    {
        NSDictionary * elementsWithAttribute = [self elementsWithAttribute:attributeName];
        if (elementsWithAttribute[elementName] != NULL)
        {
            validElement = YES;
        }

        if ([elementName isEqualToString:@"set"] == YES) 
        {
            validElement = NO;
        }
        else if ([elementName isEqualToString:@"animate"] == YES) 
        {
            validElement = NO;
        }
        else if ([elementName isEqualToString:@"animateColor"] == YES) 
        {
            validElement = NO;
        }
        else if ([elementName isEqualToString:@"animateMotion"] == YES) 
        {
            validElement = NO;
        }
        else if ([elementName isEqualToString:@"animateTransform"] == YES) 
        {
            validElement = NO;
        }
        
        if (validElement == YES)
        {
            result = self.pluginName;
        }
    }

    return result;
}

//==================================================================================
//	editorPriority:context:
//==================================================================================

- (NSInteger)editorPriority:(NSXMLElement *)targetElement context:(NSString *)context
{
    return 30;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

//==================================================================================
//	beginEditForXMLElement:domElement:attributeName:existingValue:
//==================================================================================

- (BOOL)beginEditForXMLElement:(NSXMLElement *)newPluginTargetXMLElement
        domElement:(DOMElement *)newPluginTargetDOMElement
        attributeName:(NSString *)newAttributeName
        existingValue:(NSString *)existingValue
{
    BOOL result = [super beginEditForXMLElement:newPluginTargetXMLElement
            domElement:newPluginTargetDOMElement attributeName:newAttributeName
            existingValue:existingValue];
    
    NSString * tagName = (self.pluginTargetXMLElement).name;
    if ([tagName isEqualToString:@"stop"] == YES)
    {
        [setGradientButton setEnabled:NO];
    }
    else
    {
        [setGradientButton setEnabled:YES];
    }

    NSString * colorTextString = existingValue;

    colorTextField.stringValue = colorTextString;

    NSUInteger colorTextLength = colorTextString.length;

    if (colorTextLength > 0)
    {
        unichar firstCharacter = [colorTextString characterAtIndex:0];
                
        if (firstCharacter == '#') 
        {
            NSRange hexRange;
            hexRange.location = 0;
            hexRange.length = 0;

            if (colorTextLength == 4)
            {
                // short-form hex specification
                hexRange.location = 1;
                hexRange.length = 3;
            }
            
            if (colorTextLength == 7)
            {
                // check for full-length hex specification
                hexRange.location = 1;
                hexRange.length = 6;
            }
            
            if (hexRange.location > 0)
            {
                BOOL validColorChars = YES;

                for (NSUInteger i = hexRange.location; i < hexRange.length; i++)
                {
                    unichar colorChar = [colorTextString characterAtIndex:i];

                    BOOL validColorChar = NO;
                    
                    if ((colorChar >= '0') && (colorChar <= '9'))
                    {
                        validColorChar = YES;
                    }
                    else if ((colorChar >= 'A') && (colorChar <= 'F'))
                    {
                        validColorChar = YES;
                    }
                    else if ((colorChar >= 'a') && (colorChar <= 'f'))
                    {
                        validColorChar = YES;
                    }
                    
                    if (validColorChar == NO)
                    {
                        validColorChars = NO;
                    }
                }
                
                if (validColorChars == YES)
                {
                    NSString * redString = @"00";
                    NSString * greenString = @"00";
                    NSString * blueString = @"00";
                    
                    if (colorTextLength == 4)
                    {
                        unichar redChar = [colorTextString characterAtIndex:1];
                        unichar greenChar = [colorTextString characterAtIndex:2];
                        unichar blueChar = [colorTextString characterAtIndex:1];
                        
                        redString = [NSString stringWithFormat:@"%C%C", redChar, redChar];
                        greenString = [NSString stringWithFormat:@"%C%C", greenChar, greenChar];
                        blueString = [NSString stringWithFormat:@"%C%C", blueChar, blueChar];
                    }
                    
                    if (colorTextLength == 7)
                    {
                        NSRange redRange = NSMakeRange(1, 2);
                        NSRange greenRange = NSMakeRange(3, 2);
                        NSRange blueRange = NSMakeRange(5, 2);
                        
                        redString = [colorTextString substringWithRange:redRange];
                        greenString = [colorTextString substringWithRange:greenRange];
                        blueString = [colorTextString substringWithRange:blueRange];
                    }
                    
                    NSString * hexRedString = [NSString stringWithFormat:@"0x%@", redString];
                    NSString * hexGreenString = [NSString stringWithFormat:@"0x%@", greenString];
                    NSString * hexBlueString = [NSString stringWithFormat:@"0x%@", blueString];
                    
                    NSScanner* redScanner = [NSScanner scannerWithString:hexRedString];
                    unsigned int redInt;
                    [redScanner scanHexInt: &redInt];
                    
                    NSScanner* greenScanner = [NSScanner scannerWithString:hexGreenString];
                    unsigned int greenInt;
                    [greenScanner scanHexInt: &greenInt];
                    
                    NSScanner* blueScanner = [NSScanner scannerWithString:hexBlueString];
                    unsigned int blueInt;
                    [blueScanner scanHexInt: &blueInt];
                    
                    float redFloat = (float)redInt / 255.0f;
                    float greenFloat = (float)greenInt / 255.0f;
                    float blueFloat = (float)blueInt / 255.0f;
                    
                    NSColor * colorWellColor = [NSColor colorWithCalibratedRed:redFloat green:greenFloat blue:blueFloat alpha:1];
                    
                    colorWell.color = colorWellColor;
                }
            }
        }
    }


    
    NSInteger webColorsArrayCount = (self.webColorsArray).count;
    for (NSInteger i = 0; i < webColorsArrayCount; i++)
    {
        NSDictionary * colorDictionary = (self.webColorsArray)[i];
        NSString * colorName = colorDictionary[@"name"];
        
        if ([colorName isEqualToString:existingValue] == YES)
        {
            NSIndexSet * selectedIndexSet = [NSIndexSet indexSetWithIndex:i];
            [webColorsTableView selectRowIndexes:selectedIndexSet byExtendingSelection:NO];
            [webColorsTableView scrollRowToVisible:i];

            NSString * colorRGB = colorDictionary[@"rgb"];
            
            NSArray * channelsArray = [colorRGB componentsSeparatedByString:@","];
            NSString * redString = channelsArray[0];
            NSString * greenString = channelsArray[1];
            NSString * blueString = channelsArray[2];
            
            int redInt = redString.intValue;
            int greenInt = greenString.intValue;
            int blueInt = blueString.intValue;
            
            float redFloat = ((float)redInt / 255.0f);
            float greenFloat = ((float)greenInt / 255.0f);
            float blueFloat = ((float)blueInt / 255.0f);
            
            NSColor * wellColor = [NSColor colorWithCalibratedRed:redFloat green:greenFloat blue:blueFloat alpha:1.0f];
            
            colorWell.color = wellColor;

            break;
        }
    }

    return result;
}


#pragma clang diagnostic pop

//==================================================================================
//	addWebColorName:hex:rgb:
//==================================================================================

- (void)addWebColorName:(NSString *)colorName hex:(NSString *)hex rgb:(NSString *)rgb
{
    NSDictionary * colorDictionary = @{@"name": colorName,
            @"hex": hex,
            @"rgb": rgb};
            
    [self.webColorsArray addObject:colorDictionary];
    
}

//==================================================================================
//	buildWebColorsArray
//==================================================================================

- (void)buildWebColorsArray
{
    self.webColorsArray = [[NSMutableArray alloc] init];

    [self addWebColorName:@"aliceblue" hex:@"#f0f8ff" rgb:@"240,248,255"];
    [self addWebColorName:@"antiquewhite" hex:@"#faebd7" rgb:@"250,235,215"];
    [self addWebColorName:@"aqua" hex:@"#00ffff" rgb:@"0,255,255"];
    [self addWebColorName:@"aquamarine" hex:@"#7fffd4" rgb:@"127,255,212"];
    [self addWebColorName:@"azure" hex:@"#f0ffff" rgb:@"240,255,255"];
    [self addWebColorName:@"beige" hex:@"#f5f5dc" rgb:@"245,245,220"];
    [self addWebColorName:@"bisque" hex:@"#ffe4c4" rgb:@"255,228,196"];
    [self addWebColorName:@"black" hex:@"#000000" rgb:@"0,0,0"];
    [self addWebColorName:@"blanchedalmond" hex:@"#ffebcd" rgb:@"255,235,205"];
    [self addWebColorName:@"blue" hex:@"#0000ff" rgb:@"0,0,255"];
    [self addWebColorName:@"blueviolet" hex:@"#8a2be2" rgb:@"138,43,226"];
    [self addWebColorName:@"brown" hex:@"#a52a2a" rgb:@"165,42,42"];
    [self addWebColorName:@"burlywood" hex:@"#deb887" rgb:@"222,184,135"];
    [self addWebColorName:@"cadetblue" hex:@"#5f9ea0" rgb:@"95,158,160"];
    [self addWebColorName:@"chartreuse" hex:@"#7fff00" rgb:@"127,255,0"];
    [self addWebColorName:@"chocolate" hex:@"#d2691e" rgb:@"210,105,30"];
    [self addWebColorName:@"coral" hex:@"#ff7f50" rgb:@"255,127,80"];
    [self addWebColorName:@"cornflowerblue" hex:@"#6495ed" rgb:@"100,149,237"];
    [self addWebColorName:@"cornsilk" hex:@"#fff8dc" rgb:@"255,248,220"];
    [self addWebColorName:@"crimson" hex:@"#dc143c" rgb:@"220,20,60"];
    [self addWebColorName:@"cyan" hex:@"#00ffff" rgb:@"0,255,255"];
    [self addWebColorName:@"darkblue" hex:@"#00008b" rgb:@"0,0,139"];
    [self addWebColorName:@"darkcyan" hex:@"#008b8b" rgb:@"0,139,139"];
    [self addWebColorName:@"darkgoldenrod" hex:@"#b8860b" rgb:@"184,134,11"];
    [self addWebColorName:@"darkgray" hex:@"#a9a9a9" rgb:@"169,169,169"];
    [self addWebColorName:@"darkgreen" hex:@"#006400" rgb:@"0,100,0"];
    [self addWebColorName:@"darkgrey" hex:@"#a9a9a9" rgb:@"169,169,169"];
    [self addWebColorName:@"darkkhaki" hex:@"#bdb76b" rgb:@"189,183,107"];
    [self addWebColorName:@"darkmagenta" hex:@"#8b008b" rgb:@"139,0,139"];
    [self addWebColorName:@"darkolivegreen" hex:@"#556b2f" rgb:@"85,107,47"];
    [self addWebColorName:@"darkorange" hex:@"#ff8c00" rgb:@"255,140,0"];
    [self addWebColorName:@"darkorchid" hex:@"#9932cc" rgb:@"153,50,204"];
    [self addWebColorName:@"darkred" hex:@"#8b0000" rgb:@"139,0,0"];
    [self addWebColorName:@"darksalmon" hex:@"#e9967a" rgb:@"233,150,122"];
    [self addWebColorName:@"darkseagreen" hex:@"#8fbc8f" rgb:@"143,188,143"];
    [self addWebColorName:@"darkslateblue" hex:@"#483d8b" rgb:@"72,61,139"];
    [self addWebColorName:@"darkslategray" hex:@"#2f4f4f" rgb:@"47,79,79"];
    [self addWebColorName:@"darkslategrey" hex:@"#2f4f4f" rgb:@"47,79,79"];
    [self addWebColorName:@"darkturquoise" hex:@"#00ced1" rgb:@"0,206,209"];
    [self addWebColorName:@"darkviolet" hex:@"#9400d3" rgb:@"148,0,211"];
    [self addWebColorName:@"deeppink" hex:@"#ff1493" rgb:@"255,20,147"];
    [self addWebColorName:@"deepskyblue" hex:@"#00bfff" rgb:@"0,191,255"];
    [self addWebColorName:@"dimgray" hex:@"#696969" rgb:@"105,105,105"];
    [self addWebColorName:@"dimgrey" hex:@"#696969" rgb:@"105,105,105"];
    [self addWebColorName:@"dodgerblue" hex:@"#1e90ff" rgb:@"30,144,255"];
    [self addWebColorName:@"firebrick" hex:@"#b22222" rgb:@"178,34,34"];
    [self addWebColorName:@"floralwhite" hex:@"#fffaf0" rgb:@"255,250,240"];
    [self addWebColorName:@"forestgreen" hex:@"#228b22" rgb:@"34,139,34"];
    [self addWebColorName:@"fuchsia" hex:@"#ff00ff" rgb:@"255,0,255"];
    [self addWebColorName:@"gainsboro" hex:@"#dcdcdc" rgb:@"220,220,220"];
    [self addWebColorName:@"ghostwhite" hex:@"#f8f8ff" rgb:@"248,248,255"];
    [self addWebColorName:@"gold" hex:@"#ffd700" rgb:@"255,215,0"];
    [self addWebColorName:@"goldenrod" hex:@"#daa520" rgb:@"218,165,32"];
    [self addWebColorName:@"gray" hex:@"#808080" rgb:@"128,128,128"];
    [self addWebColorName:@"green" hex:@"#008000" rgb:@"0,128,0"];
    [self addWebColorName:@"greenyellow" hex:@"#adff2f" rgb:@"173,255,47"];
    [self addWebColorName:@"grey" hex:@"#808080" rgb:@"128,128,128"];
    [self addWebColorName:@"honeydew" hex:@"#f0fff0" rgb:@"240,255,240"];
    [self addWebColorName:@"hotpink" hex:@"#ff69b4" rgb:@"255,105,180"];
    [self addWebColorName:@"indianred" hex:@"#cd5c5c" rgb:@"205,92,92"];
    [self addWebColorName:@"indigo" hex:@"#4b0082" rgb:@"75,0,130"];
    [self addWebColorName:@"ivory" hex:@"#fffff0" rgb:@"255,255,240"];
    [self addWebColorName:@"khaki" hex:@"#f0e68c" rgb:@"240,230,140"];
    [self addWebColorName:@"lavender" hex:@"#e6e6fa" rgb:@"230,230,250"];
    [self addWebColorName:@"lavenderblush" hex:@"#fff0f5" rgb:@"255,240,245"];
    [self addWebColorName:@"lawngreen" hex:@"#7cfc00" rgb:@"124,252,0"];
    [self addWebColorName:@"lemonchiffon" hex:@"#fffacd" rgb:@"255,250,205"];
    [self addWebColorName:@"lightblue" hex:@"#add8e6" rgb:@"173,216,230"];
    [self addWebColorName:@"lightcoral" hex:@"#f08080" rgb:@"240,128,128"];
    [self addWebColorName:@"lightcyan" hex:@"#e0ffff" rgb:@"224,255,255"];
    [self addWebColorName:@"lightgoldenrodyellow" hex:@"#fafad2" rgb:@"250,250,210"];
    [self addWebColorName:@"lightgray" hex:@"#d3d3d3" rgb:@"211,211,211"];
    [self addWebColorName:@"lightgreen" hex:@"#90ee90" rgb:@"144,238,144"];
    [self addWebColorName:@"lightgrey" hex:@"#d3d3d3" rgb:@"211,211,211"];
    [self addWebColorName:@"lightpink" hex:@"#ffb6c1" rgb:@"255,182,193"];
    [self addWebColorName:@"lightsalmon" hex:@"#ffa07a" rgb:@"255,160,122"];
    [self addWebColorName:@"lightseagreen" hex:@"#20b2aa" rgb:@"32,178,170"];
    [self addWebColorName:@"lightskyblue" hex:@"#87cefa" rgb:@"135,206,250"];
    [self addWebColorName:@"lightslategray" hex:@"#778899" rgb:@"119,136,153"];
    [self addWebColorName:@"lightslategrey" hex:@"#778899" rgb:@"119,136,153"];
    [self addWebColorName:@"lightsteelblue" hex:@"#b0c4de" rgb:@"176,196,222"];
    [self addWebColorName:@"lightyellow" hex:@"#ffffe0" rgb:@"255,255,224"];
    [self addWebColorName:@"lime" hex:@"#00ff00" rgb:@"0,255,0"];
    [self addWebColorName:@"limegreen" hex:@"#32cd32" rgb:@"50,205,50"];
    [self addWebColorName:@"linen" hex:@"#faf0e6" rgb:@"250,240,230"];
    [self addWebColorName:@"magenta" hex:@"#ff00ff" rgb:@"255,0,255"];
    [self addWebColorName:@"maroon" hex:@"#800000" rgb:@"128,0,0"];
    [self addWebColorName:@"mediumaquamarine" hex:@"#66cdaa" rgb:@"102,205,170"];
    [self addWebColorName:@"mediumblue" hex:@"#0000cd" rgb:@"0,0,205"];
    [self addWebColorName:@"mediumorchid" hex:@"#ba55d3" rgb:@"186,85,211"];
    [self addWebColorName:@"mediumpurple" hex:@"#9370db" rgb:@"147,112,219"];
    [self addWebColorName:@"mediumseagreen" hex:@"#3cb371" rgb:@"60,179,113"];
    [self addWebColorName:@"mediumslateblue" hex:@"#7b68ee" rgb:@"123,104,238"];
    [self addWebColorName:@"mediumspringgreen" hex:@"#00fa9a" rgb:@"0,250,154"];
    [self addWebColorName:@"mediumturquoise" hex:@"#48d1cc" rgb:@"72,209,204"];
    [self addWebColorName:@"mediumvioletred" hex:@"#c71585" rgb:@"199,21,133"];
    [self addWebColorName:@"midnightblue" hex:@"#191970" rgb:@"25,25,112"];
    [self addWebColorName:@"mintcream" hex:@"#f5fffa" rgb:@"245,255,250"];
    [self addWebColorName:@"mistyrose" hex:@"#ffe4e1" rgb:@"255,228,225"];
    [self addWebColorName:@"moccasin" hex:@"#ffe4b5" rgb:@"255,228,181"];
    [self addWebColorName:@"navajowhite" hex:@"#ffdead" rgb:@"255,222,173"];
    [self addWebColorName:@"navy" hex:@"#000080" rgb:@"0,0,128"];
    [self addWebColorName:@"oldlace" hex:@"#fdf5e6" rgb:@"253,245,230"];
    [self addWebColorName:@"olive" hex:@"#808000" rgb:@"128,128,0"];
    [self addWebColorName:@"olivedrab" hex:@"#6b8e23" rgb:@"107,142,35"];
    [self addWebColorName:@"orange" hex:@"#ffa500" rgb:@"255,165,0"];
    [self addWebColorName:@"orangered" hex:@"#ff4500" rgb:@"255,69,0"];
    [self addWebColorName:@"orchid" hex:@"#da70d6" rgb:@"218,112,214"];
    [self addWebColorName:@"palegoldenrod" hex:@"#eee8aa" rgb:@"238,232,170"];
    [self addWebColorName:@"palegreen" hex:@"#98fb98" rgb:@"152,251,152"];
    [self addWebColorName:@"paleturquoise" hex:@"#afeeee" rgb:@"175,238,238"];
    [self addWebColorName:@"palevioletred" hex:@"#db7093" rgb:@"219,112,147"];
    [self addWebColorName:@"papayawhip" hex:@"#ffefd5" rgb:@"255,239,213"];
    [self addWebColorName:@"peachpuff" hex:@"#ffdab9" rgb:@"255,218,185"];
    [self addWebColorName:@"peru" hex:@"#cd853f" rgb:@"205,133,63"];
    [self addWebColorName:@"pink" hex:@"#ffc0cb" rgb:@"255,192,203"];
    [self addWebColorName:@"plum" hex:@"#dda0dd" rgb:@"221,160,221"];
    [self addWebColorName:@"powderblue" hex:@"#b0e0e6" rgb:@"176,224,230"];
    [self addWebColorName:@"purple" hex:@"#800080" rgb:@"128,0,128"];
    [self addWebColorName:@"red" hex:@"#ff0000" rgb:@"255,0,0"];
    [self addWebColorName:@"rosybrown" hex:@"#bc8f8f" rgb:@"188,143,143"];
    [self addWebColorName:@"royalblue" hex:@"#4169e1" rgb:@"65,105,225"];
    [self addWebColorName:@"saddlebrown" hex:@"#8b4513" rgb:@"139,69,19"];
    [self addWebColorName:@"salmon" hex:@"#fa8072" rgb:@"250,128,114"];
    [self addWebColorName:@"sandybrown" hex:@"#f4a460" rgb:@"244,164,96"];
    [self addWebColorName:@"seagreen" hex:@"#2e8b57" rgb:@"46,139,87"];
    [self addWebColorName:@"seashell" hex:@"#fff5ee" rgb:@"255,245,238"];
    [self addWebColorName:@"sienna" hex:@"#a0522d" rgb:@"160,82,45"];
    [self addWebColorName:@"silver" hex:@"#c0c0c0" rgb:@"192,192,192"];
    [self addWebColorName:@"skyblue" hex:@"#87ceeb" rgb:@"135,206,235"];
    [self addWebColorName:@"slateblue" hex:@"#6a5acd" rgb:@"106,90,205"];
    [self addWebColorName:@"slategray" hex:@"#708090" rgb:@"112,128,144"];
    [self addWebColorName:@"slategrey" hex:@"#708090" rgb:@"112,128,144"];
    [self addWebColorName:@"snow" hex:@"#fffafa" rgb:@"255,250,250"];
    [self addWebColorName:@"springgreen" hex:@"#00ff7f" rgb:@"0,255,127"];
    [self addWebColorName:@"steelblue" hex:@"#4682b4" rgb:@"70,130,180"];
    [self addWebColorName:@"tan" hex:@"#d2b48c" rgb:@"210,180,140"];
    [self addWebColorName:@"teal" hex:@"#008080" rgb:@"0,128,128"];
    [self addWebColorName:@"thistle" hex:@"#d8bfd8" rgb:@"216,191,216"];
    [self addWebColorName:@"tomato" hex:@"#ff6347" rgb:@"255,99,71"];
    [self addWebColorName:@"turquoise" hex:@"#40e0d0" rgb:@"64,224,208"];
    [self addWebColorName:@"violet" hex:@"#ee82ee" rgb:@"238,130,238"];
    [self addWebColorName:@"wheat" hex:@"#f5deb3" rgb:@"245,222,179"];
    [self addWebColorName:@"white" hex:@"#ffffff" rgb:@"255,255,255"];
    [self addWebColorName:@"whitesmoke" hex:@"#f5f5f5" rgb:@"245,245,245"];
    [self addWebColorName:@"yellow" hex:@"#ffff00" rgb:@"255,255,0"];
    [self addWebColorName:@"yellowgreen" hex:@"#9acd32" rgb:@"154,205,50"];
}


//==================================================================================
//	numberOfRowsInTableView
//==================================================================================

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return (self.webColorsArray).count;
}

//==================================================================================
//	tableView:objectValueForTableColumn:rowIndex
//==================================================================================

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    id objectValue = NULL;
    NSDictionary * webColorDictionary = (self.webColorsArray)[rowIndex];
    
    if (webColorDictionary != NULL)
    {
        if ([aTableColumn.identifier isEqualToString:@"Swatch"] == YES)
        {
            objectValue = webColorDictionary[@"rgb"];
        } 
        else if ([aTableColumn.identifier isEqualToString:@"HTML Color Name"] == YES)
        {
            objectValue = webColorDictionary[@"name"];
        } 
    } 
    
    return objectValue;
}

//==================================================================================
//	tableViewSelectionDidChange:
//==================================================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id aTableView = aNotification.object;
	if (aTableView == webColorsTableView)
	{
	}
}

//==================================================================================
//	updateAttributeValue
//==================================================================================

- (void)updateAttributeValue
{
    NSXMLNode * attributeNode = [self.pluginTargetXMLElement attributeForName:self.activeAttributeName];
    
    if (attributeNode != NULL)
    {
        NSString * colorTextString = colorTextField.stringValue;
        attributeNode.stringValue = colorTextString;
        
        [self updateDocumentViews];
    }
}

//==================================================================================
//	validateColorTextField
//==================================================================================

- (BOOL)validateColorTextField
{
    BOOL result = NO;

    NSString * colorTextString = colorTextField.stringValue;

    NSUInteger colorTextLength = colorTextString.length;

    if (colorTextLength > 0)
    {
        unichar firstCharacter = [colorTextString characterAtIndex:0];
                
        if (firstCharacter == '#') 
        {
            NSRange hexRange;
            hexRange.location = 0;
            hexRange.length = 0;

            if (colorTextLength == 4)
            {
                // short-form hex specification
                hexRange.location = 1;
                hexRange.length = 3;
            }
            
            if (colorTextLength == 7)
            {
                // check for full-length hex specification
                hexRange.location = 1;
                hexRange.length = 6;
            }
            
            if (hexRange.location > 0)
            {
                BOOL validColorChars = YES;

                for (NSUInteger i = hexRange.location; i < hexRange.length; i++)
                {
                    unichar colorChar = [colorTextString characterAtIndex:i];

                    BOOL validColorChar = NO;
                    
                    if ((colorChar >= '0') && (colorChar <= '9'))
                    {
                        validColorChar = YES;
                    }
                    else if ((colorChar >= 'A') && (colorChar <= 'F'))
                    {
                        validColorChar = YES;
                    }
                    else if ((colorChar >= 'a') && (colorChar <= 'f'))
                    {
                        validColorChar = YES;
                    }
                    
                    if (validColorChar == NO)
                    {
                        validColorChars = NO;
                    }
                }

                if (validColorChars == NO)
                {
                    // check for gradient
                    NSString * idString = [colorTextString substringFromIndex:1];
                    
                    NSArray * allGradientElements = [self findAllGradientElements];
                    
                    for (NSXMLElement * aGradientElement in allGradientElements)
                    {
                        NSXMLNode * gradientIDNode = [aGradientElement attributeForName:@"id"];
                        NSString * gradientIDString = gradientIDNode.stringValue;
                        
                        if ([idString isEqualToString:gradientIDString] == YES)
                        {
                            validColorChars = YES;
                            break;
                        }
                    }
                }
                
                if (validColorChars == YES)
                {
                    //[self updateAttributeValue];
                    result = YES;
                }
            }
        }
        else
        {
            // not a hex color, check for valid HTML color name
            BOOL validHTMLColor = NO; 
            BOOL continueSearch = YES;
            
            NSUInteger webColorsCount = (self.webColorsArray).count;
                        
            int colorIdx = 0;
            while (continueSearch == YES)
            {
                NSDictionary * colorNameDictionary = (self.webColorsArray)[colorIdx];
                
                NSString * aColorName = colorNameDictionary[@"name"];
                
                if ([colorTextString isEqualToString:aColorName] == YES) 
                {
                    continueSearch = NO;
                    validHTMLColor = YES;
                }
                else
                {
                    colorIdx++;
                    if (colorIdx >= webColorsCount)
                    {
                        continueSearch = NO;
                    }
                }
            }

            if (validHTMLColor == NO)
            {
                // check for gradient
                NSRange urlRange = [colorTextString rangeOfString:@"url(#"];
                if (urlRange.location == 0)
                {
                    NSInteger extractLength = colorTextString.length - 6;
                    NSRange extractURLRange = NSMakeRange(5, extractLength);
                    NSString * idString = [colorTextString substringWithRange:extractURLRange];
                    
                    NSArray * allGradientElements = [self findAllGradientElements];
                    
                    for (NSXMLElement * aGradientElement in allGradientElements)
                    {
                        NSXMLNode * gradientIDNode = [aGradientElement attributeForName:@"id"];
                        NSString * gradientIDString = gradientIDNode.stringValue;
                        
                        if ([idString isEqualToString:gradientIDString] == YES)
                        {
                            validHTMLColor = YES;
                            break;
                        }
                    }
                }
            }
            
            if (validHTMLColor == YES)
            {
                //[self updateAttributeValue];
                result = YES;
            }
        }
    }
    
    return result;
}

//==================================================================================
//	findAllLinearGradientElements
//==================================================================================

 -(NSArray *)findAllLinearGradientElements
 {       
    NSArray * resultArray = NULL;
    
    NSXMLElement * rootElement = [self.svgXmlDocument rootElement];
    
    NSString * xpathQuery = @".//linearGradient";
    
    NSError * error = NULL;
    resultArray = [rootElement nodesForXPath:xpathQuery error:&error];
    
    return resultArray;
}

//==================================================================================
//	findAllRadialGradientElements
//==================================================================================

 -(NSArray *)findAllRadialGradientElements
 {       
    NSArray * resultArray = NULL;
    
    NSXMLElement * rootElement = [self.svgXmlDocument rootElement];
    
    NSString * xpathQuery = @".//radialGradient";
    
    NSError * error = NULL;
    resultArray = [rootElement nodesForXPath:xpathQuery error:&error];
    
    return resultArray;
}

//==================================================================================
//	findAllGradientElements
//==================================================================================

 -(NSArray *)findAllGradientElements
{
    NSArray * linearGradientsArray = [self findAllLinearGradientElements];
    NSArray * radialGradientsArray = [self findAllRadialGradientElements];
    
    NSArray * mergeGradientsArray = [NSArray arrayWithArray:linearGradientsArray];
    mergeGradientsArray = [mergeGradientsArray arrayByAddingObjectsFromArray:radialGradientsArray];
    
    return mergeGradientsArray;
}


//==================================================================================
//	setColorButtonAction:
//==================================================================================

- (IBAction)setColorButtonAction:(id)sender
{
    XMLAttributesTableController * xmlAttributesTableController =
            [self.macSVGPluginCallbacks.macSVGDocumentWindowController xmlAttributesTableController];
    NSString * selectedAttributeName = [xmlAttributesTableController selectedAttributeName];

    NSXMLNode * attributeNode = [self.pluginTargetXMLElement attributeForName:self.activeAttributeName];
    if (attributeNode != NULL)
    {
        BOOL colorTextIsValid = [self validateColorTextField];
        
        if (colorTextIsValid == YES)
        {
            NSString * colorStringValue = colorTextField.stringValue;
            attributeNode.stringValue = colorStringValue;
        }
    }
    
    [self updateDocumentViews];

    if (self.macSVGPluginCallbacks.currentToolMode == toolModeCrosshairCursor)
    {
        [self.macSVGPluginCallbacks.macSVGDocumentWindowController performSelector:@selector(beginCrosshairToolMode) withObject:NULL afterDelay:0.05f];  // workaround for a problem that incorrectly added both selection rect/handles and path/polyline/polygon/line handles

        [xmlAttributesTableController performSelector:@selector(selectAttributeWithName:) withObject:selectedAttributeName afterDelay:0.1f];
    }
}

//==================================================================================
//	setGradientElement:
//==================================================================================

- (void)setGradientElement:(NSXMLElement *)gradientElement;
{
    XMLAttributesTableController * xmlAttributesTableController =
            [self.macSVGPluginCallbacks.macSVGDocumentWindowController xmlAttributesTableController];
    NSString * selectedAttributeName = [xmlAttributesTableController selectedAttributeName];

    NSXMLNode * gradientElementIDNode = [gradientElement attributeForName:@"id"];
    NSString * gradientElementIDString = gradientElementIDNode.stringValue;
    
    NSString * gradientURLString = [NSString stringWithFormat:@"url(#%@)", gradientElementIDString];
    
    colorTextField.stringValue = gradientURLString;
    
    NSXMLNode * attributeNode = [self.pluginTargetXMLElement attributeForName:self.activeAttributeName];
    attributeNode.stringValue = gradientURLString;
    
    [self updateDocumentViews];

    if (self.macSVGPluginCallbacks.currentToolMode == toolModeCrosshairCursor)
    {
        [self.macSVGPluginCallbacks.macSVGDocumentWindowController performSelector:@selector(beginCrosshairToolMode) withObject:NULL afterDelay:0.05f];  // workaround for a problem that incorrectly added both selection rect/handles and path/polyline/polygon/line handles

        [xmlAttributesTableController performSelector:@selector(selectAttributeWithName:) withObject:selectedAttributeName afterDelay:0.1f];
    }
}

//==================================================================================
//	setWebColorButtonAction:
//==================================================================================

- (IBAction)setNoneButtonAction:(id)sender;
{
    NSXMLNode * attributeNode = [self.pluginTargetXMLElement attributeForName:self.activeAttributeName];
    if (attributeNode != NULL)
    {
        NSString * colorStringValue = @"none";
        attributeNode.stringValue = colorStringValue;
    }
    
    [self updateDocumentViews];

}

//==================================================================================
//	setWebColorButtonAction:
//==================================================================================

- (IBAction)setWebColorButtonAction:(id)sender
{
    NSInteger rowIndex = webColorsTableView.selectedRow;
    
    if (rowIndex != -1)
    {
        NSDictionary * webColorDictionary = (self.webColorsArray)[rowIndex];

        NSString * colorName = webColorDictionary[@"name"];
        //NSString * colorHex = [webColorDictionary objectForKey:@"hex"];
        NSString * colorRGB = webColorDictionary[@"rgb"];
        
        colorTextField.stringValue = colorName;
        
        NSArray * channelsArray = [colorRGB componentsSeparatedByString:@","];
        NSString * redString = channelsArray[0];
        NSString * greenString = channelsArray[1];
        NSString * blueString = channelsArray[2];
        
        int redInt = redString.intValue;
        int greenInt = greenString.intValue;
        int blueInt = blueString.intValue;
        
        float redFloat = ((float)redInt / 255.0f);
        float greenFloat = ((float)greenInt / 255.0f);
        float blueFloat = ((float)blueInt / 255.0f);
        
        NSColor * wellColor = [NSColor colorWithCalibratedRed:redFloat green:greenFloat blue:blueFloat alpha:1.0f];
        
        colorWell.color = wellColor;
        
        [self setColorButtonAction:self];
    }
}


//==================================================================================
//	colorWellAction:
//==================================================================================

- (IBAction)colorWellAction:(id)sender
{
    NSColor * wellColor = colorWell.color;
    
    CGFloat redFloat = 0;
    CGFloat greenFloat = 0;
    CGFloat blueFloat = 0;
    CGFloat alphaFloat = 0;
    
    [wellColor getRed:&redFloat green:&greenFloat blue:&blueFloat alpha:&alphaFloat];
    
    int redInt = redFloat * 255.0f;
    int greenInt = greenFloat * 255.0f;
    int blueInt = blueFloat * 255.0f;
    
    NSString * colorString = [[NSString alloc] initWithFormat:@"#%02x%02x%02x",
            redInt, greenInt, blueInt];
    
    colorTextField.stringValue = colorString;
    
    [self setColorButtonAction:self];
    
}

// -------------------------------------------------------------------------------
//  colorGradientButtonAction:
// -------------------------------------------------------------------------------
- (IBAction)colorGradientButtonAction:(id)sender
{
    NSButton *targetButton = (NSButton *)sender;
    
    [gradientEditorPopoverViewController loadGradientsData];
    
    // configure the preferred position of the popover
    [gradientEditorPopover showRelativeToRect:targetButton.bounds ofView:sender preferredEdge:NSMaxYEdge];
}


@end
