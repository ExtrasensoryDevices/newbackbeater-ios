//
//  Sidebar.swift
//  Backbeater
//
//  Created by Alina on 2015-06-03.
//

import UIKit

protocol SidebarDelegate {
    func didTapHelp()
}


@IBDesignable
class Sidebar: NibDesignable {
    
    var delegate: SidebarDelegate?

    @IBOutlet weak var sensitivitySlider: SensitivitySlider!
    @IBOutlet weak var windowSegmentedControl: SegmentedControl!
    @IBOutlet weak var beatSegmentedControl: SegmentedControl!
    
    
    @IBOutlet weak var stickButton: UIButton!
    @IBOutlet weak var dingButton: UIButton!
    @IBOutlet weak var bangButton: UIButton!
    var soundButtonCollection: [UIButton]!
    
    
    
    
    let settings = BBSetting.sharedInstance()
    
    let strikes = [2, 4, 8, 16] // WINDOW
    let timeSignature = [1, 2, 3, 4] // BEAT
    let sounds = ["stick", "beep", "clap"]
    
    override func setup() {
        self.backgroundColor = ColorPalette.Pink.color()
        soundButtonCollection = [stickButton, dingButton, bangButton]
        
        windowSegmentedControl.items = toStringArray(strikes)
        beatSegmentedControl.items = toStringArray(timeSignature)
    }
    
    
    @IBAction func didTapSoundButton(sender: UIButton) {
        for (index, button) in enumerate(soundButtonCollection) {
            if sender == button {
                if sender.selected {
                    // mute
                    settings.mute = true
                } else {
                    // set new sound
                    settings.metSound = index
                    settings.mute = false
                }
                sender.selected = !sender.selected
            } else {
                button.selected = false
            }
        }
        
    }
    

    @IBAction func sensitivityValueChanged(sender: SensitivitySlider) {
        settings.sensitivity = Float(sender.value) / 100
    }
    
    @IBAction func windowValueChanged(sender: SegmentedControl) {
        settings.strikesFilter = strikes[sender.selectedIndex]
    }
    
    @IBAction func beatValueChanged(sender: SegmentedControl) {
        settings.timeSignature = timeSignature[sender.selectedIndex]
    }
    
    @IBAction func didTapHelp(sender: AnyObject) {
        delegate?.didTapHelp()
    }
    
    
    // Helper methods
    func toStringArray(intArray: [Int]) -> [String] {
        var strArray = [String]()
        for i in intArray {
            strArray.append(String(i))
        }
        return strArray
    }
}
