//
//  NumericStepper.swift
//  Backbeater
//
//  Created by Alina on 2015-06-22.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

import UIKit

class NumericStepper: UIControlNibDesignable {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelVCenterConstraint: NSLayoutConstraint!
    
    // position in view constraints, passed from outside
    var topConstraint:NSLayoutConstraint!
    var bottomConstraint:NSLayoutConstraint!
    
    
    var originalHeight:CGFloat = 0
    var expandedHeight:CGFloat = 0
    
    var EXPANSION_COEFFICIENT:CGFloat = 109/64
    var ANIMATION_DURATION = 0.3
    
    var font:UIFont! {
        didSet {
            label.font = font
            label.fontSizeToFit()
        }
    }
    
    var value:Int = 0 {
        didSet {
            label.text = "\(value)"
            if oldValue != value {
                sendActionsForControlEvents(UIControlEvents.ValueChanged)
            }
        }
    }
    
    var prevValue:Int?
    
    override var backgroundColor:UIColor! {
        didSet {
            nibView?.backgroundColor = backgroundColor
            label?.backgroundColor = backgroundColor
        }
    }
    
    
    enum Direction {
        case Up, Down
    }
    
    enum State {
        case ExpandedUp, ExpandedDown, Collapsed
    }
    
    var currentState = State.Collapsed
    var gestureStarted = false
    
    
    override func setup() {
        font = label.font
        originalHeight = self.bounds.size.height
        expandedHeight = originalHeight * EXPANSION_COEFFICIENT
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
    }
    
    
    var prevPoint:CGPoint!
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        let touch = touches.first! as! UITouch
        let point = touch.locationInView(self)
        prevPoint = point
        gestureStarted = true
        prevValue = value
        
        let expandDirection:Direction
        if point.y < self.bounds.midY {
            expandDirection = .Down
        } else {
            expandDirection = .Up
        }
        
        expand(expandDirection)
    }
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        gestureStarted = false
        prevValue = nil
        collapse()
    }

    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        let touch = touches.first! as! UITouch
        let point = touch.locationInView(self)
        
        let crossingLine = currentState == .ExpandedUp ? expandedHeight - originalHeight/2 : originalHeight/2
        if (prevPoint.y - crossingLine) * (point.y - crossingLine) > 0 {
            println("move: return")
            return
        } else {
            prevPoint = point
            println("move:crossed")
        }

        let expandDirection:Direction
        if currentState == .ExpandedUp && point.y > crossingLine {
            println("moveDirection = .Down")
            expandDirection = .Down
        } else if currentState == .ExpandedDown && point.y < crossingLine {
            println("moveDirection = .Up")
            expandDirection = .Up
        } else {
            println("ignore")
            return
        }
        
        if (expandDirection == .Down && currentState == .ExpandedUp) || (expandDirection == .Up && currentState == .ExpandedDown){
            self.switchState(expandDirection)
        }

        
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        gestureStarted = false
        value = prevValue!
        prevValue = nil
        collapse()
    }
    
    
    func expand(direction:Direction) {
        let constraint = direction == .Up ? topConstraint : bottomConstraint
        let dY = expandedHeight - originalHeight
        let offset: CGFloat = direction == .Up ? dY : -dY
        
        constraint.constant = offset
        self.labelVCenterConstraint.constant = offset/2
        
        UIView.animateWithDuration(ANIMATION_DURATION, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }) { (completed:Bool) -> Void in
            println("expanded: \(offset)")
            self.currentState = direction == .Up ? .ExpandedUp : .ExpandedDown
        }
    }
    
    
    func collapse() {
        topConstraint.constant = 0
        bottomConstraint.constant = 0
        labelVCenterConstraint.constant = 0
        
        UIView.animateWithDuration(ANIMATION_DURATION, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }) { (completed:Bool) -> Void in
            println("collapsed")
            self.currentState = .Collapsed
        }
    }
    
    func switchState(direction:Direction) {
        let constraint1 = direction == .Up ? topConstraint : bottomConstraint
        let constraint2 = direction == .Up ? bottomConstraint : topConstraint
        
        let dY = expandedHeight - originalHeight
        let offset: CGFloat = direction == .Up ? dY : -dY
        
        constraint1.constant = offset
        constraint2.constant = 0
        
        self.labelVCenterConstraint.constant = offset/2
        UIView.animateWithDuration(ANIMATION_DURATION, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }) { (completed:Bool) -> Void in
            println("expanded: \(offset)")
            self.currentState = direction == .Up ? .ExpandedUp : .ExpandedDown
        }

    }
    
}
