//
//  SFTPUpload.m
//  macSVG
//
//  Created by Douglas Ward on 10/1/13.
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

#import "SFTPUpload.h"

@implementation SFTPUpload

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
#ifdef HAVE_SYS_SELECT_H
# include <sys/select.h>
#endif
# ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifdef HAVE_ARPA_INET_H
# include <arpa/inet.h>
#endif
#ifdef HAVE_SYS_TIME_H
# include <sys/time.h>
#endif

#include <sys/types.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <ctype.h>
#include <time.h>

static int waitsocket(int socket_fd, LIBSSH2_SESSION *session)
{
    struct timeval timeout;
    int rc;
    fd_set fd;
    fd_set *writefd = NULL;
    fd_set *readfd = NULL;
    int dir;

    timeout.tv_sec = 10;
    timeout.tv_usec = 0;

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


- (NSError *)execSFTPUploadData:(NSData *)fileData hostaddr:(NSString *)hostaddrString
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
    //const char *loclfile="sftp_write_nonblock.c";
    const char *sftppath="/tmp/sftp_write_nonblock.c";
    int rc;
    //FILE *local;
    LIBSSH2_SFTP *sftp_session;
    LIBSSH2_SFTP_HANDLE *sftp_handle;
    //char mem[1024 * 100];
    //size_t nread;
    //char *ptr;
    //time_t start;
    //long total = 0;
    //int duration;

    NSError * resultError = NULL;

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
    if (argc > 2) {
        username = argv[2];
    }
    if (argc > 3) {
        password = argv[3];
    }
    if (argc > 4) {
        loclfile = argv[4];
    }
    if (argc > 5) {
        sftppath = argv[5];
    }
*/

    hostaddr = inet_addr([hostaddrString cStringUsingEncoding:NSASCIIStringEncoding]);
    username = [usernameString cStringUsingEncoding:NSASCIIStringEncoding];
    password = [passwordString cStringUsingEncoding:NSASCIIStringEncoding];
    sftppath = [sftppathString cStringUsingEncoding:NSASCIIStringEncoding];

    rc = libssh2_init (0);
    if (rc != 0) {
        fprintf (stderr, "libssh2 initialization failed (%d)\n", rc);
        //return 1;
        NSString * errorString = [NSString stringWithFormat:@"libssh2 initialization failed (%d)", rc];
        resultError = [NSError errorWithDomain:errorString code:1 userInfo:NULL];
        goto finalExit;
    }

/*
    local = fopen(loclfile, "rb");
    if (!local) {
        fprintf(stderr, "Can't open local file %s\n", loclfile);
        //return -1;
    }
*/

    /*
     * The application code is responsible for creating the socket
     * and establishing the connection
     */
    sock = socket(AF_INET, SOCK_STREAM, 0);

    sin.sin_family = AF_INET;
    sin.sin_port = htons(22);
    sin.sin_addr.s_addr = (in_addr_t)hostaddr;
    if (connect(sock, (struct sockaddr*)(&sin),
                sizeof(struct sockaddr_in)) != 0) {
        fprintf(stderr, "failed to connect!\n");
        //return -1;
        NSString * errorString = [NSString stringWithFormat:@"SSH failed to connect"];
        resultError = [NSError errorWithDomain:errorString code:2 userInfo:NULL];
        goto finalExit;
    }

    /* Create a session instance
        */
    session = libssh2_session_init();
    if(!session)
    {
        //return -1;
        NSString * errorString = [NSString stringWithFormat:@"SSH session failed to initialize"];
        resultError = [NSError errorWithDomain:errorString code:3 userInfo:NULL];
        goto finalExit;
    }

    /* Since we have set non-blocking, tell libssh2 we are non-blocking */
    libssh2_session_set_blocking(session, 0);

    /* ... start it up. This will trade welcome banners, exchange keys,
        * and setup crypto, compression, and MAC layers
        */
    while ((rc = libssh2_session_handshake(session, sock))
           == LIBSSH2_ERROR_EAGAIN);
    if (rc) {
        fprintf(stderr, "Failure establishing SSH session: %d\n", rc);
        NSString * errorString = [NSString stringWithFormat:@"Failure setting blocking SSH session (%d)", rc];
        resultError = [NSError errorWithDomain:errorString code:4 userInfo:NULL];
        goto finalExit;
    }

    /* At this point we havn't yet authenticated.  The first thing to do is
     * check the hostkey's fingerprint against our known hosts Your app may
     * have it hard coded, may go to a file, may present it to the user,
     * that's your call
     */
    fingerprint = libssh2_hostkey_hash(session, LIBSSH2_HOSTKEY_HASH_SHA1);
    //fprintf(stderr, "Fingerprint: ");
    //for(i = 0; i < 20; i++) {
    //    fprintf(stderr, "%02X ", (unsigned char)fingerprint[i]);
    //}
    //fprintf(stderr, "\n");

    if (auth_pw) {
        /* We could authenticate via password */
        while ((rc = libssh2_userauth_password(session, username, password)) ==
               LIBSSH2_ERROR_EAGAIN);
        if (rc) {
            fprintf(stderr, "Authentication by password failed.\n");
            NSString * errorString = [NSString stringWithFormat:@"SSH authentication by password failed"];
            resultError = [NSError errorWithDomain:errorString code:6 userInfo:NULL];
            goto shutdown;
        }
    } else {
        /* Or by public key */
        while ((rc = libssh2_userauth_publickey_fromfile(session, username,
                                                         "/home/username/.ssh/id_rsa.pub",
                                                         "/home/username/.ssh/id_rsa",
                                                         password)) ==
               LIBSSH2_ERROR_EAGAIN);
    if (rc) {
            fprintf(stderr, "\tAuthentication by public key failed\n");
            NSString * errorString = [NSString stringWithFormat:@"SSH authentication by public key failed"];
            resultError = [NSError errorWithDomain:errorString code:7 userInfo:NULL];
            goto shutdown;
        }
    }

    fprintf(stderr, "libssh2_sftp_init()!\n");
    do {
        sftp_session = libssh2_sftp_init(session);

        if (!sftp_session && (libssh2_session_last_errno(session) != LIBSSH2_ERROR_EAGAIN))
        {
            char * errorMsg = NULL;
            int errorMsgLength = 0;
            int want_buf = 0;
            int errorInt = libssh2_session_last_error(session, &errorMsg,
                    &errorMsgLength, want_buf);
            NSString * sshErrorString = [NSString stringWithUTF8String:errorMsg];
            
            NSLog(@"Unable to open SFTP session: %@, %d",
                    sshErrorString, errorInt);
            
            NSString * errorString = [NSString stringWithFormat:@"Unable to open SSH channel for SCP: %@, %d",
                    sshErrorString, libssh2_session_last_errno(session)];
            resultError = [NSError errorWithDomain:errorString code:8 userInfo:NULL];
            goto shutdown;

        }
    } while (!sftp_session);

    fprintf(stderr, "libssh2_sftp_open()!\n");
    /* Request a file via SFTP */
    do {
        sftp_handle =
        libssh2_sftp_open(sftp_session, sftppath,
                          LIBSSH2_FXF_WRITE|LIBSSH2_FXF_CREAT|LIBSSH2_FXF_TRUNC,
                          LIBSSH2_SFTP_S_IRUSR|LIBSSH2_SFTP_S_IWUSR|
                          LIBSSH2_SFTP_S_IRGRP|LIBSSH2_SFTP_S_IROTH);

        if (!sftp_handle &&
            (libssh2_session_last_errno(session) != LIBSSH2_ERROR_EAGAIN))
        {
            //fprintf(stderr, "Unable to open file with SFTP\n");
            //goto shutdown;
            char * errorMsg = NULL;
            int errorMsgLength = 0;
            int want_buf = 0;
            int errorInt = libssh2_session_last_error(session, &errorMsg,
                    &errorMsgLength, want_buf);
            NSString * sshErrorString = [NSString stringWithUTF8String:errorMsg];
            
            NSLog(@"Unable to open SFTP output file: %@, %d",
                    sshErrorString, errorInt);
            
            NSString * errorString = [NSString stringWithFormat:@"Unable to open SFTP output file: %@, %d",
                    sshErrorString, libssh2_session_last_errno(session)];
            resultError = [NSError errorWithDomain:errorString code:9 userInfo:NULL];
            goto shutdown;
        }
    } while (!sftp_handle);

    fprintf(stderr, "libssh2_sftp_open() is done, now send data!\n");

    //start = time(NULL);

/*
    do {
        nread = fread(mem, 1, sizeof(mem), local);
        
        if (nread <= 0) {
            // end of file
            break;
        }
        ptr = mem;

        total += nread;

        do {
            // write data in a loop until we block
            while ((rc = libssh2_sftp_write(sftp_handle, ptr, nread)) == LIBSSH2_ERROR_EAGAIN)
            {
                waitsocket(sock, session);
            }
            if(rc < 0)
            {
                break;
            }
            ptr += rc;
            nread -= rc;

        } while (nread);
    } while (rc > 0);
*/

    NSInteger dataSize = [fileData length];
    NSLog(@"dataSize = %ld", dataSize);
    off_t got=0;

    while(got < dataSize)
    {
        char mem[1024 * 100];
        NSInteger amount=sizeof(mem);
        NSInteger rc2 = 0;

        if((dataSize - got) < amount)
        {
            amount = dataSize - got;
        }
        
        NSRange outputRange = NSMakeRange(got, amount);  // dsward calc output range
        [fileData getBytes:&mem range:outputRange];    // dsward get output data
        
        NSLog(@"amount = %ld", amount);
        NSLog(@"got = %lld", got);
        
        if(amount > 0)
        {
            //write(1, mem, rc);
            //rc2 = libssh2_channel_write(channel, mem, amount);

            while ((rc2 = libssh2_sftp_write(sftp_handle, mem, amount)) == LIBSSH2_ERROR_EAGAIN)
            {
                waitsocket(sock, session);
            }
        }
        
        if (rc2 < 0)
        {
            NSLog(@"SFTP write error");
            NSString * errorString = [NSString stringWithFormat:@"SFTP write error (%ld)", (long)rc2];
            resultError = [NSError errorWithDomain:errorString code:10 userInfo:NULL];
        }
        
        got += rc2;
    }


    //duration = (int)(time(NULL)-start);
    //fprintf(stderr, "%ld bytes in %d seconds makes %.1f bytes/sec\n",
    //       total, duration, total/(double)duration);


    //fclose(local);
    libssh2_sftp_close(sftp_handle);
    libssh2_sftp_shutdown(sftp_session);

shutdown:

    while (libssh2_session_disconnect(session, "Normal Shutdown")
           == LIBSSH2_ERROR_EAGAIN);
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
