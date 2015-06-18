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



    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Crashlytics()])
        
        setupUpdates()
        setupAppearance()
        
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
            NSFontAttributeName: Font.FuturaBook.get(13.0),
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
