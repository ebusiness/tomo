//
//  TabBarController.swift
//  spot
//
//  Created by 張志華 on 2015/02/04.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

enum TabItem: Int {
    case Home, Chat, Group, Map, Setting
    
//    static let items = [Home, Chat, Group, Map, Setting]
    static let items = [Home, Chat, Map, Setting]
    
    func storyBoardName() -> String {
        switch self {
        case .Home:
            return "Home"
        case .Chat:
            return "Chat"
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
            imageName = "home"
        case .Chat:
            imageName = "speech_bubble"
        case .Group:
            imageName = "group"
        case .Map:
            imageName = "globe"
        case .Setting:
            imageName = "user_male_circle"
        }
        
        return UIImage(named: imageName)!
    }
    
}

class TabBarController: UITabBarController {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        var viewControllers = [UIViewController]()
        
        for tabItem in TabItem.items {
            let vc = Util.createViewControllerWithIdentifier(nil, storyboardName: tabItem.storyBoardName())
            vc.tabBarItem = UITabBarItem(title: nil, image: tabItem.tabImage(), selectedImage: tabItem.tabImage())
            vc.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            viewControllers.append(vc)
        }
        self.tabBar.barTintColor = UIColor.whiteColor()
        self.tabBar.tintColor = Util.UIColorFromRGB(0x1976D2, alpha: 1)
        self.viewControllers = viewControllers
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SocketController.connect()
        
        //local
        updateBadgeNumber()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("becomeActive"), name: UIApplicationDidBecomeActiveNotification, object: nil)

        Util.setupPush()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URLSchemesController.instance.runTask()
    }
    
    // MARK: - Notification
    
    func updateBadgeNumber() {

        var invitationCount = me.friendInvitations.count ?? 0
        var messageCount = me.newMessages.count
        
        if let vc = viewControllers?[1] as? UIViewController {
            if invitationCount + messageCount > 0 {
                vc.tabBarItem.badgeValue = String(invitationCount + messageCount)
            } else {
                vc.tabBarItem.badgeValue = nil
            }
        }
    }
    
    func becomeActive() {
        // recalculate badge number
    }
    
    deinit {
        SocketController.disconnect()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
