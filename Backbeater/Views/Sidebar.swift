//
//  Sidebar.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-06-03.
//

import UIKit

protocol SidebarDelegate: class {
    func readyToRender(_ sidebar: Sidebar)
    
    func helpRequested()
    
    func sensitivityChanged(newValue:Int)
    func strikesWindowChanged(newIndex:Int)
    func timeSignatureChanged(newIndex:Int)
    func metronomeSoundChanged(newIndex:Int)
}


@IBDesignable
class Sidebar: NibDesignable {
    
    weak var delegate: SidebarDelegate? {
        didSet {
            if !initialized {
                delegate?.readyToRender(self)
            }
        }
    }

    @IBOutlet weak var sensitivitySlider: SensitivitySlider!
    @IBOutlet weak var sensitivityLabel: UILabel!
    @IBOutlet weak var windowSegmentedControl: SegmentedControl!
    @IBOutlet weak var beatSegmentedControl: SegmentedControl!
    
    
    @IBOutlet weak var sideStickButton: UIButton!
    @IBOutlet weak var stickButton: UIButton!
    @IBOutlet weak var metronomeButton: UIButton!
    @IBOutlet weak var surpriseButton: UIButton!
    private var soundButtonCollection: [UIButton]!
    
    
    @IBOutlet weak var helpButton: UIButton!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    private var initialized = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        self.backgroundColor = ColorPalette.pink.color
        soundButtonCollection = [sideStickButton, stickButton, metronomeButton, surpriseButton]
        
        soundButtonCollection.first?.isSelected = true
        
        versionLabel.text = "Version \(appVersion)"
        
        delegate?.readyToRender(self)
    }
    
    func setupOptions(strikesWindowValues:[Int], timeSignatureValues:[Int]) {
        
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        guard !initialized else {
            return
        }
        initialized = true
        windowSegmentedControl.items = strikesWindowValues.map { "\($0)" }
        beatSegmentedControl.items = timeSignatureValues.map { "\($0)" }
    }
    
    func displayValuesFromLastSession(sensitivity:       Int,
                                      metronomeSoundIdx: Int,
                                      strikesWindowIdx:  Int,
                                      timeSignatureIdx:  Int) {
        sensitivitySlider.value = sensitivity
        
        print("\(sensitivityLabel.font.pointSize)")
        sensitivityLabel.text = "\(sensitivity)"
        for (index, button) in soundButtonCollection.enumerated() {
            button.isSelected = (index == metronomeSoundIdx)
        }
        
        windowSegmentedControl.selectedIndex = strikesWindowIdx
        beatSegmentedControl.selectedIndex = timeSignatureIdx
    }
    

    
    @IBAction func didTapSoundButton(_ sender: UIButton) {
        guard !sender.isSelected else {
            // do nothing if already selected
            return
        }
        // selection changed
        for (index, button) in soundButtonCollection.enumerated() {
            if sender == button {
                delegate?.metronomeSoundChanged(newIndex: index)
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
        
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        versionLabel.font = Font.FuturaDemi.get(10)
        sensitivityLabel.font = Font.FuturaDemi.get(24)
    }
    
    @IBAction func sensitivityEditingChanged(_ sender: SensitivitySlider) {
        sensitivityLabel.text = "\(sender.value)"
    }
    
    @IBAction func sensitivityValueChanged(_ sender: SensitivitySlider) {
        delegate?.sensitivityChanged(newValue: sender.value)
        sensitivityLabel.text = "\(sender.value)"
    }
    
    @IBAction func windowValueChanged(_ sender: SegmentedControl) {
        delegate?.strikesWindowChanged(newIndex: sender.selectedIndex)
    }
    
    @IBAction func beatValueChanged(_ sender: SegmentedControl) {
        delegate?.timeSignatureChanged(newIndex: sender.selectedIndex)
    }
    
    @IBAction func didTapHelp(_ sender: AnyObject) {
        delegate?.helpRequested()
    }
    
    
    @IBAction func didTapHelpWindow(_ sender: Any) {
        let controller = UIViewController()
        controller.preferredContentSize = CGSize(width: 288, height: 144)
        
        let label = UILabel(frame: CGRect(x: 20, y: 4, width: 288-32, height: 144-8))
        label.text = "This is how many beats are averaged to show your current tempo. \nA lower setting is more accurate, a higher setting is more forgiving."
        label.numberOfLines = 0
        
        controller.view.addSubview(label)
        
        showPopup(controller, sourceView: sender as! UIView)
    }
    
    
    @IBAction func didTapHelpBeat(_ sender: Any) {
        let controller = UIViewController()
        controller.preferredContentSize = CGSize(width: 288, height: 240)
        
        let label = UILabel(frame: CGRect(x: 20, y: 4, width: 288-32, height: 240-8))
        label.text = "This setting compensates for songs with unusual rhythms.\nA default setting of 1 is best for most music, like rock songs.\nExample: If your song is 90 BPM and the app says you're playing 45 BPM, you can switch this setting to 2 and the tempo reading will correctly read 90 BPM."
        label.numberOfLines = 0
        
        controller.view.addSubview(label)
        
        showPopup(controller, sourceView: sender as! UIView)
    }
    
    private func showPopup(_ controller: UIViewController, sourceView: UIView) {
        let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: controller)
        presentationController.sourceView = sourceView
        presentationController.sourceRect = sourceView.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        if let vc = self.parentViewController {
            vc.present(controller, animated: true)
        }
    }
}
