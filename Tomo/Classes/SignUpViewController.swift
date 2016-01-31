//
//  SignUpViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/08/25.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputAreaHeight: NSLayoutConstraint!

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

        self.registerForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

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

        inputAreaHeight.constant = UIScreen.mainScreen().bounds.height

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

    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWillShown(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        guard let keyboardHeight = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height else { return }
        
        var duration = 0.3
        
        if let keyboardDuration = info[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            duration = keyboardDuration
        }
        
        self.scrollViewBottomConstraint.constant = keyboardHeight
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    func keyboardWillBeHidden(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        
        self.scrollViewBottomConstraint.constant = 0
        
        var duration = 0.3
        
        if let keyboardDuration = info[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            duration = keyboardDuration
        }
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
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
        
        Router.Signup.Email(email: emailTextField.text!, password: passwordTextField.text!, nickName: nickNameTextField.text!).response {
            
            let buttonTitle = "好"
            var title = "注册失败"
            var message = "您输入的邮件地址已经被使用，请更换其他的邮件地址"
            var handler: ((UIAlertAction!) -> Void)?
            
            if $0.result.isSuccess {
                title = "感谢您注册現場Tomo"
                message = "认证邮件已发送至您的邮箱，请查收。激活您的帐号后即可开始使用現場Tomo"
                handler = { _ in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            Util.alert(self, title: title, message: message, cancel: buttonTitle, cancelHandler: handler)
        }
        
    }
    @IBAction func agreement(sender: UIButton) {
        let agreementView = Util.createViewControllerWithIdentifier("AgreementView", storyboardName: "Setting")
        self.presentViewController(agreementView, animated: true, completion: nil)
    }
}

// MARK: - TextField Delegate

extension SignUpViewController: UITextFieldDelegate {

    @IBAction func textFieldTouchedUp(sender: UITextField) {
        self.scrollView.scrollRectToVisible(sender.frame, animated: true)
    }

    @IBAction func textFieldDidChange(sender: UITextField) {
        
        if sender == self.nickNameTextField {
            
            let nickName = self.nickNameTextField.text!.trimmed()
            
            if nickName.length == 0 || nickName.length > 10 {
                nickNameValid = false
                showHintLabel(nickNameHintLabel)
            } else {
                nickNameValid = true
                hideHintLabel(nickNameHintLabel)
            }
        }
        
        if sender == self.emailTextField {
            
            if !self.emailTextField.text!.isEmail() {
                emailValid = false
                showHintLabel(emailHintLabel)
            } else {
                emailValid = true
                hideHintLabel(emailHintLabel)
            }
        }
        
        if sender == self.passwordTextField {
            
            let repass = self.repassTextField.text!
            
            let password = self.passwordTextField.text!
            
            if !password.isValidPassword() {
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
        
        if sender == self.repassTextField {
            
            let password = self.passwordTextField.text
            
            let repass = self.repassTextField.text
            
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
        } else {
            self.signUpButton.enabled = false
        }
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
