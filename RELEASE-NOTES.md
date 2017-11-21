# macSVG Release Notes

## macSVG v1.1.1 - November 20, 2017

MacSVG v1.1.1 features improvements to the SVG web view rulers, the XML outline view, and drag-and-drop functions.

The new web view rulers now display numerical values at the major marks.  The rulers will scale and translate to match the web view zoom factor and the scroll bar knobs.

The XML outline view was converted from cell-based to view-based, and the layout and fonts were adjusted slightly.

The XML outline view was improved for drag-and-drop operations, especially when multiple items are selected.  The user interface has a new rule for using the mouse to select a single item within an existing selection; in that situation, use a double-click to select the single item.

This release changes the format of the downloadable application file to use simple Zip compression only.  Previously, a DMG disk image was contained within the Zip file.  To install the application, expand the Zip file, then drag macSVG.app to the /Applications folder.  

## macSVG v1.1 - October 24, 2017

Several improvements and bug fixes were made for using the "transform" attribute for translate, scale, rotate, skewX and skewY operations.  The interactive controls in the web view now work better with nested transformations using &lt;g&gt; group elements.  Although a transform attribute can contain multiple operations, the controls may work better if the transform operations are divided into nested groups.

A new center of rotation control handle is now displayed in the web view while editing a rotate transform.  The new handle can be dragged in the web view to change the center of rotation point, and the other handles can be dragged to rotate around the center of rotation point.

A new item is added to the Plug-Ins menu called "Path Text Generator".  The user can enter a line of text and select a font, then click a button to generate a &lt;path&gt; element to draw the shape of the text.  User settings are available for font size and origin offset.  Two options are available for generating the path: 1) the whole string converted to a single path element, or 2) each character in the string is converted as a separate path element.


<hr>

macSVG - [http://macsvg.org](http://macsvg.org)

macSVG project - [https://github.com/dsward2/macsvg](https://github.com/dsward2/macsvg)

Copyright (c) 2016-2017 by ArkPhone, LLC.

All trademarks are the property of their respective holders.

