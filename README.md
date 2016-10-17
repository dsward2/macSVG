# macSVG
macSVG - A macOS App for Designing HTML5 SVG (Scalable Vector Graphics) Art and Animation

Copyright (c) 2016 by ArkPhone, LLC

![macSVG Screenshot](https://raw.githubusercontent.com/dsward2/macSVG/master/README_images/macsvg-screenshot.jpg)

# Coming soon:
A project website.
Documentation.
Examples.
Demo videos.
An Apple ID-signed application.

Until then, macSVG can be built from source code.  Open "macSVG.xcworkspace" in Xcode, set the target to "macSVG Debug", build and run.

# Early adapter notes:
Several examples are available under macSVG's Help menu with the "Browse SVG Examples..." command.

macSVG.app includes a built-in HTTP server, which allows the current document window to be quickly previewed with standard Mac web browsers, and other devices on the local area network.  The first time macSVG is launched, macOS will pose a dialog message "Do you want the application “macSVG.app” to accept incoming network connections?".  Click "Allow" or "Deny" to enable or disable remote connections.

Currently, this project uses Apple's standard WebKit.framework, not a custom version of WebKit.  However, two pre-built static libraries are members of this project: libcrypto.a, and libssh2.a built with DFSSHWrapper.

Developing...
