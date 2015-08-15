//
//  CentralRing.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-07-16.
//

import UIKit
import AVFoundation

protocol CentralRingDelegate: class {
    func centralRingFoundTapBPM(bpm:Float64)
}


class CentralRing: NibDesignable {
    
    weak var delegate: CentralRingDelegate?
    
//    var listenToTaps = false


    @IBOutlet weak var drumImage: UIImageView!
    @IBOutlet weak var ringView: UIView!
    @IBOutlet weak var cptLabel: UILabel!
    
    @IBOutlet weak var ringTopConstraint: NSLayoutConstraint!
    
    var player:AVAudioPlayer!
    
    var cptSublayer:CAShapeLayer!
    var bpmSublayer:CAShapeLayer!
    var borderSublayer:CAShapeLayer!
    
    var cptAnimation:CABasicAnimation!
    var bpmAnimation:CAKeyframeAnimation!
    var pulseAnimation:CABasicAnimation!
    let PULSE_DURATION:Double = floor(60.0 / Double(BridgeConstants.MAX_TEMPO()) * 10) / 10 / 5
    
//    var drumAnimationImages:[UIImage] = []
    var drumAnimationImagesLeft:[UIImage] = []
    var drumAnimationImagesRight:[UIImage] = []
    
    let settings = Settings.sharedInstance()
    
    var metronomeIsOn:Bool {
        return settings.metronomeIsOn && settings.metronomeTempo >= BridgeConstants.MIN_TEMPO() && settings.metronomeTempo <= BridgeConstants.MAX_TEMPO()
    }
    
    var metronomeTimer: dispatch_source_t?
    
    
    let BPM_ANIMATION_KEY = "bpmAnimation"
    let CPT_ANIMATION_KEY = "cptAnimation"
    let PULSE_ANIMATION_KEY = "pulseAnimation"
    
    let TIME_SIGNATURE_KEY_PATH = "timeSignatureSelectedIndex"
    let METRONOME_TEMPO_KEY_PATH = "metronomeTempo"
    let METRONOME_ON_KEY_PATH = "metronomeIsOn"
    let METRONOME_SOUND_INDEX_KEY_PATH = "metronomeSoundSelectedIndex"
    
    override func setup() {
        super.setup()
        self.backgroundColor = UIColor.clearColor()
        self.ringView.backgroundColor = UIColor.clearColor()
        ringView.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.allZeros, context: nil)
        
        
        cptLabel.text = "\(settings.lastPlayedTempo)"
        
        resetSublayers()
        initAnimations()
        updateAudioPlayer()
        
       
        settings.addObserver(self, forKeyPath: TIME_SIGNATURE_KEY_PATH, options: NSKeyValueObservingOptions.allZeros, context: nil)
        settings.addObserver(self, forKeyPath: METRONOME_TEMPO_KEY_PATH, options: NSKeyValueObservingOptions.allZeros, context: nil)
        settings.addObserver(self, forKeyPath: METRONOME_ON_KEY_PATH, options: NSKeyValueObservingOptions.allZeros, context: nil)
        settings.addObserver(self, forKeyPath: METRONOME_SOUND_INDEX_KEY_PATH, options: NSKeyValueObservingOptions.allZeros, context: nil)
        
    }
    
    override func didMoveToWindow() {
        cptLabel.font = Font.SteelfishRg.get(142)
    }
    
    deinit {
        ringView.removeObserver(self, forKeyPath: "bounds")
        settings.removeObserver(self, forKeyPath: TIME_SIGNATURE_KEY_PATH)
        settings.removeObserver(self, forKeyPath: METRONOME_TEMPO_KEY_PATH)
        settings.removeObserver(self, forKeyPath: METRONOME_ON_KEY_PATH)
        settings.removeObserver(self, forKeyPath: METRONOME_SOUND_INDEX_KEY_PATH)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if object === ringView && keyPath == "bounds" {
            resetSublayers()
            handleMetronomeState()
        } else if let settings = object as? Settings {
            if keyPath == TIME_SIGNATURE_KEY_PATH {
                if metronomeIsOn {
                    handleMetronomeState()
                }
            } else if keyPath == METRONOME_TEMPO_KEY_PATH {
                handleMetronomeState()
            } else if keyPath == METRONOME_ON_KEY_PATH {
                handleMetronomeState()
            } else if keyPath == METRONOME_SOUND_INDEX_KEY_PATH {
                updateAudioPlayer()
            }
        }
    }
    
    func updateAudioPlayer() {
        var error:NSError?
        player = AVAudioPlayer(contentsOfURL: settings.urlForSound, error: &error)
        if error == nil {
            player.prepareToPlay()
        } else {
            println(error!)
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
        cptSublayer.fillColor = ColorPalette.Black.color().CGColor
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
        bpmSublayer.opacity = 0.0
        
        
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
        cptAnimation.repeatCount = Float.infinity
        cptAnimation.removedOnCompletion = true
        
        bpmAnimation = CAKeyframeAnimation(keyPath:"opacity")
        bpmAnimation.duration = 1.5
        bpmAnimation.keyTimes = [0.0, 0.01, 1.5]
        bpmAnimation.values =   [0.0, 1.0, 0.0]
        bpmAnimation.beginTime = 0.0;
        bpmAnimation.removedOnCompletion = true
        bpmAnimation.cumulative = false
        bpmAnimation.repeatCount = 1
        
        
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
        
        // drum hit animation
//        let imageCount = 8
//        for i in 0...imageCount-1 {
//            let imageName = "drum_icon\(i)"
//            if let image = UIImage(named: imageName) {
//                drumAnimationImages.append(image)
//            }
//        }
        let imageCount = 16
        for i in 1...imageCount {
            let imageName = "LEFT_\(i)"
            if let image = UIImage(named: imageName) {
                drumAnimationImagesLeft.append(image)
            }
        }
        
        for i in 1...imageCount {
            let imageName = "RIGHT_\(i)"
            if let image = UIImage(named: imageName) {
                drumAnimationImagesRight.append(image)
            }
        }
        
        drumImage.animationRepeatCount = 1
        drumImage.animationDuration = Double(imageCount) * 40.0 / 1000.0
        switchDrumAnimation()
    }
    
    
    var useDrumAnimationLeft = true
    func switchDrumAnimation() {
        useDrumAnimationLeft = !useDrumAnimationLeft
        drumImage.animationImages = useDrumAnimationLeft ? drumAnimationImagesLeft : drumAnimationImagesRight
        drumImage.image = (drumImage.animationImages!.last as! UIImage)
    }
    
    
    func runAnimationWithCPT(cpt:Int, instantTempo:Int) {
        
        bpmSublayer?.removeAllAnimations()
        // CPT
        if !metronomeIsOn {
            cptSublayer.removeAllAnimations()
            cptAnimation.duration = 60.0/(Double(cpt)/Double(settings.timeSignature)) // =60sec/actual_hits_per_min
            cptSublayer.addAnimation(cptAnimation, forKey:CPT_ANIMATION_KEY)
        }
        // BPM
        
        let fromValue: NSNumber = cptSublayer.presentationLayer().valueForKeyPath("transform.rotation.z")  as! NSNumber
        if fromValue.floatValue > -0.2 && fromValue.floatValue < 0.2 {
            animateDrumImage()
        } else {
            runPulseAnimationOnly()
        }
        bpmSublayer.transform = CATransform3DMakeRotation(CGFloat(fromValue.floatValue), 0, 0, 1.0)
        bpmSublayer.removeAllAnimations()
        bpmSublayer.addAnimation(bpmAnimation, forKey: BPM_ANIMATION_KEY)

        
    }
    
    func runPulseAnimationOnly() {
        drumImage?.layer.removeAllAnimations()
        drumImage?.layer.addAnimation(pulseAnimation, forKey: PULSE_ANIMATION_KEY)
    }
    
    func handleMetronomeState()
    {
        cptSublayer.removeAllAnimations()
        
        if let timer = metronomeTimer {
            dispatch_source_cancel(metronomeTimer!)
            metronomeTimer = nil
        }
        
        if metronomeIsOn {
            let duration = 60.0/Double(settings.metronomeTempo)
            cptAnimation.duration = duration
            cptSublayer.addAnimation(cptAnimation, forKey:CPT_ANIMATION_KEY)
            if let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue()) {
                dispatch_source_set_timer(timer, dispatch_walltime(nil, 0), UInt64(duration*Double(NSEC_PER_SEC)), 5);
                dispatch_source_set_event_handler(timer, { [weak self] () -> Void in
                    if let player = self?.player {
                        if player.playing {
                            player.stop()
                            player.currentTime = 0.0
                        }
                        player.play()
                    }
                })
                dispatch_resume(timer)
                metronomeTimer = timer
            }
            
        }
    }
    
    func  animateDrumImage() {
        drumImage.stopAnimating()
        switchDrumAnimation()
        drumImage.startAnimating()
    }
    
    
    //MARK: - Tap recognizer
    
    var newTapTime:UInt64 = 0;
    var oldTapTime:UInt64 = 0;
    
    var tapCount:UInt64 = 0;
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        if !listenToTaps {
//            return
//        }
        
        newTapTime = PublicUtilityWrapper.CAHostTimeBase_GetCurrentTime()
        
        var timeElapsedNs:UInt64 = PublicUtilityWrapper.CAHostTimeBase_AbsoluteHostDeltaToNanos(newTapTime, oldTapTime: oldTapTime)
        
        var delayFator:Float64 = 0.1
        var timeElapsedInSec:Float64 = Float64(timeElapsedNs) * 10.0e-9 * delayFator;
        
        var isNewTapSeq = (timeElapsedInSec > BridgeConstants.IDLE_TIMEOUT()) ? true : false
        
        if isNewTapSeq {
            tapCount = 0;
            runPulseAnimationOnly()
        } else {
            let figertapBPM = 60.0 / timeElapsedInSec
            self.foundFigertapBPM(figertapBPM)
        }
        
        oldTapTime = newTapTime;
        tapCount += 1;
    
    }

    func foundFigertapBPM(figertapBPM: Float64) {
        // apply time signature 
        delegate?.centralRingFoundTapBPM(figertapBPM);
    }

    func displayCPT(cpt:Int, instantTempo:Int) {
        // display numbers
        if cpt > BridgeConstants.MAX_TEMPO() || cpt < BridgeConstants.MIN_TEMPO() {
            // We do not need BPM outside this range.
            cptLabel.text = cpt > BridgeConstants.MAX_TEMPO() ? "MAX" : "MIN"
            runPulseAnimationOnly()
        } else {
            cptLabel.text = "\(cpt)"
            runAnimationWithCPT(cpt, instantTempo:instantTempo)
        }
        
        
    }
    
    func clear() {
        oldTapTime = 0
        newTapTime = 0
        tapCount = 0
        cptSublayer.removeAllAnimations()
    }
    

    
}
