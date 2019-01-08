//
//  NumericStepper.swift
//  Backbeater
//
//  Created by Alina Khgolcheva on 2015-06-22.
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
            return _value
        }
        set (newValue) {
            if _value != newValue.normalized(min: Constants.MIN_TEMPO, max: Constants.MAX_TEMPO) {
                _value = newValue
                label.text = "\(_value)"
                sendActions(for: UIControl.Event.valueChanged)
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
            updateOnOffState()
        }
    }
    
    
    enum Direction {
        case up, down
    }
    
    enum State: CustomStringConvertible {
        case expandedUp, expandedDown, collapsed
        
        var description: String {
            switch self {
            case .expandedUp    : return "expandedUp"
            case .expandedDown  : return "expandedDown"
            case .collapsed     : return "collapsed"
            }
        }
    }
    
    var currentState = State.collapsed
    var gestureStarted = false
    var gestureMoved = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        font = label.font
        self.backgroundColor = UIColor.clear
        self.frameView.backgroundColor = bgrColor
        
        V_CONSTRAINT_CONSTANT = (self.bounds.size.height - self.bounds.size.width)/2
        topConstraint.constant = V_CONSTRAINT_CONSTANT
        bottomConstraint.constant = V_CONSTRAINT_CONSTANT
        layoutIfNeeded()
        
        updateOnOffState()
        
        frameView.addGestureRecognizer(panGestureRecognizer)
   }
    
    private func updateOnOffState() {
        if isOn {
            setColorForBorder(ColorPalette.pink.color(), labelColor: UIColor.white)
        } else {
            setColorForBorder(ColorPalette.grey.color(), labelColor: ColorPalette.grey.color())
        }
    }
    
    
    private func setColorForBorder(_ borderColor:UIColor, labelColor:UIColor) {
        self.frameView?.drawBorderWithColor(borderColor)
        self.label.textColor = labelColor
    }
    
    
    
    
    
    var prevPoint:CGPoint!
    var prevPointTimeStamp:Date!
    func expand(_ direction:Direction) {
        let constraint = direction == .up ? topConstraint : bottomConstraint
        let offset: CGFloat = direction == .up ? V_CONSTRAINT_CONSTANT : -V_CONSTRAINT_CONSTANT
        
        constraint?.constant = 0
        self.labelVCenterConstraint.constant = offset/2
        
        UIView.animate(withDuration: ANIMATION_DURATION, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
        }) { (completed:Bool) -> Void in
            self.currentState = direction == .up ? .expandedUp : .expandedDown
        }
    }
    
    
    func collapse() {
        topConstraint.constant = V_CONSTRAINT_CONSTANT
        bottomConstraint.constant = V_CONSTRAINT_CONSTANT
        labelVCenterConstraint.constant = 0
        
        UIView.animate(withDuration: ANIMATION_DURATION, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
        }) { (completed:Bool) -> Void in
            self.currentState = .collapsed
        }
    }
    
    func switchState(_ direction:Direction) {
        let constraint1 = direction == .up ? topConstraint : bottomConstraint
        let constraint2 = direction == .up ? bottomConstraint : topConstraint
        
        let offset: CGFloat = direction == .up ? V_CONSTRAINT_CONSTANT : -V_CONSTRAINT_CONSTANT
        
        constraint1?.constant = 0
        constraint2?.constant = V_CONSTRAINT_CONSTANT
        
        self.labelVCenterConstraint.constant = offset/2
        
        UIView.animate(withDuration: ANIMATION_DURATION, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }) { (completed:Bool) -> Void in
            self.currentState = direction == .up ? .expandedUp : .expandedDown
        }

    }
    
    
    func incrementValue(_ increment:Int) {
        let newValue = _value + increment
        value = newValue.normalized(min: Constants.MIN_TEMPO, max: Constants.MAX_TEMPO)
    }
    
    
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBAction func didTapView(_ sender: AnyObject) {
        isOn = !isOn
        self.sendActions(for: UIControl.Event.touchUpInside)
    }
    
    
    @IBAction func didPanView(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self)
        let velocity = gesture.velocity(in: self)
        
        switch gesture.state {
        case .began:
            gestureStarted = true
            prevPoint = point
            
            setColorForBorder(UIColor.white, labelColor: UIColor.white)
            
            let expandDirection:Direction = velocity.y < 0 ? .down : .up
            expand(expandDirection)
        case .changed:
            
            let midY = self.bounds.midY
            
            let crossedTheMiddleLine = (prevPoint.y - midY) * (point.y - midY) <= 0

            prevPoint = point

            if !crossedTheMiddleLine {
                incrementValue(getIncrement(velocity.y))
                return
            }
            // croseed the middle line: switch state
            let expandDirection:Direction
            if currentState == .expandedUp && point.y <= midY {
                expandDirection = .down
            } else if currentState == .expandedDown && point.y >= midY {
                expandDirection = .up
            } else {
                return
            }
            
            self.switchState(expandDirection)
            
        case .cancelled, .ended:
            gestureStarted = false
            prevPoint = nil
            collapse()
            updateOnOffState() 
        default:
            break;
        }
        
    }
    
    
    var skipStep = false
    func getIncrement(_ velocityY:CGFloat) -> Int {
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
        return increment
    }
    
}
