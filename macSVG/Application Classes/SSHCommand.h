//
//  SSHCommand.h
//  macSVG
//
//  Created by Douglas Ward on 9/24/13.
//
//

// adapted from -
//
//  DFSSHWrapper
//
//  Created by Daniel Finneran on 23/10/2011.
//  Copyright 2011 Home. All rights reserved.
//
// and libssh2 - http://libssh2.org

#import <Foundation/Foundation.h>
#import "DFSSHServer.h"

@interface SSHCommand : NSObject

+(NSString*) execCommand:(NSString *)commandlineNSString server:(DFSSHServer*)server sshError:(NSError **)sshError;

+(NSString*) execCommand:(NSString *)commandlineNSString server:(DFSSHServer*)server timeout:(NSNumber *)timeout sshError:(NSError **)sshError;

@end
