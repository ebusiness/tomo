//
//  RegLoginViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/02.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class RegLoginViewController: BaseViewController {
    
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        
        loginBtn.layer.borderColor = UIColor.whiteColor().CGColor
        loginBtn.layer.borderWidth = 1
        loginBtn.layer.cornerRadius = 2
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
    
    class func changeRootToTab(from:UIViewController){
        Util.dismissHUD()
        let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
        Util.changeRootViewController(from: from, to: tab)
    }
    
}
