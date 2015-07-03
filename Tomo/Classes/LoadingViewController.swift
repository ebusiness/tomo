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
        
        OpenidController.instance.wxCheckAuth({ (res) -> () in
            
            if let uid = res["_id"] as? String {
                ApiController.getMyInfo({ (error) -> Void in
                    if let err = error{
                        Util.showError(err)
                    } else {
                        if let user = DBController.myUser() {//auto login
                            Defaults["shouldAutoLogin"] = true
                        }
                        let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
                        Util.changeRootViewController(from: self, to: tab)
                    }
                })
            }
        }, failure: { (errCode, errMessage) -> () in

        })
    }

}
