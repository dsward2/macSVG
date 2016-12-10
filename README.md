# macSVG

<img src="https://cdn.rawgit.com/dsward2/macSVG/7cf2b09884673e1bb65a0a9ab5df184741bb7c65/README_images/macsvg-logo-animation.svg" width="660" height="105">

**macSVG is a MIT-licensed open-source macOS app for designing HTML5 SVG (Scalable Vector Graphics) art and animation**

![macSVG Screenshot](https://raw.githubusercontent.com/dsward2/macSVG/master/README_images/macsvg-screenshot.jpg)

**The macSVG website is under construction at http://macsvg.org/**

# Examples:

<img src="https://cdn.rawgit.com/dsward2/macSVG/master/macSVG/Resources/macsvg_examples/svg/path_animation_and_shape_morphing.svg">

#

<img src="https://cdn.rawgit.com/dsward2/macSVG/master/macSVG/Resources/macsvg_examples/svg/animated_text_on_a_continuous_loop.svg">

#

<img src="https://cdn.rawgit.com/dsward2/macSVG/master/macSVG/Resources/macsvg_examples/svg/animate_stroke-dasharray_on_path.svg">

# Coming soon:

A downloadable Apple ID-signed application.

Until then, macSVG can be built from source code on this repository.  

Open "macSVG.xcworkspace" in Xcode, set the build target to "macSVG Debug", build and run.

See the macSVG.org Developer page for more info: http://macsvg.org/developer/

# Early adapter notes:
Several examples are available under macSVG's Help menu with the "Browse SVG Examples..." command.

Drag-and-drop into MacSVG's NSOutlineView can import SVG files from many external sources.

When a new build of macSVG.app is launched for the first time, macOS will ask the user if macSVG should be allowed to accept incoming network connections.  If you wish to enable macSVG's built-in HTTP server, click the "Allow" button.  Or, click the "Deny" button to block incoming network connections.  

macSVG.app includes a built-in HTTP server, which allows the current document window to be quickly previewed with standard Mac web browsers like Safari, Chrome and Firefox, and other devices on the local area network, including iOS devices, PCs, etc.  The first time macSVG is launched, macOS will pose a dialog message "Do you want the application “macSVG.app” to accept incoming network connections?".  Click "Allow" or "Deny" to enable or disable remote connections.

Currently, this project uses Apple's standard WebKit.framework, not a custom version of WebKit.  However, two pre-built static libraries are members of this project: libcrypto.a, and libssh2.a built with DFSSHWrapper.

Developing...

Copyright (c) 2016 by ArkPhone, LLC.
