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
    
    
    private var _value:Int = 0
    
    var value:Int {
        get {
            return isOn ? _value : 0
        }
        set (newValue) {
            if _value != newValue.inBounds(minValue: MIN_TEMPO, maxValue: MAX_TEMPO) {
                _value = newValue
                label.text = "\(_value)"
                sendActionsForControlEvents(UIControlEvents.ValueChanged)
            }
        }
//        didSet {
//            label.text = "\(value)"
//            if oldValue != value {
//                sendActionsForControlEvents(UIControlEvents.ValueChanged)
//            }
//        }
    }
    
    var bgrColor:UIColor! {
        didSet {
            frameView?.backgroundColor = bgrColor
            label?.backgroundColor = bgrColor
        }
    }
    
    var isOn = true {
        didSet {
            switchOnOffState()
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
    var gestureMoved = false
    
    
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
        
        switchOnOffState()
   }
    
    private func switchOnOffState() {
        if isOn {
            self.frameView?.drawBorder()
            frameView.addGestureRecognizer(panGestureRecognizer)
        } else {
            self.frameView?.drawBorderWithColor(ColorPalette.Grey.color())
            frameView.removeGestureRecognizer(panGestureRecognizer)
        }
        self.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }
    
    
    
    
    
    var prevPoint:CGPoint!
    var prevPointTimeStamp:NSDate!
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        super.touchesBegan(touches, withEvent: event)
//        let touch = touches.first! as! UITouch
//        let point = touch.locationInView(self)
//        
//        if !frameView.frame.contains(point) {
//            println("canceled")
//            gestureStarted = false
//            gestureMoved = false
//            return
//        }
//        
//        gestureStarted = true
//        prevPoint = point
//        prevPointTimeStamp = NSDate()
//        
//    }
    
    
//    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
//        super.touchesEnded(touches, withEvent: event)
//        if gestureStarted {
//            if !gestureMoved {
//                // if tap: switch on/off
//                var tapDuration = NSDate().timeIntervalSinceDate(prevPointTimeStamp)
//                tapDuration = Double(round(tapDuration*100)/100)
//                println(NSString(format:"tap duration: %.2f", tapDuration))
//                if tapDuration < 0.2 {
//                    // tap happened
//                    self.isOn = !isOn
//                }
//                gestureMoved = false
//            }
//            gestureStarted = false
//            prevPoint = nil
//            prevPointTimeStamp = nil
//            collapse()
//        }
//    }

//    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
//        super.touchesCancelled(touches, withEvent: event)
//        if gestureStarted {
//            gestureStarted = false
//            gestureMoved = false
//            prevPoint = nil
//            prevPointTimeStamp = nil
//            collapse()
//        }
//    }
    
    
   
//    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
//        super.touchesMoved(touches, withEvent: event)
//        
//        if !isOn || !gestureStarted {
//            return
//        }
//        
//        
//        
//        let touch = touches.first! as! UITouch
//        let point = touch.locationInView(self)
//        let timestamp = NSDate()
//        
//        let dx = point.x - prevPoint.x
//        let dy = point.y - prevPoint.y
//        let timeInt = timestamp.timeIntervalSinceDate(prevPointTimeStamp)
//        let time = CGFloat(timeInt)
//        let velocity = CGPoint(x: dx/time, y: dy/time)
//        
//        let midY = self.bounds.midY
//        
//        var coeff:CGFloat = 30
//        
//        
//        
//        println("-------- \(dy) \t \(timeInt) \t \(velocity.y)  \t \(velocity.y/coeff) -----------")
////        println("prevPoint: \(prevPoint.y), point: \(point.y), midY: \(midY)")
////        println("\(prevPoint.y - midY) * \(point.y - midY) = \((prevPoint.y - midY) * (point.y - midY))")
//        
//        
//        if !gestureMoved && abs(dy) > 0.2 {
//            let expandDirection:Direction
//            if dy < 0 {
//                expandDirection = .Down
//            } else {
//                expandDirection = .Up
//            }
//            gestureMoved = true
//            expand(expandDirection)
//            return
//        }
//        
//        prevPointTimeStamp = timestamp
//        prevPoint = point
//        
//        
//        let crossedTheMiddleLine = (prevPoint.y - midY) * (point.y - midY) <= 0
//
//        if crossedTheMiddleLine {
////            println("!!!!!!!!!!!!!!!!!! move:crossed !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
//        } else {
////            println("move: increase counter and return")
//            incrementValue(-Int(velocity.y/coeff))
//            return
//        }
//        
//        let expandDirection:Direction
//        if currentState == .ExpandedUp && point.y <= midY {
////            println("moveDirection = .Down")
//            expandDirection = .Down
//        } else if currentState == .ExpandedDown && point.y >= midY {
////            println("moveDirection = .Up")
//            expandDirection = .Up
//        } else {
////            println("ignore: \(currentState), point: \(point.y)")
//            return
//        }
//        switchState(expandDirection)
//    }
    
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
        var newValue = _value + increment
        value = newValue.inBounds(minValue: MIN_TEMPO, maxValue: MAX_TEMPO)
    }
    
    
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBAction func didTapView(sender: AnyObject) {
        isOn = !isOn
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            return isOn
        }
        return true
    }
    
    
    @IBAction func didPanView(gesture: UIPanGestureRecognizer) {
        let point = gesture.locationInView(self)
        let velocity = gesture.velocityInView(self)
        
        switch gesture.state {
        case .Began:
            gestureStarted = true
            prevPoint = point
            
            let expandDirection:Direction = velocity.y < 0 ? .Down : .Up
            expand(expandDirection)
        case .Changed:
            
            let midY = self.bounds.midY
            
//            println("-------------------")
//            println("prevPoint: \(prevPoint.y), point: \(point.y), midY: \(midY)")
//            println("\(prevPoint.y - midY) * \(point.y - midY) = \((prevPoint.y - midY) * (point.y - midY))")
            
            let crossedTheMiddleLine = (prevPoint.y - midY) * (point.y - midY) <= 0
            
            prevPoint = point

            if !crossedTheMiddleLine {
                incrementValue(getIncrement(0.0001*velocity.y))
                return
            }
            // croseed the middle line: switch state
            let expandDirection:Direction
            if currentState == .ExpandedUp && point.y <= midY {
                expandDirection = .Down
            } else if currentState == .ExpandedDown && point.y >= midY {
                expandDirection = .Up
            } else {
                return
            }
            
            self.switchState(expandDirection)
            
        case .Cancelled, .Ended:
            gestureStarted = false
            prevPoint = nil
            collapse()
        default:
            break;
        }
        
    }
    
    func getIncrement(velocityY:CGFloat) -> Int {
        var increment = 0
        switch abs(velocityY) {
        case 0..<0.002 : increment = 0
        case 0.002...10 : increment = 1
        case 11...15: increment = 5
        case 16...20: increment = 10
        case 21...25: increment = 15
        case 26...30: increment = 20
        default     : increment = 25
        }
        increment = velocityY < 0 ? increment : -increment // opposit to move direction
        println("velocityY: \(velocityY), \tincrement: \(increment)")
        return increment
    }
    
}
