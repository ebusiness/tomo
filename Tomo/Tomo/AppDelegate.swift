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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        self.window!.backgroundColor = UIColor.white

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
                    rootViewController = Util.createViewControllerWithIdentifier(id: "RecommendView", storyboardName: "Main")
                }

            // I'm not log in yet, take me to the sign-in view
            } else {
                rootViewController = Util.createViewControllerWithIdentifier(id: nil, storyboardName: "Main")
            }

            Util.changeRootViewController(from: (self.window?.rootViewController)!, to: rootViewController)
        }

        // the application was start up from notification
        if let launchOpts = launchOptions, let userInfo = launchOpts[UIApplicationLaunchOptionsKey.remoteNotification] as? [NSObject : AnyObject] {
            self.application(application, didReceiveRemoteNotification: userInfo)
        }

        // "touch" the LocationControll, so it been initialized here, 
        // cause the didChangeAuthorizationStatus will called at once 
        // after initialization that gonna mess the auth process
        _ = LocationController.shareInstance
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {

        
        UserDefaults.standard.set(Date(), forKey: "mapLastTimeStamp")

        // check if the rootViewController is the TabBarController (it will not when the app go background for wechat login)
        if let rootvc = self.window?.rootViewController as? TabBarController {

            // update the application icon badge before entering background
            application.applicationIconBadgeNumber = rootvc.viewControllers!.reduce(0) { (count, vc ) -> Int in
                if let badgeValue = vc.tabBarItem.badgeValue, let badge = Int(badgeValue) {
                    return count + badge
                }
                return count
            }
        }

    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Router.Setting.UpdateDevice(deviceToken: deviceToken).request()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        RemoteNotification.sharedInstance.receiveRemoteNotification(userInfo)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return self.application(application, open: url, sourceApplication: nil, annotation: [])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return URLSchemesController.sharedInstance.handleOpenURL(url)
    }
}

