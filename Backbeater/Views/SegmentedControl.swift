//
//  SegmentedControl.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-06-02.
//

import UIKit

@IBDesignable class SegmentedControl: UIControl {
    
    private var labels = [UILabel]()
    private var thumbView = UIView()
    
    var items: [String] = [] {
        didSet {
            setupLabels()
        }
    }
    
    var selectedIndex : Int = -1 {
        didSet {
            guard selectedIndex != oldValue else { return }
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
    
    private func setup() {
        backgroundColor = UIColor.clear
        setupLabels()
        insertSubview(thumbView, at: 0)
    }
    
    private func setupLabels(){
        labels.forEach { $0.removeFromSuperview() }
        labels.removeAll(keepingCapacity: true)
        
        let height = self.frame.height
        
        for index in 0..<items.count {
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: height, height: height))
            label.text = items[index]
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.font = label.font.withSize(height - BORDER_WIDTH * 2 - 8)
            label.textColor = index == selectedIndex ? selectedLabelColor : unselectedLabelColor
            label.drawBorder(color: unselectedLabelColor)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            label.tag = index + 1
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLabel(_:))))
            
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
    
    private func setupThumb() {
        var selectFrame = self.bounds
        selectFrame.size.width = selectFrame.size.height
        thumbView.frame = selectFrame
        thumbView.backgroundColor = thumbColor
        thumbView.layer.cornerRadius = thumbView.frame.height / 2
    }
    
    
    @objc func didTapLabel(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        let newIndex = tag - 1
        guard labels.isSafe(index: newIndex) else { return }
        guard selectedIndex != newIndex else { return }
        
        selectedIndex = newIndex
        sendActions(for: .valueChanged)
    }
    
    private func displayNewSelectedIndex(){
        labels.forEach{ $0.textColor = unselectedLabelColor }
        
        let label = labels[selectedIndex]
        label.textColor = selectedLabelColor
        
        UIView.animate(withDuration:0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.8,
                       options: UIView.AnimationOptions(rawValue: 0),
                       animations: { self.thumbView.frame = label.frame },
                       completion: nil)
    }
    
    private func addIndividualItemConstraints(_ items: [UIView], mainView: UIView, padding: CGFloat) {
        
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
    
    private func setSelectedColors(){
        labels.forEach { $0.textColor = unselectedLabelColor }
        labels[safe: 0]?.textColor = selectedLabelColor
        thumbView.backgroundColor = thumbColor
    }
    
}
