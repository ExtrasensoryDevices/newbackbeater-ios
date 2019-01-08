//
//  ViewController.swift
//  Backbeater
//
//  Created by Alina Khgolcheva on 2015-06-01.
//

import UIKit

class MainViewController: UIViewController, SidebarDelegate {

    @IBOutlet weak var sidebar: Sidebar!
    @IBOutlet weak var containerView: UIView!
    private weak var displayVC:DisplayViewController!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    private var visualEffectView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerCenterXConstraint.constant = 0
        self.view.backgroundColor = ColorPalette.pink.color()
        setupSidebar()
        setupDisplayViewController()
    }
    
    func setupSidebar() {
        sidebar.delegate = self
    }
    
    func setupDisplayViewController() {
        guard let displayVC = storyboard?.instantiateViewController(withIdentifier: "DisplayViewController") as? DisplayViewController else {
            fatalError("DisplayViewController not found")
        }
        
        addChild(displayVC)
        displayVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        displayVC.view.frame = containerView.bounds
        containerView.insertSubview(displayVC.view, at: 0)
        displayVC.didMove(toParent: self)
        
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView!.frame = displayVC.view.bounds
    }
    
    
    
    
    // MARK: - toggle menu
    @IBOutlet weak var containerCenterXConstraint: NSLayoutConstraint!
    
    let centerPanelExpandedOffset: CGFloat = -260.0
    
    enum MenuPanelState {
        case collapsed
        case expanded
    }
    
    var currentState: MenuPanelState = .collapsed {
        didSet {
            showShadow(currentState == .expanded)
            settingsButton.isSelected = (currentState == .expanded)
            displayVC?.view.isUserInteractionEnabled = (currentState == .collapsed)
        }
    }
    
    func showShadow(_ shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            containerView.layer.shadowOpacity = 0.8
        } else {
            containerView.layer.shadowOpacity = 0.0
        }
    }
    
    func blurAlpha(_ position:CGFloat) -> CGFloat {
        return position / centerPanelExpandedOffset
    }
    
    func slideDuration(_ currentPosition:CGFloat) -> TimeInterval {
        let coeff: CGFloat
        if centerPanelExpandedOffset == currentPosition {
            coeff = 1
        } else {
            coeff = abs((centerPanelExpandedOffset - currentPosition) / centerPanelExpandedOffset)
        }
        return TimeInterval(0.5 * coeff)
    }
    
    func addBlurView() {
        if let _visualEffectView = visualEffectView {
            _visualEffectView.alpha = blurAlpha(containerCenterXConstraint.constant)
            displayVC.view.addSubview(_visualEffectView)
            
            _visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            displayVC.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[visualEffectView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["visualEffectView":_visualEffectView]))
            displayVC.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[visualEffectView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["visualEffectView":_visualEffectView]))
        }

    }
    
    @IBAction func didTapSettingsButton(_ sender: UIButton) {
        toggleMenuPanel(true)
    }
    
    
    func toggleMenuPanel(_ animateMenuButton: Bool) {
        let newState: MenuPanelState = (currentState == .collapsed) ? .expanded : .collapsed
        animateMenuPanel(newState, animateMenuButton: animateMenuButton)
    }
    
    func animateMenuPanel(_ newState: MenuPanelState, animateMenuButton: Bool) {
        if newState == .expanded {
            currentState = .expanded
            if visualEffectView?.superview == nil {
                addBlurView()
            }
            animateCenterPanelXPosition(centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(0) { finished in
                self.currentState = .collapsed
                self.visualEffectView?.removeFromSuperview()
                self.visualEffectView?.alpha = 0.0
            }
        }
    }
    
    func animateCenterPanelXPosition(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        let currentPosition = self.containerCenterXConstraint.constant
        UIView.animate(withDuration: slideDuration(currentPosition), animations: {
            self.visualEffectView?.alpha = self.blurAlpha(targetPosition)
            self.containerCenterXConstraint.constant = targetPosition
            self.view.layoutIfNeeded()
        }, completion: completion)
    }
    

    
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let recognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let leftToRight = (recognizer.velocity(in: view).x > 0)
            let collapsed = currentState == .collapsed
            return (leftToRight && collapsed) || (!leftToRight && !collapsed)
        }
        return true
    }

    @IBAction func didPanContainerView(_ recognizer: UIPanGestureRecognizer) {
        switch(recognizer.state) {
        case .began:
            if currentState == .collapsed  {
                showShadow(true)
                addBlurView()
            }
        case .changed:
            let point = recognizer.translation(in: view)
            var newConstant = self.containerCenterXConstraint.constant - point.x
            newConstant = min(0, newConstant)
            containerCenterXConstraint.constant = newConstant
            containerView.setNeedsLayout()
            visualEffectView?.alpha = blurAlpha(newConstant)
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        case .ended:
            let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
            animateMenuPanel(hasMovedGreaterThanHalfway ? .expanded : .collapsed, animateMenuButton: true)
        default:
            break
        }
    }
    
    
    // MARK: SidebarDelegate
    func didTapHelp() {
        // present help
        guard let helpVC = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController else {
            fatalError("WebViewController not found")
        }
        helpVC.url = HELP_URL
        self.present(helpVC, animated: true) {
            self.toggleMenuPanel(false)
        }
    }
}

