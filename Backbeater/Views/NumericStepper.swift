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
    func expand(direction:Direction) {
        let constraint = direction == .Up ? topConstraint : bottomConstraint
        let offset: CGFloat = direction == .Up ? V_CONSTRAINT_CONSTANT : -V_CONSTRAINT_CONSTANT
        
        constraint.constant = 0
        self.labelVCenterConstraint.constant = offset/2
        
        UIView.animateWithDuration(ANIMATION_DURATION, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
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
    
    
    var skipStep = false
    func getIncrement(velocityY:CGFloat) -> Int {
        var increment = 0
        switch abs(velocityY) {
        case 0..<20     : increment = 0
        case 20..<300   : increment = skipStep ? 0: 1; skipStep = !skipStep
        case 300..<500  : increment = 1
        case 500..<800  : increment = 5
        case 800..<1100 : increment = 10
        case 1100..<1300: increment = 15
        case 1300..<1600: increment = 20
        default      : increment = 25
        }
        increment = velocityY < 0 ? increment : -increment // opposit to move direction
//        println("velocityY: \(abs(velocityY)), \tincrement: \(increment)")
        return increment
    }
    
}
