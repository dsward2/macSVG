////  sshConnector.m
//  sshtest
//
//  Created by Daniel Finneran on 23/10/2011.
//  Copyright 2011 Home. All rights reserved.
//

#import "DFSSHConnector.h"
#include "libssh2_config.h"
#include "libssh2.h"

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

#include <sys/time.h>
#include <sys/types.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <ctype.h>

unsigned int hostaddr;

struct sockaddr_in soin;
const char *fingerprint;

unsigned long rc;
int type;
int kb_count =0;
const char *kb_pass;

size_t len;

//Someone on the libssh team has spelling issues (known begins with a 'K')
LIBSSH2_KNOWNHOSTS *nh;

@implementation DFSSHConnector

- (id)init{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

static int waitsocket(int socket_fd, LIBSSH2_SESSION *session) {
    struct timeval timeout;
    int rc;
    fd_set fd;
    fd_set *writefd = NULL;
    fd_set *readfd = NULL;
    int dir;
    
    timeout.tv_sec = 3;
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

-(int) connect:(DFSSHServer*)server connectionType:(DFSSHConnectionType*)connectionType {
 
    //Start Connection
    [self connectInit:server];

    if (server.session) {
        
        //[NSHost hostWithName:@""];
        /*
        
         Ensure that we have a session, to use.
         
         */
        
        if (connectionType.autoDetect) {
        
        /* enable blocking from the ssh2 session */
        libssh2_session_set_blocking([server session], 1);
   
        NSArray *authtypes = [[NSString stringWithCString:(libssh2_userauth_list([server session], [[server username] UTF8String], (int)strlen([[server username] UTF8String]))) encoding:4] componentsSeparatedByString:@","];
        
            /* disable blocking again */
            
            libssh2_session_set_blocking([server session], 0);
        
        
        for (NSString *types in authtypes)
            {
            NSLog(@"%@",types);
            if ([types isEqualToString:@"publickey"]){
                connectionType.publicKey=true;
            } else if ([types isEqualToString:@"keyboard-interactive"]){
                connectionType.keyboard_interactive=true;
            } else if ([types isEqualToString:@"password"]){
                connectionType.password=true;
            }
            }
        }
  
        //Start Authentication

        if (connectionType.password) {
            NSLog(@"Using Password");
            [self connectPassword:server];
            return 0;
        }
        if (connectionType.keyboard_interactive) {
            NSLog(@"Using Keyboard");
            [self connectKeyboard_Interactive:server];
            return 0;
        }
        if (connectionType.publicKey) {
            NSLog(@"Using Public Key");
            [self connectPublicKey:server];
            return 0;
        }
    
        return 0;
    }
    return 1;
}

-(int) connectInit:(DFSSHServer*)server {

   //     hostaddr = inet_addr([[server hostname]UTF8String]);
        NSLog(@"%@",[[NSHost hostWithName:[server hostname]] address]);
    
    NSString* resolvedHost = [[NSHost hostWithName:[server hostname]] address];
    if (!resolvedHost) {
        return -1;
    }
    hostaddr = inet_addr([resolvedHost UTF8String]);
        [server setSock:socket(AF_INET, SOCK_STREAM, 0)];
        
        soin.sin_family = AF_INET;
        soin.sin_port = htons([server port]);
        soin.sin_addr.s_addr = hostaddr;
        
        if (connect([server sock], (struct sockaddr*)(&soin), sizeof(struct sockaddr_in)) != 0) {
            return -1; /*exit if not connecting */
        } 
        
        [server setSession:libssh2_session_init()]; /*Set session*/
        
        if (![server session])
            return -1;
        
        libssh2_session_set_blocking([server session], 0);
        
        /* ... start it up. This will trade welcome banners, exchange keys,
         * and setup crypto, compression, and MAC layers
         */
    
        while ((rc = libssh2_session_startup([server session], [server sock])) == LIBSSH2_ERROR_EAGAIN);
        //while ((rc = libssh2_session_handshake([server session], [server sock])) == LIBSSH2_ERROR_EAGAIN);
        if (rc) {
            NSLog(@"Failure establishing SSH session: %lu", rc);
            server.session=nil;
            return -1;
        }
        
        nh = libssh2_knownhost_init([server session]);
        if(!nh) {
            /* eeek, do cleanup here */
            return 2;
        }
        
        /* read all hosts from here */
        libssh2_knownhost_readfile(nh, "known_hosts",
                                   LIBSSH2_KNOWNHOST_FILE_OPENSSH);
        
        /* store all known hosts to here */
        libssh2_knownhost_writefile(nh, "dumpfile",
                                    LIBSSH2_KNOWNHOST_FILE_OPENSSH);
        
        fingerprint = libssh2_session_hostkey([server session], &len, &type);
        if(fingerprint) {
            struct libssh2_knownhost *host;
            int check = libssh2_knownhost_check(nh, (char *)[[server hostname]UTF8String],
                                                (char *)fingerprint, len,
                                                LIBSSH2_KNOWNHOST_TYPE_PLAIN|
                                                LIBSSH2_KNOWNHOST_KEYENC_RAW,
                                                &host);
            
            NSLog(@"Host check: %d, key: %s", check,
                  (check <= LIBSSH2_KNOWNHOST_CHECK_MISMATCH)?
                  host->key:"<none>");
            
            /*****
             * At this point, we could verify that 'check' tells us the key is
             * fine or bail out.
             *****/
        }
        else {
            /* eeek, do cleanup here */
            return 3;
        }
    
    return 0;
}

-(int) connectPublicKey:(DFSSHServer*)server {
    
    if (![server session])
        return -1;
    
    libssh2_knownhost_free(nh);
    //warning about #define doing a strlen :/
    while ((rc = libssh2_userauth_publickey_fromfile([server session], 
                                                     [[server username] UTF8String], 
                                                     [[server keypub] UTF8String], 
                                                     [[server key] UTF8String], 
                                                     [[server password] UTF8String])) == LIBSSH2_ERROR_EAGAIN);
    if (rc) {
        NSLog(@"Authentication by public key failed");
        return 1;
    }
    [server setConnected:TRUE];   
    return 0;
}

-(int) connectPassword:(DFSSHServer*)server {
    if (![server session])
        return -1;
    if ( strlen([[server password]UTF8String]) != 0 ) {
            /* We could authenticate */
            while ((rc = libssh2_userauth_password([server session], [[server username]UTF8String], [[server password]UTF8String]) ) == LIBSSH2_ERROR_EAGAIN);
            if (rc) {
                NSLog(@"Authentication by password failed for user %s", [[server username]UTF8String]);
                return 1;
        }
    }
    [server setConnected:TRUE];   
    return 0;
}

char *passwordFunc() {
    static char *pw = NULL;
    if (strlen(kb_pass)) {
        //DON'T Change *s, casting to stop warning.
        pw = (char*) kb_pass;
    } 
    return pw;
}

void kb_int(const char *name, int name_len, const char *instr, int instr_len, 
                          int num_prompts, const LIBSSH2_USERAUTH_KBDINT_PROMPT *prompts, LIBSSH2_USERAUTH_KBDINT_RESPONSE *res, 
                          void **abstract)
{  
    int i;

    (void)abstract;
    
    NSLog(@"Performing keyboard-interactive authentication.\n");

    printf("Number of prompts: %d\n\n", num_prompts);
    
    for (i = 0; i < num_prompts; i++) {
        printf("Prompt %d from server: '", i);
        fwrite(prompts[i].text, 1, prompts[i].length, stdout);
        printf("'\n");
        NSLog(@"Entering response");
        
        res[i].text = strdup(kb_pass);
        res[i].length = (int)strlen(kb_pass);
        
        printf("Response %d from user is '", i);
        fwrite(res[i].text, 1, res[i].length, stdout);
        printf("'\n\n");
    }
    
    printf("Done. Sending keyboard-interactive responses to server now.\n");


    
}

-(int) connectKeyboard_Interactive:(DFSSHServer*)server {
    if (![server session])
        return -1;

    kb_pass = [[server password]UTF8String];
    passwordFunc();    
    libssh2_session_set_blocking([server session], 1);
    int rc = (libssh2_userauth_keyboard_interactive([server session], [[server username]UTF8String], &kb_int));
    
    
    if  (rc > 0) {
        printf("\tAuthentication by keyboard-interactive failed!\n");
        return 1;
    } else if (rc < 0) {
        printf("\tAuthentication by keyboard-interactive failed!\n");
        return 1;
    }
    libssh2_session_set_blocking([server session], 0);
    if (rc == LIBSSH2_ERROR_EAGAIN) {
        printf("\tAuthentication by keyboard-interactive failed!\n");
    }
    [server setConnected:TRUE];   
    return 0;
}


-(int)reverse_port_forward:(DFSSHServer *)server{
   
   // int iretval;
   // unsigned long mode = 1;
   // int last_socket_err = 0;
    int other_port = 9999;
    fd_set read_set, write_set;

    //Local port variables
    struct sockaddr_in localhost;
    localhost.sin_family = AF_INET;
    localhost.sin_addr.s_addr = inet_addr("127.0.0.1");
    localhost.sin_port = htons(6970);
    
    // Create a pointer to a listener
    LIBSSH2_LISTENER* listener = NULL;
    
    libssh2_session_set_blocking([server session], 1); //set blocking whilst create port forward
    //listener = libssh2_channel_forward_listen_ex([server session], "127.0.0.1", 0, &other_port, 3);
    listener = libssh2_channel_forward_listen([server session], 8080);
    NSLog(@"%d is port allocated",other_port);
    
    if (!listener)
        NSLog(@"Listener was not created");
    
    LIBSSH2_CHANNEL* channel = NULL;
    
    
    // not needed
    // ioctlsocket(sshsock, FIONBIO, &mode);
    
    
    //libssh2_trace([server session], LIBSSH2_TRACE_CONN);
    libssh2_session_set_blocking([server session], 0); // non-blocking
    int err = LIBSSH2_ERROR_EAGAIN;
    char *errmsg;
    while (err == LIBSSH2_ERROR_EAGAIN)
    {
        channel = libssh2_channel_forward_accept(listener);
        if (channel) break;
        err = libssh2_session_last_errno([server session]);
        libssh2_session_last_error([server session], &errmsg, NULL, 0);
        NSLog(@"%s",errmsg);
        /* Investigate the threading! */
        
        waitsocket([server sock], [server session]);
    }
    
    if (channel)
    {
        char buf[0x4000];
        char* chunk;
        long bytes_read = 0;
        long bytes_written = 0;
        //int total_set = 0;
        struct timeval wait;
        wait.tv_sec = 0;
        wait.tv_usec = 2000;
        
        int local_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
        
        
        //ioctlsocket(local_sock, FIONBIO, &mode);
        
        if (connect(local_sock, (struct sockaddr*)(&localhost), sizeof(struct sockaddr_in)) != 0) {
            return -1; /*exit if not connecting */
        } 
        
        while (1)
        {
            bytes_read = libssh2_channel_read(channel, buf, 0x4000);
            if (bytes_read >= 0){
                FD_ZERO(&read_set);
                FD_ZERO(&write_set);
                FD_SET(local_sock, &write_set);
                
                // wait until the socket can be written to
                while (select(0, &read_set, &write_set, NULL, &wait) < 1)
                    //§ boost::this_thread::yield();
                    
                    if (FD_ISSET(local_sock, &write_set))
                    {
                        FD_CLR(local_sock, &write_set);
                        chunk = buf;
                        
                        // everything may not get written in this call because we're non blocking.  So
                        // keep writing more data until we've emptied the buffer pointer.
                        while ((bytes_written = send(local_sock, chunk, bytes_read, 0)) < bytes_read)
                        {
                            // if it couldn't write anything because the buffer is full, bytes_written
                            // will be negative which won't help our pointer math much
                            if (bytes_written > 0)
                            {
                                chunk = buf + bytes_written;
                                bytes_read -= bytes_written;
                                if (bytes_read == 0)
                                    break;
                            }
                            FD_ZERO(&read_set);
                            FD_ZERO(&write_set);
                            FD_SET(local_sock, &write_set);
                            
                            // wait until the socket can be written to
                            while (select(0, &read_set, &write_set, NULL, &wait) < 1){ }
                                // boost::this_thread::yield();
                                }
                        
                    }
            }
            
            FD_ZERO(&read_set);
            FD_ZERO(&write_set);
            FD_SET(local_sock, &read_set);
            select(0, &read_set, &write_set, NULL, &wait);
            if (FD_ISSET(local_sock, &read_set))
            {
                FD_CLR(local_sock, &read_set);
                bytes_read = recv(local_sock, buf, 0x4000, 0);
                if (bytes_read >= 0)
                    while ((bytes_written = libssh2_channel_write_ex(channel, 0, buf, bytes_read)) == LIBSSH2_ERROR_EAGAIN);
            }
        }
    } // if channel
    return 0;
}



-(BOOL) closeSSH:(DFSSHServer*)server {
    
    if (![server connectionStatus]) 
    {
        return FALSE;    
    }
    
    libssh2_session_disconnect([server session],"Disconnected");
    libssh2_session_free([server session]);
	
    close([server sock]);
    NSLog(@"Disconnecting\n");
	[server setConnected:FALSE];
	return TRUE;
}


@end
