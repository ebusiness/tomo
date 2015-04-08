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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
         setupViewControllers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.delegate = self

       
        
//        self.navigationItem.hidesBackButton = true
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
