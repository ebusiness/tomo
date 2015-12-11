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
        
//        window?.backgroundColor = UIColor.whiteColor()

        if let launchOpts = launchOptions, userInfo = launchOpts[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
            self.application(application, didReceiveRemoteNotification: userInfo)
        }
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
        if let rootvc = window?.rootViewController as? TabBarController{
            application.applicationIconBadgeNumber = rootvc.viewControllers!.reduce(0) { (count, vc ) -> Int in
                if let badgeValue = vc.tabBarItem.badgeValue, badge = Int(badgeValue) {
                    return count + badge
                }
                return count
            }
        }
        
        print("will save time \(NSDate())")
        Defaults["mapLastTimeStamp"] = NSDate()
    }
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {

        let deviceTokenString = String(deviceToken.description.characters.filter {!"<> ".characters.contains($0)})
        let device = UIDevice.currentDevice()

        let param = [
            "os": device.systemName,
            "model": device.model,
            "token": deviceTokenString,
            "version": device.systemVersion
        ]

        AlamofireController.request(.POST, "/device", parameters: param)
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        RemoteNotification.sharedInstance.receiveRemoteNotification(userInfo)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return self.application(application, openURL: url, sourceApplication: nil, annotation: [])
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return URLSchemesController.sharedInstance.handleOpenURL(url)
    }
}

