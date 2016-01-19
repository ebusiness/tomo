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

    case Map

    case Setting

    static let items = [Home, Contacts, Map, Setting]
    
    var storyBoard: String {
        switch self {
        case .Home:
            return "Home"
        case .Contacts:
            return "Contacts"
        case .Map:
            return "Map"
        case .Setting:
            return "Setting"
        }
    }
    
    var image: UIImage {
        switch self {
        case .Home:
            return UIImage(named: "home_line")!
        case .Contacts:
            return UIImage(named: "speech_bubble")!
        case .Map:
            return UIImage(named: "globe")!
        case .Setting:
            return UIImage(named: "user_male_circle")!
        }
    }

    var title: String {
        switch self {
        case .Home:
            return "动态"
        case .Contacts:
            return "聊天"
        case .Map:
            return "地图"
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

