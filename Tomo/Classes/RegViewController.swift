//
//  RegViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/01.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class RegViewController: BaseViewController {
    
    @IBOutlet weak var testSegment: UISegmentedControl!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var inputArea: UIView!
    @IBOutlet weak var inputAreaBottomSpace: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupAppearance()
        
        self.registerForKeyboardNotifications()
        
        self.tryAutoLogin()
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
        
        // hide all controls on startup
        inputArea.hidden = true
        
        // customize wechat login button
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        loginButton.layer.borderWidth = 1
        loginButton.layer.cornerRadius = 2
        
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
            
            if let keyboardHeight = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                
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
    
    private func tryAutoLogin() {
        
        if Defaults["openid"].string != nil {
            
            Util.showHUD()
            
            OpenidController.instance.wxCheckAuth(
                
                success: { (res) -> () in
                    let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
                    Util.changeRootViewController(from: self, to: tab)
                },
                failure: { (errCode, errMessage) -> () in
                    
                    self.inputArea.hidden = false
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.inputArea.alpha = 1
                    })
            })
            
        } else if Defaults["email"].string != nil && Defaults["password"].string != nil {
            
            Util.showHUD()
            
            var params = [String:String]()
            params["email"] = Defaults["email"].string
            params["password"] = Defaults["password"].string
            
            AlamofireController.request(.POST, "/signin", parameters: params, success: { result in
                let json = JSON(result)
                
                if let id = json["id"].string, nickName = json["nickName"].string {
                    me = UserEntity(json)
                    self.changeRootToTab()
                }
            }) { err in
                self.inputArea.hidden = false
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.inputArea.alpha = 1
                })
                
                let alert = UIAlertController(title: "登录失败", message: "您的账号或密码已经变更，请输入新的账号和密码", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "重试", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            
        } else {
            inputArea.hidden = false
        }
    }
    
    private func changeRootToTab(){
        Util.dismissHUD()
        let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
        Util.changeRootViewController(from: self, to: tab)
    }
}

// MARK: - Actions 

extension RegViewController {
    
    @IBAction func login_wechat(sender: AnyObject) {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.inputArea.alpha = 0
            }) { (_) -> Void in
                self.inputArea.hidden = true
        }
        
        OpenidController.instance.wxCheckAuth(
            success: { (result) -> () in
                self.changeRootToTab()
            },
            failure: { (errCode, errMessage) -> () in
                
                self.inputArea.hidden = false
                UIView.animateWithDuration(0.3) { () -> Void in
                    self.inputArea.alpha = 1
                }
                println(errCode)
                println(errMessage)
        })
    }
    
    @IBAction func accountLogin(sender: AnyObject) {
        
        var params = [String:String]()
        params["email"] = emailTextField.text
        params["password"] = passwordTextField.text
        
        AlamofireController.request(.POST, "/signin", parameters: params, success: { result in
            
            Defaults["email"] = params["email"]
            Defaults["password"] = params["password"]
            
            let json = JSON(result)
            
            if let id = json["id"].string, nickName = json["nickName"].string {
                me = UserEntity(json)
                self.changeRootToTab()
            }
        }) { err in
            
            let alert = UIAlertController(title: "登录失败", message: "您输入的账号或密码不正确", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "重试", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func releaseResponder(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
}

// MARK: - TextField Delegate

extension RegViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var email = self.emailTextField.text as NSString
        var password = self.passwordTextField.text as NSString
        
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
            
            if let id = json["id"].string, nickName = json["nickName"].string {
                me = UserEntity(json)
                self.changeRootToTab()
            }
            
        })
    }
}


