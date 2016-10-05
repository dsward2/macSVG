//
//  SSHCommand.m
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

#import "SSHCommand.h"
#import "libssh2.h"

@implementation SSHCommand

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
//	waitsocket
//==================================================================================

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

//==================================================================================
//	execCommand:server:
//==================================================================================

// Timer driven exec
+(NSString *) execCommand:(NSString *)commandlineNSString server:(DFSSHServer*)server sshError:(NSError **)sshError
{
    return [self execCommand:commandlineNSString server:server timeout:@1.0  sshError:sshError];
}

//==================================================================================
//	execCommand:server:timeout:
//==================================================================================

// from libssh2 example - ssh2_exec.c
+(NSString *) execCommand:(NSString *)commandlineNSString server:(DFSSHServer*)server timeout:(NSNumber *)timeout sshError:(NSError **)sshError
{
    NSMutableString * outputBuffer = [NSMutableString string];

    long long rc;
    int exitcode;
    LIBSSH2_CHANNEL *channel;

    CFAbsoluteTime time;
    time = CFAbsoluteTimeGetCurrent() + timeout.doubleValue;
    if (![server connectionStatus])
    {
        //return @"No Connection";
        fprintf (stderr, "libssh2 connection failed\n");
        NSString * errorString = @"libssh2 connection failed";
        * sshError = [NSError errorWithDomain:errorString code:1 userInfo:NULL];
        goto finalExit;
    }
    
    const char * cmd = commandlineNSString.UTF8String;
    
    if (!cmd)
    {
        //return @"";
        fprintf(stderr, "SSH command missing\n");
        //return -1;
        NSString * errorString = @"SSH handshake failed";
        * sshError = [NSError errorWithDomain:errorString code:2 userInfo:NULL];
        goto finalExit;
    }
    
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
        //return @"";
        NSString * errorString = @"SSH channel  failed";
        * sshError = [NSError errorWithDomain:errorString code:3 userInfo:NULL];
        goto finalExit;
    }
    
    while( (rc = libssh2_channel_exec(channel, cmd)) == LIBSSH2_ERROR_EAGAIN )
    {
        waitsocket([server sock], [server session]);
    }
    
    if( rc != 0 )
    {
        //NSLog(@"Error, return value is wrong  rc = %ld\n", rc);
        NSLog(@"Error, return value is wrong  rc = %lld\n", rc);
        //NSLog(@"Returning empty string");
        //return @"";
        //NSString * errorString = [NSString stringWithFormat:@"SSH exec failed (%d)", rc];
        NSString * errorString = [NSString stringWithFormat:@"SSH exec failed (%lld)", rc];
        *sshError = [NSError errorWithDomain:errorString code:4 userInfo:NULL];
        goto shutdown;
    }
    
    for( ;; )
    {
        // loop until we block
        long rc2;
        do
        {
            int bytecount = 0;
            char buffer[0x4000];
            memset(buffer, 0, 0x4000);
            rc2 = libssh2_channel_read( channel, buffer, sizeof(buffer) );
            
            if( rc2 > 0 )
            {
                int i;
                bytecount += rc2;
                for( i=0; i < rc2; ++i )
                {
                    char aChar = buffer[i];
                    [outputBuffer appendFormat:@"%c", aChar];
                    // [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
                }
            }
            else
            {
                if( rc2 != LIBSSH2_ERROR_EAGAIN )
                {
                    // no need to output this for the EAGAIN case
                    NSLog(@"libssh2_channel_read returned (%ld)\n", rc2);
                }
            }
        }
        while( rc2 > 0 );

        // this is due to blocking that would occur otherwise so we loop on
        // this condition
        if( rc2 == LIBSSH2_ERROR_EAGAIN ) {
            waitsocket([server sock], [server session]);
        }
        else
        {
            break;
        }
    }

shutdown:
    
    exitcode = 127;
    while( (rc = libssh2_channel_close(channel)) == LIBSSH2_ERROR_EAGAIN )
        waitsocket([server sock], [server session]);

    if( rc == 0 )
    {
        exitcode = libssh2_channel_get_exit_status( channel );
    }
    
    libssh2_channel_free(channel);
    channel = NULL;
    
finalExit:

    libssh2_exit();

    return outputBuffer;
}

@end
