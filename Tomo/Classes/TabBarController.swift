//
//  TabBarController.swift
//  spot
//
//  Created by 張志華 on 2015/02/04.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

enum TabItem: Int {

    case Home

    case Contacts

    case Chat

    case Group

    case Setting

    static let items = [Home, Contacts, Chat, Group, Setting]
    
    var storyBoard: String {
        switch self {
        case .Home:
            return "Home"
        case .Contacts:
            return "Contacts"
        case .Chat:
            return "Chat"
        case .Group:
            return "Group"
        case .Setting:
            return "Setting"
        }
    }
    
    var image: UIImage {
        switch self {
        case .Home:
            return UIImage(named: "home")!
        case .Contacts:
            return UIImage(named: "address_book")!
        case .Chat:
            return UIImage(named: "speech_bubble")!
        case .Group:
            return UIImage(named: "group")!
        case .Setting:
            return UIImage(named: "user_male_circle")!
        }
    }

    var title: String {
        switch self {
        case .Home:
            return "动态"
        case .Contacts:
            return "通讯录"
        case .Chat:
            return "聊天"
        case .Group:
            return "群组"
        case .Setting:
            return "我"
        }
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
            let vc = Util.createViewControllerWithIdentifier(nil, storyboardName: tabItem.storyBoard)
            vc.tabBarItem = UITabBarItem(title: tabItem.title, image: tabItem.image, selectedImage: tabItem.image)
            viewControllers.append(vc)
        }

        self.tabBar.barTintColor = UIColor.whiteColor()
        
        self.viewControllers = viewControllers
        
    }
    
    // MARK: - Notification
    
    func updateBadgeNumber() {
        
        if let vc = viewControllers?[1] {
            let messageCount = me.friendInvitations.count + me.newMessages.count
            if messageCount > 0 {
                vc.tabBarItem.badgeValue = String(messageCount)
            } else {
                vc.tabBarItem.badgeValue = nil
            }
        }
        
        if let vc = viewControllers?.last {
            if me.notifications > 0 {
                vc.tabBarItem.badgeValue = String(me.notifications)
            } else {
                vc.tabBarItem.badgeValue = nil
            }
        }
    }
}

