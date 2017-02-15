//
//  RegViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/01.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyJSON
import WechatKit

final class RegViewController: UIViewController {

    @IBOutlet weak fileprivate var testSegment: UISegmentedControl!
    @IBOutlet weak fileprivate var loginButton: UIButton!
    @IBOutlet weak fileprivate var emailTextField: UITextField!
    @IBOutlet weak fileprivate var passwordTextField: UITextField!
    @IBOutlet weak fileprivate var signInButton: UIButton!

    @IBOutlet weak fileprivate var inputArea: UIView!
    @IBOutlet weak fileprivate var inputAreaBottomSpace: NSLayoutConstraint!
    @IBOutlet weak fileprivate var registerBottomSpace: NSLayoutConstraint!

    override func viewDidLoad() {

        super.viewDidLoad()

        self.setupWechatManager()

        self.setupAppearance()

        self.registerForKeyboardNotifications()

    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: - Internal Methods

extension RegViewController {

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

        // show test login buttons on debug schema
        testSegment.isHidden = true
        #if DEBUG
            testSegment.isHidden = false
        #endif

        // hide all controls on startup
        inputArea.isHidden = false

        if (WechatManager.sharedInstance.isInstalled()) {
            // customize wechat login button
            loginButton.layer.borderColor = UIColor.white.cgColor
            loginButton.layer.borderWidth = 1
            loginButton.layer.cornerRadius = 2
        } else {
            registerBottomSpace.constant = 16
            loginButton.isHidden = true
        }

        // customize email input field
        customizeTextField(textField: emailTextField)
        customizeTextField(textField: passwordTextField)

    }

    fileprivate func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(RegViewController.keyboardWillShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardWillShown(_ notification: NSNotification) {

        guard let info = notification.userInfo else { return }

        if let keyboardHeight = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {

            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.inputAreaBottomSpace.constant = keyboardHeight
                self.view.layoutIfNeeded()
            })
        }
    }

    func keyboardWillBeHidden(_ notification: NSNotification) {

        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.inputAreaBottomSpace.constant = 0
            self.view.layoutIfNeeded()
        })
    }

    fileprivate func changeRootToTab() {
        Util.dismissHUD()
        if me.primaryStation != nil {
//            let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
            Util.changeRootViewController(from: self, to: TabBarController())
        } else {
            let main = Util.createViewControllerWithIdentifier(id: "RecommendView", storyboardName: "Main")
            Util.changeRootViewController(from: self, to: main)
        }
    }
}

// MARK: - Actions login_wechat

extension RegViewController {

    @IBAction func login_wechat(_ sender: Any) {
        WechatManager.sharedInstance.rxCheckAuth()
            .subscribe(onNext: { _ in
                self.signWithOpenid()
            }, onError: { _ in
                self.failure()
            })
    }

    private func signWithOpenid() {
        Router.Signin.WeChat(openid: WechatManager.openid, access_token: WechatManager.accessToken)
            .rxRequest()
            .subscribe(onNext: {
                self.success(res: $0)
            }, onError: { _ in
                self.getWeChatInfo()
            })
    }

    private func getWeChatInfo() {
        WechatManager.sharedInstance.rxGetUserInfo()
            .subscribe(onNext: { userInfo in
                self.registByWechatInfo(userInfo: userInfo)
            })
    }

    private func registByWechatInfo(userInfo: [String : Any]) {
        Router.Signup.WeChat(openid: WechatManager.openid,
                             nickname: userInfo["nickname"] as? String ?? "",
                             gender: userInfo["sex"] as? String,
                             headimgurl: userInfo["headimgurl"] as? String)
            .rxRequest()
            .subscribe(onNext: {
                self.success(res: $0.dictionaryObject!)
            }, onError: { _ in
                self.failure()
            })
    }
}

// MARK: - Actions accountLogin

extension RegViewController {

    @IBAction func accountLogin(_ sender: Any) {
        Router.Signin.Email(email: emailTextField.text!, password: passwordTextField.text!)
            .rxRequest()
            .subscribe(onNext: {
                UserDefaults.standard.set(self.emailTextField.text, forKey: "email")
                UserDefaults.standard.set(self.passwordTextField.text, forKey: "password")

                me = Account($0)
                self.changeRootToTab()
            }, onError: { _ in
                Util.alert(parentvc: self, title: "登录失败", message: "您输入的账号或密码不正确", cancel: "重试")
            })
    }

    @IBAction func releaseResponder(_ sender: Any) {
        self.view.endEditing(true)
    }

}

// MARK: - TextField Delegate

extension RegViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        var email = (self.emailTextField.text ?? "") as NSString
        var password = (self.passwordTextField.text ?? "") as NSString

        if textField == self.emailTextField {
            email = email.replacingCharacters(in: range, with: string).trimmed() as NSString
        }

        if textField == self.passwordTextField {
            password = password.replacingCharacters(in: range, with: string).trimmed() as NSString
        }

        if email.length > 0 && password.length > 0 {
            self.signInButton.isEnabled = true
        } else {
            self.signInButton.isEnabled = false
        }

        return true
    }
}

// MARK: - TestUser Login

extension RegViewController {

    @IBAction func testLogin(_ sender: UISegmentedControl) {

        sender.isUserInteractionEnabled = false
        var id: String!

        switch testSegment.selectedSegmentIndex {
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
            break
        }

        Router.Signin.Test(id: id).response {
            sender.isUserInteractionEnabled = true
            if $0.result.isFailure { return }
            me = Account($0.result.value!)
            self.changeRootToTab()
        }
    }
}

// MARK: - WechatManager
extension RegViewController {

    fileprivate func setupWechatManager() {

        WechatManager.appid = "wx4079dacf73fef72d"
        WechatManager.appSecret = "d4ec5214ea3ac56752ff75692fb88f48"
    }
}

// MARK: - WechatManagerDelegate
extension RegViewController {

    func success(res: Any) {
        me = Account(res)
        self.changeRootToTab()
    }

    fileprivate func failure() {
        self.inputArea.isHidden = false
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.inputArea.alpha = 1
        })
    }
}
