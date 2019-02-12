//
//  AppDelegate.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2019-01-01.
//  Copyright © 2019 Alina Kholcheva. All rights reserved.
//

import UIKit
import Gifu
import Flurry_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var lastOpenTime:Date!
    let INACTIVE_TIMEOUT:TimeInterval = 60 // 1 min
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // play animation
        window?.rootViewController?.view.backgroundColor = ColorPalette.black.color
        if let imageView = window?.rootViewController?.view.viewWithTag(1) as? GIFImageView {
            imageView.animate(withGIFNamed: "bblogoanimation5.gif")
        }
        
        // replace root VC
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController")
        self.delay(2.0, callback: { [unowned self] () -> () in
            UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromLeft, animations: { () -> Void in
                self.window?.rootViewController = mainVC
            }, completion: nil)
        })
        
        setupAppearance()
        
        let builder = FlurrySessionBuilder.init()
            .withAppVersion(appVersion)
            .withLogLevel(FlurryLogLevelAll)
            .withCrashReporting(true)
            .withSessionContinueSeconds(Int(INACTIVE_TIMEOUT))
        
        Flurry.startSession(FLURRY_API_KEY, with: builder)
        
        application.isIdleTimerDisabled = true

//        NSSetUncaughtExceptionHandler { exception in
//            print(exception)
//            print(exception.callStackSymbols)
//        }
        
        return true
    }
    
    func setupAppearance() {
        let button = UIButton.appearance()
        button.backgroundColor = .clear
        button.tintColor = .white
        button.titleLabel?.font = Font.FuturaDemi.get(16)
        button.titleLabel?.textColor = .white
        
        let label = UILabel.appearance()
        label.font = Font.FuturaDemi.get(16)
        label.tintColor = .white
        label.textColor = .white
        
        let textField = UITextField.appearance()
        textField.font = Font.FuturaDemi.get(16)
        textField.tintColor = .white
        textField.textColor = .white
        
        let barButton = UIBarButtonItem.appearance()
        barButton.setTitleTextAttributes([.font: Font.FuturaDemi.get(16)], for: UIControl.State())
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        // log event
        Flurry.logEvent(.appClosed, params: ["sessionLength": -lastOpenTime!.timeIntervalSinceNow])
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Flurry.logEvent(.appOpened)
        lastOpenTime = Date()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

