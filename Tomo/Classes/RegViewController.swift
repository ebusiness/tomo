//
//  RegViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/01.
//  Copyright © 2015 e-business. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftyJSON
import UIKit
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

    let disposeBag = DisposeBag()

    override func viewDidLoad() {

        super.viewDidLoad()

        self.setupWechatManager()

        self.registerForRxSwift()

        self.setupAppearance()

        self.registerForKeyboardNotifications()

    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}

// MARK: - RxSwift
extension RegViewController {
    fileprivate func registerForRxSwift() {
        /// emailValid
        let emailValid = self.emailTextField.rx.text.orEmpty.map { !$0.isEmpty && $0.isEmail }.shareReplay(1)

        /// passwordValid
        let passwordValid = self.passwordTextField.rx.text.orEmpty.map { $0.isValidPassword() }.shareReplay(1)

        /// everythingValid
        let everythingValid = Observable.combineLatest(emailValid, passwordValid) { $0 && $1 }.shareReplay(1)

        /// signInButton
        everythingValid.bindTo(self.signInButton.rx.isEnabled).addDisposableTo(self.disposeBag)
    }
}

// MARK: - Internal Methods
extension RegViewController {

    fileprivate func setupAppearance() {
        // show test login buttons on debug schema
        testSegment.isHidden = true
        #if DEBUG
            testSegment.isHidden = false
        #endif

        // hide all controls on startup
        inputArea.isHidden = false

//        if !WechatManager.sharedInstance.isInstalled() {
//            registerBottomSpace.constant = 16
//            loginButton.isHidden = true
//        }

    }

    fileprivate func registerForKeyboardNotifications() {

        NotificationCenter.default.rx
            .notification(.UIKeyboardWillChangeFrame)
//            .takeUntil(rx.methodInvoked(#selector(RegViewController.viewWillDisappear(_:))))
            .subscribe(onNext: { [weak self] notification in
                guard let info = notification.userInfo else { return }
                guard let frameEnd = info[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
                let cgRectValue = frameEnd.cgRectValue

                var constant: CGFloat = 0
                if cgRectValue.origin.y < UIScreen.main.bounds.size.height {
                    constant = cgRectValue.size.height
                }

                var duration = 0.3

                if let keyboardDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
                    duration = keyboardDuration
                }

                UIView.animate(withDuration: duration, animations: { () -> Void in
                    self?.inputAreaBottomSpace.constant = constant
                    self?.view.layoutIfNeeded()
                })
            }).addDisposableTo(self.disposeBag)
    }

    fileprivate func changeRootToTab() {

        Util.dismissHUD()
        let identifier = me.primaryGroup == nil ? "RecommendView" : "TabBarController"
        let viewController = Util.createViewController(storyboardName: "Main", id: identifier)
        Util.changeRootViewController(from: self, to: viewController)
    }
}

// MARK: - Actions login_wechat
extension RegViewController {

    /// WechatManager
    fileprivate func setupWechatManager() {

        WechatManager.appid = WechatAppid
        WechatManager.appSecret = WechatSecret
    }

    @IBAction func login_wechat(_ sender: Any) {
        WechatManager.shared.rxCheckAuth()
            .subscribe(onNext: { _ in
                self.signWithOpenid()
            }, onError: { _ in
                self.failure()
            })
    }

    private func signWithOpenid() {
        Router.Signin.weChat(openid: WechatManager.shared.openid, access_token: WechatManager.shared.accessToken)
            .response { res in
                if res.result.isSuccess {
                    self.success(res: res.result.value!)
                } else {
                    self.getWeChatInfo()
                }
            }
    }

    private func getWeChatInfo() {
        WechatManager.shared.rxGetUserInfo()
            .subscribe(onNext: { userInfo in
                self.registByWechatInfo(userInfo: userInfo)
            })
    }

    private func registByWechatInfo(userInfo: [String: Any]) {
        Router.Signup.weChat(openid: WechatManager.shared.openid,
                             nickname: userInfo["nickname"] as? String ?? "",
                             gender: userInfo["sex"] as? String,
                             headimgurl: userInfo["headimgurl"] as? String)
            .response { res in
                if res.result.isSuccess {
                    self.success(res: res.result.value!)
                } else {
                    self.failure()
                }
            }
    }

    private func success(res: Any) {
        me = Account(res)
        self.changeRootToTab()
    }

    private func failure() {
        self.inputArea.isHidden = false
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.inputArea.alpha = 1
        })
    }
}

// MARK: - Actions accountLogin

extension RegViewController {

    @IBAction func accountLogin(_ sender: Any) {
        Router.Signin.email(email: emailTextField.text!, password: passwordTextField.text!)
            .response { res in
                if res.result.isSuccess {
                    UserDefaults.standard.set(self.emailTextField.text, forKey: "email")
                    UserDefaults.standard.set(self.passwordTextField.text, forKey: "password")

                    me = Account(res.result.value!)
                    self.changeRootToTab()
                } else {
                    Util.alert(parentvc: self, title: "登录失败", message: "您输入的账号或密码不正确", cancel: "重试")
                }
            }
    }

    @IBAction func releaseResponder(_ sender: Any) {
        self.view.endEditing(true)
    }

}

// MARK: - TextField Delegate

extension RegViewController: UITextFieldDelegate {

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

        Router.Signin.test(id: id).response {
            sender.isUserInteractionEnabled = true
            if $0.result.isFailure { return }
            me = Account($0.result.value!)
            self.changeRootToTab()
        }
    }
}
