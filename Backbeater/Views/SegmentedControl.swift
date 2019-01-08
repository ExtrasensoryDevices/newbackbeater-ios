//
//  SegmentedControl.swift
//  Backbeater
//
//  Created by Alina Khgolcheva on 2015-06-02.
//

import UIKit

@IBDesignable class SegmentedControl: UIControl {
    
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
    
    @IBInspectable var selectedLabelColor : UIColor = ColorPalette.pink.color() {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable var unselectedLabelColor : UIColor = UIColor.white {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable var thumbColor : UIColor = UIColor.white {
        didSet {
            setSelectedColors()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
        backgroundColor = UIColor.clear
        
        setupLabels()
        
        insertSubview(thumbView, at: 0)
    }
    
    func setupLabels(){
        
        for label in labels {
            label.removeFromSuperview()
        }
        
        labels.removeAll(keepingCapacity: true)
        
        let height = self.frame.height
        
        for index in 0..<items.count {
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: height, height: height))
            label.text = items[index]
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.font = label.font.withSize(height - BORDER_WIDTH * 2 - 8)
            label.textColor = index == selectedIndex ? selectedLabelColor : unselectedLabelColor
            label.drawBorderWithColor(unselectedLabelColor)
            label.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(label)
            labels.append(label)
        }
        
        addIndividualItemConstraints(labels, mainView: self, padding: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupThumb()
        displayNewSelectedIndex()
    }
    
    func setupThumb() {
        var selectFrame = self.bounds
        selectFrame.size.width = selectFrame.size.height
        thumbView.frame = selectFrame
        thumbView.backgroundColor = thumbColor
        thumbView.layer.cornerRadius = thumbView.frame.height / 2
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        let location = touch.location(in: self)
        
        var calculatedIndex : Int?
        for (index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }
        
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
        }
        
        return false
    }
    
    func displayNewSelectedIndex(){
        labels.forEach{ $0.textColor = unselectedLabelColor }
        
        let label = labels[selectedIndex]
        label.textColor = selectedLabelColor
        
        UIView.animate(withDuration:0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: UIView.AnimationOptions(rawValue: 0), animations: {
            
            self.thumbView.frame = label.frame
            
            }, completion: nil)
    }
    
    func addIndividualItemConstraints(_ items: [UIView], mainView: UIView, padding: CGFloat) {
        
        for (index, button) in items.enumerated() {
            
            let heightConstraint = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: mainView, attribute: .height, multiplier: 1, constant: 0)
            let ratioConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: button, attribute: .height, multiplier: 1, constant: 0)
            let centerVConstraint = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: mainView, attribute: .centerY, multiplier: 1.0, constant: 0)
            let multiplier:CGFloat
            if items.count % 2 == 0 {
                multiplier = CGFloat(4*index+3)/CGFloat(2*items.count+1)
            } else {
                multiplier = CGFloat(2*index+2)/CGFloat(items.count+1)
            }
            let centerHConstraint = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: mainView, attribute: .centerX, multiplier: multiplier, constant: 0)
            
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
