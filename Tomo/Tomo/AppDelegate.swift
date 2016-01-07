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

        var rootViewControllerName = "Main"
        var viewIdentifier: String?

        Router.Session().response {

            if $0.result.isSuccess {
                me = UserEntity($0.result.value!)
                if let groups = me.groups where groups.count > 0 {
                    rootViewControllerName = "Tab"
                } else {
                    viewIdentifier = "RecommendView"
                }
            }

            let rootViewController = Util.createViewControllerWithIdentifier(viewIdentifier, storyboardName: rootViewControllerName)
            Util.changeRootViewController(from: (self.window?.rootViewController)!, to: rootViewController)
        }

        if let launchOpts = launchOptions, userInfo = launchOpts[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
            self.application(application, didReceiveRemoteNotification: userInfo)
        }

        // "touch" the LocationControll, so it been initialized here, 
        // cause the didChangeAuthorizationStatus will called at once 
        // after initialization that gonna mass the auth process
        LocationController.shareInstance
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        Defaults["mapLastTimeStamp"] = NSDate()
        guard let rootvc = window?.rootViewController as? TabBarController else { return }
        
        application.applicationIconBadgeNumber = rootvc.viewControllers!.reduce(0) { (count, vc ) -> Int in
            if let badgeValue = vc.tabBarItem.badgeValue, badge = Int(badgeValue) {
                return count + badge
            }
            return count
        }
        
    }
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        Router.Setting.UpdateDevice(deviceToken: deviceToken).request
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

