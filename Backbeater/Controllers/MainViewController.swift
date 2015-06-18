//
//  ViewController.swift
//  Backbeater
//
//  Created by Alina on 2015-06-01.
//

import UIKit

class MainViewController: UIViewController, SidebarDelegate {

    @IBOutlet weak var sidebar: Sidebar!
    @IBOutlet weak var containerView: UIView!
    weak var displayVC:DisplayViewController!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerCenterXConstraint.constant = 0
        setupSidebar()
        setupDisplayViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupSidebar() {
        sidebar.delegate = self
    }
    
    func setupDisplayViewController() {
        displayVC = storyboard?.instantiateViewControllerWithIdentifier("DisplayViewController") as? DisplayViewController
        
        addChildViewController(displayVC)
        displayVC.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        displayVC.view.frame = containerView.bounds
        containerView.insertSubview(displayVC.view, atIndex: 0)
        displayVC.didMoveToParentViewController(self)
        
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
            displayVC?.view.userInteractionEnabled = (currentState == .Collapsed)
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
    

    
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let recognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let leftToRight = (recognizer.velocityInView(view).x > 0)
            let collapsed = currentState == .Collapsed
            return (leftToRight && collapsed) || (!leftToRight && !collapsed)
        }
        
        return true
    }

    
    @IBAction func didPanContainerView(recognizer: UIPanGestureRecognizer) {
        switch(recognizer.state) {
        case .Began:
            if currentState == .Collapsed  {
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
    
    
    // MARK: SidebarDelegate
    func didTapHelp() {
        // present help
        let helpVC = storyboard?.instantiateViewControllerWithIdentifier("HelpViewController") as! HelpViewController
        self.presentViewController(helpVC, animated: true) {
            self.toggleMenuPanel(false)
        }
    }
}

