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
    
    
    @IBOutlet weak var sideStickButton: UIButton!
    @IBOutlet weak var stickButton: UIButton!
    @IBOutlet weak var metronomeButton: UIButton!
    @IBOutlet weak var surpriseButton: UIButton!
    var soundButtonCollection: [UIButton]!
    
    
    @IBOutlet weak var helpButton: UIButton!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    let settings = Settings.sharedInstance()
    
    
    override func setup() {
        self.backgroundColor = ColorPalette.Pink.color()
        soundButtonCollection = [sideStickButton, stickButton, metronomeButton, surpriseButton]
        
        soundButtonCollection.first?.selected = true
        
        windowSegmentedControl.items = toStringArray(Settings.sharedInstance().strikesWindowValues)
        beatSegmentedControl.items = toStringArray(Settings.sharedInstance().timeSignatureValues)
        
        displayValuesFromSettings()
        
        setupVersionLabel()
    }
    
    func setupVersionLabel() {
        if let versionNumber = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String {
            if let buldNumber = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as? String {
                versionLabel.text = String(format:"Version %@ (%@)", versionNumber, buldNumber)
            }
        }
    }
    
    
    func displayValuesFromSettings()
    {
        let settings = Settings.sharedInstance()
        sensitivitySlider.value = settings.sensitivity
        
        let selectedIndex = settings.metronomeSoundSelectedIndex
        for (index, button) in enumerate(soundButtonCollection) {
            button.selected = index == selectedIndex
        }
        
        windowSegmentedControl.selectedIndex = settings.strikesWindowSelectedIndex
        beatSegmentedControl.selectedIndex = settings.timeSignatureSelectedIndex
        
    }
    
    
    
    @IBAction func didTapSoundButton(sender: UIButton) {
        for (index, button) in enumerate(soundButtonCollection) {
            if sender == button {
                if sender.selected {
                    return
                } else {
                    // set new sound
                    settings.metronomeSoundSelectedIndex = index
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
        settings.sensitivity = sender.value
    }
    
    @IBAction func windowValueChanged(sender: SegmentedControl) {
        settings.strikesWindowSelectedIndex = sender.selectedIndex
    }
    
    @IBAction func beatValueChanged(sender: SegmentedControl) {
        settings.timeSignatureSelectedIndex = sender.selectedIndex
    }
    
    @IBAction func didTapHelp(sender: AnyObject) {
        delegate?.didTapHelp()
    }
    
    
    // Helper methods
    func toStringArray(intArray: NSArray) -> [String] {
        var strArray = [String]()
        for i in intArray {
            strArray.append(String(i.integerValue))
        }
        return strArray
    }
}
