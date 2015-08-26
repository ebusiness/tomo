//
//  SignUpViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/08/25.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var nickNameHintLabel: UILabel!
    var nickNameValid = false
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailHintLabel: UILabel!
    var emailValid = false
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordHintLabel: UILabel!
    var passwordValid = false
    
    @IBOutlet weak var repassTextField: UITextField!
    @IBOutlet weak var repassHintLabel: UILabel!
    var repassValid = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Internal Methods

extension SignUpViewController {
    
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
        
        // customize wechat login button
        signUpButton.layer.borderColor = UIColor.whiteColor().CGColor
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.cornerRadius = 2
        
        // customize email input field
        customizeTextField(nickNameTextField)
        customizeTextField(emailTextField)
        customizeTextField(passwordTextField)
        customizeTextField(repassTextField)
    }
    
    private func showHintLabel(label: UILabel) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            label.alpha = 1.0
        })
    }
    
    private func hideHintLabel(label: UILabel) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            label.alpha = 0.0
        })
    }
}

// MARK: - Actions

extension SignUpViewController {
    
    @IBAction func releaseResponder(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signUp(sender: AnyObject) {
        
        var params = [String:String]()
        params["nickName"] = nickNameTextField.text
        params["email"] = emailTextField.text
        params["password"] = passwordTextField.text
        
        Manager.sharedInstance.request(.POST, kAPIBaseURLString + "/signup" , parameters: params).validate().responseJSON { (_, _, result, error) -> Void in
            
            if error == nil {
                
                let alert = UIAlertController(title: "感谢您注册現場Tomo", message: "认证邮件已发送至您的邮箱，请查收。激活您的帐号后即可开始使用現場Tomo", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
                
            } else {
                
                let alert = UIAlertController(title: "注册失败", message: "您输入的邮件地址已经被使用，请更换其他的邮件地址", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }
}

// MARK: - TextField Delegate

extension SignUpViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.nickNameTextField {
            
            var nickName = self.nickNameTextField.text as NSString
            nickName = nickName.stringByReplacingCharactersInRange(range, withString: string).trimmed()
            
            if nickName.length == 0 || nickName.length > 10 {
                nickNameValid = false
                showHintLabel(nickNameHintLabel)
            } else {
                nickNameValid = true
                hideHintLabel(nickNameHintLabel)
            }
        }
        
        if textField == self.emailTextField {
            
            var email = self.emailTextField.text as NSString
            email = email.stringByReplacingCharactersInRange(range, withString: string)
            
            if !String(email).isEmail() {
                emailValid = false
                showHintLabel(emailHintLabel)
            } else {
                emailValid = true
                hideHintLabel(emailHintLabel)
            }
        }
        
        if textField == self.passwordTextField {
            
            var repass = self.repassTextField.text
            
            var password = self.passwordTextField.text as NSString
            password = password.stringByReplacingCharactersInRange(range, withString: string)
            
            if !String(password).isValidPassword() {
                passwordValid = false
                showHintLabel(passwordHintLabel)
            } else {
                passwordValid = true
                hideHintLabel(passwordHintLabel)
            }
            
            if repass != password {
                repassValid = false
                showHintLabel(repassHintLabel)
            } else {
                repassValid = true
                hideHintLabel(repassHintLabel)
            }
        }
        
        if textField == self.repassTextField {
            
            var password = self.passwordTextField.text
            
            var repass = self.repassTextField.text as NSString
            repass = repass.stringByReplacingCharactersInRange(range, withString: string)
            
            if repass != password {
                repassValid = false
                showHintLabel(repassHintLabel)
            } else {
                repassValid = true
                hideHintLabel(repassHintLabel)
            }
        }
        
        if nickNameValid && emailValid && passwordValid && repassValid {
            self.signUpButton.enabled = true
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let nextTag = textField.tag + 1
        
        if let nextResponder = self.view.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
}
