//
//  CalibrationViewController.swift
//  Backbeater
//
//  Created by Alina on 2015-07-09.
//

import UIKit

class CalibrationViewController: UIViewController, UITextFieldDelegate, SoundProcessorDelegate {

    @IBOutlet weak var startTh: UITextField!
    @IBOutlet weak var stopTh: UITextField!
    @IBOutlet weak var timeout: UITextField!
    @IBOutlet weak var log: UITextView!
    
    
    @IBOutlet weak var l1: UILabel!
    @IBOutlet weak var l2: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    
    var keyboardToolbar:UIToolbar!
    
    let soundProcessor = SoundProcessor.sharedInstance()
    
    let timeoutCoeff:UInt64 = 1000000
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = ColorPalette.Black.color()
        startTh.backgroundColor = ColorPalette.Black.color()
        stopTh.backgroundColor = ColorPalette.Black.color()
        timeout.backgroundColor = ColorPalette.Black.color()
        startButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        startButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Selected)
        clearButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        clearButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Selected)
        
        setupKeyboardAceessory()
        
        soundProcessor.delegate = self
        
//        startTh.text = "\(soundProcessor.startThreshold)"
//        stopTh.text = "\(soundProcessor.endThreshold)"
//        
//        let timeoutValue = soundProcessor.timeout/timeoutCoeff
        
        
        
//        timeout.text = "\(timeoutValue)"
        
    }
    
    
    
    func setupKeyboardAceessory() {
        // create toolbar with "DONE" button
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        var submitButton = UIBarButtonItem(title: "DONE", style: UIBarButtonItemStyle.Plain, target: self, action: "didTapDoneButton")
        
        let frame = CGRectMake(0, 0, 320, 50)
        
        keyboardToolbar = UIToolbar(frame: frame)
        keyboardToolbar.barTintColor = ColorPalette.KeyboardBg.color()
        keyboardToolbar.items = [flexibleSpace, submitButton]
        
        // create bottom line
        let borderView = UIView(frame: CGRectMake(0, 49, 320, 1))
        borderView.backgroundColor = ColorPalette.KeyboardBorder.color()
        borderView.userInteractionEnabled = false
        borderView.setTranslatesAutoresizingMaskIntoConstraints(false)
        keyboardToolbar.addSubview(borderView)
        keyboardToolbar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[borderView]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: ["borderView": borderView]))
        keyboardToolbar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[borderView(==1)]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: ["borderView": borderView]))
        keyboardToolbar.layoutIfNeeded()
        
        startTh.inputAccessoryView = keyboardToolbar
        stopTh.inputAccessoryView = keyboardToolbar
        timeout.inputAccessoryView = keyboardToolbar
        log.inputAccessoryView = keyboardToolbar
    }
    
    
    func didTapDoneButton() {
        startTh.resignFirstResponder()
        stopTh.resignFirstResponder()
        timeout.resignFirstResponder()
        log.resignFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        var error:NSError?
        soundProcessor.stop(&error)
        if let err = error {
            println(err)
        }
    }
    
    @IBAction func didTapStartButton(sender: UIButton) {
        var error:NSError? = nil
        if sender.selected {
            sender.selected = false
            SoundProcessor.sharedInstance().stop(&error)
        } else {
            sender.selected = true
            SoundProcessor.sharedInstance().start(&error)
        }
        if let err = error {
            println(err)
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
//        let value = (textField.text as NSString).floatValue
//        if textField == startTh {
//            soundProcessor.startThreshold = value
//        } else if textField == stopTh {
//            soundProcessor.endThreshold = value
//        } else if textField == timeout {
//            soundProcessor.timeout = UInt64(value) * timeoutCoeff
//        }
    }
    
    @IBAction func didTapClear(sender: AnyObject) {
        log.text = ""
    }
    
    @IBAction func didTapClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func logText(str:String) {
        self.log.text = self.log.text + "\n\(str)"
        
//        log.scrollRangeToVisible(NSMakeRange(count(log.text)-1, 1))
    }
    
    
    //MARK: - SoundProcessorDelegate
    
    func soundProcessorDidDetectSensorIn(sensorIn: Bool) {
        logText(sensorIn ? "---------SensorIn: true" : "SensorIn: false")
    }
    
    func soundProcessorDidDetectStrikeStart(params: [NSObject : AnyObject]!) {
        if let unwrapped = params["energyLevel"] as? NSNumber {
            logText("Strike started: \(unwrapped)")
        } else {
            logText("Strike started: \(params)")
        }
    }
    
    func soundProcessorDidDetectStrikeEnd(params: [NSObject : AnyObject]!) {
        if let unwrapped = params["energyLevel"] as? NSNumber {
            logText("           ended: \(unwrapped)")
            let time = params["time"] as? NSNumber
            let timeElapsedNs = params["timeElapsedNs"] as? NSNumber
            let timeElapsedInSec = params["timeElapsedInSec"] as? NSNumber
            println("timeElapsedNs: \(timeElapsedNs!), timeElapsedInSec: \(timeElapsedInSec!)")
        } else {
            logText("           ended: \(params)")
        }
    }
    
    func soundProcessorProcessedFrame(params: [NSObject : AnyObject]!) {
        let maxPerFrame = params["maxPerFrame"] as? NSNumber
        let maxTotal = params["maxTotal"] as? NSNumber
        logText("maxPerFrame: \(maxPerFrame!), maxTotal: \(maxTotal!)")
    }
    
    func soundProcessorDidDetectFirstStrike() {
        //
    }
    
    func soundProcessorDidFindBPM(bpm: Float64) {
        //
    }
    
}
