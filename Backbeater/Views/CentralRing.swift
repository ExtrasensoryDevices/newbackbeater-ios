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
    
    var animationSublayer:CAShapeLayer!
    var borderSublayer:CAShapeLayer!
    
    @IBOutlet weak var ringTopConstraint: NSLayoutConstraint!
    
    var timeSignature:Int!
    
    var rotationAnimation:CABasicAnimation!
    var pulseAnimation:CABasicAnimation!
    let PULSE_DURATION = floor(60.0 / Double(MAX_TEMPO) * 10) / 10
    
    override func setup() {
        super.setup()
        self.backgroundColor = UIColor.clearColor()
        self.nibView.backgroundColor = UIColor.clearColor()
        self.ringView.backgroundColor = UIColor.clearColor()
        ringView.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.allZeros, context: nil)
        
        
        crtLabel.text = ""
        
        resetSublayers()
        
        timeSignature = Settings.sharedInstance().timeSignature
        Settings.sharedInstance().addObserver(self, forKeyPath: "timeSignatureSelectedIndex", options: NSKeyValueObservingOptions.allZeros, context: nil)
        
        initAnimations()
    }
    
    override func didMoveToWindow() {
        crtLabel.font = Font.FuturaBook.get(100) // TODO: add font for label, then uncomment 142)
    }
    
    deinit {
        ringView.removeObserver(self, forKeyPath: "bounds")
        Settings.sharedInstance().removeObserver(self, forKeyPath: "timeSignatureSelectedIndex")
    }
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if object === ringView && keyPath == "bounds" {
            resetSublayers()
        } else if keyPath == "timeSignatureSelectedIndex" {
            timeSignature = Settings.sharedInstance().timeSignature
        }
    }
    
    
    func resetSublayers() {
        resetBorderSublayer()
        resetAnimationSublayer()
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
        
    func resetAnimationSublayer() {
        animationSublayer?.removeAllAnimations()
        animationSublayer?.removeFromSuperlayer()

        animationSublayer = CAShapeLayer()
        animationSublayer.frame = ringView.bounds
        animationSublayer.strokeColor = ColorPalette.Pink.color().CGColor
        animationSublayer.fillColor = UIColor.blueColor().CGColor //ColorPalette.Black.color().CGColor
        animationSublayer.lineWidth = BORDER_WIDTH
        
        
        let diameter:CGFloat = 15
        let smallCircleFrame = CGRect(x: CGRectGetMidX(ringView.bounds)-diameter/2, y: -diameter/2+1, width: diameter, height: diameter)
        let path = UIBezierPath(ovalInRect: smallCircleFrame)
        animationSublayer.path = path.CGPath
        animationSublayer.masksToBounds = false
        
        ringView.layer.insertSublayer(animationSublayer, above: borderSublayer)
        
    }
    
    
    func initAnimations() {
        // rotation
        rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = -M_PI * 2.0  //   /* full rotation*/ * rotations * duration ];
        rotationAnimation.cumulative = false
        rotationAnimation.repeatCount = 1
        rotationAnimation.removedOnCompletion = true
        
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
    
    //func runSpinAnimationWithDuration(duration:CFTimeInterval) {
    func runAnimationWithDuration(cpt:Int) {
        
        animationSublayer.removeAllAnimations() // or resetAnimationSublayer() ?
        
        rotationAnimation.duration = CFTimeInterval(60/(cpt/timeSignature)) // duration;
        
        animationSublayer?.addAnimation(rotationAnimation, forKey:"rotationAnimation")
        drumImage?.layer.addAnimation(pulseAnimation, forKey: "pulseAnimation")
    }
    
    
    func clearSublayers() {
        ringView.layer.sublayers = nil
        animationSublayer = nil
        borderSublayer = nil
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
            crtLabel.text = ""
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

    func displayCPT(cpt:Int) {

        println("cpt: \(cpt)")
        
        // display numbers
        if cpt > MAX_TEMPO || cpt < MIN_TEMPO {
            // We do not need BPM outside this range.
            crtLabel.text = "__"
            resetAnimationSublayer()
        } else {
            crtLabel.text = "\(cpt)"
            runAnimationWithDuration(cpt)
        }
        delay(PULSE_DURATION, callback: { () -> () in
            self.crtLabel.text = ""
        })
        
    }
    
    func clear() {
        oldTapTime = 0
        newTapTime = 0
        tapCount = 0
        crtLabel.text = ""
        resetAnimationSublayer()
    }
    
    
}
