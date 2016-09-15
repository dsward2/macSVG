//
//  sshOperator.h
//  sshtest
//
//  Created by Daniel Finneran on 23/10/2011.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFSSHServer.h"

@interface DFSSHOperator : NSObject

+(NSString*) execCommand:(NSString *)commandline server:(DFSSHServer*)server;

+(NSString*) execCommand:(NSString *)commandline server:(DFSSHServer*)server timeout:(NSNumber *)timeout;

@end
