//
//  Util.swift
//  spot
//
//  Created by 張志華 on 2015/02/04.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

//Util
class Util: NSObject {
    
    class func createViewControllerWithIdentifier(id: String?, storyboardName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        if let id = id {
            return storyboard.instantiateViewControllerWithIdentifier(id) as! UIViewController
        }
        
        return storyboard.instantiateInitialViewController() as! UIViewController
    }
    
    class func createViewWithNibName(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiateWithOwner(self, options: nil)[0] as! UIView
    }
    
    class func changeRootViewController(#from: UIViewController, to: UIViewController) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
    
    class func showWhatsnew(checkVersion: Bool? = true) {
        if checkVersion == true {
            if !Defaults.hasKey("version") || Defaults["version"].string != UIApplication.versionBuild() {
                showWhatsnewAlert()
                Defaults["version"] = UIApplication.versionBuild()
            }
        } else {
            showWhatsnewAlert()
        }
    }
    
    private class func showWhatsnewAlert() {
//        let array = arrayFromPlist("whatsnew")
//        let subTitle = array.componentsJoinedByString("\n")
//        SCLAlertView().showInfo("变更点", subTitle: subTitle, closeButtonTitle: "OK", duration: 0)
    }
    
    class func setupPush() {
        if iOS8() {
            var types: UIUserNotificationType = UIUserNotificationType.Badge |
                UIUserNotificationType.Alert |
                UIUserNotificationType.Sound
            
            var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )
            
            let application = UIApplication.sharedApplication()
            application.registerUserNotificationSettings( settings )
            application.registerForRemoteNotifications()
        } else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(.Alert | .Badge | .Sound);
        }
    }
    
    class func scale() -> CGFloat {
        return UIScreen.mainScreen().scale
    }
    
    // MARK: - SVProgress
    
    class func showTodo() {
//        SVProgressHUD.showInfoWithStatus("TODO", maskType: .Clear)
    }
    
    class func showError(error: NSError) {
        SVProgressHUD.showErrorWithStatus(error.localizedDescription, maskType: .Clear)
    }
    
    class func showInfo(title: String, maskType: SVProgressHUDMaskType = .Clear) {
        SVProgressHUD.showInfoWithStatus(title, maskType: maskType)
    }
    
    class func showSuccess(title: String, maskType: SVProgressHUDMaskType = .None) {
        SVProgressHUD.showSuccessWithStatus(title)
    }
    
    class func showMessage(title: String, maskType: SVProgressHUDMaskType = .Clear) {
        SVProgressHUD.showWithStatus(title, maskType: maskType)
    }
    
    class func showHUD(maskType: SVProgressHUDMaskType = .Clear) {
        SVProgressHUD.showWithMaskType(maskType)
    }
    
    class func dismissHUD() {
        SVProgressHUD.dismiss()
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
    
    class func showLocalNotificationGotSocketEvent(event: SocketEvent) {
        if UIApplication.sharedApplication().applicationState == .Background {
            let notification = UILocalNotification()
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.applicationIconBadgeNumber = 1
            
            switch event {
                
            case .Message:
                if let message = DBController.latestMessage() {
                    notification.alertBody = message.from!.nickName! + " : " + message.content!
                }
                
            case .Announcement:
                notification.alertBody = "現場TOMOからのお知らせ"
                
            default:
                println("todo")
            }
            
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
    }
    
    class func iOS8() -> Bool {
        return systemVersionGreaterThanOrEqualTo("8.0.0")
    }
    
    class func systemVersionGreaterThanOrEqualTo(verison: String) -> Bool {
        switch UIDevice.currentDevice().systemVersion.compare(verison, options: NSStringCompareOptions.NumericSearch) {
        case .OrderedSame, .OrderedDescending:
            return true
        case .OrderedAscending:
            return false
        }
    }
}
extension Util {
    //RGB To Color
    class func UIColorFromRGB(rgbValue: UInt,alpha:CGFloat) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    //重绘纯色图片
    class func coloredImage(image: UIImage, color:UIColor) -> UIImage! {
        let rect = CGRect(origin: CGPointZero, size: image.size)
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        image.drawInRect(rect)
        //CGContextSetRGBFillColor(context, red, green, blue, alpha)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextSetBlendMode(context, kCGBlendModeSourceAtop)
        CGContextFillRect(context, rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    class func changeImageColorForButton(btn:UIButton?,color:UIColor){
        if let image = btn?.imageView?.image {
            let image = Util.coloredImage( image, color: color)
            btn?.setImage(image, forState: .Normal)
        }
    }
    
    //ActionSheet
    class func alertActionSheet(parentvc:UIViewController,optionalDict: Dictionary<String,((UIAlertAction!) -> Void)!>){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        for optional in optionalDict {
            let action = UIAlertAction(title: optional.0, style: .Default, handler: optional.1)
            alertController.addAction(action)
        }
        parentvc.presentViewController(alertController, animated: true, completion: nil)
    }
    
    class func alert(parentvc:UIViewController,title:String,message:String,action:((UIAlertAction!) -> Void)!){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .Destructive, handler: action)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        parentvc.presentViewController(alertController, animated: true, completion: nil)

    }

}
extension UIApplication {
    
    class func appVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
    class func appBuild() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as NSString as String) as! String
    }
    
    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
}

extension String {
    
    func isEmail() -> Bool {
        let regex = NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, count(self))) != nil
    }
    
}
