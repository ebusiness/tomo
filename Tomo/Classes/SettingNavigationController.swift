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

        // attach event observer when init, so they start to work as TabController initiated. do this in viewDidLoad will be too late.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadgeInMainThread", name: "didMyFriendInvitationAccepted", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadgeInMainThread", name: "didMyFriendInvitationRefused", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadgeInMainThread", name: "didFriendBreak", object: me)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadgeInMainThread", name: "didReceivePost", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadgeInMainThread", name: "didPostLiked", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadgeInMainThread", name: "didPostCommented", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadgeInMainThread", name: "didPostBookmarked", object: me)

        // this event is not come from background thread
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTabBarItemBadge", name: "didCheckAllNotification", object: me)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func updateTabBarItemBadgeInMainThread() {
        gcd.sync(.Main) {
            if me.notifications > 0 {
                self.tabBarItem.badgeValue = String(me.notifications)
            } else {
                self.tabBarItem.badgeValue = nil
            }
        }
    }

    func updateTabBarItemBadge() {
        if me.notifications > 0 {
            self.tabBarItem.badgeValue = String(me.notifications)
        } else {
            self.tabBarItem.badgeValue = nil
        }
    }
}
