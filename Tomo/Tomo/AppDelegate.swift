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

var me: Account!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        self.window!.backgroundColor = UIColor.whiteColor()

        var rootViewController: UIViewController!

        // check the session see whether I'm logged in
        Router.Session().response {

            // I'm already logged in
            if $0.result.isSuccess {

                // populate my accout model
                me = Account($0.result.value!)

                // if I don't have primary station, take me to the primary station select view
                if me.primaryStation != nil {
                    rootViewController = TabBarController()
                } else {
                    rootViewController = Util.createViewControllerWithIdentifier("RecommendView", storyboardName: "Main")
                }

            // I'm not log in yet, take me to the sign-in view
            } else {
                rootViewController = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
            }

            Util.changeRootViewController(from: (self.window?.rootViewController)!, to: rootViewController)
        }

        // the application was start up from notification
        if let launchOpts = launchOptions, userInfo = launchOpts[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
            self.application(application, didReceiveRemoteNotification: userInfo)
        }

        // "touch" the LocationControll, so it been initialized here, 
        // cause the didChangeAuthorizationStatus will called at once 
        // after initialization that gonna mess the auth process
        LocationController.shareInstance
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {

        Defaults["mapLastTimeStamp"] = NSDate()

        // check if the rootViewController is the TabBarController (it will not when the app go background for wechat login)
        if let rootvc = self.window?.rootViewController as? TabBarController {

            // update the application icon badge before entering background
            application.applicationIconBadgeNumber = rootvc.viewControllers!.reduce(0) { (count, vc ) -> Int in
                if let badgeValue = vc.tabBarItem.badgeValue, badge = Int(badgeValue) {
                    return count + badge
                }
                return count
            }
        }

    }
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        Router.Setting.UpdateDevice(deviceToken: deviceToken).request
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
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

