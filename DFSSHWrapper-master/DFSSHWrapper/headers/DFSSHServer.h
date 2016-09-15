//
//  sshServer.h
//  sshtest
//
//  Created by Daniel Finneran on 23/10/2011.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "libssh2.h"



@interface DFSSHServer : NSObject {
    // Average SSH Details Required
    NSString *hostname;
	int port;
    NSString *username;
    NSString *password;
    // SSH Key Details
	NSString *key;
	NSString *keypub;
    // Session Status/Details
    bool connected;
    int sock;
    LIBSSH2_SESSION *session;
    LIBSSH2_CHANNEL *channel;
    
}
//Getter methods
/*
- (const char *)hostname;

- (const char *)username;
- (const char *)password;
- (const char *)key;
- (const char *)keypub;
 */
- (int)port;
- (int) sock;
- (LIBSSH2_SESSION *)session;
- (LIBSSH2_CHANNEL *)channel;

@property (nonatomic, strong) NSString *hostname;
//@property (nonatomic, retain) int port;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *keypub;

//sshServer Methods

/*-(char *)passwordFunc:(const char *)s;*/
-(void) setSSHHost:(NSString*)sshHost port:(int)sshPort user:(NSString*)sshUser key:(NSString*)sshKey keypub:(NSString*)sshKeypub password:(NSString*)sshpassWord;    /* Set SSH Server Details */

-(void) setSession:(LIBSSH2_SESSION *)sshSession; /* Set the persistant Session */
-(void) setSock:(int)sshSock; /* Set a persistant socket */
-(void) setConnected:(bool)sshconnected; /* Set state to connected */
-(bool) connectionStatus; /* Return connected status */

-(NSDictionary *) sanitizedData;
//- (NSMutableArray *) sanitizedData;
- (void) setSSHHostWithDictionary:(NSDictionary *)sshDetails;

@end
