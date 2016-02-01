//
//  SettingNavigationController.swift
//  Tomo
//
//  Created by joehetfield on 2016/02/02.
//  Copyright © 2016年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class SettingNavigationController: UINavigationController {

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadge", name: ListenerEvent.FriendAccepted.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadge", name: ListenerEvent.FriendRefused.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadge", name: ListenerEvent.FriendBreak.rawValue, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadge", name: ListenerEvent.PostNew.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadge", name: ListenerEvent.PostLiked.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadge", name: ListenerEvent.PostCommented.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadge", name: ListenerEvent.PostBookmarked.rawValue, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func updateTabBarItemBadge() {
        gcd.sync(.Main) {
            self.tabBarItem.badgeValue = String(me.notifications + 1)
        }
    }
}
