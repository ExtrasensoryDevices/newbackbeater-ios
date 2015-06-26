//
//  NumericStepper.swift
//  Backbeater
//
//  Created by Alina on 2015-06-22.
//

import UIKit

class NumericStepper: UIControlNibDesignable {

    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelVCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topConstraint:NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint:NSLayoutConstraint!
    
    
    var V_CONSTRAINT_CONSTANT:CGFloat = 0
    let ANIMATION_DURATION = 0.3
    
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
    
    var bgrColor:UIColor! {
        didSet {
            frameView?.backgroundColor = bgrColor
            label?.backgroundColor = bgrColor
        }
    }
    
    
    enum Direction {
        case Up, Down
    }
    
    enum State: Printable {
        case ExpandedUp, ExpandedDown, Collapsed
        
        var description: String {
            switch self {
            case .ExpandedUp    : return "expandedUp"
            case .ExpandedDown  : return "expandedDown"
            case .Collapsed     : return "collapsed"
            }
        }
    }
    
    var currentState = State.Collapsed
    var gestureStarted = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        font = label.font
        self.backgroundColor = UIColor.clearColor()
        self.nibView?.backgroundColor = UIColor.clearColor()
        self.frameView.backgroundColor = bgrColor
        
        V_CONSTRAINT_CONSTANT = (self.bounds.size.height - self.bounds.size.width)/2
        topConstraint.constant = V_CONSTRAINT_CONSTANT
        bottomConstraint.constant = V_CONSTRAINT_CONSTANT
        layoutIfNeeded()
        
        self.frameView.drawBorder()
   }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
    }
    
    
    
    
    var prevPoint:CGPoint!
    var prevPointTimeStamp:NSDate!
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        let touch = touches.first! as! UITouch
        let point = touch.locationInView(self)
        
        if !frameView.frame.contains(point) {
            println("canceled")
            gestureStarted = false
            return
        }
        
        gestureStarted = true
        prevPoint = point
        prevPointTimeStamp = NSDate()
        
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
        if gestureStarted {
            gestureStarted = false
            prevPoint = nil
            prevPointTimeStamp = nil
            collapse()
        }
    }

    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        if gestureStarted {
            gestureStarted = false
            prevPoint = nil
            prevPointTimeStamp = nil
            collapse()
        }
    }
    
    
   
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        if !gestureStarted {
            return
        }
        
        let touch = touches.first! as! UITouch
        let point = touch.locationInView(self)
        let timestamp = NSDate()
        
        let dx = point.x - prevPoint.x
        let dy = point.y - prevPoint.y
        let timeInt = timestamp.timeIntervalSinceDate(prevPointTimeStamp)
        let time = CGFloat(timeInt)
        let velocity = CGPoint(x: dx/time, y: dy/time)
        
        let midY = self.bounds.midY
        
        var coeff:CGFloat = 30
        
        
        println("-------- \(dy) \t \(timeInt) \t \(velocity.y)  \t \(velocity.y/coeff) -----------")
//        println("prevPoint: \(prevPoint.y), point: \(point.y), midY: \(midY)")
//        println("\(prevPoint.y - midY) * \(point.y - midY) = \((prevPoint.y - midY) * (point.y - midY))")
        
        let crossedTheMiddleLine = (prevPoint.y - midY) * (point.y - midY) <= 0
        
        prevPointTimeStamp = timestamp
        prevPoint = point
        
        
        if crossedTheMiddleLine {
//            println("!!!!!!!!!!!!!!!!!! move:crossed !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        } else {
//            println("move: increase counter and return")
            incrementValue(-Int(velocity.y/coeff))
            return
        }
        
        prevPointTimeStamp = timestamp
        prevPoint = point
        


        let expandDirection:Direction
        if currentState == .ExpandedUp && point.y <= midY {
//            println("moveDirection = .Down")
            expandDirection = .Down
        } else if currentState == .ExpandedDown && point.y >= midY {
//            println("moveDirection = .Up")
            expandDirection = .Up
        } else {
//            println("ignore: \(currentState), point: \(point.y)")
            return
        }
        switchState(expandDirection)
    }
    
    func expand(direction:Direction) {
        let constraint = direction == .Up ? topConstraint : bottomConstraint
        let offset: CGFloat = direction == .Up ? V_CONSTRAINT_CONSTANT : -V_CONSTRAINT_CONSTANT
        
        constraint.constant = 0
        self.labelVCenterConstraint.constant = offset/2
        
        UIView.animateWithDuration(ANIMATION_DURATION, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            //self.superview?.layoutIfNeeded()
        }) { (completed:Bool) -> Void in
            println("expanded: \(offset)")
            self.currentState = direction == .Up ? .ExpandedUp : .ExpandedDown
        }
    }
    
    
    func collapse() {
        topConstraint.constant = V_CONSTRAINT_CONSTANT
        bottomConstraint.constant = V_CONSTRAINT_CONSTANT
        labelVCenterConstraint.constant = 0
        
        UIView.animateWithDuration(ANIMATION_DURATION, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            //self.superview?.layoutIfNeeded()
        }) { (completed:Bool) -> Void in
            println("collapsed")
            self.currentState = .Collapsed
        }
    }
    
    func switchState(direction:Direction) {
        let constraint1 = direction == .Up ? topConstraint : bottomConstraint
        let constraint2 = direction == .Up ? bottomConstraint : topConstraint
        
        let offset: CGFloat = direction == .Up ? V_CONSTRAINT_CONSTANT : -V_CONSTRAINT_CONSTANT
        
        constraint1.constant = 0
        constraint2.constant = V_CONSTRAINT_CONSTANT
        
        self.labelVCenterConstraint.constant = offset/2
        
        UIView.animateWithDuration(ANIMATION_DURATION, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }) { (completed:Bool) -> Void in
            println("expanded: \(offset)")
            self.currentState = direction == .Up ? .ExpandedUp : .ExpandedDown
        }

    }
    
    
    func incrementValue(increment:Int) {
        var newValue = value + increment
        newValue = min(MAX_TEMPO, max(MIN_TEMPO, newValue))
        value = newValue
    }
    
    
    
//    
//    func didPanView(gesture: UIPanGestureRecognizer) {
//        switch gesture.state {
//        case .Began:
//            let point = gesture.locationInView(self)
//            gestureStarted = true
//            prevPoint = point
//            
//            let expandDirection:Direction
//            if point.y < self.bounds.midY {
//                expandDirection = .Down
//            } else {
//                expandDirection = .Up
//            }
//            
//            expand(expandDirection)
//        case .Changed:
//            let point = gesture.locationInView(self)
//            
//            let midY = self.bounds.midY
//            
//            println("-------------------")
//            
//            println("prevPoint: \(prevPoint.y), point: \(point.y), midY: \(midY)")
//            println("\(prevPoint.y - midY) * \(point.y - midY) = \((prevPoint.y - midY) * (point.y - midY))")
//            if (prevPoint.y - midY) * (point.y - midY) > 0 {
//                println("move: return")
//                return
//            } else {
//                prevPoint = point
//                println("!!!!!!!!!!!!!!!!!! move:crossed !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
//            }
//            
//            let expandDirection:Direction
//            if currentState == .ExpandedUp && point.y <= midY {
//                println("moveDirection = .Down")
//                expandDirection = .Down
//            } else if currentState == .ExpandedDown && point.y >= midY {
//                println("moveDirection = .Up")
//                expandDirection = .Up
//            } else {
//                println("ignore: \(currentState), point: \(point.y)")
//                return
//            }
//            
//            if (expandDirection == .Down && currentState == .ExpandedUp) || (expandDirection == .Up && currentState == .ExpandedDown){
//                self.switchState(expandDirection)
//            }
//            
//        case .Cancelled, .Ended:
//            gestureStarted = false
//            prevPoint = nil
//            collapse()
//        default:
//            println("~~~~~~~~~~~~~~~~~~~~ default: ~~~~~~~~~~~~")
//        
//        gesture.setTranslation(CGPointZero, inView: gesture.view)
//    }
    
}
