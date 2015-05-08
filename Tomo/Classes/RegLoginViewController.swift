//
//  RegLoginViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/02.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class RegLoginViewController: BaseViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    var tfs = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tfs = [emailTF,passwordTF]
        
        for tf in tfs {
            let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            tf.leftViewMode = .Always
            tf.leftView = spacerView
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let email = Defaults["email"].string {
            emailTF.text = email
            passwordTF.becomeFirstResponder()
        } else {
            emailTF.becomeFirstResponder()
        }
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
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func login(sender: AnyObject) {
        if validate() == false {
            return
        }
        
        Util.showHUD()
        
        ApiController.login(email: emailTF.text, password: passwordTF.text) { (error) -> Void in
            assert(NSThread.currentThread().isMainThread, "not main thread")
            
            if let error = error {
                Util.showError(error)
                return
            }
            
            if let preAccount = Defaults["email"].string where self.emailTF.text != preAccount {
                DBController.clearDB()
//                DBController.createUser(email: self.emailTF.text, id: Defaults["myId"].string!)
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
        }
    }
    @IBAction func login_qq(sender: AnyObject) {
        OpenidController.instance.qqCheckAuth({ (result) -> () in
            self.loginCheck(result)
            
            }, failure: { (errCode, errMessage) -> () in
                
                Util.showInfo(errMessage)
                println(errCode)
                println(errMessage)
                
        })
    }
    
    @IBAction func login_wechat(sender: AnyObject) {
        OpenidController.instance.wxCheckAuth({ (result) -> () in
            self.loginCheck(result)
            
        }, failure: { (errCode, errMessage) -> () in
            
            Util.showInfo(errMessage)
            println(errCode)
            println(errMessage)
            
        })
    }
    func loginCheck(result: Dictionary<String, AnyObject>){
        for tf in tfs {
            tf.resignFirstResponder()
        }
        if let uid = result["_id"] as? String {
            ApiController.getUserInfo(uid, done: { (error) -> Void in
                if let err = error{
                    Util.showError(err)
                } else {
                    if let user = DBController.myUser() {//auto login
                        Defaults["email"] = user.email
                        Defaults["shouldAutoLogin"] = true
                    }
                    let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
                    
                    Util.changeRootViewController(from: self, to: tab)
                }
            })
        }else{
            self.performSegueWithIdentifier("regist",sender: result)
        }
        

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let view = segue.destinationViewController as? RegSignUpViewController{
            view.openidInfo = sender as? Dictionary<String, AnyObject>
            println(sender);
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
    
}


// MARK: - UITextFieldDelegate

extension RegLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let index = find(tfs, textField)!
        
        if index == tfs.count - 1 {
            login(textField)
            return true
        }
        
        tfs[index+1].becomeFirstResponder()
        
        return true
    }
}

