//
//  TabBarController.swift
//  spot
//
//  Created by 張志華 on 2015/02/04.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

enum TabItem: Int {
    case Home, Contacts, Group, Map, Setting
    
    static let items = [Home, Contacts, Group, Map, Setting]
//    static let items = [Home, Contacts, Map, Setting]
    
    func storyBoardName() -> String {
        switch self {
        case .Home:
            return "Home"
        case .Contacts:
            return "Contacts"
        case .Group:
            return "Group"
        case .Map:
            return "Map"
        case .Setting:
            return "Setting"
        }
    }
    
    func tabImage() -> UIImage {
        var imageName: String
        
        switch self {
        case .Home:
            imageName = "template"
        case .Contacts:
            imageName = "chat"
        case .Group:
            imageName = "group"
        case .Map:
            imageName = "worldwide_location"
        case .Setting:
            imageName = "home"
        }
        
        return UIImage(named: imageName)!
    }
    
}

final class TabBarController: UITabBarController {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViewControllers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SocketController.connect()
        
        //local
        updateBadgeNumber()

        Util.setupPush()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URLSchemesController.sharedInstance.runTask()
        RemoteNotification.sharedInstance.runTask()
    }
    
    deinit {
        SocketController.disconnect()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension TabBarController {
    
    private func setupViewControllers() {
        var viewControllers = [UIViewController]()
        
        for tabItem in TabItem.items {
            let vc = Util.createViewControllerWithIdentifier(nil, storyboardName: tabItem.storyBoardName())
            
            vc.tabBarItem = UITabBarItem(title: nil, image: tabItem.tabImage(), selectedImage: tabItem.tabImage())
            vc.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            viewControllers.append(vc)
        }
        self.tabBar.barTintColor = UIColor.whiteColor()
//        self.tabBar.tintColor = Util.UIColorFromRGB(0x1976D2, alpha: 1)
        
        self.viewControllers = viewControllers
        
    }
    
    // MARK: - Notification
    
    func updateBadgeNumber() {
        
        if let vc = viewControllers?[1] as? UIViewController {
            let messageCount = me.friendInvitations.count + me.newMessages.count
            if messageCount > 0 {
                vc.tabBarItem.badgeValue = String(messageCount)
            } else {
                vc.tabBarItem.badgeValue = nil
            }
        }
        
        if let vc = viewControllers?.last as? UIViewController {
            if me.notifications > 0 {
                vc.tabBarItem.badgeValue = String(me.notifications)
            } else {
                vc.tabBarItem.badgeValue = nil
            }
        }
    }
}

