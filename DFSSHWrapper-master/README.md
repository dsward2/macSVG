This is a simple wrapper script, that allows simple and easy use of libssh2, from http://libssh2.org.

It allows simple interactions with an ssh server, however terminal and sftp aren't implemented.
To work with libssh2, the src archive needs to be downloaded from http://libssh2.org and placed in 
the same Directory as the make_libssh.sh file. This script (ensure +x) will unpack the src archive,
configure and build it.

Usage:
	$ ./make_libssh.sh ./archive.tar.gz

It then extracts the required headers and lib archive and places everything
in a libssh2_xcode directory, which can then be added to your project (Ensure that libcrypto.dylib 
and libz.dylib are added to your project as well).

When compiling there may be warnings, this is due to a type issues strlen returning a long, when an
int is required. If you want to remove these errors cast strlen to an int (int)strlen(string), where
it occurs in the headers giving the warning.

EXAMPLE CODE:


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification

{

	// Create server instance (this can be passed around as it contains the socket info etc..)
	
	DFSSHServer *server = [[DFSSHServer alloc] init];	
	
	[server setSSHHost:@"192.168.2.100" port:22 user:@"dan" key:@"" keypub:@"" password:@"XXXXX"];
	
	// Create connection instance, this will be changed at a later date to use class methods so wont
	
	// need instantiating
	
	DFSSHConnector *connection = [[DFSSHConnector alloc] init];
	

	// Set connection status to Auto Detect (will check for keyboard/password/key)
	
	// and connect
	
	[connection connect:server connectionType:[DFSSHConnectionType auto]];
	
	// if connected try the following commands
	
	if ([server connectionStatus]) {
	
	         NSLog(@”Server 1 connected”); 
	         
	         NSLog(@”%@”,[DFSSHOperator execCommand:@"uname -a" sshServer:server]);
	         
	}   
	      
	// Close connection
	
	[connection closeSSH:server];
	
}