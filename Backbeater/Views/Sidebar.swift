//
//  Sidebar.swift
//  Backbeater
//
//  Created by Alina Khgolcheva on 2015-06-03.
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
    private var soundButtonCollection: [UIButton]!
    
    
    @IBOutlet weak var helpButton: UIButton!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    private let settings = Settings.sharedInstance()
    
    
    override func setup() {
        super.setup()
        self.backgroundColor = ColorPalette.pink.color()
        soundButtonCollection = [sideStickButton, stickButton, metronomeButton, surpriseButton]
        
        soundButtonCollection.first?.isSelected = true
        
        windowSegmentedControl.items = toStringArray(Settings.sharedInstance().strikesWindowValues as NSArray)
        beatSegmentedControl.items = toStringArray(Settings.sharedInstance().timeSignatureValues as NSArray)
        
        displayValuesFromSettings()
        
        setupVersionLabel()
    }
    
    private func setupVersionLabel() {
        if let versionNumber = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            if let buldNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as? String {
                versionLabel.text = String(format:"Version %@ (%@)", versionNumber, buldNumber)
            }
        }
    }
    
    
    private func displayValuesFromSettings()
    {
        let settings = Settings.sharedInstance()
        sensitivitySlider.value = (settings?.sensitivity)!
        
        let selectedIndex = settings?.metronomeSoundSelectedIndex
        for (index, button) in soundButtonCollection.enumerated() {
            button.isSelected = index == selectedIndex
        }
        
        windowSegmentedControl.selectedIndex = (settings?.strikesWindowSelectedIndex)!
        beatSegmentedControl.selectedIndex = (settings?.timeSignatureSelectedIndex)!
        
    }
    
    
    
    @IBAction func didTapSoundButton(_ sender: UIButton) {
        for (index, button) in soundButtonCollection.enumerated() {
            if sender == button {
                if sender.isSelected {
                    return
                } else {
                    // set new sound
                    settings?.metronomeSoundSelectedIndex = index
                 }
                sender.isSelected = !sender.isSelected
            } else {
                button.isSelected = false
            }
        }
        
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        versionLabel.font = Font.FuturaDemi.get(10)
    }
    
    
    @IBAction func sensitivityValueChanged(_ sender: SensitivitySlider) {
        settings?.sensitivity = sender.value
    }
    
    @IBAction func windowValueChanged(_ sender: SegmentedControl) {
        settings?.strikesWindowSelectedIndex = sender.selectedIndex
    }
    
    @IBAction func beatValueChanged(_ sender: SegmentedControl) {
        settings?.timeSignatureSelectedIndex = sender.selectedIndex
    }
    
    @IBAction func didTapHelp(_ sender: AnyObject) {
        delegate?.didTapHelp()
    }
    
    
    // Helper methods
    func toStringArray(_ intArray: NSArray) -> [String] {
        var strArray = [String]()
        for value in intArray {
            strArray.append("\(value)")
        }
        return strArray
    }
}
