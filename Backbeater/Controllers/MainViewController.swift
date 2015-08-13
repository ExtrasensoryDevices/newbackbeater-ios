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
    
    var visualEffectView:UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerCenterXConstraint.constant = 0
        self.view.backgroundColor = ColorPalette.Pink.color()
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
        
        
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = displayVC.view.bounds
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
    
    func blurAlpha(position:CGFloat) -> CGFloat {
        return position / centerPanelExpandedOffset
    }
    
    func addBlurView() {
        visualEffectView.alpha = blurAlpha(containerCenterXConstraint.constant)
        displayVC.view.addSubview(visualEffectView)
        
        // fix for iphone 6: not covering all the screen
        visualEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
        displayVC.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[visualEffectView]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: ["visualEffectView":visualEffectView]))
        displayVC.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[visualEffectView]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: ["visualEffectView":visualEffectView]))

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
            if visualEffectView.superview == nil {
                addBlurView()
            }
            animateCenterPanelXPosition(targetPosition: centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .Collapsed
                self.visualEffectView.removeFromSuperview()
                self.visualEffectView.alpha = 0.0
            }
        }
    }
    
    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, animations: {
            let alpha = self.blurAlpha(targetPosition)
            self.visualEffectView.alpha = self.blurAlpha(targetPosition)
            self.containerCenterXConstraint.constant = targetPosition
            self.view.layoutIfNeeded()
        }, completion: completion)
        
//        self.containerCenterXConstraint.constant = targetPosition
//        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
//            self.view.layoutIfNeeded()
//        }, completion: completion)
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
                addBlurView()
            }
        case .Changed:
            let point = recognizer.translationInView(view)
            var newConstant = self.containerCenterXConstraint.constant - point.x
            newConstant = min(0, newConstant)
            containerCenterXConstraint.constant = newConstant
            containerView.setNeedsLayout()
            visualEffectView.alpha = blurAlpha(newConstant)
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
        let helpVC = storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        helpVC.url = HELP_URL
        self.presentViewController(helpVC, animated: true) {
            self.toggleMenuPanel(false)
        }
    }
}

