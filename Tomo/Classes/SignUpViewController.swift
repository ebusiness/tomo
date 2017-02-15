//
//  SignUpViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/08/25.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak fileprivate var scrollView: UIScrollView!

    @IBOutlet weak fileprivate var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var inputAreaHeight: NSLayoutConstraint!

    @IBOutlet weak fileprivate var signUpButton: UIButton!

    @IBOutlet weak fileprivate var nickNameTextField: UITextField!
    @IBOutlet weak fileprivate var nickNameHintLabel: UILabel!
    var nickNameValid = false

    @IBOutlet weak fileprivate var emailTextField: UITextField!
    @IBOutlet weak fileprivate var emailHintLabel: UILabel!
    var emailValid = false

    @IBOutlet weak fileprivate var passwordTextField: UITextField!
    @IBOutlet weak fileprivate var passwordHintLabel: UILabel!
    var passwordValid = false

    @IBOutlet weak fileprivate var repassTextField: UITextField!
    @IBOutlet weak fileprivate var repassHintLabel: UILabel!
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

    override var prefersStatusBarHidden: Bool {
        return true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: - Internal Methods

extension SignUpViewController {

    fileprivate func setupAppearance() {

        func customizeTextField(textField: UITextField) {

            // draw a white bottom border
            let border = CALayer()
            let width = CGFloat(1.0)
            border.borderColor = UIColor.white.cgColor
            border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width: textField.frame.size.width, height: textField.frame.size.height)
            border.borderWidth = width
            textField.layer.addSublayer(border)
            textField.layer.masksToBounds = true

            // make placeholder text white
            let attributeString = NSAttributedString(string: textField.placeholder!, attributes: [
                NSForegroundColorAttributeName: UIColor.white
            ])
            textField.attributedPlaceholder = attributeString
        }

        inputAreaHeight.constant = UIScreen.main.bounds.height

        // customize wechat login button
        signUpButton.layer.borderColor = UIColor.white.cgColor
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.cornerRadius = 2

        // customize email input field
        customizeTextField(textField: nickNameTextField)
        customizeTextField(textField: emailTextField)
        customizeTextField(textField: passwordTextField)
        customizeTextField(textField: repassTextField)
    }

    fileprivate func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardWillShown(_ notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        guard let keyboardHeight = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height else { return }

        var duration = 0.3

        if let keyboardDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            duration = keyboardDuration
        }

        self.scrollViewBottomConstraint.constant = keyboardHeight
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    func keyboardWillBeHidden(_ notification: NSNotification) {
        guard let info = notification.userInfo else { return }

        self.scrollViewBottomConstraint.constant = 0

        var duration = 0.3

        if let keyboardDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            duration = keyboardDuration
        }

        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    fileprivate func showHintLabel(label: UILabel) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            label.alpha = 1.0
        })
    }

    fileprivate func hideHintLabel(label: UILabel) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            label.alpha = 0.0
        })
    }
}

// MARK: - Actions

extension SignUpViewController {

    @IBAction func releaseResponder(_ sender: Any) {
        self.view.endEditing(true)
    }

    @IBAction func cancel(_ sender: Any) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func signUp(_ sender: Any) {

        Router.Signup.Email(email: emailTextField.text!, password: passwordTextField.text!, nickName: nickNameTextField.text!).response {

            let buttonTitle = "好"
            var title = "注册失败"
            var message = "您输入的邮件地址已经被使用，请更换其他的邮件地址"
            var handler: ((UIAlertAction?) -> Void)?

            if $0.result.isSuccess {
                title = "感谢您注册現場Tomo"
                message = "认证邮件已发送至您的邮箱，请查收。激活您的帐号后即可开始使用現場Tomo"
                handler = { _ in
                    self.dismiss(animated: true, completion: nil)
                }
            }
            Util.alert(parentvc: self, title: title, message: message, cancel: buttonTitle, cancelHandler: handler)
        }

    }
    @IBAction func agreement(_ sender: UIButton) {
        let agreementView = Util.createViewControllerWithIdentifier(id: "AgreementView", storyboardName: "Setting")
        self.present(agreementView, animated: true, completion: nil)
    }
}

// MARK: - TextField Delegate

extension SignUpViewController: UITextFieldDelegate {

    @IBAction func textFieldTouchedUp(_ sender: UITextField) {
        self.scrollView.scrollRectToVisible(sender.frame, animated: true)
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {

        if sender == self.nickNameTextField {

            let nickName = self.nickNameTextField.text!.trimmed()

            if nickName.isEmpty || nickName.characters.count > 10 {
                nickNameValid = false
                showHintLabel(label: nickNameHintLabel)
            } else {
                nickNameValid = true
                hideHintLabel(label: nickNameHintLabel)
            }
        }

        if sender == self.emailTextField {

            if !self.emailTextField.text!.isEmail {
                emailValid = false
                showHintLabel(label: emailHintLabel)
            } else {
                emailValid = true
                hideHintLabel(label: emailHintLabel)
            }
        }

        if sender == self.passwordTextField {

            let repass = self.repassTextField.text!

            let password = self.passwordTextField.text!

            if !password.isValidPassword() {
                passwordValid = false
                showHintLabel(label: passwordHintLabel)
            } else {
                passwordValid = true
                hideHintLabel(label: passwordHintLabel)
            }

            if repass != password {
                repassValid = false
                showHintLabel(label: repassHintLabel)
            } else {
                repassValid = true
                hideHintLabel(label: repassHintLabel)
            }
        }

        if sender == self.repassTextField {

            let password = self.passwordTextField.text

            let repass = self.repassTextField.text

            if repass != password {
                repassValid = false
                showHintLabel(label: repassHintLabel)
            } else {
                repassValid = true
                hideHintLabel(label: repassHintLabel)
            }
        }

        if nickNameValid && emailValid && passwordValid && repassValid {
            self.signUpButton.isEnabled = true
        } else {
            self.signUpButton.isEnabled = false
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        let nextTag = textField.tag + 1

        if let nextResponder = self.view.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return false
    }

}
