# macSVG 1.1.7

<img src="https://cdn.rawgit.com/dsward2/macSVG/7cf2b09884673e1bb65a0a9ab5df184741bb7c65/README_images/macsvg-logo-animation.svg?sanitize=true" width="660" height="105">

**May 12, 2020 – This release of macSVG 1.1.7 contains several bug fixes, notably with copy, paste and drag commands - and improves editing for SVG paths with relative coordinates.  Some improvements were made for editing animation with keyTimes/keySplines/keyPoints animate, animateMotion and animateTransform elements.  The built-in HTTP server was migrated to use GCDWebServer.**

<hr>

**macSVG is a MIT-licensed open-source macOS app for designing HTML5 SVG 1.1 (Scalable Vector Graphics) art and animation.**

![macSVG Screenshot](https://raw.githubusercontent.com/dsward2/macSVG/master/README_images/macsvg-screenshot.jpg)

macSVG can produce dynamic, high-quality graphics and animation for HTML5 web views that work on most major desktop and mobile platforms, including iOS, Android, macOS, Microsoft Windows and Linux.

macSVG uses the standard macOS WebKit framework for interactive editing and rendering of SVG documents, in addition to several Cocoa plug-in bundles for editing SVG elements and attributes.

**The latest version of macSVG.app – code-signed with a registered Apple ID from the developer – is available for download at the Github project release page:** 

**[https://github.com/dsward2/macSVG/releases](https://github.com/dsward2/macSVG/releases)**

**See the macSVG website for more documentation and release notes - [https://macsvg.org/](https://macsvg.org/)**

# Examples:

<img src="https://cdn.rawgit.com/dsward2/macSVG/master/macSVG/Resources/macsvg_examples/svg/path_animation_and_shape_morphing.svg">

#

<img src="https://cdn.rawgit.com/dsward2/macSVG/master/macSVG/Resources/macsvg_examples/svg/animated_text_on_a_continuous_loop.svg">

#

<img src="https://cdn.rawgit.com/dsward2/macSVG/238a59b65010ad2e77c8da4005fb37338b2669c4/macSVG/Resources/macsvg_examples/svg/animate_stroke-dasharray_on_path.svg">


Apple’s free Xcode system is required to build the macOS application from the source code. Most of the application source code is written in Objective-C language, but a Swift language target has been added recently for a plug-in editor bundle.  To build macSVG.app, open "macSVG.xcworkspace" in Xcode, set the build target to "macSVG Debug", build and run.

**See the macSVG.org Developer page for more info: https://macsvg.org/developer/**


# Future project goals:

Migration to Swift language, and Swift Package Manager for importing third-party code.

We are monitoring the WebKit project concerning their plans to remove the Legacy WebView framework, which is used extensively in macSVG.  

#

Copyright (c) 2016-2020 by ArkPhone, LLC.

All trademarks are the property of their respective holders.
