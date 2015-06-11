//
//  DisplayViewController.swift
//  Backbeater
//
//  Created by Alina on 2015-06-10.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

import UIKit

class DisplayViewController: UIViewController {

    @IBOutlet weak var logView: UITextView!
    
    let settings = BBSetting.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logView.text = ""
        
        view.backgroundColor = ColorPalette.Black.color()

        registerForNotifications()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func registerForNotifications() {
        settings.addObserver(self, forKeyPath: "sensitivity", options: .allZeros, context: nil)
        settings.addObserver(self, forKeyPath: "bpm", options: .allZeros, context: nil)
        
//        settings.addObserver(self.rioUnit, forKeyPath:"mute", options: .allZeros, context: nil)
        
        settings.addObserver(self, forKeyPath: "mute", options: .allZeros, context: nil)
        settings.addObserver(self, forKeyPath: "sensorIn", options: .allZeros, context: nil)
        
        settings.addObserver(self, forKeyPath: "foundBPMf", options: .allZeros, context: nil)
        settings.addObserver(self, forKeyPath: "sensitivityFlash", options: .allZeros, context: nil)
        
//        settings.addObserver(self.rioUnitDelegate, forKeyPath:"bpm", options: .allZeros, context: nil)
//        settings.addObserver(self.rioUnitDelegate, forKeyPath:"sensitivity", options: .allZeros, context: nil)
//        settings.addObserver(self.rioUnitDelegate, forKeyPath:"metSound", options: .allZeros, context: nil)
        
        settings.addObserver(self, forKeyPath: "strikesFilter", options: .allZeros, context: nil)
        
        settings.addObserver(self, forKeyPath: "timeSignature", options: .allZeros, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        let updateStr = "\(keyPath): \(object.valueForKey(keyPath))"
        logView.text = logView.text + "\n" + updateStr
        logView.scrollRangeToVisible(NSMakeRange(count(logView.text)-1, 1))
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
