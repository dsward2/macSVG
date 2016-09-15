//
//  sshServer.m
//  sshtest
//
//  Created by Daniel Finneran on 23/10/2011.
//  Copyright 2011 Home. All rights reserved.
//

#import "DFSSHServer.h"



@implementation DFSSHServer


@synthesize hostname, username, password,key, keypub;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}



- (void) setSSHHost:(NSString*)sshHost 
               port:(int)sshPort 
               user:(NSString*)sshUser 
               key:(NSString*)sshKey 
               keypub:(NSString*)sshKeypub 
               password:(NSString*)sshpassWord {
    
    //allocate Host details to object
    hostname = sshHost;
    port = sshPort;
    username = sshUser ;
    key = sshKey;
    keypub = sshKeypub;
    password = sshpassWord;
    //passwordFunc(password);
    
}

- (void) setSSHHostWithDictionary:(NSDictionary *)sshDetails {
    NSLog(@"%@",sshDetails);
    hostname = [sshDetails objectForKey:@"hostname"];
    port = [[sshDetails objectForKey:@"port"]intValue];
    username = [sshDetails objectForKey:@"username"];
    key = [sshDetails objectForKey:@"key"];
    keypub = [sshDetails objectForKey:@"keypub"];
    password = [sshDetails objectForKey:@"password"];
}

-(void) setSession:(LIBSSH2_SESSION *)sshSession {
    session = sshSession;
}

-(void) setSock:(int)sshSock{
    sock = sshSock;
}
-(void) setConnected:(bool)sshconnected{
    connected = sshconnected;
}

-(bool) connectionStatus {
    return connected;
}
-(NSDictionary *) sanitizedData {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          hostname, @"hostname",
                          [NSNumber numberWithInt:port], @"port", 
                          username, @"username", 
                          key, @"key", 
                          keypub, @"keypub", 
                          password, @"password", nil];
    NSLog(@"%@", dict);
    return dict;
}
    /*

- (NSMutableArray *) sanitizedData {
    //NSMutableArray *sanitizedArray = [[NSMutableArray alloc] init];
  //  [sanitizedArray addObject:hostname];
   // [sanitizedArray addObject:(int)port];
   // [sanitizedArray addObject:key];
   // [sanitizedArray addObject:keypub];
     
                                     // WithObjects:hostname, port,username, key, keypub,password, nil];
   return [[NSMutableArray alloc] initWithObjects:hostname, [NSNumber numberWithInt:port] ,username, key, keypub,password, nil];
    //return sanitizedArray;
}}*/

// Getter Methods

- (int) port {return port;}
- (int) sock {return sock;}
- (LIBSSH2_SESSION *)session {return session;}
- (LIBSSH2_CHANNEL *)channel {return channel;}

@end
