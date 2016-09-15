//
//  sshOperator.m
//  sshtest
//
//  Created by Daniel Finneran on 23/10/2011.
//  Copyright 2011 Home. All rights reserved.
//

#import "DFSSHOperator.h"
#import "libssh2.h"

LIBSSH2_CHANNEL *channel;
unsigned long rc;

int exitcode;

@implementation DFSSHOperator

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

static int waitsocket(int socket_fd, LIBSSH2_SESSION *session)
{    
    // Variable Declarations
    struct timeval timeout;
    
    fd_set fd;    
    fd_set *writefd = NULL;
    fd_set *readfd = NULL;
    
    int rc;
    int dir;
	// Wait time in Seconds
    timeout.tv_sec = 0;
    // Wait time in Microseconds... (really need that level of granularity :/ )
    timeout.tv_usec = 500000;
    
    FD_ZERO(&fd);
    FD_SET(socket_fd, &fd);

 
    /* now make sure we wait in the correct direction */
    dir = libssh2_session_block_directions(session);
    if(dir & LIBSSH2_SESSION_BLOCK_INBOUND)
        readfd = &fd;
    if(dir & LIBSSH2_SESSION_BLOCK_OUTBOUND)
        writefd = &fd;
    rc = select(socket_fd + 1, readfd, writefd, NULL, &timeout);
    
    return rc;
}

// Timer driven exec
+(NSString*) execCommand:(NSString *)commandline server:(DFSSHServer*)server {
    return [self execCommand:commandline server:server timeout:[NSNumber numberWithDouble:1]];
}



// from libssh2 example - ssh2_exec.c
+(NSString*) execCommand:(NSString *)commandline server:(DFSSHServer*)server timeout:(NSNumber *)timeout {
    int bytecount = 0; /*wrap up in a function*/
    CFAbsoluteTime time;
    time = CFAbsoluteTimeGetCurrent() + [timeout doubleValue];
    if (![server connectionStatus]) 
        return @"No Connection";    

    const char * cmd = [commandline UTF8String];
    
    if (!cmd)
        return @"";
    
    char buffer[0x4000];
    
    //Clear buffer
    memset(buffer, 0, 0x4000);
    /* Exec non-blocking on the remote host */
    channel = libssh2_channel_open_session([server session]);
    int sessionError = libssh2_session_last_error([server session],NULL,NULL,0);
    while( channel == NULL && sessionError == LIBSSH2_ERROR_EAGAIN )
    {
        waitsocket([server sock], [server session]);
        // Testing Methods
        if (time < CFAbsoluteTimeGetCurrent())
            break;
        // NSLog(@"%d", sessionError);
        channel = libssh2_channel_open_session([server session]);
        sessionError = libssh2_session_last_error([server session],NULL,NULL,0);

    }
    if( channel == NULL )
    {
        NSLog(@"Error Channel is incorrect");
        NSLog(@"Returning empty string");
        return @"";
        //exit( 1 );
    }
    while( (rc = libssh2_channel_exec(channel, cmd)) == LIBSSH2_ERROR_EAGAIN )
    {
        waitsocket([server sock], [server session]);
    }
    if( rc != 0 )
    {
        NSLog(@"Error, return value is wrong  rc = %ld\n", rc);
        NSLog(@"Returning empty string");
        return @"";
    }
    for( ;; )
    {
        /* loop until we block */
        long rc1;
        if (time < CFAbsoluteTimeGetCurrent())
            break;
        do {
            rc1 = libssh2_channel_read( channel, buffer, (sizeof(buffer)));
            if( rc1 > 0 )
                bytecount += rc1;
            //else
                //NSLog(@"libssh2_channel_read returned %ld", rc1);
            }
        while( rc1 > 0 );

        /* this is due to blocking that would occur otherwise so we loop on
		 this condition */
        if( rc1 == LIBSSH2_ERROR_EAGAIN ) {
            waitsocket([server sock], [server session]);
        }
        else
            break;
    }
    exitcode = 127;
    while( (rc = libssh2_channel_close(channel)) == LIBSSH2_ERROR_EAGAIN )
        waitsocket([server sock], [server session]);

    if( rc == 0 )
    {
        exitcode = libssh2_channel_get_exit_status( channel );
    }
    //NSLog(@"Number of bytes :%d", bytecount);
    if (sizeof(buffer) > bytecount)
        buffer[(bytecount+1)] = 0;
    //NSLog(@"\nEXIT: %d bytecount: %d", exitcode, bytecount);
    libssh2_channel_free(channel);
    channel = NULL;
    //Depricated but needed :/
    if (bytecount == 0)
        return @"";
    return [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
}
@end