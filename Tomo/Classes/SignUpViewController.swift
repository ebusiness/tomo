//
//  SignUpViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/08/25.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SignUpViewController: UIViewController {

    @IBOutlet weak fileprivate var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak fileprivate var signUpButton: UIButton!

    @IBOutlet weak fileprivate var nickNameTextField: UITextField!
    @IBOutlet weak fileprivate var nickNameHintLabel: UILabel!

    @IBOutlet weak fileprivate var emailTextField: UITextField!
    @IBOutlet weak fileprivate var emailHintLabel: UILabel!

    @IBOutlet weak fileprivate var passwordTextField: UITextField!
    @IBOutlet weak fileprivate var passwordHintLabel: UILabel!

    @IBOutlet weak fileprivate var repassTextField: UITextField!
    @IBOutlet weak fileprivate var repassHintLabel: UILabel!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {

        super.viewDidLoad()

        self.registerForRxSwift()

        self.registerForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - RxSwift

extension SignUpViewController {
    fileprivate func registerForRxSwift() {
        /// nickNameValid
        let nickNameValid = self.nickNameTextField.rx.text.orEmpty
            .map { !$0.isEmpty && $0.characters.count <= 10 }
            .shareReplay(1)
        nickNameValid.bindTo(self.nickNameHintLabel.rx.isHidden).addDisposableTo(self.disposeBag)

        /// emailValid
        let emailValid = self.emailTextField.rx.text.orEmpty.map { $0.isEmail }.shareReplay(1)
        emailValid.bindTo(self.emailHintLabel.rx.isHidden).addDisposableTo(self.disposeBag)

        /// passwordValid
        let passwordValid = self.passwordTextField.rx.text.orEmpty.map { $0.isValidPassword() }.shareReplay(1)
        passwordValid.bindTo(self.passwordHintLabel.rx.isHidden).addDisposableTo(self.disposeBag)

        /// repassValid
        let repassValid = self.repassTextField.rx.text.orEmpty.map { $0 == self.passwordTextField.text }.shareReplay(1)
        repassValid.bindTo(self.repassHintLabel.rx.isHidden).addDisposableTo(self.disposeBag)

        /// everythingValid
        let everythingValid = Observable
            .combineLatest(nickNameValid, emailValid, passwordValid, repassValid) { $0 && $1 && $2 && $3 }
            .shareReplay(1)
        everythingValid.bindTo(self.signUpButton.rx.isEnabled).addDisposableTo(self.disposeBag)
    }
}

// MARK: - Internal Methods

extension SignUpViewController {

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
                    self?.bottomConstraint.constant = constant
                    self?.view.layoutIfNeeded()
                })
            }).addDisposableTo(self.disposeBag)
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

        // swiftlint:disable:next line_length
        Router.Signup.Email(email: emailTextField.text!, password: passwordTextField.text!, nickName: nickNameTextField.text!)
            .response {
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
