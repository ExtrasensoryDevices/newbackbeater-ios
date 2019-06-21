//
//  CenterRing.swift
//  Backbeater
//
//  Created by Alejandro (idev) on 06/05/2019.
//

import UIKit
import AVFoundation


class CenterRing: NibDesignable {
    
    weak var delegate: CentralRingDelegate?

    @IBOutlet weak var drumImage: UIImageView!
    @IBOutlet weak var gaugeView: GaugeView!
    @IBOutlet weak var cptLabel: UILabel!
    
    @IBOutlet weak var labelBottomConst: NSLayoutConstraint!
    @IBOutlet weak var ringTopConstraint: NSLayoutConstraint!
    
    private var player:AVAudioPlayer?
    
    private var cptSublayer:CAShapeLayer?
    private var bpmSublayer:CAShapeLayer?
    private var strikeSublayer:CAShapeLayer?
    private var borderSublayer:CAShapeLayer?
    
    private var cptAnimation:CABasicAnimation!
    private var bpmAnimation:CAKeyframeAnimation!
    private var strikeAnimation:CAKeyframeAnimation!
    private var pulseAnimation:CABasicAnimation!
    private let pulseDuration:Double = floor(60.0 / Double(Tempo.max) * 10) / 10 / 5  /// FIXME: *10/10 ???
    
    private var drumAnimationImagesLeft:[UIImage] = []
    private var drumAnimationImagesRight:[UIImage] = []
    
    private var metronomeTimer: DispatchSourceTimer?
    
    private struct AnimationKey {
        static let cpt    = "cptAnimation"
        static let bpm    = "bpmAnimation"
        static let strike = "strikeAnimation"
        static let pulse  = "pulseAnimation"
    }
    
    override func setup() {
        super.setup()
        self.backgroundColor = UIColor.clear
        self.gaugeView.backgroundColor = UIColor.clear
        
        let winSize = UIScreen.main.bounds.size
        if (winSize.height / winSize.width) < 2 {
            labelBottomConst.constant = -40
        }
        
        var fontSize:CGFloat
        switch ScreenUtil.screenSizeClass {
            case .xsmall: fontSize = 120
            case .small:  fontSize = 120
            case .medium: fontSize = 170
            case .large:  fontSize = 200
            case .xlarge: fontSize = 240
        }
        fontSize = fontSize/2
        UILabel.appearance(whenContainedInInstancesOf: [CenterRing.self]).font = Font.SteelfishRg.get(fontSize)

        initAnimations()
    }
    
    
    func setLastPlayedTempo(_ tempo: Int) {
       setDisplayTempo(tempo)
    }
    
    func setTempo(_ tempo: Int) {
        gaugeView.tempo = tempo
    }
    
    func setSound(url:URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
        } catch  {
            print(error)
        }
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        resetSublayers()
    }

    func display(cpt:Int, timeSignature: Int, metronomeState:MetronomeState) {
        // display numbers
        setDisplayTempo(cpt)
        var pos = cpt - metronomeState.tempo
        if pos > 4 {
            pos = 4
        }
        else if pos < -4 {
            pos = -4
        }
        gaugeView.bpm = Float(pos + 4) / 8
        
        if pos == 0 {
            self.screenFlash()
        }
        
        if cpt > Tempo.max || cpt < Tempo.min {
            // We do not need BPM outside this range.
            runPulseAnimation()
        } else {
            let cptAnimationDuration = 60.0/(Double(cpt)/Double(timeSignature)) // =60sec/actual_hits_per_min
            let resetCptAnimation:Bool
            if case MetronomeState.off = metronomeState {
                resetCptAnimation = true
            } else {
                resetCptAnimation = false
            }
            runAnimation(resetCptAnimation: resetCptAnimation, cptAnimationDuration: cptAnimationDuration)
        }
    }
    
    
    func handleMetronomeState(_ metronomeState:MetronomeState) {
        
//        metronomeTimer?.cancel()
//        metronomeTimer = nil
        
        switch metronomeState {
        case .on(let metronomeTempo):
            let newDuration = 60.0/Double(metronomeTempo)
            let tempoChanged = cptAnimation.duration != newDuration
            let cptAnimationIsRunning = (cptSublayer?.animationKeys()?.count ?? 0) > 0
            
            // restart metronome if needed
            if metronomeTimer == nil || tempoChanged || !cptAnimationIsRunning {
                
                // reset animation
                cptSublayer?.removeAllAnimations()
                cptAnimation?.duration = newDuration
                cptSublayer?.add(cptAnimation, forKey: AnimationKey.cpt)
                
                // reset timer
                metronomeTimer?.cancel()
                metronomeTimer = nil
            
                let timer = DispatchSource.makeTimerSource()
                timer.schedule(wallDeadline: .now(), repeating:newDuration, leeway: .nanoseconds(5))
                
                timer.setEventHandler{ [weak self] in
                    self?.playSound()
                }
                timer.resume()
                metronomeTimer = timer
            }
            
        case .off:
            // stop metronome
            metronomeTimer?.cancel()
            metronomeTimer = nil
            cptSublayer?.removeAllAnimations()
        }
    }
    
    func stopAnimation() {
        oldTapTime = 0
        newTapTime = 0
        tapCount = 0
        cptSublayer?.removeAllAnimations()
    }
    
    func stopMetronome() {
        metronomeTimer?.cancel()
        metronomeTimer = nil
        stopAnimation()
    }
    
    private func setDisplayTempo(_ cpt: Int) {
        if cpt > Tempo.max || cpt < Tempo.min {
            // We do not need BPM outside this range.
            cptLabel.text = cpt > Tempo.max ? "MAX" : "MIN"
        } else {
            cptLabel.text = "\(cpt)"
        }
    }
    
    
//    deinit {
//        timer?.setEventHandler {}
//        timer?.cancel()
//        /*
//         If the timer is suspended, calling cancel without resuming
//         triggers a crash. This is documented here
//         https://forums.developer.apple.com/thread/15902
//         */
//        resume()
//        eventHandler = nil
//    }
    private func playSound() {
        if let player = self.player  {
            if player.isPlaying {
                player.stop()
                player.currentTime = 0.0
            }
            player.play()
        } else {
            print("Player not found")
        }
    }

    func screenFlash() {
        if let wnd = drumImage {
            var rc = wnd.bounds
            rc.origin.x = (rc.size.width - rc.size.height) / 2.0
            rc.size.width = rc.size.height
            
            let v = UIView(frame: rc)
            v.backgroundColor = UIColor.white
            v.alpha = 0.8
            v.layer.cornerRadius = rc.size.width / 2.0
            
            wnd.addSubview(v)
            UIView.animate(withDuration: 0.5, animations: {
                v.alpha = 0.0
            }, completion: {(finished:Bool) in
                v.removeFromSuperview()
            })
        }
    }


    //MARK: - Tap recognizer
    
    private var newTapTime:UInt64 = 0;
    private var oldTapTime:UInt64 = 0;
    private var tapCount:UInt64 = 0;
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        newTapTime = PublicUtilityWrapper.caHostTimeBase_GetCurrentTime()
        
        let timeElapsedNs:UInt64 = PublicUtilityWrapper.caHostTimeBase_AbsoluteHostDelta(toNanos: newTapTime, oldTapTime: oldTapTime)
        
        let delayFator:Float64 = 0.1
        let timeElapsedInSec:Float64 = Float64(timeElapsedNs) * 10.0e-9 * delayFator;
        
        let isNewTapSeq = (timeElapsedInSec > Coordinator.Constants.idleTimeout) ? true : false
        
        if isNewTapSeq {
            tapCount = 0;
            delegate?.centralRingDidDetectFirstTap()
        } else {
            let figertapBPM = 60.0 / timeElapsedInSec
            self.foundFigertapBPM(figertapBPM)
        }
        
        oldTapTime = newTapTime;
        tapCount += 1;
        
    }
    
    private func foundFigertapBPM(_ figertapBPM: Float64) {
        // apply time signature
        delegate?.centralRingFoundTap(bpm: figertapBPM)
    }
    
    // MARK: - Animation
    
    private let correctHitAngleRad:Float = 0.131
    private func runAnimation(resetCptAnimation: Bool, cptAnimationDuration:Double) {
        
        bpmSublayer?.removeAllAnimations()
        // CPT
        if resetCptAnimation {
            cptSublayer?.removeAllAnimations()
            cptAnimation?.duration = cptAnimationDuration
            cptSublayer?.add(cptAnimation, forKey: AnimationKey.cpt)
        }
        // BPM
        
        let currentRotationAngle = getCurrentRotationRad()
        if currentRotationAngle > -correctHitAngleRad && currentRotationAngle < correctHitAngleRad {
            animateStrike()
        } else {
            runPulseAnimation()
        }
        bpmSublayer?.transform = CATransform3DMakeRotation(CGFloat(currentRotationAngle), 0, 0, 1.0)
        bpmSublayer?.removeAllAnimations()
        bpmSublayer?.add(bpmAnimation, forKey: AnimationKey.bpm)
    }
    
    private func initAnimations() {
        // CPT/metronome rotation
        cptAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        cptAnimation.fromValue = 0
        cptAnimation.toValue = -.pi * 2.0  //   /* full rotation*/ * rotations * duration ];
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
        pulseAnimation.duration = pulseDuration
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
        drumImage?.layer.add(pulseAnimation, forKey: AnimationKey.pulse)
    }
    
    private func animateStrike() {
        drumImage.stopAnimating()
        switchDrumAnimation()
        drumImage.startAnimating()
        
        strikeSublayer?.removeAllAnimations()
        strikeSublayer?.add(strikeAnimation, forKey: AnimationKey.strike)
    }
    
    
    private var useDrumAnimationLeft = true
    private func switchDrumAnimation() {
        useDrumAnimationLeft = !useDrumAnimationLeft
        drumImage.animationImages = useDrumAnimationLeft ? drumAnimationImagesLeft : drumAnimationImagesRight
        drumImage.image = drumImage.animationImages!.last
    }
    

    private func getCurrentRotationRad() -> Float {
        return (cptSublayer?.presentation()?.value(forKeyPath: "transform.rotation.z")  as? NSNumber)?.floatValue ?? 0
    }
    
    
    /// Reset all sublayers when frame changes
    
    private func resetSublayers() {
        resetBorderSublayer()
        resetCptSublayer()
        resetBpmSublayer()
        resetStrikeSublayer()
    }
    
    
    private func resetBorderSublayer() {
    }
    
    private func resetCptSublayer() {
       
    }
    
    private func resetBpmSublayer() {

    }
    private func resetStrikeSublayer() {

    }
}
