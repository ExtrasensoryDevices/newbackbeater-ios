//
//  Sidebar.swift
//  Backbeater
//
//  Created by Alina on 2015-06-03.
//

import UIKit


protocol SidebarDelegate {
    func sensitivityDidChange(value:Int)
    func 
}

@IBDesignable
class Sidebar: NibDesignable {

    @IBOutlet weak var sensitivitySlider: SensitivitySlider!
    @IBOutlet weak var windowSegmentedControl: SegmentedControl!
    @IBOutlet weak var beatSegmentedControl: SegmentedControl!
    
    
    @IBOutlet weak var bangButton: UIButton!
    @IBOutlet weak var dingButton: UIButton!
    @IBOutlet weak var clapButton: UIButton!
    
    override func setup() {
        self.backgroundColor = ColorPalette.Pink.color()
    }
    
    
    @IBAction func didTapSoundButton(sender: UIButton) {
    }
    

    @IBAction func sensitivityValueChanged(sender: SensitivitySlider) {
    }
    
    @IBAction func windowValueChanged(sender: SegmentedControl) {
    }
    
    @IBAction func beatValueChanged(sender: AnyObject) {
    }
    
    @IBAction func didTapHelp(sender: AnyObject) {
    }
    
}
