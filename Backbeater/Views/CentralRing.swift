//
//  CentralRing.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-07-16.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

import UIKit


protocol CentralRingDelegate: class {
    func centralRingFoundTapBPM(bpm:Float64)
}


class CentralRing: NibDesignable {
    
    weak var delegate: CentralRingDelegate?

    @IBOutlet weak var drumImage: UIImageView!
    @IBOutlet weak var ringView: UIView!
    @IBOutlet weak var crtLabel: UILabel!
    
    var cptSublayer:CAShapeLayer!
    var bpmSublayer:CAShapeLayer!
    var borderSublayer:CAShapeLayer!
    
    @IBOutlet weak var ringTopConstraint: NSLayoutConstraint!
    
    var timeSignature:Int!
    
    var cptAnimation:CABasicAnimation!
    var bpmAnimation:CABasicAnimation!
    var pulseAnimation:CABasicAnimation!
    let PULSE_DURATION = floor(60.0 / Double(MAX_TEMPO) * 10) / 10
    
    var metronomeTempo:Int = 0
    
    var metronomeIsOn:Bool {
        return metronomeTempo >= MIN_TEMPO && metronomeTempo <= MAX_TEMPO
    }
    
    override func setup() {
        super.setup()
        self.backgroundColor = UIColor.clearColor()
        self.nibView.backgroundColor = UIColor.clearColor()
        self.ringView.backgroundColor = UIColor.clearColor()
        ringView.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.allZeros, context: nil)
        
        
        crtLabel.text = ""
        
        resetSublayers()
        
        timeSignature = Settings.sharedInstance().timeSignature
        metronomeTempo = Settings.sharedInstance().metronomeTempo
        
        Settings.sharedInstance().addObserver(self, forKeyPath: "timeSignatureSelectedIndex", options: NSKeyValueObservingOptions.allZeros, context: nil)
        Settings.sharedInstance().addObserver(self, forKeyPath: "metronomeTempo", options: NSKeyValueObservingOptions.allZeros, context: nil)
        Settings.sharedInstance().addObserver(self, forKeyPath: "metronomeIsOn", options: NSKeyValueObservingOptions.allZeros, context: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name:UIApplicationWillEnterForegroundNotification, object: nil)
        
        initAnimations()
        
    }
    
    override func didMoveToWindow() {
        crtLabel.font = Font.FuturaBook.get(100) // TODO: add font for label, then uncomment 142)
    }
    
    deinit {
        ringView.removeObserver(self, forKeyPath: "bounds")
        Settings.sharedInstance().removeObserver(self, forKeyPath: "timeSignatureSelectedIndex")
        Settings.sharedInstance().removeObserver(self, forKeyPath: "metronomeTempo")
        Settings.sharedInstance().removeObserver(self, forKeyPath: "metronomeIsOn")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func applicationWillEnterForeground() {
        handleMetronomeState()
    }
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if object === ringView && keyPath == "bounds" {
            resetSublayers()
            handleMetronomeState()
        } else if let settings = object as? Settings {
            if keyPath == "timeSignatureSelectedIndex" {
                timeSignature = settings.timeSignature
                if metronomeIsOn {
                    handleMetronomeState()
                }
            } else if keyPath == "metronomeTempo" {
                metronomeTempo = settings.metronomeTempo
                handleMetronomeState()
            } else if keyPath == "metronomeIsOn" {
                metronomeTempo = settings.metronomeIsOn ? settings.metronomeTempo : 0
                handleMetronomeState()
            }
        }
    }
    
    
    func resetSublayers() {
        resetBorderSublayer()
        resetCptSublayer()
        resetBpmSublayer()
        ringView.layer.masksToBounds = false
        ringView.clipsToBounds = false
    }
    
    
    func resetBorderSublayer() {
        
        borderSublayer?.removeFromSuperlayer()
        
        // border 
        borderSublayer = CAShapeLayer()
        borderSublayer.frame = ringView.bounds
        ringView.layer.addSublayer(borderSublayer)
        ringView.drawBorderForLayer(borderSublayer, color: ColorPalette.Pink.color(), width: BORDER_WIDTH)
    }
        
    func resetCptSublayer() {
        cptSublayer?.removeAllAnimations()
        cptSublayer?.removeFromSuperlayer()
        
        cptSublayer = CAShapeLayer()
        cptSublayer.frame = ringView.bounds
        cptSublayer.strokeColor = ColorPalette.Pink.color().CGColor
        cptSublayer.fillColor = ColorPalette.Black.color().CGColor // UIColor.blueColor().CGColor //
        cptSublayer.lineWidth = BORDER_WIDTH
        
        
        let diameter:CGFloat = 15
        let smallCircleFrame = CGRect(x: CGRectGetMidX(ringView.bounds)-diameter/2, y: -diameter/2+1, width: diameter, height: diameter)
        let path = UIBezierPath(ovalInRect: smallCircleFrame)
        cptSublayer.path = path.CGPath
        cptSublayer.masksToBounds = false
        
        ringView.layer.insertSublayer(cptSublayer, above: borderSublayer)
        
    }
    
    func resetBpmSublayer() {
        bpmSublayer?.removeAllAnimations()
        bpmSublayer?.removeFromSuperlayer()
        
        bpmSublayer = CAShapeLayer()
        bpmSublayer.frame = ringView.bounds
        bpmSublayer.strokeColor = ColorPalette.Pink.color().CGColor
        bpmSublayer.fillColor = ColorPalette.Pink.color().CGColor
        bpmSublayer.lineWidth = BORDER_WIDTH
        
        
        let diameter:CGFloat = 15
        let smallCircleFrame = CGRect(x: CGRectGetMidX(ringView.bounds)-diameter/2, y: -diameter/2+1, width: diameter, height: diameter)
        let path = UIBezierPath(ovalInRect: smallCircleFrame)
        bpmSublayer.path = path.CGPath
        bpmSublayer.masksToBounds = false
        
        ringView.layer.insertSublayer(bpmSublayer, above: cptSublayer)
        
    }
    
    
    func initAnimations() {
        // CPT rotation
        cptAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        cptAnimation.fromValue = 0
        cptAnimation.toValue = -M_PI * 2.0  //   /* full rotation*/ * rotations * duration ];
        cptAnimation.cumulative = false
        cptAnimation.repeatCount = metronomeIsOn ? Float.infinity : 1
        cptAnimation.removedOnCompletion = true
        
        // BPM rotation
        bpmAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        bpmAnimation.fromValue = 0
        bpmAnimation.toValue = -M_PI * 2.0  //   /* full rotation*/ * rotations * duration ];
        bpmAnimation.cumulative = false
        bpmAnimation.repeatCount = 1
        bpmAnimation.removedOnCompletion = true
        
        // drum frame animation
        let dSize:CGFloat = 15
        let startBounds = drumImage.bounds;
        let stopBounds = CGRectMake(0, 0, startBounds.width+dSize, startBounds.height+dSize);
        
        pulseAnimation = CABasicAnimation(keyPath:"bounds")
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        pulseAnimation.fromValue = NSValue(CGRect:startBounds)
        pulseAnimation.toValue = NSValue(CGRect:stopBounds)
        pulseAnimation.autoreverses = true
        pulseAnimation.duration = PULSE_DURATION
        pulseAnimation.cumulative = false
        pulseAnimation.repeatCount = 1
        pulseAnimation.removedOnCompletion = true
        
    }
    
//    func cptAnimationIsPlaying() -> Bool {
//        return cptSublayer.animationForKey("transform.rotation.z") != nil
//    }
    
    func runAnimationWithCpt(cpt:Int, bpm:Int) {
        drumImage?.layer.removeAllAnimations()
        bpmSublayer?.removeAllAnimations()
        // CPT
        if !metronomeIsOn {
            cptSublayer.removeAllAnimations()
            cptAnimation.duration = 60.0/(Double(cpt)/Double(timeSignature)) // =60sec/actual_hits_per_min
            cptAnimation.repeatCount = 1
            cptSublayer?.addAnimation(cptAnimation, forKey:"cptAnimation")
        }
        // BPM
        bpmAnimation.duration = 60.0/(Double(bpm)/Double(timeSignature)) // =60sec/actual_hits_per_min
        bpmSublayer?.addAnimation(bpmAnimation, forKey: "bpmAnimation")
        
        drumImage?.layer.addAnimation(pulseAnimation, forKey: "pulseAnimation")
    }
    
    func runPulseAnimationOnly() {
        if !metronomeIsOn {
            cptSublayer.removeAllAnimations()
        }
        drumImage?.layer.removeAllAnimations()
        drumImage?.layer.addAnimation(pulseAnimation, forKey: "pulseAnimation")
    }
    
    
//    func clearSublayers() {
//        ringView.layer.sublayers = nil
//        cptSublayer = nil
//        borderSublayer = nil
//    }
    
    
    func handleMetronomeState()
    {
        println("handleMetronomeState")
        cptSublayer.removeAllAnimations()
        
        if metronomeIsOn {
            cptAnimation.duration = 60.0/Double(metronomeTempo/timeSignature)
            cptAnimation.repeatCount = Float.infinity
            cptSublayer.addAnimation(cptAnimation, forKey:"cptAnimation")
            
        } else {
            println("metronom OFF")
        }
    }
    
    
    //MARK: - Tap recognizer
    
    lazy var tapGR:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapCentralRing:")
    
    func listenToTaps(doListen:Bool) {
        if doListen {
            ringView.addGestureRecognizer(tapGR)
        } else {
            ringView.removeGestureRecognizer(tapGR)
        }
    }
    
    func didTapCentralRing(gestureRecognizer:UITapGestureRecognizer) {
        handleTap()
    }
    
    
    var newTapTime:UInt64 = 0;
    var oldTapTime:UInt64 = 0;
    
    var tapCount:UInt64 = 0;
    
    func handleTap() {
        newTapTime = PublicUtilityWrapper.CAHostTimeBase_GetCurrentTime()
        
        var timeElapsedNs:UInt64 = PublicUtilityWrapper.CAHostTimeBase_AbsoluteHostDeltaToNanos(newTapTime, oldTapTime: oldTapTime)
        
        var delayFator:Float64 = 0.1
        var timeElapsedInSec:Float64 = Float64(timeElapsedNs) * 10.0e-9 * delayFator;
        
        var isNewTapSeq = (timeElapsedInSec > IDLE_TIMEOUT) ? true : false
        
        if isNewTapSeq {
            tapCount = 0;
            crtLabel.text = "_"
            runPulseAnimationOnly()
            hideCptLabelAfterDelay()
        } else {
            let figertapBPM = 60.0 / timeElapsedInSec
            self.foundFigertapBPM(figertapBPM)
        }
        
        oldTapTime = newTapTime;
        tapCount += 1;
    
    }

    func foundFigertapBPM(figertapBPM: Float64) {
        // apply time signature 
        println("bpm: \(figertapBPM)")
        delegate?.centralRingFoundTapBPM(figertapBPM);
    }

    func displayCpt(cpt:Int, bpm:Int) {

        println("cpt: \(cpt), bpm: \(bpm)")
        
        // display numbers
        if cpt > MAX_TEMPO || cpt < MIN_TEMPO {
            // We do not need BPM outside this range.
            crtLabel.text = "_"
            runPulseAnimationOnly()
        } else {
            crtLabel.text = "\(cpt)"
            runAnimationWithCpt(cpt, bpm:bpm)
        }
        hideCptLabelAfterDelay()
        
    }
    
    func clear() {
        oldTapTime = 0
        newTapTime = 0
        tapCount = 0
        crtLabel.text = ""
        resetCptSublayer()
    }
    
    func hideCptLabelAfterDelay() {
        delay(PULSE_DURATION, callback: { () -> () in
            self.crtLabel.text = ""
        })
    }
    
}
