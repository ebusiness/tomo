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
        
        application.applicationIconBadgeNumber = me.notificationCount
        
    }
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        
        // <>と" "(空白)を取る
        var characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        var deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        Defaults["deviceToken"] = deviceTokenString
        
        ApiController.setDeviceInfo(deviceTokenString, done: { (error) -> Void in
            println("didRegisterForRemoteNotificationsWithDeviceToken")
        })
    }
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        //SDK_QQhelper.getCallbakc(url)
        return OpenidController.instance.handleOpenURL(url)
    }
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        //SDK_QQhelper.getCallbakc(url)
        return OpenidController.instance.handleOpenURL(url)
    }
}

