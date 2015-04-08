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
        
        SVProgressHUD.showWithStatus("ログイン", maskType: .Clear)
        
        let email = Defaults["email"].string!
        let password = SSKeychain.passwordForService(kTomoService, account: email)
        
        ApiController.login(email: email, password: password) { (error) -> Void in
            assert(NSThread.currentThread().isMainThread, "not main thread")
            
            if let error = error {
                Util.showError(error)
                return
            }
            
            SVProgressHUD.dismiss()
            
            let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
            
            Util.changeRootViewController(from: self, to: tab)
        }
    }

}
