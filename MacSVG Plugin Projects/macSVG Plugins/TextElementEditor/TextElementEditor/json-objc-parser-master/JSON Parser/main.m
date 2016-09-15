//
//  main.m
//  JSON Parser
//
//  Created by numata on 09/09/04.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SZJsonParser.h"


NSString *loadStringFromFile(NSString *filename)
{
    NSError *error = nil;

    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];    
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
}
    
int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    NSString *source = loadStringFromFile(@"test.js");
    id obj = [source jsonObject];
    NSLog(@"JSON Object: %@", obj);
    
    [pool release];
    
    return 0;
}


