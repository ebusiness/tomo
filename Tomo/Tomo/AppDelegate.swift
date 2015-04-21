//
//  AppDelegate.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/26.
//  Copyright (c) 2015年 張志華. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var backgroundTask: UIBackgroundTaskIdentifier?
    var backgroundTimer: NSTimer?
    var didShowDisconnectionWarning = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        ApiController.setup()
        
        if Defaults["email"].string != nil && Defaults["shouldAutoLogin"].bool == true {
            let vc = Util.createViewControllerWithIdentifier("LoadingViewController", storyboardName: "Main")
            self.window?.rootViewController = vc
        }
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        backgroundTask = application.beginBackgroundTaskWithExpirationHandler { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.backgroundTimer != nil {
                    self.backgroundTimer!.invalidate()
                    self.backgroundTimer = nil
                }
                
                application.endBackgroundTask(self.backgroundTask!)
                self.backgroundTask = UIBackgroundTaskInvalid
            })
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.backgroundTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("timerUpdate:"), userInfo: nil, repeats: true)
        })
    }
    
    func timerUpdate(timer: NSTimer) {
        let application = UIApplication.sharedApplication()
        
        /*
        #if DEBUG
            println("backgroundTimeRemaining:\(application.backgroundTimeRemaining)")
            
            if application.backgroundTimeRemaining < 60 && !didShowDisconnectionWarning {
                let localNotification = UILocalNotification()
            
                localNotification.alertBody = "还有1分钟掉线"
                localNotification.soundName = UILocalNotificationDefaultSoundName
                application.presentLocalNotificationNow(localNotification)
            
                didShowDisconnectionWarning = true
            }
        #endif
        */
        
        if application.backgroundTimeRemaining < 10 {
            self.backgroundTimer?.invalidate()
            self.backgroundTimer = nil
            
            application.endBackgroundTask(backgroundTask!)
            backgroundTask = UIBackgroundTaskInvalid
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        if backgroundTimer != nil {
            backgroundTimer?.invalidate()
            backgroundTimer = nil
        }
        
        if let backgroundTask = backgroundTask where backgroundTask != UIBackgroundTaskInvalid {
            application.endBackgroundTask(backgroundTask)
            self.backgroundTask = UIBackgroundTaskInvalid
        }
        
        application.applicationIconBadgeNumber = 0
    }
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        
        // <>と" "(空白)を取る
        var characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        var deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String

        ApiController.setDeviceInfo(deviceTokenString, done: { (error) -> Void in
            println("didRegisterForRemoteNotificationsWithDeviceToken")
        })
    }
}

