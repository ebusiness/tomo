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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        ApiController.setup()
        
        if Defaults["email"].string != nil && Defaults["shouldAutoLogin"].bool == true {
            let vc = Util.createViewControllerWithIdentifier("LoadingViewController", storyboardName: "Main")
            self.window?.rootViewController = vc
        }
        
        return true
    }
}

