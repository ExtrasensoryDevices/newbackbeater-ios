//
//  AppDelegate.swift
//  Backbeater
//
//  Created by Alina on 2015-06-01.
//

import UIKit
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    var updater: Updater!
    var lastUpdateCheck: NSDate!
    
    var lastOpenTime:NSDate!
    let INACTIVE_TIMEOUT:NSTimeInterval = 60 // 1 min
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // play animation
        window?.rootViewController?.view.backgroundColor = ColorPalette.Black.color()
        if let imageView = window?.rootViewController?.view.viewWithTag(1) as? AnimatableImageView {
            imageView.animateWithImage(named: "bblogoanimation5.gif")
        }
        
        // replace root VC
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainViewController") as! UIViewController
        self.delay(2.0, callback: { [unowned self] () -> () in
            UIView.transitionWithView(self.window!, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: { () -> Void in
                self.window?.rootViewController = mainVC
            }, completion: nil)
        })
        
        Fabric.with([Crashlytics()])
        
        setupUpdates()
        setupAppearance()
        
        Fabric.with([Crashlytics()])
        Flurry.setCrashReportingEnabled(false)
        Flurry.startSession(BridgeConstants.FLURRY_API_KEY())
        
        return true
    }
    
    func setupAppearance() {
        let button = UIButton.appearance()
        button.backgroundColor = .clearColor()
        button.tintColor = .whiteColor()
        button.titleLabel?.font = Font.FuturaDemi.get(16)
        button.titleLabel?.textColor = .whiteColor()
        
        let label = UILabel.appearance()
        label.font = Font.FuturaDemi.get(16)
        label.tintColor = .whiteColor()
        label.textColor = .whiteColor()
        
        let textField = UITextField.appearance()
        textField.font = Font.FuturaDemi.get(16)
        textField.tintColor = .whiteColor()
        textField.textColor = .whiteColor()
        
        let barButton = UIBarButtonItem.appearance()
        barButton.setTitleTextAttributes([
            NSFontAttributeName: Font.FuturaDemi.get(16),
            ], forState: .Normal)
    }
    
    func setupUpdates() {
        updater = Updater(plistUrl: PLIST_URL)
        lastUpdateCheck = NSDate()
        updater.checkForUpdate()
    }
    
    
    
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // log event
        Flurry.logEvent(FlurryEvent.APP_CLOSED(), withParameters: ["sessionLength": -lastOpenTime!.timeIntervalSinceNow])
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        if NSDate().timeIntervalSinceDate(lastUpdateCheck) > CHECK_INTERVAL_SECONDS {
            lastUpdateCheck = NSDate()
            updater?.checkForUpdate()
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
 
//        if lastOpenTime == nil || lastOpenTime!.timeIntervalSinceNow > INACTIVE_TIMEOUT {
            // log event
            Flurry.logEvent(FlurryEvent.APP_OPENED())
            lastOpenTime = NSDate()
//        }

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

