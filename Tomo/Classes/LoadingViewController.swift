//
//  LoadingViewController.swift
//  spot
//
//  Created by 張志華 on 2015/03/03.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class LoadingViewController: BaseViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Util.showMessage("ログイン")
        
        let email = Defaults["email"].string!
        let password = SSKeychain.passwordForService(kTomoService, account: email)
        
        ApiController.login(tomoid: email, password: password) { (error) -> Void in
            assert(NSThread.currentThread().isMainThread, "not main thread")
            
            if let error = error {
                Defaults["shouldAutoLogin"] = false
//                Util.showError(error)
//                Util.showInfo("ユーザIDとパースワードを確かめて、もう一度ご入力ください。", maskType: .Clear)
                let main = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
                Util.changeRootViewController(from: self, to: main)
                return
            }
            
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

}
