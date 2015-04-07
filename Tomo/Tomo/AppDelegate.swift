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
    var backgroundDownloadSessionCompletionHandler: ()?
    var backgroundUploadSessionCompletionHandler: ()?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        ApiController.setup()
        
        return true
    }
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        
        NSLog("[%@ %@]", reflect(self).summary, __FUNCTION__)
        /*
        Store the completion handler.
        */
        if identifier == BackgroundSessionUploadIdentifier {
            self.backgroundUploadSessionCompletionHandler = completionHandler()
        } else if identifier == BackgroundSessionDownloadIdentifier {
            self.backgroundDownloadSessionCompletionHandler = completionHandler()
        }
    }


}

