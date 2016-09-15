//
//  SFTPReadDir.m
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

#import "SFTPReadDir.h"

@implementation SFTPReadDir



/*
 * Sample doing an SFTP directory listing.
 *
 * The sample code has default values for host name, user name, password and
 * path, but you can specify them on the command line like:
 *
 * "sftpdir 192.168.0.1 user password /tmp/secretdir"
 */

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
#ifdef HAVE_INTTYPES_H
# include <inttypes.h>
#endif

#include <sys/types.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <ctype.h>

/* last resort for systems not defining PRIu64 in inttypes.h */
#ifndef __PRI64_PREFIX
#ifdef WIN32
#define __PRI64_PREFIX "I64"
#else
#if __WORDSIZE == 64
#define __PRI64_PREFIX "l"
#else
#define __PRI64_PREFIX "ll"
#endif /* __WORDSIZE */
#endif /* WIN32 */
#endif /* !__PRI64_PREFIX */
#ifndef PRIu64
#define PRIu64 __PRI64_PREFIX "u"
#endif  /* PRIu64 */

- (void)outputPermissions:(LIBSSH2_SFTP_ATTRIBUTES)attrs resultString:(NSMutableString *)resultString;
{
    if (attrs.permissions & LIBSSH2_SFTP_S_IFDIR)
    {
        [resultString appendString:@"d"];
    }
    else
    {
        [resultString appendString:@"-"];
    }

    // owner permissions
    if (attrs.permissions & LIBSSH2_SFTP_S_IRUSR)
    {
        [resultString appendString:@"r"];
    }
    else
    {
        [resultString appendString:@"-"];
    }
    
    if (attrs.permissions & LIBSSH2_SFTP_S_IWUSR)
    {
        [resultString appendString:@"w"];
    }
    else
    {
        [resultString appendString:@"-"];
    }
    
    if (attrs.permissions & LIBSSH2_SFTP_S_IXUSR)
    {
        [resultString appendString:@"x"];
    }
    else
    {
        [resultString appendString:@"-"];
    }

    // group permissions
    if (attrs.permissions & LIBSSH2_SFTP_S_IRGRP)
    {
        [resultString appendString:@"r"];
    }
    else
    {
        [resultString appendString:@"-"];
    }
    
    if (attrs.permissions & LIBSSH2_SFTP_S_IWGRP)
    {
        [resultString appendString:@"w"];
    }
    else
    {
        [resultString appendString:@"-"];
    }
    
    if (attrs.permissions & LIBSSH2_SFTP_S_IXGRP)
    {
        [resultString appendString:@"x"];
    }
    else
    {
        [resultString appendString:@"-"];
    }
    
    // other permissions
    if (attrs.permissions & LIBSSH2_SFTP_S_IROTH)
    {
        [resultString appendString:@"r"];
    }
    else
    {
        [resultString appendString:@"-"];
    }
    
    if (attrs.permissions & LIBSSH2_SFTP_S_IWOTH)
    {
        [resultString appendString:@"w"];
    }
    else
    {
        [resultString appendString:@"-"];
    }
    
    if (attrs.permissions & LIBSSH2_SFTP_S_IXOTH)
    {
        [resultString appendString:@"x"];
    }
    else
    {
        [resultString appendString:@"-"];
    }

    [resultString appendString:@" "];
}



- (void)outputDateTime:(LIBSSH2_SFTP_ATTRIBUTES)attrs resultString:(NSMutableString *)resultString;
{
    unsigned long atime = attrs.atime;

    NSDate * aDate = [NSDate dateWithTimeIntervalSince1970:atime];

    NSDateComponents *weekdayComponents = [[NSCalendar currentCalendar]
            components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute)
            fromDate:aDate];
    
    NSInteger year = [weekdayComponents year];
    NSInteger month = [weekdayComponents month];
    NSInteger day = [weekdayComponents day];
    NSInteger hour = [weekdayComponents hour];
    NSInteger minute = [weekdayComponents minute];
    
    NSString * monthString = @"???";
    
    switch (month)
    {
        case 1:
            monthString = @"Jan";
            break;
        case 2:
            monthString = @"Feb";
            break;
        case 3:
            monthString = @"Mar";
            break;
        case 4:
            monthString = @"Apr";
            break;
        case 5:
            monthString = @"May";
            break;
        case 6:
            monthString = @"Jun";
            break;
        case 7:
            monthString = @"Jul";
            break;
        case 8:
            monthString = @"Aug";
            break;
        case 9:
            monthString = @"Sep";
            break;
        case 10:
            monthString = @"Oct";
            break;
        case 11:
            monthString = @"Nov";
            break;
        case 12:
            monthString = @"Dec";
            break;
        default:
            break;
    }
    
    NSString * dayString = [NSString stringWithFormat:@"%ld", (long)day];
    
    NSString * yearString = [NSString stringWithFormat:@"%ld", (long)year];
    
    NSString * timeString = [NSString stringWithFormat:@"%ld:%02ld", (long)hour, (long)minute];
    
    time_t currentTime = time(NULL);
    
    time_t yearTime = 60 * 60 * 24 * 365;
    NSString * outputString = NULL;
    if (currentTime - atime > yearTime)
    {
        outputString = [NSString stringWithFormat:@"%@ %@ %@ ", monthString, dayString, yearString];
    }
    else
    {
        outputString = [NSString stringWithFormat:@"%@ %@ %@ ", monthString, dayString, timeString];
    }
    
    [resultString appendString:outputString];
}

- (NSString *)execSFTPReadDir:(NSString *)hostaddrString user:(NSString *)usernameString
        password:(NSString *)passwordString sftppath:(NSString *)sftppathString sftpError:(NSError **)sftpError
{
    unsigned long hostaddr;
    //int sock, i, auth_pw = 1;
    int sock, auth_pw = 1;
    struct sockaddr_in sin;
    const char *fingerprint;
    LIBSSH2_SESSION *session;
    const char *username="username";
    const char *password="password";
    const char *sftppath="/tmp/secretdir";
    int rc;
    LIBSSH2_SFTP *sftp_session;
    LIBSSH2_SFTP_HANDLE *sftp_handle;

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
*/

    hostaddr = inet_addr([hostaddrString cStringUsingEncoding:NSASCIIStringEncoding]);
    username = [usernameString cStringUsingEncoding:NSASCIIStringEncoding];
    password = [passwordString cStringUsingEncoding:NSASCIIStringEncoding];
    sftppath = [sftppathString cStringUsingEncoding:NSASCIIStringEncoding];
    NSMutableString * resultString = [NSMutableString string];

    rc = libssh2_init (0);
    if (rc != 0) {
        fprintf (stderr, "libssh2 initialization failed (%d)\n", rc);
        NSString * errorString = [NSString stringWithFormat:@"libssh2 initialization failed (%d)", rc];
        *sftpError = [NSError errorWithDomain:errorString code:1 userInfo:NULL];
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
                sizeof(struct sockaddr_in)) != 0) {
        fprintf(stderr, "failed to connect!\n");
        NSString * errorString = [NSString stringWithFormat:@"SFTP connection failed (%d)", rc];
        *sftpError = [NSError errorWithDomain:errorString code:2 userInfo:NULL];
        goto finalExit;
    }

    /* Create a session instance
     */
    session = libssh2_session_init();
    if(!session)
    {
        //return -1;
        NSString * errorString = @"SFTP session initialization failed (%d)";
        *sftpError = [NSError errorWithDomain:errorString code:3 userInfo:NULL];
        goto finalExit;
    }

    /* Since we have set non-blocking, tell libssh2 we are non-blocking */
    libssh2_session_set_blocking(session, 0);

    /* ... start it up. This will trade welcome banners, exchange keys,
     * and setup crypto, compression, and MAC layers
     */
    while ((rc = libssh2_session_handshake(session, sock)) ==
           LIBSSH2_ERROR_EAGAIN);
    if(rc) {
        fprintf(stderr, "Failure establishing SSH session: %d\n", rc);
        //return -1;
        NSString * errorString = [NSString stringWithFormat:@"SFTP handshake failed (%d)", rc];
        *sftpError = [NSError errorWithDomain:errorString code:4 userInfo:NULL];
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
        while ((rc = libssh2_userauth_password(session, username, password)) ==
               LIBSSH2_ERROR_EAGAIN);
        if (rc) {
            fprintf(stderr, "Authentication by password failed.\n");
            NSString * errorString = [NSString stringWithFormat:@"SFTP authentication by password failed (%d)", rc];
            *sftpError = [NSError errorWithDomain:errorString code:5 userInfo:NULL];
            goto shutdown;
        }
    } else {
        /* Or by public key */
        while ((rc = libssh2_userauth_publickey_fromfile(session, username,
                                                         "/home/username/.ssh/id_rsa.pub",
                                                         "/home/username/.ssh/id_rsa",
                                                         password)) == LIBSSH2_ERROR_EAGAIN);
        if (rc) {
            fprintf(stderr, "\tAuthentication by public key failed\n");
            NSString * errorString = [NSString stringWithFormat:@"SFTP authentication by public key failed (%d)", rc];
            *sftpError = [NSError errorWithDomain:errorString code:5 userInfo:NULL];
            goto shutdown;
        }
    }

    fprintf(stderr, "libssh2_sftp_init()!\n");
    do {
        sftp_session = libssh2_sftp_init(session);

        if ((!sftp_session) && (libssh2_session_last_errno(session) !=
                                LIBSSH2_ERROR_EAGAIN)) {
            fprintf(stderr, "Unable to init SFTP session\n");
            NSString * errorString = [NSString stringWithFormat:@"SFTP initialization failed (%d)", rc];
            *sftpError = [NSError errorWithDomain:errorString code:6 userInfo:NULL];
            goto shutdown;
        }
    } while (!sftp_session);

    fprintf(stderr, "libssh2_sftp_opendir()!\n");
    /* Request a dir listing via SFTP */
    do {
        sftp_handle = libssh2_sftp_opendir(sftp_session, sftppath);

        if ((!sftp_handle) && (libssh2_session_last_errno(session) !=
                               LIBSSH2_ERROR_EAGAIN)) {
            fprintf(stderr, "Unable to open dir with SFTP\n");
            NSString * errorString = [NSString stringWithFormat:@"SFTP open directory failed (%d)", rc];
            *sftpError = [NSError errorWithDomain:errorString code:7 userInfo:NULL];
            goto shutdown;
        }
    } while (!sftp_handle);

    fprintf(stderr, "libssh2_sftp_opendir() is done, now receive listing!\n");
    do {
        char mem[512];
        LIBSSH2_SFTP_ATTRIBUTES attrs;

        /* loop until we fail */
        while ((rc = libssh2_sftp_readdir(sftp_handle, mem, sizeof(mem),
                                          &attrs)) == LIBSSH2_ERROR_EAGAIN)
        {
            ;
        }
        
        if(rc > 0)
        {
            /* rc is the length of the file name in the mem
               buffer */

            if(attrs.flags & LIBSSH2_SFTP_ATTR_PERMISSIONS)
            {
                /* this should check what permissions it
                   is and print the output accordingly */
                //printf("--fix----- ");
                
                [self outputPermissions:attrs resultString:resultString];
            }
            else
            {
                //printf("---------- ");
                [resultString appendString:@"---------- "];
            }

            if(attrs.flags & LIBSSH2_SFTP_ATTR_UIDGID)
            {
                //printf("%4ld %4ld ", attrs.uid, attrs.gid);
                [resultString appendFormat:@"0 %lu %lu ", attrs.uid, attrs.gid];
            }
            else
            {
                //printf("   -    - ");
                [resultString appendString:@"0 0 0 "];
            }

            if(attrs.flags & LIBSSH2_SFTP_ATTR_SIZE)
            {
                //printf("%8" PRIu64 " ", attrs.filesize);
                [resultString appendFormat:@"%llu ", attrs.filesize];
            }
            else
            {
                [resultString appendString:@"0 "];
            }

            if(attrs.flags & LIBSSH2_SFTP_ATTR_ACMODTIME)
            {
                //printf("%8" PRIu64 " ", attrs.filesize);
                [self outputDateTime:attrs resultString:resultString];
            }
            else
            {
                [resultString appendString:@"0 0 0 "];
            }

            //printf("%s\n", mem);
            [resultString appendFormat:@"%s\n", mem];
        }
        else if (rc == LIBSSH2_ERROR_EAGAIN)
        {
            /* blocking */
            //fprintf(stderr, "Blocking\n");
        }
        else
        {
            break;
        }

    } while (1);

    libssh2_sftp_closedir(sftp_handle);
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

    return resultString;
}

@end
