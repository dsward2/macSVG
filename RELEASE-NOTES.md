# macSVG Release Notes

macSVG v1.1 - October 24, 2017

Several improvements and bug fixes were made for using the "transform" attribute for translate, scale, rotate, skewX and skewY operations.  The interactive controls in the web view now work better with nested transformations using &lt;g&gt; group elements.  Although a transform attribute can contain multiple operations, the controls may work better if the transform operations are divided into nested groups.

A new center of rotation control handle is now displayed in the web view while editing a rotate transform.  The new handle can be dragged in the web view to change the center of rotation point, and the other handles can be dragged to rotate around the center of rotation point.

A new item is added to the Plug-Ins menu called "Path Text Generator".  The user can enter a line of text and select a font, then click a button to generate a &lt;path&gt; element to draw the shape of the text.  User settings are available for font size and origin offset.  Two options are available for generating the path: 1) the whole string converted to a single path element, or 2) each character in the string is converted as a separate path element.


<hr>

macSVG - [http://macsvg.org](http://macsvg.org)

macSVG project - [https://github.com/dsward2/macsvg](https://github.com/dsward2/macsvg)

Copyright (c) 2016-2017 by ArkPhone, LLC.

All trademarks are the property of their respective holders.

