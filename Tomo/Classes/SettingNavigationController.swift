//
//  SettingNavigationController.swift
//  Tomo
//
//  Created by joehetfield on 2016/02/02.
//  Copyright © 2016 e-business. All rights reserved.
//

import UIKit

class SettingNavigationController: UINavigationController {

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)

        // attach event observer when init, so they start to work as TabController initiated. do this in viewDidLoad will be too late.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SettingNavigationController.updateTabBarItemBadgeInMainThread),
                                               name: NSNotification.Name(rawValue: "didMyFriendInvitationAccepted"), object: me)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SettingNavigationController.updateTabBarItemBadgeInMainThread),
                                               name: NSNotification.Name(rawValue: "didMyFriendInvitationRefused"), object: me)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SettingNavigationController.updateTabBarItemBadgeInMainThread),
                                               name: NSNotification.Name(rawValue: "didFriendBreak"), object: me)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SettingNavigationController.updateTabBarItemBadgeInMainThread),
                                               name: NSNotification.Name(rawValue: "didReceivePost"), object: me)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SettingNavigationController.updateTabBarItemBadgeInMainThread),
                                               name: NSNotification.Name(rawValue: "didPostLiked"), object: me)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SettingNavigationController.updateTabBarItemBadgeInMainThread),
                                               name: NSNotification.Name(rawValue: "didPostCommented"), object: me)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SettingNavigationController.updateTabBarItemBadgeInMainThread),
                                               name: NSNotification.Name(rawValue: "didPostBookmarked"), object: me)

        // this event is not come from background thread
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SettingNavigationController.updateTabBarItemBadge),
                                               name: NSNotification.Name(rawValue: "didCheckAllNotification"), object: me)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func updateTabBarItemBadgeInMainThread() {
        gcd.sync(.main) {
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
