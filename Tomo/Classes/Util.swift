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
            return storyboard.instantiateViewController(withIdentifier: id) 
        }
        
        return storyboard.instantiateInitialViewController()!
    }
    
    class func createViewWithNibName(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    class func changeRootViewController(from fromVC: UIViewController, to toVC: UIViewController) {
        let appDelegate = UIApplication.shared//.delegate as! AppDelegate
        UIView.transition(with: appDelegate.keyWindow!, duration: 0.4, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
            
            if fromVC.presentingViewController != nil {
                fromVC.dismiss(animated: false, completion: { () -> Void in
                    appDelegate.keyWindow!.rootViewController = toVC
                })
            } else {
                appDelegate.keyWindow!.rootViewController = toVC
            }
            

            }, completion: nil)
    }

    class func setupPush() {
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        
        let application = UIApplication.shared
        application.registerUserNotificationSettings( settings )
        application.registerForRemoteNotifications()
    }
    
    class func showInfo(title: String, maskType: SVProgressHUDMaskType = .clear) {
        SVProgressHUD.showInfo(withStatus: title, maskType: maskType)
    }
    
    class func showHUD(maskType: SVProgressHUDMaskType = .clear) {
        SVProgressHUD.show(with: maskType)
    }
    
    class func dismissHUD() {
        SVProgressHUD.dismiss()
    }

}
extension Util {
    //RGB To Color
    class func UIColorFromRGB(_ rgbValue: UInt,alpha:CGFloat) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    class func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
    
        if (cString.characters.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    class func imageWithColor(rgbValue: UInt, alpha: CGFloat, size: CGSize = CGSize(width: 320, height: 64)) -> UIImage {
        
        var rect = CGRect.zero
        rect.size = size
        
        let color = Util.UIColorFromRGB(rgbValue, alpha: alpha)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext();
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    //重绘纯色图片
    class func coloredImage(image: UIImage, color:UIColor) -> UIImage! {
        let rect = CGRect(origin: CGPoint.zero, size: image.size)
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        image.draw(in: rect)
        //CGContextSetRGBFillColor(context, red, green, blue, alpha)
        context!.setFillColor(color.cgColor)
        context!.setBlendMode(CGBlendMode.sourceAtop)//kCGBlendModeSourceAtop
        context!.fill(rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    class func changeImageColorForButton(btn:UIButton?,color:UIColor){
        guard let image = btn?.imageView?.image else { return }
        gcd.async(.default) {
            let image = Util.coloredImage( image: image, color: color)
            gcd.sync(.main) {
                btn?.setImage(image, for: .normal)
            }
        }
    }
    
    //ActionSheet
    class func alertActionSheet(parentvc: UIViewController, optionalDict: Dictionary<String,((UIAlertAction?) -> Void)?>){
        
        gcd.async(.default) {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            for optional in optionalDict {
                let action = UIAlertAction(title: optional.0, style: .default, handler: optional.1)
                alertController.addAction(action)
            }
            gcd.sync(.main) {
                parentvc.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    class func alert(parentvc: UIViewController, title: String, message: String, cancel: String = "取消",ok: String = "确定", cancelHandler:((UIAlertAction?) -> Void)? = nil, okHandler:((UIAlertAction?) -> Void)? = nil){
        gcd.async(.default) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: cancelHandler)
            alertController.addAction(cancelAction)
            
            if let okHandler = okHandler {
                let okAction = UIAlertAction(title: ok, style: .destructive, handler: okHandler)
                alertController.addAction(okAction)
            }
            
            gcd.sync(.main) {
                parentvc.present(alertController, animated: true, completion: nil)
            }
        }

    }

}
extension UIApplication {
    
    class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as NSString as String) as! String
    }
    
    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        
        return version == build ? "v\(version)" : "v\(version)(\(build))"
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

extension CGFloat {
    static var almostZero: CGFloat {
        return 0.00001
    }
}

extension UIImage {
    /**
     normalizedImage
     
     - returns: UIImage
     */
    func normalizedImage() -> UIImage {
        if self.imageOrientation == .up { return self }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage!
    }
}
