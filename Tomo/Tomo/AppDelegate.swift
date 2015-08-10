//
//  AppDelegate.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/26.
//  Copyright (c) 2015年 張志華. All rights reserved.
//

import UIKit

var me = UserEntity()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var backgroundTask: UIBackgroundTaskIdentifier?
    var backgroundTimer: NSTimer?
    var didShowDisconnectionWarning = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window?.backgroundColor = UIColor.whiteColor()
        
        ApiController.setup()
        
        if Defaults["openid"].string != nil {
            let vc = Util.createViewControllerWithIdentifier("LoadingViewController", storyboardName: "Main")
            self.window?.rootViewController = vc
        }
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
//        application.applicationIconBadgeNumber = me.notificationCount
        
    }
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        
        // <>と" "(空白)を取る
        var characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        var deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        if let deviceToken = Defaults["deviceToken"].string where deviceTokenString == deviceToken {
            
        } else {
            Defaults["deviceToken"] = deviceTokenString
            
            var param = Dictionary<String, String>();
            param["name"] = UIDevice.currentDevice().name
            param["token"] = deviceTokenString;
            
            Manager.sharedInstance.request(.POST, kAPIBaseURLString + "/mobile/user/device", parameters: param)

        }
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return self.application(application, openURL: url, sourceApplication: nil, annotation: nil)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return OpenidController.instance.handleOpenURL(url)
    }
}

