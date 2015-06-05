//
//  Sidebar.swift
//  Backbeater
//
//  Created by Alina on 2015-06-03.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

import UIKit

@IBDesignable
class Sidebar: NibDesignable {

    @IBOutlet weak var sensitivitySlider: SensitivitySlider!
    
    
    override func setup() {
        self.backgroundColor = ColorPalette.Pink.color()
    }

    @IBAction func sensitivityValueChanged(sender: SensitivitySlider) {
    }
    
    
    
}
