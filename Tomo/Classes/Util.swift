//
//  Util.swift
//  spot
//
//  Created by 張志華 on 2015/02/04.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class Util: NSObject {
    
    class func createViewControllerWithIdentifier(id: String?, storyboardName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        if let id = id {
            return storyboard.instantiateViewControllerWithIdentifier(id) as UIViewController
        }
        
        return storyboard.instantiateInitialViewController() as UIViewController
    }
    
    class func createViewWithNibName(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiateWithOwner(self, options: nil)[0] as UIView
    }
    
    class func changeRootViewController(#from: UIViewController, to: UIViewController) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        UIView.transitionWithView(appDelegate.window!, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            
            if let parent = from.presentingViewController {
                from.dismissViewControllerAnimated(false, completion: { () -> Void in
                    appDelegate.window!.rootViewController = to
                })
            } else {
                appDelegate.window!.rootViewController = to
            }
            

            }, completion: nil)
    }
    
    class func dicFromPlist(name: String) -> NSDictionary {
        let path = NSBundle.mainBundle().pathForResource(name, ofType: "plist")
        return NSDictionary(contentsOfFile: path!)!
    }
    
    class func arrayFromPlist(name: String) -> NSArray {
        let path = NSBundle.mainBundle().pathForResource(name, ofType: "plist")
        return NSArray(contentsOfFile: path!)!
    }
    
    // MARK: - SVProgress
    
    class func showTodo() {
        SVProgressHUD.showInfoWithStatus("TODO", maskType: .Clear)
    }
    
    class func showError(error: NSError) {
        SVProgressHUD.showErrorWithStatus(error.localizedDescription, maskType: .Clear)
    }
    
    
    class func displayDate(date: NSDate?) -> String {
        let now = NSDate()
        
        if let date = date {
            if !date.isToday() {
                return date.toString()
            } else if date.hoursBeforeDate(now) > 0 {
                return "\(date.hoursBeforeDate(now))時"
            } else if date.minutesBeforeDate(now) > 0 {
                return "\(date.minutesBeforeDate(now))分"
            } else {
                return "\(date.seconds())秒"
            }
        }
        
        return ""
    }
}

extension UIApplication {
    
    class func appVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String
    }
    
    class func appBuild() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as NSString) as String
    }
    
    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
}


