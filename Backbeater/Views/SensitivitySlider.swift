//
//  SensitivitySlider.swift
//  Backbeater
//
//  Created by Alina on 2015-06-02.
//

import UIKit

@IBDesignable

class SensitivitySlider: UIControlNibDesignable{

    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var trackView: UIView!
    @IBOutlet weak var thumbView: UIView!
    @IBOutlet weak var thumbLabel: UILabel!
    
    var MIN_VALUE:Int = 0 {
        didSet {
            updateThumb(animated: true)
        }
    }
    var MAX_VALUE:Int = 100 {
        didSet {
            updateThumb(animated: true)
        }
    }
    
    
    var value:Int = 10 {
        didSet {
            if (value != oldValue) {
                self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
                updateThumb(animated: true)
            }
        }
    }
    // TODO ? : var continuousUpdates = true
    
    
    override func setup() {
        setupGestures()
    }
    
    override func layoutSubviews() {
        println("layoutSubviews")
        super.layoutSubviews()
        setupThumb()
    }
    
    func setupThumb() {
        thumbView.setTranslatesAutoresizingMaskIntoConstraints(false)
        var thumbViewFrame = thumbView.bounds
        thumbViewFrame.size.width = thumbViewFrame.size.height
        thumbView.frame = thumbViewFrame
        thumbView.backgroundColor = ColorPalette.Pink.color()
        thumbView.layer.cornerRadius = thumbView.frame.size.height / 2 - BORDER_WIDTH * 1.5
        thumbView.layer.borderWidth = BORDER_WIDTH
        thumbView.layer.borderColor = UIColor.whiteColor().CGColor
        thumbLabel.font = thumbLabel.font.fontWithSize(10)
        updateThumb(animated: false)
        
        println("setupThumb: \(thumbView.center)")
        
        
    }
    


    
    func updateThumb(#animated: Bool) {
        thumbLabel.text = String(value)
        moveThumbCenterToPoint(getCenterPointForValue(), animated: animated)
    }
    
    private func moveThumbCenterToPoint(point:CGPoint, animated: Bool) {
        if thumbView == nil {
            return
        }
        println("move to point: \(point) animated: \(animated)")
        println("\t\t\tb/f: \(thumbView.frame)")
        if animated {
            UIView.animateWithDuration(0.3) {[weak self] in
                self?.thumbView.center = point
            }
        } else {
            thumbView.center = point
        }
        println("\t\t\tafter: \(thumbView.frame)")
    }
    
    private func getCenterPointForValue() -> CGPoint {
        // find the center position of the thumb view on the track
        let thumbOffset = thumbView.frame.width / 2
        let minX = trackView.frame.minX + thumbOffset
        let maxX = trackView.frame.maxX - thumbOffset
        let dX = (maxX - minX) * CGFloat(value) / CGFloat(MAX_VALUE - MIN_VALUE)
        // find x position of the thumb view in the parent view
        let centerX = minX + dX
        return CGPoint(x:centerX, y: trackView.frame.midY)
    }
    
    
    // full track, not taking into account thumb width
    private func getValueForTrackTapPoint(point:CGPoint) -> Int? {
        if point.x >= trackView.frame.minX && point.x <= trackView.frame.maxX {
            let val = (point.x - trackView.frame.minX) * CGFloat(MAX_VALUE - MIN_VALUE) / (trackView.frame.maxX - trackView.frame.minX)
            return Int(round(val))
        }
        return nil
    }
    
    // inner part of the track taking into account thumb width
    private func getValueForThumbCenterPoint(thumbCenterPoint:CGPoint) -> Int? {
        // find the center position of the thumb view on the track
        let thumbOffset = thumbView.frame.width / 2
        let minX = trackView.frame.minX + thumbOffset
        let maxX = trackView.frame.maxX - thumbOffset
        if thumbCenterPoint.x >= minX && thumbCenterPoint.x <= maxX {
            let val = (thumbCenterPoint.x - minX) * CGFloat(MAX_VALUE - MIN_VALUE) / (maxX - minX)
            return Int(round(val))
        }
        return nil
    }
    
    func pointValid(centerPoint:CGPoint) -> Bool {
        let thumbOffset = thumbView.frame.width / 2
        return centerPoint.x >= trackView.frame.minX+thumbOffset && centerPoint.x <= trackView.frame.maxX-thumbOffset
    }
    
    
    
    // MARK: - Gestures
    
    private func setupGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapView:")
        self.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didPanThumbView:")
        thumbView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func didTapView(gestureRecognizer:UITapGestureRecognizer) {
        let tapPoint = gestureRecognizer.locationInView(self)
        if CGRectContainsPoint(leftImage.frame, tapPoint) {
            // left image tapped  - set min value
            value = MIN_VALUE
        } else if CGRectContainsPoint(rightImage.frame, tapPoint) {
            // right image tapped  - set max value
            value = MAX_VALUE
        } else if let val = getValueForTrackTapPoint(tapPoint) {
            value = val
        }
    }

    
    var dragging = true
    var initialValue:Int = 0
    
    func didPanThumbView(gestureRecognizer:UIPanGestureRecognizer) {
        let point = gestureRecognizer.translationInView(self)
        switch gestureRecognizer.state {
        case .Began :
            dragging = true
            initialValue = value
        case .Changed :
            var newCenter = gestureRecognizer.view!.center
            newCenter.x = newCenter.x + point.x
            if pointValid(newCenter) {
                gestureRecognizer.view!.center = newCenter
                if let val = getValueForThumbCenterPoint(newCenter) where val != value {
                    thumbLabel.text = String(val)
                }
            }
        case .Ended :
            dragging = false
            if let val = getValueForThumbCenterPoint(thumbView.center) {
                value = val
            }
        case .Cancelled, .Failed :
            dragging = false
            value = initialValue
        default:
            break
        }
        gestureRecognizer.setTranslation(CGPointZero, inView: self)
    }
    
}
