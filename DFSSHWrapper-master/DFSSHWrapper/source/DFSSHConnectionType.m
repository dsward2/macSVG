//
//  sshConnectionType.m
//  sshwrapper
//
//  Created by Daniel Finneran on 27/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DFSSHConnectionType.h"

@implementation DFSSHConnectionType

@synthesize password, keyboard_interactive, publicKey, autoDetect;

+(id)auto {
    id autoConnectorClass = [[[self class] alloc] init];
    [autoConnectorClass setAutoDetect:YES];
    return autoConnectorClass;
}

@end
