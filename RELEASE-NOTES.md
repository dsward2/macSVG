# macSVG Release Notes

## macSVG v1.1.5 - February 1, 2019

MacSVG v1.1.5 provides a temporary fix for the application to work in macOS Mojave Dark Mode.  For now, the app will "opt-out" of Dark Mode, and render views as a Light Mode application.  Specifically, the NSRequiresAquaSystemAppearance is set to true in Info.plist to force Light Mode rendering.  The next release will adjust the views to provide a proper Dark Mode user interface.

## macSVG v1.1.4 - May 8, 2018

MacSVG v1.1.4 fixes a bug in the Element Info plugin.  The bug prevented the Element Info panel from displaying live updates as elements were moved, resized, etc.

## macSVG v1.1.3 - May 8, 2018

MacSVG v1.1.3 features several bug fixes, mostly for the <path>, <image> and <animateTransform> elements, and the user interface for those elements.

In the Image Element Editor, the image box labeled "Drag image or SVG into box" now works as described.

In previous releases, the Image and Text tools remained the active tool after clicking in the SVG web view.  That is changed in this release, those tools will switch to the Arrow tool after clicking in the web view, consistent with the behavior of other drawing tools like the Rect and Circle tools.

## macSVG v1.1.2 - November 26, 2017

MacSVG v1.1.2 introduces a new plug-in called Element Info.  This plug-in displays information about the currently selected element, and is especially helpful when drawing a new element or editing an existing one.  The ElementInfoEditor shows these attribute values, depending on the element: x, y, width, height, cx, cy, r, rx and ry.  The plug-in also show the current bounding box in the web view for the selected element, and the current DOM mouse page coordinates.

When the center-of-rotation handle is dragged to new coordinates, if the selected element contains an "animateTransform" element, the app will attempt to sync the new center-of-rotation coordinates to the animateTransform element.  This works best if the SVG animation is stopped or paused.

Added ToolTips to the XMLOutlineView view.  When the mouse hovers over the Element column in the outline view, the XML representation of the element will be displayed.

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

macSVG - [https://macsvg.org](https://macsvg.org)

macSVG project - [https://github.com/dsward2/macsvg](https://github.com/dsward2/macsvg)

Copyright (c) 2016-2018 by ArkPhone, LLC.

All trademarks are the property of their respective holders.

