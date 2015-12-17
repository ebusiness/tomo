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
            return storyboard.instantiateViewControllerWithIdentifier(id) 
        }
        
        return storyboard.instantiateInitialViewController()!
    }
    
    class func createViewWithNibName(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiateWithOwner(self, options: nil)[0] as! UIView
    }
    
    class func changeRootViewController(from fromVC: UIViewController, to toVC: UIViewController) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        UIView.transitionWithView(appDelegate.window!, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            
            if fromVC.presentingViewController != nil {
                fromVC.dismissViewControllerAnimated(false, completion: { () -> Void in
                    appDelegate.window!.rootViewController = toVC
                })
            } else {
                appDelegate.window!.rootViewController = toVC
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
    
    class func setupPush() {
        let settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: [.Badge, .Alert, .Sound], categories: nil )
        
        let application = UIApplication.sharedApplication()
        application.registerUserNotificationSettings( settings )
        application.registerForRemoteNotifications()
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
        
    class func showLocalNotificationGotSocketEvent(event: ListenerEvent, data: AnyObject) {
        if UIApplication.sharedApplication().applicationState == .Background {
            let notification = UILocalNotification()
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.applicationIconBadgeNumber = 1
            
            switch event {
                
            case .Message:
                fallthrough
                // TODO: - todo
//                if let message = JSON(data)[0] {
//                    notification.alertBody = message.from!.nickName! + " : " + message.content!
//                }
                
            case .Announcement:
                notification.alertBody = "現場TOMOからのお知らせ"
                
            default:
                NSLog("todo")
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
    
    class func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.length != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    class func imageWithColor(rgbValue: UInt, alpha: CGFloat, size: CGSize = CGSizeMake(320, 64)) -> UIImage {
        
        var rect = CGRectZero
        rect.size = size
        
        let color = Util.UIColorFromRGB(rgbValue, alpha: alpha)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    //重绘纯色图片
    class func coloredImage(image: UIImage, color:UIColor) -> UIImage! {
        let rect = CGRect(origin: CGPointZero, size: image.size)
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        image.drawInRect(rect)
        //CGContextSetRGBFillColor(context, red, green, blue, alpha)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextSetBlendMode(context, CGBlendMode.SourceAtop)//kCGBlendModeSourceAtop
        CGContextFillRect(context, rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    class func changeImageColorForButton(btn:UIButton?,color:UIColor){
        if let image = btn?.imageView?.image {
            gcd.async(.Default) {
                let image = Util.coloredImage( image, color: color)
                gcd.sync(.Main) {
                    btn?.setImage(image, forState: .Normal)
                }
            }
        }
    }
    
    //ActionSheet
    class func alertActionSheet(parentvc: UIViewController, optionalDict: Dictionary<String,((UIAlertAction!) -> Void)!>){
        
        gcd.async(.Default) {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            for optional in optionalDict {
                let action = UIAlertAction(title: optional.0, style: .Default, handler: optional.1)
                alertController.addAction(action)
            }
            gcd.sync(.Main) {
                parentvc.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    class func alert(parentvc: UIViewController, title: String, message: String, cancel: String = "取消",ok: String = "确定", cancelHandler:((UIAlertAction!) -> Void)? = nil, okHandler:((UIAlertAction!) -> Void)? = nil){
        gcd.async(.Default) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: cancel, style: .Cancel, handler: cancelHandler)
            alertController.addAction(cancelAction)
            
            if let okHandler = okHandler {
                let okAction = UIAlertAction(title: ok, style: .Destructive, handler: okHandler)
                alertController.addAction(okAction)
            }
            
            gcd.sync(.Main) {
                parentvc.presentViewController(alertController, animated: true, completion: nil)
            }
        }

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
        do {
            return try self =~ "^[a-zA-Z0-9\\._%+-]+@[a-zA-Z0-9\\.-]+\\.[a-zA-Z]{2,4}$"
        } catch {
            return false
        }
    }
    
    func isValidPassword() -> Bool {
        do {
            return try self =~ "(?=^.{8,}$)(?=.*\\d)(?![.\\n])(?=.*[A-Z])(?=.*[a-z]).*$"
        } catch {
            return false
        }
    }
}

extension UIImageView {
    var roundedCorner: Bool {
        set {
            if newValue == true {
                let radius = min(bounds.width, bounds.height) / 2.0
                layer.cornerRadius = radius
                layer.masksToBounds = true
            } else {
                layer.cornerRadius = 0
                layer.masksToBounds = false
            }
        }
        get {
            return layer.masksToBounds == true && layer.cornerRadius == min(bounds.width, bounds.height) / 2.0
        }
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension CGFloat {
    static var almostZero: CGFloat {
        return 0.00001
    }
}
