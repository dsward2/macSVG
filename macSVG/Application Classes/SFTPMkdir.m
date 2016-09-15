//
//  SFTPMkdir.m
//  macSVG
//
//  Created by Douglas Ward on 10/2/13.
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

#import "SFTPMkdir.h"

#include "libssh2_config.h"
#include "libssh2.h"
#include "libssh2_sftp.h"

#ifdef HAVE_WINSOCK2_H
# include <winsock2.h>
#endif
#ifdef HAVE_SYS_SOCKET_H
# include <sys/socket.h>
#endif
#ifdef HAVE_NETINET_IN_H
# include <netinet/in.h>
#endif
# ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifdef HAVE_ARPA_INET_H
# include <arpa/inet.h>
#endif

#include <sys/types.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <ctype.h>

@implementation SFTPMkdir


- (NSError *)execSFTPMkdir:(NSString *)directoryName
        hostaddr:(NSString *)hostaddrString
        user:(NSString *)usernameString password:(NSString *)passwordString
        sftppath:(NSString *)sftppathString
{
    unsigned long hostaddr;
    //int sock, i, auth_pw = 1;
    int sock, auth_pw = 1;
    struct sockaddr_in sin;
    const char *fingerprint;
    LIBSSH2_SESSION *session;
    const char *username="username";
    const char *password="password";
    const char *sftppath="/tmp/sftp_mkdir_nonblock";
    int rc;
    LIBSSH2_SFTP *sftp_session;

    NSError * resultError = NULL;
    NSString * newDirectoryPath = [sftppathString stringByAppendingPathComponent:directoryName];
    const char * newDirectoryPathCString = [newDirectoryPath cStringUsingEncoding:NSASCIIStringEncoding];

#ifdef WIN32
    WSADATA wsadata;

    WSAStartup(MAKEWORD(2,0), &wsadata);
#endif

/*
    if (argc > 1) {
        hostaddr = inet_addr(argv[1]);
    } else {
        hostaddr = htonl(0x7F000001);
    }
    if(argc > 2) {
        username = argv[2];
    }
    if(argc > 3) {
        password = argv[3];
    }
    if(argc > 4) {
        sftppath = argv[4];
    }

    rc = libssh2_init (0);
    if (rc != 0) {
        fprintf (stderr, "libssh2 initialization failed (%d)\n", rc);
        return 1;
    }
*/

    hostaddr = inet_addr([hostaddrString cStringUsingEncoding:NSASCIIStringEncoding]);
    username = [usernameString cStringUsingEncoding:NSASCIIStringEncoding];
    password = [passwordString cStringUsingEncoding:NSASCIIStringEncoding];
    sftppath = [sftppathString cStringUsingEncoding:NSASCIIStringEncoding];

    /* Create a session instance
     */
    session = libssh2_session_init();
    if(!session)
    {
        //return -1;
        NSString * errorString = [NSString stringWithFormat:@"libssh2 initialization failed (%d)", rc];
        resultError = [NSError errorWithDomain:errorString code:1 userInfo:NULL];
        goto finalExit;
    }

    /*
     * The application code is responsible for creating the socket
     * and establishing the connection
     */
    sock = socket(AF_INET, SOCK_STREAM, 0);

    sin.sin_family = AF_INET;
    sin.sin_port = htons(22);
    sin.sin_addr.s_addr = (in_addr_t)hostaddr;
    if (connect(sock, (struct sockaddr*)(&sin),
            sizeof(struct sockaddr_in)) != 0)
    {
        fprintf(stderr, "failed to connect!\n");
        //return -1;
        NSString * errorString = [NSString stringWithFormat:@"SSH failed to connect"];
        resultError = [NSError errorWithDomain:errorString code:2 userInfo:NULL];
        goto finalExit;
    }

    
    /* ... start it up. This will trade welcome banners, exchange keys,
     * and setup crypto, compression, and MAC layers
     */
    rc = libssh2_session_handshake(session, sock);
    if(rc) {
        fprintf(stderr, "Failure establishing SSH session: %d\n", rc);
        //return -1;
        NSString * errorString = [NSString stringWithFormat:@"Failure establishing SSH session (%d)", rc];
        resultError = [NSError errorWithDomain:errorString code:4 userInfo:NULL];
        goto finalExit;
    }

    /* At this point we havn't yet authenticated.  The first thing to do
     * is check the hostkey's fingerprint against our known hosts Your app
     * may have it hard coded, may go to a file, may present it to the
     * user, that's your call
     */
    fingerprint = libssh2_hostkey_hash(session, LIBSSH2_HOSTKEY_HASH_SHA1);
    //fprintf(stderr, "Fingerprint: ");
    //for(i = 0; i < 20; i++) {
    //    fprintf(stderr, "%02X ", (unsigned char)fingerprint[i]);
    //}
    //fprintf(stderr, "\n");

    if (auth_pw) {
        /* We could authenticate via password */
        if (libssh2_userauth_password(session, username, password)) {
            fprintf(stderr, "Authentication by password failed.\n");
            //goto shutdown;
            NSString * errorString = [NSString stringWithFormat:@"SFTP authentication by password failed"];
            resultError = [NSError errorWithDomain:errorString code:6 userInfo:NULL];
            goto shutdown;
        }
    } else {
        /* Or by public key */
        if (libssh2_userauth_publickey_fromfile(session, username,
                            "/home/username/.ssh/id_rsa.pub",
                            "/home/username/.ssh/id_rsa",
                            password)) {
            fprintf(stderr, "\tAuthentication by public key failed\n");
            //goto shutdown;
            NSString * errorString = [NSString stringWithFormat:@"SFTP authentication by public key failed"];
            resultError = [NSError errorWithDomain:errorString code:7 userInfo:NULL];
            goto shutdown;
        }
    }

    fprintf(stderr, "libssh2_sftp_init()!\n");
    sftp_session = libssh2_sftp_init(session);

    if (!sftp_session) {
        fprintf(stderr, "Unable to init SFTP session\n");
        goto shutdown;

        char * errorMsg = NULL;
        int errorMsgLength = 0;
        int want_buf = 0;
        int errorInt = libssh2_session_last_error(session, &errorMsg,
                &errorMsgLength, want_buf);
        NSString * sshErrorString = [NSString stringWithUTF8String:errorMsg];
        
        NSLog(@"Unable to open SFTP session: %@, %d",
                sshErrorString, errorInt);
        
        NSString * errorString = [NSString stringWithFormat:@"Unable to open SFTP session for SCP: %@, %d",
                sshErrorString, libssh2_session_last_errno(session)];
        resultError = [NSError errorWithDomain:errorString code:8 userInfo:NULL];
        goto shutdown;
    }

    /* Since we have set non-blocking, tell libssh2 we are non-blocking */
    libssh2_session_set_blocking(session, 0);

    fprintf(stderr, "libssh2_sftp_mkdirnb()!\n");
    /* Make a directory via SFTP */
        
    while (libssh2_sftp_mkdir(sftp_session, newDirectoryPathCString,
          LIBSSH2_SFTP_S_IRWXU|
          LIBSSH2_SFTP_S_IRGRP|LIBSSH2_SFTP_S_IXGRP|
          LIBSSH2_SFTP_S_IROTH|LIBSSH2_SFTP_S_IXOTH)
           == LIBSSH2_ERROR_EAGAIN);

    libssh2_sftp_shutdown(sftp_session);

shutdown:

    libssh2_session_disconnect(session, "Normal Shutdown");
    libssh2_session_free(session);

#ifdef WIN32
    closesocket(sock);
#else
    close(sock);
#endif
    fprintf(stderr, "all done\n");

finalExit:

    libssh2_exit();

    return resultError;
}

@end
