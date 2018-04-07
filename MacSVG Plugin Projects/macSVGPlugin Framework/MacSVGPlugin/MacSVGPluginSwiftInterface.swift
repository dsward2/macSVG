//
//  MacSVGPluginSwiftInterface.swift
//  MacSVGPlugin
//
//  Created by Douglas Ward on 3/19/17.
//  Copyright © 2017 ArkPhone LLC. All rights reserved.
//

import Cocoa

public class MacSVGPluginSwiftInterface: NSObject {

    @IBOutlet weak var macSVGPlugin: MacSVGPlugin!
    
    public var testProperty = "MacSVGPluginSwiftInterface testProperty"
    
    override init() {
        super.init()
    }
}
