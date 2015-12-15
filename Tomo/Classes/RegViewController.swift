//
//  RegViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/01.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import SwiftyJSON
import WechatKit

final class RegViewController: BaseViewController {
    
    @IBOutlet weak var testSegment: UISegmentedControl!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var inputArea: UIView!
    @IBOutlet weak var inputAreaBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var registerBottomSpace: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupWechatManager()

        self.setupAppearance()
        
        self.registerForKeyboardNotifications()

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

// MARK: - Internal Methods 

extension RegViewController {
    
    private func setupAppearance() {
        
        func customizeTextField(textField: UITextField) {
            
            // draw a white bottom border
            let border = CALayer()
            let width = CGFloat(1.0)
            border.borderColor = UIColor.whiteColor().CGColor
            border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width: textField.frame.size.width, height: textField.frame.size.height)
            border.borderWidth = width
            textField.layer.addSublayer(border)
            textField.layer.masksToBounds = true
            
            // make placeholder text white
            let attributeString = NSAttributedString(string: textField.placeholder!, attributes: [
                NSForegroundColorAttributeName: UIColor.whiteColor()
                ])
            textField.attributedPlaceholder = attributeString
        }
        
        // show test login buttons on debug schema
        testSegment.hidden = true
        #if DEBUG
            testSegment.hidden = false
        #endif

        if (WechatManager.sharedInstance.isInstalled()) {
            // customize wechat login button
            loginButton.layer.borderColor = UIColor.whiteColor().CGColor
            loginButton.layer.borderWidth = 1
            loginButton.layer.cornerRadius = 2
        } else {
            registerBottomSpace.constant = 16
            loginButton.hidden = true
        }

        // customize email input field
        customizeTextField(emailTextField)
        customizeTextField(passwordTextField)
        
    }
    
    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShown(notification: NSNotification) {
        
        if let info = notification.userInfo {
            
            if let keyboardHeight = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.inputAreaBottomSpace.constant = keyboardHeight
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.inputAreaBottomSpace.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    private func changeRootToTab(){
        Util.dismissHUD()
        if let groups = me.groups where groups.count > 0 {
            let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
            Util.changeRootViewController(from: self, to: tab)
        } else {
            let main = Util.createViewControllerWithIdentifier("RecommendView", storyboardName: "Main")
            Util.changeRootViewController(from: self, to: main)
        }
    }
}

// MARK: - Actions 

extension RegViewController {
    
    @IBAction func login_wechat(sender: AnyObject) {
        
        WechatManager.sharedInstance.checkAuth()
    }
    
    @IBAction func accountLogin(sender: AnyObject) {
        
        let success: JSON -> () = { json in
            
            Defaults["email"] = self.emailTextField.text
            Defaults["password"] = self.passwordTextField.text
            
            if nil != json["id"].string && nil != json["nickName"].string {
                me = UserEntity(json)
                self.changeRootToTab()
            }
        }
        
        let failure: Int -> () = { err in

            let alert = UIAlertController(title: "登录失败", message: "您输入的账号或密码不正确", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "重试", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        Router.SignIn(email: emailTextField.text!, password: passwordTextField.text!).response { ResponseSerializer in
            switch ResponseSerializer.result {
            case .Success(let value):
                success(value)
            case .Failure(let error):
                failure(error.code)
            }
            print(ResponseSerializer.result.value)
        }
        
    }
    
    @IBAction func releaseResponder(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
}

// MARK: - TextField Delegate

extension RegViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var email = (self.emailTextField.text ?? "") as NSString
        var password = (self.passwordTextField.text ?? "") as NSString
        
        if textField == self.emailTextField {
            email = email.stringByReplacingCharactersInRange(range, withString: string).trimmed()
        }
        
        if textField == self.passwordTextField {
            password = password.stringByReplacingCharactersInRange(range, withString: string).trimmed()
        }
        
        if email.length > 0 && password.length > 0 {
            self.signInButton.enabled = true
        } else {
            self.signInButton.enabled = false
        }
        
        return true
    }
}

// MARK: - TestUser Login

extension RegViewController {
    
    @IBAction func testLogin(sender: UISegmentedControl) {
        
        var param = Dictionary<String, String>()
        
        switch testSegment.selectedSegmentIndex
        {
        case 0:
            param["id"] = "55a319577b6eb5a66e91edaa"
        case 1:
            param["id"] = "55a31bc959a1af7373c1d099"
        case 2:
            param["id"] = "55a31c7759a1af7373c1d09e"
        case 3:
            param["id"] = "55a31d0a59a1af7373c1d0a3"
        case 4:
            param["id"] = "55a31dcb59a1af7373c1d0a8"
        case 5:
            param["id"] = "55c86fd3a96768e7609cdf25"
        case 6:
            param["id"] = "55c870e3a96768e7609cdf2a"
        default:
            break;
        }
        
        AlamofireController.request(.GET, "/signin-test", parameters: param, success: { result in
            
            let json = JSON(result)
            
            if nil != json["id"].string && nil != json["nickName"].string {
                me = UserEntity(json)
                self.changeRootToTab()
            }
            
        })
    }
}

// MARK: - WechatManager
extension RegViewController {
    
    private func setupWechatManager() {
        
        WechatManager.appid = "wx4079dacf73fef72d"
        WechatManager.appSecret = "d4ec5214ea3ac56752ff75692fb88f48"
        WechatManager.openid = Defaults["openid"].string
        WechatManager.access_token = Defaults["access_token"].string
        WechatManager.refresh_token = Defaults["refresh_token"].string
        
        WechatManager.sharedInstance.authDelegate = self
    }
}

// MARK: - WechatManagerDelegate
extension RegViewController: WechatManagerAuthDelegate {
    
    func checkIfNeeded(completion: ((res: AnyObject?, errCode: Int?) -> ())) -> Bool {
        let parameters = [
            "type": "wechat",
            "openid": WechatManager.openid,
            "access_token": WechatManager.access_token ,
        ]
        AlamofireController.request(.POST, "/signin-wechat", parameters: parameters, success: { json in
            completion(res: json,errCode: nil)
        }) { errCode in
            completion(res: nil,errCode: errCode)
        }
        return true
    }
    
    func signupIfNeeded(var parameters: [String : AnyObject], completion: ((res: AnyObject) -> ())) {
        
        if let gender = parameters["sex"] as? String where gender == "2" {
            parameters["sex"] = "女"
        } else {
            parameters["sex"] = "男"
        }
        
        AlamofireController.request(.POST, "/signup-wechat", parameters: parameters, success: { userinfo in
            if let userinfo = userinfo as? Dictionary<String, AnyObject> {
                completion(res: userinfo)
            }
        }) { _ in
            self.failure(400)
        }
    }
    
    func success(res: AnyObject) {
        
        Defaults["openid"] = WechatManager.openid
        Defaults["access_token"] = WechatManager.access_token
        Defaults["refresh_token"] = WechatManager.refresh_token
        me = UserEntity(res)
        self.changeRootToTab()
    }
    
    func failure(errCode: Int) {
        self.inputArea.hidden = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.inputArea.alpha = 1
        })
        
    }
}

