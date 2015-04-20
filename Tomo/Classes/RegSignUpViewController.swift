//
//  RegSignUpViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/16.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class RegSignUpViewController: BaseViewController {

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    var tfs = [UITextField]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tfs = [firstNameTF,lastNameTF,emailTF,passwordTF]
        
        for tf in tfs {
            let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            tf.leftViewMode = .Always
            tf.leftView = spacerView
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        firstNameTF.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action

    @IBAction func close(sender: AnyObject) {
        for tf in tfs {
            tf.resignFirstResponder()
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signUp(sender: AnyObject) {
        if validate() == false {
            return
        }
        
        for tf in tfs {
            tf.resignFirstResponder()
        }
        
        Util.showMessage("登録")
        
        ApiController.signUp(email: emailTF.text, password: passwordTF.text, firstName: firstNameTF.text, lastName: lastNameTF.text) { (error) -> Void in
            if let error = error {
                Util.showError(error)
            }
            
             Util.showMessage("ログイン")
            
            ApiController.login(email: self.emailTF.text, password: self.passwordTF.text, done: { (error) -> Void in
                if let error = error {
                    Util.showError(error)
                    return
                }
                
                if let preAccount = Defaults["email"].string where self.emailTF.text != preAccount {
                    DBController.clearDB()
//                    DBController.createUser(email: self.emailTF.text, id: Defaults["myId"].string!)
                }
                
                Defaults["email"] = self.emailTF.text
                Defaults["shouldAutoLogin"] = true
                
                SSKeychain.setPassword(self.passwordTF.text, forService: kTomoService, account: self.emailTF.text)
                
                //get user detail
                ApiController.getUserInfo(Defaults["myId"].string!, done: { (error) -> Void in
                    if error == nil{
                        Util.dismissHUD()
                        
                        let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
                        
                        Util.changeRootViewController(from: self, to: tab)
                    }
                })
            })
        }
    }
    
    // MARK: - support
    
    func validate() -> Bool {
        for tf in tfs {
            if tf.text.length == 0 {
                return false
            }
        }
        
        if emailTF.text.isEmail() == false {
            return false
        }
        
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

// MARK: - UITextFieldDelegate

extension RegSignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let index = find(tfs, textField)!
        
        if index == tfs.count - 1 {
            signUp(textField)
            return true
        }
        
        tfs[index+1].becomeFirstResponder()
        
        return true
    }
}