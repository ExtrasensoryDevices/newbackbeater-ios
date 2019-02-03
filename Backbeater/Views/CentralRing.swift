//
//  CentralRing.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-07-16.
//

import UIKit
import AVFoundation


protocol CentralRingDelegate: class {
    func centralRingFoundTapBPM(_ bpm:Float64)
}


class CentralRing: NibDesignable {
    
    weak var delegate: CentralRingDelegate?

    @IBOutlet weak var drumImage: UIImageView!
    @IBOutlet weak var ringView: UIView!
    @IBOutlet weak var cptLabel: UILabel!
    
    @IBOutlet weak var ringTopConstraint: NSLayoutConstraint!
    
    private var player:AVAudioPlayer!
    
    private var cptSublayer:CAShapeLayer!
    private var bpmSublayer:CAShapeLayer!
    private var strikeSublayer:CAShapeLayer!
    private var borderSublayer:CAShapeLayer!
    
    private var cptAnimation:CABasicAnimation!
    private var bpmAnimation:CAKeyframeAnimation!
    private var strikeAnimation:CAKeyframeAnimation!
    private var pulseAnimation:CABasicAnimation!
    private let PULSE_DURATION:Double = floor(60.0 / Double(Constants.MAX_TEMPO) * 10) / 10 / 5
    
    private var drumAnimationImagesLeft:[UIImage] = []
    private var drumAnimationImagesRight:[UIImage] = []
    
    private var metronomeTimer: DispatchSourceTimer?
    
    private let CPT_ANIMATION_KEY = "cptAnimation"
    private let BPM_ANIMATION_KEY = "bpmAnimation"
    private let STRIKE_ANIMATION_KEY = "strikeAnimation"
    private let PULSE_ANIMATION_KEY = "pulseAnimation"
    
    private let METRONOME_TEMPO_KEY_PATH = "metronomeTempo"
    private let METRONOME_ON_KEY_PATH = "metronomeIsOn"
    private let METRONOME_SOUND_INDEX_KEY_PATH = "metronomeSoundSelectedIndex"
    
    override func setup() {
        super.setup()
        self.backgroundColor = UIColor.clear
        self.ringView.backgroundColor = UIColor.clear
//        ringView.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        
        let fontSize:CGFloat
        switch ScreenUtil.screenSizeClass {
            case .xsmall: fontSize = 140
            case .small:  fontSize = 165
            case .medium: fontSize = 210
            case .large:  fontSize = 220
            case .xlarge: fontSize = 300
        }
        cptLabel.font = Font.SteelfishRg.get(fontSize)
        
        resetSublayers()
        initAnimations()
    }
    
    
    func setLastPlayedTempo(tempo:Int) {
        cptLabel.text = "\(tempo)"
    }
    
    func setSound(url:URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
        } catch  {
            print(error)
        }
    }

    func display(cpt:Int, timeSignature: Int, metronomeState:MetronomeState) {
        // display numbers
        if cpt > Constants.MAX_TEMPO || cpt < Constants.MIN_TEMPO {
            // We do not need BPM outside this range.
            cptLabel.text = cpt > Constants.MAX_TEMPO ? "MAX" : "MIN"
            runPulseAnimation()
        } else {
            cptLabel.text = "\(cpt)"
            let cptAnimationDuration = 60.0/(Double(cpt)/Double(timeSignature)) // =60sec/actual_hits_per_min
            let resetCptAnimation = metronomeState == .off
            runAnimation(resetCptAnimation: resetCptAnimation, cptAnimationDuration: cptAnimationDuration)
        }
    }
    
    func handleMetronomeState(_ metronomeState:MetronomeState, metronomeTempo:Int, tempoChanged:Bool) {
        
        metronomeTimer?.cancel()
        metronomeTimer = nil
        
        switch metronomeState {
        case .on:
            let duration = 60.0/Double(metronomeTempo)
            // restart animation if needed
            let cptAnimationIsRunning = (cptSublayer.animationKeys()?.count ?? 0) > 0
            let animationShouldRestart = !cptAnimationIsRunning || (cptAnimationIsRunning && tempoChanged)
            if animationShouldRestart {
                cptSublayer.removeAllAnimations()
                cptAnimation.duration = duration
                cptSublayer.add(cptAnimation, forKey:CPT_ANIMATION_KEY)
            }
            // add sound timer
            let timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: DispatchQueue.main)
            let interval = duration * Double(NSEC_PER_SEC)
            timer.schedule(wallDeadline: DispatchWallTime.now(), repeating:interval, leeway: .nanoseconds(5))
            
            timer.setEventHandler{ [weak self] in
                self?.playSound()
            }
            timer.resume()
            metronomeTimer = timer
            
        case .off:
            cptSublayer.removeAllAnimations()
        }
    }
    
    func reset() {
        oldTapTime = 0
        newTapTime = 0
        tapCount = 0
        cptSublayer.removeAllAnimations()
    }
    
    

//    deinit {
//        ringView.removeObserver(self, forKeyPath: "bounds")
//    }
//
//    private func observeValue(forKeyPath keyPath: String, of object: Any, change: [AnyHashable: Any], context: UnsafeMutableRawPointer) {
//        if (object as? UIView) === ringView && keyPath == "bounds" {
//            resetSublayers()
//            handleMetronomeState() // FIX: DO SOMETHING ABOUT IT
//        }
//    }
    
    private func playSound() {
        if player != nil  {
            if player.isPlaying {
                player.stop()
                player.currentTime = 0.0
            }
            player.play()
        }
    }


    //MARK: - Tap recognizer
    
    private var newTapTime:UInt64 = 0;
    private var oldTapTime:UInt64 = 0;
    private var tapCount:UInt64 = 0;
    
    private func touchesBegan(_ touches: Set<NSObject>, with event: UIEvent) {
        newTapTime = PublicUtilityWrapper.caHostTimeBase_GetCurrentTime()
        
        let timeElapsedNs:UInt64 = PublicUtilityWrapper.caHostTimeBase_AbsoluteHostDelta(toNanos: newTapTime, oldTapTime: oldTapTime)
        
        let delayFator:Float64 = 0.1
        let timeElapsedInSec:Float64 = Float64(timeElapsedNs) * 10.0e-9 * delayFator;
        
        let isNewTapSeq = (timeElapsedInSec > Constants.IDLE_TIMEOUT) ? true : false
        
        if isNewTapSeq {
            tapCount = 0;
            runPulseAnimation()
        } else {
            let figertapBPM = 60.0 / timeElapsedInSec
            self.foundFigertapBPM(figertapBPM)
        }
        
        oldTapTime = newTapTime;
        tapCount += 1;
        
    }
    
    private func foundFigertapBPM(_ figertapBPM: Float64) {
        // apply time signature
        delegate?.centralRingFoundTapBPM(figertapBPM);
    }
    
    // MARK: - Animation
    
    private let correctHitAngleRad:Float = 0.131
    private func runAnimation(resetCptAnimation: Bool, cptAnimationDuration:Double) {
        
        bpmSublayer?.removeAllAnimations()
        // CPT
        if resetCptAnimation {
            cptSublayer.removeAllAnimations()
            cptAnimation.duration = cptAnimationDuration
            cptSublayer.add(cptAnimation, forKey:CPT_ANIMATION_KEY)
        }
        // BPM
        
        let currentRotationAngle = getCurrentRotationRad()
        if currentRotationAngle > -correctHitAngleRad && currentRotationAngle < correctHitAngleRad {
            animateStrike()
        } else {
            runPulseAnimation()
        }
        bpmSublayer.transform = CATransform3DMakeRotation(CGFloat(currentRotationAngle), 0, 0, 1.0)
        bpmSublayer.removeAllAnimations()
        bpmSublayer.add(bpmAnimation, forKey: BPM_ANIMATION_KEY)
    }
    
    private func initAnimations() {
        // CPT/metronome rotation
        cptAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        cptAnimation.fromValue = 0
        cptAnimation.toValue = .pi * 2.0  //   /* full rotation*/ * rotations * duration ];
        cptAnimation.isCumulative = false
        cptAnimation.repeatCount = Float.infinity
        cptAnimation.isRemovedOnCompletion = true
        
        // fading strike imprint
        bpmAnimation = CAKeyframeAnimation(keyPath:"opacity")
        bpmAnimation.duration = 1.5
        bpmAnimation.keyTimes = [0.0, 0.01, 1.5]
        bpmAnimation.values =   [0.0, 1.0, 0.0]
        bpmAnimation.beginTime = 0.0;
        bpmAnimation.isRemovedOnCompletion = true
        bpmAnimation.isCumulative = false
        bpmAnimation.repeatCount = 1
        
        //correct strike border flash
        strikeAnimation = CAKeyframeAnimation(keyPath:"opacity")
        strikeAnimation.duration = 1.5
        strikeAnimation.keyTimes = [0.0, 0.2, 0.4]
        strikeAnimation.values =   [0.0, 1.0, 0.0]
        strikeAnimation.beginTime = 0.0;
        strikeAnimation.isRemovedOnCompletion = true
        strikeAnimation.isCumulative = false
        strikeAnimation.repeatCount = 1
        
        
        // incorrect strike, drum pulse animation
        let dSize:CGFloat = 15
        let startBounds = drumImage.bounds;
        let stopBounds = CGRect(x: 0, y: 0, width: startBounds.width+dSize, height: startBounds.height+dSize);
        
        pulseAnimation = CABasicAnimation(keyPath:"bounds")
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        pulseAnimation.fromValue = NSValue(cgRect:startBounds)
        pulseAnimation.toValue = NSValue(cgRect:stopBounds)
        pulseAnimation.autoreverses = true
        pulseAnimation.duration = PULSE_DURATION
        pulseAnimation.isCumulative = false
        pulseAnimation.repeatCount = 1
        pulseAnimation.isRemovedOnCompletion = true
        
        
        // correct strike drum sticks animation
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
    
    
    func runPulseAnimation() {
        drumImage?.layer.removeAllAnimations()
        drumImage?.layer.add(pulseAnimation, forKey: PULSE_ANIMATION_KEY)
    }
    
    private func animateStrike() {
        drumImage.stopAnimating()
        switchDrumAnimation()
        drumImage.startAnimating()
        
        strikeSublayer.removeAllAnimations()
        strikeSublayer.add(strikeAnimation, forKey: STRIKE_ANIMATION_KEY)
    }
    
    
    private var useDrumAnimationLeft = true
    private func switchDrumAnimation() {
        useDrumAnimationLeft = !useDrumAnimationLeft
        drumImage.animationImages = useDrumAnimationLeft ? drumAnimationImagesLeft : drumAnimationImagesRight
        drumImage.image = drumImage.animationImages!.last
    }
    

    private func getCurrentRotationRad() -> Float {
        return (cptSublayer.presentation()!.value(forKeyPath: "transform.rotation.z")  as! NSNumber).floatValue
    }
    
    
    /// Reset all sublayers when frame changes
    
    private func resetSublayers() {
        resetBorderSublayer()
        resetCptSublayer()
        resetBpmSublayer()
        resetStrikeSublayer()
        ringView.layer.masksToBounds = false
        ringView.clipsToBounds = false
    }
    
    
    private func resetBorderSublayer() {
        
        borderSublayer?.removeFromSuperlayer()
        
        // border
        borderSublayer = CAShapeLayer()
        borderSublayer.frame = ringView.bounds
        ringView.layer.addSublayer(borderSublayer)
        ringView.drawBorder(for: borderSublayer, color: ColorPalette.pink.color(), width: BORDER_WIDTH)
    }
    
    private func resetCptSublayer() {
        cptSublayer?.removeAllAnimations()
        cptSublayer?.removeFromSuperlayer()
        
        cptSublayer = CAShapeLayer()
        cptSublayer.frame = ringView.bounds
        cptSublayer.strokeColor = ColorPalette.pink.color().cgColor
        cptSublayer.fillColor = ColorPalette.pink.color().cgColor
        cptSublayer.lineWidth = BORDER_WIDTH
        
        
        let diameter:CGFloat = 15
        let smallCircleFrame = CGRect(x: ringView.bounds.midX-diameter/2, y: -diameter/2+1, width: diameter, height: diameter)
        let path = UIBezierPath(ovalIn: smallCircleFrame)
        cptSublayer.path = path.cgPath
        cptSublayer.masksToBounds = false
        
        ringView.layer.insertSublayer(cptSublayer, above: borderSublayer)
        
    }
    
    private func resetBpmSublayer() {
        bpmSublayer?.removeAllAnimations()
        bpmSublayer?.removeFromSuperlayer()
        
        bpmSublayer = CAShapeLayer()
        bpmSublayer.frame = ringView.bounds
        bpmSublayer.strokeColor = UIColor.white.cgColor
        bpmSublayer.fillColor = UIColor.white.cgColor
        bpmSublayer.lineWidth = BORDER_WIDTH
        bpmSublayer.opacity = 0.0
        
        
        let diameter:CGFloat = 15
        let smallCircleFrame = CGRect(x: ringView.bounds.midX-diameter/2, y: -diameter/2+1, width: diameter, height: diameter)
        let path = UIBezierPath(ovalIn: smallCircleFrame)
        bpmSublayer.path = path.cgPath
        bpmSublayer.masksToBounds = false
        
        ringView.layer.insertSublayer(bpmSublayer, above: cptSublayer)
        
    }
    private func resetStrikeSublayer() {
        
        strikeSublayer?.removeFromSuperlayer()
        
        // border
        strikeSublayer = CAShapeLayer()
        strikeSublayer.frame = ringView.bounds
        strikeSublayer.opacity = 0.0
        ringView.layer.addSublayer(strikeSublayer)
        ringView.drawBorder(for: strikeSublayer, color: UIColor.white, width: BORDER_WIDTH)
        
    }
    
    
    
    
}
