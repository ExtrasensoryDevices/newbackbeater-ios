//
//  ADVSegmentedControl.swift
//  Mega
//
//  Created by Tope Abayomi on 01/12/2014.
//  Copyright (c) 2014 App Design Vault. All rights reserved.
//

import UIKit

@IBDesignable class ADVSegmentedControl: UIControl {
    
    private var labels = [UILabel]()
    var thumbView = UIView()
    
    var items: [String] = ["2", "4", "8", "16"] {
        didSet {
            setupLabels()
        }
    }
    
    var selectedIndex : Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }
    
    @IBInspectable var selectedLabelColor : UIColor = ColorPalette.Pink.color() {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable var unselectedLabelColor : UIColor = UIColor.whiteColor() {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable var thumbColor : UIColor = UIColor.whiteColor() {
        didSet {
            setSelectedColors()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
        backgroundColor = UIColor.clearColor()
        
        setupLabels()
        
        insertSubview(thumbView, atIndex: 0)
    }
    
    func setupLabels(){
        
        for label in labels {
            label.removeFromSuperview()
        }
        
        labels.removeAll(keepCapacity: true)
        
        let height = self.frame.height
        
        for index in 0..<items.count {
            
            let label = UILabel(frame: CGRectMake(0, 0, height, height))
            label.text = items[index]
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = .Center
            label.font = label.font.fontWithSize(height - BORDER_WIDTH * 2 - 8)
            label.textColor = index == selectedIndex ? selectedLabelColor : unselectedLabelColor
            label.layer.cornerRadius = height / 2
            label.layer.borderWidth = BORDER_WIDTH
            label.layer.borderColor = unselectedLabelColor.CGColor
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.addSubview(label)
            labels.append(label)
        }
        
        addIndividualItemConstraints(labels, mainView: self, padding: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var selectFrame = self.bounds
        selectFrame.size.width = selectFrame.size.height
        thumbView.frame = selectFrame
        thumbView.backgroundColor = thumbColor
        thumbView.layer.cornerRadius = thumbView.frame.height / 2
        
        displayNewSelectedIndex()
        
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        
        let location = touch.locationInView(self)
        
        var calculatedIndex : Int?
        for (index, item) in enumerate(labels) {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }
        
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActionsForControlEvents(.ValueChanged)
        }
        
        return false
    }
    
    func displayNewSelectedIndex(){
        for (index, item) in enumerate(labels) {
            item.textColor = unselectedLabelColor
        }
        
        var label = labels[selectedIndex]
        label.textColor = selectedLabelColor
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: nil, animations: {
            
            self.thumbView.frame = label.frame
            
            }, completion: nil)
    }
    
    func addIndividualItemConstraints(items: [UIView], mainView: UIView, padding: CGFloat) {
        
        let constraints = mainView.constraints()
        
        for (index, button) in enumerate(items) {
            
            println("index: \(index) - \(CGFloat(2*index+2)/CGFloat(items.count+1))")
            var heightConstraint = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: mainView, attribute: .Height, multiplier: 1, constant: 0)
            var ratioConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Height, multiplier: 1, constant: 0)
            var centerVConstraint = NSLayoutConstraint(item: button, attribute: .CenterY, relatedBy: .Equal, toItem: mainView, attribute: .CenterY, multiplier: 1.0, constant: 0)
            let multiplier:CGFloat
            if items.count % 2 == 0 {
                multiplier = CGFloat(4*index+3)/CGFloat(2*items.count+1)
            } else {
                multiplier = CGFloat(2*index+2)/CGFloat(items.count+1)
            }
            var centerHConstraint = NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: mainView, attribute: .CenterX, multiplier: multiplier, constant: 0)
            
            mainView.addConstraints([heightConstraint, ratioConstraint, centerVConstraint, centerHConstraint])
        }
    }
    
    func setSelectedColors(){
        for item in labels {
            item.textColor = unselectedLabelColor
        }
        
        if labels.count > 0 {
            labels[0].textColor = selectedLabelColor
        }
        
        thumbView.backgroundColor = thumbColor
    }
    
}
