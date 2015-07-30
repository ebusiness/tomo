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
        self.viewControllers = viewControllers
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")

//        ApiController.getStations { (error) -> Void in
//        }
        
        //local
        updateBadgeNumber()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateBadgeNumber"), name: kNotificationGotNewMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateBadgeNumber"), name: kNotificationGotNewAnnouncement, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("becomeActive"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        SocketController.start()

        Util.setupPush()
        
        //update
        ApiController.getMessage { (error) -> Void in
            self.updateBadgeNumber()
        }
    }
    
    // MARK: - Notification
    
    func updateBadgeNumber() {
        let count = DBController.unreadCountTotal()
        if count > 0 {
            if let vc = viewControllers?[1] as? UIViewController {
                vc.tabBarItem.badgeValue = String(count)
            }
        } else {
            if let vc = viewControllers?[1] as? UIViewController {
                vc.tabBarItem.badgeValue = nil
            }
        }
        
        let unreadAnnouncementsCount = DBController.unreadAnnouncementsCount()
        if unreadAnnouncementsCount > 0 {
            if let vc = viewControllers?[3] as? UIViewController {
                vc.tabBarItem.badgeValue = String(unreadAnnouncementsCount)
            }
        } else {
            if let vc = viewControllers?[3] as? UIViewController {
                vc.tabBarItem.badgeValue = nil
            }
        }
    }
    
    func becomeActive() {
        ApiController.getMessage({ (error) -> Void in
            self.updateBadgeNumber()
        })
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
        SocketController.stop()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
