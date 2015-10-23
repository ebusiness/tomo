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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window?.backgroundColor = UIColor.whiteColor()
        
        if let launchOpts = launchOptions, userInfo = launchOpts[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
            self.application(application, didReceiveRemoteNotification: userInfo)
        }
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
        if let rootvc = window?.rootViewController as? TabBarController{
            application.applicationIconBadgeNumber = rootvc.viewControllers!.reduce(0) { (count, vc ) -> Int in
                if let vc = vc as? UIViewController, badgeValue = vc.tabBarItem.badgeValue, badge = badgeValue.toInt() {
                    return count + badge
                }
                return count
            }
        }
        
        println("will save time \(NSDate())")
        Defaults["mapLastTimeStamp"] = NSDate()
    }
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        
        // <>と" "(空白)を取る
        let characterSet = NSCharacterSet( charactersInString: "<>" )
        
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        if let deviceToken = Defaults["deviceToken"].string where deviceTokenString == deviceToken {
            
        } else {
            Defaults["deviceToken"] = deviceTokenString
            
            var param = Dictionary<String, String>();
            param["os"] = UIDevice.currentDevice().systemName
            param["version"] = UIDevice.currentDevice().systemVersion
            param["model"] = UIDevice.currentDevice().model
            param["token"] = deviceTokenString;
            
            AlamofireController.request(.POST, "/device", parameters: param)

        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        RemoteNotification.sharedInstance.receiveRemoteNotification(userInfo)
    }
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
////        {
////            "aps":{
////                "content-available": 1,
////                "alert":"Test",
////                "sound":"default",
////                "badge":0
////            }
////        }
//        println(userInfo)
//        completionHandler(.NewData)
//    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return self.application(application, openURL: url, sourceApplication: nil, annotation: nil)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return URLSchemesController.sharedInstance.handleOpenURL(url)
    }
}

