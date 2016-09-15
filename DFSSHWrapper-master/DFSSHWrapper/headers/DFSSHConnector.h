//
//  sshConnector.h
//  sshtest
//
//  Created by Daniel Finneran on 23/10/2011.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFSSHServer.h"
#import "DFSSHConnectionType.h"

@interface DFSSHConnector : NSObject {
    
//const char *test;
}

-(BOOL) closeSSH:(DFSSHServer*)server;
-(int) connectInit:(DFSSHServer*)server;

-(int) connectPublicKey:(DFSSHServer*)server;
-(int) connectPassword:(DFSSHServer*)server;
-(int) connectKeyboard_Interactive:(DFSSHServer*)server;
-(int) connect:(DFSSHServer*)server connectionType:(DFSSHConnectionType*)connectionType;
-(int)reverse_port_forward:(DFSSHServer *)server;


void kb_int(const char *name, int name_len, const char *instr, int instr_len, 
            int num_prompts, const LIBSSH2_USERAUTH_KBDINT_PROMPT *prompts, LIBSSH2_USERAUTH_KBDINT_RESPONSE *res, 
            void **abstract);
//char *passwordFunc(const char *s);
char *passwordFunc();

@end
