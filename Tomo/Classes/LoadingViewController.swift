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
        
        Util.showHUD()
        
        OpenidController.instance.wxCheckAuth(
            
            success: { (res) -> () in
                let tab = Util.createViewControllerWithIdentifier(nil, storyboardName: "Tab")
                Util.changeRootViewController(from: self, to: tab)
            },
            failure: { (errCode, errMessage) -> () in
                let main = Util.createViewControllerWithIdentifier(nil, storyboardName: "Main")
                Util.changeRootViewController(from: self, to: main)
            })
    }

}
