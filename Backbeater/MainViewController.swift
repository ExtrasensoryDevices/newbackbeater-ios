//
//  ViewController.swift
//  Backbeater
//
//  Created by Alina on 2015-06-01.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    weak var mainView: UIView!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerCenterXConstraint.constant = 0
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: - toggle menu
    @IBOutlet weak var containerCenterXConstraint: NSLayoutConstraint!
    
    let centerPanelExpandedOffset: CGFloat = -260.0
    
    enum MenuPanelState {
        case Collapsed
        case Expanded
    }
    
    var currentState: MenuPanelState = .Collapsed {
        didSet {
            showShadow(currentState == .Expanded)
            settingsButton.selected = (currentState == .Expanded)
            mainView?.userInteractionEnabled = (currentState == .Collapsed)
        }
    }
    
    func showShadow(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            containerView.layer.shadowOpacity = 0.8
        } else {
            containerView.layer.shadowOpacity = 0.0
        }
    }
    
    @IBAction func didTapSettingsButton(sender: UIButton) {
        toggleMenuPanel(true)
    }
    
    
    func toggleMenuPanel(animateMenuButton: Bool) {
        let newState: MenuPanelState = (currentState == .Collapsed) ? .Expanded : .Collapsed
        animateMenuPanel(newState: newState, animateMenuButton: animateMenuButton)
    }
    
    func animateMenuPanel(#newState: MenuPanelState, animateMenuButton: Bool) {
        if newState == .Expanded {
            currentState = .Expanded
            animateCenterPanelXPosition(targetPosition: centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .Collapsed
            }
        }
    }
    
    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, animations: {
            self.containerCenterXConstraint.constant = targetPosition
            self.view.layoutIfNeeded()
        }, completion: completion)
    }
    
    @IBAction func didPanContainerView(recognizer: UIPanGestureRecognizer) {
        switch(recognizer.state) {
        case .Began:
            if (currentState == .Collapsed) {
                showShadow(true)
            }
        case .Changed:
            let point = recognizer.translationInView(view)
            containerCenterXConstraint.constant = self.containerCenterXConstraint.constant - point.x
            containerView.setNeedsLayout()
            recognizer.setTranslation(CGPointZero, inView: recognizer.view)
        case .Ended:
            let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
            animateMenuPanel(newState: hasMovedGreaterThanHalfway ? .Expanded : .Collapsed, animateMenuButton: true)
        default:
            break
        }
    }
    
    
    
}

