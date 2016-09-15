//
//  sshConnectionType.h
//  sshwrapper
//
//  Created by Daniel Finneran on 27/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFSSHConnectionType : NSObject {
    
    BOOL publicKey;
    BOOL password;
    BOOL keyboard_interactive;
    BOOL autoDetect;
}

@property (nonatomic) BOOL publicKey;
@property (nonatomic) BOOL password;
@property (nonatomic) BOOL keyboard_interactive;
@property (nonatomic) BOOL autoDetect;

+(id)auto;

@end
