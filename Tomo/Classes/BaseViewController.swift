//
//  BaseViewController.swift
//  spot
//
//  Created by 張志華 on 2015/02/04.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    let manager = RKObjectManager(baseURL: kAPIBaseURL)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMapping()
        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")
        
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
        
        
        let backitem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backitem
        
        let backimage = UIImage(named: "back")!
        navigationController?.navigationBar.backIndicatorImage = backimage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backimage
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.barStyle = .Black
        //        if let left = self.navigationController?.navigationItem.backBarButtonItem {
        //            println(left.title)
        //        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")
        
        #if DEBUG
            Util.showInfo("メモリー不足")
        #endif
    }
    
    deinit {
        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupMapping(){
    
    }
}