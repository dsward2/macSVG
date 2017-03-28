//
//  MacSVGPluginSwiftInterface.swift
//  MacSVGPlugin
//
//  Created by Douglas Ward on 3/19/17.
//  Copyright © 2017 ArkPhone LLC. All rights reserved.
//

import Cocoa

@objc public class MacSVGPluginSwiftInterface: NSObject {

    @IBOutlet weak var macSVGPlugin: MacSVGPlugin!
    
    @objc public var testProperty = "MacSVGPluginSwiftInterface testProperty"
    
    override init() {
        super.init()
    }
}
