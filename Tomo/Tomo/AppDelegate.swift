//
//  AppDelegate.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/26.
//  Copyright (c) 2015年 張志華. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

var me: UserEntity!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        self.window!.backgroundColor = UIColor.whiteColor()

//        var rootViewControllerName: String!
//
//        Router.Session().response {
//
//            if $0.result.isSuccess {
//                me = UserEntity($0.result.value!)
//                rootViewControllerName = "Tab"
//            } else {
//                rootViewControllerName = "Main"
//            }
//
//            let rootViewController = Util.createViewControllerWithIdentifier(nil, storyboardName: rootViewControllerName)
//            Util.changeRootViewController(from: (self.window?.rootViewController)!, to: rootViewController)
//        }

        AlamofireController.request(.GET, "/session", success: {

            let userInfo = JSON($0)

            if nil != userInfo["id"].string && nil != userInfo["nickName"].string {
                me = UserEntity(userInfo)
                let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
                Util.changeRootViewController(from: (self.window?.rootViewController)!, to: tab)
            }

        }) { _ in
            let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
            Util.changeRootViewController(from: (self.window?.rootViewController)!, to: tab)
        }

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

