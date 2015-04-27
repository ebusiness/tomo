//
//  TabBarController.swift
//  spot
//
//  Created by 張志華 on 2015/02/04.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

enum TabItem: Int {
    case Home, Chat, Group, Map, Account
    
    static let items = [Home, Chat, Group, Map, Account]
    
    func storyBoardName() -> String {
        switch self {
        case .Home:
            return "Newsfeed"
        case .Chat:
            return "Chat"
        case .Group:
            return "Group"
        case .Map:
            return "Map"
        case .Account:
            return "Account"
        }
    }
    
    func tabImage() -> UIImage {
        var imageName: String
        
        switch self {
        case .Home:
            imageName = "tab_home"
        case .Chat:
            imageName = "tab_chat"
        case .Group:
            imageName = "tab_group"
        case .Map:
            imageName = "tab_map"
        case .Account:
            imageName = "tab_setting"
        }
        
        return UIImage(named: imageName)!
    }
    
    func tabTitle() -> String {
        switch self {
        case .Home:
            return "ホーム"
        case .Chat:
            return "トーク"
        case .Group:
            return "グループ"
        case .Map:
            return "マップ"
        case .Account:
            return "設定"
        }
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
            vc.tabBarItem = UITabBarItem(title: tabItem.tabTitle(), image: tabItem.tabImage(), selectedImage: tabItem.tabImage())
            //            vc.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            viewControllers.append(vc)
        }
        
        self.viewControllers = viewControllers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("[\(String.fromCString(object_getClassName(self))!)][\(__LINE__)][\(__FUNCTION__)]")

        SocketController.start()

        Util.setupPush()
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
    }
}
