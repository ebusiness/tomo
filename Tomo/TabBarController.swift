//
//  TabBarController.swift
//  spot
//
//  Created by 張志華 on 2015/02/04.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    let storyBoardNames = ["Newsfeed","Map","Chat","Account"]
    let tabImageNames = ["tab_share","tab_map","tab_chat","tab_person"]
    let tabImageNamesHL = ["tab_share","tab_map","tab_chat","tab_person"]
    
    var socket:AZSocketIO!

    override func awakeFromNib() {
        super.awakeFromNib()
        
         setupViewControllers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSocket()

        setupPush()
//        self.delegate = self

       
        
//        self.navigationItem.hidesBackButton = true
    }

    
    func setupSocket() {
        
        socket = AZSocketIO(host: "tomo.e-business.co.jp", andPort: "80", secure: false)
        
        socket.eventRecievedBlock = { (name, data) -> Void in

            if name == "message-new" {
                /*
                let array = data as! NSArray
                
                for dic in array {
                    ChatController.addChat(dic as! NSDictionary)
                }
                
                ChatController.save(done: { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("GotNewMessage", object: nil)
                })*/
                
                ApiController.getMessage({ (error) -> Void in
                    
                })
            }
        }
        
        socket.connectWithSuccess({ () -> Void in
            println("connectWithSuccess")
            }, andFailure: { (error) -> Void in
                println(error)
        })
        
    }
    
    func setupPush() {
        var types: UIUserNotificationType = UIUserNotificationType.Badge |
            UIUserNotificationType.Alert |
            UIUserNotificationType.Sound
        
        var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )
        
        let application = UIApplication.sharedApplication()
        application.registerUserNotificationSettings( settings )
        application.registerForRemoteNotifications()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        println("[\(String.fromCString(object_getClassName(self))!)][\(__FUNCTION__)]")
    }
    
    private func setupViewControllers() {
        var viewControllers = [UIViewController]()
        
        for (i, name) in enumerate(storyBoardNames) {
            let vc = Util.createViewControllerWithIdentifier(nil, storyboardName: name)
            vc.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: self.tabImageNames[i]), selectedImage: UIImage(named: self.tabImageNamesHL[i]))
            vc.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            viewControllers.append(vc)
        }
        
        self.viewControllers = viewControllers
    }

}

//extension TabBarController: UITabBarControllerDelegate {
//    
//    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
//        if viewController is UINavigationController {
//            if (viewController as UINavigationController).topViewController is ContactDetailViewController {
//                (viewController as UINavigationController).popViewControllerAnimated(false)
//            }
//        }
//        
//        return true
//    }
//}
