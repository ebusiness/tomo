//
//  BaseViewController.swift
//  spot
//
//  Created by 張志華 on 2015/02/04.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        
//        if let setting_tag = Defaults["setting_tag"].string where setting_tag == "set" {
//        }else{
//            let tagSetting = Util.createViewControllerWithIdentifier("TagSettingController", storyboardName: "Setting") as! TagSettingController
//            tagSetting.submitHandler = {()->() in
//                Defaults["setting_tag"] = "set"
//                
//                // TODO: system recommended friend list
//                ApiController.getUsers({ (users, error) -> Void in
//                    if let users = users {
//                        let vc = Util.createViewControllerWithIdentifier("FriendListViewController", storyboardName: "Chat") as! NewFriendListViewController
////                        vc.displayMode = .SearchResult
//                        vc.users = users
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
//                })
//            }
//            self.presentViewController(tagSetting, animated: true, completion: nil)
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")
        
        #if DEBUG
            Util.showInfo("メモリー不足")
        #endif
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    deinit {
        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}