#!/bin/bash

# For embedding custom WebKit frameworks in a Mac app
# usage: install_name_tool -id  [name] file
# usage: install_name_tool -change [oldPath] [oldPath] file
# to verify changes, use: otool -L [pathToExecutable]

# This is not used by macSVG as of Summer 2016, but is retained for future reference

echo "updating WebKit..."

install_name_tool -id \
  @executable_path/../Frameworks/WebKit.framework/Versions/A/WebKit \
  ./WebKit/WebKitBuild/Release/WebKit.framework/Versions/A/WebKit

install_name_tool -change \
  /System/Library/Frameworks/JavaScriptCore.framework/Versions/A/JavaScriptCore \
  @loader_path/../../../JavaScriptCore.framework/Versions/A/JavaScriptCore \
  ./WebKit/WebKitBuild/Release/WebKit.framework/Versions/A/WebKit

install_name_tool -change \
  /System/Library/Frameworks/WebKit.framework/Versions/A/Frameworks/WebCore.framework/Versions/A/WebCore \
  @loader_path/../../../WebCore.framework/Versions/A/WebCore \
  ./WebKit/WebKitBuild/Release/WebKit.framework/Versions/A/WebKit


echo "updating WebCore..."

install_name_tool -id \
  @executable_path/../Frameworks/WebCore.framework/Versions/A/WebCore \
  ./WebKit/WebKitBuild/Release/WebCore.framework/Versions/A/WebCore

install_name_tool -change \
  /System/Library/Frameworks/JavaScriptCore.framework/Versions/A/JavaScriptCore \
  @loader_path/../../../JavaScriptCore.framework/Versions/A/JavaScriptCore \
  ./WebKit/WebKitBuild/Release/WebCore.framework/Versions/A/WebCore


echo "updating JavaScriptCore..."
install_name_tool -id \
  @executable_path/../Frameworks/JavaScriptCore.framework/Versions/A/JavaScriptCore \
  ./WebKit/WebKitBuild/Release/JavaScriptCore.framework/Versions/A/JavaScriptCore
