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
    
    @IBOutlet weak var thumbLeadingConstraint: NSLayoutConstraint!
    
    var MIN_VALUE:Int = 0 {
        didSet {
            updateThumbPosition(animated: true)
        }
    }
    var MAX_VALUE:Int = 100 {
        didSet {
            updateThumbPosition(animated: true)
        }
    }
    
    
    var value:Int = 0 {
        didSet {
            if (value != oldValue) {
                self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
                updateThumbPosition(animated: true)
            }
        }
    }
    
    override func setup() {
        setupGestures()
        setupThumb()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        setupThumb()
    }
    
    func setupThumb() {
        thumbView.setTranslatesAutoresizingMaskIntoConstraints(false)
        thumbView.backgroundColor = ColorPalette.Pink.color()
        thumbView.layer.cornerRadius = thumbView.frame.size.height / 2 // - BORDER_WIDTH * 1.5
        thumbView.layer.borderWidth = BORDER_WIDTH_THIN
        thumbView.layer.borderColor = UIColor.whiteColor().CGColor
        thumbLabel.font = thumbLabel.font.fontWithSize(10)
        updateThumbPosition(animated: false)
        
    }
    

    private func valueForTrackPointX(pointX:CGFloat) -> Int? {
        let minX = trackView.frame.minX
        let maxX = trackView.frame.maxX
        if pointX >= minX && pointX <= maxX {
            let val = (pointX - minX) * CGFloat(MAX_VALUE - MIN_VALUE) / (maxX - minX)
            return Int(round(val))
        }
        return nil
    }
    
    private func valueForThumbCenterPointX(pointX:CGFloat) -> Int? {
        let thumbHalfWidth = thumbView.frame.width / 2
        let minX = trackView.frame.minX + thumbHalfWidth
        let maxX = trackView.frame.maxX - thumbHalfWidth
        if pointX >= minX && pointX <= maxX {
            let val = (pointX - minX) * CGFloat(MAX_VALUE - MIN_VALUE) / (maxX - minX)
            return Int(round(val))
        }
        return nil
    }
    
    // offset from the left side of the track
    private func thumbOffsetForValue(val:Int) -> CGFloat {
        let trackLength = trackView.frame.size.width
        let trackAvailableSpace = trackLength - thumbView.frame.size.width // thumb should stay fully inside track width
        let thumbOffsetX = (trackAvailableSpace * CGFloat(val)) / 100.0
        return thumbOffsetX
    }
    
    

    
    func updateThumbPosition(#animated: Bool) {
        thumbLabel.text = String(value)
        setThumbOffset(thumbOffsetForValue(self.value), animated: animated)
    }
    
    private func setThumbOffset(offset:CGFloat, animated: Bool) {
        if thumbView == nil {
            return
        }
        thumbLeadingConstraint.constant = offset
        if animated {
            UIView.animateWithDuration(0.3) {[weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
    
    func pointValid(centerPointX:CGFloat) -> Bool {
        let thumbOffset = thumbView.frame.width / 2
        return centerPointX >= trackView.frame.minX+thumbOffset && centerPointX <= trackView.frame.maxX-thumbOffset
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
//        if CGRectContainsPoint(leftImage.frame, tapPoint) {
//            // left image tapped  - set min value
//            value = MIN_VALUE
//        } else if CGRectContainsPoint(rightImage.frame, tapPoint) {
//            // right image tapped  - set max value
//            value = MAX_VALUE
//        } else
            if let val = valueForTrackPointX(tapPoint.x) {
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
            var newCenterX = gestureRecognizer.view!.center.x + point.x
            if pointValid(newCenterX) {
                // do not call self.value:= smth, it will dispatch continuous updates
                // move thumb
                thumbLeadingConstraint.constant += point.x
                // updateLabel
                if let val = valueForThumbCenterPointX(newCenterX) where val != value {
                    thumbLabel.text = String(val)
                }
            }
        case .Ended :
            dragging = false
            if let val = valueForThumbCenterPointX(thumbView.center.x) {
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
