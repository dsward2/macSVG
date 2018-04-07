//
//  ConvertPathsDialog.swift
//  ConvertPathsDialog
//
//  Created by Douglas Ward on 3/19/17.
//  Copyright © 2017 ArkPhone LLC. All rights reserved.
//

import Cocoa
import MacSVGPlugin

class ConvertPathsDialog: MacSVGPlugin {

    @IBOutlet weak var convertPathsDialogWindowController: ConvertPathsDialogWindowController?

    /// Plugin menu title override
    ///
    /// - Returns: The Plugins menu title
    override func pluginMenuTitle() -> String! {
        return "Convert Selected Paths"    // override for menu plugins
    }
 
    
    /// Menu plugin flag override
    ///
    /// - Returns: true if this plugin is a menu plugin, false if a editor panel plugin
    override func isMenuPlugIn() -> Bool
    {
        return true    // override for menu plugins
    }
    
    /// Begin menu plugin override
    ///
    /// - Returns: true
    override func beginMenuPlugIn() -> Bool
    {
        // for menu plug-ins
        if convertPathsDialogWindowController?.window == nil
        {
            //let pluginNameString = self.className
            let pluginNameString = String(describing: type(of: self))
            var topLevelObjects: NSArray?
            
            let bundlePath = Bundle.main.path(forResource:pluginNameString, ofType:"plugin")
            
            let pluginBundle = Bundle(path:bundlePath!)
            
            let nibName = NSNib.Name(rawValue: pluginNameString)
            
            pluginBundle!.loadNibNamed(nibName, owner: self, topLevelObjects: &topLevelObjects)
        }
        
        NSApplication.shared.runModal(for:(convertPathsDialogWindowController?.window!)!)

        return true;
    }


    func convertSelectedPathsToAbsoluteCoordinates() {
        let holdSelectedPathElement: XMLElement? = macSVGPluginCallbacks.svgPathEditorSelectedPathElement() as? XMLElement

        let selectedElementsArray = macSVGPluginCallbacks.selectedElementsArray
        
        for aSelectedElement in selectedElementsArray!
        {
            let dictionaryElement: NSDictionary = aSelectedElement as! NSDictionary
        
            let aSelectedXMLElement: XMLElement = dictionaryElement.object(forKey:"xmlElement") as! XMLElement
            
            let elementName = aSelectedXMLElement.name
            
            if elementName == "path"
            {
                convertToAbsoluteCoordinates(pathElement: aSelectedXMLElement)
            }
        }

        if holdSelectedPathElement != nil
        {
            macSVGPluginCallbacks.svgPathEditorSetSelectedPathElement(holdSelectedPathElement)
        }
    }


    func convertToAbsoluteCoordinates(pathElement: XMLElement)
    {
        let convertedSegmentsArray: NSMutableArray = macSVGPluginCallbacks.convert(toAbsoluteCoordinates: pathElement)

        macSVGPluginCallbacks.svgPathEditorSetSelectedPathElement(pathElement)
        
        macSVGPluginCallbacks.pathSegmentsArray = convertedSegmentsArray

        macSVGPluginCallbacks.updateSelectedPath(inDOM:
        false);
    }

}
