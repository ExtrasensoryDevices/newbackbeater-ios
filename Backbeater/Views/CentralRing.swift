//
//  CentralRing.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-07-16.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

import UIKit


protocol CentralRingDelegate: class {
    func centralRingFoundTapBPM(bpm:UInt)
}


class CentralRing: NibDesignable {
    
    weak var delegate: CentralRingDelegate?

    @IBOutlet weak var drumImage: UIImageView!
    @IBOutlet weak var ringView: UIView!
    @IBOutlet weak var crtLabel: UILabel!
    
    var animationSublayer:CAShapeLayer!
    var borderSublayer:CAShapeLayer!
    
    @IBOutlet weak var ringTopConstraint: NSLayoutConstraint!
    
    override func setup() {
        super.setup()
        self.backgroundColor = UIColor.clearColor()
        self.nibView.backgroundColor = UIColor.clearColor()
        self.ringView.backgroundColor = UIColor.clearColor()
        ringView.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.allZeros, context: nil)
        
        
        crtLabel.text = ""
        
        resetSublayers()
    }
    
    override func didMoveToWindow() {
        crtLabel.font = Font.FuturaBook.get(100) // TODO: add font for label, then uncomment 142)
    }
    
    deinit {
        ringView.removeObserver(self, forKeyPath: "bounds")
    }
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if object === ringView && keyPath == "bounds" {
            resetSublayers()
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
        
        ringView.layer.addSublayer(animationSublayer)
        
    }
    
    //func runSpinAnimationWithDuration(duration:CFTimeInterval) {
    func runSpinAnimationWithDuration(bpm:UInt) {
        
        animationSublayer.removeAllAnimations() // or resetAnimationSublayer() ?
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = -M_PI * 2.0  //   /* full rotation*/ * rotations * duration ];
        rotationAnimation.duration = CFTimeInterval(60/bpm) // duration;
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = 1
        rotationAnimation.removedOnCompletion = true
        
        animationSublayer?.addAnimation(rotationAnimation, forKey:"rotationAnimation")
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
        
        var isNewTapSeq = (timeElapsedInSec > 2.0) ? true : false
        
        if isNewTapSeq {
            tapCount = 0;
            crtLabel.hidden = true
        } else {
//            if timeElapsedInSec > 0.2 { // When BPM is less than 100, calculate and display BPM immediately.
                let bpm = UInt(60.0 / timeElapsedInSec)
                self.foundFigertapBPM(bpm)
                println("nanoseconds: \(timeElapsedNs)\tseconds: \(timeElapsedInSec) \tbpm: \(bpm)")
//            } else { // When BPM is more than 100, add up elapsed time until tap count is over 3, then display.
//                crtLabel.hidden = true
//            }
        }
        
        oldTapTime = newTapTime;
        tapCount += 1;
    
    }

    func foundFigertapBPM(bpm: UInt) {
        // time signature correction
        let correctedBPM = bpm * UInt(Settings.sharedInstance().timeSignature)
        displayBPM(correctedBPM)
    }

    
    func displayBPM(bpm:UInt) {
        let avgBpm:UInt = bpm  //TODO: need this? [[self.filter enqueue:[NSNumber numberWithFloat:bpm]] average];

        delegate?.centralRingFoundTapBPM(avgBpm)

        // display numbers
        if avgBpm > UInt(MAX_TEMPO) || avgBpm < UInt(MIN_TEMPO) {
            // We do not need BPM outside this range.
            crtLabel.text = "__"
            resetAnimationSublayer()
        } else {
            crtLabel.text = "\(avgBpm)"
            runSpinAnimationWithDuration(avgBpm)
        }
        crtLabel.hidden = false
//        delay(0.1, callback: { () -> () in
//            self.crtLabel.hidden = true
//        })
        
    }
    
    
}
