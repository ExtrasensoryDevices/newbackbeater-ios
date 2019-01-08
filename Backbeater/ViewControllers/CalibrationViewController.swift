//
//  CalibrationViewController.swift
//  Backbeater
//
//  Created by Alina Khgolcheva on 2015-07-09.
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = ColorPalette.black.color()
        startTh.backgroundColor = ColorPalette.black.color()
        stopTh.backgroundColor = ColorPalette.black.color()
        timeout.backgroundColor = ColorPalette.black.color()
        clearButton.setTitleColor(UIColor.blue, for: UIControl.State())
        clearButton.setTitleColor(UIColor.blue, for: UIControl.State.selected)
        
        setupKeyboardAceessory()
        
        soundProcessor?.testDelegate = self
        if let soundProcessor = soundProcessor {
            startTh.text = "\(soundProcessor.testStartThreshold)"
            stopTh.text = "\(soundProcessor.testEndThreshold)"
        
            let timeoutValue = soundProcessor.testTimeout/timeoutCoeff
            timeout.text = "\(timeoutValue)"
        }
        
    }
    
    
    
    func setupKeyboardAceessory() {
        // create toolbar with "DONE" button
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let submitButton = UIBarButtonItem(title: "DONE", style: UIBarButtonItem.Style.plain, target: self, action: #selector(CalibrationViewController.didTapDoneButton))
        
        let frame = CGRect(x: 0, y: 0, width: 320, height: 50)
        
        keyboardToolbar = UIToolbar(frame: frame)
        keyboardToolbar.barTintColor = ColorPalette.keyboardBg.color()
        keyboardToolbar.items = [flexibleSpace, submitButton]
        
        // create bottom line
        let borderView = UIView(frame: CGRect(x: 0, y: 49, width: 320, height: 1))
        borderView.backgroundColor = ColorPalette.keyboardBorder.color()
        borderView.isUserInteractionEnabled = false
        borderView.translatesAutoresizingMaskIntoConstraints = false
        keyboardToolbar.addSubview(borderView)
        keyboardToolbar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[borderView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["borderView": borderView]))
        keyboardToolbar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[borderView(==1)]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["borderView": borderView]))
        keyboardToolbar.layoutIfNeeded()
        
        startTh.inputAccessoryView = keyboardToolbar
        stopTh.inputAccessoryView = keyboardToolbar
        timeout.inputAccessoryView = keyboardToolbar
        log.inputAccessoryView = keyboardToolbar
    }
    
    
    @objc func didTapDoneButton() {
        startTh.resignFirstResponder()
        stopTh.resignFirstResponder()
        timeout.resignFirstResponder()
        log.resignFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        soundProcessor?.testDelegate = nil;
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if  let value = Float(textField.text ?? "0") {
            if textField == startTh {
                soundProcessor?.testStartThreshold = value
            } else if textField == stopTh {
                soundProcessor?.testEndThreshold = value
            } else if textField == timeout {
                soundProcessor?.testTimeout = UInt64(value) * timeoutCoeff
            }
        }
    }
    
    @IBAction func didTapClear(_ sender: AnyObject) {
        log.text = ""
    }
    
    @IBAction func didTapClose(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func logText(_ str:String) {
        self.log.text = self.log.text + "\n\(str)"
        
//        log.scrollRangeToVisible(NSMakeRange(count(log.text)-1, 1))
    }
    
    
    //MARK: - SoundProcessorDelegate
    
    func soundProcessorDidDetectSensor(in sensorIn: Bool) {
        logText(sensorIn ? "---------SensorIn: true" : "SensorIn: false")
    }
    
    func soundProcessorDidDetectStrikeStart(_ startValue: Float32) {
        logText("Strike started: \(startValue)")
    }
    
    func soundProcessorDidDetectStrikeEnd(_ endValue: Float32) {
        logText("           ended: \(endValue)")
    }
    

    func soundProcessorDidDetectTimeoutEnd(_ maxValue: Float32) {
        logText("        maxValue: \(maxValue)")
    }
}
