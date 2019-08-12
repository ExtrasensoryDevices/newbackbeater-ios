//
//  CentralRing.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-07-16.
//

import UIKit
import AVFoundation


protocol CentralRingDelegate: class {
    func centralRingFoundTap(bpm:Float64)
    func centralRingDidDetectFirstTap()
}


class CentralRing: NibDesignable {
    
    weak var delegate: CentralRingDelegate?

    @IBOutlet weak var drumImage: UIImageView!
    @IBOutlet weak var ringView: UIView!
    @IBOutlet weak var cptLabel: UILabel!
    
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
        self.ringView.backgroundColor = UIColor.clear
        
        let fontSize:CGFloat
        switch ScreenUtil.screenSizeClass {
            case .xsmall: fontSize = 140
            case .small:  fontSize = 165
            case .medium: fontSize = 210
            case .large:  fontSize = 220
            case .xlarge: fontSize = 260
        }
        
        UILabel.appearance(whenContainedInInstancesOf: [CentralRing.self]).font = Font.SteelfishRg.get(fontSize)

        initAnimations()
    }
    
    
    func setLastPlayedTempo(tempo:Int) {
       setDisplayTempo(tempo)
    }
    
    func setSound(url:URL) {
        do {
//            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
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
        delegate?.centralRingFoundTap(bpm: figertapBPM);
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
        ringView.layer.masksToBounds = false
        ringView.clipsToBounds = false
    }
    
    
    private func resetBorderSublayer() {
        
        borderSublayer?.removeFromSuperlayer()
        
        let border = CAShapeLayer()
        border.frame = ringView.bounds
        ringView.layer.addSublayer(border)
        ringView.drawBorder(for: border, color: ColorPalette.pink.color, width: BORDER_WIDTH)
        borderSublayer = border
    }
    
    private func resetCptSublayer() {
        cptSublayer?.removeAllAnimations()
        cptSublayer?.removeFromSuperlayer()
        
        let cptLayer = CAShapeLayer()
        cptLayer.frame = ringView.bounds
        cptLayer.strokeColor = ColorPalette.pink.cgColor
        cptLayer.fillColor = ColorPalette.pink.cgColor
        cptLayer.lineWidth = BORDER_WIDTH
        
        let diameter:CGFloat = 15
        let smallCircleFrame = CGRect(x: ringView.bounds.midX-diameter/2, y: -diameter/2+1, width: diameter, height: diameter)
        let path = UIBezierPath(ovalIn: smallCircleFrame)
        cptLayer.path = path.cgPath
        cptLayer.masksToBounds = false
        
        ringView.layer.insertSublayer(cptLayer, above: borderSublayer)
        cptSublayer = cptLayer
    }
    
    private func resetBpmSublayer() {
        bpmSublayer?.removeAllAnimations()
        bpmSublayer?.removeFromSuperlayer()
        
        let bpmLayer = CAShapeLayer()
        bpmLayer.frame = ringView.bounds
        bpmLayer.strokeColor = UIColor.white.cgColor
        bpmLayer.fillColor = UIColor.white.cgColor
        bpmLayer.lineWidth = BORDER_WIDTH
        bpmLayer.opacity = 0.0
        
        let diameter:CGFloat = 15
        let smallCircleFrame = CGRect(x: ringView.bounds.midX-diameter/2, y: -diameter/2+1, width: diameter, height: diameter)
        let path = UIBezierPath(ovalIn: smallCircleFrame)
        bpmLayer.path = path.cgPath
        bpmLayer.masksToBounds = false
        
        ringView.layer.insertSublayer(bpmLayer, above: cptSublayer)
        bpmSublayer = bpmLayer
    }
    private func resetStrikeSublayer() {
        
        strikeSublayer?.removeFromSuperlayer()
        
        let strikeLayer = CAShapeLayer()
        strikeLayer.frame = ringView.bounds
        strikeLayer.opacity = 0.0
        ringView.layer.addSublayer(strikeLayer)
        ringView.drawBorder(for: strikeLayer, color: UIColor.white, width: BORDER_WIDTH)
        strikeSublayer = strikeLayer
    }
}
