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
        
        ApiController.login(tomoid: emailTF.text, password: passwordTF.text) { (error) -> Void in
            assert(NSThread.currentThread().isMainThread, "not main thread")
            
            if let error = error {
                //Util.showError(error)
                Util.showInfo("ユーザIDとパースワードを確かめて、もう一度ご入力ください。", maskType: .Clear)
                return
            }
            
            if let preAccount = Defaults["email"].string where self.emailTF.text != preAccount {
                DBController.clearDB()
//                DBController.createUser(email: self.emailTF.text, id: Defaults["myId"].string!)
            }
            
            Defaults["email"] = self.emailTF.text
            Defaults["shouldAutoLogin"] = true
            Defaults["shouldTypeLoginInfo"] = false;
            
            SSKeychain.setPassword(self.passwordTF.text, forService: kTomoService, account: self.emailTF.text)
            
            //get user detail
            ApiController.getMyInfo({ (error) -> Void in
                if error == nil{
                    RegLoginViewController.changeRootToTab(self)
                }
            })
        }
    }
    @IBAction func login_qq(sender: AnyObject) {
        OpenidController.instance.qqCheckAuth({ (result) -> () in
            self.loginCheck(result)
            
            }, failure: { (errCode, errMessage) -> () in
                
                println(errCode)
                println(errMessage)
                
        })
    }
    
    @IBAction func login_wechat(sender: AnyObject) {
        OpenidController.instance.wxCheckAuth({ (result) -> () in
            self.loginCheck(result)
            
        }, failure: { (errCode, errMessage) -> () in
            
            println(errCode)
            println(errMessage)
            
        })
    }
    func loginCheck(result: Dictionary<String, AnyObject>){
        Util.showMessage("ログイン")
//        if Defaults["shouldTypeLoginInfo"].bool == true {
//            Util.showInfo("Tomoid、またパスワードが変更されましたため、ご入力ください。")
//            return;
//        }
        for tf in tfs {
            tf.resignFirstResponder()
        }
        if let uid = result["_id"] as? String {
            ApiController.getMyInfo({ (error) -> Void in
                if let err = error{
                    Util.showError(err)
                } else {
                    if let user = DBController.myUser() {//auto login
                        Defaults["email"] = user.tomoid
                        Defaults["shouldAutoLogin"] = true
                    }
                    RegLoginViewController.changeRootToTab(self)
                }
            })
        }else{
            let password = NSUUID().UUIDString
            var tomoid = NSUUID().UUIDString
            if let openid = result["openid"] as? String ,type = result["type"] as? String {
                tomoid = openid + "@" + type
                OpenidController.instance.getUserInfo(type, done: { (openidInfo) -> Void in
                    var nickname = tomoid
                    if let oinfo = openidInfo{
                        nickname = oinfo["nickname"] as! String
                    }
                    
                    
                    ApiController.signUp(email: tomoid, password: password, firstName: nickname, lastName: type) { (error) -> Void in
                        if let error = error {
                            Util.showError(error)
                        }
                        
                        if let preAccount = Defaults["email"].string where tomoid != preAccount {
                            DBController.clearDB()
                        }
                        
                        Defaults["email"] = tomoid
                        Defaults["shouldAutoLogin"] = true
                        
                        SSKeychain.setPassword(password, forService: kTomoService, account: tomoid)
                        
                        ApiController.addOpenid(result, done: { (error) -> Void in
                            println(error)
                        })
                        //get user detail
                        ApiController.getMyInfo({ (error) -> Void in
                            if error == nil{
                                RegLoginViewController.changeRootToTab(self)
                                
                            }
                        })
                    }
                })
            }
        }
        

    }
    // MARK: - support
    
    func validate() -> Bool {
        for tf in tfs {
            if tf.text.length == 0 {
                return false
            }
        }
        
//        if emailTF.text.isEmail() == false {
//            return false
//        }
        
        return true
    }
    
    class func changeRootToTab(from:UIViewController){
        Util.dismissHUD()
        let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
        Util.changeRootViewController(from: from, to: tab)
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

