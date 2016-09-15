//
//  SFTPUploadWithBlocking.h
//  macSVG
//
//  Created by Douglas Ward on 10/19/13.
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

#import <Foundation/Foundation.h>

@interface SFTPUploadWithBlocking : NSObject

- (NSError *)execSFTPUploadData:(NSData *)fileData hostaddr:(NSString *)hostaddrString
        user:(NSString *)usernameString password:(NSString *)passwordString
        sftppath:(NSString *)sftppathString;

@end
