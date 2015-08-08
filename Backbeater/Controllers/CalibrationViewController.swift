//
//  CalibrationViewController.swift
//  Backbeater
//
//  Created by Alina on 2015-07-09.
//

import UIKit

class CalibrationViewController: UIViewController, UITextFieldDelegate, SoundProcessorTestDelegate {

    @IBOutlet weak var startTh: UITextField!
    @IBOutlet weak var stopTh: UITextField!
    @IBOutlet weak var timeout: UITextField!
    @IBOutlet weak var log: UITextView!
    
    
    @IBOutlet weak var clearButton: UIButton!
    
    
    var keyboardToolbar:UIToolbar!
    
    let soundProcessor = SoundProcessor.sharedInstance()
    
    let timeoutCoeff:UInt64 = 1000000
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = ColorPalette.Black.color()
        startTh.backgroundColor = ColorPalette.Black.color()
        stopTh.backgroundColor = ColorPalette.Black.color()
        timeout.backgroundColor = ColorPalette.Black.color()
        clearButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        clearButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Selected)
        
        setupKeyboardAceessory()
        
        soundProcessor.testDelegate = self
        
        startTh.text = "\(soundProcessor.testStartThreshold)"
        stopTh.text = "\(soundProcessor.testEndThreshold)"
        
        let timeoutValue = soundProcessor.testTimeout/timeoutCoeff
        timeout.text = "\(timeoutValue)"
        
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
        soundProcessor.testDelegate = nil;
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let value = (textField.text as NSString).floatValue
        if textField == startTh {
            soundProcessor.testStartThreshold = value
        } else if textField == stopTh {
            soundProcessor.testEndThreshold = value
        } else if textField == timeout {
            soundProcessor.testTimeout = UInt64(value) * timeoutCoeff
        }
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
    
    func soundProcessorDidDetectStrikeStart(startValue: Float32) {
        logText("Strike started: \(startValue)")
    }
    
    func soundProcessorDidDetectStrikeEnd(endValue: Float32) {
        logText("           ended: \(endValue)")
    }
    

    func soundProcessorDidDetectTimeoutEnd(maxValue: Float32) {
        logText("        maxValue: \(maxValue)")
    }
}
