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

final class RegViewController: UIViewController {
    
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

        // hide all controls on startup
        inputArea.hidden = false

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
        
        guard let info = notification.userInfo else { return }
        
        if let keyboardHeight = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.inputAreaBottomSpace.constant = keyboardHeight
                self.view.layoutIfNeeded()
            })
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
        if me.primaryStation != nil {
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
        
        Router.Signin.Email(email: emailTextField.text!, password: passwordTextField.text!).response {
            switch $0.result {
            case .Success(let value):
                
                Defaults["email"] = self.emailTextField.text
                Defaults["password"] = self.passwordTextField.text
                
                me = Account(value)
                self.changeRootToTab()
                
            case .Failure:
                
                Util.alert(self, title: "登录失败", message: "您输入的账号或密码不正确", cancel: "重试")
            }
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
        
        sender.userInteractionEnabled = false
        var id: String!
        
        switch testSegment.selectedSegmentIndex
        {
        case 0:
            id = "55a319577b6eb5a66e91edaa"
        case 1:
            id = "55a31bc959a1af7373c1d099"
        case 2:
            id = "55a31c7759a1af7373c1d09e"
        case 3:
            id = "55a31d0a59a1af7373c1d0a3"
        case 4:
            id = "55a31dcb59a1af7373c1d0a8"
        case 5:
            id = "55c86fd3a96768e7609cdf25"
        case 6:
            id = "55c870e3a96768e7609cdf2a"
        default:
            break;
        }
        
        Router.Signin.Test(id: id).response {
            sender.userInteractionEnabled = true
            if $0.result.isFailure { return }
            me = Account($0.result.value!)
            self.changeRootToTab()
        }
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
        
        Router.Signin.WeChat(openid: WechatManager.openid, access_token: WechatManager.access_token).response {
            switch $0.result {
            case .Success(let value):
                
                completion(res: value.dictionaryObject, errCode: nil)
                
            case .Failure:
                
                let errCode = $0.response?.statusCode ?? $0.result.error?.code
                completion(res: nil,errCode: errCode )
            }
        }
        return true
    }
    
    func signupIfNeeded(var parameters: [String : AnyObject], completion: ((res: AnyObject) -> ())) {
        
        let wechat = Router.Signup.WeChat(openid: WechatManager.openid, nickname: parameters["nickname"] as? String ?? "", gender: parameters["sex"] as? String, headimgurl: parameters["headimgurl"] as? String)
        
        wechat.response {
            
            if $0.result.isFailure {
                self.failure(400)
            } else {
                completion(res: $0.result.value!.dictionaryObject!)
            }
        }
    }
    
    func success(res: AnyObject) {
        Defaults["openid"] = WechatManager.openid
        Defaults["access_token"] = WechatManager.access_token
        Defaults["refresh_token"] = WechatManager.refresh_token
        me = Account(res)
        self.changeRootToTab()
    }
    
    func failure(errCode: Int) {
        self.inputArea.hidden = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.inputArea.alpha = 1
        })
    }
}

