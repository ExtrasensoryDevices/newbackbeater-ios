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
    
    
    @IBOutlet weak var helpButton: UIButton!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    let settings = BBSettingsWrapper.sharedInstance()
    
    let strikes = [2, 4, 8, 16] // WINDOW
    let timeSignature = [1, 2, 3, 4] // BEAT
    let sounds = ["stick", "beep", "clap"]
    
    override func setup() {
        self.backgroundColor = ColorPalette.Pink.color()
        soundButtonCollection = [stickButton, dingButton, bangButton]
        
        // TODO: save user settings between sessions
        soundButtonCollection.first?.selected = true
        
        windowSegmentedControl.items = toStringArray(strikes)
        beatSegmentedControl.items = toStringArray(timeSignature)
        
        setupVersionLabel()
    }
    
    func setupVersionLabel() {
        if let versionNumber = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String {
            if let buldNumber = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as? String {
                versionLabel.text = String(format:"Version %@ (%@)", versionNumber, buldNumber)
            }
        }
    }
    
    @IBAction func didTapSoundButton(sender: UIButton) {
        for (index, button) in enumerate(soundButtonCollection) {
            if sender == button {
                if sender.selected {
                    return
                } else {
                    // set new sound
                    settings.metSound = index
                 }
                sender.selected = !sender.selected
            } else {
                button.selected = false
            }
        }
        
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        versionLabel.font = Font.FuturaDemi.get(10)
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
