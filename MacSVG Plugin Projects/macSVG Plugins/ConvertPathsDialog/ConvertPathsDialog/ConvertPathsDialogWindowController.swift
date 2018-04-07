//
//  ConvertPathsDialogWindowController.swift
//  ConvertPathsDialog
//
//  Created by Douglas Ward on 3/19/17.
//  Copyright © 2017 ArkPhone LLC. All rights reserved.
//

import Cocoa

class ConvertPathsDialogWindowController: NSWindowController {

    @IBOutlet weak var convertPathsDialog: ConvertPathsDialog?
    @IBOutlet weak var convertPopUpButton: NSPopUpButton?
    @IBOutlet weak var applyButton: NSButton?
    @IBOutlet weak var cancelButton: NSButton?

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    override func awakeFromNib()
    {
        self.configureTextFields();
    }


    @IBAction func convertPopUpButtonAction(sender: AnyObject)
    {
        self.configureTextFields();
    }

    func configureTextFields()
    {
    }

    @IBAction func cancelButtonAction(sender: AnyObject)
    {
        NSApplication.shared.stopModal(withCode:NSApplication.ModalResponse.cancel)
        
        self.window?.close()
    }

    @IBAction func applyButtonAction(sender: AnyObject)
    {
        NSApplication.shared.stopModal(withCode:NSApplication.ModalResponse.cancel)
        
        self.window?.close()

        convertPathsDialog?.macSVGPluginCallbacks.pushUndoRedoDocumentChanges()

        let convertName = convertPopUpButton?.titleOfSelectedItem
        
        if (convertName == "Convert to Absolute Coordinates")
        {
            convertPathsDialog?.convertSelectedPathsToAbsoluteCoordinates()
        }
    }
    

}
