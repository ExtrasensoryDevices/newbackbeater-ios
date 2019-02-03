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
    
    
    private var vConstraintConstant:CGFloat = 0
    private let animationDuration = 0.3
    
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
            _value = newValue.normalized(min: Constants.MIN_TEMPO, max: Constants.MAX_TEMPO)
            label.text = "\(_value)"
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
    
    
    private enum Direction {
        case up, down
    }
    
    private enum State: CustomStringConvertible {
        case expandedUp, expandedDown, collapsed
        
        var description: String {
            switch self {
            case .expandedUp    : return "expandedUp"
            case .expandedDown  : return "expandedDown"
            case .collapsed     : return "collapsed"
            }
        }
    }
    
    private var currentState = State.collapsed
    private var gestureStarted = false
    private var gestureMoved = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        font = label.font
        self.backgroundColor = UIColor.clear
        self.frameView.backgroundColor = bgrColor
        
        vConstraintConstant = (self.bounds.size.height - self.bounds.size.width)/2
        topConstraint.constant = vConstraintConstant
        bottomConstraint.constant = vConstraintConstant
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
        self.frameView?.drawBorder(color: borderColor)
        self.label.textColor = labelColor
    }
 

    private var prevPoint:CGPoint!
    private var prevPointTimeStamp:Date!
    private func expand(_ direction:Direction) {
        let constraint = direction == .up ? topConstraint : bottomConstraint
        let offset: CGFloat = direction == .up ? vConstraintConstant : -vConstraintConstant
        
        constraint?.constant = 0
        self.labelVCenterConstraint.constant = offset/2
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
        }) { (completed:Bool) -> Void in
            self.currentState = direction == .up ? .expandedUp : .expandedDown
        }
    }
    
    
    private func collapse() {
        topConstraint.constant = vConstraintConstant
        bottomConstraint.constant = vConstraintConstant
        labelVCenterConstraint.constant = 0
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
        }) { (completed:Bool) -> Void in
            self.currentState = .collapsed
        }
    }
    
    private func switchState(_ direction:Direction) {
        let constraint1 = direction == .up ? topConstraint : bottomConstraint
        let constraint2 = direction == .up ? bottomConstraint : topConstraint
        
        let offset: CGFloat = direction == .up ? vConstraintConstant : -vConstraintConstant
        
        constraint1?.constant = 0
        constraint2?.constant = vConstraintConstant
        
        self.labelVCenterConstraint.constant = offset/2
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }) { (completed:Bool) -> Void in
            self.currentState = direction == .up ? .expandedUp : .expandedDown
        }

    }
    
    
    private func incrementValue(_ increment:Int) {
        let newValue = _value + increment
        value = newValue.normalized(min: Constants.MIN_TEMPO, max: Constants.MAX_TEMPO)
    }
    
    
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBAction func didTapView(_ sender: AnyObject) {
        isOn = !isOn
        self.sendActions(for: .touchUpInside)
    }
    
    
    @IBAction func didPanView(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        let velocity = gestureRecognizer.velocity(in: self)
        
        switch gestureRecognizer.state {
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
            sendActions(for: .valueChanged)
        default:
            break;
        }
        
    }
    
    
    private var skipStep = false
    private func getIncrement(_ velocityY:CGFloat) -> Int {
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
